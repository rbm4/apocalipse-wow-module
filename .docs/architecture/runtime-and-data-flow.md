# Runtime and data flow

Status: Active

Last source review: 2026-09-17

## Startup

```text
AzerothCore discovers Addapocalipse_wow_moduleScripts()
  -> registers gameplay systems
  -> database custom-table hooks load spec and scaling caches
  -> startup/config hooks load PvP and battleground settings
  -> spell scripts are available when their SQL bindings and spell rows exist
```

### Startup-owned state

| State | Loaded by | Source | Refresh behavior |
|---|---|---|---|
| `g_specSpells` | `ModApocalipseWorld::OnLoadCustomDatabaseTable` | `acore_world.mod_spec_spells` | Worldserver restart or another invocation of the custom-table hook |
| Four scaling maps | `SpellScalingWorld::OnLoadCustomDatabaseTable` | `acore_world.mod_spell_scaling` | Worldserver restart or another invocation of the custom-table hook |
| PvP percentages | `ModApocalipsePvPWorld` | `Apocalipse.PvP*` config keys | Startup and config reload |
| Battleground settings and aura validity | `BattlegroundStaminaWorldScript` | `Apocalipse.BattlegroundStamina.*` and loaded spell data | Startup and config reload; active auras are not swept immediately |

## Player lifecycle

### Login and talent changes

`ModSpecPlayer` reconciles the dominant talent tree on login and after each talent learn. It persists the granted spec and hidden talent budget in the character database. A per-GUID in-progress set prevents recursive reconciliation. Talent reset processing also has a one-second per-GUID throttle.

`BattlegroundStaminaPlayerScript` reacts to login, level, map, equipment, spec-slot, talent, and resurrection events. It applies or removes assistance according to the player's current battleground state.

Both scripts subscribe to login and talent-related flows. The loader registers Spec Manager first and Battleground Stamina last, but maintainers should not build correctness around undocumented global callback ordering. Each handler must remain safe when the other has already run or has not run yet.

### Battleground lifecycle

```text
non-arena battleground add/map/login recovery
  -> ApplyAssistance
     -> validate eligibility and cached spell readiness
     -> calculate baseline without active stamina/health buffs
     -> calculate minimum whole stamina for configured partial gap coverage
     -> cast or update aura 901002
     -> preserve current-health no-free-heal invariant

battleground leave or unsupported state
  -> RemoveAssistance
```

Human equipment changes are blocked for items that AzerothCore does not consider combat-swappable. Bot sessions bypass this lock. Successful bot or allowed human equipment changes invoke the equip hooks and recalculate assistance.

## Combat value composition

### Direct spell damage

The loader registers spell scaling before PvP balancing. Both hooks mutate the same damage value.

```text
base direct spell damage
  -> SpellScalingUnit for configured DAMAGE spell IDs
  -> ModPvPUnitScript when attacker is a player/player-owned unit and victim is a player
  -> final damage
```

The reductions are multiplicative, but each stage converts to an integer. Registration or dispatch-order changes can therefore alter rounding even when the mathematical factors commute.

### Periodic damage

Configured `PERIODIC` scaling and PvP balancing both mutate periodic tick damage. A missing attacker skips both modules' periodic behavior. Document and test any new periodic hook against both systems.

Pyroclastic Chain Reaction reuses normal Living Bomb ranks for its spread applications. Their ticks continue through the existing periodic scaling and PvP paths. Its special explosion reuses the matching Living Bomb explosion rank and retains the existing direct-damage hook composition.

### Mage proc interaction

```text
Pyroblast effect 0 hit
  -> passive 901003 and same-caster Living Bomb guards
  -> 20 percent roll from passive effect amount
  -> source Living Bomb refresh
  -> matching-rank Living Bomb explosion
  -> up to two random unbombed explosion-hit survivors receive the source rank
```

Normal Living Bomb expiration and dispel explosions do not spread. The spread script requires the explosion cast to identify passive 901003 as its triggering spell.

```text
Missile Barrage proc aura 44401 with passive 901004
  -> count applications and reapplications up to 20
  -> expose the count through proc charges
  -> add 500 ms of channel duration for each proc after the first
  -> Arcane Missiles starts with normal interval and mana modifiers
  -> multi-proc release plays visual-only spell 35426 on the target
  -> existing proc pipeline removes the complete accumulated aura
```

The overload script changes channel duration but does not change missile damage. Each added periodic trigger continues through the normal Arcane Missiles damage, threat, crit, scaling, and PvP paths.

```text
Hypernova 901005 cast on an enemy unit
  -> play Arcane Explosion Visual 35426 at the selected target
  -> damage enemies within 10 yards through the Arcane direct-damage path
  -> displace eligible enemies through destination knockback effect 144
  -> schedule four stacks of Arcane Blast aura 36032 after current cast procs
```

Hypernova uses the Arcane Explosion family bit, so appropriate Arcane talents and the normal 36032 consumption contract apply. Its 2.856 coefficient and base range are four times Arcane Blast rank 4. The Spell Scaling table does not modify it, while PvP balancing and the core AoE cap remain active.

```text
Prismatic Barrier 901006 cast on self
  -> trigger Mana Shield rank 9, spell 43020
  -> trigger Ice Barrier rank 8, spell 43039
  -> trigger Blazing Barrier, spell 901001
  -> each child aura continues through its existing core or module scripts
```

The parent charges 42 percent base mana and owns the 45 second cooldown. Triggered child casts add no cost or cooldown. The parent stores no aura state and the three child spells retain their normal absorb, talent, duration, dispel, and visual paths.

```text
Frost Bomb 901007 cast on an enemy
  -> four-second dummy aura
  -> expiration, enemy dispel, or target death
     -> target-centered Frost damage 901008 within 10 yards
     -> Permafrost-scaled slow 901009 on each living damage victim
```

Frost Bomb's explosion uses the Mage Frostbolt family bit for the existing Frost proc and frozen-target paths. Its triggered explosion permits proc events and deliberately does not copy Living Bomb's target-proc suppression or damage-does-not-break-auras correction. Spell 901009 reads Permafrost effects from rank chain 11175 and triggers existing healing-reduction aura 68391.

```text
Automatic Ice Lance passive 901010
  -> spell_proc selects Mage-family direct Frost damage hits at 10 percent with a 1000 ms cooldown
  -> AuraScript rejects periodic, triggered, Ice Lance, Frost Bomb Explosion, invalid-target, and blocked-line-of-sight events
  -> trigger Ice Lance 30455 with proc events enabled for Fingers of Frost consumption
  -> add one 10-second expiration to haste aura 901011
  -> periodic cleanup sets spell haste to active expiration count, capped at 20
```

The expiration queue belongs to aura 901011 and is memory-only. Its timestamps are not refreshed together, the aura is non-save, and removing passive 901010 removes the haste aura. Humans and bots follow the same bounded combat path.

```text
Frozen Retaliation rank 1 901012 or rank 2 901013
  -> positive incoming combat damage enters PROC_FLAG_TAKEN_DAMAGE
  -> spell_proc rolls 1.5 percent or 3 percent for the active rank
  -> AuraScript casts existing Fingers of Frost aura 44544 on the owner
  -> core Fingers of Frost handling creates or refreshes indicator 74396
```

The proc has no attacker, school, family, class, or phase filter. Melee, ranged, direct spell, periodic, and triggered combat damage can qualify when positive damage remains. Fully prevented damage and the separate environmental damage path do not dispatch the required positive combat-damage proc event. Humans and bots follow the same path.

### Melee, healing, and absorbs

- Melee damage is changed only by PvP balancing.
- Configured direct healing is changed only by spell scaling.
- Configured absorb auras are recalculated and scaled in `SpellScalingUnit::OnAuraApply`.
- Blazing Barrier first derives its absorb from base amount plus fire spell power in its `AuraScript`; spell 901001 is also configured as an `ABSORB` scaling entry.

## Data boundaries

| Database | Objects | Access |
|---|---|---|
| `acore_world` | `mod_spec_spells`, `mod_spell_scaling`, creature 900001, `spell_dbc`, `spell_ranks`, `spell_proc`, `spell_script_names`, `spell_bonus_data`, `spell_custom_attr`, `wotlk_spells` | `WorldDatabase` or core spell loaders |
| `acore_characters` | `mod_player_spec`, `mod_player_spec_talent_budget`, currently unused `mod_player_spec_talent_grant` | `CharacterDatabase` |

`data/mod_apocalipse.sql` explicitly switches from `acore_world` to `acore_characters` before creating the per-character tables. Keep that boundary intact.

## Custom spell graph

| Spell | Server definition | Script binding | Scaling | Client requirement |
|---|---|---|---|---|
| 901001 Blazing Barrier | Manual `data/2026_09_16_01_blazing_barrier.sql` | `spell_apoc_mage_blazing_barrier` from `data/mod_apocalipse.sql` or the manual migration | `ABSORB` row in `mod_spell_scaling` | Matching client `Spell.dbc` and patch |
| 901002 Battleground Stamina Assistance | Automatic module world update under `data/sql/db-world/` | No `spell_script_names` binding | Not in spell scaling | Matching client `Spell.dbc` and patch |
| 901003 Pyroclastic Chain Reaction | Automatic `data/sql/db-world/2026_09_17_00_pyroclastic_chain_reaction.sql` | Pyroblast `-11366` and explosion `-44461` bindings | Reuses normal Pyroblast and Living Bomb paths | Matching client `Spell.dbc` and separate talent data |
| 901004 Missile Barrage Overload | Automatic `data/sql/db-world/2026_09_17_01_missile_barrage_overload.sql` | Exact 44401 and 901004 bindings | Extends normal Arcane Missiles periodic duration without changing missile damage | Matching client `Spell.dbc` and separate talent data |
| 901005 Hypernova | Automatic `data/sql/db-world/2026_09_17_01_hypernova.sql` | `spell_apoc_mage_hypernova` on 901005 | Native Arcane damage, destination knockback, and coefficient 2.856 | Matching client `Spell.dbc`; acquisition is separate |
| 901006 Prismatic Barrier | Automatic `data/sql/db-world/2026_09_17_02_prismatic_barrier.sql` | `spell_apoc_mage_prismatic_barrier` on 901006 | Reuses Mana Shield 43020, Ice Barrier 43039, and Blazing Barrier 901001 | Matching client `Spell.dbc`; acquisition is separate |
| 901007-901009 Frost Bomb graph | Automatic `data/sql/db-world/2026_09_17_03_frost_bomb.sql` | Application, explosion, and slow scripts on their exact IDs | Native Frost direct damage with 0.4 coefficient and Permafrost rank effects | Three matching client `Spell.dbc` rows; acquisition is separate |
| 901010-901011 Automatic Ice Lance graph | Automatic `data/sql/db-world/2026_09_17_04_automatic_ice_lance.sql` | Passive proc and haste scripts on their exact IDs | Reuses Ice Lance 30455 and native spell-haste aura handling | Two matching client `Spell.dbc` rows; passive acquisition is separate |
| 901012-901013 Frozen Retaliation rank chain | Automatic `data/sql/db-world/2026_09_17_05_frozen_retaliation.sql` | Negative -901012 binding covers both `spell_ranks` rows | Rank-specific taken-damage proc chance reuses Fingers of Frost aura 44544 | Two matching client `Spell.dbc` rows with rank labels; acquisition is separate |

A server-only row can provide mechanics but not complete client presentation. A client-only row cannot provide server mechanics.

## Failure and recovery paths

| Failure | Result | Diagnostic or recovery |
|---|---|---|
| Missing custom table | Related cache remains empty | Module warning log; apply manual schema and restart |
| Invalid spell 901002 contract | Battleground assistance is disabled | `[BattlegroundStamina]` error at config load |
| Missing spell 901001 or binding | Blazing Barrier cannot load or validate correctly | Check `spell_dbc` and `spell_script_names` before startup |
| Missing spell 901003 or rank bindings | Pyroclastic Chain Reaction cannot load or does not affect Pyroblast | Check the module updater and `spell_script_names` entries `-11366` and `-44461` |
| Missing talent data for 901003 | The passive exists but cannot be acquired through the intended talent | Deploy matching server and client talent data separately |
| Missing spell 901004 or overload bindings | Missile Barrage remains normal or passive cleanup is absent | Check the module updater and exact 44401 and 901004 script bindings |
| Missing talent data for 901004 | The passive exists but cannot be acquired through the intended talent | Deploy matching server and client talent data separately |
| Missing spell 901005, binding, aura 36032, or visual 35426 | Hypernova cannot load fully or loses its script behavior | Check the Hypernova updater, base DBC, script validation, and client patch |
| Missing spell 901006, binding, or child barrier | Prismatic Barrier cannot load fully or spends its cost without activating barriers | Check the Prismatic Barrier updater, child spell rows, script bindings, and client patch |
| Missing Frost Bomb spell, binding, Permafrost rank chain, or aura 68391 | Frost Bomb fails script validation or loses explosion and slow behavior | Check the Frost Bomb updater, all three bindings, base mage spell data, and client patch |
| Missing Frozen Retaliation rank, `spell_ranks` row, `spell_proc` row, binding, or aura 44544 | One or both ranks fail to load, use the wrong chance, or cannot grant Fingers of Frost | Check both custom rows, the 901012 rank chain, separate proc rows, -901012 binding, base mage spell data, and client patch |
| Missing acquisition data for 901005 | Hypernova exists but cannot be learned normally | Add acquisition through its separately owned workflow |
| Config reload during active battleground | New values are cached but existing auras are not immediately swept | Re-enter battleground, trigger an application hook, or restart according to operator plan |
| Bot lacks a valid session | Bot exception is not detected | Fix bot lifecycle; do not add heuristic fallback |
| Custom spell ID collision | Guarded migration should fail instead of overwriting another spell | Allocate a new ID and update code, SQL, config, scaling data, and docs together |

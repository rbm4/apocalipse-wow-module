# Runtime and data flow

Status: Active

Last source review: 2026-09-18

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

Pyroclastic Chain Reaction reuses normal Living Bomb ranks for its spread applications. Passive 901003 trigger metadata marks those auras as propagated and reduces their calculated periodic amount to 30 percent before the existing periodic scaling and PvP paths. Explosions originating from propagated auras reuse the matching Living Bomb explosion rank and receive the same 30 percent modifier before the existing direct-damage hook composition. Manually applied source bombs remain at full damage.

### Mage proc interaction

```text
Pyroblast effect 0 hit
  -> passive 901003 and same-caster Living Bomb guards
  -> 20 percent roll from passive effect amount
  -> source Living Bomb refresh
  -> matching-rank Living Bomb explosion
  -> up to two random unbombed explosion-hit survivors receive the source rank
     -> propagated ticks and explosions use 30 percent damage
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
  -> refresh an existing ranked Ice Barrier aura
     or trigger Ice Barrier rank 8, spell 43039, when absent
  -> trigger Blazing Barrier, spell 901001
  -> newly applied child auras continue through existing scripts
```

The parent charges 42 percent base mana and owns the 45 second cooldown. Triggered child casts add no cost or cooldown. An existing Ice Barrier keeps its current absorb amount and receives maximum duration, avoiding the core stronger-aura cast rejection without changing normal Ice Barrier behavior.

```text
Frost Bomb 901007 cast on an enemy
  -> four-second dummy aura
  -> expiration, enemy dispel, or target death
     -> bombed target self-casts visual-only Frost Nova 34326
     -> target-centered Frost damage 901008 within 10 yards
     -> Permafrost-scaled slow 901009 on each living damage victim
```

Frost Bomb's explosion uses the Mage Frostbolt family bit for the existing Frost proc and frozen-target paths. Its triggered explosion permits proc events and deliberately does not copy Living Bomb's target-proc suppression or damage-does-not-break-auras correction. Spell 901009 reads Permafrost effects from rank chain 11175 and triggers existing healing-reduction aura 68391.

```text
Automatic Ice Lance passive 901010
  -> spell_proc selects Mage-family Frost damage hits at 10 percent with a 1000 ms cooldown
  -> direct, periodic, and triggered damage can qualify
  -> AuraScript rejects Ice Lance recursion, invalid-target, and blocked-line-of-sight events
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

```text
Divine Storm 53385 with passive 901014
  -> AfterCast schedules a caster-owned one-second event
  -> event requires the player in world, alive, and still affected by 901014
  -> triggered echo 901015 selects up to 12 enemies around the current position
  -> normalized weapon hit, critical strike, and proc results at 55 percent weapon damage
  -> existing spell_pal_divine_storm derives proportional healing from final damage
```

The scheduler is bound only to 53385, so echo 901015 cannot recursively schedule itself. The delayed event stores only the caster GUID and does not retain the original target.

```text
Permanent Seal of Righteousness passive 901016
  -> explicit proc metadata selects melee and magic damage hit events
  -> AuraScript accepts melee auto-attacks, melee abilities, and paladin judgement damage
  -> any active SoR-family dummy aura suppresses the overlay outside marked Divine Toll impacts
  -> stock AP, Holy power, target vulnerability, libram, and weapon-speed formula
  -> triggered SoR damage 25742, doubled on JotJ judgement events
```

The passive retains the Paladin family but has zero family masks, so it never enters `SPELL_SPECIFIC_SEAL` exclusivity, judgement selection, or judgement aura-state handling. Triggered events are enabled for judgement parity, while explicit 25742 and trigger-aura guards prevent recursion. Humans and bots follow the same bounded path.

```text
Divine Steed 901017
  -> four-second dummy and normal 100 percent run-speed auras
  -> Alliance display 14565 or Horde display 20030
  -> UNIT_FIELD_MOUNTDISPLAYID changes without Unit::Mount or UNIT_FLAG_MOUNT
  -> removal clears only the recorded display while not mechanically mounted
  -> logout and map-change hooks remove the aura and reconcile leaked display state
```

The client receives the rider-and-horse composition, but `IsMounted()` remains false. Ordinary casting, auto-attacks, pets, indoor use, action bars, vehicles, and mount collision height are unaffected. Humans and bots follow the same bounded path.

```text
Guardian's Vengeance 901018
  -> critical melee, direct spell damage, or periodic damage event
  -> native proc trigger casts Guardian's Resolve 901019 on the paladin
  -> add one stack and refresh the complete eight-second duration, capped at three

Sacred Vengeance 901020
  -> critical direct or periodic healing event
  -> native proc trigger casts Sacred Fervor 901021 on the paladin
  -> add one stack and refresh the complete eight-second duration, capped at three
```

Guardian's Resolve grants 1 percent all-school damage reduction and 10 flat defense rating per stack. Sacred Fervor grants 2 percent healing done and 10 mp5 per stack. Triggered events may qualify, but Beacon copies 53652 through 53654 cannot crit and therefore do not add a second stack after their critical source heal. Humans and bots follow identical native proc paths.

```text
Extended Arsenal 901022 or 901023
  -> flat SPELLMOD_RANGE of 3 or 6 yards
  -> flat SPELLMOD_JUMP_TARGETS of 1 or 2 targets
  -> Paladin family mask selects Avenger's Shield and Hammer of the Righteous
  -> native chain selection preserves each spell's hop radius and restrictions
```

The checked-in deployment DBC places Avenger's Shield in mask word 1 bit `0x00004000` and Hammer in mask word 2 bit `0x00040000`. Both base spells have a chain target count of three and accept caster spell modifiers. No script, proc row, or combat-time database access is involved, and humans and bots follow identical native paths.

```text
Divine Toll 901024 on a hostile target with a real seal
  -> roll one through five impacts and apply sequence-state aura
  -> execute immediately, then every 500 ms using GUID re-resolution
  -> invalid original target selects nearest valid hostile replacement
  -> transient marker 901025 guarantees ordinary hit checks and scopes exceptions
  -> Justice visual 901026 and debuff 20184
  -> current seal's stock Judgement damage with normal proc events
  -> marked Judgement and seal damage reduced to 50 percent before mitigation
  -> first successful impact clears shared Judgement cooldown category
```

The sequence cancels on caster death, logout, map change, real-seal loss, or cast-lock state. Vengeance and Corruption add a real stack before damage. A marker-scoped exception lets passive 901016 fire beside real SoR. An additive rank-chain check on Judgements of the Wise allows its first marked event and rejects later marked events. Heart of the Crusader, Judgements of the Just, Righteous Vengeance, and generic procs retain normal paths. Humans and bots follow identical behavior, and acquisition remains external.

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
| 901014-901015 Divine Storm Echo graph | Automatic `data/sql/db-world/2026_09_18_02_divine_storm_echo.sql` | Scheduler on 53385 and existing `spell_pal_divine_storm` on 901015 | Delayed normalized 55 percent weapon attack reuses Divine Storm target, proc, and healing paths | Two matching client `Spell.dbc` rows; acquisition references unranked passive 901014 only and echo acquisition is forbidden |
| 901016 Permanent Seal of Righteousness | Automatic `data/sql/db-world/2026_09_18_03_permanent_seal_of_righteousness.sql` | `spell_apoc_paladin_permanent_seal_of_righteousness` on 901016 | Reuses stock SoR damage 25742 and calculation without entering real seal or judgement selection | Matching client `Spell.dbc`; acquisition is separate |
| 901017 Divine Steed | Automatic `data/sql/db-world/2026_09_18_04_divine_steed.sql` | `spell_apoc_paladin_divine_steed` on 901017 plus player lifecycle cleanup | Normal run-speed aura with display-only faction charger and no mounted state | Matching client `Spell.dbc`; acquisition is separate |
| 901018-901021 Paladin Vengeance variants | Automatic `data/sql/db-world/2026_09_18_04_paladin_vengeance_variants.sql` | No script binding; native proc-trigger auras and `spell_proc` rows | Three-stack Protection damage reduction/defense or Holy healing/mp5 buff | Four matching client `Spell.dbc` rows; acquisition references only passives 901018 and 901020 |
| 901022-901023 Extended Arsenal rank chain | Automatic `data/sql/db-world/2026_09_18_05_extended_arsenal.sql` | No script binding; native flat spell modifiers | Adds 3/6 yards and 1/2 chain targets to Hammer of the Righteous and Avenger's Shield | Two matching client `Spell.dbc` rows with rank labels; acquisition is separate |
| 901024-901026 Divine Toll graph | Automatic `data/sql/db-world/2026_09_18_05_divine_toll.sql` | Parent orchestration, -31876 JotW gate, and additive stock-damage bindings | Reuses active-seal Judgement formulas, reduces marked hit damage to 50 percent, and preserves downstream PvP and proc paths | External backend derives matching client data; acquisition and patch deployment are separate |

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
| Missing Divine Storm Echo passive, echo, or binding | Scheduling validation fails, the echo cannot cast, or proportional healing is absent | Check 901014, 901015, both exact bindings, the core Divine Storm script, and client patch |
| Missing permanent SoR passive, proc row, or binding | Overlay damage does not occur or script validation fails | Check 901016, its exact proc and script rows, base SoR damage 25742, and client patch |
| Missing Divine Steed row, binding, or non-save attribute | Sprint validation fails, display lifecycle is absent, or the aura can persist unexpectedly | Check 901017, its exact script and custom-attribute rows, and client patch |
| Missing Vengeance variant row or proc metadata | The corresponding passive cannot add or correctly scale its timed buff | Check 901018 through 901021, the exact `spell_proc` rows, non-save attributes, and client patch |
| Missing Extended Arsenal row or rank metadata | The passive cannot modify range and target count or the higher rank may not replace the lower rank | Check 901022 and 901023, their exact effect masks, the `spell_ranks` rows, and client patch |
| Missing Divine Toll row, marker, visual, or additive binding | The cast fails validation, loses sequencing, permits repeated JotW, or deals unscaled stock damage | Check 901024 through 901026, -31876, all listed damage bindings, and external client export |
| Missing acquisition data for 901005 | Hypernova exists but cannot be learned normally | Add acquisition through its separately owned workflow |
| Config reload during active battleground | New values are cached but existing auras are not immediately swept | Re-enter battleground, trigger an application hook, or restart according to operator plan |
| Bot lacks a valid session | Bot exception is not detected | Fix bot lifecycle; do not add heuristic fallback |
| Custom spell ID collision | Guarded migration should fail instead of overwriting another spell | Allocate a new ID and update code, SQL, config, scaling data, and docs together |

# Runtime and data flow

Status: Active

Last source review: 2026-09-20

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

The application AuraScript makes the bombed target self-cast visual-only spell 34326 before the mage-owned explosion begins. Frost Bomb's explosion deals 1380 base damage with a 0.8 direct coefficient and uses the Mage Frostbolt family bit for the existing Frost proc and frozen-target paths. Its triggered explosion permits proc events and deliberately does not copy Living Bomb's target-proc suppression or damage-does-not-break-auras correction. Spell 901009 reads Permafrost effects from rank chain 11175 and triggers existing healing-reduction aura 68391.

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
  -> Alliance display 14584 or Horde display 19085
  -> UNIT_FIELD_MOUNTDISPLAYID changes without Unit::Mount or UNIT_FLAG_MOUNT
  -> the next successful non-triggered player spell removes aura 901017
  -> removal clears only the recorded display while not mechanically mounted
  -> logout and map-change hooks remove the aura and reconcile leaked display state
```

The client receives the rider-and-horse composition, but `IsMounted()` remains false. Ordinary casts are permitted, then the player spell hook removes Divine Steed after a successful non-triggered cast; triggered children and proc casts are ignored. Auto-attacks, pets, indoor use, action bars, vehicles, and mount collision height are unaffected. Humans and bots follow the same bounded path.

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

```text
Conflagrate rank chain with passive 901027
  -> effect script captures the exact caster-owned Immolate rank
  -> core damage calculation consumes source Immolate unless glyph-protected
  -> post-hit search around the primary target excludes invalid and already affected units
  -> up to three random enemies receive full matching-rank Immolate
```

The capture hook runs before `Spell::EffectSchoolDamage`, while spread runs after the successful single-target hit. Shadowflame can enable normal Conflagrate but cannot supply an Immolate rank. Humans and bots follow the same bounded path with no combat-time database access.

```text
Soul Link aura 25228 processes incoming damage
  -> calculate stock 20 percent split
  -> if passive 901033 is active, replace it with 75 percent of current damage
  -> core caps the transfer to remaining damage
  -> core removes the transfer from the Warlock and damages the living demon
```

Demonic Equilibrium checks the passive per hit, so acquisition and removal take effect without a Soul Link recast. It leaves activation spell 19028, demon eligibility, school filtering, combat logs, and proc dispatch on the stock path. Humans and bots use identical bounded logic with no combat-time database access.

```text
Dispel targets an Immolate or Shadowflame aura from a Warlock with passive 901034
  -> Aura::CalcDispelChance resolves the aura's original caster
  -> native operation 28 matches Immolate word 0 bit 2 or Shadowflame word 2 bit 1
  -> add 100 percent resist-dispel chance and clamp resistance to 100
  -> return zero dispel chance and skip the aura without removing it
```

Unquenchable Flames evaluates the caster's current spell modifiers at each dispel attempt. Existing caster-owned auras become protected when the passive is learned and return to stock dispel behavior when it is removed. Expiration, Conflagrate consumption, death cleanup, immunity cleanup, and scripted removal remain unchanged. Humans and bots use the same native path with no script or combat-time database access.

```text
Dispel targets a matching Warlock aura whose owner has passive 901035
  -> Aura::CalcDispelChance resolves the original caster and spell-mod owner
  -> operation 28 intersects family mask (0xC04CC41A, 0x1804161B, 0)
  -> add 100 percent resist-dispel chance and clamp resistance to 100
  -> return zero dispel chance and skip the aura without removing it
```

Unyielding Shadows covers curses, Corruption, Fear, Howl of Terror, Death Coil, Banish, drains, Seed of Corruption, Shadowfury, Haunt, Shadow Embrace, matching legacy Siphon Life variants, and owner-demon effects. Unstable Affliction's unique word 1 bit `0x00000100` is absent, preserving its stock dispel and backlash path. Existing matching auras react immediately when the passive is learned or removed. Humans and bots use the same native path with no script or combat-time database access.

```text
Chaos Bolt rank chain with passive 901031
  -> successful projectile impact casts helper 901032 at the hit position
  -> ally-category guardian 900002 is created for 20 seconds without replacing PetGUID
  -> stock Inferno Effect 22703 resolves meteor damage and area stun
  -> guardian attacks the impact target and later follows owner assist events
```

The module clone of stock Infernal 89 preserves its model, addon auras, level data, and owner-derived scaling while isolating custom autonomous AI from normal Infernal behavior. Every qualifying hit adds another guardian with no explicit count cap. The 20-second balance lifetime and Chaos Bolt cooldown bound ordinary overlap. Humans and bots share the path, and no combat-time database access occurs.

```text
Haunt rank chain with passive 901028
  -> successful AfterHit rejects active caster marker 901029
  -> apply the non-saved 30-second marker to the caster
  -> cast the highest ranks known in the active specialization
  -> preserve a different same-caster curse by skipping Curse of Agony
  -> preserve same-caster Seed of Corruption by skipping Corruption
  -> apply Unstable Affliction independently
```

The marker makes the cooldown global per Warlock across every target and starts before the DoT applications. Triggered stock casts preserve caster ownership, normal refreshes, Unstable Affliction dispel behavior, and playerbot aura awareness. Humans and bots follow identical behavior, and acquisition remains external.

```text
Demonology Warlock with passive 901030 casts Metamorphosis 59672
  -> stock activation starts the normal cooldown
  -> aura 47241 maximum duration becomes -1
  -> learning 901030 during an active form upgrades the existing aura
  -> death retains stock removal behavior
  -> passive loss, talent reset, login recovery, logout, or mount attempt removes aura 47241
  -> stock aura removal clears linked effects and temporary abilities
```

The global mount cast check removes enhanced Metamorphosis before shapeshift validation so valid mount spells can proceed. A later failed mount check still leaves the form removed, and dismounting never reapplies it. Humans and bots retain the existing 59672 activation and 47241 form checks.

### Melee, healing, and absorbs

- Melee damage is changed only by PvP balancing.
- Configured direct healing is changed only by spell scaling.
- Configured absorb auras are recalculated and scaled in `SpellScalingUnit::OnAuraApply`.
- Blazing Barrier first derives its absorb from base amount plus fire spell power in its `AuraScript`; spell 901001 is also configured as an `ABSORB` scaling entry.

## Data boundaries

| Database | Objects | Access |
|---|---|---|
| `acore_world` | `mod_spec_spells`, `mod_spell_scaling`, creatures 900001 and 900002, `summonproperties_dbc`, `creature_template_model`, `creature_template_addon`, `pet_levelstats`, `spell_dbc`, `spell_ranks`, `spell_proc`, `spell_script_names`, `spell_bonus_data`, `spell_custom_attr`, `wotlk_spells` | `WorldDatabase` or core spell loaders |
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
| 901007-901009 Frost Bomb graph | Automatic baseline plus follow-up updates under `data/sql/db-world/` | Application, explosion, and slow scripts on their exact IDs | Native Frost direct damage with 0.8 coefficient and Permafrost rank effects | Three matching client `Spell.dbc` rows; acquisition is separate |
| 901010-901011 Automatic Ice Lance graph | Automatic `data/sql/db-world/2026_09_17_04_automatic_ice_lance.sql` | Passive proc and haste scripts on their exact IDs | Reuses Ice Lance 30455 and native spell-haste aura handling | Two matching client `Spell.dbc` rows; passive acquisition is separate |
| 901012-901013 Frozen Retaliation rank chain | Automatic `data/sql/db-world/2026_09_17_05_frozen_retaliation.sql` | Negative -901012 binding covers both `spell_ranks` rows | Rank-specific taken-damage proc chance reuses Fingers of Frost aura 44544 | Two matching client `Spell.dbc` rows with rank labels; acquisition is separate |
| 901014-901015 Divine Storm Echo graph | Automatic `data/sql/db-world/2026_09_18_02_divine_storm_echo.sql` | Scheduler on 53385 and existing `spell_pal_divine_storm` on 901015 | Delayed normalized 55 percent weapon attack reuses Divine Storm target, proc, and healing paths | Two matching client `Spell.dbc` rows; acquisition references unranked passive 901014 only and echo acquisition is forbidden |
| 901016 Permanent Seal of Righteousness | Automatic `data/sql/db-world/2026_09_18_03_permanent_seal_of_righteousness.sql` | `spell_apoc_paladin_permanent_seal_of_righteousness` on 901016 | Reuses stock SoR damage 25742 and calculation without entering real seal or judgement selection | Matching client `Spell.dbc`; acquisition is separate |
| 901017 Divine Steed | Automatic baseline plus `2026_09_20_01_divine_steed_cast_cancel.sql` | `spell_apoc_paladin_divine_steed` on 901017 plus player cast and lifecycle cleanup | Normal run-speed aura with display-only faction charger, no mounted state, and cancellation after another non-triggered player spell | Matching client `Spell.dbc`; acquisition is separate |
| 901018-901021 Paladin Vengeance variants | Automatic `data/sql/db-world/2026_09_18_04_paladin_vengeance_variants.sql` | No script binding; native proc-trigger auras and `spell_proc` rows | Three-stack Protection damage reduction/defense or Holy healing/mp5 buff | Four matching client `Spell.dbc` rows; acquisition references only passives 901018 and 901020 |
| 901022-901023 Extended Arsenal rank chain | Automatic `data/sql/db-world/2026_09_18_05_extended_arsenal.sql` | No script binding; native flat spell modifiers | Adds 3/6 yards and 1/2 chain targets to Hammer of the Righteous and Avenger's Shield | Two matching client `Spell.dbc` rows with rank labels; acquisition is separate |
| 901024-901026 Divine Toll graph | Automatic `data/sql/db-world/2026_09_18_05_divine_toll.sql` | Parent orchestration, -31876 JotW gate, and additive stock-damage bindings | Reuses active-seal Judgement formulas, reduces marked hit damage to 50 percent, and preserves downstream PvP and proc paths | External backend derives matching client data; acquisition and patch deployment are separate |
| 901027 Burning Conflagration | Automatic `data/sql/db-world/2026_09_20_04_burning_conflagration.sql` | Additional `-17962` Conflagrate rank-chain binding | Reuses the captured stock Immolate rank with full initial and periodic damage behavior | Matching client row and separate talent acquisition data required |
| 901028-901029 Haunting Affliction graph | Automatic `data/sql/db-world/2026_09_20_02_haunting_affliction.sql` | Additional `-48181` Haunt rank-chain binding | Resolves and casts learned stock DoT ranks with curse and Seed exclusions behind a caster marker | Two matching client rows; acquisition references only passive 901028 |
| 901030 Permanent Metamorphosis | Automatic `data/sql/db-world/2026_09_20_03_permanent_metamorphosis.sql` | Global duration, mount pre-check, and player cleanup hooks | Makes stock aura 47241 infinite without replacing activation 59672 or its cooldown | Matching client row; Demonology Spec Manager acquisition is included |
| 901031-901032 Chaotic Inferno graph | Automatic `data/sql/db-world/2026_09_20_05_chaotic_inferno.sql` | Additional `-50796` Chaos Bolt rank-chain binding plus guardian AI and stat hook | Reuses stock Inferno Effect 22703 and Infernal model/scaling through non-pet guardian 900002 | Two matching client rows; acquisition references only passive 901031 |
| 901033 Demonic Equilibrium | Automatic `data/sql/db-world/2026_09_20_06_demonic_equilibrium.sql` | Additional stock aura 25228 split binding | Replaces Soul Link's current split amount with 75 percent while the passive is active | Matching client row and separate talent acquisition data required |
| 901034 Unquenchable Flames | Automatic `data/sql/db-world/2026_09_20_07_unquenchable_flames.sql` | No script binding; native flat spell modifier | Adds 100 percent resist-dispel chance to exact Immolate and Shadowflame family masks | Matching client row and separate talent acquisition data required |
| 901035 Unyielding Shadows | Automatic `data/sql/db-world/2026_09_20_08_unyielding_shadows.sql` | No script binding; native flat spell modifier | Adds 100 percent resist-dispel chance to matching curses and Shadow debuffs while excluding UA | Matching client row and separate talent acquisition data required |

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
| Missing Burning Conflagration row or binding | The passive cannot validate or Conflagrate does not spread Immolate | Check 901027, binding -17962, loader registration, and matching client and talent data |
| Missing Permanent Metamorphosis row or Spec Manager acquisition | Demonology players do not receive passive 901030 or clients cannot display it | Check the 901030 updater, `mod_spec_spells`, loader registration, and client export |
| Missing Permanent Metamorphosis registration | Aura 47241 retains stock duration and lifecycle hooks do not run | Check `AddModApocalipseWarlockPermanentMetamorphosisScripts()` and rebuild the module |
| Missing Chaotic Inferno spell, summon, creature, properties, or registration | Chaos Bolt cannot summon, the impact is incomplete, or guardians lack ownership, scaling, or autonomous assist | Check 901031, 901032, creature 900002, summon properties, cloned support rows, `-50796`, loader registration, and both client rows |
| Missing Demonic Equilibrium row, binding, or registration | Soul Link remains at stock 20 percent even when 901033 is learned | Check 901033, binding 25228, loader registration, and matching client and talent data |
| Missing Unquenchable Flames row or native modifier fields | Immolate and Shadowflame retain stock dispel chance even when 901034 is learned | Check operation 28, amount 100, exact family masks, and matching client and talent data |
| Missing Unyielding Shadows row or native modifier fields | Curses and Shadow debuffs retain stock dispel chance when 901035 is learned | Check operation 28, amount 100, combined family mask, UA exclusion, and matching client and talent data |
| Missing acquisition data for 901005 | Hypernova exists but cannot be learned normally | Add acquisition through its separately owned workflow |
| Config reload during active battleground | New values are cached but existing auras are not immediately swept | Re-enter battleground, trigger an application hook, or restart according to operator plan |
| Bot lacks a valid session | Bot exception is not detected | Fix bot lifecycle; do not add heuristic fallback |
| Custom spell ID collision | Guarded migration should fail instead of overwriting another spell | Allocate a new ID and update code, SQL, config, scaling data, and docs together |

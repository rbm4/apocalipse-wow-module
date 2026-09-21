# Subsystem catalog

Last source review: 2026-09-16

## Purpose

This catalog identifies the owner, entry points, state, and interactions for each registered gameplay system. Add a dedicated subsystem page when one row no longer contains enough context to change the system safely.

## Catalog

| Subsystem | Owner paths | Entry points | State and data | Main interactions |
|---|---|---|---|---|
| Module loader | `src/mod_apocalipse_loader.cpp` | `Addapocalipse_wow_moduleScripts()` | None | Establishes registration order for all systems |
| Spec Manager | `src/mod_apocalipse.cpp`, `data/mod_apocalipse.sql` | World custom-table load, player login/talent/reset hooks, creature gossip | Process cache plus `acore_characters.mod_player_spec` and `mod_player_spec_talent_budget` | Grants spells later observed by scaling and bot AI; talent changes also trigger stamina recalculation |
| Spell Scaling | `src/mod_spell_scaling.cpp`, `data/mod_spell_scaling.sql` | World custom-table load and UnitScript damage/heal/periodic/aura hooks | Four process maps keyed by spell ID | Stacks with PvP damage hooks; scales Blazing Barrier absorb |
| PvP Balancing | `src/mod_apocalipse_pvp.cpp` | Startup/config reload and UnitScript damage hooks | Process config globals | Stacks with direct and periodic spell scaling; includes bots and player-owned units |
| Blazing Barrier | `src/mod_apocalipse_mage_spells.cpp`, `data/2026_09_16_01_blazing_barrier.sql`, `data/mod_apocalipse.sql` | Spell 901001 cast, aura calculation, and absorb | Aura-local state and spell data | Uses mage talents and then participates in ABSORB scaling |
| Pyroclastic Chain Reaction | `src/mod_apocalipse_mage_pyroclastic_chain_reaction.cpp`, `data/sql/db-world/2026_09_17_00_pyroclastic_chain_reaction.sql` | Pyroblast and Living Bomb explosion scripts | Per-cast state and spell 901003 | Reuses normal Living Bomb ranks, damage, and periodic paths |
| Missile Barrage Overload | `src/mod_apocalipse_mage_missile_barrage_overload.cpp`, `data/sql/db-world/2026_09_17_01_missile_barrage_overload.sql` | Missile Barrage aura apply/reapply and proc preparation | Aura-local count plus spell 901004 | Changes Arcane Missiles duration, preserves core proc/set-bonus paths, and remains binary to bot AI |
| Hypernova | `src/mod_apocalipse_mage_hypernova.cpp`, `data/sql/db-world/2026_09_17_01_hypernova.sql` | Spell 901005 cast and target-centered area effects | Per-cast state plus Arcane Blast aura 36032 | Uses normal Arcane damage, PvP, AoE, knockback, and playerbot movement paths |
| Prismatic Barrier | `src/mod_apocalipse_mage_prismatic_barrier.cpp`, `data/sql/db-world/2026_09_17_02_prismatic_barrier.sql` | Spell 901006 self-cast script effect | No custom runtime state | Triggered casts reuse Mana Shield, Ice Barrier, and Blazing Barrier scripts |
| Frost Bomb | `src/mod_apocalipse_mage_frost_bomb.cpp`, `data/sql/db-world/2026_09_17_03_frost_bomb.sql` | Application removal, explosion hit, and slow aura hooks | Aura-local removal state plus Permafrost rank effects | Uses native Frost procs, target-centered area damage, crowd-control breaking, and healing reduction |
| Automatic Ice Lance | `src/mod_apocalipse_mage_automatic_ice_lance.cpp`, `data/sql/db-world/2026_09_17_04_automatic_ice_lance.sql` | Passive proc and haste aura hooks | Aura-local bounded expiration queue | Reuses Ice Lance, Fingers of Frost, native proc filtering, and spell-haste handling |
| Frozen Retaliation | `src/mod_apocalipse_mage_frozen_retaliation.cpp`, `data/sql/db-world/2026_09_17_05_frozen_retaliation.sql` | Two-rank passive proc hook | Rank-specific `spell_proc` chance and no custom runtime state | Uses the core taken-damage proc flag and existing Fingers of Frost aura handling |
| Ambush Trapper | `src/mod_apocalipse_hunter_ambush_trapper.cpp`, `data/sql/db-world/2026_09_21_00_ambush_trapper.sql` | Trap activation and charged melee-special proc hooks | Passive 901038 and five-charge non-saved aura 901039 | Reuses the core trap event, native charges, Spell Scaling, PvP Balancing, and percent mana energize |
| Primal Resolve | `src/mod_apocalipse_hunter_primal_resolve.cpp`, `data/sql/db-world/2026_09_21_03_primal_resolve.sql` | Active self-cast script effect | Non-saved six-second aura 901042 with no custom runtime state | Reuses core snare removal and all-school damage-taken multiplier handling |
| Apex Bond | `src/mod_apocalipse_hunter_apex_bond.cpp`, `data/sql/db-world/2026_09_21_01_apex_bond.sql` | Active spell cast validation | Spell 901046 and its pet-targeted temporary aura | Reuses native percent healing, pet targeting, cooldown, and pet damage aura handling |
| Blood of the Hunt | `src/mod_apocalipse_hunter_blood_of_the_hunt.cpp`, `data/sql/db-world/2026_09_21_01_blood_of_the_hunt.sql` | Shared melee-special and trap proc hook | Passive 901044, helper 901045, and one aura-owned 2000 ms cooldown | Reuses direct healing, trap activation, Hunter family masks, and Spell Scaling |
| Melee Specialization | `data/sql/db-world/2026_09_21_02_melee_specialization.sql` | Native aura-state and percent-damage spell modifiers | Passive 901047 with no custom runtime state | Reuses exact Hunter melee family masks, core cast validation, and `SPELLMOD_DAMAGE` handling |
| Divine Storm Echo | `src/mod_apocalipse_paladin_divine_storm_echo.cpp`, `data/sql/db-world/2026_09_18_02_divine_storm_echo.sql` | Divine Storm 53385 `AfterCast` hook | Caster-owned delayed event plus spells 901014 and 901015 | Reuses normal Divine Storm targeting, weapon procs, and core proportional healing |
| Permanent Seal of Righteousness | `src/mod_apocalipse_paladin_permanent_seal_of_righteousness.cpp`, `data/sql/db-world/2026_09_18_03_permanent_seal_of_righteousness.sql` | Passive 901016 proc hook | One permanent dummy aura with explicit proc metadata | Reuses SoR damage 25742 and stock calculation while remaining outside real seal exclusivity and judgement selection |
| Divine Steed | `src/mod_apocalipse_paladin_divine_steed.cpp`, baseline and follow-up SQL under `data/sql/db-world/` | Aura apply/remove plus player spell-cast, logout, and map-change hooks | Aura-local display ID and non-saved spell 901017 | Uses normal run speed and a cosmetic faction charger until another non-triggered player spell succeeds |
| Paladin Vengeance variants | `data/sql/db-world/2026_09_18_04_paladin_vengeance_variants.sql` | Native proc and aura handlers | Passives 901018 and 901020 plus timed buffs 901019 and 901021 | Critical damage or healing events refresh three-stack Protection or Holy buffs |
| Extended Arsenal | `data/sql/db-world/2026_09_18_05_extended_arsenal.sql` | Native range and chain-target spell modifiers | Passive ranks 901022 and 901023 | Adds range and targets to Hammer of the Righteous and Avenger's Shield without scripts |
| Divine Toll | `src/mod_apocalipse_paladin_divine_toll.cpp`, `data/sql/db-world/2026_09_18_05_divine_toll.sql` | Active cast, delayed events, stock-damage bindings, and JotW proc gate | Sequence aura 901024 and transient marker 901025 | Reuses active-seal Judgement behavior with bounded half damage and proc controls |
| Burning Conflagration | `src/mod_apocalipse_warlock_burning_conflagration.cpp`, `data/sql/db-world/2026_09_20_04_burning_conflagration.sql` | Additive Conflagrate rank-chain effect and hit hooks | Per-cast rank and primary-target state plus passive 901027 | Captures same-caster Immolate before consumption and performs a bounded nearby spread |
| Chaotic Inferno | `src/mod_apocalipse_warlock_chaotic_inferno.cpp`, `data/sql/db-world/2026_09_20_05_chaotic_inferno.sql` | Chaos Bolt `AfterHit`, creature AI, and guardian stat initialization hooks | Passive 901031, helper 901032, creature 900002, and independent timed guardians | Reuses stock Inferno impact and Infernal data without replacing the normal pet |
| Demonic Equilibrium | `src/mod_apocalipse_warlock_demonic_equilibrium.cpp`, `data/sql/db-world/2026_09_20_06_demonic_equilibrium.sql` | Stock Soul Link aura 25228 split hook | Passive 901033 and no custom runtime state | Replaces Soul Link's per-hit split amount with 75 percent while the passive is active |
| Unquenchable Flames | `data/sql/db-world/2026_09_20_07_unquenchable_flames.sql` | Native caster spell-modifier dispel resistance | Passive 901034 and no custom runtime state | Protects exact Immolate and Shadowflame family masks without scripts or global stock-spell changes |
| Unyielding Shadows | `data/sql/db-world/2026_09_20_08_unyielding_shadows.sql` | Native caster and owner spell-modifier dispel resistance | Passive 901035 and no custom runtime state | Protects matching curses and Shadow debuffs while excluding Unstable Affliction's family bit |
| Haunting Affliction | `src/mod_apocalipse_warlock_haunting_affliction.cpp`, `data/sql/db-world/2026_09_20_02_haunting_affliction.sql` | Additive Haunt rank-chain `AfterHit` hook | Passive 901028 and caster marker 901029 | Reuses learned stock DoT ranks while preserving other curses and Seed of Corruption |
| Permanent Metamorphosis | `src/mod_apocalipse_warlock_permanent_metamorphosis.cpp`, `data/sql/db-world/2026_09_20_03_permanent_metamorphosis.sql` | Global aura-duration and mount cast-check hooks plus player cleanup hooks | Passive 901030 and stock transformation aura 47241 | Preserves active spell 59672, stock cooldown, linked cleanup, and existing playerbot checks |
| Battleground Stamina | `src/battleground_stamina/`, `conf/BattlegroundStamina.conf.dist`, `data/sql/db-world/2026_09_16_00_battleground_stamina_spell.sql` | Startup/config reload, player lifecycle/equipment hooks, battleground add/remove hooks | Process settings plus aura 901002 on eligible players | Bot equipment-lock exemption, talent/equipment recalculation, client/server custom spell contract |

## Shared surfaces

### Player hooks

Spec Manager and Battleground Stamina overlap on login and talent-related events. Their logic must remain independently safe because global callback ordering is not a stable business contract.

### Unit hooks

Spell Scaling and PvP Balancing overlap on direct and periodic damage. Both mutate the value by reference. Any new damage subsystem must document its registration order, eligibility guards, integer conversions, and expected stacking.

### Spell IDs

- 901001: Blazing Barrier, code constant, manual world migration, script binding, scaling row, and client DBC.
- 901002: Battleground stamina aura, config default, automatic world migration, runtime validator, and client DBC.
- 901003: Pyroclastic Chain Reaction, code constant, automatic world migration, two rank-chain bindings, and client DBC.
- 901004: Missile Barrage Overload, code constant, automatic world migration, 44401 and passive bindings, and client DBC.
- 901005: Hypernova, code constant, automatic world migration, script binding, damage coefficient, and client DBC.
- 901006: Prismatic Barrier, code constant, automatic world migration, script binding, three child spells, and client DBC.
- 901007 through 901009: Frost Bomb application, explosion, and slow, code constants, automatic world migration, three script bindings, coefficient, and client DBC.
- 901010 and 901011: Automatic Ice Lance passive and haste aura, code constants, automatic world migration, proc row, script bindings, non-save metadata, and client DBC.
- 901012 and 901013: Frozen Retaliation ranks 1 and 2, code constants, automatic world migration, rank relationships, floating-point proc rows, rank-chain script binding, and client DBC.
- 901014 and 901015: Divine Storm Echo passive and triggered attack, code constants, automatic world migration, 53385 scheduling binding, core healing binding, and client DBC.
- 901016: Permanent Seal of Righteousness passive, code constant, automatic world migration, explicit proc metadata, script binding, and client DBC.
- 901017: Divine Steed active sprint, code constant, automatic world migrations, script binding, non-save attribute, cast-cancellation hook, faction display contract, descriptions, and client DBC.
- 901018 through 901021: Guardian's Vengeance and Sacred Vengeance passives and timed buffs, automatic world migration, proc rows, non-save metadata, and client DBC.
- 901022 and 901023: Extended Arsenal ranks 1 and 2, automatic world migration, rank relationships, two flat spell modifiers, exact Paladin family masks, and client DBC.
- 901024 through 901026: Divine Toll parent, transient impact marker, and Justice visual, code constants, automatic world migration, additive stock-spell bindings, and external client export.
- 901027: Burning Conflagration passive, code constant, automatic world migration, Conflagrate rank-chain binding, and client DBC.
- 901028 and 901029: Haunting Affliction passive and non-saved cooldown marker, code constants, automatic world migration, Haunt rank-chain binding, and client DBC.
- 901030: Permanent Metamorphosis passive, code constant, automatic world migration, Demonology Spec Manager acquisition, conditional duration hook, lifecycle cleanup, and client DBC.
- 901031 and 901032: Chaotic Inferno passive and summon helper, code constants, automatic world migration, Chaos Bolt rank-chain binding, creature 900002, summon properties, guardian AI and scaling hooks, and client DBC.
- 901033: Demonic Equilibrium passive, code constant, automatic world migration, stock Soul Link aura 25228 binding, dynamic split hook, and client DBC.
- 901034: Unquenchable Flames passive, automatic world migration, native 100 percent resist-dispel modifier, exact Immolate and Shadowflame family masks, and client DBC.
- 901035: Unyielding Shadows passive, automatic world migration, native 100 percent resist-dispel modifier, combined Warlock family mask excluding Unstable Affliction, and client DBC.
- 901038 through 901041: Ambush Trapper passive, charged buff, Physical damage helper, and mana helper, code constants, automatic world migration, proc rows, script bindings, non-save metadata, scaling row, and client DBC.
- 901044 and 901045: Blood of the Hunt passive and direct-heal helper, code constants, automatic world migration, shared cooldown proc row, script binding, zero coefficients, HEAL scaling row, and client DBC.
- 901046: Apex Bond active, code constant, automatic world migration, script binding, pet-targeted percent heals and damage aura, non-save metadata, and client DBC.

Changing any ID requires an atomic update across every listed surface.

### Configuration

PvP settings are read directly from `sConfigMgr` and currently have no dedicated `.conf.dist` in this repository. Battleground settings have `conf/BattlegroundStamina.conf.dist`. Code defaults and distributed values must match.

### Persistence

Only Spec Manager writes per-character state. Spell scaling and PvP settings are process caches. Battleground Stamina stores no character state and explicitly requires aura 901002 not to persist in `character_aura`.

## Adding a subsystem

1. Implement its script registration function.
2. Register it from `Addapocalipse_wow_moduleScripts()`.
3. Add config and SQL through the correct distribution or updater path.
4. Document bot applicability and any shared hooks.
5. Copy [`../templates/subsystem.md`](../templates/subsystem.md) when the catalog is insufficient.
6. Update this catalog, [`../architecture/overview.md`](../architecture/overview.md), root `README.md`, and the history index.

# Feature documentation index

## Purpose

Feature pages preserve end-to-end context for behavior that spans source code, hooks, configuration, SQL, custom spell data, client assets, or bot-specific behavior. They describe the current implementation and remain updated after the original change.

## Current feature map

| Feature | Owner paths | Status | Document |
|---|---|---|---|
| Specialization signature spells | `src/mod_apocalipse.cpp`, `data/mod_apocalipse.sql` | Implemented, source reviewed | [`../mod_apocalipse.md`](../mod_apocalipse.md) |
| Level-based spell scaling | `src/mod_spell_scaling.cpp`, `data/mod_spell_scaling.sql` | Implemented, source reviewed | [`../mod_spell_scaling.md`](../mod_spell_scaling.md) |
| PvP damage balancing | `src/mod_apocalipse_pvp.cpp` | Implemented, source reviewed | [`../mod_apocalipse_pvp.md`](../mod_apocalipse_pvp.md) |
| Blazing Barrier | `src/mod_apocalipse_mage_spells.cpp`, `data/2026_09_16_01_blazing_barrier.sql` | Implemented in source, runtime not verified | [`../custom-spells/blazing-barrier.md`](../custom-spells/blazing-barrier.md) |
| Pyroclastic Chain Reaction | `src/mod_apocalipse_mage_pyroclastic_chain_reaction.cpp`, `data/sql/db-world/2026_09_17_00_pyroclastic_chain_reaction.sql` | Implemented in source, runtime not verified | [`../custom-spells/pyroclastic-chain-reaction.md`](../custom-spells/pyroclastic-chain-reaction.md) |
| Missile Barrage Overload | `src/mod_apocalipse_mage_missile_barrage_overload.cpp`, `data/sql/db-world/2026_09_17_01_missile_barrage_overload.sql` | Implemented in source, runtime not verified | [`../custom-spells/missile-barrage-overload.md`](../custom-spells/missile-barrage-overload.md) |
| Hypernova | `src/mod_apocalipse_mage_hypernova.cpp`, `data/sql/db-world/2026_09_17_01_hypernova.sql` | Implemented in source, runtime not verified | [`../custom-spells/hypernova.md`](../custom-spells/hypernova.md) |
| Prismatic Barrier | `src/mod_apocalipse_mage_prismatic_barrier.cpp`, `data/sql/db-world/2026_09_17_02_prismatic_barrier.sql` | Implemented in source, runtime not verified | [`../custom-spells/prismatic-barrier.md`](../custom-spells/prismatic-barrier.md) |
| Frost Bomb | `src/mod_apocalipse_mage_frost_bomb.cpp`, `data/sql/db-world/2026_09_17_03_frost_bomb.sql` | Implemented in source, runtime not verified | [`../custom-spells/frost-bomb.md`](../custom-spells/frost-bomb.md) |
| Automatic Ice Lance | `src/mod_apocalipse_mage_automatic_ice_lance.cpp`, `data/sql/db-world/2026_09_17_04_automatic_ice_lance.sql` | Implemented in source, runtime not verified | [`../custom-spells/automatic-ice-lance.md`](../custom-spells/automatic-ice-lance.md) |
| Frozen Retaliation | `src/mod_apocalipse_mage_frozen_retaliation.cpp`, `data/sql/db-world/2026_09_17_05_frozen_retaliation.sql` | Implemented in source, runtime not verified | [`../custom-spells/frozen-retaliation.md`](../custom-spells/frozen-retaliation.md) |
| Concentrated Venom | `src/mod_apocalipse_rogue_concentrated_venom.cpp`, `data/sql/db-world/2026_09_22_03_concentrated_venom.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/concentrated-venom.md`](../custom-spells/concentrated-venom.md) |
| Pestilent Knives | `src/mod_apocalipse_rogue_pestilent_knives.cpp`, `data/sql/db-world/2026_09_22_03_rogue_pestilent_knives.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/pestilent-knives.md`](../custom-spells/pestilent-knives.md) |
| Daring Challenge | `src/mod_apocalipse_rogue_daring_challenge.cpp`, `data/sql/db-world/2026_09_22_05_daring_challenge.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/daring-challenge.md`](../custom-spells/daring-challenge.md) |
| Buckler Strike | `src/mod_apocalipse_rogue_buckler_strike.cpp`, `data/sql/db-world/2026_09_22_06_buckler_strike.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/buckler-strike.md`](../custom-spells/buckler-strike.md) |
| Gloomblade Infusion | `src/mod_apocalipse_rogue_gloomblade_infusion.cpp`, `data/sql/db-world/2026_09_22_07_gloomblade_infusion.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/gloomblade-infusion.md`](../custom-spells/gloomblade-infusion.md) |
| Shadow Execution | `src/mod_apocalipse_rogue_shadow_execution.cpp`, `data/sql/db-world/2026_09_22_08_shadow_execution.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/shadow-execution.md`](../custom-spells/shadow-execution.md) |
| Improved Feint | `src/mod_apocalipse_rogue_improved_feint.cpp`, `data/sql/db-world/2026_09_22_09_improved_feint.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/improved-feint.md`](../custom-spells/improved-feint.md) |
| Relentless Finale | `src/mod_apocalipse_rogue_relentless_finale.cpp`, `data/sql/db-world/2026_09_22_10_relentless_finale.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/relentless-finale.md`](../custom-spells/relentless-finale.md) |
| Ambush Trapper | `src/mod_apocalipse_hunter_ambush_trapper.cpp`, `data/sql/db-world/2026_09_21_00_ambush_trapper.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/ambush-trapper.md`](../custom-spells/ambush-trapper.md) |
| Primal Resolve | `src/mod_apocalipse_hunter_primal_resolve.cpp`, `data/sql/db-world/2026_09_21_03_primal_resolve.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/primal-resolve.md`](../custom-spells/primal-resolve.md) |
| Apex Bond | `src/mod_apocalipse_hunter_apex_bond.cpp`, `data/sql/db-world/2026_09_21_01_apex_bond.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/apex-bond.md`](../custom-spells/apex-bond.md) |
| Blood of the Hunt | `src/mod_apocalipse_hunter_blood_of_the_hunt.cpp`, `data/sql/db-world/2026_09_21_01_blood_of_the_hunt.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/blood-of-the-hunt.md`](../custom-spells/blood-of-the-hunt.md) |
| Melee Specialization | `data/sql/db-world/2026_09_21_02_melee_specialization.sql` | Implemented in data, database and runtime not verified | [`../custom-spells/melee-specialization.md`](../custom-spells/melee-specialization.md) |
| Crimson Ward | `src/mod_apocalipse_death_knight_crimson_ward.cpp`, `data/sql/db-world/2026_09_21_04_crimson_ward.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/crimson-ward.md`](../custom-spells/crimson-ward.md) |
| Death Knight Rupture | `src/mod_apocalipse_death_knight_rupture.cpp`, `data/sql/db-world/2026_09_21_04_death_knight_rupture.sql`, `data/sql/db-world/2026_09_25_05_death_knight_rupture_ap_scaling.sql`, `data/sql/db-world/2026_09_26_00_death_knight_rupture_melee_hits.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/death-knight-rupture.md`](../custom-spells/death-knight-rupture.md) |
| Frozen Resolve | `src/mod_apocalipse_death_knight_frozen_resolve.cpp`, `data/sql/db-world/2026_09_21_05_frozen_resolve.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/frozen-resolve.md`](../custom-spells/frozen-resolve.md) |
| Necrotic Veil | `src/mod_apocalipse_death_knight_necrotic_veil.cpp`, `data/sql/db-world/2026_09_21_07_death_knight_necrotic_veil.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/necrotic-veil.md`](../custom-spells/necrotic-veil.md) |
| Pestilent Eruption | `src/mod_apocalipse_death_knight_pestilent_eruption.cpp`, `data/sql/db-world/2026_09_21_07_death_knight_pestilent_eruption.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/pestilent-eruption.md`](../custom-spells/pestilent-eruption.md) |
| Rime Shards | `src/mod_apocalipse_death_knight_rime_shards.cpp`, `data/sql/db-world/2026_09_21_06_death_knight_rime_shards.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/rime-shards.md`](../custom-spells/rime-shards.md) |
| Threat of Thassarian extension | `src/mod_apocalipse_death_knight_threat_of_thassarian.cpp`, baseline and `2026_09_26_01_threat_of_thassarian_healing.sql` | Implemented in module and deployment-core source and data, build and runtime not verified | [`../custom-spells/threat-of-thassarian-extension.md`](../custom-spells/threat-of-thassarian-extension.md) |
| Divine Storm Echo | `src/mod_apocalipse_paladin_divine_storm_echo.cpp`, `data/sql/db-world/2026_09_18_02_divine_storm_echo.sql` | Implemented in source, runtime not verified | [`../custom-spells/divine-storm-echo.md`](../custom-spells/divine-storm-echo.md) |
| Permanent Paladin seals | `src/mod_apocalipse_paladin_permanent_seal_of_righteousness.cpp`, baseline and follow-up SQL under `data/sql/db-world/` | Implemented in source and data, build and runtime not verified | [`../custom-spells/permanent-seal-of-righteousness.md`](../custom-spells/permanent-seal-of-righteousness.md) |
| Divine Steed | `src/mod_apocalipse_paladin_divine_steed.cpp`, `data/sql/db-world/2026_09_18_04_divine_steed.sql` | Implemented in source, runtime not verified | [`../custom-spells/divine-steed.md`](../custom-spells/divine-steed.md) |
| Paladin Vengeance variants | `data/sql/db-world/2026_09_18_04_paladin_vengeance_variants.sql` | Implemented in data, runtime not verified | [`../custom-spells/paladin-vengeance-variants.md`](../custom-spells/paladin-vengeance-variants.md) |
| Extended Arsenal | `data/sql/db-world/2026_09_18_05_extended_arsenal.sql` | Implemented in data, runtime not verified | [`../custom-spells/extended-arsenal.md`](../custom-spells/extended-arsenal.md) |
| Divine Toll | `src/mod_apocalipse_paladin_divine_toll.cpp`, `data/sql/db-world/2026_09_18_05_divine_toll.sql` | Implemented in source and data, runtime not verified | [`../custom-spells/divine-toll.md`](../custom-spells/divine-toll.md) |
| Burning Conflagration | `src/mod_apocalipse_warlock_burning_conflagration.cpp`, `data/sql/db-world/2026_09_20_04_burning_conflagration.sql` | Implemented in source and data, runtime not verified | [`../custom-spells/burning-conflagration.md`](../custom-spells/burning-conflagration.md) |
| Chaotic Inferno | `src/mod_apocalipse_warlock_chaotic_inferno.cpp`, `data/sql/db-world/2026_09_20_05_chaotic_inferno.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/chaotic-inferno.md`](../custom-spells/chaotic-inferno.md) |
| Demonic Equilibrium | `src/mod_apocalipse_warlock_demonic_equilibrium.cpp`, `data/sql/db-world/2026_09_20_06_demonic_equilibrium.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/demonic-equilibrium.md`](../custom-spells/demonic-equilibrium.md) |
| Unquenchable Flames | `data/sql/db-world/2026_09_20_07_unquenchable_flames.sql` | Implemented in data, database and runtime not verified | [`../custom-spells/unquenchable-flames.md`](../custom-spells/unquenchable-flames.md) |
| Unyielding Shadows | `data/sql/db-world/2026_09_20_08_unyielding_shadows.sql` | Implemented in data, database and runtime not verified | [`../custom-spells/unyielding-shadows.md`](../custom-spells/unyielding-shadows.md) |
| Haunting Affliction | `src/mod_apocalipse_warlock_haunting_affliction.cpp`, `data/sql/db-world/2026_09_20_02_haunting_affliction.sql` | Implemented in source and data, runtime not verified | [`../custom-spells/haunting-affliction.md`](../custom-spells/haunting-affliction.md) |
| Permanent Metamorphosis | `src/mod_apocalipse_warlock_permanent_metamorphosis.cpp`, `data/sql/db-world/2026_09_20_03_permanent_metamorphosis.sql` | Implemented in source and data, runtime not verified | [`../custom-spells/permanent-metamorphosis.md`](../custom-spells/permanent-metamorphosis.md) |
| Rogue shield proficiency | `data/sql/db-world/2026_09_22_02_rogue_shield_proficiency.sql` | Implemented in data, updater and runtime not verified | [`rogue-shield-proficiency.md`](rogue-shield-proficiency.md) |
| Leeching Mixture | `src/mod_apocalipse_rogue_leeching_mixture.cpp`, `data/sql/db-world/2026_09_22_03_rogue_leeching_mixture.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/leeching-mixture.md`](../custom-spells/leeching-mixture.md) |
| Alchemical Guard | `src/mod_apocalipse_rogue_alchemical_guard.cpp`, `data/sql/db-world/2026_09_22_04_alchemical_guard.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/alchemical-guard.md`](../custom-spells/alchemical-guard.md) |
| Bladeguard | `data/sql/db-world/2026_09_22_04_bladeguard.sql` | Implemented in data, database, client, and runtime not verified | [`../custom-spells/bladeguard.md`](../custom-spells/bladeguard.md) |
| Shielded Reflexes | `src/mod_apocalipse_rogue_shielded_reflexes.cpp`, `data/sql/db-world/2026_09_25_03_shielded_reflexes.sql` | Implemented in source and data, build and runtime not verified | [`../custom-spells/shielded-reflexes.md`](../custom-spells/shielded-reflexes.md) |
| Priest ability pack | `src/mod_apocalipse_priest_spells.cpp`, `data/sql/db-world/2026_09_24_01_priest_spell_pack.sql` | Implemented in source and data, build and runtime not verified | [`priest-ability-pack.md`](priest-ability-pack.md) |
| Battleground stamina assistance | `src/battleground_stamina/`, `conf/BattlegroundStamina.conf.dist`, `data/sql/db-world/2026_09_16_00_battleground_stamina_spell.sql` | Implemented in source, runtime not verified | [`../custom-spells/battleground-stamina-assistance.md`](../custom-spells/battleground-stamina-assistance.md) |

## Adding a feature page

Create a dedicated page when work crosses at least two of these surfaces:

- Multiple AzerothCore script or hook families
- Human and bot behavior differences
- Configuration
- World or character database state
- Manual or automatic SQL migration
- Server and client custom spell data
- Multiple gameplay subsystems
- Non-trivial deployment, rollback, or runtime validation

Workflow:

1. Copy [`../templates/feature.md`](../templates/feature.md) to `<lowercase-kebab-name>.md` in this directory.
2. Complete every applicable section.
3. Add it to the current feature map.
4. Link it from architecture, subsystem, custom-spell, and README pages as applicable.
5. Keep it synchronized as later work changes behavior.
6. Mark retired behavior with migration context instead of silently deleting its history.

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
| Divine Storm Echo | `src/mod_apocalipse_paladin_divine_storm_echo.cpp`, `data/sql/db-world/2026_09_18_02_divine_storm_echo.sql` | Implemented in source, runtime not verified | [`../custom-spells/divine-storm-echo.md`](../custom-spells/divine-storm-echo.md) |
| Permanent Seal of Righteousness | `src/mod_apocalipse_paladin_permanent_seal_of_righteousness.cpp`, `data/sql/db-world/2026_09_18_03_permanent_seal_of_righteousness.sql` | Implemented in source, runtime not verified | [`../custom-spells/permanent-seal-of-righteousness.md`](../custom-spells/permanent-seal-of-righteousness.md) |
| Divine Steed | `src/mod_apocalipse_paladin_divine_steed.cpp`, `data/sql/db-world/2026_09_18_04_divine_steed.sql` | Implemented in source, runtime not verified | [`../custom-spells/divine-steed.md`](../custom-spells/divine-steed.md) |
| Paladin Vengeance variants | `data/sql/db-world/2026_09_18_04_paladin_vengeance_variants.sql` | Implemented in data, runtime not verified | [`../custom-spells/paladin-vengeance-variants.md`](../custom-spells/paladin-vengeance-variants.md) |
| Extended Arsenal | `data/sql/db-world/2026_09_18_05_extended_arsenal.sql` | Implemented in data, runtime not verified | [`../custom-spells/extended-arsenal.md`](../custom-spells/extended-arsenal.md) |
| Divine Toll | `src/mod_apocalipse_paladin_divine_toll.cpp`, `data/sql/db-world/2026_09_18_05_divine_toll.sql` | Implemented in source and data, runtime not verified | [`../custom-spells/divine-toll.md`](../custom-spells/divine-toll.md) |
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

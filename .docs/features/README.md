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

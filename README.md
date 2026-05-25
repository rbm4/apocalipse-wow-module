# apocalipse-wow-module

AzerothCore module for the **Apocalipse WoW** private server (WotLK 3.3.5a).  
It handles three custom gameplay systems compiled as a single static or dynamic AzerothCore module.

---

## Project structure

```
apocalipse-wow-module/
├── CMakeLists.txt              # Minimal — sources are auto-collected from src/
├── data/
│   ├── mod_apocalipse.sql      # One-time DDL + seed data for the spec system
│   └── mod_spell_scaling.sql   # One-time DDL + seed data for spell scaling
└── src/
    ├── mod_apocalipse_loader.cpp   # Module entry-point / script registration
    ├── mod_apocalipse.cpp          # Spec Manager: NPC + talent grant system
    ├── mod_spell_scaling.cpp       # Level-proportional spell scaling
    └── mod_apocalipse_pvp.cpp      # PvP damage balancing
```

---

## Systems

### Spec Manager (`mod_apocalipse.cpp`)

Players visit a custom NPC (entry `900001`) to choose a specialisation.  (CURRENTLY UNUSED IN-GAME)
On login and on save the module inspects which WotLK talent tree has the most points, then grants or revokes the matching signature spells defined in the `mod_spec_spells` table (`acore_world`). Per-player state is persisted in `mod_player_spec` (`acore_characters`).

### Spell Scaling (`mod_spell_scaling.cpp`)

High-level spells granted to low-level players are scaled down proportionally so they do not trivialise levelling content.

Formula: `multiplier = min((playerLevel / 80) * scaleFactor, 1.0)`

The list of spells and their scale factors is fully data-driven — rows are read once from the `mod_spell_scaling` table (`acore_world`) at world startup. No recompile is needed to add or remove a spell from the list.

Scale types: `DAMAGE`, `HEAL`, `PERIODIC`, `ABSORB`.

### PvP Damage Balancing (`mod_apocalipse_pvp.cpp`)

Two stacking layers applied to every player-vs-player damage event (melee, spells, and DoT ticks):

1. **Fixed % reduction** — applied at all levels, configured via `Apocalipse.PvPDamageReductionPct`.
2. **Bracket resilience floor** — for levels 10–79 only. If the victim's current resilience is below the configured target for their 10-level bracket, extra reduction simulates the missing resilience. Level 80+ players are excluded.

---

## Database setup

Run each SQL file once against the appropriate database before starting the worldserver for the first time:

```sql
-- Spec system tables + creature template + sample spells
SOURCE data/mod_apocalipse.sql;

-- Spell scaling table + initial spell list
SOURCE data/mod_spell_scaling.sql;
```

---

## Configuration (`worldserver.conf`)

```ini
# PvP Balancing
Apocalipse.PvPDamageReductionPct      = 15.0

Apocalipse.PvPBracketResilience.1019  = 8.0
Apocalipse.PvPBracketResilience.2029  = 10.0
Apocalipse.PvPBracketResilience.3039  = 12.0
Apocalipse.PvPBracketResilience.4049  = 14.0
Apocalipse.PvPBracketResilience.5059  = 16.0
Apocalipse.PvPBracketResilience.6069  = 18.0
Apocalipse.PvPBracketResilience.7079  = 20.0
```

All keys have sensible defaults and are optional.

---

## Building

The module follows the standard AzerothCore module layout. Place (or symlink) the directory under `modules/` in the AzerothCore source tree, then configure and build normally:

```bash
cmake .. -DMODULES=static   # or dynamic
make -j$(nproc)
```

---

## Detailed documentation

See [`.docs/`](.docs/) for per-file deep-dives:

- [mod_apocalipse_loader.cpp](.docs/mod_apocalipse_loader.md)
- [mod_apocalipse.cpp](.docs/mod_apocalipse.md)
- [mod_spell_scaling.cpp](.docs/mod_spell_scaling.md)
- [mod_apocalipse_pvp.cpp](.docs/mod_apocalipse_pvp.md)

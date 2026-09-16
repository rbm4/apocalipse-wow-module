# apocalipse-wow-module

AzerothCore module for the **Apocalipse WoW** private server (WotLK 3.3.5a).  
It handles four custom gameplay systems compiled as a single static or dynamic AzerothCore module.

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

### Battleground Stamina Assistance (`src/battleground_stamina/`)

Level 10-79 characters in non-arena battlegrounds receive a configurable
true-stamina grant based on the gap between their unbuffed equipment baseline
and a class/bracket health threshold. Partial gap coverage makes assistance
taper to zero while better equipment always continues to improve final health.

Armor and other non-combat-swappable equipment changes are blocked for human
players throughout the battleground stay. Native weapon/offhand/projectile/
relic swaps remain available, and playerbots are exempt from the lock. The aura
is applied on entry, reconstructed after resurrection or map/login recovery,
and removed on exit without granting current health.

World update `data/sql/db-world/2026_09_16_00_battleground_stamina_spell.sql`
installs aura spell `901002` on the next worldserver startup when module/world
database updates are enabled. Check that ID against the live database and the
client DBC before deployment; the local base Spell.dbc does not contain it.
The module defaults to that ID, but an installed conf value of `0` must be
changed. The spell contract and tuning values are in
`conf/BattlegroundStamina.conf.dist`.

---

## Database setup

Run each SQL file once against the appropriate database before starting the worldserver for the first time:

```sql
-- Spec system tables + creature template + sample spells
SOURCE data/mod_apocalipse.sql;

-- Spell scaling table + initial spell list
SOURCE data/mod_spell_scaling.sql;
```

The battleground stamina spell uses the AzerothCore module updater instead:
its SQL is under `data/sql/db-world/`. It runs once during worldserver startup
when world database updates are enabled, this module is present in the
compiled module list, and its source directory is available to the updater.
It requires the backend's `wotlk_spells_full` and `wotlk_spells` tables.
Compiling alone does not apply it. Do not also import this file manually if
the updater will apply it on the next startup.

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

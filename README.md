# apocalipse-wow-module

AzerothCore WotLK 3.3.5a gameplay module for the Apocalipse WoW private-server infrastructure. It is deployed with `mod-playerbots` and the custom playerbot AzerothCore branch.

The module registers six systems:

1. Specialization signature spell management
2. Level-based spell scaling
3. PvP damage balancing
4. Blazing Barrier custom mage spell
5. Pyroclastic Chain Reaction custom mage passive
6. Battleground stamina assistance and equipment control

The module does not implement bot AI. Its AzerothCore hooks also receive bot-controlled `Player` objects, and selected rules use `WorldSession::IsBot()` for bot-specific behavior.

## Documentation first

Engineering context is maintained as part of every change:

- Agent rules and mandatory documentation workflow: [`AGENTS.md`](AGENTS.md)
- Documentation index: [`.docs/README.md`](.docs/README.md)
- Architecture and subsystem interactions: [`.docs/architecture/overview.md`](.docs/architecture/overview.md)
- Runtime and data flow: [`.docs/architecture/runtime-and-data-flow.md`](.docs/architecture/runtime-and-data-flow.md)
- Playerbot integration: [`.docs/integrations/playerbots.md`](.docs/integrations/playerbots.md)
- Build, SQL, config, and release operations: [`.docs/development/operations.md`](.docs/development/operations.md)
- Dated engineering history: [`.docs/history/README.md`](.docs/history/README.md)

Future features must update their owner documentation, this README when public behavior changes, and the dated history without requiring a separate request.

## Project structure

```text
apocalipse-wow-module/
|-- AGENTS.md
|-- CMakeLists.txt
|-- README.md
|-- conf/
|   `-- BattlegroundStamina.conf.dist
|-- data/
|   |-- mod_apocalipse.sql
|   |-- mod_spell_scaling.sql
|   |-- 2026_09_16_01_blazing_barrier.sql
|   `-- sql/db-world/
|       |-- 2026_09_16_00_battleground_stamina_spell.sql
|       `-- 2026_09_17_00_pyroclastic_chain_reaction.sql
|-- src/
|   |-- mod_apocalipse_loader.cpp
|   |-- mod_apocalipse.cpp
|   |-- mod_spell_scaling.cpp
|   |-- mod_apocalipse_pvp.cpp
|   |-- mod_apocalipse_mage_spells.cpp
|   |-- mod_apocalipse_mage_pyroclastic_chain_reaction.cpp
|   `-- battleground_stamina/
`-- .docs/
    |-- architecture/
    |-- custom-spells/
    |-- development/
    |-- features/
    |-- history/
    |-- integrations/
    |-- subsystems/
    `-- templates/
```

`CMakeLists.txt` is intentionally minimal. The parent AzerothCore module build auto-collects source files under `src/`.

## Systems

### Spec Manager

Owner: `src/mod_apocalipse.cpp`

The system detects the dominant talent tree on player login and talent changes. It grants configured signature spells and managed talents, removes non-dominant layers, and persists the selected tree plus a six-point hidden talent budget in `acore_characters`.

Creature 900001 provides an explicit Spec Master gossip interface, but it is currently not part of normal gameplay. A later talent reconciliation can replace an NPC-selected tree based on actual talent points.

Bots receive the same grants and persistence. Spec success/reset chat messages are suppressed for bot sessions.

Detailed contract: [`.docs/mod_apocalipse.md`](.docs/mod_apocalipse.md)

### Spell Scaling

Owner: `src/mod_spell_scaling.cpp`

Selected player-cast spells below level 80 are scaled from `acore_world.mod_spell_scaling`:

```text
multiplier = min((casterLevel / 80.0) * scaleFactor, 1.0)
```

Supported hook families are direct damage, direct healing, periodic damage, and absorb/mana-shield auras. NPCs are not scaled; bot-controlled players are scaled like humans.

A factor below 1.0 makes the final low-level effect smaller. For example, factor 0.5 at level 40 produces 25 percent, not 75 percent.

Detailed contract: [`.docs/mod_spell_scaling.md`](.docs/mod_spell_scaling.md)

### PvP Damage Balancing

Owner: `src/mod_apocalipse_pvp.cpp`

Eligible player-versus-player damage receives two multiplicative layers:

1. A fixed reduction at every level, default 15 percent.
2. For victim levels 10 through 79, the shortfall between current melee crit chance reduction and the configured bracket target.

Player-owned pets and guardians qualify as player attackers. Human and bot-controlled players use the same rules.

Direct and periodic configured spells can pass through both Spell Scaling and PvP Balancing. Integer conversion at each hook means callback order can affect rounding.

Detailed contract: [`.docs/mod_apocalipse_pvp.md`](.docs/mod_apocalipse_pvp.md)

### Blazing Barrier

Owner: `src/mod_apocalipse_mage_spells.cpp`

Custom spell 901001 is a level-80 mage absorb with base absorb plus 80.68 percent fire spell-power contribution. Its scripts reject replacing a stronger matching barrier with a weaker cast and integrate Blazing Speed, Fiery Payback, and Incanter's Absorption behavior.

The server spell row is installed by manual migration `data/2026_09_16_01_blazing_barrier.sql`. The script binding and scaling seed also appear in the baseline SQL. A matching client `Spell.dbc` and patch are required.

Detailed contract: [`.docs/custom-spells/blazing-barrier.md`](.docs/custom-spells/blazing-barrier.md)

### Pyroclastic Chain Reaction

Owner: `src/mod_apocalipse_mage_pyroclastic_chain_reaction.cpp`

Custom passive spell 901003 gives Pyroblast hits a 20 percent chance to detonate and refresh the caster's Living Bomb on the target. The matching-rank explosion preserves its normal damage targets and spreads the source Living Bomb rank to up to two random surviving enemies hit by the explosion that do not already have that caster's Living Bomb.

The automatic module world update installs the passive and binds all Pyroblast and Living Bomb explosion ranks. Talent acquisition is intentionally external and requires matching server and client talent data. Human and bot-controlled mages use identical combat behavior.

Detailed contract: [`.docs/custom-spells/pyroclastic-chain-reaction.md`](.docs/custom-spells/pyroclastic-chain-reaction.md)

### Battleground Stamina Assistance

Owners: `src/battleground_stamina/`, `conf/BattlegroundStamina.conf.dist`

Eligible level 10 through 79 characters in non-arena battlegrounds receive a configurable true-stamina grant based on part of the gap between unbuffed baseline health and a class/bracket threshold.

Human players cannot change most non-combat-swappable equipment while in the battleground. Bot sessions bypass the equipment lock so automatic gearing can continue. Both humans and bots receive the same assistance calculation, and allowed equipment changes recalculate the aura.

Custom aura 901002 is installed by the AzerothCore module world updater. The runtime validator requires a positive, infinite, non-cancellable, death-persistent, non-saved generic stamina aura. A matching client `Spell.dbc` and patch are required.

Known config drift: distributed 10-19 thresholds differ from compiled fallbacks. Ensure `conf/BattlegroundStamina.conf.dist` is loaded into the effective server config until this is synchronized.

Detailed contract: [`.docs/custom-spells/battleground-stamina-assistance.md`](.docs/custom-spells/battleground-stamina-assistance.md)

## Requirements

- The custom playerbot AzerothCore WotLK branch used by the deployed `mod-playerbots` version
- `mod-playerbots` enabled in the parent core deployment
- World and character database access through AzerothCore
- Effective module/worldserver configuration containing desired overrides
- Server and client custom-spell data for spells 901001, 901002, and 901003
- Matching talent data when passive spell 901003 is granted through a custom talent

Stock AzerothCore compatibility has not been validated.

## Database setup

Manual baseline and migration files are outside the automatic updater path. Run them only against the named database while following the server's backup and migration procedure.

```sql
-- Switches between acore_world and acore_characters internally.
SOURCE data/mod_apocalipse.sql;

-- acore_world
SOURCE data/mod_spell_scaling.sql;

-- acore_world, while worldserver is stopped
SOURCE data/2026_09_16_01_blazing_barrier.sql;
```

Files under `data/sql/db-world/` are automatic module world updates. They run on worldserver startup only when world database updates and module update discovery are enabled. Do not also import them manually when the updater will apply them. The 901002 update is idempotent for its recognized spell row and may be executed manually, with worldserver stopped and a current backup, to repair an already-recorded deployment. The 901003 update installs Pyroclastic Chain Reaction and its rank-chain script bindings.

Before the first custom-spell deployment, verify IDs 901001, 901002, and 901003 are free in live `spell_dbc`, `wotlk_spells_full`, `wotlk_spells`, and the actual selected client/server `Spell.dbc`.

See [`.docs/development/operations.md`](.docs/development/operations.md) for migration order, preflight queries, updater checks, client patch requirements, and rollback constraints.

## Configuration

### PvP keys

```ini
Apocalipse.PvPDamageReductionPct = 15.0
Apocalipse.PvPBracketResilience.1019 = 8.0
Apocalipse.PvPBracketResilience.2029 = 10.0
Apocalipse.PvPBracketResilience.3039 = 12.0
Apocalipse.PvPBracketResilience.4049 = 14.0
Apocalipse.PvPBracketResilience.5059 = 16.0
Apocalipse.PvPBracketResilience.6069 = 18.0
Apocalipse.PvPBracketResilience.7079 = 20.0
```

These values reload on config reload and default in code. Keep production percentages in a safe 0 through 100 range.

### Battleground stamina keys

`conf/BattlegroundStamina.conf.dist` contains the complete contract:

- `Apocalipse.BattlegroundStamina.Enable`
- `Apocalipse.BattlegroundStamina.LockGear`
- `Apocalipse.BattlegroundStamina.AuraSpellId`
- `Apocalipse.BattlegroundStamina.GapCoveragePct`
- `Apocalipse.BattlegroundStamina.MaxBonusStamina`
- 70 `Apocalipse.BattlegroundStamina.HealthThreshold.<bracket>.<class>` entries

Modern AzerothCore module CMake discovers `conf/*.conf.dist` without an `AC_ADD_CONFIG_FILE` call, copies it as a module config, and loads it through `sConfigMgr`. Confirm `BattlegroundStamina.conf` appears in the CMake module config list and deployed config directory for the target custom-core revision.

## Building

Place or link the repository under the custom core's `modules/` directory, preserving the name `apocalipse-wow-module` because the loader entry point depends on it.

Typical parent-core build:

```bash
cmake .. -DMODULES=static
cmake --build . --parallel
```

Use `-DMODULES=dynamic` only when supported by the deployment core. Build with both this module and `mod-playerbots` enabled.

## Verification status

No standalone test harness exists in this repository. During the 2026-09-16 documentation update, sources, SQL, configuration, and sibling playerbot documentation were reviewed. The following were not run:

- Full custom-core build
- Worldserver startup
- Live database migrations
- Client DBC export or patch build
- In-game human or bot scenarios

Feature pages contain focused runtime matrices for future validation.

## Safety note

`deploy.ps1` only stages all files, creates a generic commit, and pushes. It does not build, test, inspect the branch, or validate deployment. Do not use it as a production deployment workflow.

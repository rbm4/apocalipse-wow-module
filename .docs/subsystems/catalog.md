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
| Battleground Stamina | `src/battleground_stamina/`, `conf/BattlegroundStamina.conf.dist`, `data/sql/db-world/2026_09_16_00_battleground_stamina_spell.sql` | Startup/config reload, player lifecycle/equipment hooks, battleground add/remove hooks | Process settings plus aura 901002 on eligible players | Bot equipment-lock exemption, talent/equipment recalculation, client/server custom spell contract |

## Shared surfaces

### Player hooks

Spec Manager and Battleground Stamina overlap on login and talent-related events. Their logic must remain independently safe because global callback ordering is not a stable business contract.

### Unit hooks

Spell Scaling and PvP Balancing overlap on direct and periodic damage. Both mutate the value by reference. Any new damage subsystem must document its registration order, eligibility guards, integer conversions, and expected stacking.

### Spell IDs

- 901001: Blazing Barrier, code constant, manual world migration, script binding, scaling row, and client DBC.
- 901002: Battleground stamina aura, config default, automatic world migration, runtime validator, and client DBC.

Changing either ID requires an atomic update across every listed surface.

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

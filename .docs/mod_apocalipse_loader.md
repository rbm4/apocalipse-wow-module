# Module loader

Status: Active

Owner: `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-16

## Purpose

This file exposes the entry point that AzerothCore discovers for the module directory and registers every gameplay subsystem.

The module directory name is transformed from hyphens to underscores:

```text
apocalipse-wow-module -> Addapocalipse_wow_moduleScripts()
```

The function name must continue to match the parent core's module discovery convention. A directory rename and loader rename must be deployed together.

## Registration order

| Order | Registration call | Owner |
|---:|---|---|
| 1 | `AddModApocalipseScripts()` | `src/mod_apocalipse.cpp` |
| 2 | `AddModSpellScalingScripts()` | `src/mod_spell_scaling.cpp` |
| 3 | `AddModApocalipsePvPScripts()` | `src/mod_apocalipse_pvp.cpp` |
| 4 | `AddModApocalipseMageSpellScripts()` | `src/mod_apocalipse_mage_spells.cpp` |
| 5 | `AddModApocalipseBattlegroundStaminaScripts()` | `src/battleground_stamina/BattlegroundStaminaScripts.cpp` |

The loader contains no gameplay state. Its order affects script registration and can affect the rounding sequence when multiple UnitScripts mutate the same damage value.

## Adding a subsystem

1. Add source under `src/`; the parent module build auto-collects sources.
2. Expose one `AddMod*Scripts()` registration function.
3. Add its declaration and call here.
4. Check overlap with existing WorldScript, PlayerScript, UnitScript, SpellScript, and battleground hooks.
5. Update root `README.md`, `.docs/architecture/overview.md`, `.docs/architecture/runtime-and-data-flow.md`, `.docs/subsystems/catalog.md`, and the relevant feature page.
6. Add a dated `.docs/history/` record and verify a full custom-core build.

## Failure mode

A subsystem source can compile but remain unreachable if its registration function is omitted here. Validate startup logs and runtime behavior in addition to compilation.

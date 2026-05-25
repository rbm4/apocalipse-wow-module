# mod_apocalipse_loader.cpp

## Purpose

Module entry-point required by the AzerothCore module system.

When AzerothCore loads a module it calls a function whose name is derived from the module's directory name with dashes replaced by underscores:

```
apocalipse-wow-module  →  Addapocalipse_wow_moduleScripts()
```

This file implements that function and delegates to the per-system registration functions declared in each other source file.

---

## Responsibilities

| Call | Source file registered |
|---|---|
| `AddModApocalipseScripts()` | `mod_apocalipse.cpp` — Spec Manager |
| `AddModSpellScalingScripts()` | `mod_spell_scaling.cpp` — Spell Scaling |
| `AddModApocalipsePvPScripts()` | `mod_apocalipse_pvp.cpp` — PvP Balancing |

---

## Notes

- Contains no game logic of its own.
- The exact function name **must** match the directory name convention or the module will silently fail to load.
- Adding a new sub-system to the module requires: creating a new `.cpp` file with its own `AddMod*Scripts()` function, then adding a forward declaration and call here.

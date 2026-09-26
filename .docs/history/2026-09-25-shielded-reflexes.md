# 2026-09-25: Shielded Reflexes

Status: Partial

## Intent

Add a shield-dependent Rogue passive that rewards a successful block with short stock Evasion and Blade Flurry windows on a 30-second internal cooldown.

## Scope

### Code and data

- `src/mod_apocalipse_rogue_shielded_reflexes.cpp`: adds shield and block validation, stock buff triggering, and duration preservation.
- `src/mod_apocalipse_loader.cpp`: registers the subsystem once.
- `data/sql/db-world/2026_09_25_03_shielded_reflexes.sql`: reserves guarded spell 901158 and installs its server, proc, binding, cache, and client-export input data.

### Documentation

- `.docs/custom-spells/shielded-reflexes.md`: records the complete spell and acquisition contract.
- Architecture, runtime flow, subsystem, playerbot, operations, README, feature, and history indexes now include Shielded Reflexes.

## Contracts changed

- Hooks or registration: adds `spell_apoc_rogue_shielded_reflexes` and `AddModApocalipseRogueShieldedReflexesScripts()`.
- Human behavior: a shield block can grant at least six seconds of stock Evasion and Blade Flurry once per 30 seconds.
- Bot behavior: identical mechanics; acquisition and shield selection remain external.
- Configuration: None.
- Database or migration: adds guarded automatic world update `2026_09_25_03_shielded_reflexes.sql`.
- Custom spell/client data: reserves single-row graph 901158; matching exported client `Spell.dbc` is required.
- Deployment or rollback: module build, updater execution, external acquisition, and client patch must ship together.

## Decisions

- Reuse stock Evasion 5277 and Blade Flurry 13877 so their native dodge, haste, replicated attack, visual, and proc behavior remain core-owned.
- Preserve stock aura durations longer than six seconds to avoid weakening an active ability cast.
- Keep acquisition external and identify 901158 as the only acquisition-facing ID.
- Use the native aura-owned `spell_proc` cooldown rather than module timer state.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Repository ID allocation | Search module SQL, C++, and documentation for 901158 and inspect newest ownership migrations | Passed before allocation |
| Core contracts | Inspect `SpellMgr.h`, `SpellAuras.cpp`, `spell_rogue.cpp`, stock SQL bindings, and read-only local `Spell.dbc` records 5277 and 13877 | Passed |
| Static source and SQL review | Registration, effect indexes, shield masks, proc flags, hit mask, cooldown, ownership guard, export contract, whitespace, line length, and stale-range scans | Passed |
| Exact custom-core build | Parent worldserver build with module and mod-playerbots | Not run: no configured build tree or compiler is available in the workspace |
| Database updater and startup | Authorized operator applies updater and inspects startup validation logs | Not run |
| Client export | Existing backend release builder produces and deploys matching Spell.dbc row 901158 | Not run |
| Human and playerbot scenarios | Owner-page verification matrix | Not run |

## Follow-up

- Authorized operator must validate live database and deployed-client collisions, execute the updater, export and deploy client data, inspect startup logs, and run the documented human and playerbot scenarios.

## References

- Custom spell: [`../custom-spells/shielded-reflexes.md`](../custom-spells/shielded-reflexes.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

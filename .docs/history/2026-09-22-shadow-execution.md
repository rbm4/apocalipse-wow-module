# 2026-09-22: Shadow Execution

Status: Partial

## Intent

Implement an offensive Rogue passive that converts damaging Rogue abilities into a stacking Shadow periodic effect based on attack-power-modified main-hand weapon damage.

## Scope

### Code and data

- `src/mod_apocalipse_rogue_shadow_execution.cpp`: Added direct Rogue ability proc filtering, per-target stack application, and main-hand damage amount calculation.
- `src/mod_apocalipse_loader.cpp`: Registered the new spell script.
- `data/sql/db-world/2026_09_22_08_shadow_execution.sql`: Added guarded spells 901081 and 901082, proc metadata, script bindings, zero coefficients, custom attributes, and backend names.

### Documentation

- `.docs/custom-spells/shadow-execution.md`: Added the owner contract, formulas, deployment requirements, and verification matrix.
- Architecture, subsystem, operation, playerbot, README, feature, and history indexes were updated for the new graph.

## Contracts changed

- Hooks or registration: Added `AddModApocalipseRogueShadowExecutionScripts()` and one AuraScript bound to passive 901081 and periodic aura 901082.
- Human behavior: Direct damaging Rogue-family abilities add one ten-second Shadow stack per damaged target, up to 50, with one-second ticks.
- Bot behavior: Identical mechanics after external acquisition, with no new action or strategy.
- Configuration: None.
- Database or migration: Added one guarded automatic world update and no `mod_spec_spells`, talent, or rank acquisition row.
- Custom spell/client data: Added server contracts for 901081 and 901082; matching client rows remain required.
- Deployment or rollback: Requires module rebuild, automatic world update, the existing external talent grant of single-rank passive 901081, and matching client patch.

## Decisions

- Duration is 10 seconds with one-second ticks, as selected by the requester.
- The existing external talent-tree flow must grant only single-rank passive 901081; helper 901082 is not an acquisition or rank ID.
- Direct Rogue-family damage events qualify. Auto attacks and existing periodic ticks are excluded so one ability does not repeatedly build stacks from its own later ticks.
- Native periodic damage and native aura stacking preserve normal Shadow mitigation, combat logs, threat, and per-target stack ownership.
- The per-stack amount uses `CalculateDamage(BASE_ATTACK, false, true)`, which includes current attack power in main-hand damage.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Static diff validation | `git diff --check` and no-index checks for new files | Passed; line-ending conversion warnings only |
| Source and data consistency | Manual C++ and SQL graph review against the deployment core and backend exporter | Passed |
| Custom-core worldserver build | Exact custom core with this module and `mod-playerbots` | Not run because core rules require an explicit build request |
| Updater and startup | Worldserver automatic migration and script validation | Not run |
| Client data | Export and inspect matching `Spell.dbc` rows | Not run |
| Human and playerbot gameplay | Owner page verification matrix | Not run |

## Follow-up

- Run live server and deployed-client collision checks for 901081 and 901082.
- Validate that the deployed external talent acquisition grants only passive 901081 and does not expose helper 901082.
- Build, run updater/startup validation, export the client patch, and execute the gameplay matrix.

## References

- Custom spell: [`../custom-spells/shadow-execution.md`](../custom-spells/shadow-execution.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

# 2026-09-21: Frozen Resolve

Status: Partial

## Intent

Implement a permanent Death Knight passive that builds deliberately bounded armor and damage reduction during sustained combat.

## Scope

### Code and data

- `src/mod_apocalipse_death_knight_frozen_resolve.cpp`: added the combat-gated periodic stack application.
- `src/mod_apocalipse_loader.cpp`: registered the new Death Knight spell script.
- `data/sql/db-world/2026_09_21_05_frozen_resolve.sql`: added guarded spell rows 901052 and 901053, script binding, non-save metadata, and backend names.

### Documentation

- `.docs/custom-spells/frozen-resolve.md`: recorded the current mechanical, data, deployment, and verification contracts.
- Architecture, operations, playerbot, feature, subsystem, history, and root indexes now reference Frozen Resolve.

## Contracts changed

- Hooks or registration: `AddModApocalipseDeathKnightFrozenResolveScripts()` now registers one AuraScript.
- Human behavior: passive owners gain one stack every 2-second passive tick while in combat.
- Bot behavior: identical to humans with no new AI action.
- Configuration: None.
- Database or migration: automatic guarded world update adds spells 901052 and 901053.
- Custom spell/client data: matching client rows for both spells are required, and the existing external acquisition flow must reference only unranked passive 901052.
- Deployment or rollback: world update, module rebuild, client patch, and externally owned acquisition are required.

## Decisions

- Used native armor and damage-taken aura handlers so the core owns effect composition and stack scaling.
- Used a permanent 2-second periodic passive plus an 8-second shared-duration stack aura to keep combat work bounded.
- Allocated 901052 and 901053 after concurrent Death Knight work claimed 901048 through 901051.
- Reused stock Icebound Fortitude icon 2720 from the checked-in deployment `Spell.dbc`.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Repository spell-ID scan | Search module migrations for 901052 and 901053 before creation | Passed for checked-in and current workspace sources; live server and deployed client remain pending |
| Custom DBC source read | Read stock spell 48792 from local `Spell.dbc` | Passed; icon 2720 confirmed |
| Static source and migration review | Focused code, loader, schema, ownership guard, rerun, and documentation inspection; `git diff --check`; spell insert count check | Passed; one loader call, matching binding, and 20/20 plus 28/28 insert counts |
| Documentation links | Repository-relative Markdown link scan across `README.md` and `.docs` | Passed with zero missing targets |
| Backend export contract | Apply 901052 and 901053 overrides through the current `SpellDbcPatcher` | Not run |
| Custom-core build | Parent worldserver build | Not run because the custom-core instructions require an explicit build request |
| SQL execution and updater startup | Apply the automatic world update and start worldserver | Not run by offline database policy |
| Human and bot runtime scenarios | Matrix in `custom-spells/frozen-resolve.md` | Not run because no runtime worldserver session was available |
| Client patch validation | Exported and deployed `Spell.dbc` | Not run; the in-memory exporter check is not a deployed client patch |

## Follow-up

- Build against the deployment custom core with this module and `mod-playerbots` enabled when a CMake and C++ toolchain is available.
- Run the named human and playerbot combat scenarios.
- Collision-check live server tables and the selected deployment client before applying the update.
- Validate the existing external acquisition flow references only passive 901052, and deploy matching client rows for both spell IDs.

## References

- Custom spell: [`../custom-spells/frozen-resolve.md`](../custom-spells/frozen-resolve.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

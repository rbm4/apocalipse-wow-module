# 2026-09-21: Ambush Trapper

Status: Partial

## Intent

Add a Survival Hunter signature passive that converts trap activations into five short-lived melee-special charges with capped percent-health Physical damage and mana restoration.

## Scope

### Code and data

- `src/mod_apocalipse_hunter_ambush_trapper.cpp`: Added trap-event validation, explicit self-targeted buff application, passive-removal cleanup, Hunter melee-special filtering, capped damage calculation, helper casts, and script registration.
- `src/mod_apocalipse_loader.cpp`: Registered `AddModApocalipseHunterAmbushTrapperScripts()` after Mage spell systems and before Paladin spell systems.
- `data/sql/db-world/2026_09_21_00_ambush_trapper.sql`: Added guarded spells 901038 through 901041, proc metadata, script bindings, non-save metadata, zero helper coefficients, lower-level scaling, and backend names.

### Documentation

- `.docs/custom-spells/ambush-trapper.md`: Added mechanics, proc, scaling, persistence, deployment, rollback, and verification contracts.
- Architecture, loader, operations, subsystem, playerbot, feature, history, root, and ownership indexes now include Ambush Trapper.

## Contracts changed

- Hooks or registration: Added two AuraScripts through `AddModApocalipseHunterAmbushTrapperScripts()`.
- Human behavior: Trap activation grants five melee-special charges for 15 seconds.
- Bot behavior: Identical when the bot has acquired passive 901038; existing trap and melee actions require no changes.
- Damage: Each consumed charge supplies Physical base damage equal to 2 percent of the lower of target and Hunter maximum health.
- Mana: Each consumed charge invokes native 5 percent maximum-mana energize.
- Shared hooks: Ambush Strike participates in Spell Scaling before PvP Balancing.
- Persistence: Predator's Ambush is non-saved and expires after 15 seconds or five procs.
- Database or migration: Added one automatic guarded world update and one `mod_spell_scaling` row.
- Custom spell/client data: Added server spells 901038 through 901041. Matching client rows and external acquisition for 901038 remain required.

## Decisions

- Used the core trap activation flag and finish phase instead of trap damage events.
- Required the trap proc spell and its original target to prevent false-positive synthetic events.
- Used native proc charges so the core decrements and removes the buff atomically.
- Defined a Hunter melee special as a Hunter-family spell with melee damage class and a landed damage or absorb event.
- Applied lower-level scaling to helper 901040 after calculating the capped percent-health base amount.
- Left talent and specialization acquisition outside this module migration.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Core proc path | Reviewed trap finish dispatch, proc filtering, and charge consumption in the deployment core | Passed by static review |
| Existing pattern | Reviewed Lock and Load trap filtering and module AuraScript proc implementations | Passed by static review |
| ID inventory | Repository search for 901038 through 901041 | No pre-existing module allocation found before implementation; live data not checked |
| SQL contract | Static review of collision guards, complete ownership signatures, proc rows, bindings, coefficients, scaling, and names | Passed |
| Independent source review | Checked compile APIs, proc phases, charge handling, eligibility, scaling order, and energize semantics against the deployment core | Passed by static review |
| Static graph contract | Checked IDs, loader registration, script names, and non-save metadata with a focused PowerShell assertion | Passed |
| Documentation links | Checked repository-relative Markdown links with PowerShell | Passed |
| Patch whitespace | `git diff --check` | Passed; existing line-ending conversion warnings remain |
| Custom-core build | Build worldserver with this module and mod-playerbots | Not run because no CMake, compiler, or configured build tree was available in the workspace environment |
| SQL execution | Apply updater to a disposable world database | Not run because database mutation was not authorized |
| Client export | Export and inspect matching client Spell.dbc rows | Not run |
| Human and bot scenarios | Execute the owner-page verification matrix | Not run because no runtime worldserver session was available |

## Follow-up

- Collision-check 901038 through 901041 in live world tables and deployed client data.
- Deploy talent acquisition for 901038 and matching client data for all four spells.
- Run worldserver startup validation and the documented human and bot scenarios.

## References

- Custom spell: [`../custom-spells/ambush-trapper.md`](../custom-spells/ambush-trapper.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

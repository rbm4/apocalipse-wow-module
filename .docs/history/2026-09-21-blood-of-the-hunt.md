# 2026-09-21: Blood of the Hunt

Status: Partial

## Intent

Add a shared Hunter passive that converts successful melee-special damage and trap activations into self-healing on one shared two-second internal cooldown.

## Scope

### Code and data

- `src/mod_apocalipse_hunter_blood_of_the_hunt.cpp`: Added Hunter melee-family and trap-event filtering, percent-heal calculations, helper casting, and script registration.
- `src/mod_apocalipse_loader.cpp`: Registered `AddModApocalipseHunterBloodOfTheHuntScripts()` after the existing Hunter systems.
- `data/sql/db-world/2026_09_21_01_blood_of_the_hunt.sql`: Added guarded spells 901044 and 901045, shared proc metadata, binding, zero coefficients, HEAL scaling, backend names, and a passive description that states the cooldown.

### Documentation

- `.docs/custom-spells/blood-of-the-hunt.md`: Added mechanics, eligibility, cooldown, scaling, deployment, rollback, and verification contracts.
- Architecture, loader, operations, subsystem, playerbot, feature, history, root, scaling, and ownership indexes now include Blood of the Hunt.

## Contracts changed

- Hooks or registration: Added one AuraScript through `AddModApocalipseHunterBloodOfTheHuntScripts()`.
- Human behavior: Eligible melee-special hits heal for 15 percent of damage and trap activations heal for 5 percent maximum health on one two-second cooldown.
- Bot behavior: Identical when the bot has acquired passive 901044; existing actions require no changes.
- Configuration: None.
- Database or migration: Added one automatic guarded world update and one `mod_spell_scaling` HEAL row.
- Custom spell/client data: Added server spells 901044 and 901045. Matching client rows and external acquisition for 901044 remain required.
- Deployment or rollback: Requires normal module rebuild, updater execution, and matching client export; no SQL was executed during implementation.

## Decisions

- Used exact Hunter melee family masks for Raptor Strike, Mongoose Bite, Wing Clip, and Counterattack rather than every Hunter-family melee damage-class spell.
- Used one `spell_proc` row with hit and finish phases so the aura-owned 2000 ms cooldown is shared across both event branches.
- Used a fixed direct-heal helper with custom base points so both formulas traverse normal healing and Spell Scaling hooks.
- Left talent and specialization acquisition outside this module migration.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Core proc path | Reviewed Aura cooldown ownership, trap finish dispatch, and melee hit dispatch in the deployment core | Passed by static review |
| Family masks | Read deployed client `Spell.dbc` entries for the supported melee-special rank families | Passed by static review |
| ID inventory | Repository search for 901044 and 901045 | No conflicting spell allocation found before implementation; live data not checked |
| SQL contract | Static review of collision guards, spell signatures, proc row, binding, coefficients, scaling, names, and cooldown description | Passed |
| Independent source review | Checked compile APIs, proc phases, shared cooldown ownership, family masks, scaling order, and neighboring Hunter interactions against the deployment core | Passed by static review |
| Patch whitespace | `git diff --check` plus trailing-whitespace scan of new files | Passed; existing line-ending conversion warnings remain |
| Custom-core build | Build worldserver with this module and mod-playerbots | Not run because builds require explicit request in the custom core |
| SQL execution | Apply updater to a disposable world database | Not run by user request |
| Client export | Export and inspect matching client Spell.dbc rows | Not run |
| Human and bot scenarios | Execute the owner-page verification matrix | Not run because no runtime worldserver session was available |

## Follow-up

- Collision-check 901044 and 901045 in live world tables and deployed client data.
- Deploy acquisition for 901044 and matching client data for both spells.
- Run worldserver startup validation and the documented human and bot scenarios.

## References

- Custom spell: [`../custom-spells/blood-of-the-hunt.md`](../custom-spells/blood-of-the-hunt.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

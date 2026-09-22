# 2026-09-22: Crimson Vial

Status: Partial

## Intent

Implement a generic Rogue active self-heal with seven current-maximum-health healing events, stealth preservation, native Energy cost, and native cooldown handling.

## Scope

### Code and data

- `data/sql/db-world/2026_09_22_09_crimson_vial.sql`: Added guarded data-only spell 901083, native percentage periodic healing, non-save metadata, and backend name.

### Documentation

- `.docs/custom-spells/crimson-vial.md`: Added the complete owner contract, runtime flow, deployment boundary, and verification matrix.
- Architecture, operations, playerbot, README, and history indexes were updated for spell 901083.

## Contracts changed

- Hooks or registration: None.
- Human behavior: A Rogue that acquires and casts 901083 spends 20 Energy and receives seven non-critical 5 percent maximum-health healing events over 6 seconds without breaking stealth.
- Bot behavior: Identical server mechanics after external acquisition and cast; no bot AI action or policy was added.
- Configuration: None.
- Database or migration: Added one guarded automatic world update and no acquisition row.
- Custom spell/client data: Added server contract 901083; a matching client `Spell.dbc` row remains required.
- Deployment or rollback: Requires the automatic world update, external acquisition if desired, and a matching client patch. No module C++ rebuild is required by this feature alone.

## Decisions

- Aura type 20 performs the percentage healing through the deployment core's native periodic path and recalculates current maximum health on each tick.
- A six-second aura with a one-second period and the immediate-period attribute produces seven healing events and a nominal 35 percent raw total.
- Healing remains subject to healing-taken modifiers, dampening, absorption, and overheal, but cannot critically heal or dispatch ordinary healing procs.
- Acquisition remains external because no specialization policy was selected.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Static diff validation | `git diff --check` and no-index checks for new files | Passed; line-ending conversion warnings only |
| Source and data consistency | Manual SQL contract review against the deployment core | Passed |
| Custom-core worldserver build | Exact custom core with this module and `mod-playerbots` | Not run because core rules require an explicit build request |
| Updater and startup | Worldserver automatic migration and spell loading | Not run |
| Client data | Export and inspect matching `Spell.dbc` row | Not run |
| Human and playerbot gameplay | Owner page verification matrix | Not run |

## Follow-up

- Run live server and deployed-client collision checks for 901083.
- Choose and deploy the external Rogue acquisition path.
- Run updater/startup validation, export the client patch, and execute the gameplay matrix.

## References

- Custom spell: [`../custom-spells/crimson-vial.md`](../custom-spells/crimson-vial.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

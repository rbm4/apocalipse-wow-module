# 2026-09-25: Threat of Thassarian extension

Status: Partial

## Intent

Extend the original Death Knight talent to support independent off-hand Heart Strike and Scourge Strike attacks without replacing its stock six-ability script, and keep Death Strike at one predictable half-strength heal while dual-wielding.

## Scope

### Code and data

- `src/mod_apocalipse_death_knight_threat_of_thassarian.cpp`: adds the exact-rank additive proc, Heart Strike explicit-target guard, three-effect source transfer, and Death Strike heal modifier.
- `src/mod_apocalipse_loader.cpp`: registers the subsystem once.
- `data/sql/db-world/2026_09_25_02_threat_of_thassarian_extension.sql`: reserves helpers 901156 and 901157, installs complete server and client-export rows, extends proc masks, binds scripts, updates talent descriptions, and adds backend names.

### Documentation

- `.docs/custom-spells/threat-of-thassarian-extension.md`: owns the complete mechanic, spell graph, acquisition boundary, deployment, rollback, and verification matrix.
- Architecture, runtime/data flow, playerbot integration, operations, indexes, subsystem catalog, root README, and history index now include the feature.

## Contracts changed

- Hooks or registration: additive AuraScript on `-65661`, existing Scourge Strike script on 901156, additive SpellScript on heal 45470, and one new loader call.
- Human behavior: talented usable-off-hand Heart Strike and Scourge Strike gain rank-chance off-hand attacks; qualifying Death Strike healing is halved once.
- Bot behavior: identical mechanics with no bot branch or AI dependency.
- Configuration: None.
- Database or migration: one automatic guarded world update; no SQL was executed during implementation.
- Custom spell/client data: helper rows 901156 and 901157 plus description overrides for 65661, 66191, and 66192 are required in the deployed `Spell.dbc`; `Talent.dbc` is unchanged.
- Deployment or rollback: world update, module build, and matching client patch must ship together; rollback restores the stock proc masks and client rows.

## Decisions

- Ranks 1 and 2 always halve Death Strike healing while the talent and usable off-hand are present, even when their probabilistic off-hand attack does not proc.
- The module composes with the stock Threat of Thassarian script instead of reproducing its existing six cases.
- Heart Strike runs only from the original explicit source target to prevent duplicate chained helpers.
- Scourge Strike reuses `spell_dk_scourge_strike`, so its Shadow amount derives from the off-hand Physical hit.
- Talent acquisition and talent-tree structure remain external and continue to reference 65661, 66191, and 66192.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Offline ID and stock-data review | Module migration ledger, deployment-core source and SQL, and read-only local `Spell.dbc` extraction | Passed for repository allocation and field contracts; live collision check pending |
| Static source and migration review | `git diff --check`, focused searches, schema review, and final diff inspection | Passed; only existing line-ending warnings were emitted |
| Exact custom-core build | Parent configured worldserver build | Not run; no configured build exists and `cmake` is unavailable in this environment |
| Database updater and startup | Authorized operator starts worldserver with updates enabled | Not run; operator-owned |
| Human and bot gameplay matrix | Scenarios in the owner page | Not run |
| Client export and deployed MPQ | Backend release builder plus selected client | Not run; operator-owned |

## Follow-up

- Authorized operator must validate live world-table and deployed-client collisions, run the updater, inspect startup validation, export and deploy matching client data, and execute focused human and playerbot scenarios.

## References

- Custom spell: [`../custom-spells/threat-of-thassarian-extension.md`](../custom-spells/threat-of-thassarian-extension.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

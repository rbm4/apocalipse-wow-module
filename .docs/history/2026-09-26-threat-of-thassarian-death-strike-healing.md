# 2026-09-26: Threat of Thassarian Death Strike healing

Status: Partial

## Intent

Let each successful off-hand Death Strike produce its own heal, then reduce every qualifying dual-wield Death Strike heal by 30 percent instead of 50 percent for higher overall healing.

## Scope

### Code and data

- Deployment-core `src/server/scripts/Spells/spell_dk.cpp`: validates the shared Death Strike handler for the main-hand and off-hand rank chains.
- `src/mod_apocalipse_death_knight_threat_of_thassarian.cpp`: changes the additive 45470 modifier from retaining 50 percent to retaining 70 percent.
- `data/sql/db-world/2026_09_25_02_threat_of_thassarian_extension.sql`: makes fresh installations use the off-hand core binding and current descriptions.
- `data/sql/db-world/2026_09_26_01_threat_of_thassarian_healing.sql`: adds the off-hand rank-chain binding and description updates to existing installations.

### Documentation

- `.docs/custom-spells/threat-of-thassarian-extension.md`: updates the spell graph, healing math, deployment contract, rollback, and verification matrix.
- Architecture, operations, playerbot integration, subsystem, feature, history, and root indexes now describe independent off-hand healing.

## Contracts changed

- Hooks or registration: `spell_dk_death_strike` is additionally bound to off-hand rank chain `-66188`; the existing module heal modifier remains bound to 45470.
- Human behavior: a landed off-hand Death Strike casts the same calculated heal as its corresponding main-hand rank. Each qualifying main-hand and off-hand heal retains 70 percent strength.
- Bot behavior: identical mechanics with no bot branch or AI dependency.
- Configuration: None.
- Database or migration: one automatic rerunnable world update adds the off-hand binding and updates the three guarded talent descriptions.
- Custom spell/client data: the talent descriptions for 65661, 66191, and 66192 change and require a refreshed client `Spell.dbc`; `Talent.dbc` remains unchanged.
- Deployment or rollback: deploy the deployment-core change, rebuilt module, world update, and refreshed client patch together. Rollback removes the `-66188` binding and restores the prior heal percentage and descriptions.

## Decisions

- Reuse the stock Death Strike handler so off-hand healing keeps stock disease count, minimum-health percentage, and Improved Death Strike behavior.
- Trigger the second heal only after the off-hand dummy effect lands; unsuccessful off-hand attacks do not heal.
- Retain 70 percent per heal, producing 140 percent total when both hands land and expected totals of 91, 112, and 140 percent before avoidance at talent ranks 1, 2, and 3.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Deployment-core spell and rank review | Inspect Death Strike and Threat of Thassarian scripts, spell-rank SQL, and local read-only `Spell.dbc` fields | Passed; off-hand ranks expose the same dummy heal effect as main-hand ranks |
| Static source and migration review | C++ codestyle linter, `git diff --check`, focused assertions, relative-link validation, and final diff inspection | Changed files passed whitespace, binding, percentage, rank, and link checks; the repository-wide core linter reported only existing violations outside `spell_dk.cpp` |
| Parent custom-core build | Build `worldserver` with this module and `mod-playerbots` | Not run because deployment-core instructions prohibit builds unless explicitly requested |
| Database updater and startup | Authorized operator runs the updater and reviews startup logs | Not run per offline-only repository policy |
| Client patch | Export and inspect all three updated talent descriptions | Not run |
| Human and bot gameplay | Run the owner-page landed, failed-proc, and avoided off-hand Death Strike scenarios | Not run |

## Follow-up

- Build and deploy through the operator workflow, regenerate the client patch, and run the documented human and playerbot combat matrix.

## References

- Custom spell: [`../custom-spells/threat-of-thassarian-extension.md`](../custom-spells/threat-of-thassarian-extension.md)
- Architecture: [`../architecture/runtime-and-data-flow.md`](../architecture/runtime-and-data-flow.md)
- Commit or PR: Not created

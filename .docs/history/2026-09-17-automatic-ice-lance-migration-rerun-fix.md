# 2026-09-17: Automatic Ice Lance migration rerun fix

Status: Completed

## Intent

Allow the Automatic Ice Lance world migration to recognize a previously inserted module-owned passive row and complete through the automatic updater.

## Scope

### Code and data

- `data/sql/db-world/2026_09_17_04_automatic_ice_lance.sql`: changed both passive ownership predicates to compare `EffectBasePoints_1` with the stored value 9 rather than the interpreted value 10.

### Documentation

- `.docs/custom-spells/automatic-ice-lance.md`: records the stored base-point representation and rerun requirement.
- `.docs/development/operations.md`: identifies the update as rerunnable for recognized rows.

## Contracts changed

- Hooks or registration: None.
- Human behavior: None. The effective proc value remains 10 percent.
- Bot behavior: None.
- Configuration: None.
- Database or migration: A previously applied 901010 row with stored `EffectBasePoints_1 = 9` is recognized as module-owned instead of causing collision guard error 1242.
- Custom spell/client data: None. The inserted server and client-facing spell value remains unchanged.
- Deployment or rollback: Deploy the corrected migration before restarting a server on which the file was imported manually but not recorded by the automatic updater.

## Decisions

- Kept the inserted base-point value at 9 because AzerothCore interprets it as 10, and corrected the ownership checks rather than changing gameplay data.
- Preserved the collision guard so genuinely non-matching rows still stop the migration before mutation.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Predicate and inserted-value consistency | Inspect all `EffectBasePoints_1` references for spell 901010 | Passed by static source review |
| Worldserver automatic update retry | Start the deployment worldserver with the preinserted rows | Not run |
| Human and bot proc rate | Focused in-game Automatic Ice Lance scenarios | Not run |

## Follow-up

- Retry the update against the backed-up deployment database and confirm it is registered successfully by the module updater.

## References

- Custom spell: [`../custom-spells/automatic-ice-lance.md`](../custom-spells/automatic-ice-lance.md)
- Operations: [`../development/operations.md`](../development/operations.md)
- Commit or PR: Not created

# 2026-09-25: Buckler Strike migration reapply fix

Status: Completed

## Intent

Prevent AzerothCore's module updater from reapplying the modified Buckler Strike baseline and failing its collision guard with `ERROR 1242` on databases that already contain the original managed row.

## Scope

### Code and data

- `data/sql/db-world/2026_09_22_06_buckler_strike.sql`: restored the previously applied six-second baseline and original description so its updater checksum and ownership predicate remain stable.

### Documentation

- `.docs/custom-spells/buckler-strike.md`: recorded the immutable baseline and follow-up balance update responsibilities.
- `.docs/development/operations.md`: distinguished the original baseline from the later current-state update.
- `.docs/history/README.md`: indexed this fix.

## Contracts changed

- Hooks or registration: None.
- Human behavior: None.
- Bot behavior: None.
- Configuration: None.
- Database or migration: the previously released baseline remains unchanged, while `2026_09_25_00_buckler_strike_balance.sql` exclusively owns the six-second to 20-second cooldown and description update.
- Custom spell/client data: None. The current deployed client contract remains a 20-second cooldown and current description.
- Deployment or rollback: the updater no longer needs to reapply the original baseline solely because current behavior was folded into that historical file.

## Decisions

- Restore the historical migration instead of weakening its collision guard. This preserves collision detection for unrelated rows while allowing already-applied databases to continue through the dated balance update.
- Keep current Buckler Strike behavior in the follow-up migration, which already recognizes both the original and current cooldown values.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Historical baseline comparison | `git diff e627abf^ -- data/sql/db-world/2026_09_22_06_buckler_strike.sql` | Passed when no diff remained |
| Follow-up ownership review | Static review of `2026_09_25_00_buckler_strike_balance.sql` | Passed: recognizes 6000 and 20000 ms, then writes 20000 ms and the current description |
| SQL runtime | AzerothCore module updater against MySQL | Not run under the repository offline-only database policy |
| In-game behavior | Human and playerbot Buckler Strike scenarios | Not run because gameplay code and current final data were unchanged |

## Follow-up

- Confirm the production updater accepts the restored baseline checksum and applies the dated balance update during the next authorized deployment.

## References

- Custom spell: [`../custom-spells/buckler-strike.md`](../custom-spells/buckler-strike.md)
- Operations: [`../development/operations.md`](../development/operations.md)
- Commit or PR: Not created

# Engineering change history

## Purpose

This directory provides a durable, dated trace of completed work. It complements git history by recording the gameplay and operational contracts affected, verification actually performed, and follow-up that remains.

History records do not replace current feature or subsystem documentation. Current behavior belongs in the owner page; a history record explains what one completed unit of work changed.

## Rules

1. Add one `YYYY-MM-DD-<lowercase-kebab-scope>.md` file for each completed feature, fix, migration, or documentation foundation.
2. Copy [`../templates/history-entry.md`](../templates/history-entry.md).
3. Name behavior, not a ticket or contributor.
4. Link the current feature/subsystem page and any commit or PR.
5. State `Not run` for verification that was not performed.
6. Add the entry to the index below.
7. Do not edit old records to pretend they described later behavior. Update current docs and add a new record.
8. If work is reverted, retain the record and mark it `Reverted` with the new reference.

## Index

| Date | Change | Status | Current context |
|---|---|---|---|
| 2026-09-16 | Battleground stamina spell migration repair | Completed | [`2026-09-16-battleground-stamina-spell-migration-repair.md`](2026-09-16-battleground-stamina-spell-migration-repair.md) |
| 2026-09-16 | Persistent documentation foundation | Completed | [`2026-09-16-documentation-foundation.md`](2026-09-16-documentation-foundation.md) |

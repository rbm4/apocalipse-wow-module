# 2026-09-22: Daring Challenge

Status: Partial

## Intent

Implement the essential Combat Rogue tank taunt with a short target-specific threat-generation window.

## Scope

- Added `src/mod_apocalipse_rogue_daring_challenge.cpp` and loader registration.
- Added guarded automatic world update `data/sql/db-world/2026_09_22_05_daring_challenge.sql` for active 901070 and helper 901071.
- Added the current contract in `../custom-spells/daring-challenge.md` and updated architecture, operations, playerbot, feature, subsystem, README, and history indexes.

## Contracts changed

- Native core effects own taunt immunity, highest-threat matching, and the three-second forced target.
- A successful taunt adds a one-point lead and a six-second target-specific outgoing-damage proc aura.
- Positive damage against that enemy adds 50 percent damage-based threat through normal modifiers and redirects.
- Combat Spec Manager grants the active to humans and playerbots; playerbot cast decisions remain external.
- Matching client rows for 901070 and 901071 are required.

## Verification

| Check | Result |
|---|---|
| Stock Taunt 355 DBC extraction and custom-core threat path review | Completed |
| Static source, SQL, and documentation review | Completed; `git diff --check` passed |
| Parent custom-core build | Not run |
| World updater startup | Not run |
| Client patch inspection | Not run |
| Human and playerbot gameplay matrix | Not run |

## Follow-up

Build with the deployment core, deploy guarded world and matching client data, then run every scenario in the owner page.

## References

- Current contract: [`../custom-spells/daring-challenge.md`](../custom-spells/daring-challenge.md)
- Commit or PR: Not created

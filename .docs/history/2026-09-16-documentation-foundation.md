# 2026-09-16: Persistent documentation foundation

Status: Completed

## Intent

Create a repository-owned context system so future agents can understand module boundaries, bot behavior, subsystem interactions, deployment requirements, and documentation obligations without repeating the full investigation.

## Scope

### Code and data

- No C++ behavior, configuration, or SQL was intentionally modified.
- The existing untracked `data/2026_09_16_01_blazing_barrier.sql` was read for context and left unchanged.
- A concurrent tracked change to `data/sql/db-world/2026_09_16_00_battleground_stamina_spell.sql` was observed and left untouched; documentation reflects the latest reviewed collision/rerun contract.

### Documentation

- Added root `AGENTS.md` with always-on maintenance and verification rules.
- Added an indexed `.docs` architecture, playerbot integration, operations, subsystem catalog, feature index, templates, and history system.
- Added Blazing Barrier custom-spell documentation.
- Corrected stale existing deep dives against current source.
- Updated root `README.md` to describe all five registered systems and current setup paths.

## Contracts changed

- Hooks or registration: None.
- Human behavior: None.
- Bot behavior: None.
- Configuration: None.
- Database or migration: None.
- Custom spell/client data: None.
- Deployment or rollback: Documentation only.

## Decisions

- Reused the documentation concepts already present in the sibling `mod-playerbots` repository so agents can follow a consistent workspace pattern.
- Kept `AGENTS.md` compact and delegated detail to indexed `.docs` pages.
- Separated current behavior from dated history to avoid turning README or architecture pages into chronological logs.
- Used source-reviewed status and explicitly retained unverified build/runtime state.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Source inventory | Read loader, all subsystem sources, SQL, config, existing docs, and sibling playerbot rules | Passed |
| Documentation link/path review | Validated 22 Markdown files with a repository-relative link checker | Passed with 0 broken links |
| Markdown hygiene | Checked trailing whitespace plus U+2013 and U+2014 across 22 Markdown files | Passed with 0 findings |
| Git whitespace review | `git diff --check` | Passed |
| Custom-core build | Full parent AzerothCore build | Not run because the full core checkout is not present in this workspace |
| Database migrations | Apply manual and automatic SQL | Not run; no database mutation requested |
| Runtime behavior | Start worldserver and execute in-game scenarios | Not run |

## Follow-up

- Build against the deployed custom AzerothCore and `mod-playerbots` branches.
- Resolve the compiled versus distributed 10-19 battleground threshold drift.
- Verify module config installation behavior for `conf/BattlegroundStamina.conf.dist`.
- Collision-check, export, and runtime-test custom spells 901001 and 901002.

## References

- Documentation index: [`../README.md`](../README.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Operations: [`../development/operations.md`](../development/operations.md)
- Commit or PR: Not created

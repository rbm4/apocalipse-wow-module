# Documentation workflow

## Principle

Documentation is part of implementation. Every agent must perform a documentation impact check and update the affected pages in the same change without waiting for an explicit documentation request.

## Separation by context

| Content | Location |
|---|---|
| Public purpose, feature summary, setup, and links | Root `README.md` |
| Always-on agent rules and mandatory workflow | Root `AGENTS.md` |
| Stable component boundaries and shared flows | `.docs/architecture/` |
| Bot-specific assumptions and behavior | `.docs/integrations/` |
| Detailed subsystem ownership | `.docs/subsystems/` or an existing subsystem deep dive |
| Cross-cutting feature contract | `.docs/features/<feature-name>.md` |
| Custom spell contract | `.docs/custom-spells/<spell-name>.md` |
| Build, config, SQL, migration, and release | `.docs/development/operations.md` |
| Dated trace of completed work | `.docs/history/YYYY-MM-DD-<scope>.md` |

Do not turn `AGENTS.md` or `README.md` into a work log. Do not duplicate whole architecture pages in feature documents. Link the owner page and record only the context needed at each level.

## Documentation triggers

Update documentation whenever work changes any of these:

- Module entry point, registration function, or registration order
- AzerothCore hook, callback, script class, or shared mutable event value
- Bot applicability, `IsBot()` behavior, gear/talent behavior, or playerbot core dependency
- Config key, default, validation, range, or reload behavior
- Database, table, query, seed, updater path, or migration order
- Custom spell ID, server attributes, script binding, scaling row, or client DBC requirement
- Gameplay formula, eligibility guard, failure path, cleanup, or persistence
- Build, test, release, rollback, or operator action
- Known limitation or validation status

Pure formatting changes may use a short history entry and do not need a feature page unless behavior or meaning changes.

## Workflow for every change

### Before implementation

1. Read `AGENTS.md` and `.docs/README.md`.
2. Trace the relevant loader registration, hook, config, SQL, spell ID, and bot path.
3. Choose the owner document before editing code.
4. For a new cross-cutting feature, copy `templates/feature.md` to `features/<lowercase-kebab-name>.md`.
5. For a new internal subsystem, copy `templates/subsystem.md` to `subsystems/<lowercase-kebab-name>.md`.

### During implementation

1. Keep code, SQL, config, and documentation names exact and synchronized.
2. Record decisions that prevent repeated investigation.
3. Record validation scenarios while the implementation context is fresh.
4. Distinguish proposed, implemented, source-reviewed, build-verified, and runtime-verified states.

### Before completion

1. Update the owner feature/subsystem/custom-spell page.
2. Update architecture if boundaries, hooks, order, or data flow changed.
3. Update playerbot integration if bot behavior or custom core assumptions changed.
4. Update operations if config, SQL, deployment, or verification changed.
5. Update root `README.md` when public behavior, setup, system list, or status changed.
6. Update every relevant index.
7. Add one history entry using `templates/history-entry.md`.
8. Check repository-relative links and named paths.
9. Review documentation against the final diff, not the original plan.
10. State exactly what verification was and was not run.

## Naming

- Use lower-case kebab-case for new documentation files.
- Name files after behavior or subsystem, not a ticket, branch, or contributor.
- Use ISO dates in history file names.
- Prefer stable symbols and paths over line numbers.

## Status language

Use explicit status terms:

- `Proposed`: documented design without implementation.
- `Implemented`: source exists, but build/runtime may not be verified.
- `Source reviewed`: documentation was checked against current repository files.
- `Build verified`: exact build command completed successfully.
- `Runtime verified`: named in-game or server scenario was observed successfully.
- `Deprecated` or `Retired`: behavior remains only for migration/history.

Never convert `Not run`, `Unknown`, or `Pending` into a successful status based on inference.

## Review checklist

- [ ] Source paths and symbols exist.
- [ ] Loader and hook registrations are complete.
- [ ] Human and bot behavior are both stated.
- [ ] Databases and updater/manual migration paths are correct.
- [ ] Config file defaults match code defaults or drift is explicitly recorded.
- [ ] Custom spell server and client requirements are both covered.
- [ ] Cross-subsystem value stacking and event overlap are covered.
- [ ] Failure, cleanup, rollback, and restart behavior are covered.
- [ ] README and indexes are current.
- [ ] A dated history entry links code and documentation scope.
- [ ] Verification claims match actual commands and observations.

# 2026-09-17: Missile Barrage Overload

Status: Partial

## Intent

Add the server-side spell and gameplay scripts for an Arcane Mage passive that accumulates repeated Missile Barrage procs, adds one Arcane Missiles tick per additional proc, and consumes the accumulated proc on use.

## Scope

### Code and data

- `src/mod_apocalipse_mage_missile_barrage_overload.cpp`: Added proc counting, duration-modifier adjustment, aggregate consumption, cleanup, and release visual behavior.
- `src/mod_apocalipse_loader.cpp`: Registered the new spell-script owner.
- `data/sql/db-world/2026_09_17_01_missile_barrage_overload.sql`: Added guarded spell 901004 creation, script bindings, and backend spell name synchronization.

### Documentation

- `.docs/custom-spells/missile-barrage-overload.md`: Added the gameplay, data, interaction, visual, deployment, and verification contract.
- Architecture, loader, operations, subsystem, feature, playerbot, root README, and history indexes were synchronized.

## Contracts changed

- Hooks or registration: Added one module registration function and AuraScripts bound to spells 44401 and 901004.
- Human behavior: Passive holders can accumulate up to 20 Missile Barrage procs and release them through a longer Arcane Missiles channel.
- Bot behavior: Identical mechanics; existing AI remains binary and does not optimize for the cap.
- Configuration: None.
- Database or migration: Added an automatic guarded world update for spell 901004 and two exact script bindings.
- Custom spell/client data: Added server spell 901004. Matching client Spell.dbc and separate acquisition data remain required.
- Deployment or rollback: Worldserver restart and updater execution are required. Rollback removes the custom passive and exact module bindings after normal backup and shutdown procedures.

## Decisions

- Used 44401 charges as the visible proc counter instead of real aura stacks because real stacks multiply all three Missile Barrage modifiers.
- Kept the first proc equivalent to normal Missile Barrage and added one 500 ms tick for each additional proc.
- Capped the script and passive at 20 procs.
- Preserved the existing T8 retention, T10 activation, Clearcasting priority, and spell-proc consumption paths.
- Used existing visual-only spell 35426 at its client-defined size. Server-side particle scaling was not attempted.
- Left talent and specialization acquisition outside this change.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Source and registration review | Inspect new source and `Addapocalipse_wow_moduleScripts()` | Passed by static review |
| SQL contract review | Inspect collision guard, spell signature, bindings, and backend cache row | Passed by static review |
| Forbidden Unicode punctuation scan | Search feature source, SQL, and documentation for U+2013 and U+2014 | Passed |
| C++ line length | Search new source for lines longer than 80 characters | Passed |
| C++ formatter | `clang-format --dry-run --Werror src/mod_apocalipse_mage_missile_barrage_overload.cpp` | Inconclusive: returned exit 1 without diagnostics; diagnostic retry was not authorized |
| Diff whitespace | `git diff --check` | Passed; Git reported only line-ending conversion warnings |
| Custom-core build | Build `worldserver` with this module and `mod-playerbots` | Not run under the custom-core instruction to skip builds unless explicitly requested |
| SQL execution | Apply updater to a non-production `acore_world` | Not run; no database mutation was authorized |
| Client data | Export and inspect matching Spell.dbc and talent data | Not run |
| In-game scenarios | Execute the Missile Barrage Overload runtime matrix | Not run |

## Follow-up

- Build the exact deployment core when explicitly authorized.
- Apply and inspect the updater in a non-production world database.
- Add acquisition data and export matching client Spell.dbc.
- Run human and bot scenarios, including T8 and T10 set bonuses.
- Add a custom client visual kit if a larger release explosion is desired.

## References

- Feature: [`../custom-spells/missile-barrage-overload.md`](../custom-spells/missile-barrage-overload.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

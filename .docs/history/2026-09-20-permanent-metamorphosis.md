# 2026-09-20: Permanent Metamorphosis

Status: Partial

## Intent

Make activated Demonology Metamorphosis last indefinitely while preserving stock activation, cooldown, effects, and cleanup behavior.

## Scope

### Code and data

- `src/mod_apocalipse_warlock_permanent_metamorphosis.cpp`: conditionally makes aura 47241 infinite, upgrades an active form when the passive is learned, and removes it on passive loss, talent reset, login recovery, logout, and mount attempts.
- `src/mod_apocalipse_loader.cpp`: registers the duration and lifecycle scripts.
- `data/sql/db-world/2026_09_20_03_permanent_metamorphosis.sql`: installs passive 901030, backend cache data, and Demonology acquisition.
- `data/mod_apocalipse.sql`: seeds passive 901030 for new Spec Manager installations.

### Documentation

- `.docs/custom-spells/permanent-metamorphosis.md`: records the current spell graph, cleanup boundaries, data contract, and runtime matrix.
- Architecture, playerbot, operations, feature, subsystem, history, and root README indexes describe the new feature.

## Contracts changed

- Hooks or registration: adds `AllSpellScript` maximum-duration and mount cast-check hooks plus player spell-learn, spell-forget, talent-reset, login, and pre-logout hooks.
- Human behavior: passive owners activate stock Metamorphosis normally, then retain aura 47241 until cleanup.
- Bot behavior: identical mechanics; existing checks for 47241 and casts of 59672 remain valid.
- Configuration: None.
- Database or migration: automatic world update adds 901030 and its Demonology `mod_spec_spells` row; manual baseline receives the same seed.
- Custom spell/client data: deployed clients require exported spell row 901030.
- Deployment or rollback: world update, client export, module rebuild, and focused runtime checks are required.

## Decisions

- Preserve 59672 as activation and cooldown owner instead of granting the form automatically.
- Change only aura 47241 instances owned by passive holders instead of modifying stock DBC duration globally.
- Remove the form before mount shapeshift validation, accepting that a later failed mount check still leaves the form removed.
- Rely on stock aura removal for temporary abilities, linked Immolation Aura, and death cleanup.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Source and hook review | Inspect matching custom-core duration and cast-check paths | Passed |
| Diff integrity | `git diff --check` | Passed |
| C++ line length | New source lines over 80 characters | Passed, none found |
| Module build | Parent custom-core `worldserver` build | Not run: no configured build directory and core instructions require an explicit build request |
| World update and client export | Startup updater and backend `Spell.dbc` export | Not run |
| Human and bot scenarios | Matrix in permanent Metamorphosis owner page | Not run |

## Follow-up

- Run the documented SQL, client export, startup, and in-game matrix in the deployment environment.

## References

- Custom spell: [`../custom-spells/permanent-metamorphosis.md`](../custom-spells/permanent-metamorphosis.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

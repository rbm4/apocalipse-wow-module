# 2026-09-17: Frost Bomb

Status: Partial

## Intent

Add a Frost Mage bomb that detonates after four seconds, on enemy dispel, or on target death, then deals target-centered Frost area damage and applies a Permafrost-scaled slow.

## Scope

### Code and data

- `src/mod_apocalipse_mage_frost_bomb.cpp`: implements removal filtering, proc-enabled explosion, per-victim slow application, and Permafrost scaling.
- `src/mod_apocalipse_loader.cpp`: registers Frost Bomb while preserving existing registration order.
- `data/sql/db-world/2026_09_17_03_frost_bomb.sql`: defines spells 901007, 901008, and 901009, their script bindings, the explosion coefficient, and backend names.

### Documentation

- `.docs/custom-spells/frost-bomb.md`: records mechanics, proc assumptions, bot behavior, migration, failures, rollback, and runtime checks.
- Architecture, loader, operations, subsystem, feature, playerbot, root README, and documentation indexes include Frost Bomb.

## Contracts changed

- Hooks or registration: Added three spell scripts and `AddModApocalipseMageFrostBombScripts()`.
- Human behavior: A mage with acquisition data can spend 22 percent base mana on a 1.5 second cast and 16 second cooldown to create the four-second bomb.
- Bot behavior: Bot-controlled mages receive identical mechanics; acquisition and rotation policy remain external.
- Configuration: None.
- Database or migration: Added automatic world update `2026_09_17_03_frost_bomb.sql`.
- Custom spell/client data: Reserved provisional IDs 901007 through 901009 and requires matching client `Spell.dbc` rows.
- Deployment or rollback: Requires a module build, automatic world update, client patch, restart, and focused in-game validation.

## Decisions

- Used separate application, explosion, and slow spells so each surface has one responsibility and can be represented in client and server spell data.
- Used the aura duration system rather than a C++ timer.
- Added death to the Living Bomb-inspired removal filter while retaining explicit exclusions for default, cancel, and cleanup removals.
- Used Living Bomb rank 3's 690 base explosion damage, 10-yard radius, and 0.4 direct coefficient as the tuning baseline.
- Did not copy Living Bomb's proc suppression or crowd-control preservation because Frost Bomb must produce normal damage procs and break eligible crowd control.
- Read Permafrost rank effects from the caster so its 4/7/10 percent slow increase, 1/2/3 second duration increase, and existing healing reduction remain rank-dependent.

## Verification

| Check | Result |
|---|---|
| Source, core, DBC, and SQL design review | Passed |
| Custom ID scan in module source and data | Passed for local repository state |
| AzerothCore C++ codestyle | Passed |
| Independent source review | Passed after correcting DBC base-point encoding and reapply handling |
| Repository whitespace review | Passed; line-ending conversion warnings remain informational |
| Parent custom-core build | Not run |
| Worldserver startup and script validation | Not run |
| Automatic world migration | Not run |
| Client patch export | Not run |
| Human and bot runtime matrix | Not run |

## Follow-up

- Add acquisition through its separately owned trainer, talent, item, or specialization workflow.
- Build against the deployment core, apply the update in a backed-up non-production database, export all three client spell rows, and complete the runtime matrix.

## References

- Custom spell: [`../custom-spells/frost-bomb.md`](../custom-spells/frost-bomb.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

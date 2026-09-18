# 2026-09-17: Automatic Ice Lance

Status: Partial

## Intent

Add a Frost Mage passive that automatically casts Ice Lance from eligible direct Frost damage and rewards each proc with an independently expiring spell-haste contribution.

## Scope

### Code and data

- `src/mod_apocalipse_mage_automatic_ice_lance.cpp`: implements proc filtering, target validation, triggered Ice Lance, Fingers of Frost compatibility, and the bounded expiration queue.
- `src/mod_apocalipse_loader.cpp`: registers Automatic Ice Lance after Frost Bomb.
- `data/sql/db-world/2026_09_17_04_automatic_ice_lance.sql`: defines spells 901010 and 901011, proc metadata, script bindings, non-save metadata, and backend names.

### Documentation

- `.docs/custom-spells/automatic-ice-lance.md`: records mechanics, proc and target guards, independent expiration behavior, bot applicability, migration, rollback, and runtime checks.
- Architecture, operations, playerbot, root README, and documentation indexes include Automatic Ice Lance.

## Contracts changed

- Hooks or registration: Added two AuraScripts and `AddModApocalipseMageAutomaticIceLanceScripts()`.
- Human behavior: A mage with passive 901010 has a 10 percent chance on eligible direct Frost damage, limited by a one-second cooldown, to cast Ice Lance and gain one temporary haste contribution.
- Bot behavior: Bot-controlled mages receive identical mechanics when passive 901010 is known.
- Configuration: None.
- Database or migration: Added automatic world update `2026_09_17_04_automatic_ice_lance.sql`.
- Custom spell/client data: Reserved provisional IDs 901010 and 901011 and requires matching client `Spell.dbc` rows.
- Deployment or rollback: Requires a module build, automatic world update, client patch, restart, and focused in-game validation.

## Decisions

- Used `spell_proc` for Mage family, Frost school, direct damage hit, 10 percent chance, and 1000 ms cooldown filtering.
- Retained C++ guards for player origin, non-triggered casts, direct damage, Ice Lance, Frost Bomb Explosion, full line of sight, and target validity.
- Allowed proc events from automatic Ice Lance so the deployment core's Fingers of Frost script consumes a charge normally.
- Stored monotonic expiration times in one aura-local FIFO instead of ordinary aura stacks, preventing new procs from refreshing older contributions.
- Limited the queue to 20 entries, removed every overdue entry per periodic update, and made the temporary aura non-persistent.

## Verification

| Check | Result |
|---|---|
| Source, core proc, aura, target, and SQL design review | Passed |
| Custom ID scan in module source and data | Passed for local repository state |
| Parent custom-core build | Not run |
| Worldserver startup and script validation | Not run |
| Automatic world migration | Not run |
| Client patch export | Not run |
| Human and bot runtime matrix | Not run |

## Follow-up

- Add acquisition through its separately owned talent, trainer, item, or specialization workflow.
- Build against the deployment core, apply the update in a backed-up non-production database, export both client spell rows, and complete the runtime matrix.

## References

- Custom spell: [`../custom-spells/automatic-ice-lance.md`](../custom-spells/automatic-ice-lance.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

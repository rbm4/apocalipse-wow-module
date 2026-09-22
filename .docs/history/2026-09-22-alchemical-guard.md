# 2026-09-22: Alchemical Guard

Status: Partial

## Intent

Implement the Combat Rogue active defensive Alchemical Guard without adding acquisition behavior.

## Scope

### Code and data

- `src/mod_apocalipse_rogue_alchemical_guard.cpp`: validates the active aura contract.
- `src/mod_apocalipse_loader.cpp`: registers the Rogue spell script.
- `data/sql/db-world/2026_09_22_04_alchemical_guard.sql`: allocates guarded spell 901077 and installs its native effects and metadata.

### Documentation

- `.docs/custom-spells/alchemical-guard.md`: records the complete gameplay and deployment contract.
- Architecture, operations, playerbot, feature, subsystem, README, and history indexes: include the new active.

## Contracts changed

- Hooks or registration: `AddModApocalipseRogueAlchemicalGuardScripts()` is registered after the Hunter scripts.
- Human behavior: acquired spell 901077 provides 20 percent all-damage reduction and poison/disease cleanse and immunity for 6 seconds.
- Bot behavior: identical mechanics; acquisition and cast-decision policy remain external.
- Configuration: None.
- Database or migration: automatic guarded world migration adds spell 901077 and related rows.
- Custom spell/client data: one matching client `Spell.dbc` row is required.
- Deployment or rollback: world update, rebuilt module, and matching client patch must deploy together.

## Decisions

- Use native dispel-immunity auras with immunity-purge metadata so cleanup and prevention share the same poison/disease classification.
- Use spell ID 901077 because current module migrations allocate through 901076.
- Preserve stealth through the stock allow-while-stealthed attribute and allow casts while stunned, feared, confused, silenced, or pacified.
- Keep acquisition outside this change.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Source and migration review | Exact C++ constants, SQL fields, IDs, binding, and loader symbols | Passed static review and `git diff --check` |
| Custom-core build | Parent `worldserver` build | Not run |
| Database updater | Start worldserver against deployment world database | Not run |
| Client patch | Export and inspect spell 901077 | Not run |
| Human and bot gameplay | Runtime matrix in owner page | Not run |

## Follow-up

- Build against the deployment core and playerbot branches.
- Deploy the world update and client row, then execute all runtime scenarios.
- Configure acquisition in its owning system.

## References

- Custom spell: [`../custom-spells/alchemical-guard.md`](../custom-spells/alchemical-guard.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

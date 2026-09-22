# 2026-09-22: Buckler Strike

Status: Partial

## Intent

Implement the approved Combat Rogue shield attack as a complete guarded custom-spell graph without changing its separately owned acquisition flow.

## Scope

### Code and data

- `src/mod_apocalipse_rogue_buckler_strike.cpp`: added shield validation, AP and shield-block-value damage, final-damage bonus threat, player interrupt suppression, and script registration.
- `src/mod_apocalipse_loader.cpp`: registered the Buckler Strike subsystem.
- `data/sql/db-world/2026_09_22_06_buckler_strike.sql`: added guarded spell 901078, its script binding, and backend export name.

### Documentation

- `.docs/custom-spells/buckler-strike.md`: recorded current mechanics, ownership, interactions, and verification scenarios.
- Architecture, runtime, operations, feature, subsystem, playerbot, root, and history indexes were updated for the new active.

## Contracts changed

- Hooks or registration: one `SpellScript` is registered from `Addapocalipse_wow_moduleScripts()`.
- Human behavior: learned spell 901078 provides the shield-required active with the approved damage and threat formulas.
- Bot behavior: identical mechanics; shield selection and active-cast policy remain external.
- Configuration: None.
- Database or migration: automatic guarded world update added for 901078.
- Custom spell/client data: matching client `Spell.dbc` row 901078 is required but was not generated or deployed.
- Deployment or rollback: world updater, module rebuild, client export, restart, and focused runtime verification are required; rollback removes the graph and registration.

## Decisions

- Allocated 901078 after concurrent repository work occupied IDs through 901077.
- Implemented damage as 20 percent melee attack power plus 150 percent total shield block value, as selected by the user.
- Implemented total damage-based threat as three times final damage by adding a two-times final-damage bonus after normal one-times damage threat.
- Kept acquisition out of scope as explicitly requested.
- Reused the native interrupt effect and prevented it only for player targets so core cast eligibility, immunity, and school lockout behavior remain authoritative.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Core API trace | Static review of `Spell::EffectInterruptCast`, `Spell::DoAllEffectOnTarget`, equipped-item validation, combo-point handling, and `ThreatManager::AddThreat` | Passed |
| SQL ownership and schema review | Static inspection of guarded migration and current module precedents | Passed |
| Forbidden punctuation scan | Repository search across Buckler Strike changed content | Passed |
| Parent worldserver build | Custom core build with module and `mod-playerbots` | Not run during implementation |
| Updater and startup | Authorized worldserver startup with automatic migration | Not run; requires deployment environment |
| Client export | Generate and deploy matching MPQ/`Spell.dbc` row | Not run; operator work |
| Human and playerbot scenarios | Matrix in `../custom-spells/buckler-strike.md` | Not run; requires runtime environment |

## Follow-up

- Run the parent custom-core build and resolve any exact-branch compiler findings.
- Collision-check 901078 in the live world tables and deployed client before migration.
- Generate and deploy the matching client spell row.
- Connect external talent or acquisition data to 901078.
- Run the documented human and playerbot matrix.

## References

- Custom spell: [`../custom-spells/buckler-strike.md`](../custom-spells/buckler-strike.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

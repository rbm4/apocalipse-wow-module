# 2026-09-22: Gloomblade Infusion

Status: Partial

## Intent

Implement a Subtlety Rogue offensive passive that adds a separate Shadow damage event equal to 10 percent of every owner-attributed damage event, including Rogue abilities and poisons.

## Scope

### Code and data

- `src/mod_apocalipse_rogue_gloomblade_infusion.cpp`: Added broad owner-attributed damage filtering, percentage calculation, recursion prevention, and the custom Shadow hit.
- `src/mod_apocalipse_loader.cpp`: Registered the Gloomblade Infusion script subsystem.
- `data/sql/db-world/2026_09_22_07_gloomblade_infusion.sql`: Added guarded passive 901079, damage helper 901080, proc metadata, script binding, zero coefficient, Subtlety acquisition, and backend names.

### Documentation

- `.docs/custom-spells/gloomblade-infusion.md`: Added the current mechanical, data, deployment, rollback, and verification contract.
- Architecture, runtime, operations, feature, subsystem, playerbot, history, and root indexes were updated for the new spell graph.

## Contracts changed

- Hooks or registration: Added an AuraScript outgoing-damage proc and loader registration.
- Human behavior: Owner-attributed positive damage generates a non-critical Shadow hit with base damage equal to 10 percent of the final triggering event.
- Bot behavior: Identical to human Subtlety Rogues; no new cast action is required.
- Configuration: None.
- Database or migration: Added automatic world migration `2026_09_22_07_gloomblade_infusion.sql`.
- Custom spell/client data: Added server rows 901079 and 901080; matching client rows remain required.
- Deployment or rollback: Requires world update, module rebuild, coordinated client patch, and the documented row and registration rollback.

## Decisions

- Broad proc metadata and direct-owner checks cover auto attacks, direct abilities, periodic effects, poisons, and valid triggered damage without maintaining a fragile spell allowlist.
- Both proc actor and `DamageInfo` attacker must be the aura owner, while self-damage and reflected-hit metadata are rejected.
- Helper 901080 cannot critically strike, has no coefficient, and uses the generic spell family. Passive 901079 permits triggered source damage but excludes helper 901080 explicitly to prevent recursion, while Rogue-family passives such as Shadow Execution do not accept the helper.
- The helper uses normal Shadow damage resolution, so its final health loss can be lower than 10 percent after independent target mitigation.
- Passive 901079 is attached to Rogue class 4, Subtlety tree index 2 through Spec Manager.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Static source and SQL review | Inspect exact IDs, proc metadata, binding, coefficient deletion, acquisition, and registration | Passed |
| Whitespace validation | `git diff --check` plus no-index checks for new files | Passed; line-ending conversion warnings only |
| Parent worldserver build | Build exact custom core with module and playerbots | Not run per custom-core repository guidance |
| World updater and startup | Start worldserver against reviewed world data | Not run |
| Human and playerbot gameplay matrix | Run scenarios from the custom spell page | Not run |
| Client export and collision check | Verify both rows in the deployed client patch | Not run |

## Follow-up

- Run the parent custom-core build, updater, startup, deployed-client collision check, client export, and in-game verification matrix.

## References

- Custom spell: [`../custom-spells/gloomblade-infusion.md`](../custom-spells/gloomblade-infusion.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

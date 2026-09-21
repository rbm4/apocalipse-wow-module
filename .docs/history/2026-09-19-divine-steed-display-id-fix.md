# 2026-09-19: Divine Steed display-ID fix

Status: Partial

## Intent

Correct Divine Steed rendering an unrelated untextured humanoid instead of a faction-specific paladin charger.

## Scope

### Code and data

- `src/mod_apocalipse_paladin_divine_steed.cpp`: Replaced creature entry IDs 14565 and 20030 with direct creature display IDs 14584 and 19085.
- Database migrations: None.

### Documentation

- `.docs/custom-spells/divine-steed.md`: Documented the creature-entry to display-ID relationship and updated expected runtime displays.
- `.docs/architecture/runtime-and-data-flow.md` and `README.md`: Updated the Divine Steed display contract.
- `.docs/history/2026-09-18-divine-steed.md`: Marked the original display-ID interpretation as superseded.

## Contracts changed

- Hooks or registration: None.
- Human behavior: Alliance and Horde Divine Steed casts now request the Charger and Thalassian Charger display records expected by the 3.3.5a client.
- Bot behavior: Identical to human players.
- Configuration: None.
- Database or migration: None.
- Custom spell/client data: No custom DBC row changed. The implementation now uses stock CreatureDisplayInfo IDs 14584 and 19085 directly.
- Deployment or rollback: Rebuild and deploy the module. Rollback restores display constants 14565 and 20030.

## Decisions

- Divine Steed continues to write `UNIT_FIELD_MOUNTDISPLAYID` directly so ordinary combat remains available.
- Direct display writes use the final `creature_template_model.CreatureDisplayID`, not the creature entry stored by a stock mounted aura.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Stock relationship | Inspect `creature_template_model` for creature entries 14565 and 20030 | Passed; resolved displays are 14584 and 19085 |
| Static references | Search module source and current documentation for display constants | Passed |
| Diff validation | `git diff --check` | Passed; only existing line-ending warnings were emitted |
| Parent worldserver build | Build custom core with module and playerbots | Not run; build was not requested |
| In-game rendering | Cast 901017 on Alliance and Horde paladins | Not run |

## Follow-up

- Rebuild and deploy the module.
- Verify both faction displays in the deployed 3.3.5a client, including enabled race and sex combinations.

## References

- Custom spell: [`../custom-spells/divine-steed.md`](../custom-spells/divine-steed.md)
- Architecture: [`../architecture/runtime-and-data-flow.md`](../architecture/runtime-and-data-flow.md)
- Commit or PR: Not created

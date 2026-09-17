# 2026-09-16: Battleground stamina spell migration repair

Status: Completed

## Intent

Repair custom spell 901002 after its original world update inherited `EquippedItemClass = 0`, which caused `HasItemFitToSpellRequirements` errors and could reject the stamina aura cast. Make the original updater safe to execute again on an installation where the updater filename may already be recorded.

## Scope

### Code and data

- `data/sql/db-world/2026_09_16_00_battleground_stamina_spell.sql`: explicitly sets the no-equipment requirement, recognizes an existing module-owned spell, repairs prior rows, preserves first-deployment collision protection, and makes dependent inserts rerunnable.

### Documentation

- `.docs/custom-spells/battleground-stamina-assistance.md`: records the equipped-item contract, rerun behavior, and failure recovery.
- `.docs/development/operations.md`: adds the production repair procedure and verification query.
- `README.md`: identifies the updater as manually rerunnable for this repair under normal production safeguards.

## Contracts changed

- Hooks or registration: None.
- Human behavior: Spell 901002 can pass the core equipped-item requirement check after the corrected row is loaded.
- Bot behavior: Same as human behavior.
- Configuration: None.
- Database or migration: Spell 901002 now uses `EquippedItemClass = -1`, `EquippedItemSubclass = 0`, and `EquippedItemInvTypes = 0`; the updater is idempotent for the recognized module-owned row.
- Custom spell/client data: Server spell equipment requirements are explicit. Matching client spell data must retain the same values.
- Deployment or rollback: Existing installations may manually rerun the updater while worldserver is stopped, after backup, then restart to reload spell data.

## Decisions

- Recognize module ownership through the existing spell name and stamina-effect signature instead of blindly updating any row with ID 901002.
- Keep first-run collision failure behavior for non-matching records in `spell_dbc`, `wotlk_spells_full`, or `wotlk_spells`.
- Repair only the equipped-item fields on an existing owned `spell_dbc` row so unrelated live tuning is not overwritten.
- Guard dependent upserts with a post-insert spell signature check.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Static field mapping | Compared the migration with the custom core `spell_dbc` schema and `Player::HasItemFitToSpellRequirements` | Passed |
| First-run path review | Traced the collision guard with no existing 901002 rows | Passed by static review |
| Existing-installation path review | Traced ownership detection, field repair, skipped insert, and dependent upserts | Passed by static review |
| Foreign-collision path review | Traced non-matching IDs to the scalar collision guard before all mutations | Passed by static review |
| Production database execution | Execute the revised updater against `acore_world` | Not run; no database mutation was authorized or performed |
| Runtime behavior | Restart worldserver and apply battleground stamina assistance | Not run |
| Custom-core build | Build worldserver with the module and playerbots | Not run; SQL and documentation only changed |

## Follow-up

- Back up `acore_world`, stop worldserver, and execute the revised updater on the affected installation.
- Restart worldserver and verify the equipped-item values are `-1`, `0`, and `0`.
- Confirm spell 901002 applies and the `HasItemFitToSpellRequirements` log no longer appears.
- Verify deployed client `Spell.dbc` uses the same no-equipment requirement.

## References

- Custom spell: [`../custom-spells/battleground-stamina-assistance.md`](../custom-spells/battleground-stamina-assistance.md)
- Operations: [`../development/operations.md`](../development/operations.md)
- Commit or PR: Not created

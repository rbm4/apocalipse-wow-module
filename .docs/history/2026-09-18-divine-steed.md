# 2026-09-18: Divine Steed

Status: Partial

## Intent

Add an in-combat paladin horse sprint without invoking the core's mounted or vehicle mechanics.

## Scope

### Code and data

- `src/mod_apocalipse_paladin_divine_steed.cpp`: Added faction-specific fake mount display lifecycle, normal run-speed aura validation, and logout/map cleanup.
- `src/mod_apocalipse_loader.cpp`: Registered the Divine Steed subsystem.
- `data/sql/db-world/2026_09_18_04_divine_steed.sql`: Added guarded spell 901017, script binding, non-save attribute, and backend name.

### Documentation

- `.docs/custom-spells/divine-steed.md`: Added the current owner contract and verification matrix.
- Architecture, playerbot, operations, indexes, root README, and repository rules now include Divine Steed and spell 901017.

## Contracts changed

- Hooks or registration: One AuraScript plus player before-logout and map-change hooks were added.
- Human behavior: Paladins can use a four-second 100 percent sprint on a 20-second cooldown while appearing on a faction-specific charger.
- Bot behavior: Identical mechanics; acquisition and rotation remain external.
- Configuration: None.
- Database or migration: Automatic guarded world update for 901017.
- Custom spell/client data: Matching client `Spell.dbc` row 901017 is required.
- Deployment or rollback: World updater, module build, and matching client patch must be deployed atomically.

## Decisions

- The display is cosmetic only. The implementation never calls `Unit::Mount`, sets `UNIT_FLAG_MOUNT`, applies `SPELL_AURA_MOUNTED`, or creates a vehicle.
- Alliance players use verified Charger display 14565 from spell 23214; Horde players use verified Thalassian Charger display 20030 from spell 34767, regardless of character race.
- The aura is non-dispellable and uses ordinary run-speed aura type 31.
- Removal does not clear a display after a real mount has replaced it.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Repository collision search | Search for 901017 across the workspace | Passed; no spell allocation found |
| Checked-in base DBC collision | Parse backend `data/Spell.dbc` | Passed; 901017 absent |
| Mount reference data | Parse spells 23214 and 34767 from backend `data/Spell.dbc` | Passed; display values 14565 and 20030 confirmed |
| Static diff checks | `git diff --check`, forbidden-dash scan, trailing-whitespace scan, API searches, ID synchronization search, and 80-column C++ scan | Passed; only existing LF-to-CRLF warnings were emitted |
| Parent worldserver build | Custom core build with module and playerbots | Not run; core repository rules require explicit build request |
| Database updater and startup | Development world database and worldserver logs | Not run |
| Client export and MPQ | Backend release workflow | Not run |
| In-game human and playerbot scenarios | Owner-page verification matrix | Not run |

## Follow-up

- Collision-check 901017 in live world tables and the selected deployment client.
- Export and deploy the matching client row.
- Run all owner-page scenarios, especially faction display choice, real mount replacement, map/logout cleanup, and rider attachment for every enabled paladin race and sex.

## References

- Custom spell: [`../custom-spells/divine-steed.md`](../custom-spells/divine-steed.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

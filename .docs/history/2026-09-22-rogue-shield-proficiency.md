# 2026-09-22: Rogue shield proficiency

Status: Partial

## Intent

Make Shield a baseline rogue skill through the same server-owned default-skill path used by stock shield classes, without a custom spell or late login reconciliation hook.

## Scope

### Code and data

- `data/sql/db-world/2026_09_22_02_rogue_shield_proficiency.sql`: adds guarded rogue Shield eligibility and a separate rogue default-skill row.

### Documentation

- Added the dedicated feature page and updated architecture, runtime flow, operations, playerbot behavior, feature and history indexes, and root README.

## Contracts changed

- Hooks or registration: None.
- Human behavior: Rogues become eligible for Shield skill 433 during default-skill loading before inventory validation.
- Bot behavior: Identical server acquisition for bot-controlled rogues; gear-selection policy is unchanged.
- Configuration: None.
- Database or migration: Adds `skillraceclassinfo_dbc` ID 10000 and rogue `playercreateinfo_skills` skill 433 through the automatic world updater.
- Custom spell/client data: No new spell ID or `Spell.dbc` row; client `SkillRaceClassInfo.dbc` remains unchanged.
- Deployment or rollback: Requires updater execution and worldserver restart; rollback must account for persisted skills and equipped shields.

## Decisions

- Preserved stock Shield records and added separately owned rogue rows.
- Copied the checked-in stock Shield eligibility fields: race mask 2047, flags 128, minimum level 0, and zero tier and cost fields.
- Reserved row ID 10000 after confirming the checked-in DBC maximum ID is 970 and ID 10000 is absent.
- Used default-skill loading instead of `OnPlayerLogin` because inventory validation occurs before that hook.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Checked-in DBC inspection | Parsed `SkillRaceClassInfo.dbc` read-only | Stock Shield row 246 confirmed; ID 10000 absent |
| Core source review | Traced DBC merge, default skill loading, skill rewards, and inventory load order | Passed |
| Migration static review | Reviewed ownership checks and collision guards | Passed |
| Skill reward class-mask inspection | Locate deployed `SkillLineAbility.dbc` rows for skill 433 | Not run; file unavailable in checked-in sources |
| World updater and startup | Apply migration and restart worldserver | Not run; operator deployment required |
| Human and bot runtime scenarios | Feature-page verification matrix | Not run; runtime environment unavailable |

## Follow-up

- Confirm deployed stock skill reward rows grant Shield Proficiency 9116 and Block 107 to rogues.
- Test existing and new human rogues, relog with a shield equipped, block resolution, and bot-controlled rogues.
- Address client UI, LFG eligibility, or playerbot gear policy only if runtime testing identifies a need.

## References

- Feature: [`../features/rogue-shield-proficiency.md`](../features/rogue-shield-proficiency.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

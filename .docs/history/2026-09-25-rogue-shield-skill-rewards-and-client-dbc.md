# 2026-09-25: Rogue shield skill rewards and client DBC

Status: Partial

## Intent

Complete rogue Shield acquisition after runtime testing showed that skill 433 alone did not teach Shield Proficiency or Block, and keep the client DBCs synchronized through the normal MPQ release pipeline.

## Scope

### Code and data

- `data/sql/db-world/2026_09_25_00_rogue_shield_skill_rewards.sql`: adds guarded rogue-only `SkillLineAbility` mappings for Block 107 and Shield Proficiency 9116.
- Backend `SkillRaceClassInfoCompiler` and release-builder integration: merges `skillraceclassinfo_dbc` into the checked-in compatibility DBC and includes the generated file in the MPQ.
- Backend `client_patch_overlay/DBFilesClient/SkillRaceClassInfo.dbc`: adds rogue Shield eligibility row 10000 while preserving the existing all-race/all-class data.

### Documentation

- Updated the feature contract, runtime flow, operations inventory, playerbot integration, history index, and root summary.

## Contracts changed

- Hooks or registration: None.
- Human behavior: Granting Shield skill 433 to a rogue now has explicit reward mappings for stock spells 9116 and 107.
- Bot behavior: Identical reward acquisition for bot-controlled rogues; equipment choice is unchanged.
- Configuration: Optional `ACORE_SKILLRACECLASSINFO_DBC_PATH`; the checked-in overlay is the default base.
- Database or migration: Adds `skilllineability_dbc` IDs 10001 and 10002 through the automatic world updater.
- Custom spell/client data: Client releases compile both `SkillRaceClassInfo.dbc` and `SkillLineAbility.dbc` from world overrides.
- Deployment or rollback: Requires the world updater, worldserver restart, and a newly built/published client MPQ. This change does not perform those operations.

## Decisions

- Added separate rogue-only reward rows instead of widening the stock class-mask-67 rows.
- Used exact-row collision guards so reruns are no-ops and unrelated ownership fails loudly.
- Used the existing static compatibility DBC as the compiler base to preserve its prior race/class combinations.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| SkillRaceClassInfo compiler tests | `python -m unittest discover -s tests -p test_skillraceclassinfo_compiler.py` | Passed, 3 tests |
| SkillLineAbility regression tests | `python -m unittest discover -s tests -p test_skilllineability_compiler.py` | Passed, 5 tests |
| Python syntax | `python -m py_compile` for the changed backend modules | Passed |
| Static DBC inspection | Parsed the modified overlay | 242 rows; stock row 246 retained and rogue row 10000 present |
| World updater and restart | Apply new migration and restart worldserver | Not run; operator deployment required |
| Client MPQ build and in-game verification | Build/publish/install, then create and inspect a rogue | Not run; operator deployment required |

## Follow-up

- Verify new and existing rogues learn skill 433, spell 9116, and spell 107 after deployment.
- Verify the existing rogue from the incomplete deployment window receives both rewards through `_LoadSkills()` reconciliation on its first login after restart.
- Validate the installed MPQ and the client skill/equipment UI.

## References

- Feature: [`../features/rogue-shield-proficiency.md`](../features/rogue-shield-proficiency.md)
- Architecture: [`../architecture/runtime-and-data-flow.md`](../architecture/runtime-and-data-flow.md)
- Commit or PR: Not created

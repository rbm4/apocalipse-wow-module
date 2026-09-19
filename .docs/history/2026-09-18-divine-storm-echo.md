# 2026-09-18: Divine Storm Echo

Status: Partial

## Intent

Add a passive-gated Divine Storm echo that executes one second after the original attack at half of its normal weapon damage while preserving normal target selection, procs, and proportional healing.

## Scope

### Code and data

- `src/mod_apocalipse_paladin_divine_storm_echo.cpp`: Added delayed GUID-safe echo scheduling from Divine Storm 53385.
- `src/mod_apocalipse_loader.cpp`: Registered the paladin echo subsystem.
- `data/sql/db-world/2026_09_18_02_divine_storm_echo.sql`: Added guarded passive 901014, echo 901015, script bindings, and backend names.

### Documentation

- `.docs/custom-spells/divine-storm-echo.md`: Added the current gameplay, data, acquisition, proc, and rollback contract.
- Architecture, subsystem, playerbot, operations, feature, history, and root indexes were updated for the new system and spell range.

## Contracts changed

- Hooks or registration: Added an `AfterCast` script bound only to 53385 and registered `AddModApocalipsePaladinDivineStormEchoScripts()`.
- Human behavior: Passive 901014 schedules one triggered 901015 attack after one second while the caster remains alive, in world, and affected by the passive.
- Bot behavior: Identical automatic behavior with no AI change.
- Configuration: None.
- Database or migration: Added an idempotent guarded automatic world update for 901014 and 901015.
- Custom spell/client data: Added a permanent passive and a normalized 55 percent weapon-damage Divine Storm derivative. Matching client rows remain required.
- Deployment or rollback: Requires updater execution, module rebuild, worldserver restart, client export, and external passive acquisition data.

## Decisions

- Allocated repository-free IDs 901014 and 901015 with collision guards because live and selected client data were unavailable.
- Used 55 percent weapon damage because the original 109 DBC base points evaluate to 110 percent, making 54 base points exactly half.
- Used a zero-damage normalized weapon effect 0 marker plus the 55 percent weapon effect 2 because the deployment core normalizes the original only through a 53385 spell-ID special case.
- Removed the echo's equipped-item requirement because this deployment core does not honor the corresponding triggered-cast bypass flag.
- Retained normal triggered proc eligibility and blocked recursion by binding the scheduler only to 53385.
- Reused core `spell_pal_divine_storm` on 901015 so healing follows final echo damage.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Base spell data | Parsed checked-in runtime-grade `Spell.dbc` row 53385 against the core `spell_dbc` schema and traced `Spell::EffectWeaponDmg` | Passed |
| Checked-in client ID collision | Parsed backend `data/Spell.dbc` and `data/SpellExtracted.dbc` for 901014 and 901015 | Passed, neither ID exists |
| Repository ID collision | Search for 901014 and 901015 across the workspace | Passed, no pre-existing spell allocation found |
| Source and SQL review | Focused diff, exact identifier search, and independent read-only review | Passed |
| Custom-core build | Parent worldserver build | Not run yet |
| Database updater and startup | Disposable development database and worldserver logs | Not run |
| Client export | Backend Spell.dbc export with custom rows | Not run |
| Human and playerbot scenarios | Matrix in the owner page | Not run |

## Follow-up

- Collision-check 901014 and 901015 against live `spell_dbc`, `wotlk_spells_full`, `wotlk_spells`, and the selected client DBC.
- Validate the separately owned talent or acquisition workflow references unranked passive 901014 only; no checked-in reference exists in the four workspace repositories.
- Export and deploy matching client Spell.dbc rows.
- Run the documented human and playerbot scenarios.

## References

- Custom spell: [`../custom-spells/divine-storm-echo.md`](../custom-spells/divine-storm-echo.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

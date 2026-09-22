# 2026-09-22: Warlock and Divine Toll balance

Status: Partial

## Intent

Adjust three existing custom spells after gameplay review: trigger Haunting Affliction on every Haunt, reduce Demonic Equilibrium's Soul Link transfer, and make Divine Toll deterministic with less per-impact damage reduction.

## Scope

### Code and data

- `src/mod_apocalipse_warlock_haunting_affliction.cpp`: Removed the 901029 internal-cooldown check and cast so every successful Haunt can apply eligible DoTs.
- `src/mod_apocalipse_warlock_demonic_equilibrium.cpp`: Reduced the Soul Link split override from 75 percent to 50 percent.
- `src/mod_apocalipse_paladin_divine_toll.cpp`: Replaced the random impact count with exactly five impacts and increased marked damage from 50 percent to 80 percent.
- `data/sql/db-world/2026_09_22_00_spell_balance_adjustments.sql`: Added guarded description updates for spells 901028, 901033, and 901024.

### Documentation

- Updated the three custom-spell owner pages, architecture and runtime flow, subsystem catalog, operations, playerbot behavior, root README, and history index.

## Contracts changed

- Hooks or registration: Existing bindings and registrations are unchanged.
- Human behavior: Haunting Affliction has no internal cooldown, Demonic Equilibrium transfers 50 percent, and Divine Toll schedules exactly five impacts at 80 percent damage.
- Bot behavior: Identical to human behavior; no playerbot AI changes are required.
- Configuration: None.
- Database or migration: One guarded automatic world update changes the three acquisition-facing descriptions.
- Custom spell/client data: Client spell 901028, 901033, and 901024 descriptions must be regenerated after the update. Legacy marker 901029 remains installed but unused.
- Deployment or rollback: Requires the automatic update, rebuilt module, and refreshed client patch. Rollback restores the prior source constants and cooldown path plus prior descriptions.

## Decisions

- Kept marker 901029 as legacy data instead of deleting an installed custom-spell row; current code has no reference to it.
- Interpreted 20 percent reduced Divine Toll damage as 80 percent of normal hit damage.
- Preserved `CastCommandCleave` after each successful Divine Toll Judgement. This explicitly casts Seal of Command cleave 20424 when Seal of Command and Judgements of the Just are active, and the existing damage binding applies the same 80 percent multiplier.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Focused source trace | Trace Haunt `AfterHit`, Soul Link `OnEffectSplit`, Divine Toll scheduling, damage binding, and `CastCommandCleave` | Passed by static review |
| SQL ownership review | Compare guard fields with the three baseline migrations | Passed by static review |
| Parent custom-core build | Build `worldserver` with this module and playerbots enabled | Not run |
| World updater and client export | Apply the automatic migration and regenerate the client patch | Not run |
| Human and bot runtime | Test consecutive Haunts, Soul Link transfer, five Divine Toll impacts, and Seal of Command cleaves | Not run |

## Follow-up

- Build against the deployment custom core, run the automatic updater, regenerate the client patch, and execute the documented human and playerbot scenarios.

## References

- Custom spells: [`../custom-spells/haunting-affliction.md`](../custom-spells/haunting-affliction.md), [`../custom-spells/demonic-equilibrium.md`](../custom-spells/demonic-equilibrium.md), [`../custom-spells/divine-toll.md`](../custom-spells/divine-toll.md)
- Architecture: [`../architecture/runtime-and-data-flow.md`](../architecture/runtime-and-data-flow.md)
- Commit or PR: Not created

# 2026-09-18: Permanent Seal of Righteousness

Status: Partial

## Intent

Add stock Seal of Righteousness proc behavior as a permanent pseudo-seal that can coexist safely with a paladin's selected real seal.

## Scope

### Code and data

- `src/mod_apocalipse_paladin_permanent_seal_of_righteousness.cpp`: added bounded AuraScript filtering, stock damage calculation, real-SoR suppression, recursion protection, and Judgements of the Just behavior.
- `src/mod_apocalipse_loader.cpp`: registered the new paladin subsystem.
- `data/sql/db-world/2026_09_18_03_permanent_seal_of_righteousness.sql`: defined passive 901016, proc metadata, script binding, collision guards, and backend name cache.

### Documentation

- `.docs/custom-spells/permanent-seal-of-righteousness.md`: recorded the complete mechanic, spell graph, acquisition boundary, data contract, and runtime matrix.
- Architecture, subsystem, operations, playerbot, feature index, root README, and history index pages were updated for the new contract.

## Contracts changed

- Hooks or registration: Added `AddModApocalipsePaladinPermanentSealOfRighteousnessScripts()` after Divine Storm Echo.
- Human behavior: Passive 901016 adds stock SoR damage beside another selected seal and suppresses itself beside real SoR.
- Bot behavior: Identical to humans with no AI-specific code.
- Configuration: None.
- Database or migration: Added one guarded automatic world update for `spell_dbc`, `spell_proc`, `spell_script_names`, and `wotlk_spells`.
- Custom spell/client data: Reserved repository ID 901016; matching client `Spell.dbc` data remains required.
- Deployment or rollback: Requires normal module updater, rebuild, client patch, external acquisition data, and focused in-game validation.

## Decisions

- Used a non-seal dummy passive rather than forcing two real seals to coexist.
- Preserved stock melee eligibility and Judgements of the Just double-proc behavior.
- Kept the passive visible and acquisition outside this module.
- Reused damage spell 25742 and the stock AP, Holy power, libram, and weapon-speed formula.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Source and SQL review | Compare with deployment core `spell_pal_seal_of_righteousness`, proc enums, and current module migrations | Passed |
| Repository spell-ID search | Search module, core, backend, and checked-in client sources for 901016 | Passed for module allocation; live database and selected deployed client remain pending |
| Custom-core build | Parent `worldserver` build with module and playerbots | Not run because custom-core rules require explicit build request |
| World updater and startup | Disposable development database and worldserver startup | Not run |
| Client export | Backend Spell.dbc patch workflow | Not run |
| Human and bot combat scenarios | Feature runtime matrix | Not run |

## Follow-up

- Collision-check 901016 against live `spell_dbc`, `wotlk_spells_full`, `wotlk_spells`, and the selected deployed client.
- Build the exact custom core, inspect startup validation, export matching client data, and run the documented human and bot scenarios.
- Integrate passive acquisition through its separately owned system.

## References

- Custom spell: [`../custom-spells/permanent-seal-of-righteousness.md`](../custom-spells/permanent-seal-of-righteousness.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

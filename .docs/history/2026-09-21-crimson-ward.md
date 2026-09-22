# 2026-09-21: Crimson Ward

Status: Partial

## Intent

Add a Blood Death Knight passive that converts positive incoming combat damage into a short maximum-health absorb on one shared one-minute internal cooldown.

## Scope

### Code and data

- `src/mod_apocalipse_death_knight_crimson_ward.cpp`: Added incoming-damage filtering, helper application, maximum-health absorb calculation, and script registration.
- `src/mod_apocalipse_loader.cpp`: Registered `AddModApocalipseDeathKnightCrimsonWardScripts()` while preserving unrelated local Rupture registration.
- `data/sql/db-world/2026_09_21_04_crimson_ward.sql`: Added guarded spells 901050 and 901051, shared proc cooldown metadata, both bindings, non-save helper metadata, Blood Spec Manager acquisition, and backend names.

### Documentation

- `.docs/custom-spells/crimson-ward.md`: Added mechanics, eligibility, absorb, cooldown, deployment, rollback, and verification contracts.
- Architecture, operations, subsystem, playerbot, feature, history, root, and ownership indexes now include Crimson Ward.

## Contracts changed

- Hooks or registration: Added passive and helper AuraScripts through `AddModApocalipseDeathKnightCrimsonWardScripts()`.
- Human behavior: Positive incoming combat damage grants a 15-second absorb equal to 20 percent of maximum health on one 60-second cooldown.
- Bot behavior: Identical when the bot has acquired passive 901050; no active action is required.
- Configuration: None.
- Database or migration: Added one automatic guarded world update with one passive proc row, a non-save helper attribute, and Blood Spec Manager acquisition.
- Custom spell/client data: Added server spells 901050 and 901051. Matching client rows remain required.
- Deployment or rollback: Requires normal module rebuild, updater execution, and matching client export; no SQL was executed during implementation.

## Decisions

- Used a separate helper aura so the permanent proc passive and timed absorb have independent data contracts.
- Used the passive aura's `spell_proc` cooldown so all qualifying incoming-damage sources share one 60000 ms cooldown.
- Snapshotted 20 percent of current maximum health when the helper is applied rather than dynamically resizing an active shield.
- Used no dispel type and all-school mask 127 for a non-dispellable general absorb.
- Allocated 901050 and 901051 because unrelated uncommitted Rupture work already reserves 901048 and 901049.
- Added passive 901050 to Blood specialization index 0 so Spec Manager owns grant and revoke behavior; helper 901051 remains internal.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Core proc and absorb paths | Reviewed incoming-damage proc handling, aura-owned cooldowns, and school absorb calculation in the deployment core | Passed by static review |
| ID inventory | Repository search for 901050 and 901051, accounting for local 901048 and 901049 reservations | No conflicting checked-in allocation found before implementation; live data not checked |
| SQL contract | Static review of collision guards, spell signatures, proc row, bindings, non-save attribute, Blood acquisition, names, and descriptions | Passed by independent static review |
| Patch whitespace | `git diff --check` and forbidden-dash scan of Crimson Ward files | Passed; existing line-ending conversion warnings remain |
| Custom-core build | Build worldserver with this module and mod-playerbots | Not run because the custom-core repository requires explicit build approval |
| SQL execution | Apply updater to a disposable world database | Not run by repository policy |
| Client export | Export and inspect matching client `Spell.dbc` rows | Not run |
| Human and bot scenarios | Execute the owner-page verification matrix | Not run because no runtime worldserver session was available |

## Follow-up

- Collision-check 901050 and 901051 in live world tables and deployed client data.
- Deploy matching client data for both spells and confirm Spec Manager grants 901050 only to the dominant Blood specialization.
- Run worldserver startup validation and the documented human and bot scenarios.

## References

- Custom spell: [`../custom-spells/crimson-ward.md`](../custom-spells/crimson-ward.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

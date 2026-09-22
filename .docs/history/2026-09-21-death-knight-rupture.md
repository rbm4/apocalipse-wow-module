# 2026-09-21: Death Knight Rupture

Status: Partial

## Intent

Add a Blood Death Knight passive that turns melee and selected Blood strike hits into a small stacking physical bleed intended to become a leading damage source during sustained combat.

## Scope

### Code and data

- `src/mod_apocalipse_death_knight_rupture.cpp`: filters normal and critical melee auto hits plus Blood Strike, Heart Strike, and Death Strike rank hits and applies a stack per event target.
- `data/sql/db-world/2026_09_21_04_death_knight_rupture.sql`: adds guarded passive 901048 and 200-stack periodic bleed helper 901049, acquisition, proc and script metadata, AP coefficient, scaling, non-save metadata, and backend names.
- `data/mod_spell_scaling.sql`: seeds helper 901049 as `PERIODIC` with factor 1.0.
- `src/mod_apocalipse_loader.cpp`: registers the new script subsystem.

### Documentation

- `.docs/custom-spells/death-knight-rupture.md`: records mechanics, formula, interactions, deployment, rollback, and runtime matrix.
- Architecture, operations, playerbot, feature, subsystem, history, root, and ownership indexes now reference Rupture and the expanded custom spell graph.

## Contracts changed

- Hooks or registration: adds one passive AuraScript proc subsystem after the Hunter systems.
- Human behavior: Blood Spec Manager acquisition makes successful qualifying hits build a refreshed 15-second bleed up to 200 stacks.
- Bot behavior: identical automatic mechanics with no new playerbot action.
- Configuration: None.
- Database or migration: adds automatic guarded world update `2026_09_21_04_death_knight_rupture.sql` and one baseline scaling row.
- Custom spell/client data: allocates 901048 and 901049 and requires matching client rows.
- Deployment or rollback: server update, module binary, client patch, and Spec Manager acquisition must remain synchronized.

## Decisions

- Use one stack for both normal and critical qualifying hits so critical strikes are included without doubling the accumulation rate.
- Use native 200-stack aura behavior and a refreshed 15-second duration so uninterrupted long encounters can reach the cap while target swaps and disengagement reset the ramp.
- Use physical school, bleed mechanic 15, Death Knight family 15, and no family bit so broad Blood, physical, and bleed modifiers apply without inheriting strike-specific modifiers.
- Use `ap_dot_bonus = 0.005`, producing 1 plus 0.5 percent melee attack power per stack per two-second tick before modifiers.
- Grant only passive 901048 through Blood Spec Manager; helper 901049 is trigger-only.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Offline allocation review | Reviewed module world-update ledger and concurrent reserved range | Passed: 901048-901049 are assigned to Rupture and guarded before later 901050+ graphs |
| Core behavior review | Reviewed proc flags, rank-chain APIs, stack recalculation, periodic bonus, bleed armor bypass, and target damage modifiers | Passed by source inspection |
| Local DBC inspection | Read local `Spell.dbc` metadata for the three selected first-rank strike IDs | Passed: all use Death Knight family 15 |
| SQL contract | Static review of collision guards, spell signatures, proc row, coefficient, scaling, acquisition, and backend names | Passed by source inspection |
| Build | Parent custom-core worldserver build | Not run: core repository instructions require an explicit build request |
| SQL application | Automatic updater against a database clone | Not run per offline-only policy |
| Runtime scenarios | Human and playerbot matrix in the owner page | Not run |
| Client patch | Export and inspect matching 901048 and 901049 rows | Not run |

## Follow-up

- Complete the custom-core build, updater/client export checks, and documented in-game tuning matrix before production rollout.
- Confirm the 0.005 AP coefficient produces the intended long-encounter and arena damage share with representative Blood gear and PvP modifiers.

## References

- Feature: [`../custom-spells/death-knight-rupture.md`](../custom-spells/death-knight-rupture.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

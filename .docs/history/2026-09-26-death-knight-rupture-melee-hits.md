# 2026-09-26: Death Knight Rupture melee-hit expansion

Status: Partial

## Intent

Make Rupture add one bleed stack for every landed melee hit, including hits whose damage is fully absorbed, so the low-damage bleed ramps consistently and faster.

## Scope

### Code and data

- `src/mod_apocalipse_death_knight_rupture.cpp`: accepts absorbed results and all outgoing melee auto-attack and melee-class ability events instead of a three-strike whitelist.
- `data/sql/db-world/2026_09_21_04_death_knight_rupture.sql`: makes fresh installations use the outgoing-hit default mask and current descriptions.
- `data/sql/db-world/2026_09_26_00_death_knight_rupture_melee_hits.sql`: updates existing 901048 proc metadata and descriptions idempotently.

### Documentation

- `.docs/custom-spells/death-knight-rupture.md`: updates eligibility, runtime flow, deployment, rollback, and verification scenarios.
- Architecture, operations, playerbot, subsystem, history, and root indexes now describe the broader proc contract and follow-up migration.

## Contracts changed

- Hooks or registration: the existing 901048 AuraScript binding and loader registration remain unchanged; its proc filter now accepts every outgoing melee auto or melee-class hit.
- Human behavior: normal, critical, partial-absorb, and full-absorb melee hits each add one stack per event target. Misses, avoidance, full resists, immunes, ranged attacks, magic-class abilities, and periodic damage remain excluded.
- Bot behavior: identical broader automatic application with no AI action or acquisition change.
- Configuration: None.
- Database or migration: the 901048 `spell_proc.HitMask` changes from explicit normal-or-critical value 3 to default value 0, which the deployment core resolves to normal, critical, or absorb for outgoing procs.
- Custom spell/client data: 901048 descriptions change and require a refreshed client `Spell.dbc` export; IDs, effects, stack cap, timing, and 901049 damage data remain unchanged.
- Deployment or rollback: deploy the rebuilt module, automatic world update, and refreshed client patch together. Rollback restores the prior C++ whitelist, hit mask 3, and descriptions.

## Decisions

- Use the core's documented default outgoing hit mask instead of a custom numeric absorb mask so the database contract stays aligned with `SpellMgr::CanSpellTriggerProcOnEvent`.
- Preserve one stack per proc event and the existing 200-stack cap, 15-second refresh, two-second tick, and 0.01 AP coefficient.
- Keep unsuccessful melee outcomes excluded because they do not land on the target.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Deployment-core proc review | Inspect `DamageInfo` hit-mask construction and `SpellMgr::CanSpellTriggerProcOnEvent` defaults | Passed by source inspection; full absorbs expose `PROC_HIT_ABSORB`, and outgoing `HitMask = 0` accepts normal, critical, and absorb results |
| Static graph review | Cross-check 901048-901049 constants, base and follow-up SQL, binding, scaling, collision guards, acquisition, and documentation | Passed |
| Patch whitespace and documentation links | `git diff --check` plus scoped relative-link validation | Passed; only existing line-ending conversion warnings were emitted |
| Parent custom-core build | Build `worldserver` with this module and `mod-playerbots` | Not run because the deployment core instructions prohibit builds unless explicitly requested |
| Database updater and startup | Authorized operator runs the updater and reviews startup logs | Not run per offline-only repository policy |
| Client patch | Export and inspect updated 901048 description with unchanged 901049 row | Not run |
| Human and bot gameplay | Run the owner-page normal, critical, partial-absorb, full-absorb, multi-target, and rejected-outcome matrix | Not run |

## Follow-up

- Build and deploy through the operator workflow, regenerate the client patch, and run the documented human and playerbot combat matrix.

## References

- Custom spell: [`../custom-spells/death-knight-rupture.md`](../custom-spells/death-knight-rupture.md)
- Architecture: [`../architecture/runtime-and-data-flow.md`](../architecture/runtime-and-data-flow.md)
- Commit or PR: Not created

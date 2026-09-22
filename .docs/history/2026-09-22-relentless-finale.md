# 2026-09-22: Relentless Finale

Status: Partial

## Intent

Implement a Combat Rogue meta passive with a visible guaranteed combo-point retention window whose 12-second recharge begins only after activation.

## Scope

### Code and data

- `src/mod_apocalipse_rogue_relentless_finale.cpp`: Added ready lifecycle, qualifying finisher preparation, native combo-point bypass, healing, cancellation cleanup, and post-use recharge.
- `src/mod_apocalipse_loader.cpp`: Registered the new subsystem.
- `data/sql/db-world/2026_09_22_10_relentless_finale.sql`: Added guarded spells 901084 through 901088, script bindings, transient non-save metadata, and backend names.

### Documentation

- Added `.docs/custom-spells/relentless-finale.md` and updated architecture, subsystem, operation, playerbot, README, feature, and history indexes.

## Contracts changed

- Hooks or registration: Added one AuraScript, one PlayerScript cast-preparation hook, and global successful-cast and cancellation hooks.
- Human behavior: Every player-initiated five-point finisher heals 5 percent maximum health. An infinite ready buff additionally guarantees point retention, then returns 12 seconds after that retention.
- Bot behavior: Mechanics are identical; deliberate double-finisher planning remains playerbot AI policy.
- Configuration: None.
- Database or migration: Added one guarded automatic world update and no acquisition row.
- Custom spell/client data: Added 901084 through 901088; matching client rows remain required.

## Decisions

- The ready indicator has no duration and is not granted periodically.
- Recharge is hidden, begins after the qualifying cast succeeds, and is set to exactly 12000 ms at runtime.
- The strict-check hook duplicates the core's combo-target ownership test, requires exactly five points, and then applies a one-second family-wide aura-state bypass before the core evaluates overrides. This avoids changing one-through-four-point finisher behavior.
- Triggered and copied finishers are rejected through `Spell::IsTriggered()`.
- The heal uses native `SPELL_EFFECT_HEAL_PCT` for 5 percent maximum health.

## Verification

| Check | Result |
|---|---|
| Static diff and source/data consistency | Passed `git diff --check`, no-index checks for new files, script/API source review, graph consistency checks, and forbidden Unicode dash scan |
| Custom-core worldserver build | Not run because core rules require an explicit build request |
| Updater and startup | Not run |
| Client data | Not run |
| Human and playerbot gameplay | Not run |

## Follow-up

- Run live server and deployed-client collision checks for 901084 through 901088.
- Grant only passive 901084 through the external acquisition flow.
- Build, run updater/startup validation, export the client patch, and execute the owner-page gameplay matrix.

## References

- Custom spell: [`../custom-spells/relentless-finale.md`](../custom-spells/relentless-finale.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

# 2026-09-25: Death Knight Rupture AP scaling

Status: Partial

## Intent

Increase Rupture's sustained-damage contribution by doubling only its periodic melee attack-power coefficient while preserving its existing application, stacking, timing, school, bleed, scaling, and PvP profile.

## Scope

### Code and data

- `data/sql/db-world/2026_09_25_05_death_knight_rupture_ap_scaling.sql`: idempotently updates helper 901049's `spell_bonus_data.ap_dot_bonus` from its prior value to 0.01 when needed.

### Documentation

- `.docs/custom-spells/death-knight-rupture.md`: updates the current formula, deployment, rollback, ownership, and history contracts.
- `.docs/architecture/runtime-and-data-flow.md`, `.docs/subsystems/catalog.md`, `README.md`, `.docs/development/operations.md`, and `.docs/history/README.md`: update current coefficient references and index the migration.

## Contracts changed

- Hooks or registration: None.
- Human behavior: each Rupture stack now contributes 1 percent melee attack power per two-second tick before modifiers, up from 0.5 percent.
- Bot behavior: identical coefficient increase with no AI or acquisition change.
- Configuration: None.
- Database or migration: one ID-scoped automatic world update changes only `spell_bonus_data.ap_dot_bonus` for helper 901049.
- Custom spell/client data: no `Spell.dbc` field changes are required because the coefficient is server-side world data.
- Deployment or rollback: run the normal world updater; coefficient-only rollback restores 901049 to 0.005.

## Decisions

- Use exactly 0.01 to provide the requested approximately double modifier as a clear two-times increase from 0.005.
- Preserve one base damage per stack, 200-stack cap, 15-second refreshed duration, two-second period, seven scheduled ticks, physical school, bleed mechanic, PERIODIC level scaling, and existing native modifiers.
- Use an `UPDATE` against exact helper ID 901049 so rerunning is safe and a missing base bonus row is not fabricated.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Static SQL review | Inspect exact ID, assigned column, and rerun predicate | Passed |
| Formula review | Compare 0.005 and 0.01 native `ap_dot_bonus` paths | Passed; AP contribution is exactly doubled before other modifiers |
| Patch whitespace | Scoped `git diff --check` plus no-index review for new files | Passed; only existing line-ending conversion warnings were emitted |
| Database updater and startup | Authorized operator runs the world updater and reviews startup logs | Not run; operator-owned |
| Human and bot gameplay | Rupture verification matrix with representative Blood gear and PvP modifiers | Not run |

## Follow-up

- Authorized operator should measure sustained PvE and PvP damage share at representative AP and stack counts after applying the update.

## References

- Custom spell: [`../custom-spells/death-knight-rupture.md`](../custom-spells/death-knight-rupture.md)
- Architecture: [`../architecture/runtime-and-data-flow.md`](../architecture/runtime-and-data-flow.md)
- Commit or PR: Not created

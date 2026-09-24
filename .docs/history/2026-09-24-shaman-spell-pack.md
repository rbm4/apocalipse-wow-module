# 2026-09-24: Shaman spell pack

Status: Partial

## Intent

Implement the approved twenty-ability Shaman design as one guarded AzerothCore module spell graph without coupling it to the current Spec Manager acquisition system.

## Scope

### Code and data

- `src/mod_apocalipse_shaman_spells.cpp`: adds stock-rank propagation, a Flame Shock target registry, stackable pseudo-shields, healing and damage procs, active cooldown behavior, and totem-cast healing.
- `src/mod_apocalipse_loader.cpp`: registers the Shaman script collection.
- `data/sql/db-world/2026_09_24_00_shaman_spell_pack.sql`: reserves and defines spells 901091 through 901117, proc rows, script bindings, helper metadata, coefficient cleanup, and backend names.
- `AGENTS.md`: extends the atomic custom-spell graph invariant through 901117.

### Documentation

- `.docs/custom-spells/shaman-spell-pack.md`: records all twenty gameplay contracts and deployment requirements.
- `.docs/architecture/overview.md`: adds the runtime owner and loader position.
- `.docs/architecture/runtime-and-data-flow.md`: adds the server, script, scaling, and client-data graph.
- `.docs/development/operations.md`: adds the updater and extends collision-check ranges.
- `.docs/integrations/playerbots.md`: records identical mechanics and missing active cast policy.
- `README.md`: adds the public Shaman pack summary.

## Contracts changed

- Hooks or registration: additive rank-wide hooks now coexist with stock Flame Shock, Lava Burst, Riptide, and Chain Heal behavior; exact custom aura and player cast hooks are registered as one Shaman subsystem.
- Human behavior: adds the twenty approved Shaman abilities and their implementation helpers.
- Bot behavior: mechanics are identical; the three actives still need separate playerbot cast policy.
- Configuration: None.
- Database or migration: automatic guarded world update adds 27 server spell rows and related metadata. No acquisition rows are inserted.
- Custom spell/client data: matching client rows 901091 through 901117 are required and were not exported in this change.
- Deployment or rollback: deploy code, world update, backend names, and client rows atomically; rollback removes the acquisition externally, then script bindings, proc rows, helper metadata, backend names, and spell rows.

## Decisions

- Wildfire and Riptide spread at 20 percent to one bounded target.
- Ascension suppresses Triple Convergence and Echoing Magma fan-out.
- Echoing Magma never spreads Flame Shock.
- Shield payloads select the closest stock rank by required character level without requiring that stock rank to be learned.
- Spirit Link Conduit pivots to any Shaman totem cast because Spirit Link Totem does not exist in WotLK 3.3.5a.
- All player-facing acquisition is deferred to a separately owned future system.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Whitespace and patch sanity | `git diff --check` plus no-index checks for new files | Passed |
| Source and SQL static review | Exact ID, binding, proc, helper, acquisition exclusion, range, and recursion review | Passed |
| Custom-core build | Worldserver build with module and playerbots | Not run under repository policy |
| World migration and startup | Authorized updater execution | Not run |
| Client export | Export and inspect all 27 Spell.dbc rows | Not run |
| Human and bot gameplay | Scenarios in the owner page | Not run |

## Follow-up

- Run the custom-core build when explicitly requested.
- Perform authorized live collision checks, world update, startup review, and client export.
- Add all acquisition in the separately owned future system.
- Add playerbot decisions for active spells 901094, 901115, and 901116.
- Execute the human and bot verification matrix in `.docs/custom-spells/shaman-spell-pack.md`.

## References

- Current spell contract: [`../custom-spells/shaman-spell-pack.md`](../custom-spells/shaman-spell-pack.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

# 2026-09-18: Pyroclastic propagated damage

Status: Partial

## Intent

Reduce Living Bombs applied by Pyroclastic Chain Reaction spread to 30 percent of the equivalent manually applied bomb's damage without changing the source bomb.

## Scope

### Code and data

- `src/mod_apocalipse_mage_pyroclastic_chain_reaction.cpp`: Marks propagated Living Bomb auras, scales periodic and explosion damage, and cleans marker state after removal.
- `data/sql/db-world/2026_09_18_01_pyroclastic_chain_reaction_propagated_damage.sql`: Binds the Living Bomb rank chain to the propagated-aura script.

### Documentation

- `.docs/custom-spells/pyroclastic-chain-reaction.md`: Records the 30 percent damage and lifecycle contract.
- `.docs/architecture/runtime-and-data-flow.md`: Records the modifier's position relative to shared damage hooks.
- `.docs/development/operations.md`: Adds the automatic update and runtime check.
- `.docs/integrations/playerbots.md`: Records identical reduced propagated damage for bots.
- `README.md`: Updates the public gameplay summary.

## Contracts changed

- Hooks or registration: Added a Living Bomb AuraScript through the `-44457` binding and a damage hook to the existing explosion script.
- Human behavior: Propagated Living Bomb periodic ticks and all explosions originating from propagated auras deal 30 percent damage. Bombs initially applied manually remain unchanged; recasting onto an active propagated aura keeps that aura reduced.
- Bot behavior: Identical when a bot has passive 901003.
- Configuration: None.
- Database or migration: Added an idempotent automatic world update for the Living Bomb aura rank binding.
- Custom spell/client data: No spell row or client data changed.
- Deployment or rollback: Worldserver restart and updater execution are required. Rollback removes the exact `-44457` script binding after normal backup and shutdown procedures.

## Decisions

- Used passive 901003 trigger metadata instead of spell rank or caster type so only spread applications are reduced.
- Applied the periodic modifier after the aura's normal amount calculation and the explosion modifier before shared direct-damage hooks.
- Keyed propagated state by caster and carrier, protected cross-map access, cleared removal-pending state synchronously after expiration or dispel explosions, and retained a generation-aware fallback for failed explosion casts.
- Reapplied the modifier on aura refresh so manual recasts cannot restore propagated periodic ticks to full damage.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Patch whitespace | `git diff --check` | Passed; existing line-ending conversion warnings remain |
| Core API review | Inspected aura trigger metadata assignment, Living Bomb removal casting, and damage hook APIs in the matching custom core | Passed by static review |
| Source and migration review | Checked the 30 percent constant, all-rank bindings, caster/target key, reapplication path, and synchronous cleanup flow | Passed by static review |
| Custom-core build | Build `worldserver` with this module and `mod-playerbots` | Not run under the custom core instruction to skip builds unless explicitly requested |
| Database updater | Apply the new update to a non-production world database | Not run; no database mutation was authorized |
| Human and bot runtime | Compare normal and propagated ticks, expiration explosions, dispels, and proc-triggered explosions | Not run; no test worldserver session was available |

## Follow-up

- Build the exact deployment core when explicitly authorized.
- Apply the automatic update to a non-production world database and verify the `-44457` binding.
- Execute the updated human and bot runtime matrix.

## References

- Custom spell: [`../custom-spells/pyroclastic-chain-reaction.md`](../custom-spells/pyroclastic-chain-reaction.md)
- Architecture: [`../architecture/runtime-and-data-flow.md`](../architecture/runtime-and-data-flow.md)
- Commit or PR: Not created

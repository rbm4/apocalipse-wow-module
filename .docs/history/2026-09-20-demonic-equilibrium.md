# 2026-09-20: Demonic Equilibrium

Status: Partial

## Intent

Add a one-point Warlock passive that raises Soul Link's transferred damage from 20 percent to 75 percent without owning talent acquisition.

## Scope

### Code and data

- `src/mod_apocalipse_warlock_demonic_equilibrium.cpp`: Added a passive-gated Soul Link split hook.
- `src/mod_apocalipse_loader.cpp`: Registered the Warlock subsystem.
- `data/sql/db-world/2026_09_20_06_demonic_equilibrium.sql`: Added guarded passive 901033, the stock Soul Link aura binding, and backend spell name synchronization.

### Documentation

- `.docs/custom-spells/demonic-equilibrium.md`: Added the behavior, spell graph, damage ordering, deployment, and verification contract.
- Architecture, operations, subsystem, playerbot, loader, feature, history, and root indexes now include Demonic Equilibrium.

## Contracts changed

- Hooks or registration: Added an `OnEffectSplit` hook to Soul Link aura 25228 and `AddModApocalipseWarlockDemonicEquilibriumScripts()`.
- Human behavior: Passive 901033 raises eligible Soul Link damage transfer to 75 percent.
- Bot behavior: Identical when the bot has acquired passive 901033.
- Configuration: None.
- Database or migration: Added one automatic guarded world update for passive 901033 and the 25228 binding.
- Custom spell/client data: Added server spell 901033. Matching client `Spell.dbc` and separate talent acquisition data remain required.
- Deployment or rollback: Worldserver updater execution, rebuild, restart, and matching client and acquisition deployment are required. Rollback removes the exact binding and module-owned passive data together.

## Decisions

- Allocated the next free custom spell ID, 901033.
- Interpreted the requested Soul Link bonus as its documented transferred-damage percentage.
- Replaced the split amount dynamically per hit so passive acquisition or removal does not require recasting Soul Link.
- Preserved stock Soul Link behavior when the passive is absent.
- Left talent acquisition outside this module migration.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| ID inventory | Repository search for 901033 across module, core, backend, and playerbots | Passed before implementation; live and deployed client data not checked |
| Stock spell contract | Inspected deployed `Spell.dbc` records 19028 and 25228 and core split processing | Passed by static review |
| Patch whitespace | `git diff --check` | Passed; existing line-ending conversion warnings remain |
| Custom-core build | Build `worldserver` with this module and `mod-playerbots` | Not run because the custom core instructions require explicit build authorization |
| SQL execution | Apply updater to a disposable world database | Not run because database mutation was not authorized |
| Client export | Export and inspect matching client `Spell.dbc` and talent data | Not run |
| Human and bot scenarios | Execute the feature verification matrix | Not run because no runtime worldserver session was available |

## Follow-up

- Collision-check 901033 in the live world tables and deployed client data.
- Deploy talent acquisition and matching client data.
- Run worldserver startup validation and the documented human and bot scenarios.
- Confirm the 75 percent balance target under representative PvE and PvP damage.

## References

- Custom spell: [`../custom-spells/demonic-equilibrium.md`](../custom-spells/demonic-equilibrium.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

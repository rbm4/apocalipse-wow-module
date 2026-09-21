# 2026-09-20: Burning Conflagration

Status: Partial

## Intent

Add a Destruction Warlock passive that spreads the exact caster-owned Immolate rank from a successful Conflagrate target to a bounded group of nearby enemies.

## Scope

### Code and data

- `src/mod_apocalipse_warlock_burning_conflagration.cpp`: Added pre-consumption Immolate capture, projectile-safe post-hit targeting, and three-target triggered propagation.
- `src/mod_apocalipse_loader.cpp`: Registered the Warlock subsystem.
- `data/sql/db-world/2026_09_20_04_burning_conflagration.sql`: Added guarded passive 901027, the Conflagrate rank-chain binding, and backend spell name synchronization.

### Documentation

- `.docs/custom-spells/burning-conflagration.md`: Added the behavior, spell graph, targeting, interaction, deployment, and verification contract.
- Architecture, operations, subsystem, playerbot, loader, feature, history, and root indexes now include Burning Conflagration.

## Contracts changed

- Hooks or registration: Added an `OnEffectHitTarget` capture and `AfterHit` spread through binding `-17962`, plus `AddModApocalipseWarlockBurningConflagrationScripts()`.
- Human behavior: Passive 901027 spreads full matching-rank Immolate to up to three random eligible enemies within 10 yards.
- Bot behavior: Identical when the bot has acquired passive 901027.
- Configuration: None.
- Database or migration: Added one automatic guarded world update for passive 901027 and the Conflagrate rank-chain binding.
- Custom spell/client data: Added server spell 901027. Matching client `Spell.dbc` and separate talent acquisition data remain required.
- Deployment or rollback: Worldserver updater execution, rebuild, restart, and matching client and acquisition deployment are required. Rollback removes the exact binding and module-owned passive data together.

## Decisions

- Selected the name Burning Conflagration.
- Used the approved 10-yard radius and three additional target cap.
- Reused the real captured Immolate rank, including its initial hit and normal DoT behavior.
- Captured the rank before the core consumes Immolate and retained only its spell ID.
- Used `AfterHit` instead of `AfterCast` so the implementation remains correct if Conflagrate has projectile speed.
- Excluded only Immolate owned by the triggering caster, preserving independent Warlock ownership.
- Left talent acquisition outside this module migration.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| ID inventory | Repository search for 901027 across module, core, backend, and playerbots | Passed for repository data before implementation; live and deployed client data not checked |
| Core hook order | Reviewed `Spell::HandleEffects` and Conflagrate in `Spell::EffectSchoolDamage` | Passed by static review |
| Patch whitespace | `git diff --check` | Passed; existing line-ending conversion warnings remain |
| Custom-core build | Build `worldserver` with this module and `mod-playerbots` | Not run because the custom core instructions require explicit build authorization |
| SQL execution | Apply updater to a disposable world database | Not run because database mutation was not authorized |
| Client export | Export and inspect matching client `Spell.dbc` and talent data | Not run |
| Human and bot scenarios | Execute the feature verification matrix | Not run because no runtime worldserver session was available |

## Follow-up

- Collision-check 901027 in the live world tables and deployed client data.
- Deploy talent acquisition and matching client data.
- Run worldserver startup validation and the documented human and bot scenarios.
- Tune radius and target cap if runtime balance results require it.

## References

- Custom spell: [`../custom-spells/burning-conflagration.md`](../custom-spells/burning-conflagration.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

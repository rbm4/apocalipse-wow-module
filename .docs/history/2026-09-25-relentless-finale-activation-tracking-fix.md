# 2026-09-25: Relentless Finale activation tracking fix

Status: Partial

## Intent

Prevent triggered child spells from clearing a parent finisher's combo-retention state, and make Relentless Finale Ready consumption independent of post-effect aura presence.

## Scope

### Code and data

- `src/mod_apocalipse_rogue_relentless_finale.cpp`: rejects triggered child checks before bypass cleanup, snapshots the exact parent spell cast that received the retention bypass, preserves the bypass through non-strict rechecks, and consumes Ready from that activation snapshot after successful completion.
- Database and custom spell rows: None.

### Documentation

- The Relentless Finale owner page and runtime architecture now describe cast-scoped activation tracking and its relationship to stock Relentless Strikes preparation.

## Contracts changed

- Hooks or registration: Existing strict-check, cancellation, player cast, and successful-cast hooks remain registered. Their shared cast state now distinguishes any qualifying finisher from the finisher that activated retention.
- Human behavior: Every successfully completed five-point finisher that received bypass consumes Ready and starts recharge even if bypass aura presence changes during spell resolution.
- Bot behavior: Identical to human behavior.
- Configuration: None.
- Database or migration: None.
- Custom spell/client data: None.
- Deployment or rollback: Requires a module rebuild and worldserver restart. Rollback restores post-effect bypass-aura inspection.

## Decisions

- Follow stock Relentless Strikes' prepare-before-resolution model. Stock `Spell::PrepareTriggersExecutedOnHit()` snapshots eligible finisher trigger state while combo points still exist, then resolves it on the successful hit path.
- Return from triggered spell checks before transient cleanup. Damaging finishers can execute poison and proc children before the parent completion hook, while Slice and Dice normally has no equivalent child chain.
- Track retention separately from general five-point qualification so healing behavior remains unchanged.
- Preserve the prepared bypass during non-strict cast validation and clear both markers on cancellation.
- Keep the existing exact-five-point and combo-target checks instead of allowing the family-wide bypass aura to waive combo requirements for an unrelated target.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Stock comparison | Inspect Relentless Strikes handling in `Spell::PrepareTriggersExecutedOnHit()` and `Spell::CanExecuteTriggersOnHit()` | Passed |
| Core cast-order review | Inspect strict check, player cast, non-strict check, effect resolution, finish phase, and global successful-cast hook order | Passed |
| Source and documentation diff review | `git diff --check` and focused diff inspection | Passed |
| Parent custom-core build | Build `worldserver` with this module and `mod-playerbots` | Not run because the core repository rules require an explicit build request |
| Human and bot gameplay | Five-point Eviscerate, Envenom, Rupture, and Kidney Shot with poison and proc children, plus Slice and Dice, while Ready is active | Not run |

## Follow-up

- Build against the deployment core and execute the owner-page gameplay matrix for humans and bots.
- Confirm combat logs show exactly one heal, one Ready removal, and one recharge start for each activating finisher.

## References

- Custom spell: [`../custom-spells/relentless-finale.md`](../custom-spells/relentless-finale.md)
- Architecture: [`../architecture/runtime-and-data-flow.md`](../architecture/runtime-and-data-flow.md)
- Commit or PR: Not created

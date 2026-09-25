# 2026-09-25: Relentless Finale selected-target consumption fix

Status: Partial

## Intent

Ensure Relentless Finale Ready is consumed by all qualifying five-combo-point Rogue finishers, not only non-explicit-target finishers such as Slice and Dice.

## Scope

### Code and data

- `src/mod_apocalipse_rogue_relentless_finale.cpp`: recognizes explicit-target finishers when the client omits the original target GUID and the core resolves the cast from the Rogue's current selection.
- Database and custom spell rows: None.

### Documentation

- `README.md`, the Relentless Finale owner page, runtime data flow, operations matrix, and history index now describe the selected-target fallback and focused verification scenarios.

## Contracts changed

- Hooks or registration: None.
- Human behavior: A five-point explicit-target finisher aimed at the combo target now retains its points, consumes Ready, heals, and starts recharge when the target was resolved from current selection.
- Bot behavior: Identical to human behavior.
- Configuration: None.
- Database or migration: None.
- Custom spell/client data: None.
- Deployment or rollback: Requires a module rebuild and worldserver restart. Rollback restores the previous target qualification logic.

## Decisions

- Preserve original-target validation when the cast packet supplies a unit target.
- Use the current selection only when it matches the Rogue's combo target, mirroring the player fallback in `Spell::InitExplicitTargets()` without allowing a wrong-target finisher to consume Ready.
- Keep Slice and Dice on the existing non-explicit-target combo-point path.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Deployment-core target flow review | Inspect `Spell::InitExplicitTargets()`, `Spell::CheckCast()`, and `Unit::GetComboPoints()` | Passed |
| Source and documentation diff review | `git diff --check` and focused diff inspection | Passed |
| Parent custom-core build | Build `worldserver` with this module and `mod-playerbots` | Not run because the core repository rules require an explicit build request |
| Human and bot gameplay | Five-point Eviscerate, Envenom, Rupture, Kidney Shot, and Slice and Dice while Ready is active | Not run |

## Follow-up

- Build against the deployment core and run the focused owner-page gameplay matrix for humans and bots.
- Confirm the deployed client and server still contain the existing 901084 through 901088 spell graph.

## References

- Custom spell: [`../custom-spells/relentless-finale.md`](../custom-spells/relentless-finale.md)
- Architecture: [`../architecture/runtime-and-data-flow.md`](../architecture/runtime-and-data-flow.md)
- Commit or PR: Not created

# 2026-09-18: Prismatic Barrier Ice Barrier refresh

Status: Partial

## Intent

Allow Prismatic Barrier to refresh an active Ice Barrier without losing a stronger absorb amount to Ice Barrier's normal recast rejection.

## Scope

### Code and data

- `src/mod_apocalipse_mage_prismatic_barrier.cpp`: refreshes an existing ranked Ice Barrier aura and casts rank 8 only when no ranked aura is active.
- Database and client spell data are unchanged.

### Documentation

- `.docs/custom-spells/prismatic-barrier.md`: records duration refresh and absorb preservation behavior.
- `.docs/architecture/runtime-and-data-flow.md`: records the conditional Ice Barrier path.
- `.docs/history/README.md`: indexes this change.

## Contracts changed

- Hooks or registration: None.
- Human behavior: Prismatic Barrier refreshes an existing ranked Ice Barrier to maximum duration while preserving its current absorb amount.
- Bot behavior: Identical to human behavior.
- Configuration: None.
- Database or migration: None.
- Custom spell/client data: None.
- Deployment or rollback: Requires a module rebuild and worldserver restart. No SQL or client patch update is required.

## Decisions

- Kept normal Ice Barrier behavior unchanged instead of modifying its core `OnCheckCast` rule globally.
- Used `GetAuraOfRankedSpell()` so every Ice Barrier rank is recognized.
- Used `Aura::RefreshDuration()` so the existing absorb amount is preserved. Previously consumed absorb is intentionally not restored.
- The parent Prismatic Barrier cast still spends mana and starts its cooldown.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Source review | Inspect ranked aura lookup, refresh branch, and fallback cast | Passed |
| AzerothCore C++ codestyle | Run the parent core codestyle checker against module `src` | Passed |
| Repository whitespace review | `git diff --check` | Passed; line-ending conversion warnings remain informational |
| Parent custom-core build | Build `worldserver` with this module and `mod-playerbots` | Not run |
| Human and bot runtime | Cast with full, partially consumed, and stronger Ice Barrier instances | Not run |

## Follow-up

- Build against the deployment core and complete the focused runtime scenarios.

## References

- Custom spell: [`../custom-spells/prismatic-barrier.md`](../custom-spells/prismatic-barrier.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

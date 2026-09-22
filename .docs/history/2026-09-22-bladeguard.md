# 2026-09-22: Bladeguard

Status: Partial

## Intent

Implement the shield-dependent Bladeguard defensive passive for Combat Rogues without changing shield acquisition or block capability.

## Scope

### Code and data

- `data/sql/db-world/2026_09_22_04_bladeguard.sql`: adds guarded Bladeguard passive 901073, Energy helper 901074, block-only proc metadata, and backend names.
- No C++ or loader registration was added because the custom core natively owns item-dependent passive lifecycle, item-armor percentage, block chance, proc cooldown, and Energy restoration.

### Documentation

- Added the Bladeguard custom-spell page and updated architecture, runtime flow, operations, playerbot behavior, feature and subsystem indexes, history, and root README.

## Contracts changed

- Hooks or registration: None; native aura and proc handling is used.
- Human behavior: A learned Bladeguard passive activates only with a usable shield, increases item armor by 130 percent, adds 15 percentage points of block chance, and restores 5 Energy on blocks once per second.
- Bot behavior: Identical mechanics; acquisition and shield selection remain external.
- Configuration: None.
- Database or migration: Adds guarded world spell rows 901073 and 901074 plus `spell_proc` and backend name rows.
- Custom spell/client data: Requires matching client spell records for 901073 and 901074.
- Deployment or rollback: Requires updater execution, matching client data, and worldserver restart. External acquisition must be revoked before destructive rollback.

## Decisions

- Reserved guarded IDs 901073 and 901074 after the earlier pending Rogue graphs through 901072 to avoid colliding with concurrent user work.
- Used `SPELL_AURA_MOD_BASE_RESISTANCE_PCT` so the 130 percent multiplier applies to item armor before Agility and flat bonuses.
- Used the spell equipment requirement rather than a polling or equipment hook so activation and removal follow the core-owned passive lifecycle.
- Kept acquisition and rogue Shield/Block capability outside Bladeguard.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Custom-core source trace | Reviewed item-dependent aura lifecycle, armor calculation, block chance, block hit mask, and proc equipment checks | Passed |
| Migration static review | Reviewed spell ownership guards, shield masks, effect values, proc flags, hit mask, and cooldown | Passed |
| Parent custom-core build | Build worldserver with module and playerbots | Not run per core repository build policy |
| World updater and startup | Apply migration and restart worldserver | Not run; operator deployment required |
| Deployed client spell data | Install and inspect matching client rows | Not run; operator deployment required |
| Human and bot runtime matrix | Equip, unequip, armor, block chance, block Energy, and cooldown scenarios | Not run; runtime environment unavailable |

## Follow-up

- Add Bladeguard acquisition through the separately owned progression path.
- Validate both spell IDs against the live world database and deployed client patch before rollout.
- Run the documented human and bot runtime scenarios.

## References

- Custom spell: [`../custom-spells/bladeguard.md`](../custom-spells/bladeguard.md)
- Shield proficiency: [`../features/rogue-shield-proficiency.md`](../features/rogue-shield-proficiency.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

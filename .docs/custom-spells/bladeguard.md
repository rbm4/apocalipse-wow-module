# Bladeguard

Status: Implemented in data, database, client, build, and runtime not verified

Owners: `data/sql/db-world/2026_09_22_04_bladeguard.sql`

Last validated: 2026-09-22 by static review against local module and custom core sources

## Summary

Bladeguard is a shield-dependent Rogue defensive passive. While its learned passive is active with a usable shield equipped, it increases armor from equipped items by 130 percent, adds 15 percentage points of block chance, and restores 5 Energy after a successful block at most once per second.

## Scope

- Passive spell 901073 owns the shield requirement, armor modifier, block modifier, and proc trigger.
- Helper spell 901074 performs the fixed 5 Energy restoration.
- Acquisition is intentionally external to this migration.
- Shield skill, shield proficiency, and Block capability remain owned by the default-skill path documented in [`../features/rogue-shield-proficiency.md`](../features/rogue-shield-proficiency.md).

## Mechanical contract

| Mechanic | Contract |
|---|---|
| Equipment gate | Item class Armor, shield subclass mask 64, shield inventory mask 16384 |
| Armor | `SPELL_AURA_MOD_BASE_RESISTANCE_PCT`, Physical mask 1, amount 130 |
| Block | `SPELL_AURA_MOD_BLOCK_PERCENT`, amount 15 |
| Proc events | Taken melee auto attacks and taken melee/ranged damage-class spells that resolve as a block |
| Proc result | Trigger 901074 on self for 5 Energy |
| Internal cooldown | Core-owned 1000 ms cooldown on passive 901073 |

The armor aura modifies `BASE_PCT` before Agility and flat armor additions in `Player::UpdateArmor()`. It therefore increases armor sourced from equipped items, not total final armor.

## Equipment lifecycle

The implementation uses the core's item-dependent passive contract instead of a module hook:

```text
learned passive 901073 plus usable shield
  -> ApplyItemDependentAuras applies Bladeguard
  -> armor, block chance, and block proc become active

shield unequipped, swapped away, or unusable
  -> RemoveItemDependentAurasAndCasts removes Bladeguard immediately
  -> all three bonuses stop together
```

A broken or unusable shield also fails the native proc equipment check. The spell does not teach Shield, grant proficiency, or enable the ability to block.

## Human and bot behavior

Humans and bot-controlled Rogues use identical aura, equipment, block-resolution, and cooldown paths. Bladeguard does not call `WorldSession::IsBot()` and adds no playerbot strategy or gear-selection policy. Bot acquisition and choosing to equip a shield remain external.

## Data and deployment

The automatic world update `2026_09_22_04_bladeguard.sql` installs guarded rows for spells 901073 and 901074, exact proc metadata, and backend display names. Both IDs require matching deployed client spell data before the passive is exposed to clients.

The migration deliberately does not add `mod_spec_spells` or another acquisition row. Rollback must remove the proc and spell rows only after external grants are revoked. Live database collision checks, updater execution, worldserver startup, and deployed-client validation remain operator work.

## Invariants

1. Spell 901073 must remain passive and shield-dependent so equipment changes control all bonuses atomically.
2. The armor effect must remain base Physical resistance percentage, not total resistance percentage.
3. The block proc must require `PROC_HIT_BLOCK` and retain its 1000 ms cooldown.
4. Spell 901074 must restore exactly 5 Energy and must not acquire its own equipment requirement.
5. Bladeguard must not grant Block capability, Shield skill, or shield proficiency.

## Verification

| Scenario | Expected | Status |
|---|---|---|
| Learn Bladeguard without a shield | No Bladeguard aura or bonuses | Not run |
| Equip a usable shield | Aura appears; item armor increases by 130 percent and block chance by 15 points | Not run |
| Unequip the shield | Aura and all bonuses disappear immediately | Not run |
| Block repeatedly inside one second | Only the first successful block restores 5 Energy | Not run |
| Block again after one second | Restores another 5 Energy | Not run |
| Human and bot Rogue | Identical mechanics when learned and shield-equipped | Not run |

## Change history

| Date | Change | Reference |
|---|---|---|
| 2026-09-22 | Initial guarded data-only implementation | [`../history/2026-09-22-bladeguard.md`](../history/2026-09-22-bladeguard.md) |

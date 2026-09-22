# Leeching Mixture

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_rogue_leeching_mixture.cpp`, `data/sql/db-world/2026_09_22_03_rogue_leeching_mixture.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-22

## Purpose

Leeching Mixture is Rogue defensive passive 901075. Poison damage dealt directly by the passive owner generates a self-heal equal to 8 percent of final event damage. Generated healing is limited to 2 percent of the Rogue's current maximum health in each one-second window.

## Acquisition and applicability

Acquisition remains external. Passive 901075 may be granted by a later talent, specialization, item, or administrative source. Helper 901076 is internal and must never be taught directly. Humans and playerbots use identical mechanics, and no active cast or playerbot strategy is required.

## Spell graph

| Spell | Contract |
|---|---|
| 901075 Leeching Mixture | Permanent Nature dummy aura with Rogue outgoing-damage proc metadata |
| 901076 Leeching Mixture Heal | Non-critical Nature self-heal with damage class none and no bonus-data row |

An event qualifies only when the aura owner is a Rogue, the proc actor and `DamageInfo` attacker are that exact Rogue, the victim is another unit, final damage is positive, and the damaging spell has both `SPELLFAMILY_ROGUE` and `DISPEL_POISON`. This includes stock Deadly Poison, Instant Poison, and Wound Poison ranks. Custom Rogue poison damage must preserve the same family and dispel metadata to qualify.

The direct-owner checks exclude poisons attributed to another Rogue, pets, guardians, or environmental sources. A poison reflected back to its caster has the Rogue as its victim and is rejected. The explicit reflected-hit guard also rejects proc events carrying `PROC_HIT_REFLECT`.

## Healing and cap formula

For each accepted event:

```text
candidate heal = floor(post-mitigation poison damage * 0.08)
window cap = floor(current maximum health * 0.02)
raw heal = min(candidate heal, window cap - raw healing already generated)
```

The first qualifying event starts an aura-local 1000 ms window. Further events share its remaining allowance. The first accepted event at or after expiration starts a new window. The cap is recalculated from current maximum health on every event. If maximum health falls below the amount already generated in the active window, no more healing is generated until the next window.

The cap applies to raw generated healing before healing-taken modifiers. Helper 901076 cannot critically heal. Its damage-class-none default and absence from `spell_bonus_data` keep healing-done bonuses from raising the generated amount above the cap. Its normal heal effect still passes through `SpellHealingBonusTaken`, so Mortal Strike-style healing reduction, arena dampening, healing absorption, and overhealing apply normally.

## Runtime flow

```text
Rogue has passive 901075
  -> Rogue directly deals positive Rogue-family poison damage
  -> reject self-damage and reflected or differently attributed events
  -> calculate 8 percent of final event damage
  -> clamp against the active one-second 2 percent maximum-health allowance
  -> cast helper 901076 on the Rogue for the remaining amount
  -> normal healing-taken reduction, dampening, absorption, and overheal resolve
```

The state consists of one window timestamp and one generated-healing counter in the passive AuraScript. Processing is constant-time and performs no combat-time database access.

## Data and deployment

The guarded automatic world update collision-checks 901075 and 901076 across `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs both spell rows, broad Rogue damage proc metadata, the passive script binding, fixed helper healing, and backend names. The icon is copied from Deadly Poison 2818 with 137 as an offline fallback.

Matching client `Spell.dbc` rows are required for both IDs. The server update, client patch, and module rebuild must ship together. Live server tables and the selected deployed client remain pending collision checks.

## Verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Deadly Poison periodic damage | Heals for floor(8 percent of final tick damage) within the cap | Not run |
| Instant Poison direct damage | Heals for floor(8 percent of final hit damage) within the cap | Not run |
| Wound Poison damage | Heals for floor(8 percent of final hit damage) within the cap | Not run |
| Custom Rogue poison with Rogue family and poison dispel metadata | Qualifies | Not run |
| Rogue damage without poison dispel metadata | Does not qualify | Not run |
| Poison damage attributed to another Rogue | Does not qualify for this Rogue | Not run |
| Reflected poison damage | Does not qualify | Not run |
| Many poison events inside one second | Raw generated healing stops at floor(2 percent maximum health) | Not run |
| Healing reduction or arena dampening is active | Helper output is reduced through normal healing-taken handling | Not run |
| Healing absorption or full health | Generated heal is absorbed or overheals normally and still consumes allowance | Not run |
| Human and playerbot Rogue | Mechanics are identical | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove 901075 from `spell_proc`, remove its script binding, and remove both backend names and spell rows. Restore the previous client patch and rebuild without the source and loader registration before restarting.

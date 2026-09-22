# Daring Challenge

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_rogue_daring_challenge.cpp`, `data/sql/db-world/2026_09_22_05_daring_challenge.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-22

## Purpose

Daring Challenge is Combat Rogue active 901070. It taunts one enemy at up to 30 yards for three seconds, matches the enemy's highest threat, adds one point of unmodified threat as a lead, and makes the Rogue's damaging attacks against that same enemy generate 50 percent additional damage-based threat for six seconds. It costs no resource, deals no damage, awards no combo point, and has a 10-second cooldown.

## Acquisition and bot behavior

The automatic world update assigns 901070 to Rogue class 4, Combat specialization index 1 through Spec Manager. Humans and playerbots use identical mechanics. Playerbot acquisition follows normal Spec Manager reconciliation, but selecting when to cast the active remains playerbot AI policy outside this module.

## Spell graph

| Spell | Contract |
|---|---|
| 901070 Daring Challenge | Client-facing 30-yard active with native `SPELL_EFFECT_ATTACK_ME` and three-second `SPELL_AURA_MOD_TAUNT` |
| 901071 Daring Challenge Threat | Internal non-saved six-second dummy proc aura cast by the successfully challenged enemy onto the Rogue |

Both IDs require matching client `Spell.dbc` rows. The helper's caster GUID identifies the only enemy eligible for bonus threat.

## Runtime flow

```text
Rogue casts 901070 on one hostile unit
  -> core hit and immunity handling resolves both taunt effects
  -> native attack-me effect matches the Rogue to highest threat
  -> native taunt aura forces target selection for three seconds
  -> only when that caster-owned taunt aura exists after the hit
     -> add one unmodified, unredirected threat
     -> challenged enemy applies helper 901071 to the Rogue for six seconds

Rogue deals positive damage while helper 901071 is active
  -> require Rogue as direct event attacker
  -> require helper caster as exact damage victim
  -> add 50 percent of final event damage through normal spell threat modifiers
```

## Threat and immunity contract

The native core owns target eligibility, effect immunity, the highest-threat match, taunt state, and expiration. Daring Challenge does not bypass `CREATURE_FLAG_EXTRA_NO_TAUNT`, encounter-script immunities, vehicle immunity, or any other core effect or aura immunity. If the taunt aura does not land, neither the one-point lead nor helper aura is applied.

The lead uses `ThreatManager::AddThreat` with threat modifiers and redirects disabled so it remains exactly one point on the challenged enemy. The six-second bonus uses the source damage spell, so normal school threat modifiers and threat redirection also affect the extra half-damage contribution. It does not multiply flat `spell_threat` additions or non-damage threat.

## State and cleanup

No global map, periodic update, or database access exists in combat. The helper aura is non-saved and expires after six seconds. Its caster is the challenged enemy, which makes simultaneous helper auras from different enemies independent. Loss of the caster makes later proc checks fail safely.

## Database and client contract

The automatic world update collision-checks 901070 and 901071 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs both spell rows, proc metadata, script bindings, non-save custom attributes, Combat Spec Manager acquisition, and backend names. Spell 901070 clones the verified stock Taunt 355 effect, target, range, duration, immunity, visual, and icon contract while changing the cooldown and Rogue family.

Live database and deployed-client collision checks remain operator deployment work. The repository currently contains concurrent uncommitted Rogue allocations through 901069, so this graph deliberately begins at 901070.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Enemy has another unit at highest threat | Rogue matches that threat, gains one point, and is forced target for three seconds | Not run |
| Enemy has an empty threat list | Rogue receives one threat and becomes the target | Not run |
| Taunt-immune boss | Core rejects the effects; no lead or helper aura appears | Not run |
| Rogue damages challenged enemy during six seconds | Additional threat equals 50 percent of final damage before normal threat modifiers | Not run |
| Rogue damages another enemy | No Daring Challenge bonus threat | Not run |
| Periodic or triggered Rogue damage hits the challenged enemy | Positive direct-owner damage remains eligible | Not run |
| Attack misses, is fully prevented, or deals zero damage | No bonus threat | Not run |
| Cooldown, range, damage, and combo points | 10 seconds, 30 yards, zero damage, and no combo point | Not run |
| Human and playerbot Combat Rogue | Identical mechanics after Spec Manager grants 901070 | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove 901070 from `mod_spec_spells`, remove 901071 from `spell_proc` and `spell_custom_attr`, remove both script bindings, backend names, and spell rows, restore the previous client patch, and rebuild without the source and loader registration before restarting.

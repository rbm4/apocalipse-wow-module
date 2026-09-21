# Apex Bond

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_hunter_apex_bond.cpp`, `data/sql/db-world/2026_09_21_01_apex_bond.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-21

## Purpose

Apex Bond is an active Beast Mastery Hunter sustain cooldown using spell 901046. It requires an alive active pet, instantly heals the Hunter and pet for 15 percent of each target's maximum health, and increases the pet's damage by 15 percent for 10 seconds. The spell has a 90-second cooldown.

## Acquisition boundary

The module defines spell 901046 and its runtime validation but does not teach it. Talent, trainer, item, specialization, and playerbot acquisition remain external. Matching server and client `Spell.dbc` rows are required.

## Human and bot applicability

Human and bot-controlled Hunters receive identical pet validation, healing, damage buff, duration, and cooldown behavior. Acquisition and cast-decision policy remain external. The cast path performs no database access and no bot detection.

## Spell contract

| Surface | Contract |
|---|---|
| Active | 901046 Apex Bond |
| Pet requirement | Hunter `Player::GetPet()` must return a living active `Pet` |
| Cooldown | 90 seconds |
| Hunter heal | Native `SPELL_EFFECT_HEAL_PCT`, 15 percent maximum health, caster target |
| Pet heal | Native `SPELL_EFFECT_HEAL_PCT`, 15 percent maximum health, pet target |
| Pet buff | Native `SPELL_AURA_MOD_DAMAGE_PERCENT_DONE`, all schools, 15 percent for 10 seconds |
| Persistence | Aura marked non-save through `spell_custom_attr` |
| Registration | `AddModApocalipseHunterApexBondScripts()` |
| Server migration | `data/sql/db-world/2026_09_21_01_apex_bond.sql` |

## Pet validation contract

The pet heal and damage aura use implicit target 5, `TARGET_UNIT_PET`. This is the same implicit target used by Mend Pet. The deployment core scans spell effects during `Spell::CheckCast` and returns `SPELL_FAILED_NO_PET` when a pet-targeted spell has no guardian pet or charm. This database target is the client-facing and generic core pet-presence contract, not a spell attribute flag.

The C++ script deliberately adds a stricter Hunter contract. It requires a player caster, obtains the active pet through `Player::GetPet()`, returns `SPELL_FAILED_NO_PET` when absent, and returns the core custom "Your pet is dead" error when the pet exists but is not alive. This follows the deployment core's Bestial Wrath validation rather than relying only on the generic implicit-target check.

## Runtime flow

```text
Hunter starts Apex Bond
  -> generic TARGET_UNIT_PET validation requires a pet-like target
  -> Apex Bond CheckCast requires a Hunter player with an active Pet
  -> dead active pet returns the standard pet-is-dead custom error
  -> successful cast heals the active pet for 15 percent maximum health
  -> successful cast heals the Hunter for 15 percent maximum health
  -> successful cast applies 15 percent all-damage increase to the pet for 10 sec
  -> parent spell enters its 90-second cooldown
```

The two percent heals are independent. Each starts from 15 percent of that unit's own maximum health and then uses normal core healing-done, healing-taken, and overheal handling. The pet damage increase is a normal aura on the pet, so pet melee and spell damage use the core's existing percent-damage modifier path without owner-side pet modifier lifecycle handling.

## Database and client contract

The automatic world update collision-checks 901046 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs the spell row, script binding, non-save metadata, and backend spell name. Duration index 1 must resolve to 10 seconds, recovery time must remain 90000 milliseconds, and both pet effects must retain implicit target 5.

A matching client patch is required. Client data must preserve the pet-targeted effects so the action is represented as requiring a pet before the server's authoritative `CheckCast` runs. The server remains authoritative for active-pet ownership and alive state.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Hunter has no active pet | Cast fails with `SPELL_FAILED_NO_PET`; no cooldown or effects | Not run |
| Hunter has a dead active pet | Cast fails with "Your pet is dead"; no cooldown or effects | Not run |
| Hunter and pet are both injured without healing modifiers | Each gains 15 percent of its own maximum health before overheal | Not run |
| Hunter or pet is at full health | Other valid effects still occur; full-health target receives only overheal | Not run |
| Valid cast | Pet gains 15 percent all-damage increase for 10 seconds | Not run |
| Buffed pet uses melee and damaging abilities | Final pet damage reflects the normal 15 percent aura modifier | Not run |
| Pet is dismissed, swapped, or dies after casting | Aura leaves with normal pet lifecycle; replacement pet does not inherit it | Not run |
| Recast before 90 seconds | Normal cooldown rejection | Not run |
| Human and playerbot Hunter | Identical mechanics when spell 901046 is acquired and cast | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove 901046 from `spell_script_names`, `spell_custom_attr`, `wotlk_spells`, and `spell_dbc`, remove acquisition references, and restore the previous client patch. Rebuild without the source and loader registration before restarting.

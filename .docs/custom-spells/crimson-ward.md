# Crimson Ward

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_death_knight_crimson_ward.cpp`, `data/sql/db-world/2026_09_21_04_crimson_ward.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-21

## Purpose

Crimson Ward is Blood Death Knight passive 901050. Positive incoming combat damage triggers a 15-second, non-dispellable absorb equal to 20 percent of the Death Knight's maximum health. All qualifying damage events share one 60-second internal cooldown.

## Acquisition boundary

The automatic world update adds passive 901050 to `mod_spec_spells` for class 6, Blood specialization index 0. Spec Manager teaches and revokes only 901050 as the dominant specialization changes. Helper 901051 must never be learned directly. Matching client `Spell.dbc` rows are required for both spells.

## Human and bot applicability

Human and bot-controlled Death Knights use identical damage eligibility, absorb calculation, duration, and cooldown behavior. No active cast decision or bot-specific integration is needed. The combat path performs no database access and no bot detection.

## Spell graph

| Surface | Contract |
|---|---|
| Passive | 901050 Crimson Ward, permanent self-targeted dummy proc aura |
| Trigger | Any positive combat damage represented by `DamageInfo` through `PROC_FLAG_TAKEN_DAMAGE` |
| Absorb | 901051 Crimson Ward, 15-second all-school absorb aura |
| Formula | `floor(20% * Death Knight maximum health)` when 901051 is applied |
| Dispel | `DispelType = 0`, so normal dispel mechanics cannot remove it |
| Cooldown | One aura-owned 60000 ms `spell_proc` cooldown shared by every qualifying damage event |
| Persistence | Helper 901051 carries `SPELL_ATTR0_CU_AURA_CANNOT_BE_SAVED` |
| Registration | `AddModApocalipseDeathKnightCrimsonWardScripts()` |
| Acquisition | `mod_spec_spells` class 6, Blood spec index 0, passive 901050 only |
| Server migration | `data/sql/db-world/2026_09_21_04_crimson_ward.sql` |

## Runtime flow

```text
positive incoming combat damage reaches Death Knight with passive 901050
  -> spell_proc checks the passive's shared 60-second cooldown
  -> AuraScript confirms a player owner and positive DamageInfo
  -> passive starts its cooldown and triggers helper 901051
  -> helper snapshots 20 percent of current maximum health
  -> all schools consume that absorb pool for up to 15 seconds
```

The triggering damage causes the proc and is resolved before the newly applied shield can absorb later damage. Fully absorbed, resisted, immune, missed, and otherwise zero-damage events do not trigger Crimson Ward or start its cooldown.

## Damage and absorb contract

`PROC_FLAG_TAKEN_DAMAGE` accepts melee, ranged, direct spell, periodic, and triggered combat damage without attacker, school, spell-family, or damage-class restrictions. The deployment core's separate environmental-damage path is outside this proc contract.

The helper amount is calculated once when aura 901051 is applied. Later maximum-health changes do not resize the existing shield. The all-school mask is 127. Normal absorb ordering and integer handling remain core-owned. Reapplication cannot occur during the 60-second cooldown, which is longer than the 15-second helper duration.

Crimson Ward is not registered with `mod_spell_scaling`, so its 20 percent maximum-health formula remains identical at every level. PvP Balancing does not alter absorb creation.

## Database and client contract

The automatic world update collision-checks 901050 and 901051 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs both spell rows, passive proc metadata, both script bindings, the helper non-save attribute, Blood Spec Manager acquisition, and backend names. The SQL uses 901050 and 901051 because unrelated local Rupture work reserves 901048 and 901049.

The passive description states the 15-second duration, 20 percent formula, non-dispellability, and one-minute cooldown. Server and client exports must preserve passive 901050, helper 901051, the all-school absorb mask, and the helper duration.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Death Knight with 30000 maximum health takes positive combat damage | Gains a 6000-point absorb for 15 seconds and starts the 60-second cooldown | Not run |
| The triggering hit deals positive damage | Hit resolves normally; the new shield applies for subsequent damage | Not run |
| Melee, ranged, direct spell, periodic, or triggered damage lands | Each source can trigger while the passive is off cooldown | Not run |
| Fully absorbed, immune, resisted, missed, or zero-damage event occurs | No shield and no cooldown | Not run |
| Environmental damage occurs | No proc through the deployment core's current environmental path | Not run |
| Qualifying damage occurs while the cooldown is active | No new shield and the existing cooldown is unchanged | Not run |
| Normal dispel targets helper 901051 | Shield remains because it has no dispel type | Not run |
| Maximum health changes after helper application | Existing absorb amount remains unchanged | Not run |
| Human and playerbot Death Knight | Identical mechanics while passive 901050 is known | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove 901050 from `spell_proc`, remove both Crimson Ward entries from `spell_script_names`, remove 901051 from `spell_custom_attr`, remove 901050 and 901051 from `wotlk_spells` and `spell_dbc`, remove the Blood `mod_spec_spells` row for 901050, and restore the previous client patch. Rebuild without the source and loader registration before restarting.

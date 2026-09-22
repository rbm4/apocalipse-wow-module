# Gloomblade Infusion

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_rogue_gloomblade_infusion.cpp`, `data/sql/db-world/2026_09_22_07_gloomblade_infusion.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-22

## Purpose

Gloomblade Infusion is Subtlety Rogue passive 901079. Every accepted positive damage event dealt directly by its owner triggers helper 901080 with base Shadow damage equal to 10 percent of the post-mitigation triggering event.

## Acquisition and applicability

The automatic world update adds passive 901079 to `mod_spec_spells` for Rogue class 4, Subtlety tree index 2. Spec Manager grants and revokes it through its existing reconciliation flow. Helper 901080 is internal and must never be taught directly. Humans and playerbots use identical mechanics, and no active cast or playerbot strategy is required.

## Spell graph

| Spell | Contract |
|---|---|
| 901079 Gloomblade Infusion | Permanent Shadow dummy aura with broad direct and periodic outgoing-damage proc metadata |
| 901080 Gloomblade Infusion Damage | Internal, non-critical, generic-family single-target Shadow school-damage spell with a script-supplied base point |

The proc requires both the event actor and `DamageInfo` attacker to be the Rogue. It accepts melee and ranged auto attacks, direct abilities, periodic damage, poisons, and triggered damage that produces an ordinary damage proc event. Pet and guardian damage, reflected damage, self-damage, zero damage, misses, and fully prevented events do not trigger it.

Helper 901080 is a triggered generic-family cast. Passive 901079 allows triggered source damage but rejects helper 901080 explicitly, preventing recursion. The generic family also prevents Rogue-family passives such as Shadow Execution from treating the internal helper as a Rogue ability. Other proc systems independently apply their normal triggered-spell eligibility rules to the helper event.

## Damage formula

For each accepted event:

```text
helper base damage = floor(post-mitigation triggering damage * 0.10)
```

A result below 1 deals no helper damage. The helper cannot critically strike. It then follows normal Shadow spell-damage resolution, including target Shadow resistance, absorbs, damage-taken modifiers, module PvP balancing, threat, and combat logging. The source event has already passed its own scaling, damage modifiers, mitigation, and PvP path before the passive reads `DamageInfo::GetDamage()`.

This design means the final health loss from helper 901080 can be lower than 10 percent of the triggering event after independent Shadow mitigation. No `mod_spell_scaling` row or spell-power coefficient is installed.

## Runtime flow

```text
Subtlety Rogue has passive 901079
  -> owner directly deals positive damage to another living unit
  -> reject reflected damage and helper 901080
  -> calculate floor(10 percent of final event damage)
  -> trigger non-critical helper 901080 on the same victim
  -> resolve a separate Shadow damage event with explicit self-recursion rejection
```

The path is constant-time and performs no combat-time database access.

## Data and deployment

The guarded automatic world update collision-checks 901079 and 901080 across `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs both server spell rows, broad outgoing-damage proc metadata, the passive script binding, a zero-coefficient helper contract, Subtlety Spec Manager acquisition, and backend names. The icon is copied from Shadow Dance 51713 with zero as a guarded fallback.

Matching client `Spell.dbc` rows are required for both IDs. The server update, client patch, module rebuild, and specialization acquisition must ship together. Live server tables and the selected deployed client remain pending collision checks.

## Verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Main-hand or offhand auto attack deals damage | One separate Shadow event with base damage floor(source damage * 0.10) | Not run |
| Direct Rogue ability deals damage | One separate Shadow event per accepted damage event | Not run |
| Deadly Poison tick or another Rogue poison deals damage | One separate Shadow event | Not run |
| Rogue periodic bleed deals damage | One separate Shadow event | Not run |
| Triggered Rogue-owned damage emits a proc event | One separate Shadow event | Not run |
| Helper 901080 deals damage | No recursive Gloomblade trigger and no Rogue-family Shadow Execution trigger | Not run |
| Pet, guardian, reflected, self, zero, missed, or fully prevented damage | No helper damage | Not run |
| Triggering damage is below 10 | Rounded helper base is zero and no cast occurs | Not run |
| Target has Shadow resistance, absorb, or PvP reduction | Helper resolves those defenses independently | Not run |
| Human and playerbot Subtlety Rogue | Mechanics are identical | Not run |
| Rogue changes away from Subtlety | Spec Manager revokes passive 901079 | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove 901079 from `mod_spec_spells` and `spell_proc`, remove its script binding, remove both backend names and spell rows, and restore the previous client patch. Rebuild without the source and loader registration before restarting.

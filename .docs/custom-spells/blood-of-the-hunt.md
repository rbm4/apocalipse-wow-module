# Blood of the Hunt

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_hunter_blood_of_the_hunt.cpp`, `data/sql/db-world/2026_09_21_01_blood_of_the_hunt.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-21

## Purpose

Blood of the Hunt is a shared Hunter passive using spell 901044. A successful Hunter melee special heals the Hunter for 15 percent of damage dealt. A Hunter trap activation heals the Hunter for 5 percent of maximum health. Both event types share a two-second internal cooldown.

## Acquisition boundary

The module defines the passive and helper but does not teach passive 901044. Talent, trainer, item, specialization, and playerbot acquisition remain external. Acquisition data must reference only 901044. Matching client `Spell.dbc` rows are required for 901044 and 901045.

## Human and bot applicability

Human and bot-controlled Hunters use identical eligibility, healing, and cooldown behavior. Existing melee-special and trap actions need no AI changes. The combat path performs no database access and no bot detection.

## Spell graph

| Surface | Contract |
|---|---|
| Passive | 901044 Blood of the Hunt, permanent passive dummy proc aura |
| Melee event | Positive damage from a Hunter-family melee damage-class spell whose family mask is Raptor Strike, Mongoose Bite, Wing Clip, or Counterattack |
| Trap event | `PROC_FLAG_DONE_TRAP_ACTIVATION`, Hunter family, finish phase, and a real trap triggerer |
| Heal helper | 901045 Blood Heal, direct self-heal with no spell-power or attack-power coefficient |
| Melee formula | `floor(15% * DamageInfo::GetDamage())` |
| Trap formula | `floor(5% * Hunter maximum health)` |
| Cooldown | One aura-owned 2000 ms `spell_proc` cooldown shared by melee and trap events |
| Scaling | 901045 has a `HEAL` row with factor 1.0 in `mod_spell_scaling` |
| Registration | `AddModApocalipseHunterBloodOfTheHuntScripts()` |
| Server migration | `data/sql/db-world/2026_09_21_01_blood_of_the_hunt.sql` |

## Runtime flow

```text
eligible Hunter melee special deals positive damage
  -> hit-phase proc candidate reaches passive 901044
  -> AuraScript requires Hunter family, melee damage class, and family mask
  -> calculate 15 percent of final DamageInfo damage
  -> trigger Blood Heal 901045 on the Hunter
  -> passive enters its shared two-second internal cooldown

Hunter trap activation finishes
  -> finish-phase proc candidate reaches passive 901044
  -> AuraScript requires Hunter family and a real trap triggerer
  -> calculate 5 percent of Hunter maximum health
  -> trigger Blood Heal 901045 on the Hunter
  -> passive enters the same shared two-second internal cooldown
```

## Eligibility contract

The melee family mask combines Mongoose Bite's `0x02` and the shared Raptor Strike and Wing Clip `0x40` bit in word 0, Counterattack's `0x00080000` bit in word 1, and Raptor Strike's additional `0x00010000` bit in word 2. The script additionally requires Hunter family, melee damage class, the melee-spell proc flag, a `DamageInfo`, and strictly positive damage. White attacks, pet abilities, ranged attacks, periodic damage, misses, dodges, parries, immune hits, and fully absorbed hits do not heal.

Trap handling uses the deployment core's explicit trap-activation event. It requires the aura owner as actor, Hunter spell family, a non-null proc spell, and the proc spell's non-null original target. The original target is the unit that activated the trap. Trap damage ticks without a new activation do not heal.

## Healing, cooldown, and scaling contract

Both formulas use 64-bit intermediate arithmetic and integer flooring. The melee branch uses post-mitigation positive damage exposed by `DamageInfo`, so absorbs and other damage reductions lower the heal. Overhealing is handled by the normal direct-heal path.

The `spell_proc` row carries one 2000 ms cooldown for passive 901044. Because cooldown state belongs to the whole aura, a melee heal blocks trap healing and a trap heal blocks melee healing until the same cooldown expires. Rejected events do not start the cooldown. `PROC_ATTR_TRIGGERED_CAN_PROC` is required because the core emits trap activation from a triggered trap cast.

Blood Heal has zero direct, periodic, attack-power, and periodic attack-power coefficients. Spell Scaling applies its `HEAL` factor after the helper amount is supplied. Below level 80, the current factor 1.0 multiplies the direct heal by Hunter level divided by 80 and truncates to an integer. PvP Balancing does not modify healing.

## Database and client contract

The automatic world update collision-checks 901044 and 901045 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs both spell rows, shared proc metadata, the passive script binding, zero helper coefficients, the HEAL scaling row, and backend spell names.

The passive description explicitly states the two-second internal cooldown. Server and client exports must preserve that description, both proc flags, hit and finish phases, the 2000 ms cooldown, and helper 901045 as a direct self-heal.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Raptor Strike, Mongoose Bite, damaging Wing Clip, or Counterattack deals 1000 damage | Hunter receives a 150 base-point Blood Heal before lower-level scaling | Not run |
| Eligible melee special deals zero damage or is fully absorbed | No heal and no internal cooldown | Not run |
| White melee, ranged special, trap damage tick, or pet melee ability lands | No heal | Not run |
| Hunter trap activates | Hunter receives a Blood Heal equal to 5 percent maximum health before lower-level scaling | Not run |
| Trap activates without a real triggerer | No heal | Not run |
| Second eligible event occurs within two seconds | No second heal | Not run |
| Melee event followed immediately by trap activation | Trap heal is blocked by the shared cooldown | Not run |
| Trap activation followed immediately by melee event | Melee heal is blocked by the shared cooldown | Not run |
| Hunter is below level 80 | Blood Heal receives configured linear HEAL scaling | Not run |
| Hunter is at full health | Proc and cooldown occur, with normal overhealing | Not run |
| Human and playerbot Hunter | Identical mechanics while passive 901044 is known | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove 901044 from `spell_proc` and `spell_script_names`, remove 901045 from `spell_bonus_data` and `mod_spell_scaling`, remove 901044 and 901045 from `wotlk_spells` and `spell_dbc`, remove acquisition references to 901044, and restore the previous client patch. Rebuild without the source and loader registration before restarting.

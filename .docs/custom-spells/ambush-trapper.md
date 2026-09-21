# Ambush Trapper

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_hunter_ambush_trapper.cpp`, `data/sql/db-world/2026_09_21_00_ambush_trapper.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-21

## Purpose

Ambush Trapper is a Survival Hunter passive using spell 901038. Any Hunter trap activation grants Predator's Ambush 901039 for 15 seconds with five proc charges. Each qualifying Hunter melee special hit consumes one charge, deals capped percent-health Physical damage through helper 901040, and restores 5 percent maximum mana through helper 901041.

## Acquisition boundary

The module defines the four-spell graph and runtime behavior but does not teach passive 901038. Talent, trainer, item, specialization, and playerbot acquisition remain external. Acquisition data must reference only 901038. Matching client `Spell.dbc` rows are required for all four spells.

## Human and bot applicability

Human and bot-controlled Hunters use identical trap, charge, damage, mana, duration, and cleanup behavior. Existing trap placement and melee-special actions need no AI changes. The combat path performs no database access and no bot detection.

## Spell graph

| Surface | Contract |
|---|---|
| Passive | 901038 Ambush Trapper, permanent passive proc-trigger aura |
| Trap event | `PROC_FLAG_DONE_TRAP_ACTIVATION`, Hunter family, finish phase, 100 percent chance |
| Buff | 901039 Predator's Ambush, 15 seconds, five native proc charges, non-saved |
| Charge event | Hunter-family spell with melee damage class that lands as normal, critical, or absorbed hit |
| Damage helper | 901040 Ambush Strike, Physical direct damage with no spell-power or attack-power coefficient |
| Damage formula | `floor(2% * min(target maximum health, Hunter maximum health))` before lower-level and PvP modifiers |
| Mana helper | 901041 Ambush Mana, native `SPELL_EFFECT_ENERGIZE_PCT` for 5 percent maximum mana |
| Scaling | 901040 has a `DAMAGE` row with factor 1.0 in `mod_spell_scaling` |
| Registration | `AddModApocalipseHunterAmbushTrapperScripts()` |
| Server migration | `data/sql/db-world/2026_09_21_00_ambush_trapper.sql` |

## Runtime flow

```text
Hunter trap activation finishes
  -> spell_proc selects the trap activation event for Hunter family
  -> passive script requires the Hunter to own the event
  -> require a real proc spell with the trap triggerer as original target
  -> passive proc handler applies or refreshes Predator's Ambush on the Hunter

Hunter melee special lands while Predator's Ambush is active
  -> spell_proc selects Hunter-family melee damage-class hit
  -> script requires a living action target and damage or absorb result
  -> core consumes one native proc charge
  -> calculate 2 percent of the lower maximum health value
  -> cast Ambush Strike on the action target
  -> cast Ambush Mana on the Hunter
  -> remove Predator's Ambush after its fifth consumed charge
```

## Trap and false-positive contract

The passive uses the deployment core's explicit trap-activation event rather than ordinary damage from a trap. Its AuraScript requires `PROC_FLAG_DONE_TRAP_ACTIVATION`, the aura owner as event actor, Hunter spell family, a non-null proc spell, and the proc spell's non-null original target. The original target is the unit that activated the trap. This permits freezing, fire, frost, snake, and other Hunter trap activations while rejecting unrelated Hunter casts and synthetic events without a trap triggerer. The script suppresses the default trigger and explicitly self-casts 901039 so the trap triggerer cannot become the buff target.

The `spell_proc` phase is finish because the core emits the trap activation event from the spell finish path. `PROC_ATTR_TRIGGERED_CAN_PROC` is required because trap activation spells are triggered casts.

## Charge and damage contract

Predator's Ambush uses native proc charges rather than aura stacks. `ProcCharges` and `spell_proc.Charges` are both five, while the spell stack amount is zero so the client can display charges. Core proc preparation decrements one charge before AuraScript handling and removes the aura after the fifth proc.

Only Hunter-family spells whose damage class is melee qualify. White attacks, ranged Hunter specials, trap damage, periodic damage, helper 901040, misses, dodges, parries, and immune results do not consume a charge. A fully absorbed melee-special hit does consume one charge because it landed and carries the absorb hit mask.

The script calculates the helper base point with 64-bit intermediate arithmetic and integer flooring. Ambush Strike has zero explicit spell-power and attack-power coefficients. Spell Scaling then multiplies direct damage by `hunter level / 80` below level 80. PvP Balancing applies afterward according to loader registration, so PvP output receives both integer conversions. At level 80 against a non-player, the helper's pre-mitigation amount is exactly the capped formula.

## Mana and persistence contract

Ambush Mana uses native percent energize with power type mana and stored base points 4, which AzerothCore interprets as 5 percent. The helper casts once for every consumed charge. At full mana the charge is still consumed and damage still occurs.

Predator's Ambush is marked non-save. Removing passive 901038 explicitly removes 901039, including talent or specialization revocation. Expiration, fifth-charge removal, logout, death, and normal aura cleanup cannot create permanent character state. A later trap activation reapplies or refreshes the 15-second buff with five charges.

## Database and client contract

The automatic world update collision-checks 901038 through 901041 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs all spell rows, both proc rows, both script bindings, non-save metadata, the zero-coefficient helper row, the lower-level scaling row, and backend spell names.

The update assumes the manual Spell Scaling baseline has already created `mod_spell_scaling`, as required by the module's existing installation order. Server and client exports must preserve duration index 8 as 15 seconds, five proc charges on 901039, Physical school and direct-damage effect on 901040, and the percent-mana effect on 901041.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Any Hunter trap activates with passive 901038 | Predator's Ambush appears for 15 seconds with five charges | Not run |
| Trap damage ticks without a new activation | No additional buff application | Not run |
| Unrelated Hunter spell finishes | No buff application | Not run |
| Raptor Strike, Mongoose Bite, Wing Clip damage, or Counterattack lands | One charge is consumed, capped Physical damage occurs, and 5 percent mana is restored | Not run |
| White melee or ranged Hunter attack lands | No charge is consumed | Not run |
| Melee special misses, is dodged, parried, or immune | No charge is consumed | Not run |
| Melee special is fully absorbed | One charge is consumed and helper behavior executes | Not run |
| Target maximum health is below Hunter maximum health | Damage starts at 2 percent of target maximum health | Not run |
| Target maximum health exceeds Hunter maximum health | Damage starts at 2 percent of Hunter maximum health | Not run |
| Hunter is below level 80 | Ambush Strike receives configured linear DAMAGE scaling | Not run |
| Player target | Existing PvP reduction composes after Spell Scaling | Not run |
| Fifth qualifying hit | Fifth damage and mana effects occur, then the buff is removed | Not run |
| Buff expires or Hunter logs out | Remaining charges are removed and not persisted | Not run |
| Human and playerbot Hunter | Identical mechanics while passive 901038 is known | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove 901038 and 901039 from `spell_proc` and `spell_script_names`, remove 901039 from `spell_custom_attr`, remove 901040 from `spell_bonus_data` and `mod_spell_scaling`, remove 901038 through 901041 from `wotlk_spells` and `spell_dbc`, remove acquisition references to 901038, and restore the previous client patch. Rebuild without the source and loader registration before restarting.

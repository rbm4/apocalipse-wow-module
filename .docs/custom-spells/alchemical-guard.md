# Alchemical Guard

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_rogue_alchemical_guard.cpp`, `data/sql/db-world/2026_09_22_04_alchemical_guard.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-22

## Purpose

Alchemical Guard is Combat Rogue active defensive spell 901077. It reduces all damage taken by 20 percent for 6 seconds, removes existing poison and disease auras, and prevents new poison and disease auras during that duration. It has a 60-second cooldown and uses the normal 1.5-second global cooldown.

## Acquisition boundary

The module defines spell 901077 and its runtime behavior but does not teach it. Talent, trainer, item, specialization, and playerbot acquisition remain external. Matching server and client `Spell.dbc` rows are required.

## Human and bot applicability

Humans and bot-controlled Rogues receive identical mechanics after casting. The module does not add a playerbot action or cast-decision policy. Acquisition and active use by bots remain external.

## Spell contract

| Surface | Contract |
|---|---|
| Active | 901077 Alchemical Guard |
| Target | Rogue caster |
| Cooldown | 60 seconds |
| Global cooldown | Category 133, 1500 milliseconds |
| Duration | 6 seconds |
| Defensive aura | Native `SPELL_AURA_MOD_DAMAGE_PERCENT_TAKEN`, -20 percent, school mask 127 |
| Immunities | Native `SPELL_AURA_DISPEL_IMMUNITY` for `DISPEL_POISON` and `DISPEL_DISEASE` |
| Activation cleanup | `SPELL_ATTR1_IMMUNITY_PURGES_EFFECT` removes existing poison and disease auras |
| Preserved effects | Magic, curse, bleed, and effects with any other dispel classification |
| Controlled casting | Allowed while stunned, feared, or confused; prevention type zero permits casting while silenced or pacified |
| Stealth | `SPELL_ATTR1_ALLOW_WHILE_STEALTHED`; the cast does not remove stealth by itself |
| Persistence | Aura marked non-save through `spell_custom_attr` |
| Registration | `AddModApocalipseRogueAlchemicalGuardScripts()` |

## Runtime flow

```text
Rogue successfully casts Alchemical Guard 901077
  -> normal 1.5-second global cooldown begins
  -> poison and disease dispel immunities activate
  -> immunity-purge handling removes existing poison and disease auras
  -> native all-school damage-taken aura reduces damage by 20 percent
  -> new poison and disease spells are rejected for 6 seconds
  -> magic, curse, bleed, and other effects remain unaffected
  -> all three aura effects expire together
  -> normal cooldown prevents recast until 60 seconds after activation
```

The implementation uses native core immunity and damage handling. The C++ aura script validates the exact spell contract but adds no combat hook, scan, database query, or custom runtime state.

## Database and client contract

The automatic world update collision-checks 901077 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs the spell row, script binding, non-save metadata, and backend spell name. The icon is derived from stock Cloak of Shadows 31224. A matching client patch is required for presentation and controlled-cast flags.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Cast with poison and disease auras active | All existing poison and disease auras are removed | Not run |
| Cast with magic, curse, and bleed effects active | Those effects remain | Not run |
| Poison or disease is applied during the aura | Application is immune | Not run |
| Physical or magical damage is received | Final damage uses the native 20 percent reduction | Not run |
| Cast while stunned, feared, confused, silenced, or pacified | Cast is allowed, subject to cooldown and GCD | Not run |
| Cast from stealth | Stealth remains unless another unrelated effect removes it | Not run |
| Recast before 60 seconds | Normal cooldown rejection | Not run |
| Human and playerbot Rogue | Identical mechanics when spell 901077 is acquired and cast | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove 901077 from `spell_script_names`, `spell_custom_attr`, `wotlk_spells`, and `spell_dbc`, remove external acquisition references, and restore the previous client patch. Rebuild without the source and loader registration before restarting.

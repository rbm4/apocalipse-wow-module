# Primal Resolve

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_hunter_primal_resolve.cpp`, `data/sql/db-world/2026_09_21_03_primal_resolve.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-21

## Purpose

Primal Resolve is shared Hunter active defensive spell 901042. On a successful self-cast it removes current snare effects and reduces all damage taken by 15 percent for 6 seconds. The spell has a 30-second cooldown.

## Acquisition boundary

The module defines spell 901042 and its runtime behavior but does not teach it. Talent, trainer, item, specialization, and playerbot acquisition remain external. Matching server and client `Spell.dbc` rows are required.

## Human and bot applicability

Human and bot-controlled Hunters receive identical snare removal, damage reduction, duration, and cooldown behavior after casting. The module does not add a playerbot action or cast-decision policy. Acquisition and active use by bots remain external.

## Spell contract

| Surface | Contract |
|---|---|
| Active | 901042 Primal Resolve |
| Target | Hunter caster |
| Cooldown | 30 seconds |
| Duration | 6 seconds |
| Defensive aura | Native `SPELL_AURA_MOD_DAMAGE_PERCENT_TAKEN`, -15 percent, school mask 127 |
| Cast cleanup | `Unit::RemoveMovementImpairingAuras(false)` |
| Root behavior | Roots are not removed |
| Immunity behavior | No snare, slow, root, control, or targeting immunity |
| Combat behavior | Does not pacify, silence, disarm, suppress attacks, or change targetability |
| Persistence | Aura marked non-save through `spell_custom_attr` |
| Registration | `AddModApocalipseHunterPrimalResolveScripts()` |
| Server migration | `data/sql/db-world/2026_09_21_03_primal_resolve.sql` |

## Runtime flow

```text
Hunter successfully casts Primal Resolve 901042
  -> native self aura reduces all-school damage taken by 15 percent
  -> script effect removes current auras carrying MECHANIC_SNARE
  -> roots and unrelated control effects remain
  -> Hunter remains attack-capable and targetable
  -> damage reduction expires after 6 seconds
  -> normal cooldown prevents recast until 30 seconds after the cast
```

The cleanup calls the deployment core helper with `withRoot` set to false. That helper removes auras whose spell or an effect carries `MECHANIC_SNARE`. It does not remove roots and does not install immunity, so a new snare can be applied immediately after the cast.

The damage reduction uses the normal all-school damage-taken multiplier. It composes multiplicatively with other positive or negative `SPELL_AURA_MOD_DAMAGE_PERCENT_TAKEN` effects and applies through the core's normal damage paths. No module damage hook, database query, periodic scan, or custom runtime state is added.

## Database and client contract

The automatic world update collision-checks 901042 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs the spell row, exact script binding, non-save metadata, and backend spell name. Duration index 32 must resolve to 6000 milliseconds, recovery time must remain 30000 milliseconds, and effect 0 must remain an all-school -15 percent damage-taken aura.

A matching client patch is required for name, description, icon, duration, cooldown, and effect presentation. The server remains authoritative for aura application and snare removal.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Hunter has one or more `MECHANIC_SNARE` auras | Successful cast removes all current snare auras | Not run |
| Hunter is rooted without a snare | Root remains after cast | Not run |
| Hunter is both rooted and snared | Snare is removed and root remains | Not run |
| A new snare lands during the 6-second aura | New snare applies normally because no immunity exists | Not run |
| Hunter takes Physical, Holy, Fire, Nature, Frost, Shadow, or Arcane damage | Final damage uses the native 15 percent reduction | Not run |
| Hunter attacks or casts during the aura | Actions remain available subject to unrelated normal restrictions | Not run |
| Enemy targets the Hunter during the aura | Hunter remains targetable | Not run |
| Aura reaches 6 seconds | Damage reduction expires normally | Not run |
| Recast before 30 seconds | Normal cooldown rejection | Not run |
| Human and playerbot Hunter | Identical mechanics when spell 901042 is acquired and cast | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove 901042 from `spell_script_names`, `spell_custom_attr`, `wotlk_spells`, and `spell_dbc`, remove acquisition references, and restore the previous client patch. Rebuild without the source and loader registration before restarting.

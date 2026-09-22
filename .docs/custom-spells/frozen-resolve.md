# Frozen Resolve

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_death_knight_frozen_resolve.cpp`, `data/sql/db-world/2026_09_21_05_frozen_resolve.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-21

## Purpose

Frozen Resolve is Death Knight passive 901052. While its owner is in combat, its permanent periodic aura applies one stack of timed aura 901053 every 2 seconds. Each stack increases armor by 2 percent and reduces all damage taken by 2 percent. The timed aura lasts 8 seconds and caps at 10 stacks, for a maximum of 20 percent armor and 20 percent damage reduction.

## Acquisition boundary

The module defines spells 901052 and 901053 and their runtime behavior but does not modify the existing external acquisition flow. Acquisition must reference only unranked passive 901052. Spell 901053 is an internal triggered helper that must never be taught, and neither spell belongs in `spell_ranks`. Matching server and client `Spell.dbc` rows are required for both spells.

## Human and bot applicability

Human and bot-controlled Death Knights use identical combat-state checks, stack cadence, cap, duration, armor, and damage reduction. The module adds no playerbot strategy or action because the passive requires no active cast.

## Spell contract

| Surface | Contract |
|---|---|
| Passive | 901052 Frozen Resolve |
| Timed aura | 901053 Frozen Resolve |
| Passive duration | Permanent |
| Period | 2000 milliseconds |
| Eligibility | Aura owner is in combat at the periodic tick |
| Timed duration | 8000 milliseconds, refreshed by each accepted application |
| Stack cap | 10 |
| Armor per stack | Native `SPELL_AURA_MOD_RESISTANCE_PCT`, +2 percent, Physical mask 1 |
| Damage reduction per stack | Native `SPELL_AURA_MOD_DAMAGE_PERCENT_TAKEN`, -2 percent, all-school mask 127 |
| Maximum benefit | +20 percent armor and -20 percent all damage taken |
| Removal | Timed aura 901053 has no dispel type and cannot be stolen |
| Persistence | Timed aura 901053 is non-save; passive acquisition remains externally owned |
| Registration | `AddModApocalipseDeathKnightFrozenResolveScripts()` |
| Server migration | `data/sql/db-world/2026_09_21_05_frozen_resolve.sql` |

## Runtime flow

```text
permanent passive 901052 ticks every 2 seconds
  -> owner is not in combat: no action
  -> owner is in combat: trigger self-cast 901053
     -> first cast creates one 8-second stack
     -> repeated cast increments one stack and refreshes the shared duration
     -> native stack cap stops growth after 10 stacks
     -> armor and all-damage reduction scale with the current stack count
```

The 2-second schedule belongs to the permanent aura, so combat entry does not restart its periodic timer. The first stack can therefore arrive between immediately and 2 seconds after combat begins. Every later qualifying periodic tick is 2 seconds apart. Leaving combat stops new applications, and the shared stack aura expires 8 seconds after its last accepted combat tick.

Repeated triggered casts use the core stacking path. At the 10-stack cap, later qualifying ticks keep the stack count at 10 and refresh the 8-second duration. The effect therefore reaches maximum strength after 10 accepted combat ticks from an empty state and remains capped while combat continues.

## Damage composition

Armor uses the native total-resistance percentage handler for the Physical school. Each stack contributes 2 percentage points to one combined multiplier, reaching 1.20 at 10 stacks. Native stack amount calculation turns the damage-taken effect into -2 percentage points per stack, reaching one 0.80 multiplier at 10 stacks. That result composes multiplicatively with Icebound Fortitude and other separate damage-taken auras. The deployment core's environmental self-damage path bypasses this damage-taken multiplier, so fall, fatigue, drowning, and similar environmental damage are not reduced. Frozen Resolve does not grant control immunity, alter Icebound Fortitude, or replace its active defensive role.

## Database and client contract

The automatic world update collision-checks 901052 and 901053 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs both spell rows, the passive script binding, the non-save timed-aura marker, and backend names. Duration index 21 must remain permanent, duration index 31 must resolve to 8000 milliseconds, and icon 2720 is derived from stock Icebound Fortitude 48792 in the checked-in deployment `Spell.dbc`.

The backend exporter reads complete override rows from `spell_dbc`, uses the ordered `wotlk_spells_full` schema as its DBC field map, and appends new IDs to the selected base `Spell.dbc`. It does not require duplicate custom rows in `wotlk_spells_full`; `wotlk_spells` supplies the picker name cache.

A matching client patch is required for names, descriptions, icon, duration, and stack presentation. The server remains authoritative for combat eligibility, stack applications, armor, and damage reduction.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Owner remains out of combat | Passive ticks but 901053 is not applied | Not run |
| Owner enters combat with no stack aura | First periodic tick applies one stack | Not run |
| Owner remains in combat for 10 accepted ticks | Aura reaches 10 stacks and stops increasing | Not run |
| Owner remains in combat at 10 stacks | Each tick refreshes the shared 8-second duration | Not run |
| Owner leaves combat | No new stacks apply and existing stacks expire within 8 seconds | Not run |
| Owner re-enters before expiration | Next qualifying tick adds one stack and refreshes duration | Not run |
| Passive 901052 is removed while helper stacks remain | No new stacks apply; helper 901053 expires within 8 seconds | Not run |
| Physical armor is inspected | Current armor includes 2 percent per stack | Not run |
| Physical and magical combat damage are received | Final damage uses 2 percent reduction per stack | Not run |
| Fall, fatigue, drowning, or similar environmental damage occurs | Damage follows the separate environmental path and is not reduced by 901053 | Not run |
| Icebound Fortitude overlaps | Both damage-taken multipliers compose without Frozen Resolve granting immunity | Not run |
| Human and playerbot Death Knight | Mechanics are identical when passive 901052 is acquired | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove 901052 and 901053 from `spell_script_names`, `spell_custom_attr`, `wotlk_spells`, and `spell_dbc`, remove acquisition references, and restore the previous client patch. Rebuild without the source and loader registration before restarting.

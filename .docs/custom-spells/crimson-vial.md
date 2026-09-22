# Crimson Vial

Status: Implemented in data, build and runtime not verified

Owner: `data/sql/db-world/2026_09_22_09_crimson_vial.sql`

Last source review: 2026-09-22

## Purpose

Crimson Vial is generic Rogue active self-heal 901083. It costs 20 Energy, starts a 45-second cooldown and one-second Rogue global cooldown on a successful cast, and heals the caster for 5 percent maximum health immediately and once per second for 6 seconds. The seven raw healing events total a nominal 35 percent maximum health.

## Acquisition boundary

The module defines the spell but does not teach it. Talent, trainer, item, specialization, and playerbot acquisition remain external. A matching client `Spell.dbc` row is required because players cast and see the spell directly.

## Human and bot applicability

Humans and bot-controlled Rogues receive identical server mechanics after casting. The module adds no playerbot action, trigger, or cast-decision policy. Acquisition and autonomous use by bots remain external.

## Spell contract

| Surface | Contract |
|---|---|
| Active | 901083 Crimson Vial |
| Caster and target | Living Rogue player, caster only |
| Cost | 20 Energy on successful cast |
| Cooldown | 45 seconds, beginning on successful cast |
| Global cooldown | Category 133, 1000 milliseconds |
| Duration and cadence | Immediate tick, then one tick each second through second 6 |
| Raw tick | `floor(current maximum health * 0.05)` |
| Nominal raw total | Seven ticks, 35 percent maximum health |
| Health basis | Current maximum health recalculated for every tick |
| Healing resolution | Native healing-taken and HoT modifiers, dampening, absorption, and overheal |
| Critical healing | Disabled |
| Proc behavior | Aura type 20 does not dispatch ordinary healing procs |
| Stealth | Castable without removing stealth |
| Combat | Usable in and out of combat |
| Dispel | Non-dispellable |
| Stacking | One aura; a forced cooldown reset and recast refreshes it |
| Persistence | Aura marked non-save and removed by death |

## Runtime flow

```text
Rogue successfully casts Crimson Vial 901083 on self
  -> consume 20 Energy
  -> start the one-second Rogue GCD and 45-second cooldown
  -> apply one six-second SPELL_AURA_OBS_MOD_HEALTH aura
  -> SPELL_ATTR5_EXTRA_INITIAL_PERIOD performs the first 5 percent tick
  -> seconds 1 through 6 each recalculate 5 percent of current maximum health
  -> native healing modifiers, dampening, absorbs, and overheal resolve each tick
  -> aura expires after the seventh healing event
```

The spell is data-only. Aura type 20 already implements current-maximum-health percentage healing in the deployment core, and the immediate-period attribute adds the initial event without a helper spell or C++ script. Periodic haste is not enabled, so the seven-event schedule remains fixed.

## Database and client contract

The automatic world update collision-checks 901083 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs the complete spell row, non-save metadata, and backend name. The icon is derived from stock Major Healing Potion 17534 with zero as the offline fallback. No script binding, proc row, rank chain, spell group, linked spell, bonus data, scaling row, or acquisition row is installed.

The matching client row must preserve the Energy cost, cooldown, duration, stealth attribute, non-critical attribute, immediate-period attribute, aura type, one-second amplitude, Rogue family, text, and icon. Live server tables and the deployed client remain pending collision checks.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Cast with 19 Energy | Cast fails with no cooldown, aura, or healing | Not run |
| Cast with exactly 20 Energy | Cast succeeds and consumes exactly 20 Energy | Not run |
| Cast below full health | Healing occurs at application and seconds 1 through 6 | Not run |
| Baseline total | Seven raw ticks of `floor(current maximum health * 0.05)` | Not run |
| Maximum health changes during aura | Later ticks use the new maximum health | Not run |
| Cast from stealth | Cast succeeds and stealth remains | Not run |
| Take damage during aura | Aura and remaining ticks continue | Not run |
| Recast before 45 seconds | Native cooldown rejects the cast | Not run |
| Forced cooldown reset and recast | Existing aura refreshes rather than stacking | Not run |
| Mortal Strike, dampening, or healing absorb | Each affected tick resolves through normal healing reduction or absorption | Not run |
| Full health | Healing is recorded as overheal and is not banked | Not run |
| Critical-heal modifiers active | No tick critically heals | Not run |
| Death before final tick | Aura ends and no remaining ticks occur | Not run |
| Logout during aura | Aura does not resume after login | Not run |
| Human and playerbot Rogue | Identical mechanics after external acquisition and cast | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove 901083 from external acquisition, `spell_custom_attr`, `wotlk_spells`, and `spell_dbc`, then restore the previous client patch before restarting. No module C++ rebuild is required for this data-only spell.

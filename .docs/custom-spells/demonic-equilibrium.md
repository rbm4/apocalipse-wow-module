# Demonic Equilibrium

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_warlock_demonic_equilibrium.cpp`, `data/sql/db-world/2026_09_20_06_demonic_equilibrium.sql`, `data/sql/db-world/2026_09_22_00_spell_balance_adjustments.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-22

## Purpose

Demonic Equilibrium is a custom Warlock passive using spell ID 901033. While the passive and stock Soul Link aura 25228 are active, 50 percent of incoming damage is transferred to the controlled demon instead of Soul Link's stock 20 percent.

## Acquisition boundary

The module defines and consumes passive 901033 but does not grant it or modify talent data. The separate talent-data workflow must teach 901033. A matching client `Spell.dbc` row and talent presentation are required.

## Human and bot applicability

Humans and bot-controlled Warlocks use identical damage-transfer behavior while passive 901033 is active. Existing playerbot Soul Link casting remains unchanged. The combat path performs no database access.

## Spell graph

| Surface | Contract |
|---|---|
| Passive | 901033 Demonic Equilibrium |
| Soul Link activation | Stock spell 19028 |
| Soul Link split aura | Stock spell 25228, effect 0, `SPELL_AURA_SPLIT_DAMAGE_PCT` |
| Script | `spell_apoc_warlock_demonic_equilibrium` bound to 25228 |
| Registration | `AddModApocalipseWarlockDemonicEquilibriumScripts()` |
| Server migration | Baseline `data/sql/db-world/2026_09_20_06_demonic_equilibrium.sql` plus balance update `data/sql/db-world/2026_09_22_00_spell_balance_adjustments.sql` |
| Client presentation | Matching client `Spell.dbc` and separate talent data required |

## Runtime flow

```text
Warlock with active Soul Link takes damage
  -> core calculates stock effect 0 split amount
  -> Soul Link AuraScript checks passive aura 901033
  -> when present, replace the split amount with 50 percent of current incoming damage
  -> core caps the amount to remaining damage
  -> core removes the transferred amount from the Warlock
  -> core deals the transferred damage to the living Soul Link demon
```

The split hook checks the passive on every qualifying damage event. Learning or removing Demonic Equilibrium therefore takes effect without requiring Soul Link to be recast. Without passive 901033, the hook leaves the stock 20 percent split unchanged.

## Damage interactions

The implementation changes only the amount produced by Soul Link effect 0. It does not replace Soul Link activation, demon eligibility, range behavior, school filtering, immunity handling, combat logging, proc dispatch, or the core's final cap to the remaining incoming damage.

The 50 percent is calculated from the damage visible to Soul Link at its normal place in `Unit::CalcAbsorbResist`. Earlier absorb, resistance, and split processing continues to affect that input according to core ordering.

## Server spell contract

The baseline automatic world update defines 901033 as an infinite passive Warlock dummy aura using Soul Link's icon and Shadow school. It collision-checks `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`, binds the AuraScript to stock split aura 25228, and synchronizes the backend spell name. The follow-up balance migration updates the spell and aura descriptions to 50 percent.

The migration does not create talent acquisition data or a deployed client patch.

## Deployment and rollback

Before deployment, verify 901033 is free in live `spell_dbc`, `wotlk_spells_full`, `wotlk_spells`, and the selected client `Spell.dbc`. Apply the automatic updater through normal worldserver startup, deploy matching client and talent data, and restart worldserver so spell definitions and script bindings load.

Rollback must remove the exact script binding, module-owned 901033 rows, acquisition references, and matching client data together, then rebuild without the registration call. Stock Soul Link then remains at 20 percent.

## Verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Soul Link active without passive 901033 | Stock 20 percent transfer remains | Not run |
| Soul Link and passive 901033 active with a living controlled demon | 50 percent of eligible incoming damage transfers to the demon | Not run |
| Passive learned while Soul Link is already active | The next qualifying hit uses 50 percent without a Soul Link recast | Not run |
| Passive removed while Soul Link remains active | The next qualifying hit returns to stock 20 percent | Not run |
| Soul Link demon is absent, dead, or invalid | Existing core Soul Link guards prevent transfer | Not run |
| Incoming damage is smaller than rounding boundaries | Core integer percentage and cap behavior remains stable | Not run |
| Bot with passive 901033 uses Soul Link | Same behavior as a human | Not run |

## Known limitations

- A 50 percent transfer still places substantial incoming damage on the demon and requires in-game balance validation.
- The live database, deployed client data, startup validation, and in-game behavior remain unverified.

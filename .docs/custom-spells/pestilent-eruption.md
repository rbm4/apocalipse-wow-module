# Pestilent Eruption

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_death_knight_pestilent_eruption.cpp`, `data/sql/db-world/2026_09_21_07_death_knight_pestilent_eruption.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-21

## Purpose

Pestilent Eruption is Unholy Death Knight passive 901058. A successful hostile hit by any Death Coil or Scourge Strike rank immediately triggers internal Pestilence carrier 901059 on that target without rune, global-cooldown, cast-time, or cooldown costs. The carrier uses Death Coil's 30-yard range and the existing core `spell_dk_pestilence` script.

## Acquisition and applicability

The automatic world update adds passive 901058 to `mod_spec_spells` for Death Knight class 6, Unholy tree index 2. Spec Manager grants and revokes it through its existing reconciliation flow. Humans and playerbots use identical mechanics, and no new cast action or playerbot strategy is required.

## Spell graph

| Spell | Contract |
|---|---|
| 901058 Pestilent Eruption | Permanent Shadow dummy aura learned by the Death Knight |
| 901059 Pestilent Eruption Pestilence | Internal triggered clone of stock Pestilence targeting and effects, with Death Coil's 30-yard range and the existing `spell_dk_pestilence` binding |
| 50842 Pestilence | Stock source contract for carrier data and the core disease-spread script |

The script is additively bound to the complete rank chains rooted at Death Coil 47541 and Scourge Strike 55090. It runs only after a successful hostile source hit while the caster still has passive 901058. Friendly Death Coil healing, misses, immune results, invalid targets, and source spells cast without the passive do not trigger Pestilence.

## Native Pestilence reuse

The triggered carrier executes the existing `spell_dk_pestilence` script rather than reproducing disease logic. The selected enemy remains Pestilence's primary source target. Blood Plague and Frost Fever owned by the Death Knight spread from that target to normal Pestilence area targets. When Glyph of Disease is active, the primary target receives the stock disease refresh behavior, including Ebon Plague or Crypt Fever and Icy Talons handling.

The triggered cast is free because it uses the core triggered-cast path. Carrier 901059 reproduces stock 50842's three effects, area radius, family mask, visual, and target selectors but replaces its melee range with Death Coil's 30-yard range so ranged Death Coil hits remain eligible. The stock script continues to own disease ownership and Glyph of Disease behavior. The carrier is not bound to the source hook and cannot recursively trigger the passive.

## Runtime flow

```text
Unholy Death Knight has passive 901058
  -> Death Coil or Scourge Strike completes a successful hostile hit
  -> source-chain script retrieves passive effect 0
  -> Death Knight triggers long-range carrier 901059 on that hit target for free
  -> existing spell_dk_pestilence handles primary refresh and disease spread
```

Death Coil's internal damage helper 47632 and Scourge Strike's Shadow helper 70890 are not bound, preventing duplicate triggers. The path performs no combat-time database access and stores no custom runtime state.

## Data and deployment

The guarded automatic world update collision-checks 901058 and 901059 across `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs the passive and carrier rows, additive negative rank-chain bindings for 47541 and 55090, the existing `spell_dk_pestilence` binding on 901059, Unholy Spec Manager acquisition, and backend names. The icon and visual are copied from Pestilence 50842 at migration time.

Matching client `Spell.dbc` rows are required for 901058 and 901059. Stock Pestilence remains unchanged. The server update, client patch, module rebuild, and specialization acquisition must ship together. Live server tables and the selected deployed client remain pending collision checks.

## Verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Any Scourge Strike rank hits a hostile target | Exactly one free Pestilence cast uses that target as its source | Not run |
| Any Death Coil rank damages a hostile target at up to 30 yards | Exactly one free Pestilence carrier cast uses that target as its source | Not run |
| Death Coil heals a friendly undead target | No Pestilence cast | Not run |
| Source misses, is immune, or has no valid hit target | No Pestilence cast | Not run |
| Primary target has owned diseases and nearby enemies exist | Stock Pestilence spreads Blood Plague and Frost Fever | Not run |
| Glyph of Disease is active | Stock primary-target disease refresh behavior runs | Not run |
| Source target has no owned diseases | Pestilence casts but spreads or refreshes nothing | Not run |
| Human and playerbot Unholy Death Knight | Mechanics are identical | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove 901058 from `mod_spec_spells`, remove both Pestilent Eruption source-chain bindings and the 901059 `spell_dk_pestilence` binding, remove both backend names and spell rows, and restore the previous client patch. Rebuild without the source and loader registration before restarting.

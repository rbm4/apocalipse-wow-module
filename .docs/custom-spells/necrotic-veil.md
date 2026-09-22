# Necrotic Veil

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_death_knight_necrotic_veil.cpp`, `data/sql/db-world/2026_09_21_07_death_knight_necrotic_veil.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-21

## Purpose

Necrotic Veil is Unholy Death Knight passive 901056. Every positive damage event dealt directly by its owner contributes 10 percent of that post-mitigation event damage to helper aura 901057. The helper absorbs only magic damage, is capped at 35 percent of current maximum health when a contribution is processed, and lasts 60 seconds from the most recent positive contribution.

## Acquisition and applicability

The automatic world update adds passive 901056 to `mod_spec_spells` for Death Knight class 6, Unholy tree index 2. Spec Manager grants and revokes it through its existing reconciliation flow. Helper 901057 is internal and must never be taught directly. Humans and playerbots use identical mechanics, and no active cast or playerbot strategy is required.

## Spell graph

| Spell | Contract |
|---|---|
| 901056 Necrotic Veil | Permanent Shadow dummy aura with all direct and periodic damage proc metadata |
| 901057 Necrotic Veil | Non-saved 60-second Shadow helper with a school-absorb mask of 126, covering Holy, Fire, Nature, Frost, Shadow, and Arcane but excluding Physical |

The proc requires the event actor to be the Death Knight. Pet and guardian damage therefore does not contribute. Zero damage, misses, full prevention, healing, environmental damage, and the Death Knight damaging itself do not contribute. Triggered damage can contribute when it produces a normal damage proc event, but the absorb helper cannot recurse because it deals no damage.

## Accumulation formula

For each accepted event:

```text
contribution = floor(post-mitigation event damage * 0.10)
cap = floor(current maximum health * 0.35)
new remaining absorb = min(cap, remaining absorb + contribution)
```

A contribution that rounds to zero does nothing and does not refresh duration. A positive contribution creates the helper when absent or updates its remaining absorb when present, then refreshes the full 60-second duration. Damage already absorbed is not restored except through later contributions. If maximum health changes, the cap is reevaluated on the next contribution; the existing amount is not resized immediately.

The source event has already passed Spell Scaling, ordinary damage modifiers, mitigation, and module PvP balancing before `DamageInfo::GetDamage()` is read. Necrotic Veil therefore does not add another damage-scaling pass and has no `mod_spell_scaling` row.

## Runtime flow

```text
Unholy Death Knight has passive 901056
  -> owner directly deals positive damage
  -> snapshot 10 percent of post-mitigation event damage
  -> compute 35 percent of current maximum health
  -> helper absent: create 901057 with the bounded contribution
  -> helper present: add to its remaining absorb and clamp to the cap
  -> refresh helper duration to 60 seconds
  -> only non-Physical damage can consume the helper
```

The path is constant-time, stores state in the aura effect amount, and performs no combat-time database access.

## Data and deployment

The guarded automatic world update collision-checks 901056 and 901057 across `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs both server spell rows, broad damage proc metadata, the passive script binding, the helper non-save marker, Unholy Spec Manager acquisition, and backend names. Duration index 3 must resolve to 60000 milliseconds. The icon is copied from Anti-Magic Shell 48707 with icon 201 as a fallback.

Matching client `Spell.dbc` rows are required for both IDs. The server update, client patch, module rebuild, and specialization acquisition must ship together. Live server tables and the selected deployed client remain pending collision checks.

## Verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Direct melee, spell, or periodic damage is dealt | Adds floor(10 percent of final event damage) | Not run |
| Triggered damage emits a valid damage proc event | Contributes once for that event | Not run |
| Pet or guardian deals damage | No contribution | Not run |
| Miss, immune, full prevention, healing, or zero damage | No contribution and no duration refresh | Not run |
| Several events occur before expiration | Remaining absorb accumulates and duration refreshes to 60 seconds | Not run |
| Accumulation reaches 35 percent maximum health | Further contributions cannot exceed the current cap | Not run |
| Physical damage is taken | Helper is not consumed | Not run |
| Holy, Fire, Nature, Frost, Shadow, or Arcane damage is taken | Helper absorbs up to its remaining amount | Not run |
| Human and playerbot Unholy Death Knight | Mechanics are identical | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove 901056 from `mod_spec_spells` and `spell_proc`, remove the passive script binding, remove 901057 from `spell_custom_attr`, remove both backend names and spell rows, and restore the previous client patch. Rebuild without the source and loader registration before restarting.

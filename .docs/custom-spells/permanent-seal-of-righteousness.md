# Permanent Seal of Righteousness

Status: Implemented in source, build and runtime not verified

Owners: `src/mod_apocalipse_paladin_permanent_seal_of_righteousness.cpp`, `data/sql/db-world/2026_09_18_03_permanent_seal_of_righteousness.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-18

## Purpose

Permanent Seal of Righteousness is a visible Paladin passive that adds stock Seal of Righteousness damage while allowing the paladin's selected real seal to remain active. It is a pseudo-seal and is never classified as `SPELL_SPECIFIC_SEAL`.

## Acquisition boundary

The module defines passive 901016 but does not teach it or modify trainers, talents, specialization data, items, or playerbot acquisition. The separate acquisition owner must grant 901016 and provide matching client data.

## Human and bot applicability

Human and bot-controlled paladins use identical proc filtering, damage calculation, suppression, and Judgements of the Just behavior. The script performs no bot detection and no database work in combat. Existing playerbot combat actions need no changes because the passive reacts automatically.

## Spell graph

| Spell | Role | Contract |
|---:|---|---|
| 901016 | Permanent Seal of Righteousness | Visible permanent self dummy aura with explicit melee and judgement proc metadata, zero seal family flags, and no judgement state |
| Existing SoR aura ranks | Existing Seal of Righteousness | Any active Paladin dummy aura with the SoR family bit suppresses 901016 to prevent duplicate SoR damage |
| 25742 | Existing SoR damage | Receives the stock AP, Holy spell-power, target Holy vulnerability, libram, and weapon-speed calculation |
| 68055 | Existing Judgements of the Just effect | Remains owned by the stock judgement path; its talent marker makes 901016 trigger a second 25742 hit from judgement damage |

## Runtime flow

```text
qualifying damage event while passive 901016 is active
  -> require the aura owner as actor, positive damage, and a living target
  -> reject 25742 recursion and any real Seal of Righteousness aura
  -> accept melee auto-attacks, melee-damage-class abilities, and paladin judgement damage
  -> calculate max(0, (0.022 * AP + 0.044 * Holy power) * base weapon speed)
  -> trigger damage spell 25742 on the proc target
  -> trigger a second 25742 only for judgement damage with Judgements of the Just
```

Holy power includes the caster's Holy spell damage, the target's Holy damage bonus taken, and Libram of Divine Purpose effect 2025 when present. Integer conversion and clamping match the deployment core's stock `spell_pal_seal_of_righteousness` implementation.

## Seal isolation and proc contract

Spell 901016 retains `SPELLFAMILY_PALADIN` for class ownership and the standard SoR icon, but all three top-level family masks are zero. It therefore does not match the seal masks used by `SpellInfo::GetSpellSpecific`, does not enter per-caster seal exclusivity, does not grant `AURA_STATE_JUDGEMENT`, and is not selected by the stock judgement aura scan.

The `spell_proc` row selects successful damage hit events from melee auto-attacks, melee-damage-class spells, and magic-damage-class spells. The AuraScript narrows magic events to the paladin judgement family bit. The engine-level triggered-event gate is open so triggered judgement damage can qualify. The AuraScript still rejects aura-triggered non-judgement damage exactly like stock SoR, and it explicitly rejects its own 25742 result to prevent recursion.

Real SoR normally suppresses this overlay. The only exception is a judgement-family damage event resolving while Divine Toll impact marker 901025 is active. That bounded event allows the overlay beside real SoR, and the Divine Toll damage script reduces each resulting 25742 hit to 50 percent. Ordinary attacks and Judgements retain the suppression contract.

## Database and client contract

The automatic world update:

1. Collision-checks 901016 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`.
2. Inserts only a missing row and recognizes only its expected passive, proc, family, target, and aura signature as module-owned.
3. Installs the exact script binding and explicit `spell_proc` metadata.
4. Synchronizes the backend spell-name cache used by the client export workflow.

A matching client `Spell.dbc` row is required for the visible passive name, description, and icon. Repository search found no module allocation for 901016, but live world tables and the selected deployment client remain pending collision checks.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Passive 901016 with no real seal | Qualifying melee and judgement events trigger 25742 | Not run |
| Passive 901016 with Seal of Command, Vengeance, Corruption, Light, Wisdom, or Justice | The selected seal remains active and its normal behavior coexists with one overlay SoR hit | Not run |
| Passive 901016 with any real Seal of Righteousness rank | Overlay damage is fully suppressed outside Divine Toll impacts | Not run |
| Divine Toll marker 901025 with passive 901016 and real SoR | Real SoR and overlay SoR both fire, including JotJ double hits, and each result is halved | Not run |
| Judgement without Judgements of the Just | One overlay 25742 hit occurs after the selected seal's judgement | Not run |
| Judgement with Judgements of the Just | Two overlay 25742 hits occur, matching stock SoR behavior | Not run |
| Divine Storm or Hammer of the Righteous | Their eligible melee damage events trigger the overlay according to stock proc rules | Not run |
| Damage spell 25742 resolves | It never recursively triggers another overlay hit | Not run |
| Human and playerbot paladin | Identical behavior while passive 901016 is active | Not run |

## Rollback

Stop worldserver, take the normal world-database backup, remove the exact 901016 script and proc rows, remove 901016 from `wotlk_spells` and `spell_dbc`, restore the previous client patch, rebuild without the source and loader registration, then restart. Acquisition data is external and must be rolled back by its owner.

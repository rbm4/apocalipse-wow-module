# Permanent Paladin seals

Status: Implemented in source and server data, build and runtime not verified

Owners: `src/mod_apocalipse_paladin_permanent_seal_of_righteousness.cpp`, `data/sql/db-world/2026_09_18_03_permanent_seal_of_righteousness.sql`, `data/sql/db-world/2026_09_22_01_permanent_paladin_seals.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-22

## Purpose

Permanent Seal of Righteousness and Permanent Seal of Vengeance are visible Paladin passives intended as the Holy and Protection acquisition options, respectively. Each adds the matching stock seal effects while allowing a normal selected seal to remain active. Both are pseudo-seals and are never classified as `SPELL_SPECIFIC_SEAL`.

Divine Toll remains a Retribution option and is not granted or restricted here.

## Acquisition boundary

The module defines acquisition-facing unranked passives 901016 and 901060. It does not teach them or modify talents, trainers, specialization data, items, or playerbot acquisition. The separate acquisition owner must reference 901016 for Holy and 901060 for Protection directly. Neither spell is part of a rank chain.

## Spell graph

| Spell | Role | Contract |
|---:|---|---|
| 901016 | Permanent Seal of Righteousness | Permanent pseudo-seal that reuses stock SoR damage calculation and spell 25742 |
| 901060 | Permanent Seal of Vengeance | Permanent pseudo-seal that reuses Holy Vengeance 31803 and weapon-damage effect 42463 |
| 25742 | Seal of Righteousness damage | Existing AP, Holy spell-power, target vulnerability, libram, and weapon-speed damage |
| 31803 | Holy Vengeance | Existing same-caster periodic aura with its normal five-stack cap |
| 42463 | Seal of Vengeance damage | Existing weapon-percent Holy damage scaled from the current Holy Vengeance stack count |

Seal of Corruption 53736, Blood Corruption 53742, and damage spell 53739 are intentionally excluded. The deployment targets 3.3.5a, and this feature defines only the Alliance Seal of Vengeance path even though the custom core contains faction-paired Corruption support.

## Permanent Seal of Righteousness

A qualifying melee auto-attack, melee-damage-class ability, or Paladin judgement damage event calculates `max(0, (0.022 * AP + 0.044 * Holy power) * base weapon speed)` and triggers 25742. Judgement damage with Judgements of the Just triggers the overlay twice. The script rejects its own 25742 output and aura-triggered non-judgement damage to prevent recursion.

The overlay no longer suppresses itself when a real Seal of Righteousness is active. The real seal and passive each proc independently, including each path's Judgements of the Just second hit. Divine Toll's impact marker applies its normal damage multiplier to every resulting 25742 hit.

## Permanent Seal of Vengeance

The passive mirrors the deployment core's `spell_pal_seal_of_vengeance_aura` ordering and filters. On a qualifying proc it first reads the caster's existing Holy Vengeance stack count and triggers 42463 at 6.6 percent weapon damage per stack, up to 33 percent at five stacks. It then applies one 31803 stack only for melee auto-attacks or Hammer of the Righteous.

Seal damage cannot recursively proc the passive. Paladin judgement damage qualifies only with Judgements of the Just, matching the stock script. A judgement proc can deal the stack-scaled 42463 hit but does not add a Holy Vengeance stack.

When real Seal of Vengeance and passive 901060 are active together, both proc handlers run. They share the same caster-owned 31803 aura, so eligible attacks can add two stacks until the normal five-stack cap, and both handlers can produce their own 42463 hit from the stack state visible when each handler executes. The effect is intentionally additive rather than suppressed.

## Isolation and lifecycle

Both passives retain `SPELLFAMILY_PALADIN` but have zero family masks. They do not enter real seal exclusivity, grant judgement aura state, or become candidates in the stock judgement seal scan. Their infinite passive auras use no per-player heap state, delayed event, update hook, database query, or explicit logout cleanup. Normal aura removal, talent reset, or respec removal stops future procs immediately.

Humans and playerbot-controlled paladins use identical proc filtering and output. Existing bot seal and judgement actions need no changes because these passives react automatically. Acquisition remains external.

## Database and client contract

The baseline update owns 901016. Follow-up update `data/sql/db-world/2026_09_22_01_permanent_paladin_seals.sql`:

1. Reserves guarded repository ID 901060 and recognizes only the expected passive signature as module-owned.
2. Defines explicit melee proc metadata and the exact script binding for Permanent Seal of Vengeance.
3. Updates recognized 901016 descriptions to state same-seal additive behavior.
4. Synchronizes `wotlk_spells` for the backend browser and export workflow.

The backend exporter reads every `spell_dbc` override and appends a complete 234-field client record from the populated columns. Matching client `Spell.dbc` rows for 901016 and 901060 are required. Checked-in `Spell.dbc` evidence contained stock 31801 and no 901060 row. Live world tables and the selected deployed client remain pending collision checks.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| 901016 with a different real seal | One additional SoR path procs on eligible events | Not run |
| 901016 with real Seal of Righteousness | Both real and permanent SoR paths proc independently | Not run |
| Same-seal SoR judgement with Judgements of the Just | Each path produces its normal two 25742 hits | Not run |
| 901060 with a different real seal | Eligible attacks build Holy Vengeance and gain stack-scaled 42463 damage | Not run |
| 901060 with real Seal of Vengeance | Both paths proc, build the shared aura up to twice per eligible attack, and produce additive 42463 hits | Not run |
| 901060 judgement without Judgements of the Just | No permanent Vengeance judgement proc | Not run |
| 901060 judgement with Judgements of the Just | One stack-scaled permanent 42463 hit and no stack application from the judgement | Not run |
| Seal-generated damage resolves | Neither passive recursively procs itself | Not run |
| Passive is removed on reset or respec | Future overlay procs stop immediately | Not run |
| Human and playerbot paladin | Identical behavior while the corresponding passive is active | Not run |

## Rollback

Stop worldserver, take the normal world-database backup, remove the exact 901060 script and proc rows, remove 901060 from `wotlk_spells` and `spell_dbc`, restore the prior 901016 descriptions and client patch, rebuild without the source changes, and restart. Acquisition data is external and must be rolled back by its owner.

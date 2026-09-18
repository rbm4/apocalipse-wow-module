# Frozen Retaliation

Status: Implemented in source, build and runtime not verified

Owners: `src/mod_apocalipse_mage_frozen_retaliation.cpp`, `data/sql/db-world/2026_09_17_05_frozen_retaliation.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-17

## Purpose

Frozen Retaliation is a two-rank Frost Mage passive. Rank 1 has a 1.5 percent chance and rank 2 has a 3 percent chance whenever the aura owner takes positive combat damage to grant existing Fingers of Frost aura 44544.

## Acquisition boundary

The module defines both passive ranks, their rank chain, proc metadata, and runtime behavior. It does not teach either rank or modify talent data. Talent, trainer, item, specialization, and playerbot acquisition remain external. Matching client `Spell.dbc` rows and rank labels are required for 901012 and 901013.

## Human and bot applicability

Human and bot-controlled mages use identical proc and Fingers of Frost behavior. The script performs no bot detection and no database work in combat.

## Spell graph

| Rank | Spell | Proc chance | Result |
|---:|---:|---:|---|
| 1 | 901012 | 1.5 percent | Cast Fingers of Frost aura 44544 on the damaged mage |
| 2 | 901013 | 3 percent | Cast Fingers of Frost aura 44544 on the damaged mage |

Both rows are permanent self-targeted dummy auras. `spell_ranks` uses 901012 as `first_spell_id`, maps 901012 to rank 1, and maps 901013 to rank 2. The negative `spell_script_names` binding on -901012 applies the AuraScript to the complete chain.

## Runtime flow

```text
positive incoming combat damage
  -> PROC_FLAG_TAKEN_DAMAGE selects the active passive rank
  -> spell_proc rolls 1.5 percent for rank 1 or 3 percent for rank 2
  -> AuraScript confirms a player owner and positive DamageInfo
  -> cast existing Fingers of Frost aura 44544 on the owner
  -> the deployment core creates or refreshes indicator aura 74396 with four charges
```

## Damage and proc contract

`PROC_FLAG_TAKEN_DAMAGE` is source-agnostic within AzerothCore's combat proc pipeline. Melee, ranged, direct spell, and periodic damage can qualify. `PROC_ATTR_TRIGGERED_CAN_PROC` also permits damage from triggered spells. The metadata does not filter by attacker, school, spell family, damage class, or hit phase. Fully absorbed, resisted, immune, missed, and otherwise zero-damage events do not qualify.

The deployment core's separate `Player::EnvironmentalDamage` path does not dispatch this proc flag, so falling, fatigue, drowning, lava, and similar environmental events are outside this passive's contract. Rank chances are stored as floating-point values in `spell_proc`; the integer `spell_dbc.ProcChance` field is not used for the 1.5 percent rank.

## Fingers of Frost contract

The AuraScript casts existing aura 44544 rather than duplicating Fingers of Frost state. In the deployment core, applying 44544 creates indicator aura 74396 when absent or refreshes it and restores four charges when present. A successful Frozen Retaliation proc therefore follows the same frozen-target and charge-consumption path as normal Fingers of Frost.

## Database contract

The automatic world update:

1. Collision-checks 901012 and 901013 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`.
2. Inserts only missing rows and recognizes only their expected signatures as module-owned.
3. Rebuilds the two-row `spell_ranks` chain with explicit rank 1 and rank 2 mappings.
4. Adds independent `spell_proc` rows with 1.5 and 3 percent chances, `PROC_FLAG_TAKEN_DAMAGE`, and `PROC_ATTR_TRIGGERED_CAN_PROC`.
5. Binds the complete rank chain to `spell_apoc_mage_frozen_retaliation` and synchronizes backend names.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Rank 1 with melee, ranged, direct spell, and periodic damage | Each positive damage event has 1.5 percent proc eligibility | Not run |
| Rank 2 with the same sources | Each positive damage event has 3 percent proc eligibility | Not run |
| Fully absorbed, immune, resisted, or missed attack | No proc | Not run |
| Environmental damage | No proc through the deployment core's current environmental path | Not run |
| Existing Fingers of Frost indicator absent | Proc grants indicator 74396 with four charges | Not run |
| Existing Fingers of Frost indicator present | Proc refreshes duration and restores four charges | Not run |
| Rank upgrade from 901012 to 901013 | Rank chain replaces rank 1 and uses the 3 percent row | Not run |
| Human and playerbot mage | Identical mechanics while the matching rank is known | Not run |

## Rollback

Stop worldserver, take the normal world-database backup, remove 901012 and 901013 from `spell_proc`, remove the -901012 binding from `spell_script_names`, remove their `spell_ranks`, `wotlk_spells`, and `spell_dbc` rows, restore the previous client patch, rebuild without the registration and source, then restart. Acquisition data is external and must be rolled back by its owner if later added.

# Haunting Affliction

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_warlock_haunting_affliction.cpp`, `data/sql/db-world/2026_09_20_02_haunting_affliction.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-20

## Purpose

Haunting Affliction is an Affliction Warlock passive that lets a successful Haunt hit apply the caster's highest learned Curse of Agony, Corruption, and Unstable Affliction ranks once every 30 seconds.

## Acquisition boundary

The module defines passive 901028 and hidden cooldown marker 901029. It does not teach 901028 or modify talent, trainer, item, specialization, or playerbot acquisition data. The acquisition owner must reference exactly 901028 as an unranked passive and provide matching client data. Marker 901029 must never be granted directly. No checked-in acquisition reference exists, so acquisition validation remains pending.

## Human and bot applicability

Human and bot-controlled Warlocks use the same Haunt hook, rank resolution, curse protection, Seed protection, and caster-global cooldown. The script performs no bot detection and no database work in combat. Existing Affliction bot triggers already observe caster-owned DoTs, so no playerbot action or trigger change is required.

## Spell graph

| Spell | Role | Contract |
|---:|---|---|
| 48181 rank chain | Existing Haunt | A successful hit invokes the additive module script |
| 901028 | Haunting Affliction passive | Permanent self dummy aura and talent acquisition ID |
| 901029 | Haunting Affliction Cooldown | Non-saved 30-second self marker shared across all targets |
| 980 rank chain | Curse of Agony | Highest learned rank is applied unless the caster owns a different curse on the target |
| 172 rank chain | Corruption | Highest learned rank is applied unless the caster owns Seed of Corruption on the target |
| 30108 rank chain | Unstable Affliction | Highest learned rank is applied with normal refresh and dispel behavior |

## Runtime flow

```text
successful Haunt hit by a player with passive 901028
  -> reject while caster has marker 901029
  -> apply marker 901029 to the caster for 30 seconds
  -> resolve each DoT from the caster's active known spells
  -> apply Curse of Agony only when no different caster-owned Warlock curse exists
  -> apply Corruption only when no caster-owned Seed of Corruption exists
  -> apply Unstable Affliction
```

The cooldown is global per caster, not per target. It starts before any DoT cast and remains active even when one or more spells are unknown or skipped by an exclusivity guard. Existing same-caster DoTs are refreshed through their normal spell casts.

## Exclusivity and rank contract

Curse detection scans only applied Warlock-family curse auras owned by the Haunt caster. A same-caster Curse of Elements, Doom, Weakness, Exhaustion, or another different curse suppresses only Curse of Agony. Curses from other casters do not suppress it.

Seed of Corruption is checked through rank chain 27243 and only for the Haunt caster. When found, only Corruption is skipped. Unstable Affliction and eligible Curse of Agony still apply.

Each application walks the registered `spell_ranks` chain and chooses the highest rank known in the player's active specialization. Hard-coded level-80 ranks are intentionally not used.

## Database and client contract

The automatic world update:

1. Collision-checks 901028 and 901029 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`.
2. Installs the permanent passive and 30-second marker rows.
3. Binds `spell_apoc_warlock_haunting_affliction` to negative spell ID `-48181`, covering every Haunt rank while preserving the existing core Haunt scripts.
4. Marks 901029 with the non-save custom attribute.
5. Synchronizes both backend name-cache rows.

Matching client `Spell.dbc` rows are required. Only 901028 is acquisition-facing. Marker 901029 is implementation-only even though it requires server and client spell data.

## Performance

Each eligible Haunt hit performs bounded aura and rank-chain scans. The target aura scan occurs at most once per successful trigger after the 30-second marker gate. There are no database queries, map scans, timers, or per-tick updates.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Warlock without passive 901028 lands Haunt | No additional DoT and no marker | Not run |
| Warlock with passive lands Haunt while marker is absent | Marker starts and each known eligible DoT is applied | Not run |
| Warlock lands Haunt during the 30-second marker | No DoT is applied or refreshed by the talent | Not run |
| Low-level Warlock knows only lower DoT ranks | Highest actually known ranks are used | Not run |
| Target has a different same-caster curse | Curse of Agony is skipped; Corruption and Unstable Affliction continue | Not run |
| Target has same-caster Seed of Corruption | Corruption is skipped; eligible Curse of Agony and Unstable Affliction continue | Not run |
| Target already has the same-caster DoTs | Normal casts refresh each eligible aura | Not run |
| Human and playerbot Warlock | Identical mechanics and caster ownership | Not run |
| Logout during the marker | Marker is not restored after login | Not run |

## Rollback

Stop worldserver, take the normal world-database backup, remove the exact `-48181` module binding, remove 901029 from `spell_custom_attr`, remove both custom IDs from `wotlk_spells` and `spell_dbc`, restore the previous client patch, rebuild without the registration and source, then restart. Acquisition data for 901028 is external and must be rolled back by its owner.

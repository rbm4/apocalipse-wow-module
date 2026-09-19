# Paladin Vengeance variants

Status: Implemented in data, runtime not verified

## Purpose

Guardian's Vengeance and Sacred Vengeance provide Protection and Holy paladins with critical-event stacking talents modeled on classic Vengeance. Both variants use native `spell_proc` and aura stacking without C++.

## Acquisition boundary

The module defines acquisition-facing passives 901018 and 901020. It does not teach them or modify talents, trainers, specialization data, items, or playerbot acquisition. The separate acquisition owner must grant Guardian's Vengeance 901018 to the Protection talent and Sacred Vengeance 901020 to the Holy talent. Internal buffs 901019 and 901021 must never be learned directly.

## Spell graph

| Spell | Role | Contract |
|---:|---|---|
| 901018 | Guardian's Vengeance | Permanent passive proc talent for melee and damaging-spell critical hits |
| 901019 | Guardian's Resolve | Eight-second self buff, capped at three stacks |
| 901020 | Sacred Vengeance | Permanent passive proc talent for direct and periodic healing critical hits |
| 901021 | Sacred Fervor | Eight-second self buff, capped at three stacks |

## Protection behavior

`spell_proc` accepts critical damage events from melee auto-attacks, melee abilities, ranged-damage-class spells, none-damage-class negative spells, magic-damage-class negative spells, and periodic damage. Triggered events may qualify. Each event casts 901019 on the paladin. Recasting adds one stack, refreshes the whole aura to eight seconds, and stops at three stacks.

Each Guardian's Resolve stack applies `SPELL_AURA_MOD_DAMAGE_PERCENT_TAKEN` at -1 percent with school mask 127 and `SPELL_AURA_MOD_RATING` at 10 with rating mask 2. At three stacks this is 3 percent less damage taken from all schools and 30 flat defense rating. It does not multiply existing defense rating.

## Holy behavior

`spell_proc` accepts critical direct or periodic healing events, including eligible triggered healing. Each event casts 901021 on the paladin. Recasting adds one stack, refreshes the whole aura to eight seconds, and stops at three stacks.

Each Sacred Fervor stack applies `SPELL_AURA_MOD_HEALING_DONE_PERCENT` at 2 percent and `SPELL_AURA_MOD_POWER_REGEN` at 10 for `POWER_MANA`. At three stacks this is 6 percent increased healing done and 30 mana per 5 seconds.

Beacon copy spells 53652, 53653, and 53654 have `SPELL_ATTR2_CANT_CRIT`. A critical source heal grants one stack, while its non-critical Beacon copy grants none. Overheal-only critical events are not excluded by the proc metadata.

## Persistence and applicability

The passive talents use infinite-duration passive auras. The timed buffs are marked non-save, so they are not restored from `character_aura` after logout. Humans and playerbot-controlled paladins use the same core proc and aura paths, with no AI changes or database access in combat.

## Database and client contract

The automatic update `data/sql/db-world/2026_09_18_04_paladin_vengeance_variants.sql`:

1. Collision-checks 901018 through 901021 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`.
2. Inserts only missing rows and recognizes only their expected signatures as module-owned.
3. Installs exact critical-event `spell_proc` rows for the acquisition-facing passives.
4. Marks both timed buffs non-save through `spell_custom_attr`.
5. Synchronizes backend spell names in `wotlk_spells`.

Four matching client `Spell.dbc` rows are required. Repository search and the checked-in backend `Spell.dbc` and `SpellExtracted.dbc` files found no pre-existing 901018 through 901021 rows when this feature was implemented. Live world tables and the selected deployed client remain pending collision checks.

## Verification scenarios

| Scenario | Expected result | Status |
|---|---|---|
| Protection melee auto-attack crit | Adds or refreshes one Guardian's Resolve stack | Not run |
| Protection direct or periodic damaging-spell crit | Adds or refreshes one Guardian's Resolve stack | Not run |
| Non-critical Protection damage | Adds no stack | Not run |
| Guardian's Resolve reaches three stacks | Applies 3 percent all-school damage reduction and 30 defense rating | Not run |
| Holy direct or periodic heal crit | Adds or refreshes one Sacred Fervor stack | Not run |
| Critical source heal with Beacon transfer | Adds one stack from the source and none from the copy | Not run |
| Overheal-only critical heal | Can add one stack | Not run |
| Sacred Fervor reaches three stacks | Applies 6 percent healing done and 30 mp5 | Not run |
| Eight seconds pass without another qualifying crit | The complete active buff expires | Not run |
| Human and playerbot paladin | Identical behavior while the corresponding passive is active | Not run |

## Rollback

Stop worldserver, take the normal world-database backup, remove the exact 901018 and 901020 `spell_proc` rows, remove 901019 and 901021 from `spell_custom_attr`, remove 901018 through 901021 from `wotlk_spells` and `spell_dbc`, restore the previous client patch, and restart. Acquisition data is external and must be rolled back by its owner.

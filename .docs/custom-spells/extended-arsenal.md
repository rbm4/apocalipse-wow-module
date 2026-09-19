# Extended Arsenal

Status: Implemented in data, runtime not verified

## Purpose

Extended Arsenal increases the maximum cast range and chain target count of Hammer of the Righteous and Avenger's Shield. Both ranks use native AzerothCore spell modifiers without C++.

## Acquisition boundary

The module defines acquisition-facing passive ranks 901022 and 901023. It does not teach them or modify talents, trainers, specialization data, items, or playerbot acquisition. The separate acquisition owner must grant rank 1 or rank 2 through the intended Protection talent flow and must not grant both ranks simultaneously.

## Spell graph

| Spell | Role | Range | Added targets |
|---:|---|---:|---:|
| 901022 | Extended Arsenal rank 1 | +3 yards | +1 |
| 901023 | Extended Arsenal rank 2 | +6 yards | +2 |

Both effects are `SPELL_AURA_ADD_FLAT_MODIFIER`. Effect 1 uses `SPELLMOD_RANGE` value 5. Effect 2 uses `SPELLMOD_JUMP_TARGETS` value 17. The two spells form one `spell_ranks` chain rooted at 901022, so the higher rank replaces the lower rank through normal rank handling.

## Affected spell mask

The checked-in deployment `Spell.dbc` and `SpellExtracted.dbc` establish the exact Paladin family layout:

- Avenger's Shield ranks use family mask word 1 bit `0x00004000`.
- Hammer of the Righteous 53595 uses family mask word 2 bit `0x00040000`.
- No other checked-in Paladin spell uses either selected bit except the Avenger's Shield rank chain and one NPC Avenger's Shield derivative.

Each modifier effect carries both bits in the same 96-bit class mask and uses `SpellClassSet = 10`. In the SQL schema, the A_1/A_2/A_3 columns form effect 1's three-word mask and B_1/B_2/B_3 form effect 2's mask. This differs from the preliminary analysis that placed Avenger's Shield in the third mask word; the migration follows the verified deployment assets.

## Core behavior

`SpellInfo::GetMaxRange` applies `SPELLMOD_RANGE` to the spell's maximum range. `Spell::SelectImplicitChainTargets` starts from the effect's `ChainTarget` value and applies `SPELLMOD_JUMP_TARGETS` before searching for secondary targets.

The checked-in deployment DBC rows confirm:

- Hammer of the Righteous 53595 has `EffectChainTargets_1 = 3`, no ignore-caster-modifiers attribute, and a 5-yard melee jump radius from its melee damage class.
- Every Avenger's Shield rank rooted at 31935 has `EffectChainTargets_1 = 3` and `EffectChainTargets_2 = 3`, no ignore-caster-modifiers attribute, and a 10-yard jump radius from its magic damage class.

The passive changes only the initial cast range and maximum number of chain targets. It does not change hop radius, target validity, line of sight, Hammer frontal restrictions, damage, daze, silence, or any per-target secondary behavior. Those remain owned by the base spells and core target selection.

## Persistence and applicability

Both ranks are infinite-duration passive auras. Humans and playerbot-controlled paladins use the same spell-modifier and chain-target paths, with no AI changes, scripts, proc metadata, or combat-time database access.

## Database and client contract

The automatic update `data/sql/db-world/2026_09_18_05_extended_arsenal.sql`:

1. Collision-checks 901022 and 901023 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`.
2. Inserts only missing rows and recognizes only their expected mechanical signatures as module-owned.
3. Defines the two native flat spell-modifier effects and their exact 96-bit Paladin family masks.
4. Installs the rank chain rooted at 901022.
5. Synchronizes backend names in `wotlk_spells`.

Two matching client `Spell.dbc` rows with rank labels are required. Repository search and both checked-in backend DBC bases found no pre-existing 901022 or 901023 row. Live world tables and the selected deployed client remain pending collision checks.

## Verification scenarios

| Scenario | Expected result | Status |
|---|---|---|
| Rank 1 Hammer cast at original range plus 3 yards | Cast is accepted | Not run |
| Rank 2 Hammer cast at original range plus 6 yards | Cast is accepted | Not run |
| Rank 1 Hammer with enough valid enemies | Hits up to four total targets within normal melee hop and frontal rules | Not run |
| Rank 2 Hammer with enough valid enemies | Hits up to five total targets within normal melee hop and frontal rules | Not run |
| Rank 1 Avenger's Shield at original range plus 3 yards | Cast is accepted | Not run |
| Rank 2 Avenger's Shield at original range plus 6 yards | Cast is accepted | Not run |
| Rank 1 Avenger's Shield with enough valid enemies | Hits up to four total targets within the normal magic hop radius | Not run |
| Rank 2 Avenger's Shield with enough valid enemies | Hits up to five total targets within the normal magic hop radius | Not run |
| Added Avenger's Shield targets | Each receives normal damage and rank-specific daze, silence, and secondary behavior | Not run |
| Unrelated Paladin abilities | Range and target count remain unchanged | Not run |
| Human and playerbot paladin | Identical behavior while the same rank is active | Not run |

## Rollback

Stop worldserver, take the normal world-database backup, remove the 901022 rank chain rows, remove 901022 and 901023 from `wotlk_spells` and `spell_dbc`, restore the previous client patch, and restart. Acquisition data is external and must be rolled back by its owner.

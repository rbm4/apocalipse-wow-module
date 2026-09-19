# 2026-09-18: Extended Arsenal

Status: Partial

## Intent

Implement a low-risk two-rank Protection passive that increases Hammer of the Righteous and Avenger's Shield range and chain target count through native AzerothCore spell modifiers.

## Scope

### Code and data

- `data/sql/db-world/2026_09_18_05_extended_arsenal.sql`: Added guarded spell definitions, a two-rank chain, and backend names for 901022 and 901023.
- C++ scripts: None. Native range and chain-target spell-modifier paths own the complete behavior.

### Documentation

- `.docs/custom-spells/extended-arsenal.md`: Added the owner contract, acquisition boundary, verified masks, mechanics, and runtime scenarios.
- Architecture, runtime flow, playerbots, operations, indexes, root README, and spell inventory: Added the data-only feature and two-rank graph.

## Contracts changed

- Hooks or registration: None.
- Human behavior: The acquired rank adds 3 or 6 yards and 1 or 2 chain targets to Hammer of the Righteous and Avenger's Shield.
- Bot behavior: Identical to humans with no playerbot AI change.
- Configuration: None.
- Database or migration: Added one automatic guarded world update.
- Custom spell/client data: Added passive ranks 901022 and 901023.
- Deployment or rollback: Requires updater execution, matching client rows, and separately owned talent acquisition data.

## Decisions

- Used `SPELL_AURA_ADD_FLAT_MODIFIER` with `SPELLMOD_RANGE` and `SPELLMOD_JUMP_TARGETS`, so no C++ script is required.
- Used IDs 901022 and 901023 after checked-in repository and DBC collision checks.
- Used Avenger's Shield family mask word 1 bit `0x00004000` and Hammer family mask word 2 bit `0x00040000` from the checked-in deployment DBC, correcting the preliminary third-word assumption.
- Preserved the base spells' normal jump radii, target restrictions, damage, daze, silence, and secondary behavior.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Core modifier contracts | Reviewed `SpellInfo::GetMaxRange`, `Spell::SelectImplicitChainTargets`, `AuraEffect::CalculateSpellMod`, and `SpellInfo::IsAffectedBySpellMod` | Passed |
| Base spell data | Parsed 53595 and all ranks rooted at 31935 from checked-in runtime-grade `Spell.dbc` and `SpellExtracted.dbc` | Passed; chain targets are 3 and neither spell ignores caster modifiers |
| Family-mask isolation | Enumerated checked-in Paladin spells using mask word 1 bit `0x00004000` and word 2 bit `0x00040000` | Passed; only the Avenger's Shield rank family, one NPC derivative, and Hammer use those bits |
| Checked-in client collision | Parsed both backend DBC bases for 901022 and 901023 | Passed; neither ID exists |
| Source and SQL review | Focused identifier, schema, link, amount, mask-layout, and diff checks plus independent read-only review | Passed |
| Custom-core build | Parent worldserver build | Not run because this environment is not suited for compilation |
| Database updater | Disposable development database | Not run because MySQL and a local AzerothCore database are unavailable |
| In-game behavior | Human and playerbot scenarios | Not run |

## Follow-up

- Collision-check 901022 and 901023 against live world tables and the selected deployed client.
- Export and deploy matching client `Spell.dbc` rows.
- Configure the separate talent owner to grant the correct Extended Arsenal rank.
- Run the documented Hammer of the Righteous, Avenger's Shield, unrelated-spell, human, and playerbot scenarios.

## References

- Custom spell: [`../custom-spells/extended-arsenal.md`](../custom-spells/extended-arsenal.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

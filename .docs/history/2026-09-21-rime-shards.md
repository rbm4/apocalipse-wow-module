# 2026-09-21: Rime Shards

Status: Partial

## Intent

Implement a Frost Death Knight passive that converts some Frost Strike and Howling Blast damage events into bounded target-centered Frost bursts.

## Scope

### Code and data

- `src/mod_apocalipse_death_knight_rime_shards.cpp`: added exact source filtering, damage-derived helper casts, ten-target selection, and diminishing per-target damage.
- `src/mod_apocalipse_loader.cpp`: registered both Rime Shards scripts.
- `data/sql/db-world/2026_09_21_06_death_knight_rime_shards.sql`: added guarded spells 901054 and 901055, proc metadata, bindings, zero bonus coefficients, Frost acquisition, and backend names.

### Documentation

- `.docs/custom-spells/rime-shards.md`: recorded mechanics, formula, data, deployment, bot behavior, and verification scenarios.
- Architecture, operations, playerbot, subsystem, history, and root indexes reference Rime Shards.

## Contracts changed

- Hooks or registration: `AddModApocalipseDeathKnightRimeShardsScripts()` now registers one AuraScript and one SpellScript.
- Human behavior: qualifying damage receives a 30 percent roll for a 20 percent damage-derived burst with diminishing AoE output.
- Bot behavior: identical to humans and requires no new AI action.
- Configuration: None.
- Database or migration: automatic guarded world update adds spells 901054 and 901055 and Frost Spec Manager acquisition.
- Custom spell/client data: matching client rows for both spells are required and acquisition references only 901054.
- Deployment or rollback: world update, module rebuild, client patch, and spec reconciliation are required.

## Decisions

- Allocated 901054 and 901055 because concurrent Death Knight work already reserves 901048 through 901053.
- Used one proc roll per successful source damage event, including each Howling Blast victim and the Frost Strike off-hand helper.
- Used `floor(base * (2N - 1) / N^2)` per target so two targets receive 75 percent each and ten targets remain capped at 190 percent aggregate helper output.
- Reused Howling Blast rank 4 visual and icon through migration-time lookup.
- Omitted a `mod_spell_scaling` row because the helper starts from already level-scaled source damage.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Repository spell-ID scan | Search module migrations for 901054 and 901055 before creation | Passed for current workspace sources; live server and deployed client remain pending |
| Custom-core API review | Checked proc flags, target selectors, rank-chain API, and custom spell casting against the deployment core | Passed by static inspection |
| Static source and migration review | Focused code, SQL, registration, and documentation inspection | Pending final diff review |
| Custom-core build | Parent worldserver build | Not run because the deployment core requires an opt-in build |
| Human and bot runtime scenarios | Matrix in `custom-spells/rime-shards.md` | Not run |
| Client patch validation | Exported and deployed `Spell.dbc` | Not run |

## Follow-up

- Build against the deployment custom core with this module and `mod-playerbots` enabled.
- Run the named single-target, multi-target, off-hand, human, and playerbot scenarios.
- Collision-check live server tables and selected deployment client before applying the update.
- Export matching client rows 901054 and 901055 and verify the Howling Blast visual at the target center.

## References

- Custom spell: [`../custom-spells/rime-shards.md`](../custom-spells/rime-shards.md)
- Architecture: [`../architecture/runtime-and-data-flow.md`](../architecture/runtime-and-data-flow.md)
- Commit or PR: Not created

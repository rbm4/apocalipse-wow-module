# 2026-09-21: Pestilent Eruption

Status: Partial

## Intent

Implement an Unholy Death Knight passive that makes successful Scourge Strike and offensive Death Coil hits trigger the complete stock Pestilence behavior for free.

## Scope

### Code and data

- `src/mod_apocalipse_death_knight_pestilent_eruption.cpp`: added passive-gated source-rank hooks and a triggered long-range Pestilence carrier cast.
- `src/mod_apocalipse_loader.cpp`: registered the Pestilent Eruption script.
- `data/sql/db-world/2026_09_21_07_death_knight_pestilent_eruption.sql`: added guarded passive 901058, internal carrier 901059, source-chain and core Pestilence bindings, Unholy acquisition, and backend names.

### Documentation

- `.docs/custom-spells/pestilent-eruption.md`: recorded source eligibility, stock Pestilence reuse, glyph behavior, deployment, bot behavior, and verification scenarios.
- Architecture, operations, playerbot, subsystem, feature, history, and root indexes reference Pestilent Eruption.

## Contracts changed

- Hooks or registration: `AddModApocalipseDeathKnightPestilentEruptionScripts()` registers one additive SpellScript on Death Coil and Scourge Strike rank chains.
- Human behavior: successful hostile source hits trigger carrier 901059 at no cost, using Death Coil's 30-yard range and the core Pestilence script.
- Bot behavior: identical to humans and requires no new AI action.
- Configuration: None.
- Database or migration: automatic guarded world update adds passive 901058, carrier 901059, and Unholy Spec Manager acquisition.
- Custom spell/client data: matching client rows are required for both IDs; stock Pestilence data remains unchanged.
- Deployment or rollback: world update, module rebuild, client patch, and spec reconciliation are required.

## Decisions

- Allocated 901058 and 901059 because concurrent Necrotic Veil work reserved 901056 and 901057 after Rime Shards 901054 and 901055.
- Added long-range carrier 901059 because stock Pestilence has melee range and would fail after a ranged Death Coil hit.
- Bound the existing core Pestilence script to the carrier so normal disease spread, Glyph of Disease refreshes, and disease ownership remain authoritative.
- Bound only parent Death Coil and Scourge Strike rank chains, excluding helpers 47632 and 70890 to prevent duplicate triggers.
- Treated the requested proc as deterministic on each successful hostile hit because no chance or cooldown was specified.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Repository spell-ID scan | Search module migrations and local deployment `Spell.dbc` for 901058 and 901059 | Passed for current workspace sources; live server and deployed client remain pending |
| DBC contract review | Compared stock 50842 effects and targeting and Death Coil range index 160 against carrier 901059 | Passed by read-only extraction |
| Custom-core behavior review | Checked Death Coil, Scourge Strike, Pestilence, Glyph of Disease, rank bindings, and triggered-cast paths | Passed by static inspection |
| Static source and migration review | Focused code, SQL, registration, and documentation inspection | Passed |
| Custom-core build | Parent worldserver build | Not run because repository rules require explicit build request |
| Human and bot runtime scenarios | Matrix in `custom-spells/pestilent-eruption.md` | Not run |
| Client patch validation | Exported and deployed `Spell.dbc` | Not run |

## Follow-up

- Build against the deployment custom core with this module and `mod-playerbots` enabled when explicitly requested.
- Run the named source-hit, disease-spread, glyph, friendly Death Coil, miss, human, and playerbot scenarios.
- Collision-check live server tables and selected deployment client before applying the update.
- Export and deploy matching client rows for 901058 and 901059.

## References

- Custom spell: [`../custom-spells/pestilent-eruption.md`](../custom-spells/pestilent-eruption.md)
- Architecture: [`../architecture/runtime-and-data-flow.md`](../architecture/runtime-and-data-flow.md)
- Commit or PR: Not created

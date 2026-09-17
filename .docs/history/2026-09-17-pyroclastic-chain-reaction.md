# 2026-09-17: Pyroclastic Chain Reaction

Status: Partial

## Intent

Add an isolated custom mage passive that lets Pyroblast interact with the caster's Living Bomb without mixing the new implementation into the existing Blazing Barrier source.

## Scope

### Code and data

- `src/mod_apocalipse_mage_pyroclastic_chain_reaction.cpp`: Added passive-gated Pyroblast proc handling, source Living Bomb refresh, matching-rank explosion triggering, and bounded random spread.
- `src/mod_apocalipse_loader.cpp`: Registered the new mage spell owner independently after the Blazing Barrier scripts.
- `data/sql/db-world/2026_09_17_00_pyroclastic_chain_reaction.sql`: Added guarded passive spell 901003, all-rank Pyroblast and Living Bomb explosion script bindings, and backend spell name synchronization.

### Documentation

- `.docs/custom-spells/pyroclastic-chain-reaction.md`: Added the complete spell, acquisition, runtime, targeting, deployment, and verification contract.
- `.docs/architecture/overview.md`: Added the source owner, subsystem boundary, registration, flow, and custom-ID invariant.
- `.docs/architecture/runtime-and-data-flow.md`: Added combat composition, custom spell graph, and failure paths.
- `.docs/mod_apocalipse_loader.md`: Added the sixth registration call.
- `.docs/integrations/playerbots.md`: Recorded identical human and bot combat behavior.
- `.docs/development/operations.md`: Added updater, collision preflight, deployment, and runtime verification requirements.
- `README.md`, `.docs/README.md`, and `AGENTS.md`: Updated public, indexed, and always-on source maps.

## Contracts changed

- Hooks or registration: Added a Pyroblast effect 0 hook and Living Bomb explosion hit/cast hooks through `-11366` and `-44461` bindings, plus `AddModApocalipseMagePyroclasticChainReactionScripts()`.
- Human behavior: Mages with passive 901003 gain a 20 percent chance on qualifying Pyroblast hits to refresh and detonate their Living Bomb, then spread its rank to up to two random unbombed explosion-hit survivors.
- Bot behavior: Identical when the bot has learned passive 901003.
- Configuration: None.
- Database or migration: Added an automatic guarded world update for spell 901003 and two rank-chain script bindings.
- Custom spell/client data: Added server spell 901003. Matching client `Spell.dbc` and separate server/client talent acquisition data remain required.
- Deployment or rollback: Worldserver restart and updater execution are required. Rollback removes the custom passive and the two exact script bindings after normal database backup and server shutdown procedures.

## Decisions

- Kept Blazing Barrier source unchanged and placed the new spell in a dedicated source file.
- Stored the 20 percent chance in passive effect 0 so server behavior and tooltip data share one value.
- Required the Living Bomb to belong to the Pyroblast caster so one mage cannot refresh or spread another mage's bomb.
- Reused the source Living Bomb's aura and explosion IDs to preserve rank automatically.
- Marked only the special explosion as triggered by passive 901003 so ordinary expiration and dispel explosions cannot spread.
- Required zero-speed explosion ranks so completed hit collection occurs before the `AfterCast` spread step.
- Preserved the full explosion damage target list and collected spread candidates from completed hit callbacks before randomly selecting up to two after the cast.
- Left talent acquisition outside the script and migration contract as requested.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Patch whitespace | `git diff --check` | Passed after source, SQL, and documentation edits; line-ending conversion warnings remain for existing tracked files |
| Source and data review | Compared implementation with custom core Pyroblast rank 11366, Living Bomb ranks 44457/55359/55360, explosion ranks 44461/55361/55362, and stock Living Bomb removal script | Passed by static review |
| Independent script review | Reviewed hook validation, cast overloads, target ownership, rank bindings, and immediate versus delayed hit order | Passed after replacing the DBC-specific area hook; deployed explosion speed remains a runtime check |
| Loader reachability | Checked declaration and call in `Addapocalipse_wow_moduleScripts()` | Passed by static review |
| SQL execution | Apply module updater to a test `acore_world` | Not run; no database mutation was authorized |
| Custom-core build | Build `worldserver` with this module and `mod-playerbots` | Not run under the custom core instruction to skip builds unless explicitly requested |
| Client data | Export and inspect matching `Spell.dbc` and talent data | Not run; client artifacts are not present in this repository |
| In-game scenarios | Execute the custom-spell runtime matrix | Not run; no test worldserver session was available |

## Follow-up

- Build the exact deployment core with the module and `mod-playerbots` enabled when explicitly authorized.
- Apply the updater to a non-production test database and inspect spell 901003 plus both negative rank bindings.
- Add the server and client talent data that grants passive 901003.
- Export the matching client `Spell.dbc` row.
- Execute the runtime matrix for humans and bots.

## References

- Custom spell: [`../custom-spells/pyroclastic-chain-reaction.md`](../custom-spells/pyroclastic-chain-reaction.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

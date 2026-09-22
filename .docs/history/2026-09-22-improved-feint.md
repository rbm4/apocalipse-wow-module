# 2026-09-22: Improved Feint

Status: Partial

## Intent

Implement a permanent Rogue passive that adds six seconds of 30 percent all-school damage reduction after any successful Feint cast while preserving stock Feint behavior.

## Scope

### Code and data

- `src/mod_apocalipse_rogue_improved_feint.cpp`: Added rank-wide successful Feint cast handling and helper application.
- `src/mod_apocalipse_loader.cpp`: Registered the new subsystem.
- `data/sql/db-world/2026_09_22_09_improved_feint.sql`: Added guarded spells 901089 and 901090, the stock Feint rank-chain binding, non-save helper metadata, and backend names.

### Documentation

- `.docs/custom-spells/improved-feint.md`: Added the owner contract, damage composition, deployment requirements, and verification matrix.
- Architecture, subsystem, operation, playerbot, README, feature, and history indexes were updated for the new graph.

## Contracts changed

- Hooks or registration: Added `AddModApocalipseRogueImprovedFeintScripts()` and one `SpellScript` bound to stock Feint rank chain 1966.
- Human behavior: Any successful Feint rank cast while passive 901089 is active applies or refreshes six-second helper 901090.
- Bot behavior: Identical mechanics after external acquisition, with no new action or strategy.
- Configuration: None.
- Database or migration: Added one guarded automatic world update and no acquisition row.
- Custom spell/client data: Added 901089 and 901090; matching client rows remain required.

## Decisions

- The requested 30 percent is interpreted as damage reduction, so non-AoE damage uses factor 0.70.
- Stock Feint's 40 percent AoE reduction remains separate. Its factor 0.60 multiplies the helper's factor 0.70, producing factor 0.42 and 58 percent total AoE reduction.
- A rank-wide negative binding on first rank 1966 covers all eight stock Feint ranks without modifying their spell rows.
- Native `SPELL_AURA_MOD_DAMAGE_PERCENT_TAKEN` handles all seven schools and ordinary multiplier composition.
- The helper is non-dispellable, cannot be stolen, and is marked non-save.
- IDs 901089 and 901090 were selected after concurrent repository work reserved 901083 through 901088.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Static diff validation | `git diff --check` plus no-index checks for new files | Passed; line-ending conversion warnings only |
| Source and data consistency | Manual C++ and SQL graph review against the deployment core and backend exporter | Passed |
| Custom-core worldserver build | Exact custom core with this module and `mod-playerbots` | Not run because core rules require an explicit build request |
| Updater and startup | Worldserver automatic migration and script validation | Not run |
| Client data | Export and inspect matching `Spell.dbc` rows | Not run |
| Human and playerbot gameplay | Owner page verification matrix | Not run |

## Follow-up

- Run live server and deployed-client collision checks for 901089 and 901090.
- Grant only passive 901089 through the external acquisition flow.
- Build, run updater and startup validation, export the client patch, and execute the owner-page gameplay matrix.

## References

- Custom spell: [`../custom-spells/improved-feint.md`](../custom-spells/improved-feint.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

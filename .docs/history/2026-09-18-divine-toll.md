# 2026-09-18: Divine Toll

Status: Partial

## Intent

Implement the approved Divine Toll contract as a server-side Paladin active that sequences one through five controlled half-damage Judgement impacts without repeatedly casting the normal Judgement wrapper.

## Scope

### Code and data

- `src/mod_apocalipse_paladin_divine_toll.cpp`: Added cast validation, GUID-based sequencing, retargeting, active-seal selection, stack ordering, damage provenance, JotW gating, cooldown reset, and proc-preserving impact casts.
- `src/mod_apocalipse_paladin_permanent_seal_of_righteousness.cpp`: Added a marker-scoped Divine Toll exception to ordinary real-SoR suppression.
- `src/mod_apocalipse_loader.cpp`: Registered the Divine Toll subsystem after permanent SoR.
- `data/sql/db-world/2026_09_18_05_divine_toll.sql`: Added guarded spells 901024 through 901026, additive script bindings, non-save metadata, and backend names.

### Documentation

- `.docs/custom-spells/divine-toll.md`: Added the complete gameplay, spell graph, boundary, failure, and verification contract.
- Architecture, operations, playerbot, root README, documentation index, permanent SoR, and history pages were synchronized.

## Contracts changed

- Hooks or registration: Added parent SpellScript, stock-damage SpellScript, Judgements of the Wise AuraScript gate, and loader registration.
- Human behavior: Externally granted Divine Toll executes the approved random sequence and seal interactions.
- Bot behavior: Identical to humans; acquisition and cast-decision policy remain external.
- Configuration: None.
- Database or migration: Added one guarded automatic world update.
- Custom spell/client data: Added acquisition-facing 901024 and internal 901025 through 901026. External backend owns generated client data.
- Deployment or rollback: Requires updater execution, matching external client export, rebuild, and focused runtime verification.

## Decisions

- Used the active seal's effect 2 judgement spell instead of casting wrappers 20271, 53407, or 53408.
- Applied the 50 percent multiplier before mitigation because the deployment core has no module hook between resistance and absorbs.
- Used a transient impact marker to bound hit bonuses, half damage, real-SoR overlay coexistence, and one-per-sequence JotW state.
- Preserved normal Heart of the Crusader, JotJ, Righteous Vengeance, generic proc, Vengeance/Corruption stack, Blood/Martyr recoil, and Seal of Command cleave paths.
- Allocated 901024 through 901026 after concurrent Extended Arsenal work claimed 901022 and 901023.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Source and SQL whitespace | `git diff --check` | Passed after final source and documentation updates |
| Module ID collision scan | Repository search for 901024 through 901026 | Passed after moving away from Extended Arsenal IDs; live database not checked |
| Static source review | Focused review of stock Judgement, seal, proc, cooldown, and damage paths | Passed with runtime caveats documented |
| Custom core build | Worldserver build with module and playerbots | Not run because separate build authorization is required |
| Database updater | Start worldserver with module updater enabled | Not run |
| Client export | External backend workflow | Not run and outside this session's ownership |
| Human and playerbot scenarios | Matrix in current owner page | Not run |

## Follow-up

- Build the deployment worldserver after explicit authorization.
- Run updater and startup validation in a backed-up non-production environment.
- Export client data through the external backend.
- Execute every human and playerbot scenario in the Divine Toll owner page.

## References

- Custom spell: [`../custom-spells/divine-toll.md`](../custom-spells/divine-toll.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

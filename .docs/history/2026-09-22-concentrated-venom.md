# 2026-09-22: Concentrated Venom

Status: Partial

## Intent

Implement the Assassination Rogue passive that accelerates real Deadly Poison stacking while preserving native enchanted-weapon and five-stack opposite-weapon behavior.

## Scope

### Code and data

- `src/mod_apocalipse_rogue_concentrated_venom.cpp`: added successful weapon-poison qualification, highest equipped Deadly Poison selection, real weapon-attributed casting, and a per-target one-second throttle.
- `src/mod_apocalipse_loader.cpp`: registered the Rogue spell subsystem.
- `data/sql/db-world/2026_09_22_03_concentrated_venom.sql`: allocated passive 901061, added exact proc and script rows, assigned Assassination Spec Manager acquisition, and added the backend name.

### Documentation

- `.docs/custom-spells/concentrated-venom.md`: recorded the complete spell, failure, throttle, client, and verification contract.
- Root and engineering indexes, architecture, runtime flow, operations, subsystem catalog, and playerbot integration were updated for the new passive.

## Contracts changed

- Hooks or registration: Added `AddModApocalipseRogueConcentratedVenomScripts()` and a passive `AuraScript` proc hook.
- Human behavior: Assassination Rogues can gain one extra real Deadly Poison application per target per second at 30 percent chance after a successful equipped weapon-poison application.
- Bot behavior: Identical mechanics with no new AI action.
- Configuration: None.
- Database or migration: Added automatic world update `2026_09_22_03_concentrated_venom.sql` and Spec Manager row for class 4, spec index 0.
- Custom spell/client data: Added server spell 901061; matching client `Spell.dbc` data remains required.
- Deployment or rollback: Requires world update, rebuilt module, matching client patch, and the documented database rollback sequence.

## Decisions

- The highest applicable rank means the greatest native Deadly Poison rank currently present as a combat enchant on either equipped weapon and permitted by the Rogue's level.
- The extra application casts that native spell with the selected enchanted weapon so `spell_rog_deadly_poison` retains its existing five-stack opposite-weapon behavior.
- The one-second limit is aura-local and keyed by target instead of using the global aura proc cooldown.
- Miss, full resist, immune, dodge, parry, evade, deflect, reflect, and full-block results are excluded before the chance roll.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Source and SQL review | Compare implementation with deployment-core `spell_rog_deadly_poison`, proc pipeline, and weapon-enchant cast path | Passed |
| Custom core build | Build `worldserver` with the module and `mod-playerbots` enabled | Not run at history creation |
| Database updater startup | Start `worldserver` and inspect updater and script-binding logs | Not run |
| Human and bot poison scenarios | Run the feature verification matrix | Not run |
| Client spell export | Verify deployed client spell 901061 | Not run |

## Follow-up

- Build against the exact deployment core.
- Apply the automatic world update and matching client spell patch in an authorized environment.
- Run the focused human and playerbot scenarios in the owner page.

## References

- Custom spell: [`../custom-spells/concentrated-venom.md`](../custom-spells/concentrated-venom.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

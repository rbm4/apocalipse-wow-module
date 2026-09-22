# 2026-09-22: Pestilent Knives

Status: Partial

## Intent

Add an Assassination Rogue active for deliberate multi-target Deadly Poison setup while preserving stock poison ranks and full-stack behavior.

## Scope

### Code and data

- `src/mod_apocalipse_rogue_pestilent_knives.cpp`: adds bounded area targeting, main-hand Deadly Poison resolution, two poison applications, and the capped full-stack path.
- `src/mod_apocalipse_loader.cpp`: registers the new spell script.
- `data/sql/db-world/2026_09_22_03_rogue_pestilent_knives.sql`: defines spell 901069, binds the script, grants Assassination acquisition, and adds the backend name.

### Documentation

- `.docs/custom-spells/pestilent-knives.md`: records the complete spell and verification contract.
- Architecture, operations, subsystem, feature, playerbot, root README, and history indexes now include Pestilent Knives.

## Contracts changed

- Hooks or registration: `AddModApocalipseRoguePestilentKnivesScripts()` is called by the module loader.
- Human behavior: Assassination Rogues gain a 35-Energy, 20-second, ten-target active using 50 percent weapon damage and main-hand Deadly Poison.
- Bot behavior: Mechanics are identical after casting; active cast-decision policy remains external.
- Configuration: None.
- Database or migration: Automatic guarded world update adds 901069, its script and acquisition rows, and its backend name.
- Custom spell/client data: One matching client `Spell.dbc` row using Fan of Knives visual and icon is required.
- Deployment or rollback: Deploy the world update, rebuilt module, and client row atomically; rollback removes 901069 and the registration.

## Decisions

- Use 50 percent weapon damage as the concrete reduced-damage value.
- Invoke the real main-hand Deadly Poison combat spell with its enchanted item instead of synthesizing stacks.
- Cast once on targets already at five stacks and twice otherwise, preserving the normal four-to-five transition while limiting the opposite poison to one trigger per target.
- Allocate guarded ID 901069 after concurrent repository work claimed lower IDs.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Static source and data review | Inspect C++, loader, SQL guards, bindings, and documentation references | Passed |
| Parent custom-core build | Build `worldserver` with module and playerbots | Not run at documentation creation |
| World updater | Start worldserver with updates enabled | Not run; offline database policy |
| Client export | Export and inspect client `Spell.dbc` row 901069 | Not run |
| Human and bot runtime matrix | Scenarios in the current spell page | Not run |

## Follow-up

- Build against the deployment custom core.
- Apply the update through an authorized deployment, export the client row, and run the documented human and bot scenarios.
- Confirm live server and client collision checks before deployment.

## References

- Custom spell: [`../custom-spells/pestilent-knives.md`](../custom-spells/pestilent-knives.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

# 2026-09-24: Priest ability pack

Status: Partial

## Intent

Implement the approved 20-ability Priest pack without changing stock AzerothCore behavior for characters that do not acquire its custom spells.

## Scope

### Code and data

- `src/mod_apocalipse_priest_spells.cpp`: Added shared, Discipline, Holy, and Shadow runtime mechanics.
- `src/mod_apocalipse_loader.cpp`: Registered the Priest pack before Battleground Stamina.
- `data/sql/db-world/2026_09_24_01_priest_spell_pack.sql`: Allocated 901118 through 901154 and installed the server spell graph, proc data, bindings, coefficients, transient attributes, and backend names.

### Documentation

- `.docs/features/priest-ability-pack.md`: Added the current behavior and deployment contract.
- Architecture, runtime, playerbot, operations, feature, history, and root indexes were updated for the new subsystem.

## Contracts changed

- Hooks or registration: Added Priest spell, aura, `UnitScript`, and `PlayerScript` handlers through `AddModApocalipsePriestSpellScripts()`.
- Human behavior: Externally acquired pack spells now provide the approved mechanics.
- Bot behavior: Passive and cast mechanics are identical, but active cast decisions remain pending because Priest AI source is unavailable.
- Configuration: None.
- Database or migration: Added one automatic world update owning 37 rows.
- Custom spell/client data: Reserved 901118 through 901154. Matching client data remains required.
- Deployment or rollback: World update, client export, acquisition, startup, and runtime checks remain operator work.

## Decisions

- Acquisition is completely external and no `mod_spec_spells` rows are included.
- Rapid Penance changes the active ranked child channel amplitude so interruption cancels pending bolts.
- Radiance records the latest qualifying direct Holy amount and applies the Mind Blast coefficient to its custom primary helper.
- Copied Devouring Plague uses a separate periodic-leech aura, participates in Shadow effect counting, and does not store Devouring Echo damage.
- Void Eruption is a no-target same-map registry cast and has no separate nearby secondary wave.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Repository status before editing | `git status --short --branch` | Clean module repository, four local commits ahead |
| Static patch review | `git diff --check`, untracked-file checks, and focused searches | Passed |
| Custom-core build | Not run | Skipped under repository instruction |
| SQL updater | Not run | Offline-only policy |
| Human gameplay | Not run | Requires deployment |
| Playerbot gameplay | Not run | AI source and deployment unavailable |

## Follow-up

- Build against the exact deployment core when explicitly approved.
- Run the automatic world update and inspect startup script validation.
- Export and deploy matching client spell rows.
- Configure acquisition in its separately owned system.
- Provide the Priest playerbot AI source repository and add decisions for Inner Renewal, Archangel, Apotheosis, and Void Eruption.
- Run focused level-80 balance and mechanics scenarios.

## References

- Feature: [`../features/priest-ability-pack.md`](../features/priest-ability-pack.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

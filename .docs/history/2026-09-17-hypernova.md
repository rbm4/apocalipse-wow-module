# 2026-09-17: Hypernova

Status: Partial

## Intent

Add a target-centered Arcane Mage burst spell with Arcane Explosion presentation, four times Arcane Blast rank-4 damage and coefficient, a short vertical displacement, and an immediate four-stack Arcane Blast reward.

## Scope

### Code and data

- `src/mod_apocalipse_mage_hypernova.cpp`: implements visual placement and the four-stack reward.
- `src/mod_apocalipse_loader.cpp`: registers the Hypernova script while preserving existing registrations.
- `data/sql/db-world/2026_09_17_01_hypernova.sql`: defines spell 901005, its script binding, direct coefficient, and backend name.

### Documentation

- `.docs/custom-spells/hypernova.md`: records the current spell, scaling, movement, client, bot, and verification contracts.
- `.docs/architecture/overview.md`: adds the Hypernova component and registration boundary.
- `.docs/architecture/runtime-and-data-flow.md`: adds Hypernova's combat and custom-spell flow.
- `.docs/development/operations.md`: adds migration, deployment, preflight, and runtime checks.
- `.docs/README.md`, `.docs/history/README.md`, and `README.md`: index the spell and public behavior.

## Contracts changed

- Hooks or registration: Added `spell_apoc_mage_hypernova` and `AddModApocalipseMageHypernovaScripts()`.
- Human behavior: Human mages can cast the defined spell once acquisition data is supplied.
- Bot behavior: Bot mages use the same spell behavior and the existing playerbot knockback packet path.
- Configuration: None.
- Database or migration: Added automatic world update `2026_09_17_01_hypernova.sql`.
- Custom spell/client data: Reserved provisional ID 901005 and requires a matching client `Spell.dbc` row.
- Deployment or rollback: Requires worldserver restart, module build, automatic update, client patch, and focused in-game validation.

## Decisions

- Used 901005 because the working source already reserves 901004 for Missile Barrage Overload.
- Used the Arcane Explosion family bit instead of the Arcane Blast bit so Hypernova receives appropriate Arcane modifiers without being treated as Arcane Blast by Missile Barrage.
- Used normal school damage and destination knockback effects so mitigation, critical strikes, AoE rules, immunities, anticheat, creatures, humans, and bots remain on core paths.
- Used visual helper 35426 because spell visual scaling requires client asset work outside this change.
- Scheduled the real aura 36032 from `AfterCast` with a one-millisecond GUID-safe delay so Hypernova's immediate damage and its Arcane Explosion-family proc phases finish before the new four-stack state.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Source and SQL review | Inspect exact symbols, IDs, target fields, coefficients, and loader calls | Passed |
| Repository diff review | `git diff --check` and `git status --short` | Passed for whitespace and path review; unrelated in-progress Missile Barrage Overload files remain in the working tree |
| C++ formatter availability | `clang-format --version` | Not run: executable is unavailable |
| Generic core codestyle | AzerothCore C++ and SQL codestyle scripts | Inconclusive: C++ reported pre-existing sibling-core findings; SQL attempted an enterprise-blocked remote fetch |
| Parent custom-core build | Build `worldserver` with this module and `mod-playerbots` | Not run: no configured parent build tree in this workspace |
| Worldserver startup | Apply automatic update and inspect script validation | Not run |
| Client patch | Export and inspect the 901005 `Spell.dbc` row | Not run |
| Human and bot runtime | Execute the Hypernova verification matrix | Not run |

## Follow-up

- Add acquisition through the separately owned trainer, talent, item, or specialization workflow.
- Build against the deployment core, apply the update in a backed-up non-production database, export the client row, and complete the runtime matrix.
- Create a custom client visual only if the original Arcane Explosion Visual is too small in play.

## References

- Custom spell: [`../custom-spells/hypernova.md`](../custom-spells/hypernova.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

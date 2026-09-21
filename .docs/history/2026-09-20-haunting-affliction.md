# 2026-09-20: Haunting Affliction

Status: Partial

## Intent

Implement the approved Affliction Warlock talent that adds three caster-owned damage over time spells after a successful Haunt hit with a caster-global 30-second internal cooldown.

## Scope

### Code and data

- `src/mod_apocalipse_warlock_haunting_affliction.cpp`: adds the passive-gated Haunt hit script, highest-known-rank resolution, and curse and Seed exclusivity guards.
- `src/mod_apocalipse_loader.cpp`: registers the Warlock script.
- `data/sql/db-world/2026_09_20_02_haunting_affliction.sql`: installs spells 901028 and 901029, the rank-wide Haunt binding, non-save marker metadata, and backend names.

### Documentation

- `.docs/custom-spells/haunting-affliction.md`: records the end-to-end mechanic, data, acquisition, bot, rollback, and verification contracts.
- Architecture, subsystem, operations, playerbot, feature-index, history-index, and root README pages: index the new graph and deployment requirements.

## Contracts changed

- Hooks or registration: Adds an `AfterHit` script to the full Haunt rank chain without replacing core Haunt scripts.
- Human behavior: Passive 901028 applies eligible highest-known DoT ranks at most once per 30 seconds per caster.
- Bot behavior: Identical mechanics; existing caster-owned DoT awareness requires no AI change.
- Configuration: None.
- Database or migration: Adds automatic world update `2026_09_20_02_haunting_affliction.sql`.
- Custom spell/client data: Adds passive 901028 and non-saved marker 901029; matching client rows are required.
- Deployment or rollback: Requires a module rebuild, world updater execution, client patch export, external passive acquisition, and focused runtime checks.

## Decisions

- The cooldown is represented by a non-saved caster aura, so it is global across targets and does not survive logout.
- A different same-caster curse suppresses only Curse of Agony.
- Same-caster Seed of Corruption suppresses only Corruption.
- Triggered casts use real learned ranks so existing refresh, ownership, dispel, and playerbot behavior remains active.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Source and data review | Inspect script, loader, migration, and stock rank chains | Passed |
| Focused compile | Parent custom-core module build | Not run |
| World updater and startup | Start worldserver with updates enabled | Not run |
| Client export | Build and inspect patched `Spell.dbc` | Not run |
| Human and bot gameplay | Scenarios in the owner page | Not run |

## Follow-up

- Build against the deployment core and `mod-playerbots` checkout.
- Collision-check live database and selected client DBC IDs 901028 and 901029.
- Deploy external acquisition for passive 901028 only.
- Run the documented human and bot scenarios.

## References

- Feature: [`../custom-spells/haunting-affliction.md`](../custom-spells/haunting-affliction.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

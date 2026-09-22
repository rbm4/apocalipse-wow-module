# 2026-09-22: Leeching Mixture

Status: Partial

## Intent

Implement a Rogue defensive passive that converts owner-attributed poison damage into bounded self-healing while preserving normal healing reduction and dampening.

## Scope

### Code and data

- `src/mod_apocalipse_rogue_leeching_mixture.cpp`: Added poison filtering, direct-owner attribution, a one-second healing allowance, and the custom self-heal.
- `src/mod_apocalipse_loader.cpp`: Registered the Leeching Mixture script subsystem.
- `data/sql/db-world/2026_09_22_03_rogue_leeching_mixture.sql`: Added guarded passive 901075, heal helper 901076, proc metadata, script binding, fixed helper healing, and backend names.

### Documentation

- `.docs/custom-spells/leeching-mixture.md`: Added the current mechanical, data, deployment, rollback, and verification contract.
- Architecture, runtime, operations, feature, subsystem, playerbot, history, and root indexes were updated for the new spell graph.

## Contracts changed

- Hooks or registration: Added an AuraScript outgoing-damage proc and loader registration.
- Human behavior: Owner-attributed Rogue poison damage generates an 8 percent self-heal, capped at 2 percent maximum health per one-second window.
- Bot behavior: Identical to human Rogues; no new cast action is required.
- Configuration: None.
- Database or migration: Added automatic world migration `2026_09_22_03_rogue_leeching_mixture.sql`.
- Custom spell/client data: Added server rows 901075 and 901076; matching client rows remain required.
- Deployment or rollback: Requires world update, module rebuild, coordinated client patch, and the documented row and registration rollback.

## Decisions

- Poison eligibility uses both Rogue spell family and poison dispel metadata, covering the named stock poisons and providing an explicit metadata contract for custom Rogue poison damage.
- Both proc actor and `DamageInfo` attacker must be the aura owner, while self-damage and reflected-hit metadata are rejected.
- The cap tracks raw generated healing before healing-taken modifiers, so healing reduction and dampening cannot increase the allowance.
- Acquisition remains external because no specialization or talent attachment was requested.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Static source and SQL review | Inspect exact IDs, proc metadata, binding, fixed helper healing, and registration | Passed |
| Whitespace validation | `git diff --check` | Passed; line-ending conversion warnings only |
| Offline client collision check | Read local `Spell.dbc` record IDs 901075 and 901076 | Passed; both IDs absent |
| Stock poison metadata check | Read local `Spell.dbc` rows for Deadly, Instant, and Wound Poison ranks | Passed; sampled rows use Rogue family 8 and poison dispel type 4 |
| Parent worldserver build | Build exact custom core with module and playerbots | Not run per custom-core repository guidance |
| World updater and startup | Start worldserver against reviewed world data | Not run |
| Human and playerbot gameplay matrix | Run scenarios from the feature page | Not run |
| Client export | Verify both rows in deployed client patch | Not run |

## Follow-up

- Run the parent custom-core build, updater, startup, client export, and in-game verification matrix.
- Attach passive 901075 through the intended external acquisition source.

## References

- Custom spell: [`../custom-spells/leeching-mixture.md`](../custom-spells/leeching-mixture.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

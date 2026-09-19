# 2026-09-18: Frost Bomb visual origin

Status: Partial

## Intent

Move the Frost Nova-like detonation visual from the mage to the enemy carrying Frost Bomb without changing target-centered damage, slow application, hostility, or mage ownership.

## Scope

### Code and data

- `src/mod_apocalipse_mage_frost_bomb.cpp`: makes the bombed target self-cast existing visual-only Frost Nova spell 34326 when 901008 starts.
- `data/sql/db-world/2026_09_17_03_frost_bomb.sql`: creates new 901008 rows without caster-attached visual 17 and can repair its recognized prior form when manually rerun.
- `data/sql/db-world/2026_09_18_00_frost_bomb_visual_origin.sql`: removes visual 17 from an already-deployed recognized 901008 row.

### Documentation

- `.docs/custom-spells/frost-bomb.md`: separates the visual and gameplay paths and records migration and runtime expectations.
- Architecture, operations, history index, and root README: record the target-local visual flow and updater.

## Contracts changed

- Hooks or registration: The existing 901008 SpellScript adds an `OnCast` visual action; registration is unchanged.
- Human behavior: The Frost Nova-like explosion renders from the bombed enemy rather than the mage.
- Bot behavior: Identical to human behavior with no bot-specific path.
- Configuration: None.
- Database or migration: A guarded automatic world update changes recognized spell 901008 `SpellVisualID_1` from 17 to 0.
- Custom spell/client data: Custom spell 901008 no longer owns visual 17. Existing client spell 34326 supplies the same visual with only a zero-value dummy effect.
- Deployment or rollback: Requires the new world update, rebuilt module, and matching exported client 901008 row.

## Decisions

- Kept mage-owned spell 901008 as the only damage path because changing its actual caster would change hostile area selection.
- Reused spell 34326 after static inspection of the bundled WotLK 3.3.5a `Spell.dbc` confirmed visual 17, one zero-value dummy effect, and no aura or triggered spell.
- Added a new updater because production may already have recorded the original Frost Bomb migration as applied.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Bundled client DBC inspection | Parse spell 34326 from `apocalipse-wow-backend/data/Spell.dbc` | Passed: visual 17, dummy-only payload, no aura or trigger |
| Focused source and migration review | Inspect final diff, exact spell signatures, script bindings, and `git diff --check` | Passed |
| Parent custom-core build | Build `worldserver` with module and playerbots enabled | Not run |
| World updater and startup | Start against a backed-up non-production world database | Not run |
| Human and bot runtime | Detonate by expiration, dispel, and target death | Not run |

## Follow-up

- Export the updated 901008 client row, run the automatic updater, rebuild the module, and verify one visual on the bombed target with unchanged damage and slow victims.

## References

- Custom spell: [`../custom-spells/frost-bomb.md`](../custom-spells/frost-bomb.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

# 2026-09-20: Frost Bomb damage and visual placement

Status: Partial

## Intent

Double Frost Bomb explosion damage and make the Frost Nova detonation visual originate from the bombed enemy without changing damage ownership, area targeting, slows, or proc behavior.

## Scope

### Code and data

- `src/mod_apocalipse_mage_frost_bomb.cpp`: moves the visual-only 34326 self-cast to the application aura's known target before the mage-owned explosion cast.
- `data/sql/db-world/2026_09_20_00_frost_bomb_damage_and_visual.sql`: changes spell 901008 from 690 base damage and a 0.4 direct coefficient to 1380 and 0.8, clears its attached visual, and updates descriptions.

### Documentation

- `.docs/custom-spells/frost-bomb.md`: records the current damage, visual flow, migration, and client-patch requirement.
- `.docs/architecture/runtime-and-data-flow.md`, `.docs/development/operations.md`, root `README.md`, and the history index: record the changed runtime and deployment contracts.

## Contracts changed

- Hooks or registration: The visual self-cast now runs from the 901007 AuraScript removal handler instead of the 901008 SpellScript `OnCast` hook. Registration is unchanged.
- Human behavior: Frost Bomb deals twice its previous base and spell-power-scaled damage and requests visual 34326 from the bombed target.
- Bot behavior: Identical to human behavior with no bot-specific path.
- Configuration: None.
- Database or migration: A guarded automatic world update changes recognized 901008 rows and their `spell_bonus_data` coefficient.
- Custom spell/client data: The client 901008 row must be regenerated with base points 1379, coefficient 0.8, and `SpellVisualID_1` 0.
- Deployment or rollback: Requires the new world update, rebuilt module, and a rebuilt client patch generated after the update.

## Decisions

- Doubled both base damage and the direct spell-power coefficient so total pre-mitigation damage remains a true 2x increase at every spell-power value.
- Kept the mage as caster of 901008 to preserve hostile area selection, ownership, talents, procs, threat, and PvP processing.
- Moved only the visual cast to the aura removal path because that path already owns the exact bombed target and does not need to recover it from the explosion cast.
- Cleared 901008 visual 17 again because a stale client row can independently render that attached visual on the mage.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Focused source and SQL review | Inspect target flow, guarded old and final values, and exact spell IDs | Passed |
| Diff whitespace check | `git diff --check` | Passed |
| Parent custom-core build | Build `worldserver` with the module and playerbots enabled | Not run |
| World updater and client release | Apply to a backed-up non-production world database, then rebuild the client patch | Not run |
| Human and bot runtime | Detonate by expiration, dispel, and target death | Not run |

## Follow-up

- Apply the automatic update to a backed-up non-production world database, rebuild the client patch from the resulting `spell_dbc`, rebuild worldserver, and verify one target-local visual with no mage-local duplicate.

## References

- Custom spell: [`../custom-spells/frost-bomb.md`](../custom-spells/frost-bomb.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

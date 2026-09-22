# 2026-09-21: Necrotic Veil

Status: Partial

## Intent

Implement an Unholy Death Knight passive that converts 10 percent of directly dealt damage into a persistent magic-only absorb capped at 35 percent of maximum health.

## Scope

### Code and data

- `src/mod_apocalipse_death_knight_necrotic_veil.cpp`: added direct-owner damage filtering, bounded accumulation, aura refresh, and magic-only helper validation.
- `src/mod_apocalipse_loader.cpp`: registered the Necrotic Veil script.
- `data/sql/db-world/2026_09_21_07_death_knight_necrotic_veil.sql`: added guarded spells 901056 and 901057, proc metadata, binding, non-save helper metadata, Unholy acquisition, and backend names.

### Documentation

- `.docs/custom-spells/necrotic-veil.md`: recorded event eligibility, formulas, cap behavior, data, deployment, bot behavior, and verification scenarios.
- Architecture, operations, playerbot, subsystem, history, and root indexes reference Necrotic Veil.

## Contracts changed

- Hooks or registration: `AddModApocalipseDeathKnightNecroticVeilScripts()` now registers one AuraScript.
- Human behavior: directly dealt positive damage adds 10 percent of final event damage to a 60-second magic-only absorb capped at 35 percent of current maximum health.
- Bot behavior: identical to humans and requires no new AI action.
- Configuration: None.
- Database or migration: automatic guarded world update adds spells 901056 and 901057 and Unholy Spec Manager acquisition.
- Custom spell/client data: matching client rows for both spells are required and acquisition references only 901056.
- Deployment or rollback: world update, module rebuild, client patch, and spec reconciliation are required.

## Decisions

- Allocated 901056 and 901057 after the migration ledger assigned 901054 and 901055 to Rime Shards.
- Used post-mitigation `DamageInfo` event damage and floor rounding for each independent event.
- Excluded pet, guardian, self, zero-damage, and non-damage events by requiring the Death Knight to be the exact event actor.
- Used school mask 126 so every magic school, including Holy, is absorbed while Physical damage is excluded.
- Used one shared remaining absorb whose full 60-second duration refreshes only after a positive rounded contribution.
- Omitted a Spell Scaling row because the contribution derives from already-resolved source damage.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Repository spell-ID scan | Search module migrations for 901056 and 901057 before creation | Passed for current workspace sources; live server and deployed client remain pending |
| Duration evidence | Read stock spell 11196 from the local deployment `Spell.dbc` | Passed: duration index 3 is 60 seconds |
| Custom-core API review | Checked proc flags, aura amount mutation, duration refresh, and school-mask absorb handling | Passed by static inspection |
| Static source and migration review | Focused code, SQL, registration, schema alignment, and documentation inspection | Passed |
| Custom-core build | Parent worldserver build | Not run because repository rules require explicit request |
| Human and bot runtime scenarios | Matrix in `custom-spells/necrotic-veil.md` | Not run |
| Client patch validation | Exported and deployed `Spell.dbc` | Not run |

## Follow-up

- Build against the deployment custom core with this module and `mod-playerbots` enabled.
- Run the named direct, periodic, triggered, pet, cap, expiration, Physical, magic, human, and playerbot scenarios.
- Collision-check live server tables and selected deployment client before applying the update.
- Export and deploy matching client rows 901056 and 901057.

## References

- Custom spell: [`../custom-spells/necrotic-veil.md`](../custom-spells/necrotic-veil.md)
- Architecture: [`../architecture/runtime-and-data-flow.md`](../architecture/runtime-and-data-flow.md)
- Commit or PR: Not created

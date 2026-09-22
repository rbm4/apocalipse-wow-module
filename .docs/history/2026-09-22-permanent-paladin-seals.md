# 2026-09-22: Permanent Paladin seals

Status: Partial

## Intent

Complete the Holy and Protection permanent-seal options, allow a permanent seal and matching active seal to proc together, and keep Divine Toll as the separately acquired Retribution option.

## Scope

### Code and data

- `src/mod_apocalipse_paladin_permanent_seal_of_righteousness.cpp`: removed real-SoR suppression and added the stock 3.3.5a Seal of Vengeance proc path for passive 901060.
- `data/sql/db-world/2026_09_22_01_permanent_paladin_seals.sql`: reserved 901060, defined its server and client-export row, proc metadata, script binding, backend name, and updated 901016 descriptions.

### Documentation

- Updated the custom spell owner, architecture, runtime flow, playerbot behavior, operations inventory, subsystem and feature indexes, root README, and history index.

## Contracts changed

- Hooks or registration: Existing `AddModApocalipsePaladinPermanentSealOfRighteousnessScripts()` now registers both exact passive scripts; loader order is unchanged.
- Human behavior: Matching permanent and active seals now proc independently. Permanent Vengeance shares normal Holy Vengeance stacks and excludes Seal of Corruption.
- Bot behavior: Identical to humans with no AI-specific code.
- Configuration: None.
- Database or migration: Added one guarded automatic world update for 901060 and a recognized-row description update for 901016.
- Custom spell/client data: Reserved repository ID 901060 as an unranked acquisition-facing passive. Matching client export remains required.
- Deployment or rollback: Requires normal updater execution, module rebuild, client `Spell.dbc` export and deployment, and external acquisition references to 901016 or 901060.

## Decisions

- Reused the deployment core's Vengeance ordering: read current 31803 stacks for damage before applying a new stack.
- Used only Seal of Vengeance 31801 behavior and effects 31803 and 42463. Corruption support remains outside this 3.3.5a contract.
- Preserved one shared same-caster Holy Vengeance aura, so double Vengeance builds it faster rather than creating an unsupported second copy.
- Left acquisition and specialization assignment outside the module. Divine Toll 901024 remains the external Retribution reference.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Core source review | Compared module behavior with `spell_pal_seal_of_righteousness` and `spell_pal_seal_of_vengeance_aura` in the deployment core | Passed |
| Repository ID inventory | Searched automatic migrations and core SQL through 901059 | Passed for repository allocation |
| Checked-in DBC inspection | Read-only scan of backend `data/Spell.dbc` for 31801 and 901060 | Stock 31801 found; 901060 absent |
| Backend export review | Inspected `SpellDbcPatcher` and full override query path | Passed by static review |
| Custom-core build | Parent `worldserver` build | Not run at user request because build tools are unavailable in this workspace |
| World updater and startup | Database updater and worldserver startup | Not run; authorized operator action required |
| Client export and deployment | Backend `Spell.dbc` export and MPQ deployment | Not run; authorized operator action required |
| Human and bot scenarios | Owner-page runtime matrix | Not run; runtime environment unavailable |

## Follow-up

- Collision-check 901060 against live world tables and the selected deployed client.
- Run the updater, inspect startup validation, export and deploy matching client data, and execute the documented human and bot scenarios.
- Configure the external acquisition CRUD to reference unranked passive 901016 for Holy, 901060 for Protection, and 901024 for Retribution.

## References

- Custom spell: [`../custom-spells/permanent-seal-of-righteousness.md`](../custom-spells/permanent-seal-of-righteousness.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

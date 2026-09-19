# 2026-09-18: Paladin Vengeance variants

Status: Partial

## Intent

Implement Protection and Holy critical-event stacking talents using native AzerothCore proc and aura data.

## Scope

### Code and data

- `data/sql/db-world/2026_09_18_04_paladin_vengeance_variants.sql`: Added guarded spell definitions, proc metadata, non-save buffs, and backend names for 901018 through 901021.

### Documentation

- `.docs/custom-spells/paladin-vengeance-variants.md`: Added the owner contract, acquisition boundary, mechanics, and scenarios.
- Architecture, runtime flow, playerbots, operations, indexes, root README, and spell inventory: Added the data-only feature and four-spell graph.

## Contracts changed

- Hooks or registration: None. Native `spell_proc` and aura handlers own the complete behavior.
- Human behavior: Protection and Holy critical events add three-stack, eight-second specialization buffs.
- Bot behavior: Identical to humans with no playerbot AI change.
- Configuration: None.
- Database or migration: Added one automatic guarded world update.
- Custom spell/client data: Added passives 901018 and 901020 plus internal buffs 901019 and 901021.
- Deployment or rollback: Requires updater execution, matching client rows, and separately owned talent acquisition data.

## Decisions

- Used three stacks and an eight-second whole-aura refresh.
- Guardian's Resolve grants 1 percent all-school damage reduction and 10 flat defense rating per stack.
- Sacred Fervor grants 2 percent healing done and 10 mp5 per stack.
- Included direct, periodic, and eligible triggered events without an internal cooldown.
- Counted only the critical source heal for Beacon because copy spells 53652 through 53654 cannot critically strike.
- Shifted the graph to 901018 through 901021 after concurrent Divine Steed work claimed 901017.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Core contracts | Reviewed proc flags, hit masks, aura enums, rating and mana regeneration paths | Passed |
| Stock precedent | Parsed Vengeance 20049 and 20050 plus eight-second Frost Nova 122 from checked-in runtime-grade `Spell.dbc` | Passed |
| Checked-in client collision | Parsed backend `data/Spell.dbc` and `data/SpellExtracted.dbc` for 901018 through 901021 | Passed, none of the four IDs exists |
| Source and SQL review | Focused identifier, schema, and diff checks | Passed |
| Custom-core build | Parent worldserver build | Not run because core instructions require explicit request |
| Database updater | Disposable development database | Not run |
| In-game behavior | Human and playerbot scenarios | Not run |

## Follow-up

- Collision-check all four IDs against live world tables and the selected deployed client.
- Export and deploy matching client `Spell.dbc` rows.
- Configure the separate talent owner to grant only 901018 and 901020.
- Run the documented human and playerbot scenarios.

## References

- Custom spell: [`../custom-spells/paladin-vengeance-variants.md`](../custom-spells/paladin-vengeance-variants.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

# 2026-09-20: Unquenchable Flames

Status: Partial

## Intent

Add a Warlock passive that prevents dispels from removing the caster's Immolate and Shadowflame effects.

## Scope

### Code and data

- `data/sql/db-world/2026_09_20_07_unquenchable_flames.sql`: Added guarded passive 901034 with a native 100 percent resist-dispel spell modifier for exact Immolate and Shadowflame family masks.
- No C++ or loader change was needed because the deployed core already calculates caster-owned spell-modifier dispel resistance for each aura.

### Documentation

- `.docs/custom-spells/unquenchable-flames.md`: Added behavior, family masks, core flow, ownership, deployment, and verification contracts.
- Architecture, operations, subsystem, playerbot, feature, history, root, and ownership indexes now include Unquenchable Flames.

## Contracts changed

- Hooks or registration: None. Reuses native aura type 107, spell modifier operation 28, and `Aura::CalcDispelChance`.
- Human behavior: Immolate and Shadowflame cast by a Warlock with passive 901034 have zero dispel chance.
- Bot behavior: Identical when the bot has acquired passive 901034.
- Configuration: None.
- Database or migration: Added one automatic guarded world update for passive 901034 and backend name synchronization.
- Custom spell/client data: Added server spell 901034. Matching client `Spell.dbc` and separate talent acquisition data remain required.
- Deployment or rollback: Worldserver updater execution, restart, and matching client and acquisition deployment are required. No module rebuild is required for this data-only feature.

## Decisions

- Selected the name Unquenchable Flames.
- Protected the exact Warlock family bits used by Immolate and Shadowflame instead of changing those stock spells globally.
- Used 100 percent caster spell-modifier dispel resistance so each aura follows its own Warlock's current passive state.
- Did not bind Conflagrate because WotLK Conflagrate has no dispellable aura. Its Immolate and Shadowflame prerequisites are protected.
- Preserved expiration, Conflagrate consumption, death cleanup, immunity cleanup, scripted removal, and replacement behavior.
- Left talent acquisition outside this module migration and documented unranked passive 901034 as its only valid spell reference.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| ID inventory | Repository search for 901034 across module, core, backend, playerbots, and checked-in client data | Passed for repository data and the checked-in 49,839-row `Spell.dbc`; live data not checked |
| Core path | Reviewed `Aura::CalcDispelChance`, `Player::ApplySpellMod`, normal dispel, Spellsteal, and mechanic-removal paths | Passed by static review |
| Family masks | Inspected checked-in `Spell.dbc` rows for every Immolate rank and both Shadowflame periodic triggers | Passed: Immolate uses family word 0 bit 2 and Shadowflame periodic triggers use word 2 bit 1 |
| Client source | Inspected checked-in `Spell.dbc` shape, ID inventory, and Immolate icon | Passed: 49,839 records, 234 fields, no 901034 collision, and `SpellIconID` 31 |
| Exporter dry run | Applied an in-memory 901034 row through the existing `SpellDbcPatcher` against the checked-in base | Passed: appended row retained effect 6, aura 107, operation 28, masks `(4, 0, 2)`, family 5, school 4, and icon 31 |
| SQL contract | Static ID, effect, amount, operation, mask, icon, collision-guard, and backend-name checks | Passed |
| Documentation links | Checked local links from the owner, history, and updated indexes | Passed |
| Patch whitespace | `git diff --check` | Passed; existing line-ending conversion warnings remain |
| Custom-core build | Build `worldserver` with this module and `mod-playerbots` | Not run because repository instructions require explicit build authorization, and no C++ changed |
| SQL execution | Apply updater to a disposable world database | Not run because database mutation was not authorized |
| Client export | Export and inspect matching client `Spell.dbc` and talent data | Not run |
| Human and bot scenarios | Execute the feature verification matrix | Not run because no runtime worldserver session was available |

## Follow-up

- Collision-check 901034 in the live world tables and deployed client data.
- Deploy talent acquisition and matching client data.
- Run worldserver startup validation and the documented human and bot scenarios.

## References

- Custom spell: [`../custom-spells/unquenchable-flames.md`](../custom-spells/unquenchable-flames.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

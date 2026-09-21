# 2026-09-20: Unyielding Shadows

Status: Partial

## Intent

Add a Warlock passive that prevents dispels from removing the caster's curses and Shadow debuffs while preserving Unstable Affliction's stock dispel interaction.

## Scope

### Code and data

- `data/sql/db-world/2026_09_20_08_unyielding_shadows.sql`: Added guarded passive 901035 with native 100 percent resist-dispel handling and a combined Warlock family mask.
- No C++ or loader change was needed because the deployed core already calculates caster-owned spell-modifier dispel resistance for each aura.

### Documentation

- `.docs/custom-spells/unyielding-shadows.md`: Added affected-spell, mask, UA exclusion, core flow, ownership, deployment, and verification contracts.
- Architecture, operations, subsystem, playerbot, feature, history, root, and ownership indexes now include Unyielding Shadows.

## Contracts changed

- Hooks or registration: None. Reuses native aura type 107, spell modifier operation 28, and `Aura::CalcDispelChance`.
- Human behavior: Matching curses and Shadow debuffs cast by a Warlock with passive 901035 have zero dispel chance.
- Bot behavior: Identical when the bot has acquired passive 901035.
- Unstable Affliction: All ranks remain outside the modifier and retain stock dispel consequences.
- Configuration: None.
- Database or migration: Added one automatic guarded world update and backend name synchronization.
- Custom spell/client data: Added server spell 901035. Matching client `Spell.dbc` and separate talent acquisition data remain required.
- Deployment or rollback: Worldserver updater execution, restart, and matching client and acquisition deployment are required. No module rebuild is required for this data-only feature.

## Decisions

- Selected the name Unyielding Shadows.
- Used the combined mask `(0xC04CC41A, 0x1804161B, 0x00000000)` derived from the checked-in deployment DBC.
- Omitted Unstable Affliction's unique word 1 bit `0x00000100` across all known ranks.
- Included matching owner-pet Warlock effects such as Seduction through the normal spell-mod-owner path.
- Preserved expiration, channel termination, death cleanup, immunity cleanup, scripted removal, and replacement behavior.
- Left talent acquisition outside this module migration and documented unranked passive 901035 as its only valid spell reference.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| ID inventory | Repository search for 901035 and Unyielding Shadows | Passed before implementation; live data not checked |
| Core path | Reviewed `Aura::CalcDispelChance`, `Player::ApplySpellMod`, and 96-bit family matching | Passed by static review |
| Family masks | Decoded checked-in `Spell.dbc` family words for representative curses, Corruption, Fear, control, drain, Seed, Haunt, Shadow Embrace, and UA ranks | Passed |
| UA exclusion | Inspected every checked-in Warlock row using word 1 bit `0x00000100` | Passed: all eight rows are Unstable Affliction variants, and the bit is absent from the passive mask |
| SQL contract | Static ID, effect, amount, operation, mask, icon, collision-guard, and backend-name checks | Passed |
| Client exporter dry run | Applied an in-memory 901035 row through `SpellDbcPatcher` | Passed: appended row preserved aura 107, operation 28, amount encoding, masks, family, school, and icon |
| Documentation links | Checked local links from owner, history, and updated indexes | Passed |
| Patch whitespace | `git diff --check` | Passed; existing line-ending conversion warnings remain |
| Custom-core build | Build `worldserver` with this module and `mod-playerbots` | Not run because repository instructions require explicit build authorization, and no C++ changed |
| SQL execution | Apply updater to a disposable world database | Not run because database mutation was not authorized |
| Client export | Export and inspect matching client `Spell.dbc` and talent data | Not run |
| Human and bot scenarios | Execute the feature verification matrix | Not run because no runtime worldserver session was available |

## Follow-up

- Collision-check 901035 in the live world tables and deployed client data.
- Deploy talent acquisition and matching client data.
- Run worldserver startup validation and the documented human and bot scenarios.

## References

- Custom spell: [`../custom-spells/unyielding-shadows.md`](../custom-spells/unyielding-shadows.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

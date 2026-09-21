# 2026-09-21: Melee Specialization

Status: Partial

## Intent

Add a data-driven Hunter melee specialization passive that makes Raptor Strike, Mongoose Bite, and Counterattack ignore aura-state requirements and increases Raptor Strike, Mongoose Bite, Wing Clip, and Counterattack damage by 30 percent.

## Scope

### Code and data

- `data/sql/db-world/2026_09_21_02_melee_specialization.sql`: adds guarded passive 901047 with native aura-state and percent-damage spell modifiers.

### Documentation

- `.docs/custom-spells/melee-specialization.md`: records mechanics, masks, boundaries, client contract, verification, and rollback.
- Architecture, operations, feature, subsystem, playerbot, history, and root indexes: add spell 901047 and extend the managed custom-spell range.

## Contracts changed

- Hooks or registration: None; native aura and spell-modifier handling is used.
- Human behavior: the three selected Hunter melee families ignore aura-state requirements, with Counterattack being the only family currently gated in the deployment DBC and all four Hunter melee damage families gain 30 percent damage while passive 901047 is known.
- Bot behavior: identical mechanics; acquisition remains external.
- Configuration: None.
- Database or migration: adds automatic guarded world update `2026_09_21_02_melee_specialization.sql`.
- Custom spell/client data: allocates 901047 and requires a matching client `Spell.dbc` row.
- Deployment or rollback: world update and client patch must be deployed together; acquisition references must be removed before rollback.

## Decisions

- Use `SPELL_AURA_ABILITY_IGNORE_AURASTATE` with misc value 1 because the deployment core natively bypasses affected aura-state and surrounding combat checks.
- Use `SPELL_AURA_ADD_PCT_MODIFIER` with `SPELLMOD_DAMAGE` instead of the school-wide damage aura, so the 30 percent increase remains restricted by Hunter family masks.
- Keep acquisition external and avoid a C++ script because both mechanics are fully represented by native spell data.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Deployment DBC family-mask inspection | Read family 9 rows from backend `data/Spell.dbc` | Passed: bypass masks resolve to Raptor Strike, Mongoose Bite, and Counterattack; the damage mask additionally resolves to Wing Clip |
| Deployment DBC aura-state inspection | Read `CasterAuraState` for the affected stock ranks | Passed: Counterattack uses state 7; Raptor Strike and Mongoose Bite use state 0 |
| Core path inspection | Reviewed `Spell::CheckCast`, `Unit::HasAuraState`, `AuraEffect::IsAffectedOnSpell`, `AuraEffect::CalculateSpellMod`, and `SPELLMOD_DAMAGE` application | Passed |
| SQL contract | Reviewed collision guard, 32-column insert alignment, stored base points and die sides, ownership signatures, exact effect masks, and backend name | Passed by static review |
| Patch whitespace and punctuation | `git diff --check` plus focused forbidden-punctuation and trailing-whitespace scans | Passed; existing line-ending conversion warnings remain |
| SQL application | Automatic world updater against a database clone | Not run |
| Build | Parent custom-core worldserver build | Not run: data-only change and core repository rules require an explicit build request |
| Runtime scenarios | Human and playerbot matrix in the owner page | Not run |
| Client patch | Export and inspect matching `Spell.dbc` row | Not run |

## Follow-up

- Apply the updater to a reviewed database clone, export the client row, and run the documented human and playerbot scenarios before production acquisition.

## References

- Feature: [`../custom-spells/melee-specialization.md`](../custom-spells/melee-specialization.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

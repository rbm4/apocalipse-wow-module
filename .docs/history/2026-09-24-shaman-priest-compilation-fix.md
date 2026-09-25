# 2026-09-24: Shaman and Priest compilation fix

Status: Partial

## Intent

Resolve two deployment-core compilation failures found after the Shaman and Priest spell packs were added.

## Scope

### Code and data

- `src/mod_apocalipse_shaman_spells.cpp`: updates the Overflowing Tides absorb cast to the deployment core's spell-first single-value `CastCustomSpell` overload.
- `src/mod_apocalipse_priest_spells.cpp`: removes the duplicate module `NPC_SHADOWFIEND` constant and directly includes `PetDefines.h` for the core-owned constant.

### Documentation

- `.docs/custom-spells/shaman-spell-pack.md`: records the compatibility review and pending rebuild.
- `.docs/features/priest-ability-pack.md`: records the core constant review and pending rebuild.
- `.docs/development/operations.md`: records both custom-core API compatibility rules.

## Contracts changed

- Hooks or registration: None.
- Human behavior: None. The changes preserve the intended Overflowing Tides target and Shadowfiend entry value.
- Bot behavior: None.
- Configuration: None.
- Database or migration: None.
- Custom spell/client data: None.
- Deployment or rollback: Rebuild `worldserver` against the deployment core. Source rollback is sufficient for these code-only fixes.

## Decisions

- Use `CastCustomSpell(spellId, mod, value, victim, ...)` because the deployment core's victim-first overload requires three base-point pointers.
- Use the core-owned `NPC_SHADOWFIEND` declaration from `PetDefines.h` instead of maintaining a duplicate value in the module namespace.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Core API inspection | Reviewed `Unit.h` overloads and `PetDefines.h` in the matching custom core | Passed |
| Focused source review | Checked all module `CastCustomSpell` and `NPC_SHADOWFIEND` references | Passed |
| Patch validation | `git diff --check` | Passed |
| Custom-core rebuild | Worldserver build with module and playerbots | Not run locally |
| Human and bot gameplay | Overflowing Tides overheal and Faithful Shadowfiend scenarios | Not run |

## Follow-up

- Rebuild `worldserver` in the deployment environment and confirm both translation units compile.
- Run focused Overflowing Tides and Faithful Shadowfiend gameplay scenarios after deployment.

## References

- Shaman spell contract: [`../custom-spells/shaman-spell-pack.md`](../custom-spells/shaman-spell-pack.md)
- Priest feature: [`../features/priest-ability-pack.md`](../features/priest-ability-pack.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

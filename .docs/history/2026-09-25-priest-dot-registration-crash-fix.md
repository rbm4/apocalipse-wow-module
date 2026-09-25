# 2026-09-25: Priest periodic-aura registration crash fix

Status: Partial

## Intent

Prevent `worldserver` from dereferencing unavailable runtime aura state while validating the Priest periodic-effect bindings during startup.

## Scope

### Code and data

- `src/mod_apocalipse_priest_spells.cpp`: `spell_apoc_priest_dot::script` now validates effect 0 as periodic damage and registers its handlers with the fixed aura type instead of calling `AuraScript::GetSpellInfo()` from `Register()`.
- Database and client data: unchanged.

### Documentation

- `.docs/features/priest-ability-pack.md`: records the diagnosed startup failure and corrected registration contract.
- `.docs/history/README.md`: indexes this fix.

## Contracts changed

- Hooks or registration: Priest DoT handlers remain on effect 0 and now explicitly require `SPELL_AURA_PERIODIC_DAMAGE`.
- Human behavior: unchanged.
- Bot behavior: unchanged and identical to human behavior.
- Configuration: None.
- Database or migration: None.
- Custom spell/client data: None.
- Deployment or rollback: rebuild `worldserver`; rollback restores the unsafe registration-time lookup and must not be used on the affected bindings.

## Decisions

- Use the invariant shared by Shadow Word: Pain, Vampiric Touch, stock Devouring Plague, and copied Devouring Plague 901148 rather than reading runtime aura state before an aura exists.
- Add `Validate()` so a future incompatible binding is rejected with a validation error instead of silently registering mismatched hooks.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Crash diagnosis | Run deployed `worldserver` under GDB and capture `thread apply all bt full` | Passed: stack ended in `AuraScript::GetSpellInfo()` from `spell_apoc_priest_dot::script::Register()` |
| Source and whitespace checks | `git diff --check` and focused source inspection | Pending |
| Deployment-core build | Build deployed custom core with the module and `mod-playerbots` | Pending |
| Startup validation | Start `acore-world.service` and confirm it advances beyond `Validating Spell Scripts...` | Pending |
| Human and playerbot gameplay | Exercise Accelerated Misery, Spreading Darkness, Devouring Echo, and Void Eruption | Not run |

## Follow-up

- Complete focused human and playerbot gameplay verification for the Shadow portion of the Priest ability pack.
- Clean up the independent nonfatal `spell_proc` mask warnings for Bladeguard and the Shaman pack separately.

## References

- Feature: [`../features/priest-ability-pack.md`](../features/priest-ability-pack.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

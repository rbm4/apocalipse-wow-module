# 2026-09-22: Crimson Ward amount-hook crash fix

Status: Partial

## Intent

Stop Crimson Ward helper 901051 from crashing worldserver when its absorb amount is calculated, and preserve the AuraScript hook lesson for future spell work.

## Scope

### Code and data

- `src/mod_apocalipse_death_knight_crimson_ward.cpp`: Replaced unsupported `AuraScript::GetTarget()` use in `DoEffectCalcAmount` with a null-checked `GetUnitOwner()` lookup.
- Database and client data: None.

### Documentation

- `.docs/custom-spells/crimson-ward.md`: Recorded the amount-hook accessor invariant, incident evidence, and runtime re-verification scenario.
- `.docs/architecture/runtime-and-data-flow.md`: Added the repository-wide AuraScript hook-context rule for future spell implementations.
- `.docs/history/README.md`: Indexed this fix.

## Contracts changed

- Hooks or registration: The existing `DoEffectCalcAmount` registration is unchanged; its handler now uses an accessor valid without an `AuraApplication`.
- Human behavior: Crimson Ward still snapshots 20 percent of the Death Knight's maximum health when helper 901051 is applied.
- Bot behavior: Identical fix for playerbot Death Knights; startup or combat-time helper application must no longer dereference a null target.
- Configuration: None.
- Database or migration: None.
- Custom spell/client data: None.
- Deployment or rollback: Requires rebuilding and deploying worldserver. No SQL, client patch, service restart, or production deployment was performed in this change.

## Decisions

- Used `GetUnitOwner()` rather than `GetCaster()` because the formula belongs to the unit carrying helper aura 901051 and must remain correct even if future casting ownership changes.
- Kept the null guard even though the helper is a unit aura, so the amount callback cannot turn an unexpected ownership state into another native crash.
- Documented relocation-aware symbolization because the original kernel-relative address was incorrectly attributed to `npc_arthas::UpdateAI`; adding the ELF executable segment virtual offset resolved the fault to `Object::GetUInt32Value` at the null `this + 0x68` access.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Hook contract | Reviewed `AuraScript::GetTarget()` and `GetUnitOwner()` in the deployment core's `SpellScript.cpp` | Passed: `GetTarget()` returns null in amount hooks; `GetUnitOwner()` reads directly from the aura |
| Crash address | Added executable segment offset `0x6b5000` to kernel-relative offset `0x12f6f9b` and resolved `0x19abf9b` in the deployed binary | Passed: exact faulting instruction was `Object::GetUInt32Value` reading `0x68(%rdi)` with null `rdi` |
| Duplicate DK misuse | Reviewed all six newly added Death Knight scripts and module amount-calculation hooks | Passed: Crimson Ward was the only new DK amount handler using `GetTarget()` |
| Source and documentation whitespace | `git diff --check` | Passed; only existing LF-to-CRLF working-tree warnings were emitted |
| Custom-core build | Build worldserver with this module and mod-playerbots | Not run because the custom-core repository requires explicit build approval |
| Runtime regression | Apply 901051 to human and playerbot Blood Death Knights after qualifying damage | Not run; requires rebuilt production-equivalent worldserver |

## Follow-up

- Rebuild and deploy worldserver, then verify qualifying damage applies a 20-percent maximum-health shield without an unsupported-hook warning or segfault.
- Enable retained core dumps and debug information for future native-crash diagnosis.

## References

- Custom spell: [`../custom-spells/crimson-ward.md`](../custom-spells/crimson-ward.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

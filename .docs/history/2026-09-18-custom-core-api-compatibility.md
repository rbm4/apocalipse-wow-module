# 2026-09-18: Custom-core API compatibility

Status: Partial

## Intent

Repair three module compile failures caused by relying on an invalid header order, a legacy proc-mask name, and a spell member that is not public in the deployment core. Record reusable rules so later spell implementations verify the exact custom-core API before copying code from another branch.

## Scope

### Code and data

- `src/mod_apocalipse_mage_prismatic_barrier.cpp`: includes `Define.h` before `SpellAuras.h` so `SpellAuraDefines.h` can resolve `uint8` without relying on a precompiled header.
- `src/mod_apocalipse_paladin_permanent_seal_of_righteousness.cpp`: includes `SpellMgr.h` and filters absorbed hits with `PROC_HIT_ABSORB`.
- `src/mod_apocalipse_paladin_divine_toll.cpp`: reads Judgement categories through `SpellInfo::GetCategory()`.
- Database and client data are unchanged.

### Documentation

- `.docs/development/operations.md`: adds custom-core C++ API and direct-include guidelines.
- `.docs/custom-spells/prismatic-barrier.md`: records the `SpellAuras.h` include-order failure and recovery.
- `.docs/custom-spells/permanent-seal-of-righteousness.md`: records the hit-mask API contract.
- `.docs/custom-spells/divine-toll.md`: records the spell-category accessor contract.
- `.docs/history/README.md`: indexes this repair.

## Contracts changed

- Hooks or registration: None.
- Human behavior: None intended.
- Bot behavior: None intended; identical to human behavior.
- Configuration: None.
- Database or migration: None.
- Custom spell/client data: None.
- Deployment or rollback: Requires a module rebuild. No SQL or client patch update is required.

## Decisions

- Added direct declaration headers instead of relying on the module precompiled header or transitive includes.
- Used `PROC_HIT_ABSORB` because `ProcEventInfo::GetHitMask()` exposes the current hit-mask contract. `PROC_EX_ABSORB` remains legacy vocabulary in this core.
- Used `SpellInfo::GetCategory()` because this core exposes `CategoryEntry`, not a public `Category` field.
- Kept the fix source-only because no gameplay, spell graph, database, or client-data contract changed.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Deployment-core API trace | Inspect `SpellAuraDefines.h`, `SpellMgr.h`, `Unit.h`, and `SpellInfo.h` in the matching custom core | Passed |
| Related core call sites | Inspect proc-mask and category-access patterns in the matching custom core | Passed |
| Repository whitespace | `git diff --check` | Passed; line-ending conversion warnings are informational |
| Parent custom-core build | Build `worldserver` with this module and `mod-playerbots` | Not run at user request; user will compile and report remaining errors |
| Human and bot runtime | Existing affected feature matrices | Not run |

## Follow-up

- Compile against the deployment core and report any remaining compiler errors.
- Run the existing Prismatic Barrier, Permanent Seal of Righteousness, and Divine Toll runtime matrices after a successful build.

## References

- Custom spells: [`../custom-spells/prismatic-barrier.md`](../custom-spells/prismatic-barrier.md), [`../custom-spells/permanent-seal-of-righteousness.md`](../custom-spells/permanent-seal-of-righteousness.md), and [`../custom-spells/divine-toll.md`](../custom-spells/divine-toll.md)
- Operations: [`../development/operations.md`](../development/operations.md)
- Commit or PR: Not created

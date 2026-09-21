# 2026-09-21: Primal Resolve

Status: Implemented in source and data, build and runtime not verified

## Summary

Added shared Hunter active spell 901042, Primal Resolve. The spell removes current snare effects, reduces all damage taken by 15 percent for 6 seconds, and has a 30-second cooldown without suppressing attacks or changing targetability.

## Produced

- `src/mod_apocalipse_hunter_primal_resolve.cpp` with exact spell-data validation and scripted snare cleanup.
- `data/sql/db-world/2026_09_21_03_primal_resolve.sql` with the guarded spell row, script binding, non-save metadata, and backend name.
- Loader registration through `AddModApocalipseHunterPrimalResolveScripts()`.
- Current behavior and verification scenarios in `.docs/custom-spells/primal-resolve.md`.
- Architecture, operations, playerbot, catalog, and root documentation updates.

## Key decisions

- The native all-school damage-taken aura owns the 15 percent reduction.
- `RemoveMovementImpairingAuras(false)` removes current snare mechanics but deliberately leaves roots.
- The spell grants no ongoing movement immunity, so later snares apply normally.
- No pacify, silence, untargetability, or attack-suppression attribute is present.
- Acquisition and playerbot cast policy remain external.

## Verification

| Check | Result |
|---|---|
| Deployment-core snare-removal helper review | Passed by static review |
| Effect ID, stored base points, duration, cooldown, targeting, and all-school aura review | Passed by static review |
| SQL schema, 36-column value alignment, collision guard, binding, and non-save metadata review | Passed by static review |
| Independent deployment-core and module review | No blocking issue found; canonical helper removes mechanic-tagged snares and preserves roots |
| Focused source, SQL, loader, punctuation, and documentation-link checks | Passed |
| Custom-core worldserver build | Not run because the core repository requires explicit build approval |
| SQL execution and updater startup | Not run because database mutation was not authorized |
| Client patch inspection | Not run |
| Human and playerbot runtime scenarios | Not run |

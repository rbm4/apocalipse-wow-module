# 2026-09-20: Divine Steed cast cancellation

Status: Partial

## Intent

Remove Divine Steed's cosmetic display and speed bonus when the player successfully casts another spell, avoiding a remaining speed aura after the 3.3.5a client hides the display during combat animations.

## Scope

### Code and data

- `src/mod_apocalipse_paladin_divine_steed.cpp`: Added a player spell-cast hook that removes aura 901017 after a successful non-triggered player spell.
- `data/sql/db-world/2026_09_20_01_divine_steed_cast_cancel.sql`: Added a guarded, rerunnable description update for spell 901017.

### Documentation

- `.docs/custom-spells/divine-steed.md`: Updated the runtime, cleanup, database, client, and verification contracts.
- `.docs/architecture/runtime-and-data-flow.md`, `.docs/development/operations.md`, root `README.md`, and the history index: Recorded spell-cast cancellation and deployment requirements.

## Contracts changed

- Hooks or registration: The existing Divine Steed `PlayerScript` now handles `OnPlayerSpellCast`; registration is unchanged.
- Human behavior: The next successful player-initiated spell removes Divine Steed's aura, speed bonus, and cosmetic display.
- Bot behavior: Identical to human behavior.
- Configuration: None.
- Database or migration: A guarded automatic world update changes the spell and aura descriptions for 901017.
- Custom spell/client data: The client 901017 row must be regenerated with the updated descriptions.
- Deployment or rollback: Requires the new world update, rebuilt module, and rebuilt client patch.

## Decisions

- Ignore triggered casts so child spells, proc effects, periodic effects, and server-triggered helpers do not cancel Divine Steed.
- Keep `AuraInterruptFlags` at zero because the explicit player hook defines the cancellation boundary consistently for successful player casts.
- Remove the full aura rather than only the speed effect so display and movement state remain synchronized.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Focused source review | Trace `OnPlayerSpellCast`, the triggered-cast guard, and `ClearDivineSteed` cleanup | Passed |
| SQL ownership review | Compare 901017 guard fields with the baseline Divine Steed migration | Passed |
| Diff whitespace check | `git diff --check` | Passed; only existing line-ending warnings were emitted |
| Parent custom-core build | Build `worldserver` with the module and playerbots enabled | Not run; local framework is unavailable |
| World updater and client release | Apply to a backed-up non-production world database, then rebuild the client patch | Not run; local framework is unavailable |
| Human and bot runtime | Cast Divine Storm, Judgement, a triggered child, and allow natural expiration | Not run; local framework is unavailable |

## Follow-up

- Deploy the automatic update, rebuild the module and client patch, then verify player-initiated and triggered spell behavior on both human and playerbot paladins.

## References

- Custom spell: [`../custom-spells/divine-steed.md`](../custom-spells/divine-steed.md)
- Architecture: [`../architecture/runtime-and-data-flow.md`](../architecture/runtime-and-data-flow.md)
- Commit or PR: Not created

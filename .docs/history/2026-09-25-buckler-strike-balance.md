# 2026-09-25: Buckler Strike damage, cooldown, and Blade Twisting balance

Status: Partial

## Intent

Raise Buckler Strike's attack-power contribution, guarantee Blade Twisting on successful hits, and offset the stronger impact with a longer cooldown.

## Scope

### Code and data

- `src/mod_apocalipse_rogue_buckler_strike.cpp`: changes the AP coefficient from 20 percent to 110 percent, validates stock Blade Twisting trigger 51585, applies it after every successful damage-effect hit, and validates a 20-second cooldown.
- `data/sql/db-world/2026_09_22_06_buckler_strike.sql`: gives fresh installations the current 20-second cooldown and description.
- `data/sql/db-world/2026_09_25_00_buckler_strike_balance.sql`: updates recognized existing spell 901078 rows without replaying the recorded original migration.

### Documentation

- Updated the Buckler Strike owner page, runtime architecture, ownership boundary, playerbot behavior, operations ledger, root feature list, and history index.

## Contracts changed

- Hooks or registration: The existing Buckler Strike SpellScript adds an effect-hit handler for effect 0. Registration is unchanged.
- Human behavior: Buckler Strike deals `floor(1.10 * AP + 1.50 * SBV)` pre-mitigation damage, applies Blade Twisting 51585 after every successful damage-effect hit, and has a 20-second cooldown.
- Bot behavior: Identical mechanics. Acquisition, shield selection, and cast policy remain external.
- Configuration: None.
- Database or migration: Adds one guarded automatic world update for recognized existing spell 901078 rows.
- Custom spell/client data: The 901078 client row requires the 20-second cooldown and current description. Blade Twisting 51585 is stock client data.
- Deployment or rollback: Requires the automatic update, module rebuild, updated client export, restart, and focused runtime checks. Rollback restores the six-second cooldown, prior description, 20 percent AP coefficient, and source without the 51585 hook.

## Decisions

- Reused 51585 because offline WotLK `Spell.dbc` evidence shows rank 2 Blade Twisting passive 31126 triggers that debuff.
- Applied 51585 directly without requiring talent 31126 because the requested Buckler Strike behavior is unconditional.
- Used the successful effect 0 hit hook instead of a random proc roll, giving 100 percent application on landed damage effects while leaving miss, dodge, parry, immunity, and daze handling to the core.
- Preserved the 150 percent shield block value term, 25 Energy cost, combo point, threat, and non-player interrupt contracts.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Stock Blade Twisting trace | Read-only extraction of spells 31124, 31125, 31126, and 51585 from local WotLK `Spell.dbc`; inspect core proc metadata | Passed: rank 2 passive 31126 triggers 51585 |
| Source and migration review | Inspect C++ validation and hooks, original migration, and guarded follow-up update | Passed |
| Static diff validation | `git diff --check` and focused changed-file review | Passed |
| Parent custom-core build | Build `worldserver` with this module and `mod-playerbots` | Not run because the core repository rules require an explicit build request |
| Updater, client, and gameplay | Apply migration, export client row, and run the Buckler Strike owner-page matrix | Not run |

## Follow-up

- Build against the deployment core and confirm the effect-hit hook compiles on the exact branch.
- Apply the automatic update in a backed-up deployment environment and export the matching client row.
- Test normal, avoided, immune, absorbed, player, creature, human, and playerbot targets.

## References

- Custom spell: [`../custom-spells/buckler-strike.md`](../custom-spells/buckler-strike.md)
- Architecture: [`../architecture/runtime-and-data-flow.md`](../architecture/runtime-and-data-flow.md)
- Commit or PR: Not created

# 2026-09-18: Automatic Ice Lance proc eligibility

Status: Partial

## Intent

Increase the effective Automatic Ice Lance proc frequency by allowing periodic and triggered Mage Frost damage to participate in the existing 10 percent roll and one-second internal cooldown.

## Scope

### Code and data

- `src/mod_apocalipse_mage_automatic_ice_lance.cpp`: removes the triggered-spell, direct-damage, and Frost Bomb Explosion exclusions while retaining player ownership, Mage Frost, Ice Lance recursion, damage, and target guards.
- `data/sql/db-world/2026_09_17_04_automatic_ice_lance.sql`: gives fresh installations the broadened proc definition and current passive descriptions.
- `data/sql/db-world/2026_09_18_01_automatic_ice_lance_proc_eligibility.sql`: updates recognized existing installations because an already recorded updater file does not run again.

### Documentation

- `README.md`, architecture, custom-spell, operations, and playerbot pages now describe direct, periodic, and triggered Frost eligibility.

## Contracts changed

- Hooks or registration: None.
- Human behavior: Periodic and triggered Mage Frost damage can now trigger Automatic Ice Lance. Ice Lance remains excluded.
- Bot behavior: Identical to human behavior.
- Configuration: None.
- Database or migration: A new updater stores proc flags `0x00050000`, attributes mask `2`, and updated passive descriptions for recognized spell 901010 installations.
- Custom spell/client data: The matching client row needs proc mask `0x00050000` and text that no longer limits eligibility to direct, non-triggered damage.
- Deployment or rollback: Requires automatic update `2026_09_18_01_automatic_ice_lance_proc_eligibility.sql`, an updated client patch, a module rebuild, and restart.

## Decisions

- Kept the 10 percent chance and 1000 ms internal cooldown unchanged.
- Allowed both direct and periodic damage because the cooldown bounds high-frequency effects.
- Enabled triggered events in `spell_proc`; removing only the AuraScript check would still leave triggered events blocked by the core proc pipeline.
- Retained the explicit Ice Lance spell-ID rejection in addition to the core self-loop guard.
- Retained target, hostility, and line-of-sight validation so a successful proc produces a valid attack and haste contribution.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Deployment-core proc path review | Inspect `Aura::GetProcEffectMask`, `Unit::ProcSkillsAndAuras`, and periodic damage dispatch | Passed |
| Source and SQL diff review | `git diff --check` and focused diff inspection | Passed |
| Parent custom-core build | Build `worldserver` with this module and `mod-playerbots` | Not run |
| Human and bot proc frequency | Direct casts, Blizzard ticks, Frost Bomb Explosion, and triggered Frost effects | Not run |

## Follow-up

- Build against the deployment core and run the focused runtime matrix for humans and bots.
- Confirm the effective world-database row contains proc flags `0x00050000`, chance `10`, cooldown `1000`, and attributes mask `2` after deployment.

## References

- Custom spell: [`../custom-spells/automatic-ice-lance.md`](../custom-spells/automatic-ice-lance.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

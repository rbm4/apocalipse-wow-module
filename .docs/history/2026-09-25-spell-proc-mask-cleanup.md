# 2026-09-25: Custom spell proc mask cleanup

Status: Partial

## Intent

Remove AzerothCore startup validation errors caused by spell type and phase masks that do not apply to the configured incoming-event proc flags, without changing the events, chances, cooldowns, hit filtering, or scripted payloads of the affected custom spells.

## Scope

### Code and data

- `data/sql/db-world/2026_09_25_04_spell_proc_mask_cleanup.sql`: idempotently clears `SpellPhaseMask` for proc rows 901073, 901099, 901100, 901101, 901102, and 901115, and clears `SpellTypeMask` for generic taken-damage rows 901099, 901100, and 901101.

### Documentation

- `.docs/custom-spells/bladeguard.md`: records the Bladeguard phase-mask cleanup and preserved block contract.
- `.docs/custom-spells/shaman-spell-pack.md`: records the Aegis, Earthen Defiance, and Stoneguard Bulwark mask cleanup.
- `.docs/development/operations.md` and `.docs/history/README.md`: index the automatic world update and this change record.

## Contracts changed

- Hooks or registration: None.
- Human behavior: No intended gameplay change.
- Bot behavior: No intended gameplay change.
- Configuration: None.
- Database or migration: one ID-scoped automatic world update modifies existing `spell_proc` rows only when a corrected mask still differs.
- Custom spell/client data: server-side proc metadata only; no client `Spell.dbc` field changes are required.
- Deployment or rollback: run the normal world updater and review startup logs; rollback restores `SpellPhaseMask = 2` for all six rows and `SpellTypeMask = 1` for 901099 through 901101, although doing so restores the validation errors.

## Decisions

- Preserve every `ProcFlags`, `HitMask`, chance, cooldown, charge, and attribute value.
- Preserve `SpellTypeMask = 1` for 901102 and 901115 because their taken melee spell events can use the damage-type filter.
- Clear `SpellPhaseMask` for all six rows because incoming proc flags do not consume spell phase metadata.
- Restrict the update by exact custom spell IDs and differing values so rerunning it is safe and missing rows are not fabricated.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Static SQL review | Inspect exact IDs, assigned columns, and rerun predicate | Passed |
| Patch whitespace | Scoped `git diff --check` plus no-index review for new files | Passed; only existing line-ending conversion warnings were emitted |
| Database updater and startup | Authorized operator starts worldserver with updates enabled and reviews `error.log` | Not run; operator-owned |
| Human and bot gameplay | Existing Bladeguard and Shaman spell-pack verification matrices | Not run; no gameplay change intended |

## Follow-up

- Authorized operator must run the world updater and confirm the nine listed `spell_proc` validation messages no longer appear at worldserver startup.

## References

- Custom spells: [`../custom-spells/bladeguard.md`](../custom-spells/bladeguard.md) and [`../custom-spells/shaman-spell-pack.md`](../custom-spells/shaman-spell-pack.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

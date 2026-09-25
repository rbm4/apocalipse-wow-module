# 2026-09-25: Spell-script registration and validation follow-up

Status: Partial

## Intent

Remove the remaining Priest startup crash and align rejected Priest, Rogue, and Mage script bindings with the deployed spell layouts.

## Scope

### Code and data

- `src/mod_apocalipse_priest_spells.cpp`: dispatches Radiance by spell ID only from runtime hooks, finds Penance's periodic trigger effect, and supports periodic-damage and periodic-leech Priest DoTs across their real effect slots.
- `src/mod_apocalipse_rogue_improved_feint.cpp`: validates Feint rank membership without requiring the rank-8-only AoE aura on every rank.
- `src/mod_apocalipse_mage_automatic_ice_lance.cpp`: validates the two hook-bearing aura types without rejecting compatible runtime-controlled timing or amount values.
- Database and client data: unchanged.

### Documentation

- Updated the Priest pack, Improved Feint, and Automatic Ice Lance owner pages with the corrected startup contracts.
- Indexed this follow-up in `.docs/history/README.md`.

## Contracts changed

- Hooks or registration: no `GetSpellInfo()` call remains in a module script's `Register()` method; mixed-layout DoTs are filtered by runtime aura type.
- Human behavior: intended spell behavior is unchanged; previously rejected bindings can now load.
- Bot behavior: unchanged and identical to human behavior.
- Configuration: None.
- Database or migration: None.
- Custom spell/client data: None.
- Deployment or rollback: rebuild and restart are required; no database update is required.

## Decisions

- Use runtime spell-ID dispatch for Radiance because `SpellScript` has not received its bound spell during `Register()`.
- Use deployed `Spell.dbc` layouts rather than assuming SQL's one-based effect suffix maps to the same-numbered C++ effect constant.
- Keep validators focused on invariants needed by their hooks and runtime behavior.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Crash diagnosis | GDB `thread apply all bt full` on deployed `worldserver` | Passed: SIGSEGV originates in `spell_apoc_priest_radiance::script::Register()` calling `SpellScript::GetSpellInfo()` |
| Stock layout diagnosis | Read deployed `dbc/Spell.dbc` records for bound Priest and Rogue ranks | Passed: confirmed Penance effect 1, mixed Priest DoT slots/types, and rank-dependent Feint layout |
| Registration-time lookup audit | Search module `Register()` bodies for `GetSpellInfo()` | Passed after source change |
| Source and whitespace checks | `git diff --check`, registration-time lookup search, and focused diff review | Passed |
| Deployment-core build and startup | Rebuild and start worldserver | Not run; deployment remains with the operator |
| Gameplay | Exercise affected Priest, Rogue, and Mage abilities | Not run |

## Follow-up

- Rebuild, deploy, and confirm startup advances beyond spell-script validation without SIGSEGV or the affected validation errors.
- Run focused gameplay checks for Radiance, Penance, all three Priest DoT families, Improved Feint, and Ice Lance Momentum.

## References

- Priest feature: [`../features/priest-ability-pack.md`](../features/priest-ability-pack.md)
- Improved Feint: [`../custom-spells/improved-feint.md`](../custom-spells/improved-feint.md)
- Automatic Ice Lance: [`../custom-spells/automatic-ice-lance.md`](../custom-spells/automatic-ice-lance.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

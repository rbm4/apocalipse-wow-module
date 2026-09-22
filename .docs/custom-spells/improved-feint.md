# Improved Feint

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_rogue_improved_feint.cpp`, `data/sql/db-world/2026_09_22_09_improved_feint.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-22

## Purpose

Improved Feint is permanent Rogue passive 901089. Successfully casting any stock Feint rank grants separate helper aura 901090 for six seconds. The helper reduces Physical, Holy, Fire, Nature, Frost, Shadow, and Arcane damage taken by 30 percent while preserving every stock Feint effect.

## Acquisition boundary

The module defines passive 901089 and helper 901090 but does not teach the passive. Talent, trainer, item, specialization, and playerbot acquisition remain external. Only passive 901089 may be learned. Helper 901090 is internal and must not be taught or placed in a rank chain.

Humans and playerbots use identical mechanics. Existing Feint actions trigger the passive automatically, so no new bot action is required.

## Spell contract

| Surface | Contract |
|---|---|
| Passive | 901089 Improved Feint, permanent passive dummy aura |
| Trigger | Successful cast of any rank in stock Feint rank chain 1966 |
| Helper | 901090 Improved Feint Damage Reduction |
| Duration | Six seconds, refreshed to six seconds by another Feint cast |
| Reduction | Native `SPELL_AURA_MOD_DAMAGE_PERCENT_TAKEN`, -30 percent, school mask 127 |
| Dispel | `DISPEL_NONE` and cannot be stolen |
| Persistence | Helper is marked non-save; the learned passive remains the acquisition contract |
| Stock behavior | Feint cost, cooldown, threat behavior, and 40 percent AoE reduction remain unchanged |
| Startup validation | Every bound Feint rank must expose native all-school `SPELL_AURA_MOD_AOE_DAMAGE_AVOIDANCE` at -40 percent |
| Registration | `AddModApocalipseRogueImprovedFeintScripts()` |

## Damage composition

The core applies the helper through normal all-school damage-taken multiplier handling and applies stock Feint through the separate AoE avoidance multiplier. The intended factors are:

- Non-AoE damage: `original damage * 0.70`.
- AoE damage: `original damage * 0.60 * 0.70 = original damage * 0.42`.
- Total AoE reduction: 58 percent, subject to integer conversion in the normal core paths.

The reductions are multiplicative, not additive. Improved Feint does not replace, modify, or suppress stock Feint's aura.

## Runtime flow

```text
Rogue with passive 901089 successfully casts any rank of Feint
  -> stock Feint resolves without modification
  -> rank-wide script binding runs after the successful cast
  -> trigger self-cast of helper 901090
  -> helper applies or refreshes a six-second all-school 30 percent reduction
  -> ordinary damage uses factor 0.70
  -> AoE damage also uses stock Feint factor 0.60, producing factor 0.42
```

The script performs no damage hook, database query, timer update, or playerbot-specific branch. Recasting the same helper relies on native aura refresh behavior.

## Data and deployment

The guarded automatic world update collision-checks 901089 and 901090 across `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs both custom rows, a negative `-1966` rank-chain binding, non-save helper metadata, and backend names. The binding also verifies that stock Feint rank 8, spell 48659, belongs to rank chain 1966.

Matching client `Spell.dbc` rows are required. The server update, client patch, external acquisition of passive 901089, and module rebuild must ship together. Live database and deployed-client collision checks remain operator work.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Rogue without passive casts any Feint rank | Stock Feint only, no helper 901090 | Not run |
| Rogue with passive casts Feint rank 1 or rank 8 | Helper 901090 is applied for six seconds | Not run |
| Non-AoE damage while helper is active | Damage uses the native 0.70 factor | Not run |
| AoE damage while stock Feint and helper are active | Damage uses factors 0.60 and 0.70, for 0.42 before ordinary rounding | Not run |
| Feint is recast before helper expires | Helper duration refreshes to six seconds without stacking | Not run |
| Enemy attempts to dispel or steal helper | Helper remains | Not run |
| Logout while helper is active | Helper is not restored after login | Not run |
| Physical and each magical school hit the Rogue | Every listed school receives the 30 percent helper reduction | Not run |
| Human and playerbot Rogue | Identical mechanics after acquisition | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove passive 901089 from external acquisition, remove the `spell_apoc_rogue_improved_feint` binding, custom helper attributes, backend names, and spell rows 901089 and 901090, then restore the previous client patch. Rebuild without the source and loader registration before restarting.

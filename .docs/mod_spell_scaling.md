# Level-based spell scaling

Status: Implemented, source reviewed; runtime not verified in this review

Owners: `src/mod_spell_scaling.cpp`, `data/mod_spell_scaling.sql`

Last source review: 2026-09-16

## Purpose

This subsystem scales selected high-level spells when cast by players below level 80. The spell list and scale factors come from `acore_world.mod_spell_scaling`.

NPC casters are not scaled. Bot-controlled players are scaled exactly like human-controlled players.

## Formula

```text
multiplier = min((casterLevel / 80.0) * scaleFactor, 1.0)
```

The code does not clamp negative scale factors. Operational data should use positive values.

| Level | Factor 0.5 | Factor 1.0 | Factor 2.0 |
|---:|---:|---:|---:|
| 10 | 6.25% | 12.5% | 25% |
| 40 | 25% | 50% | 100% |
| 60 | 37.5% | 75% | 100% |
| 80+ | 100% | 100% | 100% |

A smaller factor produces a smaller final effect, not a gentler reduction. Existing SQL comments that describe factor 0.5 as 50 percent power at level 1 do not match the implemented formula; use the C++ formula as current behavior.

## Scale types

| Type | Hook | Actual coverage |
|---|---|---|
| `DAMAGE` | `ModifySpellDamageTaken` | Direct spell damage |
| `HEAL` | `ModifyHealReceived` | Healing events delivered through this core hook |
| `PERIODIC` | `ModifyPeriodicDamageAurasTick` | Periodic damage only in this implementation |
| `ABSORB` | `OnAuraApply` | School absorbs and mana shields on aura application |

Do not document `PERIODIC` as a generic HoT path unless the implementation gains a periodic healing hook.

## Startup and cache

`SpellScalingWorld::OnLoadCustomDatabaseTable()` clears and loads four process maps keyed by spell ID. Unknown `scale_type` strings are ignored but still contribute to the logged row count.

There is no dedicated runtime database reload command. Table changes require restart or another supported invocation of the custom-table hook.

## Event flow

```text
spell event
  -> choose map from hook type
  -> look up exact spellInfo or aura ID
  -> return unchanged when ID is absent
  -> return unchanged for NPC or level-80+ caster
  -> multiply mutable value and truncate to integer
```

For absorb auras, the handler iterates all effects, selects school absorb and mana shield effects, recalculates from the effect base through `CalculateAmount(caster)`, and applies the multiplier with `ChangeAmount()`. This is intended to avoid multiplying an already scaled refresh value.

## Database table

| Column | Meaning |
|---|---|
| `spell_id` | Exact spell entry ID |
| `scale_type` | `DAMAGE`, `HEAL`, `PERIODIC`, or `ABSORB` |
| `scale_factor` | Positive multiplier factor used by the formula |
| `description` | Operator-facing label only |

Primary key `(spell_id, scale_type)` allows one spell to participate in several hook families.

## Interactions

- Direct and periodic damage may also pass through PvP Balancing. The loader registers Spell Scaling before PvP Balancing, and integer truncation occurs at each stage.
- Blazing Barrier 901001 is seeded as `ABSORB` factor 1.0. It is currently a level-80 spell, where scaling returns 1.0.
- Ambush Strike 901040 is installed as `DAMAGE` factor 1.0. The capped percent-health amount is calculated first, then lower-level scaling and PvP reduction apply with integer truncation at each stage.
- Blood Heal 901045 is installed as `HEAL` factor 1.0. The damage-based or maximum-health base amount is calculated first, then lower-level scaling applies with integer truncation.
- Spec Manager is a major source of high-level spells granted to low-level characters, but the systems communicate only through shared spell IDs.

## Failure modes

| Failure | Result | Diagnostic |
|---|---|---|
| Missing/empty table | All caches remain empty | `[ModSpellScaling] mod_spell_scaling is empty or missing` |
| Wrong spell rank/trigger ID | Intended effect is not found | Compare combat spell ID to table row |
| Wrong scale type | Event is not intercepted | Trace the actual AzerothCore hook |
| Negative factor | Signed direct damage/heal can become invalid; unsigned paths can wrap | Validate SQL before restart |
| Absorb script recalculates unexpectedly | Custom amount may be applied more than once | Focused custom-spell runtime test |

## Adding a row

1. Identify the exact final spell or triggered spell ID seen by the hook.
2. Choose the hook family matching the actual effect.
3. Calculate expected values at representative levels from the implemented formula.
4. Insert or update the row.
5. Restart the worldserver.
6. Test human and bot casters, PvE and PvP where applicable, and every relevant rank/trigger.
7. Update this page, the owning feature/custom-spell page, README if user-visible, and the history index.

No build, database load, or runtime scaling scenario was run during the 2026-09-16 documentation review.

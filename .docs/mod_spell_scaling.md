# mod_spell_scaling.cpp

## Purpose

Implements **level-proportional scaling** for a configurable set of spells. It prevents high-level signature spells (granted by the Spec Manager) from being full-power in the hands of low-level players, preserving the difficulty of levelling content.

---

## Formula

```
multiplier = min( (playerLevel / 80.0) * scaleFactor, 1.0 )
```

| Level | scaleFactor 1.0 | scaleFactor 0.5 |
|---|---|---|
| 10 | 12.5 % | 56.25 % |
| 40 | 50.0 % | 75.0 % |
| 60 | 75.0 % | 87.5 % |
| 80 | 100 % (no change) | 100 % (no change) |

- `scaleFactor 1.0` — full linear ramp; use for spells that have no natural weakening at low level.
- `scaleFactor 0.5` — gentler ramp; use when the spell already scales down naturally (e.g. through lower weapon DPS or spell power).
- Only **player** casters are affected. NPC casters always use `m = 1.0`.

---

## Scale types

| Type | Hook | Use case |
|---|---|---|
| `DAMAGE` | `ModifySpellDamageTaken` | Direct-hit nuke spells |
| `HEAL` | `ModifyHealReceived` | Direct heals |
| `PERIODIC` | `ModifyPeriodicDamageAurasTick` | DoT / HoT ticks |
| `ABSORB` | `OnAuraApply` | Absorb shields (e.g. Ice Barrier) |

For `ABSORB`, the scaling is applied once when the aura lands by recalculating the effect base amount via `CalculateAmount`, then pushing the scaled value with `ChangeAmount`. This avoids double-applying the multiplier on aura refreshes and keeps future recalculations possible.

---

## Data flow

```
worldserver startup
  └─ SpellScalingWorld::OnLoadCustomDatabaseTable()
       └─ LoadScalingSpells()  ← reads mod_spell_scaling (acore_world)
            ├─ gDamageSpells   [spellId → scaleFactor]
            ├─ gHealSpells     [spellId → scaleFactor]
            ├─ gPeriodicSpells [spellId → scaleFactor]
            └─ gAbsorbSpells   [spellId → scaleFactor]

damage/heal/tick/absorb event
  └─ SpellScalingUnit hook
       ├─ look up spellInfo->Id in the relevant map
       ├─ if found: compute multiplier via GetLevelMultiplier()
       └─ if m < 1.0: apply reduction to damage / heal / amount
```

---

## Database table

### `acore_world.mod_spell_scaling`

| Column | Type | Description |
|---|---|---|
| `spell_id` | INT UNSIGNED | Spell entry ID |
| `scale_type` | ENUM | `DAMAGE`, `HEAL`, `PERIODIC`, or `ABSORB` |
| `scale_factor` | FLOAT | Scaling aggressiveness (see formula above) |
| `description` | VARCHAR(255) | Human-readable label (optional) |

A spell can have multiple rows with different `scale_type` values (e.g. Holy Shock has both a `DAMAGE` and a `HEAL` row).

To add a new spell: `INSERT` a row and restart the worldserver. No recompile needed.

---

## Registered scripts

| Script class | Base class | Hook used |
|---|---|---|
| `SpellScalingWorld` | `WorldScript` | `OnLoadCustomDatabaseTable` |
| `SpellScalingUnit` | `UnitScript` | `ModifySpellDamageTaken`, `ModifyHealReceived`, `ModifyPeriodicDamageAurasTick`, `OnAuraApply` |

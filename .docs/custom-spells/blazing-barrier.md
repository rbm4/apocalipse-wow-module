# Blazing Barrier

Status: Implemented in source, build and runtime not verified

Owners: `src/mod_apocalipse_mage_spells.cpp`, `data/2026_09_16_01_blazing_barrier.sql`, `data/mod_apocalipse.sql`, `data/mod_spell_scaling.sql`

Last source review: 2026-09-16 on local `main`; the manual migration was untracked during review

## Purpose

Blazing Barrier is a custom level-80 mage absorb spell using provisional spell ID 901001. Its server-side script derives the shield from the configured base amount plus fire spell power, prevents replacing a stronger existing matching barrier with a weaker cast, and integrates selected mage talent effects when damage is absorbed.

## Human and bot applicability

Human and bot-controlled mages use the same cast, absorb, recast, and talent-proc behavior. This spell path does not call `WorldSession::IsBot()` and has no bot-specific suppression or bypass.

## Spell graph

| Surface | Contract |
|---|---|
| C++ ID | `SPELL_APOC_MAGE_BLAZING_BARRIER = 901001` |
| Loader | `AddModApocalipseMageSpellScripts()` |
| Script name | `spell_apoc_mage_blazing_barrier` |
| Server spell row | Manual `data/2026_09_16_01_blazing_barrier.sql` |
| Script binding | `spell_script_names`, present in `data/mod_apocalipse.sql` and guarded in the manual migration |
| Level scaling | `ABSORB` entry in `acore_world.mod_spell_scaling` |
| Client presentation | Matching client `Spell.dbc` and patch required |

## Server spell contract

The manual migration defines spell 901001 as a level-80 fire-family, all-school absorb based on Ice Barrier rank 8:

- Base absorb: stored base points 3299, producing 3300 before script bonuses.
- Additional base absorb above level 80: 15 per level in the spell row.
- Duration: 30 seconds.
- Cooldown: 30 seconds.
- Cost: 21 percent base mana.
- Effect 0: `SPELL_AURA_SCHOOL_ABSORB` with school mask 127.
- Spell school: fire.
- Visual: Fire Ward-derived visual.
- Icon: Molten Armor-derived icon.

The server row is a full definition, not an incremental patch. Any future SQL change must preserve all required columns or deliberately reconstruct the row.

## Script behavior

### Amount

`CalculateBarrierAmount()` multiplies the caster's fire spell damage bonus by 0.8068, applies effect modifiers and the level penalty to that product, then adds it to the base absorb. The AuraScript sets `canBeRecalculated = false` after calculating the amount.

### Recast rule

Before cast, the SpellScript locates an existing school-absorb aura with the same family and icon. It calculates the proposed new barrier amount and returns `SPELL_FAILED_AURA_BOUNCED` when the existing amount is stronger.

The migration intentionally uses an icon different from Ice Barrier to avoid the icon-based lookup colliding with Ice Barrier.

### Talent interactions on absorb

When the aura absorbs damage on a player:

- Blazing Speed can receive an additional proc attempt if the proc aura is not already active.
- Fiery Payback can attempt to disarm a qualifying attacker from direct or ranged damage.
- Incanter's Absorption converts a percentage of the absorbed amount into the triggered damage bonus. An existing bonus is carried forward proportionally to its remaining duration, increased, and refreshed.

The AuraScript validates the required Incanter's Absorption spell IDs. Missing required spell data prevents successful script validation.

## Spell Scaling interaction

Spell 901001 is configured as `ABSORB` with scale factor 1.0. `SpellScalingUnit::OnAuraApply()` recalculates the final absorb effect and applies the caster-level multiplier after the aura lands.

At level 80 or above, `GetLevelMultiplier()` returns 1.0, so the scaling hook makes no change. If this spell is made available below level 80, the interaction between AuraScript amount calculation and UnitScript recalculation must be build-tested and runtime-tested to ensure spell power is not applied twice.

## Database and deployment

`data/2026_09_16_01_blazing_barrier.sql` is a manual migration and must not be moved into `data/sql/db-world/` without deliberately converting it to the automatic updater contract.

Before running it:

```sql
SELECT `ID` FROM `spell_dbc` WHERE `ID` = 901001;
SELECT `ID` FROM `wotlk_spells_full` WHERE `ID` = 901001;
SELECT `ID` FROM `wotlk_spells` WHERE `ID` = 901001;
```

All must be clear for the first deployment, and the selected client `Spell.dbc` must be inspected separately. Run the migration while `worldserver` is stopped, then export and distribute matching client spell data.

The migration also:

- Adds the script binding if its spell insert succeeded.
- Adds the `ABSORB` scaling row if the scaling table exists.
- Adds the backend spell picker name.

`data/mod_apocalipse.sql` already inserts the script binding, and `data/mod_spell_scaling.sql` already seeds the scaling row. The migration uses guarded or `INSERT IGNORE` operations for these duplicate baseline cases.

## Failure modes

| Failure | Result | Detection and recovery |
|---|---|---|
| ID 901001 collision | Migration aborts rather than intentionally overwrite the existing spell | Allocate a new ID and update C++, SQL, scaling, docs, and client data together |
| Missing script binding | Spell has data but custom amount/procs/recast behavior do not attach | Check `spell_script_names` and startup script validation |
| Missing server row | Script cannot operate as a real absorb spell | Apply the manual migration while stopped and restart |
| Missing client row | Missing or incorrect name, icon, tooltip, or cast presentation | Export and distribute matching client `Spell.dbc` |
| Missing scaling table | Migration's scaling insert cannot complete | Apply `data/mod_spell_scaling.sql` first |
| Low-level double calculation | Absorb may be larger than intended | Keep level-80-only access until focused runtime verification is complete |

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Level-80 mage casts with known fire spell power | Absorb equals base plus expected 80.68 percent contribution | Not run |
| Recast weaker barrier over stronger one | Cast is rejected with aura bounced | Not run |
| Recast stronger barrier | New barrier replaces weaker one | Not run |
| Absorb with Blazing Speed | Extra proc follows talent chance and does not duplicate active proc aura | Not run |
| Qualifying Fiery Payback hit | Disarm proc uses reduced chance derived from talent amount | Not run |
| Incanter's Absorption active | Triggered damage bonus is applied or refreshed from absorbed amount | Not run |
| Level below 80 through GM/test access | Final absorb is scaled once | Not run |
| Client without patch | Failure presentation is documented before production rollout | Not run |

## Open items

- Replace provisional ID 901001 if live collision checks fail.
- Track and review the currently untracked manual migration before release.
- Verify whether low-level absorb recalculation applies the custom spell-power contribution exactly once.
- Build and execute the full runtime matrix on the target custom core and client patch.

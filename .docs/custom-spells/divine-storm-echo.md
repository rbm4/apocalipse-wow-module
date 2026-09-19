# Divine Storm Echo

Status: Implemented in source, build and runtime not verified

Owners: `src/mod_apocalipse_paladin_divine_storm_echo.cpp`, `data/sql/db-world/2026_09_18_02_divine_storm_echo.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-18

## Purpose

Divine Storm Echo is a Retribution Paladin passive that schedules a second Divine Storm one second after the paladin completes normal Divine Storm 53385. The echo deals 55 percent weapon damage, half of the original spell's 110 percent, and retains normal Divine Storm targeting, independent hit and critical strike results, proc eligibility, and proportional healing.

## Acquisition boundary

The module defines unranked passive 901014 and echo attack 901015. It does not teach passive 901014 or modify talent, trainer, item, specialization, or playerbot acquisition data. The existing acquisition owner must reference exactly 901014 as a single-rank passive and provide matching client data. Echo 901015 must not have an acquisition or rank entry. No checked-in acquisition reference to 901014 was found in the four workspace repositories, so validation of the existing external acquisition flow remains pending.

## Human and bot applicability

Human and bot-controlled paladins use identical scheduling, target selection, damage, healing, and proc behavior. The script performs no bot detection and no database work in combat. Existing playerbot Divine Storm actions need no changes because the echo is triggered automatically.

## Spell graph

| Spell | Role | Contract |
|---:|---|---|
| 53385 | Existing Divine Storm | The module script schedules one echo only when passive 901014 is active |
| 901014 | Divine Storm Echo passive | Permanent self dummy aura used as the scheduling and execution gate |
| 901015 | Divine Storm Echo Damage | Triggered 55 percent weapon attack with the original family, school, radius, targets, animation, and healing percentage |
| 54171 | Existing Divine Storm heal distributor | Receives healing totals derived from each echo victim's final damage |
| 54172 | Existing Divine Storm heal | Distributes the resulting heal through the existing core script |

## Runtime flow

```text
paladin with passive 901014 completes Divine Storm 53385
  -> AfterCast schedules an owner-bound event for one second later
  -> event resolves the caster GUID
  -> caster must remain in world, alive, and affected by passive 901014
  -> caster triggers echo attack 901015 on self
  -> targets are selected around the caster at execution time, up to 12 enemies
  -> each target independently resolves hit, critical strike, and normal weapon procs
  -> existing spell_pal_divine_storm derives healing from final damage
```

The original target is intentionally not retained. Movement during the delay changes which enemies are in range. Multiple completed Divine Storm casts can own independent delayed events. The 12-target limit matches the deployment core's correction for 53385, rather than the stock client row's lower limit.

## Damage, healing, and proc contract

The base Divine Storm weapon effect stores 109 base points, which evaluates to 110 percent weapon damage. The echo weapon-percent effect stores 54 base points, which evaluates to 55 percent. The deployment core normalizes the original only through a 53385 spell-ID special case. Echo 901015 therefore replaces the unused first dummy effect with a zero-damage `SPELL_EFFECT_NORMALIZED_WEAPON_DMG` marker that shares the later weapon effect's area selector. The core groups both effects into one target list, skips the earlier weapon handler because a later weapon effect exists, then sees the marker while processing the 55 percent weapon effect and uses normalized main-hand damage without a core change, flat 55-damage bonus, or separate zero-damage proc target.

The echo retains Divine Storm's 25 percent healing dummy value. Binding core script `spell_pal_divine_storm` to 901015 makes each successful echo hit contribute healing from its final damage through existing spells 54171 and 54172.

Spell 901015 has no equipped-item requirement because the deployment core does not honor `TRIGGERED_IGNORE_EQUIPPED_ITEM_REQUIREMENT` in its spell checks. A valid original Divine Storm can therefore still produce its delayed echo if equipment changes during the delay. The echo still calculates current normalized main-hand damage, can crit independently, and can trigger seals, weapon procs, Art of War, Righteous Vengeance, trinkets, and other eligible effects. This amplification is intentional. Recursion is prevented structurally because the scheduling script is bound only to 53385, never to 901015.

## Database contract

The automatic world update:

1. Collision-checks 901014 and 901015 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`.
2. Inserts only missing rows and recognizes only their expected signatures as module-owned.
3. Defines 901015 from the verified 53385 DBC structure with zero mana cost, cooldown, and global cooldown, no equipped-item requirement, normalized 55 percent weapon damage, and a 12-target cap.
4. Repairs recognized earlier 901015 signatures by moving normalization to a zero-damage effect 0 marker while retaining effect 2 as the 55 percent weapon multiplier.
5. Binds 53385 to `spell_apoc_paladin_divine_storm_echo` and 901015 to existing core script `spell_pal_divine_storm`.
6. Synchronizes `wotlk_spells` names while the backend exporter reads complete client rows from `spell_dbc` using `wotlk_spells_full` column metadata.

Matching client `Spell.dbc` rows are required for both custom IDs. Repository allocation search and both checked-in backend bases, `Spell.dbc` and `SpellExtracted.dbc`, contained neither ID before this feature. Live world tables and the selected deployment client remain pending collision checks.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Paladin without passive 901014 casts 53385 | No echo is scheduled | Not run |
| Paladin with passive remains alive and in world | One 901015 cast occurs after one second | Not run |
| Paladin dies, logs out, or loses the passive during the delay | Scheduled event produces no echo | Not run |
| Paladin moves during the delay | Echo selects up to 12 enemies around the new position | Not run |
| Echo damage and critical strikes | Each target resolves independently at 55 percent weapon damage | Not run |
| Echo proc eligibility | Eligible seals, weapon procs, talents, and trinkets can trigger | Not run |
| Echo healing | Existing Divine Storm scripts produce healing proportional to final echo damage | Not run |
| Human and playerbot paladin | Identical behavior while passive 901014 is active | Not run |
| Recursive scheduling | Echo 901015 never schedules another echo | Not run |

## Rollback

Stop worldserver, take the normal world-database backup, remove the exact 53385 scheduling and 901015 healing bindings, remove 901014 and 901015 from `wotlk_spells` and `spell_dbc`, restore the previous client patch, rebuild without the registration and source, then restart. Acquisition data is external and must be rolled back by its owner.

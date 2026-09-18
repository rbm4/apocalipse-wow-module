# Frost Bomb

Status: Implemented in source, build and runtime not verified

Owners: `src/mod_apocalipse_mage_frost_bomb.cpp`, `data/sql/db-world/2026_09_17_03_frost_bomb.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-17

## Purpose

Frost Bomb is a level-80 active Frost Mage spell using provisional IDs 901007, 901008, and 901009. It places a four-second hostile aura on one enemy, then deals target-centered Frost area damage and slows every living damage victim.

## Acquisition boundary

The module defines the spell graph and runtime behavior but does not teach or grant spell 901007. Trainer, talent, item, specialization, and playerbot rotation changes remain outside this feature. Matching client `Spell.dbc` rows are required for all three custom IDs.

## Human and bot applicability

Human and bot-controlled mages use identical cast, cooldown, removal, damage, proc, and slow behavior. The scripts perform no bot detection and no database queries in combat. Acquisition and playerbot rotation policy remain external.

## Spell graph

| Surface | Contract |
|---|---|
| Application | 901007 Frost Bomb, 1.5 second cast, 16 second cooldown, 22 percent base mana, four-second Magic aura |
| Explosion | 901008 Frost Bomb Explosion, 690 base Frost area damage, 10-yard target-centered radius, 0.4 direct coefficient |
| Slow | 901009 Frost Bomb Slow, 40 percent for five seconds before Permafrost |
| Permafrost talent | Rank chain beginning at 11175; effect 0 extends duration and effect 1 increases slow strength |
| Permafrost debuff | Existing spell 68391, applied while the custom slow is active for the same caster |
| Registration | `AddModApocalipseMageFrostBombScripts()` |
| Server migration | `data/sql/db-world/2026_09_17_03_frost_bomb.sql` |

## Runtime flow

```text
successful Frost Bomb cast on one enemy
  -> spend 22 percent base mana and start the 16 second cooldown
  -> apply the four-second dummy aura
  -> remove by expiration, enemy dispel, or target death
     -> trigger Frost Bomb Explosion at the bombed target
     -> deal Frost damage to enemies within 10 yards
     -> apply Frost Bomb Slow to each living damage victim
     -> apply the existing Permafrost healing-reduction aura when talented
```

Default removal, caster cancellation, logout cleanup, talent reset cleanup, and generic script cleanup do not detonate Frost Bomb. A missing caster also prevents detonation, which keeps logout cleanup from creating an ownerless explosion.

## Permafrost scaling

The slow script reads the caster's ranked Permafrost aura rather than hard-coding the currently learned spell ID. Its effects produce this contract:

| Permafrost rank | Slow | Duration |
|---:|---:|---:|
| None | 40 percent | 5 seconds |
| 1 | 44 percent | 6 seconds |
| 2 | 47 percent | 7 seconds |
| 3 | 50 percent | 8 seconds |

When Permafrost is present, spell 68391 supplies its existing rank-scaled healing reduction. Removing Frost Bomb Slow removes only the 68391 aura owned by the same caster.

## Proc and crowd-control contract

The explosion uses the Mage Frostbolt family bit. This places its damage in the existing Frost proc masks and lets it use the core frozen-target and Fingers of Frost aura-state checks without consuming a charge when the application aura is placed four seconds earlier. The explosion is triggered without `TRIGGERED_DISALLOW_PROC_EVENTS`, and `SPELL_ATTR2_ACTIVE_THREAT` is present, so damage talents and trinkets can observe it.

Unlike the core Living Bomb correction, Frost Bomb does not set target-proc suppression and does not set damage-does-not-break-auras. Its damage can therefore break crowd control and produce normal target-side and damage-based proc events. Exact Fingers of Frost, Brain Freeze, Shatter, trinket, and per-victim proc results still require runtime validation against the deployment core.

## Targeting and death removal

The explosion uses `TARGET_DEST_TARGET_ENEMY` with `TARGET_UNIT_DEST_AREA_ENEMY`, radius index 13, matching the module's established target-centered 10-yard area pattern. The primary target is retained by the default selector while valid.

The explosion spell allows a dead explicit target so `AURA_REMOVE_BY_DEATH` can still establish the destination. The dead primary cannot receive the slow, but nearby living damage victims can. This path must be verified in game because target death and aura teardown ordering are core-sensitive.

## Database contract

The automatic world update:

1. Collision-checks 901007, 901008, and 901009 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`.
2. Inserts only missing rows and recognizes only the expected spell signatures as module-owned.
3. Binds the application AuraScript, explosion SpellScript, and slow AuraScript.
4. Adds the explosion's 0.4 direct coefficient to `spell_bonus_data`.
5. Synchronizes all three backend spell names.

The update contains no acquisition, rank-chain, `spell_proc`, or module spell-scaling rows. Proc integration comes from native spell family metadata and the core proc system.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Normal expiration after four seconds | One target-centered explosion | Not run |
| Enemy dispel | One immediate explosion | Not run |
| Bombed target dies | One explosion centered on the dead target and damage to valid nearby enemies | Not run |
| Caster logout or generic cleanup | No explosion | Not run |
| Primary and nearby enemies | Each valid damage victim takes one hit and each living victim receives the slow | Not run |
| No Permafrost and ranks 1 through 3 | Slow and duration follow the documented 40/44/47/50 and 5/6/7/8 matrix | Not run |
| Permafrost healing reduction | Spell 68391 appears only while the same caster's Frost Bomb Slow is active | Not run |
| Fingers of Frost and Brain Freeze | Existing talent chances observe Frost Bomb through Mage Frost family metadata | Not run |
| Frozen target or Fingers of Frost charge | Explosion receives Shatter treatment and consumes a qualifying charge through core aura-state logic | Not run |
| Crowd control and damage trinkets | Damage breaks eligible crowd control and triggers eligible proc effects | Not run |
| Human and playerbot mage | Identical mechanics when spell 901007 is known and cast | Not run |

## Rollback

Stop worldserver, take the normal world-database backup, remove 901007 through 901009 from `spell_script_names`, remove 901008 from `spell_bonus_data`, remove all three IDs from `wotlk_spells` and `spell_dbc`, restore the previous client patch, rebuild without the Frost Bomb registration and source, then restart. Acquisition data is external and must be rolled back by its owner if later added.

# Automatic Ice Lance

Status: Implemented in source; structural haste-aura validation fix applied, rebuild and runtime not verified

Owners: `src/mod_apocalipse_mage_automatic_ice_lance.cpp`, `data/sql/db-world/2026_09_17_04_automatic_ice_lance.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-18

## Purpose

Automatic Ice Lance is a Frost Mage passive using provisional spell 901010. Mage-family Frost spell damage, including direct, periodic, and triggered damage, has a 10 percent chance to cast existing Ice Lance 30455 at the damaged target and add one independently expiring contribution to haste aura 901011.

## Acquisition boundary

The module defines both custom spell rows and runtime behavior but does not teach or grant passive 901010. Talent, trainer, item, specialization, and playerbot policy changes remain external. Matching client `Spell.dbc` rows are required for 901010 and 901011.

## Human and bot applicability

Human and bot-controlled mages use identical proc, targeting, Ice Lance, Fingers of Frost, haste, cap, and cleanup behavior. The scripts perform no bot detection and no database work in combat.

## Spell graph

| Surface | Contract |
|---|---|
| Passive | 901010 Automatic Ice Lance, permanent dummy aura |
| Trigger | 10 percent chance with a 1000 ms internal cooldown |
| Damage filter | Mage-family Frost spell damage, including direct, periodic, and triggered damage; Ice Lance itself is excluded |
| Automatic attack | Existing Ice Lance 30455, cast instantly and without cost or global cooldown |
| Haste | 901011 Ice Lance Momentum, 1 percent spell haste per active contribution |
| Expiration | Each contribution expires 10 seconds after its own proc |
| Cap | 20 active contributions; a proc at cap does not refresh older expirations |
| Update | 1000 ms periodic cleanup removes every overdue contribution |
| Registration | `AddModApocalipseMageAutomaticIceLanceScripts()` |
| Server migration | `data/sql/db-world/2026_09_17_04_automatic_ice_lance.sql` |

## Runtime flow

```text
eligible Mage-family Frost damage hit
  -> spell_proc applies the 10 percent roll and 1000 ms cooldown
  -> passive AuraScript validates cast origin, damage type, and target
  -> trigger Ice Lance 30455 on the proc target
  -> add one expiration at current monotonic time plus 10 seconds
  -> set haste amount to the active expiration count
  -> periodically remove all overdue expirations and recalculate haste
  -> remove haste aura when no expiration remains
```

## Proc and recursion contract

The `spell_proc` row filters to Mage family, Frost school, damage hit events from direct magic damage or periodic damage. `PROC_ATTR_TRIGGERED_CAN_PROC` allows triggered Frost damage to enter the same path. The AuraScript additionally requires the aura owner to be a player and the event actor, requires damage information, and rejects Ice Lance 30455 explicitly. Frost Bomb Explosion, Blizzard ticks, and other Mage-family Frost damage can qualify.

The automatic Ice Lance is cast with the Mage as caster and original caster. Its trigger flags retain proc events so existing Fingers of Frost can consume a charge. Automatic Ice Lance cannot recurse because both the core self-loop guard and the AuraScript reject Ice Lance as the triggering spell. The 1000 ms internal cooldown bounds chains involving other triggered Frost effects.

## Target contract

The target is resolved from `GetProcTarget()` with `GetActionTarget()` as fallback. Before the proc chance is rolled, the script requires a non-null living target in the same map, unobstructed full line of sight, a valid hostile attack target, and successful Ice Lance explicit and unit target checks. Walls, pillars, and any other collision geometry recognized by the deployment core therefore prevent the proc instead of merely causing the triggered cast to fail. A failed target check produces neither Ice Lance nor haste and does not start the proc cooldown.

## Independent haste expirations

Aura 901011 owns a memory-only FIFO of monotonic expiration times. Applying or reapplying it first removes every overdue entry, then appends one expiration unless 20 remain active. The visible aura duration is set to the newest expiration without changing older entries. Each periodic tick removes all overdue entries and changes `SPELL_AURA_HASTE_SPELLS` effect 0 to the active count.

The haste aura is marked non-save in `spell_custom_attr`. Removing passive 901010 also removes aura 901011. This clears temporary combat state on logout, stale login state, talent removal, and specialization removal without character-database persistence.

Startup validation requires the haste aura and periodic dummy effects used by the hooks. Duration, contribution amount, and cleanup cadence remain enforced by the runtime script rather than rejecting an otherwise compatible installed row during script validation.

## Database contract

The automatic world update:

1. Collision-checks 901010 and 901011 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`.
2. Inserts only missing rows and recognizes only their expected signatures as module-owned. The 10 percent passive stores `EffectBasePoints_1 = 9` because AzerothCore adds one when interpreting spell base points; both ownership predicates must compare against that stored value so an applied migration remains rerunnable.
3. Adds the 10 percent, 1000 ms `spell_proc` definition for direct and periodic Mage Frost damage and enables triggered spells to qualify.
4. Binds both AuraScripts and marks haste aura 901011 non-save.
5. Synchronizes both backend spell names.

The follow-up automatic update `data/sql/db-world/2026_09_18_01_automatic_ice_lance_proc_eligibility.sql` applies the broadened proc masks and descriptions to recognized existing installations. The matching client `Spell.dbc` row also needs the updated proc mask and text.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Direct non-critical Frost spell hit | 10 percent proc eligibility | Not run |
| Critical direct Frost spell hit | Same 10 percent proc eligibility | Not run |
| Periodic Mage Frost damage | 10 percent proc eligibility, limited by the shared cooldown | Not run |
| Triggered Mage Frost damage and Blizzard damage | 10 percent proc eligibility, limited by the shared cooldown | Not run |
| Frost Bomb Explosion 901008 | 10 percent proc eligibility, limited by the shared cooldown | Not run |
| Normal or automatic Ice Lance 30455 | No proc recursion | Not run |
| Automatic Ice Lance with Fingers of Frost | Ice Lance consumes Fingers of Frost normally | Not run |
| Invalid, dead, friendly, cross-map, or line-of-sight-blocked target | No proc, Ice Lance, haste contribution, or internal cooldown | Not run |
| Contributions at 0 and 7 seconds | First expires near 10 seconds and second near 17 seconds | Not run |
| Multiple overdue contributions before one tick | Every overdue timestamp is removed in that tick | Not run |
| Twenty active contributions | Haste is capped at 20 percent and later procs do not refresh old entries | Not run |
| Passive removal, logout, or spec change | Haste aura and memory-only queue are cleared | Not run |
| Human and playerbot mage | Identical mechanics while passive 901010 is known | Not run |

## Rollback

Stop worldserver, take the normal world-database backup, remove 901010 from `spell_proc`, remove 901010 and 901011 from `spell_script_names`, `spell_custom_attr`, `wotlk_spells`, and `spell_dbc`, restore the previous client patch, rebuild without the registration and source, then restart. Acquisition data is external and must be rolled back by its owner if later added.

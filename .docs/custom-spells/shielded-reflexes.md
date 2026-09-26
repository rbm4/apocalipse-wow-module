# Shielded Reflexes

Status: Implemented in source and data; database, client, build, startup, and runtime not verified

Owners: `src/mod_apocalipse_rogue_shielded_reflexes.cpp`, `data/sql/db-world/2026_09_25_03_shielded_reflexes.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-25

## Purpose

Shielded Reflexes is single-rank Rogue passive 901158. While the Rogue has a usable offhand shield, blocking a melee or ranged attack grants the stock Evasion 5277 and Blade Flurry 13877 auras for at least six seconds. The passive has one native 30-second internal cooldown.

## Acquisition boundary

The migration defines but does not teach passive 901158. The existing external talent, trainer, item, or specialization flow must reference only 901158. Stock Evasion and Blade Flurry remain normal learnable Rogue abilities and are not acquisition children of this passive.

Humans and playerbots use identical mechanics. The passive needs no cast-decision action, while shield selection remains playerbot policy.

## Spell contract

| Surface | Contract |
|---|---|
| Passive | 901158 Shielded Reflexes, permanent passive dummy aura |
| Equipment gate | Usable, unbroken offhand shield; armor class 4, subclass mask 64, inventory mask 16384 |
| Proc events | Taken melee auto attacks and taken melee or ranged damage-class spells |
| Proc result | Hit mask must include `PROC_HIT_BLOCK`, including partial or full blocks |
| Buffs | Triggered stock Evasion 5277 and Blade Flurry 13877 self-casts |
| Duration | A missing or shorter stock aura is raised to 6000 ms; a longer existing aura is never shortened |
| Internal cooldown | Native aura-owned `spell_proc` cooldown of 30000 ms |
| Registration | `AddModApocalipseRogueShieldedReflexesScripts()` |

The script validates the passive's Rogue family, shield masks, dummy effect, stock Evasion dodge aura, and stock Blade Flurry melee-haste aura at startup. Triggered casts do not spend Energy, start the stock active cooldowns, or require the Rogue to have learned either stock active.

## Runtime flow

```text
learned passive 901158 plus usable shield
  -> core item-dependent passive handling applies Shielded Reflexes
  -> a taken melee or ranged attack resolves with PROC_HIT_BLOCK
  -> AuraScript rechecks Rogue class and a usable, unbroken offhand shield
  -> native spell_proc starts one 30-second internal cooldown
  -> missing stock Evasion 5277 and Blade Flurry 13877 auras are triggered
  -> each aura with less than six seconds remaining is raised to six seconds

shield removed, broken, or unusable
  -> item-dependent passive is inactive or the script rejects the proc
  -> no cooldown or stock buff is created
```

Blade Flurry retains the deployment core's `spell_rog_blade_flurry` binding. Its melee-haste effect and replicated nearby attack behavior are therefore stock behavior. Evasion retains its stock 50 percentage-point dodge effect. If either stock aura already has more than six seconds remaining, Shielded Reflexes does not refresh or shorten it.

## Data and client export

The guarded automatic world update reserves repository range 901158 through 901158 and collision-checks that ID across `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs the complete `spell_dbc` row, exact `spell_proc` row, script binding, and backend name cache.

The backend release builder reads custom rows from `spell_dbc`, uses `wotlk_spells_full` as the ordered 234-field schema and stock base, and appends custom IDs to the generated `Spell.dbc`. No second export path or direct `wotlk_spells_full` insertion is required. The matching client export and publication remain operator work.

Offline repository evidence proves 901158 is unused by the module ledger but cannot prove the live world database or deployed client is collision-free. Live collision validation remains pending.

## Cleanup and failure behavior

The proc creates no custom helper aura or module-owned timer. Stock aura expiration and removal own cleanup. Unequipping the shield does not remove already granted Evasion or Blade Flurry early; they expire through their at-least-six-second stock aura lifetime. Logout follows normal stock aura persistence rules.

If either stock spell is missing or its expected effect layout changes, startup validation disables the script rather than running against an incompatible contract. No database query, delayed event, per-tick update, global map, or bot AI dependency is added.

## Verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Rogue lacks passive 901158 | Blocks have no new effect | Not run |
| Passive learned without a shield | Parent is inactive and blocks grant no buffs | Not run |
| Usable shield and eligible partial or full block | Evasion and Blade Flurry appear with at least six seconds remaining | Not run |
| Dodge, parry, miss, absorb, or ordinary hit without block | No proc and no internal cooldown | Not run |
| Another block inside 30 seconds | No refresh from Shielded Reflexes | Not run |
| Block after 30 seconds | Both stock effects are granted again | Not run |
| Existing stock aura has under six seconds remaining | That aura is raised to six seconds | Not run |
| Existing stock aura has over six seconds remaining | Longer duration is preserved | Not run |
| Shield is broken or removed | Later attacks cannot proc the passive | Not run |
| Human and playerbot Rogue | Identical mechanics | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Revoke external acquisition of 901158, remove its script and proc rows, remove its backend name and `spell_dbc` row, restore the prior client patch, and rebuild without the source and loader registration before restarting.

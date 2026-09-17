# Prismatic Barrier

Status: Implemented in source, build and runtime not verified

Owners: `src/mod_apocalipse_mage_prismatic_barrier.cpp`, `data/sql/db-world/2026_09_17_02_prismatic_barrier.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-17

## Purpose

Prismatic Barrier is a level-80 active Arcane Mage spell using provisional spell ID 901006. A successful cast activates Mana Shield rank 9, Ice Barrier rank 8, and custom Blazing Barrier together.

## Acquisition boundary

The module defines spell 901006 and its runtime behavior but does not teach or grant it. Trainer, talent, item, or specialization acquisition remains outside this change.

A matching client `Spell.dbc` row is required before players can use the spell normally. The backend spell cache receives its name, but that does not replace the client patch.

## Human and bot applicability

Human and bot-controlled mages use the same mana cost, cooldown, triggered spells, aura scripts, and absorb behavior. The script performs no bot detection or database queries in combat. Acquisition and playerbot rotation policy remain external.

## Spell graph

| Surface | Contract |
|---|---|
| Active spell | `SPELL_APOC_MAGE_PRISMATIC_BARRIER = 901006` |
| Mana Shield | Rank 9 spell 43020, using core rank-chain script `spell_mage_mana_shield` |
| Ice Barrier | Rank 8 spell 43039, using core rank-chain scripts `spell_mage_ice_barrier` and `spell_mage_ice_barrier_aura` |
| Blazing Barrier | Custom spell 901001, using `spell_apoc_mage_blazing_barrier` |
| Script | `spell_apoc_mage_prismatic_barrier` |
| Registration | `AddModApocalipseMagePrismaticBarrierScripts()` |
| Server migration | `data/sql/db-world/2026_09_17_02_prismatic_barrier.sql` |
| Client presentation | Matching client `Spell.dbc` required |

## Runtime flow

```text
successful Prismatic Barrier cast on self
  -> charge 42 percent base mana and start the 45 second cooldown
  -> trigger Mana Shield rank 9 on the caster
  -> trigger Ice Barrier rank 8 on the caster
  -> trigger Blazing Barrier on the caster
  -> each resulting aura uses its existing core or module AuraScript
```

The three child casts are triggered casts. They do not charge additional mana, start their normal spell cooldowns, or add separate global cooldowns. They still create the real child auras, so normal absorb calculations, talent interactions, dispels, aura replacement rules, and visuals remain owned by those spells.

## Mana, cooldown, and targeting

- Instant self-cast through casting-time index 1 and range index 1.
- 42 percent base mana, exactly twice the 21 percent barrier baseline used by Blazing Barrier and the level-80 original barriers.
- 45 second spell cooldown.
- Normal 1.5 second Mage global cooldown.
- Arcane school and Mage spell family.
- No duration on the parent spell. Each child aura retains its own duration.

## Database contract

The automatic world update:

1. Collision-checks 901006 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`.
2. Recognizes only the expected Prismatic Barrier signature as module-owned.
3. Inserts the self-targeted script-effect spell row when absent.
4. Binds `spell_apoc_mage_prismatic_barrier`.
5. Synchronizes the backend name cache.

The migration does not add acquisition data or a scaling row. Mana Shield, Ice Barrier, and Blazing Barrier continue through their existing spell data and scripts.

## Failure modes

| Failure | Result | Detection and recovery |
|---|---|---|
| Spell 901006 missing | Script cannot bind to or validate the active spell | Check module updater execution and restart worldserver |
| Script binding missing | The cast spends mana and starts cooldown but does not activate barriers | Check `spell_script_names` for 901006 |
| Child spell 43020, 43039, or 901001 missing | Script validation fails | Restore matching core data or deploy Blazing Barrier first |
| Child rank-chain binding missing | The corresponding original barrier loses scripted calculations or talent behavior | Restore the base `spell_script_names` rows |
| Foreign 901006 collision | Automatic update fails before related rows are written | Allocate a new ID and update source, SQL, client data, and docs together |
| Client spell row missing | The client cannot present or cast Prismatic Barrier normally | Export and deploy the matching client `Spell.dbc` |

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Cast with enough mana and no barriers active | All three child auras appear and the 45 second cooldown starts | Not run |
| Mana use | Exactly 42 percent base mana is spent once | Not run |
| Child spell cooldowns ready or unavailable | Only Prismatic Barrier starts a cooldown | Not run |
| Existing stronger child barrier | Existing child recast rules apply without removing unrelated barriers | Not run |
| Damage reaches each absorb layer | Each aura uses its normal amount, depletion, and talent behavior | Not run |
| Human mage and playerbot mage | Identical spell results | Not run |
| Client patch missing | Spell is unavailable or incorrectly presented | Not run |

## Rollback

Stop worldserver, take the normal world-database backup, remove the 901006 rows from `spell_script_names`, `wotlk_spells`, and `spell_dbc`, restore the previous client patch, rebuild without the Prismatic Barrier registration and source, then restart. Acquisition data is outside this feature and must be rolled back by its owner if added later.

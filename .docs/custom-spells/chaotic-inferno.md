# Chaotic Inferno

Status: Implemented and source reviewed, build and runtime not verified

Owners: `src/mod_apocalipse_warlock_chaotic_inferno.cpp`, `data/sql/db-world/2026_09_20_05_chaotic_inferno.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-20

## Purpose

Chaotic Inferno is a custom Destruction Warlock passive using spell ID 901031. Every successful Chaos Bolt impact calls down a separate Infernal at the target's position, applies the stock Inferno impact damage and area stun, and leaves the Infernal assisting its owner for 20 seconds.

## Acquisition boundary

The module defines and consumes passive 901031 but does not grant it or modify talent data. The separate talent-data workflow must teach 901031. Helper spell 901032 and creature 900002 are implementation-only and must never be acquisition targets.

## Human and bot applicability

Human and bot-controlled Warlocks use identical hit, summon, impact, ownership, scaling, follow, and assist behavior while passive 901031 is active. Existing playerbot Chaos Bolt decisions need no change. The combat path performs no database access.

## Spell graph

| Surface | Contract |
|---|---|
| Passive | 901031 Chaotic Inferno |
| Chaos Bolt chain | First rank 50796, script binding `-50796` |
| Summon helper | 901032 Chaotic Inferno Summon |
| Impact | Stock 22703 Inferno Effect |
| Guardian | Module creature 900002, cloned from stock Infernal 89 |
| Summon properties | 901032, ally category, guardian type, slot 0 |
| Duration | Duration index 18, 20 seconds |
| Script | `spell_apoc_warlock_chaotic_inferno` |
| Guardian AI | `npc_apoc_warlock_chaos_infernal` |
| Registration | `AddModApocalipseWarlockChaoticInfernoScripts()` |

## Runtime flow

```text
Chaos Bolt rank successfully lands
  -> require passive aura 901031
  -> cast helper 901032 at the hit unit's current position
  -> summon non-pet guardian 900002 for 20 seconds
  -> trigger stock Inferno Effect 22703 at the destination
  -> start the new idle guardian on the Chaos Bolt target
  -> follow and assist the owner through later owner attack events
```

`AfterHit` is used because Chaos Bolt has projectile speed and the summon must occur at impact rather than cast completion. Misses, immunities, and interrupted casts do not reach this path.

## Guardian contract

Creature 900002 clones the stock Infernal 89 template, model, addon auras, and level-stat rows. The module forces summon-pet stat initialization for that guardian and applies the stock Infernal avoidance, hit, stamina, intellect, armor, resistance, attack-power, and spell-power scaling auras.

Summon properties use ally category, guardian type, and slot 0. The guardian is therefore owned by the Warlock and present in `m_Controlled`, but it is not a pet-category summon, does not replace `PetGUID`, and does not receive a pet bar. It follows its owner, attacks the Chaos Bolt target when created, assists when the owner attacks or is attacked, uses normal melee and Immolation behavior, and returns to follow after evade.

The helper does not carry `SPELL_ATTR1_DISMISS_PET_FIRST`. An Imp, Voidwalker, Succubus, Felhunter, Felguard, or other normal pet remains active.

## Stacking and lifecycle

There is intentionally no explicit active-count cap. Every qualifying Chaos Bolt creates another independent 20-second guardian. Chaos Bolt's own cooldown and the shorter lifetime naturally bound the expected overlap during ordinary play. Each guardian expires through the core timed-summon lifecycle and is also removed by death, owner logout, owner removal, or map teardown.

The 20-second lifetime is the initial balance metric. Cooldown resets or unusual cooldown reduction can still increase overlap and should be covered by production-scale load validation.

## Impact and proc behavior

Helper 901032 reproduces stock Inferno's summon visual and triggers stock Inferno Effect 22703. The impact therefore retains the stock Fire damage, area targeting, stun duration, hit resolution, threat, PvP processing, and proc eligibility. The helper is triggered without resource, reagent, cast-time, or cooldown costs and does not invoke stock Inferno 1122, so the normal demon is not dismissed.

## Server and client data

The automatic world update collision-checks spell IDs 901031 and 901032, creature 900002, and summon-properties ID 901032. It installs both spell rows, the Chaos Bolt rank-chain binding, the cloned creature surfaces, and backend spell names.

Both custom spell rows require matching server and client `Spell.dbc` export data. Summon-properties 901032 is server-only for this implementation. Creature 900002 reuses an existing client model and requires no new creature display asset. Talent presentation must reference only 901031.

## Deployment and rollback

Deploy through the normal module updater with worldserver stopped or through startup update discovery after backup. Rebuild the module, export both custom spell rows, deploy acquisition data for 901031, and restart worldserver.

Rollback must remove the exact script binding, spell rows 901031 and 901032, summon-properties row 901032, creature 900002 and its model, addon, and level-stat rows, acquisition references, and matching client rows together. Rebuild without the loader registration.

## Verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Chaos Bolt lands without passive 901031 | No Infernal or Inferno impact is created | Not run |
| Chaos Bolt misses, is immune, or is interrupted | No Infernal or Inferno impact is created | Not run |
| Chaos Bolt lands with passive 901031 | One Infernal appears at the target and stock impact damage and stun resolve | Not run |
| Warlock already has a normal demon | Normal demon remains and the Infernal coexists without a pet bar | Not run |
| Several Chaos Bolts land within 20 seconds | Every hit adds an independent Infernal with its own remaining duration | Not run |
| Owner attacks or is attacked | Every idle proc Infernal assists a valid hostile target | Not run |
| Guardian evades | It clears combat and resumes following its owner | Not run |
| Guardian reaches 20 seconds, dies, owner logs out, or map unloads | Guardian despawns safely | Not run |
| Bot with passive casts Chaos Bolt | Behavior matches a human Warlock | Not run |

## Known limitations

- No hard count cap is enforced; the 20-second lifetime and Chaos Bolt cooldown provide the ordinary-play bound, while cooldown resets still need load validation.
- The implementation uses a module creature entry because attaching autonomous AI directly to stock creature 89 would also replace normal Infernal AI globally.
- Build, SQL application, startup, client export, and in-game behavior have not been run in this environment.

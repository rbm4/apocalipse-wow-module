# Burning Conflagration

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_warlock_burning_conflagration.cpp`, `data/sql/db-world/2026_09_20_04_burning_conflagration.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-20

## Purpose

Burning Conflagration is a custom Destruction Warlock passive using spell ID 901027. A successful Conflagrate hit captures the caster's Immolate rank from the primary target before the core can consume it, then applies that same rank to up to three random eligible enemies within 10 yards of the primary target.

## Acquisition boundary

The module defines and consumes passive 901027, but does not grant it or modify talent data. The separate talent-data workflow must teach 901027 to the intended Destruction talent. A matching client `Spell.dbc` row and talent presentation are required.

## Human and bot applicability

Humans and bot-controlled Warlocks use identical capture, selection, and spread behavior when passive 901027 is active. No bot detection, AI integration, or combat-time database access is used. Existing Destruction bot actions already cast Immolate and Conflagrate, while acquisition remains external.

## Spell graph

| Surface | Contract |
|---|---|
| Passive spell | `SPELL_APOC_WARLOCK_BURNING_CONFLAGRATION = 901027` |
| Conflagrate rank chain | First rank 17962, script binding `-17962` |
| Immolate rank chain | First rank 348, exact source aura rank reused |
| Script | `spell_apoc_warlock_burning_conflagration` |
| Registration | `AddModApocalipseWarlockBurningConflagrationScripts()` |
| Server migration | `data/sql/db-world/2026_09_20_04_burning_conflagration.sql` |
| Client presentation | Matching client `Spell.dbc` and separate talent data required |

## Runtime flow

```text
Conflagrate effect 0 successfully hits
  -> require passive aura 901027
  -> require a hostile primary target
  -> find that caster's Immolate through rank chain 348
  -> store its exact spell ID before core school damage runs
  -> core Conflagrate calculates damage and may consume the source aura
  -> AfterHit searches 10 yards around the primary target
  -> exclude the primary target, invalid enemies, and enemies with that caster's Immolate
  -> randomly retain at most three enemies
  -> cast the captured Immolate rank on each remaining enemy
```

The script uses `OnEffectHitTarget` because the custom core dispatches effect scripts before `Spell::EffectSchoolDamage`, where Conflagrate consumes Immolate unless Glyph of Conflagrate 56235 is active. It stores only the spell ID, not an aura pointer that may become invalid.

Spread runs from `AfterHit`, not `AfterCast`. This remains correct for both immediate and projectile Conflagrate data because `AfterHit` occurs after capture and after all effects on the successful primary hit. Conflagrate is single-target, so the spread step runs once.

## Source and target rules

The source must be an Immolate aura in rank chain 348 owned by the Conflagrate caster. Shadowflame can still satisfy the core Conflagrate requirement, but it cannot provide a source rank and therefore does not spread Immolate.

Candidates must satisfy all of the following:

- Alive and in world.
- On the same map as the caster.
- Within 10 yards of the primary target.
- In line of sight from the caster.
- A valid hostile attack target for the caster.
- Not the primary target.
- Not already carrying any Immolate rank from that caster.

Another Warlock's Immolate does not exclude a candidate. The eligible list is randomly reduced to three before casts begin. A second ownership check immediately before each cast handles synchronous state changes.

## Damage and proc behavior

The spread casts the captured real Immolate rank as a triggered spell. Each application therefore includes Immolate's normal initial Fire hit and periodic aura, including normal threat, PvP damage handling, spell scaling, and proc behavior. The trigger bypasses cast time and resource cost for the propagated applications.

Glyph of Conflagrate changes only whether the primary Immolate is consumed. Burning Conflagration captures and spreads the source rank in either case.

## Server spell contract

The automatic world update defines 901027 as an infinite passive Warlock dummy aura with Fire school, Warlock family, and the Conflagrate icon derived from backend spell data. It collision-checks `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`, binds all Conflagrate ranks through `-17962`, and synchronizes the backend spell picker name.

The migration does not create talent acquisition data or a deployed client patch.

## Deployment and rollback

Before deployment, verify 901027 is free in live `spell_dbc`, `wotlk_spells_full`, `wotlk_spells`, and the selected client `Spell.dbc`. Apply the automatic updater through normal worldserver startup, deploy matching client and talent data, and restart worldserver so spell definitions and script bindings load.

Rollback requires the normal database backup and stopped-worldserver procedure. Remove the exact `spell_apoc_warlock_burning_conflagration` binding and module-owned 901027 rows, remove acquisition references and client data together, then rebuild without the registration call.

## Verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Conflagrate hits a target with the caster's Immolate and passive 901027 | Same Immolate rank reaches at most three eligible enemies within 10 yards | Not run |
| Conflagrate hits with no passive | No spread | Not run |
| Conflagrate uses only Shadowflame as its required aura | Normal Conflagrate behavior, no Immolate spread | Not run |
| Glyph of Conflagrate is active | Primary Immolate remains and spread still occurs | Not run |
| Glyph is absent | Primary Immolate is consumed after capture and spread still occurs | Not run |
| Candidate has another caster's Immolate | Candidate remains eligible | Not run |
| Candidate has this caster's Immolate | Candidate is excluded | Not run |
| More than three candidates are eligible | Three are selected randomly | Not run |
| Bot with passive 901027 casts its normal sequence | Same behavior as a human | Not run |

## Known limitations

- Radius 10 yards and cap three are balance choices and require in-game tuning.
- Triggered applications include Immolate's initial direct hit by design.
- Live database, deployed client data, startup validation, and in-game behavior remain unverified.

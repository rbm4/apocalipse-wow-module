# Divine Toll

Status: Implemented in source and server data, build and runtime not verified

Owners: `src/mod_apocalipse_paladin_divine_toll.cpp`, `src/mod_apocalipse_paladin_permanent_seal_of_righteousness.cpp`, `data/sql/db-world/2026_09_18_05_divine_toll.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-18

## Purpose

Divine Toll is a one-rank Paladin active spell that unleashes a uniformly random sequence of one through five half-damage Judgement impacts against one enemy. It applies Judgement of Justice and preserves selected seal, talent, critical-strike, and generic proc behavior without repeatedly casting a normal Judgement wrapper.

## Acquisition boundary

The module defines acquisition-facing spell 901024 but does not teach it or modify talents, trainers, specialization data, items, or playerbot acquisition. A separate system owns acquisition. The external backend derives client spell data from server tables and owns client patch generation.

## Human and bot applicability

Human and bot-controlled paladins use identical cast checks, sequencing, retargeting, damage, seal, talent, and proc behavior. The module contains no bot detection and no combat-time database access. Playerbot AI decides whether and when to cast an externally granted Divine Toll.

## Spell graph

| Spell | Role | Contract |
|---:|---|---|
| 901024 | Divine Toll | Instant hostile-target active, 10 percent base mana, normal global cooldown, 60-second cooldown, four-second sequence-state aura |
| 901025 | Divine Toll Impact Marker | Internal non-saved hit, spell-hit, and expertise marker applied only while one impact resolves |
| 901026 | Divine Toll Justice Visual | Internal target visual derived from stock Judgement of Justice spell data |
| 20184 | Judgement of Justice | Existing debuff applied or refreshed by every non-immune impact |
| Dynamic seal damage spell | Existing seal Judgement | Read from the active real seal's effect 2 amount at every impact, with stock fallback 54158 |
| 25742 | Seal of Righteousness damage | Existing real and permanent-overlay SoR damage, including JotJ double hits |

Only 901024 is acquisition-facing. Spells 901025 and 901026 are internal and must never be taught.

## Cast and sequence contract

Divine Toll requires a living hostile selected target, line of sight, normal Judgement range, and any active real seal. Facing is not required. It rolls one through five impacts with equal probability, executes the first immediately, and schedules later impacts at 500 ms intervals.

Each event stores caster and original-target GUIDs. At execution it resolves objects again and requires the caster to be in world, alive, carrying the sequence aura, holding a real seal, and free from controlled, silence, pacify, and pacify-silence states. Failure of a caster requirement removes the sequence aura and cancels remaining events.

A valid original target continues to receive every impact. If it becomes invalid, that event selects the nearest living hostile target within the caster's current normal Judgement range and line of sight. Previously hit targets remain eligible. Failure to find a replacement loses only that event; later events search again.

Directly replacing one real seal with another is allowed. Each event reads the currently active seal. Losing all real seals cancels the sequence.

## Impact and damage contract

Before a non-immune impact, the internal marker temporarily grants enough melee hit, spell hit, and expertise to prevent ordinary miss, dodge, and parry outcomes. The marker is removed immediately after the synchronous impact graph resolves. Immunity remains authoritative.

Every accepted impact:

1. Plays the stock Judgement of Justice visual through 901026.
2. Applies or refreshes Judgement of Justice 20184.
3. Adds or refreshes a real Holy Vengeance 31803 or Blood Corruption 53742 stack before Vengeance or Corruption Judgement damage.
4. Casts the active seal's existing Judgement damage spell with normal proc events enabled.
5. Clears the shared normal Judgement cooldown category on the first successful impact only.
6. Executes the stock Seal of Command JotJ cleave when applicable.

Scripts bound to the existing Judgement and seal damage spells reduce positive hit damage to 50 percent only while marker 901025 is present. The multiplier is applied to raw hit damage before critical bonus, PvP reduction, resistance, and absorbs because the deployment core exposes no module hook between resistance and absorb processing. This preserves normal downstream damage handling with possible integer-rounding differences from a post-resistance multiplier.

A fully absorbed non-immune impact counts as successful. An impact rejected by spell or damage immunity applies no Divine Toll debuff, damage proc, or Judgement cooldown reset. Remaining scheduled impacts continue.

## Seal and talent interactions

- Every stock real seal is selected through the same effect 2 contract used by the stock Judgement wrapper.
- Vengeance and Corruption receive a real stack before damage; their periodic aura behavior is unchanged and later ticks are not reduced by Divine Toll.
- Blood and Martyr recoil derives from the reduced impact and therefore remains proportionate.
- Seal of Command's JotJ cleave runs on every applicable impact and is reduced by the same marker-bound damage script.
- Passive 901016 normally suppresses itself beside real SoR. During a marked Divine Toll Judgement only, it is allowed to fire beside real SoR.
- Real SoR and passive 901016 both retain their JotJ second hit, with every 25742 result reduced to 50 percent while marked.
- Judgements of the Wise uses an additional check on rank chain 31876. Its first eligible marked event records a bit in the 901024 sequence aura; later marked events are rejected.
- Judgements of the Just, Heart of the Crusader, Righteous Vengeance on eligible critical hits, and generic damage procs use their normal existing proc rows for every impact.
- The Tier 5 Holy two-piece Improved Judgement energize does not run because Divine Toll bypasses the normal Judgement wrapper.

The transient marker bounds all exceptions to the synchronous Divine Toll impact. Normal Judgements and ordinary seal procs outside that marker retain stock behavior.

## Database and client contract

The automatic world update:

1. Reads the stock Justice range, visual, and icon from `wotlk_spells_full`.
2. Collision-checks 901024 through 901026 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`.
3. Inserts only missing rows and recognizes only the expected module-owned signatures.
4. Installs the parent, JotW gate, and additive stock-damage script bindings.
5. Marks the parent and impact marker non-save.
6. Synchronizes backend spell-name rows used by the external export workflow.

The external backend owns generated client data and patch deployment. This repository does not generate or apply the client patch.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Cast with no real seal | Cast fails without spending mana or starting cooldown | Not run |
| Cast on valid hostile target | Costs 10 percent base mana, starts 60-second cooldown, and rolls one through five impacts | Not run |
| One through five roll sampling | Counts are approximately uniform across a large sample | Not run |
| Target remains valid | Every rolled impact hits that target at 0, 500, 1000, 1500, or 2000 ms | Not run |
| Target dies or leaves range | Current event retargets nearest valid enemy; later events repeat validation | Not run |
| No replacement exists | Current event is lost; later events search again | Not run |
| Caster dies, changes map, loses seal, or becomes cast-locked | Remaining sequence cancels | Not run |
| Seal changes directly | Later events use the new seal | Not run |
| Immune target | No impact side effects or Judgement reset for that event | Not run |
| Fully absorbed target | Debuffs and successful-impact reset still occur | Not run |
| Vengeance or Corruption | Stack is added before each impact and normal periodic behavior remains | Not run |
| Real SoR with passive 901016 and JotJ | Both SoR paths fire twice per impact at half damage | Not run |
| Seal of Command with JotJ | Every impact produces a half-damage stock cleave | Not run |
| Judgements of the Wise | At most one mana and Replenishment proc occurs per sequence | Not run |
| Independent critical hits | Each impact can separately trigger Righteous Vengeance | Not run |
| Human and playerbot | Identical mechanics when 901024 is externally granted | Not run |

## Rollback

Stop worldserver, take the normal world-database backup, remove the exact 901024 parent binding, -31876 JotW gate binding, additive stock-damage bindings, custom-attribute rows, backend names, and spell rows 901024 through 901026. Restore the previous client patch through its external owner, rebuild without the source and loader registration, and restart. Acquisition rollback remains owned by the external system.

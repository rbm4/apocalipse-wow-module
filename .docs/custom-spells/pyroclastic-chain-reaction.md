# Pyroclastic Chain Reaction

Status: Implemented in source, build and runtime not verified

Owners: `src/mod_apocalipse_mage_pyroclastic_chain_reaction.cpp`, `data/sql/db-world/2026_09_17_00_pyroclastic_chain_reaction.sql`, `data/sql/db-world/2026_09_18_01_pyroclastic_chain_reaction_propagated_damage.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-18

## Purpose

Pyroclastic Chain Reaction is a custom mage passive using provisional spell ID 901003. A qualifying Pyroblast hit has a 20 percent chance to detonate and refresh the caster's existing Living Bomb on the target. The special explosion can spread the same Living Bomb rank to up to two random enemies hit by that explosion that do not already have that caster's Living Bomb.

## Acquisition boundary

This module defines and consumes passive spell 901003, but it does not grant the spell or modify talent data. Talent acquisition and the matching client talent contract are owned by the deployment's separate talent-data workflow.

When spell 901003 is learned, its passive self aura carries effect 0 with amount 20. The Pyroblast script reads that amount as the proc chance. Without the passive aura, Pyroblast and Living Bomb retain their normal behavior.

## Human and bot applicability

Human and bot-controlled mages use identical proc, refresh, explosion, and spread behavior. The combat path performs no bot detection and no database queries. Bot talent acquisition remains outside this script in the same way as human talent acquisition.

## Spell graph

| Surface | Contract |
|---|---|
| Passive spell | `SPELL_APOC_MAGE_PYROCLASTIC_CHAIN_REACTION = 901003` |
| Pyroblast rank chain | First rank 11366, script binding `-11366` |
| Living Bomb rank chain | Aura ranks 44457, 55359, and 55360 |
| Explosion rank chain | Explosion ranks 44461, 55361, and 55362, script binding `-44461` |
| Proc script | `spell_apoc_mage_pyroclastic_chain_reaction_pyroblast` |
| Spread script | `spell_apoc_mage_pyroclastic_chain_reaction_explosion` |
| Registration | `AddModApocalipseMagePyroclasticChainReactionScripts()` |
| Server migration | `data/sql/db-world/2026_09_17_00_pyroclastic_chain_reaction.sql` |
| Client presentation | Matching client `Spell.dbc` and talent data required |

## Runtime flow

```text
Pyroblast effect 0 hits a unit
  -> require passive aura 901003 on the caster
  -> roll the passive effect amount as the chance
  -> require a Living Bomb owned by the same caster on the hit unit
  -> read the matching explosion ID from Living Bomb effect 1
  -> refresh the current Living Bomb duration and periodic tick counters
  -> cast the matching Living Bomb explosion as a triggered spell
     -> mark this cast as triggered by passive 901003
     -> preserve normal explosion damage against all selected enemies
     -> collect surviving unbombed units from completed hit callbacks
     -> choose up to two collected units randomly after the explosion
     -> apply the source Living Bomb rank
        -> mark the aura as propagated through passive 901003
        -> reduce its periodic damage and its explosions to 30 percent
```

The source Living Bomb is not removed to cause the special explosion. It remains active and receives a full duration refresh. The normal Living Bomb expiration and dispel path is unchanged. Only bombs applied by the spread step receive the 30 percent modifier; a manually applied source bomb remains at full damage.

## Eligibility and rank preservation

The interaction requires all of the following:

1. The landed spell belongs to the Pyroblast rank chain through the `-11366` binding.
2. The caster has passive aura 901003.
3. The Pyroblast target has a Living Bomb from that same caster.
4. The passive's chance roll succeeds.
5. The Living Bomb effect identifies a loaded explosion spell.

The explosion ID is read from the source Living Bomb aura, and spread applications reuse the source aura's spell ID. Rank 1 therefore spreads rank 1, and the same rule applies to ranks 2 and 3.

## Spread targeting

The special explosion keeps its complete original damage target list. The explosion script collects candidates only from completed hit callbacks, so target-selection failures and misses do not enter the spread pool.

Candidates are excluded when they are:

- The original bomb carrier.
- Not a unit.
- Already affected by the triggering caster's Living Bomb rank chain.

After the explosion completes, up to two collected candidates are selected randomly. Living Bomb is applied only while a selected target remains alive and still lacks that caster's Living Bomb. Another mage's Living Bomb does not disqualify a target because ownership is checked against the triggering caster.

Normal Living Bomb explosions do not spread. The explosion script requires `GetTriggeringSpell()` to identify passive 901003, which is supplied only by the Pyroclastic Chain Reaction cast path.

## Combat-system interactions

The special explosion from the manually applied source Living Bomb reuses the normal Living Bomb explosion spell at full damage. A propagated aura is identified by its passive 901003 trigger metadata. Its calculated periodic amount is reduced to 30 percent on application, and every matching-rank explosion originating from that aura is reduced to 30 percent before the normal direct-damage hooks complete.

The propagated marker is keyed by caster and bomb carrier so different mages remain independent. Expiration and enemy-dispel removal marks the entry for cleanup, and the synchronous Living Bomb explosion clears it after damage is processed. A generation-aware next-update fallback also clears the entry if that explosion cast fails. Refreshing or recasting the propagated aura recalculates and reapplies the 30 percent periodic amount without creating a second marker.

Spell Scaling and PvP Balancing remain active after the 30 percent modifier. Integer conversion at each stage can produce rounding differences from multiplying the final displayed damage by exactly 0.30.

## Server spell contract

The automatic world update defines spell 901003 as:

- A passive mage spell with an infinite self aura.
- Effect 0: `SPELL_EFFECT_APPLY_AURA` and `SPELL_AURA_DUMMY`.
- Effect 0 amount: 20, used as the proc percentage.
- Fire school and Living Bomb icon.
- No item requirement.
- English description documenting the proc, refresh, and two-target spread.

The initial update binds all Pyroblast and Living Bomb explosion ranks through negative first-rank IDs and synchronizes the backend spell picker name. The follow-up update `2026_09_18_01_pyroclastic_chain_reaction_propagated_damage.sql` binds all Living Bomb aura ranks through `-44457` so propagated applications can be marked, scaled, and cleaned up.

The spread implementation collects completed hits and applies bombs from `AfterCast`. It therefore validates that every bound Living Bomb explosion rank has `Speed = 0`, which is required for the core to process all immediate hits before `AfterCast`. A rank with positive speed rejects the spread script during validation rather than running with an empty candidate list.

## Deployment

Before first deployment, verify ID 901003 is free in `spell_dbc`, `wotlk_spells_full`, `wotlk_spells`, and the selected client `Spell.dbc`. The automatic module update has a collision guard and recognizes only its expected passive signature as module-owned.

The server update does not create client talent data. Deployment must separately provide:

- A matching client `Spell.dbc` row for 901003.
- The intended talent acquisition data that teaches 901003.
- Any matching server-side talent data required by the deployed custom core.

Worldserver must restart after the update so spell data and script bindings are loaded. On the deployed core, run `.spellinfo all 44461`, `.spellinfo all 55361`, and `.spellinfo all 55362` and confirm each loaded explosion rank reports `Speed: 0.00`.

## Failure modes

| Failure | Result | Detection and recovery |
|---|---|---|
| Passive 901003 missing | Both bound scripts fail validation or the proc gate is absent | Check updater execution, spell data, and startup script validation |
| Passive not learned | Pyroblast behaves normally | Fix the separate talent acquisition data |
| Script binding missing | The passive can exist without changing Pyroblast, spreading, or reducing propagated damage | Check `spell_script_names` for `-11366`, `-44457`, and `-44461` |
| Explosion rank has positive speed | That rank's spread script fails validation because `AfterCast` would precede delayed hits | Inspect all three ranks with `.spellinfo all` and redesign delayed completion before enabling that data |
| Foreign ID collision | Automatic update fails before inserting module data | Allocate a new ID and update source, SQL, client data, and docs together |
| Client spell row missing | Server behavior may exist with broken passive presentation | Deploy matching client spell data |
| Talent data missing | Spell cannot be acquired through the intended talent | Deploy the separate server/client talent contract |
| No eligible explosion targets | Source bomb refreshes and explodes, but no bomb spreads | Expected behavior |

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Pyroblast without passive 901003 | No extra explosion, refresh, or spread | Not run |
| Passive present but target has no caster-owned Living Bomb | No proc behavior | Not run |
| Failed 20 percent roll | No proc behavior | Not run |
| Loaded explosion rank metadata | Ranks 44461, 55361, and 55362 each report speed zero | Not run |
| Successful roll on each Living Bomb rank | Matching explosion fires and source rank refreshes | Not run |
| Two or more unbombed enemies in explosion | Up to two random hit survivors receive the source rank | Not run |
| Enemy already has caster's Living Bomb | Enemy is not selected for spread | Not run |
| Enemy has another mage's Living Bomb | Enemy remains eligible for this caster's bomb | Not run |
| Normal Living Bomb expiration or dispel | Explosion occurs at full damage without spread | Not run |
| Propagated Living Bomb ticks | Each tick uses 30 percent of the equivalent normal bomb amount before shared scaling and PvP hooks | Not run |
| Manual recast on a propagated carrier | Refreshed periodic amount remains at 30 percent and the explosion remains marked | Not run |
| Propagated Living Bomb expiration or dispel | Matching explosion uses 30 percent damage and does not spread | Not run |
| Pyroclastic proc from a propagated carrier | Immediate explosion uses 30 percent damage and can spread up to two new reduced bombs | Not run |
| Explosion kills a selected spread target | Living Bomb is not applied to the dead target | Not run |
| Human and bot mage | Identical combat behavior | Not run |

## Open items

- Build against the exact custom AzerothCore and `mod-playerbots` deployment branches.
- Apply the automatic update to a non-production test world database.
- Export and deploy matching client spell and talent data.
- Execute the runtime verification matrix with deterministic proc testing where possible.

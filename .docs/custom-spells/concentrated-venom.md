# Concentrated Venom

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_rogue_concentrated_venom.cpp`, `data/sql/db-world/2026_09_22_03_concentrated_venom.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-22

## Purpose

Concentrated Venom is Assassination Rogue passive 901061. Each successful application of an equipped weapon poison has a 30 percent chance to apply one additional stack of the highest-rank Deadly Poison currently present on either equipped weapon. One Rogue can produce at most one extra application on a given target per second.

## Acquisition boundary

The automatic world update assigns 901061 to Rogue class 4, Assassination specialization index 0 through Spec Manager. The passive is the only custom spell in the graph. Matching client `Spell.dbc` data for 901061 is required.

If neither equipped weapon has an applicable Deadly Poison combat enchant, qualifying poison applications cannot produce an extra stack. A Deadly Poison rank is applicable when its enchant remains on an equipped main-hand or off-hand weapon and its spell level does not exceed the Rogue's level.

## Human and bot applicability

Human and bot-controlled Rogues use identical proc, rank selection, weapon attribution, throttle, and native poison behavior. Existing bot attacks and poison applications need no new AI action. The combat path performs no database access and no bot detection.

## Spell graph

| Surface | Contract |
|---|---|
| Passive | 901061 Concentrated Venom, permanent passive dummy proc aura |
| Source event | Successful hit-phase application of a hostile Rogue-family poison from the actual equipped main-hand or off-hand `CastItem` |
| Chance | 30 percent after all eligibility and per-target throttle checks pass |
| Extra application | Highest-rank applicable Deadly Poison combat-enchant spell found on the equipped weapons, cast with that enchanted weapon |
| Throttle | Aura-local target GUID map, 1000 ms per target, pruned during qualifying proc checks |
| Native interaction | Existing `spell_rog_deadly_poison` handles stacking and the five-stack opposite-weapon poison path |
| Registration | `AddModApocalipseRogueConcentratedVenomScripts()` |
| Server migration | `data/sql/db-world/2026_09_22_03_concentrated_venom.sql` |

## Runtime flow

```text
equipped weapon poison reaches a hostile target
  -> spell_proc requires Rogue family, negative spell hit phase, and a landed or absorbed result
  -> AuraScript requires a poison spell and its equipped weapon CastItem
  -> locate the highest applicable Deadly Poison rank on main hand or off hand
  -> reject while this target's one-second throttle is active
  -> core rolls the 30 percent proc chance
  -> arm this target's throttle and cast the real Deadly Poison spell with its enchanted weapon
  -> remove the throttle if the cast request is rejected
  -> native Deadly Poison script adds or refreshes the stack
     -> when the target already had five stacks, proc eligible poisons from the opposite weapon
```

## Eligibility contract

The passive accepts direct poison applications with `PROC_FLAG_DONE_SPELL_NONE_DMG_CLASS_NEG` or `PROC_FLAG_DONE_SPELL_MAGIC_DMG_CLASS_NEG`. `PROC_ATTR_TRIGGERED_CAN_PROC` is required because weapon enchant spells are triggered casts. The proc hit mask accepts normal, critical, partial or full absorb results and excludes misses, full resists, dodges, parries, evades, immunities, deflects, reflects, and full blocks.

The script additionally requires the aura owner as actor, Rogue spell family, `DISPEL_POISON`, a living hostile target, a non-null proc `Spell`, and a `CastItem` equal to the currently equipped main-hand or off-hand item. Item-use casts, poison-application crafting spells, periodic poison ticks, and non-poison Rogue abilities do not qualify.

## Rank, weapon, and recursion contract

Rank selection inspects combat-spell enchant effects on both equipped weapons and keeps only native Deadly Poison family flags. It chooses the greatest `spell_ranks` rank, using spell level as the tie breaker. The selected spell and weapon are passed directly to `Unit::CastSpell` with the passive aura effect as the trigger source.

This preserves native stack ownership, duration, damage, cast-item attribution, and `spell_rog_deadly_poison`. At five existing stacks, that native script recognizes the selected Deadly Poison weapon and scans the opposite equipped weapon for non-Deadly Rogue poisons. The core suppresses recursive Concentrated Venom activation when an effect is triggered by the same passive aura.

## Throttle and state

Throttle state belongs to the passive aura instance and is keyed by target GUID, so different Rogues have independent limits and one target does not block another. Expired entries are erased on later qualifying poison checks. Removing the passive destroys all throttle state. No state is persisted and no periodic update or database query is added.

The throttle is armed immediately before the extra cast so native five-stack opposite-weapon poison casts cannot re-enter the passive in the same call chain. It is removed again if the extra `CastSpell` request does not return `SPELL_CAST_OK`. The triggered cast uses the same flags as normal weapon-enchant poison casts except that spell and category cooldown checks remain enabled.

## Database and client contract

The automatic world update collision-checks 901061 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs the passive row, exact proc metadata, script binding, Assassination Spec Manager acquisition, and backend spell name. The server row reuses Deadly Poison rank 1's icon through the checked-in spell-data cache.

The deployed client patch must include matching spell 901061 with the same name, description, passive dummy aura, 30 percent amount, and Rogue/Nature presentation. Live database and deployed-client collision checks remain operator deployment work.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Deadly Poison and another poison are equipped, and either poison lands repeatedly | Approximately 30 percent of eligible applications add one real Deadly Poison application outside the throttle | Not run |
| Both weapons carry different Deadly Poison ranks | The higher applicable rank and its weapon are used | Not run |
| No equipped weapon carries Deadly Poison | No extra application and no throttle | Not run |
| Source poison misses, fully resists, or receives immune result | No proc roll, extra application, or throttle | Not run |
| Source poison is partially or fully absorbed but lands | Event remains eligible | Not run |
| Two eligible applications hit the same target within one second | At most one extra application is accepted | Not run |
| Eligible applications hit two targets within one second | Each target has an independent chance and throttle | Not run |
| Target already has five same-caster Deadly Poison stacks | Extra Deadly Poison invokes native opposite-weapon non-Deadly poison behavior | Not run |
| Extra Deadly Poison generates proc events | Concentrated Venom does not recursively trigger itself | Not run |
| Passive is removed and learned again | Previous target throttle state is gone | Not run |
| Human and playerbot Assassination Rogue | Identical mechanics while 901061 is granted | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove 901061 from `mod_spec_spells`, `spell_proc`, `spell_script_names`, `wotlk_spells`, and `spell_dbc`, then restore the previous client patch. Rebuild without the source and loader registration before restarting.

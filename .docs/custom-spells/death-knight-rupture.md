# Death Knight Rupture

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_death_knight_rupture.cpp`, `data/sql/db-world/2026_09_21_04_death_knight_rupture.sql`, `data/sql/db-world/2026_09_25_05_death_knight_rupture_ap_scaling.sql`, `data/sql/db-world/2026_09_26_00_death_knight_rupture_melee_hits.sql`, and `data/mod_spell_scaling.sql`

Last source review: 2026-09-26

## Purpose

Rupture is Blood Death Knight passive 901048. Every landed main-hand or off-hand melee auto-attack and every landed melee-class ability target applies one stack of physical periodic bleed helper 901049. Normal, critical, partially absorbed, and fully absorbed hits qualify. Misses, dodges, parries, full resists, immune results, pets, ranged attacks, magic-class abilities, and periodic damage do not.

## Acquisition and applicability

The automatic world update adds passive 901048 to `mod_spec_spells` for Death Knight class 6, Blood tree index 0. Spec Manager grants and revokes it through its existing reconciliation and persistence flow. Humans and playerbots use identical mechanics, and no playerbot strategy or cast action is required.

## Spell graph

| Spell | Contract |
|---|---|
| 901048 Rupture | Infinite passive dummy aura, 100 percent proc metadata for normal, critical, or absorbed outgoing melee-auto and melee-spell damage hits |
| 901049 Rupture Bleed | Hostile physical bleed, 15-second refreshed duration, two-second ticks, maximum 200 stacks, non-save custom attribute |

The stack limit is an implementation contract and is intentionally omitted from the player-facing passive description.

## Damage formula

Each stack contributes the following amount before broad done and taken modifiers:

```text
per-stack tick = 1 + floor(0.01 * melee attack power)
total tick = per-stack tick * active stacks
```

`spell_bonus_data.ap_dot_bonus = 0.01` supplies the attack-power term through native periodic spell calculation. This is 1 percent melee attack power per stack, doubled from the original 0.5 percent coefficient without changing the base damage, stack cap, duration, tick interval, school, mechanic, or modifier profile. Spell 901049 is physical, uses Death Knight family 15, and carries bleed mechanic 15. It therefore ignores armor, establishes the bleeding aura state, and continues through applicable physical, bleed, Death Knight, Blood, target vulnerability, resilience, and module PvP modifiers. It has no Death Knight family bit, so strike-specific modifiers do not incorrectly treat it as a source melee ability.

`mod_spell_scaling` registers helper 901049 as `PERIODIC` with factor 1.0. Below level 80, each final tick is additionally multiplied by `min(level / 80, 1)` before PvP balancing. Human and bot casters follow the same hook order and integer truncation.

## Runtime flow

```text
Blood Death Knight has passive 901048
  -> landed melee auto-attack or melee-class ability event
  -> normal, critical, partial-absorb, and full-absorb results qualify
  -> AuraScript validates actor, living event target, melee proc type, and hit result
  -> caster triggers helper 901049 on that event target
  -> native aura stacking adds one stack and refreshes the 15-second duration
  -> every two seconds native periodic calculation applies AP and damage bonuses
  -> PERIODIC level scaling and PvP balancing mutate the final tick when eligible
```

Multi-target melee abilities dispatch one proc event per landed target, so each target receives its own stack. Reaching the cap requires continuous applications; allowing the refreshed aura to expire removes the complete stack.

## Data and deployment

The guarded base updater collision-checks 901048 and 901049 across `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs both spell rows, proc metadata, the passive script binding, original AP coefficient, periodic scaling row, non-save helper attribute, Blood acquisition row, and backend names. The idempotent follow-up `2026_09_25_05_death_knight_rupture_ap_scaling.sql` updates only helper 901049's `ap_dot_bonus` to 0.01. The idempotent follow-up `2026_09_26_00_death_knight_rupture_melee_hits.sql` changes the proc hit mask to the core default for outgoing hits, which accepts normal, critical, and absorbed results, and updates the passive descriptions. The baseline `data/mod_spell_scaling.sql` also seeds helper 901049.

Matching client `Spell.dbc` rows are required for both IDs before deployment. The server update, client patch, and Spec Manager acquisition must ship together. Live server tables and the selected deployed client remain pending collision checks.

## Performance and state

The proc path performs constant-time event checks and one triggered cast. It performs no combat-time database access and owns no process-global state. Stack and duration state belongs to each caster-target aura pair and is removed by normal expiration, target death, aura removal, or Spec Manager revocation preventing future applications.

## Verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Main-hand or off-hand normal/critical auto hit | One stack on that target and duration refresh | Not run |
| Fully absorbed melee auto hit | One stack on that target and duration refresh | Not run |
| Any normal, critical, partially absorbed, or fully absorbed melee-class ability hit | One stack on each landed event target | Not run |
| Miss, dodge, parry, full resist, immune result, ranged attack, magic-class ability, or periodic damage | No stack | Not run |
| Continuous attacks reach 200 stacks | Stack remains capped at 200 while duration refreshes | Not run |
| No qualifying hit for 15 seconds | Entire bleed expires | Not run |
| Level 40 caster | Final periodic tick receives 50 percent PERIODIC scaling before PvP reduction | Not run |
| Broad Blood/physical/bleed modifier changes | Tick follows applicable native done or taken modifier | Not run |
| Human and playerbot Blood Death Knight | Identical applications and damage | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. To roll back the broader proc behavior, restore `spell_proc.HitMask = 3`, restore the previous passive descriptions and C++ strike whitelist, rebuild, and restore the prior client patch. To roll back only the AP balance change, restore helper 901049's `spell_bonus_data.ap_dot_bonus` to 0.005. To remove Rupture completely, remove the 901048 Blood row from `mod_spec_spells` first, then remove its script/proc rows, helper scaling/bonus/custom-attribute rows, both backend names, and both `spell_dbc` rows. Existing helper auras are non-save and disappear through normal aura cleanup.

## Change history

| Date | Change | Reference |
|---|---|---|
| 2026-09-26 | Expanded stacking to every landed melee hit, including full absorbs | [`../history/2026-09-26-death-knight-rupture-melee-hits.md`](../history/2026-09-26-death-knight-rupture-melee-hits.md) |
| 2026-09-25 | Doubled per-stack periodic AP coefficient from 0.005 to 0.01 | [`../history/2026-09-25-death-knight-rupture-ap-scaling.md`](../history/2026-09-25-death-knight-rupture-ap-scaling.md) |
| 2026-09-21 | Initial Rupture implementation | [`../history/2026-09-21-death-knight-rupture.md`](../history/2026-09-21-death-knight-rupture.md) |

# Buckler Strike

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_rogue_buckler_strike.cpp`, `data/sql/db-world/2026_09_22_06_buckler_strike.sql`, `data/sql/db-world/2026_09_25_00_buckler_strike_balance.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-25

## Purpose

Buckler Strike is Combat Rogue active 901078. It costs 25 Energy, has a 20-second cooldown, requires a usable offhand shield, deals Physical melee damage equal to 110 percent of melee attack power plus 150 percent of total shield block value, applies stock rank 2 Blade Twisting debuff 51585 on every successful damage-effect hit, awards one combo point, and generates three times its final damage as damage-based threat. Against non-player targets, it also interrupts eligible spellcasting and locks the interrupted school for three seconds.

## Acquisition and bot behavior

Acquisition is intentionally not handled by this feature. The owning talent or acquisition workflow must reference 901078. Humans and playerbots use identical mechanics after learning the spell. Selecting a shield and deciding when to cast the active remain playerbot AI policy outside this module.

## Spell graph

| Spell | Contract |
|---|---|
| 901078 Buckler Strike | Client-facing Rogue Physical melee active with damage, one native combo-point effect, one native interrupt effect, and a scripted stock Blade Twisting application |
| 51585 Blade Twisting | Stock rank 2 triggered daze applied by every successful Buckler Strike damage-effect hit |

The ID requires a matching client `Spell.dbc` row. The automatic migration supplies the server and backend export inputs but does not generate or deploy an MPQ.

## Runtime flow

```text
Rogue begins Buckler Strike 901078
  -> core and script require a usable offhand shield
  -> charge 25 Energy and start the 20-second cooldown on a valid cast
  -> resolve a Physical melee-special hit against one enemy
  -> calculate pre-mitigation damage as floor(110% AP + 150% shield block value)
  -> normal melee hit, critical strike, armor, block, absorb, and immunity paths resolve
  -> every successful damage-effect hit triggers stock Blade Twisting 51585
  -> native effect awards one combo point on a successful spell hit
  -> final positive damage produces normal threat plus 200% bonus damage threat
  -> if the target is not a player and is casting an interruptible spell
     -> interrupt the cast and lock its school for three seconds
```

## Damage and threat contract

The script snapshots current total base-attack power and current total shield block value during effect launch. It calculates `floor(1.10 * AP + 1.50 * SBV)`, clamps the result to at least one, and supplies it to the Physical school-damage effect. The spell uses melee defense resolution and suppresses weapon item procs because the strike is delivered by the shield rather than either weapon.

The effect-hit hook makes the Rogue cast stock Blade Twisting 51585 on the struck target without a random roll. This is the triggered debuff used by WotLK Blade Twisting rank 2 passive 31126. Buckler Strike does not require the Rogue to know that talent. Miss, dodge, parry, and immunity paths do not execute the successful damage-effect hook; ordinary target immunity and diminishing behavior for the daze remains core-owned.

Normal damage handling creates one times damage threat. `AfterHit` reads final dealt damage after mitigation and adds another two times through `ThreatManager`, so the ability contributes three times final damage before ordinary threat modifiers and redirects. Zero damage, a miss, an immunity, or a target without a threat list adds no bonus threat. Daring Challenge can compose with this threat because its separate target-specific damage proc observes the completed hit.

## Shield and interrupt contract

Spell equipment metadata requires armor subclass Shield in inventory type Shield. `CheckCast` additionally verifies that the offhand item is a non-broken shield, preventing stale or unusual item state from bypassing the requirement.

The core `SPELL_EFFECT_INTERRUPT_CAST` path owns cast-state checks, interrupt immunity, interrupt flags, school selection, and the three-second lockout. The script prevents that effect for player targets before default effect execution. Damage and the combo point still resolve against players, but player spellcasting is never interrupted by Buckler Strike.

## State and cleanup

Buckler Strike creates no custom aura, delayed event, global map, periodic update, or database access in combat. It applies stock target aura 51585 and otherwise retains only normal core cooldown and combo-point state. Unequipping or breaking the shield causes later casts to fail through the normal equipped-item error path.

## Database and client contract

The original automatic world update collision-checks 901078 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It retains the original 6000 ms cooldown and description so its checksum stays stable for databases that already applied it, and installs the spell row, script binding, and backend name on fresh databases. Range is derived from stock Shield Bash 72. Visual and icon data are derived from stock Shield Slam 23922 with guarded fallbacks.

Automatic follow-up `2026_09_25_00_buckler_strike_balance.sql` recognizes the managed existing row by identity, equipment contract, and effect graph, then changes its cooldown from 6000 ms to 20000 ms and updates the export description. The AP coefficient and guaranteed Blade Twisting application are C++ behavior. The deployed client row must also receive the 20000 ms cooldown and current description; stock spell 51585 already exists in the WotLK client.

The migration does not add `mod_spec_spells`, player-creation, trainer, or talent acquisition data. Live database and deployed-client collision checks remain operator deployment work. ID 901078 follows concurrent repository allocations through 901077.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| No offhand item or non-shield offhand | Core cast validation fails with the equipped-item requirement and spends no Energy | Not run |
| Broken offhand shield | Script validation fails with the offhand equipped-item requirement and spends no Energy | Not run |
| Usable offhand shield | Cast can begin, spends 25 Energy, and starts a 20-second cooldown | Not run |
| Known AP and shield block value | Pre-mitigation amount equals `floor(1.10 * AP + 1.50 * SBV)` | Not run |
| Successful damage-effect hit without Blade Twisting talent | Stock Blade Twisting 51585 is applied once with no random roll | Not run |
| Miss, dodge, parry, or immunity | Blade Twisting is not applied | Not run |
| Normal, critical, blocked, absorbed, and immune hits | Core Physical melee resolution applies and bonus threat uses final positive damage only | Not run |
| Successful hit | Exactly one combo point is awarded on the struck target | Not run |
| Miss, dodge, parry, or immunity | No combo point or bonus threat is awarded | Not run |
| Creature casts an interruptible spell | Cast stops and its school is locked for three seconds | Not run |
| Creature is not casting or is interrupt-immune | Damage and combo behavior remain; no school lockout is added | Not run |
| Player casts a spell | Damage and combo behavior remain, but casting is not interrupted | Not run |
| Daring Challenge is active on the same target | Buckler Strike threat and the separate challenge bonus compose without recursion | Not run |
| Human and playerbot Rogue | Mechanics are identical after external acquisition and shield equipment | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. To roll back only this balance change, restore 901078 to a 6000 ms cooldown and the prior description, restore the prior client row, and rebuild the prior C++ formula without the 51585 hit hook. To remove the feature entirely, remove the 901078 script binding, backend name, and spell row, restore the previous client patch, and rebuild without the source and loader registration before restarting. Remove any external acquisition reference separately through its owning workflow.

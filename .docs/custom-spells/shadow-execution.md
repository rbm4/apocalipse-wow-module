# Shadow Execution

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_rogue_shadow_execution.cpp`, `data/sql/db-world/2026_09_22_08_shadow_execution.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-22

## Purpose

Shadow Execution is offensive Rogue passive 901081. Each accepted damaging Rogue ability adds one stack of Shadow Execution Damage 901082 to its target and refreshes the effect to 10 seconds. The effect ticks every second, stacks up to 50 times, and each stack deals 1 percent of the Rogue's attack-power-modified main-hand weapon damage.

## Acquisition and applicability

Acquisition is owned by the existing external talent-tree flow. The migration deliberately adds no `mod_spec_spells`, talent, or rank row. That flow must reference passive 901081 as its single-rank grant. Damage aura 901082 is internal and must never be taught directly or used as a talent rank.

Humans and playerbots use identical mechanics. Existing Rogue ability actions apply the effect automatically after the passive is acquired, so no playerbot strategy or cast action is required.

## Spell graph

| Spell | Contract |
|---|---|
| 901081 Shadow Execution | Permanent Shadow dummy aura with direct damaging spell proc metadata |
| 901082 Shadow Execution Damage | Ten-second, one-second-period, non-critical Shadow periodic damage aura with 50 native stacks |

The proc requires the passive owner to be a Rogue, have a usable main-hand weapon, and directly deal positive damage with a Rogue-family spell to another living unit. Melee, ranged, negative none-class, and negative magic-class direct spell events qualify. Auto attacks, periodic ticks, pets, guardians, reflected damage, self-damage, zero damage, misses, fully prevented events, and both Shadow Execution spell IDs are excluded.

Each qualifying damage event applies one stack to that event's victim. Multi-target abilities apply one stack independently to every damaged target. Native aura stacking caps the effect at 50 and refreshes the full 10-second duration on every accepted application without resetting the periodic timer.

## Damage formula

The script calculates a fresh per-stack amount when the aura is first applied or its stack amount changes:

```text
main-hand roll = current main-hand weapon damage including attack power and total percent modifiers
per-stack tick amount = floor(main-hand roll * 0.01)
raw tick amount = per-stack tick amount * current stack count
```

At 50 stacks, the raw periodic tick is 50 times the already-rounded one-stack value. It is nominally 50 percent of the same attack-power-modified main-hand roll, but flooring occurs before stack multiplication. A per-stack result below 1 therefore produces a zero raw tick at every stack count.

The roll is recalculated when a stack is added, not on an unchanged aura's later ticks. If the weapon becomes unusable after the last application, no new stacks can be added and the existing snapshot continues until the aura expires. The native Shadow periodic path then applies target damage-taken modifiers, Shadow resistance, absorbs, resilience, module PvP balancing, threat, and combat logging. The spell has zero spell-power and separate AP coefficients because attack power is already included in `Player::CalculateDamage(BASE_ATTACK, false, true)`.

## Runtime flow

```text
Rogue has passive 901081 and a usable main-hand weapon
  -> direct Rogue-family ability deals positive damage
  -> reject auto attacks, periodic ticks, reflected damage, and recursion
  -> apply or add one stack of 901082 to that victim
  -> refresh the shared ten-second duration
  -> every one second, native periodic handling deals stacked Shadow damage
```

The path is constant-time and performs no combat-time database access.

## Data and deployment

The guarded automatic world update collision-checks 901081 and 901082 across `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs the passive and periodic aura rows, direct spell proc metadata, bindings for both IDs, a zero-coefficient periodic contract, non-critical metadata, and backend names. No acquisition row is installed.

Matching client `Spell.dbc` rows are required for both IDs. The existing backend release builder reads every `spell_dbc` override, maps columns in `wotlk_spells_full` ordinal order, and appends new rows to `Spell.dbc`, so these complete override rows are the client export input and `wotlk_spells` supplies names. The server update, client patch, existing external talent grant of single-rank passive 901081, and module rebuild must ship together. Live server tables and the selected deployed client remain pending collision checks.

## Verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Direct damaging Rogue ability with a main-hand weapon | Adds one stack and starts or refreshes 10 seconds | Not run |
| Multi-target Rogue ability | Adds one stack to every target that takes positive damage | Not run |
| One through 50 stacks | Tick scales linearly and caps at 50 stacks | Not run |
| Reapply between ticks | Duration refreshes without restarting the one-second tick timer | Not run |
| Main-hand attack power or total damage modifier changes before a new stack | Newly recalculated per-stack amount reflects the current main-hand roll | Not run |
| Rogue auto attack or existing periodic damage tick | Does not add a stack | Not run |
| No usable main-hand weapon | Adds no new stack; an existing snapshot continues only until its current duration expires | Not run |
| Shadow Execution periodic tick | Does not recursively add a stack | Not run |
| Target has Shadow resistance, absorb, resilience, or PvP reduction | Native periodic damage resolves those defenses | Not run |
| Human and playerbot Rogue | Mechanics are identical after external acquisition | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove spell 901081 from its external acquisition source, remove both script bindings, `spell_proc`, `spell_bonus_data`, `spell_custom_attr`, backend names, and spell rows, then restore the previous client patch. Rebuild without the source and loader registration before restarting.

# PvP damage balancing

Status: Implemented, source reviewed; runtime not verified in this review

Owner: `src/mod_apocalipse_pvp.cpp`

Last source review: 2026-09-16

## Purpose

This subsystem reduces damage when the attacker is a player or player-owned unit and the victim is a player. Human players and bot-controlled players follow the same rules.

## Reduction model

Both layers mutate the current damage in sequence.

### Fixed reduction

All eligible PvP damage is multiplied by:

```text
1 - (Apocalipse.PvPDamageReductionPct / 100)
```

Default: 15 percent.

### Bracket resilience floor

Victims from level 10 through 79 receive an additional reduction when their current melee crit chance reduction is below the configured target for their level bracket.

```text
bonusPercent = targetPercent - currentResiliencePercent
finalAfterBracket = damageAfterFixed * (1 - bonusPercent / 100)
```

Victims below level 10 and level 80 or above do not receive this layer. Meeting or exceeding the target also skips the layer.

Example for 1000 base damage, fixed 15 percent, level-15 target 8 percent, and zero current resilience:

```text
1000 * 0.85 = 850
850 * 0.92 = 782 after integer conversion
```

## Attacker and victim guards

- The victim must be a `Player`.
- A player attacker qualifies directly.
- A pet or guardian qualifies when `GetCharmerOrOwnerPlayerOrPlayerItself()` resolves a player.
- Periodic damage with a missing attacker is skipped.

No arena, battleground, faction, duel, or hostility check is made beyond these player relationships. The hook therefore applies wherever AzerothCore sends eligible player-versus-player damage through these callbacks.

## Configuration

| Key | Default |
|---|---:|
| `Apocalipse.PvPDamageReductionPct` | `15.0` |
| `Apocalipse.PvPBracketResilience.1019` | `8.0` |
| `Apocalipse.PvPBracketResilience.2029` | `10.0` |
| `Apocalipse.PvPBracketResilience.3039` | `12.0` |
| `Apocalipse.PvPBracketResilience.4049` | `14.0` |
| `Apocalipse.PvPBracketResilience.5059` | `16.0` |
| `Apocalipse.PvPBracketResilience.6069` | `18.0` |
| `Apocalipse.PvPBracketResilience.7079` | `20.0` |

Values reload on startup and config reload. The code does not clamp them. Keep operational values in a safe 0 through 100 range; values above 100 can produce negative floating-point results before conversion into unsigned damage.

This repository has no dedicated PvP `.conf.dist`. Add values to the effective worldserver configuration when overriding defaults.

## Registered scripts

| Script | Base | Hooks |
|---|---|---|
| `ModPvPUnitScript` | `UnitScript` | `ModifyMeleeDamage`, `ModifySpellDamageTaken`, `ModifyPeriodicDamageAurasTick` |
| `ModApocalipsePvPWorld` | `WorldScript` | `OnStartup`, `OnAfterConfigLoad` |

## Interaction with Spell Scaling

Direct and periodic configured spells can pass through both systems. The loader registers Spell Scaling first and PvP Balancing second:

```text
configured spell value
  -> caster-level scaling and integer truncation
  -> fixed PvP reduction and integer truncation
  -> bracket shortfall reduction and integer truncation
```

The mathematical percentages multiply, but dispatch order can affect integer rounding. New damage hooks must document and test their position in this chain.

## Bot behavior

No bot exemption exists. Bots can be attackers or victims, and bot-owned pets qualify through the same owner resolution. Unlike Battleground Stamina's equipment lock, PvP balancing never calls `WorldSession::IsBot()`.

## Failure modes and constraints

| Constraint | Effect |
|---|---|
| Resilience approximation uses `GetMeleeCritChanceReduction()` | One value stands in for the configured floor across melee, spell, and periodic damage |
| Invalid percentage configuration | Damage can be reduced to zero or converted from a negative intermediate |
| Attacker despawns before periodic tick | Tick skips module PvP reduction |
| Another UnitScript changes the same value | Final result depends on all registered modifiers and integer conversion order |

## Verification

Test melee, direct spell, periodic, pet/guardian, bot attacker, bot victim, below-level-10, each bracket edge, current resilience below/equal/above target, and level 80. Also test configured spell scaling combined with PvP balancing. No runtime scenarios were run during the 2026-09-16 documentation review.

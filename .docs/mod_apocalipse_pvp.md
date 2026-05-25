# mod_apocalipse_pvp.cpp

## Purpose

Implements **PvP damage balancing** for Apocalipse WoW. It intercepts every player-vs-player damage event and applies two stacking damage reductions to keep PvP balanced across all level brackets without requiring players to obtain specific gear at low levels.

---

## Two-layer reduction model

Both layers are applied in sequence on the same damage value.

### Layer 1 — Fixed % reduction (all levels)

A flat percentage is subtracted from **every** PvP damage hit, regardless of the attacker's or victim's level. Configured via:

```ini
Apocalipse.PvPDamageReductionPct = 15.0
```

### Layer 2 — Bracket resilience floor (levels 10–79 only)

Each 10-level bracket has a target resilience percentage. If the victim's current resilience stat is *below* that target, the shortfall is applied as an additional damage reduction to simulate the missing resilience.

- Players **at or above** the bracket target receive **no** bonus.
- Level 80+ players are **excluded** (expected to gear for resilience themselves).

```ini
Apocalipse.PvPBracketResilience.1019 = 8.0   # levels 10–19
Apocalipse.PvPBracketResilience.2029 = 10.0  # levels 20–29
Apocalipse.PvPBracketResilience.3039 = 12.0  # levels 30–39
Apocalipse.PvPBracketResilience.4049 = 14.0  # levels 40–49
Apocalipse.PvPBracketResilience.5059 = 16.0  # levels 50–59
Apocalipse.PvPBracketResilience.6069 = 18.0  # levels 60–69
Apocalipse.PvPBracketResilience.7079 = 20.0  # levels 70–79
```

---

## Example

A level 15 player with 0 resilience receives a hit that would deal 1 000 damage.

| Step | Calculation | Result |
|---|---|---|
| Base damage | — | 1 000 |
| Fixed 15 % reduction | `1000 × 0.85` | 850 |
| Bracket target 8 %, current 0 % → bonus 8 % | `850 × 0.92` | 782 |

---

## Attacker detection

Player-owned pets and guardians attacking a player are treated as "player attackers" so their damage is also subject to PvP modifiers. The helper `IsPlayerOrPlayerOwnedUnit` checks `GetCharmerOrOwnerPlayerOrPlayerItself()` for non-player units.

---

## Data flow

```
damage event (melee / spell / periodic)
  └─ ModPvPUnitScript hook
       └─ ApplyPvPModifiers(victim, attacker, damage)
            ├─ guard: attacker must be player or player-owned, victim must be player
            ├─ Layer 1: damage *= (1 - g_pvpDmgReductionPct / 100)
            └─ Layer 2 (levels 10–79 only):
                 ├─ targetResil = GetBracketTargetPct(victim->GetLevel())
                 ├─ currentResil = victim->GetMeleeCritChanceReduction()
                 └─ if currentResil < targetResil:
                      damage *= (1 - (targetResil - currentResil) / 100)
```

---

## Registered scripts

| Script class | Base class | Hook used |
|---|---|---|
| `ModPvPUnitScript` | `UnitScript` | `ModifyMeleeDamage`, `ModifySpellDamageTaken`, `ModifyPeriodicDamageAurasTick` |
| `ModApocalipsePvPWorld` | `WorldScript` | `OnStartup`, `OnAfterConfigLoad` |

Config values are (re-)loaded on both initial startup and live config reloads so they can be adjusted without restarting the worldserver.

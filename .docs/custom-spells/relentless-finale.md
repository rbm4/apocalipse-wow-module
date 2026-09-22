# Relentless Finale

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_rogue_relentless_finale.cpp`, `data/sql/db-world/2026_09_22_10_relentless_finale.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-22

## Purpose

Relentless Finale is offensive Rogue meta passive 901084. Every player-initiated five-combo-point Rogue finisher restores 5 percent maximum health. It also exposes an infinite-duration ready buff that makes the next qualifying finisher retain all five combo points. The ready buff then returns exactly 12 seconds after a retention, so the Rogue can identify and use the guaranteed double-finisher window.

## Acquisition and applicability

Acquisition remains external. The talent flow must grant only passive 901084. Ready, bypass, recharge, and heal spells 901085 through 901088 are internal and must not be taught or placed in a rank chain.

Humans and playerbots use identical mechanics. Existing finisher actions activate the passive automatically. No new bot action is required, although existing AI does not deliberately pool Energy or sequence two finishers around the ready indicator.

## Spell graph

| Spell | Contract |
|---|---|
| 901084 Relentless Finale | Permanent passive and lifecycle owner |
| 901085 Relentless Finale Ready | Visible, non-cancelable, infinite-duration ready indicator |
| 901086 Relentless Finale Bypass | Hidden one-second transient aura 262 applied only while a qualifying cast executes |
| 901087 Relentless Finale Recharge | Hidden non-saved timer set to 12000 ms at runtime |
| 901088 Relentless Finale Heal | Non-critical native heal for 5 percent maximum health |

The bypass uses `SPELL_AURA_ABILITY_IGNORE_AURASTATE`, which makes the core set `Spell::m_needComboPoints` false. The strict-check hook first duplicates the core's explicit-target combo ownership check and requires exactly five points, then applies the one-second bypass before the core evaluates aura-state overrides. Lower-point and wrong-target finishers never receive the bypass. `_handle_finish_phase()` therefore skips clearing only for the qualifying cast.

## Runtime flow

```text
passive 901084 applies
  -> if no recharge is active, apply visible ready aura 901085

player begins a non-triggered Rogue finisher with exactly five combo points
  -> mark the qualifying cast
  -> when ready aura 901085 is present, apply transient bypass 901086
  -> core executes the finisher, retaining points only when bypass is present
  -> every successful qualifying cast triggers 901088 for 5 percent maximum-health healing
  -> a retained cast removes bypass and ready
  -> apply hidden recharge 901087 and set its duration to 12000 ms

recharge expires
  -> apply infinite ready aura 901085 again
```

Triggered and copied finishers have triggered cast flags and are rejected before bypass application. Canceled tracked casts remove the transient bypass, while an early failed check leaves at most the bypass's one-second runtime duration; both leave the ready aura available. A cast that completes but misses still counts as using the finisher: it heals, consumes ready, and starts recharge. The 12-second timer is created only after cast completion and is not periodic or anchored to passive application.

The path is constant-time and performs no combat-time database access.

## Data and deployment

The guarded automatic world update collision-checks 901084 through 901088 across `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs all five rows, bindings for passive 901084 and recharge 901087, non-save metadata for transient state, and backend names. No acquisition row is installed.

Matching client `Spell.dbc` rows are required. The server update, client patch, external grant of passive 901084, and module rebuild must ship together. Live database and deployed-client collision checks remain operator work.

## Verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Passive acquired with no recharge | Infinite ready buff appears | Not run |
| Player-initiated finisher at one through four points | Normal consumption and no Relentless Finale healing or recharge | Not run |
| Player-initiated five-point finisher while ready | Finisher executes, five points remain, and 5 percent maximum health is restored | Not run |
| Immediate second five-point finisher | Consumes retained points normally because ready is absent and restores another 5 percent maximum health | Not run |
| Five-point finisher during recharge | Consumes points normally and restores 5 percent maximum health without restarting recharge | Not run |
| Twelve seconds after activation | Ready returns once, measured from the activating finisher | Not run |
| Qualifying finisher completes but misses | Core retains points; talent still heals, consumes ready, and starts recharge because the finisher was used | Not run |
| Finisher is canceled or fails before cast completion | No heal or recharge; ready remains and transient bypass is removed or expires within one second | Not run |
| Triggered or copied five-point finisher | Does not consume ready, heal, or start recharge | Not run |
| Passive removed during ready or recharge | All internal auras are removed and no later ready buff appears | Not run |
| Human and playerbot Rogue | Mechanics are identical after external acquisition | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove passive 901084 from external acquisition, remove both script bindings, custom attributes, backend names, and spell rows 901084 through 901088, then restore the previous client patch. Rebuild without the source and loader registration before restarting.

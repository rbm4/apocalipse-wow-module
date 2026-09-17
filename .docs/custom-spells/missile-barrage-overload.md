# Missile Barrage Overload

Status: Implemented in source, build and runtime not verified

Owners: `src/mod_apocalipse_mage_missile_barrage_overload.cpp`, `data/sql/db-world/2026_09_17_01_missile_barrage_overload.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-17

## Purpose

Missile Barrage Overload is a custom Arcane Mage passive using provisional spell ID 901004. While the passive is active, repeated applications of Missile Barrage proc aura 44401 accumulate up to 20 procs. The first proc retains normal Missile Barrage behavior, and every additional proc adds one periodic missile to the next Arcane Missiles channel. A successful Arcane Missiles cast consumes the complete accumulated proc.

## Acquisition boundary

The module defines and consumes passive spell 901004, but does not grant it or add it to `mod_spec_spells`. Talent acquisition and matching client talent data remain outside this feature.

## Human and bot applicability

Human and bot-controlled mages use identical aura, channel, consumption, and visual behavior. No bot detection or database query runs in combat. Existing playerbot logic treats Missile Barrage as a binary aura and does not deliberately wait for 20 procs.

## Spell graph

| Surface | Contract |
|---|---|
| Passive spell | `SPELL_APOC_MAGE_MISSILE_BARRAGE_OVERLOAD = 901004` |
| Missile Barrage proc | Spell 44401, script binding `spell_apoc_mage_missile_barrage_overload_proc` |
| Arcane Missiles | Rank chain rooted at 5143, recognized by Mage family flag `0x00000800` |
| Release visual | Existing visual-only spell 35426 on the Arcane Missiles target when more than one proc is released |
| Passive cleanup | Script binding `spell_apoc_mage_missile_barrage_overload_passive` on 901004 |
| Registration | `AddModApocalipseMageMissileBarrageOverloadScripts()` |
| Server migration | `data/sql/db-world/2026_09_17_01_missile_barrage_overload.sql` |
| Client presentation | Matching client `Spell.dbc` and separate talent data required |

## Runtime flow

```text
Missile Barrage proc aura 44401 is applied
  -> require passive aura 901004
  -> initialize the aura-local proc count at one
  -> expose the count through 44401 charges
  -> retain the normal -2500 ms channel-duration modifier

Missile Barrage proc aura 44401 is reapplied
  -> increment the aura-local count up to min(passive amount, 20)
  -> restore the visible charge count after normal aura refresh
  -> add 500 ms to the duration modifier for each proc after the first

Arcane Missiles successfully starts with 44401 active
  -> normal Missile Barrage duration, interval, and mana modifiers are applied
  -> if the count exceeds one, play visual-only spell 35426 on the target
  -> collapse 44401 to one charge before normal proc consumption
  -> the existing proc pipeline decrements to zero and removes the whole aura
```

## Missile count

The existing 44401 data reduces Arcane Missiles from 5 seconds to 2.5 seconds and its interval from 1 second to 0.5 seconds. The module changes only the duration modifier:

```text
duration modifier = -2500 ms + (proc count - 1) * 500 ms
missile count = 5 + (proc count - 1)
```

At 20 procs, Arcane Missiles has a 12 second pre-haste channel and fires 24 missiles. The mana-cost modifier remains -100 percent and the interval modifier remains -500 ms.

## Proc and set-bonus interactions

- Clearcasting continues to defer to Missile Barrage because aura 44401 remains active until the Arcane Missiles channel has started.
- The Mage T8 four-piece retention roll executes before preparation. When it succeeds, the entire accumulated proc remains. When it fails, all accumulated procs are consumed.
- Removing 44401 after the channel starts preserves the existing T10 two-piece handshake with the active Arcane Missiles aura.
- Interrupting Arcane Missiles after the channel starts does not restore the consumed proc, matching existing Missile Barrage behavior.
- A new Missile Barrage generated after consumption belongs to the next Arcane Missiles cast.

## Visual contract

Spell 35426 is an existing visual-only Arcane Explosion spell and is cast by the target on itself when a multi-proc barrage is released. The visual has no module-owned damage.

The particle scale is defined by client SpellVisual and SpellVisualKit data. The server script cannot safely enlarge only that effect. Changing unit scale would resize the target rather than the particle and is intentionally not used. A larger explosion requires a custom client visual kit and a matching spell visual assignment.

## Data and deployment

The automatic world update creates passive spell 901004 as an infinite Arcane-school Mage dummy aura whose effect amount is 20. It adds both exact script bindings and synchronizes `wotlk_spells`. A collision with a foreign 901004 record in `spell_dbc`, `wotlk_spells_full`, or `wotlk_spells` makes the guarded insert fail before module data is attached.

The migration does not change spell 44401, its `spell_proc` row, Arcane Missiles, or talent data. Worldserver must restart after the update so spell data and bindings are loaded.

Before deployment, provide:

- A matching client `Spell.dbc` row for 901004.
- Separate server and client talent data if 901004 will be acquired through a talent.
- A custom SpellVisual asset only if a larger release visual is required.

## Failure modes

| Failure | Result | Detection and recovery |
|---|---|---|
| Passive 901004 missing | Both module scripts fail validation or remain gated off | Check updater execution and startup spell-script validation |
| Passive not learned | Missile Barrage retains normal one-proc behavior | Provide acquisition data separately |
| 44401 binding missing | Repeated procs only refresh normal Missile Barrage | Check the exact `spell_script_names` row |
| Passive cleanup binding missing | Removing 901004 can leave an active overloaded 44401 until it expires or is cast | Restore the 901004 binding |
| Foreign ID collision | Migration fails before attaching bindings | Allocate a new ID and update source, SQL, client data, and docs together |
| Client spell row missing | Server behavior may work with broken passive presentation | Deploy matching client spell data |
| Visual spell missing | The 44401 overload script fails validation | Restore base spell 35426 or replace it with a validated visual-only spell |

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Missile Barrage without 901004 | Normal five-missile proc and normal consumption | Not run |
| First proc with 901004 | One displayed charge and five missiles | Not run |
| Two procs | Two displayed charges, release visual, and six missiles | Not run |
| Twenty procs | Cap at 20 displayed charges and 24 missiles | Not run |
| Proc beyond cap | Count remains 20 and aura duration refreshes | Not run |
| Arcane Missiles cast fails before channel start | Accumulated proc remains | Not run |
| Channel starts and is interrupted | Entire proc is consumed | Not run |
| T8 retention succeeds | Entire accumulated proc remains | Not run |
| T8 retention fails | Entire accumulated proc is removed and T10 behavior remains correct | Not run |
| Passive removed while 44401 is active | 44401 is removed immediately | Not run |
| Human and bot mage | Identical combat behavior | Not run |

## Open items

- Build against the exact custom AzerothCore and `mod-playerbots` deployment branches.
- Apply the automatic update to a non-production test world database.
- Export and deploy matching client spell and talent data.
- Execute the runtime verification matrix.
- Create a custom client visual kit if the release explosion must be larger.

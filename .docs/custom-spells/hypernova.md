# Hypernova

Status: Implemented in source, build and runtime not verified

Owners: `src/mod_apocalipse_mage_hypernova.cpp`, `data/sql/db-world/2026_09_17_01_hypernova.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-17

## Purpose

Hypernova is a level-80 active Arcane Mage spell using provisional spell ID 901005. It instantly detonates at an enemy target, damages enemies within 10 yards, launches them upward with a small outward displacement, and leaves the caster with four Arcane Blast stacks.

## Acquisition boundary

This module defines spell 901005 and its runtime behavior but does not teach or grant it. Trainer, talent, item, or specialization acquisition remains outside this change.

A matching client `Spell.dbc` row is required before players can use the spell normally through the client. The backend spell cache receives the Hypernova name, but that does not replace the client patch.

## Human and bot applicability

Human and bot-controlled mages use the same damage, mana cost, cooldown, charge grant, target selection, and immunity rules. The script performs no bot detection or database queries in combat.

Human players execute knockback through the normal client movement packet and acknowledgement path. The deployed playerbot module converts that packet into server-controlled spline movement and clamps very small horizontal values when needed.

## Spell graph

| Surface | Contract |
|---|---|
| Active spell | `SPELL_APOC_MAGE_HYPERNOVA = 901005` |
| Arcane Blast stack aura | 36032, forced to its four-stack DBC cap after a successful cast |
| Visual helper | 35426 Arcane Explosion Visual, cast by the selected target on itself |
| Script | `spell_apoc_mage_hypernova` |
| Registration | `AddModApocalipseMageHypernovaScripts()` |
| Server migration | `data/sql/db-world/2026_09_17_01_hypernova.sql` |
| Client presentation | Matching client `Spell.dbc` required |

Spell ID 901005 follows the existing allocations because the working source already reserves 901004 for Missile Barrage Overload. Deployment must still collision-check 901005 in every server and client spell source.

## Runtime flow

```text
successful Hypernova cast against an enemy unit
  -> resolve that unit as the destination center
  -> play Arcane Explosion Visual 35426 at the target
  -> select hostile units within 10 yards of that destination
  -> deal Arcane school damage through the normal spell pipeline
  -> apply destination-centered knockback through effect 144
  -> after immediate effects finish, schedule the four-stack reward
  -> finish Hypernova's cast-phase and finish-phase proc processing
  -> one millisecond later, cast aura 36032 on the mage at four stacks
```

The spell has speed zero. This keeps all area hits immediate before `AfterCast` schedules the four-stack reward. The delayed lambda is owned by the caster's `m_Events` queue, matching the core's established player-event lifetime pattern.

## Damage and talent interaction

Arcane Blast rank 4 has a base range of 1185 to 1377 and a direct spell-power coefficient of 0.714 in the deployed core data. Hypernova uses four times both values:

- Base damage: 4740 to 5508.
- Direct spell-power coefficient: 2.856.
- School mask: 64, Arcane.
- Spell family: 3, Mage.
- Family mask 0: 4096, the Arcane Explosion family bit.
- Damage class: Magic.

The Arcane school and Mage family fields preserve normal spell damage, critical strike, hit, threat, resistance, Arcane talent, spell modifier, PvP balancing, and target AoE-avoidance processing. The Arcane Explosion family bit allows applicable Mage modifiers such as Arcane Potency and Arcane Explosion-specific effects without pretending Hypernova is Arcane Blast for Missile Barrage.

Existing Arcane Blast stacks can increase Hypernova's Arcane damage. The normal 36032 proc contract recognizes the Arcane Explosion family bit, so the cast can consume the prior stack aura. Hypernova schedules a fresh four-stack 36032 aura from `AfterCast`, then applies it one millisecond later after the current cast proc phases. The 36032 cost modifier only targets Arcane Blast's family bit, so Hypernova remains at its own 22 percent base mana cost.

Player-cast area damage is subject to the core's normal damage distribution cap above 10 targets. No `mod_spell_scaling` row is added because this is a level-80 spell with a fixed rank-4 Arcane Blast baseline.

## Knockback contract

Effect 1 uses `SPELL_EFFECT_KNOCK_BACK_DEST` with the same destination target pair and 10-yard radius as the damage effect:

- Calculated vertical value: 100, producing vertical speed 10.
- Misc value: 20, producing horizontal speed 2.
- Approximate maximum launch height: 2.59 yards.
- Approximate horizontal travel on level ground: 2.07 yards.

The normal core handler supplies vehicle, boss, giant, knockback-immune creature, root, cast interruption, player packet, playerbot packet, creature spline, collision, and anticheat behavior. Hypernova does not call `Unit::KnockbackFrom` directly.

## Mana, cooldown, and targeting

- Instant cast through casting-time index 1.
- 22 percent base mana, matching Arcane Explosion rank 10.
- 45 second spell cooldown.
- Normal 1.5 second Mage global cooldown.
- 30-yard enemy target range through range index 4.
- 10-yard hostile area centered at the selected target.

The selected target participates in the same hostile area search as nearby enemies.

## Visual contract

The script casts spell 35426 on the selected target to place an Arcane Explosion visual at that unit's feet. The Hypernova row does not attach a second spell visual, avoiding a duplicate explosion at the mage.

Spell visual size is client asset data and cannot be enlarged safely through this server spell row. A larger model would require a separate client-side visual asset or visual-kit patch. The implementation intentionally uses the original Arcane Explosion Visual size.

## Database contract

The automatic world update:

1. Collision-checks 901005 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`.
2. Recognizes only the expected Hypernova signature as module-owned.
3. Inserts the server spell row when absent.
4. Binds `spell_apoc_mage_hypernova`.
5. Adds a `spell_bonus_data` coefficient of 2.856.
6. Synchronizes the backend name cache.

The related rows are written only when the expected spell signature is present. A foreign collision causes the guard query to fail before the spell insert.

## Failure modes

| Failure | Result | Detection and recovery |
|---|---|---|
| Spell 901005 missing | Script validation fails and Hypernova cannot be cast | Check module updater execution and restart worldserver |
| Script binding missing | Damage and knockback work, but visual and four-stack grant do not | Check `spell_script_names` for 901005 |
| Aura 36032 missing or stack cap changed | Script validation fails | Restore matching 3.3.5a spell data |
| Visual 35426 missing | Script validation fails | Restore matching visual helper spell data |
| Foreign 901005 collision | Automatic update fails before related rows are written | Allocate a new ID and update source, SQL, client data, and docs together |
| Client spell row missing | Server data exists but the client cannot present or cast Hypernova normally | Export and deploy the matching client `Spell.dbc` |
| Target is root, boss, giant, vehicle-bound, or knockback immune | Damage can land while movement is suppressed | Expected core behavior |
| More than 10 enemies are selected | Core area damage distribution reduces per-target damage | Expected core behavior |

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Cast on a hostile unit at 30 yards | Instant target-centered explosion and cooldown start | Not run |
| Mana use | Costs the same 22 percent base mana as Arcane Explosion rank 10 | Not run |
| One target without spell power | Damage remains within 4740 to 5508 before mitigation | Not run |
| Spell power and Arcane talents active | Normal Arcane and Mage modifiers increase damage | Not run |
| Existing zero through four Arcane Blast stacks | Damage uses applicable pre-cast modifiers and caster finishes at four stacks | Not run |
| Several enemies within 10 yards | Every eligible enemy is damaged and displaced from the target center | Not run |
| Rooted or knockback-immune enemy | Damage lands and movement is suppressed | Not run |
| Human mage and playerbot mage | Identical spell results, with their respective normal movement paths | Not run |
| Client patch missing | Spell is unavailable or incorrectly presented | Not run |

## Rollback

Stop worldserver, take the normal world-database backup, remove the 901005 rows from `spell_script_names`, `spell_bonus_data`, `wotlk_spells`, and `spell_dbc`, restore the previous client patch, rebuild without the Hypernova registration and source, then restart. Production rollback remains an explicit operator action and is not performed by the module update.

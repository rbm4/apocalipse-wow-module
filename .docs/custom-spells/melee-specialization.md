# Melee Specialization

Status: Implemented in data, database and runtime not verified

Owner: `data/sql/db-world/2026_09_21_02_melee_specialization.sql`

Last source review: 2026-09-21

## Purpose

Melee Specialization is Hunter passive 901047. It makes Raptor Strike, Mongoose Bite, and Counterattack satisfy any aura-state requirement and increases the damage of Raptor Strike, Mongoose Bite, Wing Clip, and Counterattack by 30 percent. In the deployment DBC, only Counterattack currently has such a requirement; Raptor Strike and Mongoose Bite are already unrestricted by aura state.

## Acquisition boundary

The module defines passive 901047 but does not teach it. Talent, trainer, item, specialization, and playerbot acquisition remain external. Acquisition must reference only 901047, and matching server and client `Spell.dbc` rows are required.

## Human and bot applicability

Human and bot-controlled Hunters receive identical native aura-state and damage modifiers while they know passive 901047. Existing bot melee actions need no new script integration. Acquisition remains external.

## Spell contract

| Surface | Contract |
|---|---|
| Passive | 901047 Melee Specialization |
| Aura-state bypass | `SPELL_AURA_ABILITY_IGNORE_AURASTATE` 262 with misc value 1 |
| Damage increase | `SPELL_AURA_ADD_PCT_MODIFIER` 108 with `SPELLMOD_DAMAGE` 0 and amount 30 percent |
| Aura-state masks | word 0 `0x00000002`, word 1 `0x00080000`, word 2 `0x00010000` |
| Damage masks | word 0 `0x00000042`, word 1 `0x00080000`, word 2 `0x00010000` |
| Aura-state mask families | Raptor Strike, Mongoose Bite, and Counterattack ranks; only Counterattack currently declares a caster aura state |
| Damage families | Raptor Strike, Mongoose Bite, Wing Clip, and Counterattack ranks |
| Runtime script | None; native core aura and spell-modifier handling only |
| Server migration | `data/sql/db-world/2026_09_21_02_melee_specialization.sql` |

## Runtime flow

```text
Hunter knows passive 901047
  -> effect 0 supplies the three Hunter family masks to aura type 262
  -> Unit::HasAuraState treats an affected melee ability's required state as present
  -> Spell::CheckCast also disables the surrounding combat-only restriction for affected spells
  -> effect 1 registers a 30 percent SPELLMOD_DAMAGE modifier that also includes Wing Clip
  -> affected Raptor Strike, Mongoose Bite, Wing Clip, and Counterattack damage is multiplied by 1.30
```

The bypass does not remove melee range, weapon, resource, cooldown, target, silence, disarm, or other cast checks. For an affected spell that declares a caster aura state, it satisfies that state and suppresses the surrounding combat requirement through misc value 1. Counterattack declares caster aura state 7 in the deployment DBC. Raptor Strike and Mongoose Bite declare caster aura state 0, so they are already castable without a dodge or parry event; their inclusion in effect 0 is harmless and preserves the requested family contract.

## Family-mask basis

The deployment `Spell.dbc` was inspected for Hunter family 9. Mongoose Bite ranks carry word 0 bit `0x00000002`. Raptor Strike ranks carry that bit plus word 2 bit `0x00010000`. Wing Clip ranks carry word 0 bit `0x00000040`, and Counterattack ranks carry word 1 bit `0x00080000`. Effect 0 omits the Wing Clip bit because Wing Clip has no reactive aura-state gate. Effect 1 combines all four player Hunter melee families. NPC spells with the same names and family 0 are not affected.

## Database and client contract

The automatic world update collision-checks 901047 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs one passive row and its backend spell name. No `spell_script_names`, `spell_proc`, scaling, or custom-attribute row is required.

The client `Spell.dbc` row must preserve both effects, the Hunter spell family, all effect class masks, and the passive attribute. Client and server rows must agree before acquisition is enabled.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Hunter without 901047 casts Raptor Strike or Mongoose Bite without a reactive event | No aura-state rejection because both stock families declare caster aura state 0 | Not run |
| Hunter with 901047 casts Raptor Strike or Mongoose Bite without a reactive event | Same cast eligibility as baseline; damage receives the passive modifier | Not run |
| Hunter without 901047 casts Counterattack without a parry | Normal aura-state rejection | Not run |
| Hunter with 901047 casts Counterattack without a parry | Cast passes the reactive aura-state check | Not run |
| Affected ability deals damage with no other modifiers | Damage is 30 percent above the same baseline without 901047, subject to normal integer rounding | Not run |
| Wing Clip deals damage | Damage is increased by 30 percent; no aura-state behavior changes | Not run |
| Ranged shots, traps, auto-attacks, or pet attacks deal damage | No modifier from 901047 | Not run |
| Affected ability violates range, weapon, resource, cooldown, or target checks | Normal rejection remains | Not run |
| Human and playerbot Hunter | Identical mechanics when 901047 is acquired | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove acquisition references, remove 901047 from `wotlk_spells` and `spell_dbc`, and restore the previous client patch before restarting.

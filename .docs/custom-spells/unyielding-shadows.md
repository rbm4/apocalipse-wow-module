# Unyielding Shadows

Status: Implemented in data; database application, client export, and runtime not verified

Owner: `data/sql/db-world/2026_09_20_08_unyielding_shadows.sql`

Last source review: 2026-09-20

## Purpose

Unyielding Shadows is a custom Warlock passive using spell ID 901035. While active, the Warlock's curses and selected Shadow-school hostile auras have 100 percent dispel resistance. Unstable Affliction is deliberately excluded so its stock dispel backlash remains usable.

## Acquisition boundary

The module defines passive 901035 but does not grant it or modify talent data. The separate talent-data workflow must teach unranked passive 901035 as its only spell reference. A matching client `Spell.dbc` row and talent presentation are required.

## Human and bot applicability

Humans and bot-controlled Warlocks use identical native spell-modifier behavior while passive 901035 is active. Owner spell modifiers also cover matching Warlock-family demon effects such as Seduction. No bot detection, custom AI, C++ script, runtime target scan, or combat-time database access is used.

## Spell graph

| Surface | Contract |
|---|---|
| Passive | 901035 Unyielding Shadows |
| Native aura | `SPELL_AURA_ADD_FLAT_MODIFIER` 107 |
| Spell modifier | `SPELLMOD_RESIST_DISPEL_CHANCE` 28 |
| Amount | 100 percent, encoded as base points 99 plus one die side |
| Icon | Stock Corruption `SpellIconID` 313 |
| Warlock family mask | `(0xC04CC41A, 0x1804161B, 0x00000000)` |
| Excluded UA bit | Word 1 `0x00000100` |
| Server migration | `data/sql/db-world/2026_09_20_08_unyielding_shadows.sql` |
| C++ registration | None required |
| Client presentation | Matching client `Spell.dbc` and separate talent data required |

## Affected stock behavior

The checked-in deployment DBC confirms the mask covers the playable rank chains for Corruption, every player curse, Fear, Howl of Terror, Death Coil, Banish, Drain Life, Drain Mana, Seed of Corruption, Shadowfury, Haunt, Shadow Embrace, and the owner's Seduction. Matching legacy Siphon Life variants are also selected. Non-dispellable matching spells such as Drain Soul are harmlessly selected because no dispel operation can remove them.

All known Unstable Affliction ranks use only Warlock family word 1 bit `0x00000100`. That bit is absent from the modifier mask. The UA periodic aura therefore retains its stock dispel chance, and spell 31117 continues to handle its dispel consequence.

The family mask also selects stock NPC or quest variants that reuse the same Warlock bits. They receive protection only when their aura caster resolves to a spell-mod owner carrying passive 901035.

## Runtime flow

```text
Warlock has passive 901035
  -> native spell modifier registers +100 resist-dispel chance
  -> Warlock or owned demon applies a matching hostile aura
  -> a dispel path asks the aura for its current dispel chance
  -> the aura resolves its original caster and spell-mod owner
  -> the combined Warlock family mask contributes 100 resistance
  -> core clamps resistance to 100 and returns a zero dispel chance
  -> zero-chance aura is skipped and remains active
```

The core computes resistance when the dispel is attempted. Learning or removing the passive therefore affects existing caster-owned matching auras without requiring them to be recast.

## Dispel behavior

The implementation reuses `Aura::CalcDispelChance`, which applies caster spell modifiers before clamping resistance to 100. Normal dispels and Spellsteal use this calculation. Mechanic-removal effects also use it before removing matching auras.

The passive prevents dispel removal only. It does not prevent expiration, channel termination, death cleanup, immunity cleanup, scripted removal, aura replacement, or explicit administrator commands. Banish keeps its existing special Mass Dispel restriction in addition to this passive.

## Server spell contract

The automatic world update defines 901035 as an infinite passive Warlock Shadow aura. Its single native flat spell-modifier effect carries operation 28, amount 100, and the combined family mask. No `spell_script_names`, proc, rank, group, linked-spell, or custom-attribute row is required.

The migration collision-checks `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`, synchronizes the backend spell picker name, and provides the fields required by the existing backend `Spell.dbc` patch exporter. It does not create talent acquisition data or a deployed client patch.

## Deployment and rollback

Before deployment, verify 901035 is free in live `spell_dbc`, `wotlk_spells_full`, `wotlk_spells`, and the selected client `Spell.dbc`. Apply the automatic updater through normal worldserver startup, export and deploy matching client and talent data, and restart worldserver so the passive definition loads.

Rollback requires the normal database backup and stopped-worldserver procedure. Remove the module-owned 901035 rows, acquisition references, and matching client data together. No module rebuild or loader change is required.

## Verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Warlock without passive applies a covered debuff | Enemy dispels retain stock behavior | Not run |
| Warlock with passive applies each curse | Curse dispels have zero chance | Not run |
| Warlock with passive applies Corruption, Fear, or another covered aura | Dispel attempts cannot remove the aura | Not run |
| Warlock with passive applies Unstable Affliction | UA retains stock dispel and backlash behavior | Not run |
| Two Warlocks apply the same debuff and only one has the passive | Only the passive owner's aura is protected | Not run |
| Passive is learned or removed while a covered aura is active | Existing aura immediately gains or loses protection | Not run |
| Owned Succubus applies Seduction | Owner passive protects the matching aura | Not run |
| Covered aura expires or is removed outside a dispel path | Normal removal still occurs | Not run |
| Bot with passive applies a covered aura | Same protection as a human | Not run |

## Known limitations

- Protection intentionally follows DBC family flags rather than a hardcoded spell-ID list. Future custom spells reusing any selected bit inherit the modifier.
- Family flags cannot distinguish player ranks from NPC and quest variants that reuse the same bits.
- If an aura's original caster or spell-mod owner cannot be resolved, stock dispel behavior applies.
- Live database, deployed client data, startup validation, and in-game behavior remain unverified.

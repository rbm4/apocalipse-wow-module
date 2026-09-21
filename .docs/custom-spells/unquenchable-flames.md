# Unquenchable Flames

Status: Implemented in data; database application, client export, and runtime not verified

Owner: `data/sql/db-world/2026_09_20_07_unquenchable_flames.sql`

Last source review: 2026-09-20

## Purpose

Unquenchable Flames is a custom Warlock passive using spell ID 901034. While active, the Warlock's Immolate and Shadowflame auras have 100 percent dispel resistance and cannot be removed by dispel effects.

Conflagrate is included in the gameplay intent through the fire auras it consumes. WotLK Conflagrate is direct damage and does not place a dispellable aura of its own.

## Acquisition boundary

The module defines passive 901034 but does not grant it or modify talent data. The separate talent-data workflow must teach unranked passive 901034 as its only spell reference; there is no `spell_ranks` chain or helper spell to acquire. A matching client `Spell.dbc` row and talent presentation are required.

## Human and bot applicability

Humans and bot-controlled Warlocks use identical native spell-modifier behavior while passive 901034 is active. No bot detection, custom AI, C++ script, runtime target scan, or combat-time database access is used.

## Spell graph

| Surface | Contract |
|---|---|
| Passive | 901034 Unquenchable Flames |
| Native aura | `SPELL_AURA_ADD_FLAT_MODIFIER` 107 |
| Spell modifier | `SPELLMOD_RESIST_DISPEL_CHANCE` 28 |
| Amount | 100 percent, encoded as base points 99 plus one die side |
| Icon | Stock Immolate `SpellIconID` 31 |
| Warlock family mask | Word 0 bit `0x00000004` for Immolate; word 2 bit `0x00000002` for Shadowflame |
| Server migration | `data/sql/db-world/2026_09_20_07_unquenchable_flames.sql` |
| C++ registration | None required |
| Client presentation | Matching client `Spell.dbc` and separate talent data required |

## Runtime flow

```text
Warlock has passive 901034
  -> native spell modifier registers +100 resist-dispel chance
  -> Warlock applies an Immolate or Shadowflame aura
  -> a dispel path asks the aura for its current dispel chance
  -> the aura resolves its original Warlock caster
  -> the caster's exact family-mask modifier contributes 100 resistance
  -> core clamps resistance to 100 and returns a zero dispel chance
  -> zero-chance aura is skipped and remains active
```

The core computes resistance when the dispel is attempted. Learning or removing the passive therefore affects existing caster-owned Immolate and Shadowflame auras without requiring them to be recast.

## Scope and ownership rules

The modifier applies only when all of these are true:

- The aura has a currently resolvable Warlock caster with the passive active.
- The aura belongs to Warlock spell family 5.
- Its family flags contain Immolate word 0 bit `0x00000004` or Shadowflame word 2 bit `0x00000002`.

Each Warlock's aura resolves its own caster. One Warlock's passive does not protect another Warlock's effects. Other Fire spells and other Warlock Magic debuffs remain normally dispellable unless their DBC family flags deliberately share one of the two protected bits.

## Dispel behavior

The implementation reuses `Aura::CalcDispelChance`, which applies caster spell modifiers before clamping resistance to 100. Normal dispels and Spellsteal use this calculation. Mechanic-removal effects also use it before removing matching auras.

The passive prevents dispel removal only. It does not prevent expiration, Conflagrate consumption, death cleanup, immunity cleanup, scripted removal, aura replacement, or explicit administrator commands.

## Server spell contract

The automatic world update defines 901034 as an infinite passive Warlock Fire aura. Its single native flat spell-modifier effect carries operation 28, amount 100, and the exact Immolate and Shadowflame family masks. No `spell_script_names`, proc, rank, group, or custom-attribute row is required.

The migration collision-checks `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`, synchronizes the backend spell picker name, and provides all fields required by the existing backend `Spell.dbc` patch exporter. It does not create talent acquisition data or a deployed client patch.

## Deployment and rollback

Before deployment, verify 901034 is free in live `spell_dbc`, `wotlk_spells_full`, `wotlk_spells`, and the selected client `Spell.dbc`. Apply the automatic updater through normal worldserver startup, export and deploy matching client and talent data, and restart worldserver so the passive definition loads.

Rollback requires the normal database backup and stopped-worldserver procedure. Remove the module-owned 901034 rows, acquisition references, and matching client data together. No module rebuild or loader change is required.

## Verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Warlock without passive casts Immolate | Enemy dispels retain stock behavior | Not run |
| Warlock with passive casts any Immolate rank | Dispel attempts cannot remove that Warlock's Immolate | Not run |
| Warlock with passive casts either Shadowflame rank | Dispel attempts cannot remove that Warlock's Shadowflame aura | Not run |
| Warlock with passive casts another dispellable Warlock debuff | The unrelated debuff retains stock dispel behavior | Not run |
| Two Warlocks apply Immolate and only one has the passive | Only the passive owner's aura is protected | Not run |
| Passive is learned while a protected aura is active | The existing aura immediately receives zero dispel chance | Not run |
| Passive is removed while a protected aura is active | The existing aura returns to stock dispel chance | Not run |
| Conflagrate consumes a protected aura without its glyph | Normal consumption still occurs | Not run |
| Protected aura expires or is removed by death or immunity cleanup | Normal non-dispel removal still occurs | Not run |
| Bot with passive applies Immolate or Shadowflame | Same protection as a human | Not run |

## Known limitations

- Family-mask protection intentionally follows DBC family flags rather than a hardcoded spell-ID list. A custom future spell that reuses either protected family bit will also inherit the modifier.
- If the aura's original caster cannot be resolved, the core cannot read that caster's spell modifiers and stock dispel behavior applies.
- Live database, deployed client data, startup validation, and in-game behavior remain unverified.

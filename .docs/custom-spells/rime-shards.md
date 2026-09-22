# Rime Shards

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_death_knight_rime_shards.cpp`, `data/sql/db-world/2026_09_21_06_death_knight_rime_shards.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-21

## Purpose

Rime Shards is Frost Death Knight passive 901054. Each positive normal or critical Frost Strike or Howling Blast damage event has a 30 percent chance to trigger target-centered Frost burst 901055. The burst starts from 20 percent of the triggering event damage, hits enemies within 10 yards, and is capped at 10 targets.

## Acquisition and applicability

The automatic world update adds passive 901054 to `mod_spec_spells` for Death Knight class 6, Frost tree index 1. Spec Manager grants and revokes it through its existing reconciliation flow. Humans and playerbots use identical mechanics, and no playerbot strategy or cast action is required.

## Spell graph

| Spell | Contract |
|---|---|
| 901054 Rime Shards | Permanent Frost dummy aura with 30 percent damage-hit proc metadata |
| 901055 Rime Shards Burst | Triggered target-centered Frost school damage in a 10-yard radius, maximum 10 targets, and Howling Blast visual |

The proc script accepts the complete Frost Strike rank chain, the Threat of Thassarian Frost Strike off-hand helper 66196, and the complete Howling Blast rank chain. Misses, full prevention, zero damage, non-damage effects, periodic events, pets, and unrelated Death Knight abilities do not qualify. Each Howling Blast victim is an independent qualifying damage event and receives its own 30 percent roll.

## Damage formula

The initial helper amount is:

```text
base helper damage = floor(triggering event damage * 0.20)
```

For `N` selected enemies, where `1 <= N <= 10`, each target receives:

```text
per-target damage = floor(base helper damage * (2N - 1) / N^2)
```

This produces 100 percent of the helper amount for one target, 75 percent per target for two targets, about 55.6 percent per target for three targets, and 19 percent per target for ten targets. Total pre-rounding helper output rises from 100 percent to 190 percent of the base helper amount and never exceeds the selected ten-target cap.

Spell 901055 has zero spell-power and attack-power coefficients. It is intentionally absent from `mod_spell_scaling`: the helper amount is already derived from source damage after the source spell's level scaling. The helper does not roll a second critical strike. It remains Frost spell damage and therefore follows normal Frost done and taken modifiers, resistance, resilience, module PvP balancing, threat, and per-target rounding when it resolves.

## Runtime flow

```text
Frost Death Knight has passive 901054
  -> Frost Strike, Frost Strike off-hand, or Howling Blast deals positive damage
  -> normal or critical result receives one 30 percent proc roll
  -> helper base amount snapshots 20 percent of that event damage
  -> triggered burst 901055 centers on the damaged target
  -> up to 10 enemies are selected within 10 yards
  -> per-target diminishing formula scales the post-bonus hit amount
  -> each target resolves normal Frost damage
```

The helper cannot recursively proc Rime Shards because its ID is not in either accepted source chain. The path performs no combat-time database access and owns only one target-count value per helper cast.

## Data and deployment

The guarded automatic world update collision-checks 901054 and 901055 across `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs both spell rows, proc metadata, both script bindings, zero bonus coefficients, Frost Spec Manager acquisition, and backend names. The helper visual and icon are copied at migration time from Howling Blast rank 4, spell 51411, with a zero visual and icon 2721 fallback.

Matching client `Spell.dbc` rows are required for both IDs before deployment. The server update, client patch, and Spec Manager acquisition must ship together. Live server tables and the selected deployed client remain pending collision checks.

## Verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Any Frost Strike rank deals positive normal or critical damage | One 30 percent roll | Not run |
| Threat of Thassarian off-hand Frost Strike deals damage | Its damage event receives an independent roll | Not run |
| Howling Blast hits multiple enemies | Each damage event receives an independent roll centered on its victim | Not run |
| Miss, immune, full prevention, zero damage, or unrelated ability | No burst | Not run |
| Burst finds one enemy | That enemy receives 100 percent of the helper amount before normal Frost resolution | Not run |
| Burst finds two enemies | Each receives 75 percent, for 150 percent aggregate before rounding | Not run |
| Burst finds ten or more enemies | At most ten are hit, each at 19 percent, for 190 percent aggregate before rounding | Not run |
| Burst damage resolves | It does not recursively trigger Rime Shards | Not run |
| Human and playerbot Frost Death Knight | Mechanics are identical | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove the 901054 Frost row from `mod_spec_spells`, remove 901054 from `spell_proc`, remove both script bindings, remove the 901055 bonus row, remove both backend names and spell rows, and restore the previous client patch. Rebuild without the source and loader registration before restarting.

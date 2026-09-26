# Threat of Thassarian extension

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_death_knight_threat_of_thassarian.cpp`, `data/sql/db-world/2026_09_25_02_threat_of_thassarian_extension.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-25

## Purpose

The extension preserves stock Threat of Thassarian and adds off-hand Heart Strike and Scourge Strike attacks. It also reduces the one stock Death Strike heal by 50 percent while the talented Death Knight has a usable off-hand weapon.

## Acquisition and ranks

This feature does not grant the talent or alter `Talent.dbc`. It observes the existing Threat of Thassarian rank chain:

| Rank | Spell | Off-hand chance |
|---|---:|---:|
| 1 | 65661 | 30 percent |
| 2 | 66191 | 60 percent |
| 3 | 66192 | 100 percent |

The existing talent-tree and acquisition flow must continue to reference these three IDs. No specialization receives the talent automatically from this migration.

## Spell graph

| Spell | Contract |
|---|---|
| 65661, 66191, 66192 | Existing Threat of Thassarian ranks and chance amounts |
| 901156 | Hidden zero-cost off-hand Scourge Strike helper |
| 901157 | Hidden zero-cost two-target off-hand Heart Strike helper |
| 70890 | Existing disease-scaled Scourge Strike Shadow helper |
| 45470 | Existing single Death Strike heal helper |

The repository-owned contiguous range is 901156 through 901157. Offline module migrations, module source, custom-core source, checked-in SQL, and the read-only local `Spell.dbc` showed no prior allocation. Live world-database and deployed-client collision checks remain pending operator work.

## Runtime behavior

```text
Threat of Thassarian proc event for Heart Strike or Scourge Strike
  -> require a usable off-hand weapon
  -> identify the exact stock source rank chain
  -> for Heart Strike, require the proc target to be the original explicit target
  -> roll the active aura amount: 30, 60, or 100 percent
  -> copy all three calculated source effect values into the matching helper
  -> resolve an independent off-hand melee spell with no resource or GCD cost
```

The additive aura script is bound through `-65661`, alongside the stock `spell_dk_threat_of_thassarian` script. The custom-core aura dispatcher invokes each loaded effect-proc handler even when another script prevents the default action, so stock Death Strike, Obliterate, Plague Strike, Rune Strike, Blood Strike, and Frost Strike behavior remains core-owned.

The extended `spell_proc` masks are `0x01400011` and `0x28020004`. The existing finish-phase and `0x477` hit-mask contract remains unchanged, so a main-hand miss, dodge, or parry can still launch the separately resolved off-hand attempt.

### Heart Strike

Helper 901157 retains Death Knight Heart Strike family mask `0x01000000`, native normalized weapon damage, weapon percentage, two chain targets, 0.5 secondary-target amplitude, and per-target disease scaling. The module starts it only from the source spell's original explicit target. This prevents the secondary main-hand victim from launching another two-target helper.

### Scourge Strike

Helper 901156 retains Death Knight Scourge Strike family mask `0x08000000`, normalized weapon damage, weapon percentage, and disease dummy effect. Exact binding to the existing `spell_dk_scourge_strike` script calculates helper 70890 from that helper's own final Physical hit. A successful dual-wield Scourge Strike can therefore produce main-hand Physical, main-hand Shadow, off-hand Physical, and off-hand Shadow events.

Both helpers require the off-hand attack type, suppress caster procs, and are cast with the deployment core's triggered custom-base-point API. They do not spend runes or Runic Power, start a GCD, reset swing timers, or recursively trigger Threat of Thassarian. Normal target-side combat handling, mitigation, critical resolution, threat, combat logging, and module PvP balancing remain core-owned.

## Death Strike healing

Script `spell_apoc_death_knight_death_strike_heal` is additive on stock heal 45470. It halves the final pre-resolution heal with integer truncation when the caster has a Death Knight dummy aura with Threat of Thassarian icon 2023 and a usable off-hand weapon.

This rule is equipment and talent-state based, not proc-result based. Ranks 1 and 2 therefore receive half healing on every qualifying dual-wield Death Strike cast even when their off-hand chance fails. The stock off-hand Death Strike helper remains unbound from `spell_dk_death_strike`, so there is exactly one heal.

No talent or no usable off-hand weapon leaves Death Strike healing unchanged. Off-hand disarm and broken-weapon handling use the deployment core's normal `HasOffhandWeaponForAttack()` contract.

## Data and client export

The automatic world update:

- collision-guards helpers 901156 and 901157 across `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`
- clones the complete three stock talent rows into `spell_dbc` before changing their English descriptions
- installs both complete helper rows and their backend `wotlk_spells` names
- binds the additive talent aura, Scourge Strike helper, and Death Strike heal scripts
- replaces only proc row `-65661` after validating its complete recognized stock or managed contract
- preserves the existing rank IDs, talent position, and acquisition

The backend release builder exports all `spell_dbc` overrides into `Spell.dbc` using the `wotlk_spells_full` field order. This supplies matching helper rows and the three description overrides without a second export path. `Talent.dbc` needs no structural change. MPQ generation and deployment were not run.

No `spell_bonus_data`, `mod_spell_scaling`, custom rank chain, spell group, linked spell, jump-distance row, or helper `spell_proc` row is required. Native weapon damage and the copied source-rank values own scaling.

## Human and playerbot behavior

Humans and playerbots use the same aura, equipment, spell, and heal paths. No `WorldSession::IsBot()` branch, playerbot AI dependency, strategy, action, trigger, or value is added. Existing bot Heart Strike, Scourge Strike, and Death Strike actions receive the mechanic automatically when the bot knows Threat of Thassarian and equips a usable off-hand weapon.

## Verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Rank 1, 2, or 3 Heart Strike | 30, 60, or 100 percent chance for one off-hand helper cast | Not run |
| Heart Strike with two enemies | One main-hand and one off-hand event per selected target with native secondary reduction | Not run |
| Heart Strike with one enemy | Exactly one main-hand and one off-hand event when the talent roll succeeds | Not run |
| Heart Strike main-hand miss, dodge, or parry | Off-hand chance still rolls and resolves independently | Not run |
| Scourge Strike with diseases | Each successful Physical strike derives its own Shadow component | Not run |
| Scourge Strike without diseases | Physical strikes occur with no disease-derived Shadow damage | Not run |
| Dual-wield Death Strike | Existing main and off-hand damage plus exactly one heal at 50 percent | Not run |
| Two-handed, broken off-hand, or off-hand-disarmed Death Strike | Full stock heal | Not run |
| No talent | No new helpers and full Death Strike heal | Not run |
| Human and equivalent bot | Identical results | Not run |
| Database updater | Guarded migration succeeds and startup validates bindings | Pending operator |
| Client export | Deployed client contains both helpers and all three talent descriptions | Pending operator |

## Rollback

Stop worldserver and take the normal world-database backup. Remove the module bindings, restore proc row `-65661` to masks `0x00400011` and `0x20020004`, remove helper names and rows 901156 and 901157, restore or remove the three module-created talent overrides, restore the previous client patch, and rebuild without the source and loader registration before restarting.

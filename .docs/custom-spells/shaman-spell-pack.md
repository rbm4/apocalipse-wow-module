# Shaman spell pack

Status: Implemented in source and SQL, pending build, migration, client export, and runtime validation

## Ownership

- Runtime: `src/mod_apocalipse_shaman_spells.cpp`
- Registration: `src/mod_apocalipse_loader.cpp`
- World update: `data/sql/db-world/2026_09_24_00_shaman_spell_pack.sql`
- Reserved graph: 901091 through 901117
- Acquisition: external for every player-facing spell in this pack

## Elemental contracts

| Spell | Behavior |
|---|---|
| 901091 Molten Anchors | Native Shaman-family spell modifier gives the caster's Flame Shock 50 percent dispel resistance. |
| 901092 Wildfire Contagion | Each same-caster Flame Shock periodic tick has a 20 percent chance to copy its exact rank to one random eligible enemy within 10 yards that lacks that caster's Flame Shock. |
| 901093 Triple Convergence | A successful Lava Burst against the caster's Flame Shock refreshes the primary aura, then applies that captured rank to three targets within 10 yards. Targets without that caster's Flame Shock sort before affected targets, and affected targets sort by ascending remaining duration. Each missing nearby target causes one additional primary recast. |
| 901094 Ascension: Rain of Fire | Three-minute active. A Flame Shock application registry resolves every living same-map hostile target currently carrying that caster's Flame Shock and triggers the caster's highest known Lava Burst rank on it. The parent ignores line of sight and triggered children inherit that rule. Marker 901095 suppresses Triple Convergence and Echoing Magma during the sequence. |
| 901096 Echoing Magma | A successful Lava Burst echoes 50 percent of final hit damage through non-critical, zero-coefficient Fire helper 901097 to the two nearest additional enemies within 10 yards carrying that caster's Flame Shock. Echoes never spread Flame Shock. |

The Flame Shock registry is maintained by the rank-wide `-8050` aura binding. It avoids an unbounded map grid search for Ascension and validates each stored target again before casting.

## Enhancement and tank contracts

| Spell | Behavior |
|---|---|
| 901098 Trifold Bulwark | Applying the passive applies custom neutral-family shields 901099 through 901101. Removing the passive removes all three. |
| 901099 Molten Aegis | Uses the Lightning Shield rank whose required level is closest without exceeding character level. It adopts that rank's stock charges and retaliation rank. Depleting the last charge restores the stock charge count while Trifold Bulwark remains active. |
| 901100 Tidebound Aegis | Uses the corresponding Water Shield rank, stock charge count, and stock triggered mana payload selected by character level. |
| 901101 Stonehide Aegis | Uses the corresponding Earth Shield rank, stock charge count, and base heal amount selected by character level. The heal retains the stock 3.5 second internal cooldown. |
| 901102 Earthen Defiance | Melee damage has a 25 percent chance, with a one-second internal cooldown, to add one ten-second stack of helper 901103. Each of five stacks gives 4 percent armor and 4 percent all-damage reduction. |

The three Aegis spells have generic family metadata so AzerothCore does not classify them as mutually exclusive elemental shields. Stock rank rows are not copied. Runtime selection reads stock rank chains and payloads directly.

## Restoration contracts

| Spell | Behavior |
|---|---|
| 901104 Riptide Resonance | Each Riptide periodic heal has a 20 percent chance to copy its exact rank to the lowest-health injured ally within 10 yards that lacks that caster's Riptide. |
| 901105 Overflowing Tides | All direct or periodic healing attributed to the shaman, including owned totems, converts 50 percent of overhealing into all-school absorb 901106. The ten-second shield accumulates and refreshes up to 10 percent of the recipient's maximum health. Internal helper healing is excluded. |
| 901107 Tidal Echo | After Chain Heal completes, helper 901108 heals the lowest-health injured ally within 15 yards of the primary target that was not hit by the cast. The helper amount is 50 percent of the primary target's raw heal, including overhealing. |
| 901109 Deep Currents | Healing attributed to the shaman on a target in the below-35-percent aura state grants helper 901110 for eight seconds. It gives 10 percent spell haste and 10 percent mana-cost reduction and has a 20 second internal cooldown. Internal helper healing is excluded. |
| 901111 Spirit Link Conduit | Because WotLK 3.3.5a has no Spirit Link Totem, any non-triggered Shaman totem cast heals the caster for 5 percent maximum health through helper 901108. The effect has a 30 second internal cooldown. |

## Shared cooldown contracts

| Spell | Behavior |
|---|---|
| 901112 Earthen Call | Native flat spell modifier reduces Earth Elemental Totem cooldown by 300000 milliseconds. |
| 901113 Alpha's Call | Native flat spell modifier reduces Feral Spirit cooldown by 45000 milliseconds. |
| 901114 Tidal Call | Native flat spell modifier reduces Mana Tide Totem cooldown by 120000 milliseconds. |
| 901115 Stoneguard Bulwark | Three-minute active. For ten seconds it removes current snares, grants snare immunity, reduces all damage by 30 percent, and retaliates against melee attackers using level-selected Lightning Shield damage. |
| 901116 Storm Unleashed | Three-minute active. Its aura is extended to twelve seconds by script. Direct damage, direct healing, and melee events trigger non-critical, zero-coefficient Nature helper 901117 for 20 percent of the source amount, limited by a 500 millisecond caster cooldown. Healing selects the nearest valid enemy within 10 yards of the healed unit. |

## Hook overlap and recursion

- The additional Flame Shock aura loader coexists with stock `spell_sha_flame_shock` Lava Flows handling.
- The additional Chain Heal loader coexists with stock Chain Heal and captures the post-modifier primary raw heal.
- Ascension marker 901095 prevents triggered Lava Bursts from starting spread or echo fan-out.
- Echoing Magma and Storm Unleashed helpers are outside stock rank chains, cannot critically strike, have no coefficient rows, and are explicitly excluded from recursive paths.
- Overflowing Tides and Deep Currents exclude helper 901108 so Tidal Echo and Conduit healing cannot recurse.
- Humans and bots use identical server mechanics. Passives require no AI action. Ascension, Stoneguard Bulwark, and Storm Unleashed require future playerbot cast-decision support.

## Data and deployment

The world update guards all IDs against `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`, derives family masks from stock backend rows, installs proc metadata and script bindings, removes coefficients from fixed helpers, marks transient helpers non-save, and adds backend names. It deliberately inserts no `mod_spec_spells` rows.

Deployment still requires:

1. Authorized live collision checks for 901091 through 901117.
2. World updater execution and startup log review.
3. Matching client `Spell.dbc` export and patch deployment for all 27 rows.
4. Acquisition through the separately owned future system.
5. Human and bot runtime scenarios for rank selection, spread ordering, cross-map registry cleanup, proc recursion, cooldowns, shields, absorbs, and active cast policy.

## Verification status

| Layer | Status |
|---|---|
| Static source and SQL review | Passed for ID coverage, bindings, acquisition exclusion, documentation ranges, patch whitespace, and deployment-core `CastCustomSpell` overload compatibility |
| Custom-core build | Initial deployment build exposed and informed the Overflowing Tides overload fix; rebuild not run locally |
| Database update and startup | Not run |
| Client export | Not run |
| Human gameplay | Not run |
| Playerbot gameplay | Not run |

## Change history

| Date | Change | Code or history reference |
|---|---|---|
| 2026-09-24 | Initial source and SQL implementation | [`../history/2026-09-24-shaman-spell-pack.md`](../history/2026-09-24-shaman-spell-pack.md) |
| 2026-09-24 | Deployment-core compilation compatibility fix | [`../history/2026-09-24-shaman-priest-compilation-fix.md`](../history/2026-09-24-shaman-priest-compilation-fix.md) |

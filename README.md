# apocalipse-wow-module

AzerothCore WotLK 3.3.5a gameplay module for the Apocalipse WoW private-server infrastructure. It is deployed with `mod-playerbots` and the custom playerbot AzerothCore branch.

The module provides forty-eight systems:

1. Specialization signature spell management
2. Level-based spell scaling
3. PvP damage balancing
4. Blazing Barrier custom mage spell
5. Pyroclastic Chain Reaction custom mage passive
6. Missile Barrage Overload custom mage passive
7. Hypernova custom mage spell
8. Prismatic Barrier custom mage spell
9. Frost Bomb custom mage spell
10. Automatic Ice Lance custom mage passive
11. Frozen Retaliation custom mage passive
12. Ambush Trapper custom hunter passive
13. Primal Resolve custom hunter defensive
14. Apex Bond custom hunter spell
15. Blood of the Hunt custom hunter passive
16. Melee Specialization custom hunter passive
17. Rupture custom blood death knight passive
18. Crimson Ward custom death knight passive
19. Frozen Resolve custom death knight passive
20. Rime Shards custom frost death knight passive
21. Necrotic Veil custom unholy death knight passive
22. Pestilent Eruption custom unholy death knight passive
23. Divine Storm Echo custom paladin passive
24. Permanent Seal of Righteousness and Vengeance custom paladin passives
25. Divine Steed custom paladin sprint
26. Paladin Vengeance variant passives
27. Extended Arsenal custom paladin passive
28. Divine Toll custom paladin spell
29. Burning Conflagration custom warlock passive
30. Chaotic Inferno custom warlock passive
31. Demonic Equilibrium custom warlock passive
32. Unquenchable Flames custom warlock passive
33. Unyielding Shadows custom warlock passive
34. Haunting Affliction custom warlock passive
35. Permanent Metamorphosis custom warlock passive
36. Baseline rogue shield proficiency and blocking
37. Leeching Mixture custom rogue defensive passive
38. Alchemical Guard custom combat rogue defensive
39. Bladeguard custom combat rogue shield passive
40. Pestilent Knives custom assassination rogue active
41. Daring Challenge custom combat rogue taunt
42. Buckler Strike custom combat rogue shield attack
43. Gloomblade Infusion custom subtlety rogue offensive passive
44. Shadow Execution custom rogue offensive passive
45. Crimson Vial custom rogue self-heal
46. Relentless Finale custom combat rogue meta passive
47. Improved Feint custom rogue defensive passive
48. Battleground stamina assistance and equipment control

The module does not implement bot AI. Its AzerothCore hooks also receive bot-controlled `Player` objects, and selected rules use `WorldSession::IsBot()` for bot-specific behavior.

## Documentation first

Engineering context is maintained as part of every change:

- Agent rules and mandatory documentation workflow: [`AGENTS.md`](AGENTS.md)
- Documentation index: [`.docs/README.md`](.docs/README.md)
- Architecture and subsystem interactions: [`.docs/architecture/overview.md`](.docs/architecture/overview.md)
- Runtime and data flow: [`.docs/architecture/runtime-and-data-flow.md`](.docs/architecture/runtime-and-data-flow.md)
- Playerbot integration: [`.docs/integrations/playerbots.md`](.docs/integrations/playerbots.md)
- Build, SQL, config, and release operations: [`.docs/development/operations.md`](.docs/development/operations.md)
- Dated engineering history: [`.docs/history/README.md`](.docs/history/README.md)

Future features must update their owner documentation, this README when public behavior changes, and the dated history without requiring a separate request.

## Project structure

```text
apocalipse-wow-module/
|-- AGENTS.md
|-- CMakeLists.txt
|-- README.md
|-- conf/
|   `-- BattlegroundStamina.conf.dist
|-- data/
|   |-- mod_apocalipse.sql
|   |-- mod_spell_scaling.sql
|   |-- 2026_09_16_01_blazing_barrier.sql
|   `-- sql/db-world/
|       |-- 2026_09_16_00_battleground_stamina_spell.sql
|       |-- 2026_09_17_00_pyroclastic_chain_reaction.sql
|       |-- 2026_09_17_01_hypernova.sql
|       |-- 2026_09_17_01_missile_barrage_overload.sql
|       |-- 2026_09_17_02_prismatic_barrier.sql
|       |-- 2026_09_17_03_frost_bomb.sql
|       |-- 2026_09_17_04_automatic_ice_lance.sql
|       |-- 2026_09_17_05_frozen_retaliation.sql
|       |-- 2026_09_18_02_divine_storm_echo.sql
|       |-- 2026_09_18_03_permanent_seal_of_righteousness.sql
|       |-- 2026_09_18_04_divine_steed.sql
|       |-- 2026_09_18_04_paladin_vengeance_variants.sql
|       |-- 2026_09_18_05_extended_arsenal.sql
|       |-- 2026_09_20_04_burning_conflagration.sql
|       |-- 2026_09_20_05_chaotic_inferno.sql
|       |-- 2026_09_20_06_demonic_equilibrium.sql
|       |-- 2026_09_21_00_ambush_trapper.sql
|       |-- 2026_09_21_01_apex_bond.sql
|       |-- 2026_09_21_01_blood_of_the_hunt.sql
|       |-- 2026_09_21_02_melee_specialization.sql
|       `-- 2026_09_21_04_death_knight_rupture.sql
|-- src/
|   |-- mod_apocalipse_loader.cpp
|   |-- mod_apocalipse.cpp
|   |-- mod_spell_scaling.cpp
|   |-- mod_apocalipse_pvp.cpp
|   |-- mod_apocalipse_mage_spells.cpp
|   |-- mod_apocalipse_mage_pyroclastic_chain_reaction.cpp
|   |-- mod_apocalipse_mage_missile_barrage_overload.cpp
|   |-- mod_apocalipse_mage_hypernova.cpp
|   |-- mod_apocalipse_mage_prismatic_barrier.cpp
|   |-- mod_apocalipse_mage_frost_bomb.cpp
|   |-- mod_apocalipse_mage_automatic_ice_lance.cpp
|   |-- mod_apocalipse_mage_frozen_retaliation.cpp
|   |-- mod_apocalipse_hunter_ambush_trapper.cpp
|   |-- mod_apocalipse_hunter_apex_bond.cpp
|   |-- mod_apocalipse_hunter_blood_of_the_hunt.cpp
|   |-- mod_apocalipse_death_knight_rupture.cpp
|   |-- mod_apocalipse_paladin_divine_storm_echo.cpp
|   |-- mod_apocalipse_paladin_permanent_seal_of_righteousness.cpp
|   |-- mod_apocalipse_paladin_divine_steed.cpp
|   |-- mod_apocalipse_warlock_burning_conflagration.cpp
|   |-- mod_apocalipse_warlock_chaotic_inferno.cpp
|   |-- mod_apocalipse_warlock_demonic_equilibrium.cpp
|   `-- battleground_stamina/
`-- .docs/
    |-- architecture/
    |-- custom-spells/
    |-- development/
    |-- features/
    |-- history/
    |-- integrations/
    |-- subsystems/
    `-- templates/
```

`CMakeLists.txt` is intentionally minimal. The parent AzerothCore module build auto-collects source files under `src/`.

## Systems

### Spec Manager

Owner: `src/mod_apocalipse.cpp`

The system detects the dominant talent tree on player login and talent changes. It grants configured signature spells and managed talents, removes non-dominant layers, and persists the selected tree plus a six-point hidden talent budget in `acore_characters`.

Creature 900001 provides an explicit Spec Master gossip interface, but it is currently not part of normal gameplay. A later talent reconciliation can replace an NPC-selected tree based on actual talent points.

Bots receive the same grants and persistence. Spec success/reset chat messages are suppressed for bot sessions.

Detailed contract: [`.docs/mod_apocalipse.md`](.docs/mod_apocalipse.md)

### Spell Scaling

Owner: `src/mod_spell_scaling.cpp`

Selected player-cast spells below level 80 are scaled from `acore_world.mod_spell_scaling`:

```text
multiplier = min((casterLevel / 80.0) * scaleFactor, 1.0)
```

Supported hook families are direct damage, direct healing, periodic damage, and absorb/mana-shield auras. NPCs are not scaled; bot-controlled players are scaled like humans.

A factor below 1.0 makes the final low-level effect smaller. For example, factor 0.5 at level 40 produces 25 percent, not 75 percent.

Detailed contract: [`.docs/mod_spell_scaling.md`](.docs/mod_spell_scaling.md)

### PvP Damage Balancing

Owner: `src/mod_apocalipse_pvp.cpp`

Eligible player-versus-player damage receives two multiplicative layers:

1. A fixed reduction at every level, default 15 percent.
2. For victim levels 10 through 79, the shortfall between current melee crit chance reduction and the configured bracket target.

Player-owned pets and guardians qualify as player attackers. Human and bot-controlled players use the same rules.

Direct and periodic configured spells can pass through both Spell Scaling and PvP Balancing. Integer conversion at each hook means callback order can affect rounding.

Detailed contract: [`.docs/mod_apocalipse_pvp.md`](.docs/mod_apocalipse_pvp.md)

### Blazing Barrier

Owner: `src/mod_apocalipse_mage_spells.cpp`

Custom spell 901001 is a level-80 mage absorb with base absorb plus 80.68 percent fire spell-power contribution. Its scripts reject replacing a stronger matching barrier with a weaker cast and integrate Blazing Speed, Fiery Payback, and Incanter's Absorption behavior.

The server spell row is installed by manual migration `data/2026_09_16_01_blazing_barrier.sql`. The script binding and scaling seed also appear in the baseline SQL. A matching client `Spell.dbc` and patch are required.

Detailed contract: [`.docs/custom-spells/blazing-barrier.md`](.docs/custom-spells/blazing-barrier.md)

### Pyroclastic Chain Reaction

Owner: `src/mod_apocalipse_mage_pyroclastic_chain_reaction.cpp`

Custom passive spell 901003 gives Pyroblast hits a 20 percent chance to detonate and refresh the caster's Living Bomb on the target. The matching-rank explosion preserves its normal damage targets and spreads the source Living Bomb rank to up to two random surviving enemies hit by the explosion that do not already have that caster's Living Bomb. Propagated bombs deal 30 percent of normal periodic and explosion damage.

The automatic module world updates install the passive and bind all Pyroblast, Living Bomb aura, and Living Bomb explosion ranks. Talent acquisition is intentionally external and requires matching server and client talent data. Human and bot-controlled mages use identical combat behavior.

Detailed contract: [`.docs/custom-spells/pyroclastic-chain-reaction.md`](.docs/custom-spells/pyroclastic-chain-reaction.md)

### Missile Barrage Overload

Owner: `src/mod_apocalipse_mage_missile_barrage_overload.cpp`

Custom passive spell 901004 lets Missile Barrage accumulate up to 20 procs. The first proc retains normal behavior, every additional proc adds one missile to the next Arcane Missiles channel, and a successful cast consumes the complete accumulated proc. Multi-proc releases play the existing visual-only Arcane Explosion spell 35426 on the target.

The automatic module world update installs the passive and binds its behavior to spells 44401 and 901004. Acquisition is intentionally external. Human and bot-controlled mages use identical mechanics, although existing bot AI does not deliberately wait for more procs.

Detailed contract: [`.docs/custom-spells/missile-barrage-overload.md`](.docs/custom-spells/missile-barrage-overload.md)

### Hypernova

Owner: `src/mod_apocalipse_mage_hypernova.cpp`

Custom active spell 901005 detonates at an enemy target, deals Arcane area damage, applies destination knockback, and grants the caster four Arcane Blast stacks. Its automatic world update and matching client spell row are required, while acquisition remains external.

Detailed contract: [`.docs/custom-spells/hypernova.md`](.docs/custom-spells/hypernova.md)

### Prismatic Barrier

Owner: `src/mod_apocalipse_mage_prismatic_barrier.cpp`

Custom active spell 901006 costs 42 percent base mana and has a 45 second cooldown. It triggers Mana Shield rank 9, Ice Barrier rank 8, and custom Blazing Barrier together, preserving each child spell's existing scripts and absorb behavior. Its automatic world update and matching client spell row are required, while acquisition remains external.

Detailed contract: [`.docs/custom-spells/prismatic-barrier.md`](.docs/custom-spells/prismatic-barrier.md)

### Frost Bomb

Owner: `src/mod_apocalipse_mage_frost_bomb.cpp`

Custom active spell 901007 places a four-second Frost Bomb on one enemy with a 1.5 second cast and 16 second cooldown. Expiration, enemy dispel, or target death shows a Frost Nova explosion on the bombed enemy, triggers spell 901008 for 1380 base target-centered Frost area damage with a 0.8 coefficient, then spell 901009 slows each living damage victim according to the caster's Permafrost rank. Its automatic world updates and matching client spell rows are required, while acquisition remains external.

Detailed contract: [`.docs/custom-spells/frost-bomb.md`](.docs/custom-spells/frost-bomb.md)

### Automatic Ice Lance

Owner: `src/mod_apocalipse_mage_automatic_ice_lance.cpp`

Custom passive spell 901010 gives Mage-family Frost spell damage, including periodic and triggered damage, a 10 percent chance, with a one-second internal cooldown, to trigger existing Ice Lance 30455 on the damaged target. Ice Lance damage is excluded to prevent recursion. Each proc also grants an independently expiring 1 percent spell-haste contribution for 10 seconds through non-persistent aura 901011, capped at 20 percent. The automatic Ice Lance retains proc events so it consumes Fingers of Frost normally.

The automatic module world update installs both custom rows, proc metadata, script bindings, and temporary-aura cleanup metadata. Acquisition remains external, and matching client spell rows are required. Human and bot-controlled mages use identical mechanics.

Detailed contract: [`.docs/custom-spells/automatic-ice-lance.md`](.docs/custom-spells/automatic-ice-lance.md)

### Frozen Retaliation

Owner: `src/mod_apocalipse_mage_frozen_retaliation.cpp`

Custom passive ranks 901012 and 901013 give positive incoming combat damage a 1.5 percent or 3 percent chance to grant existing Fingers of Frost aura 44544. Both ranks belong to the same `spell_ranks` chain, and the core's normal Fingers of Frost indicator, four-charge refresh, and consumption behavior remain active.

The automatic module world update installs both custom rows, rank relationships, floating-point proc chances, rank-chain script binding, and backend names. Acquisition remains external, matching client spell rows with rank labels are required, and human and bot-controlled mages use identical mechanics.

Detailed contract: [`.docs/custom-spells/frozen-retaliation.md`](.docs/custom-spells/frozen-retaliation.md)

### Ambush Trapper

Owners: `src/mod_apocalipse_hunter_ambush_trapper.cpp`, `data/sql/db-world/2026_09_21_00_ambush_trapper.sql`

Custom passive 901038 grants Predator's Ambush 901039 whenever a Hunter trap activates. The 15-second buff has five native charges. Each landed Hunter melee special consumes one charge, deals Physical damage through helper 901040 equal to 2 percent of the lower of target and Hunter maximum health, and restores 5 percent maximum mana through helper 901041.

Ambush Strike receives linear lower-level DAMAGE scaling and then existing PvP reduction. Acquisition remains external and must reference only 901038. Matching client rows are required for all four spells, and humans and bots use identical mechanics.

Detailed contract: [`.docs/custom-spells/ambush-trapper.md`](.docs/custom-spells/ambush-trapper.md)

### Primal Resolve

Owners: `src/mod_apocalipse_hunter_primal_resolve.cpp`, `data/sql/db-world/2026_09_21_03_primal_resolve.sql`

Custom active spell 901042 removes current snare mechanics and reduces all damage taken by 15 percent for 6 seconds. It has a 30-second cooldown, does not remove roots or grant ongoing movement immunity, and leaves the Hunter attack-capable and targetable.

The reduction uses native all-school damage-taken handling, while the one-time cleanup uses the deployment core's snare-removal helper. Acquisition and playerbot cast policy remain external, and a matching client spell row is required.

Detailed contract: [`.docs/custom-spells/primal-resolve.md`](.docs/custom-spells/primal-resolve.md)

### Apex Bond

Owners: `src/mod_apocalipse_hunter_apex_bond.cpp`, `data/sql/db-world/2026_09_21_01_apex_bond.sql`

Custom active spell 901046 requires a living active pet. It instantly heals the Hunter and pet for 15 percent of each target's maximum health, then grants the pet 15 percent increased damage for 10 seconds. The spell has a 90-second cooldown.

Implicit pet targets provide the same generic pet-presence contract used by Mend Pet, while the script enforces the stricter active and alive pet checks used by Bestial Wrath. Acquisition and bot cast policy remain external, and a matching client spell row is required.

Detailed contract: [`.docs/custom-spells/apex-bond.md`](.docs/custom-spells/apex-bond.md)

### Blood of the Hunt

Owners: `src/mod_apocalipse_hunter_blood_of_the_hunt.cpp`, `data/sql/db-world/2026_09_21_01_blood_of_the_hunt.sql`

Custom passive 901044 heals the Hunter for 15 percent of positive damage dealt by Raptor Strike, Mongoose Bite, Wing Clip, or Counterattack. Hunter trap activations instead heal for 5 percent maximum health. Both branches cast direct-heal helper 901045 and share one two-second internal cooldown.

Blood Heal receives linear lower-level HEAL scaling. Acquisition remains external and must reference only 901044. Matching client rows are required for both spells, and humans and bots use identical mechanics.

Detailed contract: [`.docs/custom-spells/blood-of-the-hunt.md`](.docs/custom-spells/blood-of-the-hunt.md)

### Melee Specialization

Owner: `data/sql/db-world/2026_09_21_02_melee_specialization.sql`

Custom passive 901047 uses native Hunter family filters to let Raptor Strike, Mongoose Bite, and Counterattack satisfy any aura-state requirement. In the deployment DBC only Counterattack currently declares one; Raptor Strike and Mongoose Bite are already unrestricted by aura state. A second family mask adds Wing Clip and gives all four Hunter melee ability families a 30 percent `SPELLMOD_DAMAGE` increase.

The passive does not remove range, weapon, resource, cooldown, target, silence, disarm, or other cast checks. It requires no C++ script or loader registration. Acquisition remains external, matching client spell data is required, and humans and bots use identical mechanics.

Detailed contract: [`.docs/custom-spells/melee-specialization.md`](.docs/custom-spells/melee-specialization.md)

### Concentrated Venom

Owners: `src/mod_apocalipse_rogue_concentrated_venom.cpp`, `data/sql/db-world/2026_09_22_03_concentrated_venom.sql`

Custom Assassination Rogue passive 901061 gives each successful equipped weapon-poison application a 30 percent chance to apply one additional stack of the highest applicable Deadly Poison rank found on the Rogue's equipped weapons. Each target has an independent one-second throttle.

The extra cast uses the native Deadly Poison spell and its enchanted weapon, preserving normal stack duration, damage, and five-stack opposite-weapon poison behavior. Assassination Spec Manager acquisition is included, a matching client row is required, and humans and bots use identical mechanics.

Detailed contract: [`.docs/custom-spells/concentrated-venom.md`](.docs/custom-spells/concentrated-venom.md)

### Rupture

Owners: `src/mod_apocalipse_death_knight_rupture.cpp`, `data/sql/db-world/2026_09_21_04_death_knight_rupture.sql`

Custom Blood Death Knight passive 901048 makes successful melee auto-attacks and each Blood Strike, Heart Strike, or Death Strike target apply one stack of helper 901049. The physical bleed ticks every two seconds, refreshes its 15-second duration, and scales each stack with 0.5 percent melee attack power up to 200 stacks.

The helper uses native bleed and Death Knight damage paths, participates in `PERIODIC` level scaling and PvP balancing, and is granted through Blood Spec Manager acquisition. Matching client rows are required for both spells, and humans and bots use identical mechanics.

Detailed contract: [`.docs/custom-spells/death-knight-rupture.md`](.docs/custom-spells/death-knight-rupture.md)

### Crimson Ward

Owners: `src/mod_apocalipse_death_knight_crimson_ward.cpp`, `data/sql/db-world/2026_09_21_04_crimson_ward.sql`

Custom Blood Death Knight passive 901050 triggers from positive incoming combat damage and applies helper 901051, a non-dispellable all-school absorb equal to 20 percent of current maximum health. The shield lasts 15 seconds, and all qualifying damage sources share one 60-second internal cooldown.

The triggering hit resolves before the shield is applied. The world update assigns passive 901050 to Blood specialization index 0 through Spec Manager; helper 901051 is never learned directly. Matching client rows are required for both spells, and humans and bots use identical mechanics.

Detailed contract: [`.docs/custom-spells/crimson-ward.md`](.docs/custom-spells/crimson-ward.md)

### Frozen Resolve

Owners: `src/mod_apocalipse_death_knight_frozen_resolve.cpp`, `data/sql/db-world/2026_09_21_05_frozen_resolve.sql`

Custom Death Knight passive 901052 checks combat state every 2 seconds and applies timed stack aura 901053 while in combat. Each 8-second stack increases armor by 2 percent and reduces all damage taken by 2 percent, up to 10 stacks. Continued combat refreshes the shared duration at the cap.

The stack aura expires within 8 seconds after qualifying combat ticks stop. Acquisition remains external and must reference only 901052. Matching client rows are required for both spells, and humans and bots use identical mechanics.

Detailed contract: [`.docs/custom-spells/frozen-resolve.md`](.docs/custom-spells/frozen-resolve.md)

### Rime Shards

Owners: `src/mod_apocalipse_death_knight_rime_shards.cpp`, `data/sql/db-world/2026_09_21_06_death_knight_rime_shards.sql`

Custom Frost Death Knight passive 901054 gives each positive Frost Strike or Howling Blast damage event a 30 percent chance to trigger helper 901055 at that target. The helper starts from 20 percent of the triggering damage, hits up to 10 enemies within 10 yards, and uses a diminishing curve that gives two targets 75 percent each and caps ten-target aggregate output at 190 percent of the helper amount.

The burst reuses the Howling Blast visual, has no separate level-scaling row because its amount derives from source damage, and follows normal Frost and PvP damage resolution. Frost Spec Manager acquisition is included, matching client rows are required for both spells, and humans and bots use identical mechanics.

Detailed contract: [`.docs/custom-spells/rime-shards.md`](.docs/custom-spells/rime-shards.md)

### Necrotic Veil

Owners: `src/mod_apocalipse_death_knight_necrotic_veil.cpp`, `data/sql/db-world/2026_09_21_07_death_knight_necrotic_veil.sql`

Custom Unholy Death Knight passive 901056 converts 10 percent of every positive post-mitigation damage event dealt directly by its owner into helper 901057. The helper accumulates remaining absorb up to 35 percent of current maximum health, refreshes to 60 seconds after each positive contribution, and absorbs magic schools while excluding Physical damage.

Pet, guardian, self, zero-damage, and non-damage events do not contribute. The world update assigns passive 901056 to Unholy specialization index 2 through Spec Manager; helper 901057 is never learned directly. Matching client rows are required for both spells, and humans and bots use identical mechanics.

Detailed contract: [`.docs/custom-spells/necrotic-veil.md`](.docs/custom-spells/necrotic-veil.md)

### Pestilent Eruption

Owners: `src/mod_apocalipse_death_knight_pestilent_eruption.cpp`, `data/sql/db-world/2026_09_21_07_death_knight_pestilent_eruption.sql`

Custom Unholy Death Knight passive 901058 makes every successful hostile Death Coil or Scourge Strike rank hit trigger internal Pestilence carrier 901059 on that target at no cost. The carrier uses Death Coil's 30-yard range, while source rank hooks exclude Death Coil healing and internal damage helpers so each eligible parent hit produces exactly one cast.

Carrier 901059 reuses the complete core `spell_dk_pestilence` script, including owned Blood Plague and Frost Fever spread plus Glyph of Disease primary-target refresh behavior. Unholy Spec Manager acquisition is included, matching client rows are required for both IDs, and humans and bots use identical mechanics.

Detailed contract: [`.docs/custom-spells/pestilent-eruption.md`](.docs/custom-spells/pestilent-eruption.md)

### Divine Storm Echo

Owner: `src/mod_apocalipse_paladin_divine_storm_echo.cpp`

Custom passive 901014 makes completed Divine Storm 53385 casts schedule triggered echo 901015 one second later. The echo selects up to 12 enemies around the paladin's current position, deals normalized 55 percent weapon damage, resolves independent hits and critical strikes, retains normal proc eligibility, and reuses core Divine Storm healing proportional to final damage.

The automatic module world update installs both custom rows and exact script bindings. Passive acquisition remains external, echo 901015 must never be learned directly, and matching client rows are required. Human and bot-controlled paladins use identical mechanics.

Detailed contract: [`.docs/custom-spells/divine-storm-echo.md`](.docs/custom-spells/divine-storm-echo.md)

### Permanent Paladin Seals

Owner: `src/mod_apocalipse_paladin_permanent_seal_of_righteousness.cpp`

Custom passive 901016 adds stock Seal of Righteousness damage to eligible melee attacks and judgements. Custom passive 901060 adds the stock Seal of Vengeance melee path, including Holy Vengeance 31803 stacks and stack-scaled weapon damage 42463. Seal of Corruption is intentionally outside this 3.3.5a feature contract.

Both passives have zero seal family masks, so they do not enter real seal exclusivity or judgement selection. A matching active seal does not suppress its permanent counterpart: both paths proc for an intentionally additive result. Acquisition for the Holy and Protection options remains external, Divine Toll remains a Retribution option, matching visible client rows are required, and humans and bots use identical mechanics.

Detailed contract: [`.docs/custom-spells/permanent-seal-of-righteousness.md`](.docs/custom-spells/permanent-seal-of-righteousness.md)

### Divine Steed

Owner: `src/mod_apocalipse_paladin_divine_steed.cpp`

Custom active spell 901017 doubles run speed for up to four seconds on a 20-second cooldown and shows Charger display 14584 for Alliance players or Thalassian Charger display 19085 for Horde players. It changes only `UNIT_FIELD_MOUNTDISPLAYID`, never applies mounted state, and removes the aura, speed bonus, and cosmetic display after the player's next successful non-triggered spell cast.

The AuraScript clears only its own display while the player is not mechanically mounted, and the player hook removes the effect after another successful non-triggered spell, on logout, and on map changes. Automatic module world updates install the spell, binding, non-save attribute, and current descriptions. Acquisition is external, a matching client spell row is required, and humans and bots use identical mechanics.

Detailed contract: [`.docs/custom-spells/divine-steed.md`](.docs/custom-spells/divine-steed.md)

### Paladin Vengeance Variants

Owner: `data/sql/db-world/2026_09_18_04_paladin_vengeance_variants.sql`

Guardian's Vengeance passive 901018 turns melee and damaging-spell critical hits into Guardian's Resolve 901019. Each of its three eight-second stacks reduces all damage taken by 1 percent and adds 10 flat defense rating.

Sacred Vengeance passive 901020 turns direct and periodic healing critical hits into Sacred Fervor 901021. Each of its three eight-second stacks increases healing done by 2 percent and adds 10 mana per 5 seconds. A critical source heal grants one stack; Beacon copies cannot crit and grant none.

Both graphs use native proc and aura handling without C++. Acquisition remains external, only the passive IDs may be granted, four matching client spell rows are required, and humans and bots use identical mechanics.

Detailed contract: [`.docs/custom-spells/paladin-vengeance-variants.md`](.docs/custom-spells/paladin-vengeance-variants.md)

### Extended Arsenal

Owner: `data/sql/db-world/2026_09_18_05_extended_arsenal.sql`

Extended Arsenal ranks 901022 and 901023 increase Hammer of the Righteous and Avenger's Shield maximum range by 3 or 6 yards and their chain target count by 1 or 2. The passive uses native flat spell modifiers and the exact Paladin family masks from the deployment DBC.

No C++ script, proc metadata, or playerbot AI change is required. The automatic module world update installs both ranks and their rank relationship. Acquisition remains external, matching client spell rows are required, and humans and bots use identical mechanics.

Detailed contract: [`.docs/custom-spells/extended-arsenal.md`](.docs/custom-spells/extended-arsenal.md)

### Divine Toll

Owners: `src/mod_apocalipse_paladin_divine_toll.cpp`, `data/sql/db-world/2026_09_18_05_divine_toll.sql`, `data/sql/db-world/2026_09_22_00_spell_balance_adjustments.sql`

Custom active spell 901024 costs 10 percent base mana, uses the global cooldown, and has a 60-second cooldown. It executes exactly five impacts against the selected hostile target, beginning immediately and continuing every 500 ms. Invalid targets are replaced by the nearest valid enemy within normal Judgement range.

Each impact applies Judgement of Justice and executes the currently active real seal's stock Judgement behavior at 80 percent damage, a 20 percent reduction, with independent critical strikes and normal downstream PvP and proc handling. Judgements of the Wise is limited to once per sequence, while Judgements of the Just, Heart of the Crusader, Righteous Vengeance, and generic procs retain their approved per-impact behavior. Seal of Command's Judgements of the Just cleave is explicitly cast on every successful impact. Passive 901016 fires independently beside real Seal of Righteousness, and the bounded Divine Toll marker reduces every resulting hit.

Acquisition and client patch generation remain external. The acquisition owner must reference 901024 only for Retribution. Humans and bots use identical mechanics.

Detailed contract: [`.docs/custom-spells/divine-toll.md`](.docs/custom-spells/divine-toll.md)

### Burning Conflagration

Owners: `src/mod_apocalipse_warlock_burning_conflagration.cpp`, `data/sql/db-world/2026_09_20_04_burning_conflagration.sql`

Custom passive 901027 makes a successful Conflagrate hit capture the caster's exact Immolate rank before normal consumption, then apply that full Immolate to up to three random eligible enemies within 10 yards of the primary target. Targets already carrying that caster's Immolate are excluded, while another Warlock's Immolate does not block propagation.

The automatic module update defines the passive and binds every Conflagrate rank through `-17962`. Talent acquisition and matching client data remain external. Humans and bots use identical mechanics, and existing Destruction actions need no AI changes.

Detailed contract: [`.docs/custom-spells/burning-conflagration.md`](.docs/custom-spells/burning-conflagration.md)

### Chaotic Inferno

Owners: `src/mod_apocalipse_warlock_chaotic_inferno.cpp`, `data/sql/db-world/2026_09_20_05_chaotic_inferno.sql`

Custom passive 901031 makes every successful Chaos Bolt impact cast helper 901032 at the target's position. The helper reproduces stock Inferno meteor damage and area stun, then creates an independent 20-second Infernal that follows and assists the Warlock.

The guardian uses module creature 900002, cloned from stock Infernal 89, with stock model, Immolation, level data, and owner scaling. Its ally-category guardian properties let it coexist with the normal demon without a pet bar or player commands. There is no explicit active-count cap, but the 20-second lifetime and Chaos Bolt cooldown naturally bound ordinary overlap.

Acquisition remains external and must reference only 901031. Matching client rows are required for 901031 and implementation-only helper 901032. Humans and bots use identical behavior.

Detailed contract: [`.docs/custom-spells/chaotic-inferno.md`](.docs/custom-spells/chaotic-inferno.md)

### Haunting Affliction

Owners: `src/mod_apocalipse_warlock_haunting_affliction.cpp`, `data/sql/db-world/2026_09_20_02_haunting_affliction.sql`, `data/sql/db-world/2026_09_22_00_spell_balance_adjustments.sql`

Custom passive 901028 causes every successful Haunt hit to apply the Warlock's highest learned Curse of Agony, Corruption, and Unstable Affliction ranks. There is no internal cooldown. Legacy marker 901029 remains in the original data graph but is no longer cast or checked.

A different curse owned by the same Warlock suppresses only Curse of Agony. Same-caster Seed of Corruption suppresses only Corruption. Existing eligible DoTs refresh normally, Unstable Affliction retains its stock dispel behavior, and humans and bots use identical mechanics.

Acquisition remains external and must reference only passive 901028. Matching client rows are required for 901028 and implementation-only marker 901029.

Detailed contract: [`.docs/custom-spells/haunting-affliction.md`](.docs/custom-spells/haunting-affliction.md)

### Permanent Metamorphosis

Owners: `src/mod_apocalipse_warlock_permanent_metamorphosis.cpp`, `data/sql/db-world/2026_09_20_03_permanent_metamorphosis.sql`

Demonology passive 901030 preserves normal Metamorphosis activation spell 59672 and its cooldown, but gives transformation aura 47241 infinite duration. Death retains stock cleanup, while passive removal, talent reset, login recovery after an interrupted shutdown, logout, or a mount attempt removes the transformation and its linked effects. Dismounting does not restore it.

The Demonology Spec Manager profile grants passive 901030 alongside active spell 59672. Humans and bots use identical mechanics, and existing playerbot activation and aura checks remain valid. A matching client spell row is required.

Detailed contract: [`.docs/custom-spells/permanent-metamorphosis.md`](.docs/custom-spells/permanent-metamorphosis.md)

### Demonic Equilibrium

Owners: `src/mod_apocalipse_warlock_demonic_equilibrium.cpp`, `data/sql/db-world/2026_09_20_06_demonic_equilibrium.sql`, `data/sql/db-world/2026_09_22_00_spell_balance_adjustments.sql`

Custom passive 901033 raises stock Soul Link's damage transfer from 20 percent to 50 percent while both auras are active. The per-hit split hook preserves stock Soul Link activation, demon eligibility, combat logs, proc handling, and its behavior when the passive is absent.

The automatic module update defines the passive and binds its script to stock Soul Link aura 25228. Talent acquisition and matching client data remain external. Humans and bots use identical mechanics, and existing Soul Link actions need no AI changes.

Detailed contract: [`.docs/custom-spells/demonic-equilibrium.md`](.docs/custom-spells/demonic-equilibrium.md)

### Unquenchable Flames

Owner: `data/sql/db-world/2026_09_20_07_unquenchable_flames.sql`

Custom passive 901034 gives the Warlock's Immolate and Shadowflame effects 100 percent dispel resistance through native caster spell-modifier handling. Existing caster-owned effects react immediately when the passive is learned or removed, while expiration, Conflagrate consumption, death cleanup, immunity cleanup, and scripted removal remain unchanged.

The automatic module update defines the complete data-only passive and backend client-export source. Talent acquisition and matching client data remain external. Humans and bots use identical mechanics, and no C++ registration or AI change is required.

Detailed contract: [`.docs/custom-spells/unquenchable-flames.md`](.docs/custom-spells/unquenchable-flames.md)

### Unyielding Shadows

Owner: `data/sql/db-world/2026_09_20_08_unyielding_shadows.sql`

Custom passive 901035 gives matching Warlock curses and Shadow debuffs 100 percent dispel resistance through native caster and owner spell-modifier handling. Its combined family mask covers Corruption, Fear, Howl of Terror, Death Coil, Banish, drains, Seed of Corruption, Shadowfury, Haunt, Shadow Embrace and Seduction while deliberately excluding Unstable Affliction.

The automatic module update defines the complete data-only passive and backend client-export source. Talent acquisition and matching client data remain external. Humans and bots use identical mechanics, and no C++ registration or AI change is required.

Detailed contract: [`.docs/custom-spells/unyielding-shadows.md`](.docs/custom-spells/unyielding-shadows.md)

### Rogue Shield Proficiency

Owner: `data/sql/db-world/2026_09_22_02_rogue_shield_proficiency.sql`

Rogues receive stock Shield skill 433 through AzerothCore's default-skill loading path before inventory validation. The migration adds a separate rogue-only eligibility override and default-skill row without changing the stock warrior, paladin, and shaman records. Stock Shield Proficiency and Block rewards are expected to provide equipment eligibility and normal block calculations for humans and bots.

Client skill UI, LFG shield eligibility, and playerbot shield-selection policy remain follow-up concerns. No custom spell or module C++ hook is introduced.

Detailed contract: [`.docs/features/rogue-shield-proficiency.md`](.docs/features/rogue-shield-proficiency.md)

### Leeching Mixture

Owners: `src/mod_apocalipse_rogue_leeching_mixture.cpp`, `data/sql/db-world/2026_09_22_03_rogue_leeching_mixture.sql`

Custom passive 901075 heals its Rogue owner for 8 percent of directly attributed Rogue poison damage. Aura-local accounting caps raw generated healing at 2 percent of current maximum health per one-second window. Reflected, self, pet, guardian, environmental, and other-Rogue damage are excluded. Helper 901076 remains non-critical and passes through normal healing reduction, dampening, absorption, and overheal handling.

Acquisition remains external. Matching server and client spell rows, the world update, and a module rebuild must ship together. Humans and playerbots use identical mechanics.

Detailed contract: [`.docs/custom-spells/leeching-mixture.md`](.docs/custom-spells/leeching-mixture.md)

### Gloomblade Infusion

Owners: `src/mod_apocalipse_rogue_gloomblade_infusion.cpp`, `data/sql/db-world/2026_09_22_07_gloomblade_infusion.sql`

Custom Subtlety Rogue passive 901079 observes positive damage dealt directly by its owner, including auto attacks, direct abilities, periodic effects, and poisons. It triggers non-critical helper 901080 with base Shadow damage equal to 10 percent of the final source event. Pet, guardian, reflected, self, zero, and recursive helper damage are excluded.

Subtlety Spec Manager acquisition is included. Matching server and client spell rows, the world update, and a module rebuild must ship together. Humans and playerbots use identical mechanics.

Detailed contract: [`.docs/custom-spells/gloomblade-infusion.md`](.docs/custom-spells/gloomblade-infusion.md)

### Shadow Execution

Owners: `src/mod_apocalipse_rogue_shadow_execution.cpp`, `data/sql/db-world/2026_09_22_08_shadow_execution.sql`

Custom Rogue passive 901081 makes direct damaging Rogue-family abilities apply one stack of Shadow Execution Damage 901082 to each damaged target. The non-critical Shadow periodic effect lasts 10 seconds, ticks every second, refreshes on application, and stacks to 50. Each stack deals 1 percent of the Rogue's attack-power-modified main-hand weapon damage.

The existing external talent-tree flow must grant single-rank passive 901081 only; helper 901082 is internal. Auto attacks and existing periodic ticks do not add stacks. Matching server and client spell rows, the world update, talent grant, and a module rebuild must ship together. Humans and playerbots use identical mechanics.

Detailed contract: [`.docs/custom-spells/shadow-execution.md`](.docs/custom-spells/shadow-execution.md)

### Crimson Vial

Owner: `data/sql/db-world/2026_09_22_09_crimson_vial.sql`

Custom Rogue active 901083 costs 20 Energy and heals the caster for 5 percent current maximum health immediately and once per second for 6 seconds. The seven non-critical healing events total a nominal 35 percent, recalculate maximum health for every tick, preserve stealth, and use normal healing reductions, dampening, absorption, and overheal handling.

Acquisition and playerbot cast policy remain external. Matching server and client spell rows and the automatic world update must ship together. No module C++ script or rebuild is required by this data-only spell alone.

Detailed contract: [`.docs/custom-spells/crimson-vial.md`](.docs/custom-spells/crimson-vial.md)

### Relentless Finale

Owners: `src/mod_apocalipse_rogue_relentless_finale.cpp`, `data/sql/db-world/2026_09_22_10_relentless_finale.sql`

Custom Combat Rogue passive 901084 makes every player-initiated five-combo-point Rogue finisher restore 5 percent maximum health. It also maintains a visible infinite ready buff that makes the next qualifying finisher retain all five points. Ready then returns exactly 12 seconds after that retention, enabling a predictable double-finisher sequence. Triggered and copied finishers cannot activate the effect.

Acquisition remains external and must grant only passive 901084. Matching server and client rows for 901084 through 901088, the world update, and a module rebuild must ship together. Humans and playerbots use identical mechanics, while deliberate double-finisher planning remains AI policy.

Detailed contract: [`.docs/custom-spells/relentless-finale.md`](.docs/custom-spells/relentless-finale.md)

### Improved Feint

Owners: `src/mod_apocalipse_rogue_improved_feint.cpp`, `data/sql/db-world/2026_09_22_09_improved_feint.sql`

Custom Rogue passive 901089 makes every successful stock Feint rank cast apply or refresh six-second helper 901090. The helper reduces Physical, Holy, Fire, Nature, Frost, Shadow, and Arcane damage taken by 30 percent without changing stock Feint behavior.

Ordinary damage uses factor 0.70. Stock Feint's 40 percent AoE reduction remains separate, so AoE damage uses `0.60 * 0.70 = 0.42`, for 58 percent total reduction rather than 70 percent. Acquisition remains external and must grant only passive 901089. Matching server and client rows, the world update, and a module rebuild must ship together. Humans and playerbots use identical mechanics.

Detailed contract: [`.docs/custom-spells/improved-feint.md`](.docs/custom-spells/improved-feint.md)

### Pestilent Knives

Owners: `src/mod_apocalipse_rogue_pestilent_knives.cpp`, `data/sql/db-world/2026_09_22_03_rogue_pestilent_knives.sql`

Custom Assassination Rogue active 901069 costs 35 Energy on a 20-second cooldown and deals 50 percent weapon damage to up to ten enemies within 10 yards. Each enemy hit receives two applications of the Rogue's main-hand Deadly Poison rank.

The implementation reuses real poison casts and the stock full-stack script. Targets already at five stacks trigger the opposite weapon's poison only once per cast. Assassination Spec Manager acquisition is included, matching client data is required, and bot cast-decision policy remains external.

Detailed contract: [`.docs/custom-spells/pestilent-knives.md`](.docs/custom-spells/pestilent-knives.md)

### Battleground Stamina Assistance

Owners: `src/battleground_stamina/`, `conf/BattlegroundStamina.conf.dist`

Eligible level 10 through 79 characters in non-arena battlegrounds receive a configurable true-stamina grant based on part of the gap between unbuffed baseline health and a class/bracket threshold.

Human players cannot change most non-combat-swappable equipment while in the battleground. Bot sessions bypass the equipment lock so automatic gearing can continue. Both humans and bots receive the same assistance calculation, and allowed equipment changes recalculate the aura.

Custom aura 901002 is installed by the AzerothCore module world updater. The runtime validator requires a positive, infinite, non-cancellable, death-persistent, non-saved generic stamina aura. A matching client `Spell.dbc` and patch are required.

Known config drift: distributed 10-19 thresholds differ from compiled fallbacks. Ensure `conf/BattlegroundStamina.conf.dist` is loaded into the effective server config until this is synchronized.

Detailed contract: [`.docs/custom-spells/battleground-stamina-assistance.md`](.docs/custom-spells/battleground-stamina-assistance.md)

## Requirements

- The custom playerbot AzerothCore WotLK branch used by the deployed `mod-playerbots` version
- `mod-playerbots` enabled in the parent core deployment
- World and character database access through AzerothCore
- Effective module/worldserver configuration containing desired overrides
- Server and client custom-spell data for managed spells through 901090
- Matching talent data when a custom passive is granted through a talent

Stock AzerothCore compatibility has not been validated.

## Database setup

Agent development and review are offline-only and must assume MySQL is unavailable. Agents derive IDs and spell data only from module migrations, matching AzerothCore source and checked-in SQL, and finally read-only local DBC extraction when needed. Backend source may explain export mechanics but is not allocation evidence. Agents do not probe for MySQL or execute the commands in this section. Live collision checks and migration execution belong to an authorized deployment operator.

Manual baseline and migration files are outside the automatic updater path. Run them only against the named database while following the server's backup and migration procedure.

```sql
-- Switches between acore_world and acore_characters internally.
SOURCE data/mod_apocalipse.sql;

-- acore_world
SOURCE data/mod_spell_scaling.sql;

-- acore_world, while worldserver is stopped
SOURCE data/2026_09_16_01_blazing_barrier.sql;
```

Files under `data/sql/db-world/` are automatic module world updates. They run on worldserver startup only when world database updates and module update discovery are enabled. Do not also import them manually when the updater will apply them. The 901002 update is idempotent for its recognized spell row and may be executed manually, with worldserver stopped and a current backup, to repair an already-recorded deployment. The updates through 901090 install custom class spells, native modifiers, proc metadata, and script bindings.

Before the first custom-spell deployment, verify IDs 901001 through 901090 are free or match the guarded module-owned rows in live `spell_dbc`, `wotlk_spells_full`, `wotlk_spells`, and the actual selected client/server `Spell.dbc`.

See [`.docs/development/operations.md`](.docs/development/operations.md) for migration order, preflight queries, updater checks, client patch requirements, and rollback constraints.

## Configuration

### PvP keys

```ini
Apocalipse.PvPDamageReductionPct = 15.0
Apocalipse.PvPBracketResilience.1019 = 8.0
Apocalipse.PvPBracketResilience.2029 = 10.0
Apocalipse.PvPBracketResilience.3039 = 12.0
Apocalipse.PvPBracketResilience.4049 = 14.0
Apocalipse.PvPBracketResilience.5059 = 16.0
Apocalipse.PvPBracketResilience.6069 = 18.0
Apocalipse.PvPBracketResilience.7079 = 20.0
```

These values reload on config reload and default in code. Keep production percentages in a safe 0 through 100 range.

### Battleground stamina keys

`conf/BattlegroundStamina.conf.dist` contains the complete contract:

- `Apocalipse.BattlegroundStamina.Enable`
- `Apocalipse.BattlegroundStamina.LockGear`
- `Apocalipse.BattlegroundStamina.AuraSpellId`
- `Apocalipse.BattlegroundStamina.GapCoveragePct`
- `Apocalipse.BattlegroundStamina.MaxBonusStamina`
- 70 `Apocalipse.BattlegroundStamina.HealthThreshold.<bracket>.<class>` entries

Modern AzerothCore module CMake discovers `conf/*.conf.dist` without an `AC_ADD_CONFIG_FILE` call, copies it as a module config, and loads it through `sConfigMgr`. Confirm `BattlegroundStamina.conf` appears in the CMake module config list and deployed config directory for the target custom-core revision.

## Building

Place or link the repository under the custom core's `modules/` directory, preserving the name `apocalipse-wow-module` because the loader entry point depends on it.

Typical parent-core build:

```bash
cmake .. -DMODULES=static
cmake --build . --parallel
```

Use `-DMODULES=dynamic` only when supported by the deployment core. Build with both this module and `mod-playerbots` enabled.

## Verification status

No standalone test harness exists in this repository. During the 2026-09-16 documentation update, sources, SQL, configuration, and sibling playerbot documentation were reviewed. The following were not run:

- Full custom-core build
- Worldserver startup
- Live database migrations
- Client DBC export or patch build
- In-game human or bot scenarios

Feature pages contain focused runtime matrices for future validation.

## Safety note

`deploy.ps1` only stages all files, creates a generic commit, and pushes. It does not build, test, inspect the branch, or validate deployment. Do not use it as a production deployment workflow.

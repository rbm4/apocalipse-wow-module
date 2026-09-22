# Architecture overview

Status: Active

Last source review: 2026-09-17 on local `main`

## System context

`apocalipse-wow-module` is an AzerothCore gameplay module for the Apocalipse WoW WotLK 3.3.5a server. It is loaded inside `worldserver` and uses AzerothCore `WorldScript`, `PlayerScript`, `UnitScript`, `CreatureScript`, `AllBattlegroundScript`, `SpellScript`, and `AuraScript` extension points.

The deployment also runs `mod-playerbots` and its custom AzerothCore branch. This module does not create bots, own bot AI state, or register strategies, triggers, actions, or values. Bots enter these systems because they are `Player` instances with bot-backed `WorldSession` objects.

## Source map

| Path | Responsibility |
|---|---|
| `src/mod_apocalipse_loader.cpp` | Module entry point and registration order |
| `src/mod_apocalipse.cpp` | Talent-tree detection, signature spell grants, hidden talent budget, and Spec Master NPC |
| `src/mod_spell_scaling.cpp` | Data-driven level scaling for selected damage, healing, periodic, and absorb effects |
| `src/mod_apocalipse_pvp.cpp` | Fixed PvP reduction and level-bracket resilience floor |
| `src/mod_apocalipse_mage_spells.cpp` | Custom Blazing Barrier spell and talent interactions |
| `src/mod_apocalipse_mage_pyroclastic_chain_reaction.cpp` | Pyroblast and Living Bomb passive interaction for spell 901003 |
| `src/mod_apocalipse_mage_missile_barrage_overload.cpp` | Missile Barrage accumulation and Arcane Missiles extension for spell 901004 |
| `src/mod_apocalipse_mage_hypernova.cpp` | Target-centered Arcane burst, visual, and four-stack reward for spell 901005 |
| `src/mod_apocalipse_mage_prismatic_barrier.cpp` | Three-barrier orchestration for spell 901006 |
| `src/mod_apocalipse_mage_frost_bomb.cpp` | Frost Bomb removal, explosion, proc, and Permafrost slow behavior for spells 901007 through 901009 |
| `src/mod_apocalipse_mage_automatic_ice_lance.cpp` | Automatic Ice Lance proc filtering and independently expiring haste for spells 901010 and 901011 |
| `src/mod_apocalipse_mage_frozen_retaliation.cpp` | Incoming-damage proc and Fingers of Frost grant for ranks 901012 and 901013 |
| `src/mod_apocalipse_rogue_concentrated_venom.cpp` | Successful weapon-poison proc, real Deadly Poison application, and per-target throttle for spell 901061 |
| `src/mod_apocalipse_rogue_leeching_mixture.cpp` | Owner-attributed poison damage self-healing with a one-second maximum-health cap for spells 901075 and 901076 |
| `src/mod_apocalipse_rogue_gloomblade_infusion.cpp` | Owner-attributed outgoing damage converted into a separate Shadow hit for spells 901079 and 901080 |
| `src/mod_apocalipse_rogue_shadow_execution.cpp` | Rogue ability-applied stacking Shadow periodic weapon damage for spells 901081 and 901082 |
| `data/sql/db-world/2026_09_22_09_crimson_vial.sql` | Data-only Rogue current-maximum-health self-heal 901083 |
| `src/mod_apocalipse_rogue_relentless_finale.cpp` | Five-point Rogue finisher healing, transient combo retention, visible readiness, and post-use recharge for spells 901084 through 901088 |
| `src/mod_apocalipse_rogue_improved_feint.cpp` | Rank-wide Feint-triggered all-school damage reduction for spells 901089 and 901090 |
| `src/mod_apocalipse_hunter_ambush_trapper.cpp` | Trap activation and charged melee-special behavior for spells 901038 through 901041 |
| `src/mod_apocalipse_hunter_primal_resolve.cpp` | Active damage reduction and snare cleanup for spell 901042 |
| `src/mod_apocalipse_hunter_apex_bond.cpp` | Active-pet validation, percent healing, and pet damage buff for spell 901046 |
| `src/mod_apocalipse_hunter_blood_of_the_hunt.cpp` | Melee-special and trap self-healing for spells 901044 and 901045 |
| `data/sql/db-world/2026_09_21_02_melee_specialization.sql` | Data-only native aura-state bypass and damage modifier passive 901047 |
| `src/mod_apocalipse_rogue_alchemical_guard.cpp` | Active damage reduction and poison/disease cleanse and immunity for spell 901077 |
| `src/mod_apocalipse_death_knight_crimson_ward.cpp` | Incoming-damage maximum-health absorb for spells 901050 and 901051 |
| `src/mod_apocalipse_death_knight_rupture.cpp` | Blood Death Knight melee-hit stacking bleed for spells 901048 and 901049 |
| `src/mod_apocalipse_death_knight_frozen_resolve.cpp` | Combat-gated stacking armor and damage reduction for spells 901052 and 901053 |
| `src/mod_apocalipse_death_knight_necrotic_veil.cpp` | Damage-derived persistent magic absorb for spells 901056 and 901057 |
| `src/mod_apocalipse_death_knight_pestilent_eruption.cpp` | Passive-gated free Pestilence carrier for spells 901058 and 901059 |
| `src/mod_apocalipse_death_knight_rime_shards.cpp` | Damage-derived target-centered Frost burst for spells 901054 and 901055 |
| `src/mod_apocalipse_rogue_pestilent_knives.cpp` | Active bounded area weapon attack and main-hand Deadly Poison applications for spell 901069 |
| `src/mod_apocalipse_rogue_daring_challenge.cpp` | Native taunt composition and target-specific bonus threat for spells 901070 and 901071 |
| `src/mod_apocalipse_rogue_buckler_strike.cpp` | Shield-required Physical melee strike, combo point, bonus threat, and NPC-only interrupt for spell 901078 |
| `src/mod_apocalipse_paladin_divine_storm_echo.cpp` | Passive-gated delayed Divine Storm echo for spells 901014 and 901015 |
| `src/mod_apocalipse_paladin_permanent_seal_of_righteousness.cpp` | Permanent pseudo-SoR and pseudo-Vengeance proc behavior for passives 901016 and 901060 |
| `src/mod_apocalipse_paladin_divine_toll.cpp` | Five sequential 80-percent-damage Judgement impacts for spells 901024 through 901026 |
| `src/mod_apocalipse_paladin_divine_steed.cpp` | Display-only horse sprint and lifecycle cleanup for spell 901017 |
| `src/mod_apocalipse_warlock_burning_conflagration.cpp` | Conflagrate and Immolate spread interaction for spell 901027 |
| `src/mod_apocalipse_warlock_chaotic_inferno.cpp` | Chaos Bolt impact summons and autonomous Infernal behavior for spells 901031 and 901032 |
| `src/mod_apocalipse_warlock_demonic_equilibrium.cpp` | Passive-gated Soul Link damage transfer increase for spell 901033 |
| `data/sql/db-world/2026_09_20_07_unquenchable_flames.sql` | Data-only native Fire dispel resistance passive 901034 |
| `data/sql/db-world/2026_09_20_08_unyielding_shadows.sql` | Data-only native Shadow dispel resistance passive 901035 with Unstable Affliction excluded |
| `src/mod_apocalipse_warlock_haunting_affliction.cpp` | Passive-gated DoT applications on every Haunt hit for spell 901028 |
| `src/mod_apocalipse_warlock_permanent_metamorphosis.cpp` | Passive-gated infinite Metamorphosis duration and lifecycle cleanup for spell 901030 |
| `data/sql/db-world/2026_09_22_02_rogue_shield_proficiency.sql` | Server-side rogue Shield skill eligibility and default acquisition through stock proficiency and Block rewards |
| `data/sql/db-world/2026_09_22_04_bladeguard.sql` | Data-only shield-gated Rogue item-armor, block-chance, and block-Energy passive 901073 with helper 901074 |
| `src/battleground_stamina/` | Battleground stamina calculation, custom aura lifecycle, and equipment lock |
| `conf/` | Distributed module configuration |
| `data/mod_apocalipse.sql` | Manual Spec Manager schema, seed data, NPC, and Blazing Barrier script binding |
| `data/mod_spell_scaling.sql` | Manual spell-scaling schema and seed data |
| `data/2026_09_16_01_blazing_barrier.sql` | Manual server-side Blazing Barrier spell migration |
| `data/sql/db-world/` | AzerothCore module world-database updates, including managed spells through 901090 |
| `.docs/` | Persistent engineering and operational context |

## Registered subsystem order

`Addapocalipse_wow_moduleScripts()` registers systems in this order:

1. `AddModApocalipseScripts()`
2. `AddModSpellScalingScripts()`
3. `AddModApocalipsePvPScripts()`
4. `AddModApocalipseMageSpellScripts()`
5. `AddModApocalipseMagePyroclasticChainReactionScripts()`
6. `AddModApocalipseMageMissileBarrageOverloadScripts()`
7. `AddModApocalipseMageHypernovaScripts()`
8. `AddModApocalipseMagePrismaticBarrierScripts()`
9. `AddModApocalipseMageFrostBombScripts()`
10. `AddModApocalipseMageAutomaticIceLanceScripts()`
11. `AddModApocalipseMageFrozenRetaliationScripts()`
12. `AddModApocalipseRogueConcentratedVenomScripts()`
13. `AddModApocalipseRogueLeechingMixtureScripts()`
14. `AddModApocalipseRogueGloombladeInfusionScripts()`
15. `AddModApocalipseRogueShadowExecutionScripts()`
16. `AddModApocalipseRogueRelentlessFinaleScripts()`
17. `AddModApocalipseRogueImprovedFeintScripts()`
18. `AddModApocalipseRogueDaringChallengeScripts()`
19. `AddModApocalipseRogueBucklerStrikeScripts()`
20. `AddModApocalipseHunterAmbushTrapperScripts()`
21. `AddModApocalipseHunterApexBondScripts()`
22. `AddModApocalipseHunterBloodOfTheHuntScripts()`
23. `AddModApocalipseHunterPrimalResolveScripts()`
24. `AddModApocalipseRogueAlchemicalGuardScripts()`
25. `AddModApocalipseDeathKnightCrimsonWardScripts()`
26. `AddModApocalipseDeathKnightFrozenResolveScripts()`
27. `AddModApocalipseDeathKnightNecroticVeilScripts()`
28. `AddModApocalipseDeathKnightPestilentEruptionScripts()`
29. `AddModApocalipseDeathKnightRimeShardsScripts()`
30. `AddModApocalipseDeathKnightRuptureScripts()`
31. `AddModApocalipseRoguePestilentKnivesScripts()`
32. `AddModApocalipsePaladinDivineStormEchoScripts()`
33. `AddModApocalipsePaladinPermanentSealOfRighteousnessScripts()`
34. `AddModApocalipsePaladinDivineTollScripts()`
35. `AddModApocalipsePaladinDivineSteedScripts()`
36. `AddModApocalipseWarlockBurningConflagrationScripts()`
37. `AddModApocalipseWarlockChaoticInfernoScripts()`
38. `AddModApocalipseWarlockDemonicEquilibriumScripts()`
39. `AddModApocalipseWarlockHauntingAfflictionScripts()`
40. `AddModApocalipseWarlockPermanentMetamorphosisScripts()`
41. `AddModApocalipseBattlegroundStaminaScripts()`

The entry-point name is derived from the module directory `apocalipse-wow-module`, with hyphens converted to underscores. Renaming the directory requires changing the entry point.

## Subsystem boundaries

| Subsystem | Owns | Does not own |
|---|---|---|
| Spec Manager | Dominant tree detection, managed spells and talents, per-character grant state | General bot talent selection or AI |
| Spell Scaling | Final value scaling for spell IDs listed in `mod_spell_scaling` | Spell acquisition, PvP eligibility, or custom spell definitions |
| PvP Balancing | Damage reduction when a player or player-owned unit damages a player | Healing, absorb creation, battleground stamina, or arena matchmaking |
| Blazing Barrier | Spell 901001 amount, recast rule, and selected mage talent procs | Spell row installation, client DBC distribution, or level scaling |
| Pyroclastic Chain Reaction | Spell 901003 proc gate, Living Bomb refresh, triggered explosion, and bounded spread | Talent acquisition, custom client data, or changing normal Living Bomb expiration |
| Missile Barrage Overload | Spell 901004 gate, aura-local proc count, Arcane Missiles duration adjustment, aggregate consumption, and release visual | Talent acquisition, playerbot rotation policy, or client visual scaling |
| Hypernova | Spell 901005 target-centered damage, knockback, visual placement, and Arcane Blast stack reward | Acquisition, custom client assets, or playerbot rotation policy |
| Prismatic Barrier | Spell 901006 orchestration of three existing barrier spells | Acquisition, child aura mechanics, client assets, or playerbot rotation policy |
| Frost Bomb | Spells 901007 through 901009, removal filtering, target-centered explosion, proc path, and Permafrost slow | Acquisition, client assets, or playerbot rotation policy |
| Automatic Ice Lance | Spell 901010 proc filtering, triggered Ice Lance, and spell 901011 independent haste expirations | Acquisition, client assets, or playerbot rotation policy |
| Frozen Retaliation | Spells 901012 and 901013, incoming positive combat-damage proc, rank-specific chance, and Fingers of Frost grant | Acquisition, client assets, environmental damage, or playerbot rotation policy |
| Concentrated Venom | Assassination-managed passive 901061, successful equipped weapon-poison filtering, highest applicable Deadly Poison selection, and per-target throttle | Client patch generation, base poison proc rates, native Deadly Poison stacking, opposite-weapon poison selection, or playerbot action policy |
| Leeching Mixture | Passive 901075, direct-owner Rogue poison filtering, one-second 2 percent maximum-health allowance, and heal helper 901076 | Acquisition, client patch generation, poison metadata on custom damage, or playerbot action policy |
| Gloomblade Infusion | Subtlety-managed passive 901079, broad direct-owner damage filtering, 10 percent floor calculation, and Shadow helper 901080 | Client patch generation, source damage calculation, pet or guardian output, or playerbot action policy |
| Shadow Execution | Passive 901081, direct Rogue-family ability filtering, per-target application, and 50-stack periodic helper 901082 | External acquisition, client patch generation, unrelated Rogue damage, or playerbot action policy |
| Crimson Vial | Data-only active 901083, Energy cost, cooldown, stealth preservation, and seven native current-maximum-health healing events | Acquisition, client patch generation, or playerbot cast-decision policy |
| Relentless Finale | Passive 901084, visible readiness, qualifying five-point finisher bypass, percent heal, and post-use 12-second recharge | Acquisition, client patch generation, ordinary finisher formulas, or playerbot finisher sequencing policy |
| Improved Feint | Passive 901089, stock Feint rank-chain cast hook, and six-second all-school helper 901090 | Acquisition, client patch generation, stock Feint behavior, or playerbot Feint policy |
| Ambush Trapper | Passive 901038, trap activation filtering, five-charge buff 901039, capped damage 901040, and mana helper 901041 | Acquisition, client patch generation, trap placement policy, or playerbot rotation policy |
| Primal Resolve | Active 901042, exact self-cast snare cleanup, and native six-second all-damage reduction | Acquisition, client patch generation, root removal, ongoing immunity, or playerbot cast policy |
| Apex Bond | Active 901046, active and alive pet validation, native percent heals, and temporary pet damage aura | Acquisition, client patch generation, pet lifecycle ownership, or playerbot rotation policy |
| Blood of the Hunt | Passive 901044, Hunter melee-family and trap filtering, shared two-second cooldown, and direct-heal helper 901045 | Acquisition, client patch generation, melee or trap action policy, or playerbot rotation policy |
| Melee Specialization | Passive 901047, exact Hunter family masks, native family-filtered aura-state bypass, and 30 percent spell damage modifier including Wing Clip | Acquisition, client patch generation, unrelated cast restrictions, or playerbot action policy |
| Alchemical Guard | Active 901077, all-damage reduction, poison/disease cleanse and immunity, controlled casting, GCD, and stealth preservation | Acquisition, client patch generation, or playerbot cast policy |
| Crimson Ward | Blood-managed passive 901050, positive incoming-damage filtering, shared one-minute cooldown, and 20 percent maximum-health absorb helper 901051 | Client patch generation, environmental damage, or playerbot action policy |
| Death Knight Rupture | Blood passive 901048, exact melee and strike filtering, per-target applications, and stacking bleed helper 901049 | Client patch generation, playerbot action policy, or unrelated Death Knight attacks |
| Frozen Resolve | Passive 901052, combat-gated two-second cadence, native stack cap, timed aura 901053, armor, and all-damage reduction | Acquisition, client patch generation, Icebound Fortitude behavior, or playerbot action policy |
| Necrotic Veil | Unholy-managed passive 901056, direct-owner damage filtering, bounded absorb accumulation, duration refresh, and magic-only helper 901057 | Client patch generation, pet damage, source damage calculation, or playerbot action policy |
| Pestilent Eruption | Unholy-managed passive 901058, exact source-rank hit hooks, hostile target gate, and free long-range carrier 901059 | Client patch generation, core Pestilence script mechanics, or playerbot action policy |
| Rime Shards | Passive 901054, exact source filtering, damage snapshot, target count, diminishing curve, and helper 901055 | Client patch generation, source spell behavior, or playerbot action policy |
| Pestilent Knives | Active 901069, bounded area selection, main-hand Deadly Poison rank resolution, two applications, and per-target full-stack proc cap | Client patch generation, stock poison mechanics, opposite-weapon enchant ownership, or playerbot cast policy |
| Bladeguard | Shield-gated passive 901073, item-armor and block-chance modifiers, block-only proc cooldown, and Energy helper 901074 | Acquisition, Shield skill, Block capability, client patch generation, or playerbot shield-selection policy |
| Buckler Strike | Shield-gated active 901078, AP and shield-block-value damage, one combo point, final-damage threat, and non-player interrupt restriction | Acquisition, Shield skill, client patch generation, or playerbot shield-selection and cast policy |
| Divine Storm Echo | Passive 901014, echo 901015, delayed scheduling, execution guards, and recursion prevention | Acquisition, client assets, original Divine Storm behavior, or playerbot rotation policy |
| Permanent Paladin seals | Passives 901016 and 901060, stock SoR and Vengeance behavior, same-seal additive procs, filtering, and recursion prevention | Acquisition, client assets, real seal exclusivity, judgement selection, Divine Toll specialization assignment, or playerbot rotation policy |
| Divine Steed | Active 901017, faction display choice, run-speed aura, safe removal, and logout/map cleanup | Acquisition, client export, real mounted state, vehicles, or playerbot rotation policy |
| Paladin Vengeance variants | Passives 901018 and 901020, timed buffs 901019 and 901021, critical-event eligibility, stack caps, and effect amounts | Acquisition, client assets, specialization enforcement, or playerbot talent selection |
| Extended Arsenal | Passive ranks 901022 and 901023, native range and jump-target modifiers, and exact Paladin family masks | Acquisition, client assets, base spell target rules, or playerbot talent selection |
| Divine Toll | Active 901024, impact marker 901025, Justice visual 901026, delayed events, seal selection, damage provenance, and proc bounds | Acquisition, client patch generation, normal Judgement wrappers, or playerbot rotation policy |
| Burning Conflagration | Passive 901027, pre-consumption Immolate rank capture, bounded nearby selection, and full matching-rank propagation | Acquisition, client patch generation, base Conflagrate consumption, or playerbot rotation policy |
| Chaotic Inferno | Passive 901031, helper 901032, creature 900002, non-pet guardian ownership, stock Inferno impact, scaling, follow, assist, and duration | Acquisition, client patch generation, stock Inferno 1122, or playerbot rotation policy |
| Demonic Equilibrium | Passive 901033, stock Soul Link aura 25228 split override, and per-hit 50 percent calculation | Acquisition, client patch generation, Soul Link activation, demon eligibility, or playerbot rotation policy |
| Unquenchable Flames | Passive 901034, native 100 percent resist-dispel modifier, and exact Immolate and Shadowflame family masks | Acquisition, client patch generation, global stock-spell changes, or playerbot rotation policy |
| Unyielding Shadows | Passive 901035, native 100 percent resist-dispel modifier, and combined Warlock family mask excluding Unstable Affliction | Acquisition, client patch generation, global stock-spell changes, or playerbot rotation policy |
| Haunting Affliction | Passive 901028, every-Haunt hit hook, highest-known DoT ranks, and curse and Seed exclusions | Acquisition, base DoT mechanics, client patch generation, or playerbot rotation policy |
| Permanent Metamorphosis | Passive 901030, conditional aura 47241 duration, mount pre-check, and lifecycle cleanup | Stock activation spell 59672, cooldown, transformation effects, linked cleanup, or playerbot rotation policy |
| Battleground Stamina | Spell 901002 validation, unbuffed baseline, assistance aura, and human gear lock | Bot gearing decisions, matchmaking, or arenas |

## Dependency direction

```text
AzerothCore and custom playerbot core APIs
  -> module loader
     -> independent script registrations
        -> Player, Unit, Battleground, Spell, Aura, ConfigMgr
        -> WorldDatabase and CharacterDatabase

Spec Manager configured spell IDs
  -> normal spell casts
     -> Spell Scaling when the spell ID is configured
     -> PvP Balancing when attacker and victim satisfy PvP guards

Blazing Barrier AuraScript
  -> final absorb aura
     -> Spell Scaling ABSORB hook

Pyroblast with passive 901003
  -> same-caster Living Bomb refresh and matching-rank explosion
     -> up to two matching-rank Living Bomb applications

Missile Barrage with passive 901004
  -> aura-local proc count exposed as charges
     -> longer Arcane Missiles channel and aggregate consumption

Hypernova 901005
  -> target-centered Arcane damage and destination knockback
     -> Arcane Explosion visual and four Arcane Blast stacks

Prismatic Barrier 901006
  -> triggered Mana Shield, Ice Barrier, and Blazing Barrier casts
     -> existing child AuraScripts and absorb paths

Frost Bomb 901007
  -> four-second hostile aura and filtered removal detonation
     -> target-local Frost Nova visual 34326
     -> target-centered damage 901008 and Permafrost slow 901009

Automatic Ice Lance passive 901010
  -> eligible Mage-family Frost damage proc, including periodic and triggered damage
     -> triggered Ice Lance 30455 and one haste expiration in aura 901011

Frozen Retaliation ranks 901012 and 901013
  -> positive incoming combat damage at 1.5 or 3 percent
     -> existing Fingers of Frost aura 44544

Ambush Trapper passive 901038
  -> Hunter trap activation grants five-charge aura 901039
     -> melee specials trigger capped Physical damage 901040 and mana 901041

Primal Resolve active 901042
  -> remove current snare mechanics without removing roots
  -> reduce all damage taken by 15 percent for 6 seconds

Blood of the Hunt passive 901044
  -> eligible melee-special damage or Hunter trap activation
     -> direct self-heal 901045 and shared two-second proc cooldown

Melee Specialization passive 901047
  -> native family-filtered aura-state bypass covers Raptor Strike, Mongoose Bite, and Counterattack
     -> only Counterattack currently declares a caster aura state in the deployment DBC
  -> native family-filtered SPELLMOD_DAMAGE increases those abilities and Wing Clip by 30 percent

Crimson Ward passive 901050
  -> positive incoming combat damage starts one shared 60-second cooldown
     -> helper 901051 snapshots a 20 percent maximum-health absorb for 15 seconds

Divine Storm 53385 with passive 901014
  -> caster-owned one-second delayed event
     -> echo attack 901015 with normal procs and proportional healing

Permanent Seal of Righteousness passive 901016
  -> melee and judgement damage proc filtering
     -> stock SoR damage 25742 unless real SoR is active

Divine Steed 901017
  -> ordinary run-speed aura and faction-specific mount display
     -> aura, logout, and map cleanup without mechanical mounted state

Guardian's Vengeance 901018 or Sacred Vengeance 901020
  -> native critical-event proc filtering
     -> three-stack, eight-second buff 901019 or 901021

Extended Arsenal 901022 or 901023
  -> native flat range and jump-target spell modifiers
     -> Hammer of the Righteous and Avenger's Shield chain selection

Divine Toll 901024
  -> exactly five GUID-based impacts at 500 ms intervals
     -> marker 901025 scopes 80 percent damage, guaranteed hit, SoR overlap, and one JotW proc
     -> visual 901026 and current real-seal Judgement behavior

Conflagrate rank chain with passive 901027
  -> capture exact same-caster Immolate rank before core consumption
     -> apply full Immolate to up to three eligible enemies within 10 yards

Haunt rank chain with passive 901028
  -> every successful hit applies eligible highest-known Curse of Agony, Corruption, and Unstable Affliction ranks

Metamorphosis 59672 with passive 901030
  -> stock activation and cooldown
     -> infinite transformation aura 47241 until stock or explicit lifecycle cleanup

Battleground and player hooks
  -> Battleground Stamina
     -> bot session check only for equipment-lock exemption
```

Subsystems do not call each other's C++ functions. Their integration is event-driven through shared AzerothCore objects, hook dispatch, spell IDs, configuration, and database rows.

## Core invariants

1. Every subsystem must be registered from `Addapocalipse_wow_moduleScripts()`.
2. Bot-specific behavior must use the custom core's `WorldSession::IsBot()` contract rather than guessing from names, accounts, or AI pointers.
3. World data belongs in `WorldDatabase`; per-character state belongs in `CharacterDatabase`.
4. Spell IDs 901001 through 901090 are provisional deployment contracts and must be collision-checked in server and client data.
5. Server `spell_dbc` rows and client `Spell.dbc` rows must agree for custom spells.
6. Damage modifiers stack through shared mutable hook arguments. New modifiers must document hook overlap and rounding order.
7. Configuration defaults in code and distributed `.conf.dist` files must remain synchronized.
8. Runtime and database validation status must be recorded honestly.

## Current validation status

The repository contains no standalone unit-test or integration-test harness. This documentation was checked against local source, SQL, configuration, and the sibling `mod-playerbots` repository. No full custom-core build, worldserver startup, live database migration, client DBC export, or in-game scenario was run during the 2026-09-16 documentation review.
The repository contains no standalone unit-test or integration-test harness. This documentation was checked against local source, SQL, configuration, and the sibling `mod-playerbots` repository. No full custom-core build, worldserver startup, live database migration, client DBC export, or in-game scenario was run during the 2026-09-16 documentation review.
The repository contains no standalone unit-test or integration-test harness. This documentation was checked against local source, SQL, configuration, and the sibling `mod-playerbots` repository. No full custom-core build, worldserver startup, live database migration, client DBC export, or in-game scenario was run during the 2026-09-16 documentation review.

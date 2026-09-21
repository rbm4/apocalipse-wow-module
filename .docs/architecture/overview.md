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
| `src/mod_apocalipse_hunter_ambush_trapper.cpp` | Trap activation and charged melee-special behavior for spells 901038 through 901041 |
| `src/mod_apocalipse_hunter_primal_resolve.cpp` | Active damage reduction and snare cleanup for spell 901042 |
| `src/mod_apocalipse_hunter_apex_bond.cpp` | Active-pet validation, percent healing, and pet damage buff for spell 901046 |
| `src/mod_apocalipse_hunter_blood_of_the_hunt.cpp` | Melee-special and trap self-healing for spells 901044 and 901045 |
| `data/sql/db-world/2026_09_21_02_melee_specialization.sql` | Data-only native aura-state bypass and damage modifier passive 901047 |
| `src/mod_apocalipse_paladin_divine_storm_echo.cpp` | Passive-gated delayed Divine Storm echo for spells 901014 and 901015 |
| `src/mod_apocalipse_paladin_permanent_seal_of_righteousness.cpp` | Permanent pseudo-SoR proc behavior for passive 901016 |
| `src/mod_apocalipse_paladin_divine_toll.cpp` | Sequenced half-damage Judgement orchestration for spells 901024 through 901026 |
| `src/mod_apocalipse_paladin_divine_steed.cpp` | Display-only horse sprint and lifecycle cleanup for spell 901017 |
| `src/mod_apocalipse_warlock_burning_conflagration.cpp` | Conflagrate and Immolate spread interaction for spell 901027 |
| `src/mod_apocalipse_warlock_chaotic_inferno.cpp` | Chaos Bolt impact summons and autonomous Infernal behavior for spells 901031 and 901032 |
| `src/mod_apocalipse_warlock_demonic_equilibrium.cpp` | Passive-gated Soul Link damage transfer increase for spell 901033 |
| `data/sql/db-world/2026_09_20_07_unquenchable_flames.sql` | Data-only native Fire dispel resistance passive 901034 |
| `data/sql/db-world/2026_09_20_08_unyielding_shadows.sql` | Data-only native Shadow dispel resistance passive 901035 with Unstable Affliction excluded |
| `src/mod_apocalipse_warlock_haunting_affliction.cpp` | Passive-gated Haunt DoT applications and caster-global cooldown for spells 901028 and 901029 |
| `src/mod_apocalipse_warlock_permanent_metamorphosis.cpp` | Passive-gated infinite Metamorphosis duration and lifecycle cleanup for spell 901030 |
| `src/battleground_stamina/` | Battleground stamina calculation, custom aura lifecycle, and equipment lock |
| `conf/` | Distributed module configuration |
| `data/mod_apocalipse.sql` | Manual Spec Manager schema, seed data, NPC, and Blazing Barrier script binding |
| `data/mod_spell_scaling.sql` | Manual spell-scaling schema and seed data |
| `data/2026_09_16_01_blazing_barrier.sql` | Manual server-side Blazing Barrier spell migration |
| `data/sql/db-world/` | AzerothCore module world-database updates, including spells 901002 through 901047 |
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
12. `AddModApocalipseHunterAmbushTrapperScripts()`
13. `AddModApocalipseHunterApexBondScripts()`
14. `AddModApocalipseHunterBloodOfTheHuntScripts()`
15. `AddModApocalipseHunterPrimalResolveScripts()`
16. `AddModApocalipsePaladinDivineStormEchoScripts()`
17. `AddModApocalipsePaladinPermanentSealOfRighteousnessScripts()`
18. `AddModApocalipsePaladinDivineTollScripts()`
19. `AddModApocalipsePaladinDivineSteedScripts()`
20. `AddModApocalipseWarlockBurningConflagrationScripts()`
21. `AddModApocalipseWarlockChaoticInfernoScripts()`
22. `AddModApocalipseWarlockDemonicEquilibriumScripts()`
23. `AddModApocalipseWarlockHauntingAfflictionScripts()`
24. `AddModApocalipseWarlockPermanentMetamorphosisScripts()`
25. `AddModApocalipseBattlegroundStaminaScripts()`

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
| Ambush Trapper | Passive 901038, trap activation filtering, five-charge buff 901039, capped damage 901040, and mana helper 901041 | Acquisition, client patch generation, trap placement policy, or playerbot rotation policy |
| Primal Resolve | Active 901042, exact self-cast snare cleanup, and native six-second all-damage reduction | Acquisition, client patch generation, root removal, ongoing immunity, or playerbot cast policy |
| Apex Bond | Active 901046, active and alive pet validation, native percent heals, and temporary pet damage aura | Acquisition, client patch generation, pet lifecycle ownership, or playerbot rotation policy |
| Blood of the Hunt | Passive 901044, Hunter melee-family and trap filtering, shared two-second cooldown, and direct-heal helper 901045 | Acquisition, client patch generation, melee or trap action policy, or playerbot rotation policy |
| Melee Specialization | Passive 901047, exact Hunter family masks, native family-filtered aura-state bypass, and 30 percent spell damage modifier including Wing Clip | Acquisition, client patch generation, unrelated cast restrictions, or playerbot action policy |
| Divine Storm Echo | Passive 901014, echo 901015, delayed scheduling, execution guards, and recursion prevention | Acquisition, client assets, original Divine Storm behavior, or playerbot rotation policy |
| Permanent Seal of Righteousness | Passive 901016, stock SoR calculation, proc filtering, real-SoR suppression, and recursion prevention | Acquisition, client assets, real seal exclusivity, judgement selection, or playerbot rotation policy |
| Divine Steed | Active 901017, faction display choice, run-speed aura, safe removal, and logout/map cleanup | Acquisition, client export, real mounted state, vehicles, or playerbot rotation policy |
| Paladin Vengeance variants | Passives 901018 and 901020, timed buffs 901019 and 901021, critical-event eligibility, stack caps, and effect amounts | Acquisition, client assets, specialization enforcement, or playerbot talent selection |
| Extended Arsenal | Passive ranks 901022 and 901023, native range and jump-target modifiers, and exact Paladin family masks | Acquisition, client assets, base spell target rules, or playerbot talent selection |
| Divine Toll | Active 901024, impact marker 901025, Justice visual 901026, delayed events, seal selection, damage provenance, and proc bounds | Acquisition, client patch generation, normal Judgement wrappers, or playerbot rotation policy |
| Burning Conflagration | Passive 901027, pre-consumption Immolate rank capture, bounded nearby selection, and full matching-rank propagation | Acquisition, client patch generation, base Conflagrate consumption, or playerbot rotation policy |
| Chaotic Inferno | Passive 901031, helper 901032, creature 900002, non-pet guardian ownership, stock Inferno impact, scaling, follow, assist, and duration | Acquisition, client patch generation, stock Inferno 1122, or playerbot rotation policy |
| Demonic Equilibrium | Passive 901033, stock Soul Link aura 25228 split override, and per-hit 75 percent calculation | Acquisition, client patch generation, Soul Link activation, demon eligibility, or playerbot rotation policy |
| Unquenchable Flames | Passive 901034, native 100 percent resist-dispel modifier, and exact Immolate and Shadowflame family masks | Acquisition, client patch generation, global stock-spell changes, or playerbot rotation policy |
| Unyielding Shadows | Passive 901035, native 100 percent resist-dispel modifier, and combined Warlock family mask excluding Unstable Affliction | Acquisition, client patch generation, global stock-spell changes, or playerbot rotation policy |
| Haunting Affliction | Passive 901028, marker 901029, Haunt hit hook, highest-known DoT ranks, and curse and Seed exclusions | Acquisition, base DoT mechanics, client patch generation, or playerbot rotation policy |
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
  -> one through five GUID-based impacts at 500 ms intervals
     -> marker 901025 scopes half damage, guaranteed hit, SoR overlap, and one JotW proc
     -> visual 901026 and current real-seal Judgement behavior

Conflagrate rank chain with passive 901027
  -> capture exact same-caster Immolate rank before core consumption
     -> apply full Immolate to up to three eligible enemies within 10 yards

Haunt rank chain with passive 901028
  -> successful hit applies caster marker 901029 for 30 seconds
     -> eligible highest-known Curse of Agony, Corruption, and Unstable Affliction ranks

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
4. Spell IDs 901001 through 901047 are provisional deployment contracts and must be collision-checked in server and client data.
5. Server `spell_dbc` rows and client `Spell.dbc` rows must agree for custom spells.
6. Damage modifiers stack through shared mutable hook arguments. New modifiers must document hook overlap and rounding order.
7. Configuration defaults in code and distributed `.conf.dist` files must remain synchronized.
8. Runtime and database validation status must be recorded honestly.

## Current validation status

The repository contains no standalone unit-test or integration-test harness. This documentation was checked against local source, SQL, configuration, and the sibling `mod-playerbots` repository. No full custom-core build, worldserver startup, live database migration, client DBC export, or in-game scenario was run during the 2026-09-16 documentation review.

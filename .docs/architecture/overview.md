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
| `src/battleground_stamina/` | Battleground stamina calculation, custom aura lifecycle, and equipment lock |
| `conf/` | Distributed module configuration |
| `data/mod_apocalipse.sql` | Manual Spec Manager schema, seed data, NPC, and Blazing Barrier script binding |
| `data/mod_spell_scaling.sql` | Manual spell-scaling schema and seed data |
| `data/2026_09_16_01_blazing_barrier.sql` | Manual server-side Blazing Barrier spell migration |
| `data/sql/db-world/` | AzerothCore module world-database updates, including spells 901002 and 901003 |
| `.docs/` | Persistent engineering and operational context |

## Registered subsystem order

`Addapocalipse_wow_moduleScripts()` registers systems in this order:

1. `AddModApocalipseScripts()`
2. `AddModSpellScalingScripts()`
3. `AddModApocalipsePvPScripts()`
4. `AddModApocalipseMageSpellScripts()`
5. `AddModApocalipseMagePyroclasticChainReactionScripts()`
6. `AddModApocalipseBattlegroundStaminaScripts()`

The entry-point name is derived from the module directory `apocalipse-wow-module`, with hyphens converted to underscores. Renaming the directory requires changing the entry point.

## Subsystem boundaries

| Subsystem | Owns | Does not own |
|---|---|---|
| Spec Manager | Dominant tree detection, managed spells and talents, per-character grant state | General bot talent selection or AI |
| Spell Scaling | Final value scaling for spell IDs listed in `mod_spell_scaling` | Spell acquisition, PvP eligibility, or custom spell definitions |
| PvP Balancing | Damage reduction when a player or player-owned unit damages a player | Healing, absorb creation, battleground stamina, or arena matchmaking |
| Blazing Barrier | Spell 901001 amount, recast rule, and selected mage talent procs | Spell row installation, client DBC distribution, or level scaling |
| Pyroclastic Chain Reaction | Spell 901003 proc gate, Living Bomb refresh, triggered explosion, and bounded spread | Talent acquisition, custom client data, or changing normal Living Bomb expiration |
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

Battleground and player hooks
  -> Battleground Stamina
     -> bot session check only for equipment-lock exemption
```

Subsystems do not call each other's C++ functions. Their integration is event-driven through shared AzerothCore objects, hook dispatch, spell IDs, configuration, and database rows.

## Core invariants

1. Every subsystem must be registered from `Addapocalipse_wow_moduleScripts()`.
2. Bot-specific behavior must use the custom core's `WorldSession::IsBot()` contract rather than guessing from names, accounts, or AI pointers.
3. World data belongs in `WorldDatabase`; per-character state belongs in `CharacterDatabase`.
4. Spell IDs 901001, 901002, and 901003 are provisional deployment contracts and must be collision-checked in server and client data.
5. Server `spell_dbc` rows and client `Spell.dbc` rows must agree for custom spells.
6. Damage modifiers stack through shared mutable hook arguments. New modifiers must document hook overlap and rounding order.
7. Configuration defaults in code and distributed `.conf.dist` files must remain synchronized.
8. Runtime and database validation status must be recorded honestly.

## Current validation status

The repository contains no standalone unit-test or integration-test harness. This documentation was checked against local source, SQL, configuration, and the sibling `mod-playerbots` repository. No full custom-core build, worldserver startup, live database migration, client DBC export, or in-game scenario was run during the 2026-09-16 documentation review.

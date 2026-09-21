# apocalipse-wow-module

AzerothCore WotLK 3.3.5a gameplay module for the Apocalipse WoW private-server infrastructure. It is deployed with `mod-playerbots` and the custom playerbot AzerothCore branch.

The module provides twenty-five systems:

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
12. Divine Storm Echo custom paladin passive
13. Permanent Seal of Righteousness custom paladin passive
14. Divine Steed custom paladin sprint
15. Paladin Vengeance variant passives
16. Extended Arsenal custom paladin passive
17. Divine Toll custom paladin spell
18. Burning Conflagration custom warlock passive
19. Chaotic Inferno custom warlock passive
20. Demonic Equilibrium custom warlock passive
21. Unquenchable Flames custom warlock passive
22. Unyielding Shadows custom warlock passive
23. Haunting Affliction custom warlock passive
24. Permanent Metamorphosis custom warlock passive
25. Battleground stamina assistance and equipment control

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
|       `-- 2026_09_20_06_demonic_equilibrium.sql
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

### Divine Storm Echo

Owner: `src/mod_apocalipse_paladin_divine_storm_echo.cpp`

Custom passive 901014 makes completed Divine Storm 53385 casts schedule triggered echo 901015 one second later. The echo selects up to 12 enemies around the paladin's current position, deals normalized 55 percent weapon damage, resolves independent hits and critical strikes, retains normal proc eligibility, and reuses core Divine Storm healing proportional to final damage.

The automatic module world update installs both custom rows and exact script bindings. Passive acquisition remains external, echo 901015 must never be learned directly, and matching client rows are required. Human and bot-controlled paladins use identical mechanics.

Detailed contract: [`.docs/custom-spells/divine-storm-echo.md`](.docs/custom-spells/divine-storm-echo.md)

### Permanent Seal of Righteousness

Owner: `src/mod_apocalipse_paladin_permanent_seal_of_righteousness.cpp`

Custom passive 901016 adds stock Seal of Righteousness damage to eligible melee attacks and judgements while another real seal remains active. It reuses damage spell 25742, the stock AP, Holy spell-power, target vulnerability, libram, and weapon-speed formula, including the Judgements of the Just double hit.

The passive has no seal family flags, so it does not enter real seal exclusivity or judgement selection. It suppresses itself while real Seal of Righteousness is active and rejects its own damage to prevent recursion. Acquisition remains external, a matching visible client spell row is required, and humans and bots use identical mechanics.

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

Owners: `src/mod_apocalipse_paladin_divine_toll.cpp`, `data/sql/db-world/2026_09_18_05_divine_toll.sql`

Custom active spell 901024 costs 10 percent base mana, uses the global cooldown, and has a 60-second cooldown. It rolls one through five impacts against the selected hostile target, beginning immediately and continuing every 500 ms. Invalid targets are replaced by the nearest valid enemy within normal Judgement range.

Each impact applies Judgement of Justice and executes the currently active real seal's stock Judgement behavior at 50 percent damage with independent critical strikes and normal downstream PvP and proc handling. Judgements of the Wise is limited to once per sequence, while Judgements of the Just, Heart of the Crusader, Righteous Vengeance, and generic procs retain their approved per-impact behavior. Passive 901016 can fire beside real Seal of Righteousness only during the bounded Divine Toll impact marker.

Acquisition and client patch generation remain external. Humans and bots use identical mechanics.

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

Owners: `src/mod_apocalipse_warlock_haunting_affliction.cpp`, `data/sql/db-world/2026_09_20_02_haunting_affliction.sql`

Custom passive 901028 causes a successful Haunt hit to apply the Warlock's highest learned Curse of Agony, Corruption, and Unstable Affliction ranks. Hidden marker 901029 enforces a caster-global 30-second internal cooldown across every target and is not saved through logout.

A different curse owned by the same Warlock suppresses only Curse of Agony. Same-caster Seed of Corruption suppresses only Corruption. Existing eligible DoTs refresh normally, Unstable Affliction retains its stock dispel behavior, and humans and bots use identical mechanics.

Acquisition remains external and must reference only passive 901028. Matching client rows are required for 901028 and implementation-only marker 901029.

Detailed contract: [`.docs/custom-spells/haunting-affliction.md`](.docs/custom-spells/haunting-affliction.md)

### Permanent Metamorphosis

Owners: `src/mod_apocalipse_warlock_permanent_metamorphosis.cpp`, `data/sql/db-world/2026_09_20_03_permanent_metamorphosis.sql`

Demonology passive 901030 preserves normal Metamorphosis activation spell 59672 and its cooldown, but gives transformation aura 47241 infinite duration. Death retains stock cleanup, while passive removal, talent reset, login recovery after an interrupted shutdown, logout, or a mount attempt removes the transformation and its linked effects. Dismounting does not restore it.

The Demonology Spec Manager profile grants passive 901030 alongside active spell 59672. Humans and bots use identical mechanics, and existing playerbot activation and aura checks remain valid. A matching client spell row is required.

Detailed contract: [`.docs/custom-spells/permanent-metamorphosis.md`](.docs/custom-spells/permanent-metamorphosis.md)

### Demonic Equilibrium

Owners: `src/mod_apocalipse_warlock_demonic_equilibrium.cpp`, `data/sql/db-world/2026_09_20_06_demonic_equilibrium.sql`

Custom passive 901033 raises stock Soul Link's damage transfer from 20 percent to 75 percent while both auras are active. The per-hit split hook preserves stock Soul Link activation, demon eligibility, combat logs, proc handling, and its behavior when the passive is absent.

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
- Server and client custom-spell data for spells 901001 through 901035
- Matching talent data when a custom passive is granted through a talent

Stock AzerothCore compatibility has not been validated.

## Database setup

Manual baseline and migration files are outside the automatic updater path. Run them only against the named database while following the server's backup and migration procedure.

```sql
-- Switches between acore_world and acore_characters internally.
SOURCE data/mod_apocalipse.sql;

-- acore_world
SOURCE data/mod_spell_scaling.sql;

-- acore_world, while worldserver is stopped
SOURCE data/2026_09_16_01_blazing_barrier.sql;
```

Files under `data/sql/db-world/` are automatic module world updates. They run on worldserver startup only when world database updates and module update discovery are enabled. Do not also import them manually when the updater will apply them. The 901002 update is idempotent for its recognized spell row and may be executed manually, with worldserver stopped and a current backup, to repair an already-recorded deployment. The 901003 through 901035 updates install the custom class spells, native modifiers, proc metadata, and script bindings.

Before the first custom-spell deployment, verify IDs 901001 through 901035 are free in live `spell_dbc`, `wotlk_spells_full`, `wotlk_spells`, and the actual selected client/server `Spell.dbc`.

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

# Build, configuration, database, and release operations

Last source review: 2026-09-20

## Supported context

This repository is not standalone. Build it under `modules/apocalipse-wow-module` in the custom AzerothCore WotLK branch required by the deployed `mod-playerbots` version. `CMakeLists.txt` is intentionally minimal because the parent module build collects sources under `src/`.

The matching custom AzerothCore checkout is available under `../wowlk-core/apocalipse-azerothcore-wotlk`. Builds remain opt-in under that core's repository instructions.

## Install and build

1. Place or link this repository at `<azerothcore>/modules/apocalipse-wow-module`.
2. Configure the parent core with modules enabled.
3. Build `worldserver` through the parent core's supported platform workflow.

Typical Linux configuration:

```bash
cmake .. -DMODULES=static
cmake --build . --parallel
```

Dynamic modules may use `-DMODULES=dynamic` when supported by the target core. A successful standalone C++ compile is not sufficient; verify against the exact custom core and `mod-playerbots` branch used in deployment.

## Custom-core C++ API compatibility

Module source must follow the declarations and include dependencies of the deployed custom core, even when a similar API exists in another AzerothCore revision.

- Include the header that directly declares every core symbol used by a module source. Do not rely on the precompiled header or incidental transitive includes.
- Include `Define.h` before a direct `SpellAuras.h` include. In the deployment core, `SpellAuraDefines.h` uses aliases such as `uint8` but does not include their declaration itself. An include order that starts with `SpellAuras.h` therefore fails when module sources compile outside a precompiled-header context.
- Include `SpellMgr.h` when using proc masks. `ProcEventInfo::GetHitMask()` uses the `PROC_HIT_*` contract, so use `PROC_HIT_ABSORB` rather than the legacy `PROC_EX_ABSORB` name when filtering absorbed hits.
- Access a spell category through `SpellInfo::GetCategory()`. This custom core stores the category through `CategoryEntry` and does not expose a public `SpellInfo::Category` member.
- Before adding or copying spell code, search the matching custom core for the exact symbol and a current call site. Treat code from stock AzerothCore, TrinityCore, or another branch as a behavioral reference only.
- Keep module builds valid with and without core or script precompiled headers when the deployment build supports both modes. Missing direct includes often remain hidden until a non-PCH translation unit or a different build configuration compiles the file.

## Configuration

### PvP balancing

The following keys are read directly from the worldserver configuration and default in code:

| Key | Default | Reload behavior |
|---|---:|---|
| `Apocalipse.PvPDamageReductionPct` | `15.0` | Reloaded on config reload |
| `Apocalipse.PvPBracketResilience.1019` | `8.0` | Reloaded on config reload |
| `Apocalipse.PvPBracketResilience.2029` | `10.0` | Reloaded on config reload |
| `Apocalipse.PvPBracketResilience.3039` | `12.0` | Reloaded on config reload |
| `Apocalipse.PvPBracketResilience.4049` | `14.0` | Reloaded on config reload |
| `Apocalipse.PvPBracketResilience.5059` | `16.0` | Reloaded on config reload |
| `Apocalipse.PvPBracketResilience.6069` | `18.0` | Reloaded on config reload |
| `Apocalipse.PvPBracketResilience.7079` | `20.0` | Reloaded on config reload |

No dedicated PvP `.conf.dist` is currently present. Operators must ensure these keys exist in the effective worldserver configuration if they do not want code defaults.

### Battleground stamina

`conf/BattlegroundStamina.conf.dist` defines enablement, human gear locking, aura ID, gap coverage, maximum stamina, and 70 class/bracket thresholds.

Modern AzerothCore parent CMake discovers each enabled module's `conf/*.conf.dist` files without an `AC_ADD_CONFIG_FILE` call, copies them without the `.dist` suffix, and adds them to the module config list consumed by `sConfigMgr`. Confirm CMake reports `BattlegroundStamina.conf` and that the generated/deployed module config exists in the target custom-core revision.

Important drift: the 10-19 threshold values in `conf/BattlegroundStamina.conf.dist` are higher than the compiled fallback values in `BattlegroundStamina.cpp`. Until synchronized in code, a missing or stale deployed module config changes live behavior.

A config reload updates cached values and revalidates aura 901002. It does not sweep every player already inside a battleground. Re-entry, another application hook, or restart is needed for deterministic reconciliation.

## Database ownership

| File | Database | Mode | Purpose |
|---|---|---|---|
| `data/mod_apocalipse.sql` | `acore_world`, then `acore_characters` | Manual, one-time baseline | Spec table and seeds, NPC 900001, spell script binding, per-character spec/budget tables |
| `data/mod_spell_scaling.sql` | `acore_world` | Manual, one-time baseline | Scaling table and seed rows |
| `data/2026_09_16_01_blazing_barrier.sql` | `acore_world` | Manual while worldserver is stopped | Spell 901001, binding, scaling row, and backend name cache |
| `data/sql/db-world/2026_09_16_00_battleground_stamina_spell.sql` | `acore_world` | AzerothCore module updater; idempotent for its recognized spell row | Spell 901002, equipped-item requirement repair, custom non-save attribute, and backend name cache |
| `data/sql/db-world/2026_09_17_00_pyroclastic_chain_reaction.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized passive row | Spell 901003, Pyroblast and Living Bomb explosion bindings, and backend name cache |
| `data/sql/db-world/2026_09_18_01_pyroclastic_chain_reaction_propagated_damage.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized passive row | Living Bomb aura rank binding for propagated 30 percent periodic and explosion damage |
| `data/sql/db-world/2026_09_17_01_hypernova.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized active spell row | Spell 901005, script binding, damage coefficient, and backend name cache |
| `data/sql/db-world/2026_09_17_01_missile_barrage_overload.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized passive row | Spell 901004, Missile Barrage and passive cleanup bindings, and backend name cache |
| `data/sql/db-world/2026_09_17_02_prismatic_barrier.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized active spell row | Spell 901006, script binding, and backend name cache |
| `data/sql/db-world/2026_09_17_03_frost_bomb.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized three-spell graph | Spells 901007 through 901009, script bindings, coefficient, and backend names |
| `data/sql/db-world/2026_09_17_04_automatic_ice_lance.sql` | `acore_world` | AzerothCore module updater; guarded and rerunnable for its recognized passive and haste rows | Spells 901010 and 901011, proc metadata, script bindings, non-save haste metadata, and backend names |
| `data/sql/db-world/2026_09_17_05_frozen_retaliation.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized two-rank passive chain | Spells 901012 and 901013, rank relationships, incoming-damage proc metadata, script binding, and backend names |
| `data/sql/db-world/2026_09_18_02_divine_storm_echo.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized passive and echo rows | Spells 901014 and 901015, Divine Storm scheduling and healing bindings, and backend names |
| `data/sql/db-world/2026_09_18_03_permanent_seal_of_righteousness.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized passive row | Spell 901016, melee and judgement proc metadata, script binding, and backend name |
| `data/sql/db-world/2026_09_18_04_divine_steed.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized active row | Spell 901017, display lifecycle binding, non-save attribute, and backend name |
| `data/sql/db-world/2026_09_20_01_divine_steed_cast_cancel.sql` | `acore_world` | AzerothCore module updater; guarded and rerunnable for the recognized active row | Updates 901017 descriptions for cancellation after another spell cast |
| `data/sql/db-world/2026_09_18_04_paladin_vengeance_variants.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized four-spell graph | Spells 901018 through 901021, critical-event proc metadata, non-save timed buffs, and backend names |
| `data/sql/db-world/2026_09_18_05_extended_arsenal.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized two-rank passive chain | Spells 901022 and 901023, range and jump-target modifiers, rank relationships, and backend names |
| `data/sql/db-world/2026_09_18_05_divine_toll.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized three-spell active graph | Spells 901024 through 901026, parent and additive stock-spell bindings, non-save markers, and backend names |
| `data/sql/db-world/2026_09_20_02_haunting_affliction.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized passive and cooldown graph | Spells 901028 and 901029, Haunt rank-chain binding, non-save marker metadata, and backend names |
| `data/sql/db-world/2026_09_20_03_permanent_metamorphosis.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized passive row | Spell 901030, Demonology Spec Manager acquisition, and backend name |
| `data/sql/db-world/2026_09_20_04_burning_conflagration.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized passive row | Spell 901027, Conflagrate rank-chain binding, and backend name |
| `data/sql/db-world/2026_09_20_05_chaotic_inferno.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized spell, creature, and summon graph | Spells 901031 and 901032, creature 900002, summon properties, Infernal support rows, Chaos Bolt binding, and backend names |
| `data/sql/db-world/2026_09_20_06_demonic_equilibrium.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized passive row | Spell 901033, stock Soul Link aura binding, and backend name |
| `data/sql/db-world/2026_09_20_07_unquenchable_flames.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized passive row | Spell 901034, native resist-dispel modifier, exact Immolate and Shadowflame family masks, and backend name |
| `data/sql/db-world/2026_09_20_08_unyielding_shadows.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized passive row | Spell 901035, native resist-dispel modifier, combined Warlock family mask excluding Unstable Affliction, and backend name |
| `data/sql/db-world/2026_09_21_00_ambush_trapper.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized four-spell graph | Spells 901038 through 901041, trap and melee proc metadata, script bindings, non-save buff, zero coefficients, DAMAGE scaling, and backend names |
| `data/sql/db-world/2026_09_21_03_primal_resolve.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized active row | Spell 901042, all-school damage reduction, snare-removal binding, non-save metadata, and backend name |
| `data/sql/db-world/2026_09_21_01_apex_bond.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized active row | Spell 901046, native percent heals, pet damage aura, script binding, non-save metadata, and backend name |
| `data/sql/db-world/2026_09_21_01_blood_of_the_hunt.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized passive and helper rows | Spells 901044 and 901045, shared melee/trap cooldown metadata, script binding, zero coefficients, HEAL scaling, and backend names |
| `data/sql/db-world/2026_09_21_02_melee_specialization.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized passive row | Spell 901047, native family-filtered aura-state bypass, 30 percent melee-family damage modifier, and backend name |
| `data/sql/db-world/2026_09_18_01_automatic_ice_lance_proc_eligibility.sql` | `acore_world` | AzerothCore module updater; guarded for the recognized passive row | Updates installed spell 901010 for direct, periodic, and triggered Frost damage eligibility and current descriptions |
| `data/sql/db-world/2026_09_18_00_frost_bomb_visual_origin.sql` | `acore_world` | AzerothCore module updater; guarded and rerunnable for the recognized explosion row | Removes caster-attached visual 17 from spell 901008 so C++ can emit the same visual from the bombed target through existing spell 34326 |
| `data/sql/db-world/2026_09_20_00_frost_bomb_damage_and_visual.sql` | `acore_world` | AzerothCore module updater; guarded and rerunnable for the recognized explosion row and coefficient | Doubles 901008 base damage and direct coefficient, updates descriptions, and clears caster-attached visual 17 again before client export |

`data/mod_apocalipse.sql` correctly issues `USE acore_characters` before creating `mod_player_spec`, `mod_player_spec_talent_budget`, and `mod_player_spec_talent_grant`. Do not remove that switch.

The `mod_player_spec_talent_grant` table is currently created but not used by the C++ implementation. Treat it as reserved/dead schema until code establishes an owner.

Custom-spell updater files require the externally managed `wotlk_spells_full` and `wotlk_spells` tables in `acore_world`. They use those tables for collision guards, stock spell metadata, backend names, and client-export ownership. Missing tables are a hard migration failure and must be restored through the backend schema workflow before worldserver startup.

## Agent offline-only database policy

Agent sessions must always assume that MySQL is unavailable. Agents must not attempt connections, service or port probes, container startup, credential discovery, database MCP access, or SQL execution. SQL review is static only.

For spell IDs and spell data, agents must use this order:

1. Module world updates and manual migrations. C++ constants and documentation only cross-check migration consistency.
2. Matching custom AzerothCore source and checked-in SQL.
3. Read-only extraction from an available local `.dbc` only when the earlier sources are insufficient.

These are the only permitted ID and spell-data discovery sources. Backend source may be reviewed for export mechanics, but backend caches, services, and databases are not allocation evidence.

Agents allocate the next repository-free guarded range and leave live database and deployed-client collision checks pending for an authorized deployment operator. The deployment SQL below is operator guidance and must not be executed by agents.

## First deployment sequence

The following sequence is for an authorized deployment operator in an environment that actually provides the databases. It is not an agent validation workflow.

1. Stop `worldserver`.
2. Back up affected databases according to the server's normal procedure.
3. Collision-check custom spell IDs 901001 through 901047 in live server tables and the selected client `Spell.dbc`.
4. Apply `data/mod_apocalipse.sql` and `data/mod_spell_scaling.sql` to their named databases.
5. Apply the manual Blazing Barrier migration if spell 901001 is being deployed.
6. Build and install the module under the custom core.
7. Ensure world database updates are enabled, then start `worldserver` so the 901002 through 901047 module updates can run.
8. Confirm all updater records and module startup logs.
9. Deploy matching client `Spell.dbc` data and patch artifacts for custom spells. Deploy the separate talent and acquisition data through their owned workflows.
10. Run focused human and bot in-game scenarios.

Do not manually import the 901002 updater file on a first deployment if the normal module updater will apply it. Do not execute any production SQL without explicit operator approval.

### Repairing an existing 901002 installation

The original 901002 insert omitted `EquippedItemClass`, so the world table default stored `0`. Because AzerothCore may retain the updater filename as already applied, replacing the repository file does not guarantee another automatic execution.

For an existing module-owned 901002 row, stop worldserver, take the normal world-database backup, and execute `data/sql/db-world/2026_09_16_00_battleground_stamina_spell.sql` manually against `acore_world`. The file recognizes ownership from the spell name and stamina-effect signature, repairs the equipped-item fields, and can be rerun without duplicate-key failure. A non-matching collision still fails before related rows are changed.

Restart worldserver so the corrected `spell_dbc` row is loaded, then verify:

```sql
SELECT `ID`, `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`
FROM `spell_dbc`
WHERE `ID` = 901002;
```

The expected equipped-item values are `-1`, `0`, and `0`. Confirm the `HasItemFitToSpellRequirements` error no longer appears when assistance is applied.

## Operator custom spell preflight

Before first deployment, an authorized operator verifies all custom IDs in the real deployment environment. Agents do not run these queries and instead rely on the offline evidence hierarchy and migration collision guards.

Verify all custom IDs are unallocated in:

```sql
SELECT `ID` FROM `spell_dbc` WHERE `ID` BETWEEN 901001 AND 901047;
SELECT `ID` FROM `wotlk_spells_full` WHERE `ID` BETWEEN 901001 AND 901047;
SELECT `ID` FROM `wotlk_spells` WHERE `ID` BETWEEN 901001 AND 901047;
SELECT `entry` FROM `creature_template` WHERE `entry` = 900002;
SELECT `ID` FROM `summonproperties_dbc` WHERE `ID` = 901032;
```

Also inspect the actual client/server base `Spell.dbc`; it is not represented fully by these SQL queries.

## Verification

### Static and build

- Inspect `git diff` and exact config/SQL string keys.
- Build the parent custom AzerothCore `worldserver` with this module and `mod-playerbots` enabled.
- Check startup logs for all registered load paths.
- Confirm no custom table or spell validation warnings.

### Runtime

At minimum test:

- Human and bot login with each representative spec transition.
- Talent reset and dual-spec behavior.
- Configured direct, periodic, healing, and absorb scaling below and at level 80.
- PvP direct, periodic, melee, pet-owned, low-bracket, and level-80 damage.
- Blazing Barrier cast, weaker/stronger recast, absorb, and mage talent procs.
- Pyroclastic Chain Reaction explosion rank speed validation, passive gating, 20 percent proc, source refresh, rank preservation, normal explosion isolation, zero/one/two-target spread, and 30 percent propagated tick and explosion damage.
- Missile Barrage Overload one/two/twenty-proc channels, cap refresh, release visual, aggregate consumption, passive cleanup, Clearcasting, T8, and T10 behavior.
- Hypernova target range, 22 percent base mana cost, 45 second cooldown, 4x Arcane Blast damage and coefficient, Arcane modifiers, 10-yard target area, four-stack reward, knockback immunities, and human/playerbot movement.
- Prismatic Barrier 42 percent base mana cost, 45 second cooldown, all three child auras, child script behavior, existing stronger barriers, child cooldown isolation, and identical human/playerbot results.
- Frost Bomb cast cost and cooldown, expiration/dispel/death detonation, cleanup exclusions, dead-target center, 10-yard damage, primary inclusion, Permafrost ranks, Fingers of Frost, Brain Freeze, Shatter, crowd-control breaking, damage procs, and identical human/playerbot results.
- Automatic Ice Lance direct, periodic, and triggered Mage Frost eligibility, Ice Lance recursion exclusion, 10 percent chance, one-second cooldown, wall and pillar line-of-sight rejection, target guards, Fingers of Frost consumption, independent 10-second expirations, 20 percent cap, passive removal cleanup, and identical human/playerbot results.
- Frozen Retaliation ranks 1 and 2, 1.5 and 3 percent chances, melee, ranged, direct spell, periodic, triggered, fully prevented, environmental, existing Fingers of Frost, rank upgrade, and identical human/playerbot results.
- Divine Storm Echo without the passive, one-second timing, death, logout, passive removal, movement, 12-target selection, normalized 55 percent weapon damage, independent hit and critical strike results, normal procs, proportional healing, recursion prevention, and identical human/playerbot results.
- Divine Steed Alliance/Horde display selection, four-second duration, 100 percent run speed, 20-second cooldown, combat and indoor use, cancellation after successful non-triggered player spells, triggered-spell exclusion, ordinary attacks, pet retention, death/cancel/logout/map cleanup, real mount replacement, enabled race and sex rider attachments, and identical human/playerbot results.
- Extended Arsenal ranks 1 and 2, 3 and 6 yard cast-range increases, one and two added targets, Hammer melee hop radius and frontal restrictions, Avenger's Shield daze, silence, and secondary behavior on every added target, unrelated Paladin spell isolation, and identical human/playerbot results.
- Divine Toll no-seal rejection, 10 percent base mana cost, 60-second cooldown, uniform one-through-five roll, immediate and 500 ms timing, invalid-target retargeting, caster cancellation states, every stock seal, half damage, independent critical strikes, immunity and absorb behavior, shared Judgement reset, JotW once, per-impact talent and generic procs, real-SoR overlay exception, and identical human/playerbot results.
- Permanent Metamorphosis stock activation and cooldown, infinite aura 47241 duration, active-form passive acquisition, death, passive removal, talent reset, interrupted-shutdown login recovery, logout, valid and later-rejected mount attempts, dismount behavior, linked aura and temporary ability cleanup, and identical human/playerbot results.
- Unquenchable Flames all Immolate and Shadowflame ranks, unrelated Warlock debuff isolation, multiple-caster ownership, passive acquisition and removal during an active aura, normal expiration and Conflagrate consumption, and identical human/playerbot results.
- Unyielding Shadows every curse and covered Shadow aura, Unstable Affliction stock dispel and backlash behavior, multiple-caster ownership, owner-demon effects, passive acquisition and removal during an active aura, normal non-dispel removal, and identical human/playerbot results.
- Chaotic Inferno successful and failed Chaos Bolt impacts, stock meteor damage and stun, 20-second guardian duration, cooldown-bounded unlimited stacking, normal pet coexistence, owner assist and follow behavior, lifecycle cleanup, and identical human/playerbot results.
- Battleground stamina below/above threshold, buff isolation, gear swaps, bot auto-gearing, death, reconnect, and exit cleanup.

Record observed results in the relevant feature page and history entry. If a scenario was not run, mark it `Not run`.

## Deployment script warning

`deploy.ps1` runs `git add .`, creates a generic commit, and pushes with no build, branch, diff, or safety checks. It is not a production deployment workflow. Agents must not run it unless the user explicitly asks for those exact git side effects after reviewing what will be staged.

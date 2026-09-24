# AGENTS.md

## Scope

These instructions apply to the entire `apocalipse-wow-module` repository.

## Project identity

This is an AzerothCore WotLK 3.3.5a gameplay module for the Apocalipse WoW private-server infrastructure. It is deployed with `mod-playerbots` and the custom playerbot AzerothCore branch. It is not a standalone program and has not been validated against stock AzerothCore.

The module does not implement bot AI strategies, actions, triggers, or values. It changes gameplay for AzerothCore `Player` objects, including bot-controlled players, through scripts, hooks, configuration, databases, and custom spell data.

## Start here

Before changing code or data, read:

1. Documentation index and maintenance contract: [`.docs/README.md`](.docs/README.md)
2. Component boundaries: [`.docs/architecture/overview.md`](.docs/architecture/overview.md)
3. Hook and data interactions: [`.docs/architecture/runtime-and-data-flow.md`](.docs/architecture/runtime-and-data-flow.md)
4. Playerbot boundary for bot-related work: [`.docs/integrations/playerbots.md`](.docs/integrations/playerbots.md)
5. Build, configuration, SQL, and release rules: [`.docs/development/operations.md`](.docs/development/operations.md)
6. Subsystem and feature indexes: [`.docs/subsystems/catalog.md`](.docs/subsystems/catalog.md) and [`.docs/features/README.md`](.docs/features/README.md)

Use executed code in the matching custom core as the final source of truth. When code, SQL, config, and docs disagree, investigate the runtime path and fix the drift in the same change.

## Offline-only database assumption

Agent development and review must always assume that no local or reachable MySQL service exists. Agents must not attempt a MySQL connection, probe database ports or services, start a database or container, search for credentials, invoke database MCP tools, or execute SQL for discovery or validation. This remains true even when configuration files contain database connection settings.

Use this mandatory evidence order for spell IDs and spell data:

1. Inspect `data/sql/db-world/` and manual migrations in this module for existing custom allocations and ownership. Use module C++ constants and documentation only to cross-check migration consistency, not as a substitute for the migration ledger.
2. Inspect the matching custom AzerothCore source and checked-in AzerothCore SQL for stock IDs, schemas, enum values, proc behavior, family masks, and nearby spell contracts.
3. Only when those sources are insufficient, extract fields from an available local `.dbc` file in read-only mode. Never require a DBC file and never modify one unless explicitly requested.

These are the only permitted ID and spell-data discovery sources. Backend code may be inspected to understand export mechanics, but backend caches, services, and databases are not ID-allocation evidence.

If these offline sources cannot prove that an ID is globally free, use the next repository-free guarded range, preserve collision guards, and report live database and deployed-client collision checks as pending operator deployment work. Do not ask for database credentials and do not block implementation solely because live MySQL validation is unavailable. SQL validation during agent work is static review only. SQL snippets in operations documentation are commands for an authorized deployment operator, not instructions for agents to execute.

## Current source map

| Path | Responsibility |
|---|---|
| `src/mod_apocalipse_loader.cpp` | Entry point and registration order |
| `src/mod_apocalipse.cpp` | Dominant spec, signature spells, hidden talent budget, and Spec Master NPC |
| `src/mod_spell_scaling.cpp` | Data-driven level scaling for selected spell effects |
| `src/mod_apocalipse_pvp.cpp` | PvP damage reduction and bracket resilience floor |
| `src/mod_apocalipse_mage_spells.cpp` | Blazing Barrier custom spell behavior |
| `src/mod_apocalipse_mage_pyroclastic_chain_reaction.cpp` | Passive-gated Pyroblast and Living Bomb interaction |
| `src/mod_apocalipse_mage_missile_barrage_overload.cpp` | Missile Barrage accumulation and Arcane Missiles extension |
| `src/mod_apocalipse_mage_hypernova.cpp` | Hypernova Arcane burst, target visual, and four-stack reward |
| `src/mod_apocalipse_mage_prismatic_barrier.cpp` | Prismatic Barrier orchestration of three existing mage barriers |
| `src/mod_apocalipse_mage_frost_bomb.cpp` | Frost Bomb removal, explosion, proc, and Permafrost slow behavior |
| `src/mod_apocalipse_mage_automatic_ice_lance.cpp` | Automatic Ice Lance proc filtering and independent haste expirations |
| `src/mod_apocalipse_mage_frozen_retaliation.cpp` | Two-rank incoming-damage proc that grants Fingers of Frost |
| `src/mod_apocalipse_rogue_concentrated_venom.cpp` | Equipped weapon-poison proc that adds real Deadly Poison applications with a per-target throttle |
| `src/mod_apocalipse_rogue_leeching_mixture.cpp` | Owner-attributed Rogue poison damage self-healing with a one-second maximum-health cap |
| `src/mod_apocalipse_rogue_gloomblade_infusion.cpp` | Owner-attributed outgoing damage converted into a separate Shadow hit |
| `src/mod_apocalipse_rogue_shadow_execution.cpp` | Rogue ability-applied stacking Shadow periodic weapon damage |
| `src/mod_apocalipse_rogue_relentless_finale.cpp` | Five-point finisher healing, cast-scoped combo retention, visible readiness, and post-use recharge |
| `src/mod_apocalipse_rogue_improved_feint.cpp` | Rank-wide Feint-triggered all-school damage reduction passive |
| `src/mod_apocalipse_rogue_daring_challenge.cpp` | Combat Rogue taunt, threat lead, and target-specific threat amplification |
| `src/mod_apocalipse_hunter_ambush_trapper.cpp` | Trap-activation buff and charged Hunter melee-special behavior |
| `src/mod_apocalipse_hunter_primal_resolve.cpp` | Active Hunter damage reduction and snare cleanup |
| `src/mod_apocalipse_hunter_apex_bond.cpp` | Active Hunter and pet healing with a temporary pet damage buff |
| `src/mod_apocalipse_hunter_blood_of_the_hunt.cpp` | Shared-cooldown Hunter melee-special and trap self-healing |
| `src/mod_apocalipse_rogue_alchemical_guard.cpp` | Active Rogue damage reduction and poison/disease cleanse and immunity |
| `src/mod_apocalipse_death_knight_crimson_ward.cpp` | Incoming-damage Blood Death Knight maximum-health absorb |
| `src/mod_apocalipse_death_knight_frozen_resolve.cpp` | Combat-gated Death Knight stacking armor and damage reduction |
| `src/mod_apocalipse_death_knight_necrotic_veil.cpp` | Unholy Death Knight damage-derived persistent magic absorb |
| `src/mod_apocalipse_death_knight_rime_shards.cpp` | Frost Strike and Howling Blast damage-derived target-centered Frost burst |
| `src/mod_apocalipse_death_knight_pestilent_eruption.cpp` | Passive-gated free stock Pestilence after Death Coil and Scourge Strike hits |
| `src/mod_apocalipse_death_knight_rupture.cpp` | Blood Death Knight melee-hit stacking periodic bleed |
| `src/mod_apocalipse_rogue_buckler_strike.cpp` | Shield-required Combat Rogue damage, combo point, high threat, and NPC interrupt active |
| `src/mod_apocalipse_paladin_divine_storm_echo.cpp` | Passive-gated delayed Divine Storm echo |
| `src/mod_apocalipse_paladin_permanent_seal_of_righteousness.cpp` | Permanent pseudo-SoR and pseudo-Vengeance proc behavior beside real seals |
| `src/mod_apocalipse_paladin_divine_toll.cpp` | Five sequential 80-percent-damage Judgement impacts and proc controls |
| `src/mod_apocalipse_paladin_divine_steed.cpp` | Display-only paladin horse sprint and lifecycle cleanup |
| `src/mod_apocalipse_warlock_burning_conflagration.cpp` | Passive-gated Conflagrate spread of same-caster Immolate |
| `src/mod_apocalipse_warlock_chaotic_inferno.cpp` | Passive-gated Chaos Bolt Inferno impacts and autonomous guardians |
| `src/mod_apocalipse_warlock_demonic_equilibrium.cpp` | Passive-gated Soul Link damage transfer increase |
| `src/mod_apocalipse_warlock_haunting_affliction.cpp` | Passive-gated DoT applications on every successful Haunt hit |
| `src/mod_apocalipse_warlock_permanent_metamorphosis.cpp` | Passive-gated infinite Metamorphosis duration and lifecycle cleanup |
| `src/mod_apocalipse_shaman_spells.cpp` | Shaman elemental, tank, restoration, defensive, and offensive custom spell pack |
| `src/mod_apocalipse_priest_spells.cpp` | Shared, Discipline, Holy, and Shadow Priest custom spell pack |
| `src/battleground_stamina/` | Battleground stamina calculation, aura lifecycle, and equipment lock |
| `conf/` | Distributed module configuration |
| `data/` | Manual SQL baselines/migrations and automatic module updater SQL |
| `.docs/` | Persistent engineering, feature, operation, and history context |

## Non-negotiable invariants

1. **Use the deployment core.** Compile and validate against the exact custom AzerothCore and `mod-playerbots` branches used by the server.
2. **Register every subsystem.** New script code is unreachable until its `AddMod*Scripts()` function is called by `Addapocalipse_wow_moduleScripts()`.
3. **Treat hook overlap as architecture.** Spell Scaling and PvP Balancing mutate shared damage values. Spec Manager and Battleground Stamina overlap on player events. Document ordering, guards, rounding, and cleanup.
4. **Use the bot session contract.** Detect bots through a valid `WorldSession::IsBot()` call. Do not infer bot state from accounts, names, or optional AI pointers.
5. **State bot behavior explicitly.** Every gameplay feature must say whether it applies identically to bots, suppresses output, bypasses a restriction, or requires separate logic.
6. **Use the correct database.** World definitions use `WorldDatabase`; per-character grant state uses `CharacterDatabase`. Preserve explicit `USE` boundaries in manual SQL.
7. **Keep SQL mode clear.** Files outside `data/sql/db-world/` are manual unless documented otherwise. Files inside that directory are automatic world updates. Never apply production SQL without explicit approval.
8. **Keep custom spell graphs atomic.** Changing any spell from 901001 through 901154 requires checking C++ constants/config, server spell rows, script bindings, scaling rows, backend caches, client `Spell.dbc`, collision guards, talent data where applicable, and documentation.
9. **Keep config defaults synchronized.** A setting's code fallback, distributed `.conf.dist`, validation, and documented default must agree. If they do not, record the drift until fixed.
10. **Preserve gameplay cleanup.** Battleground-only state must be removed on unsupported maps/leave. Managed talents and hidden budgets must be revoked on tree transitions/reset. Do not add persistent auras accidentally.
11. **Keep event work bounded.** Bot populations multiply login, talent, equipment, and combat-hook cost. Do not add database queries to combat or per-tick paths.
12. **Report verification honestly.** Source review is not a build; a build is not a worldserver startup; server data is not a client patch; and none of these prove in-game behavior without a named runtime scenario.

## Required change workflow

1. Read this file and the relevant `.docs` pages.
2. Trace loader registration, all callers/hooks, exact config keys, SQL objects, spell IDs, and human/bot paths before editing.
3. Identify overlapping script hooks and mutable values.
4. Implement the smallest complete vertical change, including registration, config, SQL, server/client spell contracts, and cleanup where applicable.
5. Build against the custom core when available and run focused runtime scenarios for gameplay behavior.
6. Review the final diff for bot impact, reentrancy, integer conversions, persistence, migration order, config drift, and spell-ID collisions.
7. Complete the documentation workflow below before considering the task done.

## Documentation is mandatory

Documentation is part of implementation, not optional follow-up. Future agents must update it without being explicitly asked.

For every feature, fix, refactor, config change, schema change, custom spell change, or operational change:

1. Update the existing owner page in `.docs`.
2. For a new cross-cutting feature, copy [`.docs/templates/feature.md`](.docs/templates/feature.md) to `.docs/features/<lowercase-kebab-name>.md` and index it.
3. For a new internal subsystem, copy [`.docs/templates/subsystem.md`](.docs/templates/subsystem.md) to `.docs/subsystems/<lowercase-kebab-name>.md` and index it.
4. Update architecture when entry points, call order, hooks, boundaries, shared values, or data flow change.
5. Update playerbot integration when bot applicability or custom-core assumptions change.
6. Update operations when config, SQL, spell data, build, deployment, rollback, or verification changes.
7. Update root `README.md` when public behavior, setup, system list, requirements, or status changes.
8. Add a dated `.docs/history/YYYY-MM-DD-<scope>.md` record from [`.docs/templates/history-entry.md`](.docs/templates/history-entry.md) and add it to the history index.
9. Review all links and validation claims against the final diff.

Keep context separated:

- `README.md`: current high-level operator and contributor entry point.
- `AGENTS.md`: compact always-on rules, not implementation history.
- Architecture pages: stable relationships and shared flow.
- Feature/subsystem/custom-spell pages: current detailed behavior and extension constraints.
- History pages: dated trace of what a completed unit of work produced.

Do not copy large source blocks into docs. Prefer exact symbols, keys, tables, short flows, invariants, failure modes, and verification matrices. Do not silently delete retired context; mark it retired or superseded and link the replacement.

## Verification baseline

This repository has no standalone C++ unit-test harness. Use the narrowest available checks and then the parent custom-core build:

- Inspect changed paths and exact string keys.
- Scan documentation links and forbidden stale references.
- Build `worldserver` with this module and `mod-playerbots` enabled.
- Check startup logs and database updater results.
- Run focused human and bot in-game scenarios documented by the affected feature.

For custom spells, validation is incomplete until both server data and the deployed client patch are checked.

## Operational safety

- Do not run `deploy.ps1` unless the user explicitly approves staging all changes, creating its generic commit, and pushing. It performs no build or safety checks.
- Do not run manual or production database migrations without explicit approval and a reviewed backup/rollback plan.
- Preserve unrelated and untracked user work. At the 2026-09-16 source review, `data/2026_09_16_01_blazing_barrier.sql` was untracked.
- Do not claim runtime validation when only documentation or static source review was performed.

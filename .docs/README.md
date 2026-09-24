# Apocalipse WoW module engineering documentation

Last source review: 2026-09-17

## Purpose

This directory preserves implementation and operational context for `apocalipse-wow-module`. The module is compiled into an AzerothCore WotLK 3.3.5a server that also runs `mod-playerbots`. It does not implement the playerbot AI engine. It changes gameplay for `Player` objects, including bots, through AzerothCore script hooks.

The documentation describes current behavior, subsystem interactions, database and custom-spell contracts, bot-specific exceptions, deployment requirements, and known validation gaps. Code, SQL, and distributed configuration remain the source of truth.

## Required reading paths

### First change in this repository

1. Read [`../AGENTS.md`](../AGENTS.md).
2. Read [`architecture/overview.md`](architecture/overview.md).
3. Read [`architecture/runtime-and-data-flow.md`](architecture/runtime-and-data-flow.md).
4. Read the relevant subsystem or feature page.
5. Check [`development/operations.md`](development/operations.md) before changing configuration, SQL, spell IDs, or deployment behavior.

### Bot behavior change

1. [`integrations/playerbots.md`](integrations/playerbots.md)
2. [`architecture/runtime-and-data-flow.md`](architecture/runtime-and-data-flow.md)
3. The affected subsystem page

### New feature or subsystem

1. [`development/documentation-workflow.md`](development/documentation-workflow.md)
2. [`templates/feature.md`](templates/feature.md) or [`templates/subsystem.md`](templates/subsystem.md)
3. [`features/README.md`](features/README.md) and [`subsystems/catalog.md`](subsystems/catalog.md)
4. [`history/README.md`](history/README.md)

## Document map

| Document | Question answered |
|---|---|
| [`architecture/overview.md`](architecture/overview.md) | What is in the module and where are the boundaries? |
| [`architecture/runtime-and-data-flow.md`](architecture/runtime-and-data-flow.md) | How do startup, hooks, databases, spells, and overlapping systems interact? |
| [`integrations/playerbots.md`](integrations/playerbots.md) | Which behavior differs for bots and what does this module rely on from the custom core? |
| [`subsystems/catalog.md`](subsystems/catalog.md) | Which subsystem owns each gameplay concern? |
| [`development/operations.md`](development/operations.md) | How is the module configured, migrated, built, released, and validated? |
| [`development/documentation-workflow.md`](development/documentation-workflow.md) | What must an agent update with each change? |
| [`features/README.md`](features/README.md) | Which features have dedicated end-to-end documentation? |
| [`history/README.md`](history/README.md) | Where is the dated trace of completed work? |
| [`templates/feature.md`](templates/feature.md) | How should cross-cutting feature context be recorded? |
| [`templates/subsystem.md`](templates/subsystem.md) | How should a subsystem be documented in depth? |

Existing deep dives remain valid entry points:

- [`mod_apocalipse.md`](mod_apocalipse.md)
- [`mod_apocalipse_loader.md`](mod_apocalipse_loader.md)
- [`mod_apocalipse_pvp.md`](mod_apocalipse_pvp.md)
- [`mod_spell_scaling.md`](mod_spell_scaling.md)
- [`custom-spells/battleground-stamina-assistance.md`](custom-spells/battleground-stamina-assistance.md)
- [`custom-spells/blazing-barrier.md`](custom-spells/blazing-barrier.md)
- [`custom-spells/pyroclastic-chain-reaction.md`](custom-spells/pyroclastic-chain-reaction.md)
- [`custom-spells/hypernova.md`](custom-spells/hypernova.md)
- [`custom-spells/missile-barrage-overload.md`](custom-spells/missile-barrage-overload.md)
- [`custom-spells/prismatic-barrier.md`](custom-spells/prismatic-barrier.md)
- [`custom-spells/frost-bomb.md`](custom-spells/frost-bomb.md)
- [`custom-spells/automatic-ice-lance.md`](custom-spells/automatic-ice-lance.md)
- [`custom-spells/frozen-retaliation.md`](custom-spells/frozen-retaliation.md)
- [`custom-spells/concentrated-venom.md`](custom-spells/concentrated-venom.md)
- [`custom-spells/ambush-trapper.md`](custom-spells/ambush-trapper.md)
- [`custom-spells/primal-resolve.md`](custom-spells/primal-resolve.md)
- [`custom-spells/apex-bond.md`](custom-spells/apex-bond.md)
- [`custom-spells/blood-of-the-hunt.md`](custom-spells/blood-of-the-hunt.md)
- [`custom-spells/melee-specialization.md`](custom-spells/melee-specialization.md)
- [`custom-spells/crimson-ward.md`](custom-spells/crimson-ward.md)
- [`custom-spells/death-knight-rupture.md`](custom-spells/death-knight-rupture.md)
- [`custom-spells/frozen-resolve.md`](custom-spells/frozen-resolve.md)
- [`custom-spells/necrotic-veil.md`](custom-spells/necrotic-veil.md)
- [`custom-spells/rime-shards.md`](custom-spells/rime-shards.md)
- [`custom-spells/pestilent-eruption.md`](custom-spells/pestilent-eruption.md)
- [`custom-spells/pestilent-knives.md`](custom-spells/pestilent-knives.md)
- [`custom-spells/daring-challenge.md`](custom-spells/daring-challenge.md)
- [`custom-spells/buckler-strike.md`](custom-spells/buckler-strike.md)
- [`custom-spells/divine-storm-echo.md`](custom-spells/divine-storm-echo.md)
- [`custom-spells/permanent-seal-of-righteousness.md`](custom-spells/permanent-seal-of-righteousness.md)
- [`custom-spells/divine-steed.md`](custom-spells/divine-steed.md)
- [`custom-spells/paladin-vengeance-variants.md`](custom-spells/paladin-vengeance-variants.md)
- [`custom-spells/extended-arsenal.md`](custom-spells/extended-arsenal.md)
- [`custom-spells/divine-toll.md`](custom-spells/divine-toll.md)
- [`custom-spells/burning-conflagration.md`](custom-spells/burning-conflagration.md)
- [`custom-spells/chaotic-inferno.md`](custom-spells/chaotic-inferno.md)
- [`custom-spells/demonic-equilibrium.md`](custom-spells/demonic-equilibrium.md)
- [`custom-spells/unquenchable-flames.md`](custom-spells/unquenchable-flames.md)
- [`custom-spells/unyielding-shadows.md`](custom-spells/unyielding-shadows.md)
- [`custom-spells/haunting-affliction.md`](custom-spells/haunting-affliction.md)
- [`custom-spells/permanent-metamorphosis.md`](custom-spells/permanent-metamorphosis.md)
- [`custom-spells/leeching-mixture.md`](custom-spells/leeching-mixture.md)
- [`custom-spells/gloomblade-infusion.md`](custom-spells/gloomblade-infusion.md)
- [`custom-spells/shadow-execution.md`](custom-spells/shadow-execution.md)
- [`custom-spells/crimson-vial.md`](custom-spells/crimson-vial.md)
- [`custom-spells/relentless-finale.md`](custom-spells/relentless-finale.md)
- [`custom-spells/improved-feint.md`](custom-spells/improved-feint.md)
- [`custom-spells/alchemical-guard.md`](custom-spells/alchemical-guard.md)
- [`custom-spells/bladeguard.md`](custom-spells/bladeguard.md)
- [`custom-spells/shaman-spell-pack.md`](custom-spells/shaman-spell-pack.md)
- [`features/priest-ability-pack.md`](features/priest-ability-pack.md)

## Source-of-truth order

When sources disagree, investigate and update the drift in the same change:

1. Executed code in this module and the matching custom AzerothCore branch
2. SQL files and distributed configuration
3. This engineering documentation
4. Root `README.md`
5. External issues, chat, or wiki guidance

Use symbols and repository-relative paths instead of fragile line numbers. Never claim a build, SQL migration, client patch, or in-game scenario passed unless it was actually run.

## Maintenance contract

Documentation is part of every feature, fix, refactor, configuration change, schema change, or custom-spell change. Agents must update it without waiting for a separate request.

- Keep `README.md` concise and current for operators and new contributors.
- Keep architectural relationships in `architecture/`.
- Keep bot-specific contracts in `integrations/`.
- Keep detailed ownership and behavior in `subsystems/` or existing deep dives.
- Keep cross-cutting feature behavior in `features/`.
- Add one dated `history/` record for a completed unit of work.
- Record pending runtime validation as pending, not successful.

See [`development/documentation-workflow.md`](development/documentation-workflow.md) for the completion checklist.

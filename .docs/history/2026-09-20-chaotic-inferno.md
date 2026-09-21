# 2026-09-20: Chaotic Inferno

Status: Partial

## Intent

Add a small Destruction passive that turns every successful Chaos Bolt impact into a full Inferno impact and a temporary autonomous Infernal without replacing the Warlock's normal demon.

## Scope

### Code and data

- `src/mod_apocalipse_warlock_chaotic_inferno.cpp`: adds the Chaos Bolt hit hook, destination summon, Infernal assist AI, and guardian stat initialization hook.
- `src/mod_apocalipse_loader.cpp`: registers Chaotic Inferno scripts.
- `data/sql/db-world/2026_09_20_05_chaotic_inferno.sql`: installs spells 901031 and 901032, creature 900002, summon properties, cloned Infernal support rows, and the Chaos Bolt rank-chain binding.

### Documentation

- `.docs/custom-spells/chaotic-inferno.md`: records the complete mechanical and deployment contract.
- Architecture, operations, catalog, playerbot, README, and history indexes: add the new source, data, ID, and behavior surfaces.

## Contracts changed

- Hooks or registration: Chaos Bolt rank chain 50796 gains an additive `AfterHit` script; one creature AI and one guardian initialization hook are registered.
- Human behavior: every qualifying Chaos Bolt creates an independent 20-second Infernal and stock Inferno impact.
- Bot behavior: identical when the bot has passive 901031; no AI action changes.
- Configuration: None.
- Database or migration: automatic world update adds two spells, one creature and support rows, one summon-properties row, and one script binding.
- Custom spell/client data: client and server spell data must include 901031 and 901032; acquisition references only 901031.
- Deployment or rollback: module rebuild, updater execution, client export, acquisition deployment, startup checks, and focused runtime checks remain required.

## Decisions

- No explicit guardian count cap was selected; the lifetime was reduced from the stock 60 seconds to 20 seconds as the initial balance metric, with Chaos Bolt's cooldown providing the ordinary-play overlap bound.
- Stock Inferno impact damage and stun were explicitly selected.
- Stock Inferno 1122 is not cast because it carries pet-dismissal behavior.
- A cloned creature entry is used so autonomous AI does not alter stock Infernal 89 globally.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Source and data inspection | Static review of custom core summon, guardian, scaling, and Chaos Bolt paths | Passed |
| Build | Parent custom-core build | Failed on duplicate pet-scaling enum names; module declarations removed in favor of `PetDefines.h`; rebuild pending |
| SQL updater | Apply automatic world update | Not run by user instruction |
| Client export | Build and inspect client patch | Not run by user instruction |
| Runtime | Human and bot scenarios from owner page | Not run by user instruction |

## Follow-up

- Build against the deployment core and resolve any compiler mismatch.
- Run collision queries before applying the updater.
- Load-test guardian overlap under cooldown-reset and unusual cooldown-reduction effects.
- Complete startup, client, and in-game verification.

## References

- Custom spell: [`../custom-spells/chaotic-inferno.md`](../custom-spells/chaotic-inferno.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

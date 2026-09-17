# 2026-09-17: Prismatic Barrier

Status: Partial

## Intent

Add an Arcane Mage defensive spell that activates Mana Shield, Ice Barrier, and Blazing Barrier together for twice the normal barrier mana cost and a 45 second cooldown.

## Scope

### Code and data

- `src/mod_apocalipse_mage_prismatic_barrier.cpp`: implements the validated triggered casts for all three barriers.
- `src/mod_apocalipse_loader.cpp`: registers the Prismatic Barrier script while preserving existing registrations.
- `data/sql/db-world/2026_09_17_02_prismatic_barrier.sql`: defines spell 901006, its script binding, and backend name.

### Documentation

- `.docs/custom-spells/prismatic-barrier.md`: records mechanics, dependencies, bot behavior, deployment, failures, and runtime checks.
- Architecture, loader, operations, subsystem, feature, playerbot, and README pages now include Prismatic Barrier.
- `.docs/history/README.md`: indexes this change.

## Contracts changed

- Hooks or registration: Added `spell_apoc_mage_prismatic_barrier` and `AddModApocalipseMagePrismaticBarrierScripts()`.
- Human behavior: A mage with acquisition data can spend 42 percent base mana to activate all three barriers on a 45 second cooldown.
- Bot behavior: Bot-controlled mages receive identical mechanics; acquisition and rotation policy remain external.
- Configuration: None.
- Database or migration: Added automatic world update `2026_09_17_02_prismatic_barrier.sql`.
- Custom spell/client data: Reserved provisional ID 901006 and requires a matching client `Spell.dbc` row.
- Deployment or rollback: Requires Blazing Barrier to exist first, a module build, automatic world update, client patch, restart, and focused in-game validation.

## Decisions

- Used triggered casts of 43020, 43039, and 901001 so each child keeps its existing core or module AuraScript and no child mana cost or cooldown is charged.
- Used 42 percent base mana because the level-80 barriers use a 21 percent base mana baseline.
- Used a self-targeted script effect so the parent spell owns only orchestration while the child spells own all absorb behavior.
- Used provisional ID 901006 because local source, SQL, and documentation already allocate 901001 through 901005 and no local 901006 reference was found.

## Verification

| Check | Command or scenario | Result |
|---|---|---|
| Source and SQL review | Inspect exact symbols, IDs, effect, target, cost, cooldown, and loader call | Passed |
| AzerothCore C++ codestyle | Run the parent core codestyle checker against module `src` | Passed |
| Independent source review | Compare script hooks, triggered-cast flags, child bindings, SQL schema, migration guards, IDs, and docs against the deployed core | Passed with no high-severity findings |
| Repository whitespace review | `git diff --check` | Passed; line-ending conversion warnings remain informational |
| Parent custom-core build | Build `worldserver` with this module and `mod-playerbots` | Not run |
| Worldserver startup | Apply automatic update and inspect script validation | Not run |
| Client patch | Export and inspect the 901006 `Spell.dbc` row | Not run |
| Human and bot runtime | Execute the Prismatic Barrier verification matrix | Not run |

## Follow-up

- Add acquisition through its separately owned trainer, talent, item, or specialization workflow.
- Build against the deployment core, apply the update in a backed-up non-production database, export the client row, and complete the runtime matrix.

## References

- Custom spell: [`../custom-spells/prismatic-barrier.md`](../custom-spells/prismatic-barrier.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

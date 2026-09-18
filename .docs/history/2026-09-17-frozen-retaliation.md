# 2026-09-17: Frozen Retaliation

Status: Partial

## Intent

Add a two-rank Frost Mage passive that can grant Fingers of Frost whenever its owner takes positive combat damage.

## Scope

### Code and data

- `src/mod_apocalipse_mage_frozen_retaliation.cpp`: validates incoming positive damage and grants existing Fingers of Frost aura 44544.
- `src/mod_apocalipse_loader.cpp`: registers Frozen Retaliation after Automatic Ice Lance.
- `data/sql/db-world/2026_09_17_05_frozen_retaliation.sql`: defines ranks 901012 and 901013, their explicit rank relationship, floating-point proc chances, script binding, and backend names.

### Documentation

- `.docs/custom-spells/frozen-retaliation.md`: records rank, damage, proc, Fingers of Frost, acquisition, bot, deployment, rollback, and runtime contracts.
- Architecture, operations, playerbot, root README, subsystem, feature, and history indexes include Frozen Retaliation.

## Contracts changed

- Hooks or registration: Added one AuraScript and `AddModApocalipseMageFrozenRetaliationScripts()`.
- Human behavior: Rank 1 grants Fingers of Frost on 1.5 percent of positive incoming combat damage events; rank 2 uses 3 percent.
- Bot behavior: Bot-controlled mages receive identical mechanics when either passive rank is known.
- Configuration: None.
- Database or migration: Added automatic world update `2026_09_17_05_frozen_retaliation.sql` with two `spell_ranks` rows.
- Custom spell/client data: Reserved provisional IDs 901012 and 901013 and requires matching client `Spell.dbc` rows with rank labels.
- Deployment or rollback: Requires a module build, automatic world update, client patch, restart, and focused in-game validation.

## Decisions

- Used `PROC_FLAG_TAKEN_DAMAGE` without attacker, school, family, class, or phase filters, plus `PROC_ATTR_TRIGGERED_CAN_PROC`, so all positive combat damage represented by the core proc pipeline can qualify.
- Stored 1.5 and 3 percent in separate floating-point `spell_proc.Chance` rows because `spell_dbc.ProcChance` is integer-only.
- Cast existing aura 44544 so the deployment core retains normal Fingers of Frost indicator, refresh, charge, and consumption behavior.
- Used `spell_ranks` with first spell 901012 and a negative -901012 script binding to keep both ranks in one equivalent-rank chain.

## Verification

| Check | Result |
|---|---|
| Deployment core proc, Fingers of Frost, rank-loader, and SQL schema review | Passed |
| Custom spell ID and table-namespace scan | Passed for local repository state; 901012 and 901013 are new spell IDs |
| Parent custom-core build | Not run |
| Worldserver startup and script validation | Not run |
| Automatic world migration | Not run |
| Client patch export and rank labels | Not run |
| Human and bot runtime matrix | Not run |

## Follow-up

- Add acquisition through its separately owned talent, trainer, item, or specialization workflow.
- Build against the deployment core, apply the update in a backed-up non-production database, export both client spell rows with rank labels, and complete the runtime matrix.

## References

- Custom spell: [`../custom-spells/frozen-retaliation.md`](../custom-spells/frozen-retaliation.md)
- Architecture: [`../architecture/overview.md`](../architecture/overview.md)
- Commit or PR: Not created

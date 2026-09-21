# 2026-09-21: Offline database policy

Status: Completed

## Intent

Prevent repository agents from repeatedly attempting unavailable local MySQL access during spell analysis, implementation, ID allocation, and verification.

## Scope

### Agent and repository instructions

- `AGENTS.md`: Added the mandatory offline-only database assumption, prohibited database discovery attempts, and defined the spell ID and spell-data evidence hierarchy.
- `.devin/skills/azerothcore-spell-analysis/SKILL.md`: Required offline evidence and made database execution an operator-owned pending check.
- `.devin/skills/azerothcore-spell-implementation/SKILL.md`: Removed optional live-database discovery, required repository-first ID allocation, and restricted verification to static SQL review.

### Documentation

- `.docs/development/operations.md`: Separated agent static work from authorized operator deployment and database preflight.
- `.docs/development/documentation-workflow.md`: Required offline-only tracing for spell IDs and SQL contracts.
- `README.md`: Clarified that database commands are operator instructions and are never part of agent development or review.

## Contracts changed

- Agent environment: Always assumed to have no local or reachable MySQL service.
- Prohibited agent actions: Database connection attempts, service and port probes, container startup, credential discovery, database MCP access, and SQL execution.
- ID evidence order: Module migrations, custom AzerothCore source and checked-in SQL, then read-only local DBC extraction as the final fallback. Module constants and documentation cross-check migrations, while backend source is limited to export mechanics.
- ID allocation: Use the next repository-free guarded range when global availability cannot be proven offline.
- Database verification: Report live collision checks, updater execution, and database behavior as pending authorized operator work.
- Deployment behavior: Unchanged. Operators still perform backups, preflight queries, migrations, startup validation, and runtime checks in the real deployment environment.

## Decisions

- Kept operator SQL and deployment procedures because they remain valid outside the agent environment.
- Made the prohibition unconditional so configuration files or apparent connection details cannot trigger database probing.
- Kept local DBC extraction read-only and last in the evidence hierarchy because most IDs and contracts should already be derivable from migrations and the custom core.

## Verification

| Check | Result |
|---|---|
| Repository rule review | Offline-only policy added to `AGENTS.md` |
| Spell-analysis agent review | MySQL access prohibited and evidence hierarchy added |
| Spell-implementation agent review | Live-database allocation and execution paths removed |
| Operations review | Agent and operator responsibilities explicitly separated |
| SQL execution | Not run and prohibited by this policy |

## Follow-up

- Future agent or skill instructions must preserve this offline-only assumption.
- Authorized operators remain responsible for live database and deployed-client validation during deployment.

## References

- Operations: [`../development/operations.md`](../development/operations.md)
- Agent rules: [`../../AGENTS.md`](../../AGENTS.md)
- Commit or PR: Not created

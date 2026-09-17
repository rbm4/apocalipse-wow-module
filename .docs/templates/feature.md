# {Feature name}

Status: Proposed | Implemented | Deprecated | Retired

Owners: `{primary source, SQL, and config paths}`

Last validated: YYYY-MM-DD against module `{branch or commit}` and core `{branch or commit}`

## Summary

Describe the player, bot, operator, or developer problem and the current behavior.

## Scope

### Included

- {Behavior included}

### Excluded

- {Related behavior intentionally outside this feature}

## Gameplay and operator contract

Describe visible behavior, eligibility, formulas, exact configuration keys, defaults, messages, and operator actions.

## Human and bot applicability

| Dimension | Humans | Bots | Exceptions |
|---|---|---|---|
| Eligibility | {behavior} | {behavior} | {exceptions} |
| Session requirement | {behavior} | {behavior} | {exceptions} |
| Equipment/talent/combat effect | {behavior} | {behavior} | {exceptions} |

State whether the feature uses `WorldSession::IsBot()` and why.

## Entry points

| Trigger | Source symbol | Preconditions | Result |
|---|---|---|---|
| {startup, hook, gossip, spell, updater} | `{path and symbol}` | {conditions} | {mutation} |

## End-to-end flow

```text
{entry}
  -> {validation}
  -> {state or calculation}
  -> {gameplay mutation}
  -> {cleanup or persistence}
```

Document alternate, denied, error, reset, restart, and cleanup paths.

## Ownership and lifetime

- Process-owned state:
- Per-player state:
- Aura or spell state:
- Persistent state:
- Cache load and invalidation:
- Reentrancy or duplicate protection:

## Configuration

| Exact key | Type | Default | Range | Reload behavior | Effect |
|---|---|---:|---|---|---|
| `{key}` | {type} | {default} | {range} | {behavior} | {effect} |

## Data and migration

| Database/client | Object | Authoritative or derived | Read/write owner | Migration path |
|---|---|---|---|---|
| {database or client} | `{table, DBC, or cache}` | {kind} | `{symbol}` | `{file}` |

Include migration order, restart behavior, rollback limitations, and spell-ID collision handling.

## Dependencies and interactions

- AzerothCore hooks and custom core APIs:
- `mod-playerbots` boundary:
- Other module subsystems:
- Shared hook values and ordering:
- Custom spell server/client graph:

## Invariants

1. {Invariant that must remain true}

## Failure modes and diagnostics

| Failure | Effect | Detection | Recovery |
|---|---|---|---|
| {failure} | {effect} | {log/query/behavior} | {recovery} |

## Performance

- Invocation frequency:
- Database work:
- Population multiplier for bots:
- Expensive calculations or allocations:

## Verification

### Automated and build

- [ ] Formatting/static checks
- [ ] Build against exact custom AzerothCore and `mod-playerbots` branches
- [ ] Focused automated check if available

### Runtime scenarios

| Scenario | Setup | Expected | Observed and date |
|---|---|---|---|
| {scenario} | {human/bot, class, level, map} | {result} | Not run |

Never mark a scenario successful unless it was observed.

## Rollout and rollback

- Operator steps:
- Compatibility requirements:
- Data/client rollback limitations:
- Safe disable path:

## Decisions and rejected alternatives

Record facts that prevent future agents from repeating the same investigation.

## Open questions

- {Question and condition for resolution}

## Change history

| Date | Change | Code or history reference |
|---|---|---|
| YYYY-MM-DD | Initial documentation | `{commit, PR, or ../history file}` |

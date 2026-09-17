# {Subsystem name}

Status: Active | Deprecated | Retired

Primary owners: `{source paths}`

Last validated: YYYY-MM-DD against module `{branch or commit}` and core `{branch or commit}`

## Responsibility

State what this subsystem owns and deliberately does not own.

## Public surface

| Surface | Exact symbol or key | Caller | Result |
|---|---|---|---|
| {hook, function, config, table, spell} | `{name}` | `{caller}` | {result} |

## Ownership and lifetime

| Object or state | Cardinality | Created or loaded | Reset or destroyed | Owner |
|---|---:|---|---|---|
| {state} | {process/per player/per aura} | {point} | {point} | {owner} |

## Control flow

```text
{input}
  -> {owner}
  -> {processing}
  -> {output or cleanup}
```

Include startup, normal operation, failure, reset, and shutdown behavior.

## Hook and execution context

| Flow | Entry point | Frequency | Shared state or value |
|---|---|---|---|
| {flow} | `{symbol}` | {frequency} | {state} |

State any custom-core or playerbot execution-context assumptions. Do not guess a thread when it has not been verified.

## Data flow

| Data | Source of truth | Cache | Readers | Writers | Invalidation |
|---|---|---|---|---|---|
| {data} | {source} | {cache} | {readers} | {writers} | {rule} |

## Human and bot behavior

State whether behavior is identical, suppressed, bypassed, or recalculated for bot sessions. Name the `IsBot()` use site if present.

## Configuration

| Exact key | Default | Consumer | Reload semantics | Interactions |
|---|---:|---|---|---|
| `{key}` | {value} | `{symbol}` | {restart/reload} | {related behavior} |

## Persistence and SQL

| Database/client | Object | Purpose | Migration | Authoritative or derived |
|---|---|---|---|---|
| {database} | `{table or DBC}` | {purpose} | `{path}` | {kind} |

## Dependencies

### Calls into

- {Core or module surface and reason}

### Called by or overlaps with

- {Subsystem and reason}

### Custom AzerothCore contracts

- {Hook or API supplied by the playerbot core}

## Invariants

1. {Invariant}

## Failure modes

| Failure | Effect | Detection | Recovery |
|---|---|---|---|
| {failure} | {effect} | {diagnostic} | {recovery} |

## Extension guide

List the smallest complete steps to add behavior, including loader registration, config, SQL, custom spell data, bot handling, docs, and verification.

## Verification matrix

| Scenario | Setup | Expected | Diagnostic | Status/date |
|---|---|---|---|---|
| {scenario} | {setup} | {result} | {log/query} | Not run |

## Known constraints and technical debt

Record current limitations as facts. Keep speculation labeled and link an issue when available.

## Related documentation

- [`../architecture/overview.md`](../architecture/overview.md)
- {Relevant feature or integration page}

## Change history

| Date | Change | Reference |
|---|---|---|
| YYYY-MM-DD | Initial documentation | `{commit, PR, or history page}` |

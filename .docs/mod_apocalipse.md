# Spec Manager

Status: Implemented, source reviewed; runtime not verified in this review

Owners: `src/mod_apocalipse.cpp`, `data/mod_apocalipse.sql`

Last source review: 2026-09-16

## Purpose

The Spec Manager detects a player's dominant WotLK talent tree and grants the configured signature spells for that tree. It also exposes creature 900001, the Spec Master, for explicit selection or refresh.

The system applies to human players and playerbots. Bot sessions receive the same talents, spells, budget, and persistence but do not receive the Spec Manager chat messages.

## Configuration and constants

| Contract | Value |
|---|---:|
| Spec Master creature entry | `900001` |
| Minimum points for a dominant tree | `1` |
| Hidden talent budget per spec | `6` |
| Talent reset throttle per GUID | `1000 ms` |

The spell list is data-driven through `acore_world.mod_spec_spells`. There is no worldserver config family for this subsystem.

## Startup and cache

`ModApocalipseWorld::OnLoadCustomDatabaseTable()` loads all `(class, spec_index, spell_id)` rows into process memory as `g_specSpells`.

Changes to `mod_spec_spells` do not have a dedicated config reload path. Restart the worldserver or explicitly invoke the matching database-table lifecycle through supported core behavior.

## Reconciliation flow

```text
player login or talent learn
  -> ReconcileSpecFromTalentPoints
     -> synchronize persisted hidden budget with Player bonus points
     -> reject recursive work for the same GUID
     -> read current persisted granted spec
     -> count points in all three talent trees
     -> prefer current spec on an equal-point tie
     -> if no tree has at least one point: clear all managed layers
     -> if stored spec already equals dominant: EnsureSpecLayer repairs missing grants
     -> otherwise: GrantSpec(dominant)
```

For each non-dominant tree, `GrantSpec()` calls `RevokeManagedTalents()` to remove configured talent ranks and their auras, then `RemoveSpecLayer()` to remove signature spells and revoke that tree's hidden budget. It then ensures the dominant layer, persists the selected index, and sends updated talent information.

## Managed spells and talents

Each configured spell follows one of two paths:

- Non-talent spell: learned directly if absent.
- Talent spell: validated against talent DBC data, class mask, tree, rank, current learned rank, free points, and the six-point hidden budget.

Talent grants are sorted by rank and spell ID for deterministic processing. The module uses bonus talent points to fund configured managed talents. Revocation removes configured talent ranks and their auras/spells, then removes the persisted hidden budget for that tree.

The current implementation does not persist individual talent grant rows. `mod_player_spec_talent_grant` is created by SQL but has no C++ reader or writer.

## NPC behavior

Creature 900001 uses script name `ModSpecNPC`.

- `Choose my specialization` displays the three class tree names and calls `GrantSpec()` directly.
- `Refresh my current spec spells` clears the persisted current value and grants it again.
- A later login or talent event reconciles from actual talent points and can replace an NPC-selected tree if another tree is dominant.

Spawn in a controlled environment with:

```text
.npc add 900001
```

The README marks the NPC as currently unused in normal gameplay. Do not remove its schema or script without confirming operator and GM workflows.

## Talent reset

`OnPlayerTalentsReset()` is limited to one execution per GUID per second. When a stored spec exists, it removes that spec's configured spells, revokes managed talents and hidden budgets from all trees, and persists `granted_spec = -1`. When no stored spec exists, it still revokes residual managed talents and hidden budgets but returns without another persistence write.

The in-memory reset timestamp map has process lifetime and no logout cleanup. Its entry count grows with distinct reset GUIDs until restart.

## Database model

| Database | Table | Purpose |
|---|---|---|
| `acore_world` | `mod_spec_spells` | Authoritative class/spec signature spell list |
| `acore_world` | `creature_template` | Spec Master 900001 |
| `acore_characters` | `mod_player_spec` | Last granted spec per character GUID |
| `acore_characters` | `mod_player_spec_talent_budget` | Hidden bonus points granted per character and spec |
| `acore_characters` | `mod_player_spec_talent_grant` | Created but currently unused |

`data/mod_apocalipse.sql` switches to `acore_characters` before creating character-owned tables. Preserve this database boundary.

## Registered scripts

| Script | Base | Hooks |
|---|---|---|
| `ModSpecNPC` | `CreatureScript` | `OnGossipHello`, `OnGossipSelect` |
| `ModSpecPlayer` | `PlayerScript` | `OnPlayerLogin`, `OnPlayerLearnTalents`, `OnPlayerTalentsReset` |
| `ModApocalipseWorld` | `WorldScript` | `OnLoadCustomDatabaseTable`, `OnStartup` |

There is no `OnSave` or `OnAfterConfigLoad` handler in the current source.

## Interactions

- Granted spell IDs can be scaled by `mod_spell_scaling` when matching rows exist.
- Talent changes also trigger Battleground Stamina recalculation.
- Bot AI may observe newly learned spells and talents, but this module does not update playerbot strategies or contexts.
- Blazing Barrier's script binding is also seeded in `data/mod_apocalipse.sql`.

## Failure modes

| Failure | Result | Diagnostic |
|---|---|---|
| Missing `mod_spec_spells` | Cache is empty and no configured spells are granted | `[ModApocalipse] mod_spec_spells is empty or missing` |
| Missing character tables | Spec and hidden budget queries fail | Character database errors |
| Invalid talent spell/class/tree | Row is skipped | Module warning with GUID, spec, and spell |
| Hidden budget exhausted | Remaining grant plan stops | Module warning/info logs |
| Recursive talent hook | Same-GUID nested reconciliation returns | `g_reconcileInProgress` guard |

## Verification

Test human and bot login, first talent point, equal-point tie, tree transition, dual-spec replay, full reset, NPC selection/refresh, restart persistence, missing table behavior, and representative six-point talent plans. No runtime scenarios were run during the 2026-09-16 documentation review.

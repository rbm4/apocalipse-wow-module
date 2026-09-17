# Runtime and data flow

Status: Active

Last source review: 2026-09-16

## Startup

```text
AzerothCore discovers Addapocalipse_wow_moduleScripts()
  -> registers five gameplay systems
  -> database custom-table hooks load spec and scaling caches
  -> startup/config hooks load PvP and battleground settings
  -> spell scripts are available when their SQL bindings and spell rows exist
```

### Startup-owned state

| State | Loaded by | Source | Refresh behavior |
|---|---|---|---|
| `g_specSpells` | `ModApocalipseWorld::OnLoadCustomDatabaseTable` | `acore_world.mod_spec_spells` | Worldserver restart or another invocation of the custom-table hook |
| Four scaling maps | `SpellScalingWorld::OnLoadCustomDatabaseTable` | `acore_world.mod_spell_scaling` | Worldserver restart or another invocation of the custom-table hook |
| PvP percentages | `ModApocalipsePvPWorld` | `Apocalipse.PvP*` config keys | Startup and config reload |
| Battleground settings and aura validity | `BattlegroundStaminaWorldScript` | `Apocalipse.BattlegroundStamina.*` and loaded spell data | Startup and config reload; active auras are not swept immediately |

## Player lifecycle

### Login and talent changes

`ModSpecPlayer` reconciles the dominant talent tree on login and after each talent learn. It persists the granted spec and hidden talent budget in the character database. A per-GUID in-progress set prevents recursive reconciliation. Talent reset processing also has a one-second per-GUID throttle.

`BattlegroundStaminaPlayerScript` reacts to login, level, map, equipment, spec-slot, talent, and resurrection events. It applies or removes assistance according to the player's current battleground state.

Both scripts subscribe to login and talent-related flows. The loader registers Spec Manager first and Battleground Stamina last, but maintainers should not build correctness around undocumented global callback ordering. Each handler must remain safe when the other has already run or has not run yet.

### Battleground lifecycle

```text
non-arena battleground add/map/login recovery
  -> ApplyAssistance
     -> validate eligibility and cached spell readiness
     -> calculate baseline without active stamina/health buffs
     -> calculate minimum whole stamina for configured partial gap coverage
     -> cast or update aura 901002
     -> preserve current-health no-free-heal invariant

battleground leave or unsupported state
  -> RemoveAssistance
```

Human equipment changes are blocked for items that AzerothCore does not consider combat-swappable. Bot sessions bypass this lock. Successful bot or allowed human equipment changes invoke the equip hooks and recalculate assistance.

## Combat value composition

### Direct spell damage

The loader registers spell scaling before PvP balancing. Both hooks mutate the same damage value.

```text
base direct spell damage
  -> SpellScalingUnit for configured DAMAGE spell IDs
  -> ModPvPUnitScript when attacker is a player/player-owned unit and victim is a player
  -> final damage
```

The reductions are multiplicative, but each stage converts to an integer. Registration or dispatch-order changes can therefore alter rounding even when the mathematical factors commute.

### Periodic damage

Configured `PERIODIC` scaling and PvP balancing both mutate periodic tick damage. A missing attacker skips both modules' periodic behavior. Document and test any new periodic hook against both systems.

### Melee, healing, and absorbs

- Melee damage is changed only by PvP balancing.
- Configured direct healing is changed only by spell scaling.
- Configured absorb auras are recalculated and scaled in `SpellScalingUnit::OnAuraApply`.
- Blazing Barrier first derives its absorb from base amount plus fire spell power in its `AuraScript`; spell 901001 is also configured as an `ABSORB` scaling entry.

## Data boundaries

| Database | Objects | Access |
|---|---|---|
| `acore_world` | `mod_spec_spells`, `mod_spell_scaling`, creature 900001, `spell_dbc`, `spell_script_names`, `spell_custom_attr`, `wotlk_spells` | `WorldDatabase` or core spell loaders |
| `acore_characters` | `mod_player_spec`, `mod_player_spec_talent_budget`, currently unused `mod_player_spec_talent_grant` | `CharacterDatabase` |

`data/mod_apocalipse.sql` explicitly switches from `acore_world` to `acore_characters` before creating the per-character tables. Keep that boundary intact.

## Custom spell graph

| Spell | Server definition | Script binding | Scaling | Client requirement |
|---|---|---|---|---|
| 901001 Blazing Barrier | Manual `data/2026_09_16_01_blazing_barrier.sql` | `spell_apoc_mage_blazing_barrier` from `data/mod_apocalipse.sql` or the manual migration | `ABSORB` row in `mod_spell_scaling` | Matching client `Spell.dbc` and patch |
| 901002 Battleground Stamina Assistance | Automatic module world update under `data/sql/db-world/` | No `spell_script_names` binding | Not in spell scaling | Matching client `Spell.dbc` and patch |

A server-only row can provide mechanics but not complete client presentation. A client-only row cannot provide server mechanics.

## Failure and recovery paths

| Failure | Result | Diagnostic or recovery |
|---|---|---|
| Missing custom table | Related cache remains empty | Module warning log; apply manual schema and restart |
| Invalid spell 901002 contract | Battleground assistance is disabled | `[BattlegroundStamina]` error at config load |
| Missing spell 901001 or binding | Blazing Barrier cannot load or validate correctly | Check `spell_dbc` and `spell_script_names` before startup |
| Config reload during active battleground | New values are cached but existing auras are not immediately swept | Re-enter battleground, trigger an application hook, or restart according to operator plan |
| Bot lacks a valid session | Bot exception is not detected | Fix bot lifecycle; do not add heuristic fallback |
| Custom spell ID collision | Guarded migration should fail instead of overwriting another spell | Allocate a new ID and update code, SQL, config, scaling data, and docs together |

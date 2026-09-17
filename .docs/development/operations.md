# Build, configuration, database, and release operations

Last source review: 2026-09-17

## Supported context

This repository is not standalone. Build it under `modules/apocalipse-wow-module` in the custom AzerothCore WotLK branch required by the deployed `mod-playerbots` version. `CMakeLists.txt` is intentionally minimal because the parent module build collects sources under `src/`.

No complete AzerothCore checkout is present in this workspace, so the commands below were not run during this documentation review.

## Install and build

1. Place or link this repository at `<azerothcore>/modules/apocalipse-wow-module`.
2. Configure the parent core with modules enabled.
3. Build `worldserver` through the parent core's supported platform workflow.

Typical Linux configuration:

```bash
cmake .. -DMODULES=static
cmake --build . --parallel
```

Dynamic modules may use `-DMODULES=dynamic` when supported by the target core. A successful standalone C++ compile is not sufficient; verify against the exact custom core and `mod-playerbots` branch used in deployment.

## Configuration

### PvP balancing

The following keys are read directly from the worldserver configuration and default in code:

| Key | Default | Reload behavior |
|---|---:|---|
| `Apocalipse.PvPDamageReductionPct` | `15.0` | Reloaded on config reload |
| `Apocalipse.PvPBracketResilience.1019` | `8.0` | Reloaded on config reload |
| `Apocalipse.PvPBracketResilience.2029` | `10.0` | Reloaded on config reload |
| `Apocalipse.PvPBracketResilience.3039` | `12.0` | Reloaded on config reload |
| `Apocalipse.PvPBracketResilience.4049` | `14.0` | Reloaded on config reload |
| `Apocalipse.PvPBracketResilience.5059` | `16.0` | Reloaded on config reload |
| `Apocalipse.PvPBracketResilience.6069` | `18.0` | Reloaded on config reload |
| `Apocalipse.PvPBracketResilience.7079` | `20.0` | Reloaded on config reload |

No dedicated PvP `.conf.dist` is currently present. Operators must ensure these keys exist in the effective worldserver configuration if they do not want code defaults.

### Battleground stamina

`conf/BattlegroundStamina.conf.dist` defines enablement, human gear locking, aura ID, gap coverage, maximum stamina, and 70 class/bracket thresholds.

Modern AzerothCore parent CMake discovers each enabled module's `conf/*.conf.dist` files without an `AC_ADD_CONFIG_FILE` call, copies them without the `.dist` suffix, and adds them to the module config list consumed by `sConfigMgr`. Confirm CMake reports `BattlegroundStamina.conf` and that the generated/deployed module config exists in the target custom-core revision.

Important drift: the 10-19 threshold values in `conf/BattlegroundStamina.conf.dist` are higher than the compiled fallback values in `BattlegroundStamina.cpp`. Until synchronized in code, a missing or stale deployed module config changes live behavior.

A config reload updates cached values and revalidates aura 901002. It does not sweep every player already inside a battleground. Re-entry, another application hook, or restart is needed for deterministic reconciliation.

## Database ownership

| File | Database | Mode | Purpose |
|---|---|---|---|
| `data/mod_apocalipse.sql` | `acore_world`, then `acore_characters` | Manual, one-time baseline | Spec table and seeds, NPC 900001, spell script binding, per-character spec/budget tables |
| `data/mod_spell_scaling.sql` | `acore_world` | Manual, one-time baseline | Scaling table and seed rows |
| `data/2026_09_16_01_blazing_barrier.sql` | `acore_world` | Manual while worldserver is stopped | Spell 901001, binding, scaling row, and backend name cache |
| `data/sql/db-world/2026_09_16_00_battleground_stamina_spell.sql` | `acore_world` | AzerothCore module updater; idempotent for its recognized spell row | Spell 901002, equipped-item requirement repair, custom non-save attribute, and backend name cache |
| `data/sql/db-world/2026_09_17_00_pyroclastic_chain_reaction.sql` | `acore_world` | AzerothCore module updater; guarded for its recognized passive row | Spell 901003, Pyroblast and Living Bomb explosion bindings, and backend name cache |

`data/mod_apocalipse.sql` correctly issues `USE acore_characters` before creating `mod_player_spec`, `mod_player_spec_talent_budget`, and `mod_player_spec_talent_grant`. Do not remove that switch.

The `mod_player_spec_talent_grant` table is currently created but not used by the C++ implementation. Treat it as reserved/dead schema until code establishes an owner.

## First deployment sequence

1. Stop `worldserver`.
2. Back up affected databases according to the server's normal procedure.
3. Collision-check custom spell IDs 901001, 901002, and 901003 in live server tables and the selected client `Spell.dbc`.
4. Apply `data/mod_apocalipse.sql` and `data/mod_spell_scaling.sql` to their named databases.
5. Apply the manual Blazing Barrier migration if spell 901001 is being deployed.
6. Build and install the module under the custom core.
7. Ensure world database updates are enabled, then start `worldserver` so the 901002 and 901003 module updates can run.
8. Confirm both updater records and module startup logs.
9. Deploy matching client `Spell.dbc` data and patch artifacts for custom spells, plus the separate talent data that teaches 901003.
10. Run focused human and bot in-game scenarios.

Do not manually import the 901002 updater file on a first deployment if the normal module updater will apply it. Do not execute any production SQL without explicit operator approval.

### Repairing an existing 901002 installation

The original 901002 insert omitted `EquippedItemClass`, so the world table default stored `0`. Because AzerothCore may retain the updater filename as already applied, replacing the repository file does not guarantee another automatic execution.

For an existing module-owned 901002 row, stop worldserver, take the normal world-database backup, and execute `data/sql/db-world/2026_09_16_00_battleground_stamina_spell.sql` manually against `acore_world`. The file recognizes ownership from the spell name and stamina-effect signature, repairs the equipped-item fields, and can be rerun without duplicate-key failure. A non-matching collision still fails before related rows are changed.

Restart worldserver so the corrected `spell_dbc` row is loaded, then verify:

```sql
SELECT `ID`, `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`
FROM `spell_dbc`
WHERE `ID` = 901002;
```

The expected equipped-item values are `-1`, `0`, and `0`. Confirm the `HasItemFitToSpellRequirements` error no longer appears when assistance is applied.

## Custom spell preflight

Before first deployment, verify all custom IDs are unallocated in:

```sql
SELECT `ID` FROM `spell_dbc` WHERE `ID` IN (901001, 901002, 901003);
SELECT `ID` FROM `wotlk_spells_full` WHERE `ID` IN (901001, 901002, 901003);
SELECT `ID` FROM `wotlk_spells` WHERE `ID` IN (901001, 901002, 901003);
```

Also inspect the actual client/server base `Spell.dbc`; it is not represented fully by these SQL queries.

## Verification

### Static and build

- Inspect `git diff` and exact config/SQL string keys.
- Build the parent custom AzerothCore `worldserver` with this module and `mod-playerbots` enabled.
- Check startup logs for all five registration/load paths.
- Confirm no custom table or spell validation warnings.

### Runtime

At minimum test:

- Human and bot login with each representative spec transition.
- Talent reset and dual-spec behavior.
- Configured direct, periodic, healing, and absorb scaling below and at level 80.
- PvP direct, periodic, melee, pet-owned, low-bracket, and level-80 damage.
- Blazing Barrier cast, weaker/stronger recast, absorb, and mage talent procs.
- Pyroclastic Chain Reaction explosion rank speed validation, passive gating, 20 percent proc, source refresh, rank preservation, normal explosion isolation, and zero/one/two-target spread.
- Battleground stamina below/above threshold, buff isolation, gear swaps, bot auto-gearing, death, reconnect, and exit cleanup.

Record observed results in the relevant feature page and history entry. If a scenario was not run, mark it `Not run`.

## Deployment script warning

`deploy.ps1` runs `git add .`, creates a generic commit, and pushes with no build, branch, diff, or safety checks. It is not a production deployment workflow. Agents must not run it unless the user explicitly asks for those exact git side effects after reviewing what will be staged.

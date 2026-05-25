# mod_apocalipse.cpp

## Purpose

Implements the **Spec Manager** system for Apocalipse WoW. It allows players to select a specialisation through an in-game NPC and automatically grants or revokes the signature spells of that specialisation as the player's talent investment changes.

---

## How it works

### NPC interaction

A custom creature (entry `900001`, named *Spec Master*) opens a gossip menu listing all specs available to the player's class. Selecting one immediately triggers a spec reconciliation for that player.

Spawn the NPC in-world with: `.npc add 900001`

### Spec detection

On each relevant event (login, save, talent reset, explicit NPC selection) the module reads the player's current talent point distribution across the three WotLK talent trees. The tree with the most invested points — provided it meets the `MIN_POINTS_FOR_SPEC` threshold — is treated as the active spec.

### Spell grant / revoke

1. The module loads the full spell list for the new spec from the in-memory cache (`g_specSpells`), originally read from `mod_spec_spells` (`acore_world`).
2. Spells belonging to the *previous* spec are removed (`removeSpell`).
3. Spells belonging to the *new* spec are learned (`learnSpell`).
4. For spells that are also talents, `GrantManagedTalent` is used instead, which spends the player's available talent points correctly and validates class-mask compatibility before granting.

### Hidden talent budget

Each spec is allowed up to `HIDDEN_TALENT_BUDGET_PER_SPEC` (6) talent-point-based spells granted silently, so core signature talents are learned without consuming the player's own points.

### Anti-spam protection

A per-player timestamp (`g_lastTalentsResetMs`) ensures `OnPlayerTalentsReset` cannot trigger a full reconciliation more frequently than once every `TALENTS_RESET_MIN_INTERVAL_MS` (1 000 ms).

---

## Database tables

### `acore_world.mod_spec_spells`

Stores the spell list per class/spec. Editable from the admin panel without recompiling.

| Column | Description |
|---|---|
| `class` | WoW class ID (1=Warrior, 2=Paladin, …, 11=Druid) |
| `spec_index` | 0 = leftmost tree, 1 = middle, 2 = rightmost |
| `spell_id` | Spell to grant when this spec is active |
| `description` | Human-readable label (optional) |

### `acore_characters.mod_player_spec`

Persists the last known spec index per player GUID so the module can detect spec changes across sessions.

---

## Registered scripts

| Script class | Base class | Hook used |
|---|---|---|
| `ModSpecNPC` | `CreatureScript` | `OnGossipHello`, `OnGossipSelect` |
| `ModApocalipsePlayerScript` | `PlayerScript` | `OnLogin`, `OnSave`, `OnPlayerTalentsReset` |
| `ModApocalipseWorldScript` | `WorldScript` | `OnAfterConfigLoad`, `OnLoadCustomDatabaseTable` |

---

## Constants

| Constant | Value | Meaning |
|---|---|---|
| `NPC_SPEC_SELECTOR` | `900001` | Creature entry for the spec-selector NPC |
| `MIN_POINTS_FOR_SPEC` | `1` | Minimum talent points in a tree to consider it dominant |
| `HIDDEN_TALENT_BUDGET_PER_SPEC` | `6` | Max talent-backed spells silently granted per spec |
| `TALENTS_RESET_MIN_INTERVAL_MS` | `1000` | Debounce window for `OnPlayerTalentsReset` (ms) |

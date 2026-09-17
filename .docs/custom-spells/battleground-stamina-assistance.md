# Battleground Stamina Assistance

Status: Implemented in source, build and runtime not verified

Owners: `src/battleground_stamina/`, `conf/BattlegroundStamina.conf.dist`, `data/sql/db-world/2026_09_16_00_battleground_stamina_spell.sql`

Last source review: 2026-09-16

## Intent

The feature gives undergeared level 10 through 79 characters additional true stamina in non-arena battlegrounds. It covers only part of the gap to a class/bracket health threshold so better equipment continues to improve final assisted health.

Human players cannot change most equipment during the battleground stay. Bot sessions bypass that lock so `mod-playerbots` auto-gearing continues to work. Both humans and bots receive the same stamina calculation.

## Eligibility

Assistance requires all of these:

- Feature enabled.
- Player is in a `Battleground` that reports `isBattleground()` and not `isArena()`.
- Level maps to brackets 10-19 through 70-79.
- The player's class/bracket threshold is non-zero.
- The validated custom aura exists and is ready.
- Calculated unbuffed baseline health is below the threshold.

Level 80 or above, arenas, and threshold-zero combinations receive no aura.

## Calculation

```text
missing health = max(threshold - unbuffed baseline health, 0)
desired bonus health = ceil(missing health * gap coverage percent / 100)
bonus stamina = minimum whole stamina that supplies desired bonus health
```

Gap coverage is clamped to 0 through 99 percent. The default is 50 percent. This prevents assistance from normalizing all characters to one health value.

For a 10,000 threshold at 50 percent coverage, baselines of 4,000, 6,000, 8,000, and 10,000 target approximately 7,000, 8,000, 9,000, and 10,000 assisted health.

The stamina conversion preserves WotLK's first-20 rule: the first 20 stamina gives one health each, and later stamina gives ten health each before passive multipliers.

A binary search from zero through `MaxBonusStamina` finds the minimum whole stamina amount that reaches the desired health contribution.

## Unbuffed baseline

`CalculateUnbuffedBaseline()` reconstructs health from native character values while excluding active temporary stamina and health buffs.

Included:

- Class/level create health and stamina.
- Base and equipment values.
- Direct enchant-style totals.
- Passive flat and percentage stamina/health effects.

Excluded:

- Active flat stamina buffs.
- Active flat health buffs.
- Active stamina percentage buffs.
- Active health percentage buffs.
- The existing assistance aura.

This logic is sensitive to AzerothCore stat-modifier semantics. Changes to aura filtering require tests with Fortitude, Kings, food, talents, forms, enchants, and temporary maximum-health cooldowns.

## Lifecycle

`ApplyAssistance()` is invoked on:

- Player login.
- Player level change.
- Player map change.
- Equipment equip and unequip.
- Active spec slot change.
- Talent learn.
- Player resurrection.
- Non-arena battleground add-player.

`RemoveAssistance()` is invoked on explicit battleground leave and whenever an application finds the player unsupported or the aura unready.

The aura is updated in place with `ChangeAmount()` or cast through `CastCustomSpell()`. Application stores current health first and restores it if the maximum-health increase raised current health. Assistance must never act as a free heal.

## Equipment lock and bots

When enabled, can-equip and can-unequip hooks block human changes to equipment that `ItemTemplate::CanChangeEquipStateInCombat()` does not permit. Database loading is not blocked, and AzerothCore's combat-swappable item group remains allowed.

A session for which `WorldSession::IsBot()` is true bypasses the lock. Bot equipment changes still invoke post-equip hooks and recalculate assistance.

Do not broaden this exemption to humans and do not disable the assistance aura for bots.

## Configuration

`conf/BattlegroundStamina.conf.dist` defines:

| Key family | Default/meaning |
|---|---|
| `Apocalipse.BattlegroundStamina.Enable` | `1` |
| `Apocalipse.BattlegroundStamina.LockGear` | `1` |
| `Apocalipse.BattlegroundStamina.AuraSpellId` | `901002` |
| `Apocalipse.BattlegroundStamina.GapCoveragePct` | `50.0`, clamped 0-99 |
| `Apocalipse.BattlegroundStamina.MaxBonusStamina` | `5000`, minimum 1 |
| `Apocalipse.BattlegroundStamina.HealthThreshold.<bracket>.<class>` | 70 class/bracket thresholds; zero disables the combination |

Known drift: distributed 10-19 thresholds are higher than the compiled fallback values in `BattlegroundStamina.cpp`. If the config file is not loaded, the code fallbacks apply. Synchronize both surfaces in a dedicated behavior change.

Modern AzerothCore module CMake discovers `conf/*.conf.dist` automatically, copies it as `BattlegroundStamina.conf`, and includes module configs in `sConfigMgr`. Confirm the file appears in the target custom core's CMake module config list and deployed config directory.

Config reload updates cached settings and aura validation but does not immediately iterate active battleground players. Use re-entry, another application event, or restart for deterministic reconciliation.

## Custom spell 901002

The module world update defines spell 901002. The runtime validator requires:

- Effect 0 is `SPELL_EFFECT_APPLY_AURA`.
- Aura type is `SPELL_AURA_MOD_STAT` with `STAT_STAMINA`.
- Target is `TARGET_UNIT_CASTER`.
- Spell is positive, non-passive, generic family, infinite duration, and non-dispellable.
- Effect amount has no random die other than 0 or 1, no per-level scaling, and no combo-point scaling.
- `SPELL_ATTR0_NO_AURA_CANCEL` is set.
- `SPELL_ATTR3_ALLOW_AURA_WHILE_DEAD` is set.
- `SPELL_ATTR0_CU_AURA_CANNOT_BE_SAVED` is set through `spell_custom_attr`.

Separately, the server and client spell contract sets `EquippedItemClass` to `-1`, with both equipped-item masks set to `0`, because the aura has no equipment requirement. The runtime validator does not currently check these three fields.

The world `spell_dbc` row currently uses `Name_Lang_enUS = 'Battleground inspiration'`. The backend `wotlk_spells` cache uses `Battleground Stamina Assistance`. Keep server and client presentation deliberately synchronized if renaming.

No `spell_script_names` binding is required because the lifecycle and dynamic amount are implemented through player and battleground hooks.

## Server and client deployment

`data/sql/db-world/2026_09_16_00_battleground_stamina_spell.sql` is an automatic module world update. It runs at worldserver startup only when module update discovery and world database updates are enabled. Compiling alone does not apply it.

Before first deployment:

```sql
SELECT `ID` FROM `spell_dbc` WHERE `ID` = 901002;
SELECT `ID` FROM `wotlk_spells_full` WHERE `ID` = 901002;
SELECT `ID` FROM `wotlk_spells` WHERE `ID` = 901002;
```

All three must be clear, and the actual selected base client/server `Spell.dbc` must be checked separately. On first execution, the SQL collision guard intentionally fails before mutation if any world table already uses the ID. On later executions, an existing row is accepted as module-owned only when its name and stamina-effect signature match this spell.

The update is idempotent for a module-owned 901002 row. Re-execution repairs `EquippedItemClass` to `-1`, resets both equipped-item masks to `0`, preserves other custom-attribute bits, and resynchronizes the backend name. This repairs installations created by the earlier definition that inherited the table default `EquippedItemClass = 0` and caused `HasItemFitToSpellRequirements` errors.

After the update:

1. Confirm the world `updates` table records the file.
2. Inspect `spell_dbc`, `spell_custom_attr`, and `wotlk_spells`.
3. Confirm `[BattlegroundStamina]` startup validation has no error.
4. Export and distribute a client `Spell.dbc` row through the existing patch flow.
5. Confirm the installed config does not override `AuraSpellId` with zero.

A server-only row cannot provide correct client icon/name/tooltip presentation. A client-only row cannot provide the server aura mechanic.

## Failure modes

| Failure | Result | Recovery |
|---|---|---|
| Aura ID zero or missing | Assistance disabled; gear lock can still be enabled because it depends on feature config, not `AuraReady` | Install/allocate spell and correct config |
| Aura contract invalid | Assistance disabled with detailed module error | Fix server spell row and restart/reload config |
| `EquippedItemClass` is `0` | Cast checks log `HasItemFitToSpellRequirements` errors and can reject aura application | Re-execute the module-owned 901002 updater and restart worldserver |
| Config not installed | Compiled defaults apply, including different 10-19 values | Merge `.conf.dist` into effective config |
| Aura survives an unexpected path | Player may retain assistance outside battleground until another cleanup hook | Reproduce map/leave path and add focused cleanup coverage |
| Client patch missing | Server mechanic may work with broken presentation | Deploy matching client data |
| Max stamina cap too low | Search returns cap without necessarily reaching target bonus | Tune cap and test high-threshold cases |

## Runtime validation matrix

- Below-threshold and above-threshold characters in every bracket.
- Same class/bracket with different gear; better gear must retain higher assisted health.
- Fortitude, Kings, food, forms, talents, enchants, and maximum-health cooldowns.
- Human armor/accessory lock and allowed weapon/offhand/projectile/relic swaps.
- Bot auto-gearing and recalculation while in battleground.
- Talent and active-spec changes.
- Death, resurrection, disconnect, reconnect, late join, normal leave, deserter leave, and server restart.
- Aura application, update, and removal without increasing current health.
- Arena and level-80 exclusion.

No runtime cases, live database migration, client patch build, or full custom-core build were performed during the 2026-09-16 documentation review.

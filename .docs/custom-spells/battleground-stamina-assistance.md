# Battleground Stamina Assistance

## Intent and state

- Gives undergeared level 10-79 characters additional true stamina in
  battlegrounds, never arenas.
- Uses a diminishing grant rather than normalizing everyone to identical
  health: `bonus health = gap coverage * max(threshold - baseline health, 0)`.
- Better equipment always improves final health because gap coverage is
  clamped below 100%.
- Module behavior and configuration are implemented locally.
- Spell `901002` is defined in a module world update and is the configured
  default. It was absent from the local base Spell.dbc and local module
  references, but live database and deployed client DBC availability remain
  unverified. The SQL has not been applied here, and no client artifact has
  been built or distributed for this spell.
- Runtime validation has not been performed.

## Gameplay contract

- Eligible levels: 10-79, grouped into 10-19 through 70-79 brackets.
- Each class/bracket combination has an independent configurable health
  threshold. A zero threshold disables that combination.
- Default gap coverage is 50% and is configurable from 0-99%.
- At a 10,000-health threshold and 50% coverage, unbuffed baselines of 4,000,
  6,000, 8,000 and 10,000 produce assisted targets of approximately 7,000,
  8,000, 9,000 and 10,000 respectively.
- Baseline health excludes active aura-based flat stamina, flat health,
  stamina percentages and health percentages. It retains native class/level
  values, equipment stats, direct enchant contributions, and passive
  class/talent modifiers.
- The grant is converted back into the minimum whole stamina amount that
  supplies the intended unbuffed bonus health, including the native first-20
  stamina rule.
- Human players cannot equip or unequip non-combat-swappable equipment for the
  entire non-arena battleground stay. The core's native combat-swappable group
  (weapons, offhands, projectiles, relics) remains usable, subject to its usual
  combat and weapon-swap rules. Playerbot sessions are exempt from the lock.
  Loading equipment from the character database is not blocked. Allowed
  equipment changes (including human weapon swaps and bot auto-gearing) and
  talent/spec changes trigger assistance recalculation.
- The aura is applied on battleground entry and reconstructed on resurrection,
  level change, login or map recovery. It is removed on battleground exit.
- Applying or changing assistance never raises current health. Lowering or
  removing maximum health may clamp current health normally.

## Spell graph and integration

| ID / allocation state | Role | Learned / visible | Effects | Owner / lifecycle |
| --- | --- | --- | --- | --- |
| `901002`; local definition prepared | Battleground stamina aura | Not learned; visible buff | Effect 0 applies `SPELL_AURA_MOD_STAT`, `STAT_STAMINA` | Self-cast by battleground module; removed on exit |

Required spell properties:

- Effect 0: `SPELL_EFFECT_APPLY_AURA` / `SPELL_AURA_MOD_STAT` /
  `STAT_STAMINA`.
- Positive, non-passive, infinite-duration aura targeting
  `TARGET_UNIT_CASTER`, with no resource, cooldown, proc, family or spell-group
  interaction.
- Effect die sides is 0 or 1, and real-points-per-level and
  points-per-combo-point are zero, so the custom server amount remains exact.
- `Dispel = DISPEL_NONE`.
- `SPELL_ATTR0_NO_AURA_CANCEL`.
- `SPELL_ATTR3_ALLOW_AURA_WHILE_DEAD`.
- World `spell_custom_attr` includes
  `SPELL_ATTR0_CU_AURA_CANNOT_BE_SAVED`.
- Generic client wording; it must not display a fixed `$s1` because the server
  supplies a different amount for each character.

The battleground lifecycle is code-only and does not need a
`spell_script_names` binding. The world record and custom attribute bit are
defined in `data/sql/db-world/2026_09_16_00_battleground_stamina_spell.sql`.
The visible aura still needs a matching client Spell.dbc record through the
existing backend/export/release flow.

### Spell definition and release

1. Before deploying, verify ID `901002` is free in live `spell_dbc`, imported
   `wotlk_spells_full`, and the actual selected client/server base Spell.dbc.
   The local base DBC has no such ID. An occupied ID in live `spell_dbc`,
   backend `wotlk_spells_full`, or its `wotlk_spells` name cache makes the
   migration fail rather than overwrite
   another spell. This guard requires `wotlk_spells_full` to exist.
2. The migration sets `SpellIconID = 685` (Fortitude icon),
   `Name_Lang_enUS = Battleground Stamina Assistance`, and generic
   descriptions. Do not put a fixed `$s1` value in the text, since the server
   supplies a per-character amount.
3. Set `Effect_1 = 6` (apply aura), `EffectAura_1 = 29` (modify stat),
   `EffectMiscValue_1 = 2` (Stamina), `ImplicitTargetA_1 = 1` (caster),
   `EffectBasePoints_1 = 1`, `EffectDieSides_1 = 0`,
   `EffectRealPointsPerLevel_1 = 0`, and
   `EffectPointsPerCombo_1 = 0`. Leave effects 2 and 3 unused. The effect's
   stored +1 base point is only a positive placeholder; the module overrides it.
   This must be a real stamina aura, not `SPELL_AURA_DUMMY`.
4. Set `DispelType = 0`, `SpellClassSet = 0`, no cost/cooldown/proc or learned
   acquisition, and choose a `DurationIndex` whose loaded duration is -1.
   In the attribute editor set `Attributes` bit `0x80000000` (cannot cancel)
   and `AttributesEx3` bit `0x00100000` (persists through death). Keep the
   spell non-passive and positive.
5. The migration also sets world `spell_custom_attr.attributes` bit
   `0x01000000` (`SPELL_ATTR0_CU_AURA_CANNOT_BE_SAVED`) without erasing any
   existing custom bits. The character should never persist this
   battleground-only aura in `character_aura`. It also syncs the
   `wotlk_spells` name cache used by the backend spell picker.
6. Ensure the module updater applies the world SQL at server startup, then
   export/deploy a client Spell.dbc containing the same row through the
   existing backend/patch flow. The module defaults
   `Apocalipse.BattlegroundStamina.AuraSpellId` to `901002`; any installed
   config still setting it to `0` must be updated. Confirm the startup
   validator accepts the spell before testing in a BG.

The backend's `spell_dbc` row is a full server-side spell override, not an
incremental patch. A server-only row cannot supply the name/icon/tooltip to
the client. Conversely, a client-only DBC entry will not give the server a
working stamina effect. The code sets the dynamic stamina amount and the
combat/map lifecycle; the spell record supplies both the real aura mechanic
and its visible presentation.

## Configuration

`conf/BattlegroundStamina.conf.dist` owns:

- Feature enable and human battleground non-weapon gear lock.
- Allocated aura spell ID.
- Gap coverage percentage and maximum stamina safety cap.
- Seventy class/bracket health thresholds.

Configuration reload updates values for future applications. Restart or a
new battleground entry is the intended way to reconcile already-active auras
after tuning.

## Validation and release

Production preflight (read-only, on the live world database):

```sql
SELECT `ID` FROM `spell_dbc` WHERE `ID` = 901002;
SELECT `ID` FROM `wotlk_spells_full` WHERE `ID` = 901002;
SELECT `ID` FROM `wotlk_spells` WHERE `ID` = 901002;
```

Both queries must return no rows before the first deployment. Check the base
Spell.dbc selected by the live patch/export process separately. The first
worldserver restart with the compiled module/source and world updates enabled
applies the SQL before DBC/spell loading. Confirm `updates` records the file,
then inspect `spell_dbc`, `spell_custom_attr`, `wotlk_spells`, startup validator
logs, and a matching client MPQ. A running worldserver does not hot-load this
new spell merely because the source was compiled or SQL was inserted.

Pending runtime cases:

- One below-threshold and one above-threshold character for every bracket.
- Two characters of the same class with different gear; the better-geared
  character must retain higher assisted health.
- Fortitude, Kings, stamina food and temporary maximum-health cooldowns must
  not change the baseline-selected grant.
- Human armor/trinket/ring equip, unequip and equipment-manager swaps must fail
  from preparation through battleground exit; weapon/offhand/projectile/relic
  swaps must follow native rules and work, and recompute assistance. Bot
  equipment changes must remain available and recompute assistance.
- Death/resurrection, disconnect/reconnect, late join, normal exit, deserter
  exit and server restart must not leak the aura outside the battleground.
- Aura application and reconstruction must not increase current health.

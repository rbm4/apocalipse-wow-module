# Battleground Stamina Assistance

## Intent and state

- Gives undergeared level 10-79 characters additional true stamina in
  battlegrounds, never arenas.
- Uses a diminishing grant rather than normalizing everyone to identical
  health: `bonus health = gap coverage * max(threshold - baseline health, 0)`.
- Better equipment always improves final health because gap coverage is
  clamped below 100%.
- Module behavior and configuration are implemented locally.
- The aura spell is not allocated or created yet. Runtime spell/client
  integration remains pending and `AuraSpellId` therefore defaults to `0`.
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
- Gear equip, unequip and swap operations are rejected for the entire
  non-arena battleground stay. Loading equipment from the character database
  is not blocked.
- The aura is applied on battleground entry and reconstructed on resurrection,
  level change, login or map recovery. It is removed on battleground exit.
- Applying or changing assistance never raises current health. Lowering or
  removing maximum health may clamp current health normally.

## Spell graph and integration

| ID / allocation state | Role | Learned / visible | Effects | Owner / lifecycle |
| --- | --- | --- | --- | --- |
| Configured `AuraSpellId`; unallocated | Battleground stamina aura | Not learned; visible buff | Effect 0 applies `SPELL_AURA_MOD_STAT`, `STAT_STAMINA` | Self-cast by battleground module; removed on exit |

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
`spell_script_names` binding. The visible aura still needs matching server and
client Spell.dbc records through the existing backend/export/release flow.

## Configuration

`conf/BattlegroundStamina.conf.dist` owns:

- Feature enable and complete battleground gear lock.
- Allocated aura spell ID.
- Gap coverage percentage and maximum stamina safety cap.
- Seventy class/bracket health thresholds.

Configuration reload updates values for future applications. Restart or a
new battleground entry is the intended way to reconcile already-active auras
after tuning.

## Validation and release

Pending runtime cases:

- One below-threshold and one above-threshold character for every bracket.
- Two characters of the same class with different gear; the better-geared
  character must retain higher assisted health.
- Fortitude, Kings, stamina food and temporary maximum-health cooldowns must
  not change the baseline-selected grant.
- Equip, unequip, weapon swap and equipment-manager swaps must fail from
  preparation through battleground exit, but work immediately afterward.
- Death/resurrection, disconnect/reconnect, late join, normal exit, deserter
  exit and server restart must not leak the aura outside the battleground.
- Aura application and reconstruction must not increase current health.

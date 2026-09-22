SET @frozen_resolve_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901052
      AND `Name_Lang_enUS` = 'Frozen Resolve'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 15
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 226
      AND `EffectAuraPeriod_1` = 2000
      AND `SpellIconID` = 2720
);

SET @frozen_resolve_stack_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901053
      AND `Name_Lang_enUS` = 'Frozen Resolve'
      AND `Attributes` = 0
      AND `AttributesEx4` = 0x00000040
      AND `DurationIndex` = 31
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 10
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 15
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 1
      AND `EffectMiscValue_1` = 1
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 101
      AND `Effect_2` = 6
      AND `EffectDieSides_2` = 1
      AND `EffectBasePoints_2` = -3
      AND `EffectMiscValue_2` = 127
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 87
      AND `SpellIconID` = 2720
);

SET @frozen_resolve_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901052 AND @frozen_resolve_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901052 AND @frozen_resolve_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901052 AND @frozen_resolve_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901053 AND @frozen_resolve_stack_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901053 AND @frozen_resolve_stack_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901053 AND @frozen_resolve_stack_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `EffectAuraPeriod_1`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901052, 0x00000040, 21, 1, 1,
    1, 15, -1,
    0, 0, 6,
    0, 0, 1,
    226, 2000, 2720,
    'Frozen Resolve',
    'While in combat, gain a stack of Frozen Resolve every 2 sec. Each stack increases armor by 2% and reduces all damage taken by 2% for 8 sec. Stacks up to 10 times.',
    'Gain Frozen Resolve while in combat.'
FROM DUAL
WHERE @frozen_resolve_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `AttributesEx4`, `DurationIndex`, `RangeIndex`,
    `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `EffectMiscValue_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `Effect_2`, `EffectDieSides_2`,
    `EffectBasePoints_2`, `EffectMiscValue_2`, `ImplicitTargetA_2`,
    `EffectAura_2`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901053, 0, 0x00000040, 31, 1,
    10, 1, 15, 0, -1,
    0, 0, 6,
    1, 1, 1,
    1, 101, 6, 1,
    -3, 127, 1,
    87, 2720, 'Frozen Resolve',
    'Increases armor by 2% and reduces all damage taken by 2% per stack. Lasts 8 sec and stacks up to 10 times.',
    'Armor increased by $s1%. Damage taken reduced by 2%. $u stacks.'
FROM DUAL
WHERE @frozen_resolve_stack_owned = 0;

SET @frozen_resolve_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901052
      AND `Name_Lang_enUS` = 'Frozen Resolve'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 15
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 226
      AND `EffectAuraPeriod_1` = 2000
      AND `SpellIconID` = 2720
);

SET @frozen_resolve_stack_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901053
      AND `Name_Lang_enUS` = 'Frozen Resolve'
      AND `Attributes` = 0
      AND `AttributesEx4` = 0x00000040
      AND `DurationIndex` = 31
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 10
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 15
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 1
      AND `EffectMiscValue_1` = 1
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 101
      AND `Effect_2` = 6
      AND `EffectDieSides_2` = 1
      AND `EffectBasePoints_2` = -3
      AND `EffectMiscValue_2` = 127
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 87
      AND `SpellIconID` = 2720
);

DELETE FROM `spell_script_names`
WHERE `ScriptName` = 'spell_apoc_death_knight_frozen_resolve';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901052, 'spell_apoc_death_knight_frozen_resolve'
FROM DUAL
WHERE @frozen_resolve_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901053, 0x01000000
FROM DUAL
WHERE @frozen_resolve_stack_managed = 1
ON DUPLICATE KEY UPDATE
    `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901052, 'Frozen Resolve'
FROM DUAL
WHERE @frozen_resolve_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901053, 'Frozen Resolve'
FROM DUAL
WHERE @frozen_resolve_stack_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

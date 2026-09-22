SET @improved_feint_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 48659
), 0);

SET @improved_feint_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901089
      AND `Name_Lang_enUS` = 'Improved Feint'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 8
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @improved_feint_icon
);

SET @improved_feint_reduction_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901090
      AND `Name_Lang_enUS` = 'Improved Feint Damage Reduction'
      AND `Attributes` = 0
      AND `AttributesEx4` = 0x00000040
      AND `DurationIndex` = 32
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 8
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = -31
      AND `EffectMiscValue_1` = 127
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 87
      AND `SpellIconID` = @improved_feint_icon
);

SET @improved_feint_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901089 AND @improved_feint_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901089 AND @improved_feint_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901089 AND @improved_feint_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901090 AND @improved_feint_reduction_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901090 AND @improved_feint_reduction_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901090 AND @improved_feint_reduction_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901089, 0x00000040, 21, 1, 1,
    1, 8, 0, -1,
    0, 0, 6,
    0, 0, 1,
    4, @improved_feint_icon, 'Improved Feint',
    'Your Feint grants an additional 30% reduction to all damage taken for 6 sec.',
    'Feint also reduces all damage taken by 30% for 6 sec.'
FROM DUAL
WHERE @improved_feint_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `AttributesEx4`, `DurationIndex`, `RangeIndex`,
    `CumulativeAura`, `SchoolMask`, `SpellClassSet`, `DispelType`,
    `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `EffectMiscValue_1`, `ImplicitTargetA_1`, `EffectAura_1`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901090, 0, 0x00000040, 32, 1,
    1, 1, 8, 0,
    -1, 0, 0,
    6, 1, -31,
    127, 1, 87, @improved_feint_icon,
    'Improved Feint Damage Reduction',
    'Reduces all damage taken by 30% for 6 sec.',
    'Damage taken reduced by 30%.'
FROM DUAL
WHERE @improved_feint_reduction_owned = 0;

SET @improved_feint_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901089
      AND `Name_Lang_enUS` = 'Improved Feint'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 8
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @improved_feint_icon
);

SET @improved_feint_reduction_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901090
      AND `Name_Lang_enUS` = 'Improved Feint Damage Reduction'
      AND `Attributes` = 0
      AND `AttributesEx4` = 0x00000040
      AND `DurationIndex` = 32
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 8
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = -31
      AND `EffectMiscValue_1` = 127
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 87
      AND `SpellIconID` = @improved_feint_icon
);

DELETE FROM `spell_script_names`
WHERE `ScriptName` = 'spell_apoc_rogue_improved_feint';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT -1966, 'spell_apoc_rogue_improved_feint'
FROM DUAL
WHERE @improved_feint_managed = 1
  AND @improved_feint_reduction_managed = 1
  AND EXISTS (
      SELECT 1
      FROM `spell_ranks`
      WHERE `first_spell_id` = 1966
        AND `spell_id` = 48659
        AND `rank` = 8
  );

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901090, 0x01000000
FROM DUAL
WHERE @improved_feint_reduction_managed = 1
ON DUPLICATE KEY UPDATE
    `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901089, 'Improved Feint'
FROM DUAL
WHERE @improved_feint_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901090, 'Improved Feint Damage Reduction'
FROM DUAL
WHERE @improved_feint_reduction_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

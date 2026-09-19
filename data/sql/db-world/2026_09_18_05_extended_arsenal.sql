SET @extended_arsenal_r1_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901022
      AND `Name_Lang_enUS` = 'Extended Arsenal'
      AND `NameSubtext_Lang_enUS` = 'Rank 1'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 2
      AND `SpellClassSet` = 10
      AND `EquippedItemClass` = -1
      AND `EquippedItemSubclass` = 0
      AND `EquippedItemInvTypes` = 0
      AND `SpellIconID` = 3023
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 2
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 107
      AND `EffectMiscValue_1` = 5
      AND `EffectSpellClassMaskA_1` = 0x00004000
      AND `EffectSpellClassMaskA_2` = 0x00040000
      AND `EffectSpellClassMaskA_3` = 0
      AND `Effect_2` = 6
      AND `EffectDieSides_2` = 1
      AND `EffectBasePoints_2` = 0
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 107
      AND `EffectMiscValue_2` = 17
      AND `EffectSpellClassMaskB_1` = 0x00004000
      AND `EffectSpellClassMaskB_2` = 0x00040000
      AND `EffectSpellClassMaskB_3` = 0
);

SET @extended_arsenal_r2_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901023
      AND `Name_Lang_enUS` = 'Extended Arsenal'
      AND `NameSubtext_Lang_enUS` = 'Rank 2'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 2
      AND `SpellClassSet` = 10
      AND `EquippedItemClass` = -1
      AND `EquippedItemSubclass` = 0
      AND `EquippedItemInvTypes` = 0
      AND `SpellIconID` = 3023
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 5
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 107
      AND `EffectMiscValue_1` = 5
      AND `EffectSpellClassMaskA_1` = 0x00004000
      AND `EffectSpellClassMaskA_2` = 0x00040000
      AND `EffectSpellClassMaskA_3` = 0
      AND `Effect_2` = 6
      AND `EffectDieSides_2` = 1
      AND `EffectBasePoints_2` = 1
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 107
      AND `EffectMiscValue_2` = 17
      AND `EffectSpellClassMaskB_1` = 0x00004000
      AND `EffectSpellClassMaskB_2` = 0x00040000
      AND `EffectSpellClassMaskB_3` = 0
);

SET @extended_arsenal_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901022 AND @extended_arsenal_r1_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901022 AND @extended_arsenal_r1_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901022 AND @extended_arsenal_r1_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901023 AND @extended_arsenal_r2_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901023 AND @extended_arsenal_r2_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901023 AND @extended_arsenal_r2_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `EffectMiscValue_1`,
    `EffectSpellClassMaskA_1`, `EffectSpellClassMaskA_2`,
    `EffectSpellClassMaskA_3`, `Effect_2`, `EffectDieSides_2`,
    `EffectBasePoints_2`, `ImplicitTargetA_2`, `EffectAura_2`,
    `EffectMiscValue_2`, `EffectSpellClassMaskB_1`,
    `EffectSpellClassMaskB_2`, `EffectSpellClassMaskB_3`, `SpellIconID`,
    `Name_Lang_enUS`, `NameSubtext_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`
) SELECT
    901022, 0x00000040, 21, 1, 1,
    2, 10, -1,
    0, 0,
    6, 1, 2,
    1, 107, 5,
    0x00004000, 0x00040000,
    0, 6, 1,
    0, 1, 107,
    17, 0x00004000,
    0x00040000, 0, 3023,
    'Extended Arsenal', 'Rank 1',
    'Increases the range of Hammer of the Righteous and Avenger\'s Shield by $s1 yards and the number of targets they hit by $s2.',
    'Range increased by $s1 yards and target count increased by $s2.'
FROM DUAL
WHERE @extended_arsenal_r1_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `EffectMiscValue_1`,
    `EffectSpellClassMaskA_1`, `EffectSpellClassMaskA_2`,
    `EffectSpellClassMaskA_3`, `Effect_2`, `EffectDieSides_2`,
    `EffectBasePoints_2`, `ImplicitTargetA_2`, `EffectAura_2`,
    `EffectMiscValue_2`, `EffectSpellClassMaskB_1`,
    `EffectSpellClassMaskB_2`, `EffectSpellClassMaskB_3`, `SpellIconID`,
    `Name_Lang_enUS`, `NameSubtext_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`
) SELECT
    901023, 0x00000040, 21, 1, 1,
    2, 10, -1,
    0, 0,
    6, 1, 5,
    1, 107, 5,
    0x00004000, 0x00040000,
    0, 6, 1,
    1, 1, 107,
    17, 0x00004000,
    0x00040000, 0, 3023,
    'Extended Arsenal', 'Rank 2',
    'Increases the range of Hammer of the Righteous and Avenger\'s Shield by $s1 yards and the number of targets they hit by $s2.',
    'Range increased by $s1 yards and target count increased by $s2.'
FROM DUAL
WHERE @extended_arsenal_r2_owned = 0;

SET @extended_arsenal_r1_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901022
      AND `Name_Lang_enUS` = 'Extended Arsenal'
      AND `NameSubtext_Lang_enUS` = 'Rank 1'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 2
      AND `SpellClassSet` = 10
      AND `EquippedItemClass` = -1
      AND `EquippedItemSubclass` = 0
      AND `EquippedItemInvTypes` = 0
      AND `SpellIconID` = 3023
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 2
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 107
      AND `EffectMiscValue_1` = 5
      AND `EffectSpellClassMaskA_1` = 0x00004000
      AND `EffectSpellClassMaskA_2` = 0x00040000
      AND `EffectSpellClassMaskA_3` = 0
      AND `Effect_2` = 6
      AND `EffectDieSides_2` = 1
      AND `EffectBasePoints_2` = 0
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 107
      AND `EffectMiscValue_2` = 17
      AND `EffectSpellClassMaskB_1` = 0x00004000
      AND `EffectSpellClassMaskB_2` = 0x00040000
      AND `EffectSpellClassMaskB_3` = 0
);

SET @extended_arsenal_r2_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901023
      AND `Name_Lang_enUS` = 'Extended Arsenal'
      AND `NameSubtext_Lang_enUS` = 'Rank 2'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 2
      AND `SpellClassSet` = 10
      AND `EquippedItemClass` = -1
      AND `EquippedItemSubclass` = 0
      AND `EquippedItemInvTypes` = 0
      AND `SpellIconID` = 3023
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 5
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 107
      AND `EffectMiscValue_1` = 5
      AND `EffectSpellClassMaskA_1` = 0x00004000
      AND `EffectSpellClassMaskA_2` = 0x00040000
      AND `EffectSpellClassMaskA_3` = 0
      AND `Effect_2` = 6
      AND `EffectDieSides_2` = 1
      AND `EffectBasePoints_2` = 1
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 107
      AND `EffectMiscValue_2` = 17
      AND `EffectSpellClassMaskB_1` = 0x00004000
      AND `EffectSpellClassMaskB_2` = 0x00040000
      AND `EffectSpellClassMaskB_3` = 0
);

DELETE FROM `spell_ranks`
WHERE @extended_arsenal_r1_managed = 1
  AND @extended_arsenal_r2_managed = 1
  AND (`first_spell_id` = 901022 OR `spell_id` IN (901022, 901023));

INSERT INTO `spell_ranks` (`first_spell_id`, `spell_id`, `rank`)
SELECT 901022, 901022, 1
FROM DUAL
WHERE @extended_arsenal_r1_managed = 1
  AND @extended_arsenal_r2_managed = 1;

INSERT INTO `spell_ranks` (`first_spell_id`, `spell_id`, `rank`)
SELECT 901022, 901023, 2
FROM DUAL
WHERE @extended_arsenal_r1_managed = 1
  AND @extended_arsenal_r2_managed = 1;

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901022, 'Extended Arsenal'
FROM DUAL
WHERE @extended_arsenal_r1_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901023, 'Extended Arsenal'
FROM DUAL
WHERE @extended_arsenal_r2_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

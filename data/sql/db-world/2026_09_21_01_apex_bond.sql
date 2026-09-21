SET @apex_bond_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901046
      AND `Name_Lang_enUS` = 'Apex Bond'
      AND `Attributes` = 0x00000010
      AND `RecoveryTime` = 90000
      AND `DurationIndex` = 1
      AND `RangeIndex` = 36
      AND `SchoolMask` = 8
      AND `SpellClassSet` = 9
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 136
      AND `EffectBasePoints_1` = 14
      AND `ImplicitTargetA_1` = 5
      AND `Effect_2` = 136
      AND `EffectBasePoints_2` = 14
      AND `ImplicitTargetA_2` = 1
      AND `Effect_3` = 6
      AND `EffectBasePoints_3` = 14
      AND `ImplicitTargetA_3` = 5
      AND `EffectAura_3` = 79
      AND `EffectMiscValue_3` = 127
      AND `SpellIconID` = 1680
);

SET @apex_bond_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901046 AND @apex_bond_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901046 AND @apex_bond_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901046 AND @apex_bond_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `CastingTimeIndex`, `RecoveryTime`, `InterruptFlags`,
    `ProcChance`, `BaseLevel`, `SpellLevel`, `DurationIndex`, `PowerType`,
    `ManaCost`, `RangeIndex`, `Speed`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`, `Effect_2`,
    `Effect_3`, `EffectDieSides_1`, `EffectDieSides_2`, `EffectDieSides_3`,
    `EffectBasePoints_1`, `EffectBasePoints_2`, `EffectBasePoints_3`,
    `ImplicitTargetA_1`, `ImplicitTargetA_2`, `ImplicitTargetA_3`,
    `EffectAura_3`, `EffectMiscValue_3`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`,
    `StartRecoveryCategory`, `StartRecoveryTime`, `SpellClassSet`,
    `DefenseType`, `PreventionType`, `EffectChainAmplitude_1`,
    `EffectChainAmplitude_2`, `EffectChainAmplitude_3`, `SchoolMask`
) SELECT
    901046, 0x00000010, 1, 90000, 15,
    101, 1, 1, 1, 0,
    0, 36, 0, -1,
    0, 0, 136, 136,
    6, 1, 1, 1,
    14, 14, 14,
    5, 1, 5,
    79, 127, 1680, 'Apex Bond',
    'Instantly heals you and your active pet for 15% of maximum health and increases your pet\'s damage by 15% for 10 sec. Requires an alive pet.',
    'Damage increased by 15%.',
    133, 1500, 9,
    1, 1, 1.0,
    1.0, 1.0, 8
FROM DUAL
WHERE @apex_bond_owned = 0;

SET @apex_bond_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901046
      AND `Name_Lang_enUS` = 'Apex Bond'
      AND `Attributes` = 0x00000010
      AND `RecoveryTime` = 90000
      AND `DurationIndex` = 1
      AND `RangeIndex` = 36
      AND `SchoolMask` = 8
      AND `SpellClassSet` = 9
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 136
      AND `EffectBasePoints_1` = 14
      AND `ImplicitTargetA_1` = 5
      AND `Effect_2` = 136
      AND `EffectBasePoints_2` = 14
      AND `ImplicitTargetA_2` = 1
      AND `Effect_3` = 6
      AND `EffectBasePoints_3` = 14
      AND `ImplicitTargetA_3` = 5
      AND `EffectAura_3` = 79
      AND `EffectMiscValue_3` = 127
      AND `SpellIconID` = 1680
);

DELETE FROM `spell_script_names`
WHERE `ScriptName` = 'spell_apoc_hunter_apex_bond';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901046, 'spell_apoc_hunter_apex_bond'
FROM DUAL
WHERE @apex_bond_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901046, 0x01000000
FROM DUAL
WHERE @apex_bond_managed = 1
ON DUPLICATE KEY UPDATE
    `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901046, 'Apex Bond'
FROM DUAL
WHERE @apex_bond_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

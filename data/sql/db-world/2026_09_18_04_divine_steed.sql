SET @divine_steed_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901017
      AND `Name_Lang_enUS` = 'Divine Steed'
      AND `Attributes` = 0x00000010
      AND `RecoveryTime` = 20000
      AND `DurationIndex` = 35
      AND `DispelType` = 0
      AND `SchoolMask` = 2
      AND `SpellClassSet` = 10
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `Effect_2` = 6
      AND `EffectBasePoints_2` = 99
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 31
);

SET @divine_steed_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901017 AND @divine_steed_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901017 AND @divine_steed_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901017 AND @divine_steed_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `DispelType`, `Attributes`, `CastingTimeIndex`, `RecoveryTime`,
    `InterruptFlags`, `ProcChance`, `BaseLevel`, `SpellLevel`, `DurationIndex`,
    `PowerType`, `ManaCost`, `RangeIndex`, `Speed`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`, `Effect_2`,
    `EffectDieSides_1`, `EffectDieSides_2`, `EffectBasePoints_1`,
    `EffectBasePoints_2`, `ImplicitTargetA_1`, `ImplicitTargetA_2`,
    `EffectAura_1`, `EffectAura_2`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`,
    `StartRecoveryCategory`, `StartRecoveryTime`, `SpellClassSet`,
    `DefenseType`, `PreventionType`, `EffectChainAmplitude_1`,
    `EffectChainAmplitude_2`, `SchoolMask`
) SELECT
    901017, 0, 0x00000010, 1, 20000,
    15, 101, 1, 1, 35,
    0, 0, 1, 0, -1,
    0, 0, 6, 6,
    1, 1, 0,
    99, 1, 1,
    4, 31, 1716, 'Divine Steed',
    'Calls upon the Light to grant 100% increased movement speed for 4 sec. The paladin appears mounted but can continue fighting normally.',
    'Movement speed increased by 100%.',
    133, 1500, 10,
    1, 1, 1.0,
    1.0, 2
FROM DUAL
WHERE @divine_steed_owned = 0;

SET @divine_steed_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901017
      AND `Name_Lang_enUS` = 'Divine Steed'
      AND `Attributes` = 0x00000010
      AND `RecoveryTime` = 20000
      AND `DurationIndex` = 35
      AND `DispelType` = 0
      AND `SchoolMask` = 2
      AND `SpellClassSet` = 10
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `Effect_2` = 6
      AND `EffectBasePoints_2` = 99
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 31
);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901017, 'spell_apoc_paladin_divine_steed'
FROM DUAL
WHERE @divine_steed_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901017, 0x01000000
FROM DUAL
WHERE @divine_steed_managed = 1
ON DUPLICATE KEY UPDATE
    `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901017, 'Divine Steed'
FROM DUAL
WHERE @divine_steed_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

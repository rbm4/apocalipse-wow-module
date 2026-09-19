SET @divine_storm_echo_passive_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901014
      AND `Name_Lang_enUS` = 'Divine Storm Echo'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 10
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @divine_storm_echo_spell_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901015
      AND `Name_Lang_enUS` = 'Divine Storm Echo Damage'
      AND `Attributes` = 0x00050000
      AND `AttributesEx` = 0x00000010
      AND `AttributesEx5` = 0x00008000
      AND `RecoveryTime` = 0
      AND `ManaCostPct` = 0
      AND `StartRecoveryCategory` = 0
      AND `StartRecoveryTime` = 0
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 10
      AND `SpellClassMask_2` = 0x00020000
      AND `MaxTargets` = 12
      AND `Effect_2` = 3
      AND `EffectBasePoints_2` = 24
      AND `EffectBasePoints_3` = 54
      AND `ImplicitTargetA_3` = 22
      AND `ImplicitTargetB_3` = 15
      AND `EffectRadiusIndex_3` = 14
      AND (
          (`EquippedItemClass` = 2
           AND `EquippedItemSubclass` = 173555
           AND `Effect_1` = 3
           AND `EffectBasePoints_1` = 109
           AND `Effect_3` IN (31, 121))
          OR
          (`EquippedItemClass` = -1
           AND `EquippedItemSubclass` = 0
           AND `Effect_1` = 121
           AND `EffectBasePoints_1` = -1
           AND `ImplicitTargetA_1` = 22
           AND `ImplicitTargetB_1` = 15
           AND `EffectRadiusIndex_1` = 14
           AND `Effect_3` = 31)
      )
);

SET @divine_storm_echo_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901014 AND @divine_storm_echo_passive_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901014 AND @divine_storm_echo_passive_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901014 AND @divine_storm_echo_passive_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901015 AND @divine_storm_echo_spell_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901015 AND @divine_storm_echo_spell_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901015 AND @divine_storm_echo_spell_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901014, 0x00000040, 21, 1, 1,
    1, 10, -1,
    0, 0, 6,
    0, 0, 1,
    4, 3027, 'Divine Storm Echo',
    'Your Divine Storm echoes after 1 sec for 55% weapon damage, half of Divine Storm, with independent hit and critical strike results.',
    'Divine Storm echoes after 1 sec.'
FROM DUAL
WHERE @divine_storm_echo_passive_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `AttributesEx`, `AttributesEx5`,
    `CastingTimeIndex`, `ProcChance`, `BaseLevel`, `SpellLevel`, `RangeIndex`,
    `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `Effect_2`, `Effect_3`,
    `EffectDieSides_1`, `EffectDieSides_2`, `EffectDieSides_3`,
    `EffectBasePoints_1`, `EffectBasePoints_2`, `EffectBasePoints_3`,
    `ImplicitTargetA_1`, `ImplicitTargetA_2`, `ImplicitTargetA_3`,
    `ImplicitTargetB_1`, `ImplicitTargetB_3`, `EffectRadiusIndex_1`,
    `EffectRadiusIndex_3`,
    `EffectChainAmplitude_1`, `EffectChainAmplitude_2`,
    `EffectChainAmplitude_3`, `SpellVisualID_1`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`, `SpellClassSet`,
    `SpellClassMask_2`, `MaxTargets`, `DefenseType`, `PreventionType`,
    `SchoolMask`
) SELECT
    901015, 0x00050000, 0x00000010, 0x00008000,
    1, 101, 60, 60, 1,
    -1, 0, 0,
    121, 3, 31,
    1, 1, 1,
    -1, 24, 54,
    22, 1, 22,
    15, 15, 14,
    14,
    1.0, 1.0,
    1.0, 12006, 3027,
    'Divine Storm Echo Damage',
    'An echoed weapon attack that causes $s3% of weapon damage to up to 12 enemies within $a3 yards. The Divine Storm heals up to 3 party or raid members totaling $s2% of the damage caused.',
    10, 0x00020000, 12, 2, 2,
    1
FROM DUAL
WHERE @divine_storm_echo_spell_owned = 0;

UPDATE `spell_dbc`
SET `EquippedItemClass` = -1,
    `EquippedItemSubclass` = 0,
    `Effect_1` = 121,
    `EffectBasePoints_1` = -1,
    `ImplicitTargetA_1` = 22,
    `ImplicitTargetB_1` = 15,
    `EffectRadiusIndex_1` = 14,
    `Effect_3` = 31
WHERE `ID` = 901015
  AND @divine_storm_echo_spell_owned = 1;

SET @divine_storm_echo_passive_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901014
      AND `Name_Lang_enUS` = 'Divine Storm Echo'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 10
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @divine_storm_echo_spell_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901015
      AND `Name_Lang_enUS` = 'Divine Storm Echo Damage'
      AND `Attributes` = 0x00050000
      AND `AttributesEx` = 0x00000010
      AND `AttributesEx5` = 0x00008000
      AND `RecoveryTime` = 0
      AND `ManaCostPct` = 0
      AND `StartRecoveryCategory` = 0
      AND `StartRecoveryTime` = 0
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 10
      AND `SpellClassMask_2` = 0x00020000
      AND `MaxTargets` = 12
      AND `EquippedItemClass` = -1
      AND `EquippedItemSubclass` = 0
      AND `Effect_1` = 121
      AND `EffectBasePoints_1` = -1
      AND `ImplicitTargetA_1` = 22
      AND `ImplicitTargetB_1` = 15
      AND `EffectRadiusIndex_1` = 14
      AND `Effect_2` = 3
      AND `EffectBasePoints_2` = 24
      AND `Effect_3` = 31
      AND `EffectBasePoints_3` = 54
      AND `ImplicitTargetA_3` = 22
      AND `ImplicitTargetB_3` = 15
      AND `EffectRadiusIndex_3` = 14
);

DELETE FROM `spell_script_names`
WHERE `ScriptName` = 'spell_apoc_paladin_divine_storm_echo'
  AND `spell_id` <> 53385
  AND @divine_storm_echo_passive_managed = 1
  AND @divine_storm_echo_spell_managed = 1;

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 53385, 'spell_apoc_paladin_divine_storm_echo'
FROM DUAL
WHERE @divine_storm_echo_passive_managed = 1
  AND @divine_storm_echo_spell_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901015, 'spell_pal_divine_storm'
FROM DUAL
WHERE @divine_storm_echo_spell_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901014, 'Divine Storm Echo'
FROM DUAL
WHERE @divine_storm_echo_passive_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901015, 'Divine Storm Echo Damage'
FROM DUAL
WHERE @divine_storm_echo_spell_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

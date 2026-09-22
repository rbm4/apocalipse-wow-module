SET @pestilent_eruption_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 50842
), 0);
SET @pestilent_eruption_visual := COALESCE((
    SELECT `SpellVisualID_1`
    FROM `wotlk_spells_full`
    WHERE `ID` = 50842
), 0);

SET @pestilent_eruption_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901058
      AND `Name_Lang_enUS` = 'Pestilent Eruption'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 32
      AND `SpellClassSet` = 15
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @pestilent_eruption_icon
);

SET @pestilent_eruption_pestilence_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901059
      AND `Name_Lang_enUS` = 'Pestilent Eruption Pestilence'
      AND `AttributesEx` = 0x08000000
      AND `AttributesEx5` = 0x00001000
      AND `CastingTimeIndex` = 1
      AND `BaseLevel` = 56
      AND `SpellLevel` = 56
      AND `PowerType` = 5
      AND `RangeIndex` = 160
      AND `SchoolMask` = 32
      AND `RuneCostID` = 844
      AND `SpellClassSet` = 15
      AND `SpellClassMask_2` = 65536
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 3
      AND `Effect_2` = 3
      AND `Effect_3` = 77
      AND `ImplicitTargetA_1` = 6
      AND `ImplicitTargetA_2` = 47
      AND `ImplicitTargetA_3` = 53
      AND `ImplicitTargetB_3` = 16
      AND `EffectRadiusIndex_2` = 52
      AND `EffectRadiusIndex_3` = 13
      AND `EffectChainAmplitude_1` = 1.0
      AND `EffectChainAmplitude_2` = 1.0
      AND `EffectChainAmplitude_3` = 1.0
      AND `SpellVisualID_1` = @pestilent_eruption_visual
      AND `SpellIconID` = @pestilent_eruption_icon
);

SET @pestilent_eruption_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901058 AND @pestilent_eruption_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901058 AND @pestilent_eruption_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901058 AND @pestilent_eruption_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901059
          AND @pestilent_eruption_pestilence_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901059
          AND @pestilent_eruption_pestilence_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901059
          AND @pestilent_eruption_pestilence_owned = 0
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
    901058, 0x00000040, 21, 1, 1,
    32, 15, 0, -1,
    0, 0, 6,
    0, 0, 1,
    4, @pestilent_eruption_icon, 'Pestilent Eruption',
    'Your Scourge Strike and offensive Death Coil hits trigger Pestilence on the target at no cost.',
    'Scourge Strike and offensive Death Coil hits trigger Pestilence for free.'
FROM DUAL
WHERE @pestilent_eruption_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `DispelType`, `Mechanic`, `AttributesEx`, `AttributesEx5`,
    `CastingTimeIndex`, `ProcChance`, `BaseLevel`, `SpellLevel`,
    `PowerType`, `RangeIndex`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`, `Effect_2`,
    `Effect_3`, `ImplicitTargetA_1`, `ImplicitTargetA_2`,
    `ImplicitTargetA_3`, `ImplicitTargetB_3`, `EffectRadiusIndex_2`,
    `EffectRadiusIndex_3`, `EffectChainAmplitude_1`,
    `EffectChainAmplitude_2`, `EffectChainAmplitude_3`, `SpellVisualID_1`,
    `SpellIconID`, `SpellPriority`, `StartRecoveryCategory`, `StartRecoveryTime`,
    `SpellClassSet`, `SpellClassMask_2`, `DefenseType`, `PreventionType`,
    `SchoolMask`, `RuneCostID`, `Name_Lang_enUS`, `Description_Lang_enUS`
) SELECT
    901059, 3, 22, 0x08000000, 0x00001000,
    1, 101, 56, 56,
    5, 160, -1,
    0, 0, 3, 3,
    77, 6, 47,
    53, 16, 52,
    13, 1.0,
    1.0, 1.0, @pestilent_eruption_visual,
    @pestilent_eruption_icon, 50, 133, 1500,
    15, 65536, 1, 1,
    32, 844, 'Pestilent Eruption Pestilence',
    'Internal long-range Pestilence carrier for Pestilent Eruption.'
FROM DUAL
WHERE @pestilent_eruption_pestilence_owned = 0;

SET @pestilent_eruption_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901058
      AND `Name_Lang_enUS` = 'Pestilent Eruption'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 32
      AND `SpellClassSet` = 15
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @pestilent_eruption_icon
);

SET @pestilent_eruption_pestilence_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901059
      AND `Name_Lang_enUS` = 'Pestilent Eruption Pestilence'
      AND `AttributesEx` = 0x08000000
      AND `AttributesEx5` = 0x00001000
      AND `CastingTimeIndex` = 1
      AND `BaseLevel` = 56
      AND `SpellLevel` = 56
      AND `PowerType` = 5
      AND `RangeIndex` = 160
      AND `SchoolMask` = 32
      AND `RuneCostID` = 844
      AND `SpellClassSet` = 15
      AND `SpellClassMask_2` = 65536
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 3
      AND `Effect_2` = 3
      AND `Effect_3` = 77
      AND `ImplicitTargetA_1` = 6
      AND `ImplicitTargetA_2` = 47
      AND `ImplicitTargetA_3` = 53
      AND `ImplicitTargetB_3` = 16
      AND `EffectRadiusIndex_2` = 52
      AND `EffectRadiusIndex_3` = 13
      AND `EffectChainAmplitude_1` = 1.0
      AND `EffectChainAmplitude_2` = 1.0
      AND `EffectChainAmplitude_3` = 1.0
      AND `SpellVisualID_1` = @pestilent_eruption_visual
      AND `SpellIconID` = @pestilent_eruption_icon
);

DELETE FROM `spell_script_names`
WHERE `ScriptName` = 'spell_apoc_death_knight_pestilent_eruption';

DELETE FROM `spell_script_names`
WHERE `spell_id` = 901059
  AND `ScriptName` = 'spell_dk_pestilence';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT -47541, 'spell_apoc_death_knight_pestilent_eruption'
FROM DUAL
WHERE @pestilent_eruption_managed = 1
  AND @pestilent_eruption_pestilence_managed = 1;

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT -55090, 'spell_apoc_death_knight_pestilent_eruption'
FROM DUAL
WHERE @pestilent_eruption_managed = 1
  AND @pestilent_eruption_pestilence_managed = 1;

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901059, 'spell_dk_pestilence'
FROM DUAL
WHERE @pestilent_eruption_managed = 1
  AND @pestilent_eruption_pestilence_managed = 1;

INSERT INTO `mod_spec_spells` (
    `class`, `spec_index`, `spell_id`, `description`
)
SELECT 6, 2, 901058, 'Pestilent Eruption'
FROM DUAL
WHERE @pestilent_eruption_managed = 1
  AND @pestilent_eruption_pestilence_managed = 1
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901058, 'Pestilent Eruption'
FROM DUAL
WHERE @pestilent_eruption_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901059, 'Pestilent Eruption Pestilence'
FROM DUAL
WHERE @pestilent_eruption_pestilence_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

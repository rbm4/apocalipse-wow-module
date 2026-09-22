SET @pestilent_knives_visual := COALESCE((
    SELECT `SpellVisualID_1`
    FROM `wotlk_spells_full`
    WHERE `ID` = 51723
), 12317);
SET @pestilent_knives_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 51723
), 2904);

SET @pestilent_knives_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901069
      AND `Name_Lang_enUS` = 'Pestilent Knives'
      AND `Attributes` = 0x00010010
      AND `AttributesEx` = 0x00000010
      AND `AttributesEx3` = 0x00000400
      AND `AttributesEx4` = 0x00800000
      AND `RecoveryTime` = 20000
      AND `PowerType` = 3
      AND `ManaCost` = 35
      AND `RangeIndex` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 8
      AND `SpellClassMask_2` = 0
      AND `MaxTargets` = 10
      AND `EquippedItemClass` = 2
      AND `EquippedItemSubclass` = 173555
      AND `Effect_1` = 31
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 49
      AND `ImplicitTargetA_1` = 18
      AND `ImplicitTargetB_1` = 16
      AND `EffectRadiusIndex_1` = 13
      AND `SpellVisualID_1` = @pestilent_knives_visual
      AND `SpellIconID` = @pestilent_knives_icon
);

SET @pestilent_knives_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901069 AND @pestilent_knives_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901069 AND @pestilent_knives_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901069 AND @pestilent_knives_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `AttributesEx`, `AttributesEx3`, `AttributesEx4`,
    `CastingTimeIndex`, `RecoveryTime`, `ProcChance`, `BaseLevel`,
    `SpellLevel`, `PowerType`, `ManaCost`, `RangeIndex`, `Speed`,
    `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `ImplicitTargetB_1`, `EffectRadiusIndex_1`,
    `SpellVisualID_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `StartRecoveryCategory`, `StartRecoveryTime`,
    `SpellClassSet`, `SpellClassMask_2`, `MaxTargets`, `DefenseType`,
    `PreventionType`, `EffectChainAmplitude_1`, `SchoolMask`
) SELECT
    901069, 0x00010010, 0x00000010, 0x00000400, 0x00800000,
    1, 20000, 101, 1,
    1, 3, 35, 1, 18,
    2, 173555, 0,
    31, 1, 49,
    18, 16, 13,
    @pestilent_knives_visual, @pestilent_knives_icon, 'Pestilent Knives',
    'Throws poisoned knives at up to 10 enemies within 10 yards, dealing 50% weapon damage and applying 2 doses of your main-hand Deadly Poison. At 5 doses, triggers its normal full-stack interaction no more than once per enemy.',
    133, 1000,
    8, 0, 10, 2,
    2, 1.0, 1
FROM DUAL
WHERE @pestilent_knives_owned = 0;

SET @pestilent_knives_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901069
      AND `Name_Lang_enUS` = 'Pestilent Knives'
      AND `Attributes` = 0x00010010
      AND `AttributesEx` = 0x00000010
      AND `AttributesEx3` = 0x00000400
      AND `AttributesEx4` = 0x00800000
      AND `RecoveryTime` = 20000
      AND `PowerType` = 3
      AND `ManaCost` = 35
      AND `RangeIndex` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 8
      AND `SpellClassMask_2` = 0
      AND `MaxTargets` = 10
      AND `EquippedItemClass` = 2
      AND `EquippedItemSubclass` = 173555
      AND `Effect_1` = 31
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 49
      AND `ImplicitTargetA_1` = 18
      AND `ImplicitTargetB_1` = 16
      AND `EffectRadiusIndex_1` = 13
      AND `SpellVisualID_1` = @pestilent_knives_visual
      AND `SpellIconID` = @pestilent_knives_icon
);

DELETE FROM `spell_script_names`
WHERE `ScriptName` = 'spell_apoc_rogue_pestilent_knives';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901069, 'spell_apoc_rogue_pestilent_knives'
FROM DUAL
WHERE @pestilent_knives_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `mod_spec_spells` (
    `class`, `spec_index`, `spell_id`, `description`
)
SELECT 4, 0, 901069, 'Pestilent Knives'
FROM DUAL
WHERE @pestilent_knives_managed = 1
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901069, 'Pestilent Knives'
FROM DUAL
WHERE @pestilent_knives_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

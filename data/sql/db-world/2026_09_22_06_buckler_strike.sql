SET @buckler_strike_range := COALESCE((
    SELECT `RangeIndex`
    FROM `wotlk_spells_full`
    WHERE `ID` = 72
), 2);
SET @buckler_strike_visual := COALESCE((
    SELECT `SpellVisualID_1`
    FROM `wotlk_spells_full`
    WHERE `ID` = 23922
), 0);
SET @buckler_strike_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 23922
), 292);

SET @buckler_strike_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901078
      AND `Name_Lang_enUS` = 'Buckler Strike'
      AND `Attributes` = 0x00010010
      AND `AttributesEx` = 0x00000210
      AND `AttributesEx4` = 0x00800000
      AND `RecoveryTime` = 20000
      AND `DurationIndex` = 27
      AND `PowerType` = 3
      AND `ManaCost` = 25
      AND `RangeIndex` = @buckler_strike_range
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 8
      AND `EquippedItemClass` = 4
      AND `EquippedItemSubclass` = 64
      AND `EquippedItemInvTypes` = 16384
      AND `Effect_1` = 2
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = -1
      AND `ImplicitTargetA_1` = 6
      AND `Effect_2` = 80
      AND `EffectDieSides_2` = 1
      AND `EffectBasePoints_2` = 0
      AND `ImplicitTargetA_2` = 6
      AND `Effect_3` = 68
      AND `EffectDieSides_3` = 1
      AND `EffectBasePoints_3` = 0
      AND `ImplicitTargetA_3` = 6
      AND `SpellVisualID_1` = @buckler_strike_visual
      AND `SpellIconID` = @buckler_strike_icon
);

SET @buckler_strike_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901078 AND @buckler_strike_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901078 AND @buckler_strike_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901078 AND @buckler_strike_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `AttributesEx`, `AttributesEx4`,
    `CastingTimeIndex`, `RecoveryTime`, `InterruptFlags`, `ProcChance`,
    `BaseLevel`, `SpellLevel`, `DurationIndex`, `PowerType`, `ManaCost`,
    `RangeIndex`, `Speed`, `EquippedItemClass`, `EquippedItemSubclass`,
    `EquippedItemInvTypes`, `Effect_1`, `Effect_2`, `Effect_3`,
    `EffectDieSides_1`, `EffectDieSides_2`, `EffectDieSides_3`,
    `EffectBasePoints_1`, `EffectBasePoints_2`, `EffectBasePoints_3`,
    `ImplicitTargetA_1`, `ImplicitTargetA_2`, `ImplicitTargetA_3`,
    `SpellVisualID_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `StartRecoveryCategory`, `StartRecoveryTime`,
    `SpellClassSet`, `DefenseType`, `PreventionType`,
    `EffectChainAmplitude_1`, `EffectChainAmplitude_2`,
    `EffectChainAmplitude_3`, `SchoolMask`
) SELECT
    901078, 0x00010010, 0x00000210, 0x00800000,
    1, 20000, 15, 101,
    1, 1, 27, 3, 25,
    @buckler_strike_range, 0, 4, 64,
    16384, 2, 80, 68,
    1, 1, 1,
    -1, 0, 0,
    6, 6, 6,
    @buckler_strike_visual, @buckler_strike_icon, 'Buckler Strike',
    'Strikes with your equipped shield for Physical damage equal to 110% of attack power plus 150% of shield block value, applies Blade Twisting, awards 1 combo point, and generates high threat. Interrupts non-player spellcasting for 3 sec. Requires a shield.',
    133, 1000,
    8, 2, 1,
    1.0, 1.0,
    1.0, 1
FROM DUAL
WHERE @buckler_strike_owned = 0;

SET @buckler_strike_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901078
      AND `Name_Lang_enUS` = 'Buckler Strike'
      AND `Attributes` = 0x00010010
      AND `AttributesEx` = 0x00000210
      AND `AttributesEx4` = 0x00800000
      AND `RecoveryTime` = 20000
      AND `DurationIndex` = 27
      AND `PowerType` = 3
      AND `ManaCost` = 25
      AND `RangeIndex` = @buckler_strike_range
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 8
      AND `EquippedItemClass` = 4
      AND `EquippedItemSubclass` = 64
      AND `EquippedItemInvTypes` = 16384
      AND `Effect_1` = 2
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = -1
      AND `ImplicitTargetA_1` = 6
      AND `Effect_2` = 80
      AND `EffectDieSides_2` = 1
      AND `EffectBasePoints_2` = 0
      AND `ImplicitTargetA_2` = 6
      AND `Effect_3` = 68
      AND `EffectDieSides_3` = 1
      AND `EffectBasePoints_3` = 0
      AND `ImplicitTargetA_3` = 6
      AND `SpellVisualID_1` = @buckler_strike_visual
      AND `SpellIconID` = @buckler_strike_icon
);

DELETE FROM `spell_script_names`
WHERE `ScriptName` = 'spell_apoc_rogue_buckler_strike';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901078, 'spell_apoc_rogue_buckler_strike'
FROM DUAL
WHERE @buckler_strike_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901078, 'Buckler Strike'
FROM DUAL
WHERE @buckler_strike_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

SET @divine_toll_range := COALESCE((
    SELECT `RangeIndex`
    FROM `wotlk_spells_full`
    WHERE `ID` = 53407
), 4);
SET @divine_toll_visual := COALESCE((
    SELECT `SpellVisualID_1`
    FROM `wotlk_spells_full`
    WHERE `ID` = 53407
), 0);
SET @divine_toll_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 53407
), 25);

SET @divine_toll_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901024
      AND `Name_Lang_enUS` = 'Divine Toll'
      AND `RecoveryTime` = 60000
      AND `DurationIndex` = 35
      AND `ManaCostPct` = 10
      AND `RangeIndex` = @divine_toll_range
      AND `SpellClassSet` = 10
      AND `Effect_1` = 3
      AND `ImplicitTargetA_1` = 6
      AND `Effect_2` = 6
      AND `EffectBasePoints_2` = -1
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 4
);

SET @divine_toll_marker_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901025
      AND `Name_Lang_enUS` = 'Divine Toll Impact Marker'
      AND `DurationIndex` = 35
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = 9999
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 54
      AND `Effect_2` = 6
      AND `EffectBasePoints_2` = 9999
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 55
      AND `Effect_3` = 6
      AND `EffectBasePoints_3` = 9999
      AND `ImplicitTargetA_3` = 1
      AND `EffectAura_3` = 240
);

SET @divine_toll_visual_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901026
      AND `Name_Lang_enUS` = 'Divine Toll Justice Visual'
      AND `SpellVisualID_1` = @divine_toll_visual
      AND `Effect_1` = 3
      AND `ImplicitTargetA_1` = 6
);

SET @divine_toll_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901024 AND @divine_toll_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901024 AND @divine_toll_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901024 AND @divine_toll_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901025 AND @divine_toll_marker_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901025 AND @divine_toll_marker_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901025 AND @divine_toll_marker_owned = 0
        UNION ALL
        SELECT 8 FROM `spell_dbc`
        WHERE `ID` = 901026 AND @divine_toll_visual_owned = 0
        UNION ALL
        SELECT 9 FROM `wotlk_spells_full`
        WHERE `ID` = 901026 AND @divine_toll_visual_owned = 0
        UNION ALL
        SELECT 10 FROM `wotlk_spells`
        WHERE `ID` = 901026 AND @divine_toll_visual_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `AttributesEx3`, `CastingTimeIndex`, `RecoveryTime`,
    `InterruptFlags`, `ProcChance`, `BaseLevel`, `SpellLevel`, `DurationIndex`,
    `PowerType`, `ManaCost`, `RangeIndex`, `Speed`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`, `Effect_2`,
    `EffectDieSides_1`, `EffectDieSides_2`, `EffectBasePoints_1`,
    `EffectBasePoints_2`, `ImplicitTargetA_1`, `ImplicitTargetA_2`,
    `EffectAura_2`, `SpellVisualID_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`, `ManaCostPct`,
    `StartRecoveryCategory`, `StartRecoveryTime`, `SpellClassSet`,
    `DefenseType`, `PreventionType`, `EffectChainAmplitude_1`,
    `EffectChainAmplitude_2`, `SchoolMask`
) SELECT
    901024, 0, 0x00040000, 1, 60000,
    15, 101, 1, 1, 35,
    0, 0, @divine_toll_range, 0, -1,
    0, 0, 3, 6,
    1, 1, 0,
    -1, 6, 1,
    4, @divine_toll_visual, @divine_toll_icon, 'Divine Toll',
    'Unleashes 1 to 5 Judgements against an enemy. Each impact deals 50% damage, applies Judgement of Justice, and occurs 0.5 sec after the previous impact.',
    'Unleashing sequential Judgements.', 10,
    133, 1500, 10,
    1, 1, 1.0,
    1.0, 2
FROM DUAL
WHERE @divine_toll_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `DurationIndex`, `RangeIndex`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`, `Effect_2`,
    `Effect_3`, `EffectDieSides_1`, `EffectDieSides_2`, `EffectDieSides_3`,
    `EffectBasePoints_1`, `EffectBasePoints_2`, `EffectBasePoints_3`,
    `ImplicitTargetA_1`, `ImplicitTargetA_2`, `ImplicitTargetA_3`,
    `EffectAura_1`, `EffectAura_2`, `EffectAura_3`, `SpellIconID`,
    `Name_Lang_enUS`, `AuraDescription_Lang_enUS`, `SpellClassSet`,
    `EffectChainAmplitude_1`, `EffectChainAmplitude_2`,
    `EffectChainAmplitude_3`, `SchoolMask`
) SELECT
    901025, 0x00000040, 35, 1, -1,
    0, 0, 6, 6,
    6, 1, 1, 1,
    9999, 9999, 9999,
    1, 1, 1,
    54, 55, 240, @divine_toll_icon,
    'Divine Toll Impact Marker', 'Divine Toll impact cannot miss.', 10,
    1.0, 1.0,
    1.0, 2
FROM DUAL
WHERE @divine_toll_marker_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `AttributesEx3`, `CastingTimeIndex`, `ProcChance`,
    `BaseLevel`, `SpellLevel`, `RangeIndex`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `SpellVisualID_1`, `SpellIconID`, `Name_Lang_enUS`, `SpellClassSet`,
    `DefenseType`, `PreventionType`, `EffectChainAmplitude_1`, `SchoolMask`
) SELECT
    901026, 0, 0x00040000, 1, 101,
    1, 1, @divine_toll_range, -1,
    0, 0, 3,
    1, 0, 6,
    @divine_toll_visual, @divine_toll_icon,
    'Divine Toll Justice Visual', 10,
    1, 1, 1.0, 2
FROM DUAL
WHERE @divine_toll_visual_owned = 0;

SET @divine_toll_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901024
      AND `Name_Lang_enUS` = 'Divine Toll'
      AND `RecoveryTime` = 60000
      AND `DurationIndex` = 35
      AND `ManaCostPct` = 10
      AND `RangeIndex` = @divine_toll_range
      AND `SpellClassSet` = 10
      AND `Effect_1` = 3
      AND `ImplicitTargetA_1` = 6
      AND `Effect_2` = 6
      AND `EffectBasePoints_2` = -1
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 4
);

SET @divine_toll_marker_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901025
      AND `Name_Lang_enUS` = 'Divine Toll Impact Marker'
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = 9999
      AND `EffectAura_1` = 54
      AND `Effect_2` = 6
      AND `EffectBasePoints_2` = 9999
      AND `EffectAura_2` = 55
      AND `Effect_3` = 6
      AND `EffectBasePoints_3` = 9999
      AND `EffectAura_3` = 240
);

SET @divine_toll_visual_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901026
      AND `Name_Lang_enUS` = 'Divine Toll Justice Visual'
      AND `SpellVisualID_1` = @divine_toll_visual
      AND `Effect_1` = 3
      AND `ImplicitTargetA_1` = 6
);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901024, 'spell_apoc_paladin_divine_toll'
FROM DUAL
WHERE @divine_toll_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT IGNORE INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT -31876, 'spell_apoc_paladin_divine_toll_wise_gate'
FROM DUAL
WHERE @divine_toll_managed = 1;

INSERT IGNORE INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT `spell_id`, 'spell_apoc_paladin_divine_toll_damage'
FROM (
    SELECT 20424 AS `spell_id`
    UNION ALL SELECT 20467
    UNION ALL SELECT 25742
    UNION ALL SELECT 31804
    UNION ALL SELECT 32220
    UNION ALL SELECT 42463
    UNION ALL SELECT 53725
    UNION ALL SELECT 53733
    UNION ALL SELECT 53739
    UNION ALL SELECT 54158
) AS `divine_toll_damage_spells`
WHERE @divine_toll_managed = 1
  AND @divine_toll_marker_managed = 1;

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901024, 0x01000000
FROM DUAL
WHERE @divine_toll_managed = 1
ON DUPLICATE KEY UPDATE
    `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901025, 0x01000000
FROM DUAL
WHERE @divine_toll_marker_managed = 1
ON DUPLICATE KEY UPDATE
    `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901024, 'Divine Toll'
FROM DUAL
WHERE @divine_toll_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901025, 'Divine Toll Impact Marker'
FROM DUAL
WHERE @divine_toll_marker_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901026, 'Divine Toll Justice Visual'
FROM DUAL
WHERE @divine_toll_visual_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

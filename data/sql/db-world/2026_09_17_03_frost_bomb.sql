SET @frost_bomb_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901007
      AND `Name_Lang_enUS` = 'Frost Bomb'
      AND `CastingTimeIndex` = 16
      AND `RecoveryTime` = 16000
      AND `DurationIndex` = 35
      AND `ManaCostPct` = 22
      AND `DispelType` = 1
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 3
      AND `SpellClassMask_1` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 901007
      AND `ImplicitTargetA_1` = 6
      AND `EffectAura_1` = 4
);

SET @frost_bomb_explosion_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901008
      AND `Name_Lang_enUS` = 'Frost Bomb Explosion'
      AND `AttributesEx2` = 0x40000001
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 3
      AND `SpellClassMask_1` = 32
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 2
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 689
      AND ABS(`EffectBonusMultiplier_1` - 0.4) < 0.0001
      AND `ImplicitTargetA_1` = 53
      AND `ImplicitTargetB_1` = 16
      AND `EffectRadiusIndex_1` = 13
      AND `SpellVisualID_1` IN (0, 17)
);

SET @frost_bomb_slow_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901009
      AND `Name_Lang_enUS` = 'Frost Bomb Slow'
      AND `DispelType` = 1
      AND `DurationIndex` = 28
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 3
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = -41
      AND `ImplicitTargetA_1` = 6
      AND `EffectAura_1` = 33
);

SET @frost_bomb_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901007 AND @frost_bomb_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901007 AND @frost_bomb_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901007 AND @frost_bomb_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901008 AND @frost_bomb_explosion_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901008 AND @frost_bomb_explosion_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901008 AND @frost_bomb_explosion_owned = 0
        UNION ALL
        SELECT 8 FROM `spell_dbc`
        WHERE `ID` = 901009 AND @frost_bomb_slow_owned = 0
        UNION ALL
        SELECT 9 FROM `wotlk_spells_full`
        WHERE `ID` = 901009 AND @frost_bomb_slow_owned = 0
        UNION ALL
        SELECT 10 FROM `wotlk_spells`
        WHERE `ID` = 901009 AND @frost_bomb_slow_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `DispelType`, `Attributes`, `CastingTimeIndex`, `RecoveryTime`,
    `InterruptFlags`, `ProcChance`, `BaseLevel`, `SpellLevel`, `DurationIndex`,
    `PowerType`, `ManaCost`, `RangeIndex`, `Speed`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `SpellVisualID_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`, `ManaCostPct`,
    `StartRecoveryCategory`, `StartRecoveryTime`, `SpellClassSet`,
    `SpellClassMask_1`, `DefenseType`, `PreventionType`,
    `EffectChainAmplitude_1`, `SchoolMask`
) SELECT
    901007, 1, 0x04010000, 16, 16000,
    15, 101, 80, 80, 35,
    0, 0, 4, 0, -1,
    0, 0, 6,
    1, 901007, 6,
    4, 13, 188, 'Frost Bomb',
    'Places a Frost Bomb on an enemy. After 4 sec, or when dispelled or the target dies, it explodes for 690 Frost damage to enemies within 10 yards and applies Frost Bomb Slow.',
    'Explodes after 4 sec, when dispelled, or when the target dies.',
    22, 133, 1500, 3,
    0, 1, 1,
    1.0, 16
FROM DUAL
WHERE @frost_bomb_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `AttributesEx2`, `CastingTimeIndex`, `ProcChance`,
    `BaseLevel`, `SpellLevel`, `PowerType`, `ManaCost`, `RangeIndex`, `Speed`,
    `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `ImplicitTargetB_1`, `EffectRadiusIndex_1`,
    `SpellVisualID_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `SpellClassSet`, `SpellClassMask_1`,
    `DefenseType`, `PreventionType`, `EffectChainAmplitude_1`, `SchoolMask`,
    `EffectBonusMultiplier_1`
) SELECT
    901008, 0x04010080, 0x40000001, 1, 101,
    80, 80, 0, 0, 4, 0,
    -1, 0, 0,
    2, 1, 689,
    53, 16, 13,
    0, 188, 'Frost Bomb Explosion',
    'Deals $s1 Frost damage to enemies within 10 yards of the Frost Bomb and applies Frost Bomb Slow.',
    3, 32,
    1, 1, 1.0, 16,
    0.4
FROM DUAL
WHERE @frost_bomb_explosion_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `DispelType`, `Attributes`, `CastingTimeIndex`, `ProcChance`,
    `BaseLevel`, `SpellLevel`, `DurationIndex`, `PowerType`, `ManaCost`,
    `RangeIndex`,
    `Speed`, `EquippedItemClass`, `EquippedItemSubclass`,
    `EquippedItemInvTypes`, `Effect_1`, `EffectDieSides_1`,
    `EffectBasePoints_1`, `ImplicitTargetA_1`, `EffectAura_1`,
    `SpellVisualID_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`, `SpellClassSet`,
    `DefenseType`, `PreventionType`, `EffectChainAmplitude_1`, `SchoolMask`
) SELECT
    901009, 1, 0x04010000, 1, 101,
    80, 80, 28, 0, 0,
    4,
    0, -1, 0,
    0, 6, 1,
    -41, 6, 33,
    17, 193, 'Frost Bomb Slow',
    'Slows movement by 40% for 5 sec. Permafrost increases the slow to 44%, 47%, or 50% and its duration to 6, 7, or 8 sec based on talent rank, and applies Permafrost healing reduction.',
    'Movement slowed. Permafrost increases the slow and duration based on talent rank.',
    3, 1, 1,
    1.0, 16
FROM DUAL
WHERE @frost_bomb_slow_owned = 0;

SET @frost_bomb_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901007
      AND `Name_Lang_enUS` = 'Frost Bomb'
      AND `CastingTimeIndex` = 16
      AND `RecoveryTime` = 16000
      AND `DurationIndex` = 35
      AND `ManaCostPct` = 22
      AND `DispelType` = 1
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 3
      AND `SpellClassMask_1` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 901007
      AND `ImplicitTargetA_1` = 6
      AND `EffectAura_1` = 4
);

SET @frost_bomb_explosion_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901008
      AND `Name_Lang_enUS` = 'Frost Bomb Explosion'
      AND `AttributesEx2` = 0x40000001
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 3
      AND `SpellClassMask_1` = 32
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 2
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 689
      AND ABS(`EffectBonusMultiplier_1` - 0.4) < 0.0001
      AND `ImplicitTargetA_1` = 53
      AND `ImplicitTargetB_1` = 16
      AND `EffectRadiusIndex_1` = 13
      AND `SpellVisualID_1` IN (0, 17)
);

UPDATE `spell_dbc`
SET `SpellVisualID_1` = 0
WHERE @frost_bomb_explosion_managed = 1
  AND `ID` = 901008;

SET @frost_bomb_slow_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901009
      AND `Name_Lang_enUS` = 'Frost Bomb Slow'
      AND `DispelType` = 1
      AND `DurationIndex` = 28
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 3
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = -41
      AND `ImplicitTargetA_1` = 6
      AND `EffectAura_1` = 33
);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901007, 'spell_apoc_mage_frost_bomb'
FROM DUAL
WHERE @frost_bomb_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901008, 'spell_apoc_mage_frost_bomb_explosion'
FROM DUAL
WHERE @frost_bomb_explosion_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901009, 'spell_apoc_mage_frost_bomb_slow'
FROM DUAL
WHERE @frost_bomb_slow_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_bonus_data`
    (`entry`, `direct_bonus`, `dot_bonus`, `ap_bonus`, `ap_dot_bonus`, `comments`)
SELECT 901008, 0.4, 0, 0, 0, 'Mage - Frost Bomb Explosion'
FROM DUAL
WHERE @frost_bomb_explosion_managed = 1
ON DUPLICATE KEY UPDATE
    `direct_bonus` = VALUES(`direct_bonus`),
    `dot_bonus` = VALUES(`dot_bonus`),
    `ap_bonus` = VALUES(`ap_bonus`),
    `ap_dot_bonus` = VALUES(`ap_dot_bonus`),
    `comments` = VALUES(`comments`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901007, 'Frost Bomb'
FROM DUAL
WHERE @frost_bomb_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901008, 'Frost Bomb Explosion'
FROM DUAL
WHERE @frost_bomb_explosion_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901009, 'Frost Bomb Slow'
FROM DUAL
WHERE @frost_bomb_slow_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

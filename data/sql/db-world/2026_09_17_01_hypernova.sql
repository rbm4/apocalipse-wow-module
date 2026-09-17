SET @hypernova_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901005
      AND `Name_Lang_enUS` = 'Hypernova'
      AND `SchoolMask` = 64
      AND `SpellClassSet` = 3
      AND `SpellClassMask_1` = 4096
      AND `RecoveryTime` = 45000
      AND `ManaCostPct` = 22
      AND `Effect_1` = 2
      AND `EffectBasePoints_1` = 4739
      AND `EffectDieSides_1` = 769
      AND `ImplicitTargetA_1` = 53
      AND `ImplicitTargetB_1` = 16
      AND `EffectRadiusIndex_1` = 13
      AND `Effect_2` = 144
      AND `EffectBasePoints_2` = 100
      AND `EffectMiscValue_2` = 20
      AND `ImplicitTargetA_2` = 53
      AND `ImplicitTargetB_2` = 16
      AND `EffectRadiusIndex_2` = 13
);

SET @hypernova_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901005 AND @hypernova_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901005 AND @hypernova_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901005 AND @hypernova_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `CastingTimeIndex`, `RecoveryTime`,
    `InterruptFlags`, `ProcChance`, `BaseLevel`, `SpellLevel`, `PowerType`,
    `ManaCost`, `RangeIndex`, `Speed`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `ImplicitTargetB_1`, `EffectRadiusIndex_1`, `Effect_2`,
    `EffectDieSides_2`, `EffectBasePoints_2`, `ImplicitTargetA_2`,
    `ImplicitTargetB_2`, `EffectRadiusIndex_2`, `EffectMiscValue_2`,
    `SpellVisualID_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `ManaCostPct`, `StartRecoveryCategory`,
    `StartRecoveryTime`, `SpellClassSet`, `SpellClassMask_1`, `DefenseType`,
    `PreventionType`, `EffectChainAmplitude_1`, `EffectChainAmplitude_2`,
    `SchoolMask`, `EffectBonusMultiplier_1`
) SELECT
    901005, 0, 1, 45000,
    15, 101, 80, 80, 0,
    0, 4, 0, -1,
    0, 0, 2,
    769, 4739, 53,
    16, 13, 144,
    0, 100, 53,
    16, 13, 20,
    0, 122, 'Hypernova',
    'Detonates a hypernova at the target, dealing $s1 Arcane damage to enemies within 10 yards and knocking them into the air. Grants 4 Arcane Blast charges.',
    22, 133,
    1500, 3, 4096, 1,
    1, 1.0, 1.0,
    64, 2.856
FROM DUAL
WHERE @hypernova_owned = 0;

SET @hypernova_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901005
      AND `Name_Lang_enUS` = 'Hypernova'
      AND `SchoolMask` = 64
      AND `SpellClassSet` = 3
      AND `SpellClassMask_1` = 4096
      AND `RecoveryTime` = 45000
      AND `ManaCostPct` = 22
      AND `Effect_1` = 2
      AND `EffectBasePoints_1` = 4739
      AND `EffectDieSides_1` = 769
      AND `ImplicitTargetA_1` = 53
      AND `ImplicitTargetB_1` = 16
      AND `EffectRadiusIndex_1` = 13
      AND `Effect_2` = 144
      AND `EffectBasePoints_2` = 100
      AND `EffectMiscValue_2` = 20
      AND `ImplicitTargetA_2` = 53
      AND `ImplicitTargetB_2` = 16
      AND `EffectRadiusIndex_2` = 13
);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901005, 'spell_apoc_mage_hypernova'
FROM DUAL
WHERE @hypernova_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_bonus_data`
    (`entry`, `direct_bonus`, `dot_bonus`, `ap_bonus`, `ap_dot_bonus`, `comments`)
SELECT 901005, 2.856, 0, 0, 0, 'Mage - Hypernova'
FROM DUAL
WHERE @hypernova_managed = 1
ON DUPLICATE KEY UPDATE
    `direct_bonus` = VALUES(`direct_bonus`),
    `dot_bonus` = VALUES(`dot_bonus`),
    `ap_bonus` = VALUES(`ap_bonus`),
    `ap_dot_bonus` = VALUES(`ap_dot_bonus`),
    `comments` = VALUES(`comments`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901005, 'Hypernova'
FROM DUAL
WHERE @hypernova_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

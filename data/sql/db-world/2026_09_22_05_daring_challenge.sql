SET @daring_challenge_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 355
), 24);

SET @daring_challenge_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901070
      AND `Name_Lang_enUS` = 'Daring Challenge'
      AND `Attributes` = 0x00050010
      AND `AttributesEx2` = 0x04000000
      AND `AttributesEx4` = 0x00000800
      AND `AttributesEx6` = 0x00800000
      AND `RecoveryTime` = 10000
      AND `DurationIndex` = 27
      AND `RangeIndex` = 4
      AND `SpellClassSet` = 8
      AND `MaxTargets` = 1
      AND `Effect_1` = 114
      AND `ImplicitTargetA_1` = 6
      AND `Effect_2` = 6
      AND `ImplicitTargetA_2` = 6
      AND `EffectAura_2` = 11
      AND `SpellIconID` = @daring_challenge_icon
);

SET @daring_challenge_threat_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901071
      AND `Name_Lang_enUS` = 'Daring Challenge Threat'
      AND `Attributes` = 0
      AND `ProcTypeMask` = 0x00051114
      AND `ProcChance` = 100
      AND `DurationIndex` = 32
      AND `RangeIndex` = 4
      AND `SpellClassSet` = 8
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = 49
      AND `ImplicitTargetA_1` = 6
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @daring_challenge_icon
);

SET @daring_challenge_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901070 AND @daring_challenge_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901070 AND @daring_challenge_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901070 AND @daring_challenge_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901071 AND @daring_challenge_threat_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901071 AND @daring_challenge_threat_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901071 AND @daring_challenge_threat_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `AttributesEx2`, `AttributesEx4`, `AttributesEx6`,
    `CastingTimeIndex`, `RecoveryTime`, `ProcChance`, `BaseLevel`,
    `SpellLevel`, `DurationIndex`, `PowerType`, `RangeIndex`,
    `EquippedItemClass`, `Effect_1`, `Effect_2`, `EffectDieSides_1`,
    `EffectDieSides_2`, `EffectBasePoints_1`, `EffectBasePoints_2`,
    `ImplicitTargetA_1`, `ImplicitTargetA_2`, `EffectAura_2`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`, `SpellClassSet`, `MaxTargets`,
    `DefenseType`, `PreventionType`, `EffectChainAmplitude_1`,
    `EffectChainAmplitude_2`, `SchoolMask`
) SELECT
    901070, 0x00050010, 0x04000000, 0x00000800, 0x00800000,
    1, 10000, 101, 1,
    1, 27, 1, 4,
    -1, 114, 6, 0,
    0, 0, 0,
    6, 6, 11,
    @daring_challenge_icon, 'Daring Challenge',
    'Taunts the enemy to attack you for 3 sec, matches its highest threat, and adds a small threat lead. For 6 sec, your attacks against that enemy generate 50% additional threat.',
    '', 8, 1,
    1, 0, 1.0,
    1.0, 1
FROM DUAL
WHERE @daring_challenge_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `ProcTypeMask`, `ProcChance`, `BaseLevel`,
    `SpellLevel`, `DurationIndex`, `PowerType`, `RangeIndex`,
    `EquippedItemClass`, `Effect_1`, `EffectDieSides_1`,
    `EffectBasePoints_1`, `ImplicitTargetA_1`, `EffectAura_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`, `SpellClassSet`, `DefenseType`,
    `PreventionType`, `EffectChainAmplitude_1`, `SchoolMask`
) SELECT
    901071, 0, 0x00051114, 100, 1,
    1, 32, 0, 4,
    -1, 6, 0,
    49, 6, 4,
    @daring_challenge_icon, 'Daring Challenge Threat',
    'Your attacks against the challenged enemy generate $s1% additional threat.',
    'Attacks against the challenged enemy generate $s1% additional threat.',
    8, 1,
    0, 1.0, 1
FROM DUAL
WHERE @daring_challenge_threat_owned = 0;

SET @daring_challenge_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901070
      AND `Name_Lang_enUS` = 'Daring Challenge'
      AND `Attributes` = 0x00050010
      AND `AttributesEx2` = 0x04000000
      AND `AttributesEx4` = 0x00000800
      AND `AttributesEx6` = 0x00800000
      AND `RecoveryTime` = 10000
      AND `DurationIndex` = 27
      AND `RangeIndex` = 4
      AND `SpellClassSet` = 8
      AND `MaxTargets` = 1
      AND `Effect_1` = 114
      AND `ImplicitTargetA_1` = 6
      AND `Effect_2` = 6
      AND `ImplicitTargetA_2` = 6
      AND `EffectAura_2` = 11
      AND `SpellIconID` = @daring_challenge_icon
);

SET @daring_challenge_threat_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901071
      AND `Name_Lang_enUS` = 'Daring Challenge Threat'
      AND `Attributes` = 0
      AND `ProcTypeMask` = 0x00051114
      AND `ProcChance` = 100
      AND `DurationIndex` = 32
      AND `RangeIndex` = 4
      AND `SpellClassSet` = 8
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = 49
      AND `ImplicitTargetA_1` = 6
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @daring_challenge_icon
);

INSERT INTO `spell_proc` (
    `SpellId`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`,
    `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`, `SpellTypeMask`,
    `SpellPhaseMask`, `HitMask`, `AttributesMask`, `DisableEffectsMask`,
    `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`
) SELECT
    901071, 0, 0, 0,
    0, 0, 0x00051114, 1,
    2, 0, 2, 0,
    0, 100, 0, 0
FROM DUAL
WHERE @daring_challenge_managed = 1
  AND @daring_challenge_threat_managed = 1
ON DUPLICATE KEY UPDATE
    `SchoolMask` = VALUES(`SchoolMask`),
    `SpellFamilyName` = VALUES(`SpellFamilyName`),
    `SpellFamilyMask0` = VALUES(`SpellFamilyMask0`),
    `SpellFamilyMask1` = VALUES(`SpellFamilyMask1`),
    `SpellFamilyMask2` = VALUES(`SpellFamilyMask2`),
    `ProcFlags` = VALUES(`ProcFlags`),
    `SpellTypeMask` = VALUES(`SpellTypeMask`),
    `SpellPhaseMask` = VALUES(`SpellPhaseMask`),
    `HitMask` = VALUES(`HitMask`),
    `AttributesMask` = VALUES(`AttributesMask`),
    `DisableEffectsMask` = VALUES(`DisableEffectsMask`),
    `ProcsPerMinute` = VALUES(`ProcsPerMinute`),
    `Chance` = VALUES(`Chance`),
    `Cooldown` = VALUES(`Cooldown`),
    `Charges` = VALUES(`Charges`);

DELETE FROM `spell_script_names`
WHERE `ScriptName` IN (
    'spell_apoc_rogue_daring_challenge',
    'spell_apoc_rogue_daring_challenge_threat'
);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901070, 'spell_apoc_rogue_daring_challenge'
FROM DUAL
WHERE @daring_challenge_managed = 1
  AND @daring_challenge_threat_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901071, 'spell_apoc_rogue_daring_challenge_threat'
FROM DUAL
WHERE @daring_challenge_managed = 1
  AND @daring_challenge_threat_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901071, 0x01000000
FROM DUAL
WHERE @daring_challenge_threat_managed = 1
ON DUPLICATE KEY UPDATE
    `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `mod_spec_spells` (
    `class`, `spec_index`, `spell_id`, `description`
)
SELECT 4, 1, 901070, 'Daring Challenge'
FROM DUAL
WHERE @daring_challenge_managed = 1
  AND @daring_challenge_threat_managed = 1
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901070, 'Daring Challenge'
FROM DUAL
WHERE @daring_challenge_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901071, 'Daring Challenge Threat'
FROM DUAL
WHERE @daring_challenge_threat_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

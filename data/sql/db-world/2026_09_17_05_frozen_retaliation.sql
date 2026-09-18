SET @frozen_retaliation_r1_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901012
      AND `Name_Lang_enUS` = 'Frozen Retaliation'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00100000
      AND `DurationIndex` = 21
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 3
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @frozen_retaliation_r2_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901013
      AND `Name_Lang_enUS` = 'Frozen Retaliation'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00100000
      AND `DurationIndex` = 21
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 3
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @frozen_retaliation_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901012 AND @frozen_retaliation_r1_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901012 AND @frozen_retaliation_r1_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901012 AND @frozen_retaliation_r1_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901013 AND @frozen_retaliation_r2_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901013 AND @frozen_retaliation_r2_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901013 AND @frozen_retaliation_r2_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `ProcTypeMask`, `DurationIndex`, `RangeIndex`,
    `CumulativeAura`, `SchoolMask`, `SpellClassSet`, `DispelType`,
    `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901012, 0x00000040, 0x00100000, 21, 1,
    1, 16, 3, 0,
    -1, 0, 0,
    6, 0, 0,
    1, 4, 193, 'Frozen Retaliation',
    'Whenever you take damage, you have a 1.5% chance to gain Fingers of Frost.',
    'Damage taken has a 1.5% chance to grant Fingers of Frost.'
FROM DUAL
WHERE @frozen_retaliation_r1_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `ProcTypeMask`, `DurationIndex`, `RangeIndex`,
    `CumulativeAura`, `SchoolMask`, `SpellClassSet`, `DispelType`,
    `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901013, 0x00000040, 0x00100000, 21, 1,
    1, 16, 3, 0,
    -1, 0, 0,
    6, 0, 0,
    1, 4, 193, 'Frozen Retaliation',
    'Whenever you take damage, you have a 3% chance to gain Fingers of Frost.',
    'Damage taken has a 3% chance to grant Fingers of Frost.'
FROM DUAL
WHERE @frozen_retaliation_r2_owned = 0;

SET @frozen_retaliation_r1_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901012
      AND `Name_Lang_enUS` = 'Frozen Retaliation'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00100000
      AND `DurationIndex` = 21
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 3
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @frozen_retaliation_r2_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901013
      AND `Name_Lang_enUS` = 'Frozen Retaliation'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00100000
      AND `DurationIndex` = 21
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 3
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

DELETE FROM `spell_ranks`
WHERE @frozen_retaliation_r1_managed = 1
  AND @frozen_retaliation_r2_managed = 1
  AND (`first_spell_id` = 901012 OR `spell_id` IN (901012, 901013));

INSERT INTO `spell_ranks` (`first_spell_id`, `spell_id`, `rank`)
SELECT 901012, 901012, 1
FROM DUAL
WHERE @frozen_retaliation_r1_managed = 1
  AND @frozen_retaliation_r2_managed = 1;

INSERT INTO `spell_ranks` (`first_spell_id`, `spell_id`, `rank`)
SELECT 901012, 901013, 2
FROM DUAL
WHERE @frozen_retaliation_r1_managed = 1
  AND @frozen_retaliation_r2_managed = 1;

INSERT INTO `spell_proc` (
    `SpellId`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`,
    `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`, `SpellTypeMask`,
    `SpellPhaseMask`, `HitMask`, `AttributesMask`, `DisableEffectsMask`,
    `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`
) SELECT
    901012, 0, 0, 0,
    0, 0, 0x00100000, 0,
    0, 0, 0x00000002, 0,
    0, 1.5, 0, 0
FROM DUAL
WHERE @frozen_retaliation_r1_managed = 1
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

INSERT INTO `spell_proc` (
    `SpellId`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`,
    `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`, `SpellTypeMask`,
    `SpellPhaseMask`, `HitMask`, `AttributesMask`, `DisableEffectsMask`,
    `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`
) SELECT
    901013, 0, 0, 0,
    0, 0, 0x00100000, 0,
    0, 0, 0x00000002, 0,
    0, 3.0, 0, 0
FROM DUAL
WHERE @frozen_retaliation_r2_managed = 1
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

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT -901012, 'spell_apoc_mage_frozen_retaliation'
FROM DUAL
WHERE @frozen_retaliation_r1_managed = 1
  AND @frozen_retaliation_r2_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901012, 'Frozen Retaliation'
FROM DUAL
WHERE @frozen_retaliation_r1_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901013, 'Frozen Retaliation'
FROM DUAL
WHERE @frozen_retaliation_r2_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

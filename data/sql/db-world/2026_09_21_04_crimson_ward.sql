SET @crimson_ward_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901050
      AND `Name_Lang_enUS` = 'Crimson Ward'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00100000
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 15
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = 201
);

SET @crimson_ward_absorb_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901051
      AND `Name_Lang_enUS` = 'Crimson Ward'
      AND `DurationIndex` = 8
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 15
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = 0
      AND `EffectMiscValue_1` = 127
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 69
      AND `SpellIconID` = 201
);

SET @crimson_ward_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901050 AND @crimson_ward_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901050 AND @crimson_ward_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901050 AND @crimson_ward_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901051 AND @crimson_ward_absorb_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901051 AND @crimson_ward_absorb_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901051 AND @crimson_ward_absorb_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `ProcTypeMask`, `ProcChance`, `DurationIndex`,
    `RangeIndex`, `CumulativeAura`, `SchoolMask`, `SpellClassSet`,
    `DispelType`, `EquippedItemClass`, `EquippedItemSubclass`,
    `EquippedItemInvTypes`, `Effect_1`, `EffectDieSides_1`,
    `EffectBasePoints_1`, `ImplicitTargetA_1`, `EffectAura_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`
) SELECT
    901050, 0x00000040, 0x00100000, 100, 21,
    1, 1, 1, 15,
    0, -1, 0,
    0, 6, 0,
    0, 1, 4,
    201, 'Crimson Ward',
    'When you take damage, you gain a non-dispellable shield that absorbs damage equal to 20% of your maximum health for 15 sec. This effect has a 1 min internal cooldown.',
    'Damage taken grants a 20% maximum-health absorb for 15 sec. 1 min internal cooldown.'
FROM DUAL
WHERE @crimson_ward_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `DurationIndex`, `RangeIndex`, `CumulativeAura`, `SchoolMask`,
    `SpellClassSet`, `DispelType`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `EffectMiscValue_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`
) SELECT
    901051, 8, 1, 1, 1,
    15, 0, -1,
    0, 0, 6,
    0, 0, 127,
    1, 69, 201,
    'Crimson Ward',
    'Absorbs damage equal to 20% of the Death Knight\'s maximum health. Lasts 15 sec.',
    'Absorbs all damage.'
FROM DUAL
WHERE @crimson_ward_absorb_owned = 0;

SET @crimson_ward_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901050
      AND `Name_Lang_enUS` = 'Crimson Ward'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00100000
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 15
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = 201
);

SET @crimson_ward_absorb_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901051
      AND `Name_Lang_enUS` = 'Crimson Ward'
      AND `DurationIndex` = 8
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 15
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = 0
      AND `EffectMiscValue_1` = 127
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 69
      AND `SpellIconID` = 201
);

INSERT INTO `spell_proc` (
    `SpellId`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`,
    `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`, `SpellTypeMask`,
    `SpellPhaseMask`, `HitMask`, `AttributesMask`, `DisableEffectsMask`,
    `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`
) SELECT
    901050, 0, 0, 0,
    0, 0, 0x00100000, 0,
    0, 0, 0x00000002, 0,
    0, 100, 60000, 0
FROM DUAL
WHERE @crimson_ward_managed = 1
  AND @crimson_ward_absorb_managed = 1
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
WHERE @crimson_ward_managed = 1
  AND @crimson_ward_absorb_managed = 1
  AND `ScriptName` IN (
      'spell_apoc_death_knight_crimson_ward',
      'spell_apoc_death_knight_crimson_ward_absorb'
  );

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901050, 'spell_apoc_death_knight_crimson_ward'
FROM DUAL
WHERE @crimson_ward_managed = 1
  AND @crimson_ward_absorb_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901051, 'spell_apoc_death_knight_crimson_ward_absorb'
FROM DUAL
WHERE @crimson_ward_managed = 1
  AND @crimson_ward_absorb_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901051, 0x01000000
FROM DUAL
WHERE @crimson_ward_absorb_managed = 1
ON DUPLICATE KEY UPDATE
    `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `mod_spec_spells` (
    `class`, `spec_index`, `spell_id`, `description`
)
SELECT 6, 0, 901050, 'Crimson Ward'
FROM DUAL
WHERE @crimson_ward_managed = 1
  AND @crimson_ward_absorb_managed = 1
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901050, 'Crimson Ward'
FROM DUAL
WHERE @crimson_ward_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901051, 'Crimson Ward'
FROM DUAL
WHERE @crimson_ward_absorb_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

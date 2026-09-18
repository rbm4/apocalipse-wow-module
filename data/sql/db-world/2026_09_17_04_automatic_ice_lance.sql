SET @automatic_ice_lance_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901010
      AND `Name_Lang_enUS` = 'Automatic Ice Lance'
      AND `Attributes` = 0x00000040
      AND `ProcChance` = 10
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 3
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = 10
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @ice_lance_haste_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901011
      AND `Name_Lang_enUS` = 'Ice Lance Momentum'
      AND `DurationIndex` = 1
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 3
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 216
      AND `Effect_2` = 6
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 226
      AND `EffectAuraPeriod_2` = 1000
);

SET @automatic_ice_lance_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901010 AND @automatic_ice_lance_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901010 AND @automatic_ice_lance_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901010 AND @automatic_ice_lance_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901011 AND @ice_lance_haste_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901011 AND @ice_lance_haste_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901011 AND @ice_lance_haste_owned = 0
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
    901010, 0x00000040, 0x00010000, 10, 21,
    1, 1, 16, 3,
    0, -1, 0,
    0, 6, 0,
    9, 1, 4,
    186, 'Automatic Ice Lance',
    'Your direct, non-triggered Frost spell damage has a $s1% chance to cast Ice Lance automatically at the target and grant 1% spell haste for 10 sec. Haste contributions expire independently and can accumulate up to 20%.',
    'Direct Frost spell damage can trigger an automatic Ice Lance.'
FROM DUAL
WHERE @automatic_ice_lance_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `Effect_2`, `EffectDieSides_2`, `EffectBasePoints_2`,
    `ImplicitTargetA_2`, `EffectAura_2`, `EffectAuraPeriod_2`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901011, 0, 1, 1, 1,
    16, 3, 0, -1,
    0, 0, 6,
    0, 0, 1,
    216, 6, 0, 0,
    1, 226, 1000, 186,
    'Ice Lance Momentum',
    'Increases spell casting haste by 1% for each active Automatic Ice Lance contribution. Each contribution lasts 10 sec independently, up to 20%.',
    'Spell casting haste increased by $s1%.'
FROM DUAL
WHERE @ice_lance_haste_owned = 0;

SET @automatic_ice_lance_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901010
      AND `Name_Lang_enUS` = 'Automatic Ice Lance'
      AND `Attributes` = 0x00000040
      AND `ProcChance` = 10
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 3
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = 10
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @ice_lance_haste_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901011
      AND `Name_Lang_enUS` = 'Ice Lance Momentum'
      AND `DurationIndex` = 1
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 3
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 216
      AND `Effect_2` = 6
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 226
      AND `EffectAuraPeriod_2` = 1000
);

INSERT INTO `spell_proc` (
    `SpellId`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`,
    `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`, `SpellTypeMask`,
    `SpellPhaseMask`, `HitMask`, `AttributesMask`, `DisableEffectsMask`,
    `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`
) SELECT
    901010, 16, 3, 0,
    0, 0, 0x00010000, 1,
    2, 0, 0, 0,
    0, 10, 1000, 0
FROM DUAL
WHERE @automatic_ice_lance_managed = 1
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
SELECT 901010, 'spell_apoc_mage_automatic_ice_lance'
FROM DUAL
WHERE @automatic_ice_lance_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901011, 'spell_apoc_mage_ice_lance_haste'
FROM DUAL
WHERE @ice_lance_haste_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901011, 0x01000000
FROM DUAL
WHERE @ice_lance_haste_managed = 1
ON DUPLICATE KEY UPDATE `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901010, 'Automatic Ice Lance'
FROM DUAL
WHERE @automatic_ice_lance_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901011, 'Ice Lance Momentum'
FROM DUAL
WHERE @ice_lance_haste_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

SET @ambush_trapper_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901038
      AND `Name_Lang_enUS` = 'Ambush Trapper'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00200000
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 9
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 42
      AND `EffectTriggerSpell_1` = 901039
      AND `SpellIconID` = 201
);

SET @predators_ambush_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901039
      AND `Name_Lang_enUS` = 'Predator\'s Ambush'
      AND `ProcTypeMask` = 0x00000010
      AND `ProcChance` = 100
      AND `ProcCharges` = 5
      AND `DurationIndex` = 8
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 0
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 9
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = 201
);

SET @ambush_strike_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901040
      AND `Name_Lang_enUS` = 'Ambush Strike'
      AND `RangeIndex` = 13
      AND `SchoolMask` = 1
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 2
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
      AND `EffectMiscValue_1` = 0
      AND `ImplicitTargetA_1` = 6
      AND `SpellIconID` = 201
);

SET @ambush_mana_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901041
      AND `Name_Lang_enUS` = 'Ambush Mana'
      AND `RangeIndex` = 1
      AND `SchoolMask` = 1
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 137
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 4
      AND `EffectMiscValue_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `SpellIconID` = 201
);

SET @ambush_trapper_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901038 AND @ambush_trapper_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901038 AND @ambush_trapper_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901038 AND @ambush_trapper_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901039 AND @predators_ambush_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901039 AND @predators_ambush_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901039 AND @predators_ambush_owned = 0
        UNION ALL
        SELECT 8 FROM `spell_dbc`
        WHERE `ID` = 901040 AND @ambush_strike_owned = 0
        UNION ALL
        SELECT 9 FROM `wotlk_spells_full`
        WHERE `ID` = 901040 AND @ambush_strike_owned = 0
        UNION ALL
        SELECT 10 FROM `wotlk_spells`
        WHERE `ID` = 901040 AND @ambush_strike_owned = 0
        UNION ALL
        SELECT 11 FROM `spell_dbc`
        WHERE `ID` = 901041 AND @ambush_mana_owned = 0
        UNION ALL
        SELECT 12 FROM `wotlk_spells_full`
        WHERE `ID` = 901041 AND @ambush_mana_owned = 0
        UNION ALL
        SELECT 13 FROM `wotlk_spells`
        WHERE `ID` = 901041 AND @ambush_mana_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `ProcTypeMask`, `ProcChance`, `DurationIndex`,
    `RangeIndex`, `CumulativeAura`, `SchoolMask`, `SpellClassSet`,
    `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `EffectTriggerSpell_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`
) SELECT
    901038, 0x00000040, 0x00200000, 100, 21,
    1, 1, 1, 9,
    -1, 0, 0,
    6, 0, 0,
    1, 42, 901039,
    201, 'Ambush Trapper',
    'When one of your traps activates, you gain Predator\'s Ambush for 15 sec with 5 charges.',
    'Trap activation grants Predator\'s Ambush.'
FROM DUAL
WHERE @ambush_trapper_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `ProcTypeMask`, `ProcChance`, `ProcCharges`, `DurationIndex`,
    `RangeIndex`, `CumulativeAura`, `SchoolMask`, `SpellClassSet`,
    `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901039, 0x00000010, 100, 5, 8,
    1, 0, 1, 9,
    -1, 0, 0,
    6, 0, 0,
    1, 4, 201,
    'Predator\'s Ambush',
    'Your next 5 Hunter melee special hits deal additional Physical damage equal to 2% of the target\'s maximum health, capped at 2% of your maximum health, and restore 5% of your maximum mana. Lasts 15 sec.',
    'Hunter melee special hits consume one of 5 charges to deal additional Physical damage and restore mana.'
FROM DUAL
WHERE @predators_ambush_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `RangeIndex`, `SchoolMask`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`
) SELECT
    901040, 13, 1, -1,
    0, 0, 2,
    0, 0, 6,
    201, 'Ambush Strike',
    'Deals Physical damage equal to 2% of the target\'s maximum health, capped at 2% of the Hunter\'s maximum health.'
FROM DUAL
WHERE @ambush_strike_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `RangeIndex`, `SchoolMask`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `EffectMiscValue_1`,
    `ImplicitTargetA_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`
) SELECT
    901041, 1, 1, -1,
    0, 0, 137,
    1, 4, 0,
    1, 201, 'Ambush Mana',
    'Restores 5% of maximum mana.'
FROM DUAL
WHERE @ambush_mana_owned = 0;

SET @ambush_trapper_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901038
      AND `Name_Lang_enUS` = 'Ambush Trapper'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00200000
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 9
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 42
      AND `EffectTriggerSpell_1` = 901039
      AND `SpellIconID` = 201
);

SET @predators_ambush_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901039
      AND `Name_Lang_enUS` = 'Predator\'s Ambush'
      AND `ProcTypeMask` = 0x00000010
      AND `ProcChance` = 100
      AND `ProcCharges` = 5
      AND `DurationIndex` = 8
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 0
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 9
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = 201
);

SET @ambush_strike_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901040
      AND `Name_Lang_enUS` = 'Ambush Strike'
      AND `RangeIndex` = 13
      AND `SchoolMask` = 1
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 2
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
      AND `EffectMiscValue_1` = 0
      AND `ImplicitTargetA_1` = 6
      AND `SpellIconID` = 201
);

SET @ambush_mana_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901041
      AND `Name_Lang_enUS` = 'Ambush Mana'
      AND `RangeIndex` = 1
      AND `SchoolMask` = 1
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 137
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 4
      AND `EffectMiscValue_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `SpellIconID` = 201
);

INSERT INTO `spell_proc` (
    `SpellId`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`,
    `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`, `SpellTypeMask`,
    `SpellPhaseMask`, `HitMask`, `AttributesMask`, `DisableEffectsMask`,
    `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`
) SELECT
    901038, 0, 9, 0,
    0, 0, 0x00200000, 0,
    4, 0, 2, 0,
    0, 100, 0, 0
FROM DUAL
WHERE @ambush_trapper_managed = 1
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
    901039, 0, 9, 0,
    0, 0, 0x00000010, 1,
    2, 0, 0, 0,
    0, 100, 0, 5
FROM DUAL
WHERE @predators_ambush_managed = 1
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
    'spell_apoc_hunter_ambush_trapper',
    'spell_apoc_hunter_predators_ambush'
);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901038, 'spell_apoc_hunter_ambush_trapper'
FROM DUAL
WHERE @ambush_trapper_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901039, 'spell_apoc_hunter_predators_ambush'
FROM DUAL
WHERE @predators_ambush_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901039, 0x01000000
FROM DUAL
WHERE @predators_ambush_managed = 1
ON DUPLICATE KEY UPDATE `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `spell_bonus_data`
    (`entry`, `direct_bonus`, `dot_bonus`, `ap_bonus`, `ap_dot_bonus`, `comments`)
SELECT 901040, 0, 0, 0, 0, 'Hunter - Ambush Strike'
FROM DUAL
WHERE @ambush_strike_managed = 1
ON DUPLICATE KEY UPDATE
    `direct_bonus` = VALUES(`direct_bonus`),
    `dot_bonus` = VALUES(`dot_bonus`),
    `ap_bonus` = VALUES(`ap_bonus`),
    `ap_dot_bonus` = VALUES(`ap_dot_bonus`),
    `comments` = VALUES(`comments`);

INSERT INTO `mod_spell_scaling`
    (`spell_id`, `scale_type`, `scale_factor`, `description`)
SELECT 901040, 'DAMAGE', 1.0,
    'Ambush Strike - capped percent-health physical damage'
FROM DUAL
WHERE @ambush_strike_managed = 1
ON DUPLICATE KEY UPDATE
    `scale_factor` = VALUES(`scale_factor`),
    `description` = VALUES(`description`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901038, 'Ambush Trapper'
FROM DUAL
WHERE @ambush_trapper_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901039, 'Predator\'s Ambush'
FROM DUAL
WHERE @predators_ambush_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901040, 'Ambush Strike'
FROM DUAL
WHERE @ambush_strike_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901041, 'Ambush Mana'
FROM DUAL
WHERE @ambush_mana_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

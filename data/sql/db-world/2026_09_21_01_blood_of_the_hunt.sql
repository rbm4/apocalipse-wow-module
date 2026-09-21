SET @blood_of_the_hunt_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901044
      AND `Name_Lang_enUS` = 'Blood of the Hunt'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00200010
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 9
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = 201
);

SET @blood_heal_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901045
      AND `Name_Lang_enUS` = 'Blood Heal'
      AND `RangeIndex` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 9
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 10
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
      AND `EffectMiscValue_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `SpellIconID` = 201
);

SET @blood_of_the_hunt_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901044 AND @blood_of_the_hunt_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901044 AND @blood_of_the_hunt_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901044 AND @blood_of_the_hunt_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901045 AND @blood_heal_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901045 AND @blood_heal_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901045 AND @blood_heal_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `ProcTypeMask`, `ProcChance`, `DurationIndex`,
    `RangeIndex`, `CumulativeAura`, `SchoolMask`, `SpellClassSet`,
    `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901044, 0x00000040, 0x00200010, 100, 21,
    1, 1, 1, 9,
    -1, 0, 0,
    6, 0, 0,
    1, 4, 201,
    'Blood of the Hunt',
    'Your successful Hunter melee special hits heal you for 15% of the damage dealt, and your trap activations heal you for 5% of your maximum health. This effect has a 2 sec internal cooldown.',
    'Hunter melee specials and trap activations heal you. 2 sec internal cooldown.'
FROM DUAL
WHERE @blood_of_the_hunt_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `RangeIndex`, `SchoolMask`, `SpellClassSet`,
    `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `EffectMiscValue_1`, `ImplicitTargetA_1`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`
) SELECT
    901045, 1, 1, 9,
    -1, 0, 0,
    10, 0, 0,
    0, 1, 201,
    'Blood Heal', 'Restores health based on Blood of the Hunt.'
FROM DUAL
WHERE @blood_heal_owned = 0;

SET @blood_of_the_hunt_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901044
      AND `Name_Lang_enUS` = 'Blood of the Hunt'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00200010
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 9
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = 201
);

SET @blood_heal_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901045
      AND `Name_Lang_enUS` = 'Blood Heal'
      AND `RangeIndex` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 9
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 10
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
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
    901044, 0, 9, 0,
    0, 0, 0x00200010, 0,
    6, 0, 2, 0,
    0, 100, 2000, 0
FROM DUAL
WHERE @blood_of_the_hunt_managed = 1
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
WHERE `ScriptName` = 'spell_apoc_hunter_blood_of_the_hunt';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901044, 'spell_apoc_hunter_blood_of_the_hunt'
FROM DUAL
WHERE @blood_of_the_hunt_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_bonus_data`
    (`entry`, `direct_bonus`, `dot_bonus`, `ap_bonus`, `ap_dot_bonus`, `comments`)
SELECT 901045, 0, 0, 0, 0, 'Hunter - Blood Heal'
FROM DUAL
WHERE @blood_heal_managed = 1
ON DUPLICATE KEY UPDATE
    `direct_bonus` = VALUES(`direct_bonus`),
    `dot_bonus` = VALUES(`dot_bonus`),
    `ap_bonus` = VALUES(`ap_bonus`),
    `ap_dot_bonus` = VALUES(`ap_dot_bonus`),
    `comments` = VALUES(`comments`);

INSERT INTO `mod_spell_scaling`
    (`spell_id`, `scale_type`, `scale_factor`, `description`)
SELECT 901045, 'HEAL', 1.0,
    'Blood Heal - damage or maximum-health based self-heal'
FROM DUAL
WHERE @blood_heal_managed = 1
ON DUPLICATE KEY UPDATE
    `scale_factor` = VALUES(`scale_factor`),
    `description` = VALUES(`description`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901044, 'Blood of the Hunt'
FROM DUAL
WHERE @blood_of_the_hunt_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901045, 'Blood Heal'
FROM DUAL
WHERE @blood_heal_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

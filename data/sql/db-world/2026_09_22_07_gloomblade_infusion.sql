SET @gloomblade_infusion_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 51713
), 0);

SET @gloomblade_infusion_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901079
      AND `Name_Lang_enUS` = 'Gloomblade Infusion'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00051154
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 32
      AND `SpellClassSet` = 8
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 9
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @gloomblade_infusion_icon
);

SET @gloomblade_infusion_damage_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901080
      AND `Name_Lang_enUS` = 'Gloomblade Infusion Damage'
      AND `AttributesEx2` = 0x20000000
      AND `RangeIndex` = 13
      AND `SchoolMask` = 32
      AND `SpellClassSet` = 0
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 2
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 6
      AND `SpellIconID` = @gloomblade_infusion_icon
      AND `DefenseType` = 1
);

SET @gloomblade_infusion_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901079 AND @gloomblade_infusion_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901079 AND @gloomblade_infusion_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901079 AND @gloomblade_infusion_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901080
          AND @gloomblade_infusion_damage_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901080
          AND @gloomblade_infusion_damage_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901080
          AND @gloomblade_infusion_damage_owned = 0
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
    901079, 0x00000040, 0x00051154, 100, 21,
    1, 1, 32, 8,
    0, -1, 0,
    0, 6, 0,
    9, 1, 4,
    @gloomblade_infusion_icon, 'Gloomblade Infusion',
    'Each time you deal damage, you deal an additional 10% of the damage dealt as separate Shadow damage. Includes Rogue abilities and poisons.',
    'Damage dealt triggers additional Shadow damage.'
FROM DUAL
WHERE @gloomblade_infusion_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `AttributesEx2`, `RangeIndex`, `SchoolMask`, `SpellClassSet`,
    `DispelType`, `EquippedItemClass`, `EquippedItemSubclass`,
    `EquippedItemInvTypes`, `Effect_1`, `EffectDieSides_1`,
    `EffectBasePoints_1`, `ImplicitTargetA_1`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`, `DefenseType`
) SELECT
    901080, 0x20000000, 13, 32, 0,
    0, -1, 0,
    0, 2, 0,
    0, 6, @gloomblade_infusion_icon,
    'Gloomblade Infusion Damage',
    'Deals Shadow damage based on Gloomblade Infusion.', 1
FROM DUAL
WHERE @gloomblade_infusion_damage_owned = 0;

SET @gloomblade_infusion_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901079
      AND `Name_Lang_enUS` = 'Gloomblade Infusion'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00051154
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 32
      AND `SpellClassSet` = 8
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 9
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @gloomblade_infusion_icon
);

SET @gloomblade_infusion_damage_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901080
      AND `Name_Lang_enUS` = 'Gloomblade Infusion Damage'
      AND `AttributesEx2` = 0x20000000
      AND `RangeIndex` = 13
      AND `SchoolMask` = 32
      AND `SpellClassSet` = 0
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 2
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 6
      AND `SpellIconID` = @gloomblade_infusion_icon
      AND `DefenseType` = 1
);

INSERT INTO `spell_proc` (
    `SpellId`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`,
    `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`, `SpellTypeMask`,
    `SpellPhaseMask`, `HitMask`, `AttributesMask`, `DisableEffectsMask`,
    `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`
) SELECT
    901079, 0, 0, 0,
    0, 0, 0x00051154, 1,
    2, 0, 2, 0,
    0, 100, 0, 0
FROM DUAL
WHERE @gloomblade_infusion_managed = 1
  AND @gloomblade_infusion_damage_managed = 1
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
WHERE `ScriptName` = 'spell_apoc_rogue_gloomblade_infusion';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901079, 'spell_apoc_rogue_gloomblade_infusion'
FROM DUAL
WHERE @gloomblade_infusion_managed = 1
  AND @gloomblade_infusion_damage_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

DELETE FROM `spell_bonus_data`
WHERE `entry` = 901080
  AND @gloomblade_infusion_damage_managed = 1;

INSERT INTO `mod_spec_spells` (
    `class`, `spec_index`, `spell_id`, `description`
)
SELECT 4, 2, 901079, 'Gloomblade Infusion'
FROM DUAL
WHERE @gloomblade_infusion_managed = 1
  AND @gloomblade_infusion_damage_managed = 1
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901079, 'Gloomblade Infusion'
FROM DUAL
WHERE @gloomblade_infusion_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901080, 'Gloomblade Infusion Damage'
FROM DUAL
WHERE @gloomblade_infusion_damage_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

SET @concentrated_venom_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 2818
), 0);

SET @concentrated_venom_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901061
      AND `Name_Lang_enUS` = 'Concentrated Venom'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00011000
      AND `ProcChance` = 30
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 8
      AND `SpellClassSet` = 8
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 29
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @concentrated_venom_icon
);

SET @concentrated_venom_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901061 AND @concentrated_venom_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901061 AND @concentrated_venom_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901061 AND @concentrated_venom_owned = 0
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
    901061, 0x00000040, 0x00011000, 30, 21,
    1, 1, 8, 8,
    0, -1, 0,
    0, 6, 0,
    29, 1, 4,
    @concentrated_venom_icon, 'Concentrated Venom',
    'Successful weapon-poison applications have a $s1% chance to apply one additional stack of the highest-rank Deadly Poison on your equipped weapons. This can occur once per target every 1 sec.',
    'Weapon-poison applications can add an extra Deadly Poison stack.'
FROM DUAL
WHERE @concentrated_venom_owned = 0;

SET @concentrated_venom_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901061
      AND `Name_Lang_enUS` = 'Concentrated Venom'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00011000
      AND `ProcChance` = 30
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 8
      AND `SpellClassSet` = 8
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 29
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @concentrated_venom_icon
);

INSERT INTO `spell_proc` (
    `SpellId`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`,
    `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`, `SpellTypeMask`,
    `SpellPhaseMask`, `HitMask`, `AttributesMask`, `DisableEffectsMask`,
    `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`
) SELECT
    901061, 0, 8, 0,
    0, 0, 0x00011000, 5,
    2, 0x00000403, 2, 0,
    0, 30, 0, 0
FROM DUAL
WHERE @concentrated_venom_managed = 1
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
WHERE `ScriptName` = 'spell_apoc_rogue_concentrated_venom';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901061, 'spell_apoc_rogue_concentrated_venom'
FROM DUAL
WHERE @concentrated_venom_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `mod_spec_spells` (
    `class`, `spec_index`, `spell_id`, `description`
)
SELECT 4, 0, 901061, 'Concentrated Venom'
FROM DUAL
WHERE @concentrated_venom_managed = 1
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901061, 'Concentrated Venom'
FROM DUAL
WHERE @concentrated_venom_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

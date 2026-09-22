SET @necrotic_veil_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 48707
), 201);

SET @necrotic_veil_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901056
      AND `Name_Lang_enUS` = 'Necrotic Veil'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00051114
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 32
      AND `SpellClassSet` = 15
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 9
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @necrotic_veil_icon
);

SET @necrotic_veil_absorb_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901057
      AND `Name_Lang_enUS` = 'Necrotic Veil'
      AND `AttributesEx4` = 0x00000040
      AND `DurationIndex` = 3
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 32
      AND `SpellClassSet` = 15
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
      AND `EffectMiscValue_1` = 126
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 69
      AND `SpellIconID` = @necrotic_veil_icon
);

SET @necrotic_veil_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901056 AND @necrotic_veil_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901056 AND @necrotic_veil_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901056 AND @necrotic_veil_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901057 AND @necrotic_veil_absorb_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901057 AND @necrotic_veil_absorb_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901057 AND @necrotic_veil_absorb_owned = 0
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
    901056, 0x00000040, 0x00051114, 100, 21,
    1, 1, 32, 15,
    0, -1, 0,
    0, 6, 1,
    9, 1, 4,
    @necrotic_veil_icon, 'Necrotic Veil',
    'Each time you deal damage, 10% of the damage dealt is added to Necrotic Veil, which absorbs only magic damage. The absorb cannot exceed 35% of your maximum health and lasts 1 min.',
    'Damage dealt builds a magic-only absorb up to 35% of maximum health.'
FROM DUAL
WHERE @necrotic_veil_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `AttributesEx4`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `EffectMiscValue_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`
) SELECT
    901057, 0x00000040, 3, 1, 1,
    32, 15, 0, -1,
    0, 0, 6,
    0, 0, 126,
    1, 69, @necrotic_veil_icon,
    'Necrotic Veil',
    'Absorbs magic damage. Damage dealt adds 10% of that damage to the remaining absorb, up to 35% of the Death Knight\'s maximum health. Lasts 1 min.',
    'Absorbs magic damage.'
FROM DUAL
WHERE @necrotic_veil_absorb_owned = 0;

SET @necrotic_veil_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901056
      AND `Name_Lang_enUS` = 'Necrotic Veil'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00051114
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 32
      AND `SpellClassSet` = 15
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 9
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @necrotic_veil_icon
);

SET @necrotic_veil_absorb_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901057
      AND `Name_Lang_enUS` = 'Necrotic Veil'
      AND `AttributesEx4` = 0x00000040
      AND `DurationIndex` = 3
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 32
      AND `SpellClassSet` = 15
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
      AND `EffectMiscValue_1` = 126
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 69
      AND `SpellIconID` = @necrotic_veil_icon
);

INSERT INTO `spell_proc` (
    `SpellId`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`,
    `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`, `SpellTypeMask`,
    `SpellPhaseMask`, `HitMask`, `AttributesMask`, `DisableEffectsMask`,
    `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`
) SELECT
    901056, 0, 0, 0,
    0, 0, 0x00051114, 1,
    2, 0, 2, 0,
    0, 100, 0, 0
FROM DUAL
WHERE @necrotic_veil_managed = 1
  AND @necrotic_veil_absorb_managed = 1
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
WHERE `ScriptName` = 'spell_apoc_death_knight_necrotic_veil';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901056, 'spell_apoc_death_knight_necrotic_veil'
FROM DUAL
WHERE @necrotic_veil_managed = 1
  AND @necrotic_veil_absorb_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901057, 0x01000000
FROM DUAL
WHERE @necrotic_veil_absorb_managed = 1
ON DUPLICATE KEY UPDATE
    `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `mod_spec_spells` (
    `class`, `spec_index`, `spell_id`, `description`
)
SELECT 6, 2, 901056, 'Necrotic Veil'
FROM DUAL
WHERE @necrotic_veil_managed = 1
  AND @necrotic_veil_absorb_managed = 1
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901056, 'Necrotic Veil'
FROM DUAL
WHERE @necrotic_veil_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901057, 'Necrotic Veil'
FROM DUAL
WHERE @necrotic_veil_absorb_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

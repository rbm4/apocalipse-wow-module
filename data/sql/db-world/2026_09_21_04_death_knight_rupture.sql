SET @death_knight_rupture_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 55050
), 3145);

SET @death_knight_rupture_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901048
      AND `Name_Lang_enUS` = 'Rupture'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00000014
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 15
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @death_knight_rupture_bleed_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901049
      AND `Name_Lang_enUS` = 'Rupture Bleed'
      AND `Mechanic` = 15
      AND `DurationIndex` = 8
      AND `CumulativeAura` = 200
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 15
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 0
      AND `EffectMechanic_1` = 15
      AND `ImplicitTargetA_1` = 6
      AND `EffectAura_1` = 3
      AND `EffectAuraPeriod_1` = 2000
);

SET @death_knight_rupture_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901048 AND @death_knight_rupture_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901048 AND @death_knight_rupture_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901048 AND @death_knight_rupture_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901049 AND @death_knight_rupture_bleed_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901049 AND @death_knight_rupture_bleed_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901049 AND @death_knight_rupture_bleed_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `ProcTypeMask`, `ProcChance`, `DurationIndex`,
    `RangeIndex`, `CumulativeAura`, `SchoolMask`, `SpellClassSet`,
    `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901048, 0x00000040, 0x00000014, 100, 21,
    1, 1, 1, 15,
    -1, 0, 0,
    6, 0, 0,
    1, 4, @death_knight_rupture_icon, 'Rupture',
    'Your melee hits, including critical hits, rupture the target for a small amount of Physical damage every 2 sec for 15 sec. Blood Strike, Heart Strike, and Death Strike apply Rupture to every target hit.',
    'Melee attacks and selected Blood strikes apply a stacking Physical bleed.'
FROM DUAL
WHERE @death_knight_rupture_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `Mechanic`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `EffectMechanic_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `EffectAuraPeriod_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`
) SELECT
    901049, 15, 8, 15, 200,
    1, 15, -1,
    0, 0, 6,
    1, 0, 15,
    6, 3, 2000,
    @death_knight_rupture_icon, 'Rupture Bleed',
    'Deals stacking Physical damage every 2 sec for 15 sec.',
    'Bleeding for Physical damage every 2 sec.'
FROM DUAL
WHERE @death_knight_rupture_bleed_owned = 0;

SET @death_knight_rupture_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901048
      AND `Name_Lang_enUS` = 'Rupture'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00000014
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 15
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @death_knight_rupture_bleed_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901049
      AND `Name_Lang_enUS` = 'Rupture Bleed'
      AND `Mechanic` = 15
      AND `DurationIndex` = 8
      AND `CumulativeAura` = 200
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 15
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 0
      AND `EffectMechanic_1` = 15
      AND `ImplicitTargetA_1` = 6
      AND `EffectAura_1` = 3
      AND `EffectAuraPeriod_1` = 2000
);

INSERT INTO `spell_proc` (
    `SpellId`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`,
    `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`, `SpellTypeMask`,
    `SpellPhaseMask`, `HitMask`, `AttributesMask`, `DisableEffectsMask`,
    `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`
) SELECT
    901048, 0, 0, 0,
    0, 0, 0x00000014, 1,
    2, 3, 2, 0,
    0, 100, 0, 0
FROM DUAL
WHERE @death_knight_rupture_managed = 1
  AND @death_knight_rupture_bleed_managed = 1
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
SELECT 901048, 'spell_apoc_death_knight_rupture'
FROM DUAL
WHERE @death_knight_rupture_managed = 1
  AND @death_knight_rupture_bleed_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_bonus_data`
    (`entry`, `direct_bonus`, `dot_bonus`, `ap_bonus`, `ap_dot_bonus`, `comments`)
SELECT 901049, 0, 0, 0, 0.005, 'Death Knight - Rupture Bleed'
FROM DUAL
WHERE @death_knight_rupture_bleed_managed = 1
ON DUPLICATE KEY UPDATE
    `direct_bonus` = VALUES(`direct_bonus`),
    `dot_bonus` = VALUES(`dot_bonus`),
    `ap_bonus` = VALUES(`ap_bonus`),
    `ap_dot_bonus` = VALUES(`ap_dot_bonus`),
    `comments` = VALUES(`comments`);

INSERT INTO `mod_spell_scaling`
    (`spell_id`, `scale_type`, `scale_factor`, `description`)
SELECT 901049, 'PERIODIC', 1.0,
    'Rupture Bleed - stacking Physical periodic damage'
FROM DUAL
WHERE @death_knight_rupture_bleed_managed = 1
ON DUPLICATE KEY UPDATE
    `scale_factor` = VALUES(`scale_factor`),
    `description` = VALUES(`description`);

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901049, 0x01000000
FROM DUAL
WHERE @death_knight_rupture_bleed_managed = 1
ON DUPLICATE KEY UPDATE
    `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `mod_spec_spells` (
    `class`, `spec_index`, `spell_id`, `description`
)
SELECT 6, 0, 901048, 'Rupture'
FROM DUAL
WHERE @death_knight_rupture_managed = 1
  AND @death_knight_rupture_bleed_managed = 1
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901048, 'Rupture'
FROM DUAL
WHERE @death_knight_rupture_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901049, 'Rupture Bleed'
FROM DUAL
WHERE @death_knight_rupture_bleed_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

SET @leeching_mixture_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 2818
), 137);

SET @leeching_mixture_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901075
      AND `Name_Lang_enUS` = 'Leeching Mixture'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00051114
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 8
      AND `SpellClassSet` = 8
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @leeching_mixture_icon
);

SET @leeching_mixture_heal_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901076
      AND `Name_Lang_enUS` = 'Leeching Mixture Heal'
      AND `AttributesEx2` = 0x20000000
      AND `RangeIndex` = 1
      AND `SchoolMask` = 8
      AND `SpellClassSet` = 8
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 10
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
      AND `EffectMiscValue_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `SpellIconID` = @leeching_mixture_icon
);

SET @leeching_mixture_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901075 AND @leeching_mixture_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901075 AND @leeching_mixture_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901075 AND @leeching_mixture_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901076 AND @leeching_mixture_heal_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901076 AND @leeching_mixture_heal_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901076 AND @leeching_mixture_heal_owned = 0
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
    901075, 0x00000040, 0x00051114, 100, 21,
    1, 1, 8, 8,
    0, -1, 0,
    0, 6, 0,
    0, 1, 4,
    @leeching_mixture_icon, 'Leeching Mixture',
    'Your Deadly Poison, Instant Poison, Wound Poison, and custom Rogue poison damage heals you for 8% of the damage dealt, up to 2% of your maximum health per second. Reflected damage and damage dealt by other Rogues do not trigger this effect.',
    'Rogue poison damage heals you, up to 2% of maximum health per second.'
FROM DUAL
WHERE @leeching_mixture_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `AttributesEx2`, `RangeIndex`, `SchoolMask`, `SpellClassSet`,
    `DispelType`, `EquippedItemClass`, `EquippedItemSubclass`,
    `EquippedItemInvTypes`, `Effect_1`, `EffectDieSides_1`,
    `EffectBasePoints_1`, `EffectMiscValue_1`, `ImplicitTargetA_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`
) SELECT
    901076, 0x20000000, 1, 8, 8,
    0, -1, 0,
    0, 10, 0,
    0, 0, 1,
    @leeching_mixture_icon, 'Leeching Mixture Heal',
    'Restores health based on Leeching Mixture.'
FROM DUAL
WHERE @leeching_mixture_heal_owned = 0;

SET @leeching_mixture_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901075
      AND `Name_Lang_enUS` = 'Leeching Mixture'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00051114
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 8
      AND `SpellClassSet` = 8
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @leeching_mixture_icon
);

SET @leeching_mixture_heal_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901076
      AND `Name_Lang_enUS` = 'Leeching Mixture Heal'
      AND `AttributesEx2` = 0x20000000
      AND `RangeIndex` = 1
      AND `SchoolMask` = 8
      AND `SpellClassSet` = 8
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 10
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
      AND `EffectMiscValue_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `SpellIconID` = @leeching_mixture_icon
);

INSERT INTO `spell_proc` (
    `SpellId`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`,
    `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`, `SpellTypeMask`,
    `SpellPhaseMask`, `HitMask`, `AttributesMask`, `DisableEffectsMask`,
    `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`
) SELECT
    901075, 0, 8, 0,
    0, 0, 0x00051114, 1,
    2, 0, 2, 0,
    0, 100, 0, 0
FROM DUAL
WHERE @leeching_mixture_managed = 1
  AND @leeching_mixture_heal_managed = 1
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
WHERE `ScriptName` = 'spell_apoc_rogue_leeching_mixture';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901075, 'spell_apoc_rogue_leeching_mixture'
FROM DUAL
WHERE @leeching_mixture_managed = 1
  AND @leeching_mixture_heal_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

DELETE FROM `spell_bonus_data`
WHERE `entry` = 901076
  AND @leeching_mixture_heal_managed = 1;

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901075, 'Leeching Mixture'
FROM DUAL
WHERE @leeching_mixture_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901076, 'Leeching Mixture Heal'
FROM DUAL
WHERE @leeching_mixture_heal_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

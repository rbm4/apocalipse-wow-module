SET @bladeguard_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 12750
), 146);

SET @bladeguard_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901073
      AND `Name_Lang_enUS` = 'Bladeguard'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x000002A8
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 8
      AND `DispelType` = 0
      AND `EquippedItemClass` = 4
      AND `EquippedItemSubclass` = 64
      AND `EquippedItemInvTypes` = 16384
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 129
      AND `EffectMiscValue_1` = 1
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 142
      AND `Effect_2` = 6
      AND `EffectDieSides_2` = 1
      AND `EffectBasePoints_2` = 14
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 51
      AND `Effect_3` = 6
      AND `EffectDieSides_3` = 0
      AND `EffectBasePoints_3` = 0
      AND `ImplicitTargetA_3` = 1
      AND `EffectAura_3` = 42
      AND `EffectTriggerSpell_3` = 901074
      AND `SpellIconID` = @bladeguard_icon
);

SET @bladeguard_energize_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901074
      AND `Name_Lang_enUS` = 'Bladeguard Energize'
      AND `AttributesEx2` = 0x20000000
      AND `RangeIndex` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 8
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 30
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 4
      AND `EffectMiscValue_1` = 3
      AND `ImplicitTargetA_1` = 1
      AND `SpellIconID` = @bladeguard_icon
);

SET @bladeguard_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901073 AND @bladeguard_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901073 AND @bladeguard_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901073 AND @bladeguard_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901074 AND @bladeguard_energize_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901074 AND @bladeguard_energize_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901074 AND @bladeguard_energize_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `ProcTypeMask`, `ProcChance`, `DurationIndex`,
    `RangeIndex`, `CumulativeAura`, `SchoolMask`, `SpellClassSet`,
    `DispelType`, `EquippedItemClass`, `EquippedItemSubclass`,
    `EquippedItemInvTypes`, `Effect_1`, `EffectDieSides_1`,
    `EffectBasePoints_1`, `EffectMiscValue_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `Effect_2`, `EffectDieSides_2`, `EffectBasePoints_2`,
    `ImplicitTargetA_2`, `EffectAura_2`, `Effect_3`, `EffectDieSides_3`,
    `EffectBasePoints_3`, `ImplicitTargetA_3`, `EffectAura_3`,
    `EffectTriggerSpell_3`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901073, 0x00000040, 0x000002A8, 100, 21,
    1, 1, 1, 8,
    0, 4, 64,
    16384, 6, 1,
    129, 1, 1,
    142, 6, 1, 14,
    1, 51, 6, 0,
    0, 1, 42,
    901074, @bladeguard_icon, 'Bladeguard',
    'While you have a shield equipped, increases armor from equipped items by $s1% and block chance by $s2%. Successful blocks restore 5 Energy. This can occur once per second.',
    'Armor from equipped items increased by $s1% and block chance increased by $s2%. Successful blocks restore Energy.'
FROM DUAL
WHERE @bladeguard_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `AttributesEx2`, `RangeIndex`, `SchoolMask`, `SpellClassSet`,
    `DispelType`, `EquippedItemClass`, `EquippedItemSubclass`,
    `EquippedItemInvTypes`, `Effect_1`, `EffectDieSides_1`,
    `EffectBasePoints_1`, `EffectMiscValue_1`, `ImplicitTargetA_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`
) SELECT
    901074, 0x20000000, 1, 1, 8,
    0, -1, 0,
    0, 30, 1,
    4, 3, 1,
    @bladeguard_icon, 'Bladeguard Energize',
    'Restores 5 Energy.'
FROM DUAL
WHERE @bladeguard_energize_owned = 0;

SET @bladeguard_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901073
      AND `Name_Lang_enUS` = 'Bladeguard'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x000002A8
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 8
      AND `DispelType` = 0
      AND `EquippedItemClass` = 4
      AND `EquippedItemSubclass` = 64
      AND `EquippedItemInvTypes` = 16384
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 129
      AND `EffectMiscValue_1` = 1
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 142
      AND `Effect_2` = 6
      AND `EffectDieSides_2` = 1
      AND `EffectBasePoints_2` = 14
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 51
      AND `Effect_3` = 6
      AND `EffectDieSides_3` = 0
      AND `EffectBasePoints_3` = 0
      AND `ImplicitTargetA_3` = 1
      AND `EffectAura_3` = 42
      AND `EffectTriggerSpell_3` = 901074
      AND `SpellIconID` = @bladeguard_icon
);

SET @bladeguard_energize_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901074
      AND `Name_Lang_enUS` = 'Bladeguard Energize'
      AND `AttributesEx2` = 0x20000000
      AND `RangeIndex` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 8
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 30
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 4
      AND `EffectMiscValue_1` = 3
      AND `ImplicitTargetA_1` = 1
      AND `SpellIconID` = @bladeguard_icon
);

INSERT INTO `spell_proc` (
    `SpellId`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`,
    `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`, `SpellTypeMask`,
    `SpellPhaseMask`, `HitMask`, `AttributesMask`, `DisableEffectsMask`,
    `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`
) SELECT
    901073, 0, 0, 0,
    0, 0, 0x000002A8, 0,
    2, 0x00000040, 0, 0,
    0, 100, 1000, 0
FROM DUAL
WHERE @bladeguard_managed = 1
  AND @bladeguard_energize_managed = 1
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

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901073, 'Bladeguard'
FROM DUAL
WHERE @bladeguard_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901074, 'Bladeguard Energize'
FROM DUAL
WHERE @bladeguard_energize_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

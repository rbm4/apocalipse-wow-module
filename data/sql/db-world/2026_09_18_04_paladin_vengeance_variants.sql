SET @guardians_vengeance_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901018
      AND `Name_Lang_enUS` = 'Guardian\'s Vengeance'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00051114
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `SchoolMask` = 2
      AND `SpellClassSet` = 10
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 42
      AND `EffectTriggerSpell_1` = 901019
);

SET @guardians_resolve_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901019
      AND `Name_Lang_enUS` = 'Guardian\'s Resolve'
      AND `AttributesEx4` = 0x00000040
      AND `DurationIndex` = 31
      AND `CumulativeAura` = 3
      AND `SchoolMask` = 2
      AND `SpellClassSet` = 10
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = -2
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 87
      AND `EffectMiscValue_1` = 127
      AND `Effect_2` = 6
      AND `EffectDieSides_2` = 1
      AND `EffectBasePoints_2` = 9
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 189
      AND `EffectMiscValue_2` = 2
);

SET @sacred_vengeance_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901020
      AND `Name_Lang_enUS` = 'Sacred Vengeance'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00044400
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `SchoolMask` = 2
      AND `SpellClassSet` = 10
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 42
      AND `EffectTriggerSpell_1` = 901021
);

SET @sacred_fervor_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901021
      AND `Name_Lang_enUS` = 'Sacred Fervor'
      AND `AttributesEx4` = 0x00000040
      AND `DurationIndex` = 31
      AND `CumulativeAura` = 3
      AND `SchoolMask` = 2
      AND `SpellClassSet` = 10
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 1
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 136
      AND `Effect_2` = 6
      AND `EffectDieSides_2` = 1
      AND `EffectBasePoints_2` = 9
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 85
      AND `EffectMiscValue_2` = 0
);

SET @paladin_vengeance_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901018 AND @guardians_vengeance_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901018 AND @guardians_vengeance_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901018 AND @guardians_vengeance_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901019 AND @guardians_resolve_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901019 AND @guardians_resolve_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901019 AND @guardians_resolve_owned = 0
        UNION ALL
        SELECT 8 FROM `spell_dbc`
        WHERE `ID` = 901020 AND @sacred_vengeance_owned = 0
        UNION ALL
        SELECT 9 FROM `wotlk_spells_full`
        WHERE `ID` = 901020 AND @sacred_vengeance_owned = 0
        UNION ALL
        SELECT 10 FROM `wotlk_spells`
        WHERE `ID` = 901020 AND @sacred_vengeance_owned = 0
        UNION ALL
        SELECT 11 FROM `spell_dbc`
        WHERE `ID` = 901021 AND @sacred_fervor_owned = 0
        UNION ALL
        SELECT 12 FROM `wotlk_spells_full`
        WHERE `ID` = 901021 AND @sacred_fervor_owned = 0
        UNION ALL
        SELECT 13 FROM `wotlk_spells`
        WHERE `ID` = 901021 AND @sacred_fervor_owned = 0
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
    901018, 0x00000040, 0x00051114, 100, 21,
    1, 1, 2, 10,
    -1, 0, 0,
    6, 0, 0,
    1, 42, 901019,
    84, 'Guardian\'s Vengeance',
    'Your melee and damaging spell critical hits grant Guardian\'s Resolve for 8 sec, stacking up to 3 times. Each stack reduces all damage taken by 1% and increases defense rating by 10.',
    'Critical melee and damaging spell hits grant Guardian\'s Resolve.'
FROM DUAL
WHERE @guardians_vengeance_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `AttributesEx4`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `EffectMiscValue_1`, `Effect_2`, `EffectDieSides_2`,
    `EffectBasePoints_2`, `ImplicitTargetA_2`, `EffectAura_2`,
    `EffectMiscValue_2`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901019, 0x00000040, 31, 1, 3,
    2, 10, -1,
    0, 0, 6,
    1, -2, 1,
    87, 127, 6, 1,
    9, 1, 189,
    2, 84, 'Guardian\'s Resolve',
    'Reduces all damage taken by 1% and increases defense rating by 10 per stack. Lasts 8 sec and stacks up to 3 times.',
    'Damage taken reduced by $s1%. Defense rating increased by $s2. $u stacks.'
FROM DUAL
WHERE @guardians_resolve_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `ProcTypeMask`, `ProcChance`, `DurationIndex`,
    `RangeIndex`, `CumulativeAura`, `SchoolMask`, `SpellClassSet`,
    `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `EffectTriggerSpell_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`
) SELECT
    901020, 0x00000040, 0x00044400, 100, 21,
    1, 1, 2, 10,
    -1, 0, 0,
    6, 0, 0,
    1, 42, 901021,
    84, 'Sacred Vengeance',
    'Your direct or periodic healing critical hits grant Sacred Fervor for 8 sec, stacking up to 3 times. Each stack increases healing done by 2% and restores 10 mana per 5 sec.',
    'Critical healing grants Sacred Fervor.'
FROM DUAL
WHERE @sacred_vengeance_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `AttributesEx4`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `Effect_2`, `EffectDieSides_2`, `EffectBasePoints_2`,
    `ImplicitTargetA_2`, `EffectAura_2`, `EffectMiscValue_2`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`
) SELECT
    901021, 0x00000040, 31, 1, 3,
    2, 10, -1,
    0, 0, 6,
    1, 1, 1,
    136, 6, 1, 9,
    1, 85, 0,
    84, 'Sacred Fervor',
    'Increases healing done by 2% and restores 10 mana per 5 sec per stack. Lasts 8 sec and stacks up to 3 times.',
    'Healing done increased by $s1%. Restores $s2 mana per 5 sec. $u stacks.'
FROM DUAL
WHERE @sacred_fervor_owned = 0;

SET @guardians_vengeance_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901018
      AND `Name_Lang_enUS` = 'Guardian\'s Vengeance'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00051114
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `SchoolMask` = 2
      AND `SpellClassSet` = 10
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 42
      AND `EffectTriggerSpell_1` = 901019
);

SET @guardians_resolve_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901019
      AND `Name_Lang_enUS` = 'Guardian\'s Resolve'
      AND `AttributesEx4` = 0x00000040
      AND `DurationIndex` = 31
      AND `CumulativeAura` = 3
      AND `SchoolMask` = 2
      AND `SpellClassSet` = 10
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = -2
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 87
      AND `EffectMiscValue_1` = 127
      AND `Effect_2` = 6
      AND `EffectDieSides_2` = 1
      AND `EffectBasePoints_2` = 9
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 189
      AND `EffectMiscValue_2` = 2
);

SET @sacred_vengeance_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901020
      AND `Name_Lang_enUS` = 'Sacred Vengeance'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00044400
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `SchoolMask` = 2
      AND `SpellClassSet` = 10
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 42
      AND `EffectTriggerSpell_1` = 901021
);

SET @sacred_fervor_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901021
      AND `Name_Lang_enUS` = 'Sacred Fervor'
      AND `AttributesEx4` = 0x00000040
      AND `DurationIndex` = 31
      AND `CumulativeAura` = 3
      AND `SchoolMask` = 2
      AND `SpellClassSet` = 10
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 1
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 136
      AND `Effect_2` = 6
      AND `EffectDieSides_2` = 1
      AND `EffectBasePoints_2` = 9
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 85
      AND `EffectMiscValue_2` = 0
);

INSERT INTO `spell_proc` (
    `SpellId`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`,
    `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`, `SpellTypeMask`,
    `SpellPhaseMask`, `HitMask`, `AttributesMask`, `DisableEffectsMask`,
    `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`
) SELECT
    901018, 0, 0, 0,
    0, 0, 0x00051114, 1,
    2, 2, 2, 0,
    0, 100, 0, 0
FROM DUAL
WHERE @guardians_vengeance_managed = 1
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
    901020, 0, 0, 0,
    0, 0, 0x00044400, 2,
    2, 2, 2, 0,
    0, 100, 0, 0
FROM DUAL
WHERE @sacred_vengeance_managed = 1
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

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901019, 0x01000000
FROM DUAL
WHERE @guardians_resolve_managed = 1
ON DUPLICATE KEY UPDATE `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901021, 0x01000000
FROM DUAL
WHERE @sacred_fervor_managed = 1
ON DUPLICATE KEY UPDATE `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901018, 'Guardian\'s Vengeance'
FROM DUAL
WHERE @guardians_vengeance_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901019, 'Guardian\'s Resolve'
FROM DUAL
WHERE @guardians_resolve_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901020, 'Sacred Vengeance'
FROM DUAL
WHERE @sacred_vengeance_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901021, 'Sacred Fervor'
FROM DUAL
WHERE @sacred_fervor_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

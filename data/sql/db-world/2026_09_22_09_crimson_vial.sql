SET @crimson_vial_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 17534
), 0);

SET @crimson_vial_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901083
      AND `Name_Lang_enUS` = 'Crimson Vial'
      AND `Attributes` = 0x00000010
      AND `AttributesEx` = 0x00000020
      AND `AttributesEx2` = 0x20000000
      AND `AttributesEx5` = 0x00000200
      AND `CastingTimeIndex` = 1
      AND `RecoveryTime` = 45000
      AND `InterruptFlags` = 15
      AND `ProcChance` = 101
      AND `BaseLevel` = 1
      AND `SpellLevel` = 1
      AND `DurationIndex` = 32
      AND `PowerType` = 3
      AND `ManaCost` = 20
      AND `RangeIndex` = 1
      AND `Speed` = 0
      AND `CumulativeAura` = 1
      AND `DispelType` = 0
      AND `SchoolMask` = 8
      AND `SpellClassSet` = 8
      AND `EquippedItemClass` = -1
      AND `EquippedItemSubclass` = 0
      AND `EquippedItemInvTypes` = 0
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 4
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 20
      AND `EffectAuraPeriod_1` = 1000
      AND `StartRecoveryCategory` = 133
      AND `StartRecoveryTime` = 1000
      AND `DefenseType` = 1
      AND `PreventionType` = 0
      AND `EffectChainAmplitude_1` = 1.0
      AND `SpellIconID` = @crimson_vial_icon
);

SET @crimson_vial_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901083 AND @crimson_vial_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901083 AND @crimson_vial_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901083 AND @crimson_vial_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `AttributesEx`, `AttributesEx2`, `AttributesEx5`,
    `CastingTimeIndex`, `RecoveryTime`, `InterruptFlags`, `ProcChance`,
    `BaseLevel`, `SpellLevel`, `DurationIndex`, `PowerType`, `ManaCost`,
    `RangeIndex`, `Speed`, `CumulativeAura`, `DispelType`,
    `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `EffectAuraPeriod_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`, `StartRecoveryCategory`,
    `StartRecoveryTime`, `SpellClassSet`, `DefenseType`, `PreventionType`,
    `EffectChainAmplitude_1`, `SchoolMask`
) SELECT
    901083, 0x00000010, 0x00000020, 0x20000000, 0x00000200,
    1, 45000, 15, 101,
    1, 1, 32, 3, 20,
    1, 0, 1, 0,
    -1, 0, 0,
    6, 0, 4,
    1, 20, 1000,
    @crimson_vial_icon, 'Crimson Vial',
    'Heals you for 5% of your maximum health immediately and every 1 sec for 6 sec. Does not break stealth.',
    'Restores 5% of maximum health every 1 sec.',
    133, 1000, 8, 1, 0,
    1.0, 8
FROM DUAL
WHERE @crimson_vial_owned = 0;

SET @crimson_vial_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901083
      AND `Name_Lang_enUS` = 'Crimson Vial'
      AND `Attributes` = 0x00000010
      AND `AttributesEx` = 0x00000020
      AND `AttributesEx2` = 0x20000000
      AND `AttributesEx5` = 0x00000200
      AND `CastingTimeIndex` = 1
      AND `RecoveryTime` = 45000
      AND `InterruptFlags` = 15
      AND `ProcChance` = 101
      AND `BaseLevel` = 1
      AND `SpellLevel` = 1
      AND `DurationIndex` = 32
      AND `PowerType` = 3
      AND `ManaCost` = 20
      AND `RangeIndex` = 1
      AND `Speed` = 0
      AND `CumulativeAura` = 1
      AND `DispelType` = 0
      AND `SchoolMask` = 8
      AND `SpellClassSet` = 8
      AND `EquippedItemClass` = -1
      AND `EquippedItemSubclass` = 0
      AND `EquippedItemInvTypes` = 0
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 4
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 20
      AND `EffectAuraPeriod_1` = 1000
      AND `StartRecoveryCategory` = 133
      AND `StartRecoveryTime` = 1000
      AND `DefenseType` = 1
      AND `PreventionType` = 0
      AND `EffectChainAmplitude_1` = 1.0
      AND `SpellIconID` = @crimson_vial_icon
);

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901083, 0x01000000
FROM DUAL
WHERE @crimson_vial_managed = 1
ON DUPLICATE KEY UPDATE
    `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901083, 'Crimson Vial'
FROM DUAL
WHERE @crimson_vial_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

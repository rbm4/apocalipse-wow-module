SET @alchemical_guard_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 31224
), 0);

SET @alchemical_guard_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901077
      AND `Name_Lang_enUS` = 'Alchemical Guard'
      AND `Attributes` = 0x00000010
      AND `AttributesEx` = 0x00008020
      AND `AttributesEx5` = 0x00060008
      AND `RecoveryTime` = 60000
      AND `DurationIndex` = 32
      AND `RangeIndex` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 8
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = -21
      AND `EffectAura_1` = 87
      AND `EffectMiscValue_1` = 127
      AND `Effect_2` = 6
      AND `EffectAura_2` = 41
      AND `EffectMiscValue_2` = 4
      AND `Effect_3` = 6
      AND `EffectAura_3` = 41
      AND `EffectMiscValue_3` = 3
      AND `SpellIconID` = @alchemical_guard_icon
);

SET @alchemical_guard_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901077 AND @alchemical_guard_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901077 AND @alchemical_guard_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901077 AND @alchemical_guard_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `AttributesEx`, `AttributesEx5`, `CastingTimeIndex`,
    `RecoveryTime`, `InterruptFlags`, `ProcChance`, `BaseLevel`, `SpellLevel`,
    `DurationIndex`, `PowerType`, `ManaCost`, `RangeIndex`, `Speed`,
    `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `Effect_2`, `Effect_3`, `EffectDieSides_1`,
    `EffectBasePoints_1`, `ImplicitTargetA_1`, `ImplicitTargetA_2`,
    `ImplicitTargetA_3`, `EffectAura_1`, `EffectAura_2`, `EffectAura_3`,
    `EffectMiscValue_1`, `EffectMiscValue_2`, `EffectMiscValue_3`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`, `StartRecoveryCategory`,
    `StartRecoveryTime`, `SpellClassSet`, `DefenseType`, `PreventionType`,
    `EffectChainAmplitude_1`, `EffectChainAmplitude_2`,
    `EffectChainAmplitude_3`, `SchoolMask`
) SELECT
    901077, 0x00000010, 0x00008020, 0x00060008, 1,
    60000, 15, 101, 1, 1,
    32, 0, 0, 1, 0,
    -1, 0, 0,
    6, 6, 6, 1,
    -21, 1, 1,
    1, 87, 41, 41,
    127, 4, 3,
    @alchemical_guard_icon, 'Alchemical Guard',
    'Reduces all damage taken by 20% and grants immunity to Poison and Disease effects for $d. Removes existing Poison and Disease effects when activated. Usable while controlled and does not break stealth.',
    'Damage taken reduced by 20%. Immune to Poison and Disease effects.',
    133, 1500, 8, 1, 0,
    1.0, 1.0, 1.0, 1
FROM DUAL
WHERE @alchemical_guard_owned = 0;

SET @alchemical_guard_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901077
      AND `Name_Lang_enUS` = 'Alchemical Guard'
      AND `Attributes` = 0x00000010
      AND `AttributesEx` = 0x00008020
      AND `AttributesEx5` = 0x00060008
      AND `RecoveryTime` = 60000
      AND `DurationIndex` = 32
      AND `RangeIndex` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 8
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = -21
      AND `EffectAura_1` = 87
      AND `EffectMiscValue_1` = 127
      AND `Effect_2` = 6
      AND `EffectAura_2` = 41
      AND `EffectMiscValue_2` = 4
      AND `Effect_3` = 6
      AND `EffectAura_3` = 41
      AND `EffectMiscValue_3` = 3
      AND `SpellIconID` = @alchemical_guard_icon
);

DELETE FROM `spell_script_names`
WHERE `ScriptName` = 'spell_apoc_rogue_alchemical_guard';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901077, 'spell_apoc_rogue_alchemical_guard'
FROM DUAL
WHERE @alchemical_guard_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901077, 0x01000000
FROM DUAL
WHERE @alchemical_guard_managed = 1
ON DUPLICATE KEY UPDATE
    `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901077, 'Alchemical Guard'
FROM DUAL
WHERE @alchemical_guard_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

SET @primal_resolve_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901042
      AND `Name_Lang_enUS` = 'Primal Resolve'
      AND `Attributes` = 0x00000010
      AND `RecoveryTime` = 30000
      AND `DurationIndex` = 32
      AND `RangeIndex` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 9
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = -16
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 87
      AND `EffectMiscValue_1` = 127
      AND `Effect_2` = 77
      AND `ImplicitTargetA_2` = 1
      AND `SpellIconID` = 83
);

SET @primal_resolve_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901042 AND @primal_resolve_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901042 AND @primal_resolve_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901042 AND @primal_resolve_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `CastingTimeIndex`, `RecoveryTime`, `InterruptFlags`,
    `ProcChance`, `BaseLevel`, `SpellLevel`, `DurationIndex`, `PowerType`,
    `ManaCost`, `RangeIndex`, `Speed`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`, `Effect_2`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `ImplicitTargetA_2`, `EffectAura_1`, `EffectMiscValue_1`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`, `AuraDescription_Lang_enUS`,
    `StartRecoveryCategory`, `StartRecoveryTime`, `SpellClassSet`,
    `DefenseType`, `PreventionType`, `EffectChainAmplitude_1`,
    `EffectChainAmplitude_2`, `SchoolMask`
) SELECT
    901042, 0x00000010, 1, 30000, 15,
    101, 1, 1, 32, 0,
    0, 1, 0, -1,
    0, 0, 6, 77,
    1, -16, 1,
    1, 87, 127, 83,
    'Primal Resolve',
    'Removes snare effects and reduces all damage taken by 15% for 6 sec.',
    'Damage taken reduced by 15%.',
    133, 1500, 9,
    1, 1, 1.0,
    1.0, 1
FROM DUAL
WHERE @primal_resolve_owned = 0;

SET @primal_resolve_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901042
      AND `Name_Lang_enUS` = 'Primal Resolve'
      AND `Attributes` = 0x00000010
      AND `RecoveryTime` = 30000
      AND `DurationIndex` = 32
      AND `RangeIndex` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 9
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = -16
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 87
      AND `EffectMiscValue_1` = 127
      AND `Effect_2` = 77
      AND `ImplicitTargetA_2` = 1
      AND `SpellIconID` = 83
);

DELETE FROM `spell_script_names`
WHERE `ScriptName` = 'spell_apoc_hunter_primal_resolve';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901042, 'spell_apoc_hunter_primal_resolve'
FROM DUAL
WHERE @primal_resolve_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901042, 0x01000000
FROM DUAL
WHERE @primal_resolve_managed = 1
ON DUPLICATE KEY UPDATE
    `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901042, 'Primal Resolve'
FROM DUAL
WHERE @primal_resolve_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

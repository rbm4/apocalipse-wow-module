SET @shadow_execution_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 51713
), 0);

SET @shadow_execution_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901081
      AND `Name_Lang_enUS` = 'Shadow Execution'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00011110
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
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @shadow_execution_icon
);

SET @shadow_execution_dot_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901082
      AND `Name_Lang_enUS` = 'Shadow Execution Damage'
      AND `AttributesEx2` = 0x20000000
      AND `DurationIndex` = 1
      AND `RangeIndex` = 13
      AND `CumulativeAura` = 50
      AND `SchoolMask` = 32
      AND `SpellClassSet` = 8
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 6
      AND `EffectAura_1` = 3
      AND `EffectAuraPeriod_1` = 1000
      AND `SpellIconID` = @shadow_execution_icon
      AND `DefenseType` = 1
);

SET @shadow_execution_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901081 AND @shadow_execution_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901081 AND @shadow_execution_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901081 AND @shadow_execution_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901082 AND @shadow_execution_dot_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901082 AND @shadow_execution_dot_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901082 AND @shadow_execution_dot_owned = 0
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
    901081, 0x00000040, 0x00011110, 100, 21,
    1, 1, 32, 8,
    0, -1, 0,
    0, 6, 0,
    0, 1, 4,
    @shadow_execution_icon, 'Shadow Execution',
    'Damaging Rogue abilities apply Shadow Execution for 10 sec. It stacks up to 50 times. Each stack deals 1% of your attack-power-modified main-hand weapon damage every 1 sec.',
    'Damaging Rogue abilities apply a stacking Shadow damage over time effect.'
FROM DUAL
WHERE @shadow_execution_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `AttributesEx2`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `EffectAuraPeriod_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`, `DefenseType`
) SELECT
    901082, 0x20000000, 1, 13, 50,
    32, 8, 0, -1,
    0, 0, 6,
    1, 0, 6,
    3, 1000, @shadow_execution_icon, 'Shadow Execution Damage',
    'Deals Shadow damage every 1 sec for 10 sec. Each stack deals 1% of the caster\'s attack-power-modified main-hand weapon damage.',
    'Taking stacking Shadow damage every 1 sec.', 1
FROM DUAL
WHERE @shadow_execution_dot_owned = 0;

SET @shadow_execution_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901081
      AND `Name_Lang_enUS` = 'Shadow Execution'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00011110
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
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @shadow_execution_icon
);

SET @shadow_execution_dot_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901082
      AND `Name_Lang_enUS` = 'Shadow Execution Damage'
      AND `AttributesEx2` = 0x20000000
      AND `DurationIndex` = 1
      AND `RangeIndex` = 13
      AND `CumulativeAura` = 50
      AND `SchoolMask` = 32
      AND `SpellClassSet` = 8
      AND `DispelType` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 6
      AND `EffectAura_1` = 3
      AND `EffectAuraPeriod_1` = 1000
      AND `SpellIconID` = @shadow_execution_icon
      AND `DefenseType` = 1
);

INSERT INTO `spell_proc` (
    `SpellId`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`,
    `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`, `SpellTypeMask`,
    `SpellPhaseMask`, `HitMask`, `AttributesMask`, `DisableEffectsMask`,
    `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`
) SELECT
    901081, 0, 8, 0,
    0, 0, 0x00011110, 1,
    2, 0, 2, 0,
    0, 100, 0, 0
FROM DUAL
WHERE @shadow_execution_managed = 1
  AND @shadow_execution_dot_managed = 1
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
WHERE `ScriptName` = 'spell_apoc_rogue_shadow_execution';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901081, 'spell_apoc_rogue_shadow_execution'
FROM DUAL
WHERE @shadow_execution_managed = 1
  AND @shadow_execution_dot_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901082, 'spell_apoc_rogue_shadow_execution'
FROM DUAL
WHERE @shadow_execution_managed = 1
  AND @shadow_execution_dot_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_bonus_data`
    (`entry`, `direct_bonus`, `dot_bonus`, `ap_bonus`, `ap_dot_bonus`, `comments`)
SELECT 901082, 0, 0, 0, 0, 'Rogue - Shadow Execution Damage'
FROM DUAL
WHERE @shadow_execution_dot_managed = 1
ON DUPLICATE KEY UPDATE
    `direct_bonus` = VALUES(`direct_bonus`),
    `dot_bonus` = VALUES(`dot_bonus`),
    `ap_bonus` = VALUES(`ap_bonus`),
    `ap_dot_bonus` = VALUES(`ap_dot_bonus`),
    `comments` = VALUES(`comments`);

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901082, 0x01000000
FROM DUAL
WHERE @shadow_execution_dot_managed = 1
ON DUPLICATE KEY UPDATE
    `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901081, 'Shadow Execution'
FROM DUAL
WHERE @shadow_execution_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901082, 'Shadow Execution Damage'
FROM DUAL
WHERE @shadow_execution_dot_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

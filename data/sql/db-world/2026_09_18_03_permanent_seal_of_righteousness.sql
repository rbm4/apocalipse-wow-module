SET @permanent_sor_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901016
      AND `Name_Lang_enUS` = 'Permanent Seal of Righteousness'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00011014
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `SchoolMask` = 2
      AND `SpellClassSet` = 10
      AND `SpellClassMask_1` = 0
      AND `SpellClassMask_2` = 0
      AND `SpellClassMask_3` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @permanent_sor_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901016 AND @permanent_sor_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901016 AND @permanent_sor_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901016 AND @permanent_sor_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `ProcTypeMask`, `ProcChance`, `DurationIndex`,
    `RangeIndex`, `CumulativeAura`, `SchoolMask`, `SpellClassSet`,
    `SpellClassMask_1`, `SpellClassMask_2`, `SpellClassMask_3`,
    `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901016, 0x00000040, 0x00011014, 100, 21,
    1, 1, 2, 10,
    0, 0, 0,
    -1, 0, 0,
    6, 0, 0,
    1, 4, 25, 'Permanent Seal of Righteousness',
    'Permanently grants the melee and Judgement damage of Seal of Righteousness while another seal is active. This effect is suppressed while Seal of Righteousness is active.',
    'Melee attacks and Judgements deal additional Holy damage as if Seal of Righteousness were active.'
FROM DUAL
WHERE @permanent_sor_owned = 0;

SET @permanent_sor_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901016
      AND `Name_Lang_enUS` = 'Permanent Seal of Righteousness'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00011014
      AND `ProcChance` = 100
      AND `DurationIndex` = 21
      AND `SchoolMask` = 2
      AND `SpellClassSet` = 10
      AND `SpellClassMask_1` = 0
      AND `SpellClassMask_2` = 0
      AND `SpellClassMask_3` = 0
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

INSERT INTO `spell_proc` (
    `SpellId`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`,
    `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`, `SpellTypeMask`,
    `SpellPhaseMask`, `HitMask`, `AttributesMask`, `DisableEffectsMask`,
    `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`
) SELECT
    901016, 0, 0, 0,
    0, 0, 0x00011014, 1,
    2, 0, 0x00000002, 0,
    0, 100, 0, 0
FROM DUAL
WHERE @permanent_sor_managed = 1
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
SELECT 901016, 'spell_apoc_paladin_permanent_seal_of_righteousness'
FROM DUAL
WHERE @permanent_sor_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901016, 'Permanent Seal of Righteousness'
FROM DUAL
WHERE @permanent_sor_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

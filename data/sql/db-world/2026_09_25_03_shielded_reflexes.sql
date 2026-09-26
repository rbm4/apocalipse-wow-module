SET @shielded_reflexes_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 5277
), 178);

SET @shielded_reflexes_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901158
      AND `Name_Lang_enUS` = 'Shielded Reflexes'
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
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @shielded_reflexes_icon
);

SET @shielded_reflexes_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901158 AND @shielded_reflexes_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901158 AND @shielded_reflexes_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901158 AND @shielded_reflexes_owned = 0
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
    901158, 0x00000040, 0x000002A8, 100, 21,
    1, 1, 1, 8,
    0, 4, 64,
    16384, 6, 0,
    0, 1, 4,
    @shielded_reflexes_icon, 'Shielded Reflexes',
    'While you have a shield equipped, blocking an attack grants Evasion and Blade Flurry for at least 6 sec. This effect has a 30 sec internal cooldown.',
    'Blocks grant Evasion and Blade Flurry for at least 6 sec. 30 sec internal cooldown.'
FROM DUAL
WHERE @shielded_reflexes_owned = 0;

SET @shielded_reflexes_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901158
      AND `Name_Lang_enUS` = 'Shielded Reflexes'
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
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @shielded_reflexes_icon
);

INSERT INTO `spell_proc` (
    `SpellId`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`,
    `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`, `SpellTypeMask`,
    `SpellPhaseMask`, `HitMask`, `AttributesMask`, `DisableEffectsMask`,
    `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`
) SELECT
    901158, 0, 0, 0,
    0, 0, 0x000002A8, 0,
    2, 0x00000040, 0, 0,
    0, 100, 30000, 0
FROM DUAL
WHERE @shielded_reflexes_managed = 1
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
WHERE `ScriptName` = 'spell_apoc_rogue_shielded_reflexes';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901158, 'spell_apoc_rogue_shielded_reflexes'
FROM DUAL
WHERE @shielded_reflexes_managed = 1;

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901158, 'Shielded Reflexes'
FROM DUAL
WHERE @shielded_reflexes_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

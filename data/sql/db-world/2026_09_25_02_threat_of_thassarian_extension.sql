SET @thassarian_rank_1_description := 'When dual-wielding, your Death Strike, Obliterate, Plague Strike, Rune Strike, Blood Strike, Frost Strike, Heart Strike, and Scourge Strike have a 30% chance to also strike with your off-hand weapon. A successful off-hand Death Strike also heals you. Each Death Strike heal is reduced by 30% while a usable off-hand weapon is equipped.';
SET @thassarian_rank_2_description := 'When dual-wielding, your Death Strike, Obliterate, Plague Strike, Rune Strike, Blood Strike, Frost Strike, Heart Strike, and Scourge Strike have a 60% chance to also strike with your off-hand weapon. A successful off-hand Death Strike also heals you. Each Death Strike heal is reduced by 30% while a usable off-hand weapon is equipped.';
SET @thassarian_rank_3_description := 'When dual-wielding, your Death Strike, Obliterate, Plague Strike, Rune Strike, Blood Strike, Frost Strike, Heart Strike, and Scourge Strike also strike with your off-hand weapon. A successful off-hand Death Strike also heals you. Each Death Strike heal is reduced by 30% while a usable off-hand weapon is equipped.';

SET @thassarian_scourge_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901156
      AND `Name_Lang_enUS` = 'Scourge Strike Off-Hand'
      AND `Attributes` = 0x00040010
      AND `AttributesEx` = 0x08000000
      AND `AttributesEx3` = 0x01010000
      AND `RangeIndex` = 6
      AND `PowerType` = 0
      AND `ManaCost` = 0
      AND `RuneCostID` = 0
      AND `EquippedItemClass` = 2
      AND `EquippedItemSubclass` = 173555
      AND `Effect_1` = 121
      AND `Effect_2` = 31
      AND `Effect_3` = 3
      AND `EffectDieSides_1` = 0
      AND `EffectDieSides_2` = 0
      AND `EffectDieSides_3` = 0
      AND `ImplicitTargetA_1` = 6
      AND `ImplicitTargetA_2` = 6
      AND `ImplicitTargetA_3` = 6
      AND `SpellClassSet` = 15
      AND `SpellClassMask_1` = 0
      AND `SpellClassMask_2` = 0x08000000
      AND `SpellClassMask_3` = 0
      AND `DefenseType` = 2
      AND `SchoolMask` = 1
);

SET @thassarian_heart_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901157
      AND `Name_Lang_enUS` = 'Heart Strike Off-Hand'
      AND `Attributes` = 0x00040010
      AND `AttributesEx` = 0x08000000
      AND `AttributesEx2` = 0x00001000
      AND `AttributesEx3` = 0x01010000
      AND `AttributesEx5` = 0x00008000
      AND `RangeIndex` = 6
      AND `PowerType` = 0
      AND `ManaCost` = 0
      AND `RuneCostID` = 0
      AND `EquippedItemClass` = 2
      AND `EquippedItemSubclass` = 173555
      AND `Effect_1` = 121
      AND `Effect_2` = 31
      AND `Effect_3` = 0
      AND `EffectDieSides_1` = 0
      AND `EffectDieSides_2` = 0
      AND `EffectDieSides_3` = 0
      AND `ImplicitTargetA_1` = 6
      AND `ImplicitTargetA_2` = 6
      AND `ImplicitTargetA_3` = 25
      AND `EffectChainTargets_1` = 2
      AND `EffectChainTargets_2` = 2
      AND `EffectChainAmplitude_1` = 0.5
      AND `EffectChainAmplitude_2` = 0.5
      AND `SpellClassSet` = 15
      AND `SpellClassMask_1` = 0x01000000
      AND `SpellClassMask_2` = 0
      AND `SpellClassMask_3` = 0
      AND `DefenseType` = 2
      AND `SchoolMask` = 1
);

SET @thassarian_rank_1_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 65661
      AND `Name_Lang_enUS` = 'Threat of Thassarian'
      AND `SpellClassSet` = 15
      AND `SpellIconID` = 2023
      AND `Effect_1` = 6
      AND `EffectAura_1` = 4
      AND `EffectBasePoints_1` = 29
      AND `Description_Lang_enUS` = @thassarian_rank_1_description
);

SET @thassarian_rank_2_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 66191
      AND `Name_Lang_enUS` = 'Threat of Thassarian'
      AND `SpellClassSet` = 15
      AND `SpellIconID` = 2023
      AND `Effect_1` = 6
      AND `EffectAura_1` = 4
      AND `EffectBasePoints_1` = 59
      AND `Description_Lang_enUS` = @thassarian_rank_2_description
);

SET @thassarian_rank_3_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 66192
      AND `Name_Lang_enUS` = 'Threat of Thassarian'
      AND `SpellClassSet` = 15
      AND `SpellIconID` = 2023
      AND `Effect_1` = 6
      AND `EffectAura_1` = 4
      AND `EffectBasePoints_1` = 99
      AND `Description_Lang_enUS` = @thassarian_rank_3_description
);

SET @thassarian_proc_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_proc`
    WHERE `SpellId` = -65661
      AND `SchoolMask` = 0
      AND `SpellFamilyName` = 15
      AND `SpellFamilyMask0` IN (0x00400011, 0x01400011)
      AND `SpellFamilyMask1` IN (0x20020004, 0x28020004)
      AND `SpellFamilyMask2` = 0
      AND `ProcFlags` = 0x10
      AND `SpellTypeMask` = 0
      AND `SpellPhaseMask` = 2
      AND `HitMask` = 0x477
      AND `AttributesMask` = 0
      AND `DisableEffectsMask` = 0
      AND `ProcsPerMinute` = 0
      AND `Chance` = 100
      AND `Cooldown` = 0
      AND `Charges` = 0
);

SET @thassarian_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901156 AND @thassarian_scourge_owned = 0
        UNION ALL SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901156 AND @thassarian_scourge_owned = 0
        UNION ALL SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901156 AND @thassarian_scourge_owned = 0
        UNION ALL SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901157 AND @thassarian_heart_owned = 0
        UNION ALL SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901157 AND @thassarian_heart_owned = 0
        UNION ALL SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901157 AND @thassarian_heart_owned = 0
        UNION ALL SELECT 8 FROM `spell_dbc`
        WHERE `ID` = 65661 AND @thassarian_rank_1_owned = 0
        UNION ALL SELECT 9 FROM `spell_dbc`
        WHERE `ID` = 66191 AND @thassarian_rank_2_owned = 0
        UNION ALL SELECT 10 FROM `spell_dbc`
        WHERE `ID` = 66192 AND @thassarian_rank_3_owned = 0
        UNION ALL SELECT 11 FROM `spell_proc`
        WHERE `SpellId` = -65661 AND @thassarian_proc_owned = 0
        UNION ALL SELECT 12 FROM DUAL
        WHERE (SELECT COUNT(*) FROM `wotlk_spells_full`
            WHERE `ID` IN (65661, 66191, 66192)) <> 3
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `AttributesEx`, `AttributesEx3`, `CastingTimeIndex`,
    `ProcChance`, `PowerType`, `ManaCost`, `RangeIndex`,
    `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `Effect_2`, `Effect_3`, `EffectDieSides_1`,
    `EffectDieSides_2`, `EffectDieSides_3`, `EffectBasePoints_1`,
    `EffectBasePoints_2`, `EffectBasePoints_3`, `ImplicitTargetA_1`,
    `ImplicitTargetA_2`, `ImplicitTargetA_3`, `SpellVisualID_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `SpellClassSet`, `SpellClassMask_1`, `SpellClassMask_2`,
    `SpellClassMask_3`, `DefenseType`, `PreventionType`,
    `EffectChainAmplitude_1`, `EffectChainAmplitude_2`,
    `EffectChainAmplitude_3`, `SchoolMask`, `RuneCostID`
) SELECT
    901156, 0x00040010, 0x08000000, 0x01010000, 1,
    101, 0, 0, 6,
    2, 173555, 0,
    121, 31, 3, 0,
    0, 0, 0,
    0, 0, 6,
    6, 6, 11832,
    3143, 'Scourge Strike Off-Hand',
    'Triggered Threat of Thassarian off-hand Scourge Strike.',
    15, 0, 0x08000000,
    0, 2, 2,
    1.0, 1.0,
    1.0, 1, 0
FROM DUAL
WHERE @thassarian_scourge_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `AttributesEx`, `AttributesEx2`, `AttributesEx3`,
    `AttributesEx5`, `CastingTimeIndex`, `ProcChance`, `PowerType`,
    `ManaCost`, `RangeIndex`, `EquippedItemClass`, `EquippedItemSubclass`,
    `EquippedItemInvTypes`, `Effect_1`, `Effect_2`, `Effect_3`,
    `EffectDieSides_1`, `EffectDieSides_2`, `EffectDieSides_3`,
    `EffectBasePoints_1`, `EffectBasePoints_2`, `EffectBasePoints_3`,
    `ImplicitTargetA_1`, `ImplicitTargetA_2`, `ImplicitTargetA_3`,
    `EffectChainTargets_1`, `EffectChainTargets_2`, `EffectChainTargets_3`,
    `SpellVisualID_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `SpellClassSet`, `SpellClassMask_1`,
    `SpellClassMask_2`, `SpellClassMask_3`, `DefenseType`, `PreventionType`,
    `EffectChainAmplitude_1`, `EffectChainAmplitude_2`,
    `EffectChainAmplitude_3`, `SchoolMask`, `RuneCostID`
) SELECT
    901157, 0x00040010, 0x08000000, 0x00001000, 0x01010000,
    0x00008000, 1, 101, 0,
    0, 6, 2, 173555,
    0, 121, 31, 0,
    0, 0, 0,
    0, 0, 0,
    6, 6, 25,
    2, 2, 0,
    11148, 3145, 'Heart Strike Off-Hand',
    'Triggered Threat of Thassarian off-hand Heart Strike.',
    15, 0x01000000,
    0, 0, 2, 2,
    0.5, 0.5,
    1.0, 1, 0
FROM DUAL
WHERE @thassarian_heart_owned = 0;

INSERT INTO `spell_dbc`
SELECT f.*
FROM `wotlk_spells_full` f
WHERE f.`ID` IN (65661, 66191, 66192)
  AND NOT EXISTS (
      SELECT 1 FROM `spell_dbc` d WHERE d.`ID` = f.`ID`
  );

UPDATE `spell_dbc`
SET `Description_Lang_enUS` = CASE `ID`
        WHEN 65661 THEN @thassarian_rank_1_description
        WHEN 66191 THEN @thassarian_rank_2_description
        WHEN 66192 THEN @thassarian_rank_3_description
    END
WHERE `ID` IN (65661, 66191, 66192)
  AND `Name_Lang_enUS` = 'Threat of Thassarian'
  AND `SpellClassSet` = 15
  AND `SpellIconID` = 2023
  AND `Effect_1` = 6
  AND `EffectAura_1` = 4;

SET @thassarian_scourge_managed := (
    SELECT COUNT(*) = 1 FROM `spell_dbc`
    WHERE `ID` = 901156
      AND `Name_Lang_enUS` = 'Scourge Strike Off-Hand'
      AND `Attributes` = 0x00040010
      AND `AttributesEx3` = 0x01010000
      AND `Effect_1` = 121
      AND `Effect_2` = 31
      AND `Effect_3` = 3
      AND `SpellClassMask_2` = 0x08000000
);

SET @thassarian_heart_managed := (
    SELECT COUNT(*) = 1 FROM `spell_dbc`
    WHERE `ID` = 901157
      AND `Name_Lang_enUS` = 'Heart Strike Off-Hand'
      AND `Attributes` = 0x00040010
      AND `AttributesEx3` = 0x01010000
      AND `Effect_1` = 121
      AND `Effect_2` = 31
      AND `EffectChainTargets_1` = 2
      AND `EffectChainAmplitude_1` = 0.5
      AND `SpellClassMask_1` = 0x01000000
);

SET @thassarian_talents_managed := (
    SELECT COUNT(*) = 3
    FROM `spell_dbc`
    WHERE (`ID` = 65661 AND `Description_Lang_enUS` = @thassarian_rank_1_description)
       OR (`ID` = 66191 AND `Description_Lang_enUS` = @thassarian_rank_2_description)
       OR (`ID` = 66192 AND `Description_Lang_enUS` = @thassarian_rank_3_description)
);

DELETE FROM `spell_script_names`
WHERE `ScriptName` IN (
    'spell_apoc_death_knight_threat_of_thassarian',
    'spell_apoc_death_knight_death_strike_heal'
);

DELETE FROM `spell_script_names`
WHERE `spell_id` = 901156
  AND `ScriptName` = 'spell_dk_scourge_strike';

DELETE FROM `spell_script_names`
WHERE `spell_id` = -66188
  AND `ScriptName` = 'spell_dk_death_strike';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT -65661, 'spell_apoc_death_knight_threat_of_thassarian'
FROM DUAL
WHERE @thassarian_scourge_managed = 1
  AND @thassarian_heart_managed = 1
  AND @thassarian_talents_managed = 1;

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901156, 'spell_dk_scourge_strike'
FROM DUAL
WHERE @thassarian_scourge_managed = 1;

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 45470, 'spell_apoc_death_knight_death_strike_heal'
FROM DUAL
WHERE @thassarian_talents_managed = 1;

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT -66188, 'spell_dk_death_strike'
FROM DUAL
WHERE @thassarian_talents_managed = 1;

DELETE FROM `spell_proc`
WHERE `SpellId` = -65661
  AND @thassarian_scourge_managed = 1
  AND @thassarian_heart_managed = 1
  AND @thassarian_talents_managed = 1;

INSERT INTO `spell_proc` (
    `SpellId`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`,
    `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`, `SpellTypeMask`,
    `SpellPhaseMask`, `HitMask`, `AttributesMask`, `DisableEffectsMask`,
    `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`
) SELECT
    -65661, 0, 15, 0x01400011,
    0x28020004, 0, 0x10, 0,
    2, 0x477, 0, 0,
    0, 100, 0, 0
FROM DUAL
WHERE @thassarian_scourge_managed = 1
  AND @thassarian_heart_managed = 1
  AND @thassarian_talents_managed = 1;

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901156, 'Scourge Strike Off-Hand'
FROM DUAL
WHERE @thassarian_scourge_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901157, 'Heart Strike Off-Hand'
FROM DUAL
WHERE @thassarian_heart_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

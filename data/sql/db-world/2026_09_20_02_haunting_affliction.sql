SET @haunting_affliction_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 48181
), 3172);
SET @haunting_affliction_icd_duration := 9;

SET @haunting_affliction_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901028
      AND `Name_Lang_enUS` = 'Haunting Affliction'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `SpellClassSet` = 5
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @haunting_affliction_icd_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901029
      AND `Name_Lang_enUS` = 'Haunting Affliction Cooldown'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = @haunting_affliction_icd_duration
      AND `SpellClassSet` = 5
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @haunting_affliction_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901028 AND @haunting_affliction_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901028 AND @haunting_affliction_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901028 AND @haunting_affliction_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901029 AND @haunting_affliction_icd_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901029 AND @haunting_affliction_icd_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901029 AND @haunting_affliction_icd_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901028, 0x00000040, 21, 1, 1,
    32, 5, -1,
    0, 0, 6,
    0, 0, 1,
    4, @haunting_affliction_icon, 'Haunting Affliction',
    'When Haunt hits, it applies your highest learned ranks of Curse of Agony, Corruption, and Unstable Affliction. This effect has a 30 sec internal cooldown. Curse of Agony will not replace another curse, and Corruption will not replace Seed of Corruption.',
    'Haunt can apply your Affliction damage over time spells once every 30 sec.'
FROM DUAL
WHERE @haunting_affliction_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`,
    `AuraDescription_Lang_enUS`
) SELECT
    901029, 0x00000040, @haunting_affliction_icd_duration, 1, 1,
    32, 5, -1,
    0, 0, 6,
    0, 0, 1,
    4, @haunting_affliction_icon, 'Haunting Affliction Cooldown',
    'Haunting Affliction cannot trigger.'
FROM DUAL
WHERE @haunting_affliction_icd_owned = 0;

SET @haunting_affliction_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901028
      AND `Name_Lang_enUS` = 'Haunting Affliction'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `SpellClassSet` = 5
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @haunting_affliction_icd_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901029
      AND `Name_Lang_enUS` = 'Haunting Affliction Cooldown'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = @haunting_affliction_icd_duration
      AND `SpellClassSet` = 5
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT -48181, 'spell_apoc_warlock_haunting_affliction'
FROM DUAL
WHERE @haunting_affliction_managed = 1
  AND @haunting_affliction_icd_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901029, 0x01000000
FROM DUAL
WHERE @haunting_affliction_icd_managed = 1
ON DUPLICATE KEY UPDATE
    `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901028, 'Haunting Affliction'
FROM DUAL
WHERE @haunting_affliction_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901029, 'Haunting Affliction Cooldown'
FROM DUAL
WHERE @haunting_affliction_icd_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

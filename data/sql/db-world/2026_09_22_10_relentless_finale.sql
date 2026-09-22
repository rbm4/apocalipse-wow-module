SET @relentless_finale_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 14181
), 0);

SET @relentless_finale_owned := (
    SELECT COUNT(*) = 1 FROM `spell_dbc`
    WHERE `ID` = 901084
      AND `Name_Lang_enUS` = 'Relentless Finale'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `SpellClassSet` = 8
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @relentless_finale_icon
);

SET @relentless_finale_ready_owned := (
    SELECT COUNT(*) = 1 FROM `spell_dbc`
    WHERE `ID` = 901085
      AND `Name_Lang_enUS` = 'Relentless Finale Ready'
      AND `Attributes` = 0x80000000
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `SpellClassSet` = 8
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @relentless_finale_icon
);

SET @relentless_finale_bypass_owned := (
    SELECT COUNT(*) = 1 FROM `spell_dbc`
    WHERE `ID` = 901086
      AND `Name_Lang_enUS` = 'Relentless Finale Bypass'
      AND `Attributes` = 0x000000C0
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `SpellClassSet` = 8
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 262
      AND `EffectSpellClassMaskA_1` = 0xFFFFFFFF
      AND `EffectSpellClassMaskA_2` = 0xFFFFFFFF
      AND `EffectSpellClassMaskA_3` = 0xFFFFFFFF
      AND `SpellIconID` = @relentless_finale_icon
);

SET @relentless_finale_recharge_owned := (
    SELECT COUNT(*) = 1 FROM `spell_dbc`
    WHERE `ID` = 901087
      AND `Name_Lang_enUS` = 'Relentless Finale Recharge'
      AND `Attributes` = 0x000000C0
      AND `DurationIndex` = 1
      AND `RangeIndex` = 1
      AND `SpellClassSet` = 8
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `SpellIconID` = @relentless_finale_icon
);

SET @relentless_finale_heal_owned := (
    SELECT COUNT(*) = 1 FROM `spell_dbc`
    WHERE `ID` = 901088
      AND `Name_Lang_enUS` = 'Relentless Finale Heal'
      AND `Attributes` = 0x00000080
      AND `AttributesEx2` = 0x20000000
      AND `RangeIndex` = 1
      AND `SpellClassSet` = 8
      AND `Effect_1` = 136
      AND `EffectBasePoints_1` = 4
      AND `ImplicitTargetA_1` = 1
      AND `SpellIconID` = @relentless_finale_icon
);

SET @relentless_finale_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901084 AND @relentless_finale_owned = 0
        UNION ALL SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901084 AND @relentless_finale_owned = 0
        UNION ALL SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901084 AND @relentless_finale_owned = 0
        UNION ALL SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901085 AND @relentless_finale_ready_owned = 0
        UNION ALL SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901085 AND @relentless_finale_ready_owned = 0
        UNION ALL SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901085 AND @relentless_finale_ready_owned = 0
        UNION ALL SELECT 8 FROM `spell_dbc`
        WHERE `ID` = 901086 AND @relentless_finale_bypass_owned = 0
        UNION ALL SELECT 9 FROM `wotlk_spells_full`
        WHERE `ID` = 901086 AND @relentless_finale_bypass_owned = 0
        UNION ALL SELECT 10 FROM `wotlk_spells`
        WHERE `ID` = 901086 AND @relentless_finale_bypass_owned = 0
        UNION ALL SELECT 11 FROM `spell_dbc`
        WHERE `ID` = 901087 AND @relentless_finale_recharge_owned = 0
        UNION ALL SELECT 12 FROM `wotlk_spells_full`
        WHERE `ID` = 901087 AND @relentless_finale_recharge_owned = 0
        UNION ALL SELECT 13 FROM `wotlk_spells`
        WHERE `ID` = 901087 AND @relentless_finale_recharge_owned = 0
        UNION ALL SELECT 14 FROM `spell_dbc`
        WHERE `ID` = 901088 AND @relentless_finale_heal_owned = 0
        UNION ALL SELECT 15 FROM `wotlk_spells_full`
        WHERE `ID` = 901088 AND @relentless_finale_heal_owned = 0
        UNION ALL SELECT 16 FROM `wotlk_spells`
        WHERE `ID` = 901088 AND @relentless_finale_heal_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901084, 0x00000040, 21, 1, 1,
    1, 8, 0, -1,
    0, 0, 6,
    0, 0, 1,
    4, @relentless_finale_icon, 'Relentless Finale',
    'Your five-combo-point finishing moves restore 1% of your maximum health per combo point. While Relentless Finale Ready is active, the next such finisher does not consume combo points. This cannot occur more than once every 12 sec. Triggered and copied finishers cannot activate this effect.',
    'Five-combo-point finishing moves can retain their combo points and restore health.'
FROM DUAL WHERE @relentless_finale_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901085, 0x80000000, 21, 1, 1,
    1, 8, 0, -1,
    0, 0, 6,
    0, 0, 1,
    4, @relentless_finale_icon, 'Relentless Finale Ready',
    'Your next player-initiated five-combo-point finishing move does not consume combo points.',
    'Your next five-combo-point finishing move does not consume combo points.'
FROM DUAL WHERE @relentless_finale_ready_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `EffectSpellClassMaskA_1`,
    `EffectSpellClassMaskA_2`, `EffectSpellClassMaskA_3`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`
) SELECT
    901086, 0x000000C0, 21, 1, 1,
    1, 8, 0, -1,
    0, 0, 6,
    0, 0, 1,
    262, 0xFFFFFFFF,
    0xFFFFFFFF, 0xFFFFFFFF, @relentless_finale_icon,
    'Relentless Finale Bypass',
    'Temporarily prevents a qualifying finisher from consuming combo points.'
FROM DUAL WHERE @relentless_finale_bypass_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`
) SELECT
    901087, 0x000000C0, 1, 1, 1,
    1, 8, 0, -1,
    0, 0, 6,
    0, 0, 1,
    4, @relentless_finale_icon, 'Relentless Finale Recharge',
    'Relentless Finale Ready returns after 12 sec.'
FROM DUAL WHERE @relentless_finale_recharge_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `AttributesEx2`, `RangeIndex`, `SchoolMask`,
    `SpellClassSet`, `DispelType`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`
) SELECT
    901088, 0x00000080, 0x20000000, 1, 1,
    8, 0, -1,
    0, 0, 136,
    0, 4, 1,
    @relentless_finale_icon, 'Relentless Finale Heal',
    'Restores 5% of maximum health.'
FROM DUAL WHERE @relentless_finale_heal_owned = 0;

SET @relentless_finale_managed := (
    SELECT COUNT(*) = 1 FROM `spell_dbc`
    WHERE `ID` = 901084 AND `Name_Lang_enUS` = 'Relentless Finale'
      AND `EffectAura_1` = 4
);
SET @relentless_finale_ready_managed := (
    SELECT COUNT(*) = 1 FROM `spell_dbc`
    WHERE `ID` = 901085 AND `Name_Lang_enUS` = 'Relentless Finale Ready'
      AND `EffectAura_1` = 4
);
SET @relentless_finale_bypass_managed := (
    SELECT COUNT(*) = 1 FROM `spell_dbc`
    WHERE `ID` = 901086 AND `Name_Lang_enUS` = 'Relentless Finale Bypass'
      AND `EffectAura_1` = 262
);
SET @relentless_finale_recharge_managed := (
    SELECT COUNT(*) = 1 FROM `spell_dbc`
    WHERE `ID` = 901087 AND `Name_Lang_enUS` = 'Relentless Finale Recharge'
      AND `EffectAura_1` = 4
);
SET @relentless_finale_heal_managed := (
    SELECT COUNT(*) = 1 FROM `spell_dbc`
    WHERE `ID` = 901088 AND `Name_Lang_enUS` = 'Relentless Finale Heal'
      AND `Effect_1` = 136 AND `EffectBasePoints_1` = 4
);

DELETE FROM `spell_script_names`
WHERE `ScriptName` = 'spell_apoc_rogue_relentless_finale';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901084, 'spell_apoc_rogue_relentless_finale'
FROM DUAL
WHERE @relentless_finale_managed = 1
  AND @relentless_finale_ready_managed = 1
  AND @relentless_finale_bypass_managed = 1
  AND @relentless_finale_recharge_managed = 1
  AND @relentless_finale_heal_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901087, 'spell_apoc_rogue_relentless_finale'
FROM DUAL
WHERE @relentless_finale_managed = 1
  AND @relentless_finale_ready_managed = 1
  AND @relentless_finale_bypass_managed = 1
  AND @relentless_finale_recharge_managed = 1
  AND @relentless_finale_heal_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901085, 0x01000000 FROM DUAL
WHERE @relentless_finale_ready_managed = 1
ON DUPLICATE KEY UPDATE `attributes` = `attributes` | VALUES(`attributes`);
INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901086, 0x01000000 FROM DUAL
WHERE @relentless_finale_bypass_managed = 1
ON DUPLICATE KEY UPDATE `attributes` = `attributes` | VALUES(`attributes`);
INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901087, 0x01000000 FROM DUAL
WHERE @relentless_finale_recharge_managed = 1
ON DUPLICATE KEY UPDATE `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901084, 'Relentless Finale' FROM DUAL
WHERE @relentless_finale_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901085, 'Relentless Finale Ready' FROM DUAL
WHERE @relentless_finale_ready_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901086, 'Relentless Finale Bypass' FROM DUAL
WHERE @relentless_finale_bypass_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901087, 'Relentless Finale Recharge' FROM DUAL
WHERE @relentless_finale_recharge_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);
INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901088, 'Relentless Finale Heal' FROM DUAL
WHERE @relentless_finale_heal_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

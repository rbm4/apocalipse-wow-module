SET @rime_shards_visual := COALESCE((
    SELECT `SpellVisualID_1`
    FROM `wotlk_spells_full`
    WHERE `ID` = 51411
), 0);
SET @rime_shards_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 51411
), 2721);

SET @rime_shards_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901054
      AND `Name_Lang_enUS` = 'Rime Shards'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00010010
      AND `ProcChance` = 30
      AND `DurationIndex` = 21
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 15
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = 29
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @rime_shards_burst_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901055
      AND `Name_Lang_enUS` = 'Rime Shards Burst'
      AND `RangeIndex` = 15
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 15
      AND `MaxAffectedTargets` = 10
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 2
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 53
      AND `ImplicitTargetB_1` = 16
      AND `EffectRadiusIndex_1` = 13
      AND `SpellVisualID_1` = @rime_shards_visual
);

SET @rime_shards_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901054 AND @rime_shards_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901054 AND @rime_shards_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901054 AND @rime_shards_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901055 AND @rime_shards_burst_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901055 AND @rime_shards_burst_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901055 AND @rime_shards_burst_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `ProcTypeMask`, `ProcChance`, `DurationIndex`,
    `RangeIndex`, `CumulativeAura`, `SchoolMask`, `SpellClassSet`,
    `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901054, 0x00000040, 0x00010010, 30, 21,
    1, 1, 16, 15,
    -1, 0, 0,
    6, 0, 29,
    1, 4, @rime_shards_icon, 'Rime Shards',
    'Frost Strike and Howling Blast damage has a $s1% chance to release Rime Shards at the target, dealing Frost damage based on 20% of the triggering damage to up to 10 enemies within 10 yards. Damage per target diminishes as additional enemies are hit.',
    'Frost Strike and Howling Blast damage can release Rime Shards.'
FROM DUAL
WHERE @rime_shards_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `RangeIndex`, `SchoolMask`, `SpellClassSet`, `MaxAffectedTargets`,
    `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `ImplicitTargetB_1`, `EffectRadiusIndex_1`,
    `SpellVisualID_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `DefenseType`
) SELECT
    901055, 15, 16, 15, 10,
    -1, 0, 0,
    2, 0, 0,
    53, 16, 13,
    @rime_shards_visual, @rime_shards_icon, 'Rime Shards Burst',
    'Deals Frost damage to up to 10 enemies within 10 yards of the target.', 1
FROM DUAL
WHERE @rime_shards_burst_owned = 0;

SET @rime_shards_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901054
      AND `Name_Lang_enUS` = 'Rime Shards'
      AND `Attributes` = 0x00000040
      AND `ProcTypeMask` = 0x00010010
      AND `ProcChance` = 30
      AND `DurationIndex` = 21
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 15
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = 29
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @rime_shards_burst_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901055
      AND `Name_Lang_enUS` = 'Rime Shards Burst'
      AND `RangeIndex` = 15
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 15
      AND `MaxAffectedTargets` = 10
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 2
      AND `EffectDieSides_1` = 0
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 53
      AND `ImplicitTargetB_1` = 16
      AND `EffectRadiusIndex_1` = 13
      AND `SpellVisualID_1` = @rime_shards_visual
);

INSERT INTO `spell_proc` (
    `SpellId`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`,
    `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`, `SpellTypeMask`,
    `SpellPhaseMask`, `HitMask`, `AttributesMask`, `DisableEffectsMask`,
    `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`
) SELECT
    901054, 0, 0, 0,
    0, 0, 0x00010010, 1,
    2, 3, 2, 0,
    0, 30, 0, 0
FROM DUAL
WHERE @rime_shards_managed = 1
  AND @rime_shards_burst_managed = 1
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
WHERE `spell_id` = 901054
  AND @rime_shards_managed = 1
  AND @rime_shards_burst_managed = 1;

DELETE FROM `spell_script_names`
WHERE `spell_id` = 901055
  AND @rime_shards_burst_managed = 1;

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901054, 'spell_apoc_death_knight_rime_shards'
FROM DUAL
WHERE @rime_shards_managed = 1
  AND @rime_shards_burst_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901055, 'spell_apoc_death_knight_rime_shards_burst'
FROM DUAL
WHERE @rime_shards_burst_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_bonus_data`
    (`entry`, `direct_bonus`, `dot_bonus`, `ap_bonus`, `ap_dot_bonus`, `comments`)
SELECT 901055, 0, 0, 0, 0, 'Death Knight - Rime Shards Burst'
FROM DUAL
WHERE @rime_shards_burst_managed = 1
ON DUPLICATE KEY UPDATE
    `direct_bonus` = VALUES(`direct_bonus`),
    `dot_bonus` = VALUES(`dot_bonus`),
    `ap_bonus` = VALUES(`ap_bonus`),
    `ap_dot_bonus` = VALUES(`ap_dot_bonus`),
    `comments` = VALUES(`comments`);

INSERT INTO `mod_spec_spells` (
    `class`, `spec_index`, `spell_id`, `description`
)
SELECT 6, 1, 901054, 'Rime Shards'
FROM DUAL
WHERE @rime_shards_managed = 1
  AND @rime_shards_burst_managed = 1
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901054, 'Rime Shards'
FROM DUAL
WHERE @rime_shards_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901055, 'Rime Shards Burst'
FROM DUAL
WHERE @rime_shards_burst_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

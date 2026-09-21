SET @permanent_metamorphosis_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 59672
), 3314);

SET @permanent_metamorphosis_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901030
      AND `Name_Lang_enUS` = 'Permanent Metamorphosis'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `SpellClassSet` = 5
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @permanent_metamorphosis_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901030 AND @permanent_metamorphosis_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901030 AND @permanent_metamorphosis_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901030 AND @permanent_metamorphosis_owned = 0
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
    901030, 0x00000040, 21, 1, 1,
    32, 5, -1,
    0, 0, 6,
    0, 0, 1,
    4, @permanent_metamorphosis_icon, 'Permanent Metamorphosis',
    'Your Metamorphosis transformation lasts until death, mounting, logout, or this passive is removed. Metamorphosis must still be activated and retains its normal cooldown.',
    'Metamorphosis has no duration while active.'
FROM DUAL
WHERE @permanent_metamorphosis_owned = 0;

SET @permanent_metamorphosis_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901030
      AND `Name_Lang_enUS` = 'Permanent Metamorphosis'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `SpellClassSet` = 5
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

INSERT INTO `mod_spec_spells` (
    `class`, `spec_index`, `spell_id`, `description`
)
SELECT 9, 1, 901030, 'Permanent Metamorphosis'
FROM DUAL
WHERE @permanent_metamorphosis_managed = 1
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901030, 'Permanent Metamorphosis'
FROM DUAL
WHERE @permanent_metamorphosis_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

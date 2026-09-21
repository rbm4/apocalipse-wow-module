SET @unquenchable_flames_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901034
      AND `Name_Lang_enUS` = 'Unquenchable Flames'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 4
      AND `SpellClassSet` = 5
      AND `EquippedItemClass` = -1
      AND `EquippedItemSubclass` = 0
      AND `EquippedItemInvTypes` = 0
      AND `SpellIconID` = 31
      AND `Description_Lang_enUS` = 'Increases the dispel resistance of your Immolate and Shadowflame effects by 100%.'
      AND `AuraDescription_Lang_enUS` = 'Your Immolate and Shadowflame effects cannot be dispelled.'
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 99
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 107
      AND `EffectMiscValue_1` = 28
      AND `EffectSpellClassMaskA_1` = 0x00000004
      AND `EffectSpellClassMaskA_2` = 0
      AND `EffectSpellClassMaskA_3` = 0x00000002
);

SET @unquenchable_flames_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901034 AND @unquenchable_flames_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901034 AND @unquenchable_flames_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901034 AND @unquenchable_flames_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `EffectMiscValue_1`, `EffectSpellClassMaskA_1`,
    `EffectSpellClassMaskA_2`, `EffectSpellClassMaskA_3`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901034, 0x00000040, 21, 1, 1,
    4, 5, -1,
    0, 0, 6,
    1, 99, 1,
    107, 28, 0x00000004,
    0, 0x00000002, 31,
    'Unquenchable Flames',
    'Increases the dispel resistance of your Immolate and Shadowflame effects by 100%.',
    'Your Immolate and Shadowflame effects cannot be dispelled.'
FROM DUAL
WHERE @unquenchable_flames_owned = 0;

SET @unquenchable_flames_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901034
      AND `Name_Lang_enUS` = 'Unquenchable Flames'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 4
      AND `SpellClassSet` = 5
      AND `EquippedItemClass` = -1
      AND `EquippedItemSubclass` = 0
      AND `EquippedItemInvTypes` = 0
      AND `SpellIconID` = 31
      AND `Description_Lang_enUS` = 'Increases the dispel resistance of your Immolate and Shadowflame effects by 100%.'
      AND `AuraDescription_Lang_enUS` = 'Your Immolate and Shadowflame effects cannot be dispelled.'
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 99
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 107
      AND `EffectMiscValue_1` = 28
      AND `EffectSpellClassMaskA_1` = 0x00000004
      AND `EffectSpellClassMaskA_2` = 0
      AND `EffectSpellClassMaskA_3` = 0x00000002
);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901034, 'Unquenchable Flames'
FROM DUAL
WHERE @unquenchable_flames_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

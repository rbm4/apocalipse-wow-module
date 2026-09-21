SET @unyielding_shadows_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901035
      AND `Name_Lang_enUS` = 'Unyielding Shadows'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 32
      AND `SpellClassSet` = 5
      AND `EquippedItemClass` = -1
      AND `EquippedItemSubclass` = 0
      AND `EquippedItemInvTypes` = 0
      AND `SpellIconID` = 313
      AND `Description_Lang_enUS` = 'Increases the dispel resistance of your curses and shadow effects, except Unstable Affliction, by 100%.'
      AND `AuraDescription_Lang_enUS` = 'Your curses and shadow effects, except Unstable Affliction, cannot be dispelled.'
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 99
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 107
      AND `EffectMiscValue_1` = 28
      AND `EffectSpellClassMaskA_1` = 0xC04CC41A
      AND `EffectSpellClassMaskA_2` = 0x1804161B
      AND `EffectSpellClassMaskA_3` = 0
);

SET @unyielding_shadows_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901035 AND @unyielding_shadows_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901035 AND @unyielding_shadows_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901035 AND @unyielding_shadows_owned = 0
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
    901035, 0x00000040, 21, 1, 1,
    32, 5, -1,
    0, 0, 6,
    1, 99, 1,
    107, 28, 0xC04CC41A,
    0x1804161B, 0, 313,
    'Unyielding Shadows',
    'Increases the dispel resistance of your curses and shadow effects, except Unstable Affliction, by 100%.',
    'Your curses and shadow effects, except Unstable Affliction, cannot be dispelled.'
FROM DUAL
WHERE @unyielding_shadows_owned = 0;

SET @unyielding_shadows_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901035
      AND `Name_Lang_enUS` = 'Unyielding Shadows'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 32
      AND `SpellClassSet` = 5
      AND `EquippedItemClass` = -1
      AND `EquippedItemSubclass` = 0
      AND `EquippedItemInvTypes` = 0
      AND `SpellIconID` = 313
      AND `Description_Lang_enUS` = 'Increases the dispel resistance of your curses and shadow effects, except Unstable Affliction, by 100%.'
      AND `AuraDescription_Lang_enUS` = 'Your curses and shadow effects, except Unstable Affliction, cannot be dispelled.'
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 99
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 107
      AND `EffectMiscValue_1` = 28
      AND `EffectSpellClassMaskA_1` = 0xC04CC41A
      AND `EffectSpellClassMaskA_2` = 0x1804161B
      AND `EffectSpellClassMaskA_3` = 0
);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901035, 'Unyielding Shadows'
FROM DUAL
WHERE @unyielding_shadows_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

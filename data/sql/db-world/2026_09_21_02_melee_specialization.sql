SET @melee_specialization_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901047
      AND `Name_Lang_enUS` = 'Melee Specialization'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 9
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 262
      AND `EffectMiscValue_1` = 1
      AND `EffectSpellClassMaskA_1` = 0x00000002
      AND `EffectSpellClassMaskA_2` = 0x00080000
      AND `EffectSpellClassMaskA_3` = 0x00010000
      AND `Effect_2` = 6
      AND `EffectDieSides_2` = 1
      AND `EffectBasePoints_2` = 29
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 108
      AND `EffectMiscValue_2` = 0
      AND `EffectSpellClassMaskB_1` = 0x00000042
      AND `EffectSpellClassMaskB_2` = 0x00080000
      AND `EffectSpellClassMaskB_3` = 0x00010000
      AND `SpellIconID` = 257
);

SET @melee_specialization_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901047 AND @melee_specialization_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901047 AND @melee_specialization_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901047 AND @melee_specialization_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `EffectMiscValue_1`,
    `EffectSpellClassMaskA_1`, `EffectSpellClassMaskA_2`,
    `EffectSpellClassMaskA_3`, `Effect_2`, `EffectDieSides_2`,
    `EffectBasePoints_2`, `ImplicitTargetA_2`, `EffectAura_2`,
    `EffectMiscValue_2`, `EffectSpellClassMaskB_1`,
    `EffectSpellClassMaskB_2`, `EffectSpellClassMaskB_3`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901047, 0x00000040, 21, 1, 1,
    1, 9, -1,
    0, 0,
    6, 1, 0,
    1, 262, 1,
    0x00000002, 0x00080000,
    0x00010000, 6, 1,
    29, 1, 108,
    0, 0x00000042,
    0x00080000, 0x00010000, 257,
    'Melee Specialization',
    'Allows Raptor Strike, Mongoose Bite, and Counterattack to ignore aura-state requirements and increases the damage of Raptor Strike, Mongoose Bite, Wing Clip, and Counterattack by 30%.',
    'Selected melee abilities ignore aura-state requirements. Hunter melee ability damage is increased by 30%.'
FROM DUAL
WHERE @melee_specialization_owned = 0;

SET @melee_specialization_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901047
      AND `Name_Lang_enUS` = 'Melee Specialization'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `RangeIndex` = 1
      AND `CumulativeAura` = 1
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 9
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 0
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 262
      AND `EffectMiscValue_1` = 1
      AND `EffectSpellClassMaskA_1` = 0x00000002
      AND `EffectSpellClassMaskA_2` = 0x00080000
      AND `EffectSpellClassMaskA_3` = 0x00010000
      AND `Effect_2` = 6
      AND `EffectDieSides_2` = 1
      AND `EffectBasePoints_2` = 29
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 108
      AND `EffectMiscValue_2` = 0
      AND `EffectSpellClassMaskB_1` = 0x00000042
      AND `EffectSpellClassMaskB_2` = 0x00080000
      AND `EffectSpellClassMaskB_3` = 0x00010000
      AND `SpellIconID` = 257
);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901047, 'Melee Specialization'
FROM DUAL
WHERE @melee_specialization_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

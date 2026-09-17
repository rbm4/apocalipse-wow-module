SET @missile_barrage_overload_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901004
      AND `Name_Lang_enUS` = 'Missile Barrage Overload'
      AND `Attributes` = 0x00000040
      AND `SchoolMask` = 64
      AND `SpellClassSet` = 3
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = 20
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @missile_barrage_overload_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901004 AND @missile_barrage_overload_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901004 AND @missile_barrage_overload_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901004 AND @missile_barrage_overload_owned = 0
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
    901004, 0x00000040, 21, 1, 1,
    64, 3, 0, -1,
    0, 0, 6,
    0, 20, 1,
    4, 3261, 'Missile Barrage Overload',
    'Your Missile Barrage effect can accumulate up to $s1 procs. Each proc after the first causes your next Arcane Missiles to fire one additional missile. Casting Arcane Missiles consumes all accumulated procs.',
    'Missile Barrage can accumulate up to $s1 procs.'
FROM DUAL
WHERE @missile_barrage_overload_owned = 0;

SET @missile_barrage_overload_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901004
      AND `Name_Lang_enUS` = 'Missile Barrage Overload'
      AND `Attributes` = 0x00000040
      AND `SchoolMask` = 64
      AND `SpellClassSet` = 3
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = 20
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 44401, 'spell_apoc_mage_missile_barrage_overload_proc'
FROM DUAL
WHERE @missile_barrage_overload_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901004, 'spell_apoc_mage_missile_barrage_overload_passive'
FROM DUAL
WHERE @missile_barrage_overload_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901004, 'Missile Barrage Overload'
FROM DUAL
WHERE @missile_barrage_overload_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

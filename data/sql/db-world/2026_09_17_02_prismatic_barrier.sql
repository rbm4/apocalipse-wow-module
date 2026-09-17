SET @prismatic_barrier_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901006
      AND `Name_Lang_enUS` = 'Prismatic Barrier'
      AND `Attributes` = 0
      AND `RecoveryTime` = 45000
      AND `ManaCostPct` = 42
      AND `SchoolMask` = 64
      AND `SpellClassSet` = 3
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 77
      AND `ImplicitTargetA_1` = 1
);

SET @prismatic_barrier_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901006 AND @prismatic_barrier_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901006 AND @prismatic_barrier_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901006 AND @prismatic_barrier_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `CastingTimeIndex`, `RecoveryTime`,
    `InterruptFlags`, `ProcChance`, `BaseLevel`, `SpellLevel`, `PowerType`,
    `ManaCost`, `RangeIndex`, `Speed`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `ImplicitTargetA_1`, `SpellVisualID_1`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`, `ManaCostPct`,
    `StartRecoveryCategory`, `StartRecoveryTime`, `SpellClassSet`,
    `DefenseType`, `PreventionType`, `EffectChainAmplitude_1`, `SchoolMask`
) SELECT
    901006, 0, 1, 45000,
    15, 101, 80, 80, 0,
    0, 1, 0, -1,
    0, 0, 77,
    1, 0, 2307,
    'Prismatic Barrier',
    'Surrounds you with Mana Shield, Ice Barrier, and Blazing Barrier. Costs twice the mana of a normal barrier.',
    42, 133, 1500, 3,
    1, 1, 1.0, 64
FROM DUAL
WHERE @prismatic_barrier_owned = 0;

SET @prismatic_barrier_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901006
      AND `Name_Lang_enUS` = 'Prismatic Barrier'
      AND `Attributes` = 0
      AND `RecoveryTime` = 45000
      AND `ManaCostPct` = 42
      AND `SchoolMask` = 64
      AND `SpellClassSet` = 3
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 77
      AND `ImplicitTargetA_1` = 1
);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901006, 'spell_apoc_mage_prismatic_barrier'
FROM DUAL
WHERE @prismatic_barrier_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901006, 'Prismatic Barrier'
FROM DUAL
WHERE @prismatic_barrier_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

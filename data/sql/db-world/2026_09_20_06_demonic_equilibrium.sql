SET @demonic_equilibrium_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 19028
), 173);

SET @demonic_equilibrium_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901033
      AND `Name_Lang_enUS` = 'Demonic Equilibrium'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `SchoolMask` = 32
      AND `SpellClassSet` = 5
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @demonic_equilibrium_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901033 AND @demonic_equilibrium_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901033 AND @demonic_equilibrium_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901033 AND @demonic_equilibrium_owned = 0
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
    901033, 0x00000040, 21, 1, 1,
    32, 5, -1,
    0, 0, 6,
    0, 0, 1,
    4, @demonic_equilibrium_icon, 'Demonic Equilibrium',
    'Increases the amount of damage transferred by your Soul Link to 75%.',
    'Soul Link transfers 75% of damage taken to your demon.'
FROM DUAL
WHERE @demonic_equilibrium_owned = 0;

SET @demonic_equilibrium_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901033
      AND `Name_Lang_enUS` = 'Demonic Equilibrium'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `SchoolMask` = 32
      AND `SpellClassSet` = 5
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

DELETE FROM `spell_script_names`
WHERE `ScriptName` = 'spell_apoc_warlock_demonic_equilibrium';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 25228, 'spell_apoc_warlock_demonic_equilibrium'
FROM DUAL
WHERE @demonic_equilibrium_managed = 1;

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901033, 'Demonic Equilibrium'
FROM DUAL
WHERE @demonic_equilibrium_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

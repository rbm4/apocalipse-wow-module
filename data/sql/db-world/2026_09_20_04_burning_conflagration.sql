SET @burning_conflagration_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 17962
), 0);

SET @burning_conflagration_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901027
      AND `Name_Lang_enUS` = 'Burning Conflagration'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `SchoolMask` = 4
      AND `SpellClassSet` = 5
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @burning_conflagration_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901027 AND @burning_conflagration_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901027 AND @burning_conflagration_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901027 AND @burning_conflagration_owned = 0
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
    901027, 0x00000040, 21, 1, 1,
    4, 5, 0, -1,
    0, 0, 6,
    0, 0, 1,
    4, @burning_conflagration_icon, 'Burning Conflagration',
    'Your Conflagrate hits spread your Immolate on the target to up to 3 additional enemies within 10 yards. Enemies already affected by your Immolate are excluded.',
    'Conflagrate spreads Immolate to nearby enemies.'
FROM DUAL
WHERE @burning_conflagration_owned = 0;

SET @burning_conflagration_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901027
      AND `Name_Lang_enUS` = 'Burning Conflagration'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `SchoolMask` = 4
      AND `SpellClassSet` = 5
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

DELETE FROM `spell_script_names`
WHERE `ScriptName` = 'spell_apoc_warlock_burning_conflagration';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT -17962, 'spell_apoc_warlock_burning_conflagration'
FROM DUAL
WHERE @burning_conflagration_managed = 1;

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901027, 'Burning Conflagration'
FROM DUAL
WHERE @burning_conflagration_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

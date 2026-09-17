SET @pyroclastic_chain_reaction_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901003
      AND `Name_Lang_enUS` = 'Pyroclastic Chain Reaction'
      AND `Attributes` = 0x00000040
      AND `SchoolMask` = 4
      AND `SpellClassSet` = 3
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = 20
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @pyroclastic_chain_reaction_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901003 AND @pyroclastic_chain_reaction_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901003 AND @pyroclastic_chain_reaction_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901003 AND @pyroclastic_chain_reaction_owned = 0
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
    901003, 0x00000040, 21, 1, 1,
    4, 3, 0, -1,
    0, 0, 6,
    0, 20, 1,
    4, 3000, 'Pyroclastic Chain Reaction',
    'Your Pyroblast hits have a $s1% chance to detonate and refresh your Living Bomb on the target, then spread Living Bomb to up to 2 additional unbombed enemies hit by the explosion.',
    'Pyroblast can trigger a Pyroclastic Chain Reaction.'
FROM DUAL
WHERE @pyroclastic_chain_reaction_owned = 0;

SET @pyroclastic_chain_reaction_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901003
      AND `Name_Lang_enUS` = 'Pyroclastic Chain Reaction'
      AND `Attributes` = 0x00000040
      AND `SchoolMask` = 4
      AND `SpellClassSet` = 3
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = 20
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT -11366, 'spell_apoc_mage_pyroclastic_chain_reaction_pyroblast'
FROM DUAL
WHERE @pyroclastic_chain_reaction_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT -44461, 'spell_apoc_mage_pyroclastic_chain_reaction_explosion'
FROM DUAL
WHERE @pyroclastic_chain_reaction_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901003, 'Pyroclastic Chain Reaction'
FROM DUAL
WHERE @pyroclastic_chain_reaction_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

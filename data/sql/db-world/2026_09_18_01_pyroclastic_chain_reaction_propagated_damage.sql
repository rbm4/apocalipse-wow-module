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
SELECT -44457, 'spell_apoc_mage_pyroclastic_chain_reaction_living_bomb'
FROM DUAL
WHERE @pyroclastic_chain_reaction_managed = 1
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

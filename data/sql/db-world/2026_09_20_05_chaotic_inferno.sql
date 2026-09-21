SET @chaotic_inferno_icon := COALESCE((
    SELECT `SpellIconID`
    FROM `wotlk_spells_full`
    WHERE `ID` = 1122
), 460);

SET @chaotic_inferno_passive_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901031
      AND `Name_Lang_enUS` = 'Chaotic Inferno'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `SpellClassSet` = 5
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @chaotic_inferno_summon_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901032
      AND `Name_Lang_enUS` = 'Chaotic Inferno Summon'
      AND `Attributes` = 0x00010000
      AND `AttributesEx` = 0x00020000
      AND `DurationIndex` IN (3, 18)
      AND `SchoolMask` = 32
      AND `Effect_1` = 28
      AND `EffectBasePoints_1` = 49
      AND `EffectRadiusIndex_1` = 13
      AND `EffectMiscValue_1` = 900002
      AND `EffectMiscValueB_1` = 901032
      AND `Effect_2` = 64
      AND `EffectTriggerSpell_2` = 22703
);

SET @chaos_infernal_owned := (
    SELECT COUNT(*) = 1
    FROM `creature_template`
    WHERE `entry` = 900002
      AND `name` = 'Chaos Infernal'
      AND `ScriptName` = 'npc_apoc_warlock_chaos_infernal'
);

SET @chaotic_inferno_properties_owned := (
    SELECT COUNT(*) = 1
    FROM `summonproperties_dbc`
    WHERE `ID` = 901032
      AND `Control` = 1
      AND `Faction` = 0
      AND `Title` = 2
      AND `Slot` = 0
      AND `Flags` = 0
);

SET @chaotic_inferno_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901031 AND @chaotic_inferno_passive_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901031 AND @chaotic_inferno_passive_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901031 AND @chaotic_inferno_passive_owned = 0
        UNION ALL
        SELECT 5 FROM `spell_dbc`
        WHERE `ID` = 901032 AND @chaotic_inferno_summon_owned = 0
        UNION ALL
        SELECT 6 FROM `wotlk_spells_full`
        WHERE `ID` = 901032 AND @chaotic_inferno_summon_owned = 0
        UNION ALL
        SELECT 7 FROM `wotlk_spells`
        WHERE `ID` = 901032 AND @chaotic_inferno_summon_owned = 0
        UNION ALL
        SELECT 8 FROM `creature_template`
        WHERE `entry` = 900002 AND @chaos_infernal_owned = 0
        UNION ALL
        SELECT 9 FROM `summonproperties_dbc`
        WHERE `ID` = 901032 AND @chaotic_inferno_properties_owned = 0
        UNION ALL
        SELECT 10 FROM `creature_template_model`
        WHERE `CreatureID` = 900002 AND @chaos_infernal_owned = 0
        UNION ALL
        SELECT 11 FROM `creature_template_addon`
        WHERE `entry` = 900002 AND @chaos_infernal_owned = 0
        UNION ALL
        SELECT 12 FROM `pet_levelstats`
        WHERE `creature_entry` = 900002 AND @chaos_infernal_owned = 0
    ) AS `collision_guard`
);

UPDATE `spell_dbc`
SET `Description_Lang_enUS` = 'When your Chaos Bolt lands, it calls down an Infernal at the target''s location. The impact deals normal Inferno damage and stuns nearby enemies. Each Infernal assists you for 20 sec.'
WHERE `ID` = 901031
  AND @chaotic_inferno_passive_owned = 1;

UPDATE `spell_dbc`
SET `DurationIndex` = 18,
    `Description_Lang_enUS` = 'Calls down a module-owned Infernal guardian for 20 sec and triggers the normal Inferno impact at the destination.'
WHERE `ID` = 901032
  AND @chaotic_inferno_summon_owned = 1;

INSERT INTO `summonproperties_dbc` (
    `ID`, `Control`, `Faction`, `Title`, `Slot`, `Flags`
) SELECT 901032, 1, 0, 2, 0, 0
FROM DUAL
WHERE @chaotic_inferno_properties_owned = 0;

INSERT INTO `creature_template` (
    `entry`, `difficulty_entry_1`, `difficulty_entry_2`,
    `difficulty_entry_3`, `KillCredit1`, `KillCredit2`, `name`,
    `subname`, `IconName`, `gossip_menu_id`, `minlevel`, `maxlevel`,
    `exp`, `faction`, `npcflag`, `speed_walk`, `speed_run`, `speed_swim`,
    `speed_flight`, `detection_range`, `scale`, `rank`, `dmgschool`,
    `DamageModifier`, `BaseAttackTime`, `RangeAttackTime`, `BaseVariance`,
    `RangeVariance`, `unit_class`, `unit_flags`, `unit_flags2`,
    `dynamicflags`, `family`, `type`, `type_flags`, `lootid`,
    `pickpocketloot`, `skinloot`, `PetSpellDataId`, `VehicleId`, `mingold`,
    `maxgold`, `AIName`, `MovementType`, `HoverHeight`, `HealthModifier`,
    `ManaModifier`, `ArmorModifier`, `ExperienceModifier`, `RacialLeader`,
    `movementId`, `RegenHealth`, `mechanic_immune_mask`,
    `spell_school_immune_mask`, `flags_extra`, `ScriptName`,
    `VerifiedBuild`
) SELECT
    900002, `difficulty_entry_1`, `difficulty_entry_2`,
    `difficulty_entry_3`, `KillCredit1`, `KillCredit2`, 'Chaos Infernal',
    `subname`, `IconName`, `gossip_menu_id`, `minlevel`, `maxlevel`,
    `exp`, `faction`, `npcflag`, `speed_walk`, `speed_run`, `speed_swim`,
    `speed_flight`, `detection_range`, `scale`, `rank`, `dmgschool`,
    `DamageModifier`, `BaseAttackTime`, `RangeAttackTime`, `BaseVariance`,
    `RangeVariance`, `unit_class`, `unit_flags`, `unit_flags2`,
    `dynamicflags`, `family`, `type`, `type_flags`, 0,
    0, 0, 0, 0, 0,
    0, '', `MovementType`, `HoverHeight`, `HealthModifier`,
    `ManaModifier`, `ArmorModifier`, `ExperienceModifier`, `RacialLeader`,
    `movementId`, `RegenHealth`, `mechanic_immune_mask`,
    `spell_school_immune_mask`, `flags_extra`,
    'npc_apoc_warlock_chaos_infernal', NULL
FROM `creature_template`
WHERE `entry` = 89
  AND @chaos_infernal_owned = 0;

INSERT INTO `creature_template_model` (
    `CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`,
    `Probability`, `VerifiedBuild`
) SELECT
    900002, `Idx`, `CreatureDisplayID`, `DisplayScale`,
    `Probability`, `VerifiedBuild`
FROM `creature_template_model` AS `stock_model`
WHERE `CreatureID` = 89
  AND NOT EXISTS (
      SELECT 1
      FROM `creature_template_model` AS `custom_model`
      WHERE `custom_model`.`CreatureID` = 900002
        AND `custom_model`.`Idx` = `stock_model`.`Idx`
  );

INSERT INTO `creature_template_addon` (
    `entry`, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`,
    `visibilityDistanceType`, `auras`
) SELECT
    900002, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`,
    `visibilityDistanceType`, `auras`
FROM `creature_template_addon`
WHERE `entry` = 89
  AND NOT EXISTS (
      SELECT 1 FROM `creature_template_addon` WHERE `entry` = 900002
  );

INSERT INTO `pet_levelstats` (
    `creature_entry`, `level`, `hp`, `mana`, `armor`, `str`, `agi`, `sta`,
    `inte`, `spi`, `min_dmg`, `max_dmg`
) SELECT
    900002, `level`, `hp`, `mana`, `armor`, `str`, `agi`, `sta`,
    `inte`, `spi`, `min_dmg`, `max_dmg`
FROM `pet_levelstats` AS `stock_stats`
WHERE `creature_entry` = 89
  AND NOT EXISTS (
      SELECT 1
      FROM `pet_levelstats` AS `custom_stats`
      WHERE `custom_stats`.`creature_entry` = 900002
        AND `custom_stats`.`level` = `stock_stats`.`level`
  );

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`
) SELECT
    901031, 0x00000040, 21, 1, 1,
    4, 5, -1,
    0, 0, 6,
    0, 0, 1,
    4, @chaotic_inferno_icon, 'Chaotic Inferno',
    'When your Chaos Bolt lands, it calls down an Infernal at the target''s location. The impact deals normal Inferno damage and stuns nearby enemies. Each Infernal assists you for 20 sec.',
    'Chaos Bolt impacts summon an assisting Infernal.'
FROM DUAL
WHERE @chaotic_inferno_passive_owned = 0;

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `AttributesEx`, `AttributesEx2`, `DurationIndex`,
    `RangeIndex`, `SchoolMask`, `EquippedItemClass`,
    `EquippedItemSubclass`, `EquippedItemInvTypes`, `Effect_1`, `Effect_2`,
    `EffectBasePoints_1`, `ImplicitTargetA_1`, `ImplicitTargetA_2`,
    `EffectRadiusIndex_1`, `EffectMiscValue_1`, `EffectMiscValueB_1`,
    `EffectTriggerSpell_2`, `SpellVisualID_1`, `SpellIconID`,
    `Name_Lang_enUS`, `DefenseType`, `PreventionType`,
    `Description_Lang_enUS`
) SELECT
    901032, 0x00010000, 0x00020000, 0x00080000, 18,
    4, 32, -1,
    0, 0, 28, 64,
    49, 16, 87,
    13, 900002, 901032, 22703,
    4859, @chaotic_inferno_icon, 'Chaotic Inferno Summon', 1, 1,
    'Calls down a module-owned Infernal guardian for 20 sec and triggers the normal Inferno impact at the destination.'
FROM DUAL
WHERE @chaotic_inferno_summon_owned = 0;

SET @chaotic_inferno_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901031
      AND `Name_Lang_enUS` = 'Chaotic Inferno'
      AND `Effect_1` = 6
);

SET @chaotic_inferno_summon_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901032
      AND `Name_Lang_enUS` = 'Chaotic Inferno Summon'
      AND `Effect_1` = 28
      AND `EffectBasePoints_1` = 49
      AND `EffectRadiusIndex_1` = 13
      AND `EffectMiscValue_1` = 900002
      AND `EffectMiscValueB_1` = 901032
);

DELETE FROM `spell_script_names`
WHERE `ScriptName` = 'spell_apoc_warlock_chaotic_inferno';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT -50796, 'spell_apoc_warlock_chaotic_inferno'
FROM DUAL
WHERE @chaotic_inferno_managed = 1
  AND @chaotic_inferno_summon_managed = 1
  AND EXISTS (
      SELECT 1 FROM `creature_template`
      WHERE `entry` = 900002
        AND `ScriptName` = 'npc_apoc_warlock_chaos_infernal'
  );

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901031, 'Chaotic Inferno'
FROM DUAL
WHERE @chaotic_inferno_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901032, 'Chaotic Inferno Summon'
FROM DUAL
WHERE @chaotic_inferno_summon_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

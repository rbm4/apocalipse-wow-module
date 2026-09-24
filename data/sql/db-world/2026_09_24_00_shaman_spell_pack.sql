SET @fs_mask_1 := COALESCE((SELECT `SpellClassMask_1` FROM `wotlk_spells_full` WHERE `ID` = 8050), 0);
SET @fs_mask_2 := COALESCE((SELECT `SpellClassMask_2` FROM `wotlk_spells_full` WHERE `ID` = 8050), 0);
SET @fs_mask_3 := COALESCE((SELECT `SpellClassMask_3` FROM `wotlk_spells_full` WHERE `ID` = 8050), 0);
SET @earth_elemental_mask_1 := COALESCE((SELECT `SpellClassMask_1` FROM `wotlk_spells_full` WHERE `ID` = 2062), 0);
SET @earth_elemental_mask_2 := COALESCE((SELECT `SpellClassMask_2` FROM `wotlk_spells_full` WHERE `ID` = 2062), 0);
SET @earth_elemental_mask_3 := COALESCE((SELECT `SpellClassMask_3` FROM `wotlk_spells_full` WHERE `ID` = 2062), 0);
SET @feral_spirit_mask_1 := COALESCE((SELECT `SpellClassMask_1` FROM `wotlk_spells_full` WHERE `ID` = 51533), 0);
SET @feral_spirit_mask_2 := COALESCE((SELECT `SpellClassMask_2` FROM `wotlk_spells_full` WHERE `ID` = 51533), 0);
SET @feral_spirit_mask_3 := COALESCE((SELECT `SpellClassMask_3` FROM `wotlk_spells_full` WHERE `ID` = 51533), 0);
SET @mana_tide_mask_1 := COALESCE((SELECT `SpellClassMask_1` FROM `wotlk_spells_full` WHERE `ID` = 16190), 0);
SET @mana_tide_mask_2 := COALESCE((SELECT `SpellClassMask_2` FROM `wotlk_spells_full` WHERE `ID` = 16190), 0);
SET @mana_tide_mask_3 := COALESCE((SELECT `SpellClassMask_3` FROM `wotlk_spells_full` WHERE `ID` = 16190), 0);
SET @shaman_icon := COALESCE((SELECT `SpellIconID` FROM `wotlk_spells_full` WHERE `ID` = 51505), 0);

SET @shaman_pack_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` BETWEEN 901091 AND 901117
          AND `Name_Lang_enUS` <> CASE `ID`
            WHEN 901091 THEN 'Molten Anchors'
            WHEN 901092 THEN 'Wildfire Contagion'
            WHEN 901093 THEN 'Triple Convergence'
            WHEN 901094 THEN 'Ascension: Rain of Fire'
            WHEN 901095 THEN 'Ascension Suppression'
            WHEN 901096 THEN 'Echoing Magma'
            WHEN 901097 THEN 'Echoing Magma Damage'
            WHEN 901098 THEN 'Trifold Bulwark'
            WHEN 901099 THEN 'Molten Aegis'
            WHEN 901100 THEN 'Tidebound Aegis'
            WHEN 901101 THEN 'Stonehide Aegis'
            WHEN 901102 THEN 'Earthen Defiance'
            WHEN 901103 THEN 'Earthen Defiance'
            WHEN 901104 THEN 'Riptide Resonance'
            WHEN 901105 THEN 'Overflowing Tides'
            WHEN 901106 THEN 'Overflowing Tides Absorb'
            WHEN 901107 THEN 'Tidal Echo'
            WHEN 901108 THEN 'Tidal Echo Heal'
            WHEN 901109 THEN 'Deep Currents'
            WHEN 901110 THEN 'Deep Currents'
            WHEN 901111 THEN 'Spirit Link Conduit'
            WHEN 901112 THEN 'Earthen Call'
            WHEN 901113 THEN 'Alpha''s Call'
            WHEN 901114 THEN 'Tidal Call'
            WHEN 901115 THEN 'Stoneguard Bulwark'
            WHEN 901116 THEN 'Storm Unleashed'
            WHEN 901117 THEN 'Storm Unleashed Damage'
          END
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full` f
        WHERE f.`ID` BETWEEN 901091 AND 901117
          AND NOT EXISTS (SELECT 1 FROM `spell_dbc` d WHERE d.`ID` = f.`ID`)
        UNION ALL
        SELECT 4 FROM `wotlk_spells` w
        WHERE w.`ID` BETWEEN 901091 AND 901117
          AND NOT EXISTS (SELECT 1 FROM `spell_dbc` d WHERE d.`ID` = w.`ID`)
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `AttributesEx2`, `ProcTypeMask`, `ProcChance`,
    `ProcCharges`, `RecoveryTime`, `DurationIndex`, `RangeIndex`,
    `CumulativeAura`, `SchoolMask`, `SpellClassSet`, `DispelType`,
    `EquippedItemClass`, `Effect_1`, `EffectDieSides_1`,
    `EffectBasePoints_1`, `ImplicitTargetA_1`, `EffectAura_1`,
    `EffectMiscValue_1`, `EffectSpellClassMaskA_1`,
    `EffectSpellClassMaskA_2`, `EffectSpellClassMaskA_3`, `Effect_2`,
    `EffectDieSides_2`, `EffectBasePoints_2`, `ImplicitTargetA_2`,
    `EffectAura_2`, `EffectMiscValue_2`, `Effect_3`, `EffectDieSides_3`,
    `EffectBasePoints_3`, `ImplicitTargetA_3`, `EffectAura_3`,
    `EffectMiscValue_3`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`,
    `StartRecoveryCategory`, `StartRecoveryTime`, `DefenseType`
)
SELECT 901091, 0x00000040, 0, 0, 0, 0, 0, 21, 1, 1, 8, 11, 0, -1,
    6, 1, 49, 1, 107, 28, @fs_mask_1, @fs_mask_2, @fs_mask_3,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, @shaman_icon,
    'Molten Anchors', 'Increases the dispel resistance of your Flame Shock by 50%.',
    'Flame Shock has 50% increased dispel resistance.', 0, 0, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901091);

INSERT INTO `spell_dbc` (`ID`, `Attributes`, `ProcTypeMask`, `ProcChance`,
    `RecoveryTime`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`)
SELECT 901092, 0x00000040, 0, 0, 0, 21, 1, 1, 8, 11, 0, -1,
    6, 0, 0, 1, 4, @shaman_icon, 'Wildfire Contagion',
    'Flame Shock periodic damage has a 20% chance to spread that rank to one unaffected enemy within 10 yards.',
    'Flame Shock can spread on periodic damage.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901092);

INSERT INTO `spell_dbc` (`ID`, `Attributes`, `DurationIndex`, `RangeIndex`,
    `CumulativeAura`, `SchoolMask`, `SpellClassSet`, `DispelType`,
    `EquippedItemClass`, `Effect_1`, `ImplicitTargetA_1`, `EffectAura_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`)
SELECT `id`, 0x00000040, 21, 1, 1, 8, 11, 0, -1, 6, 1, 4,
    @shaman_icon, `name`, `description`, `aura_description`
FROM (
    SELECT 901093 AS `id`, 'Triple Convergence' AS `name`,
        'Lava Burst refreshes Flame Shock and spreads it to three nearby enemies, dumping missing applications into the primary target.' AS `description`,
        'Lava Burst refreshes and spreads Flame Shock.' AS `aura_description`
    UNION ALL SELECT 901096, 'Echoing Magma',
        'Lava Burst deals 50% of its damage to the two nearest additional enemies within 10 yards affected by your Flame Shock.',
        'Lava Burst echoes to nearby Flame Shock targets.'
    UNION ALL SELECT 901098, 'Trifold Bulwark',
        'Maintains Molten, Tidebound, and Stonehide Aegis together. Their values use the closest stock shield rank for your level.',
        'Maintains three stacking elemental shields.'
    UNION ALL SELECT 901104, 'Riptide Resonance',
        'Riptide periodic healing has a 20% chance to spread that rank to the lowest-health injured ally within 10 yards.',
        'Riptide can spread on periodic healing.'
    UNION ALL SELECT 901107, 'Tidal Echo',
        'Chain Heal echoes 50% of its primary raw heal to the lowest-health injured ally within 15 yards not already hit by that cast.',
        'Chain Heal produces an additional echo.'
    UNION ALL SELECT 901111, 'Spirit Link Conduit',
        'Casting a Shaman totem heals you for 5% of maximum health. This effect has a 30 second internal cooldown.',
        'Totem casts can restore health.'
) AS `passives`
WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = `passives`.`id`);

INSERT INTO `spell_dbc` (`ID`, `Attributes`, `AttributesEx2`, `RecoveryTime`,
    `DurationIndex`, `RangeIndex`, `CumulativeAura`, `SchoolMask`,
    `SpellClassSet`, `DispelType`, `EquippedItemClass`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`,
    `StartRecoveryCategory`, `StartRecoveryTime`, `DefenseType`)
SELECT 901094, 0x00000010, 0x00000004, 180000, 32, 1, 1, 4, 11, 0, -1,
    6, 0, 0, 1, 4, @shaman_icon, 'Ascension: Rain of Fire',
    'Calls down your highest known Lava Burst rank on every living same-map enemy affected by your Flame Shock, ignoring range and line of sight. These casts do not trigger Triple Convergence or Echoing Magma.',
    'Lava Burst strikes every target affected by your Flame Shock.', 133, 1500, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901094);

INSERT INTO `spell_dbc` (`ID`, `Attributes`, `DurationIndex`, `RangeIndex`,
    `CumulativeAura`, `SchoolMask`, `SpellClassSet`, `DispelType`,
    `EquippedItemClass`, `Effect_1`, `ImplicitTargetA_1`, `EffectAura_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`)
SELECT 901095, 0x00000040, 32, 1, 1, 8, 11, 0, -1, 6, 1, 4,
    @shaman_icon, 'Ascension Suppression', 'Suppresses secondary Ascension interactions.',
    'Secondary Ascension interactions are suppressed.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901095);

INSERT INTO `spell_dbc` (`ID`, `AttributesEx2`, `RangeIndex`, `SchoolMask`,
    `SpellClassSet`, `DispelType`, `EquippedItemClass`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`, `DefenseType`)
SELECT 901097, 0x20000000, 13, 4, 0, 0, -1, 2, 0, 0, 6,
    @shaman_icon, 'Echoing Magma Damage', 'Deals fixed Fire damage based on Lava Burst.', 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901097);

INSERT INTO `spell_dbc` (`ID`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `ProcTypeMask`, `ProcChance`, `ProcCharges`, `SchoolMask`, `SpellClassSet`,
    `DispelType`, `EquippedItemClass`, `Effect_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`)
SELECT `id`, 21, 1, 1, 0x00100000, 100, 3, 8, 0, 0, -1, 6, 1, 4,
    @shaman_icon, `name`, `description`, `aura_description`
FROM (
    SELECT 901099 AS `id`, 'Molten Aegis' AS `name`,
        'Retaliates against attackers with level-appropriate Lightning Shield damage and uses stock charges.' AS `description`,
        'Retaliates with Lightning Shield damage.' AS `aura_description`
    UNION ALL SELECT 901100, 'Tidebound Aegis',
        'Restores mana with the level-appropriate Water Shield payload and uses stock charges.',
        'Restores mana when struck.'
    UNION ALL SELECT 901101, 'Stonehide Aegis',
        'Heals with the level-appropriate Earth Shield amount and uses stock charges with a 3.5 second internal cooldown.',
        'Heals when struck.'
) AS `shields`
WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = `shields`.`id`);

INSERT INTO `spell_dbc` (`ID`, `Attributes`, `ProcTypeMask`, `ProcChance`,
    `DurationIndex`, `RangeIndex`, `CumulativeAura`, `SchoolMask`,
    `SpellClassSet`, `DispelType`, `EquippedItemClass`, `Effect_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`)
SELECT 901102, 0x00000040, 0x00000028, 25, 21, 1, 1, 8, 11, 0, -1,
    6, 1, 4, @shaman_icon, 'Earthen Defiance',
    'Melee damage has a 25% chance to grant 4% armor and 4% damage reduction for 10 seconds, stacking 5 times. 1 second internal cooldown.',
    'Melee damage can build Earthen Defiance.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901102);

INSERT INTO `spell_dbc` (`ID`, `AttributesEx4`, `DurationIndex`, `RangeIndex`,
    `CumulativeAura`, `SchoolMask`, `SpellClassSet`, `DispelType`,
    `EquippedItemClass`, `Effect_1`, `EffectDieSides_1`,
    `EffectBasePoints_1`, `EffectMiscValue_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `Effect_2`, `EffectDieSides_2`, `EffectBasePoints_2`,
    `EffectMiscValue_2`, `ImplicitTargetA_2`, `EffectAura_2`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`, `AuraDescription_Lang_enUS`)
SELECT 901103, 0x00000040, 1, 1, 5, 8, 11, 0, -1,
    6, 1, 3, 1, 1, 101, 6, 1, -5, 127, 1, 87, @shaman_icon,
    'Earthen Defiance', 'Increases armor by 4% and reduces all damage taken by 4% per stack for 10 seconds. Stacks 5 times.',
    'Armor increased and damage taken reduced by 4% per stack.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901103);

INSERT INTO `spell_dbc` (`ID`, `Attributes`, `ProcTypeMask`, `ProcChance`,
    `DurationIndex`, `RangeIndex`, `CumulativeAura`, `SchoolMask`,
    `SpellClassSet`, `DispelType`, `EquippedItemClass`, `Effect_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`)
SELECT `id`, 0x00000040, 0x00044400, 100, 21, 1, 1, 8, 11, 0, -1,
    6, 1, 4, @shaman_icon, `name`, `description`, `aura_description`
FROM (
    SELECT 901105 AS `id`, 'Overflowing Tides' AS `name`,
        'Converts 50% of overhealing from all healing you own into a 10 second absorb capped at 10% of the target maximum health.' AS `description`,
        'Overhealing becomes an absorb.' AS `aura_description`
    UNION ALL SELECT 901109, 'Deep Currents',
        'Healing a target below 35% health grants 10% spell haste and 10% reduced mana cost for 8 seconds. 20 second internal cooldown.',
        'Emergency healing grants haste and mana efficiency.'
) AS `heal_passives`
WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = `heal_passives`.`id`);

INSERT INTO `spell_dbc` (`ID`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `EffectMiscValue_1`, `ImplicitTargetA_1`, `EffectAura_1`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`, `AuraDescription_Lang_enUS`)
SELECT 901106, 1, 1, 1, 8, 11, 0, -1, 6, 0, 0, 127, 1, 69,
    @shaman_icon, 'Overflowing Tides Absorb', 'Absorbs damage generated by Overflowing Tides.',
    'Absorbs damage.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901106);

INSERT INTO `spell_dbc` (`ID`, `AttributesEx2`, `RangeIndex`, `SchoolMask`,
    `SpellClassSet`, `DispelType`, `EquippedItemClass`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`, `DefenseType`)
SELECT 901108, 0x20000000, 13, 8, 0, 0, -1, 10, 0, 0, 6,
    @shaman_icon, 'Tidal Echo Heal', 'Restores fixed health based on its triggering effect.', 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901108);

INSERT INTO `spell_dbc` (`ID`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `EffectMiscValue_1`, `ImplicitTargetA_1`, `EffectAura_1`, `Effect_2`,
    `EffectDieSides_2`, `EffectBasePoints_2`, `EffectMiscValue_2`,
    `ImplicitTargetA_2`, `EffectAura_2`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`)
SELECT 901110, 31, 1, 1, 8, 11, 0, -1,
    6, 1, -11, 0, 1, 65, 6, 1, -11, 127, 1, 72, @shaman_icon,
    'Deep Currents', 'Increases spell haste by 10% and reduces mana costs by 10% for 8 seconds.',
    'Spell haste increased by 10%. Mana costs reduced by 10%.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901110);

INSERT INTO `spell_dbc` (`ID`, `Attributes`, `DurationIndex`, `RangeIndex`,
    `CumulativeAura`, `SchoolMask`, `SpellClassSet`, `DispelType`,
    `EquippedItemClass`, `Effect_1`, `EffectDieSides_1`,
    `EffectBasePoints_1`, `EffectMiscValue_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `EffectSpellClassMaskA_1`, `EffectSpellClassMaskA_2`,
    `EffectSpellClassMaskA_3`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`)
SELECT `id`, 0x00000040, 21, 1, 1, 8, 11, 0, -1, 6, 1, `base_points`, 11,
    1, 107, `mask_1`, `mask_2`, `mask_3`, @shaman_icon, `name`,
    `description`, `aura_description`
FROM (
    SELECT 901112 AS `id`, -300001 AS `base_points`,
        @earth_elemental_mask_1 AS `mask_1`, @earth_elemental_mask_2 AS `mask_2`,
        @earth_elemental_mask_3 AS `mask_3`, 'Earthen Call' AS `name`,
        'Reduces the cooldown of Earth Elemental Totem by 5 minutes.' AS `description`,
        'Earth Elemental Totem cooldown reduced by 5 minutes.' AS `aura_description`
    UNION ALL SELECT 901113, -45001, @feral_spirit_mask_1, @feral_spirit_mask_2,
        @feral_spirit_mask_3, 'Alpha''s Call',
        'Reduces the cooldown of Feral Spirit by 45 seconds.',
        'Feral Spirit cooldown reduced by 45 seconds.'
    UNION ALL SELECT 901114, -120001, @mana_tide_mask_1, @mana_tide_mask_2,
        @mana_tide_mask_3, 'Tidal Call',
        'Reduces the cooldown of Mana Tide Totem by 2 minutes.',
        'Mana Tide Totem cooldown reduced by 2 minutes.'
) AS `cooldown_passives`
WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = `cooldown_passives`.`id`);

INSERT INTO `spell_dbc` (`ID`, `Attributes`, `ProcTypeMask`, `ProcChance`,
    `RecoveryTime`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `EffectMiscValue_1`, `ImplicitTargetA_1`, `EffectAura_1`, `Effect_2`,
    `ImplicitTargetA_2`, `EffectAura_2`, `Effect_3`, `EffectDieSides_3`,
    `EffectBasePoints_3`, `EffectMiscValue_3`, `ImplicitTargetA_3`,
    `EffectAura_3`, `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`, `StartRecoveryCategory`,
    `StartRecoveryTime`, `DefenseType`)
SELECT 901115, 0x00000010, 0x00000028, 100, 180000, 1, 1, 1, 8, 11, 0, -1,
    6, 1, -31, 127, 1, 87, 6, 1, 4, 6, 0, 0, 11, 1, 77,
    @shaman_icon, 'Stoneguard Bulwark',
    'Removes snares, grants snare immunity, reduces all damage taken by 30%, and retaliates against melee attackers with level-appropriate Lightning Shield damage for 10 seconds.',
    'Damage taken reduced by 30%. Immune to snares. Retaliates against melee attackers.',
    133, 1500, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901115);

INSERT INTO `spell_dbc` (`ID`, `Attributes`, `ProcTypeMask`, `ProcChance`,
    `RecoveryTime`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`,
    `Effect_1`, `ImplicitTargetA_1`, `EffectAura_1`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`, `AuraDescription_Lang_enUS`,
    `StartRecoveryCategory`, `StartRecoveryTime`, `DefenseType`)
SELECT 901116, 0x00000010, 0x00015554, 100, 180000, 1, 1, 1, 8, 11, 0, -1,
    6, 1, 4, @shaman_icon, 'Storm Unleashed',
    'For 12 seconds, direct damage, direct healing, and melee hits trigger Nature damage equal to 20% of the source amount. Healing damages the nearest enemy within 10 yards of the healed target. 500 millisecond internal cooldown.',
    'Your direct damage, direct healing, and melee hits unleash bonus Nature damage.',
    133, 1500, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901116);

INSERT INTO `spell_dbc` (`ID`, `AttributesEx2`, `RangeIndex`, `SchoolMask`,
    `SpellClassSet`, `DispelType`, `EquippedItemClass`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`, `DefenseType`)
SELECT 901117, 0x20000000, 13, 8, 0, 0, -1, 2, 0, 0, 6,
    @shaman_icon, 'Storm Unleashed Damage', 'Deals fixed Nature damage based on the triggering event.', 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901117);

INSERT INTO `spell_proc` (`SpellId`, `SchoolMask`, `SpellFamilyName`,
    `SpellFamilyMask0`, `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`,
    `SpellTypeMask`, `SpellPhaseMask`, `HitMask`, `AttributesMask`,
    `DisableEffectsMask`, `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`)
VALUES
    (901099, 0, 0, 0, 0, 0, 0x00100000, 1, 2, 0, 2, 0, 0, 100, 0, 0),
    (901100, 0, 0, 0, 0, 0, 0x00100000, 1, 2, 0, 2, 0, 0, 100, 0, 0),
    (901101, 0, 0, 0, 0, 0, 0x00100000, 1, 2, 0, 2, 0, 0, 100, 0, 0),
    (901102, 0, 0, 0, 0, 0, 0x00000028, 1, 2, 0, 2, 0, 0, 25, 1000, 0),
    (901105, 0, 0, 0, 0, 0, 0x00044400, 2, 2, 0, 2, 0, 0, 100, 0, 0),
    (901109, 0, 0, 0, 0, 0, 0x00044400, 2, 2, 0, 2, 0, 0, 100, 20000, 0),
    (901115, 0, 0, 0, 0, 0, 0x00000028, 1, 2, 0, 2, 0, 0, 100, 0, 0),
    (901116, 0, 0, 0, 0, 0, 0x00015554, 3, 2, 0, 2, 0, 0, 100, 0, 0)
ON DUPLICATE KEY UPDATE
    `ProcFlags` = VALUES(`ProcFlags`), `SpellTypeMask` = VALUES(`SpellTypeMask`),
    `SpellPhaseMask` = VALUES(`SpellPhaseMask`), `AttributesMask` = VALUES(`AttributesMask`),
    `Chance` = VALUES(`Chance`), `Cooldown` = VALUES(`Cooldown`);

DELETE FROM `spell_script_names`
WHERE `ScriptName` IN (
    'spell_apoc_shaman_flame_shock', 'spell_apoc_shaman_lava_burst',
    'spell_apoc_shaman_ascension', 'spell_apoc_shaman_trifold_bulwark',
    'spell_apoc_shaman_aegis', 'spell_apoc_shaman_earthen_defiance',
    'spell_apoc_shaman_riptide', 'spell_apoc_shaman_overflowing_tides',
    'spell_apoc_shaman_tidal_echo', 'spell_apoc_shaman_deep_currents',
    'spell_apoc_shaman_stoneguard_bulwark',
    'spell_apoc_shaman_storm_unleashed'
);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
    (-8050, 'spell_apoc_shaman_flame_shock'),
    (-51505, 'spell_apoc_shaman_lava_burst'),
    (901094, 'spell_apoc_shaman_ascension'),
    (901098, 'spell_apoc_shaman_trifold_bulwark'),
    (901099, 'spell_apoc_shaman_aegis'),
    (901100, 'spell_apoc_shaman_aegis'),
    (901101, 'spell_apoc_shaman_aegis'),
    (901102, 'spell_apoc_shaman_earthen_defiance'),
    (-61295, 'spell_apoc_shaman_riptide'),
    (901105, 'spell_apoc_shaman_overflowing_tides'),
    (-1064, 'spell_apoc_shaman_tidal_echo'),
    (901109, 'spell_apoc_shaman_deep_currents'),
    (901115, 'spell_apoc_shaman_stoneguard_bulwark'),
    (901116, 'spell_apoc_shaman_storm_unleashed')
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

DELETE FROM `spell_bonus_data` WHERE `entry` IN (901097, 901108, 901117);

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT `ID`, 0x01000000 FROM `spell_dbc`
WHERE `ID` IN (901095, 901097, 901099, 901100, 901101, 901103,
    901106, 901108, 901110, 901117)
ON DUPLICATE KEY UPDATE `attributes` = `attributes` | VALUES(`attributes`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT `ID`, `Name_Lang_enUS` FROM `spell_dbc`
WHERE `ID` BETWEEN 901091 AND 901117
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

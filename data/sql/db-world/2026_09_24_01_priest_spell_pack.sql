SET @priest_icon := COALESCE((SELECT `SpellIconID` FROM `wotlk_spells_full` WHERE `ID` = 48127), 0);
SET @shadowfiend_mask_1 := COALESCE((SELECT `SpellClassMask_1` FROM `wotlk_spells_full` WHERE `ID` = 34433), 0);
SET @shadowfiend_mask_2 := COALESCE((SELECT `SpellClassMask_2` FROM `wotlk_spells_full` WHERE `ID` = 34433), 0);
SET @shadowfiend_mask_3 := COALESCE((SELECT `SpellClassMask_3` FROM `wotlk_spells_full` WHERE `ID` = 34433), 0);
SET @vt_mask_1 := COALESCE((SELECT BIT_OR(`SpellClassMask_1`) FROM `wotlk_spells_full` WHERE `ID` IN (34914, 34916, 34917, 48159, 48160)), 0);
SET @vt_mask_2 := COALESCE((SELECT BIT_OR(`SpellClassMask_2`) FROM `wotlk_spells_full` WHERE `ID` IN (34914, 34916, 34917, 48159, 48160)), 0);
SET @vt_mask_3 := COALESCE((SELECT BIT_OR(`SpellClassMask_3`) FROM `wotlk_spells_full` WHERE `ID` IN (34914, 34916, 34917, 48159, 48160)), 0);
SET @harmful_mask_1 := COALESCE((SELECT BIT_OR(`SpellClassMask_1`) FROM `wotlk_spells_full` WHERE `SpellClassSet` = 6 AND `SchoolMask` <> 1 AND `DefenseType` = 1), 0) & ~@vt_mask_1;
SET @harmful_mask_2 := COALESCE((SELECT BIT_OR(`SpellClassMask_2`) FROM `wotlk_spells_full` WHERE `SpellClassSet` = 6 AND `SchoolMask` <> 1 AND `DefenseType` = 1), 0) & ~@vt_mask_2;
SET @harmful_mask_3 := COALESCE((SELECT BIT_OR(`SpellClassMask_3`) FROM `wotlk_spells_full` WHERE `SpellClassSet` = 6 AND `SchoolMask` <> 1 AND `DefenseType` = 1), 0) & ~@vt_mask_3;
SET @smite_mask_1 := COALESCE((SELECT `SpellClassMask_1` FROM `wotlk_spells_full` WHERE `ID` = 48123), 0);
SET @smite_mask_2 := COALESCE((SELECT `SpellClassMask_2` FROM `wotlk_spells_full` WHERE `ID` = 48123), 0);
SET @smite_mask_3 := COALESCE((SELECT `SpellClassMask_3` FROM `wotlk_spells_full` WHERE `ID` = 48123), 0);
SET @holy_fire_mask_1 := COALESCE((SELECT `SpellClassMask_1` FROM `wotlk_spells_full` WHERE `ID` = 48135), 0);
SET @holy_fire_mask_2 := COALESCE((SELECT `SpellClassMask_2` FROM `wotlk_spells_full` WHERE `ID` = 48135), 0);
SET @holy_fire_mask_3 := COALESCE((SELECT `SpellClassMask_3` FROM `wotlk_spells_full` WHERE `ID` = 48135), 0);
SET @penance_damage_mask_1 := COALESCE((SELECT `SpellClassMask_1` FROM `wotlk_spells_full` WHERE `ID` = 53003), 0);
SET @penance_damage_mask_2 := COALESCE((SELECT `SpellClassMask_2` FROM `wotlk_spells_full` WHERE `ID` = 53003), 0);
SET @penance_damage_mask_3 := COALESCE((SELECT `SpellClassMask_3` FROM `wotlk_spells_full` WHERE `ID` = 53003), 0);
SET @greater_heal_mask_1 := COALESCE((SELECT `SpellClassMask_1` FROM `wotlk_spells_full` WHERE `ID` = 48063), 0);
SET @greater_heal_mask_2 := COALESCE((SELECT `SpellClassMask_2` FROM `wotlk_spells_full` WHERE `ID` = 48063), 0);
SET @greater_heal_mask_3 := COALESCE((SELECT `SpellClassMask_3` FROM `wotlk_spells_full` WHERE `ID` = 48063), 0);
SET @flash_heal_mask_1 := COALESCE((SELECT `SpellClassMask_1` FROM `wotlk_spells_full` WHERE `ID` = 48071), 0);
SET @flash_heal_mask_2 := COALESCE((SELECT `SpellClassMask_2` FROM `wotlk_spells_full` WHERE `ID` = 48071), 0);
SET @flash_heal_mask_3 := COALESCE((SELECT `SpellClassMask_3` FROM `wotlk_spells_full` WHERE `ID` = 48071), 0);
SET @holy_nova_mask_1 := COALESCE((SELECT `SpellClassMask_1` FROM `wotlk_spells_full` WHERE `ID` = 48078), 0);
SET @holy_nova_mask_2 := COALESCE((SELECT `SpellClassMask_2` FROM `wotlk_spells_full` WHERE `ID` = 48078), 0);
SET @holy_nova_mask_3 := COALESCE((SELECT `SpellClassMask_3` FROM `wotlk_spells_full` WHERE `ID` = 48078), 0);

SET @priest_pack_collision_guard := (
    SELECT `guard_row` FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` BETWEEN 901118 AND 901154
          AND `Name_Lang_enUS` <> CASE `ID`
            WHEN 901118 THEN 'Spiritual Conservation'
            WHEN 901119 THEN 'Spiritual Conservation Mana'
            WHEN 901120 THEN 'Faithful Shadowfiend'
            WHEN 901121 THEN 'Inner Renewal'
            WHEN 901122 THEN 'Unshakable Conviction'
            WHEN 901123 THEN 'Rapid Surge of Faith'
            WHEN 901124 THEN 'Rapid Surge of Faith'
            WHEN 901125 THEN 'Rapid Penance'
            WHEN 901126 THEN 'Rapid Penance'
            WHEN 901127 THEN 'Evangelism'
            WHEN 901128 THEN 'Evangelism'
            WHEN 901129 THEN 'Archangel'
            WHEN 901130 THEN 'Archangel'
            WHEN 901131 THEN 'Atonement'
            WHEN 901132 THEN 'Atonement Heal'
            WHEN 901133 THEN 'Balanced Judgment'
            WHEN 901134 THEN 'Judgment Charges'
            WHEN 901135 THEN 'Wrathful Seraph'
            WHEN 901136 THEN 'Divine Concord'
            WHEN 901137 THEN 'Mercy'
            WHEN 901138 THEN 'Wrath'
            WHEN 901139 THEN 'Holy Word: Radiance'
            WHEN 901140 THEN 'Holy Word: Radiance Damage'
            WHEN 901141 THEN 'Holy Word: Radiance Heal'
            WHEN 901142 THEN 'Blessed Echoes'
            WHEN 901143 THEN 'Blessed Echo Damage'
            WHEN 901144 THEN 'Blessed Echo Heal'
            WHEN 901145 THEN 'Apotheosis'
            WHEN 901146 THEN 'Accelerated Misery'
            WHEN 901147 THEN 'Spreading Darkness'
            WHEN 901148 THEN 'Copied Devouring Plague'
            WHEN 901149 THEN 'Void Pressure'
            WHEN 901150 THEN 'Void Presence'
            WHEN 901151 THEN 'Devouring Echo'
            WHEN 901152 THEN 'Devouring Echo Damage'
            WHEN 901153 THEN 'Void Eruption'
            WHEN 901154 THEN 'Void Eruption Damage'
          END
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full` f
        WHERE f.`ID` BETWEEN 901118 AND 901154
          AND NOT EXISTS (SELECT 1 FROM `spell_dbc` d WHERE d.`ID` = f.`ID`)
        UNION ALL
        SELECT 4 FROM `wotlk_spells` w
        WHERE w.`ID` BETWEEN 901118 AND 901154
          AND NOT EXISTS (SELECT 1 FROM `spell_dbc` d WHERE d.`ID` = w.`ID`)
    ) AS `collision_guard`
);

INSERT INTO `spell_dbc` (`ID`, `Attributes`, `ProcTypeMask`, `ProcChance`,
    `DurationIndex`, `RangeIndex`, `CumulativeAura`, `SchoolMask`,
    `SpellClassSet`, `DispelType`, `EquippedItemClass`, `Effect_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`)
SELECT `id`, 0x00000040, `proc_flags`, 100, 21, 1, 1, `school`, 6, 0, -1,
    6, 1, 4, @priest_icon, `name`, `description`, `aura_description`
FROM (
    SELECT 901118 AS `id`, 0x00055554 AS `proc_flags`, 3 AS `school`,
        'Spiritual Conservation' AS `name`,
        'Critical Priest spell damage and healing restores 0.75% maximum mana. 2 second internal cooldown. Periodic effects can trigger it.' AS `description`,
        'Critical Priest spells restore mana.' AS `aura_description`
    UNION ALL SELECT 901123, 0x00055554, 3, 'Rapid Surge of Faith',
        'Critical direct Priest damage or healing has a 20% chance to grant 12% spell haste for 8 seconds. 20 second internal cooldown.',
        'Critical direct Priest spells can grant spell haste.'
    UNION ALL SELECT 901131, 0x00015554, 2, 'Atonement',
        'Smite, Holy Fire, and offensive Penance heal the lowest-health injured party or raid member within 15 yards of the enemy for 75% of final damage.',
        'Offensive Discipline spells heal nearby allies.'
    UNION ALL SELECT 901142, 0x00055554, 2, 'Blessed Echoes',
        'Direct Holy damage and direct healing have a 30% chance to repeat 40% of their final amount after 1 second. 500 millisecond internal cooldown.',
        'Direct Holy spells can echo after 1 second.'
) AS `proc_passives`
WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = `proc_passives`.`id`);

INSERT INTO `spell_dbc` (`ID`, `Attributes`, `DurationIndex`, `RangeIndex`,
    `CumulativeAura`, `SchoolMask`, `SpellClassSet`, `DispelType`,
    `EquippedItemClass`, `Effect_1`, `ImplicitTargetA_1`, `EffectAura_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`)
SELECT `id`, 0x00000040, 21, 1, 1, `school`, 6, 0, -1, 6, 1, 4,
    @priest_icon, `name`, `description`, `aura_description`
FROM (
    SELECT 901125 AS `id`, 2 AS `school`, 'Rapid Penance' AS `name`,
        'Penance fires three additional bolts during its normal channel. Each bolt grants 5% increased damage or healing to the next direct non-Penance Holy Priest spell, up to 30%.' AS `description`,
        'Penance fires additional bolts and empowers the next Holy spell.' AS `aura_description`
    UNION ALL SELECT 901127, 2, 'Evangelism',
        'Smite, Holy Fire, and offensive Penance grant Evangelism for 15 seconds, stacking 5 times. Each stack increases their damage and reduces their mana cost by 3%.',
        'Offensive Discipline spells build Evangelism.'
    UNION ALL SELECT 901133, 2, 'Balanced Judgment',
        'Penance bolts grant charges for 12 seconds, up to 3. Charges empower the next Smite, Greater Heal, Holy Fire, or Flash Heal.',
        'Penance bolts prepare an empowered follow-up.'
    UNION ALL SELECT 901136, 2, 'Divine Concord',
        'Direct Holy damage grants Mercy and direct Holy healing grants Wrath. Each stack increases one opposite-role spell by 15%, and that spell consumes one stack. Mercy and Wrath stack 10 times.',
        'Alternating Holy damage and healing grants 15% bonuses.'
    UNION ALL SELECT 901146, 32, 'Accelerated Misery',
        'Your Shadow Word: Pain, Vampiric Touch, and Devouring Plague tick faster with spell haste without reducing their normal duration.',
        'Priest damage over time effects tick faster with haste.'
    UNION ALL SELECT 901147, 32, 'Spreading Darkness',
        'Mind Blast spreads your Shadow Word: Pain, Vampiric Touch, and a copied Devouring Plague to one enemy within 10 yards.',
        'Mind Blast spreads your Shadow periodic effects.'
    UNION ALL SELECT 901149, 32, 'Void Pressure',
        'Mind Blast and Mind Flay build Void Presence on targets carrying your Shadow periodic effects.',
        'Mind spells build Void Presence.'
    UNION ALL SELECT 901151, 32, 'Devouring Echo',
        'Devouring Plague stores 20% of each tick, up to 15% of maximum health, then erupts against all enemies within 10 yards when it expires, is refreshed, dispelled, or removed by death.',
        'Devouring Plague stores damage for a nearby eruption.'
) AS `passives`
WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = `passives`.`id`);

INSERT INTO `spell_dbc` (`ID`, `Attributes`, `DurationIndex`, `RangeIndex`,
    `CumulativeAura`, `SchoolMask`, `SpellClassSet`, `DispelType`,
    `EquippedItemClass`, `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `EffectMiscValue_1`, `ImplicitTargetA_1`, `EffectAura_1`,
    `EffectSpellClassMaskA_1`, `EffectSpellClassMaskA_2`,
    `EffectSpellClassMaskA_3`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`)
SELECT 901120, 0x00000040, 21, 1, 1, 32, 6, 0, -1, 6, 1, -60001, 11,
    1, 107, @shadowfiend_mask_1, @shadowfiend_mask_2, @shadowfiend_mask_3,
    @priest_icon, 'Faithful Shadowfiend',
    'Reduces Shadowfiend cooldown by 60 seconds, extends its duration by 10 seconds, and restores an additional 1% maximum mana on each successful attack.',
    'Shadowfiend is available sooner, lasts longer, and restores more mana.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901120);

INSERT INTO `spell_dbc` (`ID`, `Attributes`, `DurationIndex`, `RangeIndex`,
    `CumulativeAura`, `SchoolMask`, `SpellClassSet`, `DispelType`,
    `EquippedItemClass`, `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `EffectMiscValue_1`, `ImplicitTargetA_1`, `EffectAura_1`,
    `EffectSpellClassMaskA_1`, `EffectSpellClassMaskA_2`,
    `EffectSpellClassMaskA_3`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`)
SELECT 901122, 0x00000040, 21, 1, 1, 2, 6, 0, -1, 6, 1, 49, 28, 1, 107,
    @harmful_mask_1, @harmful_mask_2, @harmful_mask_3, @priest_icon,
    'Unshakable Conviction',
    'Increases the dispel resistance of approved harmful magical Priest effects by 50%. Vampiric Touch is excluded.',
    'Harmful magical Priest effects have 50% increased dispel resistance.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901122);

INSERT INTO `spell_dbc` (`ID`, `Attributes`, `DurationIndex`, `RangeIndex`,
    `CumulativeAura`, `SchoolMask`, `SpellClassSet`, `DispelType`,
    `EquippedItemClass`, `Effect_1`, `ImplicitTargetA_1`, `EffectAura_1`,
    `Effect_2`, `EffectDieSides_2`, `EffectBasePoints_2`, `EffectMiscValue_2`,
    `ImplicitTargetA_2`, `EffectAura_2`, `EffectSpellClassMaskB_1`,
    `EffectSpellClassMaskB_2`, `EffectSpellClassMaskB_3`, `Effect_3`,
    `EffectDieSides_3`, `EffectBasePoints_3`, `EffectMiscValue_3`,
    `ImplicitTargetA_3`, `EffectAura_3`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`)
SELECT 901135, 0x00000040, 21, 1, 1, 2, 6, 0, -1,
    6, 1, 4, 6, 1, 119, 14, 1, 108,
    @holy_nova_mask_1, @holy_nova_mask_2, @holy_nova_mask_3,
    6, 1, -31, 2, 1, 10, @priest_icon, 'Wrathful Seraph',
    'Increases Smite and Holy Fire damage by 40% and Holy Nova damage by 325% with 120% increased Holy Nova mana cost. Reduces Flash Heal and Greater Heal healing by 15%, Holy Nova healing by 25%, and offensive Holy threat by 30%.',
    'Holy damage is empowered at the cost of healing efficiency.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901135);

INSERT INTO `spell_dbc` (`ID`, `Attributes`, `RecoveryTime`, `DurationIndex`,
    `RangeIndex`, `CumulativeAura`, `SchoolMask`, `SpellClassSet`, `DispelType`,
    `ManaCostPct`, `EquippedItemClass`, `Effect_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `Effect_2`, `EffectBasePoints_2`,
    `EffectMiscValue_2`, `ImplicitTargetA_2`, `EffectAura_2`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`, `AuraDescription_Lang_enUS`,
    `StartRecoveryCategory`, `StartRecoveryTime`, `DefenseType`)
SELECT 901121, 0x00000010, 120000, 8, 1, 1, 2, 6, 0, 0, -1,
    3, 0, 1, 4, 6, -21, 127, 1, 72, @priest_icon, 'Inner Renewal',
    'Immediately restores 16% maximum mana. For 15 seconds, mana costs are reduced by 20% and damage and healing are reduced by 15%.',
    'Mana costs reduced by 20%. Damage and healing reduced by 15%.', 133, 1500, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901121);

INSERT INTO `spell_dbc` (`ID`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`, `EffectAura_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`)
VALUES
    (901124, 31, 1, 1, 2, 6, 0, -1, 6, 1, -13, 1, 65, @priest_icon,
        'Rapid Surge of Faith', 'Increases spell haste by 12% for 8 seconds.',
        'Spell haste increased by 12%.'),
    (901126, 9, 1, 6, 2, 6, 0, -1, 6, 1, 0, 1, 4, @priest_icon,
        'Rapid Penance', 'Increases the next direct non-Penance Holy Priest spell by 5% per stack.',
        'Next qualifying Holy spell increased by 5% per stack.'),
    (901137, 9, 1, 10, 2, 6, 0, -1, 6, 1, 0, 1, 4, @priest_icon,
        'Mercy', 'Increases your next direct Holy heal by 15%. One stack is consumed.',
        'Next direct Holy heal increased by 15%.'),
    (901138, 9, 1, 10, 2, 6, 0, -1, 6, 1, 0, 1, 4, @priest_icon,
        'Wrath', 'Increases your next direct Holy damage spell by 15%. One stack is consumed.',
        'Next direct Holy damage spell increased by 15%.')
ON DUPLICATE KEY UPDATE `Name_Lang_enUS` = VALUES(`Name_Lang_enUS`);

INSERT INTO `spell_dbc` (`ID`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `EffectMiscValue_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `EffectSpellClassMaskA_1`,
    `EffectSpellClassMaskA_2`, `EffectSpellClassMaskA_3`, `Effect_2`,
    `EffectDieSides_2`, `EffectBasePoints_2`, `EffectMiscValue_2`,
    `ImplicitTargetA_2`, `EffectAura_2`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `AuraDescription_Lang_enUS`)
SELECT 901128, 8, 1, 5, 2, 6, 0, -1,
    6, 1, 2, 0, 1, 108,
    @smite_mask_1 | @holy_fire_mask_1 | @penance_damage_mask_1,
    @smite_mask_2 | @holy_fire_mask_2 | @penance_damage_mask_2,
    @smite_mask_3 | @holy_fire_mask_3 | @penance_damage_mask_3,
    6, 1, -4, 14, 1, 108, @priest_icon, 'Evangelism',
    'Increases Smite, Holy Fire, and offensive Penance damage by 3% and reduces their mana cost by 3% per stack for 15 seconds. Stacks 5 times.',
    'Damage increased and mana cost reduced by 3% per stack.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901128);

INSERT INTO `spell_dbc` (`ID`, `Attributes`, `RecoveryTime`, `DurationIndex`,
    `RangeIndex`, `CumulativeAura`, `SchoolMask`, `SpellClassSet`, `DispelType`,
    `EquippedItemClass`, `Effect_1`, `ImplicitTargetA_1`, `EffectAura_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`, `StartRecoveryCategory`, `StartRecoveryTime`,
    `DefenseType`)
SELECT 901129, 0x00000010, 30000, 1, 1, 1, 2, 6, 0, -1, 3, 1, 0,
    @priest_icon, 'Archangel',
    'Consumes all Evangelism stacks, restoring 1% maximum mana and granting 3% Priest damage and healing per stack for 15 seconds.',
    'Consumes Evangelism to restore mana and increase output.', 133, 1500, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901129);

INSERT INTO `spell_dbc` (`ID`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`, `Effect_1`,
    `EffectBasePoints_1`, `ImplicitTargetA_1`, `EffectAura_1`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`, `AuraDescription_Lang_enUS`)
SELECT 901130, 8, 1, 1, 2, 6, 0, -1, 6, 0, 1, 4, @priest_icon,
    'Archangel', 'Increases Priest damage and healing by 3% per Evangelism stack consumed for 15 seconds.',
    'Priest damage and healing increased.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901130);

INSERT INTO `spell_dbc` (`ID`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `EffectMiscValue_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `EffectSpellClassMaskA_1`,
    `EffectSpellClassMaskA_2`, `EffectSpellClassMaskA_3`, `Effect_2`,
    `EffectDieSides_2`, `EffectBasePoints_2`, `EffectMiscValue_2`,
    `ImplicitTargetA_2`, `EffectAura_2`, `EffectSpellClassMaskB_1`,
    `EffectSpellClassMaskB_2`, `EffectSpellClassMaskB_3`, `Effect_3`,
    `EffectDieSides_3`, `EffectBasePoints_3`, `EffectMiscValue_3`,
    `ImplicitTargetA_3`, `EffectAura_3`, `EffectSpellClassMaskC_1`,
    `EffectSpellClassMaskC_2`, `EffectSpellClassMaskC_3`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`, `AuraDescription_Lang_enUS`)
SELECT 901134, 32, 1, 3, 2, 6, 0, -1,
    6, 1, -11, 10, 1, 108,
    @smite_mask_1 | @greater_heal_mask_1, @smite_mask_2 | @greater_heal_mask_2,
    @smite_mask_3 | @greater_heal_mask_3,
    6, 1, 7, 0, 1, 108, @holy_fire_mask_1, @holy_fire_mask_2, @holy_fire_mask_3,
    6, 1, 7, 0, 1, 108, @flash_heal_mask_1, @flash_heal_mask_2, @flash_heal_mask_3,
    @priest_icon, 'Judgment Charges',
    'Each stack reduces Smite and Greater Heal cast time by 10% and increases Holy Fire damage and Flash Heal healing by 8%. The next qualifying spell consumes all charges.',
    'Empowers the next qualifying Discipline follow-up.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901134);

INSERT INTO `spell_dbc` (`ID`, `AttributesEx2`, `RangeIndex`, `SchoolMask`,
    `SpellClassSet`, `DispelType`, `EquippedItemClass`, `Effect_1`,
    `EffectBasePoints_1`, `EffectMiscValue_1`, `ImplicitTargetA_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`, `DefenseType`)
VALUES
    (901119, 0x20000000, 1, 2, 0, 0, -1, 30, 0, 0, 1, @priest_icon,
        'Spiritual Conservation Mana', 'Restores fixed mana.', 1),
    (901132, 0x20000000, 13, 2, 0, 0, -1, 10, 0, 0, 21, @priest_icon,
        'Atonement Heal', 'Restores fixed health based on final damage.', 1),
    (901141, 0x20000000, 13, 2, 0, 0, -1, 10, 0, 0, 21, @priest_icon,
        'Holy Word: Radiance Heal', 'Restores health based on the last direct Holy spell.', 1),
    (901144, 0x20000000, 13, 2, 0, 0, -1, 10, 0, 0, 21, @priest_icon,
        'Blessed Echo Heal', 'Repeats fixed healing and cannot critically strike.', 1)
ON DUPLICATE KEY UPDATE `Name_Lang_enUS` = VALUES(`Name_Lang_enUS`);

INSERT INTO `spell_dbc` (`ID`, `AttributesEx2`, `RangeIndex`, `SchoolMask`,
    `SpellClassSet`, `DispelType`, `EquippedItemClass`, `Effect_1`,
    `EffectBasePoints_1`, `ImplicitTargetA_1`, `SpellIconID`, `Name_Lang_enUS`,
    `Description_Lang_enUS`, `DefenseType`)
VALUES
    (901140, 0x20000000, 13, 2, 0, 0, -1, 2, 0, 6, @priest_icon,
        'Holy Word: Radiance Damage', 'Deals Holy damage based on the last direct Holy spell.', 1),
    (901143, 0x20000000, 13, 2, 0, 0, -1, 2, 0, 6, @priest_icon,
        'Blessed Echo Damage', 'Repeats fixed Holy damage and cannot critically strike.', 1),
    (901152, 0x20000000, 13, 32, 0, 0, -1, 2, 0, 6, @priest_icon,
        'Devouring Echo Damage', 'Deals stored non-critical Shadow damage.', 1),
    (901154, 0x20000000, 13, 32, 0, 0, -1, 2, 0, 6, @priest_icon,
        'Void Eruption Damage', 'Deals non-critical Shadow damage with Mind Blast scaling.', 1)
ON DUPLICATE KEY UPDATE `Name_Lang_enUS` = VALUES(`Name_Lang_enUS`);

INSERT INTO `spell_dbc` (`ID`, `Attributes`, `RecoveryTime`, `DurationIndex`,
    `RangeIndex`, `CumulativeAura`, `SchoolMask`, `SpellClassSet`, `DispelType`,
    `ManaCostPct`, `EquippedItemClass`, `Effect_1`, `ImplicitTargetA_1`,
    `EffectAura_1`, `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`, `StartRecoveryCategory`, `StartRecoveryTime`,
    `DefenseType`)
VALUES
    (901139, 0x00000010, 15000, 1, 13, 1, 2, 6, 0, 8, -1, 3, 25, 0,
        @priest_icon, 'Holy Word: Radiance',
        'Repeats the final amount of your last direct Holy spell on the primary target. A friendly target causes 40% Holy damage to the nearest enemy within 10 yards. A hostile target heals the lowest-health injured ally within 10 yards for 40%. No secondary effect occurs without a valid target.',
        'Repeats your last direct Holy spell and creates a 40% opposite-role secondary effect.', 133, 1500, 1),
    (901153, 0x00000010, 45000, 1, 1, 1, 32, 6, 0, 12, -1, 3, 1, 0,
        @priest_icon, 'Void Eruption',
        'Deals Mind Blast-scaled Shadow damage to every living same-map enemy carrying your Shadow Word: Pain, Vampiric Touch, or Devouring Plague, plus 20% per active effect. Refreshes those effects and forces stock Devouring Plague to erupt.',
        'Erupts all targets carrying your Shadow periodic effects.', 133, 1500, 1)
ON DUPLICATE KEY UPDATE `Name_Lang_enUS` = VALUES(`Name_Lang_enUS`);

INSERT INTO `spell_dbc` (`ID`, `Attributes`, `RecoveryTime`, `DurationIndex`,
    `RangeIndex`, `CumulativeAura`, `SchoolMask`, `SpellClassSet`, `DispelType`,
    `EquippedItemClass`, `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `Effect_2`, `EffectDieSides_2`,
    `EffectBasePoints_2`, `EffectMiscValue_2`, `ImplicitTargetA_2`,
    `EffectAura_2`, `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`, `StartRecoveryCategory`, `StartRecoveryTime`,
    `DefenseType`)
SELECT 901145, 0x00000010, 120000, 18, 1, 1, 2, 6, 0, -1,
    6, 1, -21, 1, 65, 6, 1, -21, 2, 1, 72, @priest_icon, 'Apotheosis',
    'For 20 seconds, grants 20% spell haste, reduces Holy Priest spell mana costs by 20%, halves the cooldown added by Holy Word: Radiance casts, and raises Blessed Echoes chance to 40%.',
    'Spell haste increased by 20%. Holy spell costs reduced by 20%.', 133, 1500, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901145);

INSERT INTO `spell_dbc` (`ID`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`, `EffectAura_1`,
    `EffectAuraPeriod_1`, `EffectMultipleValue_1`, `SpellIconID`,
    `Name_Lang_enUS`, `Description_Lang_enUS`, `AuraDescription_Lang_enUS`)
SELECT 901148,
    COALESCE((SELECT `DurationIndex` FROM `wotlk_spells_full` WHERE `ID` = 48300), 18),
    13, 1, 32, 6, 3, -1, 6, 0, 0, 6, 53,
    COALESCE((SELECT `EffectAuraPeriod_1` FROM `wotlk_spells_full` WHERE `ID` = 48300), 3000),
    COALESCE((SELECT `EffectMultipleValue_1` FROM `wotlk_spells_full` WHERE `ID` = 48300), 0.15),
    @priest_icon, 'Copied Devouring Plague',
    'A fresh-duration copy of Devouring Plague with snapshotted periodic damage and normal leech healing. It does not store Devouring Echo damage.',
    'Deals periodic Shadow damage and heals the caster.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901148);

INSERT INTO `spell_dbc` (`ID`, `DurationIndex`, `RangeIndex`, `CumulativeAura`,
    `SchoolMask`, `SpellClassSet`, `DispelType`, `EquippedItemClass`, `Effect_1`,
    `EffectDieSides_1`, `EffectBasePoints_1`, `ImplicitTargetA_1`, `EffectAura_1`,
    `Effect_2`, `EffectDieSides_2`, `EffectBasePoints_2`, `ImplicitTargetA_2`,
    `EffectAura_2`, `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`)
SELECT 901150, 31, 1, 50, 32, 6, 1, -1,
    6, 1, -2, 6, 33, 6, 1, -2, 6, 118, @priest_icon, 'Void Presence',
    'Reduces movement speed and healing taken by 1% per stack for 8 seconds. Stacks 50 times.',
    'Movement speed and healing taken reduced by 1% per stack.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `spell_dbc` WHERE `ID` = 901150);

UPDATE `spell_dbc` SET `ProcTypeMask` = 0x00015554, `ProcChance` = 100
WHERE `ID` = 901151 AND `Name_Lang_enUS` = 'Devouring Echo';

INSERT INTO `spell_proc` (`SpellId`, `SchoolMask`, `SpellFamilyName`,
    `SpellFamilyMask0`, `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`,
    `SpellTypeMask`, `SpellPhaseMask`, `HitMask`, `AttributesMask`,
    `DisableEffectsMask`, `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`)
VALUES
    (901118, 0, 6, 0, 0, 0, 0x00055554, 3, 2, 0, 2, 0, 0, 100, 0, 0),
    (901123, 0, 6, 0, 0, 0, 0x00055554, 3, 2, 0, 2, 0, 0, 100, 0, 0),
    (901131, 0, 6, 0, 0, 0, 0x00015554, 1, 2, 0, 2, 0, 0, 100, 0, 0),
    (901142, 0, 6, 0, 0, 0, 0x00055554, 3, 2, 0, 2, 0, 0, 100, 0, 0),
    (901151, 0, 6, 0, 0, 0, 0x00015554, 1, 2, 0, 2, 0, 0, 100, 0, 0)
ON DUPLICATE KEY UPDATE `ProcFlags` = VALUES(`ProcFlags`),
    `SpellTypeMask` = VALUES(`SpellTypeMask`), `SpellPhaseMask` = VALUES(`SpellPhaseMask`),
    `AttributesMask` = VALUES(`AttributesMask`), `Chance` = VALUES(`Chance`);

DELETE FROM `spell_script_names` WHERE `ScriptName` IN (
    'spell_apoc_priest_spiritual_conservation', 'spell_apoc_priest_rapid_surge',
    'spell_apoc_priest_inner_renewal', 'spell_apoc_priest_rapid_penance',
    'spell_apoc_priest_archangel', 'spell_apoc_priest_atonement',
    'spell_apoc_priest_radiance', 'spell_apoc_priest_blessed_echoes',
    'spell_apoc_priest_dot', 'spell_apoc_priest_mind_blast',
    'spell_apoc_priest_mind_flay', 'spell_apoc_priest_devouring_echo',
    'spell_apoc_priest_void_eruption'
);

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
    (901118, 'spell_apoc_priest_spiritual_conservation'),
    (901123, 'spell_apoc_priest_rapid_surge'),
    (901121, 'spell_apoc_priest_inner_renewal'),
    (-47757, 'spell_apoc_priest_rapid_penance'),
    (-47758, 'spell_apoc_priest_rapid_penance'),
    (901129, 'spell_apoc_priest_archangel'),
    (901131, 'spell_apoc_priest_atonement'),
    (901139, 'spell_apoc_priest_radiance'),
    (901140, 'spell_apoc_priest_radiance'),
    (901141, 'spell_apoc_priest_radiance'),
    (901142, 'spell_apoc_priest_blessed_echoes'),
    (-589, 'spell_apoc_priest_dot'),
    (-34914, 'spell_apoc_priest_dot'),
    (-2944, 'spell_apoc_priest_dot'),
    (901148, 'spell_apoc_priest_dot'),
    (-8092, 'spell_apoc_priest_mind_blast'),
    (58381, 'spell_apoc_priest_mind_flay'),
    (901151, 'spell_apoc_priest_devouring_echo'),
    (901153, 'spell_apoc_priest_void_eruption')
ON DUPLICATE KEY UPDATE `ScriptName` = VALUES(`ScriptName`);

DELETE FROM `spell_bonus_data` WHERE `entry` IN (901119, 901132, 901140, 901141,
    901143, 901144, 901148, 901152, 901154);
INSERT INTO `spell_bonus_data` (`entry`, `direct_bonus`, `dot_bonus`,
    `ap_bonus`, `ap_dot_bonus`, `comments`) VALUES
    (901119, 0, 0, 0, 0, 'Priest pack fixed mana helper'),
    (901132, 0, 0, 0, 0, 'Priest pack fixed Atonement heal'),
    (901140, 0, 0, 0, 0, 'Priest - Holy Word: Radiance damage'),
    (901141, 0, 0, 0, 0, 'Priest - Holy Word: Radiance heal'),
    (901143, 0, 0, 0, 0, 'Priest pack fixed Blessed Echo damage'),
    (901144, 0, 0, 0, 0, 'Priest pack fixed Blessed Echo heal'),
    (901148, 0, 0, 0, 0, 'Priest pack snapshotted copied Devouring Plague'),
    (901152, 0, 0, 0, 0, 'Priest pack fixed Devouring Echo damage'),
    (901154, 0.268, 0, 0, 0, 'Priest - Void Eruption damage');

INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT `ID`, 0x01000000 FROM `spell_dbc`
WHERE `ID` IN (901119, 901124, 901126, 901128, 901130, 901132, 901134,
    901137, 901138, 901140, 901141, 901143, 901144, 901148, 901150,
    901152, 901154)
ON DUPLICATE KEY UPDATE `attributes` = `spell_custom_attr`.`attributes` | VALUES(`attributes`);

INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT `ID`, `Name_Lang_enUS` FROM `spell_dbc`
WHERE `ID` BETWEEN 901118 AND 901154
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

SET @haunting_affliction_balance_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901028
      AND `Name_Lang_enUS` = 'Haunting Affliction'
      AND `Attributes` = 0x00000040
      AND `DurationIndex` = 21
      AND `SpellClassSet` = 5
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

SET @demonic_equilibrium_balance_owned := (
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

SET @divine_toll_balance_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901024
      AND `Name_Lang_enUS` = 'Divine Toll'
      AND `RecoveryTime` = 60000
      AND `DurationIndex` = 35
      AND `ManaCostPct` = 10
      AND `SpellClassSet` = 10
      AND `Effect_1` = 3
      AND `ImplicitTargetA_1` = 6
      AND `Effect_2` = 6
      AND `EffectBasePoints_2` = -1
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 4
);

SET @spell_balance_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901028
          AND @haunting_affliction_balance_owned = 0
        UNION ALL
        SELECT 3 FROM `spell_dbc`
        WHERE `ID` = 901033
          AND @demonic_equilibrium_balance_owned = 0
        UNION ALL
        SELECT 4 FROM `spell_dbc`
        WHERE `ID` = 901024
          AND @divine_toll_balance_owned = 0
    ) AS `collision_guard`
);

UPDATE `spell_dbc`
SET `Description_Lang_enUS` = 'When Haunt hits, it applies your highest learned ranks of Curse of Agony, Corruption, and Unstable Affliction. Curse of Agony will not replace another curse, and Corruption will not replace Seed of Corruption.',
    `AuraDescription_Lang_enUS` = 'Every Haunt applies your eligible Affliction damage over time spells.'
WHERE `ID` = 901028
  AND @haunting_affliction_balance_owned = 1;

UPDATE `spell_dbc`
SET `Description_Lang_enUS` = 'Increases the amount of damage transferred by your Soul Link to 50%.',
    `AuraDescription_Lang_enUS` = 'Soul Link transfers 50% of damage taken to your demon.'
WHERE `ID` = 901033
  AND @demonic_equilibrium_balance_owned = 1;

UPDATE `spell_dbc`
SET `Description_Lang_enUS` = 'Unleashes 5 Judgements against an enemy. Each impact deals 80% damage, applies Judgement of Justice, and occurs 0.5 sec after the previous impact.',
    `AuraDescription_Lang_enUS` = 'Unleashing 5 sequential Judgements at 20% reduced damage.'
WHERE `ID` = 901024
  AND @divine_toll_balance_owned = 1;

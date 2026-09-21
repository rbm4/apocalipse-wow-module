SET @divine_steed_cast_cancel_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901017
      AND `Name_Lang_enUS` = 'Divine Steed'
      AND `Attributes` = 0x00000010
      AND `AuraInterruptFlags` = 0
      AND `RecoveryTime` = 20000
      AND `DurationIndex` = 35
      AND `DispelType` = 0
      AND `SchoolMask` = 2
      AND `SpellClassSet` = 10
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
      AND `Effect_2` = 6
      AND `EffectBasePoints_2` = 99
      AND `ImplicitTargetA_2` = 1
      AND `EffectAura_2` = 31
      AND `Description_Lang_enUS` IN (
          'Calls upon the Light to grant 100% increased movement speed for 4 sec. The paladin appears mounted but can continue fighting normally.',
          'Calls upon the Light to grant 100% increased movement speed for 4 sec. Casting another spell cancels this effect.'
      )
      AND `AuraDescription_Lang_enUS` IN (
          'Movement speed increased by 100%.',
          'Movement speed increased by 100%. Casting another spell cancels this effect.'
      )
);

SET @divine_steed_cast_cancel_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901017
          AND @divine_steed_cast_cancel_owned = 0
    ) AS `collision_guard`
);

UPDATE `spell_dbc`
SET `Description_Lang_enUS` = 'Calls upon the Light to grant 100% increased movement speed for 4 sec. Casting another spell cancels this effect.',
    `AuraDescription_Lang_enUS` = 'Movement speed increased by 100%. Casting another spell cancels this effect.'
WHERE `ID` = 901017
  AND @divine_steed_cast_cancel_owned = 1;

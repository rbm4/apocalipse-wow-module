SET @buckler_strike_balance_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901078
      AND `Name_Lang_enUS` = 'Buckler Strike'
      AND `Attributes` = 0x00010010
      AND `AttributesEx` = 0x00000210
      AND `AttributesEx4` = 0x00800000
      AND `RecoveryTime` IN (6000, 20000)
      AND `DurationIndex` = 27
      AND `PowerType` = 3
      AND `ManaCost` = 25
      AND `SchoolMask` = 1
      AND `SpellClassSet` = 8
      AND `EquippedItemClass` = 4
      AND `EquippedItemSubclass` = 64
      AND `EquippedItemInvTypes` = 16384
      AND `Effect_1` = 2
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = -1
      AND `ImplicitTargetA_1` = 6
      AND `Effect_2` = 80
      AND `EffectDieSides_2` = 1
      AND `EffectBasePoints_2` = 0
      AND `ImplicitTargetA_2` = 6
      AND `Effect_3` = 68
      AND `EffectDieSides_3` = 1
      AND `EffectBasePoints_3` = 0
      AND `ImplicitTargetA_3` = 6
);

UPDATE `spell_dbc`
SET `RecoveryTime` = 20000,
    `Description_Lang_enUS` = 'Strikes with your equipped shield for Physical damage equal to 110% of attack power plus 150% of shield block value, applies Blade Twisting, awards 1 combo point, and generates high threat. Interrupts non-player spellcasting for 3 sec. Requires a shield.'
WHERE `ID` = 901078
  AND @buckler_strike_balance_managed = 1;

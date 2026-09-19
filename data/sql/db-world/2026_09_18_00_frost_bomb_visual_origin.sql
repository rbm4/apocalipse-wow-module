SET @frost_bomb_explosion_visual_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901008
      AND `Name_Lang_enUS` = 'Frost Bomb Explosion'
      AND `AttributesEx2` = 0x40000001
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 3
      AND `SpellClassMask_1` = 32
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 2
      AND `EffectDieSides_1` = 1
      AND `EffectBasePoints_1` = 689
      AND ABS(`EffectBonusMultiplier_1` - 0.4) < 0.0001
      AND `ImplicitTargetA_1` = 53
      AND `ImplicitTargetB_1` = 16
      AND `EffectRadiusIndex_1` = 13
      AND `SpellVisualID_1` IN (0, 17)
);

SET @frost_bomb_explosion_visual_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901008
          AND @frost_bomb_explosion_visual_owned = 0
    ) AS `collision_guard`
);

UPDATE `spell_dbc`
SET `SpellVisualID_1` = 0
WHERE @frost_bomb_explosion_visual_owned = 1
  AND `ID` = 901008;

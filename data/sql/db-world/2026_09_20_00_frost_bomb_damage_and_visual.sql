SET @frost_bomb_damage_owned := (
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
      AND (
          (`EffectBasePoints_1` = 689
              AND ABS(`EffectBonusMultiplier_1` - 0.4) < 0.0001)
          OR (`EffectBasePoints_1` = 1379
              AND ABS(`EffectBonusMultiplier_1` - 0.8) < 0.0001)
      )
      AND `ImplicitTargetA_1` = 53
      AND `ImplicitTargetB_1` = 16
      AND `EffectRadiusIndex_1` = 13
      AND `SpellVisualID_1` IN (0, 17)
);

SET @frost_bomb_damage_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901008
          AND @frost_bomb_damage_owned = 0
    ) AS `collision_guard`
);

UPDATE `spell_dbc`
SET `EffectBasePoints_1` = 1979,
    `EffectBonusMultiplier_1` = 0.8,
    `SpellVisualID_1` = 0,
    `Description_Lang_enUS` = 'Deals $s1 Frost damage to enemies within 10 yards of the Frost Bomb and applies Frost Bomb Slow.'
WHERE `ID` = 901008
  AND @frost_bomb_damage_owned = 1;

UPDATE `spell_dbc`
SET `Description_Lang_enUS` = 'Places a Frost Bomb on an enemy. After 4 sec, or when dispelled or the target dies, it explodes for 1380 Frost damage to enemies within 10 yards and applies Frost Bomb Slow.'
WHERE `ID` = 901007
  AND @frost_bomb_damage_owned = 1
  AND `Name_Lang_enUS` = 'Frost Bomb'
  AND `Effect_1` = 6
  AND `EffectBasePoints_1` = 901007
  AND `ImplicitTargetA_1` = 6
  AND `EffectAura_1` = 4;

SET @frost_bomb_bonus_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_bonus_data`
    WHERE `entry` = 901008
      AND `comments` = 'Mage - Frost Bomb Explosion'
      AND (
          ABS(`direct_bonus` - 0.4) < 0.0001
          OR ABS(`direct_bonus` - 0.8) < 0.0001
      )
      AND `dot_bonus` = 0
      AND `ap_bonus` = 0
      AND `ap_dot_bonus` = 0
);

SET @frost_bomb_bonus_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_bonus_data`
        WHERE `entry` = 901008
          AND @frost_bomb_bonus_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `spell_bonus_data`
    (`entry`, `direct_bonus`, `dot_bonus`, `ap_bonus`, `ap_dot_bonus`, `comments`)
SELECT 901008, 0.8, 0, 0, 0, 'Mage - Frost Bomb Explosion'
FROM DUAL
WHERE @frost_bomb_damage_owned = 1
  AND NOT EXISTS (
      SELECT 1 FROM `spell_bonus_data` WHERE `entry` = 901008
  );

UPDATE `spell_bonus_data`
SET `direct_bonus` = 0.8
WHERE `entry` = 901008
  AND @frost_bomb_bonus_owned = 1
  AND (
      ABS(`direct_bonus` - 0.4) < 0.0001
      OR ABS(`direct_bonus` - 0.8) < 0.0001
  )
  AND `comments` = 'Mage - Frost Bomb Explosion';

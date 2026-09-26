UPDATE `spell_bonus_data`
SET `ap_dot_bonus` = 0.01
WHERE `entry` = 901049
  AND `ap_dot_bonus` <> 0.01;

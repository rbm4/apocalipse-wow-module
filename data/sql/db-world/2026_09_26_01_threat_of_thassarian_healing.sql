SET @thassarian_rank_1_description := 'When dual-wielding, your Death Strike, Obliterate, Plague Strike, Rune Strike, Blood Strike, Frost Strike, Heart Strike, and Scourge Strike have a 30% chance to also strike with your off-hand weapon. A successful off-hand Death Strike also heals you. Each Death Strike heal is reduced by 30% while a usable off-hand weapon is equipped.';
SET @thassarian_rank_2_description := 'When dual-wielding, your Death Strike, Obliterate, Plague Strike, Rune Strike, Blood Strike, Frost Strike, Heart Strike, and Scourge Strike have a 60% chance to also strike with your off-hand weapon. A successful off-hand Death Strike also heals you. Each Death Strike heal is reduced by 30% while a usable off-hand weapon is equipped.';
SET @thassarian_rank_3_description := 'When dual-wielding, your Death Strike, Obliterate, Plague Strike, Rune Strike, Blood Strike, Frost Strike, Heart Strike, and Scourge Strike also strike with your off-hand weapon. A successful off-hand Death Strike also heals you. Each Death Strike heal is reduced by 30% while a usable off-hand weapon is equipped.';

DELETE FROM `spell_script_names`
WHERE `spell_id` = -66188
  AND `ScriptName` = 'spell_dk_death_strike';

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`)
VALUES (-66188, 'spell_dk_death_strike');

UPDATE `spell_dbc`
SET `Description_Lang_enUS` = CASE `ID`
        WHEN 65661 THEN @thassarian_rank_1_description
        WHEN 66191 THEN @thassarian_rank_2_description
        WHEN 66192 THEN @thassarian_rank_3_description
    END
WHERE `ID` IN (65661, 66191, 66192)
  AND `Name_Lang_enUS` = 'Threat of Thassarian'
  AND `SpellClassSet` = 15
  AND `SpellIconID` = 2023
  AND `Effect_1` = 6
  AND `EffectAura_1` = 4;

SET @rogue_block_reward_owned := (
    SELECT COUNT(*) = 1
    FROM `skilllineability_dbc`
    WHERE `ID` = 10001
      AND `SkillLine` = 95
      AND `Spell` = 107
      AND `RaceMask` = 0
      AND `ClassMask` = 8
      AND `ExcludeRace` = 0
      AND `ExcludeClass` = 0
      AND `MinSkillLineRank` = 1
      AND `SupercededBySpell` = 0
      AND `AcquireMethod` = 2
      AND `TrivialSkillLineRankHigh` = 0
      AND `TrivialSkillLineRankLow` = 0
      AND `CharacterPoints_1` = 0
      AND `CharacterPoints_2` = 0
);

SET @rogue_block_reward_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2
        FROM `skilllineability_dbc`
        WHERE `ID` = 10001
          AND @rogue_block_reward_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `skilllineability_dbc` (
    `ID`, `SkillLine`, `Spell`, `RaceMask`, `ClassMask`, `ExcludeRace`,
    `ExcludeClass`, `MinSkillLineRank`, `SupercededBySpell`, `AcquireMethod`,
    `TrivialSkillLineRankHigh`, `TrivialSkillLineRankLow`,
    `CharacterPoints_1`, `CharacterPoints_2`
)
SELECT
    10001, 95, 107, 0, 8, 0,
    0, 1, 0, 2,
    0, 0,
    0, 0
FROM DUAL
WHERE @rogue_block_reward_owned = 0;

SET @rogue_shield_proficiency_reward_owned := (
    SELECT COUNT(*) = 1
    FROM `skilllineability_dbc`
    WHERE `ID` = 10002
      AND `SkillLine` = 433
      AND `Spell` = 9116
      AND `RaceMask` = 0
      AND `ClassMask` = 8
      AND `ExcludeRace` = 0
      AND `ExcludeClass` = 0
      AND `MinSkillLineRank` = 1
      AND `SupercededBySpell` = 0
      AND `AcquireMethod` = 2
      AND `TrivialSkillLineRankHigh` = 0
      AND `TrivialSkillLineRankLow` = 0
      AND `CharacterPoints_1` = 0
      AND `CharacterPoints_2` = 0
);

SET @rogue_shield_proficiency_reward_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2
        FROM `skilllineability_dbc`
        WHERE `ID` = 10002
          AND @rogue_shield_proficiency_reward_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `skilllineability_dbc` (
    `ID`, `SkillLine`, `Spell`, `RaceMask`, `ClassMask`, `ExcludeRace`,
    `ExcludeClass`, `MinSkillLineRank`, `SupercededBySpell`, `AcquireMethod`,
    `TrivialSkillLineRankHigh`, `TrivialSkillLineRankLow`,
    `CharacterPoints_1`, `CharacterPoints_2`
)
SELECT
    10002, 433, 9116, 0, 8, 0,
    0, 1, 0, 2,
    0, 0,
    0, 0
FROM DUAL
WHERE @rogue_shield_proficiency_reward_owned = 0;

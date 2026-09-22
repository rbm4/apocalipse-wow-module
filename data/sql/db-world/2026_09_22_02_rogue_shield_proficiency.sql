SET @rogue_shield_skill_info_owned := (
    SELECT COUNT(*) = 1
    FROM `skillraceclassinfo_dbc`
    WHERE `ID` = 10000
      AND `SkillID` = 433
      AND `RaceMask` = 2047
      AND `ClassMask` = 8
      AND `Flags` = 128
      AND `MinLevel` = 0
      AND `SkillTierID` = 0
      AND `SkillCostIndex` = 0
);

SET @rogue_shield_skill_info_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2
        FROM `skillraceclassinfo_dbc`
        WHERE `ID` = 10000
          AND @rogue_shield_skill_info_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `skillraceclassinfo_dbc` (
    `ID`, `SkillID`, `RaceMask`, `ClassMask`, `Flags`, `MinLevel`,
    `SkillTierID`, `SkillCostIndex`
)
SELECT
    10000, 433, 2047, 8, 128, 0,
    0, 0
FROM DUAL
WHERE @rogue_shield_skill_info_owned = 0;

SET @rogue_shield_skill_info_managed := (
    SELECT COUNT(*) = 1
    FROM `skillraceclassinfo_dbc`
    WHERE `ID` = 10000
      AND `SkillID` = 433
      AND `RaceMask` = 2047
      AND `ClassMask` = 8
      AND `Flags` = 128
      AND `MinLevel` = 0
      AND `SkillTierID` = 0
      AND `SkillCostIndex` = 0
);

SET @rogue_shield_default_owned := (
    SELECT COUNT(*) = 1
    FROM `playercreateinfo_skills`
    WHERE `raceMask` = 0
      AND `classMask` = 8
      AND `skill` = 433
      AND `rank` = 0
      AND `comment` = 'Rogue - Shield'
);

SET @rogue_shield_default_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2
        FROM `playercreateinfo_skills`
        WHERE `raceMask` = 0
          AND `classMask` = 8
          AND `skill` = 433
          AND @rogue_shield_default_owned = 0
    ) AS `collision_guard`
);

INSERT INTO `playercreateinfo_skills` (
    `raceMask`, `classMask`, `skill`, `rank`, `comment`
)
SELECT
    0, 8, 433, 0, 'Rogue - Shield'
FROM DUAL
WHERE @rogue_shield_skill_info_managed = 1
  AND @rogue_shield_default_owned = 0;

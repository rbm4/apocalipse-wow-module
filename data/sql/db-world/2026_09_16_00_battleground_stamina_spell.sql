-- Module world update: Battleground Stamina Assistance (spell 901002).
-- The ID was checked against the local unpatched WotLK Spell.dbc. Verify it
-- against the live spell_dbc, wotlk_spells_full, wotlk_spells, and selected
-- client DBC before deployment. A first-run collision in any world table makes
-- the update fail before mutation instead of replacing another spell. A matching
-- existing spell_dbc row is treated as module-owned so this update can be rerun
-- safely.
-- The backend's wotlk_spells_full import must exist for the collision guard.
-- Worldserver applies this update at startup when world DB updates and module
-- update discovery are enabled; recompiling the module alone does not run it.

SET @battleground_stamina_spell_owned := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901002
      AND `Name_Lang_enUS` = 'Battleground inspiration'
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 29
      AND `EffectMiscValue_1` = 2
);

-- A scalar subquery fails before mutation if a first-run ID collision exists.
SET @battleground_stamina_collision_guard := (
    SELECT `guard_row`
    FROM (
        SELECT 1 AS `guard_row`
        UNION ALL
        SELECT 2 FROM `spell_dbc`
        WHERE `ID` = 901002 AND @battleground_stamina_spell_owned = 0
        UNION ALL
        SELECT 3 FROM `wotlk_spells_full`
        WHERE `ID` = 901002 AND @battleground_stamina_spell_owned = 0
        UNION ALL
        SELECT 4 FROM `wotlk_spells`
        WHERE `ID` = 901002 AND @battleground_stamina_spell_owned = 0
    ) AS `collision_guard`
);

-- Repair installations created before EquippedItemClass was set explicitly.
UPDATE `spell_dbc`
SET `EquippedItemClass` = -1,
    `EquippedItemSubclass` = 0,
    `EquippedItemInvTypes` = 0
WHERE `ID` = 901002
  AND @battleground_stamina_spell_owned = 1;

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `AttributesEx3`, `DurationIndex`, `RangeIndex`,
    `CumulativeAura`, `SchoolMask`, `SpellClassSet`, `DispelType`,
    `EquippedItemClass`, `EquippedItemSubclass`, `EquippedItemInvTypes`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `EffectMiscValue_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`
) SELECT
    901002, 0x80000000, 0x00100000, 21, 1,
    1, 1, 0, 0,
    -1, 0, 0,
    6, 0, 1,
    1, 29, 2,
    685, 'Battleground inspiration',
    'Increases Stamina based on your unbuffed health while in a battleground.',
    'Stamina increased based on your unbuffed health while in a battleground.'
FROM DUAL
WHERE @battleground_stamina_spell_owned = 0;

SET @battleground_stamina_spell_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901002
      AND `Name_Lang_enUS` = 'Battleground inspiration'
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 29
      AND `EffectMiscValue_1` = 2
);

-- Prevent a battleground-only aura from being saved to character_aura.
INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
SELECT 901002, 0x01000000
FROM DUAL
WHERE @battleground_stamina_spell_managed = 1
ON DUPLICATE KEY UPDATE `attributes` = `attributes` | VALUES(`attributes`);

-- Keep the backend spell browser's name/picker cache in sync with spell_dbc.
INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901002, 'Battleground Stamina Assistance'
FROM DUAL
WHERE @battleground_stamina_spell_managed = 1
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- Module world update: Battleground Stamina Assistance (spell 901002).
-- The ID was checked against the local unpatched WotLK Spell.dbc. Verify it
-- against the live spell_dbc, wotlk_spells_full, wotlk_spells, and selected
-- client DBC before deployment. An occupied ID in any world table makes the first
-- INSERT fail instead of replacing an existing spell. The backend's
-- wotlk_spells_full import must exist for this deployment guard.
-- Worldserver applies this update at startup when world DB updates and module
-- update discovery are enabled; recompiling the module alone does not run it.

INSERT INTO `spell_dbc` (
    `ID`, `Attributes`, `AttributesEx3`, `DurationIndex`, `RangeIndex`,
    `CumulativeAura`, `SchoolMask`, `SpellClassSet`, `DispelType`,
    `Effect_1`, `EffectDieSides_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `EffectMiscValue_1`,
    `SpellIconID`, `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`
) SELECT
    901002, 0x80000000, 0x00100000, 21, 1,
    1, 1, 0, 0,
    6, 0, 1,
    1, 29, 2,
    685, 'Battleground inspiration',
    'Increases Stamina based on your unbuffed health while in a battleground.',
    'Stamina increased based on your unbuffed health while in a battleground.'
FROM (
    SELECT 1 AS `guard_row`
    UNION ALL
    SELECT 2 FROM `wotlk_spells_full` WHERE `ID` = 901002
    UNION ALL
    SELECT 3 FROM `wotlk_spells` WHERE `ID` = 901002
) AS `collision_guard`;

-- Prevent a battleground-only aura from being saved to character_aura.
INSERT INTO `spell_custom_attr` (`spell_id`, `attributes`)
VALUES (901002, 0x01000000)
ON DUPLICATE KEY UPDATE `attributes` = `attributes` | VALUES(`attributes`);

-- Keep the backend spell browser's name/picker cache in sync with spell_dbc.
INSERT INTO `wotlk_spells` (`ID`, `name`)
VALUES (901002, 'Battleground Stamina Assistance')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

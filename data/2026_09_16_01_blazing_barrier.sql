-- Manual migration for acore_world. Run after mod_apocalipse.sql and
-- mod_spell_scaling.sql, while worldserver is stopped. Do not put this file in
-- data/sql/db-world: that directory is processed by the automatic updater.
--
-- Spell 901001 is the provisional ID used by mod_apocalipse_mage_spells.cpp.
-- Check the live spell_dbc, wotlk_spells_full, wotlk_spells, and client
-- Spell.dbc before running this file. A collision aborts the first INSERT.
-- A server SQL row alone does not add the spell to the player's client; export
-- a new client Spell.dbc/patch after importing this migration.

USE `acore_world`;
SET @blazing_barrier_inserted := 0;

-- Level 80 shield based on Ice Barrier rank 8 (43039): 3300 base absorb,
-- 15 additional base absorb per level above 80, 30 seconds, 30 second cooldown,
-- 21% base mana cost. The AuraScript adds 80.68% of fire spell power.
-- Its school absorb mask is 127 (all damage schools); SchoolMask 4 makes
-- the spell itself a fire spell. The visual comes from Fire Ward and the icon
-- from Molten Armor, avoiding Ice Barrier's icon-based recast lookup.
INSERT INTO `spell_dbc` (
    `ID`, `Category`, `DispelType`, `Attributes`, `CastingTimeIndex`,
    `CategoryRecoveryTime`, `InterruptFlags`, `ProcChance`, `MaxLevel`,
    `BaseLevel`, `SpellLevel`, `DurationIndex`, `RangeIndex`,
    `EquippedItemClass`, `Effect_1`, `EffectDieSides_1`,
    `EffectRealPointsPerLevel_1`, `EffectBasePoints_1`,
    `ImplicitTargetA_1`, `EffectAura_1`, `EffectMiscValue_1`,
    `SpellVisualID_1`, `SpellIconID`, `SpellPriority`,
    `Name_Lang_enUS`, `Description_Lang_enUS`,
    `AuraDescription_Lang_enUS`, `ManaCostPct`,
    `StartRecoveryCategory`, `StartRecoveryTime`, `SpellClassSet`,
    `DefenseType`, `PreventionType`, `EffectChainAmplitude_1`, `SchoolMask`
)
SELECT
    901001, 471, 1, 327680, 1,
    30000, 8, 101, 84,
    80, 80, 3, 1,
    -1, 6, 1,
    15.0, 3299,
    1, 69, 127,
    290, 2307, 50,
    'Blazing Barrier',
    'Surrounds you with a blazing barrier that absorbs $s1 damage. Lasts $d.',
    'Absorbs damage.', 21,
    133, 1500, 3,
    1, 1, 1.0, 4
FROM (
    SELECT 1 AS `guard_row`
    UNION ALL
    SELECT 2 FROM `wotlk_spells_full` WHERE `ID` = 901001
    UNION ALL
    SELECT 3 FROM `wotlk_spells` WHERE `ID` = 901001
) AS `collision_guard`;
SET @blazing_barrier_inserted := ROW_COUNT();

-- The binding also exists in the original module seed. Keep this migration
-- usable when that seed was imported before the spell definition existed.
INSERT IGNORE INTO `spell_script_names` (`spell_id`, `ScriptName`)
SELECT 901001, 'spell_apoc_mage_blazing_barrier'
WHERE @blazing_barrier_inserted = 1;

INSERT IGNORE INTO `mod_spell_scaling`
    (`spell_id`, `scale_type`, `scale_factor`, `description`)
SELECT 901001, 'ABSORB', 1.0, 'Blazing Barrier - absorb shield'
WHERE @blazing_barrier_inserted = 1;

-- Keep the backend spell picker in sync with spell_dbc.
INSERT INTO `wotlk_spells` (`ID`, `name`)
SELECT 901001, 'Blazing Barrier'
WHERE @blazing_barrier_inserted = 1;

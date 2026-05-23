-- ============================================================================
-- mod_spell_scaling.sql
-- Run ONCE on acore_world.
--
-- Creates mod_spell_scaling and seeds it with the initial spell list.
-- To add a new spell later: INSERT a row and restart the worldserver.
--
-- scale_type:
--   DAMAGE   - intercepted at final spell-damage application
--   HEAL     - intercepted at final heal application
--   PERIODIC - intercepted at each DoT/HoT tick
--   ABSORB   - applied to the absorb-shield amount when the aura lands
--
-- scale_factor:
--   Final multiplier = (playerLevel / 80) * scale_factor.
--   1.0 = full linear scaling (1% power at level 1, 50% at level 40, 100% at 80).
--   0.5 = half nerf (50% power at level 1, 75% at level 40, 100% at 80).
--   Useful when a spell already weakens naturally via low weapon/SP (set 0.5).
-- ============================================================================

USE acore_world;

CREATE TABLE IF NOT EXISTS `mod_spell_scaling` (
  `spell_id`     INT UNSIGNED  NOT NULL,
  `scale_type`   ENUM('DAMAGE','HEAL','PERIODIC','ABSORB') NOT NULL,
  `scale_factor` FLOAT         NOT NULL DEFAULT '1',
  `description`  VARCHAR(255)  DEFAULT NULL,
  PRIMARY KEY (`spell_id`, `scale_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── Warrior ──────────────────────────────────────────────────────────────────
INSERT IGNORE INTO `mod_spell_scaling` (`spell_id`, `scale_type`, `scale_factor`, `description`) VALUES
(46968, 'DAMAGE', 1.0, 'Shockwave - AoE stun + flat holy damage');

-- ── Paladin ──────────────────────────────────────────────────────────────────
INSERT IGNORE INTO `mod_spell_scaling` (`spell_id`, `scale_type`, `scale_factor`, `description`) VALUES
(20473, 'DAMAGE', 1.0, 'Holy Shock (damage)'),
(20473, 'HEAL',   1.0, 'Holy Shock (heal)'),
(31935, 'DAMAGE', 1.0, 'Avenger Shield - flat holy damage + SP'),
(47540, 'DAMAGE', 1.0, 'Penance (damage channel)'),
(47540, 'HEAL',   1.0, 'Penance (heal channel)'),
(53385, 'DAMAGE', 1.0, 'Divine Storm - AoE holy damage'),
(58597, 'ABSORB', 1.0, 'Sacred Shield');

-- ── Hunter ───────────────────────────────────────────────────────────────────
INSERT IGNORE INTO `mod_spell_scaling` (`spell_id`, `scale_type`, `scale_factor`, `description`) VALUES
(60053, 'DAMAGE',   1.0, 'Explosive Shot - flat fire damage'),
(60053, 'PERIODIC', 1.0, 'Explosive Shot (DoT ticks)'),
(53352, 'DAMAGE',   1.0, 'Explosive Shot (triggered damage)'),
(3674,  'PERIODIC', 1.0, 'Black Arrow (DoT ticks)');

-- ── Priest ───────────────────────────────────────────────────────────────────
INSERT IGNORE INTO `mod_spell_scaling` (`spell_id`, `scale_type`, `scale_factor`, `description`) VALUES
(34861, 'HEAL',     1.0, 'Circle of Healing - flat AoE heal'),
(34914, 'PERIODIC', 1.0, 'Vampiric Touch (DoT ticks)');

-- ── Death Knight ─────────────────────────────────────────────────────────────
INSERT IGNORE INTO `mod_spell_scaling` (`spell_id`, `scale_type`, `scale_factor`, `description`) VALUES
(49184, 'DAMAGE', 1.0, 'Howling Blast - AoE frost damage');

-- ── Shaman ───────────────────────────────────────────────────────────────────
INSERT IGNORE INTO `mod_spell_scaling` (`spell_id`, `scale_type`, `scale_factor`, `description`) VALUES
(51490, 'DAMAGE', 1.0, 'Thunderstorm - AoE + knockback + flat damage'),
(61295, 'HEAL',   1.0, 'Riptide (direct heal component)');

-- ── Mage ─────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO `mod_spell_scaling` (`spell_id`, `scale_type`, `scale_factor`, `description`) VALUES
(44425, 'DAMAGE',   1.0, 'Arcane Barrage - flat arcane damage'),
(44457, 'DAMAGE',   1.0, 'Living Bomb (explosion)'),
(44457, 'PERIODIC', 1.0, 'Living Bomb (DoT ticks)'),
(11426, 'ABSORB',   1.0, 'Ice Barrier - absorb shield');

-- ── Warlock ──────────────────────────────────────────────────────────────────
INSERT IGNORE INTO `mod_spell_scaling` (`spell_id`, `scale_type`, `scale_factor`, `description`) VALUES
(50796, 'DAMAGE', 1.0, 'Chaos Bolt - direct fire damage (bypasses resistances)'),
(30283, 'DAMAGE', 1.0, 'Shadowfury - AoE shadow stun'),
(48181, 'DAMAGE',   1.0, 'Haunt - direct shadow hit'),
(48181, 'PERIODIC', 1.0, 'Haunt (DoT ticks)');

-- ── Druid ────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO `mod_spell_scaling` (`spell_id`, `scale_type`, `scale_factor`, `description`) VALUES
(48505, 'DAMAGE', 1.0, 'Starfall - AoE falling star damage per tick'),
(50516, 'DAMAGE', 1.0, 'Typhoon - AoE + knockback + flat damage'),
(48438, 'HEAL',   1.0, 'Wild Growth (HoT ticks per target)');

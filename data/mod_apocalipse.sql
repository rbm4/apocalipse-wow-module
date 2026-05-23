-- ============================================================================
-- mod_apocalipse.sql
-- Run ONCE:
--   acore_world:      CREATE TABLE mod_spec_spells + creature_template entry
--   acore_characters: CREATE TABLE mod_player_spec
-- ============================================================================

-- ── acore_world ──────────────────────────────────────────────────────────────

USE acore_world;

-- Spec spell definitions.  Managed via the admin panel.
CREATE TABLE IF NOT EXISTS `mod_spec_spells` (
  `id`          INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  `class`       TINYINT UNSIGNED NOT NULL COMMENT '1=Warrior 2=Paladin 3=Hunter 4=Rogue 5=Priest 6=DK 7=Shaman 8=Mage 9=Warlock 11=Druid',
  `spec_index`  TINYINT UNSIGNED NOT NULL COMMENT '0=first tree 1=second tree 2=third tree',
  `spell_id`    INT UNSIGNED     NOT NULL,
  `description` VARCHAR(100)     DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_class_spec_spell` (`class`, `spec_index`, `spell_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Spec-selector NPC creature template.
-- Spawn in-game with:  .npc add 900001
INSERT IGNORE INTO `creature_template`
  (`entry`, `name`, `subname`, `minlevel`, `maxlevel`,
   `faction`, `npcflag`, `speed_run`, `BaseAttackTime`,
   `unit_class`, `unit_flags`, `type`, `RacialLeader`, `ScriptName`)
VALUES
  (900001, 'Spec Master', 'Specialization', 80, 80,
   35, 1, 1.14286, 2000,
   1, 33536, 7, 0, 'ModSpecNPC');

-- ── Sample spell data ─────────────────────────────────────────────────────────
-- Edit freely.  class column: see COMMENT above.
-- spec_index: 0 = leftmost tree, 1 = middle, 2 = rightmost (per WotLK UI).

-- Warrior
INSERT IGNORE INTO `mod_spec_spells` (`class`, `spec_index`, `spell_id`, `description`) VALUES
(1, 0, 46924, 'Bladestorm'),          -- Arms
(1, 0, 12328, 'Sweeping Strikes'),          -- Arms
(1, 0, 64976, 'Juggernaut'),          -- Arms
(1, 0, 29623, 'Endless Rage'),          -- Arms
(1, 0, 46854, 'Trauma (rank 1)'),          -- Arms
(1, 0, 12294, 'Mortal Strike'),       -- Arms
(1, 1, 12323, 'Piercing Howl'),       -- Fury
(1, 1, 12292, 'Death Wish'),         -- Fury
(1, 1, 23881, 'Bloodthirst'),         -- Fury
(1, 1, 29801, 'Rampage'),         -- Fury
(1, 1, 46917, 'Titans Grip'),         -- Fury
(1, 1, 60970, 'Heroic Fury'),         -- Fury
(1, 2, 46968, 'Shockwave'),           -- Protection
(1, 2, 57499, 'Warbringer'),           -- Protection
(1, 2, 12809, 'Concussion blow'),           -- Protection
(1, 2, 12311, 'Gag order (rank 1)'),           -- Protection
(1, 2, 12958, 'Gag order (rank 2)'),           -- Protection
(1, 2, 20243, 'Devastate');           -- Protection

-- Paladin
INSERT IGNORE INTO `mod_spec_spells` (`class`, `spec_index`, `spell_id`, `description`) VALUES
(2, 0, 20473, 'Holy Shock'),          -- Holy
(2, 0, 31842, 'Divine Illumination'),          -- Holy
(2, 0, 53556, 'Enlightned judgements'),          -- Holy
(2, 0, 53557, 'Enlightned judgements'),          -- Holy
(2, 0, 31833, 'Lights grace'),          -- Holy
(2, 0, 53563, 'Beacon of Light'),     -- Holy
(2, 1, 53595, 'Hammer of the Righteous'), -- Protection
(2, 1, 31935, 'Avenger Shield'),      -- Protection
(2, 1, 31850, 'Ardent defender (rank 1)'),      -- Protection
(2, 1, 31851, 'Ardent defender (rank 2)'),      -- Protection
(2, 1, 31852, 'Ardent defender (rank 3)'),      -- Protection
(2, 1, 20925, 'Holy Shield'),      -- Protection
(2, 2, 53385, 'Divine Storm'),        -- Retribution
(2, 2, 31876, 'Judgement of the Wise (Rank 1)'),-- Retribution
(2, 2, 31877, 'Judgement of the Wise (Rank 2)'),-- Retribution
(2, 2, 31878, 'Judgement of the Wise (Rank 3)'),-- Retribution
(2, 2, 20066, 'Repetance'),-- Retribution
(2, 2, 35395, 'Crusader Strike');     -- Retribution

-- Hunter
INSERT IGNORE INTO `mod_spec_spells` (`class`, `spec_index`, `spell_id`, `description`) VALUES
(3, 0, 19574, 'Bestial Wrath'),       -- Beast Mastery
(3, 0, 19577, 'Intimidation'),        -- Beast Mastery
(3, 0, 53270, 'Best Mastery'),        -- Beast Mastery
(3, 0, 34692, 'The Best Within'),        -- Beast Mastery
(3, 0, 19578, 'Spirit Bond (Rank 1)'),        -- Beast Mastery
(3, 0, 20895, 'Spirit Bond (Rank 2)'),        -- Beast Mastery
(3, 1, 19434, 'Aimed Shot'),          -- Marksmanship
(3, 1, 19506, 'Trueshot Aura'),          -- Marksmanship
(3, 1, 34490, 'Silencing Shot'),          -- Marksmanship
(3, 1, 53209, 'Chimera Shot'),        -- Marksmanship
(3, 1, 23989, 'Readiness'),        -- Marksmanship
(3, 1, 35100, 'Concussive Barrage'),        -- Marksmanship
(3, 2, 60053, 'Explosive Shot'),      -- Survival
(3, 2, 19385, 'Wyvern Sting'),      -- Survival
(3, 2, 56342, 'Lock and load (rank 1)'),      -- Survival
(3, 2, 56343, 'Lock and load (rank 2)'),      -- Survival
(3, 2, 56344, 'Lock and load (rank 3)'),      -- Survival
(3, 2, 3674, 'Black Arrow');          -- Survival

-- Rogue
INSERT IGNORE INTO `mod_spec_spells` (`class`, `spec_index`, `spell_id`, `description`) VALUES
(4, 0, 51662, 'Hunger For Blood'),    -- Assassination
(4, 0, 1329, 'Mutilate'),             -- Assassination
(4, 0, 31226, 'Master Poisoner'),             -- Assassination
(4, 0, 31227, 'Master Poisoner'),             -- Assassination
(4, 0, 58410, 'Master Poisoner'),             -- Assassination
(4, 0, 14177, 'Cold Blood'),          -- Assassination
(4, 1, 13877, 'Blade Flurry'),        -- Combat
(4, 1, 51690, 'Killing Spree'),       -- Combat
(4, 1, 31122, 'Vitality (rank 1)'),       -- Combat
(4, 1, 31123, 'Vitality (rank 2)'),       -- Combat
(4, 1, 61329, 'Vitality (rank 3)'),       -- Combat
(4, 1, 13750, 'Adrenaline Rush'),     -- Combat
(4, 2, 36554, 'Shadow Step'),         -- Subtlety
(4, 2, 14183, 'Premeditation'),         -- Subtlety
(4, 2, 14185, 'Preparation'),         -- Subtlety
(4, 2, 51692, 'Waylay'),         -- Subtlety
(4, 2, 51713, 'Shadow Dance'),        -- Subtlety
(4, 2, 16511, 'Hemorrhage');          -- Subtlety

-- Priest
INSERT IGNORE INTO `mod_spec_spells` (`class`, `spec_index`, `spell_id`, `description`) VALUES
(5, 0, 47540, 'Penance'),             -- Discipline
(5, 0, 33206, 'Pain Suppresion'),             -- Discipline
(5, 0, 10060, 'Power Infusion'),             -- Discipline
(5, 0, 63574, 'Soul Warding'),             -- Discipline
(5, 0, 47509, 'Divine Aegis (Rank 1)'),             -- Discipline
(5, 0, 47511, 'Divine Aegis (Rank 2)'),             -- Discipline
(5, 1, 34861, 'Circle of Healing'),         -- Holy
(5, 1, 47788, 'Guardian Spirit'),         -- Holy
(5, 1, 19236, 'Desperate Prayer'),         -- Holy
(5, 1, 64127, 'Body and Soul (rank 1)'),         -- Holy
(5, 1, 64129, 'Body and Soul (rank 2)'),         -- Holy
(5, 1, 724, 'Lightwell'),         -- Holy
(5, 2, 15473, 'Shadow Form'),         -- Shadow
(5, 2, 47585, 'Dispersion'),          -- Shadow
(5, 2, 15286, 'Vampiric Embrace'),          -- Shadow
(5, 2, 64044, 'Psychic Horror'),          -- Shadow
(5, 2, 15487, 'Silence'),          -- Shadow
(5, 2, 34914, 'Vampiric Touch');      -- Shadow

-- Death Knight
INSERT IGNORE INTO `mod_spec_spells` (`class`, `spec_index`, `spell_id`, `description`) VALUES
(6, 0, 55050, 'Heart Strike'),        -- Blood
(6, 0, 49016, 'Hysteria'),        -- Blood
(6, 0, 49028, 'Dancing Rune Weapon'),        -- Blood
(6, 1, 49184, 'Howling Blast'),       -- Frost
(6, 1, 49143, 'Frost Strike'),        -- Frost
(6, 1, 51271, 'Unbreakable Armor'),   -- Frost
(6, 2, 63560, 'Scourge Strike'),      -- Unholy
(6, 2, 49206, 'Summon Gargoyle'),     -- Unholy
(6, 2, 49222, 'Bone Shield');         -- Unholy

-- Shaman
INSERT IGNORE INTO `mod_spec_spells` (`class`, `spec_index`, `spell_id`, `description`) VALUES
(7, 0, 51490, 'Thunderstorm'),        -- Elemental
(7, 0, 16166, 'Elemental Mastery'),   -- Elemental
(7, 0, 30706, 'Totem of Wrath'),   -- Elemental
(7, 0, 16164, 'Elemental Focus'),   -- Elemental
(7, 0, 30664, 'Unrelenting storm (rank 1)'),   -- Elemental
(7, 0, 30665, 'Unrelenting storm (rank 2)'),   -- Elemental
(7, 1, 17364, 'Stormstrike'),         -- Enhancement
(7, 1, 30798, 'Dual Wield'),         -- Enhancement
(7, 1, 51521, 'Improved Stormstrike (rank 1)'),         -- Enhancement
(7, 1, 51522, 'Improved Stormstrike (Rank 2)'),         -- Enhancement
(7, 1, 51533, 'Feral Spirit'),         -- Enhancement
(7, 1, 60103, 'Lava Lash'),         -- Enhancement
(7, 2, 61295, 'Riptide'),             -- Restoration
(7, 2, 974,   'Earth Shield'),        -- Restoration
(7, 2, 16188,   'Natures swiftness'),        -- Restoration
(7, 2, 51556,   'Ancestral awakening (rank 1)'),        -- Restoration
(7, 2, 51557,   'Ancestral awakening (rank 2)'),        -- Restoration
(7, 2, 16190, 'Mana Tide Totem');     -- Restoration

-- Mage
INSERT IGNORE INTO `mod_spec_spells` (`class`, `spec_index`, `spell_id`, `description`) VALUES
(8, 0, 44425, 'Arcane Barrage'),      -- Arcane
(8, 0, 31589, 'Slow'),      -- Arcane
(8, 0, 44404, 'Missile barrage (rank 1)'),      -- Arcane
(8, 0, 54404, 'Missile barrage (rank 2)'),      -- Arcane
(8, 0, 54486, 'Missile barrage (rank 3)'),      -- Arcane
(8, 0, 12042, 'Arcane Power'),      -- Arcane
(8, 1, 11129, 'Combustion'),          -- Fire
(8, 1, 31661, 'Dragons Breath'),          -- Fire
(8, 1, 11113, 'Blast Wave'),          -- Fire
(8, 1, 44448, 'Hot Streak'),          -- Fire
(8, 1, 44457, 'Living Bomb'),         -- Fire
(8, 1, 11366, 'Pyroblast'),           -- Fire
(8, 2, 44572, 'Deep Freeze'),         -- Frost
(8, 2, 31687, 'Summon Water Elemental'), -- Frost
(8, 2, 44546, 'Brain Freeze (rank 1)'), -- Frost
(8, 2, 44548, 'Brain Freeze (rank 2)'), -- Frost
(8, 2, 44549, 'Brain Freeze (rank 3)'), -- Frost
(8, 2, 11426, 'Ice Barrier');         -- Frost

-- Warlock
INSERT IGNORE INTO `mod_spec_spells` (`class`, `spec_index`, `spell_id`, `description`) VALUES
(9, 0, 48181, 'Haunt'),                -- Affliction
(9, 0, 63108, 'Siphon Life'),                -- Affliction
(9, 0, 47195, 'Erradication (rank 1)'),                -- Affliction
(9, 0, 47196, 'Erradication (rank 2)'),                -- Affliction
(9, 0, 30108, 'Unstable Afliction'),   -- Affliction
(9, 0, 18223, 'Curse of Exhaustion'),  -- Affliction
(9, 1, 59672, 'Metamorphosis'),        -- Demonology
(9, 1, 30146, 'Summon Felguard'),      -- Demonology
(9, 1, 47193, 'Demonic Empowerment'),  -- Demonology
(9, 1, 63156, 'Decimation (rank 1)'),  -- Demonology
(9, 1, 63158, 'Decimation (rank 2)'),  -- Demonology
(9, 2, 50796, 'Chaos Bolt'),          -- Destruction
(9, 2, 30283, 'Shadowfury'),          -- Destruction
(9, 2, 47258, 'Backdraft (rank 1)'),          -- Destruction
(9, 2, 47259, 'Backdraft (rank 2)'),          -- Destruction
(9, 2, 47260, 'Backdraft (rank 3)'),          -- Destruction
(9, 2, 17962, 'Conflagrate');         -- Destruction

-- Druid
INSERT IGNORE INTO `mod_spec_spells` (`class`, `spec_index`, `spell_id`, `description`) VALUES
(11, 0, 48505, 'Starfall'),           -- Balance
(11, 0, 50516, 'Typhoon'),            -- Balance
(11, 0, 48516, 'Eclipse'),            -- Balance
(11, 0, 33597, 'Dreamstate'),            -- Balance
(11, 0, 33592, 'Balance of Power'),            -- Balance
(11, 0, 24858, 'Moonkin Form'),       -- Balance
(11, 1, 50334, 'Berserk'),            -- Feral
(11, 1, 33917, 'Mangle'),             -- Feral
(11, 1, 17007, 'Leader of the Pack'),             -- Feral
(11, 1, 48492, 'King of the Jungle (rank 1)'),             -- Feral
(11, 1, 48494, 'King of the Jungle (rank 1)'),             -- Feral
(11, 1, 61336, 'Survival Instincts'), -- Feral
(11, 2, 48438, 'Wild Growth'),        -- Restoration
(11, 2, 16864, 'Omen of clarity'),        -- Restoration
(11, 2, 48539, 'Revitalize (rank 1)'),        -- Restoration
(11, 2, 48544, 'Revitalize (rank 2)'),        -- Restoration
(11, 2, 65139, 'Tree of Life'),       -- Restoration
(11, 2, 18562, 'Swiftmend');          -- Restoration


-- ── acore_characters ─────────────────────────────────────────────────────────

USE acore_characters;

-- Tracks which spec was last granted to each player.
CREATE TABLE IF NOT EXISTS `mod_player_spec` (
  `guid`         INT UNSIGNED  NOT NULL,
  `granted_spec` TINYINT SIGNED NOT NULL DEFAULT -1 COMMENT '-1=none 0=first 1=second 2=third',
  PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Hidden bonus-talent budget granted by the module per player/spec.
CREATE TABLE IF NOT EXISTS `mod_player_spec_talent_budget` (
  `guid`           INT UNSIGNED      NOT NULL,
  `spec_index`     TINYINT UNSIGNED  NOT NULL COMMENT '0=first 1=second 2=third',
  `granted_points` TINYINT UNSIGNED  NOT NULL DEFAULT 0,
  PRIMARY KEY (`guid`, `spec_index`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Talent spell ranks that were explicitly granted by the module.
CREATE TABLE IF NOT EXISTS `mod_player_spec_talent_grant` (
  `guid`       INT UNSIGNED      NOT NULL,
  `spec_index` TINYINT UNSIGNED  NOT NULL COMMENT '0=first 1=second 2=third',
  `spell_id`   INT UNSIGNED      NOT NULL,
  PRIMARY KEY (`guid`, `spec_index`, `spell_id`),
  KEY `idx_guid_spec` (`guid`, `spec_index`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

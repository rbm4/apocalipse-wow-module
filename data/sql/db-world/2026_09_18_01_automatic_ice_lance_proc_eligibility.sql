SET @automatic_ice_lance_managed := (
    SELECT COUNT(*) = 1
    FROM `spell_dbc`
    WHERE `ID` = 901010
      AND `Name_Lang_enUS` = 'Automatic Ice Lance'
      AND `Attributes` = 0x00000040
      AND `ProcChance` = 10
      AND `SchoolMask` = 16
      AND `SpellClassSet` = 3
      AND `EquippedItemClass` = -1
      AND `Effect_1` = 6
      AND `EffectBasePoints_1` = 9
      AND `ImplicitTargetA_1` = 1
      AND `EffectAura_1` = 4
);

UPDATE `spell_dbc`
SET `ProcTypeMask` = 0x00050000,
    `Description_Lang_enUS` = 'Your Frost spell damage has a $s1% chance to cast Ice Lance automatically at the target and grant 1% spell haste for 10 sec. Haste contributions expire independently and can accumulate up to 20%.',
    `AuraDescription_Lang_enUS` = 'Frost spell damage can trigger an automatic Ice Lance.'
WHERE `ID` = 901010
  AND @automatic_ice_lance_managed = 1;

INSERT INTO `spell_proc` (
    `SpellId`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`,
    `SpellFamilyMask1`, `SpellFamilyMask2`, `ProcFlags`, `SpellTypeMask`,
    `SpellPhaseMask`, `HitMask`, `AttributesMask`, `DisableEffectsMask`,
    `ProcsPerMinute`, `Chance`, `Cooldown`, `Charges`
) SELECT
    901010, 16, 3, 0,
    0, 0, 0x00050000, 1,
    2, 0, 2, 0,
    0, 10, 1000, 0
FROM DUAL
WHERE @automatic_ice_lance_managed = 1
ON DUPLICATE KEY UPDATE
    `SchoolMask` = VALUES(`SchoolMask`),
    `SpellFamilyName` = VALUES(`SpellFamilyName`),
    `SpellFamilyMask0` = VALUES(`SpellFamilyMask0`),
    `SpellFamilyMask1` = VALUES(`SpellFamilyMask1`),
    `SpellFamilyMask2` = VALUES(`SpellFamilyMask2`),
    `ProcFlags` = VALUES(`ProcFlags`),
    `SpellTypeMask` = VALUES(`SpellTypeMask`),
    `SpellPhaseMask` = VALUES(`SpellPhaseMask`),
    `HitMask` = VALUES(`HitMask`),
    `AttributesMask` = VALUES(`AttributesMask`),
    `DisableEffectsMask` = VALUES(`DisableEffectsMask`),
    `ProcsPerMinute` = VALUES(`ProcsPerMinute`),
    `Chance` = VALUES(`Chance`),
    `Cooldown` = VALUES(`Cooldown`),
    `Charges` = VALUES(`Charges`);

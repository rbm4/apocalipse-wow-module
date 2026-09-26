UPDATE `spell_proc`
SET `ProcFlags` = 0x00000014,
    `SpellTypeMask` = 1,
    `SpellPhaseMask` = 2,
    `HitMask` = 0,
    `Chance` = 100,
    `Cooldown` = 0,
    `Charges` = 0
WHERE `SpellId` = 901048;

UPDATE `spell_dbc`
SET `Description_Lang_enUS` =
        'Every melee hit ruptures the target for a small amount of Physical damage every 2 sec for 15 sec. Fully absorbed hits still apply Rupture.',
    `AuraDescription_Lang_enUS` =
        'Every melee hit applies a stacking Physical bleed, even when fully absorbed.'
WHERE `ID` = 901048
  AND `Name_Lang_enUS` = 'Rupture';

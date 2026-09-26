UPDATE `spell_proc`
SET `SpellTypeMask` = CASE
        WHEN `SpellId` IN (901099, 901100, 901101) THEN 0
        ELSE `SpellTypeMask`
    END,
    `SpellPhaseMask` = 0
WHERE `SpellId` IN (901073, 901099, 901100, 901101, 901102, 901115)
  AND (
      `SpellPhaseMask` <> 0
      OR (`SpellId` IN (901099, 901100, 901101) AND `SpellTypeMask` <> 0)
  );

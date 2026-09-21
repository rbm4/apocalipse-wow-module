#include "Pet.h"
#include "Player.h"
#include "SpellInfo.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"

namespace
{
enum ApocalipseHunterApexBondSpells
{
    SPELL_APOC_HUNTER_APEX_BOND = 901046
};
}

class spell_apoc_hunter_apex_bond : public SpellScriptLoader
{
public:
    spell_apoc_hunter_apex_bond()
        : SpellScriptLoader("spell_apoc_hunter_apex_bond") { }

    class apex_bond_SpellScript : public SpellScript
    {
        PrepareSpellScript(apex_bond_SpellScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Id == SPELL_APOC_HUNTER_APEX_BOND &&
                spellInfo->GetRecoveryTime() == 90000 &&
                spellInfo->GetMaxDuration() == 10000 &&
                spellInfo->SpellFamilyName == SPELLFAMILY_HUNTER &&
                spellInfo->Effects[EFFECT_0].Effect == SPELL_EFFECT_HEAL_PCT &&
                spellInfo->Effects[EFFECT_0].CalcValue() == 15 &&
                spellInfo->Effects[EFFECT_0].TargetA.GetTarget() ==
                    TARGET_UNIT_PET &&
                spellInfo->Effects[EFFECT_1].Effect == SPELL_EFFECT_HEAL_PCT &&
                spellInfo->Effects[EFFECT_1].CalcValue() == 15 &&
                spellInfo->Effects[EFFECT_1].TargetA.GetTarget() ==
                    TARGET_UNIT_CASTER &&
                spellInfo->Effects[EFFECT_2].IsAura(
                    SPELL_AURA_MOD_DAMAGE_PERCENT_DONE) &&
                spellInfo->Effects[EFFECT_2].CalcValue() == 15 &&
                spellInfo->Effects[EFFECT_2].MiscValue ==
                    SPELL_SCHOOL_MASK_ALL &&
                spellInfo->Effects[EFFECT_2].TargetA.GetTarget() ==
                    TARGET_UNIT_PET;
        }

        SpellCastResult CheckCast()
        {
            Player* hunter = GetCaster()->ToPlayer();
            if (!hunter)
                return SPELL_FAILED_NO_VALID_TARGETS;

            Pet* pet = hunter->GetPet();
            if (!pet)
                return SPELL_FAILED_NO_PET;

            if (!pet->IsAlive())
            {
                SetCustomCastResultMessage(SPELL_CUSTOM_ERROR_PET_IS_DEAD);
                return SPELL_FAILED_CUSTOM_ERROR;
            }

            return SPELL_CAST_OK;
        }

        void Register() override
        {
            OnCheckCast += SpellCheckCastFn(apex_bond_SpellScript::CheckCast);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new apex_bond_SpellScript();
    }
};

void AddModApocalipseHunterApexBondScripts()
{
    new spell_apoc_hunter_apex_bond();
}

#include "SpellInfo.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"

namespace
{
enum ApocalipseRogueAlchemicalGuardSpells
{
    SPELL_APOC_ROGUE_ALCHEMICAL_GUARD = 901077
};
}

class spell_apoc_rogue_alchemical_guard : public SpellScriptLoader
{
public:
    spell_apoc_rogue_alchemical_guard()
        : SpellScriptLoader("spell_apoc_rogue_alchemical_guard") { }

    class alchemical_guard_AuraScript : public AuraScript
    {
        PrepareAuraScript(alchemical_guard_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Id == SPELL_APOC_ROGUE_ALCHEMICAL_GUARD &&
                spellInfo->GetRecoveryTime() == 60000 &&
                spellInfo->GetMaxDuration() == 6000 &&
                spellInfo->StartRecoveryCategory == 133 &&
                spellInfo->StartRecoveryTime == 1500 &&
                spellInfo->SpellFamilyName == SPELLFAMILY_ROGUE &&
                spellInfo->PreventionType == SPELL_PREVENTION_TYPE_NONE &&
                spellInfo->HasAttribute(
                    SPELL_ATTR1_ALLOW_WHILE_STEALTHED) &&
                spellInfo->HasAttribute(
                    SPELL_ATTR1_IMMUNITY_PURGES_EFFECT) &&
                spellInfo->HasAttribute(SPELL_ATTR5_ALLOW_WHILE_STUNNED) &&
                spellInfo->HasAttribute(SPELL_ATTR5_ALLOW_WHILE_FLEEING) &&
                spellInfo->HasAttribute(SPELL_ATTR5_ALLOW_WHILE_CONFUSED) &&
                spellInfo->Effects[EFFECT_0].IsAura(
                    SPELL_AURA_MOD_DAMAGE_PERCENT_TAKEN) &&
                spellInfo->Effects[EFFECT_0].CalcValue() == -20 &&
                spellInfo->Effects[EFFECT_0].MiscValue ==
                    SPELL_SCHOOL_MASK_ALL &&
                spellInfo->Effects[EFFECT_0].TargetA.GetTarget() ==
                    TARGET_UNIT_CASTER &&
                spellInfo->Effects[EFFECT_1].IsAura(
                    SPELL_AURA_DISPEL_IMMUNITY) &&
                spellInfo->Effects[EFFECT_1].MiscValue == DISPEL_POISON &&
                spellInfo->Effects[EFFECT_1].TargetA.GetTarget() ==
                    TARGET_UNIT_CASTER &&
                spellInfo->Effects[EFFECT_2].IsAura(
                    SPELL_AURA_DISPEL_IMMUNITY) &&
                spellInfo->Effects[EFFECT_2].MiscValue == DISPEL_DISEASE &&
                spellInfo->Effects[EFFECT_2].TargetA.GetTarget() ==
                    TARGET_UNIT_CASTER;
        }

        void Register() override { }
    };

    AuraScript* GetAuraScript() const override
    {
        return new alchemical_guard_AuraScript();
    }
};

void AddModApocalipseRogueAlchemicalGuardScripts()
{
    new spell_apoc_rogue_alchemical_guard();
}

#include "SpellInfo.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

namespace
{
enum ApocalipseHunterPrimalResolveSpells
{
    SPELL_APOC_HUNTER_PRIMAL_RESOLVE = 901042
};
}

class spell_apoc_hunter_primal_resolve : public SpellScriptLoader
{
public:
    spell_apoc_hunter_primal_resolve()
        : SpellScriptLoader("spell_apoc_hunter_primal_resolve") { }

    class primal_resolve_SpellScript : public SpellScript
    {
        PrepareSpellScript(primal_resolve_SpellScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Id == SPELL_APOC_HUNTER_PRIMAL_RESOLVE &&
                spellInfo->GetRecoveryTime() == 30000 &&
                spellInfo->GetMaxDuration() == 6000 &&
                spellInfo->SpellFamilyName == SPELLFAMILY_HUNTER &&
                spellInfo->Effects[EFFECT_0].IsAura(
                    SPELL_AURA_MOD_DAMAGE_PERCENT_TAKEN) &&
                spellInfo->Effects[EFFECT_0].CalcValue() == -15 &&
                spellInfo->Effects[EFFECT_0].MiscValue ==
                    SPELL_SCHOOL_MASK_ALL &&
                spellInfo->Effects[EFFECT_0].TargetA.GetTarget() ==
                    TARGET_UNIT_CASTER &&
                spellInfo->Effects[EFFECT_1].IsEffect(
                    SPELL_EFFECT_SCRIPT_EFFECT) &&
                spellInfo->Effects[EFFECT_1].TargetA.GetTarget() ==
                    TARGET_UNIT_CASTER;
        }

        void RemoveSnares(SpellEffIndex)
        {
            GetHitUnit()->RemoveMovementImpairingAuras(false);
        }

        void Register() override
        {
            OnEffectHitTarget += SpellEffectFn(
                primal_resolve_SpellScript::RemoveSnares, EFFECT_1,
                SPELL_EFFECT_SCRIPT_EFFECT);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new primal_resolve_SpellScript();
    }
};

void AddModApocalipseHunterPrimalResolveScripts()
{
    new spell_apoc_hunter_primal_resolve();
}

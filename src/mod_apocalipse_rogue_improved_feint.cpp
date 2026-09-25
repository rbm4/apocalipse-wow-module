#include "Player.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"

namespace
{
enum ApocalipseRogueImprovedFeintSpells
{
    SPELL_ROGUE_FEINT_RANK_1 = 1966,
    SPELL_APOC_ROGUE_IMPROVED_FEINT = 901089,
    SPELL_APOC_ROGUE_IMPROVED_FEINT_REDUCTION = 901090
};
}

class spell_apoc_rogue_improved_feint : public SpellScriptLoader
{
public:
    spell_apoc_rogue_improved_feint()
        : SpellScriptLoader("spell_apoc_rogue_improved_feint") { }

    class improved_feint_SpellScript : public SpellScript
    {
        PrepareSpellScript(improved_feint_SpellScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            SpellInfo const* feintInfo = sSpellMgr->GetSpellInfo(
                SPELL_ROGUE_FEINT_RANK_1);
            SpellInfo const* passiveInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_ROGUE_IMPROVED_FEINT);
            SpellInfo const* reductionInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_ROGUE_IMPROVED_FEINT_REDUCTION);
            return feintInfo && spellInfo->IsRankOf(feintInfo) &&
                ValidateSpellInfo({
                    SPELL_APOC_ROGUE_IMPROVED_FEINT,
                    SPELL_APOC_ROGUE_IMPROVED_FEINT_REDUCTION
                }) && passiveInfo && passiveInfo->IsPassive() &&
                passiveInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                reductionInfo && reductionInfo->GetMaxDuration() == 6000 &&
                reductionInfo->Dispel == DISPEL_NONE &&
                reductionInfo->HasAttribute(SPELL_ATTR4_CANNOT_BE_STOLEN) &&
                reductionInfo->Effects[EFFECT_0].IsAura(
                    SPELL_AURA_MOD_DAMAGE_PERCENT_TAKEN) &&
                reductionInfo->Effects[EFFECT_0].CalcValue() == -30 &&
                reductionInfo->Effects[EFFECT_0].MiscValue ==
                    SPELL_SCHOOL_MASK_ALL &&
                reductionInfo->Effects[EFFECT_0].TargetA.GetTarget() ==
                    TARGET_UNIT_CASTER;
        }

        void ApplyReduction()
        {
            Player* rogue = GetCaster()->ToPlayer();
            if (!rogue || rogue->getClass() != CLASS_ROGUE ||
                !rogue->HasAura(SPELL_APOC_ROGUE_IMPROVED_FEINT))
                return;

            rogue->CastSpell(
                rogue, SPELL_APOC_ROGUE_IMPROVED_FEINT_REDUCTION, true);
        }

        void Register() override
        {
            AfterCast += SpellCastFn(
                improved_feint_SpellScript::ApplyReduction);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new improved_feint_SpellScript();
    }
};

void AddModApocalipseRogueImprovedFeintScripts()
{
    new spell_apoc_rogue_improved_feint();
}

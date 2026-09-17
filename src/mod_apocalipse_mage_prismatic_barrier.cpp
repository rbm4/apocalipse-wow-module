#include "SpellInfo.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

enum ApocalipseMagePrismaticBarrierSpells
{
    SPELL_APOC_MAGE_PRISMATIC_BARRIER = 901006,
    SPELL_APOC_MAGE_BLAZING_BARRIER   = 901001,
    SPELL_MAGE_MANA_SHIELD_R9          = 43020,
    SPELL_MAGE_ICE_BARRIER_R8          = 43039
};

namespace
{
constexpr uint32 PRISMATIC_BARRIER_COOLDOWN_MS = 45000;
constexpr uint32 PRISMATIC_BARRIER_MANA_COST_PCT = 42;
}

class spell_apoc_mage_prismatic_barrier : public SpellScriptLoader
{
public:
    spell_apoc_mage_prismatic_barrier()
        : SpellScriptLoader("spell_apoc_mage_prismatic_barrier") { }

    class spell_apoc_mage_prismatic_barrier_SpellScript : public SpellScript
    {
        PrepareSpellScript(spell_apoc_mage_prismatic_barrier_SpellScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return ValidateSpellInfo({
                SPELL_APOC_MAGE_PRISMATIC_BARRIER,
                SPELL_APOC_MAGE_BLAZING_BARRIER,
                SPELL_MAGE_MANA_SHIELD_R9,
                SPELL_MAGE_ICE_BARRIER_R8
            }) &&
                spellInfo->RecoveryTime == PRISMATIC_BARRIER_COOLDOWN_MS &&
                spellInfo->ManaCostPercentage ==
                    PRISMATIC_BARRIER_MANA_COST_PCT &&
                spellInfo->SpellFamilyName == SPELLFAMILY_MAGE &&
                spellInfo->GetSchoolMask() == SPELL_SCHOOL_MASK_ARCANE &&
                spellInfo->Effects[EFFECT_0].IsEffect(
                    SPELL_EFFECT_SCRIPT_EFFECT) &&
                spellInfo->Effects[EFFECT_0].TargetA.GetTarget() ==
                    TARGET_UNIT_CASTER;
        }

        void ActivateBarriers(SpellEffIndex)
        {
            Unit* caster = GetCaster();
            if (!caster)
                return;

            caster->CastSpell(caster, SPELL_MAGE_MANA_SHIELD_R9, true);
            caster->CastSpell(caster, SPELL_MAGE_ICE_BARRIER_R8, true);
            caster->CastSpell(caster, SPELL_APOC_MAGE_BLAZING_BARRIER, true);
        }

        void Register() override
        {
            OnEffectHitTarget += SpellEffectFn(
                spell_apoc_mage_prismatic_barrier_SpellScript::
                    ActivateBarriers,
                EFFECT_0, SPELL_EFFECT_SCRIPT_EFFECT);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new spell_apoc_mage_prismatic_barrier_SpellScript();
    }
};

void AddModApocalipseMagePrismaticBarrierScripts()
{
    new spell_apoc_mage_prismatic_barrier();
}

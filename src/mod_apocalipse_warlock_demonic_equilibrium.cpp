#include "SpellAuraEffects.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

namespace
{
enum ApocalipseWarlockDemonicEquilibriumSpells
{
    SPELL_APOC_WARLOCK_DEMONIC_EQUILIBRIUM = 901033,
    SPELL_WARLOCK_SOUL_LINK_AURA            = 25228
};

constexpr int32 DEMONIC_EQUILIBRIUM_SPLIT_PCT = 50;
}

class spell_apoc_warlock_demonic_equilibrium : public SpellScriptLoader
{
public:
    spell_apoc_warlock_demonic_equilibrium()
        : SpellScriptLoader("spell_apoc_warlock_demonic_equilibrium") { }

    class AuraScriptImpl : public AuraScript
    {
        PrepareAuraScript(AuraScriptImpl);

        bool Validate(SpellInfo const* /*spellInfo*/) override
        {
            return ValidateSpellInfo({
                SPELL_APOC_WARLOCK_DEMONIC_EQUILIBRIUM,
                SPELL_WARLOCK_SOUL_LINK_AURA
            });
        }

        void IncreaseSplit(AuraEffect* /*aurEff*/, DamageInfo& damageInfo,
            uint32& splitAmount)
        {
            Unit* warlock = GetTarget();
            if (warlock && warlock->HasAura(
                SPELL_APOC_WARLOCK_DEMONIC_EQUILIBRIUM))
                splitAmount = CalculatePct(
                    damageInfo.GetDamage(), DEMONIC_EQUILIBRIUM_SPLIT_PCT);
        }

        void Register() override
        {
            OnEffectSplit += AuraEffectSplitFn(
                AuraScriptImpl::IncreaseSplit, EFFECT_0);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new AuraScriptImpl();
    }
};

void AddModApocalipseWarlockDemonicEquilibriumScripts()
{
    new spell_apoc_warlock_demonic_equilibrium();
}

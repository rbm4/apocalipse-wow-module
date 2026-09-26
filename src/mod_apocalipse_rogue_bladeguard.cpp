#include "Player.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"

namespace
{
enum ApocalipseRogueBladeguardSpells
{
    SPELL_APOC_ROGUE_BLADEGUARD = 901073,
    SPELL_APOC_ROGUE_BLADEGUARD_THREAT = 901155
};
}

class spell_apoc_rogue_bladeguard : public SpellScriptLoader
{
public:
    spell_apoc_rogue_bladeguard()
        : SpellScriptLoader("spell_apoc_rogue_bladeguard") { }

    class bladeguard_AuraScript : public AuraScript
    {
        PrepareAuraScript(bladeguard_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            SpellInfo const* threatInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_ROGUE_BLADEGUARD_THREAT);
            return spellInfo->Id == SPELL_APOC_ROGUE_BLADEGUARD &&
                spellInfo->Effects[EFFECT_0].IsAura(
                    SPELL_AURA_MOD_BASE_RESISTANCE_PCT) &&
                ValidateSpellInfo({
                    SPELL_APOC_ROGUE_BLADEGUARD_THREAT
                }) && threatInfo &&
                threatInfo->SpellFamilyName == SPELLFAMILY_ROGUE &&
                threatInfo->Effects[EFFECT_0].IsAura(
                    SPELL_AURA_ADD_PCT_MODIFIER) &&
                threatInfo->Effects[EFFECT_0].MiscValue == SPELLMOD_THREAT &&
                threatInfo->Effects[EFFECT_0].CalcValue() == 75;
        }

        void HandleApply(
            AuraEffect const* aurEff, AuraEffectHandleModes)
        {
            Player* rogue = GetTarget()->ToPlayer();
            if (!rogue || rogue->getClass() != CLASS_ROGUE)
                return;

            rogue->CastSpell(
                rogue, SPELL_APOC_ROGUE_BLADEGUARD_THREAT,
                true, nullptr, aurEff);
        }

        void HandleRemove(AuraEffect const*, AuraEffectHandleModes)
        {
            GetTarget()->RemoveAurasDueToSpell(
                SPELL_APOC_ROGUE_BLADEGUARD_THREAT);
        }

        void Register() override
        {
            AfterEffectApply += AuraEffectApplyFn(
                bladeguard_AuraScript::HandleApply, EFFECT_0,
                SPELL_AURA_MOD_BASE_RESISTANCE_PCT,
                AURA_EFFECT_HANDLE_REAL);
            AfterEffectRemove += AuraEffectRemoveFn(
                bladeguard_AuraScript::HandleRemove, EFFECT_0,
                SPELL_AURA_MOD_BASE_RESISTANCE_PCT,
                AURA_EFFECT_HANDLE_REAL);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new bladeguard_AuraScript();
    }
};

void AddModApocalipseRogueBladeguardScripts()
{
    new spell_apoc_rogue_bladeguard();
}

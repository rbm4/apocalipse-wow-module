#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

enum ApocalipseMageFrozenRetaliationSpells
{
    SPELL_APOC_MAGE_FROZEN_RETALIATION_R1 = 901012,
    SPELL_APOC_MAGE_FROZEN_RETALIATION_R2 = 901013,
    SPELL_MAGE_FINGERS_OF_FROST_AURASTATE  = 44544
};

class spell_apoc_mage_frozen_retaliation : public SpellScriptLoader
{
public:
    spell_apoc_mage_frozen_retaliation()
        : SpellScriptLoader("spell_apoc_mage_frozen_retaliation") { }

    class frozen_retaliation_AuraScript : public AuraScript
    {
        PrepareAuraScript(frozen_retaliation_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return (spellInfo->Id == SPELL_APOC_MAGE_FROZEN_RETALIATION_R1 ||
                spellInfo->Id == SPELL_APOC_MAGE_FROZEN_RETALIATION_R2) &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({ SPELL_MAGE_FINGERS_OF_FROST_AURASTATE });
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            DamageInfo const* damageInfo = eventInfo.GetDamageInfo();
            return GetTarget()->ToPlayer() && damageInfo &&
                damageInfo->GetDamage() > 0;
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo&)
        {
            PreventDefaultAction();
            GetTarget()->CastSpell(
                GetTarget(), SPELL_MAGE_FINGERS_OF_FROST_AURASTATE, true,
                nullptr, aurEff);
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(
                frozen_retaliation_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(
                frozen_retaliation_AuraScript::HandleProc, EFFECT_0,
                SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new frozen_retaliation_AuraScript();
    }
};

void AddModApocalipseMageFrozenRetaliationScripts()
{
    new spell_apoc_mage_frozen_retaliation();
}

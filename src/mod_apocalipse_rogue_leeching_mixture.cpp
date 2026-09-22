#include "GameTime.h"
#include "Player.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

#include <algorithm>

namespace
{
enum ApocalipseRogueLeechingMixtureSpells
{
    SPELL_APOC_ROGUE_LEECHING_MIXTURE = 901075,
    SPELL_APOC_ROGUE_LEECHING_MIXTURE_HEAL = 901076
};

constexpr uint32 LEECHING_MIXTURE_HEAL_PCT = 8;
constexpr uint32 LEECHING_MIXTURE_CAP_PCT = 2;
constexpr uint64 LEECHING_MIXTURE_WINDOW_MS = 1000;
}

class spell_apoc_rogue_leeching_mixture : public SpellScriptLoader
{
public:
    spell_apoc_rogue_leeching_mixture()
        : SpellScriptLoader("spell_apoc_rogue_leeching_mixture") { }

    class leeching_mixture_AuraScript : public AuraScript
    {
        PrepareAuraScript(leeching_mixture_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            SpellInfo const* healInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_ROGUE_LEECHING_MIXTURE_HEAL);
            return spellInfo->Id == SPELL_APOC_ROGUE_LEECHING_MIXTURE &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_APOC_ROGUE_LEECHING_MIXTURE_HEAL
                }) && healInfo &&
                healInfo->Effects[EFFECT_0].Effect == SPELL_EFFECT_HEAL &&
                healInfo->DmgClass == SPELL_DAMAGE_CLASS_NONE &&
                healInfo->HasAttribute(SPELL_ATTR2_CANT_CRIT);
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Unit* rogue = GetTarget();
            DamageInfo const* damageInfo = eventInfo.GetDamageInfo();
            SpellInfo const* damageSpell = eventInfo.GetSpellInfo();
            return rogue && rogue->ToPlayer() &&
                rogue->ToPlayer()->getClass() == CLASS_ROGUE && damageInfo &&
                damageSpell && eventInfo.GetActor() == rogue &&
                damageInfo->GetAttacker() == rogue &&
                damageInfo->GetVictim() &&
                damageInfo->GetVictim() != rogue &&
                damageInfo->GetDamage() > 0 &&
                !(eventInfo.GetHitMask() & PROC_HIT_REFLECT) &&
                damageSpell->SpellFamilyName == SPELLFAMILY_ROGUE &&
                damageSpell->Dispel == DISPEL_POISON;
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();

            Unit* rogue = GetTarget();
            uint64 now = GameTime::GetGameTimeMS().count();
            if (!_windowStartedAtMs ||
                now - _windowStartedAtMs >= LEECHING_MIXTURE_WINDOW_MS)
            {
                _windowStartedAtMs = now;
                _healingGeneratedInWindow = 0;
            }

            uint32 cap = uint32(uint64(rogue->GetMaxHealth()) *
                LEECHING_MIXTURE_CAP_PCT / 100);
            if (_healingGeneratedInWindow >= cap)
                return;

            uint32 heal = uint32(uint64(
                eventInfo.GetDamageInfo()->GetDamage()) *
                LEECHING_MIXTURE_HEAL_PCT / 100);
            heal = std::min(heal, cap - _healingGeneratedInWindow);
            if (!heal)
                return;

            _healingGeneratedInWindow += heal;
            rogue->CastCustomSpell(
                SPELL_APOC_ROGUE_LEECHING_MIXTURE_HEAL,
                SPELLVALUE_BASE_POINT0, int32(heal), rogue, true,
                nullptr, aurEff, rogue->GetGUID());
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(
                leeching_mixture_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(
                leeching_mixture_AuraScript::HandleProc, EFFECT_0,
                SPELL_AURA_DUMMY);
        }

    private:
        uint64 _windowStartedAtMs = 0;
        uint32 _healingGeneratedInWindow = 0;
    };

    AuraScript* GetAuraScript() const override
    {
        return new leeching_mixture_AuraScript();
    }
};

void AddModApocalipseRogueLeechingMixtureScripts()
{
    new spell_apoc_rogue_leeching_mixture();
}

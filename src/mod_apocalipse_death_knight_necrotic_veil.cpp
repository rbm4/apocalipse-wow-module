#include "Define.h"
#include "Player.h"
#include "SpellAuras.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

#include <algorithm>

namespace
{
enum ApocalipseDeathKnightNecroticVeilSpells
{
    SPELL_APOC_DEATH_KNIGHT_NECROTIC_VEIL = 901056,
    SPELL_APOC_DEATH_KNIGHT_NECROTIC_VEIL_ABSORB = 901057
};

constexpr uint32 NECROTIC_VEIL_DAMAGE_PCT = 10;
constexpr uint32 NECROTIC_VEIL_MAX_HEALTH_PCT = 35;
constexpr int32 NECROTIC_VEIL_DURATION_MS = 60000;
}

class spell_apoc_death_knight_necrotic_veil : public SpellScriptLoader
{
public:
    spell_apoc_death_knight_necrotic_veil()
        : SpellScriptLoader("spell_apoc_death_knight_necrotic_veil") { }

    class necrotic_veil_AuraScript : public AuraScript
    {
        PrepareAuraScript(necrotic_veil_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            SpellInfo const* absorbInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_DEATH_KNIGHT_NECROTIC_VEIL_ABSORB);
            return spellInfo->Id == SPELL_APOC_DEATH_KNIGHT_NECROTIC_VEIL &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_APOC_DEATH_KNIGHT_NECROTIC_VEIL_ABSORB
                }) && absorbInfo &&
                absorbInfo->GetMaxDuration() == NECROTIC_VEIL_DURATION_MS &&
                absorbInfo->Effects[EFFECT_0].IsAura(
                    SPELL_AURA_SCHOOL_ABSORB) &&
                absorbInfo->Effects[EFFECT_0].MiscValue ==
                    SPELL_SCHOOL_MASK_MAGIC;
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Unit* deathKnight = GetTarget();
            DamageInfo const* damageInfo = eventInfo.GetDamageInfo();
            return deathKnight && deathKnight->ToPlayer() && damageInfo &&
                eventInfo.GetActor() == deathKnight &&
                damageInfo->GetAttacker() == deathKnight &&
                damageInfo->GetVictim() &&
                damageInfo->GetVictim() != deathKnight &&
                damageInfo->GetDamage() > 0;
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();

            Unit* deathKnight = GetTarget();
            uint32 contribution = uint32(
                uint64(eventInfo.GetDamageInfo()->GetDamage()) *
                NECROTIC_VEIL_DAMAGE_PCT / 100);
            uint32 cap = uint32(
                uint64(deathKnight->GetMaxHealth()) *
                NECROTIC_VEIL_MAX_HEALTH_PCT / 100);
            contribution = std::min(contribution, cap);
            if (!contribution)
                return;

            Aura* veil = deathKnight->GetAura(
                SPELL_APOC_DEATH_KNIGHT_NECROTIC_VEIL_ABSORB,
                deathKnight->GetGUID());
            if (!veil)
            {
                deathKnight->CastCustomSpell(
                    SPELL_APOC_DEATH_KNIGHT_NECROTIC_VEIL_ABSORB,
                    SPELLVALUE_BASE_POINT0, int32(contribution), deathKnight,
                    true, nullptr, aurEff, deathKnight->GetGUID());
                return;
            }

            AuraEffect* absorb = veil->GetEffect(EFFECT_0);
            if (!absorb)
                return;

            uint64 accumulated = uint64(std::max(0, absorb->GetAmount())) +
                contribution;
            absorb->ChangeAmount(int32(std::min<uint64>(accumulated, cap)));
            veil->RefreshDuration();
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(
                necrotic_veil_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(
                necrotic_veil_AuraScript::HandleProc, EFFECT_0,
                SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new necrotic_veil_AuraScript();
    }
};

void AddModApocalipseDeathKnightNecroticVeilScripts()
{
    new spell_apoc_death_knight_necrotic_veil();
}

#include "Player.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

namespace
{
enum ApocalipseRogueShadowExecutionSpells
{
    SPELL_APOC_ROGUE_SHADOW_EXECUTION = 901081,
    SPELL_APOC_ROGUE_SHADOW_EXECUTION_DOT = 901082
};

constexpr uint8 SHADOW_EXECUTION_MAX_STACKS = 50;
constexpr uint32 SHADOW_EXECUTION_WEAPON_DAMAGE_PCT = 1;
}

class spell_apoc_rogue_shadow_execution : public SpellScriptLoader
{
public:
    spell_apoc_rogue_shadow_execution()
        : SpellScriptLoader("spell_apoc_rogue_shadow_execution") { }

    class shadow_execution_AuraScript : public AuraScript
    {
        PrepareAuraScript(shadow_execution_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            SpellInfo const* passiveInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_ROGUE_SHADOW_EXECUTION);
            SpellInfo const* dotInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_ROGUE_SHADOW_EXECUTION_DOT);
            return (spellInfo->Id == SPELL_APOC_ROGUE_SHADOW_EXECUTION ||
                    spellInfo->Id == SPELL_APOC_ROGUE_SHADOW_EXECUTION_DOT) &&
                ValidateSpellInfo({
                    SPELL_APOC_ROGUE_SHADOW_EXECUTION,
                    SPELL_APOC_ROGUE_SHADOW_EXECUTION_DOT
                }) && passiveInfo &&
                passiveInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                dotInfo &&
                dotInfo->StackAmount == SHADOW_EXECUTION_MAX_STACKS &&
                dotInfo->GetDuration() == 10000 &&
                dotInfo->GetSchoolMask() == SPELL_SCHOOL_MASK_SHADOW &&
                dotInfo->SpellFamilyName == SPELLFAMILY_ROGUE &&
                dotInfo->Effects[EFFECT_0].IsAura(
                    SPELL_AURA_PERIODIC_DAMAGE) &&
                dotInfo->Effects[EFFECT_0].Amplitude == 1000 &&
                dotInfo->Effects[EFFECT_0].TargetA.GetTarget() ==
                    TARGET_UNIT_TARGET_ENEMY &&
                dotInfo->HasAttribute(SPELL_ATTR2_CANT_CRIT);
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Player* rogue = GetTarget()->ToPlayer();
            DamageInfo const* damageInfo = eventInfo.GetDamageInfo();
            SpellInfo const* abilityInfo = eventInfo.GetSpellInfo();
            return rogue && rogue->getClass() == CLASS_ROGUE &&
                rogue->GetWeaponForAttack(BASE_ATTACK, true) && damageInfo &&
                abilityInfo && abilityInfo->SpellFamilyName ==
                    SPELLFAMILY_ROGUE &&
                abilityInfo->Id != SPELL_APOC_ROGUE_SHADOW_EXECUTION &&
                abilityInfo->Id != SPELL_APOC_ROGUE_SHADOW_EXECUTION_DOT &&
                eventInfo.GetActor() == rogue &&
                damageInfo->GetAttacker() == rogue &&
                damageInfo->GetVictim() &&
                damageInfo->GetVictim() != rogue &&
                damageInfo->GetVictim()->IsAlive() &&
                damageInfo->GetDamage() > 0 &&
                !(eventInfo.GetHitMask() & PROC_HIT_REFLECT);
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();
            GetTarget()->CastSpell(
                eventInfo.GetDamageInfo()->GetVictim(),
                SPELL_APOC_ROGUE_SHADOW_EXECUTION_DOT, true, nullptr, aurEff,
                GetTarget()->GetGUID());
        }

        void CalculateDotAmount(
            AuraEffect const*, int32& amount, bool& canBeRecalculated)
        {
            Player* rogue = GetCaster() ? GetCaster()->ToPlayer() : nullptr;
            if (!rogue || rogue->getClass() != CLASS_ROGUE ||
                !rogue->GetWeaponForAttack(BASE_ATTACK, true))
            {
                amount = 0;
                canBeRecalculated = true;
                return;
            }

            amount = CalculatePct(
                rogue->CalculateDamage(BASE_ATTACK, false, true),
                SHADOW_EXECUTION_WEAPON_DAMAGE_PCT);
            canBeRecalculated = true;
        }

        void Register() override
        {
            if (m_scriptSpellId == SPELL_APOC_ROGUE_SHADOW_EXECUTION)
            {
                DoCheckProc += AuraCheckProcFn(
                    shadow_execution_AuraScript::CheckProc);
                OnEffectProc += AuraEffectProcFn(
                    shadow_execution_AuraScript::HandleProc, EFFECT_0,
                    SPELL_AURA_DUMMY);
            }
            else if (m_scriptSpellId == SPELL_APOC_ROGUE_SHADOW_EXECUTION_DOT)
            {
                DoEffectCalcAmount += AuraEffectCalcAmountFn(
                    shadow_execution_AuraScript::CalculateDotAmount, EFFECT_0,
                    SPELL_AURA_PERIODIC_DAMAGE);
            }
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new shadow_execution_AuraScript();
    }
};

void AddModApocalipseRogueShadowExecutionScripts()
{
    new spell_apoc_rogue_shadow_execution();
}

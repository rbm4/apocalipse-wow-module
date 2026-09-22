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
enum ApocalipsePaladinPermanentSealSpells
{
    SPELL_PALADIN_SEAL_OF_RIGHTEOUSNESS_DAMAGE = 25742,
    SPELL_PALADIN_HOLY_VENGEANCE = 31803,
    SPELL_PALADIN_SEAL_OF_VENGEANCE_DAMAGE = 42463,
    SPELL_APOC_PERMANENT_SEAL_OF_RIGHTEOUSNESS = 901016,
    SPELL_APOC_PERMANENT_SEAL_OF_VENGEANCE = 901060
};

constexpr uint32 PALADIN_ICON_HAMMER_OF_THE_RIGHTEOUS = 3023;
constexpr uint32 PALADIN_ICON_JUDGEMENTS_OF_THE_JUST = 3015;

bool IsJudgementDamageSpell(SpellInfo const* spellInfo)
{
    return spellInfo &&
        spellInfo->SpellFamilyName == SPELLFAMILY_PALADIN &&
        (spellInfo->SpellFamilyFlags[0] & 0x800000);
}

bool HasJudgementsOfTheJust(Unit const* caster)
{
    return caster && caster->GetAuraEffect(
        SPELL_AURA_ADD_FLAT_MODIFIER, SPELLFAMILY_PALADIN,
        PALADIN_ICON_JUDGEMENTS_OF_THE_JUST, 0) != nullptr;
}
}

class spell_apoc_paladin_permanent_seal_of_righteousness :
    public SpellScriptLoader
{
public:
    spell_apoc_paladin_permanent_seal_of_righteousness()
        : SpellScriptLoader(
            "spell_apoc_paladin_permanent_seal_of_righteousness") { }

    class permanent_seal_of_righteousness_AuraScript : public AuraScript
    {
        PrepareAuraScript(permanent_seal_of_righteousness_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Id ==
                    SPELL_APOC_PERMANENT_SEAL_OF_RIGHTEOUSNESS &&
                spellInfo->GetSpellSpecific() != SPELL_SPECIFIC_SEAL &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_PALADIN_SEAL_OF_RIGHTEOUSNESS_DAMAGE
                });
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Unit* caster = GetTarget();
            Unit* target = eventInfo.GetProcTarget();
            DamageInfo const* damageInfo = eventInfo.GetDamageInfo();
            SpellInfo const* procSpellInfo = eventInfo.GetSpellInfo();
            if (!caster->ToPlayer() || eventInfo.GetActor() != caster ||
                !target || !target->IsAlive() || !damageInfo ||
                (!damageInfo->GetDamage() &&
                    !(eventInfo.GetHitMask() & PROC_HIT_ABSORB)) ||
                (procSpellInfo && procSpellInfo->Id ==
                    SPELL_PALADIN_SEAL_OF_RIGHTEOUSNESS_DAMAGE))
                return false;

            if (IsJudgementDamageSpell(procSpellInfo))
                return true;

            return !eventInfo.GetTriggerAuraSpell() &&
                (eventInfo.GetTypeMask() &
                    (PROC_FLAG_DONE_MELEE_AUTO_ATTACK |
                        PROC_FLAG_DONE_SPELL_MELEE_DMG_CLASS));
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();

            Unit* caster = GetTarget();
            Unit* target = eventInfo.GetProcTarget();
            float attackPower =
                caster->GetTotalAttackPowerValue(BASE_ATTACK);
            int32 holySpellPower =
                caster->SpellBaseDamageBonusDone(SPELL_SCHOOL_MASK_HOLY);
            holySpellPower +=
                target->SpellBaseDamageBonusTaken(SPELL_SCHOOL_MASK_HOLY);

            if (AuraEffect* libramEffect = caster->GetDummyAuraEffect(
                SPELLFAMILY_PALADIN, 2025, EFFECT_0))
                holySpellPower += libramEffect->GetAmount();

            int32 damage = std::max<int32>(0, int32(
                (attackPower * 0.022f + 0.044f * holySpellPower) *
                caster->GetAttackTime(BASE_ATTACK) / 1000));

            caster->CastCustomSpell(
                SPELL_PALADIN_SEAL_OF_RIGHTEOUSNESS_DAMAGE,
                SPELLVALUE_BASE_POINT0, damage, target, true, nullptr, aurEff);

            if (IsJudgementDamageSpell(eventInfo.GetSpellInfo()) &&
                HasJudgementsOfTheJust(caster))
            {
                caster->CastCustomSpell(
                    SPELL_PALADIN_SEAL_OF_RIGHTEOUSNESS_DAMAGE,
                    SPELLVALUE_BASE_POINT0, damage, target, true, nullptr,
                    aurEff);
            }
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(
                permanent_seal_of_righteousness_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(
                permanent_seal_of_righteousness_AuraScript::HandleProc,
                EFFECT_0, SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new permanent_seal_of_righteousness_AuraScript();
    }
};

class spell_apoc_paladin_permanent_seal_of_vengeance :
    public SpellScriptLoader
{
public:
    spell_apoc_paladin_permanent_seal_of_vengeance()
        : SpellScriptLoader(
            "spell_apoc_paladin_permanent_seal_of_vengeance") { }

    class permanent_seal_of_vengeance_AuraScript : public AuraScript
    {
        PrepareAuraScript(permanent_seal_of_vengeance_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Id == SPELL_APOC_PERMANENT_SEAL_OF_VENGEANCE &&
                spellInfo->GetSpellSpecific() != SPELL_SPECIFIC_SEAL &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_PALADIN_HOLY_VENGEANCE,
                    SPELL_PALADIN_SEAL_OF_VENGEANCE_DAMAGE
                });
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Unit* caster = GetTarget();
            Unit* target = eventInfo.GetActionTarget();
            if (!caster->ToPlayer() || eventInfo.GetActor() != caster ||
                !target || !target->IsAlive())
                return false;

            SpellInfo const* procSpell = eventInfo.GetSpellInfo();
            if (procSpell &&
                procSpell->SpellFamilyName == SPELLFAMILY_PALADIN)
            {
                if ((procSpell->SpellFamilyFlags[1] & 0x800) &&
                    !(procSpell->SpellFamilyFlags[0] & 0x800000))
                    return false;

                if (IsJudgementDamageSpell(procSpell))
                    return HasJudgementsOfTheJust(caster);
            }

            return true;
        }

        void HandleSeal(AuraEffect const* aurEff, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();

            Unit* caster = eventInfo.GetActor();
            Unit* target = eventInfo.GetActionTarget();
            AuraEffect const* sealDot = target->GetAuraEffect(
                SPELL_AURA_PERIODIC_DAMAGE, SPELLFAMILY_PALADIN,
                0, 0x00000800, 0, caster->GetGUID());
            if (!sealDot)
                return;

            uint8 stacks = sealDot->GetBase()->GetStackAmount();
            uint8 maxStacks = sealDot->GetSpellInfo()->StackAmount;
            SpellInfo const* damageSpell =
                sSpellMgr->GetSpellInfo(
                    SPELL_PALADIN_SEAL_OF_VENGEANCE_DAMAGE);
            int32 amount = damageSpell->Effects[EFFECT_0].CalcValue();
            amount = (amount * stacks) / maxStacks;
            caster->CastCustomSpell(
                SPELL_PALADIN_SEAL_OF_VENGEANCE_DAMAGE,
                SPELLVALUE_BASE_POINT0, amount, target, true, nullptr, aurEff);
        }

        void HandleApplyDoT(
            AuraEffect const* aurEff, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();

            if (!(eventInfo.GetTypeMask() &
                PROC_FLAG_DONE_MELEE_AUTO_ATTACK))
            {
                SpellInfo const* spellInfo = eventInfo.GetSpellInfo();
                if (!spellInfo || spellInfo->SpellIconID !=
                    PALADIN_ICON_HAMMER_OF_THE_RIGHTEOUS)
                    return;
            }

            eventInfo.GetActor()->CastSpell(
                eventInfo.GetActionTarget(), SPELL_PALADIN_HOLY_VENGEANCE,
                true, nullptr, aurEff);
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(
                permanent_seal_of_vengeance_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(
                permanent_seal_of_vengeance_AuraScript::HandleSeal,
                EFFECT_0, SPELL_AURA_DUMMY);
            OnEffectProc += AuraEffectProcFn(
                permanent_seal_of_vengeance_AuraScript::HandleApplyDoT,
                EFFECT_0, SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new permanent_seal_of_vengeance_AuraScript();
    }
};

void AddModApocalipsePaladinPermanentSealOfRighteousnessScripts()
{
    new spell_apoc_paladin_permanent_seal_of_righteousness();
    new spell_apoc_paladin_permanent_seal_of_vengeance();
}

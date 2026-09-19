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
enum ApocalipsePaladinPermanentSealOfRighteousnessSpells
{
    SPELL_PALADIN_SEAL_OF_RIGHTEOUSNESS_DAMAGE = 25742,
    SPELL_APOC_PERMANENT_SEAL_OF_RIGHTEOUSNESS = 901016,
    SPELL_APOC_PALADIN_DIVINE_TOLL_IMPACT_MARKER = 901025
};

constexpr uint32 PALADIN_FAMILY_FLAG_SEAL_OF_RIGHTEOUSNESS = 0x08000000;
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

bool HasSealOfRighteousness(Unit const* caster)
{
    return caster && caster->GetAuraEffect(
        SPELL_AURA_DUMMY, SPELLFAMILY_PALADIN,
        PALADIN_FAMILY_FLAG_SEAL_OF_RIGHTEOUSNESS, 0, 0) != nullptr;
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
            bool divineTollJudgement =
                IsJudgementDamageSpell(procSpellInfo) &&
                caster->HasAura(
                    SPELL_APOC_PALADIN_DIVINE_TOLL_IMPACT_MARKER);
            if (!caster->ToPlayer() || eventInfo.GetActor() != caster ||
                !target || !target->IsAlive() || !damageInfo ||
                (!damageInfo->GetDamage() &&
                    !(eventInfo.GetHitMask() & PROC_HIT_ABSORB)) ||
                (HasSealOfRighteousness(caster) && !divineTollJudgement) ||
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

void AddModApocalipsePaladinPermanentSealOfRighteousnessScripts()
{
    new spell_apoc_paladin_permanent_seal_of_righteousness();
}

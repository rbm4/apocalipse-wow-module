#include "Player.h"
#include "Random.h"
#include "ScriptMgr.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

#include <algorithm>

enum ApocalipseMageSpells
{
    // Replace this when the final DBC/client spell entry is assigned.
    SPELL_APOC_MAGE_BLAZING_BARRIER              = 901001,

    SPELL_MAGE_BLAZING_SPEED_R1                  = 31641,
    SPELL_MAGE_BLAZING_SPEED_PROC                = 31643,
    SPELL_MAGE_FIERY_PAYBACK_R1                  = 44440,
    SPELL_MAGE_FIERY_PAYBACK_DISARM              = 64346,
    SPELL_MAGE_INCANTERS_ABSORBTION_R1           = 44394,
    SPELL_MAGE_INCANTERS_ABSORBTION_TRIGGERED    = 44413
};

namespace
{
int32 CalculateBarrierAmount(Unit* caster, int32 amount, SpellInfo const* spellInfo, AuraEffect const* aurEff)
{
    float bonus = 0.8068f;
    bonus *= caster->SpellBaseDamageBonusDone(spellInfo->GetSchoolMask());
    bonus = caster->ApplyEffectModifiers(spellInfo, aurEff->GetEffIndex(), bonus);
    bonus *= caster->CalculateLevelPenalty(spellInfo);

    return amount + int32(bonus);
}

void TryExtraBlazingSpeedProc(Player* player)
{
    AuraEffect const* talentAurEff = player->GetAuraEffectOfRankedSpell(SPELL_MAGE_BLAZING_SPEED_R1, EFFECT_0);
    if (!talentAurEff || player->HasAura(SPELL_MAGE_BLAZING_SPEED_PROC))
        return;

    int32 chance = std::max<int32>(1, talentAurEff->GetAmount());
    if (roll_chance_i(chance))
        player->CastSpell(player, SPELL_MAGE_BLAZING_SPEED_PROC, true, nullptr, talentAurEff);
}

void TryFieryPaybackProc(Player* player, DamageInfo const& dmgInfo)
{
    AuraEffect const* talentAurEff = player->GetAuraEffectOfRankedSpell(SPELL_MAGE_FIERY_PAYBACK_R1, EFFECT_0);
    Unit* attacker = dmgInfo.GetAttacker();

    if (!talentAurEff || !attacker || attacker == player)
        return;

    if (dmgInfo.GetDamageType() != DIRECT_DAMAGE && dmgInfo.GetAttackType() != RANGED_ATTACK)
        return;

    int32 chance = std::max<int32>(1, talentAurEff->GetAmount() / 2);
    if (roll_chance_i(chance))
        player->CastSpell(attacker, SPELL_MAGE_FIERY_PAYBACK_DISARM, true, nullptr, talentAurEff);
}
}

class spell_apoc_mage_blazing_barrier : public SpellScriptLoader
{
public:
    spell_apoc_mage_blazing_barrier() : SpellScriptLoader("spell_apoc_mage_blazing_barrier") { }

    class spell_apoc_mage_blazing_barrier_AuraScript : public AuraScript
    {
        PrepareAuraScript(spell_apoc_mage_blazing_barrier_AuraScript);

        bool Validate(SpellInfo const* /*spellInfo*/) override
        {
            return ValidateSpellInfo({ SPELL_MAGE_INCANTERS_ABSORBTION_TRIGGERED, SPELL_MAGE_INCANTERS_ABSORBTION_R1 });
        }

        void CalculateAmount(AuraEffect const* aurEff, int32& amount, bool& canBeRecalculated)
        {
            canBeRecalculated = false;

            if (Unit* caster = GetCaster())
                amount = CalculateBarrierAmount(caster, amount, GetSpellInfo(), aurEff);
        }

        void TriggerIncantersAbsorbtion(AuraEffect* aurEff, DamageInfo& dmgInfo, uint32& absorbAmount)
        {
            Unit* target = GetTarget();
            if (!target)
                return;

            if (absorbAmount > 0 && target->IsPlayer())
            {
                Player* player = target->ToPlayer();
                TryExtraBlazingSpeedProc(player);
                TryFieryPaybackProc(player, dmgInfo);
            }

            AuraEffect* talentAurEff = target->GetAuraEffectOfRankedSpell(SPELL_MAGE_INCANTERS_ABSORBTION_R1, EFFECT_0);
            if (!talentAurEff)
                return;

            int32 bp = CalculatePct(absorbAmount, talentAurEff->GetAmount());
            if (AuraEffect* currentAura = target->GetAuraEffect(SPELL_AURA_MOD_DAMAGE_DONE, SPELLFAMILY_MAGE, 2941, EFFECT_0))
            {
                bp += int32(currentAura->GetAmount() * (currentAura->GetBase()->GetDuration() / float(currentAura->GetBase()->GetMaxDuration())));
                currentAura->ChangeAmount(bp);
                currentAura->GetBase()->RefreshDuration();
            }
            else
                target->CastCustomSpell(target, SPELL_MAGE_INCANTERS_ABSORBTION_TRIGGERED, &bp, nullptr, nullptr, true, nullptr, aurEff);
        }

        void Register() override
        {
            DoEffectCalcAmount += AuraEffectCalcAmountFn(spell_apoc_mage_blazing_barrier_AuraScript::CalculateAmount, EFFECT_0, SPELL_AURA_SCHOOL_ABSORB);
            AfterEffectAbsorb += AuraEffectAbsorbFn(spell_apoc_mage_blazing_barrier_AuraScript::TriggerIncantersAbsorbtion, EFFECT_0);
        }
    };

    class spell_apoc_mage_blazing_barrier_SpellScript : public SpellScript
    {
        PrepareSpellScript(spell_apoc_mage_blazing_barrier_SpellScript);

        SpellCastResult CheckCast()
        {
            Unit* caster = GetCaster();
            if (!caster)
                return SPELL_FAILED_DONT_REPORT;

            if (AuraEffect* aurEff = caster->GetAuraEffect(SPELL_AURA_SCHOOL_ABSORB, SpellFamilyNames(GetSpellInfo()->SpellFamilyName), GetSpellInfo()->SpellIconID, EFFECT_0))
            {
                int32 newAmount = GetSpellInfo()->Effects[EFFECT_0].CalcValue(caster, nullptr, nullptr);
                newAmount = CalculateBarrierAmount(caster, newAmount, GetSpellInfo(), aurEff);

                if (aurEff->GetAmount() > newAmount)
                    return SPELL_FAILED_AURA_BOUNCED;
            }

            return SPELL_CAST_OK;
        }

        void Register() override
        {
            OnCheckCast += SpellCheckCastFn(spell_apoc_mage_blazing_barrier_SpellScript::CheckCast);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new spell_apoc_mage_blazing_barrier_AuraScript();
    }

    SpellScript* GetSpellScript() const override
    {
        return new spell_apoc_mage_blazing_barrier_SpellScript();
    }
};

void AddModApocalipseMageSpellScripts()
{
    new spell_apoc_mage_blazing_barrier();
}

#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

enum ApocalipseMageFrostBombSpells
{
    SPELL_APOC_MAGE_FROST_BOMB           = 901007,
    SPELL_APOC_MAGE_FROST_BOMB_EXPLOSION = 901008,
    SPELL_APOC_MAGE_FROST_BOMB_SLOW      = 901009,
    SPELL_MAGE_PERMAFROST_R1             = 11175,
    SPELL_MAGE_PERMAFROST_AURA           = 68391
};

namespace
{
constexpr int32 FROST_BOMB_DURATION_MS = 4000;
}

class spell_apoc_mage_frost_bomb : public SpellScriptLoader
{
public:
    spell_apoc_mage_frost_bomb()
        : SpellScriptLoader("spell_apoc_mage_frost_bomb") { }

    class spell_apoc_mage_frost_bomb_AuraScript : public AuraScript
    {
        PrepareAuraScript(spell_apoc_mage_frost_bomb_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->GetMaxDuration() == FROST_BOMB_DURATION_MS &&
                uint32(spellInfo->Effects[EFFECT_0].CalcValue()) ==
                    SPELL_APOC_MAGE_FROST_BOMB_EXPLOSION &&
                ValidateSpellInfo({
                    SPELL_APOC_MAGE_FROST_BOMB_EXPLOSION,
                    SPELL_APOC_MAGE_FROST_BOMB_SLOW
                });
        }

        void HandleRemove(AuraEffect const* aurEff,
            AuraEffectHandleModes /*mode*/)
        {
            AuraRemoveMode removeMode = GetTargetApplication()->GetRemoveMode();
            if (removeMode != AURA_REMOVE_BY_EXPIRE &&
                removeMode != AURA_REMOVE_BY_ENEMY_SPELL &&
                removeMode != AURA_REMOVE_BY_DEATH)
                return;

            if (Unit* caster = GetCaster())
                caster->CastSpell(
                    GetTarget(), SPELL_APOC_MAGE_FROST_BOMB_EXPLOSION,
                    TriggerCastFlags(
                        TRIGGERED_FULL_MASK & ~TRIGGERED_DISALLOW_PROC_EVENTS),
                    nullptr, aurEff);
        }

        void Register() override
        {
            AfterEffectRemove += AuraEffectRemoveFn(
                spell_apoc_mage_frost_bomb_AuraScript::HandleRemove,
                EFFECT_0, SPELL_AURA_DUMMY, AURA_EFFECT_HANDLE_REAL);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new spell_apoc_mage_frost_bomb_AuraScript();
    }
};

class spell_apoc_mage_frost_bomb_explosion : public SpellScriptLoader
{
public:
    spell_apoc_mage_frost_bomb_explosion()
        : SpellScriptLoader("spell_apoc_mage_frost_bomb_explosion") { }

    class spell_apoc_mage_frost_bomb_explosion_SpellScript :
        public SpellScript
    {
        PrepareSpellScript(
            spell_apoc_mage_frost_bomb_explosion_SpellScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return ValidateSpellInfo({ SPELL_APOC_MAGE_FROST_BOMB_SLOW }) &&
                spellInfo->GetSchoolMask() == SPELL_SCHOOL_MASK_FROST &&
                spellInfo->SpellFamilyName == SPELLFAMILY_MAGE &&
                spellInfo->Effects[EFFECT_0].IsEffect(
                    SPELL_EFFECT_SCHOOL_DAMAGE) &&
                spellInfo->Effects[EFFECT_0].TargetA.GetTarget() ==
                    TARGET_DEST_TARGET_ENEMY &&
                spellInfo->Effects[EFFECT_0].TargetB.GetTarget() ==
                    TARGET_UNIT_DEST_AREA_ENEMY;
        }

        void ApplySlow(SpellEffIndex /*effIndex*/)
        {
            Unit* caster = GetCaster();
            Unit* target = GetHitUnit();
            if (caster && target && target->IsAlive())
                caster->CastSpell(
                    target, SPELL_APOC_MAGE_FROST_BOMB_SLOW, true);
        }

        void Register() override
        {
            OnEffectHitTarget += SpellEffectFn(
                spell_apoc_mage_frost_bomb_explosion_SpellScript::ApplySlow,
                EFFECT_0, SPELL_EFFECT_SCHOOL_DAMAGE);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new spell_apoc_mage_frost_bomb_explosion_SpellScript();
    }
};

class spell_apoc_mage_frost_bomb_slow : public SpellScriptLoader
{
public:
    spell_apoc_mage_frost_bomb_slow()
        : SpellScriptLoader("spell_apoc_mage_frost_bomb_slow") { }

    class spell_apoc_mage_frost_bomb_slow_AuraScript : public AuraScript
    {
        PrepareAuraScript(spell_apoc_mage_frost_bomb_slow_AuraScript);

        bool Validate(SpellInfo const* /*spellInfo*/) override
        {
            return ValidateSpellInfo({
                SPELL_MAGE_PERMAFROST_R1,
                SPELL_MAGE_PERMAFROST_AURA
            });
        }

        void CalculateSlow(AuraEffect const* /*aurEff*/, int32& amount,
            bool& canBeRecalculated)
        {
            canBeRecalculated = false;
            if (Unit* caster = GetCaster())
                if (AuraEffect const* permafrost =
                    caster->GetAuraEffectOfRankedSpell(
                        SPELL_MAGE_PERMAFROST_R1, EFFECT_1))
                    amount += permafrost->GetAmount();
        }

        void ApplyPermafrost(AuraEffect const* aurEff,
            AuraEffectHandleModes /*mode*/)
        {
            Unit* caster = GetCaster();
            if (!caster)
                return;

            AuraEffect const* permafrostDuration =
                caster->GetAuraEffectOfRankedSpell(
                    SPELL_MAGE_PERMAFROST_R1, EFFECT_0);
            if (!permafrostDuration)
                return;

            int32 duration = GetSpellInfo()->GetMaxDuration() +
                permafrostDuration->GetAmount();
            SetMaxDuration(duration);
            SetDuration(duration);
            caster->CastSpell(
                GetTarget(), SPELL_MAGE_PERMAFROST_AURA, true, nullptr,
                aurEff);
        }

        void RemovePermafrost(AuraEffect const* /*aurEff*/,
            AuraEffectHandleModes /*mode*/)
        {
            GetTarget()->RemoveAurasDueToSpell(
                SPELL_MAGE_PERMAFROST_AURA, GetCasterGUID());
        }

        void Register() override
        {
            DoEffectCalcAmount += AuraEffectCalcAmountFn(
                spell_apoc_mage_frost_bomb_slow_AuraScript::CalculateSlow,
                EFFECT_0, SPELL_AURA_MOD_DECREASE_SPEED);
            AfterEffectApply += AuraEffectApplyFn(
                spell_apoc_mage_frost_bomb_slow_AuraScript::ApplyPermafrost,
                EFFECT_0, SPELL_AURA_MOD_DECREASE_SPEED,
                AURA_EFFECT_HANDLE_REAL_OR_REAPPLY_MASK);
            AfterEffectRemove += AuraEffectRemoveFn(
                spell_apoc_mage_frost_bomb_slow_AuraScript::RemovePermafrost,
                EFFECT_0, SPELL_AURA_MOD_DECREASE_SPEED,
                AURA_EFFECT_HANDLE_REAL);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new spell_apoc_mage_frost_bomb_slow_AuraScript();
    }
};

void AddModApocalipseMageFrostBombScripts()
{
    new spell_apoc_mage_frost_bomb();
    new spell_apoc_mage_frost_bomb_explosion();
    new spell_apoc_mage_frost_bomb_slow();
}

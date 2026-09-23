#include "Player.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

namespace
{
enum ApocalipseDeathKnightCrimsonWardSpells
{
    SPELL_APOC_DEATH_KNIGHT_CRIMSON_WARD = 901050,
    SPELL_APOC_DEATH_KNIGHT_CRIMSON_WARD_ABSORB = 901051
};

constexpr uint32 CRIMSON_WARD_MAX_HEALTH_PCT = 20;
}

class spell_apoc_death_knight_crimson_ward : public SpellScriptLoader
{
public:
    spell_apoc_death_knight_crimson_ward()
        : SpellScriptLoader("spell_apoc_death_knight_crimson_ward") { }

    class crimson_ward_AuraScript : public AuraScript
    {
        PrepareAuraScript(crimson_ward_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Id == SPELL_APOC_DEATH_KNIGHT_CRIMSON_WARD &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_APOC_DEATH_KNIGHT_CRIMSON_WARD_ABSORB
                });
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
                GetTarget(), SPELL_APOC_DEATH_KNIGHT_CRIMSON_WARD_ABSORB,
                true, nullptr, aurEff);
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(
                crimson_ward_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(
                crimson_ward_AuraScript::HandleProc, EFFECT_0,
                SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new crimson_ward_AuraScript();
    }
};

class spell_apoc_death_knight_crimson_ward_absorb :
    public SpellScriptLoader
{
public:
    spell_apoc_death_knight_crimson_ward_absorb()
        : SpellScriptLoader("spell_apoc_death_knight_crimson_ward_absorb") { }

    class crimson_ward_absorb_AuraScript : public AuraScript
    {
        PrepareAuraScript(crimson_ward_absorb_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Id ==
                    SPELL_APOC_DEATH_KNIGHT_CRIMSON_WARD_ABSORB &&
                spellInfo->Effects[EFFECT_0].IsAura(
                    SPELL_AURA_SCHOOL_ABSORB);
        }

        void CalculateAmount(
            AuraEffect const*, int32& amount, bool& canBeRecalculated)
        {
            canBeRecalculated = false;

            if (Unit* target = GetUnitOwner())
                amount = target->CountPctFromMaxHealth(
                    CRIMSON_WARD_MAX_HEALTH_PCT);
        }

        void Register() override
        {
            DoEffectCalcAmount += AuraEffectCalcAmountFn(
                crimson_ward_absorb_AuraScript::CalculateAmount, EFFECT_0,
                SPELL_AURA_SCHOOL_ABSORB);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new crimson_ward_absorb_AuraScript();
    }
};

void AddModApocalipseDeathKnightCrimsonWardScripts()
{
    new spell_apoc_death_knight_crimson_ward();
    new spell_apoc_death_knight_crimson_ward_absorb();
}

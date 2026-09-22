#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

namespace
{
enum ApocalipseDeathKnightFrozenResolveSpells
{
    SPELL_APOC_DEATH_KNIGHT_FROZEN_RESOLVE = 901052,
    SPELL_APOC_DEATH_KNIGHT_FROZEN_RESOLVE_STACK = 901053
};

constexpr int32 FROZEN_RESOLVE_STACK_DURATION_MS = 8000;
constexpr uint32 FROZEN_RESOLVE_PERIOD_MS = 2000;
constexpr uint32 FROZEN_RESOLVE_MAX_STACKS = 10;
constexpr int32 FROZEN_RESOLVE_ARMOR_PCT = 2;
constexpr int32 FROZEN_RESOLVE_DAMAGE_REDUCTION_PCT = -2;
}

class spell_apoc_death_knight_frozen_resolve : public SpellScriptLoader
{
public:
    spell_apoc_death_knight_frozen_resolve()
        : SpellScriptLoader("spell_apoc_death_knight_frozen_resolve") { }

    class frozen_resolve_AuraScript : public AuraScript
    {
        PrepareAuraScript(frozen_resolve_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            SpellInfo const* stackInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_DEATH_KNIGHT_FROZEN_RESOLVE_STACK);
            return spellInfo->Id ==
                    SPELL_APOC_DEATH_KNIGHT_FROZEN_RESOLVE &&
                spellInfo->IsPassive() && spellInfo->GetMaxDuration() == -1 &&
                spellInfo->Effects[EFFECT_0].IsAura(
                    SPELL_AURA_PERIODIC_DUMMY) &&
                spellInfo->Effects[EFFECT_0].Amplitude ==
                    FROZEN_RESOLVE_PERIOD_MS &&
                ValidateSpellInfo({
                    SPELL_APOC_DEATH_KNIGHT_FROZEN_RESOLVE_STACK
                }) && stackInfo &&
                stackInfo->GetMaxDuration() ==
                    FROZEN_RESOLVE_STACK_DURATION_MS &&
                stackInfo->StackAmount == FROZEN_RESOLVE_MAX_STACKS &&
                !stackInfo->IsPassive() &&
                stackInfo->Dispel == DISPEL_NONE &&
                stackInfo->HasAttribute(SPELL_ATTR4_CANNOT_BE_STOLEN) &&
                stackInfo->HasAttribute(
                    SPELL_ATTR0_CU_AURA_CANNOT_BE_SAVED) &&
                stackInfo->Effects[EFFECT_0].IsAura(
                    SPELL_AURA_MOD_RESISTANCE_PCT) &&
                stackInfo->Effects[EFFECT_0].CalcValue() ==
                    FROZEN_RESOLVE_ARMOR_PCT &&
                stackInfo->Effects[EFFECT_0].MiscValue ==
                    SPELL_SCHOOL_MASK_NORMAL &&
                stackInfo->Effects[EFFECT_1].IsAura(
                    SPELL_AURA_MOD_DAMAGE_PERCENT_TAKEN) &&
                stackInfo->Effects[EFFECT_1].CalcValue() ==
                    FROZEN_RESOLVE_DAMAGE_REDUCTION_PCT &&
                stackInfo->Effects[EFFECT_1].MiscValue ==
                    SPELL_SCHOOL_MASK_ALL;
        }

        void HandlePeriodic(AuraEffect const* aurEff)
        {
            Unit* deathKnight = GetTarget();
            if (!deathKnight || !deathKnight->IsInCombat())
                return;

            deathKnight->CastSpell(
                deathKnight,
                SPELL_APOC_DEATH_KNIGHT_FROZEN_RESOLVE_STACK,
                true, nullptr, aurEff);
        }

        void Register() override
        {
            OnEffectPeriodic += AuraEffectPeriodicFn(
                frozen_resolve_AuraScript::HandlePeriodic, EFFECT_0,
                SPELL_AURA_PERIODIC_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new frozen_resolve_AuraScript();
    }
};

void AddModApocalipseDeathKnightFrozenResolveScripts()
{
    new spell_apoc_death_knight_frozen_resolve();
}

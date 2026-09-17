#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

#include <algorithm>

enum ApocalipseMageMissileBarrageOverloadSpells
{
    SPELL_APOC_MAGE_MISSILE_BARRAGE_OVERLOAD = 901004,
    SPELL_MAGE_ARCANE_MISSILES_R1             = 5143,
    SPELL_MAGE_MISSILE_BARRAGE_PROC           = 44401,
    SPELL_ARCANE_EXPLOSION_VISUAL              = 35426
};

namespace
{
constexpr uint8 MAX_MISSILE_BARRAGE_PROCS = 20;
constexpr uint32 ARCANE_MISSILES_FAMILY_FLAG = 0x00000800;
constexpr int32 MISSILE_BARRAGE_DURATION_MODIFIER_MS = -2500;
constexpr int32 MISSILE_BARRAGE_MANA_COST_PCT = -100;
constexpr int32 EXTRA_MISSILE_DURATION_MS = 500;
}

class spell_apoc_mage_missile_barrage_overload_proc :
    public SpellScriptLoader
{
public:
    spell_apoc_mage_missile_barrage_overload_proc()
        : SpellScriptLoader(
            "spell_apoc_mage_missile_barrage_overload_proc") { }

    class overload_proc_AuraScript : public AuraScript
    {
        PrepareAuraScript(overload_proc_AuraScript);

        bool Load() override
        {
            _procCount = 0;
            return true;
        }

        bool Validate(SpellInfo const* spellInfo) override
        {
            return ValidateSpellInfo({
                SPELL_APOC_MAGE_MISSILE_BARRAGE_OVERLOAD,
                SPELL_MAGE_ARCANE_MISSILES_R1,
                SPELL_ARCANE_EXPLOSION_VISUAL
            }) &&
                spellInfo->Effects[EFFECT_0].IsAura(
                    SPELL_AURA_ADD_FLAT_MODIFIER) &&
                spellInfo->Effects[EFFECT_0].MiscValue == SPELLMOD_DURATION &&
                spellInfo->Effects[EFFECT_1].IsAura(
                    SPELL_AURA_ADD_FLAT_MODIFIER) &&
                spellInfo->Effects[EFFECT_1].MiscValue ==
                    SPELLMOD_ACTIVATION_TIME &&
                spellInfo->Effects[EFFECT_2].IsAura(
                    SPELL_AURA_ADD_PCT_MODIFIER) &&
                spellInfo->Effects[EFFECT_2].MiscValue == SPELLMOD_COST &&
                spellInfo->Effects[EFFECT_0].CalcValue() ==
                    MISSILE_BARRAGE_DURATION_MODIFIER_MS &&
                spellInfo->Effects[EFFECT_1].CalcValue() ==
                    -EXTRA_MISSILE_DURATION_MS &&
                spellInfo->Effects[EFFECT_2].CalcValue() ==
                    MISSILE_BARRAGE_MANA_COST_PCT;
        }

        void HandleApply(AuraEffect const*, AuraEffectHandleModes mode)
        {
            Unit* target = GetTarget();
            AuraEffect const* passive = target->GetAuraEffect(
                SPELL_APOC_MAGE_MISSILE_BARRAGE_OVERLOAD, EFFECT_0);
            if (!passive)
                return;

            int32 configuredMax = std::max<int32>(1, passive->GetAmount());
            uint8 maxProcCount = uint8(std::min<int32>(
                MAX_MISSILE_BARRAGE_PROCS, configuredMax));

            if (mode & AURA_EFFECT_HANDLE_REAL)
            {
                uint8 loadedCount = std::max<uint8>(uint8(1), GetCharges());
                _procCount = std::min<uint8>(loadedCount, maxProcCount);
            }
            else if (mode & AURA_EFFECT_HANDLE_REAPPLY)
            {
                uint8 nextCount = uint8(
                    std::max<uint8>(uint8(1), _procCount) + 1);
                _procCount = std::min<uint8>(nextCount, maxProcCount);
            }

            SetCharges(_procCount);

            int32 durationModifier = MISSILE_BARRAGE_DURATION_MODIFIER_MS +
                int32(_procCount - 1) * EXTRA_MISSILE_DURATION_MS;
            GetEffect(EFFECT_0)->ChangeAmount(durationModifier);
        }

        void PrepareProc(ProcEventInfo& eventInfo)
        {
            SpellInfo const* spellInfo = eventInfo.GetSpellInfo();
            if (!spellInfo || spellInfo->SpellFamilyName != SPELLFAMILY_MAGE ||
                !(spellInfo->SpellFamilyFlags[0] & ARCANE_MISSILES_FAMILY_FLAG))
                return;

            if (_procCount > 1)
                if (Unit* target = eventInfo.GetActionTarget())
                    target->CastSpell(
                        target, SPELL_ARCANE_EXPLOSION_VISUAL, true);

            SetCharges(1);
        }

        void Register() override
        {
            AfterEffectApply += AuraEffectApplyFn(
                overload_proc_AuraScript::HandleApply, EFFECT_0,
                SPELL_AURA_ADD_FLAT_MODIFIER,
                AURA_EFFECT_HANDLE_REAL_OR_REAPPLY_MASK);
            DoPrepareProc += AuraProcFn(overload_proc_AuraScript::PrepareProc);
        }

    private:
        uint8 _procCount;
    };

    AuraScript* GetAuraScript() const override
    {
        return new overload_proc_AuraScript();
    }
};

class spell_apoc_mage_missile_barrage_overload_passive :
    public SpellScriptLoader
{
public:
    spell_apoc_mage_missile_barrage_overload_passive()
        : SpellScriptLoader(
            "spell_apoc_mage_missile_barrage_overload_passive") { }

    class overload_passive_AuraScript : public AuraScript
    {
        PrepareAuraScript(overload_passive_AuraScript);

        bool Validate(SpellInfo const*) override
        {
            return ValidateSpellInfo({ SPELL_MAGE_MISSILE_BARRAGE_PROC });
        }

        void HandleRemove(AuraEffect const*, AuraEffectHandleModes)
        {
            GetTarget()->RemoveAurasDueToSpell(SPELL_MAGE_MISSILE_BARRAGE_PROC);
        }

        void Register() override
        {
            AfterEffectRemove += AuraEffectRemoveFn(
                overload_passive_AuraScript::HandleRemove, EFFECT_0,
                SPELL_AURA_DUMMY, AURA_EFFECT_HANDLE_REAL);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new overload_passive_AuraScript();
    }
};

void AddModApocalipseMageMissileBarrageOverloadScripts()
{
    new spell_apoc_mage_missile_barrage_overload_proc();
    new spell_apoc_mage_missile_barrage_overload_passive();
}

#include "GameTime.h"
#include "Spell.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

#include <deque>

enum ApocalipseMageAutomaticIceLanceSpells
{
    SPELL_APOC_MAGE_AUTOMATIC_ICE_LANCE = 901010,
    SPELL_APOC_MAGE_ICE_LANCE_HASTE     = 901011,
    SPELL_MAGE_ICE_LANCE                 = 30455
};

namespace
{
constexpr uint8 MAX_HASTE_CONTRIBUTIONS = 20;
constexpr int32 HASTE_CONTRIBUTION_PCT = 1;
constexpr int32 HASTE_DURATION_MS = 10000;
constexpr int32 HASTE_UPDATE_PERIOD_MS = 1000;
}

class spell_apoc_mage_automatic_ice_lance : public SpellScriptLoader
{
public:
    spell_apoc_mage_automatic_ice_lance()
        : SpellScriptLoader("spell_apoc_mage_automatic_ice_lance") { }

    class automatic_ice_lance_AuraScript : public AuraScript
    {
        PrepareAuraScript(automatic_ice_lance_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_APOC_MAGE_ICE_LANCE_HASTE,
                    SPELL_MAGE_ICE_LANCE
                });
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Unit* caster = GetTarget();
            SpellInfo const* procSpellInfo = eventInfo.GetSpellInfo();
            DamageInfo const* damageInfo = eventInfo.GetDamageInfo();
            if (!caster || !caster->ToPlayer() ||
                eventInfo.GetActor() != caster || !procSpellInfo || !damageInfo)
                return false;

            if (procSpellInfo->Id == SPELL_MAGE_ICE_LANCE ||
                procSpellInfo->SpellFamilyName != SPELLFAMILY_MAGE ||
                !(procSpellInfo->GetSchoolMask() & SPELL_SCHOOL_MASK_FROST))
                return false;

            Unit* target = eventInfo.GetProcTarget();
            if (!target)
                target = eventInfo.GetActionTarget();

            SpellInfo const* iceLanceInfo =
                sSpellMgr->GetSpellInfo(SPELL_MAGE_ICE_LANCE);
            return target && target->IsAlive() && caster->IsInMap(target) &&
                caster->IsWithinLOSInMap(target) &&
                caster->IsValidAttackTarget(target, iceLanceInfo) &&
                iceLanceInfo->CheckExplicitTarget(caster, target) ==
                    SPELL_CAST_OK &&
                iceLanceInfo->CheckTarget(caster, target, false) ==
                    SPELL_CAST_OK;
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();

            Unit* caster = GetTarget();
            Unit* target = eventInfo.GetProcTarget();
            if (!target)
                target = eventInfo.GetActionTarget();

            if (caster->CastSpell(
                target, SPELL_MAGE_ICE_LANCE,
                TriggerCastFlags(
                    TRIGGERED_FULL_MASK & ~TRIGGERED_DISALLOW_PROC_EVENTS),
                nullptr, aurEff, caster->GetGUID()) != SPELL_CAST_OK)
                return;

            caster->CastSpell(
                caster, SPELL_APOC_MAGE_ICE_LANCE_HASTE,
                TRIGGERED_FULL_MASK, nullptr, aurEff, caster->GetGUID());
        }

        void HandleRemove(AuraEffect const*, AuraEffectHandleModes)
        {
            GetTarget()->RemoveAurasDueToSpell(
                SPELL_APOC_MAGE_ICE_LANCE_HASTE, GetCasterGUID());
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(
                automatic_ice_lance_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(
                automatic_ice_lance_AuraScript::HandleProc, EFFECT_0,
                SPELL_AURA_DUMMY);
            AfterEffectRemove += AuraEffectRemoveFn(
                automatic_ice_lance_AuraScript::HandleRemove, EFFECT_0,
                SPELL_AURA_DUMMY, AURA_EFFECT_HANDLE_REAL);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new automatic_ice_lance_AuraScript();
    }
};

class spell_apoc_mage_ice_lance_haste : public SpellScriptLoader
{
public:
    spell_apoc_mage_ice_lance_haste()
        : SpellScriptLoader("spell_apoc_mage_ice_lance_haste") { }

    class ice_lance_haste_AuraScript : public AuraScript
    {
        PrepareAuraScript(ice_lance_haste_AuraScript);

        using ExpirationTime = uint64;

        bool Load() override
        {
            _expirationTimes.clear();
            return true;
        }

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Effects[EFFECT_0].IsAura(
                    SPELL_AURA_HASTE_SPELLS) &&
                spellInfo->Effects[EFFECT_1].IsAura(
                    SPELL_AURA_PERIODIC_DUMMY);
        }

        void RemoveExpired(ExpirationTime now)
        {
            while (!_expirationTimes.empty() &&
                _expirationTimes.front() <= now)
                _expirationTimes.pop_front();
        }

        void UpdateHaste(ExpirationTime now)
        {
            RemoveExpired(now);
            if (_expirationTimes.empty())
            {
                GetAura()->Remove(AURA_REMOVE_BY_EXPIRE);
                return;
            }

            GetEffect(EFFECT_0)->ChangeAmount(
                int32(_expirationTimes.size()) * HASTE_CONTRIBUTION_PCT);
            int32 remaining =
                int32(_expirationTimes.back() - now);
            SetMaxDuration(HASTE_DURATION_MS);
            SetDuration(remaining);
        }

        void HandleApply(AuraEffect const*, AuraEffectHandleModes)
        {
            ExpirationTime now = GameTime::GetGameTimeMS().count();
            RemoveExpired(now);
            if (_expirationTimes.size() < MAX_HASTE_CONTRIBUTIONS)
                _expirationTimes.push_back(now + HASTE_DURATION_MS);
            UpdateHaste(now);
        }

        void HandlePeriodic(AuraEffect const*)
        {
            UpdateHaste(GameTime::GetGameTimeMS().count());
        }

        void Register() override
        {
            AfterEffectApply += AuraEffectApplyFn(
                ice_lance_haste_AuraScript::HandleApply, EFFECT_0,
                SPELL_AURA_HASTE_SPELLS,
                AURA_EFFECT_HANDLE_REAL_OR_REAPPLY_MASK);
            OnEffectPeriodic += AuraEffectPeriodicFn(
                ice_lance_haste_AuraScript::HandlePeriodic, EFFECT_1,
                SPELL_AURA_PERIODIC_DUMMY);
        }

    private:
        std::deque<ExpirationTime> _expirationTimes;
    };

    AuraScript* GetAuraScript() const override
    {
        return new ice_lance_haste_AuraScript();
    }
};

void AddModApocalipseMageAutomaticIceLanceScripts()
{
    new spell_apoc_mage_automatic_ice_lance();
    new spell_apoc_mage_ice_lance_haste();
}

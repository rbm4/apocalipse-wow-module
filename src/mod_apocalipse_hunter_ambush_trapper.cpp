#include "Player.h"
#include "Spell.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

#include <algorithm>

namespace
{
enum ApocalipseHunterAmbushTrapperSpells
{
    SPELL_APOC_HUNTER_AMBUSH_TRAPPER   = 901038,
    SPELL_APOC_HUNTER_PREDATORS_AMBUSH = 901039,
    SPELL_APOC_HUNTER_AMBUSH_STRIKE    = 901040,
    SPELL_APOC_HUNTER_AMBUSH_MANA      = 901041
};

constexpr uint32 AMBUSH_DAMAGE_PCT = 2;
}

class spell_apoc_hunter_ambush_trapper : public SpellScriptLoader
{
public:
    spell_apoc_hunter_ambush_trapper()
        : SpellScriptLoader("spell_apoc_hunter_ambush_trapper") { }

    class ambush_trapper_AuraScript : public AuraScript
    {
        PrepareAuraScript(ambush_trapper_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            SpellInfo const* ambushInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_HUNTER_PREDATORS_AMBUSH);
            return spellInfo->Id == SPELL_APOC_HUNTER_AMBUSH_TRAPPER &&
                spellInfo->Effects[EFFECT_0].IsAura(
                    SPELL_AURA_PROC_TRIGGER_SPELL) &&
                spellInfo->Effects[EFFECT_0].TriggerSpell ==
                    SPELL_APOC_HUNTER_PREDATORS_AMBUSH &&
                ValidateSpellInfo({ SPELL_APOC_HUNTER_PREDATORS_AMBUSH }) &&
                ambushInfo && ambushInfo->GetMaxDuration() == 15000 &&
                ambushInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY);
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Unit* hunter = GetTarget();
            SpellInfo const* trapInfo = eventInfo.GetSpellInfo();
            Spell const* trapSpell = eventInfo.GetProcSpell();
            return hunter && hunter->ToPlayer() &&
                eventInfo.GetActor() == hunter &&
                (eventInfo.GetTypeMask() &
                    PROC_FLAG_DONE_TRAP_ACTIVATION) &&
                trapInfo &&
                trapInfo->SpellFamilyName == SPELLFAMILY_HUNTER &&
                trapSpell && trapSpell->GetOriginalTarget();
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo&)
        {
            PreventDefaultAction();
            GetTarget()->CastSpell(
                GetTarget(), SPELL_APOC_HUNTER_PREDATORS_AMBUSH, true,
                nullptr, aurEff);
        }

        void HandleRemove(AuraEffect const*, AuraEffectHandleModes)
        {
            GetTarget()->RemoveAurasDueToSpell(
                SPELL_APOC_HUNTER_PREDATORS_AMBUSH);
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(
                ambush_trapper_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(
                ambush_trapper_AuraScript::HandleProc, EFFECT_0,
                SPELL_AURA_PROC_TRIGGER_SPELL);
            AfterEffectRemove += AuraEffectRemoveFn(
                ambush_trapper_AuraScript::HandleRemove, EFFECT_0,
                SPELL_AURA_PROC_TRIGGER_SPELL, AURA_EFFECT_HANDLE_REAL);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new ambush_trapper_AuraScript();
    }
};

class spell_apoc_hunter_predators_ambush : public SpellScriptLoader
{
public:
    spell_apoc_hunter_predators_ambush()
        : SpellScriptLoader("spell_apoc_hunter_predators_ambush") { }

    class predators_ambush_AuraScript : public AuraScript
    {
        PrepareAuraScript(predators_ambush_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            SpellInfo const* strikeInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_HUNTER_AMBUSH_STRIKE);
            SpellInfo const* manaInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_HUNTER_AMBUSH_MANA);
            return spellInfo->Id == SPELL_APOC_HUNTER_PREDATORS_AMBUSH &&
                spellInfo->GetMaxDuration() == 15000 &&
                spellInfo->ProcCharges == 5 &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_APOC_HUNTER_AMBUSH_STRIKE,
                    SPELL_APOC_HUNTER_AMBUSH_MANA
                }) && strikeInfo && manaInfo &&
                strikeInfo->Effects[EFFECT_0].Effect ==
                    SPELL_EFFECT_SCHOOL_DAMAGE &&
                manaInfo->Effects[EFFECT_0].Effect ==
                    SPELL_EFFECT_ENERGIZE_PCT &&
                manaInfo->Effects[EFFECT_0].MiscValue == POWER_MANA;
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Unit* hunter = GetTarget();
            Unit* target = eventInfo.GetActionTarget();
            SpellInfo const* procSpellInfo = eventInfo.GetSpellInfo();
            DamageInfo const* damageInfo = eventInfo.GetDamageInfo();
            return hunter && hunter->ToPlayer() &&
                eventInfo.GetActor() == hunter && target &&
                target->IsAlive() && damageInfo && procSpellInfo &&
                procSpellInfo->SpellFamilyName == SPELLFAMILY_HUNTER &&
                procSpellInfo->DmgClass == SPELL_DAMAGE_CLASS_MELEE &&
                (eventInfo.GetTypeMask() &
                    PROC_FLAG_DONE_SPELL_MELEE_DMG_CLASS) &&
                (damageInfo->GetDamage() > 0 ||
                    (eventInfo.GetHitMask() & PROC_HIT_ABSORB));
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();

            Unit* hunter = GetTarget();
            Unit* target = eventInfo.GetActionTarget();
            uint32 cappedHealth = std::min(
                target->GetMaxHealth(), hunter->GetMaxHealth());
            int32 damage = int32(
                uint64(cappedHealth) * AMBUSH_DAMAGE_PCT / 100);

            hunter->CastCustomSpell(
                SPELL_APOC_HUNTER_AMBUSH_STRIKE,
                SPELLVALUE_BASE_POINT0, damage, target, true, nullptr, aurEff);
            hunter->CastSpell(
                hunter, SPELL_APOC_HUNTER_AMBUSH_MANA, true, nullptr, aurEff);
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(
                predators_ambush_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(
                predators_ambush_AuraScript::HandleProc, EFFECT_0,
                SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new predators_ambush_AuraScript();
    }
};

void AddModApocalipseHunterAmbushTrapperScripts()
{
    new spell_apoc_hunter_ambush_trapper();
    new spell_apoc_hunter_predators_ambush();
}

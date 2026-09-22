#include "Player.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

namespace
{
enum ApocalipseDeathKnightRuptureSpells
{
    SPELL_APOC_DEATH_KNIGHT_RUPTURE = 901048,
    SPELL_APOC_DEATH_KNIGHT_RUPTURE_BLEED = 901049,
    SPELL_DEATH_KNIGHT_BLOOD_STRIKE_R1 = 45902,
    SPELL_DEATH_KNIGHT_DEATH_STRIKE_R1 = 49998,
    SPELL_DEATH_KNIGHT_HEART_STRIKE_R1 = 55050
};

bool IsRuptureStrike(SpellInfo const* spellInfo)
{
    if (!spellInfo || spellInfo->SpellFamilyName != SPELLFAMILY_DEATHKNIGHT)
        return false;

    uint32 firstRank = sSpellMgr->GetFirstSpellInChain(spellInfo->Id);
    return firstRank == SPELL_DEATH_KNIGHT_BLOOD_STRIKE_R1 ||
        firstRank == SPELL_DEATH_KNIGHT_DEATH_STRIKE_R1 ||
        firstRank == SPELL_DEATH_KNIGHT_HEART_STRIKE_R1;
}
}

class spell_apoc_death_knight_rupture : public SpellScriptLoader
{
public:
    spell_apoc_death_knight_rupture()
        : SpellScriptLoader("spell_apoc_death_knight_rupture") { }

    class rupture_AuraScript : public AuraScript
    {
        PrepareAuraScript(rupture_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            SpellInfo const* bleedInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_DEATH_KNIGHT_RUPTURE_BLEED);
            return spellInfo->Id == SPELL_APOC_DEATH_KNIGHT_RUPTURE &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_APOC_DEATH_KNIGHT_RUPTURE_BLEED,
                    SPELL_DEATH_KNIGHT_BLOOD_STRIKE_R1,
                    SPELL_DEATH_KNIGHT_DEATH_STRIKE_R1,
                    SPELL_DEATH_KNIGHT_HEART_STRIKE_R1
                }) && bleedInfo && bleedInfo->StackAmount == 200 &&
                bleedInfo->Effects[EFFECT_0].IsAura(
                    SPELL_AURA_PERIODIC_DAMAGE) &&
                (bleedInfo->GetEffectMechanicMask(EFFECT_0) &
                    (1ULL << MECHANIC_BLEED));
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Unit* deathKnight = GetTarget();
            Unit* target = eventInfo.GetProcTarget();
            if (!deathKnight || !deathKnight->ToPlayer() ||
                eventInfo.GetActor() != deathKnight || !target ||
                !target->IsAlive() || target == deathKnight ||
                !(eventInfo.GetHitMask() &
                    (PROC_HIT_NORMAL | PROC_HIT_CRITICAL)))
                return false;

            if (eventInfo.GetTypeMask() & PROC_FLAG_DONE_MELEE_AUTO_ATTACK)
                return eventInfo.GetSpellInfo() == nullptr;

            return (eventInfo.GetTypeMask() &
                    PROC_FLAG_DONE_SPELL_MELEE_DMG_CLASS) &&
                IsRuptureStrike(eventInfo.GetSpellInfo());
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();
            GetTarget()->CastSpell(
                eventInfo.GetProcTarget(),
                SPELL_APOC_DEATH_KNIGHT_RUPTURE_BLEED, true, nullptr, aurEff);
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(rupture_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(
                rupture_AuraScript::HandleProc, EFFECT_0,
                SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new rupture_AuraScript();
    }
};

void AddModApocalipseDeathKnightRuptureScripts()
{
    new spell_apoc_death_knight_rupture();
}

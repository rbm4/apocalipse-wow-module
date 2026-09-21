#include "Player.h"
#include "Spell.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

namespace
{
enum ApocalipseHunterBloodOfTheHuntSpells
{
    SPELL_APOC_HUNTER_BLOOD_OF_THE_HUNT = 901044,
    SPELL_APOC_HUNTER_BLOOD_HEAL        = 901045
};

constexpr uint32 MELEE_HEAL_PCT = 15;
constexpr uint32 TRAP_HEAL_PCT = 5;
constexpr uint32 HUNTER_MELEE_MASK_0 = 0x00000042;
constexpr uint32 HUNTER_MELEE_MASK_1 = 0x00080000;
constexpr uint32 HUNTER_MELEE_MASK_2 = 0x00010000;
}

class spell_apoc_hunter_blood_of_the_hunt : public SpellScriptLoader
{
public:
    spell_apoc_hunter_blood_of_the_hunt()
        : SpellScriptLoader("spell_apoc_hunter_blood_of_the_hunt") { }

    class blood_of_the_hunt_AuraScript : public AuraScript
    {
        PrepareAuraScript(blood_of_the_hunt_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            SpellInfo const* healInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_HUNTER_BLOOD_HEAL);
            return spellInfo->Id == SPELL_APOC_HUNTER_BLOOD_OF_THE_HUNT &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({ SPELL_APOC_HUNTER_BLOOD_HEAL }) &&
                healInfo &&
                healInfo->Effects[EFFECT_0].Effect == SPELL_EFFECT_HEAL;
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Unit* hunter = GetTarget();
            SpellInfo const* procSpellInfo = eventInfo.GetSpellInfo();
            if (!hunter || !hunter->ToPlayer() ||
                eventInfo.GetActor() != hunter || !procSpellInfo ||
                procSpellInfo->SpellFamilyName != SPELLFAMILY_HUNTER)
                return false;

            if (eventInfo.GetTypeMask() & PROC_FLAG_DONE_TRAP_ACTIVATION)
            {
                Spell const* trapSpell = eventInfo.GetProcSpell();
                return trapSpell && trapSpell->GetOriginalTarget();
            }

            DamageInfo const* damageInfo = eventInfo.GetDamageInfo();
            return (eventInfo.GetTypeMask() &
                    PROC_FLAG_DONE_SPELL_MELEE_DMG_CLASS) &&
                procSpellInfo->DmgClass == SPELL_DAMAGE_CLASS_MELEE &&
                procSpellInfo->SpellFamilyFlags.HasFlag(
                    HUNTER_MELEE_MASK_0, HUNTER_MELEE_MASK_1,
                    HUNTER_MELEE_MASK_2) &&
                damageInfo && damageInfo->GetDamage() > 0;
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();

            Unit* hunter = GetTarget();
            uint32 heal = eventInfo.GetTypeMask() &
                PROC_FLAG_DONE_TRAP_ACTIVATION
                ? uint32(uint64(hunter->GetMaxHealth()) * TRAP_HEAL_PCT / 100)
                : uint32(uint64(eventInfo.GetDamageInfo()->GetDamage()) *
                    MELEE_HEAL_PCT / 100);

            hunter->CastCustomSpell(
                SPELL_APOC_HUNTER_BLOOD_HEAL,
                SPELLVALUE_BASE_POINT0, int32(heal), hunter, true,
                nullptr, aurEff);
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(
                blood_of_the_hunt_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(
                blood_of_the_hunt_AuraScript::HandleProc, EFFECT_0,
                SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new blood_of_the_hunt_AuraScript();
    }
};

void AddModApocalipseHunterBloodOfTheHuntScripts()
{
    new spell_apoc_hunter_blood_of_the_hunt();
}

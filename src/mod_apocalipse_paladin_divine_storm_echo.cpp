#include "ObjectAccessor.h"
#include "Player.h"
#include "Spell.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"

namespace
{
enum ApocalipsePaladinDivineStormEchoSpells
{
    SPELL_PALADIN_DIVINE_STORM             = 53385,
    SPELL_PALADIN_DIVINE_STORM_DUMMY       = 54171,
    SPELL_PALADIN_DIVINE_STORM_HEAL        = 54172,
    SPELL_APOC_DIVINE_STORM_ECHO_PASSIVE   = 901014,
    SPELL_APOC_DIVINE_STORM_ECHO           = 901015
};

constexpr uint32 DIVINE_STORM_TARGET_COUNT = 12;
constexpr int32 DIVINE_STORM_ECHO_WEAPON_DAMAGE_PCT = 55;
constexpr int32 DIVINE_STORM_HEAL_PCT = 25;
}

class spell_apoc_paladin_divine_storm_echo : public SpellScriptLoader
{
public:
    spell_apoc_paladin_divine_storm_echo()
        : SpellScriptLoader("spell_apoc_paladin_divine_storm_echo") { }

    class divine_storm_echo_SpellScript : public SpellScript
    {
        PrepareSpellScript(divine_storm_echo_SpellScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            if (spellInfo->Id != SPELL_PALADIN_DIVINE_STORM ||
                !ValidateSpellInfo({
                    SPELL_PALADIN_DIVINE_STORM_DUMMY,
                    SPELL_PALADIN_DIVINE_STORM_HEAL,
                    SPELL_APOC_DIVINE_STORM_ECHO_PASSIVE,
                    SPELL_APOC_DIVINE_STORM_ECHO
                }))
                return false;

            SpellInfo const* passive =
                sSpellMgr->GetSpellInfo(SPELL_APOC_DIVINE_STORM_ECHO_PASSIVE);
            SpellInfo const* echo =
                sSpellMgr->GetSpellInfo(SPELL_APOC_DIVINE_STORM_ECHO);

            return passive->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                passive->Effects[EFFECT_0].TargetA.GetTarget() ==
                    TARGET_UNIT_CASTER &&
                echo->SpellFamilyName == SPELLFAMILY_PALADIN &&
                echo->GetSchoolMask() == spellInfo->GetSchoolMask() &&
                echo->MaxAffectedTargets == DIVINE_STORM_TARGET_COUNT &&
                echo->ManaCost == 0 &&
                echo->ManaCostPercentage == 0 &&
                echo->RecoveryTime == 0 &&
                echo->StartRecoveryTime == 0 &&
                echo->EquippedItemClass < 0 &&
                echo->Effects[EFFECT_0].IsEffect(
                    SPELL_EFFECT_NORMALIZED_WEAPON_DMG) &&
                echo->Effects[EFFECT_0].CalcValue() == 0 &&
                echo->Effects[EFFECT_0].TargetA.GetTarget() ==
                    TARGET_SRC_CASTER &&
                echo->Effects[EFFECT_0].TargetB.GetTarget() ==
                    TARGET_UNIT_SRC_AREA_ENEMY &&
                echo->Effects[EFFECT_1].IsEffect(SPELL_EFFECT_DUMMY) &&
                echo->Effects[EFFECT_1].CalcValue() ==
                    DIVINE_STORM_HEAL_PCT &&
                echo->Effects[EFFECT_2].IsEffect(
                    SPELL_EFFECT_WEAPON_PERCENT_DAMAGE) &&
                echo->Effects[EFFECT_2].CalcValue() ==
                    DIVINE_STORM_ECHO_WEAPON_DAMAGE_PCT &&
                echo->Effects[EFFECT_2].TargetA.GetTarget() ==
                    TARGET_SRC_CASTER &&
                echo->Effects[EFFECT_2].TargetB.GetTarget() ==
                    TARGET_UNIT_SRC_AREA_ENEMY;
        }

        void ScheduleEcho()
        {
            Player* caster = GetCaster()->ToPlayer();
            if (!caster ||
                !caster->HasAura(SPELL_APOC_DIVINE_STORM_ECHO_PASSIVE))
                return;

            ObjectGuid casterGuid = caster->GetGUID();
            caster->m_Events.AddEventAtOffset([casterGuid]()
            {
                Player* caster = ObjectAccessor::FindPlayer(casterGuid);
                if (!caster || !caster->IsInWorld() || !caster->IsAlive() ||
                    !caster->HasAura(SPELL_APOC_DIVINE_STORM_ECHO_PASSIVE))
                    return;

                caster->CastSpell(
                    caster, SPELL_APOC_DIVINE_STORM_ECHO,
                    TriggerCastFlags(
                        TRIGGERED_FULL_MASK &
                            ~TRIGGERED_DISALLOW_PROC_EVENTS));
            }, 1s);
        }

        void Register() override
        {
            AfterCast += SpellCastFn(
                divine_storm_echo_SpellScript::ScheduleEcho);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new divine_storm_echo_SpellScript();
    }
};

void AddModApocalipsePaladinDivineStormEchoScripts()
{
    new spell_apoc_paladin_divine_storm_echo();
}

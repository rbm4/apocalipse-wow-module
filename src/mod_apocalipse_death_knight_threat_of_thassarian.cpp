#include "Player.h"
#include "Spell.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"
#include "Util.h"

namespace
{
enum ApocalipseDeathKnightThreatOfThassarianSpells
{
    SPELL_DEATH_KNIGHT_THREAT_OF_THASSARIAN_R1 = 65661,
    SPELL_DEATH_KNIGHT_THREAT_OF_THASSARIAN_R2 = 66191,
    SPELL_DEATH_KNIGHT_THREAT_OF_THASSARIAN_R3 = 66192,
    SPELL_DEATH_KNIGHT_HEART_STRIKE_R1 = 55050,
    SPELL_DEATH_KNIGHT_SCOURGE_STRIKE_R1 = 55090,
    SPELL_DEATH_KNIGHT_DEATH_STRIKE_HEAL = 45470,
    SPELL_APOC_DEATH_KNIGHT_SCOURGE_STRIKE_OFF_HAND = 901156,
    SPELL_APOC_DEATH_KNIGHT_HEART_STRIKE_OFF_HAND = 901157
};

enum ApocalipseDeathKnightThreatOfThassarianIcons
{
    ICON_DEATH_KNIGHT_THREAT_OF_THASSARIAN = 2023
};

bool HasUsableOffhandWeapon(Unit const* unit)
{
    Player const* player = unit ? unit->ToPlayer() : nullptr;
    return player && player->HasOffhandWeaponForAttack();
}
}

class spell_apoc_death_knight_threat_of_thassarian : public SpellScriptLoader
{
public:
    spell_apoc_death_knight_threat_of_thassarian()
        : SpellScriptLoader(
            "spell_apoc_death_knight_threat_of_thassarian") { }

    class threat_of_thassarian_AuraScript : public AuraScript
    {
        PrepareAuraScript(threat_of_thassarian_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->SpellFamilyName == SPELLFAMILY_DEATHKNIGHT &&
                spellInfo->SpellIconID ==
                    ICON_DEATH_KNIGHT_THREAT_OF_THASSARIAN &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_DEATH_KNIGHT_THREAT_OF_THASSARIAN_R1,
                    SPELL_DEATH_KNIGHT_THREAT_OF_THASSARIAN_R2,
                    SPELL_DEATH_KNIGHT_THREAT_OF_THASSARIAN_R3,
                    SPELL_DEATH_KNIGHT_HEART_STRIKE_R1,
                    SPELL_DEATH_KNIGHT_SCOURGE_STRIKE_R1,
                    SPELL_APOC_DEATH_KNIGHT_SCOURGE_STRIKE_OFF_HAND,
                    SPELL_APOC_DEATH_KNIGHT_HEART_STRIKE_OFF_HAND
                });
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();

            SpellInfo const* sourceInfo = eventInfo.GetSpellInfo();
            Spell const* procSpell = eventInfo.GetProcSpell();
            Unit* caster = eventInfo.GetActor();
            Unit* target = eventInfo.GetActionTarget();
            if (!sourceInfo || !procSpell || !caster || !target ||
                sourceInfo->SpellFamilyName != SPELLFAMILY_DEATHKNIGHT ||
                !HasUsableOffhandWeapon(caster))
                return;

            uint32 firstRank = sSpellMgr->GetFirstSpellInChain(sourceInfo->Id);
            uint32 helperId = 0;
            if (firstRank == SPELL_DEATH_KNIGHT_HEART_STRIKE_R1)
            {
                if (procSpell->m_targets.GetUnitTarget() != target)
                    return;

                helperId = SPELL_APOC_DEATH_KNIGHT_HEART_STRIKE_OFF_HAND;
            }
            else if (firstRank == SPELL_DEATH_KNIGHT_SCOURGE_STRIKE_R1)
                helperId = SPELL_APOC_DEATH_KNIGHT_SCOURGE_STRIKE_OFF_HAND;
            else
                return;

            if (!roll_chance_i(aurEff->GetAmount()))
                return;

            int32 effect0 = procSpell->CalculateSpellDamage(EFFECT_0, target);
            int32 effect1 = procSpell->CalculateSpellDamage(EFFECT_1, target);
            int32 effect2 = procSpell->CalculateSpellDamage(EFFECT_2, target);
            caster->CastCustomSpell(target, helperId, &effect0, &effect1,
                &effect2, true, nullptr, aurEff);
        }

        void Register() override
        {
            OnEffectProc += AuraEffectProcFn(
                threat_of_thassarian_AuraScript::HandleProc, EFFECT_0,
                SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new threat_of_thassarian_AuraScript();
    }
};

class spell_apoc_death_knight_death_strike_heal : public SpellScriptLoader
{
public:
    spell_apoc_death_knight_death_strike_heal()
        : SpellScriptLoader(
            "spell_apoc_death_knight_death_strike_heal") { }

    class death_strike_heal_SpellScript : public SpellScript
    {
        PrepareSpellScript(death_strike_heal_SpellScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Id == SPELL_DEATH_KNIGHT_DEATH_STRIKE_HEAL &&
                spellInfo->Effects[EFFECT_0].Effect == SPELL_EFFECT_HEAL &&
                ValidateSpellInfo({
                    SPELL_DEATH_KNIGHT_THREAT_OF_THASSARIAN_R1,
                    SPELL_DEATH_KNIGHT_THREAT_OF_THASSARIAN_R2,
                    SPELL_DEATH_KNIGHT_THREAT_OF_THASSARIAN_R3
                });
        }

        void ReduceHeal(SpellEffIndex)
        {
            Unit* caster = GetCaster();
            if (HasUsableOffhandWeapon(caster) &&
                caster->GetDummyAuraEffect(SPELLFAMILY_DEATHKNIGHT,
                    ICON_DEATH_KNIGHT_THREAT_OF_THASSARIAN, EFFECT_0))
                SetHitHeal(GetHitHeal() / 2);
        }

        void Register() override
        {
            OnEffectHitTarget += SpellEffectFn(
                death_strike_heal_SpellScript::ReduceHeal, EFFECT_0,
                SPELL_EFFECT_HEAL);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new death_strike_heal_SpellScript();
    }
};

void AddModApocalipseDeathKnightThreatOfThassarianScripts()
{
    new spell_apoc_death_knight_threat_of_thassarian();
    new spell_apoc_death_knight_death_strike_heal();
}

#include "Player.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "ThreatManager.h"
#include "Unit.h"

namespace
{
enum ApocalipseRogueDaringChallengeSpells
{
    SPELL_APOC_ROGUE_DARING_CHALLENGE = 901070,
    SPELL_APOC_ROGUE_DARING_CHALLENGE_THREAT = 901071
};

constexpr float DARING_CHALLENGE_THREAT_LEAD = 1.0f;
constexpr float DARING_CHALLENGE_BONUS_THREAT = 0.5f;
}

class spell_apoc_rogue_daring_challenge : public SpellScriptLoader
{
public:
    spell_apoc_rogue_daring_challenge()
        : SpellScriptLoader("spell_apoc_rogue_daring_challenge") { }

    class daring_challenge_SpellScript : public SpellScript
    {
        PrepareSpellScript(daring_challenge_SpellScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Effects[EFFECT_0].Effect ==
                    SPELL_EFFECT_ATTACK_ME &&
                spellInfo->Effects[EFFECT_1].IsAura(
                    SPELL_AURA_MOD_TAUNT) &&
                ValidateSpellInfo({
                    SPELL_APOC_ROGUE_DARING_CHALLENGE_THREAT
                });
        }

        void HandleAfterHit()
        {
            Player* rogue = GetCaster()->ToPlayer();
            Unit* target = GetHitUnit();
            if (!rogue || rogue->getClass() != CLASS_ROGUE || !target ||
                !target->CanHaveThreatList() ||
                !target->HasAura(
                    SPELL_APOC_ROGUE_DARING_CHALLENGE,
                    rogue->GetGUID()))
                return;

            target->GetThreatMgr().AddThreat(
                rogue, DARING_CHALLENGE_THREAT_LEAD, nullptr, true, true);
            target->CastSpell(
                rogue, SPELL_APOC_ROGUE_DARING_CHALLENGE_THREAT, true);
        }

        void Register() override
        {
            AfterHit += SpellHitFn(
                daring_challenge_SpellScript::HandleAfterHit);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new daring_challenge_SpellScript();
    }
};

class spell_apoc_rogue_daring_challenge_threat : public SpellScriptLoader
{
public:
    spell_apoc_rogue_daring_challenge_threat()
        : SpellScriptLoader(
            "spell_apoc_rogue_daring_challenge_threat") { }

    class daring_challenge_threat_AuraScript : public AuraScript
    {
        PrepareAuraScript(daring_challenge_threat_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Effects[EFFECT_0].IsAura(
                SPELL_AURA_DUMMY);
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Player* rogue = GetTarget()->ToPlayer();
            Unit* challenged = GetCaster();
            DamageInfo const* damageInfo = eventInfo.GetDamageInfo();
            return rogue && rogue->getClass() == CLASS_ROGUE &&
                challenged && challenged->CanHaveThreatList() &&
                eventInfo.GetActor() == rogue && damageInfo &&
                damageInfo->GetAttacker() == rogue &&
                damageInfo->GetVictim() == challenged &&
                damageInfo->GetDamage() > 0;
        }

        void HandleProc(
            AuraEffect const* /*aurEff*/, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();

            Unit* challenged = GetCaster();
            Unit* rogue = GetTarget();
            float bonusThreat = float(
                eventInfo.GetDamageInfo()->GetDamage()) *
                DARING_CHALLENGE_BONUS_THREAT;
            challenged->GetThreatMgr().AddThreat(
                rogue, bonusThreat, eventInfo.GetSpellInfo());
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(
                daring_challenge_threat_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(
                daring_challenge_threat_AuraScript::HandleProc,
                EFFECT_0, SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new daring_challenge_threat_AuraScript();
    }
};

void AddModApocalipseRogueDaringChallengeScripts()
{
    new spell_apoc_rogue_daring_challenge();
    new spell_apoc_rogue_daring_challenge_threat();
}

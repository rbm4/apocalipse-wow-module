#include "Player.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

namespace
{
enum ApocalipseRogueGloombladeInfusionSpells
{
    SPELL_APOC_ROGUE_GLOOMBLADE_INFUSION = 901079,
    SPELL_APOC_ROGUE_GLOOMBLADE_INFUSION_DAMAGE = 901080
};

constexpr uint32 GLOOMBLADE_INFUSION_DAMAGE_PCT = 10;
}

class spell_apoc_rogue_gloomblade_infusion : public SpellScriptLoader
{
public:
    spell_apoc_rogue_gloomblade_infusion()
        : SpellScriptLoader("spell_apoc_rogue_gloomblade_infusion") { }

    class gloomblade_infusion_AuraScript : public AuraScript
    {
        PrepareAuraScript(gloomblade_infusion_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            SpellInfo const* damageInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_ROGUE_GLOOMBLADE_INFUSION_DAMAGE);
            return spellInfo->Id == SPELL_APOC_ROGUE_GLOOMBLADE_INFUSION &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_APOC_ROGUE_GLOOMBLADE_INFUSION_DAMAGE
                }) && damageInfo &&
                damageInfo->GetSchoolMask() == SPELL_SCHOOL_MASK_SHADOW &&
                damageInfo->SpellFamilyName == SPELLFAMILY_GENERIC &&
                damageInfo->Effects[EFFECT_0].IsEffect(
                    SPELL_EFFECT_SCHOOL_DAMAGE) &&
                damageInfo->HasAttribute(SPELL_ATTR2_CANT_CRIT);
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Unit* rogue = GetTarget();
            DamageInfo const* damageInfo = eventInfo.GetDamageInfo();
            SpellInfo const* damageSpell = eventInfo.GetSpellInfo();
            return rogue && rogue->ToPlayer() &&
                rogue->ToPlayer()->getClass() == CLASS_ROGUE && damageInfo &&
                eventInfo.GetActor() == rogue &&
                damageInfo->GetAttacker() == rogue &&
                damageInfo->GetVictim() &&
                damageInfo->GetVictim() != rogue &&
                damageInfo->GetVictim()->IsAlive() &&
                damageInfo->GetDamage() > 0 &&
                !(eventInfo.GetHitMask() & PROC_HIT_REFLECT) &&
                (!damageSpell || damageSpell->Id !=
                    SPELL_APOC_ROGUE_GLOOMBLADE_INFUSION_DAMAGE);
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();

            uint32 damage = CalculatePct(
                eventInfo.GetDamageInfo()->GetDamage(),
                GLOOMBLADE_INFUSION_DAMAGE_PCT);
            if (!damage)
                return;

            GetTarget()->CastCustomSpell(
                SPELL_APOC_ROGUE_GLOOMBLADE_INFUSION_DAMAGE,
                SPELLVALUE_BASE_POINT0, int32(damage),
                eventInfo.GetDamageInfo()->GetVictim(), true, nullptr, aurEff,
                GetTarget()->GetGUID());
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(
                gloomblade_infusion_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(
                gloomblade_infusion_AuraScript::HandleProc, EFFECT_0,
                SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new gloomblade_infusion_AuraScript();
    }
};

void AddModApocalipseRogueGloombladeInfusionScripts()
{
    new spell_apoc_rogue_gloomblade_infusion();
}

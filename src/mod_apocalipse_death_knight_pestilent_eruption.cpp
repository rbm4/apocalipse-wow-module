#include "Player.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

namespace
{
enum ApocalipseDeathKnightPestilentEruptionSpells
{
    SPELL_APOC_DEATH_KNIGHT_PESTILENT_ERUPTION = 901058,
    SPELL_APOC_DEATH_KNIGHT_PESTILENT_ERUPTION_PESTILENCE = 901059,
    SPELL_DEATH_KNIGHT_DEATH_COIL_R1 = 47541,
    SPELL_DEATH_KNIGHT_PESTILENCE = 50842,
    SPELL_DEATH_KNIGHT_SCOURGE_STRIKE_R1 = 55090
};

bool IsPestilentEruptionSource(SpellInfo const* spellInfo)
{
    if (!spellInfo || spellInfo->SpellFamilyName != SPELLFAMILY_DEATHKNIGHT)
        return false;

    uint32 firstRank = sSpellMgr->GetFirstSpellInChain(spellInfo->Id);
    return firstRank == SPELL_DEATH_KNIGHT_DEATH_COIL_R1 ||
        firstRank == SPELL_DEATH_KNIGHT_SCOURGE_STRIKE_R1;
}
}

class spell_apoc_death_knight_pestilent_eruption : public SpellScriptLoader
{
public:
    spell_apoc_death_knight_pestilent_eruption()
        : SpellScriptLoader(
            "spell_apoc_death_knight_pestilent_eruption") { }

    class pestilent_eruption_SpellScript : public SpellScript
    {
        PrepareSpellScript(pestilent_eruption_SpellScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return IsPestilentEruptionSource(spellInfo) &&
                ValidateSpellInfo({
                    SPELL_APOC_DEATH_KNIGHT_PESTILENT_ERUPTION,
                    SPELL_APOC_DEATH_KNIGHT_PESTILENT_ERUPTION_PESTILENCE,
                    SPELL_DEATH_KNIGHT_DEATH_COIL_R1,
                    SPELL_DEATH_KNIGHT_PESTILENCE,
                    SPELL_DEATH_KNIGHT_SCOURGE_STRIKE_R1
                });
        }

        void TriggerPestilence()
        {
            Unit* deathKnight = GetCaster();
            Unit* target = GetHitUnit();
            if (!deathKnight || !deathKnight->ToPlayer() || !target ||
                !target->IsAlive() || target == deathKnight ||
                !deathKnight->IsValidAttackTarget(target))
                return;

            AuraEffect const* passive = deathKnight->GetAuraEffect(
                SPELL_APOC_DEATH_KNIGHT_PESTILENT_ERUPTION, EFFECT_0);
            if (!passive)
                return;

            deathKnight->CastSpell(
                target,
                SPELL_APOC_DEATH_KNIGHT_PESTILENT_ERUPTION_PESTILENCE,
                true, nullptr, passive);
        }

        void Register() override
        {
            AfterHit += SpellHitFn(
                pestilent_eruption_SpellScript::TriggerPestilence);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new pestilent_eruption_SpellScript();
    }
};

void AddModApocalipseDeathKnightPestilentEruptionScripts()
{
    new spell_apoc_death_knight_pestilent_eruption();
}

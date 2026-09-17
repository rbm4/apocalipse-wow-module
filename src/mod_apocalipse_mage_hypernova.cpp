#include "Player.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

enum ApocalipseMageHypernovaSpells
{
    SPELL_APOC_MAGE_HYPERNOVA       = 901005,
    SPELL_MAGE_ARCANE_BLAST_STACK   = 36032,
    SPELL_ARCANE_EXPLOSION_VISUAL   = 35426
};

namespace
{
constexpr uint8 ARCANE_BLAST_MAX_STACKS = 4;
constexpr uint32 ARCANE_EXPLOSION_FAMILY_FLAG = 0x00001000;
constexpr uint32 HYPERNOVA_COOLDOWN_MS = 45000;
constexpr uint32 HYPERNOVA_MANA_COST_PCT = 22;
}

class spell_apoc_mage_hypernova : public SpellScriptLoader
{
public:
    spell_apoc_mage_hypernova()
        : SpellScriptLoader("spell_apoc_mage_hypernova") { }

    class spell_apoc_mage_hypernova_SpellScript : public SpellScript
    {
        PrepareSpellScript(spell_apoc_mage_hypernova_SpellScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            if (!ValidateSpellInfo({
                SPELL_MAGE_ARCANE_BLAST_STACK,
                SPELL_ARCANE_EXPLOSION_VISUAL
            }))
                return false;

            SpellInfo const* stackSpell =
                sSpellMgr->GetSpellInfo(SPELL_MAGE_ARCANE_BLAST_STACK);

            return stackSpell->StackAmount == ARCANE_BLAST_MAX_STACKS &&
                spellInfo->Speed == 0.0f &&
                spellInfo->RecoveryTime == HYPERNOVA_COOLDOWN_MS &&
                spellInfo->ManaCostPercentage == HYPERNOVA_MANA_COST_PCT &&
                spellInfo->SpellFamilyName == SPELLFAMILY_MAGE &&
                spellInfo->SpellFamilyFlags[0] ==
                    ARCANE_EXPLOSION_FAMILY_FLAG &&
                spellInfo->GetSchoolMask() == SPELL_SCHOOL_MASK_ARCANE &&
                spellInfo->Effects[EFFECT_0].IsEffect(
                    SPELL_EFFECT_SCHOOL_DAMAGE) &&
                spellInfo->Effects[EFFECT_1].IsEffect(
                    SPELL_EFFECT_KNOCK_BACK_DEST) &&
                spellInfo->Effects[EFFECT_0].TargetA.GetTarget() ==
                    TARGET_DEST_TARGET_ENEMY &&
                spellInfo->Effects[EFFECT_0].TargetB.GetTarget() ==
                    TARGET_UNIT_DEST_AREA_ENEMY &&
                spellInfo->Effects[EFFECT_1].TargetA.GetTarget() ==
                    TARGET_DEST_TARGET_ENEMY &&
                spellInfo->Effects[EFFECT_1].TargetB.GetTarget() ==
                    TARGET_UNIT_DEST_AREA_ENEMY;
        }

        void ShowExplosion()
        {
            if (Unit* target = GetExplTargetUnit())
                target->CastSpell(target, SPELL_ARCANE_EXPLOSION_VISUAL, true);
        }

        void ScheduleArcaneBlastStacks()
        {
            Player* caster = GetCaster()->ToPlayer();
            if (!caster)
                return;

            caster->m_Events.AddEventAtOffset([caster]()
            {
                caster->CastCustomSpell(
                    SPELL_MAGE_ARCANE_BLAST_STACK,
                    SPELLVALUE_AURA_STACK, ARCANE_BLAST_MAX_STACKS,
                    caster, true);
            }, Milliseconds(1));
        }

        void Register() override
        {
            OnCast += SpellCastFn(
                spell_apoc_mage_hypernova_SpellScript::ShowExplosion);
            AfterCast += SpellCastFn(
                spell_apoc_mage_hypernova_SpellScript::
                    ScheduleArcaneBlastStacks);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new spell_apoc_mage_hypernova_SpellScript();
    }
};

void AddModApocalipseMageHypernovaScripts()
{
    new spell_apoc_mage_hypernova();
}

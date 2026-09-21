#include "Player.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

enum ApocalipseWarlockHauntingAfflictionSpells
{
    SPELL_APOC_WARLOCK_HAUNTING_AFFLICTION = 901028,
    SPELL_APOC_WARLOCK_HAUNTING_AFFLICTION_ICD = 901029,
    SPELL_WARLOCK_CURSE_OF_AGONY_R1 = 980,
    SPELL_WARLOCK_CORRUPTION_R1 = 172,
    SPELL_WARLOCK_SEED_OF_CORRUPTION_R1 = 27243,
    SPELL_WARLOCK_UNSTABLE_AFFLICTION_R1 = 30108
};

class spell_apoc_warlock_haunting_affliction : public SpellScriptLoader
{
public:
    spell_apoc_warlock_haunting_affliction()
        : SpellScriptLoader("spell_apoc_warlock_haunting_affliction") { }

    class haunting_affliction_SpellScript : public SpellScript
    {
        PrepareSpellScript(haunting_affliction_SpellScript);

        bool Validate(SpellInfo const* /*spellInfo*/) override
        {
            return ValidateSpellInfo({
                SPELL_APOC_WARLOCK_HAUNTING_AFFLICTION,
                SPELL_APOC_WARLOCK_HAUNTING_AFFLICTION_ICD,
                SPELL_WARLOCK_CURSE_OF_AGONY_R1,
                SPELL_WARLOCK_CORRUPTION_R1,
                SPELL_WARLOCK_SEED_OF_CORRUPTION_R1,
                SPELL_WARLOCK_UNSTABLE_AFFLICTION_R1
            });
        }

        static uint32 GetHighestKnownRank(
            Player const* player, uint32 firstRank)
        {
            uint32 highestKnownRank = 0;
            for (uint32 spellId = sSpellMgr->GetFirstSpellInChain(firstRank);
                spellId; spellId = sSpellMgr->GetNextSpellInChain(spellId))
                if (player->HasSpell(spellId))
                    highestKnownRank = spellId;

            return highestKnownRank;
        }

        static bool HasDifferentCurse(Unit const* target, ObjectGuid casterGuid)
        {
            for (auto const& appliedAura : target->GetAppliedAuras())
            {
                Aura const* aura = appliedAura.second->GetBase();
                SpellInfo const* auraInfo = aura->GetSpellInfo();
                if (aura->GetCasterGUID() != casterGuid ||
                    auraInfo->SpellFamilyName != SPELLFAMILY_WARLOCK ||
                    auraInfo->Dispel != DISPEL_CURSE)
                    continue;

                if (sSpellMgr->GetFirstSpellInChain(auraInfo->Id) !=
                    SPELL_WARLOCK_CURSE_OF_AGONY_R1)
                    return true;
            }

            return false;
        }

        void HandleAfterHit()
        {
            Unit* casterUnit = GetCaster();
            Player* caster = casterUnit ? casterUnit->ToPlayer() : nullptr;
            Unit* target = GetHitUnit();
            if (!caster || !target || target == caster ||
                !caster->HasAura(SPELL_APOC_WARLOCK_HAUNTING_AFFLICTION) ||
                caster->HasAura(
                    SPELL_APOC_WARLOCK_HAUNTING_AFFLICTION_ICD))
                return;

            if (caster->CastSpell(
                caster, SPELL_APOC_WARLOCK_HAUNTING_AFFLICTION_ICD, true) !=
                SPELL_CAST_OK || !caster->HasAura(
                    SPELL_APOC_WARLOCK_HAUNTING_AFFLICTION_ICD))
                return;

            if (!HasDifferentCurse(target, caster->GetGUID()))
                if (uint32 spellId = GetHighestKnownRank(
                    caster, SPELL_WARLOCK_CURSE_OF_AGONY_R1))
                    caster->CastSpell(target, spellId, true);

            if (!target->GetAuraOfRankedSpell(
                SPELL_WARLOCK_SEED_OF_CORRUPTION_R1, caster->GetGUID()))
                if (uint32 spellId = GetHighestKnownRank(
                    caster, SPELL_WARLOCK_CORRUPTION_R1))
                    caster->CastSpell(target, spellId, true);

            if (uint32 spellId = GetHighestKnownRank(
                caster, SPELL_WARLOCK_UNSTABLE_AFFLICTION_R1))
                caster->CastSpell(target, spellId, true);
        }

        void Register() override
        {
            AfterHit += SpellHitFn(
                haunting_affliction_SpellScript::HandleAfterHit);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new haunting_affliction_SpellScript();
    }
};

void AddModApocalipseWarlockHauntingAfflictionScripts()
{
    new spell_apoc_warlock_haunting_affliction();
}

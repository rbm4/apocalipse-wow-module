#include "Containers.h"
#include "DBCStores.h"
#include "DBCStructure.h"
#include "Item.h"
#include "Player.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

#include <list>

namespace
{
enum ApocalipseRoguePestilentKnivesSpells
{
    SPELL_APOC_ROGUE_PESTILENT_KNIVES = 901069,
    SPELL_ROGUE_DEADLY_POISON_R1 = 2818
};

constexpr uint32 PESTILENT_KNIVES_MAX_TARGETS = 10;
constexpr uint8 DEADLY_POISON_MAX_STACKS = 5;

bool IsDeadlyPoison(SpellInfo const* spellInfo)
{
    return spellInfo && spellInfo->SpellFamilyName == SPELLFAMILY_ROGUE &&
        spellInfo->Dispel == DISPEL_POISON &&
        spellInfo->SpellFamilyFlags.IsEqual(0x10000, 0x80000, 0);
}

uint32 GetMainHandDeadlyPoison(Player* rogue, Item*& mainHand)
{
    mainHand = rogue->GetItemByPos(
        INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_MAINHAND);
    if (!mainHand)
        return 0;

    SpellItemEnchantmentEntry const* enchant =
        sSpellItemEnchantmentStore.LookupEntry(
            mainHand->GetEnchantmentId(TEMP_ENCHANTMENT_SLOT));
    if (!enchant)
        return 0;

    for (uint8 effect = 0;
        effect < MAX_SPELL_ITEM_ENCHANTMENT_EFFECTS; ++effect)
    {
        if (enchant->type[effect] != ITEM_ENCHANTMENT_TYPE_COMBAT_SPELL)
            continue;

        uint32 spellId = enchant->spellid[effect];
        if (IsDeadlyPoison(sSpellMgr->GetSpellInfo(spellId)))
            return spellId;
    }

    return 0;
}
}

class spell_apoc_rogue_pestilent_knives : public SpellScriptLoader
{
public:
    spell_apoc_rogue_pestilent_knives()
        : SpellScriptLoader("spell_apoc_rogue_pestilent_knives") { }

    class pestilent_knives_SpellScript : public SpellScript
    {
        PrepareSpellScript(pestilent_knives_SpellScript);

        bool Load() override
        {
            Player* rogue = GetCaster()->ToPlayer();
            if (!rogue)
                return false;

            _deadlyPoison = GetMainHandDeadlyPoison(rogue, _mainHand);
            return true;
        }

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Id == SPELL_APOC_ROGUE_PESTILENT_KNIVES &&
                spellInfo->HasAttribute(
                    SPELL_ATTR4_SUPPRESS_WEAPON_PROCS) &&
                spellInfo->MaxAffectedTargets ==
                    PESTILENT_KNIVES_MAX_TARGETS &&
                spellInfo->Effects[EFFECT_0].IsEffect(
                    SPELL_EFFECT_WEAPON_PERCENT_DAMAGE) &&
                spellInfo->Effects[EFFECT_0].CalcValue() == 50 &&
                spellInfo->Effects[EFFECT_0].TargetA.GetTarget() ==
                    TARGET_DEST_CASTER &&
                spellInfo->Effects[EFFECT_0].TargetB.GetTarget() ==
                    TARGET_UNIT_DEST_AREA_ENEMY &&
                ValidateSpellInfo({ SPELL_ROGUE_DEADLY_POISON_R1 });
        }

        void SelectTargets(std::list<WorldObject*>& targets)
        {
            Acore::Containers::RandomResize(
                targets, PESTILENT_KNIVES_MAX_TARGETS);
        }

        void HandleHit(SpellEffIndex)
        {
            if (!_deadlyPoison || !_mainHand)
                return;

            Player* rogue = GetCaster()->ToPlayer();
            Unit* target = GetHitUnit();
            if (!rogue || !target || !target->IsAlive())
                return;

            uint8 stacks = 0;
            if (AuraEffect const* deadlyPoison = target->GetAuraEffect(
                SPELL_AURA_PERIODIC_DAMAGE, SPELLFAMILY_ROGUE,
                0x10000, 0x80000, 0, rogue->GetGUID()))
            {
                stacks = deadlyPoison->GetBase()->GetStackAmount();
            }

            uint8 applications = stacks >= DEADLY_POISON_MAX_STACKS ? 1 : 2;
            for (uint8 application = 0; application < applications;
                ++application)
            {
                rogue->CastSpell(
                    target, _deadlyPoison, true, _mainHand);
            }
        }

        void Register() override
        {
            OnObjectAreaTargetSelect += SpellObjectAreaTargetSelectFn(
                pestilent_knives_SpellScript::SelectTargets, EFFECT_0,
                TARGET_UNIT_DEST_AREA_ENEMY);
            OnEffectHitTarget += SpellEffectFn(
                pestilent_knives_SpellScript::HandleHit, EFFECT_0,
                SPELL_EFFECT_WEAPON_PERCENT_DAMAGE);
        }

    private:
        Item* _mainHand = nullptr;
        uint32 _deadlyPoison = 0;
    };

    SpellScript* GetSpellScript() const override
    {
        return new pestilent_knives_SpellScript();
    }
};

void AddModApocalipseRoguePestilentKnivesScripts()
{
    new spell_apoc_rogue_pestilent_knives();
}

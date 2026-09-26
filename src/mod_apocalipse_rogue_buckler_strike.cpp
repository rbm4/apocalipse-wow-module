#include "Item.h"
#include "Player.h"
#include "SpellInfo.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "ThreatManager.h"
#include "Unit.h"

#include <algorithm>

namespace
{
enum ApocalipseRogueBucklerStrikeSpells
{
    SPELL_ROGUE_BLADE_TWISTING_TRIGGER = 51585,
    SPELL_APOC_ROGUE_BUCKLER_STRIKE = 901078
};

constexpr float BUCKLER_STRIKE_ATTACK_POWER_COEFFICIENT = 1.10f;
constexpr float BUCKLER_STRIKE_BLOCK_VALUE_COEFFICIENT = 1.50f;
constexpr float BUCKLER_STRIKE_BONUS_THREAT_MULTIPLIER = 2.0f;

bool HasOffhandShield(Player const* rogue)
{
    Item const* shield = rogue->GetItemByPos(
        INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_OFFHAND);
    ItemTemplate const* itemTemplate = shield ? shield->GetTemplate() : nullptr;
    return itemTemplate && itemTemplate->Class == ITEM_CLASS_ARMOR &&
        itemTemplate->SubClass == ITEM_SUBCLASS_ARMOR_SHIELD &&
        !shield->IsBroken();
}
}

class spell_apoc_rogue_buckler_strike : public SpellScriptLoader
{
public:
    spell_apoc_rogue_buckler_strike()
        : SpellScriptLoader("spell_apoc_rogue_buckler_strike") { }

    class buckler_strike_SpellScript : public SpellScript
    {
        PrepareSpellScript(buckler_strike_SpellScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return ValidateSpellInfo({
                    SPELL_ROGUE_BLADE_TWISTING_TRIGGER
                }) &&
                spellInfo->Id == SPELL_APOC_ROGUE_BUCKLER_STRIKE &&
                spellInfo->GetRecoveryTime() == 20000 &&
                spellInfo->GetMaxDuration() == 3000 &&
                spellInfo->PowerType == POWER_ENERGY &&
                spellInfo->ManaCost == 25 &&
                spellInfo->SpellFamilyName == SPELLFAMILY_ROGUE &&
                spellInfo->GetSchoolMask() == SPELL_SCHOOL_MASK_NORMAL &&
                spellInfo->EquippedItemClass == ITEM_CLASS_ARMOR &&
                spellInfo->EquippedItemSubClassMask ==
                    (1 << ITEM_SUBCLASS_ARMOR_SHIELD) &&
                spellInfo->EquippedItemInventoryTypeMask ==
                    (1 << INVTYPE_SHIELD) &&
                spellInfo->Effects[EFFECT_0].IsEffect(
                    SPELL_EFFECT_SCHOOL_DAMAGE) &&
                spellInfo->Effects[EFFECT_0].TargetA.GetTarget() ==
                    TARGET_UNIT_TARGET_ENEMY &&
                spellInfo->Effects[EFFECT_1].IsEffect(
                    SPELL_EFFECT_ADD_COMBO_POINTS) &&
                spellInfo->Effects[EFFECT_1].CalcValue() == 1 &&
                spellInfo->Effects[EFFECT_1].TargetA.GetTarget() ==
                    TARGET_UNIT_TARGET_ENEMY &&
                spellInfo->Effects[EFFECT_2].IsEffect(
                    SPELL_EFFECT_INTERRUPT_CAST) &&
                spellInfo->Effects[EFFECT_2].TargetA.GetTarget() ==
                    TARGET_UNIT_TARGET_ENEMY;
        }

        SpellCastResult CheckCast()
        {
            Player* rogue = GetCaster()->ToPlayer();
            if (!rogue || rogue->getClass() != CLASS_ROGUE)
                return SPELL_FAILED_BAD_TARGETS;

            if (!HasOffhandShield(rogue))
                return SPELL_FAILED_EQUIPPED_ITEM_CLASS_OFFHAND;

            return SPELL_CAST_OK;
        }

        void CalculateDamage(SpellEffIndex)
        {
            Player* rogue = GetCaster()->ToPlayer();
            if (!rogue)
                return;

            float attackPower = std::max(
                0.0f, rogue->GetTotalAttackPowerValue(BASE_ATTACK));
            float damage = attackPower *
                    BUCKLER_STRIKE_ATTACK_POWER_COEFFICIENT +
                float(rogue->GetShieldBlockValue()) *
                    BUCKLER_STRIKE_BLOCK_VALUE_COEFFICIENT;
            SetEffectValue(std::max(1, int32(damage)));
        }

        void RestrictInterrupt(SpellEffIndex effectIndex)
        {
            Unit* target = GetHitUnit();
            if (!target || target->IsPlayer())
                PreventHitDefaultEffect(effectIndex);
        }

        void ApplyBladeTwisting(SpellEffIndex)
        {
            if (Unit* target = GetHitUnit())
                GetCaster()->CastSpell(
                    target, SPELL_ROGUE_BLADE_TWISTING_TRIGGER, true);
        }

        void AddBonusThreat()
        {
            Player* rogue = GetCaster()->ToPlayer();
            Unit* target = GetHitUnit();
            if (!rogue || !target || !target->CanHaveThreatList() ||
                GetHitDamage() <= 0)
                return;

            target->GetThreatMgr().AddThreat(
                rogue,
                float(GetHitDamage()) *
                    BUCKLER_STRIKE_BONUS_THREAT_MULTIPLIER,
                GetSpellInfo());
        }

        void Register() override
        {
            OnCheckCast += SpellCheckCastFn(
                buckler_strike_SpellScript::CheckCast);
            OnEffectLaunchTarget += SpellEffectFn(
                buckler_strike_SpellScript::CalculateDamage, EFFECT_0,
                SPELL_EFFECT_SCHOOL_DAMAGE);
            OnEffectHitTarget += SpellEffectFn(
                buckler_strike_SpellScript::ApplyBladeTwisting, EFFECT_0,
                SPELL_EFFECT_SCHOOL_DAMAGE);
            OnEffectLaunchTarget += SpellEffectFn(
                buckler_strike_SpellScript::RestrictInterrupt, EFFECT_2,
                SPELL_EFFECT_INTERRUPT_CAST);
            AfterHit += SpellHitFn(
                buckler_strike_SpellScript::AddBonusThreat);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new buckler_strike_SpellScript();
    }
};

void AddModApocalipseRogueBucklerStrikeScripts()
{
    new spell_apoc_rogue_buckler_strike();
}

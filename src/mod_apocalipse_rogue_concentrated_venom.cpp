#include "DBCStores.h"
#include "GameTime.h"
#include "Item.h"
#include "Player.h"
#include "Spell.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

#include <unordered_map>

namespace
{
enum ApocalipseRogueConcentratedVenomSpells
{
    SPELL_APOC_ROGUE_CONCENTRATED_VENOM = 901061
};

constexpr uint32 TARGET_COOLDOWN_MS = 1000;

bool IsRoguePoison(SpellInfo const* spellInfo)
{
    return spellInfo && spellInfo->SpellFamilyName == SPELLFAMILY_ROGUE &&
        spellInfo->Dispel == DISPEL_POISON;
}

bool IsDeadlyPoison(SpellInfo const* spellInfo)
{
    return IsRoguePoison(spellInfo) &&
        spellInfo->SpellFamilyFlags.IsEqual(0x10000, 0x80000, 0);
}

bool IsEquippedWeapon(Player const* rogue, Item const* item)
{
    return item &&
        (item == rogue->GetItemByPos(
            INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_MAINHAND) ||
        item == rogue->GetItemByPos(
            INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_OFFHAND));
}

struct DeadlyPoisonSource
{
    Item* Weapon = nullptr;
    SpellInfo const* Spell = nullptr;
};

DeadlyPoisonSource FindHighestDeadlyPoison(Player* rogue)
{
    DeadlyPoisonSource best;
    uint8 bestRank = 0;

    uint8 const equipmentSlots[] = {
        EQUIPMENT_SLOT_MAINHAND, EQUIPMENT_SLOT_OFFHAND
    };
    for (uint8 equipmentSlot : equipmentSlots)
    {
        Item* weapon = rogue->GetItemByPos(
            INVENTORY_SLOT_BAG_0, equipmentSlot);
        if (!weapon)
            continue;

        for (uint8 enchantmentSlot = 0;
            enchantmentSlot < MAX_ENCHANTMENT_SLOT; ++enchantmentSlot)
        {
            SpellItemEnchantmentEntry const* enchantment =
                sSpellItemEnchantmentStore.LookupEntry(
                    weapon->GetEnchantmentId(
                        EnchantmentSlot(enchantmentSlot)));
            if (!enchantment)
                continue;

            for (uint8 effect = 0;
                effect < MAX_SPELL_ITEM_ENCHANTMENT_EFFECTS; ++effect)
            {
                if (enchantment->type[effect] !=
                    ITEM_ENCHANTMENT_TYPE_COMBAT_SPELL)
                    continue;

                SpellInfo const* poison =
                    sSpellMgr->GetSpellInfo(enchantment->spellid[effect]);
                if (!IsDeadlyPoison(poison) ||
                    poison->SpellLevel > rogue->GetLevel())
                    continue;

                uint8 rank = sSpellMgr->GetSpellRank(poison->Id);
                if (!best.Spell || rank > bestRank ||
                    (rank == bestRank &&
                        poison->SpellLevel > best.Spell->SpellLevel))
                {
                    best = { weapon, poison };
                    bestRank = rank;
                }
            }
        }
    }

    return best;
}
}

class spell_apoc_rogue_concentrated_venom : public SpellScriptLoader
{
public:
    spell_apoc_rogue_concentrated_venom()
        : SpellScriptLoader("spell_apoc_rogue_concentrated_venom") { }

    class concentrated_venom_AuraScript : public AuraScript
    {
        PrepareAuraScript(concentrated_venom_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Id == SPELL_APOC_ROGUE_CONCENTRATED_VENOM &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY);
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Player* rogue = GetTarget()->ToPlayer();
            Spell const* procSpell = eventInfo.GetProcSpell();
            SpellInfo const* poison = eventInfo.GetSpellInfo();
            Unit* target = eventInfo.GetProcTarget();
            if (!target)
                target = eventInfo.GetActionTarget();

            if (!rogue || eventInfo.GetActor() != rogue || !procSpell ||
                !IsRoguePoison(poison) ||
                !IsEquippedWeapon(rogue, procSpell->m_CastItem) || !target ||
                !target->IsAlive() || target == rogue ||
                !rogue->IsValidAttackTarget(target))
                return false;

            DeadlyPoisonSource source = FindHighestDeadlyPoison(rogue);
            if (!source.Weapon || !source.Spell)
                return false;

            uint64 now = GameTime::GetGameTimeMS().count();
            for (auto itr = _nextAllowedByTarget.begin();
                itr != _nextAllowedByTarget.end();)
            {
                if (itr->second <= now)
                    itr = _nextAllowedByTarget.erase(itr);
                else
                    ++itr;
            }

            return _nextAllowedByTarget.find(target->GetGUID()) ==
                _nextAllowedByTarget.end();
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();

            Player* rogue = GetTarget()->ToPlayer();
            Unit* target = eventInfo.GetProcTarget();
            if (!target)
                target = eventInfo.GetActionTarget();

            DeadlyPoisonSource source = FindHighestDeadlyPoison(rogue);
            if (!target || !source.Weapon || !source.Spell)
                return;

            ObjectGuid targetGuid = target->GetGUID();
            _nextAllowedByTarget[targetGuid] =
                GameTime::GetGameTimeMS().count() + TARGET_COOLDOWN_MS;

            SpellCastResult result = rogue->CastSpell(
                target, source.Spell,
                TriggerCastFlags(
                    TRIGGERED_FULL_MASK &
                    ~TRIGGERED_IGNORE_SPELL_AND_CATEGORY_CD),
                source.Weapon, aurEff, rogue->GetGUID());
            if (result != SPELL_CAST_OK)
                _nextAllowedByTarget.erase(targetGuid);
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(
                concentrated_venom_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(
                concentrated_venom_AuraScript::HandleProc, EFFECT_0,
                SPELL_AURA_DUMMY);
        }

    private:
        std::unordered_map<ObjectGuid, uint64> _nextAllowedByTarget;
    };

    AuraScript* GetAuraScript() const override
    {
        return new concentrated_venom_AuraScript();
    }
};

void AddModApocalipseRogueConcentratedVenomScripts()
{
    new spell_apoc_rogue_concentrated_venom();
}

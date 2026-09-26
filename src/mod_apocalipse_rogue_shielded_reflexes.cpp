#include "Define.h"
#include "Item.h"
#include "Player.h"
#include "SpellAuras.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"

namespace
{
enum ApocalipseRogueShieldedReflexesSpells
{
    SPELL_ROGUE_EVASION = 5277,
    SPELL_ROGUE_BLADE_FLURRY = 13877,
    SPELL_APOC_ROGUE_SHIELDED_REFLEXES = 901158
};

constexpr int32 SHIELDED_REFLEXES_DURATION = 6000;

bool HasOffhandShield(Player const* rogue)
{
    Item const* shield = rogue->GetItemByPos(
        INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_OFFHAND);
    ItemTemplate const* itemTemplate = shield ? shield->GetTemplate() : nullptr;
    return itemTemplate && itemTemplate->Class == ITEM_CLASS_ARMOR &&
        itemTemplate->SubClass == ITEM_SUBCLASS_ARMOR_SHIELD &&
        !shield->IsBroken();
}

void EnsureAuraDuration(Player* rogue, uint32 spellId)
{
    Aura* aura = rogue->GetAura(spellId, rogue->GetGUID());
    if (!aura)
    {
        rogue->CastSpell(rogue, spellId, true);
        if (Aura* triggeredAura = rogue->GetAura(spellId, rogue->GetGUID()))
            triggeredAura->SetDuration(SHIELDED_REFLEXES_DURATION);
        return;
    }

    if (aura->GetDuration() < SHIELDED_REFLEXES_DURATION)
        aura->SetDuration(SHIELDED_REFLEXES_DURATION);
}
}

class spell_apoc_rogue_shielded_reflexes : public SpellScriptLoader
{
public:
    spell_apoc_rogue_shielded_reflexes()
        : SpellScriptLoader("spell_apoc_rogue_shielded_reflexes") { }

    class shielded_reflexes_AuraScript : public AuraScript
    {
        PrepareAuraScript(shielded_reflexes_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            SpellInfo const* evasionInfo = sSpellMgr->GetSpellInfo(
                SPELL_ROGUE_EVASION);
            SpellInfo const* bladeFlurryInfo = sSpellMgr->GetSpellInfo(
                SPELL_ROGUE_BLADE_FLURRY);
            return spellInfo->Id == SPELL_APOC_ROGUE_SHIELDED_REFLEXES &&
                spellInfo->SpellFamilyName == SPELLFAMILY_ROGUE &&
                spellInfo->EquippedItemClass == ITEM_CLASS_ARMOR &&
                spellInfo->EquippedItemSubClassMask ==
                    (1 << ITEM_SUBCLASS_ARMOR_SHIELD) &&
                spellInfo->EquippedItemInventoryTypeMask ==
                    (1 << INVTYPE_SHIELD) &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_ROGUE_EVASION,
                    SPELL_ROGUE_BLADE_FLURRY
                }) && evasionInfo && bladeFlurryInfo &&
                evasionInfo->Effects[EFFECT_0].IsAura(
                    SPELL_AURA_MOD_DODGE_PERCENT) &&
                bladeFlurryInfo->Effects[EFFECT_0].IsAura(
                    SPELL_AURA_MOD_MELEE_HASTE);
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Player* rogue = GetTarget()->ToPlayer();
            return rogue && rogue->getClass() == CLASS_ROGUE &&
                HasOffhandShield(rogue) &&
                (eventInfo.GetHitMask() & PROC_HIT_BLOCK);
        }

        void HandleProc(AuraEffect const*, ProcEventInfo&)
        {
            PreventDefaultAction();

            Player* rogue = GetTarget()->ToPlayer();
            if (!rogue)
                return;

            EnsureAuraDuration(rogue, SPELL_ROGUE_EVASION);
            EnsureAuraDuration(rogue, SPELL_ROGUE_BLADE_FLURRY);
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(
                shielded_reflexes_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(
                shielded_reflexes_AuraScript::HandleProc, EFFECT_0,
                SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new shielded_reflexes_AuraScript();
    }
};

void AddModApocalipseRogueShieldedReflexesScripts()
{
    new spell_apoc_rogue_shielded_reflexes();
}

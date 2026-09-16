#include "BattlegroundStamina.h"

#include "Battleground.h"
#include "Item.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "WorldSession.h"

namespace Apocalipse::BattlegroundStamina
{
namespace
{
bool IsPlayerbot(Player const* player)
{
    return player && player->GetSession() && player->GetSession()->IsBot();
}

bool CanSwapInCombat(Item const* item)
{
    return item && item->GetTemplate() && item->GetTemplate()->CanChangeEquipStateInCombat();
}
}

class BattlegroundStaminaWorldScript : public WorldScript
{
public:
    BattlegroundStaminaWorldScript() : WorldScript("BattlegroundStaminaWorldScript") { }

    void OnStartup() override
    {
        LoadConfig();
    }

    void OnAfterConfigLoad(bool /*reload*/) override
    {
        LoadConfig();
    }
};

class BattlegroundStaminaPlayerScript : public PlayerScript
{
public:
    BattlegroundStaminaPlayerScript() : PlayerScript("BattlegroundStaminaPlayerScript", {
        PLAYERHOOK_ON_LOGIN,
        PLAYERHOOK_ON_LEVEL_CHANGED,
        PLAYERHOOK_ON_MAP_CHANGED,
        PLAYERHOOK_CAN_EQUIP_ITEM,
        PLAYERHOOK_CAN_UNEQUIP_ITEM,
        PLAYERHOOK_ON_EQUIP,
        PLAYERHOOK_ON_UNEQUIP_ITEM,
        PLAYERHOOK_ON_AFTER_SPEC_SLOT_CHANGED,
        PLAYERHOOK_ON_PLAYER_LEARN_TALENTS,
        PLAYERHOOK_ON_PLAYER_RESURRECT
    }) { }

    void OnPlayerLogin(Player* player) override
    {
        ApplyAssistance(player);
    }

    void OnPlayerLevelChanged(Player* player, uint8 /*oldLevel*/) override
    {
        ApplyAssistance(player);
    }

    void OnPlayerMapChanged(Player* player) override
    {
        ApplyAssistance(player);
    }

    bool OnPlayerCanEquipItem(Player* player, uint8 /*slot*/, uint16& /*dest*/, Item* item, bool /*swap*/,
        bool notLoading) override
    {
        return !notLoading || !IsGearLocked(player) || IsPlayerbot(player) || CanSwapInCombat(item);
    }

    bool OnPlayerCanUnequipItem(Player* player, uint16 pos, bool /*swap*/) override
    {
        return !IsGearLocked(player) || IsPlayerbot(player) || !Player::IsEquipmentPos(pos)
            || CanSwapInCombat(player->GetItemByPos(pos));
    }

    void OnPlayerEquip(Player* player, Item* /*item*/, uint8 /*bag*/, uint8 /*slot*/, bool /*update*/) override
    {
        if (player && player->InBattleground())
            ApplyAssistance(player);
    }

    void OnPlayerUnequip(Player* player, Item* /*item*/) override
    {
        if (player && player->InBattleground())
            ApplyAssistance(player);
    }

    void OnPlayerAfterSpecSlotChanged(Player* player, uint8 /*newSlot*/) override
    {
        ApplyAssistance(player);
    }

    void OnPlayerLearnTalents(Player* player, uint32 /*talentId*/, uint32 /*talentRank*/,
        uint32 /*spellId*/) override
    {
        ApplyAssistance(player);
    }

    void OnPlayerResurrect(Player* player, float /*restorePercent*/, bool& /*applySickness*/) override
    {
        ApplyAssistance(player);
    }
};

class BattlegroundStaminaBattlegroundScript : public AllBattlegroundScript
{
public:
    BattlegroundStaminaBattlegroundScript() : AllBattlegroundScript("BattlegroundStaminaBattlegroundScript", {
        ALLBATTLEGROUNDHOOK_ON_BATTLEGROUND_ADD_PLAYER,
        ALLBATTLEGROUNDHOOK_ON_BATTLEGROUND_REMOVE_PLAYER_AT_LEAVE
    }) { }

    void OnBattlegroundAddPlayer(Battleground* battleground, Player* player) override
    {
        if (battleground && battleground->isBattleground() && !battleground->isArena())
            ApplyAssistance(player);
    }

    void OnBattlegroundRemovePlayerAtLeave(Battleground* /*battleground*/, Player* player) override
    {
        RemoveAssistance(player);
    }
};
}

void AddModApocalipseBattlegroundStaminaScripts()
{
    new Apocalipse::BattlegroundStamina::BattlegroundStaminaWorldScript();
    new Apocalipse::BattlegroundStamina::BattlegroundStaminaPlayerScript();
    new Apocalipse::BattlegroundStamina::BattlegroundStaminaBattlegroundScript();
}

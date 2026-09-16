#include "BattlegroundStamina.h"

#include "Battleground.h"
#include "Player.h"
#include "ScriptMgr.h"

namespace Apocalipse::BattlegroundStamina
{
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

    bool OnPlayerCanEquipItem(Player* player, uint8 /*slot*/, uint16& /*dest*/, Item* /*item*/, bool /*swap*/,
        bool notLoading) override
    {
        return !notLoading || !IsGearLocked(player);
    }

    bool OnPlayerCanUnequipItem(Player* player, uint16 /*pos*/, bool /*swap*/) override
    {
        return !IsGearLocked(player);
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

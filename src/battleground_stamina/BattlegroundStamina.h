#ifndef APOCALIPSE_BATTLEGROUND_STAMINA_H
#define APOCALIPSE_BATTLEGROUND_STAMINA_H

class Player;

namespace Apocalipse::BattlegroundStamina
{
void LoadConfig();
bool IsGearLocked(Player const* player);
void ApplyAssistance(Player* player);
void RemoveAssistance(Player* player);
}

void AddModApocalipseBattlegroundStaminaScripts();

#endif

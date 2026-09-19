#include "Player.h"
#include "ScriptMgr.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"

namespace
{
enum ApocalipsePaladinDivineSteedSpells
{
    SPELL_APOC_PALADIN_DIVINE_STEED = 901017
};

constexpr uint32 DIVINE_STEED_ALLIANCE_DISPLAY = 14565;
constexpr uint32 DIVINE_STEED_HORDE_DISPLAY = 20030;
constexpr uint32 DIVINE_STEED_DURATION_MS = 4000;
constexpr uint32 DIVINE_STEED_COOLDOWN_MS = 20000;
constexpr int32 DIVINE_STEED_SPEED_PCT = 100;

uint32 GetDivineSteedDisplay(Player const* player)
{
    return player->GetTeamId() == TEAM_ALLIANCE ?
        DIVINE_STEED_ALLIANCE_DISPLAY : DIVINE_STEED_HORDE_DISPLAY;
}

bool IsDivineSteedDisplay(uint32 displayId)
{
    return displayId == DIVINE_STEED_ALLIANCE_DISPLAY ||
        displayId == DIVINE_STEED_HORDE_DISPLAY;
}

void ClearDivineSteed(Player* player)
{
    player->RemoveAurasDueToSpell(SPELL_APOC_PALADIN_DIVINE_STEED);

    uint32 displayId = player->GetUInt32Value(UNIT_FIELD_MOUNTDISPLAYID);
    if (!player->IsMounted() && IsDivineSteedDisplay(displayId))
        player->SetUInt32Value(UNIT_FIELD_MOUNTDISPLAYID, 0);
}
}

class spell_apoc_paladin_divine_steed : public SpellScriptLoader
{
public:
    spell_apoc_paladin_divine_steed()
        : SpellScriptLoader("spell_apoc_paladin_divine_steed") { }

    class divine_steed_AuraScript : public AuraScript
    {
        PrepareAuraScript(divine_steed_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return ValidateSpellInfo({
                    SPELL_APOC_PALADIN_DIVINE_STEED
                }) &&
                spellInfo->Id == SPELL_APOC_PALADIN_DIVINE_STEED &&
                spellInfo->RecoveryTime == DIVINE_STEED_COOLDOWN_MS &&
                spellInfo->GetDuration() == DIVINE_STEED_DURATION_MS &&
                spellInfo->Dispel == DISPEL_NONE &&
                spellInfo->SpellFamilyName == SPELLFAMILY_PALADIN &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                spellInfo->Effects[EFFECT_1].IsAura(
                    SPELL_AURA_MOD_INCREASE_SPEED) &&
                spellInfo->Effects[EFFECT_1].CalcValue() ==
                    DIVINE_STEED_SPEED_PCT;
        }

        void HandleApply(AuraEffect const*, AuraEffectHandleModes)
        {
            Player* player = GetTarget()->ToPlayer();
            if (!player || player->IsMounted())
                return;

            _displayId = GetDivineSteedDisplay(player);
            player->SetUInt32Value(UNIT_FIELD_MOUNTDISPLAYID, _displayId);
        }

        void HandleRemove(AuraEffect const*, AuraEffectHandleModes)
        {
            Player* player = GetTarget()->ToPlayer();
            if (!player || player->IsMounted() || !_displayId)
                return;

            if (player->GetUInt32Value(UNIT_FIELD_MOUNTDISPLAYID) == _displayId)
                player->SetUInt32Value(UNIT_FIELD_MOUNTDISPLAYID, 0);
        }

        void Register() override
        {
            AfterEffectApply += AuraEffectApplyFn(
                divine_steed_AuraScript::HandleApply, EFFECT_0,
                SPELL_AURA_DUMMY, AURA_EFFECT_HANDLE_REAL);
            AfterEffectRemove += AuraEffectRemoveFn(
                divine_steed_AuraScript::HandleRemove, EFFECT_0,
                SPELL_AURA_DUMMY, AURA_EFFECT_HANDLE_REAL);
        }

    private:
        uint32 _displayId = 0;
    };

    AuraScript* GetAuraScript() const override
    {
        return new divine_steed_AuraScript();
    }
};

class apoc_paladin_divine_steed_player : public PlayerScript
{
public:
    apoc_paladin_divine_steed_player()
        : PlayerScript("apoc_paladin_divine_steed_player") { }

    void OnPlayerBeforeLogout(Player* player) override
    {
        ClearDivineSteed(player);
    }

    void OnPlayerMapChanged(Player* player) override
    {
        ClearDivineSteed(player);
    }
};

void AddModApocalipsePaladinDivineSteedScripts()
{
    new spell_apoc_paladin_divine_steed();
    new apoc_paladin_divine_steed_player();
}

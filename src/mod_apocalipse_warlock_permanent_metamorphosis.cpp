#include "AllSpellScript.h"
#include "Define.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "Spell.h"
#include "SpellAuras.h"
#include "SpellInfo.h"

namespace
{
enum ApocalipseWarlockPermanentMetamorphosisSpells
{
    SPELL_APOC_WARLOCK_PERMANENT_METAMORPHOSIS = 901030,
    SPELL_WARLOCK_METAMORPHOSIS_AURA = 47241
};

void ClearMetamorphosis(Player* player)
{
    if (player->HasAura(SPELL_WARLOCK_METAMORPHOSIS_AURA))
        player->RemoveAurasDueToSpell(SPELL_WARLOCK_METAMORPHOSIS_AURA);
}

void MakeMetamorphosisPermanent(Player* player)
{
    if (Aura* aura = player->GetAura(SPELL_WARLOCK_METAMORPHOSIS_AURA))
    {
        aura->SetMaxDuration(-1);
        aura->SetDuration(-1);
    }
}
}

class apoc_warlock_permanent_metamorphosis_spell : public AllSpellScript
{
public:
    apoc_warlock_permanent_metamorphosis_spell()
        : AllSpellScript("apoc_warlock_permanent_metamorphosis_spell", {
            ALLSPELLHOOK_ON_CALC_MAX_DURATION,
            ALLSPELLHOOK_ON_SPELL_CHECK_CAST
        }) { }

    void OnCalcMaxDuration(Aura const* aura, int32& maxDuration) override
    {
        if (aura->GetId() != SPELL_WARLOCK_METAMORPHOSIS_AURA)
            return;

        Player const* player = aura->GetUnitOwner()->ToPlayer();
        if (player && player->HasSpell(
            SPELL_APOC_WARLOCK_PERMANENT_METAMORPHOSIS))
            maxDuration = -1;
    }

    void OnSpellCheckCast(Spell* spell, bool, SpellCastResult&) override
    {
        if (!spell->GetSpellInfo()->HasAura(SPELL_AURA_MOUNTED))
            return;

        Player* player = spell->GetCaster()->ToPlayer();
        if (player && player->HasSpell(
            SPELL_APOC_WARLOCK_PERMANENT_METAMORPHOSIS))
            ClearMetamorphosis(player);
    }
};

class apoc_warlock_permanent_metamorphosis_player : public PlayerScript
{
public:
    apoc_warlock_permanent_metamorphosis_player()
        : PlayerScript("apoc_warlock_permanent_metamorphosis_player") { }

    void OnPlayerLearnSpell(Player* player, uint32 spellId) override
    {
        if (spellId == SPELL_APOC_WARLOCK_PERMANENT_METAMORPHOSIS)
            MakeMetamorphosisPermanent(player);
    }

    void OnPlayerForgotSpell(Player* player, uint32 spellId) override
    {
        if (spellId == SPELL_APOC_WARLOCK_PERMANENT_METAMORPHOSIS)
            ClearMetamorphosis(player);
    }

    void OnPlayerTalentsReset(Player* player, bool) override
    {
        if (player->HasSpell(SPELL_APOC_WARLOCK_PERMANENT_METAMORPHOSIS))
            ClearMetamorphosis(player);
    }

    void OnPlayerLogin(Player* player) override
    {
        if (player->HasSpell(SPELL_APOC_WARLOCK_PERMANENT_METAMORPHOSIS))
            ClearMetamorphosis(player);
    }

    void OnPlayerBeforeLogout(Player* player) override
    {
        ClearMetamorphosis(player);
    }
};

void AddModApocalipseWarlockPermanentMetamorphosisScripts()
{
    new apoc_warlock_permanent_metamorphosis_spell();
    new apoc_warlock_permanent_metamorphosis_player();
}

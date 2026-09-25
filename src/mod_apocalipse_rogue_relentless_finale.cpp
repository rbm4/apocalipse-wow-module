#include "AllSpellScript.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "Spell.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"

#include <unordered_set>

namespace
{
enum ApocalipseRogueRelentlessFinaleSpells
{
    SPELL_APOC_ROGUE_RELENTLESS_FINALE = 901084,
    SPELL_APOC_ROGUE_RELENTLESS_FINALE_READY = 901085,
    SPELL_APOC_ROGUE_RELENTLESS_FINALE_BYPASS = 901086,
    SPELL_APOC_ROGUE_RELENTLESS_FINALE_RECHARGE = 901087,
    SPELL_APOC_ROGUE_RELENTLESS_FINALE_HEAL = 901088
};

constexpr uint8 RELENTLESS_FINALE_REQUIRED_COMBO_POINTS = 5;
constexpr int32 RELENTLESS_FINALE_BYPASS_MS = 1000;
constexpr int32 RELENTLESS_FINALE_RECHARGE_MS = 12000;
thread_local std::unordered_set<Spell const*> g_qualifyingFinisherCasts;

bool IsQualifyingFinisher(Player const* player, Spell const* spell)
{
    SpellInfo const* spellInfo = spell->GetSpellInfo();
    if (player->getClass() != CLASS_ROGUE || spell->IsTriggered() ||
        spellInfo->SpellFamilyName != SPELLFAMILY_ROGUE ||
        !spellInfo->NeedsComboPoints())
        return false;

    if (spellInfo->NeedsExplicitUnitTarget())
    {
        Unit const* comboTarget = player->GetComboTarget();
        if (!comboTarget || player->GetComboPoints(comboTarget) !=
            RELENTLESS_FINALE_REQUIRED_COMBO_POINTS)
            return false;

        if (Unit* target = spell->GetOriginalTarget())
            return target == comboTarget;

        return player->GetTarget() == comboTarget->GetGUID();
    }

    return player->GetComboPoints() ==
        RELENTLESS_FINALE_REQUIRED_COMBO_POINTS;
}

void ApplyReady(Player* player)
{
    if (player->HasAura(SPELL_APOC_ROGUE_RELENTLESS_FINALE) &&
        !player->HasAura(SPELL_APOC_ROGUE_RELENTLESS_FINALE_RECHARGE) &&
        !player->HasAura(SPELL_APOC_ROGUE_RELENTLESS_FINALE_READY))
        player->CastSpell(player,
            SPELL_APOC_ROGUE_RELENTLESS_FINALE_READY, true);
}

void ApplyBypass(Player* player)
{
    player->CastSpell(player,
        SPELL_APOC_ROGUE_RELENTLESS_FINALE_BYPASS, true);
    if (Aura* bypass = player->GetAura(
        SPELL_APOC_ROGUE_RELENTLESS_FINALE_BYPASS))
    {
        bypass->SetMaxDuration(RELENTLESS_FINALE_BYPASS_MS);
        bypass->SetDuration(RELENTLESS_FINALE_BYPASS_MS);
    }
}

void StartRecharge(Player* player)
{
    player->CastSpell(player,
        SPELL_APOC_ROGUE_RELENTLESS_FINALE_RECHARGE, true);
    if (Aura* recharge = player->GetAura(
        SPELL_APOC_ROGUE_RELENTLESS_FINALE_RECHARGE))
    {
        recharge->SetMaxDuration(RELENTLESS_FINALE_RECHARGE_MS);
        recharge->SetDuration(RELENTLESS_FINALE_RECHARGE_MS);
    }
}

void ClearTransientAuras(Player* player)
{
    player->RemoveAurasDueToSpell(
        SPELL_APOC_ROGUE_RELENTLESS_FINALE_READY);
    player->RemoveAurasDueToSpell(
        SPELL_APOC_ROGUE_RELENTLESS_FINALE_BYPASS);
    player->RemoveAurasDueToSpell(
        SPELL_APOC_ROGUE_RELENTLESS_FINALE_RECHARGE);
}
}

class spell_apoc_rogue_relentless_finale : public SpellScriptLoader
{
public:
    spell_apoc_rogue_relentless_finale()
        : SpellScriptLoader("spell_apoc_rogue_relentless_finale") { }

    class relentless_finale_AuraScript : public AuraScript
    {
        PrepareAuraScript(relentless_finale_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            SpellInfo const* readyInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_ROGUE_RELENTLESS_FINALE_READY);
            SpellInfo const* bypassInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_ROGUE_RELENTLESS_FINALE_BYPASS);
            SpellInfo const* rechargeInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_ROGUE_RELENTLESS_FINALE_RECHARGE);
            SpellInfo const* healInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_ROGUE_RELENTLESS_FINALE_HEAL);
            return (spellInfo->Id == SPELL_APOC_ROGUE_RELENTLESS_FINALE ||
                    spellInfo->Id ==
                        SPELL_APOC_ROGUE_RELENTLESS_FINALE_RECHARGE) &&
                ValidateSpellInfo({
                    SPELL_APOC_ROGUE_RELENTLESS_FINALE,
                    SPELL_APOC_ROGUE_RELENTLESS_FINALE_READY,
                    SPELL_APOC_ROGUE_RELENTLESS_FINALE_BYPASS,
                    SPELL_APOC_ROGUE_RELENTLESS_FINALE_RECHARGE,
                    SPELL_APOC_ROGUE_RELENTLESS_FINALE_HEAL
                }) && readyInfo &&
                readyInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                bypassInfo && bypassInfo->Effects[EFFECT_0].IsAura(
                    SPELL_AURA_ABILITY_IGNORE_AURASTATE) &&
                rechargeInfo &&
                rechargeInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                healInfo && healInfo->Effects[EFFECT_0].Effect ==
                    SPELL_EFFECT_HEAL_PCT;
        }

        void HandleApply(AuraEffect const*, AuraEffectHandleModes)
        {
            if (m_scriptSpellId != SPELL_APOC_ROGUE_RELENTLESS_FINALE)
                return;

            if (Player* player = GetTarget()->ToPlayer())
                ApplyReady(player);
        }

        void HandleRemove(AuraEffect const*, AuraEffectHandleModes)
        {
            Player* player = GetTarget()->ToPlayer();
            if (!player)
                return;

            if (m_scriptSpellId == SPELL_APOC_ROGUE_RELENTLESS_FINALE)
                ClearTransientAuras(player);
            else if (GetTargetApplication()->GetRemoveMode() ==
                AURA_REMOVE_BY_EXPIRE)
                ApplyReady(player);
        }

        void Register() override
        {
            AfterEffectApply += AuraEffectApplyFn(
                relentless_finale_AuraScript::HandleApply, EFFECT_0,
                SPELL_AURA_DUMMY, AURA_EFFECT_HANDLE_REAL);
            AfterEffectRemove += AuraEffectRemoveFn(
                relentless_finale_AuraScript::HandleRemove, EFFECT_0,
                SPELL_AURA_DUMMY, AURA_EFFECT_HANDLE_REAL);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new relentless_finale_AuraScript();
    }
};

class apoc_rogue_relentless_finale_player : public PlayerScript
{
public:
    apoc_rogue_relentless_finale_player()
        : PlayerScript("apoc_rogue_relentless_finale_player") { }

    void OnPlayerSpellCast(Player* player, Spell* spell, bool) override
    {
        if (!player->HasAura(SPELL_APOC_ROGUE_RELENTLESS_FINALE) ||
            !IsQualifyingFinisher(player, spell))
            return;

        g_qualifyingFinisherCasts.insert(spell);
    }
};

class apoc_rogue_relentless_finale_spell : public AllSpellScript
{
public:
    apoc_rogue_relentless_finale_spell()
        : AllSpellScript("apoc_rogue_relentless_finale_spell", {
            ALLSPELLHOOK_ON_SPELL_CHECK_CAST,
            ALLSPELLHOOK_ON_CAST_CANCEL,
            ALLSPELLHOOK_ON_CAST
        }) { }

    void OnSpellCheckCast(
        Spell* spell, bool strict, SpellCastResult&) override
    {
        Player* player = spell->GetCaster()->ToPlayer();
        if (!player)
            return;

        player->RemoveAurasDueToSpell(
            SPELL_APOC_ROGUE_RELENTLESS_FINALE_BYPASS);
        if (spell->IsTriggered())
            return;

        if (strict)
            g_qualifyingFinisherCasts.clear();
        if (strict &&
            player->HasAura(SPELL_APOC_ROGUE_RELENTLESS_FINALE_READY) &&
            IsQualifyingFinisher(player, spell))
            ApplyBypass(player);
    }

    void OnSpellCastCancel(
        Spell* spell, Unit* caster, SpellInfo const*, bool) override
    {
        if (g_qualifyingFinisherCasts.erase(spell) == 0)
            return;

        if (Player* player = caster->ToPlayer())
            player->RemoveAurasDueToSpell(
                SPELL_APOC_ROGUE_RELENTLESS_FINALE_BYPASS);
    }

    void OnSpellCast(
        Spell* spell, Unit* caster, SpellInfo const*, bool) override
    {
        Player* player = caster->ToPlayer();
        if (!player || spell->IsTriggered() ||
            g_qualifyingFinisherCasts.erase(spell) == 0)
            return;

        bool retainedComboPoints = player->HasAura(
            SPELL_APOC_ROGUE_RELENTLESS_FINALE_BYPASS);
        player->RemoveAurasDueToSpell(
            SPELL_APOC_ROGUE_RELENTLESS_FINALE_BYPASS);
        player->CastSpell(player,
            SPELL_APOC_ROGUE_RELENTLESS_FINALE_HEAL, true);
        if (retainedComboPoints)
        {
            player->RemoveAurasDueToSpell(
                SPELL_APOC_ROGUE_RELENTLESS_FINALE_READY);
            StartRecharge(player);
        }
    }
};

void AddModApocalipseRogueRelentlessFinaleScripts()
{
    new spell_apoc_rogue_relentless_finale();
    new apoc_rogue_relentless_finale_player();
    new apoc_rogue_relentless_finale_spell();
}

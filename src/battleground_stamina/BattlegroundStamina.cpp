#include "BattlegroundStamina.h"

#include "Battleground.h"
#include "Config.h"
#include "Log.h"
#include "Player.h"
#include "SpellDefines.h"
#include "SpellAuraEffects.h"
#include "SpellAuras.h"
#include "SpellInfo.h"
#include "SpellMgr.h"

#include <algorithm>
#include <array>
#include <cmath>
#include <string>

namespace Apocalipse::BattlegroundStamina
{
namespace
{
constexpr uint8 BracketCount = 7;

struct ClassConfig
{
    uint8 Id;
    char const* Name;
};

constexpr std::array<ClassConfig, 10> Classes = {{
    { CLASS_WARRIOR, "Warrior" },
    { CLASS_PALADIN, "Paladin" },
    { CLASS_HUNTER, "Hunter" },
    { CLASS_ROGUE, "Rogue" },
    { CLASS_PRIEST, "Priest" },
    { CLASS_DEATH_KNIGHT, "DeathKnight" },
    { CLASS_SHAMAN, "Shaman" },
    { CLASS_MAGE, "Mage" },
    { CLASS_WARLOCK, "Warlock" },
    { CLASS_DRUID, "Druid" }
}};

// Rows are brackets 10-19 through 70-79. Columns use the Classes order above.
// These are conservative starting points, not claims about final balance.
constexpr std::array<std::array<uint32, Classes.size()>, BracketCount> DefaultThresholds = {{
    {{ 1200, 1150, 900, 850, 800,    0, 900, 800, 900, 850 }},
    {{ 3000, 2900, 2700, 2600, 2350,    0, 2700, 2250, 2500, 2600 }},
    {{ 4800, 4600, 4300, 4100, 3700,    0, 4300, 3550, 3950, 4100 }},
    {{ 7500, 7200, 6700, 6400, 5750,    0, 6700, 5550, 6150, 6400 }},
    {{ 11000, 10600, 9800, 9400, 8400, 11000, 9800, 8100, 9000, 9400 }},
    {{ 16500, 15900, 14700, 14100, 12600, 16500, 14700, 12100, 13500, 14100 }},
    {{ 26000, 25000, 23200, 22200, 19900, 26000, 23200, 19100, 21300, 22200 }}
}};

struct Settings
{
    bool Enabled = true;
    bool LockGear = true;
    uint32 AuraSpellId = 0;
    float GapCoveragePct = 50.0f;
    uint32 MaxBonusStamina = 5000;
    std::array<std::array<uint32, MAX_CLASSES>, BracketCount> HealthThresholds = {};
    bool AuraReady = false;
};

Settings g_settings;

uint8 GetBracketIndex(uint8 level)
{
    if (level < 10 || level >= 80)
        return BracketCount;

    return (level / 10) - 1;
}

bool IsStaminaEffect(AuraEffect const* effect)
{
    return effect && (effect->GetMiscValue() == STAT_STAMINA || effect->GetMiscValue() < 0);
}

bool IsPassiveEffect(AuraEffect const* effect)
{
    return effect && effect->GetBase()->IsPassive();
}

bool IsPassiveStaminaEffect(AuraEffect const* effect)
{
    return IsStaminaEffect(effect) && IsPassiveEffect(effect);
}

bool IsPassiveStaminaPercentEffect(AuraEffect const* effect)
{
    return IsPassiveEffect(effect)
        && (effect->GetMiscValue() == STAT_STAMINA || effect->GetMiscValue() == -1);
}

float GetHealthFromStamina(float stamina)
{
    stamina = std::max(stamina, 0.0f);
    float baseStamina = std::min(stamina, 20.0f);
    return baseStamina + ((stamina - baseStamina) * 10.0f);
}

struct Baseline
{
    float Health;
    float Stamina;
    float StaminaTotalMultiplier;
    float HealthTotalMultiplier;
};

Baseline CalculateUnbuffedBaseline(Player const* player)
{
    UnitMods staminaMod = UNIT_MOD_STAT_STAMINA;

    // Item stats live in BASE_VALUE. Direct enchant stats live in TOTAL_VALUE,
    // together with aura stats. Rebuild the native formula with direct values
    // and passive effects, excluding active buffs and this assistance aura.
    float directStaminaTotal = player->GetFlatModifierValue(staminaMod, TOTAL_VALUE)
        - player->GetTotalAuraModifier(SPELL_AURA_MOD_STAT, IsStaminaEffect);
    float passiveStaminaFlat = player->GetTotalAuraModifier(
        SPELL_AURA_MOD_STAT, IsPassiveStaminaEffect);
    float staminaBaseMultiplier = player->GetTotalAuraMultiplier(
        SPELL_AURA_MOD_PERCENT_STAT, IsPassiveStaminaPercentEffect);
    float staminaTotalMultiplier = player->GetTotalAuraMultiplier(
        SPELL_AURA_MOD_TOTAL_STAT_PERCENTAGE, IsPassiveStaminaPercentEffect);

    float stamina = (player->GetCreateStat(STAT_STAMINA)
        + player->GetFlatModifierValue(staminaMod, BASE_VALUE)) * staminaBaseMultiplier;
    stamina = (stamina + directStaminaTotal + passiveStaminaFlat) * staminaTotalMultiplier;
    stamina = std::floor(std::max(stamina, 0.0f));

    float directHealthTotal = player->GetFlatModifierValue(UNIT_MOD_HEALTH, TOTAL_VALUE)
        - player->GetTotalAuraModifier(SPELL_AURA_MOD_INCREASE_HEALTH)
        - player->GetTotalAuraModifier(SPELL_AURA_MOD_INCREASE_HEALTH_2);
    float passiveHealthFlat = player->GetTotalAuraModifier(
        SPELL_AURA_MOD_INCREASE_HEALTH, IsPassiveEffect)
        + player->GetTotalAuraModifier(SPELL_AURA_MOD_INCREASE_HEALTH_2, IsPassiveEffect);
    float healthBaseMultiplier = player->GetTotalAuraMultiplier(
        SPELL_AURA_MOD_BASE_HEALTH_PCT, IsPassiveEffect);
    float healthTotalMultiplier = player->GetTotalAuraMultiplier(
        SPELL_AURA_MOD_INCREASE_HEALTH_PERCENT, IsPassiveEffect);

    float health = (float(player->GetCreateHealth())
        + player->GetFlatModifierValue(UNIT_MOD_HEALTH, BASE_VALUE)) * healthBaseMultiplier;
    health = (health + directHealthTotal + passiveHealthFlat + GetHealthFromStamina(stamina))
        * healthTotalMultiplier;

    return {
        std::max(health, 1.0f),
        stamina,
        staminaTotalMultiplier,
        healthTotalMultiplier
    };
}

uint32 GetThreshold(Player const* player)
{
    uint8 bracket = GetBracketIndex(player->GetLevel());
    uint8 playerClass = player->getClass();
    if (bracket >= BracketCount || playerClass >= MAX_CLASSES)
        return 0;

    return g_settings.HealthThresholds[bracket][playerClass];
}

uint32 CalculateStaminaBonus(Baseline const& baseline, uint32 threshold)
{
    if (!threshold || baseline.Health >= float(threshold) || g_settings.GapCoveragePct <= 0.0f)
        return 0;

    float missingHealth = float(threshold) - baseline.Health;
    float desiredBonusHealth = std::ceil(missingHealth * g_settings.GapCoveragePct / 100.0f);
    float startingStaminaHealth = GetHealthFromStamina(baseline.Stamina);

    uint32 low = 0;
    uint32 high = g_settings.MaxBonusStamina;
    while (low < high)
    {
        uint32 middle = low + ((high - low) / 2);
        float candidateStamina = std::floor(
            baseline.Stamina + (float(middle) * baseline.StaminaTotalMultiplier));
        float grantedHealth = (GetHealthFromStamina(candidateStamina) - startingStaminaHealth)
            * baseline.HealthTotalMultiplier;
        if (grantedHealth >= desiredBonusHealth)
            high = middle;
        else
            low = middle + 1;
    }

    return low;
}

bool IsSupportedBattleground(Player const* player)
{
    if (!player || !player->InBattleground())
        return false;

    Battleground* battleground = player->GetBattleground();
    return battleground && battleground->isBattleground() && !battleground->isArena();
}

bool ValidateAuraSpell()
{
    if (!g_settings.AuraSpellId)
    {
        LOG_WARN("module", "[BattlegroundStamina] AuraSpellId is 0; stamina assistance is disabled until a "
            "custom spell is allocated.");
        return false;
    }

    SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(g_settings.AuraSpellId);
    if (!spellInfo)
    {
        LOG_ERROR("module", "[BattlegroundStamina] Spell {} does not exist; stamina assistance is disabled.",
            g_settings.AuraSpellId);
        return false;
    }

    SpellEffectInfo const& effect = spellInfo->Effects[EFFECT_0];
    if (!effect.IsEffect(SPELL_EFFECT_APPLY_AURA)
        || effect.ApplyAuraName != SPELL_AURA_MOD_STAT
        || effect.MiscValue != STAT_STAMINA)
    {
        LOG_ERROR("module", "[BattlegroundStamina] Spell {} effect 0 must apply SPELL_AURA_MOD_STAT with "
            "STAT_STAMINA; stamina assistance is disabled.", g_settings.AuraSpellId);
        return false;
    }

    if (spellInfo->IsPassive() || spellInfo->SpellFamilyName != SPELLFAMILY_GENERIC
        || (effect.DieSides != 0 && effect.DieSides != 1)
        || effect.RealPointsPerLevel != 0.0f || effect.PointsPerComboPoint != 0.0f)
    {
        LOG_ERROR("module", "[BattlegroundStamina] Spell {} must be non-passive, generic, and have no random, "
            "level, or combo-point amount scaling; stamina assistance is disabled.", g_settings.AuraSpellId);
        return false;
    }

    if (effect.TargetA.GetTarget() != TARGET_UNIT_CASTER)
    {
        LOG_ERROR("module", "[BattlegroundStamina] Spell {} effect 0 must target TARGET_UNIT_CASTER; "
            "stamina assistance is disabled.", g_settings.AuraSpellId);
        return false;
    }

    if (!spellInfo->IsPositive() || spellInfo->GetDuration() != -1
        || !spellInfo->HasAttribute(SPELL_ATTR0_NO_AURA_CANCEL)
        || !spellInfo->HasAttribute(SPELL_ATTR3_ALLOW_AURA_WHILE_DEAD)
        || !spellInfo->HasAttribute(SPELL_ATTR0_CU_AURA_CANNOT_BE_SAVED)
        || spellInfo->Dispel != DISPEL_NONE)
    {
        LOG_ERROR("module", "[BattlegroundStamina] Spell {} must be positive, infinite, non-cancellable, "
            "death-persistent, non-persistent in character_aura, and use DISPEL_NONE; stamina assistance "
            "is disabled.", g_settings.AuraSpellId);
        return false;
    }

    return true;
}
}

void LoadConfig()
{
    g_settings.Enabled = sConfigMgr->GetOption<bool>("Apocalipse.BattlegroundStamina.Enable", true);
    g_settings.LockGear = sConfigMgr->GetOption<bool>("Apocalipse.BattlegroundStamina.LockGear", true);
    g_settings.AuraSpellId = sConfigMgr->GetOption<uint32>("Apocalipse.BattlegroundStamina.AuraSpellId", 0);
    g_settings.GapCoveragePct = std::clamp(
        sConfigMgr->GetOption<float>("Apocalipse.BattlegroundStamina.GapCoveragePct", 50.0f), 0.0f, 99.0f);
    g_settings.MaxBonusStamina = std::max<uint32>(
        sConfigMgr->GetOption<uint32>("Apocalipse.BattlegroundStamina.MaxBonusStamina", 5000), 1);

    for (uint8 bracket = 0; bracket < BracketCount; ++bracket)
    {
        std::string bracketName = std::to_string((bracket + 1) * 10)
            + std::to_string(((bracket + 1) * 10) + 9);
        for (uint8 classIndex = 0; classIndex < Classes.size(); ++classIndex)
        {
            ClassConfig const& classConfig = Classes[classIndex];
            std::string key = "Apocalipse.BattlegroundStamina.HealthThreshold."
                + bracketName + "." + classConfig.Name;
            g_settings.HealthThresholds[bracket][classConfig.Id] =
                sConfigMgr->GetOption<uint32>(key, DefaultThresholds[bracket][classIndex]);
        }
    }

    g_settings.AuraReady = g_settings.Enabled && ValidateAuraSpell();
    LOG_INFO("module", "[BattlegroundStamina] Enabled={}, gear lock={}, aura={}, gap coverage={:.1f}%, "
        "max stamina bonus={}.",
        g_settings.Enabled, g_settings.LockGear, g_settings.AuraSpellId,
        g_settings.GapCoveragePct, g_settings.MaxBonusStamina);
}

bool IsGearLocked(Player const* player)
{
    return g_settings.Enabled && g_settings.LockGear && IsSupportedBattleground(player);
}

void ApplyAssistance(Player* player)
{
    if (!player)
        return;

    if (!g_settings.AuraReady || !IsSupportedBattleground(player))
    {
        RemoveAssistance(player);
        return;
    }

    uint32 threshold = GetThreshold(player);
    Baseline baseline = CalculateUnbuffedBaseline(player);
    uint32 staminaBonus = CalculateStaminaBonus(baseline, threshold);
    uint32 healthBefore = player->GetHealth();

    if (!staminaBonus)
    {
        player->RemoveAurasDueToSpell(g_settings.AuraSpellId);
        return;
    }

    if (AuraEffect* auraEffect = player->GetAuraEffect(g_settings.AuraSpellId, EFFECT_0, player->GetGUID()))
    {
        auraEffect->ChangeAmount(int32(staminaBonus));
    }
    else
    {
        player->CastCustomSpell(g_settings.AuraSpellId, SPELLVALUE_BASE_POINT0, int32(staminaBonus), player,
            TRIGGERED_FULL_MASK);
    }

    // Flat stamina normally only raises maximum health, but retain an explicit
    // invariant so future spell-data changes cannot turn gear or map events
    // into a free heal.
    if (player->GetHealth() > healthBefore)
        player->SetHealth(healthBefore);
}

void RemoveAssistance(Player* player)
{
    if (player && g_settings.AuraSpellId)
        player->RemoveAurasDueToSpell(g_settings.AuraSpellId);
}
}

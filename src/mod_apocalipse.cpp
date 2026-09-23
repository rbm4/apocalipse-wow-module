/*
 * mod_apocalipse.cpp
 *
 * Spec Manager module for Apocalipse WoW.
 *
 * Behaviour:
 *   - NPC (entry 900001) lets a player choose his spec manually.
 *   - On login and on save the module inspects which talent tree has the most
 *     points spent.  If the dominant tree changed since the last grant it
 *     removes the previous spec's signature spells and learns the new ones.
 *   - Spell lists are stored in `mod_spec_spells` (acore_world) so they can
 *     be edited from the admin panel without recompiling.
 *   - Per-player state is stored in `mod_player_spec` (acore_characters).
 */

#include "ScriptMgr.h"
#include "Player.h"
#include "Creature.h"
#include "GossipDef.h"
#include "ScriptedGossip.h"
#include "DatabaseEnv.h"
#include "Chat.h"
#include "Log.h"
#include "SpellMgr.h"
#include "DBCStores.h"
#include "WorldSession.h"

#include <unordered_map>
#include <unordered_set>
#include <vector>
#include <string>
#include <map>
#include <algorithm>
#include <mutex>
#include <chrono>

// ─────────────────────────────────────────────────────────────────────────────
// Config
// ─────────────────────────────────────────────────────────────────────────────

// Creature entry used for the spec-selector NPC.
static constexpr uint32 NPC_SPEC_SELECTOR = 900001;

// A player must have at least this many points in a tree before that tree is
// considered "dominant" and its spells are granted.
static constexpr uint32 MIN_POINTS_FOR_SPEC = 1;
static constexpr uint8 HIDDEN_TALENT_BUDGET_PER_SPEC = 6;

// ─────────────────────────────────────────────────────────────────────────────
// Spec name table  (WotLK talent-tab order per class)
// ─────────────────────────────────────────────────────────────────────────────

static const std::map<uint8, std::vector<std::string>> g_specNames = {
    {1, {"Arms", "Fury", "Protection"}},                // Warrior
    {2, {"Holy", "Protection", "Retribution"}},         // Paladin
    {3, {"Beast Mastery", "Marksmanship", "Survival"}}, // Hunter
    {4, {"Assassination", "Combat", "Subtlety"}},       // Rogue
    {5, {"Discipline", "Holy", "Shadow"}},              // Priest
    {6, {"Blood", "Frost", "Unholy"}},                  // Death Knight
    {7, {"Elemental", "Enhancement", "Restoration"}},   // Shaman
    {8, {"Arcane", "Fire", "Frost"}},                   // Mage
    {9, {"Affliction", "Demonology", "Destruction"}},   // Warlock
    {11, {"Balance", "Feral Combat", "Restoration"}},   // Druid
};

// ─────────────────────────────────────────────────────────────────────────────
// In-memory spell cache
// g_specSpells[class][spec_index] = { spell_id, ... }
// ─────────────────────────────────────────────────────────────────────────────

using SpecSpellMap = std::unordered_map<uint8, std::unordered_map<uint8, std::vector<uint32>>>;
static SpecSpellMap g_specSpells;
static std::unordered_set<uint32> g_reconcileInProgress;
static std::unordered_map<uint32, uint64> g_lastTalentsResetMs; // Track last OnPlayerTalentsReset call per player
static std::mutex g_specUpdateMutex;

using SpellIdSet = std::unordered_set<uint32>;
static constexpr uint32 TALENTS_RESET_MIN_INTERVAL_MS = 1000; // Prevent rapid OnPlayerTalentsReset calls

static uint64 GetNowMs()
{
    auto now = std::chrono::steady_clock::now().time_since_epoch();
    return (uint64)std::chrono::duration_cast<std::chrono::milliseconds>(now).count();
}

static bool HasValidSpecManagerSession(Player *player)
{
    if (!player)
        return false;

    WorldSession *session = player->GetSession();
    return session != nullptr;
}

static bool IsBotSession(Player *player)
{
    if (!player)
        return false;

    WorldSession *session = player->GetSession();
    return session && session->IsBot();
}

static SpellIdSet GetSpecSpellSet(uint8 cls, uint8 spec)
{
    SpellIdSet spells;

    auto clsIt = g_specSpells.find(cls);
    if (clsIt == g_specSpells.end())
        return spells;

    auto specIt = clsIt->second.find(spec);
    if (specIt == clsIt->second.end())
        return spells;

    for (uint32 id : specIt->second)
        spells.insert(id);

    return spells;
}

static uint8 GetPlayerTalentRank(Player *player, TalentEntry const *talentInfo)
{
    uint8 maxRank = 0;
    for (uint8 rank = 0; rank < MAX_TALENT_RANK; ++rank)
    {
        uint32 rankSpell = talentInfo->RankID[rank];
        if (rankSpell && player->HasTalent(rankSpell, player->GetActiveSpec()))
            maxRank = std::max<uint8>(maxRank, uint8(rank + 1));
    }

    return maxRank;
}

enum class ManagedTalentGrantResult : uint8
{
    Skipped,
    Applied,
    Stop
};

struct ManagedTalentGrantContext
{
    TalentSpellPos const *pos = nullptr;
    TalentEntry const *talentInfo = nullptr;
    TalentTabEntry const *talentTabInfo = nullptr;
    SpellInfo const *spellInfo = nullptr;
    uint8 currentRank = 0;
    uint8 targetRank = 0;
    uint32 cost = 0;
};

static ManagedTalentGrantResult GrantManagedTalent(Player *player, uint8 specIndex, uint32 spellId, uint32 &available)
{
    uint32 guid = player->GetGUID().GetCounter();

    ManagedTalentGrantContext ctx;
    ctx.pos = GetTalentSpellPos(spellId);
    if (!ctx.pos)
    {
        LOG_WARN("module", "[ModApocalipse] Skipping non-talent spell {} for guid {} spec {}.",
                 spellId, guid, uint32(specIndex));
        return ManagedTalentGrantResult::Skipped;
    }

    ctx.talentInfo = sTalentStore.LookupEntry(ctx.pos->talent_id);
    if (!ctx.talentInfo)
    {
        LOG_WARN("module", "[ModApocalipse] Missing talent info for guid {} spec {} spell {}.",
                 guid, uint32(specIndex), spellId);
        return ManagedTalentGrantResult::Skipped;
    }

    ctx.talentTabInfo = sTalentTabStore.LookupEntry(ctx.talentInfo->TalentTab);
    if (!ctx.talentTabInfo)
    {
        LOG_WARN("module", "[ModApocalipse] Missing talent tab for guid {} spec {} spell {} talent {}.",
                 guid, uint32(specIndex), spellId, ctx.talentInfo->TalentID);
        return ManagedTalentGrantResult::Skipped;
    }

    if ((player->getClassMask() & ctx.talentTabInfo->ClassMask) == 0)
    {
        LOG_WARN("module", "[ModApocalipse] Talent class mismatch for guid {} spec {} spell {} talent {}.",
                 guid, uint32(specIndex), spellId, ctx.talentInfo->TalentID);
        return ManagedTalentGrantResult::Skipped;
    }

    ctx.spellInfo = sSpellMgr->GetSpellInfo(spellId);
    if (!ctx.spellInfo)
    {
        LOG_WARN("module", "[ModApocalipse] Missing spell info for guid {} spec {} spell {} talent {}.",
                 guid, uint32(specIndex), spellId, ctx.talentInfo->TalentID);
        return ManagedTalentGrantResult::Skipped;
    }

    ctx.currentRank = GetPlayerTalentRank(player, ctx.talentInfo);
    ctx.targetRank = uint8(ctx.pos->rank + 1);

    if (ctx.currentRank >= ctx.targetRank)
    {
        LOG_INFO("module", "[ModApocalipse] Skip talent guid {} spec {} spell {} (current rank {} target {}).",
                 guid, uint32(specIndex), spellId, uint32(ctx.currentRank), uint32(ctx.targetRank));
        return ManagedTalentGrantResult::Skipped;
    }

    ctx.cost = uint32(ctx.targetRank - ctx.currentRank);
    if (ctx.cost == 0)
    {
        LOG_WARN("module", "[ModApocalipse] Invalid cost for guid {} spec {} spell {} (current {} target {}).",
                 guid, uint32(specIndex), spellId, uint32(ctx.currentRank), uint32(ctx.targetRank));
        return ManagedTalentGrantResult::Skipped;
    }

    if (available < ctx.cost)
    {
        LOG_WARN("module", "[ModApocalipse] Hidden budget exceeded for guid {} spec {} (need {}, have {}).",
                 guid, uint32(specIndex), ctx.cost, available);
        return ManagedTalentGrantResult::Stop;
    }

    uint32 freePoints = player->GetFreeTalentPoints();
    if (freePoints < ctx.cost)
    {
        LOG_WARN("module", "[ModApocalipse] Free talent points exhausted for guid {} spec {} (need {}, have {}).",
                 guid, uint32(specIndex), ctx.cost, freePoints);
        return ManagedTalentGrantResult::Stop;
    }

    bool learned = false;

    if (ctx.talentInfo->addToSpellBook)
        if (!ctx.spellInfo->HasAttribute(SPELL_ATTR0_PASSIVE) && !ctx.spellInfo->HasEffect(SPELL_EFFECT_LEARN_SPELL))
        {
            player->learnSpell(spellId);
            learned = true;
        }

    if (!learned)
        player->SendLearnPacket(spellId, true);

    for (uint8 i = 0; i < MAX_SPELL_EFFECTS; ++i)
        if (ctx.spellInfo->Effects[i].Effect == SPELL_EFFECT_LEARN_SPELL)
            if (sSpellMgr->IsAdditionalTalentSpell(ctx.spellInfo->Effects[i].TriggerSpell))
                player->learnSpell(ctx.spellInfo->Effects[i].TriggerSpell);

    if (!player->addTalent(spellId, player->GetActiveSpecMask(), ctx.currentRank))
    {
        if (!player->HasTalent(spellId, player->GetActiveSpec()))
        {
            LOG_WARN("module", "[ModApocalipse] FAILED to apply talent guid {} spec {} spell {} (addTalent returned false).",
                     guid, uint32(specIndex), spellId);
            return ManagedTalentGrantResult::Skipped;
        }
    }

    player->SetFreeTalentPoints(freePoints - ctx.cost);
    available -= ctx.cost;

    LOG_INFO("module", "[ModApocalipse] Granted talent guid {} spec {} spell {} rank {} cost {} remaining {}.",
             guid, uint32(specIndex), spellId, uint32(ctx.pos->rank), ctx.cost, available);

    return ManagedTalentGrantResult::Applied;
}

// ─────────────────────────────────────────────────────────────────────────────
// DB helpers
// ─────────────────────────────────────────────────────────────────────────────

static void LoadSpecSpells()
{
    LOG_INFO("module", "[ModApocalipse] Entering LoadSpecSpells().");

    g_specSpells.clear();

    QueryResult result = WorldDatabase.Query(
        "SELECT `class`, `spec_index`, `spell_id` FROM `mod_spec_spells`");

    if (!result)
    {
        LOG_WARN("module", "[ModApocalipse] mod_spec_spells is empty or missing.");
        return;
    }

    uint32 count = 0;
    do
    {
        Field *f = result->Fetch();
        g_specSpells[f[0].Get<uint8>()][f[1].Get<uint8>()].push_back(f[2].Get<uint32>());
        ++count;
    } while (result->NextRow());

    LOG_INFO("module", "[ModApocalipse] Loaded {} spec spell entries.", count);
}

// Returns the spec index (0/1/2) last granted to this player, or -1 if none.
static int8 GetGrantedSpec(uint32 guid)
{
    QueryResult res = CharacterDatabase.Query(
        "SELECT `granted_spec` FROM `mod_player_spec` WHERE `guid` = {}", guid);
    return res ? res->Fetch()[0].Get<int8>() : -1;
}

// Persists the granted spec for this player.
static void SetGrantedSpec(uint32 guid, int8 specIndex)
{
    CharacterDatabase.Execute(
        "INSERT INTO `mod_player_spec` (`guid`, `granted_spec`) VALUES ({}, {})"
        " ON DUPLICATE KEY UPDATE `granted_spec` = {}",
        guid, (int32)specIndex, (int32)specIndex);
}

static uint8 GetGrantedBudget(uint32 guid, uint8 specIndex)
{
    QueryResult res = CharacterDatabase.Query(
        "SELECT `granted_points` FROM `mod_player_spec_talent_budget` "
        "WHERE `guid` = {} AND `spec_index` = {}",
        guid, uint32(specIndex));

    return res ? res->Fetch()[0].Get<uint8>() : 0;
}

static uint32 GetGrantedBudgetTotal(uint32 guid)
{
    QueryResult res = CharacterDatabase.Query(
        "SELECT COALESCE(SUM(`granted_points`), 0) "
        "FROM `mod_player_spec_talent_budget` WHERE `guid` = {}",
        guid);

    return res ? res->Fetch()[0].Get<uint32>() : 0;
}

static void SyncHiddenBudget(Player *player)
{
    uint32 guid = player->GetGUID().GetCounter();
    uint32 totalBudget = GetGrantedBudgetTotal(guid);

    if (player->GetBonusTalentCount() != totalBudget)
        player->SetBonusTalentCount(totalBudget);

    player->InitTalentForLevel();
}

static void SetGrantedBudget(uint32 guid, uint8 specIndex, uint8 points)
{
    if (points == 0)
    {
        CharacterDatabase.Execute(
            "DELETE FROM `mod_player_spec_talent_budget` "
            "WHERE `guid` = {} AND `spec_index` = {}",
            guid, uint32(specIndex));
        return;
    }

    CharacterDatabase.Execute(
        "INSERT INTO `mod_player_spec_talent_budget` (`guid`, `spec_index`, `granted_points`) "
        "VALUES ({}, {}, {}) ON DUPLICATE KEY UPDATE `granted_points` = {}",
        guid, uint32(specIndex), uint32(points), uint32(points));
}

// Simplified: no database tracking of individual talents.
// We just ensure the budget is granted and let the player keep talents they earned.
// On unlearn, the hidden budget is revoked.

static bool GetTalentTabIndexForClass(uint8 cls, uint32 talentTabId, uint8 &outSpecIndex)
{
    uint32 const *pages = GetTalentTabPages(cls);
    if (!pages)
        return false;

    for (uint8 i = 0; i < MAX_TALENT_TABS; ++i)
    {
        if (pages[i] == talentTabId)
        {
            outSpecIndex = i;
            return true;
        }
    }

    return false;
}

static bool GetSpellTalentSpecIndex(uint8 cls, uint32 spellId, uint8 &outSpecIndex)
{
    TalentSpellPos const *pos = GetTalentSpellPos(spellId);
    if (!pos)
        return false;

    TalentEntry const *talentInfo = sTalentStore.LookupEntry(pos->talent_id);
    if (!talentInfo)
        return false;

    return GetTalentTabIndexForClass(cls, talentInfo->TalentTab, outSpecIndex);
}

static std::vector<uint32> BuildTalentGrantPlan(uint8 cls, uint8 targetSpec, SpellIdSet const &specSpells)
{
    std::vector<uint32> ordered;
    ordered.reserve(specSpells.size());

    for (uint32 spellId : specSpells)
    {
        TalentSpellPos const *pos = GetTalentSpellPos(spellId);
        if (!pos)
            continue;

        uint8 spellSpec = 255;
        if (!GetSpellTalentSpecIndex(cls, spellId, spellSpec))
        {
            LOG_WARN("module", "[ModApocalipse] Could not resolve class/spec for talent spell {} (class {}).",
                     spellId, uint32(cls));
            continue;
        }

        if (spellSpec != targetSpec)
            continue;

        ordered.push_back(spellId);
    }

    // Grant lower ranks first and keep execution deterministic.
    std::sort(ordered.begin(), ordered.end(), [](uint32 a, uint32 b)
              {
                  TalentSpellPos const *aPos = GetTalentSpellPos(a);
                  TalentSpellPos const *bPos = GetTalentSpellPos(b);
                  if (aPos && bPos && aPos->rank != bPos->rank)
                      return aPos->rank < bPos->rank;

                  if (aPos && !bPos)
                      return true;

                  if (!aPos && bPos)
                      return false;

                  return a < b; });

    return ordered;
}

static uint32 EnsureHiddenBudget(Player *player, uint8 specIndex)
{
    uint32 guid = player->GetGUID().GetCounter();
    uint8 currentBudget = GetGrantedBudget(guid, specIndex);
    LOG_INFO("module", "[ModApocalipse] EnsureHiddenBudget guid {} spec {} currentBudget {} target {}.",
             guid, uint32(specIndex), uint32(currentBudget), uint32(HIDDEN_TALENT_BUDGET_PER_SPEC));
    if (currentBudget >= HIDDEN_TALENT_BUDGET_PER_SPEC)
    {
        SyncHiddenBudget(player);
        return currentBudget;
    }

    uint8 toGrant = HIDDEN_TALENT_BUDGET_PER_SPEC - currentBudget;
    player->RewardExtraBonusTalentPoints(toGrant);
    SetGrantedBudget(guid, specIndex, HIDDEN_TALENT_BUDGET_PER_SPEC);
    SyncHiddenBudget(player);

    LOG_INFO("module", "[ModApocalipse] Granted hidden talent budget {} for guid {} spec {}.",
             uint32(toGrant), guid, uint32(specIndex));

    return HIDDEN_TALENT_BUDGET_PER_SPEC;
}

static void RevokeHiddenBudget(Player *player, uint8 specIndex)
{
    uint32 guid = player->GetGUID().GetCounter();
    uint8 grantedBudget = GetGrantedBudget(guid, specIndex);
    if (grantedBudget == 0)
    {
        SyncHiddenBudget(player);
        return;
    }

    uint32 currentBonus = player->GetBonusTalentCount();
    uint32 toRemove = std::min<uint32>(currentBonus, grantedBudget);
    if (toRemove > 0)
        player->RemoveBonusTalent(toRemove);

    SetGrantedBudget(guid, specIndex, 0);
    SyncHiddenBudget(player);

    // LOG_INFO("module", "[ModApocalipse] Revoked hidden talent budget {} for guid {} spec {}.",
    //          toRemove, guid, uint32(specIndex));
}

static void RevokeManagedTalents(Player *player, uint8 specIndex)
{
    uint32 guid = player->GetGUID().GetCounter();
    uint8 cls = player->getClass();
    uint8 activeSpecMask = player->GetActiveSpecMask();

    // LOG_INFO("module", "[ModApocalipse] RevokeManagedTalents guid {} spec {}.",
    //          guid, uint32(specIndex));

    // Remove all configured managed talents for this tree, including passive effects.
    // This guarantees non-dominant signature talents stop working immediately.
    SpellIdSet specSpellSet = GetSpecSpellSet(cls, specIndex);
    for (uint32 spellId : specSpellSet)
    {
        TalentSpellPos const *pos = GetTalentSpellPos(spellId);
        if (!pos)
            continue;

        TalentEntry const *talentInfo = sTalentStore.LookupEntry(pos->talent_id);
        if (!talentInfo)
            continue;

        uint8 currentRank = GetPlayerTalentRank(player, talentInfo);
        if (currentRank == 0)
            continue;

        for (uint8 rank = 0; rank < MAX_TALENT_RANK; ++rank)
        {
            uint32 rankSpell = talentInfo->RankID[rank];
            if (!rankSpell)
                continue;

            if (!player->HasTalent(rankSpell, player->GetActiveSpec()))
                continue;

            player->_removeTalent(rankSpell, activeSpecMask);
            player->_removeTalentAurasAndSpells(rankSpell);
            player->removeSpell(rankSpell, SPEC_MASK_ALL, true);
            player->SendLearnPacket(rankSpell, false);

            // LOG_INFO("module", "[ModApocalipse] Revoked managed talent guid {} spec {} spell {}.",
            //          guid, uint32(specIndex), rankSpell);
        }
    }
}

static void GrantManagedTalents(Player *player, uint8 specIndex, SpellIdSet const &specSpells)
{
    uint32 guid = player->GetGUID().GetCounter();
    std::vector<uint32> plan = BuildTalentGrantPlan(player->getClass(), specIndex, specSpells);

    // LOG_INFO("module", "[ModApocalipse] GrantManagedTalents guid {} spec {} planSize {}.",
    //          guid, uint32(specIndex), plan.size());

    if (plan.empty())
        return;

    uint32 available = EnsureHiddenBudget(player, specIndex);

    // Grant talents in order of rank (lower ranks first), but skip if already learned
    for (uint32 spellId : plan)
    {
        ManagedTalentGrantResult grantResult = GrantManagedTalent(player, specIndex, spellId, available);
        if (grantResult == ManagedTalentGrantResult::Stop)
        {
            break;
        }
    }
}

static void EnsureSpecLayer(Player *player, uint8 specIndex, SpellIdSet const &specSpells)
{
    // LOG_INFO("module", "[ModApocalipse] EnsureSpecLayer guid {} spec {} spellCount {}.",
    //          player->GetGUID().GetCounter(), uint32(specIndex), specSpells.size());
    GrantManagedTalents(player, specIndex, specSpells);

    for (uint32 spellId : specSpells)
    {
        if (GetTalentSpellPos(spellId))
            continue;

        if (!player->HasSpell(spellId))
            player->learnSpell(spellId);
    }
}

static void RemoveSpecLayer(Player *player, uint8 cls, uint8 specIndex, SpellIdSet const &dominantSet)
{
    SpellIdSet specSpellSet = GetSpecSpellSet(cls, specIndex);
    for (uint32 spellId : specSpellSet)
    {
        if (dominantSet.count(spellId))
            continue;

        if (player->HasSpell(spellId))
            player->removeSpell(spellId, SPEC_MASK_ALL, false);
    }

    RevokeHiddenBudget(player, specIndex);
}

// ─────────────────────────────────────────────────────────────────────────────
// Spec detection
// ─────────────────────────────────────────────────────────────────────────────

// Returns 0/1/2 for the dominant talent tree, or 255 if no tree meets the
// minimum threshold.
// When multiple specs have equal points, prefers the currently granted spec
// to prevent oscillation.
static uint8 GetDominantSpec(Player *player, int8 currentSpec = -1)
{
    uint8 specPoints[3] = {0, 0, 0};
    player->GetTalentTreePoints(specPoints);

    uint8 dominant = 255;
    uint32 maxPoints = 0;

    // First pass: find max points
    for (uint8 i = 0; i < 3; ++i)
    {
        if (specPoints[i] >= MIN_POINTS_FOR_SPEC && specPoints[i] > maxPoints)
        {
            maxPoints = specPoints[i];
            dominant = i;
        }
    }

    // Tiebreaker: if current spec has max points, stick with it to prevent oscillation
    if (currentSpec >= 0 && currentSpec < 3 && specPoints[currentSpec] == maxPoints &&
        specPoints[currentSpec] >= MIN_POINTS_FOR_SPEC)
    {
        dominant = currentSpec;
    }

    if (dominant != 255)
    {
        // LOG_INFO("module", "[ModApocalipse] GetDominantSpec: [{}] [{}] [{}] -> spec {} (current {}).",
        //          uint32(specPoints[0]), uint32(specPoints[1]), uint32(specPoints[2]),
        //          uint32(dominant), int32(currentSpec));
    }

    return dominant;
}

// ─────────────────────────────────────────────────────────────────────────────
// Spec grant / revoke
// ─────────────────────────────────────────────────────────────────────────────

static void GrantSpec(Player *player, uint8 newSpec)
{
    uint8 cls = player->getClass();
    int8 oldSpec = GetGrantedSpec(player->GetGUID().GetCounter());
    // LOG_INFO("module", "[ModApocalipse] GrantSpec guid {} class {} oldSpec {} newSpec {}.",
    //          player->GetGUID().GetCounter(), uint32(cls), int32(oldSpec), uint32(newSpec));

    SpellIdSet newSpellSet = GetSpecSpellSet(cls, newSpec);

    // Strict transition: remove managed layers for every non-dominant tree first.
    for (uint8 spec = 0; spec < MAX_TALENT_TABS; ++spec)
    {
        if (spec == newSpec)
            continue;

        RevokeManagedTalents(player, spec);
        RemoveSpecLayer(player, cls, spec, newSpellSet);
    }

    EnsureSpecLayer(player, newSpec, newSpellSet);

    SetGrantedSpec(player->GetGUID().GetCounter(), (int8)newSpec);
    player->SendTalentsInfoData(false);

    // Notify player.
    std::string specName = "Unknown";
    if (g_specNames.count(cls) && newSpec < (uint8)g_specNames.at(cls).size())
        specName = g_specNames.at(cls)[newSpec];

    if (!IsBotSession(player))
    {
        ChatHandler(player->GetSession()).SendSysMessage(("|cff00ff00[Spec Manager]|r Especialização setada para: |cffffcc00" + specName + "|r. "
                                                                                                                                           "Suas habilidades assinatura foram atualizadas, confira seu Spellbook.")
                                                             .c_str());
    }
}

// Single synchronous reconciliation entrypoint.
static void ReconcileSpecFromTalentPoints(Player *player)
{
    if (!HasValidSpecManagerSession(player))
        return;

    uint32 guid = player->GetGUID().GetCounter();
    // LOG_INFO("module", "[ModApocalipse] ReconcileSpecFromTalentPoints enter guid {}.", guid);
    SyncHiddenBudget(player);

    {
        std::lock_guard<std::mutex> guard(g_specUpdateMutex);
        if (g_reconcileInProgress.count(guid))
            return;

        g_reconcileInProgress.insert(guid);
    }

    struct ScopedReconcileCleanup
    {
        explicit ScopedReconcileCleanup(uint32 pGuid) : guid(pGuid) {}
        ~ScopedReconcileCleanup()
        {
            std::lock_guard<std::mutex> guard(g_specUpdateMutex);
            g_reconcileInProgress.erase(guid);
        }

        uint32 guid;
    } cleanup(guid);

    uint8 cls = player->getClass();
    int8 current = GetGrantedSpec(guid);
    uint8 dominant = GetDominantSpec(player, current);
    // LOG_INFO("module", "[ModApocalipse] Spec state guid {} class {} dominant {} current {}.",
    //          guid, uint32(cls), uint32(dominant), int32(current));

    if (dominant == 255)
    {
        if (current < 0)
        {
            // LOG_INFO("module", "[ModApocalipse] No dominant spec for guid {} and no granted spec to clear.", guid);
            return;
        }

        auto clsIt = g_specSpells.find(cls);
        if (clsIt != g_specSpells.end())
        {
            auto specIt = clsIt->second.find((uint8)current);
            if (specIt != clsIt->second.end())
                for (uint32 spellId : specIt->second)
                    if (player->HasSpell(spellId))
                        player->removeSpell(spellId, SPEC_MASK_ALL, false);
        }

        for (uint8 i = 0; i < 3; ++i)
        {
            RevokeManagedTalents(player, i);
            RevokeHiddenBudget(player, i);
        }

        SetGrantedSpec(guid, -1);
        // LOG_INFO("module", "[ModApocalipse] Cleared granted spec state for guid {} (no dominant spec).", guid);
    }
    else if (current != (int8)dominant)
    {
        GrantSpec(player, dominant);
    }
    else
    {
        EnsureSpecLayer(player, dominant, GetSpecSpellSet(cls, dominant));
    }

    // Module-driven mutations can happen outside normal talent opcodes (e.g. login, gossip).
    // Always send a full talents payload so the client talent UI stays in sync.
    player->SendTalentsInfoData(false);
}

// ─────────────────────────────────────────────────────────────────────────────
// NPC Script
// ─────────────────────────────────────────────────────────────────────────────

class ModSpecNPC : public CreatureScript
{
public:
    ModSpecNPC() : CreatureScript("ModSpecNPC") {}

    bool OnGossipHello(Player *player, Creature *creature) override
    {
        if (!creature || creature->GetEntry() != NPC_SPEC_SELECTOR)
            return false;

        ClearGossipMenuFor(player);
        AddGossipItemFor(player, GOSSIP_ICON_TRAINER, "Choose my specialization.", GOSSIP_SENDER_MAIN, 0);
        AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Refresh my current spec spells.", GOSSIP_SENDER_MAIN, 10);
        SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, creature->GetGUID());
        return true;
    }

    bool OnGossipSelect(Player *player, Creature *creature, uint32 /*sender*/, uint32 action) override
    {
        if (!creature || creature->GetEntry() != NPC_SPEC_SELECTOR)
            return false;

        uint8 cls = player->getClass();

        // ── Show spec list ───────────────────────────────────────────────────
        if (action == 0)
        {
            ClearGossipMenuFor(player);
            auto nameIt = g_specNames.find(cls);
            if (nameIt != g_specNames.end())
            {
                for (uint8 i = 0; i < (uint8)nameIt->second.size(); ++i)
                    AddGossipItemFor(player, GOSSIP_ICON_TRAINER,
                                     nameIt->second[i].c_str(), GOSSIP_SENDER_MAIN, 100 + i);
            }
            AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Never mind.", GOSSIP_SENDER_MAIN, 99);
            SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, creature->GetGUID());
            return true;
        }

        // ── Refresh current spec ─────────────────────────────────────────────
        if (action == 10)
        {
            int8 current = GetGrantedSpec(player->GetGUID().GetCounter());
            if (current < 0)
            {
                ChatHandler(player->GetSession()).PSendSysMessage("|cff00ff00[Spec Manager]|r You haven't chosen a specialization yet.");
            }
            else
            {
                // Force re-grant by clearing stored spec first.
                SetGrantedSpec(player->GetGUID().GetCounter(), -1);
                GrantSpec(player, (uint8)current);
            }
            CloseGossipMenuFor(player);
            return true;
        }

        // ── Spec selected (actions 100, 101, 102) ───────────────────────────
        if (action >= 100 && action <= 102)
        {
            GrantSpec(player, (uint8)(action - 100));
            CloseGossipMenuFor(player);
            return true;
        }

        // ── Cancel ──────────────────────────────────────────────────────────
        CloseGossipMenuFor(player);
        return true;
    }
};

// ─────────────────────────────────────────────────────────────────────────────
// Player Script
// ─────────────────────────────────────────────────────────────────────────────

class ModSpecPlayer : public PlayerScript
{
public:
    ModSpecPlayer() : PlayerScript("ModSpecPlayer") {}

    void OnPlayerLogin(Player *player) override
    {
        if (!HasValidSpecManagerSession(player))
            return;

        // LOG_INFO("module", "[ModApocalipse] OnPlayerLogin guid {}.", player->GetGUID().GetCounter());
        ReconcileSpecFromTalentPoints(player);
    }

    // Fires after each individual talent point is spent - catches spec changes
    // in real time, including dual spec swaps (which replay talent learns).
    void OnPlayerLearnTalents(Player *player, uint32 talentId, uint32 talentRank, uint32 spellId) override
    {
        if (!HasValidSpecManagerSession(player))
            return;

        // LOG_INFO("module", "[ModApocalipse] OnPlayerLearnTalents guid {} talentId {} talentRank {} spellId {}.",
        //          player->GetGUID().GetCounter(), talentId, talentRank, spellId);
        ReconcileSpecFromTalentPoints(player);
    }

    // Fires when the player fully resets all talents (paid respec or GM command).
    // Strip spec spells so the player must re-earn them by spending points.
    void OnPlayerTalentsReset(Player *player, bool /*noCost*/) override
    {
        if (!HasValidSpecManagerSession(player))
            return;

        uint32 guid = player->GetGUID().GetCounter();

        // Guard against rapid re-entry: prevent this hook from running more than once per second per player
        {
            std::lock_guard<std::mutex> guard(g_specUpdateMutex);
            auto lastResetIt = g_lastTalentsResetMs.find(guid);
            if (lastResetIt != g_lastTalentsResetMs.end())
            {
                uint64 timeSinceLast = GetNowMs() - lastResetIt->second;
                if (timeSinceLast < TALENTS_RESET_MIN_INTERVAL_MS)
                {
                    LOG_WARN("module", "[ModApocalipse] OnPlayerTalentsReset throttled for guid {} (called {} ms after last).",
                             guid, uint32(timeSinceLast));
                    return;
                }
            }
            g_lastTalentsResetMs[guid] = GetNowMs();
        }

        uint8 cls = player->getClass();
        int8 granted = GetGrantedSpec(guid);
        if (granted < 0)
        {
            for (uint8 i = 0; i < 3; ++i)
            {
                RevokeManagedTalents(player, i);
                RevokeHiddenBudget(player, i);
            }
            return;
        }

        auto clsIt = g_specSpells.find(cls);
        if (clsIt != g_specSpells.end())
        {
            auto specIt = clsIt->second.find((uint8)granted);
            if (specIt != clsIt->second.end())
                for (uint32 spellId : specIt->second)
                    if (player->HasSpell(spellId))
                        player->removeSpell(spellId, SPEC_MASK_ALL, false);
        }

        for (uint8 i = 0; i < 3; ++i)
        {
            RevokeManagedTalents(player, i);
            RevokeHiddenBudget(player, i);
        }

        SetGrantedSpec(guid, -1);
        if (!IsBotSession(player))
        {
            ChatHandler(player->GetSession()).PSendSysMessage("|cff00ff00[Spec Manager]|r Seus talentos foram resetados. "
                                                              "Gaste pontos em uma árvore de talentos para ganhar suas habilidades assinatura.");
        }
    }
};

// ─────────────────────────────────────────────────────────────────────────────
// World Script - loads spell data on server startup
// ─────────────────────────────────────────────────────────────────────────────

class ModApocalipseWorld : public WorldScript
{
public:
    ModApocalipseWorld() : WorldScript("ModApocalipseWorld") {}

    void OnLoadCustomDatabaseTable() override
    {
        LOG_INFO("module", "[ModApocalipse] Loading spec spells from custom database table hook.");
        LoadSpecSpells();
    }

    void OnStartup() override
    {
        // LOG_INFO("module", "[ModApocalipse] World OnStartup completed.");
    }
};

// ─────────────────────────────────────────────────────────────────────────────
// Registration
// ─────────────────────────────────────────────────────────────────────────────

void AddModApocalipseScripts()
{
    LOG_INFO("module", "[ModApocalipse] Registering scripts.");

    new ModSpecNPC();
    new ModSpecPlayer();
    new ModApocalipseWorld();
}

/*
 * mod_apocalipse_pvp.cpp
 *
 * PvP Damage Balancing for Apocalipse WoW.
 *
 * Behaviour:
 *   1. Fixed % damage reduction applied to ALL player-vs-player damage
 *      (including player-owned pets attacking players), at every level.
 *
 *   2. Level-bracket resilience floor (levels 10–79 only):
 *      Each 10-level bracket has a configurable target resilience %.
 *      If the victim's current resilience is below that target, an extra
 *      damage reduction is applied to simulate the missing resilience.
 *      Players already at or above the target receive no additional bonus.
 *      Level 80+ players are NOT subject to the bracket bonus (they are
 *      expected to gear for resilience themselves).
 *
 * Both layers stack: a level-79 player with 0 resilience receives the
 * fixed % reduction AND the full bracket bonus.
 *
 * All values are configured in worldserver.conf:
 *
 *   Apocalipse.PvPDamageReductionPct     = 15.0   (applies to all levels)
 *   Apocalipse.PvPBracketResilience.1019 = 8.0
 *   Apocalipse.PvPBracketResilience.2029 = 10.0
 *   Apocalipse.PvPBracketResilience.3039 = 12.0
 *   Apocalipse.PvPBracketResilience.4049 = 14.0
 *   Apocalipse.PvPBracketResilience.5059 = 16.0
 *   Apocalipse.PvPBracketResilience.6069 = 18.0
 *   Apocalipse.PvPBracketResilience.7079 = 20.0
 */

#include "ScriptMgr.h"
#include "Player.h"
#include "Unit.h"
#include "Config.h"
#include "Log.h"
#include "SpellInfo.h"

// ─────────────────────────────────────────────────────────────────────────────
// Config globals (loaded at world startup)
// ─────────────────────────────────────────────────────────────────────────────

// Fixed % reduction applied to ALL PvP damage regardless of level.
static float g_pvpDmgReductionPct = 15.0f;

// Target resilience % floor per bracket index 0–6 (brackets 10-19 through 70-79).
// Index maps as: 0=10-19, 1=20-29, 2=30-39, 3=40-49, 4=50-59, 5=60-69, 6=70-79.
static float g_bracketTarget[7] = {8.0f, 10.0f, 12.0f, 14.0f, 16.0f, 18.0f, 20.0f};

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

// Returns the configured resilience % target for the bracket that contains
// the given player level. Returns 0.0f for levels outside 10–79.
static float GetBracketTargetPct(uint8 level)
{
    if (level < 10 || level >= 80)
        return 0.0f;

    // Integer division gives bracket index: (10-19)/10 = 1, subtract 1 → 0.
    uint8 index = (level / 10) - 1;

    // Clamp to array bounds (level 10–79 → indices 0–6).
    if (index >= 7)
        return 0.0f;

    return g_bracketTarget[index];
}

// Returns true if the unit is a player or is a pet/guardian whose owner is
// a player. This is used to detect the attacking side of a PvP interaction
// so that player-owned pet attacks are also subject to PvP modifiers.
static bool IsPlayerOrPlayerOwnedUnit(Unit *unit)
{
    if (!unit)
        return false;
    if (unit->IsPlayer())
        return true;
    return unit->GetCharmerOrOwnerPlayerOrPlayerItself() != nullptr;
}

// Core reduction logic shared by all three damage hooks.
// Applies the fixed PvP reduction and, where eligible, the bracket bonus.
static void ApplyPvPModifiers(Unit *victim, Unit *attacker, uint32 &damage)
{
    if (damage == 0)
        return;

    // Both sides must resolve to a player (or player-owned unit).
    if (!IsPlayerOrPlayerOwnedUnit(attacker) || !victim || !victim->IsPlayer())
        return;

    // ── Step 1: Fixed % reduction (all levels, including 80) ──────────────
    damage = uint32(damage * (1.0f - g_pvpDmgReductionPct / 100.0f));

    // ── Step 2: Bracket resilience bonus (levels 10–79 only) ──────────────
    float targetResil = GetBracketTargetPct(victim->GetLevel());
    if (targetResil <= 0.0f)
        return;

    // GetMeleeCritChanceReduction returns the resilience as a percentage value
    // (e.g. 5.2 means 5.2% reduction). It is the public wrapper around the
    // private GetCombatRatingReduction(CR_CRIT_TAKEN_MELEE).
    float currentResil = victim->GetMeleeCritChanceReduction();

    if (currentResil >= targetResil)
        return; // Victim already meets or exceeds the bracket floor.

    float bonusPct = targetResil - currentResil;
    damage = uint32(damage * (1.0f - bonusPct / 100.0f));
}

// ─────────────────────────────────────────────────────────────────────────────
// UnitScript
// ─────────────────────────────────────────────────────────────────────────────

class ModPvPUnitScript : public UnitScript
{
public:
    ModPvPUnitScript() : UnitScript("ModPvPUnitScript") {}

    // Auto-attack and weapon swings.
    void ModifyMeleeDamage(Unit *target, Unit *attacker, uint32 &damage) override
    {
        ApplyPvPModifiers(target, attacker, damage);
    }

    // Direct spell hits (nukes, burst, etc.).
    void ModifySpellDamageTaken(Unit *target, Unit *attacker, int32 &damage, SpellInfo const * /*spellInfo*/) override
    {
        if (damage <= 0)
            return;

        uint32 dmg = static_cast<uint32>(damage);
        ApplyPvPModifiers(target, attacker, dmg);
        damage = static_cast<int32>(dmg);
    }

    // DoT / periodic aura ticks. Attacker may be nullptr if despawned.
    void ModifyPeriodicDamageAurasTick(Unit *target, Unit *attacker, uint32 &damage, SpellInfo const * /*spellInfo*/) override
    {
        if (!attacker)
            return;

        ApplyPvPModifiers(target, attacker, damage);
    }
};

// ─────────────────────────────────────────────────────────────────────────────
// WorldScript - loads config values on server startup
// ─────────────────────────────────────────────────────────────────────────────

class ModApocalipsePvPWorld : public WorldScript
{
public:
    ModApocalipsePvPWorld() : WorldScript("ModApocalipsePvPWorld") {}

    void OnStartup() override
    {
        LoadConfig();
    }

    void OnAfterConfigLoad(bool /*reload*/) override
    {
        LoadConfig();
    }

private:
    static void LoadConfig()
    {
        g_pvpDmgReductionPct = sConfigMgr->GetOption<float>("Apocalipse.PvPDamageReductionPct", 15.0f);

        g_bracketTarget[0] = sConfigMgr->GetOption<float>("Apocalipse.PvPBracketResilience.1019", 8.0f);
        g_bracketTarget[1] = sConfigMgr->GetOption<float>("Apocalipse.PvPBracketResilience.2029", 10.0f);
        g_bracketTarget[2] = sConfigMgr->GetOption<float>("Apocalipse.PvPBracketResilience.3039", 12.0f);
        g_bracketTarget[3] = sConfigMgr->GetOption<float>("Apocalipse.PvPBracketResilience.4049", 14.0f);
        g_bracketTarget[4] = sConfigMgr->GetOption<float>("Apocalipse.PvPBracketResilience.5059", 16.0f);
        g_bracketTarget[5] = sConfigMgr->GetOption<float>("Apocalipse.PvPBracketResilience.6069", 18.0f);
        g_bracketTarget[6] = sConfigMgr->GetOption<float>("Apocalipse.PvPBracketResilience.7079", 20.0f);

        LOG_INFO("module", "[ModApocalipsePvP] PvP damage reduction: {:.1f}%", g_pvpDmgReductionPct);
        LOG_INFO("module", "[ModApocalipsePvP] Bracket resilience targets (%%): "
                           "10-19={:.1f}  20-29={:.1f}  30-39={:.1f}  40-49={:.1f}  "
                           "50-59={:.1f}  60-69={:.1f}  70-79={:.1f}",
                 g_bracketTarget[0], g_bracketTarget[1], g_bracketTarget[2],
                 g_bracketTarget[3], g_bracketTarget[4], g_bracketTarget[5],
                 g_bracketTarget[6]);
    }
};

// ─────────────────────────────────────────────────────────────────────────────
// Registration
// ─────────────────────────────────────────────────────────────────────────────

void AddModApocalipsePvPScripts()
{
    new ModPvPUnitScript();
    new ModApocalipsePvPWorld();
}

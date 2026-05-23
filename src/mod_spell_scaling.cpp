/*
 * mod_spell_scaling.cpp
 *
 * Level-proportional scaling for spells granted to low-level players.
 *
 * Which spells are scaled is fully data-driven: add or remove rows in
 * `mod_spell_scaling` (acore_world) and restart the worldserver.
 *
 * Multiplier formula:
 *   m = min((casterLevel / 80.0) * scaleFactor, 1.0)
 *
 * Examples at scale_factor = 1.0:
 *   level 10 -> m = 0.125  (12.5% of max power)
 *   level 40 -> m = 0.500  (50%  of max power)
 *   level 60 -> m = 0.750  (75%  of max power)
 *   level 80 -> m = 1.000  (100% - no reduction)
 *
 * Only player casters are affected; NPCs always use m = 1.0.
 *
 * Four scale types, each handled by a separate hook:
 *   DAMAGE   - ModifySpellDamageTaken    (direct spell hits)
 *   HEAL     - ModifyHealReceived        (direct heals)
 *   PERIODIC - ModifyPeriodicDamageAurasTick  (DoT/HoT ticks)
 *   ABSORB   - OnAuraApply              (absorb shields, set once at aura apply)
 */

#include "ScriptMgr.h"
#include "Player.h"
#include "Unit.h"
#include "DatabaseEnv.h"
#include "Log.h"
#include "SpellInfo.h"
#include "SpellAuraEffects.h"

#include <algorithm>
#include <string>
#include <unordered_map>

// ─────────────────────────────────────────────────────────────────────────────
// In-memory spell cache
// Populated once at startup from `mod_spell_scaling` (acore_world).
// ─────────────────────────────────────────────────────────────────────────────

static std::unordered_map<uint32, float> gDamageSpells;
static std::unordered_map<uint32, float> gHealSpells;
static std::unordered_map<uint32, float> gPeriodicSpells;
static std::unordered_map<uint32, float> gAbsorbSpells;

// ─────────────────────────────────────────────────────────────────────────────
// DB loader
// ─────────────────────────────────────────────────────────────────────────────

static void LoadScalingSpells()
{
    gDamageSpells.clear();
    gHealSpells.clear();
    gPeriodicSpells.clear();
    gAbsorbSpells.clear();

    QueryResult result = WorldDatabase.Query(
        "SELECT `spell_id`, `scale_type`, `scale_factor` FROM `mod_spell_scaling`");

    if (!result)
    {
        LOG_WARN("module", "[ModSpellScaling] mod_spell_scaling is empty or missing.");
        return;
    }

    uint32 count = 0;
    do
    {
        Field *f = result->Fetch();
        uint32 spellId = f[0].Get<uint32>();
        std::string type = f[1].Get<std::string>();
        float scaleFactor = f[2].Get<float>();

        if (type == "DAMAGE")
            gDamageSpells[spellId] = scaleFactor;
        else if (type == "HEAL")
            gHealSpells[spellId] = scaleFactor;
        else if (type == "PERIODIC")
            gPeriodicSpells[spellId] = scaleFactor;
        else if (type == "ABSORB")
            gAbsorbSpells[spellId] = scaleFactor;

        ++count;
    } while (result->NextRow());

    LOG_INFO("module", "[ModSpellScaling] Loaded {} spell scaling entries.", count);
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: compute (level / 80) * scaleFactor for a player caster.
// Returns 1.0f if the unit is null, not a player, or already level 80+.
// ─────────────────────────────────────────────────────────────────────────────

static float GetLevelMultiplier(Unit const *caster, float scaleFactor)
{
    if (!caster || !caster->IsPlayer())
        return 1.0f;

    uint8 level = caster->GetLevel();
    if (level >= 80)
        return 1.0f;

    float ratio = static_cast<float>(level) / 80.0f;
    return std::min(ratio * scaleFactor, 1.0f);
}

// ─────────────────────────────────────────────────────────────────────────────
// WorldScript: populate the caches after the world DB is ready
// ─────────────────────────────────────────────────────────────────────────────

class SpellScalingWorld : public WorldScript
{
public:
    SpellScalingWorld() : WorldScript("SpellScalingWorld") {}

    void OnLoadCustomDatabaseTable() override
    {
        LoadScalingSpells();
    }
};

// ─────────────────────────────────────────────────────────────────────────────
// UnitScript: intercept final damage / heal / periodic / absorb values
// ─────────────────────────────────────────────────────────────────────────────

class SpellScalingUnit : public UnitScript
{
public:
    SpellScalingUnit() : UnitScript("SpellScalingUnit") {}

    // ── Direct spell damage ──────────────────────────────────────────────────
    void ModifySpellDamageTaken(Unit * /*target*/, Unit *attacker,
                                int32 &damage, SpellInfo const *spellInfo) override
    {
        if (!spellInfo || damage <= 0)
            return;

        auto it = gDamageSpells.find(spellInfo->Id);
        if (it == gDamageSpells.end())
            return;

        float m = GetLevelMultiplier(attacker, it->second);
        if (m < 1.0f)
            damage = static_cast<int32>(damage * m);
    }

    // ── Direct healing ───────────────────────────────────────────────────────
    void ModifyHealReceived(Unit * /*target*/, Unit *healer,
                            uint32 &heal, SpellInfo const *spellInfo) override
    {
        if (!spellInfo || heal == 0)
            return;

        auto it = gHealSpells.find(spellInfo->Id);
        if (it == gHealSpells.end())
            return;

        float m = GetLevelMultiplier(healer, it->second);
        if (m < 1.0f)
            heal = static_cast<uint32>(heal * m);
    }

    // ── Periodic damage ticks (DoTs) ─────────────────────────────────────────
    // Note: attacker can be nullptr if the caster despawned while the aura
    //       still ticks on the target.  Guard before dereferencing.
    void ModifyPeriodicDamageAurasTick(Unit * /*target*/, Unit *attacker,
                                       uint32 &damage,
                                       SpellInfo const *spellInfo) override
    {
        if (!spellInfo || !attacker || damage == 0)
            return;

        auto it = gPeriodicSpells.find(spellInfo->Id);
        if (it == gPeriodicSpells.end())
            return;

        float m = GetLevelMultiplier(attacker, it->second);
        if (m < 1.0f)
            damage = static_cast<uint32>(damage * m);
    }

    // ── Absorb shields (e.g. Ice Barrier) ───────────────────────────────────
    // Fires after DoEffectCalcAmount, so the absorb amount already includes
    // any spell-power bonus added by the core AuraScript.  We scale the final
    // value once so it reflects the caster's current level.
    void OnAuraApply(Unit * /*unit*/, Aura *aura) override
    {
        if (!aura)
            return;

        auto it = gAbsorbSpells.find(aura->GetId());
        if (it == gAbsorbSpells.end())
            return;

        Unit *caster = aura->GetCaster();
        float m = GetLevelMultiplier(caster, it->second);
        if (m >= 1.0f)
            return;

        for (uint8 i = 0; i < MAX_SPELL_EFFECTS; ++i)
        {
            AuraEffect *aurEff = aura->GetEffect(i);
            if (!aurEff)
                continue;

            AuraType type = aurEff->GetAuraType();
            if (type != SPELL_AURA_SCHOOL_ABSORB && type != SPELL_AURA_MANA_SHIELD)
                continue;

            // Always recalculate from the base so that a refresh (recast while
            // active) doesn't apply the multiplier a second time on an already-
            // scaled value.  SetAmount is intentionally avoided here: it would
            // set m_canBeRecalculated = false and lock out future recalculations.
            int32 baseValue = aurEff->CalculateAmount(caster);
            if (baseValue > 0)
                aurEff->ChangeAmount(static_cast<int32>(baseValue * m));
        }
    }
};

// ─────────────────────────────────────────────────────────────────────────────
// Registration – called from mod_apocalipse_loader.cpp
// ─────────────────────────────────────────────────────────────────────────────

void AddModSpellScalingScripts()
{
    new SpellScalingWorld();
    new SpellScalingUnit();
}

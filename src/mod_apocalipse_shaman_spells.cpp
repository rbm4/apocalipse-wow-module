#include "Define.h"
#include "CellImpl.h"
#include "Containers.h"
#include "GridNotifiers.h"
#include "GridNotifiersImpl.h"
#include "ObjectAccessor.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "Spell.h"
#include "SpellAuras.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

#include <algorithm>
#include <list>
#include <map>
#include <mutex>
#include <set>
#include <vector>

namespace
{
enum ApocalipseShamanSpells
{
    SPELL_APOC_SHAMAN_MOLTEN_ANCHORS = 901091,
    SPELL_APOC_SHAMAN_WILDFIRE_CONTAGION = 901092,
    SPELL_APOC_SHAMAN_TRIPLE_CONVERGENCE = 901093,
    SPELL_APOC_SHAMAN_ASCENSION = 901094,
    SPELL_APOC_SHAMAN_ASCENSION_MARKER = 901095,
    SPELL_APOC_SHAMAN_ECHOING_MAGMA = 901096,
    SPELL_APOC_SHAMAN_ECHOING_MAGMA_DAMAGE = 901097,
    SPELL_APOC_SHAMAN_TRIFOLD_BULWARK = 901098,
    SPELL_APOC_SHAMAN_MOLTEN_AEGIS = 901099,
    SPELL_APOC_SHAMAN_TIDEBOUND_AEGIS = 901100,
    SPELL_APOC_SHAMAN_STONEHIDE_AEGIS = 901101,
    SPELL_APOC_SHAMAN_EARTHEN_DEFIANCE = 901102,
    SPELL_APOC_SHAMAN_EARTHEN_DEFIANCE_STACK = 901103,
    SPELL_APOC_SHAMAN_RIPTIDE_RESONANCE = 901104,
    SPELL_APOC_SHAMAN_OVERFLOWING_TIDES = 901105,
    SPELL_APOC_SHAMAN_OVERFLOWING_TIDES_ABSORB = 901106,
    SPELL_APOC_SHAMAN_TIDAL_ECHO = 901107,
    SPELL_APOC_SHAMAN_TIDAL_ECHO_HEAL = 901108,
    SPELL_APOC_SHAMAN_DEEP_CURRENTS = 901109,
    SPELL_APOC_SHAMAN_DEEP_CURRENTS_BUFF = 901110,
    SPELL_APOC_SHAMAN_SPIRIT_LINK_CONDUIT = 901111,
    SPELL_APOC_SHAMAN_EARTHEN_CALL = 901112,
    SPELL_APOC_SHAMAN_ALPHAS_CALL = 901113,
    SPELL_APOC_SHAMAN_TIDAL_CALL = 901114,
    SPELL_APOC_SHAMAN_STONEGUARD_BULWARK = 901115,
    SPELL_APOC_SHAMAN_STORM_UNLEASHED = 901116,
    SPELL_APOC_SHAMAN_STORM_UNLEASHED_DAMAGE = 901117,
    SPELL_SHAMAN_LIGHTNING_SHIELD_R1 = 324,
    SPELL_SHAMAN_LIGHTNING_SHIELD_DAMAGE_R1 = 26364,
    SPELL_SHAMAN_WATER_SHIELD_R1 = 52127,
    SPELL_SHAMAN_EARTH_SHIELD_R1 = 974,
    SPELL_SHAMAN_EARTH_SHIELD_HEAL = 379,
    SPELL_SHAMAN_GLYPH_OF_EARTH_SHIELD = 63279,
    SPELL_SHAMAN_FLAME_SHOCK_R1 = 8050,
    SPELL_SHAMAN_CHAIN_HEAL_R1 = 1064,
    SPELL_SHAMAN_LAVA_BURST_R1 = 51505,
    SPELL_SHAMAN_RIPTIDE_R1 = 61295
};

constexpr float SPREAD_RADIUS = 10.0f;
constexpr float TIDAL_ECHO_RADIUS = 15.0f;
constexpr uint32 WILDFIRE_CHANCE = 20;
constexpr uint32 RIPTIDE_CHANCE = 20;
constexpr uint32 ECHO_DAMAGE_PCT = 50;
constexpr uint32 OVERHEAL_ABSORB_PCT = 50;
constexpr uint32 OVERHEAL_CAP_PCT = 10;
constexpr uint32 STORM_DAMAGE_PCT = 20;
constexpr uint32 CONDUIT_HEAL_PCT = 5;
constexpr uint32 CONDUIT_ICD_MS = 30000;
constexpr uint32 STORM_ICD_MS = 500;
constexpr uint32 EARTH_SHIELD_ICD_MS = 3500;

std::map<ObjectGuid, std::set<ObjectGuid>> FlameShockTargets;
std::mutex FlameShockTargetsMutex;

uint32 GetRankForLevel(Unit const* caster, uint32 firstRank)
{
    if (!caster)
        return 0;

    uint32 selected = 0;
    for (uint32 spellId = sSpellMgr->GetFirstSpellInChain(firstRank); spellId;
        spellId = sSpellMgr->GetNextSpellInChain(spellId))
    {
        SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(spellId);
        if (!spellInfo || spellInfo->SpellLevel > caster->GetLevel())
            break;
        selected = spellId;
    }
    return selected ? selected : sSpellMgr->GetFirstSpellInChain(firstRank);
}

uint32 GetHighestKnownRank(Player const* player, uint32 firstRank)
{
    uint32 selected = 0;
    if (!player)
        return selected;

    for (uint32 spellId = sSpellMgr->GetFirstSpellInChain(firstRank); spellId;
        spellId = sSpellMgr->GetNextSpellInChain(spellId))
        if (player->HasSpell(spellId))
            selected = spellId;
    return selected;
}

std::list<Unit*> GetNearbyEnemies(Unit* center, Unit* caster, float radius)
{
    std::list<Unit*> targets;
    Acore::AnyUnfriendlyUnitInObjectRangeCheck check(center, caster, radius);
    Acore::UnitListSearcher<Acore::AnyUnfriendlyUnitInObjectRangeCheck> searcher(
        center, targets, check);
    Cell::VisitObjects(center, searcher, radius);
    targets.remove_if([center, caster, radius](Unit* target)
    {
        return !target || target == center || !target->IsAlive() ||
            !target->IsInWorld() || !caster->IsInMap(target) ||
            !center->IsWithinDistInMap(target, radius) ||
            !caster->IsWithinLOSInMap(target) ||
            !caster->IsValidAttackTarget(target);
    });
    return targets;
}

std::list<Unit*> GetNearbyAllies(Unit* center, Unit* caster, float radius)
{
    std::list<Unit*> targets;
    Acore::AnyFriendlyUnitInObjectRangeCheck check(center, caster, radius);
    Acore::UnitListSearcher<Acore::AnyFriendlyUnitInObjectRangeCheck> searcher(
        center, targets, check);
    Cell::VisitObjects(center, searcher, radius);
    targets.remove_if([center, caster, radius](Unit* target)
    {
        return !target || !target->IsAlive() || !target->IsInWorld() ||
            !caster->IsInMap(target) || !center->IsWithinDistInMap(target, radius);
    });
    return targets;
}

Unit* GetLowestHealthAlly(Unit* center, Unit* caster, float radius,
    std::set<ObjectGuid> const& excluded, uint32 rankedAura = 0)
{
    std::list<Unit*> targets = GetNearbyAllies(center, caster, radius);
    targets.remove_if([caster, &excluded, rankedAura](Unit* target)
    {
        return target->GetHealth() >= target->GetMaxHealth() ||
            excluded.count(target->GetGUID()) ||
            (rankedAura && target->GetAuraOfRankedSpell(
                rankedAura, caster->GetGUID()));
    });
    if (targets.empty())
        return nullptr;
    targets.sort(Acore::HealthPctOrderPred());
    return targets.front();
}

Unit* GetNearestEnemy(Unit* center, Unit* caster, float radius)
{
    std::list<Unit*> targets = GetNearbyEnemies(center, caster, radius);
    if (targets.empty())
        return nullptr;
    targets.sort([center](Unit* left, Unit* right)
    {
        return center->GetDistance(left) < center->GetDistance(right);
    });
    return targets.front();
}

void RegisterFlameShock(ObjectGuid caster, ObjectGuid target)
{
    std::lock_guard<std::mutex> lock(FlameShockTargetsMutex);
    FlameShockTargets[caster].insert(target);
}

void UnregisterFlameShock(ObjectGuid caster, ObjectGuid target)
{
    std::lock_guard<std::mutex> lock(FlameShockTargetsMutex);
    auto itr = FlameShockTargets.find(caster);
    if (itr == FlameShockTargets.end())
        return;
    itr->second.erase(target);
    if (itr->second.empty())
        FlameShockTargets.erase(itr);
}

std::vector<ObjectGuid> GetFlameShockTargets(ObjectGuid caster)
{
    std::lock_guard<std::mutex> lock(FlameShockTargetsMutex);
    auto itr = FlameShockTargets.find(caster);
    return itr == FlameShockTargets.end() ? std::vector<ObjectGuid>() :
        std::vector<ObjectGuid>(itr->second.begin(), itr->second.end());
}

void ClearFlameShockTargets(ObjectGuid caster)
{
    std::lock_guard<std::mutex> lock(FlameShockTargetsMutex);
    FlameShockTargets.erase(caster);
}

bool IsOwnedHeal(Unit* shaman, ProcEventInfo& eventInfo)
{
    HealInfo* healInfo = eventInfo.GetHealInfo();
    if (!shaman || !healInfo || !healInfo->GetHeal() || !healInfo->GetTarget())
        return false;
    Unit* healer = healInfo->GetHealer();
    return healer == shaman ||
        (healer && healer->GetCharmerOrOwnerPlayerOrPlayerItself() == shaman);
}
}

class spell_apoc_shaman_flame_shock : public SpellScriptLoader
{
public:
    spell_apoc_shaman_flame_shock()
        : SpellScriptLoader("spell_apoc_shaman_flame_shock") { }

    class flame_shock_AuraScript : public AuraScript
    {
        PrepareAuraScript(flame_shock_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            SpellInfo const* firstRank = sSpellMgr->GetSpellInfo(
                SPELL_SHAMAN_FLAME_SHOCK_R1);
            return firstRank && spellInfo->IsRankOf(firstRank) &&
                spellInfo->Effects[EFFECT_1].IsAura(
                    SPELL_AURA_PERIODIC_DAMAGE) &&
                ValidateSpellInfo({
                    SPELL_APOC_SHAMAN_MOLTEN_ANCHORS,
                    SPELL_APOC_SHAMAN_WILDFIRE_CONTAGION
                });
        }

        void HandleApply(AuraEffect const*, AuraEffectHandleModes)
        {
            RegisterFlameShock(GetCasterGUID(), GetTarget()->GetGUID());
        }

        void HandleRemove(AuraEffect const*, AuraEffectHandleModes)
        {
            UnregisterFlameShock(GetCasterGUID(), GetTarget()->GetGUID());
        }

        void HandlePeriodic(AuraEffect const* aurEff)
        {
            Unit* caster = GetCaster();
            Unit* target = GetTarget();
            if (!caster || !target ||
                !caster->HasAura(SPELL_APOC_SHAMAN_WILDFIRE_CONTAGION) ||
                !roll_chance_i(WILDFIRE_CHANCE))
                return;

            std::list<Unit*> targets = GetNearbyEnemies(target, caster, SPREAD_RADIUS);
            targets.remove_if([caster](Unit* spreadTarget)
            {
                return spreadTarget->GetAuraOfRankedSpell(
                    SPELL_SHAMAN_FLAME_SHOCK_R1, caster->GetGUID());
            });
            Acore::Containers::RandomResize(targets, 1);
            for (Unit* spreadTarget : targets)
                caster->CastSpell(spreadTarget, GetId(),
                    TriggerCastFlags(TRIGGERED_FULL_MASK &
                        ~TRIGGERED_DISALLOW_PROC_EVENTS), nullptr, aurEff);
        }

        void Register() override
        {
            AfterEffectApply += AuraEffectApplyFn(flame_shock_AuraScript::HandleApply,
                EFFECT_1, SPELL_AURA_PERIODIC_DAMAGE, AURA_EFFECT_HANDLE_REAL);
            AfterEffectRemove += AuraEffectRemoveFn(flame_shock_AuraScript::HandleRemove,
                EFFECT_1, SPELL_AURA_PERIODIC_DAMAGE, AURA_EFFECT_HANDLE_REAL);
            OnEffectPeriodic += AuraEffectPeriodicFn(
                flame_shock_AuraScript::HandlePeriodic, EFFECT_1,
                SPELL_AURA_PERIODIC_DAMAGE);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new flame_shock_AuraScript();
    }
};

class spell_apoc_shaman_lava_burst : public SpellScriptLoader
{
public:
    spell_apoc_shaman_lava_burst()
        : SpellScriptLoader("spell_apoc_shaman_lava_burst") { }

    class lava_burst_SpellScript : public SpellScript
    {
        PrepareSpellScript(lava_burst_SpellScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            SpellInfo const* firstRank = sSpellMgr->GetSpellInfo(
                SPELL_SHAMAN_LAVA_BURST_R1);
            return firstRank && spellInfo->IsRankOf(firstRank) &&
                spellInfo->Effects[EFFECT_0].Effect ==
                    SPELL_EFFECT_SCHOOL_DAMAGE &&
                ValidateSpellInfo({
                    SPELL_APOC_SHAMAN_TRIPLE_CONVERGENCE,
                    SPELL_APOC_SHAMAN_ECHOING_MAGMA,
                    SPELL_APOC_SHAMAN_ECHOING_MAGMA_DAMAGE,
                    SPELL_SHAMAN_FLAME_SHOCK_R1
                });
        }

        void HandleHit(SpellEffIndex)
        {
            Unit* caster = GetCaster();
            Unit* primary = GetHitUnit();
            if (!caster || !primary || GetHitDamage() <= 0 ||
                caster->HasAura(SPELL_APOC_SHAMAN_ASCENSION_MARKER))
                return;

            Aura* flameShock = primary->GetAuraOfRankedSpell(
                SPELL_SHAMAN_FLAME_SHOCK_R1, caster->GetGUID());
            if (!flameShock)
                return;

            if (caster->HasAura(SPELL_APOC_SHAMAN_TRIPLE_CONVERGENCE))
            {
                flameShock->RefreshDuration();
                flameShock->RefreshSpellMods();
                std::list<Unit*> targets = GetNearbyEnemies(primary, caster, SPREAD_RADIUS);
                targets.sort([caster](Unit* left, Unit* right)
                {
                    Aura* leftAura = left->GetAuraOfRankedSpell(
                        SPELL_SHAMAN_FLAME_SHOCK_R1, caster->GetGUID());
                    Aura* rightAura = right->GetAuraOfRankedSpell(
                        SPELL_SHAMAN_FLAME_SHOCK_R1, caster->GetGUID());
                    if (!leftAura != !rightAura)
                        return !leftAura;
                    int32 leftDuration = leftAura ? leftAura->GetDuration() : 0;
                    int32 rightDuration = rightAura ? rightAura->GetDuration() : 0;
                    return leftDuration < rightDuration;
                });
                if (targets.size() > 3)
                    targets.resize(3);
                uint32 spreadCount = 0;
                AuraEffect const* passive = caster->GetAuraEffect(
                    SPELL_APOC_SHAMAN_TRIPLE_CONVERGENCE, EFFECT_0);
                for (Unit* target : targets)
                {
                    caster->CastSpell(target, flameShock->GetId(),
                        TriggerCastFlags(TRIGGERED_FULL_MASK &
                            ~TRIGGERED_DISALLOW_PROC_EVENTS), nullptr, passive);
                    ++spreadCount;
                }
                while (spreadCount++ < 3)
                    caster->CastSpell(primary, flameShock->GetId(),
                        TriggerCastFlags(TRIGGERED_FULL_MASK &
                            ~TRIGGERED_DISALLOW_PROC_EVENTS), nullptr, passive);
            }

            if (!caster->HasAura(SPELL_APOC_SHAMAN_ECHOING_MAGMA))
                return;

            std::list<Unit*> targets = GetNearbyEnemies(primary, caster, SPREAD_RADIUS);
            targets.remove_if([caster](Unit* target)
            {
                return !target->GetAuraOfRankedSpell(
                    SPELL_SHAMAN_FLAME_SHOCK_R1, caster->GetGUID());
            });
            targets.sort([primary](Unit* left, Unit* right)
            {
                return primary->GetDistance(left) < primary->GetDistance(right);
            });
            if (targets.size() > 2)
                targets.resize(2);
            int32 damage = CalculatePct(GetHitDamage(), ECHO_DAMAGE_PCT);
            AuraEffect const* passive = caster->GetAuraEffect(
                SPELL_APOC_SHAMAN_ECHOING_MAGMA, EFFECT_0);
            for (Unit* target : targets)
                caster->CastCustomSpell(
                    SPELL_APOC_SHAMAN_ECHOING_MAGMA_DAMAGE,
                    SPELLVALUE_BASE_POINT0, damage, target, true, nullptr, passive);
        }

        void Register() override
        {
            OnEffectHitTarget += SpellEffectFn(lava_burst_SpellScript::HandleHit,
                EFFECT_0, SPELL_EFFECT_SCHOOL_DAMAGE);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new lava_burst_SpellScript();
    }
};

class spell_apoc_shaman_ascension : public SpellScriptLoader
{
public:
    spell_apoc_shaman_ascension()
        : SpellScriptLoader("spell_apoc_shaman_ascension") { }

    class ascension_AuraScript : public AuraScript
    {
        PrepareAuraScript(ascension_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Id == SPELL_APOC_SHAMAN_ASCENSION &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_APOC_SHAMAN_ASCENSION_MARKER,
                    SPELL_SHAMAN_FLAME_SHOCK_R1,
                    SPELL_SHAMAN_LAVA_BURST_R1
                });
        }

        void HandleApply(AuraEffect const* aurEff, AuraEffectHandleModes)
        {
            Player* caster = GetTarget()->ToPlayer();
            uint32 lavaBurst = GetHighestKnownRank(caster, SPELL_SHAMAN_LAVA_BURST_R1);
            if (!caster || !lavaBurst)
                return;

            caster->CastSpell(caster, SPELL_APOC_SHAMAN_ASCENSION_MARKER, true);
            for (ObjectGuid guid : GetFlameShockTargets(caster->GetGUID()))
            {
                Unit* target = ObjectAccessor::GetUnit(*caster, guid);
                if (!target || !target->IsAlive() || !caster->IsInMap(target) ||
                    !caster->IsValidAttackTarget(target) ||
                    !target->GetAuraOfRankedSpell(
                        SPELL_SHAMAN_FLAME_SHOCK_R1, caster->GetGUID()))
                    continue;
                caster->CastSpell(target, lavaBurst,
                    TriggerCastFlags(TRIGGERED_FULL_MASK |
                        TRIGGERED_IGNORE_SET_FACING), nullptr, aurEff);
            }
            caster->RemoveAurasDueToSpell(SPELL_APOC_SHAMAN_ASCENSION_MARKER);
        }

        void Register() override
        {
            AfterEffectApply += AuraEffectApplyFn(ascension_AuraScript::HandleApply,
                EFFECT_0, SPELL_AURA_DUMMY, AURA_EFFECT_HANDLE_REAL);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new ascension_AuraScript();
    }
};

class spell_apoc_shaman_trifold_bulwark : public SpellScriptLoader
{
public:
    spell_apoc_shaman_trifold_bulwark()
        : SpellScriptLoader("spell_apoc_shaman_trifold_bulwark") { }

    class trifold_bulwark_AuraScript : public AuraScript
    {
        PrepareAuraScript(trifold_bulwark_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Id == SPELL_APOC_SHAMAN_TRIFOLD_BULWARK &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_APOC_SHAMAN_MOLTEN_AEGIS,
                    SPELL_APOC_SHAMAN_TIDEBOUND_AEGIS,
                    SPELL_APOC_SHAMAN_STONEHIDE_AEGIS
                });
        }

        void HandleApply(AuraEffect const* aurEff, AuraEffectHandleModes)
        {
            Unit* target = GetTarget();
            target->CastSpell(target, SPELL_APOC_SHAMAN_MOLTEN_AEGIS,
                true, nullptr, aurEff);
            target->CastSpell(target, SPELL_APOC_SHAMAN_TIDEBOUND_AEGIS,
                true, nullptr, aurEff);
            target->CastSpell(target, SPELL_APOC_SHAMAN_STONEHIDE_AEGIS,
                true, nullptr, aurEff);
        }

        void HandleRemove(AuraEffect const*, AuraEffectHandleModes)
        {
            GetTarget()->RemoveAurasDueToSpell(SPELL_APOC_SHAMAN_MOLTEN_AEGIS);
            GetTarget()->RemoveAurasDueToSpell(SPELL_APOC_SHAMAN_TIDEBOUND_AEGIS);
            GetTarget()->RemoveAurasDueToSpell(SPELL_APOC_SHAMAN_STONEHIDE_AEGIS);
        }

        void Register() override
        {
            AfterEffectApply += AuraEffectApplyFn(
                trifold_bulwark_AuraScript::HandleApply, EFFECT_0,
                SPELL_AURA_DUMMY, AURA_EFFECT_HANDLE_REAL);
            AfterEffectRemove += AuraEffectRemoveFn(
                trifold_bulwark_AuraScript::HandleRemove, EFFECT_0,
                SPELL_AURA_DUMMY, AURA_EFFECT_HANDLE_REAL);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new trifold_bulwark_AuraScript();
    }
};

class spell_apoc_shaman_aegis : public SpellScriptLoader
{
public:
    spell_apoc_shaman_aegis() : SpellScriptLoader("spell_apoc_shaman_aegis") { }

    class aegis_AuraScript : public AuraScript
    {
        PrepareAuraScript(aegis_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return (spellInfo->Id == SPELL_APOC_SHAMAN_MOLTEN_AEGIS ||
                    spellInfo->Id == SPELL_APOC_SHAMAN_TIDEBOUND_AEGIS ||
                    spellInfo->Id == SPELL_APOC_SHAMAN_STONEHIDE_AEGIS) &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_SHAMAN_LIGHTNING_SHIELD_R1,
                    SPELL_SHAMAN_LIGHTNING_SHIELD_DAMAGE_R1,
                    SPELL_SHAMAN_WATER_SHIELD_R1,
                    SPELL_SHAMAN_EARTH_SHIELD_R1,
                    SPELL_SHAMAN_EARTH_SHIELD_HEAL,
                    SPELL_SHAMAN_GLYPH_OF_EARTH_SHIELD
                });
        }

        uint32 GetStockFirstRank() const
        {
            if (GetId() == SPELL_APOC_SHAMAN_MOLTEN_AEGIS)
                return SPELL_SHAMAN_LIGHTNING_SHIELD_R1;
            if (GetId() == SPELL_APOC_SHAMAN_TIDEBOUND_AEGIS)
                return SPELL_SHAMAN_WATER_SHIELD_R1;
            return SPELL_SHAMAN_EARTH_SHIELD_R1;
        }

        void HandleApply(AuraEffect const*, AuraEffectHandleModes)
        {
            SpellInfo const* stock = sSpellMgr->GetSpellInfo(
                GetRankForLevel(GetTarget(), GetStockFirstRank()));
            if (stock)
                SetCharges(uint8(stock->ProcCharges));
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            DamageInfo* damageInfo = eventInfo.GetDamageInfo();
            Unit* attacker = damageInfo ? damageInfo->GetAttacker() : nullptr;
            if (!attacker || attacker == GetTarget() || !attacker->IsAlive() ||
                !damageInfo->GetDamage())
                return false;
            if (GetId() == SPELL_APOC_SHAMAN_STONEHIDE_AEGIS)
                return !GetTarget()->HasSpellCooldown(
                    SPELL_SHAMAN_EARTH_SHIELD_HEAL);
            return true;
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();
            Unit* shaman = GetTarget();
            SpellInfo const* stock = sSpellMgr->GetSpellInfo(
                GetRankForLevel(shaman, GetStockFirstRank()));
            if (!stock)
                return;

            if (GetId() == SPELL_APOC_SHAMAN_MOLTEN_AEGIS)
            {
                uint32 trigger = sSpellMgr->GetSpellWithRank(
                    SPELL_SHAMAN_LIGHTNING_SHIELD_DAMAGE_R1, stock->GetRank());
                shaman->CastSpell(eventInfo.GetDamageInfo()->GetAttacker(),
                    trigger, true, nullptr, aurEff);
            }
            else if (GetId() == SPELL_APOC_SHAMAN_TIDEBOUND_AEGIS)
            {
                for (SpellEffectInfo const& effect : stock->Effects)
                    if (effect.TriggerSpell)
                    {
                        shaman->CastSpell(shaman, effect.TriggerSpell,
                            true, nullptr, aurEff);
                        break;
                    }
            }
            else
            {
                int32 baseAmount = stock->Effects[EFFECT_0].CalcValue(shaman);
                int32 amount = shaman->SpellHealingBonusDone(
                    shaman, stock, baseAmount, HEAL, EFFECT_0);
                if (AuraEffect* glyph = shaman->GetAuraEffect(
                    SPELL_SHAMAN_GLYPH_OF_EARTH_SHIELD, EFFECT_0))
                    AddPct(amount, glyph->GetAmount());
                if ((baseAmount = amount - baseAmount))
                    if (AuraEffect* improvedShields = shaman->GetAuraEffect(
                        SPELL_AURA_ADD_PCT_MODIFIER, SPELLFAMILY_SHAMAN, 19,
                        EFFECT_1))
                    {
                        ApplyPct(baseAmount, improvedShields->GetAmount());
                        amount += baseAmount;
                    }
                shaman->CastCustomSpell(SPELL_SHAMAN_EARTH_SHIELD_HEAL,
                    SPELLVALUE_BASE_POINT0, amount, shaman, true, nullptr,
                    aurEff, shaman->GetGUID());
                shaman->AddSpellCooldown(
                    SPELL_SHAMAN_EARTH_SHIELD_HEAL, 0, EARTH_SHIELD_ICD_MS);
            }

            if (GetCharges() <= 1 && stock->ProcCharges)
                SetCharges(uint8(stock->ProcCharges + 1));
        }

        void Register() override
        {
            AfterEffectApply += AuraEffectApplyFn(aegis_AuraScript::HandleApply,
                EFFECT_0, SPELL_AURA_DUMMY, AURA_EFFECT_HANDLE_REAL);
            DoCheckProc += AuraCheckProcFn(aegis_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(aegis_AuraScript::HandleProc,
                EFFECT_0, SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new aegis_AuraScript();
    }
};

class spell_apoc_shaman_earthen_defiance : public SpellScriptLoader
{
public:
    spell_apoc_shaman_earthen_defiance()
        : SpellScriptLoader("spell_apoc_shaman_earthen_defiance") { }

    class earthen_defiance_AuraScript : public AuraScript
    {
        PrepareAuraScript(earthen_defiance_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Id == SPELL_APOC_SHAMAN_EARTHEN_DEFIANCE &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_APOC_SHAMAN_EARTHEN_DEFIANCE_STACK
                });
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            DamageInfo* damageInfo = eventInfo.GetDamageInfo();
            return damageInfo && damageInfo->GetDamage() &&
                damageInfo->GetAttacker() && damageInfo->GetAttacker() != GetTarget();
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo&)
        {
            PreventDefaultAction();
            GetTarget()->CastSpell(GetTarget(),
                SPELL_APOC_SHAMAN_EARTHEN_DEFIANCE_STACK, true, nullptr, aurEff);
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(earthen_defiance_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(earthen_defiance_AuraScript::HandleProc,
                EFFECT_0, SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new earthen_defiance_AuraScript();
    }
};

class spell_apoc_shaman_riptide : public SpellScriptLoader
{
public:
    spell_apoc_shaman_riptide()
        : SpellScriptLoader("spell_apoc_shaman_riptide") { }

    class riptide_AuraScript : public AuraScript
    {
        PrepareAuraScript(riptide_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            SpellInfo const* firstRank = sSpellMgr->GetSpellInfo(
                SPELL_SHAMAN_RIPTIDE_R1);
            return firstRank && spellInfo->IsRankOf(firstRank) &&
                spellInfo->Effects[EFFECT_1].IsAura(SPELL_AURA_PERIODIC_HEAL) &&
                ValidateSpellInfo({
                    SPELL_APOC_SHAMAN_RIPTIDE_RESONANCE
                });
        }

        void HandlePeriodic(AuraEffect const* aurEff)
        {
            Unit* caster = GetCaster();
            if (!caster || !caster->HasAura(SPELL_APOC_SHAMAN_RIPTIDE_RESONANCE) ||
                !roll_chance_i(RIPTIDE_CHANCE))
                return;
            std::set<ObjectGuid> excluded;
            Unit* target = GetLowestHealthAlly(GetTarget(), caster, SPREAD_RADIUS,
                excluded, SPELL_SHAMAN_RIPTIDE_R1);
            if (target)
                caster->CastSpell(target, GetId(), true, nullptr, aurEff);
        }

        void Register() override
        {
            OnEffectPeriodic += AuraEffectPeriodicFn(riptide_AuraScript::HandlePeriodic,
                EFFECT_1, SPELL_AURA_PERIODIC_HEAL);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new riptide_AuraScript();
    }
};

class spell_apoc_shaman_overflowing_tides : public SpellScriptLoader
{
public:
    spell_apoc_shaman_overflowing_tides()
        : SpellScriptLoader("spell_apoc_shaman_overflowing_tides") { }

    class overflowing_tides_AuraScript : public AuraScript
    {
        PrepareAuraScript(overflowing_tides_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Id == SPELL_APOC_SHAMAN_OVERFLOWING_TIDES &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_APOC_SHAMAN_OVERFLOWING_TIDES_ABSORB,
                    SPELL_APOC_SHAMAN_TIDAL_ECHO_HEAL
                });
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            SpellInfo const* spellInfo = eventInfo.GetSpellInfo();
            HealInfo* healInfo = eventInfo.GetHealInfo();
            return IsOwnedHeal(GetTarget(), eventInfo) && spellInfo &&
                spellInfo->Id != SPELL_APOC_SHAMAN_TIDAL_ECHO_HEAL &&
                healInfo->GetHeal() > healInfo->GetEffectiveHeal();
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();
            HealInfo* healInfo = eventInfo.GetHealInfo();
            Unit* target = healInfo->GetTarget();
            uint32 overheal = healInfo->GetHeal() - healInfo->GetEffectiveHeal();
            uint32 contribution = CalculatePct(overheal, OVERHEAL_ABSORB_PCT);
            uint32 cap = target->CountPctFromMaxHealth(OVERHEAL_CAP_PCT);
            if (!contribution || !cap)
                return;

            Aura* shield = target->GetAura(
                SPELL_APOC_SHAMAN_OVERFLOWING_TIDES_ABSORB,
                GetTarget()->GetGUID());
            if (!shield)
            {
                GetTarget()->CastCustomSpell(target,
                    SPELL_APOC_SHAMAN_OVERFLOWING_TIDES_ABSORB,
                    SPELLVALUE_BASE_POINT0, int32(std::min(contribution, cap)),
                    true, nullptr, aurEff);
                return;
            }
            AuraEffect* absorb = shield->GetEffect(EFFECT_0);
            if (!absorb)
                return;
            uint64 amount = uint64(std::max(0, absorb->GetAmount())) + contribution;
            absorb->ChangeAmount(int32(std::min<uint64>(amount, cap)));
            shield->RefreshDuration();
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(overflowing_tides_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(overflowing_tides_AuraScript::HandleProc,
                EFFECT_0, SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new overflowing_tides_AuraScript();
    }
};

class spell_apoc_shaman_tidal_echo : public SpellScriptLoader
{
public:
    spell_apoc_shaman_tidal_echo()
        : SpellScriptLoader("spell_apoc_shaman_tidal_echo") { }

    class tidal_echo_SpellScript : public SpellScript
    {
        PrepareSpellScript(tidal_echo_SpellScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            SpellInfo const* firstRank = sSpellMgr->GetSpellInfo(
                SPELL_SHAMAN_CHAIN_HEAL_R1);
            return firstRank && spellInfo->IsRankOf(firstRank) &&
                spellInfo->Effects[EFFECT_0].Effect == SPELL_EFFECT_HEAL &&
                ValidateSpellInfo({
                    SPELL_APOC_SHAMAN_TIDAL_ECHO,
                    SPELL_APOC_SHAMAN_TIDAL_ECHO_HEAL
                });
        }

        bool Load() override
        {
            _primaryHeal = 0;
            _primary.Clear();
            _hitTargets.clear();
            return true;
        }

        void CaptureHeal(SpellEffIndex)
        {
            Unit* target = GetHitUnit();
            if (!target)
                return;
            _hitTargets.insert(target->GetGUID());
            if (target == GetExplTargetUnit())
            {
                _primary = target->GetGUID();
                _primaryHeal = GetHitHeal();
            }
        }

        void HandleAfterCast()
        {
            Unit* caster = GetCaster();
            if (!caster || !caster->HasAura(SPELL_APOC_SHAMAN_TIDAL_ECHO) ||
                !_primaryHeal || _primary.IsEmpty())
                return;
            Unit* primary = ObjectAccessor::GetUnit(*caster, _primary);
            if (!primary)
                return;
            Unit* target = GetLowestHealthAlly(primary, caster, TIDAL_ECHO_RADIUS,
                _hitTargets);
            if (!target)
                return;
            int32 heal = CalculatePct(_primaryHeal, 50);
            caster->CastCustomSpell(SPELL_APOC_SHAMAN_TIDAL_ECHO_HEAL,
                SPELLVALUE_BASE_POINT0, heal, target, true, nullptr,
                caster->GetAuraEffect(SPELL_APOC_SHAMAN_TIDAL_ECHO, EFFECT_0));
        }

        void Register() override
        {
            OnEffectHitTarget += SpellEffectFn(tidal_echo_SpellScript::CaptureHeal,
                EFFECT_0, SPELL_EFFECT_HEAL);
            AfterCast += SpellCastFn(tidal_echo_SpellScript::HandleAfterCast);
        }

    private:
        int32 _primaryHeal;
        ObjectGuid _primary;
        std::set<ObjectGuid> _hitTargets;
    };

    SpellScript* GetSpellScript() const override
    {
        return new tidal_echo_SpellScript();
    }
};

class spell_apoc_shaman_deep_currents : public SpellScriptLoader
{
public:
    spell_apoc_shaman_deep_currents()
        : SpellScriptLoader("spell_apoc_shaman_deep_currents") { }

    class deep_currents_AuraScript : public AuraScript
    {
        PrepareAuraScript(deep_currents_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Id == SPELL_APOC_SHAMAN_DEEP_CURRENTS &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_APOC_SHAMAN_DEEP_CURRENTS_BUFF,
                    SPELL_APOC_SHAMAN_TIDAL_ECHO_HEAL
                });
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            SpellInfo const* spellInfo = eventInfo.GetSpellInfo();
            return IsOwnedHeal(GetTarget(), eventInfo) && spellInfo &&
                spellInfo->Id != SPELL_APOC_SHAMAN_TIDAL_ECHO_HEAL &&
                eventInfo.GetHealInfo()->GetTarget()->HasAuraState(
                    AURA_STATE_HEALTHLESS_35_PERCENT);
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo&)
        {
            PreventDefaultAction();
            GetTarget()->CastSpell(GetTarget(),
                SPELL_APOC_SHAMAN_DEEP_CURRENTS_BUFF, true, nullptr, aurEff);
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(deep_currents_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(deep_currents_AuraScript::HandleProc,
                EFFECT_0, SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new deep_currents_AuraScript();
    }
};

class spell_apoc_shaman_stoneguard_bulwark : public SpellScriptLoader
{
public:
    spell_apoc_shaman_stoneguard_bulwark()
        : SpellScriptLoader("spell_apoc_shaman_stoneguard_bulwark") { }

    class stoneguard_bulwark_SpellScript : public SpellScript
    {
        PrepareSpellScript(stoneguard_bulwark_SpellScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Id == SPELL_APOC_SHAMAN_STONEGUARD_BULWARK &&
                ValidateSpellInfo({
                    SPELL_APOC_SHAMAN_EARTHEN_CALL,
                    SPELL_APOC_SHAMAN_ALPHAS_CALL,
                    SPELL_APOC_SHAMAN_TIDAL_CALL,
                    SPELL_SHAMAN_LIGHTNING_SHIELD_R1,
                    SPELL_SHAMAN_LIGHTNING_SHIELD_DAMAGE_R1
                });
        }

        void HandleAfterCast()
        {
            GetCaster()->RemoveMovementImpairingAuras(false);
        }

        void Register() override
        {
            AfterCast += SpellCastFn(stoneguard_bulwark_SpellScript::HandleAfterCast);
        }
    };

    class stoneguard_bulwark_AuraScript : public AuraScript
    {
        PrepareAuraScript(stoneguard_bulwark_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Id == SPELL_APOC_SHAMAN_STONEGUARD_BULWARK &&
                spellInfo->Effects[EFFECT_1].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_SHAMAN_LIGHTNING_SHIELD_R1,
                    SPELL_SHAMAN_LIGHTNING_SHIELD_DAMAGE_R1
                });
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            DamageInfo* damageInfo = eventInfo.GetDamageInfo();
            return damageInfo && damageInfo->GetDamage() &&
                damageInfo->GetAttacker() && damageInfo->GetAttacker() != GetTarget();
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();
            Unit* shaman = GetTarget();
            SpellInfo const* shield = sSpellMgr->GetSpellInfo(
                GetRankForLevel(shaman, SPELL_SHAMAN_LIGHTNING_SHIELD_R1));
            if (!shield)
                return;
            uint32 trigger = sSpellMgr->GetSpellWithRank(
                SPELL_SHAMAN_LIGHTNING_SHIELD_DAMAGE_R1, shield->GetRank());
            shaman->CastSpell(eventInfo.GetDamageInfo()->GetAttacker(), trigger,
                true, nullptr, aurEff);
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(stoneguard_bulwark_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(
                stoneguard_bulwark_AuraScript::HandleProc, EFFECT_1,
                SPELL_AURA_DUMMY);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new stoneguard_bulwark_SpellScript();
    }

    AuraScript* GetAuraScript() const override
    {
        return new stoneguard_bulwark_AuraScript();
    }
};

class spell_apoc_shaman_storm_unleashed : public SpellScriptLoader
{
public:
    spell_apoc_shaman_storm_unleashed()
        : SpellScriptLoader("spell_apoc_shaman_storm_unleashed") { }

    class storm_unleashed_AuraScript : public AuraScript
    {
        PrepareAuraScript(storm_unleashed_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Id == SPELL_APOC_SHAMAN_STORM_UNLEASHED &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_APOC_SHAMAN_STORM_UNLEASHED_DAMAGE
                });
        }

        void HandleApply(AuraEffect const*, AuraEffectHandleModes)
        {
            SetMaxDuration(12000);
            SetDuration(12000);
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Unit* shaman = GetTarget();
            if (!shaman || shaman->HasSpellCooldown(
                SPELL_APOC_SHAMAN_STORM_UNLEASHED_DAMAGE))
                return false;
            SpellInfo const* spellInfo = eventInfo.GetSpellInfo();
            if (spellInfo && spellInfo->Id ==
                SPELL_APOC_SHAMAN_STORM_UNLEASHED_DAMAGE)
                return false;
            if (DamageInfo* damageInfo = eventInfo.GetDamageInfo())
                return damageInfo->GetDamage() && damageInfo->GetVictim() != shaman;
            return eventInfo.GetHealInfo() && eventInfo.GetHealInfo()->GetHeal();
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();
            Unit* shaman = GetTarget();
            Unit* target = nullptr;
            uint32 sourceAmount = 0;
            if (DamageInfo* damageInfo = eventInfo.GetDamageInfo())
            {
                target = damageInfo->GetVictim();
                sourceAmount = damageInfo->GetDamage();
            }
            else if (HealInfo* healInfo = eventInfo.GetHealInfo())
            {
                target = GetNearestEnemy(healInfo->GetTarget(), shaman, SPREAD_RADIUS);
                sourceAmount = healInfo->GetHeal();
            }
            if (!target || !sourceAmount)
                return;
            int32 damage = CalculatePct(sourceAmount, STORM_DAMAGE_PCT);
            shaman->CastCustomSpell(SPELL_APOC_SHAMAN_STORM_UNLEASHED_DAMAGE,
                SPELLVALUE_BASE_POINT0, damage, target, true, nullptr, aurEff);
            shaman->AddSpellCooldown(
                SPELL_APOC_SHAMAN_STORM_UNLEASHED_DAMAGE, 0, STORM_ICD_MS);
        }

        void Register() override
        {
            AfterEffectApply += AuraEffectApplyFn(
                storm_unleashed_AuraScript::HandleApply, EFFECT_0,
                SPELL_AURA_DUMMY, AURA_EFFECT_HANDLE_REAL);
            DoCheckProc += AuraCheckProcFn(storm_unleashed_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(storm_unleashed_AuraScript::HandleProc,
                EFFECT_0, SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new storm_unleashed_AuraScript();
    }
};

class spell_apoc_shaman_spirit_link_conduit : public SpellScriptLoader
{
public:
    spell_apoc_shaman_spirit_link_conduit()
        : SpellScriptLoader("spell_apoc_shaman_spirit_link_conduit") { }

    class spirit_link_conduit_AuraScript : public AuraScript
    {
        PrepareAuraScript(spirit_link_conduit_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Id == SPELL_APOC_SHAMAN_SPIRIT_LINK_CONDUIT &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_APOC_SHAMAN_TIDAL_ECHO_HEAL
                });
        }

        void Register() override { }
    };

    AuraScript* GetAuraScript() const override
    {
        return new spirit_link_conduit_AuraScript();
    }
};

class apoc_shaman_player : public PlayerScript
{
public:
    apoc_shaman_player() : PlayerScript("apoc_shaman_player") { }

    void OnPlayerSpellCast(Player* player, Spell* spell, bool) override
    {
        if (!player || !spell || spell->IsTriggered() ||
            !player->HasAura(SPELL_APOC_SHAMAN_SPIRIT_LINK_CONDUIT) ||
            player->HasSpellCooldown(SPELL_APOC_SHAMAN_SPIRIT_LINK_CONDUIT))
            return;
        SpellInfo const* spellInfo = spell->GetSpellInfo();
        if (!spellInfo || spellInfo->SpellFamilyName != SPELLFAMILY_SHAMAN ||
            (!spellInfo->TotemCategory[0] && !spellInfo->TotemCategory[1]))
            return;
        int32 heal = player->CountPctFromMaxHealth(CONDUIT_HEAL_PCT);
        player->CastCustomSpell(SPELL_APOC_SHAMAN_TIDAL_ECHO_HEAL,
            SPELLVALUE_BASE_POINT0, heal, player, true, nullptr,
            player->GetAuraEffect(SPELL_APOC_SHAMAN_SPIRIT_LINK_CONDUIT, EFFECT_0));
        player->AddSpellCooldown(
            SPELL_APOC_SHAMAN_SPIRIT_LINK_CONDUIT, 0, CONDUIT_ICD_MS);
    }

    void OnPlayerLogout(Player* player) override
    {
        if (player)
            ClearFlameShockTargets(player->GetGUID());
    }
};

void AddModApocalipseShamanSpellScripts()
{
    new spell_apoc_shaman_flame_shock();
    new spell_apoc_shaman_lava_burst();
    new spell_apoc_shaman_ascension();
    new spell_apoc_shaman_trifold_bulwark();
    new spell_apoc_shaman_aegis();
    new spell_apoc_shaman_earthen_defiance();
    new spell_apoc_shaman_riptide();
    new spell_apoc_shaman_overflowing_tides();
    new spell_apoc_shaman_tidal_echo();
    new spell_apoc_shaman_deep_currents();
    new spell_apoc_shaman_stoneguard_bulwark();
    new spell_apoc_shaman_storm_unleashed();
    new spell_apoc_shaman_spirit_link_conduit();
    new apoc_shaman_player();
}

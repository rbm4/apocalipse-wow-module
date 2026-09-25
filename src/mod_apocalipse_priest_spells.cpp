#include "Define.h"
#include "CellImpl.h"
#include "Creature.h"
#include "GridNotifiers.h"
#include "GridNotifiersImpl.h"
#include "Group.h"
#include "ObjectAccessor.h"
#include "PetDefines.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "Spell.h"
#include "SpellAuras.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "TemporarySummon.h"
#include "Unit.h"

#include <algorithm>
#include <list>
#include <map>
#include <mutex>
#include <set>
#include <vector>

using namespace std::chrono_literals;

namespace
{
enum PriestSpells
{
    SPELL_SPIRITUAL_CONSERVATION = 901118,
    SPELL_CONSERVATION_MANA = 901119,
    SPELL_FAITHFUL_SHADOWFIEND = 901120,
    SPELL_INNER_RENEWAL = 901121,
    SPELL_UNSHAKABLE_CONVICTION = 901122,
    SPELL_RAPID_SURGE = 901123,
    SPELL_RAPID_SURGE_BUFF = 901124,
    SPELL_RAPID_PENANCE = 901125,
    SPELL_RAPID_PENANCE_BONUS = 901126,
    SPELL_EVANGELISM = 901127,
    SPELL_EVANGELISM_STACK = 901128,
    SPELL_ARCHANGEL = 901129,
    SPELL_ARCHANGEL_BUFF = 901130,
    SPELL_ATONEMENT = 901131,
    SPELL_ATONEMENT_HEAL = 901132,
    SPELL_BALANCED_JUDGMENT = 901133,
    SPELL_JUDGMENT_CHARGES = 901134,
    SPELL_WRATHFUL_SERAPH = 901135,
    SPELL_DIVINE_CONCORD = 901136,
    SPELL_MERCY = 901137,
    SPELL_WRATH = 901138,
    SPELL_HOLY_WORD_RADIANCE = 901139,
    SPELL_RADIANCE_DAMAGE = 901140,
    SPELL_RADIANCE_HEAL = 901141,
    SPELL_BLESSED_ECHOES = 901142,
    SPELL_ECHO_DAMAGE = 901143,
    SPELL_ECHO_HEAL = 901144,
    SPELL_APOTHEOSIS = 901145,
    SPELL_ACCELERATED_MISERY = 901146,
    SPELL_SPREADING_DARKNESS = 901147,
    SPELL_COPIED_DEVOURING_PLAGUE = 901148,
    SPELL_VOID_PRESSURE = 901149,
    SPELL_VOID_PRESENCE = 901150,
    SPELL_DEVOURING_ECHO = 901151,
    SPELL_DEVOURING_ECHO_DAMAGE = 901152,
    SPELL_VOID_ERUPTION = 901153,
    SPELL_VOID_ERUPTION_DAMAGE = 901154,
    SPELL_SMITE_R1 = 585,
    SPELL_HOLY_FIRE_R1 = 14914,
    SPELL_HOLY_NOVA_R1 = 15237,
    SPELL_GREATER_HEAL_R1 = 2060,
    SPELL_FLASH_HEAL_R1 = 2061,
    SPELL_SHADOW_WORD_PAIN_R1 = 589,
    SPELL_MIND_BLAST_R1 = 8092,
    SPELL_MIND_FLAY_R1 = 15407,
    SPELL_MIND_FLAY_DAMAGE = 58381,
    SPELL_VAMPIRIC_TOUCH_R1 = 34914,
    SPELL_DEVOURING_PLAGUE_R1 = 2944,
    SPELL_PENANCE_R1 = 47540,
    SPELL_PENANCE_DAMAGE_R1 = 47758,
    SPELL_PENANCE_HEAL_R1 = 47757
};

constexpr float NEARBY_RADIUS = 10.0f;
constexpr float ATONEMENT_RADIUS = 15.0f;
constexpr uint32 CONSERVATION_ICD = 2000;
constexpr uint32 SURGE_ICD = 20000;
constexpr uint32 ECHO_ICD = 500;

struct DotKey
{
    ObjectGuid Caster;
    ObjectGuid Target;

    bool operator<(DotKey const& other) const
    {
        return Caster < other.Caster || (Caster == other.Caster && Target < other.Target);
    }
};

std::map<ObjectGuid, std::set<ObjectGuid>> DotTargets;
std::map<DotKey, uint32> DevouringEchoAmounts;
struct HolyCastState
{
    uint32 SpellId = 0;
    uint8 RapidPct = 0;
    uint8 ConcordPct = 0;
    uint8 JudgmentPct = 0;
};

std::map<ObjectGuid, uint32> LastHolyAmounts;
std::map<ObjectGuid, HolyCastState> HolyCastStates;
std::set<ObjectGuid> RadianceSecondaryCasters;
std::mutex PriestStateMutex;

bool IsCustomHelper(uint32 id)
{
    return id == SPELL_CONSERVATION_MANA || id == SPELL_ATONEMENT_HEAL ||
        id == SPELL_RADIANCE_DAMAGE || id == SPELL_RADIANCE_HEAL ||
        id == SPELL_ECHO_DAMAGE || id == SPELL_ECHO_HEAL ||
        id == SPELL_DEVOURING_ECHO_DAMAGE || id == SPELL_VOID_ERUPTION_DAMAGE;
}

bool IsPriestHoly(SpellInfo const* spellInfo)
{
    return spellInfo && spellInfo->SpellFamilyName == SPELLFAMILY_PRIEST &&
        (spellInfo->GetSchoolMask() & SPELL_SCHOOL_MASK_HOLY);
}

bool IsRank(SpellInfo const* spellInfo, uint32 firstRank)
{
    SpellInfo const* first = sSpellMgr->GetSpellInfo(firstRank);
    return spellInfo && first && spellInfo->IsRankOf(first);
}

bool IsPenance(SpellInfo const* spellInfo)
{
    return IsRank(spellInfo, SPELL_PENANCE_R1) ||
        IsRank(spellInfo, SPELL_PENANCE_DAMAGE_R1) ||
        IsRank(spellInfo, SPELL_PENANCE_HEAL_R1);
}

bool IsDirectSpell(SpellInfo const* spellInfo)
{
    return spellInfo && !spellInfo->HasAura(SPELL_AURA_PERIODIC_DAMAGE) &&
        !spellInfo->HasAura(SPELL_AURA_PERIODIC_HEAL) &&
        !spellInfo->HasAura(SPELL_AURA_PERIODIC_LEECH);
}

Player* GetPriestOwner(Unit* unit)
{
    Player* player = unit ? unit->GetCharmerOrOwnerPlayerOrPlayerItself() : nullptr;
    return player && player->getClass() == CLASS_PRIEST ? player : nullptr;
}

void AddStack(Unit* target, uint32 spellId, uint8 maximum, AuraEffect const* trigger = nullptr)
{
    if (Aura* aura = target->GetAura(spellId))
    {
        aura->ModStackAmount(1);
        if (aura->GetStackAmount() > maximum)
            aura->SetStackAmount(maximum);
        aura->RefreshDuration();
    }
    else
        target->CastSpell(target, spellId, true, nullptr, trigger);
}

void AddTargetStack(Unit* caster, Unit* target, uint32 spellId, uint8 maximum,
    AuraEffect const* trigger)
{
    if (Aura* aura = target->GetAura(spellId, caster->GetGUID()))
    {
        aura->ModStackAmount(1);
        if (aura->GetStackAmount() > maximum)
            aura->SetStackAmount(maximum);
        aura->RefreshDuration();
    }
    else
        caster->CastSpell(target, spellId, true, nullptr, trigger);
}

std::list<Unit*> GetNearbyEnemies(Unit* center, Unit* caster, float radius)
{
    std::list<Unit*> targets;
    Acore::AnyUnfriendlyUnitInObjectRangeCheck check(center, caster, radius);
    Acore::UnitListSearcher<Acore::AnyUnfriendlyUnitInObjectRangeCheck> searcher(center, targets, check);
    Cell::VisitObjects(center, searcher, radius);
    targets.remove_if([center, caster, radius](Unit* target)
    {
        return !target || !target->IsAlive() || !target->IsInWorld() ||
            !caster->IsInMap(target) || !center->IsWithinDistInMap(target, radius) ||
            !caster->IsValidAttackTarget(target);
    });
    return targets;
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

Unit* GetAtonementTarget(Player* priest, Unit* enemy)
{
    Unit* selected = nullptr;
    float healthPct = 101.0f;
    if (Group* group = priest->GetGroup())
    {
        for (GroupReference* ref = group->GetFirstMember(); ref; ref = ref->next())
        {
            Player* member = ref->GetSource();
            if (!member || member == priest || !member->IsAlive() ||
                !member->IsInWorld() || !enemy->IsWithinDistInMap(member, ATONEMENT_RADIUS) ||
                member->GetHealth() >= member->GetMaxHealth())
                continue;
            float pct = member->GetHealthPct();
            if (pct < healthPct)
            {
                healthPct = pct;
                selected = member;
            }
        }
    }
    if (!selected && priest->IsAlive() && priest->GetHealth() < priest->GetMaxHealth() &&
        enemy->IsWithinDistInMap(priest, ATONEMENT_RADIUS))
        selected = priest;
    return selected;
}

void RegisterDot(ObjectGuid caster, ObjectGuid target)
{
    std::lock_guard<std::mutex> lock(PriestStateMutex);
    DotTargets[caster].insert(target);
}

void UnregisterDot(ObjectGuid caster, ObjectGuid target)
{
    std::lock_guard<std::mutex> lock(PriestStateMutex);
    auto itr = DotTargets.find(caster);
    if (itr == DotTargets.end())
        return;
    itr->second.erase(target);
    if (itr->second.empty())
        DotTargets.erase(itr);
}

std::vector<ObjectGuid> GetDotTargets(ObjectGuid caster)
{
    std::lock_guard<std::mutex> lock(PriestStateMutex);
    auto itr = DotTargets.find(caster);
    return itr == DotTargets.end() ? std::vector<ObjectGuid>() :
        std::vector<ObjectGuid>(itr->second.begin(), itr->second.end());
}

HolyCastState GetHolyCastState(Player* caster, SpellInfo const* spellInfo)
{
    std::lock_guard<std::mutex> lock(PriestStateMutex);
    auto itr = HolyCastStates.find(caster->GetGUID());
    return itr != HolyCastStates.end() && itr->second.SpellId == spellInfo->Id ?
        itr->second : HolyCastState{};
}

uint8 CountDots(Unit* target, ObjectGuid caster)
{
    uint8 count = 0;
    if (target->GetAuraOfRankedSpell(SPELL_SHADOW_WORD_PAIN_R1, caster))
        ++count;
    if (target->GetAuraOfRankedSpell(SPELL_VAMPIRIC_TOUCH_R1, caster))
        ++count;
    if (target->GetAuraOfRankedSpell(SPELL_DEVOURING_PLAGUE_R1, caster) ||
        target->GetAura(SPELL_COPIED_DEVOURING_PLAGUE, caster))
        ++count;
    return count;
}

void EruptDevouringEcho(Player* caster, Unit* center, bool includeCenter)
{
    if (!caster || !center)
        return;
    DotKey key{caster->GetGUID(), center->GetGUID()};
    uint32 amount = 0;
    {
        std::lock_guard<std::mutex> lock(PriestStateMutex);
        auto itr = DevouringEchoAmounts.find(key);
        if (itr != DevouringEchoAmounts.end())
        {
            amount = itr->second;
            DevouringEchoAmounts.erase(itr);
        }
    }
    if (!amount)
        return;
    AuraEffect const* trigger = caster->GetAuraEffect(SPELL_DEVOURING_ECHO, EFFECT_0);
    if (includeCenter && center->IsAlive())
        caster->CastCustomSpell(SPELL_DEVOURING_ECHO_DAMAGE, SPELLVALUE_BASE_POINT0,
            amount, center, true, nullptr, trigger);
    for (Unit* target : GetNearbyEnemies(center, caster, NEARBY_RADIUS))
        if (target != center)
            caster->CastCustomSpell(SPELL_DEVOURING_ECHO_DAMAGE, SPELLVALUE_BASE_POINT0,
                amount, target, true, nullptr, trigger);
}

void ClearPriestState(ObjectGuid caster)
{
    std::lock_guard<std::mutex> lock(PriestStateMutex);
    DotTargets.erase(caster);
    LastHolyAmounts.erase(caster);
    HolyCastStates.erase(caster);
    RadianceSecondaryCasters.erase(caster);
    for (auto itr = DevouringEchoAmounts.begin(); itr != DevouringEchoAmounts.end();)
        if (itr->first.Caster == caster)
            itr = DevouringEchoAmounts.erase(itr);
        else
            ++itr;
}
}

class spell_apoc_priest_spiritual_conservation : public SpellScriptLoader
{
public:
    spell_apoc_priest_spiritual_conservation() : SpellScriptLoader("spell_apoc_priest_spiritual_conservation") { }

    class script : public AuraScript
    {
        PrepareAuraScript(script);

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Unit* priest = GetTarget();
            SpellInfo const* spellInfo = eventInfo.GetSpellInfo();
            return priest && !priest->HasSpellCooldown(SPELL_CONSERVATION_MANA) &&
                spellInfo && spellInfo->SpellFamilyName == SPELLFAMILY_PRIEST &&
                !IsCustomHelper(spellInfo->Id) &&
                (eventInfo.GetHitMask() & PROC_HIT_CRITICAL) &&
                ((eventInfo.GetDamageInfo() && eventInfo.GetDamageInfo()->GetDamage()) ||
                    (eventInfo.GetHealInfo() && eventInfo.GetHealInfo()->GetHeal()));
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo&)
        {
            PreventDefaultAction();
            Unit* priest = GetTarget();
            int32 mana = priest->GetMaxPower(POWER_MANA) * 75 / 10000;
            priest->CastCustomSpell(SPELL_CONSERVATION_MANA, SPELLVALUE_BASE_POINT0,
                mana, priest, true, nullptr, aurEff);
            priest->AddSpellCooldown(SPELL_CONSERVATION_MANA, 0, CONSERVATION_ICD);
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(script::CheckProc);
            OnEffectProc += AuraEffectProcFn(script::HandleProc, EFFECT_0, SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override { return new script(); }
};

class spell_apoc_priest_rapid_surge : public SpellScriptLoader
{
public:
    spell_apoc_priest_rapid_surge() : SpellScriptLoader("spell_apoc_priest_rapid_surge") { }

    class script : public AuraScript
    {
        PrepareAuraScript(script);

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Unit* priest = GetTarget();
            SpellInfo const* spellInfo = eventInfo.GetSpellInfo();
            return priest && !priest->HasSpellCooldown(SPELL_RAPID_SURGE_BUFF) &&
                spellInfo && spellInfo->SpellFamilyName == SPELLFAMILY_PRIEST &&
                !(eventInfo.GetTypeMask() & PROC_FLAG_DONE_PERIODIC) &&
                (eventInfo.GetHitMask() & PROC_HIT_CRITICAL) &&
                !IsCustomHelper(spellInfo->Id) && roll_chance_i(20);
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo&)
        {
            PreventDefaultAction();
            Unit* priest = GetTarget();
            priest->CastSpell(priest, SPELL_RAPID_SURGE_BUFF, true, nullptr, aurEff);
            priest->AddSpellCooldown(SPELL_RAPID_SURGE_BUFF, 0, SURGE_ICD);
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(script::CheckProc);
            OnEffectProc += AuraEffectProcFn(script::HandleProc, EFFECT_0, SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override { return new script(); }
};

class spell_apoc_priest_inner_renewal : public SpellScriptLoader
{
public:
    spell_apoc_priest_inner_renewal() : SpellScriptLoader("spell_apoc_priest_inner_renewal") { }

    class script : public SpellScript
    {
        PrepareSpellScript(script);

        void RestoreMana(SpellEffIndex)
        {
            Unit* caster = GetCaster();
            caster->ModifyPower(POWER_MANA,
                CalculatePct(caster->GetMaxPower(POWER_MANA), 16));
        }

        void Register() override
        {
            OnEffectHitTarget += SpellEffectFn(script::RestoreMana, EFFECT_0, SPELL_EFFECT_DUMMY);
        }
    };

    SpellScript* GetSpellScript() const override { return new script(); }
};

class spell_apoc_priest_rapid_penance : public SpellScriptLoader
{
public:
    spell_apoc_priest_rapid_penance() : SpellScriptLoader("spell_apoc_priest_rapid_penance") { }

    class script : public AuraScript
    {
        PrepareAuraScript(script);

        void CalculatePeriodic(AuraEffect const*, bool&, int32& amplitude)
        {
            if (Unit* caster = GetCaster())
                if (caster->HasAura(SPELL_RAPID_PENANCE))
                    amplitude = std::max<int32>(1, amplitude / 2);
        }

        void HandlePeriodic(AuraEffect const* aurEff)
        {
            if (Unit* caster = GetCaster())
                if (caster->HasAura(SPELL_RAPID_PENANCE))
                {
                    AddStack(caster, SPELL_RAPID_PENANCE_BONUS, 6, aurEff);
                    if (caster->HasAura(SPELL_BALANCED_JUDGMENT))
                        AddStack(caster, SPELL_JUDGMENT_CHARGES, 3, aurEff);
                }
        }

        void Register() override
        {
            DoEffectCalcPeriodic += AuraEffectCalcPeriodicFn(script::CalculatePeriodic,
                EFFECT_FIRST_FOUND, SPELL_AURA_PERIODIC_TRIGGER_SPELL);
            OnEffectPeriodic += AuraEffectPeriodicFn(script::HandlePeriodic,
                EFFECT_FIRST_FOUND, SPELL_AURA_PERIODIC_TRIGGER_SPELL);
        }
    };

    AuraScript* GetAuraScript() const override { return new script(); }
};

class spell_apoc_priest_archangel : public SpellScriptLoader
{
public:
    spell_apoc_priest_archangel() : SpellScriptLoader("spell_apoc_priest_archangel") { }

    class script : public SpellScript
    {
        PrepareSpellScript(script);

        void Handle(SpellEffIndex)
        {
            Unit* caster = GetCaster();
            Aura* stacks = caster->GetAura(SPELL_EVANGELISM_STACK);
            if (!stacks)
                return;
            uint8 count = stacks->GetStackAmount();
            caster->RemoveAurasDueToSpell(SPELL_EVANGELISM_STACK);
            caster->ModifyPower(POWER_MANA,
                CalculatePct(caster->GetMaxPower(POWER_MANA), count));
            caster->CastCustomSpell(SPELL_ARCHANGEL_BUFF, SPELLVALUE_BASE_POINT0,
                count * 3, caster, true);
        }

        void Register() override
        {
            OnEffectHitTarget += SpellEffectFn(script::Handle, EFFECT_0, SPELL_EFFECT_DUMMY);
        }
    };

    SpellScript* GetSpellScript() const override { return new script(); }
};

class spell_apoc_priest_atonement : public SpellScriptLoader
{
public:
    spell_apoc_priest_atonement() : SpellScriptLoader("spell_apoc_priest_atonement") { }

    class script : public AuraScript
    {
        PrepareAuraScript(script);

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            DamageInfo* damage = eventInfo.GetDamageInfo();
            SpellInfo const* spellInfo = eventInfo.GetSpellInfo();
            return damage && damage->GetDamage() && damage->GetAttacker() == GetTarget() &&
                damage->GetVictim() && spellInfo && !IsCustomHelper(spellInfo->Id) &&
                (IsRank(spellInfo, SPELL_SMITE_R1) || IsRank(spellInfo, SPELL_HOLY_FIRE_R1) ||
                    IsRank(spellInfo, SPELL_PENANCE_DAMAGE_R1));
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();
            Player* priest = GetTarget()->ToPlayer();
            DamageInfo* damage = eventInfo.GetDamageInfo();
            Unit* target = GetAtonementTarget(priest, damage->GetVictim());
            if (!target)
                return;
            int32 heal = CalculatePct(damage->GetDamage(), 75);
            priest->CastCustomSpell(SPELL_ATONEMENT_HEAL, SPELLVALUE_BASE_POINT0,
                heal, target, true, nullptr, aurEff);
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(script::CheckProc);
            OnEffectProc += AuraEffectProcFn(script::HandleProc, EFFECT_0, SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override { return new script(); }
};

class spell_apoc_priest_radiance : public SpellScriptLoader
{
public:
    spell_apoc_priest_radiance() : SpellScriptLoader("spell_apoc_priest_radiance") { }

    class script : public SpellScript
    {
        PrepareSpellScript(script);

        void HandlePrimary()
        {
            Player* caster = GetCaster()->ToPlayer();
            Unit* primary = GetHitUnit();
            if (!caster || !primary)
                return;
            uint32 amount = 0;
            {
                std::lock_guard<std::mutex> lock(PriestStateMutex);
                amount = LastHolyAmounts[caster->GetGUID()];
            }
            if (!amount)
                return;
            if (caster->IsFriendlyTo(primary))
            {
                amount += int32(caster->SpellBaseHealingBonusDone(
                    SPELL_SCHOOL_MASK_HOLY) * 0.268f);
                caster->CastCustomSpell(SPELL_RADIANCE_HEAL, SPELLVALUE_BASE_POINT0,
                    amount, primary, true);
            }
            else
            {
                amount += int32(caster->SpellBaseDamageBonusDone(
                    SPELL_SCHOOL_MASK_HOLY) * 0.268f);
                caster->CastCustomSpell(SPELL_RADIANCE_DAMAGE, SPELLVALUE_BASE_POINT0,
                    amount, primary, true);
            }
        }

        void HandleSecondary()
        {
            Player* caster = GetCaster()->ToPlayer();
            Unit* primary = GetHitUnit();
            if (!caster || !primary)
                return;
            {
                std::lock_guard<std::mutex> lock(PriestStateMutex);
                if (RadianceSecondaryCasters.count(caster->GetGUID()))
                    return;
            }
            Unit* target = nullptr;
            uint32 amount = 0;
            uint32 helper = 0;
            if (GetSpellInfo()->Id == SPELL_RADIANCE_HEAL)
            {
                target = GetNearestEnemy(primary, caster, NEARBY_RADIUS);
                amount = GetHitHeal();
                helper = SPELL_RADIANCE_DAMAGE;
            }
            else
            {
                target = GetAtonementTarget(caster, primary);
                amount = GetHitDamage();
                helper = SPELL_RADIANCE_HEAL;
            }
            if (!target || !amount)
                return;
            {
                std::lock_guard<std::mutex> lock(PriestStateMutex);
                RadianceSecondaryCasters.insert(caster->GetGUID());
            }
            caster->CastCustomSpell(helper, SPELLVALUE_BASE_POINT0,
                CalculatePct(amount, 40), target, true);
            {
                std::lock_guard<std::mutex> lock(PriestStateMutex);
                RadianceSecondaryCasters.erase(caster->GetGUID());
            }
        }

        void AfterCastHandler()
        {
            if (GetSpellInfo()->Id != SPELL_HOLY_WORD_RADIANCE)
                return;

            Player* caster = GetCaster()->ToPlayer();
            if (caster && caster->HasAura(SPELL_APOTHEOSIS))
                caster->ModifySpellCooldown(SPELL_HOLY_WORD_RADIANCE, -7500);
        }

        void HandleHit()
        {
            switch (GetSpellInfo()->Id)
            {
                case SPELL_HOLY_WORD_RADIANCE:
                    HandlePrimary();
                    break;
                case SPELL_RADIANCE_DAMAGE:
                case SPELL_RADIANCE_HEAL:
                    HandleSecondary();
                    break;
                default:
                    break;
            }
        }

        void Register() override
        {
            OnHit += SpellHitFn(script::HandleHit);
            AfterCast += SpellCastFn(script::AfterCastHandler);
        }
    };

    SpellScript* GetSpellScript() const override { return new script(); }
};

class spell_apoc_priest_blessed_echoes : public SpellScriptLoader
{
public:
    spell_apoc_priest_blessed_echoes() : SpellScriptLoader("spell_apoc_priest_blessed_echoes") { }

    class script : public AuraScript
    {
        PrepareAuraScript(script);

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Unit* priest = GetTarget();
            SpellInfo const* spellInfo = eventInfo.GetSpellInfo();
            if (!priest || priest->HasSpellCooldown(SPELL_BLESSED_ECHOES) ||
                !IsPriestHoly(spellInfo) || !IsDirectSpell(spellInfo) ||
                IsCustomHelper(spellInfo->Id))
                return false;
            uint32 chance = priest->HasAura(SPELL_APOTHEOSIS) ? 40 : 30;
            return roll_chance_i(chance) &&
                ((eventInfo.GetDamageInfo() && eventInfo.GetDamageInfo()->GetDamage()) ||
                    (eventInfo.GetHealInfo() && eventInfo.GetHealInfo()->GetHeal()));
        }

        void HandleProc(AuraEffect const*, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();
            Unit* priest = GetTarget();
            Unit* target = nullptr;
            uint32 amount = 0;
            uint32 helper = 0;
            if (DamageInfo* damage = eventInfo.GetDamageInfo())
            {
                target = damage->GetVictim();
                amount = damage->GetDamage();
                helper = SPELL_ECHO_DAMAGE;
            }
            else if (HealInfo* heal = eventInfo.GetHealInfo())
            {
                target = heal->GetTarget();
                amount = heal->GetHeal();
                helper = SPELL_ECHO_HEAL;
            }
            if (!target || !amount)
                return;
            ObjectGuid casterGuid = priest->GetGUID();
            ObjectGuid targetGuid = target->GetGUID();
            int32 echo = CalculatePct(amount, 40);
            priest->AddSpellCooldown(SPELL_BLESSED_ECHOES, 0, ECHO_ICD);
            priest->m_Events.AddEventAtOffset([casterGuid, targetGuid, helper, echo]()
            {
                Player* caster = ObjectAccessor::FindPlayer(casterGuid);
                if (!caster || !caster->IsAlive() || !caster->IsInWorld())
                    return;
                Unit* target = ObjectAccessor::GetUnit(*caster, targetGuid);
                if (!target || !target->IsAlive() || !target->IsInWorld() ||
                    !caster->IsInMap(target))
                    return;
                caster->CastCustomSpell(helper, SPELLVALUE_BASE_POINT0, echo, target, true);
            }, 1s);
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(script::CheckProc);
            OnEffectProc += AuraEffectProcFn(script::HandleProc, EFFECT_0, SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override { return new script(); }
};

class spell_apoc_priest_dot : public SpellScriptLoader
{
public:
    spell_apoc_priest_dot() : SpellScriptLoader("spell_apoc_priest_dot") { }

    class script : public AuraScript
    {
        PrepareAuraScript(script);

        bool Validate(SpellInfo const* spellInfo) override
        {
            for (SpellEffectInfo const& effect : spellInfo->Effects)
                if (effect.IsAura(SPELL_AURA_PERIODIC_DAMAGE) ||
                    effect.IsAura(SPELL_AURA_PERIODIC_LEECH))
                    return true;

            return false;
        }

        static bool IsTrackedDotEffect(AuraEffect const* aurEff)
        {
            AuraType type = aurEff->GetAuraType();
            return type == SPELL_AURA_PERIODIC_DAMAGE ||
                type == SPELL_AURA_PERIODIC_LEECH;
        }

        void CalculatePeriodic(AuraEffect const* aurEff, bool&, int32& amplitude)
        {
            if (!IsTrackedDotEffect(aurEff))
                return;

            Unit* caster = GetCaster();
            if (caster && caster->HasAura(SPELL_ACCELERATED_MISERY))
                amplitude = std::max<int32>(1,
                    int32(amplitude * caster->GetFloatValue(UNIT_MOD_CAST_SPEED)));
        }

        void HandleApply(AuraEffect const* aurEff, AuraEffectHandleModes mode)
        {
            if (!IsTrackedDotEffect(aurEff))
                return;

            Unit* caster = GetCaster();
            if (!caster)
                return;
            RegisterDot(caster->GetGUID(), GetTarget()->GetGUID());
            if ((mode & AURA_EFFECT_HANDLE_REAPPLY) &&
                IsRank(GetSpellInfo(), SPELL_DEVOURING_PLAGUE_R1) &&
                caster->HasAura(SPELL_DEVOURING_ECHO))
                EruptDevouringEcho(caster->ToPlayer(), GetTarget(), true);
        }

        void HandleRemove(AuraEffect const* aurEff, AuraEffectHandleModes)
        {
            if (!IsTrackedDotEffect(aurEff))
                return;

            Unit* caster = GetCaster();
            Unit* target = GetTarget();
            if (!caster)
                return;
            if (!CountDots(target, caster->GetGUID()))
                UnregisterDot(caster->GetGUID(), target->GetGUID());
            if (IsRank(GetSpellInfo(), SPELL_DEVOURING_PLAGUE_R1) &&
                caster->HasAura(SPELL_DEVOURING_ECHO))
            {
                AuraRemoveMode mode = GetTargetApplication()->GetRemoveMode();
                if (mode == AURA_REMOVE_BY_EXPIRE || mode == AURA_REMOVE_BY_ENEMY_SPELL ||
                    mode == AURA_REMOVE_BY_DEATH)
                    EruptDevouringEcho(caster->ToPlayer(), target,
                        mode != AURA_REMOVE_BY_DEATH);
            }
        }

        void Register() override
        {
            DoEffectCalcPeriodic += AuraEffectCalcPeriodicFn(script::CalculatePeriodic,
                EFFECT_ALL, SPELL_AURA_ANY);
            AfterEffectApply += AuraEffectApplyFn(script::HandleApply, EFFECT_ALL,
                SPELL_AURA_ANY,
                AuraEffectHandleModes(AURA_EFFECT_HANDLE_REAL | AURA_EFFECT_HANDLE_REAPPLY));
            AfterEffectRemove += AuraEffectRemoveFn(script::HandleRemove, EFFECT_ALL,
                SPELL_AURA_ANY, AURA_EFFECT_HANDLE_REAL);
        }
    };

    AuraScript* GetAuraScript() const override { return new script(); }
};

class spell_apoc_priest_mind_blast : public SpellScriptLoader
{
public:
    spell_apoc_priest_mind_blast() : SpellScriptLoader("spell_apoc_priest_mind_blast") { }

    class script : public SpellScript
    {
        PrepareSpellScript(script);

        void HandleHit(SpellEffIndex)
        {
            Unit* caster = GetCaster();
            Unit* primary = GetHitUnit();
            if (!caster || !primary || GetHitDamage() <= 0)
                return;
            if (caster->HasAura(SPELL_VOID_PRESSURE) && CountDots(primary, caster->GetGUID()))
                for (uint8 i = 0; i < 3; ++i)
                    AddTargetStack(caster, primary, SPELL_VOID_PRESENCE, 50,
                        caster->GetAuraEffect(SPELL_VOID_PRESSURE, EFFECT_0));
            if (!caster->HasAura(SPELL_SPREADING_DARKNESS))
                return;
            std::list<Unit*> targets = GetNearbyEnemies(primary, caster, NEARBY_RADIUS);
            targets.remove(primary);
            targets.sort([caster](Unit* left, Unit* right)
            {
                uint8 leftMissing = !left->GetAuraOfRankedSpell(SPELL_SHADOW_WORD_PAIN_R1,
                    caster->GetGUID()) + !left->GetAuraOfRankedSpell(SPELL_VAMPIRIC_TOUCH_R1,
                    caster->GetGUID());
                uint8 rightMissing = !right->GetAuraOfRankedSpell(SPELL_SHADOW_WORD_PAIN_R1,
                    caster->GetGUID()) + !right->GetAuraOfRankedSpell(SPELL_VAMPIRIC_TOUCH_R1,
                    caster->GetGUID());
                return leftMissing > rightMissing;
            });
            if (targets.empty())
                return;
            Unit* target = targets.front();
            for (uint32 firstRank : {SPELL_SHADOW_WORD_PAIN_R1, SPELL_VAMPIRIC_TOUCH_R1})
                if (Aura* source = primary->GetAuraOfRankedSpell(firstRank, caster->GetGUID()))
                {
                    Aura* existing = target->GetAuraOfRankedSpell(firstRank, caster->GetGUID());
                    if (!existing || existing->GetDuration() < source->GetMaxDuration())
                        caster->CastSpell(target, source->GetId(), true);
                }
            if (Aura* source = primary->GetAuraOfRankedSpell(
                SPELL_DEVOURING_PLAGUE_R1, caster->GetGUID()))
                if (AuraEffect const* effect = source->GetEffect(EFFECT_0))
                    caster->CastCustomSpell(SPELL_COPIED_DEVOURING_PLAGUE,
                        SPELLVALUE_BASE_POINT0, effect->GetAmount(), target, true);
        }

        void Register() override
        {
            OnEffectHitTarget += SpellEffectFn(script::HandleHit, EFFECT_0,
                SPELL_EFFECT_SCHOOL_DAMAGE);
        }
    };

    SpellScript* GetSpellScript() const override { return new script(); }
};

class spell_apoc_priest_mind_flay : public SpellScriptLoader
{
public:
    spell_apoc_priest_mind_flay() : SpellScriptLoader("spell_apoc_priest_mind_flay") { }

    class script : public SpellScript
    {
        PrepareSpellScript(script);

        void HandleHit(SpellEffIndex)
        {
            Unit* caster = GetCaster();
            Unit* target = GetHitUnit();
            if (caster && target && GetHitDamage() > 0 &&
                caster->HasAura(SPELL_VOID_PRESSURE) && CountDots(target, caster->GetGUID()))
                AddTargetStack(caster, target, SPELL_VOID_PRESENCE, 50,
                    caster->GetAuraEffect(SPELL_VOID_PRESSURE, EFFECT_0));
        }

        void Register() override
        {
            OnEffectHitTarget += SpellEffectFn(script::HandleHit, EFFECT_0,
                SPELL_EFFECT_SCHOOL_DAMAGE);
        }
    };

    SpellScript* GetSpellScript() const override { return new script(); }
};

class spell_apoc_priest_devouring_echo : public SpellScriptLoader
{
public:
    spell_apoc_priest_devouring_echo()
        : SpellScriptLoader("spell_apoc_priest_devouring_echo") { }

    class script : public AuraScript
    {
        PrepareAuraScript(script);

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            DamageInfo* damage = eventInfo.GetDamageInfo();
            SpellInfo const* spellInfo = eventInfo.GetSpellInfo();
            return damage && damage->GetDamage() && damage->GetVictim() &&
                damage->GetAttacker() == GetTarget() &&
                (eventInfo.GetTypeMask() & PROC_FLAG_DONE_PERIODIC) &&
                IsRank(spellInfo, SPELL_DEVOURING_PLAGUE_R1);
        }

        void HandleProc(AuraEffect const*, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();
            Unit* caster = GetTarget();
            DamageInfo* damage = eventInfo.GetDamageInfo();
            uint32 amount = CalculatePct(damage->GetDamage(), 20);
            uint32 cap = caster->CountPctFromMaxHealth(15);
            std::lock_guard<std::mutex> lock(PriestStateMutex);
            DotKey key{caster->GetGUID(), damage->GetVictim()->GetGUID()};
            DevouringEchoAmounts[key] = std::min(cap,
                DevouringEchoAmounts[key] + amount);
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(script::CheckProc);
            OnEffectProc += AuraEffectProcFn(script::HandleProc, EFFECT_0,
                SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override { return new script(); }
};

class spell_apoc_priest_void_eruption : public SpellScriptLoader
{
public:
    spell_apoc_priest_void_eruption() : SpellScriptLoader("spell_apoc_priest_void_eruption") { }

    class script : public SpellScript
    {
        PrepareSpellScript(script);

        void Handle(SpellEffIndex)
        {
            Player* caster = GetCaster()->ToPlayer();
            if (!caster)
                return;
            SpellInfo const* mindBlast = sSpellMgr->GetSpellInfo(48127);
            if (!mindBlast)
                return;
            int32 baseDamage = mindBlast->Effects[EFFECT_0].CalcValue(caster);
            for (ObjectGuid guid : GetDotTargets(caster->GetGUID()))
            {
                Unit* target = ObjectAccessor::GetUnit(*caster, guid);
                uint8 dots = target ? CountDots(target, caster->GetGUID()) : 0;
                if (!target || !target->IsAlive() || !target->IsInWorld() ||
                    !caster->IsInMap(target) || !caster->IsValidAttackTarget(target) || !dots)
                    continue;
                int32 damage = CalculatePct(baseDamage, 100 + 20 * dots);
                caster->CastCustomSpell(SPELL_VOID_ERUPTION_DAMAGE,
                    SPELLVALUE_BASE_POINT0, damage, target, true);
                if (Aura* aura = target->GetAuraOfRankedSpell(
                    SPELL_SHADOW_WORD_PAIN_R1, caster->GetGUID()))
                    aura->RefreshDuration(false);
                if (Aura* aura = target->GetAuraOfRankedSpell(
                    SPELL_VAMPIRIC_TOUCH_R1, caster->GetGUID()))
                    aura->RefreshDuration(false);
                if (Aura* aura = target->GetAuraOfRankedSpell(
                    SPELL_DEVOURING_PLAGUE_R1, caster->GetGUID()))
                {
                    EruptDevouringEcho(caster, target, true);
                    aura->RefreshDuration(false);
                }
                if (Aura* aura = target->GetAura(
                    SPELL_COPIED_DEVOURING_PLAGUE, caster->GetGUID()))
                    aura->RefreshDuration(false);
            }
        }

        void Register() override
        {
            OnEffectHitTarget += SpellEffectFn(script::Handle, EFFECT_0, SPELL_EFFECT_DUMMY);
        }
    };

    SpellScript* GetSpellScript() const override { return new script(); }
};

class apoc_priest_unit : public UnitScript
{
public:
    apoc_priest_unit() : UnitScript("apoc_priest_unit") { }

    void ModifySpellDamageTaken(Unit*, Unit* attacker, int32& damage,
        SpellInfo const* spellInfo) override
    {
        Player* priest = GetPriestOwner(attacker);
        if (!priest || damage <= 0 || !spellInfo || IsCustomHelper(spellInfo->Id))
            return;
        if (priest->HasAura(SPELL_INNER_RENEWAL))
            damage = CalculatePct(damage, 85);
        if (spellInfo->SpellFamilyName == SPELLFAMILY_PRIEST &&
            priest->HasAura(SPELL_ARCHANGEL_BUFF))
            if (Aura* aura = priest->GetAura(SPELL_ARCHANGEL_BUFF))
                AddPct(damage, aura->GetEffect(EFFECT_0)->GetAmount());
        bool holy = IsPriestHoly(spellInfo);
        bool direct = IsDirectSpell(spellInfo);
        if (holy && priest->HasAura(SPELL_WRATHFUL_SERAPH))
        {
            if (IsRank(spellInfo, SPELL_SMITE_R1) || IsRank(spellInfo, SPELL_HOLY_FIRE_R1))
                AddPct(damage, 40);
            else if (IsRank(spellInfo, SPELL_HOLY_NOVA_R1))
                AddPct(damage, 325);
        }
        if (holy && direct && !IsRank(spellInfo, SPELL_HOLY_NOVA_R1))
        {
            HolyCastState state = GetHolyCastState(priest, spellInfo);
            AddPct(damage,
                state.RapidPct + state.ConcordPct + state.JudgmentPct);
            std::lock_guard<std::mutex> lock(PriestStateMutex);
            LastHolyAmounts[priest->GetGUID()] = damage;
        }
    }

    void ModifyPeriodicDamageAurasTick(Unit*, Unit* attacker, uint32& damage,
        SpellInfo const* spellInfo) override
    {
        Player* priest = GetPriestOwner(attacker);
        if (!priest || !damage || !spellInfo || IsCustomHelper(spellInfo->Id))
            return;
        if (priest->HasAura(SPELL_INNER_RENEWAL))
            damage = CalculatePct(damage, 85);
        if (spellInfo->SpellFamilyName == SPELLFAMILY_PRIEST &&
            priest->HasAura(SPELL_ARCHANGEL_BUFF))
            if (Aura* aura = priest->GetAura(SPELL_ARCHANGEL_BUFF))
                AddPct(damage, aura->GetEffect(EFFECT_0)->GetAmount());
        if (priest->HasAura(SPELL_WRATHFUL_SERAPH) &&
            IsRank(spellInfo, SPELL_HOLY_FIRE_R1))
            AddPct(damage, 40);
    }

    void ModifyHealReceived(Unit*, Unit* healer, uint32& heal,
        SpellInfo const* spellInfo) override
    {
        Player* priest = GetPriestOwner(healer);
        if (!priest || !heal || !spellInfo || IsCustomHelper(spellInfo->Id))
            return;
        if (priest->HasAura(SPELL_INNER_RENEWAL))
            heal = CalculatePct(heal, 85);
        if (spellInfo->SpellFamilyName == SPELLFAMILY_PRIEST &&
            priest->HasAura(SPELL_ARCHANGEL_BUFF))
            if (Aura* aura = priest->GetAura(SPELL_ARCHANGEL_BUFF))
                AddPct(heal, aura->GetEffect(EFFECT_0)->GetAmount());
        bool holy = IsPriestHoly(spellInfo);
        bool direct = IsDirectSpell(spellInfo);
        if (holy && priest->HasAura(SPELL_WRATHFUL_SERAPH))
        {
            if (IsRank(spellInfo, SPELL_FLASH_HEAL_R1) ||
                IsRank(spellInfo, SPELL_GREATER_HEAL_R1))
                heal = CalculatePct(heal, 85);
            else if (IsRank(spellInfo, SPELL_HOLY_NOVA_R1))
                heal = CalculatePct(heal, 75);
        }
        if (holy && direct)
        {
            HolyCastState state = GetHolyCastState(priest, spellInfo);
            AddPct(heal,
                state.RapidPct + state.ConcordPct + state.JudgmentPct);
            std::lock_guard<std::mutex> lock(PriestStateMutex);
            LastHolyAmounts[priest->GetGUID()] = heal;
        }
    }

    void OnDamage(Unit* attacker, Unit*, uint32& damage) override
    {
        Creature* fiend = attacker ? attacker->ToCreature() : nullptr;
        Player* owner = fiend ? fiend->GetCharmerOrOwnerPlayerOrPlayerItself() : nullptr;
        if (!damage || !fiend || fiend->GetEntry() != NPC_SHADOWFIEND || !owner ||
            !owner->HasAura(SPELL_FAITHFUL_SHADOWFIEND))
            return;
        owner->ModifyPower(POWER_MANA,
            CalculatePct(owner->GetMaxPower(POWER_MANA), 1));
    }
};

class apoc_priest_player : public PlayerScript
{
public:
    apoc_priest_player() : PlayerScript("apoc_priest_player") { }

    void OnPlayerSpellCast(Player* player, Spell* spell, bool) override
    {
        if (!player || !spell || spell->IsTriggered())
            return;
        SpellInfo const* spellInfo = spell->GetSpellInfo();
        Unit* target = spell->m_targets.GetUnitTarget();
        if (!spellInfo)
            return;
        if (player->HasAura(SPELL_EVANGELISM) &&
            (IsRank(spellInfo, SPELL_SMITE_R1) || IsRank(spellInfo, SPELL_HOLY_FIRE_R1) ||
                (IsRank(spellInfo, SPELL_PENANCE_R1) && target &&
                    player->IsValidAttackTarget(target))))
            AddStack(player, SPELL_EVANGELISM_STACK, 5,
                player->GetAuraEffect(SPELL_EVANGELISM, EFFECT_0));
        if (IsPriestHoly(spellInfo) && IsDirectSpell(spellInfo) &&
            !IsCustomHelper(spellInfo->Id))
        {
            HolyCastState state;
            state.SpellId = spellInfo->Id;
            if (!IsPenance(spellInfo))
                if (Aura* bonus = player->GetAura(SPELL_RAPID_PENANCE_BONUS))
                {
                    state.RapidPct = bonus->GetStackAmount() * 5;
                    player->RemoveAurasDueToSpell(SPELL_RAPID_PENANCE_BONUS);
                }
            bool healingRole = spellInfo->IsPositive() ||
                IsRank(spellInfo, SPELL_HOLY_NOVA_R1);
            if (player->HasAura(SPELL_DIVINE_CONCORD))
            {
                if (Aura* concord = player->GetAura(
                    healingRole ? SPELL_MERCY : SPELL_WRATH))
                {
                    state.ConcordPct = 15;
                    concord->ModStackAmount(-1);
                }
                AddStack(player, healingRole ? SPELL_WRATH : SPELL_MERCY, 10,
                    player->GetAuraEffect(SPELL_DIVINE_CONCORD, EFFECT_0));
            }
            if (Aura* charges = player->GetAura(SPELL_JUDGMENT_CHARGES))
                if (IsRank(spellInfo, SPELL_SMITE_R1) ||
                    IsRank(spellInfo, SPELL_GREATER_HEAL_R1) ||
                    IsRank(spellInfo, SPELL_HOLY_FIRE_R1) ||
                    IsRank(spellInfo, SPELL_FLASH_HEAL_R1))
                {
                    if (IsRank(spellInfo, SPELL_HOLY_FIRE_R1) ||
                        IsRank(spellInfo, SPELL_FLASH_HEAL_R1))
                        state.JudgmentPct = charges->GetStackAmount() * 8;
                    player->RemoveAurasDueToSpell(SPELL_JUDGMENT_CHARGES);
                }
            ObjectGuid casterGuid = player->GetGUID();
            {
                std::lock_guard<std::mutex> lock(PriestStateMutex);
                HolyCastStates[casterGuid] = state;
            }
            player->m_Events.AddEventAtOffset([casterGuid, spellId = spellInfo->Id]()
            {
                std::lock_guard<std::mutex> lock(PriestStateMutex);
                auto itr = HolyCastStates.find(casterGuid);
                if (itr != HolyCastStates.end() && itr->second.SpellId == spellId)
                    HolyCastStates.erase(itr);
            }, 10s);
        }
    }

    void OnPlayerBeforeTempSummonInitStats(Player* player, TempSummon* summon,
        uint32& duration) override
    {
        if (player && summon && summon->GetEntry() == NPC_SHADOWFIEND &&
            player->HasAura(SPELL_FAITHFUL_SHADOWFIEND))
            duration += 10000;
    }

    void OnPlayerLogout(Player* player) override
    {
        if (player)
            ClearPriestState(player->GetGUID());
    }
};

void AddModApocalipsePriestSpellScripts()
{
    new spell_apoc_priest_spiritual_conservation();
    new spell_apoc_priest_rapid_surge();
    new spell_apoc_priest_inner_renewal();
    new spell_apoc_priest_rapid_penance();
    new spell_apoc_priest_archangel();
    new spell_apoc_priest_atonement();
    new spell_apoc_priest_radiance();
    new spell_apoc_priest_blessed_echoes();
    new spell_apoc_priest_dot();
    new spell_apoc_priest_mind_blast();
    new spell_apoc_priest_mind_flay();
    new spell_apoc_priest_devouring_echo();
    new spell_apoc_priest_void_eruption();
    new apoc_priest_unit();
    new apoc_priest_player();
}

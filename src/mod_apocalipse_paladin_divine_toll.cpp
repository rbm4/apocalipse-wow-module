#include "CellImpl.h"
#include "GridNotifiers.h"
#include "GridNotifiersImpl.h"
#include "ObjectAccessor.h"
#include "Player.h"
#include "Random.h"
#include "Spell.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"

#include <algorithm>
#include <list>

namespace
{
enum ApocalipsePaladinDivineTollSpells
{
    SPELL_PALADIN_JUDGEMENT_OF_LIGHT = 20271,
    SPELL_PALADIN_SEAL_OF_COMMAND = 20375,
    SPELL_PALADIN_SEAL_OF_COMMAND_CLEAVE = 20424,
    SPELL_PALADIN_JUDGEMENT_OF_COMMAND = 20467,
    SPELL_PALADIN_SEAL_OF_RIGHTEOUSNESS_DAMAGE = 25742,
    SPELL_PALADIN_JUDGEMENT_OF_VENGEANCE = 31804,
    SPELL_PALADIN_HOLY_VENGEANCE = 31803,
    SPELL_PALADIN_JUDGEMENT_OF_BLOOD = 32220,
    SPELL_PALADIN_SEAL_OF_VENGEANCE_DAMAGE = 42463,
    SPELL_PALADIN_JUDGEMENT_OF_JUSTICE = 53407,
    SPELL_PALADIN_JUDGEMENT_OF_WISDOM = 53408,
    SPELL_PALADIN_JUDGEMENT_OF_MARTYR = 53725,
    SPELL_PALADIN_JUDGEMENT_OF_CORRUPTION = 53733,
    SPELL_PALADIN_SEAL_OF_CORRUPTION_DAMAGE = 53739,
    SPELL_PALADIN_BLOOD_CORRUPTION = 53742,
    SPELL_PALADIN_JUDGEMENT_DAMAGE = 54158,
    SPELL_PALADIN_JUDGEMENT_OF_JUSTICE_DEBUFF = 20184,
    SPELL_APOC_PALADIN_DIVINE_TOLL = 901024,
    SPELL_APOC_PALADIN_DIVINE_TOLL_IMPACT_MARKER = 901025,
    SPELL_APOC_PALADIN_DIVINE_TOLL_VISUAL = 901026
};

constexpr uint32 PALADIN_ICON_JUDGEMENTS_OF_THE_JUST = 3015;
constexpr uint32 DIVINE_TOLL_MIN_IMPACTS = 3;
constexpr uint32 DIVINE_TOLL_MAX_IMPACTS = 6;
constexpr uint32 DIVINE_TOLL_IMPACT_INTERVAL_MS = 500;
constexpr int32 DIVINE_TOLL_DAMAGE_PCT = 50;
constexpr int32 DIVINE_TOLL_HIT_BONUS_PCT = 10000;
constexpr int32 DIVINE_TOLL_WISE_CONSUMED = 0x01;
constexpr int32 DIVINE_TOLL_JUDGEMENT_RESET = 0x02;

bool HasJudgementsOfTheJust(Unit const* caster)
{
    return caster && caster->GetAuraEffect(
        SPELL_AURA_ADD_FLAT_MODIFIER, SPELLFAMILY_PALADIN,
        PALADIN_ICON_JUDGEMENTS_OF_THE_JUST, 0) != nullptr;
}

struct ActiveSeal
{
    AuraEffect const* effect = nullptr;
    uint32 judgementSpellId = SPELL_PALADIN_JUDGEMENT_DAMAGE;
};

ActiveSeal GetActiveSeal(Unit* caster)
{
    ActiveSeal seal;
    for (AuraEffect const* auraEffect :
        caster->GetAuraEffectsByType(SPELL_AURA_DUMMY))
    {
        if (auraEffect->GetSpellInfo()->GetSpellSpecific() !=
            SPELL_SPECIFIC_SEAL)
            continue;

        if (!seal.effect)
            seal.effect = auraEffect;
        if (auraEffect->GetEffIndex() == EFFECT_2 &&
            auraEffect->GetAmount() > 0 &&
            sSpellMgr->GetSpellInfo(uint32(auraEffect->GetAmount())))
        {
            seal.effect = auraEffect;
            seal.judgementSpellId = uint32(auraEffect->GetAmount());
            break;
        }
    }

    return seal;
}

bool IsDivineTollCastLocked(Player const* caster)
{
    return caster->HasUnitState(UNIT_STATE_CONTROLLED) ||
        caster->HasAuraType(SPELL_AURA_MOD_SILENCE) ||
        caster->HasAuraType(SPELL_AURA_MOD_PACIFY) ||
        caster->HasAuraType(SPELL_AURA_MOD_PACIFY_SILENCE);
}

bool IsValidDivineTollTarget(Player* caster, Unit* target, float range)
{
    return target && target->IsInWorld() && target->IsAlive() &&
        caster->IsInMap(target) && caster->IsWithinDistInMap(target, range) &&
        caster->IsWithinLOSInMap(target) &&
        caster->IsValidAttackTarget(target);
}

Unit* FindNearestDivineTollTarget(Player* caster, float range)
{
    std::list<Unit*> targets;
    Acore::AnyUnfriendlyUnitInObjectRangeCheck check(
        caster, caster, range);
    Acore::UnitListSearcher<
        Acore::AnyUnfriendlyUnitInObjectRangeCheck> searcher(
            caster, targets, check);
    Cell::VisitObjects(caster, searcher, range);

    targets.remove_if([caster, range](Unit* target)
    {
        return !IsValidDivineTollTarget(caster, target, range);
    });
    if (targets.empty())
        return nullptr;

    return *std::min_element(targets.begin(), targets.end(),
        [caster](Unit const* left, Unit const* right)
        {
            return caster->GetDistance(left) < caster->GetDistance(right);
        });
}

bool IsDivineTollDamageSpell(uint32 spellId)
{
    switch (spellId)
    {
        case SPELL_PALADIN_SEAL_OF_COMMAND_CLEAVE:
        case SPELL_PALADIN_JUDGEMENT_OF_COMMAND:
        case SPELL_PALADIN_SEAL_OF_RIGHTEOUSNESS_DAMAGE:
        case SPELL_PALADIN_JUDGEMENT_OF_VENGEANCE:
        case SPELL_PALADIN_JUDGEMENT_OF_BLOOD:
        case SPELL_PALADIN_SEAL_OF_VENGEANCE_DAMAGE:
        case SPELL_PALADIN_JUDGEMENT_OF_MARTYR:
        case SPELL_PALADIN_JUDGEMENT_OF_CORRUPTION:
        case SPELL_PALADIN_SEAL_OF_CORRUPTION_DAMAGE:
        case SPELL_PALADIN_JUDGEMENT_DAMAGE:
            return true;
        default:
            return false;
    }
}

void SetSequenceState(AuraEffect* stateEffect, int32 state)
{
    stateEffect->ChangeAmount(state, false);
}

void ResetJudgementCooldown(Player* caster, AuraEffect* stateEffect)
{
    int32 state = stateEffect->GetAmount();
    if (state & DIVINE_TOLL_JUDGEMENT_RESET)
        return;

    SpellInfo const* justice =
        sSpellMgr->GetSpellInfo(SPELL_PALADIN_JUDGEMENT_OF_JUSTICE);
    if (justice->GetCategory())
        caster->RemoveCategoryCooldown(justice->GetCategory());
    else
    {
        caster->RemoveSpellCooldown(SPELL_PALADIN_JUDGEMENT_OF_LIGHT, true);
        caster->RemoveSpellCooldown(SPELL_PALADIN_JUDGEMENT_OF_JUSTICE, true);
        caster->RemoveSpellCooldown(SPELL_PALADIN_JUDGEMENT_OF_WISDOM, true);
    }

    SetSequenceState(
        stateEffect, state | DIVINE_TOLL_JUDGEMENT_RESET);
}

void ApplyVengeanceStack(
    Player* caster, Unit* target, AuraEffect const* sealEffect,
    uint32 judgementSpellId)
{
    uint32 stackSpellId = 0;
    if (judgementSpellId == SPELL_PALADIN_JUDGEMENT_OF_VENGEANCE)
        stackSpellId = SPELL_PALADIN_HOLY_VENGEANCE;
    else if (judgementSpellId == SPELL_PALADIN_JUDGEMENT_OF_CORRUPTION)
        stackSpellId = SPELL_PALADIN_BLOOD_CORRUPTION;

    if (stackSpellId)
        caster->CastSpell(target, stackSpellId, true, nullptr, sealEffect);
}

void CastCommandCleave(
    Player* caster, Unit* target, AuraEffect const* sealEffect)
{
    if (sealEffect->GetId() != SPELL_PALADIN_SEAL_OF_COMMAND ||
        !HasJudgementsOfTheJust(caster) || !target->IsAlive())
        return;

    caster->CastCustomSpell(
        SPELL_PALADIN_SEAL_OF_COMMAND_CLEAVE,
        SPELLVALUE_MAX_TARGETS, 3, target, true, nullptr, sealEffect);
}

void ExecuteDivineTollImpact(
    ObjectGuid casterGuid, ObjectGuid originalTargetGuid, uint32 originalMapId,
    bool finalImpact)
{
    Player* caster = ObjectAccessor::FindPlayer(casterGuid);
    if (!caster || !caster->IsInWorld() || !caster->IsAlive() ||
        !caster->HasAura(SPELL_APOC_PALADIN_DIVINE_TOLL))
        return;

    if (caster->GetMapId() != originalMapId)
    {
        caster->RemoveAurasDueToSpell(SPELL_APOC_PALADIN_DIVINE_TOLL);
        return;
    }

    ActiveSeal activeSeal = GetActiveSeal(caster);
    if (!activeSeal.effect || IsDivineTollCastLocked(caster))
    {
        caster->RemoveAurasDueToSpell(SPELL_APOC_PALADIN_DIVINE_TOLL);
        return;
    }

    SpellInfo const* judgement =
        sSpellMgr->GetSpellInfo(SPELL_PALADIN_JUDGEMENT_OF_JUSTICE);
    float range = judgement->GetMaxRange(false, caster);
    Unit* target = ObjectAccessor::GetUnit(*caster, originalTargetGuid);
    if (!IsValidDivineTollTarget(caster, target, range))
        target = FindNearestDivineTollTarget(caster, range);

    if (target)
    {
        uint32 judgementSpellId = activeSeal.judgementSpellId;
        SpellInfo const* damageSpell =
            sSpellMgr->GetSpellInfo(judgementSpellId);
        bool immune = target->IsImmunedToSpell(damageSpell) ||
            target->IsImmunedToDamage(caster, damageSpell);
        if (!immune)
        {
            caster->CastSpell(
                caster, SPELL_APOC_PALADIN_DIVINE_TOLL_IMPACT_MARKER,
                TRIGGERED_FULL_MASK);
            AuraEffect const* impactMarker = caster->GetAuraEffect(
                SPELL_APOC_PALADIN_DIVINE_TOLL_IMPACT_MARKER, EFFECT_0);
            AuraEffect* stateEffect = caster->GetAuraEffect(
                SPELL_APOC_PALADIN_DIVINE_TOLL, EFFECT_1);
            if (impactMarker && stateEffect)
            {
                caster->CastSpell(
                    target, SPELL_APOC_PALADIN_DIVINE_TOLL_VISUAL,
                    TRIGGERED_FULL_MASK, nullptr, impactMarker,
                    caster->GetGUID());
                caster->CastSpell(
                    target, SPELL_PALADIN_JUDGEMENT_OF_JUSTICE_DEBUFF,
                    TRIGGERED_FULL_MASK, nullptr, impactMarker,
                    caster->GetGUID());
                ApplyVengeanceStack(
                    caster, target, activeSeal.effect, judgementSpellId);

                SpellCastResult result = caster->CastSpell(
                    target, judgementSpellId,
                    TriggerCastFlags(
                        TRIGGERED_FULL_MASK &
                            ~TRIGGERED_DISALLOW_PROC_EVENTS),
                    nullptr, impactMarker, caster->GetGUID());
                if (result == SPELL_CAST_OK && caster->IsAlive() &&
                    caster->HasAura(SPELL_APOC_PALADIN_DIVINE_TOLL))
                {
                    stateEffect = caster->GetAuraEffect(
                        SPELL_APOC_PALADIN_DIVINE_TOLL, EFFECT_1);
                    activeSeal = GetActiveSeal(caster);
                    if (stateEffect && activeSeal.effect)
                    {
                        ResetJudgementCooldown(caster, stateEffect);
                        CastCommandCleave(
                            caster, target, activeSeal.effect);
                    }
                }
            }
            caster->RemoveAurasDueToSpell(
                SPELL_APOC_PALADIN_DIVINE_TOLL_IMPACT_MARKER);
        }
    }

    if (finalImpact)
        caster->RemoveAurasDueToSpell(SPELL_APOC_PALADIN_DIVINE_TOLL);
}
}

class spell_apoc_paladin_divine_toll : public SpellScriptLoader
{
public:
    spell_apoc_paladin_divine_toll()
        : SpellScriptLoader("spell_apoc_paladin_divine_toll") { }

    class divine_toll_SpellScript : public SpellScript
    {
        PrepareSpellScript(divine_toll_SpellScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            if (spellInfo->Id != SPELL_APOC_PALADIN_DIVINE_TOLL ||
                !ValidateSpellInfo({
                    SPELL_PALADIN_JUDGEMENT_OF_LIGHT,
                    SPELL_PALADIN_SEAL_OF_COMMAND_CLEAVE,
                    SPELL_PALADIN_JUDGEMENT_OF_COMMAND,
                    SPELL_PALADIN_SEAL_OF_RIGHTEOUSNESS_DAMAGE,
                    SPELL_PALADIN_JUDGEMENT_OF_VENGEANCE,
                    SPELL_PALADIN_HOLY_VENGEANCE,
                    SPELL_PALADIN_JUDGEMENT_OF_BLOOD,
                    SPELL_PALADIN_SEAL_OF_VENGEANCE_DAMAGE,
                    SPELL_PALADIN_JUDGEMENT_OF_JUSTICE,
                    SPELL_PALADIN_JUDGEMENT_OF_WISDOM,
                    SPELL_PALADIN_JUDGEMENT_OF_MARTYR,
                    SPELL_PALADIN_JUDGEMENT_OF_CORRUPTION,
                    SPELL_PALADIN_SEAL_OF_CORRUPTION_DAMAGE,
                    SPELL_PALADIN_BLOOD_CORRUPTION,
                    SPELL_PALADIN_JUDGEMENT_DAMAGE,
                    SPELL_PALADIN_JUDGEMENT_OF_JUSTICE_DEBUFF,
                    SPELL_APOC_PALADIN_DIVINE_TOLL_IMPACT_MARKER,
                    SPELL_APOC_PALADIN_DIVINE_TOLL_VISUAL
                }))
                return false;

            SpellInfo const* marker = sSpellMgr->GetSpellInfo(
                SPELL_APOC_PALADIN_DIVINE_TOLL_IMPACT_MARKER);
            SpellInfo const* visual = sSpellMgr->GetSpellInfo(
                SPELL_APOC_PALADIN_DIVINE_TOLL_VISUAL);
            SpellInfo const* justice = sSpellMgr->GetSpellInfo(
                SPELL_PALADIN_JUDGEMENT_OF_JUSTICE);
            SpellInfo const* light = sSpellMgr->GetSpellInfo(
                SPELL_PALADIN_JUDGEMENT_OF_LIGHT);
            SpellInfo const* wisdom = sSpellMgr->GetSpellInfo(
                SPELL_PALADIN_JUDGEMENT_OF_WISDOM);

            return spellInfo->RecoveryTime == 60000 &&
                spellInfo->ManaCostPercentage == 10 &&
                spellInfo->GetDuration() >= 4000 &&
                spellInfo->Effects[EFFECT_0].IsEffect(SPELL_EFFECT_DUMMY) &&
                spellInfo->Effects[EFFECT_0].TargetA.GetTarget() ==
                    TARGET_UNIT_TARGET_ENEMY &&
                spellInfo->Effects[EFFECT_1].IsAura(SPELL_AURA_DUMMY) &&
                spellInfo->Effects[EFFECT_1].TargetA.GetTarget() ==
                    TARGET_UNIT_CASTER &&
                marker->Effects[EFFECT_0].IsAura(
                    SPELL_AURA_MOD_HIT_CHANCE) &&
                marker->Effects[EFFECT_0].CalcValue() ==
                    DIVINE_TOLL_HIT_BONUS_PCT &&
                marker->Effects[EFFECT_1].IsAura(
                    SPELL_AURA_MOD_SPELL_HIT_CHANCE) &&
                marker->Effects[EFFECT_1].CalcValue() ==
                    DIVINE_TOLL_HIT_BONUS_PCT &&
                marker->Effects[EFFECT_2].IsAura(
                    SPELL_AURA_MOD_EXPERTISE) &&
                marker->Effects[EFFECT_2].CalcValue() ==
                    DIVINE_TOLL_HIT_BONUS_PCT &&
                visual->Effects[EFFECT_0].IsEffect(SPELL_EFFECT_DUMMY) &&
                visual->Effects[EFFECT_0].TargetA.GetTarget() ==
                    TARGET_UNIT_TARGET_ENEMY &&
                justice->GetCategory() == light->GetCategory() &&
                justice->GetCategory() == wisdom->GetCategory();
        }

        SpellCastResult CheckCast()
        {
            Player* caster = GetCaster()->ToPlayer();
            Unit* target = GetExplTargetUnit();
            if (!caster || !target || !target->IsAlive() ||
                !caster->IsValidAttackTarget(target))
                return SPELL_FAILED_BAD_TARGETS;

            if (!GetActiveSeal(caster).effect)
                return SPELL_FAILED_CASTER_AURASTATE;

            SpellInfo const* judgement = sSpellMgr->GetSpellInfo(
                SPELL_PALADIN_JUDGEMENT_OF_JUSTICE);
            float range = judgement->GetMaxRange(false, caster);
            if (!caster->IsWithinDistInMap(target, range))
                return SPELL_FAILED_OUT_OF_RANGE;
            if (!caster->IsWithinLOSInMap(target))
                return SPELL_FAILED_LINE_OF_SIGHT;

            return SPELL_CAST_OK;
        }

        void ScheduleImpacts()
        {
            Player* caster = GetCaster()->ToPlayer();
            Unit* target = GetExplTargetUnit();
            if (!caster || !target ||
                !caster->HasAura(SPELL_APOC_PALADIN_DIVINE_TOLL))
                return;

            ObjectGuid casterGuid = caster->GetGUID();
            ObjectGuid targetGuid = target->GetGUID();
            uint32 mapId = caster->GetMapId();
            uint32 impactCount = urand(
                DIVINE_TOLL_MIN_IMPACTS, DIVINE_TOLL_MAX_IMPACTS);
            for (uint32 index = 0; index < impactCount; ++index)
            {
                bool finalImpact = index + 1 == impactCount;
                if (!index)
                {
                    ExecuteDivineTollImpact(
                        casterGuid, targetGuid, mapId, finalImpact);
                    continue;
                }

                caster->m_Events.AddEventAtOffset(
                    [casterGuid, targetGuid, mapId, finalImpact]()
                    {
                        ExecuteDivineTollImpact(
                            casterGuid, targetGuid, mapId, finalImpact);
                    }, Milliseconds(index * DIVINE_TOLL_IMPACT_INTERVAL_MS));
            }
        }

        void Register() override
        {
            OnCheckCast += SpellCheckCastFn(
                divine_toll_SpellScript::CheckCast);
            AfterCast += SpellCastFn(
                divine_toll_SpellScript::ScheduleImpacts);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new divine_toll_SpellScript();
    }
};

class spell_apoc_paladin_divine_toll_damage : public SpellScriptLoader
{
public:
    spell_apoc_paladin_divine_toll_damage()
        : SpellScriptLoader("spell_apoc_paladin_divine_toll_damage") { }

    class divine_toll_damage_SpellScript : public SpellScript
    {
        PrepareSpellScript(divine_toll_damage_SpellScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            return IsDivineTollDamageSpell(spellInfo->Id) &&
                ValidateSpellInfo({
                    SPELL_APOC_PALADIN_DIVINE_TOLL_IMPACT_MARKER
                });
        }

        void ScaleDamage()
        {
            if (GetCaster()->HasAura(
                    SPELL_APOC_PALADIN_DIVINE_TOLL_IMPACT_MARKER) &&
                GetHitDamage() > 0)
                SetHitDamage(CalculatePct(
                    GetHitDamage(), DIVINE_TOLL_DAMAGE_PCT));
        }

        void Register() override
        {
            OnHit += SpellHitFn(
                divine_toll_damage_SpellScript::ScaleDamage);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new divine_toll_damage_SpellScript();
    }
};

class spell_apoc_paladin_divine_toll_wise_gate : public SpellScriptLoader
{
public:
    spell_apoc_paladin_divine_toll_wise_gate()
        : SpellScriptLoader("spell_apoc_paladin_divine_toll_wise_gate") { }

    class divine_toll_wise_gate_AuraScript : public AuraScript
    {
        PrepareAuraScript(divine_toll_wise_gate_AuraScript);

        bool Validate(SpellInfo const*) override
        {
            return ValidateSpellInfo({
                SPELL_APOC_PALADIN_DIVINE_TOLL,
                SPELL_APOC_PALADIN_DIVINE_TOLL_IMPACT_MARKER
            });
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Unit* actor = eventInfo.GetActor();
            if (!actor || !actor->HasAura(
                    SPELL_APOC_PALADIN_DIVINE_TOLL_IMPACT_MARKER))
                return true;

            AuraEffect* stateEffect = actor->GetAuraEffect(
                SPELL_APOC_PALADIN_DIVINE_TOLL, EFFECT_1);
            if (!stateEffect ||
                (stateEffect->GetAmount() & DIVINE_TOLL_WISE_CONSUMED))
                return false;

            SetSequenceState(
                stateEffect,
                stateEffect->GetAmount() | DIVINE_TOLL_WISE_CONSUMED);
            return true;
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(
                divine_toll_wise_gate_AuraScript::CheckProc);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new divine_toll_wise_gate_AuraScript();
    }
};

void AddModApocalipsePaladinDivineTollScripts()
{
    new spell_apoc_paladin_divine_toll();
    new spell_apoc_paladin_divine_toll_damage();
    new spell_apoc_paladin_divine_toll_wise_gate();
}

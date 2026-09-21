#include "CellImpl.h"
#include "Containers.h"
#include "GridNotifiers.h"
#include "GridNotifiersImpl.h"
#include "ObjectAccessor.h"
#include "Spell.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

#include <list>

enum ApocalipseWarlockBurningConflagrationSpells
{
    SPELL_APOC_WARLOCK_BURNING_CONFLAGRATION = 901027,
    SPELL_WARLOCK_IMMOLATE_R1                = 348,
    SPELL_WARLOCK_CONFLAGRATE_R1             = 17962
};

namespace
{
constexpr float IMMOLATE_SPREAD_RADIUS = 10.0f;
constexpr std::size_t MAX_IMMOLATE_SPREAD_TARGETS = 3;
}

class spell_apoc_warlock_burning_conflagration : public SpellScriptLoader
{
public:
    spell_apoc_warlock_burning_conflagration()
        : SpellScriptLoader("spell_apoc_warlock_burning_conflagration") { }

    class spell_apoc_warlock_burning_conflagration_SpellScript : public SpellScript
    {
        PrepareSpellScript(spell_apoc_warlock_burning_conflagration_SpellScript);

        bool Load() override
        {
            _primaryTargetGuid.Clear();
            _immolateSpellId = 0;
            return true;
        }

        bool Validate(SpellInfo const* spellInfo) override
        {
            return spellInfo->Effects[EFFECT_0].IsEffect(
                    SPELL_EFFECT_SCHOOL_DAMAGE) &&
                spellInfo->TargetAuraState == AURA_STATE_CONFLAGRATE &&
                ValidateSpellInfo({
                    SPELL_APOC_WARLOCK_BURNING_CONFLAGRATION,
                    SPELL_WARLOCK_IMMOLATE_R1,
                    SPELL_WARLOCK_CONFLAGRATE_R1
                });
        }

        void CaptureImmolate(SpellEffIndex /*effIndex*/)
        {
            Unit* caster = GetCaster();
            Unit* target = GetHitUnit();
            if (!caster || !target || target == caster ||
                !caster->HasAura(SPELL_APOC_WARLOCK_BURNING_CONFLAGRATION) ||
                !caster->IsValidAttackTarget(target))
                return;

            Aura* immolate = target->GetAuraOfRankedSpell(
                SPELL_WARLOCK_IMMOLATE_R1, caster->GetGUID());
            if (!immolate)
                return;

            _primaryTargetGuid = target->GetGUID();
            _immolateSpellId = immolate->GetId();
        }

        void SpreadImmolate()
        {
            Unit* caster = GetCaster();
            if (!caster || !_immolateSpellId)
                return;

            if (!caster->HasAura(
                SPELL_APOC_WARLOCK_BURNING_CONFLAGRATION))
                return;

            Unit* primaryTarget = ObjectAccessor::GetUnit(*caster, _primaryTargetGuid);
            if (!primaryTarget || !primaryTarget->IsInWorld() ||
                !caster->IsInMap(primaryTarget))
                return;

            std::list<Unit*> nearbyTargets;
            Acore::AnyUnfriendlyUnitInObjectRangeCheck check(
                primaryTarget, caster, IMMOLATE_SPREAD_RADIUS);
            Acore::UnitListSearcher<
                Acore::AnyUnfriendlyUnitInObjectRangeCheck> searcher(
                    primaryTarget, nearbyTargets, check);
            Cell::VisitObjects(primaryTarget, searcher, IMMOLATE_SPREAD_RADIUS);

            nearbyTargets.remove_if([caster, primaryTarget](Unit* target)
            {
                return !target || target == primaryTarget || !target->IsInWorld() ||
                    !target->IsAlive() || !caster->IsInMap(target) ||
                    !primaryTarget->IsWithinDistInMap(
                        target, IMMOLATE_SPREAD_RADIUS) ||
                    !caster->IsWithinLOSInMap(target) ||
                    !caster->IsValidAttackTarget(target) ||
                    target->GetAuraOfRankedSpell(
                        SPELL_WARLOCK_IMMOLATE_R1, caster->GetGUID());
            });

            Acore::Containers::RandomResize(
                nearbyTargets, MAX_IMMOLATE_SPREAD_TARGETS);
            for (Unit* target : nearbyTargets)
            {
                if (!target->IsAlive() || target->GetAuraOfRankedSpell(
                    SPELL_WARLOCK_IMMOLATE_R1, caster->GetGUID()))
                    continue;

                AuraEffect const* passive = caster->GetAuraEffect(
                    SPELL_APOC_WARLOCK_BURNING_CONFLAGRATION, EFFECT_0);
                if (!passive)
                    break;

                caster->CastSpell(
                    target, _immolateSpellId,
                    TriggerCastFlags(
                        TRIGGERED_FULL_MASK &
                            ~TRIGGERED_DISALLOW_PROC_EVENTS),
                    nullptr, passive);
            }
        }

        void Register() override
        {
            OnEffectHitTarget += SpellEffectFn(
                spell_apoc_warlock_burning_conflagration_SpellScript::CaptureImmolate,
                EFFECT_0, SPELL_EFFECT_SCHOOL_DAMAGE);
            AfterHit += SpellHitFn(
                spell_apoc_warlock_burning_conflagration_SpellScript::SpreadImmolate);
        }

    private:
        ObjectGuid _primaryTargetGuid;
        uint32 _immolateSpellId;
    };

    SpellScript* GetSpellScript() const override
    {
        return new spell_apoc_warlock_burning_conflagration_SpellScript();
    }
};

void AddModApocalipseWarlockBurningConflagrationScripts()
{
    new spell_apoc_warlock_burning_conflagration();
}

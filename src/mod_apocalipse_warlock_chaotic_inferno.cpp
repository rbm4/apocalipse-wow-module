#include "Creature.h"
#include "CreatureAI.h"
#include "PetDefines.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "Spell.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "TemporarySummon.h"
#include "Unit.h"

#include <algorithm>
#include <list>
#include <vector>

namespace
{
enum ApocalipseWarlockChaoticInfernoSpells
{
    SPELL_APOC_WARLOCK_CHAOTIC_INFERNO = 901031,
    SPELL_APOC_WARLOCK_CHAOTIC_INFERNO_SUMMON = 901032,
    SPELL_WARLOCK_INFERNO_EFFECT = 22703
};

enum ApocalipseWarlockChaoticInfernoCreatures
{
    NPC_APOC_WARLOCK_CHAOS_INFERNAL = 900002
};

std::vector<ObjectGuid> GetInfernalGuids(Unit* caster)
{
    std::list<Creature*> infernals;
    caster->GetAllMinionsByEntry(
        infernals, NPC_APOC_WARLOCK_CHAOS_INFERNAL);

    std::vector<ObjectGuid> guids;
    guids.reserve(infernals.size());
    for (Creature const* infernal : infernals)
        guids.push_back(infernal->GetGUID());

    return guids;
}

void StartNewInfernal(Unit* caster, Unit* target,
    std::vector<ObjectGuid> const& existingGuids)
{
    std::list<Creature*> infernals;
    caster->GetAllMinionsByEntry(
        infernals, NPC_APOC_WARLOCK_CHAOS_INFERNAL);

    for (Creature* infernal : infernals)
    {
        bool isNew = std::find(existingGuids.begin(), existingGuids.end(),
            infernal->GetGUID()) == existingGuids.end();
        if (isNew)
            infernal->NearTeleportTo(
                target->GetPositionX(), target->GetPositionY(),
                target->GetPositionZ(), infernal->GetOrientation());

        if (!infernal->GetVictim() && infernal->AI())
            infernal->AI()->AttackStart(target);
    }
}
}

class spell_apoc_warlock_chaotic_inferno : public SpellScriptLoader
{
public:
    spell_apoc_warlock_chaotic_inferno()
        : SpellScriptLoader("spell_apoc_warlock_chaotic_inferno") { }

    class chaotic_inferno_SpellScript : public SpellScript
    {
        PrepareSpellScript(chaotic_inferno_SpellScript);

        bool Validate(SpellInfo const* /*spellInfo*/) override
        {
            return ValidateSpellInfo({
                SPELL_APOC_WARLOCK_CHAOTIC_INFERNO,
                SPELL_APOC_WARLOCK_CHAOTIC_INFERNO_SUMMON,
                SPELL_WARLOCK_INFERNO_EFFECT,
                SPELL_PET_AVOIDANCE,
                SPELL_WARLOCK_PET_SCALING_05,
                SPELL_INFERNAL_SCALING_01,
                SPELL_INFERNAL_SCALING_02,
                SPELL_INFERNAL_SCALING_03,
                SPELL_INFERNAL_SCALING_04
            });
        }

        void HandleAfterHit()
        {
            Unit* caster = GetCaster();
            Unit* target = GetHitUnit();
            if (!caster || !target || !caster->HasAura(
                SPELL_APOC_WARLOCK_CHAOTIC_INFERNO))
                return;

            AuraEffect const* passive = caster->GetAuraEffect(
                SPELL_APOC_WARLOCK_CHAOTIC_INFERNO, EFFECT_0);
            SpellInfo const* summonInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_WARLOCK_CHAOTIC_INFERNO_SUMMON);
            if (!passive || !summonInfo)
                return;

            std::vector<ObjectGuid> existingGuids = GetInfernalGuids(caster);
            SpellCastTargets targets;
            targets.SetDst(*target);
            if (caster->CastSpell(
                targets, summonInfo, nullptr,
                TriggerCastFlags(
                    TRIGGERED_FULL_MASK & ~TRIGGERED_DISALLOW_PROC_EVENTS),
                nullptr, passive, caster->GetGUID()) == SPELL_CAST_OK)
                StartNewInfernal(caster, target, existingGuids);
        }

        void Register() override
        {
            AfterHit += SpellHitFn(
                chaotic_inferno_SpellScript::HandleAfterHit);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new chaotic_inferno_SpellScript();
    }
};

class npc_apoc_warlock_chaos_infernal : public CreatureScript
{
public:
    npc_apoc_warlock_chaos_infernal()
        : CreatureScript("npc_apoc_warlock_chaos_infernal") { }

    struct npc_apoc_warlock_chaos_infernalAI : public CreatureAI
    {
        npc_apoc_warlock_chaos_infernalAI(Creature* creature)
            : CreatureAI(creature) { }

        void InitializeAI() override
        {
            CreatureAI::InitializeAI();
            me->SetReactState(REACT_AGGRESSIVE);
            me->SetSpeed(MOVE_RUN, me->GetCreatureTemplate()->speed_run);
            me->AddAura(SPELL_PET_AVOIDANCE, me);
            me->AddAura(SPELL_WARLOCK_PET_SCALING_05, me);
            me->AddAura(SPELL_INFERNAL_SCALING_01, me);
            me->AddAura(SPELL_INFERNAL_SCALING_02, me);
            me->AddAura(SPELL_INFERNAL_SCALING_03, me);
            me->AddAura(SPELL_INFERNAL_SCALING_04, me);
        }

        void OwnerAttacked(Unit* target) override
        {
            Assist(target);
        }

        void OwnerAttackedBy(Unit* attacker) override
        {
            Assist(attacker);
        }

        void UpdateAI(uint32 /*diff*/) override
        {
            if (!me->GetVictim())
                if (Unit* owner = me->GetOwner())
                    Assist(owner->GetVictim());

            if (!UpdateVictim())
                return;

            DoMeleeAttackIfReady();
        }

    private:
        void Assist(Unit* target)
        {
            if (target && target->IsAlive() &&
                me->IsValidAttackTarget(target) &&
                me->CanCreatureAttack(target))
                AttackStart(target);
        }
    };

    CreatureAI* GetAI(Creature* creature) const override
    {
        return new npc_apoc_warlock_chaos_infernalAI(creature);
    }
};

class apoc_warlock_chaotic_inferno_player : public PlayerScript
{
public:
    apoc_warlock_chaotic_inferno_player()
        : PlayerScript("apoc_warlock_chaotic_inferno_player") { }

    void OnPlayerBeforeGuardianInitStatsForLevel(
        Player*, Guardian* guardian, CreatureTemplate const*,
        PetType& petType) override
    {
        if (guardian->GetEntry() == NPC_APOC_WARLOCK_CHAOS_INFERNAL)
            petType = SUMMON_PET;
    }
};

void AddModApocalipseWarlockChaoticInfernoScripts()
{
    new spell_apoc_warlock_chaotic_inferno();
    new npc_apoc_warlock_chaos_infernal();
    new apoc_warlock_chaotic_inferno_player();
}

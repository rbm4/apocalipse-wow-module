#include "Containers.h"
#include "Player.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

#include <algorithm>
#include <list>

namespace
{
enum ApocalipseDeathKnightRimeShardsSpells
{
    SPELL_APOC_DEATH_KNIGHT_RIME_SHARDS = 901054,
    SPELL_APOC_DEATH_KNIGHT_RIME_SHARDS_BURST = 901055,
    SPELL_DEATH_KNIGHT_FROST_STRIKE_R1 = 49143,
    SPELL_DEATH_KNIGHT_HOWLING_BLAST_R1 = 49184,
    SPELL_DEATH_KNIGHT_FROST_STRIKE_OFF_HAND_R1 = 66196
};

constexpr uint32 RIME_SHARDS_DAMAGE_PCT = 20;
constexpr uint32 RIME_SHARDS_MAX_TARGETS = 10;

bool IsRimeShardsSource(SpellInfo const* spellInfo)
{
    if (!spellInfo || spellInfo->SpellFamilyName != SPELLFAMILY_DEATHKNIGHT)
        return false;

    uint32 firstRank = sSpellMgr->GetFirstSpellInChain(spellInfo->Id);
    return firstRank == SPELL_DEATH_KNIGHT_FROST_STRIKE_R1 ||
        firstRank == SPELL_DEATH_KNIGHT_HOWLING_BLAST_R1 ||
        spellInfo->Id == SPELL_DEATH_KNIGHT_FROST_STRIKE_OFF_HAND_R1;
}
}

class spell_apoc_death_knight_rime_shards : public SpellScriptLoader
{
public:
    spell_apoc_death_knight_rime_shards()
        : SpellScriptLoader("spell_apoc_death_knight_rime_shards") { }

    class rime_shards_AuraScript : public AuraScript
    {
        PrepareAuraScript(rime_shards_AuraScript);

        bool Validate(SpellInfo const* spellInfo) override
        {
            SpellInfo const* burstInfo = sSpellMgr->GetSpellInfo(
                SPELL_APOC_DEATH_KNIGHT_RIME_SHARDS_BURST);
            return spellInfo->Id == SPELL_APOC_DEATH_KNIGHT_RIME_SHARDS &&
                spellInfo->Effects[EFFECT_0].IsAura(SPELL_AURA_DUMMY) &&
                ValidateSpellInfo({
                    SPELL_APOC_DEATH_KNIGHT_RIME_SHARDS_BURST,
                    SPELL_DEATH_KNIGHT_FROST_STRIKE_R1,
                    SPELL_DEATH_KNIGHT_HOWLING_BLAST_R1,
                    SPELL_DEATH_KNIGHT_FROST_STRIKE_OFF_HAND_R1
                }) && burstInfo &&
                burstInfo->GetSchoolMask() == SPELL_SCHOOL_MASK_FROST &&
                burstInfo->MaxAffectedTargets == RIME_SHARDS_MAX_TARGETS &&
                burstInfo->Effects[EFFECT_0].IsEffect(
                    SPELL_EFFECT_SCHOOL_DAMAGE) &&
                burstInfo->Effects[EFFECT_0].TargetA.GetTarget() ==
                    TARGET_DEST_TARGET_ENEMY &&
                burstInfo->Effects[EFFECT_0].TargetB.GetTarget() ==
                    TARGET_UNIT_DEST_AREA_ENEMY;
        }

        bool CheckProc(ProcEventInfo& eventInfo)
        {
            Unit* deathKnight = GetTarget();
            Unit* target = eventInfo.GetProcTarget();
            DamageInfo const* damageInfo = eventInfo.GetDamageInfo();
            return deathKnight && deathKnight->ToPlayer() &&
                eventInfo.GetActor() == deathKnight && target &&
                target->IsAlive() && target != deathKnight && damageInfo &&
                damageInfo->GetDamage() > 0 &&
                (eventInfo.GetHitMask() &
                    (PROC_HIT_NORMAL | PROC_HIT_CRITICAL)) &&
                IsRimeShardsSource(eventInfo.GetSpellInfo());
        }

        void HandleProc(AuraEffect const* aurEff, ProcEventInfo& eventInfo)
        {
            PreventDefaultAction();

            uint32 damage = CalculatePct(
                eventInfo.GetDamageInfo()->GetDamage(),
                RIME_SHARDS_DAMAGE_PCT);
            if (!damage)
                return;

            GetTarget()->CastCustomSpell(
                SPELL_APOC_DEATH_KNIGHT_RIME_SHARDS_BURST,
                SPELLVALUE_BASE_POINT0, int32(damage),
                eventInfo.GetProcTarget(), true, nullptr, aurEff);
        }

        void Register() override
        {
            DoCheckProc += AuraCheckProcFn(
                rime_shards_AuraScript::CheckProc);
            OnEffectProc += AuraEffectProcFn(
                rime_shards_AuraScript::HandleProc, EFFECT_0,
                SPELL_AURA_DUMMY);
        }
    };

    AuraScript* GetAuraScript() const override
    {
        return new rime_shards_AuraScript();
    }
};

class spell_apoc_death_knight_rime_shards_burst : public SpellScriptLoader
{
public:
    spell_apoc_death_knight_rime_shards_burst()
        : SpellScriptLoader("spell_apoc_death_knight_rime_shards_burst") { }

    class rime_shards_burst_SpellScript : public SpellScript
    {
        PrepareSpellScript(rime_shards_burst_SpellScript);

        void SelectTargets(std::list<WorldObject*>& targets)
        {
            Acore::Containers::RandomResize(
                targets, RIME_SHARDS_MAX_TARGETS);
            _targetCount = std::max<uint32>(1, targets.size());
        }

        void ScaleDamage(SpellEffIndex)
        {
            uint64 targetCount = _targetCount;
            uint64 damage = uint32(std::max(0, GetHitDamage()));
            damage = damage * (2 * targetCount - 1) /
                (targetCount * targetCount);
            SetHitDamage(int32(damage));
        }

        void Register() override
        {
            OnObjectAreaTargetSelect += SpellObjectAreaTargetSelectFn(
                rime_shards_burst_SpellScript::SelectTargets, EFFECT_0,
                TARGET_UNIT_DEST_AREA_ENEMY);
            OnEffectHitTarget += SpellEffectFn(
                rime_shards_burst_SpellScript::ScaleDamage, EFFECT_0,
                SPELL_EFFECT_SCHOOL_DAMAGE);
        }

    private:
        uint32 _targetCount = 1;
    };

    SpellScript* GetSpellScript() const override
    {
        return new rime_shards_burst_SpellScript();
    }
};

void AddModApocalipseDeathKnightRimeShardsScripts()
{
    new spell_apoc_death_knight_rime_shards();
    new spell_apoc_death_knight_rime_shards_burst();
}

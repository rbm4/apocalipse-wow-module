#include "Containers.h"
#include "ObjectAccessor.h"
#include "Random.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

#include <map>
#include <mutex>
#include <utility>
#include <vector>

enum ApocalipseMagePyroclasticChainReactionSpells
{
    SPELL_APOC_MAGE_PYROCLASTIC_CHAIN_REACTION = 901003,
    SPELL_MAGE_PYROBLAST_R1                    = 11366,
    SPELL_MAGE_LIVING_BOMB_R1                  = 44457,
    SPELL_MAGE_LIVING_BOMB_EXPLOSION_R1        = 44461
};

namespace
{
constexpr std::size_t MAX_LIVING_BOMB_SPREAD_TARGETS = 2;
constexpr int32 PROPAGATED_LIVING_BOMB_DAMAGE_PCT = 30;

using PropagatedLivingBombKey = std::pair<ObjectGuid, ObjectGuid>;

struct PropagatedLivingBombState
{
    uint64 Token;
    bool RemovalPending;
};

std::map<PropagatedLivingBombKey, PropagatedLivingBombState> propagatedLivingBombs;
std::mutex propagatedLivingBombsMutex;
uint64 propagatedLivingBombToken = 0;

uint64 MarkPropagatedLivingBomb(ObjectGuid casterGuid, ObjectGuid targetGuid)
{
    std::lock_guard<std::mutex> lock(propagatedLivingBombsMutex);
    uint64 token = ++propagatedLivingBombToken;
    propagatedLivingBombs[{ casterGuid, targetGuid }] = { token, false };
    return token;
}

bool IsPropagatedLivingBomb(ObjectGuid casterGuid, ObjectGuid targetGuid)
{
    std::lock_guard<std::mutex> lock(propagatedLivingBombsMutex);
    return propagatedLivingBombs.count({ casterGuid, targetGuid }) != 0;
}

void MarkPropagatedLivingBombForRemoval(
    ObjectGuid casterGuid, ObjectGuid targetGuid, uint64 token)
{
    std::lock_guard<std::mutex> lock(propagatedLivingBombsMutex);
    auto itr = propagatedLivingBombs.find({ casterGuid, targetGuid });
    if (itr != propagatedLivingBombs.end() && itr->second.Token == token)
        itr->second.RemovalPending = true;
}

void UnmarkPropagatedLivingBomb(
    ObjectGuid casterGuid, ObjectGuid targetGuid, uint64 token)
{
    std::lock_guard<std::mutex> lock(propagatedLivingBombsMutex);
    auto itr = propagatedLivingBombs.find({ casterGuid, targetGuid });
    if (itr != propagatedLivingBombs.end() && itr->second.Token == token)
        propagatedLivingBombs.erase(itr);
}

void UnmarkRemovedPropagatedLivingBomb(
    ObjectGuid casterGuid, ObjectGuid targetGuid)
{
    std::lock_guard<std::mutex> lock(propagatedLivingBombsMutex);
    auto itr = propagatedLivingBombs.find({ casterGuid, targetGuid });
    if (itr != propagatedLivingBombs.end() && itr->second.RemovalPending)
        propagatedLivingBombs.erase(itr);
}
}

class spell_apoc_mage_pyroclastic_chain_reaction_pyroblast : public SpellScriptLoader
{
public:
    spell_apoc_mage_pyroclastic_chain_reaction_pyroblast()
        : SpellScriptLoader("spell_apoc_mage_pyroclastic_chain_reaction_pyroblast") { }

    class spell_apoc_mage_pyroclastic_chain_reaction_pyroblast_SpellScript : public SpellScript
    {
        PrepareSpellScript(spell_apoc_mage_pyroclastic_chain_reaction_pyroblast_SpellScript);

        bool Validate(SpellInfo const* /*spellInfo*/) override
        {
            return ValidateSpellInfo({
                SPELL_APOC_MAGE_PYROCLASTIC_CHAIN_REACTION,
                SPELL_MAGE_PYROBLAST_R1,
                SPELL_MAGE_LIVING_BOMB_R1,
                SPELL_MAGE_LIVING_BOMB_EXPLOSION_R1
            });
        }

        void HandleDamage(SpellEffIndex /*effIndex*/)
        {
            Unit* caster = GetCaster();
            Unit* target = GetHitUnit();
            if (!caster || !target)
                return;

            AuraEffect const* passive = caster->GetAuraEffect(
                SPELL_APOC_MAGE_PYROCLASTIC_CHAIN_REACTION, EFFECT_0);
            if (!passive)
                return;

            Aura* livingBomb = target->GetAuraOfRankedSpell(
                SPELL_MAGE_LIVING_BOMB_R1, caster->GetGUID());
            if (!livingBomb || !roll_chance_i(passive->GetAmount()))
                return;

            AuraEffect const* explosionEffect = livingBomb->GetEffect(EFFECT_1);
            if (!explosionEffect)
                return;

            uint32 explosionSpellId = uint32(explosionEffect->GetAmount());
            if (!sSpellMgr->GetSpellInfo(explosionSpellId))
                return;

            livingBomb->RefreshDuration();
            caster->CastSpell(target, explosionSpellId, true, nullptr, passive);
        }

        void Register() override
        {
            OnEffectHitTarget += SpellEffectFn(
                spell_apoc_mage_pyroclastic_chain_reaction_pyroblast_SpellScript::HandleDamage,
                EFFECT_0, SPELL_EFFECT_SCHOOL_DAMAGE);
        }
    };

    SpellScript* GetSpellScript() const override
    {
        return new spell_apoc_mage_pyroclastic_chain_reaction_pyroblast_SpellScript();
    }
};

class spell_apoc_mage_pyroclastic_chain_reaction_living_bomb : public SpellScriptLoader
{
public:
    spell_apoc_mage_pyroclastic_chain_reaction_living_bomb()
        : SpellScriptLoader("spell_apoc_mage_pyroclastic_chain_reaction_living_bomb") { }

    class spell_apoc_mage_pyroclastic_chain_reaction_living_bomb_AuraScript : public AuraScript
    {
        PrepareAuraScript(spell_apoc_mage_pyroclastic_chain_reaction_living_bomb_AuraScript);

        bool Load() override
        {
            _propagatedToken = 0;
            return true;
        }

        bool Validate(SpellInfo const* /*spellInfo*/) override
        {
            return ValidateSpellInfo({
                SPELL_APOC_MAGE_PYROCLASTIC_CHAIN_REACTION,
                SPELL_MAGE_LIVING_BOMB_R1
            });
        }

        void HandleApply(AuraEffect const* aurEff, AuraEffectHandleModes /*mode*/)
        {
            SpellInfo const* triggeringSpell =
                aurEff->GetBase()->GetTriggeredByAuraSpellInfo();
            if (!triggeringSpell ||
                triggeringSpell->Id != SPELL_APOC_MAGE_PYROCLASTIC_CHAIN_REACTION)
                return;

            AuraEffect* periodicEffect = GetEffect(EFFECT_0);
            if (!periodicEffect)
                return;

            periodicEffect->ChangeAmount(CalculatePct(
                periodicEffect->GetAmount(), PROPAGATED_LIVING_BOMB_DAMAGE_PCT));
            if (!_propagatedToken)
            {
                _propagatedToken = MarkPropagatedLivingBomb(
                    GetCasterGUID(), GetTarget()->GetGUID());
            }
        }

        void HandleBeforeRemove(
            AuraEffect const* /*aurEff*/, AuraEffectHandleModes /*mode*/)
        {
            if (!_propagatedToken)
                return;

            AuraRemoveMode removeMode = GetTargetApplication()->GetRemoveMode();
            if (removeMode == AURA_REMOVE_BY_ENEMY_SPELL ||
                removeMode == AURA_REMOVE_BY_EXPIRE)
            {
                MarkPropagatedLivingBombForRemoval(
                    GetCasterGUID(), GetTarget()->GetGUID(), _propagatedToken);
            }
        }

        void HandleRemove(AuraEffect const* /*aurEff*/, AuraEffectHandleModes /*mode*/)
        {
            if (!_propagatedToken)
                return;

            AuraRemoveMode removeMode = GetTargetApplication()->GetRemoveMode();
            if (removeMode == AURA_REMOVE_BY_ENEMY_SPELL ||
                removeMode == AURA_REMOVE_BY_EXPIRE)
            {
                if (Unit* caster = GetCaster())
                {
                    ObjectGuid casterGuid = GetCasterGUID();
                    ObjectGuid targetGuid = GetTarget()->GetGUID();
                    uint64 token = _propagatedToken;
                    caster->m_Events.AddEventAtOffset(
                        [casterGuid, targetGuid, token]()
                        {
                            UnmarkPropagatedLivingBomb(
                                casterGuid, targetGuid, token);
                        }, Milliseconds(1));
                    return;
                }
            }

            UnmarkPropagatedLivingBomb(
                GetCasterGUID(), GetTarget()->GetGUID(), _propagatedToken);
        }

        void Register() override
        {
            AfterEffectApply += AuraEffectApplyFn(
                spell_apoc_mage_pyroclastic_chain_reaction_living_bomb_AuraScript::HandleApply,
                EFFECT_0, SPELL_AURA_PERIODIC_DAMAGE,
                AURA_EFFECT_HANDLE_REAL_OR_REAPPLY_MASK);
            OnEffectRemove += AuraEffectRemoveFn(
                spell_apoc_mage_pyroclastic_chain_reaction_living_bomb_AuraScript::HandleBeforeRemove,
                EFFECT_1, SPELL_AURA_DUMMY, AURA_EFFECT_HANDLE_REAL);
            AfterEffectRemove += AuraEffectRemoveFn(
                spell_apoc_mage_pyroclastic_chain_reaction_living_bomb_AuraScript::HandleRemove,
                EFFECT_1, SPELL_AURA_DUMMY, AURA_EFFECT_HANDLE_REAL);
        }

    private:
        uint64 _propagatedToken;
    };

    AuraScript* GetAuraScript() const override
    {
        return new spell_apoc_mage_pyroclastic_chain_reaction_living_bomb_AuraScript();
    }
};

class spell_apoc_mage_pyroclastic_chain_reaction_explosion : public SpellScriptLoader
{
public:
    spell_apoc_mage_pyroclastic_chain_reaction_explosion()
        : SpellScriptLoader("spell_apoc_mage_pyroclastic_chain_reaction_explosion") { }

    class spell_apoc_mage_pyroclastic_chain_reaction_explosion_SpellScript : public SpellScript
    {
        PrepareSpellScript(spell_apoc_mage_pyroclastic_chain_reaction_explosion_SpellScript);

        bool Load() override
        {
            _livingBombSpellId = 0;
            _spreadTargetGuids.clear();
            return true;
        }

        bool Validate(SpellInfo const* spellInfo) override
        {
            if (spellInfo->Speed > 0.0f)
                return false;

            return ValidateSpellInfo({
                SPELL_APOC_MAGE_PYROCLASTIC_CHAIN_REACTION,
                SPELL_MAGE_LIVING_BOMB_R1,
                SPELL_MAGE_LIVING_BOMB_EXPLOSION_R1
            });
        }

        void HandleDamage(SpellEffIndex /*effIndex*/)
        {
            Unit* caster = GetCaster();
            Unit* sourceTarget = GetExplTargetUnit();
            if (!caster || !sourceTarget || !IsPropagatedLivingBomb(
                caster->GetGUID(), sourceTarget->GetGUID()))
                return;

            SetHitDamage(CalculatePct(
                GetHitDamage(), PROPAGATED_LIVING_BOMB_DAMAGE_PCT));
        }

        void CollectSpreadTarget()
        {
            SpellInfo const* triggeringSpell = GetTriggeringSpell();
            if (!triggeringSpell ||
                triggeringSpell->Id != SPELL_APOC_MAGE_PYROCLASTIC_CHAIN_REACTION)
                return;

            Unit* caster = GetCaster();
            Unit* sourceTarget = GetExplTargetUnit();
            Unit* hitTarget = GetHitUnit();
            if (!caster || !sourceTarget || !hitTarget || !hitTarget->IsAlive() ||
                hitTarget == sourceTarget)
                return;

            if (!_livingBombSpellId)
            {
                Aura* livingBomb = sourceTarget->GetAuraOfRankedSpell(
                    SPELL_MAGE_LIVING_BOMB_R1, caster->GetGUID());
                if (!livingBomb)
                    return;

                _livingBombSpellId = livingBomb->GetId();
            }

            if (hitTarget->GetAuraOfRankedSpell(
                SPELL_MAGE_LIVING_BOMB_R1, caster->GetGUID()))
                return;

            _spreadTargetGuids.push_back(hitTarget->GetGUID());
        }

        void SpreadLivingBomb()
        {
            Unit* caster = GetCaster();
            if (!caster || !_livingBombSpellId)
                return;

            AuraEffect const* passive = caster->GetAuraEffect(
                SPELL_APOC_MAGE_PYROCLASTIC_CHAIN_REACTION, EFFECT_0);
            if (!passive)
                return;

            Acore::Containers::RandomResize(
                _spreadTargetGuids, MAX_LIVING_BOMB_SPREAD_TARGETS);
            for (ObjectGuid const& targetGuid : _spreadTargetGuids)
            {
                Unit* target = ObjectAccessor::GetUnit(*caster, targetGuid);
                if (!target || !target->IsAlive())
                    continue;

                if (target->GetAuraOfRankedSpell(
                    SPELL_MAGE_LIVING_BOMB_R1, caster->GetGUID()))
                    continue;

                caster->CastSpell(target, _livingBombSpellId, true, nullptr, passive);
            }
        }

        void FinishPropagatedExplosion()
        {
            Unit* caster = GetCaster();
            Unit* sourceTarget = GetExplTargetUnit();
            if (caster && sourceTarget)
            {
                UnmarkRemovedPropagatedLivingBomb(
                    caster->GetGUID(), sourceTarget->GetGUID());
            }
        }

        void Register() override
        {
            OnEffectHitTarget += SpellEffectFn(
                spell_apoc_mage_pyroclastic_chain_reaction_explosion_SpellScript::HandleDamage,
                EFFECT_0, SPELL_EFFECT_SCHOOL_DAMAGE);
            AfterHit += SpellHitFn(
                spell_apoc_mage_pyroclastic_chain_reaction_explosion_SpellScript::CollectSpreadTarget);
            AfterCast += SpellCastFn(
                spell_apoc_mage_pyroclastic_chain_reaction_explosion_SpellScript::SpreadLivingBomb);
            AfterCast += SpellCastFn(
                spell_apoc_mage_pyroclastic_chain_reaction_explosion_SpellScript::FinishPropagatedExplosion);
        }

    private:
        uint32 _livingBombSpellId;
        std::vector<ObjectGuid> _spreadTargetGuids;
    };

    SpellScript* GetSpellScript() const override
    {
        return new spell_apoc_mage_pyroclastic_chain_reaction_explosion_SpellScript();
    }
};

void AddModApocalipseMagePyroclasticChainReactionScripts()
{
    new spell_apoc_mage_pyroclastic_chain_reaction_pyroblast();
    new spell_apoc_mage_pyroclastic_chain_reaction_living_bomb();
    new spell_apoc_mage_pyroclastic_chain_reaction_explosion();
}

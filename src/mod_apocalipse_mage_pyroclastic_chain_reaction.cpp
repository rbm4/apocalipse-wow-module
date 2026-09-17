#include "Containers.h"
#include "ObjectAccessor.h"
#include "Random.h"
#include "SpellAuraEffects.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include "Unit.h"

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

        void Register() override
        {
            AfterHit += SpellHitFn(
                spell_apoc_mage_pyroclastic_chain_reaction_explosion_SpellScript::CollectSpreadTarget);
            AfterCast += SpellCastFn(
                spell_apoc_mage_pyroclastic_chain_reaction_explosion_SpellScript::SpreadLivingBomb);
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
    new spell_apoc_mage_pyroclastic_chain_reaction_explosion();
}

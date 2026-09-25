# Priest ability pack

Status: Implemented in source and SQL; startup validation verified after the periodic-aura registration fix; pending migration, client export, playerbot policy, and gameplay validation

Owners: `src/mod_apocalipse_priest_spells.cpp`, `src/mod_apocalipse_loader.cpp`, `data/sql/db-world/2026_09_24_01_priest_spell_pack.sql`

Last validated: 2026-09-24 by static review against module `main` and the local custom core `Playerbot` branch

## Summary

The pack defines exactly 20 player-facing Priest abilities: five shared, five Discipline, five Holy, and five Shadow. The complete server spell graph reserves IDs 901118 through 901154. Acquisition is external and no specialization grant rows are installed.

## Scope

### Included

- Shared mana sustain, Shadowfiend improvements, dispel protection, and haste.
- Penance-centered Discipline damage and healing interactions.
- Holy damage and healing alternation, Radiance, echoes, and Apotheosis.
- Fixed-duration hasted Shadow periodic effects, bounded spreading, stored damage, and global same-map eruption.
- Identical server mechanics for human and bot-controlled Priests.

### Excluded

- Spell or talent acquisition.
- Client `Spell.dbc` export and patch delivery.
- Playerbot actions, triggers, or strategy priorities.
- Runtime balance tuning.

## Gameplay contract

### Shared

| Ability | Contract |
|---|---|
| Spiritual Conservation 901118 | Critical Priest damage or healing, including periodic critical events, restores 0.75 percent maximum mana through helper 901119. Custom helpers are excluded and the caster cooldown is 2 seconds. |
| Faithful Shadowfiend 901120 | Native spell modification removes 60 seconds from Shadowfiend cooldown. Summon initialization adds 10 seconds to creature 19668, and each positive Shadowfiend damage event restores 1 percent owner maximum mana. |
| Inner Renewal 901121 | Two-minute active that restores 16 percent maximum mana and applies 15 seconds of 20 percent reduced mana cost with 15 percent reduced damage and healing. |
| Unshakable Conviction 901122 | Native Priest-family dispel resistance covers harmful magical family bits after subtracting all Vampiric Touch family bits. Friendly buffs and physical effects are outside the derived mask. |
| Rapid Surge of Faith 901123 | Critical direct Priest damage or healing has a script-rolled 20 percent chance to apply eight seconds of 12 percent spell haste through 901124. The caster cooldown is 20 seconds. |

### Discipline

| Ability | Contract |
|---|---|
| Rapid Penance 901125 | The ranked Penance child channel amplitude is halved while the passive is active, producing six complete ticks in the unchanged channel duration. Interruption ends the child channel and its remaining ticks. Each tick adds one 901126 stack, up to six, and adds one Balanced Judgment charge when that passive is active. |
| Evangelism 901127 | Non-triggered Smite, Holy Fire, and hostile-target Penance casts add 15-second 901128 stacks, up to five. Native spell modifiers add 3 percent damage and remove 3 percent mana cost per stack for the three approved families. |
| Archangel 901129 | A 30-second active consumes every Evangelism stack, restores 1 percent maximum mana per stack, and applies 15-second 901130 with 3 percent Priest damage and healing per consumed stack. |
| Atonement 901131 | Final positive Smite, Holy Fire, or offensive Penance damage heals the lowest-health injured group member within 15 yards of the enemy for 75 percent. The Priest is selected only as fallback. Helper 901132 is non-critical and subject to normal healing-taken processing. |
| Balanced Judgment 901133 | Penance builds 12-second 901134 up to three stacks. Native modifiers provide 10 percent Smite and Greater Heal cast-time reduction and 8 percent Holy Fire damage or Flash Heal healing per stack. The next qualifying cast consumes all charges. |

### Holy

| Ability | Contract |
|---|---|
| Wrathful Seraph 901135 | Runtime output changes apply the specified Smite, Holy Fire, Holy Nova, Flash Heal, and Greater Heal values. Native modifiers add 120 percent Holy Nova mana cost and reduce Holy threat by 30 percent. |
| Divine Concord 901136 | A qualifying direct Holy damage cast adds Mercy 901137 and a qualifying direct Holy heal adds Wrath 901138. Both last 30 seconds and stack ten times. An opposite-role event consumes one stack for a 15 percent bonus. Holy Nova follows its friendly self-centered heal role. |
| Holy Word: Radiance 901139 | The 8 percent base-mana active repeats the stored amount from the Priest's latest qualifying direct Holy event and adds the Mind Blast coefficient. Friendly primaries receive healing and cause 40 percent damage to the nearest enemy within 10 yards. Hostile primaries take damage and cause 40 percent healing to the lowest-health injured group member within 10 yards. No secondary target means no secondary effect. |
| Blessed Echoes 901142 | Direct Holy damage or healing has a 30 percent chance to schedule a 40 percent non-critical repeat on the original target after one second. Helpers 901143 and 901144 cannot recurse. The caster cooldown is 500 milliseconds. |
| Apotheosis 901145 | Two-minute active that grants 20 seconds of 20 percent spell haste and 20 percent reduced Holy-school mana cost. Radiance casts made while active reduce their newly added cooldown from 15 to 7.5 seconds. Existing cooldowns are unchanged. Blessed Echoes uses 40 percent chance while active. |

### Shadow

| Ability | Contract |
|---|---|
| Accelerated Misery 901146 | Rank-wide Shadow Word: Pain, Vampiric Touch, and stock Devouring Plague bindings multiply periodic amplitude by current cast-speed value while leaving normal duration unchanged. Complete ticks only are produced. |
| Spreading Darkness 901147 | A successful Mind Blast hit chooses one enemy within 10 yards, prioritizing the number of missing Shadow Word: Pain and Vampiric Touch effects. Exact source ranks are copied without replacing a longer same-caster aura. Copied Devouring Plague 901148 snapshots tick amount, starts a fresh duration, leeches normally, and does not store Devouring Echo. |
| Void Pressure 901149 | Mind Blast adds three 901150 stacks and each Mind Flay damage event adds one when the target carries at least one qualifying Priest periodic effect. Each stack reduces movement speed and healing taken by 1 percent for eight seconds, up to 50. |
| Devouring Echo 901151 | Each stock Devouring Plague periodic event stores 20 percent of its damage in a caster-target accumulator capped at 15 percent caster maximum health. Expiration, refresh, dispel, and death removal erupt helper 901152 against living enemies within 10 yards. Death removal excludes the dying unit. |
| Void Eruption 901153 | The 12 percent base-mana, 45-second self-cast iterates the caster's registered same-map periodic targets without range or line-of-sight checks. Helper 901154 uses Mind Blast rank 13 base damage and coefficient, increased by 20 percent per active qualifying periodic effect. Shadow Word: Pain and Vampiric Touch refresh normally. Stock Devouring Plague erupts before refresh, while copied Devouring Plague only refreshes. |

## Human and bot applicability

| Dimension | Humans | Bots | Exceptions |
|---|---|---|---|
| Passive mechanics | Automatic after external acquisition | Identical | None |
| Active mechanics | Available after external acquisition | Identical when cast | Playerbot policy is not present in the available repositories |
| Acquisition | External | External | No module grant rows are installed |

The module does not call `WorldSession::IsBot()` for this pack because all runtime mechanics are intentionally identical. Inner Renewal, Archangel, Apotheosis, and Void Eruption need playerbot cast-decision support in the repository that owns Priest AI.

## Entry points and state

- `AddModApocalipsePriestSpellScripts()` registers all spell, aura, unit, and player scripts before Battleground Stamina.
- SQL binds ranked stock chains with negative first-rank IDs and binds custom rows directly.
- `DotTargets` tracks caster-owned Shadow periodic targets for Void Eruption.
- `DevouringEchoAmounts` tracks capped stock Devouring Plague storage by caster and target.
- `LastHolyAmounts` tracks the latest qualifying direct Holy amount by caster for Radiance.
- Player logout removes all caster-owned process state. Aura removal prunes target registrations.
- Combat paths perform no database work.

## Data and migration

The automatic world update installs 37 spell rows, proc metadata, ranked and custom script bindings, coefficient rows, non-save helper attributes, and backend names. It derives stock family masks from `wotlk_spells_full` and guards 901118 through 901154 against existing module and backend ownership.

Deployment requires an authorized live collision check, world updater execution, startup log review, matching client export for all player-visible and helper rows required by the client, and external acquisition configuration. Rollback requires removing acquisition first, reverting the client patch, removing bindings and owned rows, then reverting the module source.

## Interactions and invariants

1. Custom damage and healing helpers are excluded from recursive mana, haste, Concord, Atonement, Echoes, and Holy amount capture paths.
2. Vampiric Touch remains outside the Unshakable Conviction modifier and retains stock backlash behavior.
3. Copied Devouring Plague participates in Accelerated Misery, Void Pressure, and Void Eruption but never contributes to Devouring Echo storage.
4. Rapid Penance modifies the active child channel rather than scheduling detached impacts.
5. Void Eruption only resolves living, hostile, same-map registered targets that still carry at least one qualifying effect.
6. Acquisition remains external for all 20 player-facing abilities.

## Verification

| Check | Status |
|---|---|
| Static ID, binding, helper recursion, acquisition, patch-whitespace, and core Shadowfiend constant review | Passed on 2026-09-24 |
| Custom-core build | Initial deployment build exposed and informed the duplicate Shadowfiend constant fix; rebuild not run locally |
| Database updater and startup | Worldserver startup reached spell-script validation on 2026-09-25; GDB identified an invalid `AuraScript::GetSpellInfo()` call from `spell_apoc_priest_dot::script::Register()`. The registration now uses the fixed `SPELL_AURA_PERIODIC_DAMAGE` contract and validates effect 0 before registering hooks. |
| Client export | Not run |
| Human gameplay | Not run |
| Playerbot gameplay and active policy | Not run, AI source unavailable |

## Open questions

- The deployment owner must provide the repository containing Priest playerbot actions and strategies before cast-decision support can be implemented.
- Runtime testing must tune the initial level-80 values and verify stock family-mask derivation against deployed server data.

## Change history

| Date | Change | Code or history reference |
|---|---|---|
| 2026-09-24 | Initial source and SQL implementation | [`../history/2026-09-24-priest-ability-pack.md`](../history/2026-09-24-priest-ability-pack.md) |
| 2026-09-24 | Deployment-core compilation compatibility fix | [`../history/2026-09-24-shaman-priest-compilation-fix.md`](../history/2026-09-24-shaman-priest-compilation-fix.md) |
| 2026-09-25 | Priest periodic-aura startup crash fix | [`../history/2026-09-25-priest-dot-registration-crash-fix.md`](../history/2026-09-25-priest-dot-registration-crash-fix.md) |

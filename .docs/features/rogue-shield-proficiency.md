# Rogue shield proficiency

Status: Implemented

Owners: `data/sql/db-world/2026_09_22_02_rogue_shield_proficiency.sql`

Last validated: 2026-09-22 by static review against the deployment core

## Summary

Rogues receive the stock Shield skill 433 through AzerothCore's default-skill loading path. The stock skill reward graph is expected to grant Shield Proficiency 9116 and Block 107, allowing rogues to equip shields and enabling normal block calculations without a custom spell or player login script.

## Scope

### Included

- Server-side rogue eligibility for Shield skill 433.
- A separate rogue-only default-skill row that leaves the stock warrior, paladin, and shaman row unchanged.
- Existing-character reconciliation through `LearnDefaultSkills()` during character loading.
- Identical acquisition for human and bot-controlled rogues.

### Excluded

- Client `SkillRaceClassInfo.dbc` changes and skill-panel presentation.
- LFG Need Before Greed shield eligibility.
- Playerbot equipment-selection policy.
- Rogue tank talents, abilities, threat, mitigation, or itemization.

## Gameplay and operator contract

World update `2026_09_22_02_rogue_shield_proficiency.sql` adds `skillraceclassinfo_dbc` row 10000 by copying the stock Shield eligibility fields and replacing the class mask with rogue mask 8. It also adds `(raceMask 0, classMask 8, skill 433, rank 0)` to `playercreateinfo_skills`.

The stock Shield row remains unchanged. The worldserver must restart after the updater runs because DBC override and player-create skill stores are startup-owned.

## Human and bot applicability

| Dimension | Humans | Bots | Exceptions |
|---|---|---|---|
| Eligibility | Every rogue race | Every bot-controlled rogue race | None in server acquisition |
| Session requirement | Applied during character loading | Applied during bot character loading | No `WorldSession::IsBot()` branch |
| Equipment and combat | Stock shield proficiency and block paths | Same server mechanics | Bot gear choice remains external |

## Entry points

| Trigger | Source symbol | Preconditions | Result |
|---|---|---|---|
| Worldserver startup | `ObjectMgr` player-create skill loading | Migration installed and server restarted | Rogue Shield row passes `GetSkillRaceClassInfo` validation |
| Character load | `Player::LearnDefaultSkills()` | Player is a rogue missing skill 433 | Grants the default Shield skill before inventory loading |
| Skill grant | `Player::SetSkill()` and `learnSkillRewardedSpells()` | Stock skill reward rows accept the rogue | Learns the stock proficiency and Block effects |

## End-to-end flow

```text
world updater installs rogue Shield eligibility and default acquisition
  -> worldserver restart merges skillraceclassinfo_dbc row 10000
  -> rogue character load calls LearnDefaultSkills before inventory loading
  -> missing Shield skill 433 is granted as a monolithic 1/1 armor skill
  -> stock SkillLineAbility rewards grant Shield Proficiency and Block
  -> equipped shield validation and normal block calculations use stock paths
```

## Ownership and lifetime

- Process-owned state: loaded DBC override and player-create skill stores.
- Per-player state: persisted Shield skill and learned stock reward spells.
- Aura or spell state: stock proficiency and Block effects reconstruct runtime flags.
- Persistent state: normal character skill and spell persistence.
- Cache load and invalidation: worldserver restart.
- Reentrancy or duplicate protection: guarded ownership checks make the migration rerunnable.

## Configuration

None.

## Data and migration

| Database/client | Object | Authoritative or derived | Read/write owner | Migration path |
|---|---|---|---|---|
| `acore_world` | `skillraceclassinfo_dbc` ID 10000 | Server eligibility override | AzerothCore DBC loader | `data/sql/db-world/2026_09_22_02_rogue_shield_proficiency.sql` |
| `acore_world` | `playercreateinfo_skills` rogue skill 433 | Default acquisition | `ObjectMgr` and `Player::LearnDefaultSkills()` | Same migration |
| Client | `SkillRaceClassInfo.dbc` | Stock and currently unchanged | Client | Deferred |

Rollback requires removing both owned rows and deciding how to handle rogues already wearing shields or persisting skill 433 before restarting the worldserver.

## Dependencies and interactions

- Uses the deployment core's database-backed DBC overlay loader.
- Runs before inventory loading through the normal default-skill path.
- Does not register module C++ hooks.
- Does not alter custom spell IDs or require a new `Spell.dbc` row.
- LFG and client UI class filters remain outside this migration.

## Invariants

1. The stock Shield eligibility and default-skill records remain unchanged.
2. Row ID 10000 may only represent the exact rogue Shield eligibility contract.
3. Rogue Shield acquisition must complete before inventory validation.
4. Humans and bots use the same core path.

## Failure modes and diagnostics

| Failure | Effect | Detection | Recovery |
|---|---|---|---|
| ID 10000 is occupied by another override | Migration stops through its collision guard | World updater error | Allocate a verified free ID and revise the migration before deployment |
| DBC override is absent or rejected | Rogue default skill is skipped | Startup logs and missing skill 433 | Verify updater execution and restart |
| Stock skill reward rows exclude rogue class mask | Skill 433 exists but proficiency or Block is missing | In-game spell, equip, and block checks | Add a reviewed `skilllineability_dbc` override or targeted core handling |
| Client filters the skill | Server mechanics work but UI is inconsistent | Client skill and trainer UI inspection | Export a matching client DBC in a follow-up |

## Performance

- Invocation frequency: normal startup and character load only.
- Database work: world updater and existing startup table loads.
- Population multiplier for bots: bounded default-skill check per bot login.
- Expensive calculations or allocations: none added.

## Verification

### Automated and build

- [x] Static migration and deployment-core path review
- [ ] World updater and startup validation
- [ ] Build against the exact deployment core and `mod-playerbots`

### Runtime scenarios

| Scenario | Setup | Expected | Observed and date |
|---|---|---|---|
| Existing rogue login | Rogue without skill 433 | Learns Shield before inventory load | Not run |
| New rogue creation | New rogue | Starts with Shield | Not run |
| Shield equip and relog | Rogue equips shield and relogs | Shield remains equipped | Not run |
| Block resolution | Rogue with shield attacked from the front | Stock block chance and value apply | Not run |
| Bot rogue login | Bot-controlled rogue | Same skill and proficiency state | Not run |

## Rollout and rollback

- Operator steps: run the automatic world updater, restart worldserver, inspect startup logs, and run the named scenarios.
- Compatibility requirements: deployment core database-backed DBC loading and stock Shield reward data.
- Data/client rollback limitations: existing character state may persist after world rows are removed.
- Safe disable path: reviewed removal migration plus equipped-shield handling before restart.

## Decisions and rejected alternatives

- A separate rogue `playercreateinfo_skills` row was chosen instead of changing stock class mask 67.
- The normal default-skill path was chosen instead of a late `OnPlayerLogin` reconciliation because inventory validates equipment before that hook.
- Client DBC export was deferred because the minimum server mechanic is server-authoritative.

## Open questions

- Confirm the deployed stock `SkillLineAbility` rows for Shield skill 433 permit rogue reward acquisition.
- Determine whether client skill, trainer, LFG, or playerbot gear-selection filters need follow-up changes.

## Change history

| Date | Change | Code or history reference |
|---|---|---|
| 2026-09-22 | Added server-side baseline rogue Shield acquisition | `../history/2026-09-22-rogue-shield-proficiency.md` |

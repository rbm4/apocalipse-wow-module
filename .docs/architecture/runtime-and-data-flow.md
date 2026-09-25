# Runtime and data flow

Status: Active

Last source review: 2026-09-20

## Startup

```text
AzerothCore discovers Addapocalipse_wow_moduleScripts()
  -> registers gameplay systems
  -> database custom-table hooks load spec and scaling caches
  -> startup/config hooks load PvP and battleground settings
  -> spell scripts are available when their SQL bindings and spell rows exist
```

### Startup-owned state

| State | Loaded by | Source | Refresh behavior |
|---|---|---|---|
| `g_specSpells` | `ModApocalipseWorld::OnLoadCustomDatabaseTable` | `acore_world.mod_spec_spells` | Worldserver restart or another invocation of the custom-table hook |
| Four scaling maps | `SpellScalingWorld::OnLoadCustomDatabaseTable` | `acore_world.mod_spell_scaling` | Worldserver restart or another invocation of the custom-table hook |
| PvP percentages | `ModApocalipsePvPWorld` | `Apocalipse.PvP*` config keys | Startup and config reload |
| Battleground settings and aura validity | `BattlegroundStaminaWorldScript` | `Apocalipse.BattlegroundStamina.*` and loaded spell data | Startup and config reload; active auras are not swept immediately |

## Player lifecycle

### Default rogue Shield acquisition

```text
worldserver startup
  -> merges skillraceclassinfo_dbc row 10000 into the server DBC store
  -> accepts rogue class mask 8 for Shield skill 433

rogue character load before inventory validation
  -> LearnDefaultSkills reads the separate rogue playercreateinfo_skills row
  -> grants missing Shield skill 433
  -> stock skill rewards reconstruct Shield Proficiency and Block capability
```

This path applies to existing and new rogues without a module login hook. Client DBC presentation, LFG shield eligibility, and playerbot equipment-selection policy remain separate concerns.

### Bladeguard equipment lifecycle

```text
learned passive 901073 plus usable shield
  -> core item-dependent passive handling applies Bladeguard
  -> item armor gains 130 percent and block chance gains 15 points
  -> successful block can trigger helper 901074 for 5 Energy
     -> spell_proc enforces one trigger per 1000 ms

shield removed or no longer usable
  -> core item-dependent aura cleanup removes 901073 immediately
  -> armor, block chance, and Energy proc all deactivate
```

Bladeguard uses native aura and proc paths and does not grant Shield skill, shield proficiency, or Block capability. Acquisition is external.

### Login and talent changes

`ModSpecPlayer` reconciles the dominant talent tree on login and after each talent learn. It persists the granted spec and hidden talent budget in the character database. A per-GUID in-progress set prevents recursive reconciliation. Talent reset processing also has a one-second per-GUID throttle.

`BattlegroundStaminaPlayerScript` reacts to login, level, map, equipment, spec-slot, talent, and resurrection events. It applies or removes assistance according to the player's current battleground state.

Both scripts subscribe to login and talent-related flows. The loader registers Spec Manager first and Battleground Stamina last, but maintainers should not build correctness around undocumented global callback ordering. Each handler must remain safe when the other has already run or has not run yet.

### Battleground lifecycle

```text
non-arena battleground add/map/login recovery
  -> ApplyAssistance
     -> validate eligibility and cached spell readiness
     -> calculate baseline without active stamina/health buffs
     -> calculate minimum whole stamina for configured partial gap coverage
     -> cast or update aura 901002
     -> preserve current-health no-free-heal invariant

battleground leave or unsupported state
  -> RemoveAssistance
```

Human equipment changes are blocked for items that AzerothCore does not consider combat-swappable. Bot sessions bypass this lock. Successful bot or allowed human equipment changes invoke the equip hooks and recalculate assistance.

## Combat value composition

### Direct spell damage

The loader registers spell scaling before PvP balancing. Both hooks mutate the same damage value.

```text
base direct spell damage
  -> SpellScalingUnit for configured DAMAGE spell IDs
  -> ModPvPUnitScript when attacker is a player/player-owned unit and victim is a player
  -> final damage
```

The reductions are multiplicative, but each stage converts to an integer. Registration or dispatch-order changes can therefore alter rounding even when the mathematical factors commute.

### Periodic damage

Configured `PERIODIC` scaling and PvP balancing both mutate periodic tick damage. A missing attacker skips both modules' periodic behavior. Document and test any new periodic hook against both systems.

Pyroclastic Chain Reaction reuses normal Living Bomb ranks for its spread applications. Passive 901003 trigger metadata marks those auras as propagated and reduces their calculated periodic amount to 30 percent before the existing periodic scaling and PvP paths. Explosions originating from propagated auras reuse the matching Living Bomb explosion rank and receive the same 30 percent modifier before the existing direct-damage hook composition. Manually applied source bombs remain at full damage.

### Mage proc interaction

```text
Pyroblast effect 0 hit
  -> passive 901003 and same-caster Living Bomb guards
  -> 20 percent roll from passive effect amount
  -> source Living Bomb refresh
  -> matching-rank Living Bomb explosion
  -> up to two random unbombed explosion-hit survivors receive the source rank
     -> propagated ticks and explosions use 30 percent damage
```

Normal Living Bomb expiration and dispel explosions do not spread. The spread script requires the explosion cast to identify passive 901003 as its triggering spell.

```text
Missile Barrage proc aura 44401 with passive 901004
  -> count applications and reapplications up to 20
  -> expose the count through proc charges
  -> add 500 ms of channel duration for each proc after the first
  -> Arcane Missiles starts with normal interval and mana modifiers
  -> multi-proc release plays visual-only spell 35426 on the target
  -> existing proc pipeline removes the complete accumulated aura
```

The overload script changes channel duration but does not change missile damage. Each added periodic trigger continues through the normal Arcane Missiles damage, threat, crit, scaling, and PvP paths.

```text
Hypernova 901005 cast on an enemy unit
  -> play Arcane Explosion Visual 35426 at the selected target
  -> damage enemies within 10 yards through the Arcane direct-damage path
  -> displace eligible enemies through destination knockback effect 144
  -> schedule four stacks of Arcane Blast aura 36032 after current cast procs
```

Hypernova uses the Arcane Explosion family bit, so appropriate Arcane talents and the normal 36032 consumption contract apply. Its 2.856 coefficient and base range are four times Arcane Blast rank 4. The Spell Scaling table does not modify it, while PvP balancing and the core AoE cap remain active.

```text
Prismatic Barrier 901006 cast on self
  -> trigger Mana Shield rank 9, spell 43020
  -> refresh an existing ranked Ice Barrier aura
     or trigger Ice Barrier rank 8, spell 43039, when absent
  -> trigger Blazing Barrier, spell 901001
  -> newly applied child auras continue through existing scripts
```

The parent charges 42 percent base mana and owns the 45 second cooldown. Triggered child casts add no cost or cooldown. An existing Ice Barrier keeps its current absorb amount and receives maximum duration, avoiding the core stronger-aura cast rejection without changing normal Ice Barrier behavior.

```text
Frost Bomb 901007 cast on an enemy
  -> four-second dummy aura
  -> expiration, enemy dispel, or target death
     -> bombed target self-casts visual-only Frost Nova 34326
     -> target-centered Frost damage 901008 within 10 yards
     -> Permafrost-scaled slow 901009 on each living damage victim
```

The application AuraScript makes the bombed target self-cast visual-only spell 34326 before the mage-owned explosion begins. Frost Bomb's explosion deals 1380 base damage with a 0.8 direct coefficient and uses the Mage Frostbolt family bit for the existing Frost proc and frozen-target paths. Its triggered explosion permits proc events and deliberately does not copy Living Bomb's target-proc suppression or damage-does-not-break-auras correction. Spell 901009 reads Permafrost effects from rank chain 11175 and triggers existing healing-reduction aura 68391.

```text
Automatic Ice Lance passive 901010
  -> spell_proc selects Mage-family Frost damage hits at 10 percent with a 1000 ms cooldown
  -> direct, periodic, and triggered damage can qualify
  -> AuraScript rejects Ice Lance recursion, invalid-target, and blocked-line-of-sight events
  -> trigger Ice Lance 30455 with proc events enabled for Fingers of Frost consumption
  -> add one 10-second expiration to haste aura 901011
  -> periodic cleanup sets spell haste to active expiration count, capped at 20
```

The expiration queue belongs to aura 901011 and is memory-only. Its timestamps are not refreshed together, the aura is non-save, and removing passive 901010 removes the haste aura. Humans and bots follow the same bounded combat path.

```text
Frozen Retaliation rank 1 901012 or rank 2 901013
  -> positive incoming combat damage enters PROC_FLAG_TAKEN_DAMAGE
  -> spell_proc rolls 1.5 percent or 3 percent for the active rank
  -> AuraScript casts existing Fingers of Frost aura 44544 on the owner
  -> core Fingers of Frost handling creates or refreshes indicator 74396
```

The proc has no attacker, school, family, class, or phase filter. Melee, ranged, direct spell, periodic, and triggered combat damage can qualify when positive damage remains. Fully prevented damage and the separate environmental damage path do not dispatch the required positive combat-damage proc event. Humans and bots follow the same path.

```text
Concentrated Venom passive 901061 observes a landed equipped weapon poison
  -> AuraScript verifies Rogue poison family, hostile target, and real weapon CastItem
  -> select the highest applicable Deadly Poison rank on either equipped weapon
  -> reject while this target's aura-local 1000 ms throttle is active
  -> spell_proc rolls 30 percent
  -> cast the native Deadly Poison spell with its enchanted weapon
  -> native script adds a stack or, at five prior stacks, procs the opposite weapon
```

The proc event excludes misses, full resists, immunities, and other non-landed results before the chance roll. The script arms the target throttle before casting and removes it if the request fails, so the native five-stack opposite-weapon cast cannot re-enter the passive in the same call chain. The extra Deadly Poison cast also names passive 901061 as its trigger and receives the core's same-aura recursion guard. Expired target entries are pruned during later qualifying checks, and removing the passive destroys the map. Humans and bots follow the same bounded path with no combat-time database access.

```text
Daring Challenge 901070 lands on one enemy
  -> core matches the Rogue to highest threat and applies a 3-second taunt
  -> AfterHit verifies the caster-owned taunt aura survived immunity handling
  -> add one unmodified, unredirected point of threat
  -> enemy applies non-saved helper 901071 to the Rogue for 6 seconds
  -> positive Rogue damage against that exact enemy adds 50 percent damage threat
```

The bonus path uses the original damage spell when adding threat, so normal school threat modifiers and redirects compose with the extra contribution. Boss and encounter taunt immunity remain entirely core-owned. No damage value is changed, and no database query or global combat state is added.

```text
Buckler Strike 901078 cast with a usable offhand shield
  -> calculate floor(20 percent AP plus 150 percent shield block value)
  -> normal Physical melee resolution deals final damage
  -> native effect awards one combo point on a successful hit
  -> normal damage threat plus two-times final-damage bonus threat
  -> native interrupt effect executes only when the target is not a player
```

The interrupt path uses the core cast-state, interrupt-flag, immunity, and three-second school-lockout contract. Player targets still receive damage and normal combo-point handling, but the script prevents the interrupt effect before default execution. The strike suppresses weapon item procs and creates no combat-time database or global state.

```text
Leeching Mixture passive 901075 observes owner-attributed Rogue poison damage
  -> require Rogue family, poison dispel metadata, positive final damage, and another-unit victim
  -> calculate floor(8 percent of final event damage)
  -> clamp raw generated healing to floor(2 percent of current maximum health) per 1000 ms window
  -> cast non-critical self-heal helper 901076
  -> normal healing-taken reduction, dampening, absorption, and overheal resolve
```

The proc actor and `DamageInfo` attacker must both be the passive owner. Other Rogues, pets, guardians, environmental damage, self-damage, and reflected-hit events are rejected. Custom Rogue poison damage qualifies by preserving Rogue family and poison dispel metadata. The two-value window state is aura-local, performs no database access, and behaves identically for humans and bots.

```text
Gloomblade Infusion passive 901079 observes owner-attributed damage
  -> accept positive auto-attack, direct, periodic, poison, and triggered damage events
  -> reject self-damage, reflected damage, and helper 901080
  -> calculate floor(10 percent of final event damage)
  -> cast non-critical Shadow helper 901080 on the same living victim
  -> normal Shadow mitigation, PvP balancing, threat, and combat logging resolve
```

The helper is a triggered generic-family cast and is excluded explicitly by ID, preventing recursion while also keeping internal damage out of Rogue-family consumers such as Shadow Execution. Other proc systems retain their own triggered-spell eligibility rules. Pet and guardian damage is excluded by actor and attacker ownership checks. The source event has already completed its own scaling and mitigation path, while helper 901080 independently traverses normal Shadow damage handling.

```text
Shadow Execution passive 901081 observes direct Rogue-family ability damage
  -> require positive owner damage, another living unit, and a usable main-hand weapon
  -> reject auto attacks, periodic ticks, reflected damage, and IDs 901081 and 901082
  -> apply one native stack of periodic Shadow aura 901082 to that victim
  -> refresh ten seconds without resetting its one-second periodic timer
  -> calculate one percent of current AP-modified main-hand damage per stack
```

The periodic amount is recalculated when native stack application changes the aura. Core amount handling multiplies that one-stack amount by the current stack count, capped at 50, then normal Shadow periodic mitigation, PvP balancing, threat, and combat logging resolve. The existing external talent-tree flow must grant only single-rank passive 901081, and humans and bots share the same path.

```text
Relentless Finale passive 901084 applies visible infinite ready aura 901085
  -> player begins a non-triggered Rogue finisher with exactly five combo points
  -> transient aura 901086 disables combo-point clearing for that cast only
  -> every successful five-point cast heals 5 percent maximum health through 901088
  -> a retained cast removes ready and starts hidden recharge 901087 at 12000 ms
  -> recharge expiration reapplies ready aura 901085
```

The strict-check hook duplicates the core's explicit-target combo ownership test and requires exactly five points before applying the one-second transient aura. It checks the original unit target when present. When the client omits that GUID, it mirrors `Spell::InitExplicitTargets()` by accepting the Rogue's current selection only when it is also the combo target. The core then observes that aura in the same check and suppresses clearing for that cast. One-through-four-point, wrong-target, triggered, and copied finishers follow their normal path. The recharge begins after the activating cast rather than on a periodic passive schedule. Humans and bots share the mechanics, while intentional double-finisher sequencing remains AI policy.

```text
Rogue with Improved Feint passive 901089 successfully casts any Feint rank
  -> stock Feint effects resolve without modification
  -> rank-wide AfterCast hook triggers helper 901090 on the Rogue
  -> helper applies or refreshes six seconds of 30 percent all-school reduction
  -> non-AoE damage uses factor 0.70
  -> AoE damage also uses stock Feint factor 0.60, producing factor 0.42
```

The helper reuses native `SPELL_AURA_MOD_DAMAGE_PERCENT_TAKEN` handling while stock Feint keeps its separate AoE avoidance aura. Their reductions therefore multiply to 58 percent total AoE reduction rather than adding to 70 percent. Helper 901090 is non-dispellable, cannot be stolen, is not saved across logout, and follows the same path for humans and bots.

```text
Ambush Trapper passive 901038 observes a Hunter trap activation
  -> finish-phase spell_proc requires Hunter family and the trap activation flag
  -> AuraScript requires the Hunter as actor and a trap triggerer as original target
  -> passive proc handler applies 15-second, five-charge aura 901039 to the Hunter
  -> a landed Hunter-family melee damage-class spell consumes one native charge
  -> helper 901040 deals floor(2% * min(target max health, Hunter max health))
  -> helper 901041 restores 5 percent maximum mana
```

Ambush Strike participates in direct Spell Scaling before PvP Balancing. Below level 80, scaling multiplies the capped base amount by the Hunter's level divided by 80 and converts to an integer. PvP Balancing then applies its configured integer reduction for player victims. Humans and bots follow the same bounded path with no combat-time database access.

```text
Primal Resolve 901042 cast by a Hunter
  -> native all-school aura reduces damage taken by 15 percent
  -> script effect removes current MECHANIC_SNARE auras
  -> roots remain and no ongoing movement immunity is granted
  -> Hunter remains attack-capable and targetable for the 6-second duration
  -> parent spell retains its 30-second cooldown
```

The cleanup uses the deployment core's `RemoveMovementImpairingAuras(false)` path. Damage reduction composes through the core's normal multiplicative damage-taken aura handling and adds no module damage hook or runtime state. Humans and bots receive identical mechanics when they cast the spell; acquisition and playerbot cast policy remain external.

```text
Alchemical Guard 901077 cast by a Rogue
  -> native poison and disease immunities purge matching existing auras
  -> new poison and disease applications are immune for 6 seconds
  -> native all-school aura reduces damage taken by 20 percent
  -> magic, curse, bleed, and other effect classifications remain unchanged
  -> controlled-cast attributes permit use while stunned, feared, or confused
  -> prevention type zero permits use while silenced or pacified
  -> allow-while-stealthed preserves stealth and the normal GCD starts
  -> parent spell retains its 60-second cooldown
```

All gameplay effects use native spell and aura handling. The bound AuraScript validates the graph but does not add per-event work or runtime state. Acquisition and playerbot cast decisions remain external.

```text
Crimson Vial 901083 cast by a Rogue
  -> consume 20 Energy and start a 45-second cooldown and one-second GCD
  -> apply one non-dispellable, non-saved six-second self aura
  -> heal 5 percent current maximum health immediately
  -> heal 5 percent current maximum health at seconds 1 through 6
  -> resolve healing modifiers, dampening, absorption, and overheal per event
```

The data-only spell uses `SPELL_AURA_OBS_MOD_HEALTH` and the immediate-period attribute. The deployment core recalculates current maximum health for every tick and excludes this aura type from ordinary healing proc dispatch. No script, helper spell, scaling row, or combat-time database access is added. Humans and bots receive identical mechanics after external acquisition and cast.

```text
Apex Bond 901046 cast by a Hunter
  -> implicit TARGET_UNIT_PET supplies generic core and client pet presence validation
  -> SpellScript requires Player::GetPet() and a living active pet
  -> native percent effects heal pet and Hunter for 15 percent maximum health
  -> normal pet aura increases all pet damage by 15 percent for 10 seconds
  -> parent spell enters its 90-second cooldown
```

The active pet owns its temporary damage aura, so dismissal, swapping, death, and normal pet lifecycle cleanup cannot transfer the buff to another pet. Humans and bots follow the same bounded cast path; acquisition and cast policy remain external.

```text
Blood of the Hunt passive 901044 observes two event families
  -> positive Hunter melee-special damage at hit phase
     -> exact Raptor Strike, Mongoose Bite, Wing Clip, or Counterattack family mask
     -> helper 901045 receives floor(15% * post-mitigation damage)
  -> Hunter trap activation at finish phase with a real triggerer
     -> helper 901045 receives floor(5% * Hunter maximum health)
  -> either accepted branch starts one shared 2000 ms aura proc cooldown
```

Blood Heal participates in direct HEAL scaling. Below level 80, Spell Scaling multiplies the supplied helper amount by the Hunter's level divided by 80 and converts to an integer. Rejected and zero-damage events do not start the cooldown. Humans and bots follow the same bounded path with no combat-time database access.

```text
Melee Specialization passive 901047 is active
  -> aura type 262 reports selected Hunter melee aura states as satisfied
     -> Counterattack currently declares caster aura state 7
     -> Raptor Strike and Mongoose Bite currently declare caster aura state 0
  -> misc value 1 also suppresses the surrounding combat requirement for affected spells
  -> aura type 108 registers a 30 percent SPELLMOD_DAMAGE modifier
  -> damage masks select Raptor Strike, Mongoose Bite, Wing Clip, and Counterattack
```

The passive uses only native spell data and adds no script registration or combat-time database access. Range, weapon, resource, cooldown, target, silence, disarm, and other cast checks remain unchanged. Humans and bots follow the same path.

```text
Blood Death Knight with Rupture passive 901048
  -> normal or critical melee auto hit, or exact Blood Strike, Heart Strike, or Death Strike rank hit
  -> apply one helper 901049 stack to that event target and refresh its 15-second duration
  -> every two seconds native periodic calculation adds 0.5 percent melee AP per stack
  -> physical and bleed modifiers, PERIODIC scaling, and PvP balancing compose on the tick
```

The helper caps at 200 stacks, ignores armor through bleed mechanic 15, and expires as one aura when applications stop for 15 seconds. Heart Strike secondary targets dispatch separate hit events. Humans and bots use identical mechanics, and the proc path performs no database work.

```text
Crimson Ward passive 901050 observes positive incoming combat damage
  -> one aura-owned 60000 ms spell_proc cooldown accepts the event
  -> triggering damage resolves before the helper is active
  -> helper 901051 snapshots floor(20% * current maximum health)
  -> all-school absorb remains for up to 15 seconds
```

The helper has no dispel type, is non-save, and does not dynamically resize after maximum-health changes. Zero-damage and environmental events do not enter this proc path. Crimson Ward has no Spell Scaling row, adds no module damage hook, and behaves identically for humans and bots.

```text
Frozen Resolve passive 901052 ticks every two seconds
  -> out of combat: no action
  -> in combat: trigger one self-cast of timed aura 901053
  -> native stacking adds one stack up to 10 and refreshes the shared eight-second duration
  -> the stacked aura adds 2 percent armor and 2 percentage points of all-school combat-damage reduction per stack
```

The permanent passive owns the periodic timer, so combat entry does not reset the cadence. At the cap, accepted ticks refresh duration without increasing stacks. Native stack calculation reaches +20 percent armor and one 0.80 all-school combat-damage multiplier at 10 stacks; separate damage-taken auras compose multiplicatively. Environmental self-damage follows the core's separate path and bypasses this multiplier. Leaving combat or losing the passive stops applications, and helper 901053 expires no later than eight seconds after its last accepted tick. The path is constant-time, performs no database access, and is identical for humans and bots.

```text
Rime Shards passive 901054 observes Frost Strike or Howling Blast damage
  -> positive normal or critical event receives one 30 percent roll
  -> snapshot 20 percent of event damage into helper 901055
  -> center a 10-yard Frost burst on that event target
  -> select no more than 10 enemies
  -> each receives floor(base * (2N - 1) / N^2) before final Frost resolution
```

Each Howling Blast victim and Threat of Thassarian Frost Strike off-hand hit is an independent event. Aggregate helper output grows from 100 percent with one target to 190 percent with ten targets, while per-target output diminishes. The helper has no Spell Scaling row because its base amount already derives from source damage. Normal Frost modifiers and PvP balancing still apply when each helper hit resolves. Humans and bots follow the same path.

```text
Necrotic Veil passive 901056 observes direct-owner outgoing damage
  -> snapshot floor(10 percent of positive post-mitigation event damage)
  -> compute floor(35 percent of current maximum health)
  -> create or increase helper 901057 without exceeding that cap
  -> refresh the helper to 60 seconds after a positive contribution
  -> school mask 126 absorbs magic damage but excludes Physical
```

Pet, guardian, self, zero-damage, healing, and environmental events do not contribute. Triggered direct or periodic damage can contribute when it emits a normal proc event with the Death Knight as the exact actor. The helper stores only its remaining absorb amount, performs no database access, has no separate Spell Scaling row, and behaves identically for humans and bots.

```text
Pestilent Eruption passive 901058 is active
  -> a Death Coil or Scourge Strike rank completes a successful hostile hit
  -> additive source-chain script retrieves passive effect 0
  -> trigger long-range carrier 901059 on the hit target at no cost
  -> existing spell_dk_pestilence spreads owned diseases and applies glyph refresh rules
```

Only parent rank chains 47541 and 55090 are bound. Death Coil damage helper 47632 and Scourge Strike Shadow helper 70890 cannot duplicate the trigger. Friendly Death Coil healing is rejected by the hostile-target gate. Carrier 901059 copies stock Pestilence effects and targeting, uses Death Coil's 30-yard range, and invokes the core Pestilence script for disease and glyph behavior. The path stores no custom runtime state, performs no database access, and behaves identically for humans and bots.

```text
Pestilent Knives 901069
  -> charge 35 Energy and start a 20-second cooldown
  -> select at most ten enemies within 10 yards
  -> each successful effect deals 50 percent Physical weapon damage
  -> resolve the main-hand temporary enchant's Deadly Poison combat spell
  -> cast that poison twice below five caster-owned stacks
     or once when the target already has five stacks
  -> stock spell_rog_deadly_poison applies the rank and handles the other weapon
```

The cast snapshots the main-hand item and Deadly Poison spell before hit handling. A target beginning at four stacks reaches five on the first poison cast and triggers the normal full-stack interaction on the second. A target already at five receives only one poison cast, bounding the opposite poison to one trigger per enemy. The script stores no persistent state, performs no database access, and behaves identically for humans and bots after an active cast.

```text
Divine Storm 53385 with passive 901014
  -> AfterCast schedules a caster-owned one-second event
  -> event requires the player in world, alive, and still affected by 901014
  -> triggered echo 901015 selects up to 12 enemies around the current position
  -> normalized weapon hit, critical strike, and proc results at 55 percent weapon damage
  -> existing spell_pal_divine_storm derives proportional healing from final damage
```

The scheduler is bound only to 53385, so echo 901015 cannot recursively schedule itself. The delayed event stores only the caster GUID and does not retain the original target.

```text
Permanent Seal of Righteousness passive 901016
  -> explicit proc metadata selects melee and magic damage hit events
  -> AuraScript accepts melee auto-attacks, melee abilities, and paladin judgement damage
  -> stock AP, Holy power, target vulnerability, libram, and weapon-speed formula
  -> triggered SoR damage 25742, doubled on JotJ judgement events
  -> real SoR and permanent SoR remain independently active when combined

Permanent Seal of Vengeance passive 901060
  -> stock Vengeance proc filters accept melee events and JotJ judgement damage
  -> existing Holy Vengeance 31803 stack is read before application
  -> stock damage 42463 scales from 6.6 to 33 percent weapon damage
  -> auto-attacks and Hammer of the Righteous apply one 31803 stack
  -> real Vengeance and permanent Vengeance both proc when combined
```

Both passives retain the Paladin family but have zero family masks, so they never enter `SPELL_SPECIFIC_SEAL` exclusivity, judgement selection, or judgement aura-state handling. Explicit seal-damage filters prevent recursion. Same-seal combinations are intentionally additive; the two Vengeance paths share the caster's normal five-stack 31803 aura and can add two stacks on one eligible attack. Humans and bots follow the same bounded paths.

```text
Divine Steed 901017
  -> four-second dummy and normal 100 percent run-speed auras
  -> Alliance display 14584 or Horde display 19085
  -> UNIT_FIELD_MOUNTDISPLAYID changes without Unit::Mount or UNIT_FLAG_MOUNT
  -> the next successful non-triggered player spell removes aura 901017
  -> removal clears only the recorded display while not mechanically mounted
  -> logout and map-change hooks remove the aura and reconcile leaked display state
```

The client receives the rider-and-horse composition, but `IsMounted()` remains false. Ordinary casts are permitted, then the player spell hook removes Divine Steed after a successful non-triggered cast; triggered children and proc casts are ignored. Auto-attacks, pets, indoor use, action bars, vehicles, and mount collision height are unaffected. Humans and bots follow the same bounded path.

```text
Guardian's Vengeance 901018
  -> critical melee, direct spell damage, or periodic damage event
  -> native proc trigger casts Guardian's Resolve 901019 on the paladin
  -> add one stack and refresh the complete eight-second duration, capped at three

Sacred Vengeance 901020
  -> critical direct or periodic healing event
  -> native proc trigger casts Sacred Fervor 901021 on the paladin
  -> add one stack and refresh the complete eight-second duration, capped at three
```

Guardian's Resolve grants 1 percent all-school damage reduction and 10 flat defense rating per stack. Sacred Fervor grants 2 percent healing done and 10 mp5 per stack. Triggered events may qualify, but Beacon copies 53652 through 53654 cannot crit and therefore do not add a second stack after their critical source heal. Humans and bots follow identical native proc paths.

```text
Extended Arsenal 901022 or 901023
  -> flat SPELLMOD_RANGE of 3 or 6 yards
  -> flat SPELLMOD_JUMP_TARGETS of 1 or 2 targets
  -> Paladin family mask selects Avenger's Shield and Hammer of the Righteous
  -> native chain selection preserves each spell's hop radius and restrictions
```

The checked-in deployment DBC places Avenger's Shield in mask word 1 bit `0x00004000` and Hammer in mask word 2 bit `0x00040000`. Both base spells have a chain target count of three and accept caster spell modifiers. No script, proc row, or combat-time database access is involved, and humans and bots follow identical native paths.

```text
Divine Toll 901024 on a hostile target with a real seal
  -> schedule exactly five impacts and apply sequence-state aura
  -> execute immediately, then every 500 ms using GUID re-resolution
  -> invalid original target selects nearest valid hostile replacement
  -> transient marker 901025 guarantees ordinary hit checks and scopes exceptions
  -> Justice visual 901026 and debuff 20184
  -> current seal's stock Judgement damage with normal proc events
  -> marked Judgement and seal damage reduced by 20 percent before mitigation
  -> first successful impact clears shared Judgement cooldown category
```

The sequence cancels on caster death, logout, map change, real-seal loss, or cast-lock state. Vengeance and Corruption add a real stack before damage. A marker-scoped exception lets passive 901016 fire beside real SoR. An additive rank-chain check on Judgements of the Wise allows its first marked event and rejects later marked events. Heart of the Crusader, Judgements of the Just, Righteous Vengeance, and generic procs retain normal paths. Humans and bots follow identical behavior, and acquisition remains external.

```text
Conflagrate rank chain with passive 901027
  -> effect script captures the exact caster-owned Immolate rank
  -> core damage calculation consumes source Immolate unless glyph-protected
  -> post-hit search around the primary target excludes invalid and already affected units
  -> up to three random enemies receive full matching-rank Immolate
```

The capture hook runs before `Spell::EffectSchoolDamage`, while spread runs after the successful single-target hit. Shadowflame can enable normal Conflagrate but cannot supply an Immolate rank. Humans and bots follow the same bounded path with no combat-time database access.

```text
Soul Link aura 25228 processes incoming damage
  -> calculate stock 20 percent split
  -> if passive 901033 is active, replace it with 50 percent of current damage
  -> core caps the transfer to remaining damage
  -> core removes the transfer from the Warlock and damages the living demon
```

Demonic Equilibrium checks the passive per hit, so acquisition and removal take effect without a Soul Link recast. It leaves activation spell 19028, demon eligibility, school filtering, combat logs, and proc dispatch on the stock path. Humans and bots use identical bounded logic with no combat-time database access.

```text
Dispel targets an Immolate or Shadowflame aura from a Warlock with passive 901034
  -> Aura::CalcDispelChance resolves the aura's original caster
  -> native operation 28 matches Immolate word 0 bit 2 or Shadowflame word 2 bit 1
  -> add 100 percent resist-dispel chance and clamp resistance to 100
  -> return zero dispel chance and skip the aura without removing it
```

Unquenchable Flames evaluates the caster's current spell modifiers at each dispel attempt. Existing caster-owned auras become protected when the passive is learned and return to stock dispel behavior when it is removed. Expiration, Conflagrate consumption, death cleanup, immunity cleanup, and scripted removal remain unchanged. Humans and bots use the same native path with no script or combat-time database access.

```text
Dispel targets a matching Warlock aura whose owner has passive 901035
  -> Aura::CalcDispelChance resolves the original caster and spell-mod owner
  -> operation 28 intersects family mask (0xC04CC41A, 0x1804161B, 0)
  -> add 100 percent resist-dispel chance and clamp resistance to 100
  -> return zero dispel chance and skip the aura without removing it
```

Unyielding Shadows covers curses, Corruption, Fear, Howl of Terror, Death Coil, Banish, drains, Seed of Corruption, Shadowfury, Haunt, Shadow Embrace, matching legacy Siphon Life variants, and owner-demon effects. Unstable Affliction's unique word 1 bit `0x00000100` is absent, preserving its stock dispel and backlash path. Existing matching auras react immediately when the passive is learned or removed. Humans and bots use the same native path with no script or combat-time database access.

```text
Chaos Bolt rank chain with passive 901031
  -> successful projectile impact casts helper 901032 at the hit position
  -> ally-category guardian 900002 is created for 20 seconds without replacing PetGUID
  -> stock Inferno Effect 22703 resolves meteor damage and area stun
  -> guardian attacks the impact target and later follows owner assist events
```

The module clone of stock Infernal 89 preserves its model, addon auras, level data, and owner-derived scaling while isolating custom autonomous AI from normal Infernal behavior. Every qualifying hit adds another guardian with no explicit count cap. The 20-second balance lifetime and Chaos Bolt cooldown bound ordinary overlap. Humans and bots share the path, and no combat-time database access occurs.

```text
Haunt rank chain with passive 901028
  -> every successful AfterHit casts the highest ranks known in the active specialization
  -> preserve a different same-caster curse by skipping Curse of Agony
  -> preserve same-caster Seed of Corruption by skipping Corruption
  -> apply Unstable Affliction independently
```

There is no internal cooldown or runtime marker gate. Triggered stock casts preserve caster ownership, normal refreshes, Unstable Affliction dispel behavior, and playerbot aura awareness. Humans and bots follow identical behavior, and acquisition remains external.

```text
Demonology Warlock with passive 901030 casts Metamorphosis 59672
  -> stock activation starts the normal cooldown
  -> aura 47241 maximum duration becomes -1
  -> learning 901030 during an active form upgrades the existing aura
  -> death retains stock removal behavior
  -> passive loss, talent reset, login recovery, logout, or mount attempt removes aura 47241
  -> stock aura removal clears linked effects and temporary abilities
```

The global mount cast check removes enhanced Metamorphosis before shapeshift validation so valid mount spells can proceed. A later failed mount check still leaves the form removed, and dismounting never reapplies it. Humans and bots retain the existing 59672 activation and 47241 form checks.

### Melee, healing, and absorbs

- Melee damage is changed only by PvP balancing.
- Configured direct healing is changed only by spell scaling.
- Configured absorb auras are recalculated and scaled in `SpellScalingUnit::OnAuraApply`.
- Blazing Barrier first derives its absorb from base amount plus fire spell power in its `AuraScript`; spell 901001 is also configured as an `ABSORB` scaling entry.

### AuraScript hook context

Aura accessors are hook-specific. In the deployment core, `AuraScript::GetTarget()` requires an active `AuraApplication` and returns `nullptr` from `DoEffectCalcAmount`; amount handlers that need the aura-bearing unit must use `GetUnitOwner()` instead. Before dereferencing an AuraScript accessor in a new hook, verify that hook in `SpellScript.cpp` and retain an appropriate null guard. Violating this rule caused Crimson Ward helper 901051 to dereference a null owner through `Object::GetUInt32Value` during absorb calculation.

## Data boundaries

| Database | Objects | Access |
|---|---|---|
| `acore_world` | `mod_spec_spells`, `mod_spell_scaling`, creatures 900001 and 900002, `summonproperties_dbc`, `creature_template_model`, `creature_template_addon`, `pet_levelstats`, `spell_dbc`, `spell_ranks`, `spell_proc`, `spell_script_names`, `spell_bonus_data`, `spell_custom_attr`, `wotlk_spells` | `WorldDatabase` or core spell loaders |
| `acore_characters` | `mod_player_spec`, `mod_player_spec_talent_budget`, currently unused `mod_player_spec_talent_grant` | `CharacterDatabase` |

`data/mod_apocalipse.sql` explicitly switches from `acore_world` to `acore_characters` before creating the per-character tables. Keep that boundary intact.

## Custom spell graph

| Spell | Server definition | Script binding | Scaling | Client requirement |
|---|---|---|---|---|
| 901001 Blazing Barrier | Manual `data/2026_09_16_01_blazing_barrier.sql` | `spell_apoc_mage_blazing_barrier` from `data/mod_apocalipse.sql` or the manual migration | `ABSORB` row in `mod_spell_scaling` | Matching client `Spell.dbc` and patch |
| 901002 Battleground Stamina Assistance | Automatic module world update under `data/sql/db-world/` | No `spell_script_names` binding | Not in spell scaling | Matching client `Spell.dbc` and patch |
| 901003 Pyroclastic Chain Reaction | Automatic `data/sql/db-world/2026_09_17_00_pyroclastic_chain_reaction.sql` | Pyroblast `-11366` and explosion `-44461` bindings | Reuses normal Pyroblast and Living Bomb paths | Matching client `Spell.dbc` and separate talent data |
| 901004 Missile Barrage Overload | Automatic `data/sql/db-world/2026_09_17_01_missile_barrage_overload.sql` | Exact 44401 and 901004 bindings | Extends normal Arcane Missiles periodic duration without changing missile damage | Matching client `Spell.dbc` and separate talent data |
| 901005 Hypernova | Automatic `data/sql/db-world/2026_09_17_01_hypernova.sql` | `spell_apoc_mage_hypernova` on 901005 | Native Arcane damage, destination knockback, and coefficient 2.856 | Matching client `Spell.dbc`; acquisition is separate |
| 901006 Prismatic Barrier | Automatic `data/sql/db-world/2026_09_17_02_prismatic_barrier.sql` | `spell_apoc_mage_prismatic_barrier` on 901006 | Reuses Mana Shield 43020, Ice Barrier 43039, and Blazing Barrier 901001 | Matching client `Spell.dbc`; acquisition is separate |
| 901007-901009 Frost Bomb graph | Automatic baseline plus follow-up updates under `data/sql/db-world/` | Application, explosion, and slow scripts on their exact IDs | Native Frost direct damage with 0.8 coefficient and Permafrost rank effects | Three matching client `Spell.dbc` rows; acquisition is separate |
| 901010-901011 Automatic Ice Lance graph | Automatic `data/sql/db-world/2026_09_17_04_automatic_ice_lance.sql` | Passive proc and haste scripts on their exact IDs | Reuses Ice Lance 30455 and native spell-haste aura handling | Two matching client `Spell.dbc` rows; passive acquisition is separate |
| 901012-901013 Frozen Retaliation rank chain | Automatic `data/sql/db-world/2026_09_17_05_frozen_retaliation.sql` | Negative -901012 binding covers both `spell_ranks` rows | Rank-specific taken-damage proc chance reuses Fingers of Frost aura 44544 | Two matching client `Spell.dbc` rows with rank labels; acquisition is separate |
| 901075-901076 Leeching Mixture graph | Automatic `data/sql/db-world/2026_09_22_03_rogue_leeching_mixture.sql` | `spell_apoc_rogue_leeching_mixture` on 901075 | Owner-attributed Rogue poison damage generates a non-critical self-heal with a one-second raw cap | Two matching client `Spell.dbc` rows; acquisition is separate |
| 901078 Buckler Strike | Automatic `data/sql/db-world/2026_09_22_06_buckler_strike.sql` | `spell_apoc_rogue_buckler_strike` on 901078 | Physical melee damage, native combo point and interrupt, shield validation, and final-damage threat | Matching client `Spell.dbc`; acquisition and bot cast policy are separate |
| 901079-901080 Gloomblade Infusion graph | Automatic `data/sql/db-world/2026_09_22_07_gloomblade_infusion.sql` | `spell_apoc_rogue_gloomblade_infusion` on 901079 | Broad owner-attributed damage produces a non-critical, zero-coefficient Shadow helper hit | Two matching client `Spell.dbc` rows; Subtlety acquisition is included |
| 901081-901082 Shadow Execution graph | Automatic `data/sql/db-world/2026_09_22_08_shadow_execution.sql` | `spell_apoc_rogue_shadow_execution` on both IDs | Direct Rogue ability damage adds a ten-second, one-second-tick Shadow aura whose 50 stacks each use one percent AP-modified main-hand damage | Two matching client `Spell.dbc` rows; acquisition is separate |
| 901083 Crimson Vial | Automatic `data/sql/db-world/2026_09_22_09_crimson_vial.sql` | No script binding | Native immediate plus six periodic 5 percent current-maximum-health healing events with no ordinary healing proc dispatch | Matching client `Spell.dbc`; acquisition and bot cast policy are separate |
| 901089-901090 Improved Feint graph | Automatic `data/sql/db-world/2026_09_22_09_improved_feint.sql` | Negative -1966 binding covers all stock Feint ranks | Successful Feint casts trigger six seconds of native 30 percent all-school reduction while preserving stock AoE avoidance | Two matching client `Spell.dbc` rows; acquisition references only passive 901089 |
| 901084-901088 Relentless Finale graph | Automatic `data/sql/db-world/2026_09_22_10_relentless_finale.sql` | `spell_apoc_rogue_relentless_finale` on 901084 and 901087 plus player and global spell hooks | Visible infinite readiness, cast-scoped native combo retention, 5 percent maximum-health healing, and post-use 12-second recharge | Five matching client `Spell.dbc` rows; acquisition references only passive 901084 |
| 901091-901117 Shaman spell pack | Automatic `data/sql/db-world/2026_09_24_00_shaman_spell_pack.sql` | Additive Flame Shock, Lava Burst, Riptide, Chain Heal, custom aura, and player cast hooks from `mod_apocalipse_shaman_spells.cpp` | Native spell modifiers, exact-rank propagation, a same-map Flame Shock registry, level-selected shield payloads, bounded healing and damage procs, and three actives | Twenty-seven matching client `Spell.dbc` rows; acquisition and active bot policy are separate |
| 901118-901154 Priest ability pack | Automatic `data/sql/db-world/2026_09_24_01_priest_spell_pack.sql` | Additive Penance child, Priest periodic, Mind Blast, Mind Flay, custom aura, unit output, summon, and player cast hooks from `mod_apocalipse_priest_spells.cpp` | Native spell modifiers, fixed-duration periodic haste, bounded proc helpers, caster-target storage, and a same-map periodic-target registry | Thirty-seven matching server rows and deployed client data; acquisition and active bot policy are separate |
| 901038-901041 Ambush Trapper graph | Automatic `data/sql/db-world/2026_09_21_00_ambush_trapper.sql` | Trap passive and charged buff bindings on 901038 and 901039 | Native five charges, capped Physical helper with DAMAGE scaling, and percent mana energize | Four matching client `Spell.dbc` rows; acquisition references only passive 901038 |
| 901042 Primal Resolve | Automatic `data/sql/db-world/2026_09_21_03_primal_resolve.sql` | `spell_apoc_hunter_primal_resolve` on 901042 | Native all-school damage reduction plus one-time scripted snare removal | Matching client `Spell.dbc`; acquisition and bot cast policy are separate |
| 901077 Alchemical Guard | Automatic `data/sql/db-world/2026_09_22_04_alchemical_guard.sql` | `spell_apoc_rogue_alchemical_guard` on 901077 | Native all-school damage reduction and poison/disease purge and immunity | Matching client `Spell.dbc`; acquisition and bot cast policy are separate |
| 901046 Apex Bond | Automatic `data/sql/db-world/2026_09_21_01_apex_bond.sql` | `spell_apoc_hunter_apex_bond` on 901046 | Native percent healing, pet target validation, cooldown, and all-damage pet aura | Matching client `Spell.dbc`; acquisition and bot cast policy are separate |
| 901044-901045 Blood of the Hunt graph | Automatic `data/sql/db-world/2026_09_21_01_blood_of_the_hunt.sql` | `spell_apoc_hunter_blood_of_the_hunt` on 901044 | Shared melee/trap proc cooldown and direct helper with HEAL scaling | Two matching client `Spell.dbc` rows; acquisition references only passive 901044 |
| 901047 Melee Specialization | Automatic `data/sql/db-world/2026_09_21_02_melee_specialization.sql` | No script binding; native aura-state and spell-modifier handlers | Exact Hunter family masks bypass declared aura states, currently only Counterattack, and apply 30 percent `SPELLMOD_DAMAGE` to the three selected families plus Wing Clip | Matching client `Spell.dbc`; acquisition is separate |
| 901050-901051 Crimson Ward graph | Automatic `data/sql/db-world/2026_09_21_04_crimson_ward.sql` | Passive and absorb helper bindings on their exact IDs | Shared 60-second incoming-damage proc cooldown and 15-second all-school absorb equal to 20 percent maximum health | Two matching client `Spell.dbc` rows; Blood Spec Manager acquisition references only passive 901050 |
| 901048-901049 Death Knight Rupture graph | Automatic `data/sql/db-world/2026_09_21_04_death_knight_rupture.sql` | `spell_apoc_death_knight_rupture` on 901048 | Per-target 200-stack physical bleed with 0.005 AP coefficient and PERIODIC scaling | Two matching client `Spell.dbc` rows; Blood Spec Manager acquisition is included |
| 901052-901053 Frozen Resolve graph | Automatic `data/sql/db-world/2026_09_21_05_frozen_resolve.sql` | `spell_apoc_death_knight_frozen_resolve` on 901052 | Combat-gated periodic self-cast reuses native stacking, Physical armor percentage, and all-school damage-taken handling | Two matching client `Spell.dbc` rows; acquisition references only passive 901052 |
| 901054-901055 Rime Shards graph | Automatic `data/sql/db-world/2026_09_21_06_death_knight_rime_shards.sql` | Passive and target-centered helper bindings on their exact IDs | 30 percent source-event proc, 20 percent damage snapshot, ten-target diminishing Frost burst, and no separate scaling row | Two matching client `Spell.dbc` rows; Frost Spec Manager acquisition is included |
| 901056-901057 Necrotic Veil graph | Automatic `data/sql/db-world/2026_09_21_07_death_knight_necrotic_veil.sql` | `spell_apoc_death_knight_necrotic_veil` on 901056 | Direct-owner outgoing damage accumulates a 60-second magic-only absorb capped at 35 percent maximum health | Two matching client `Spell.dbc` rows; Unholy Spec Manager acquisition references only passive 901056 |
| 901058-901059 Pestilent Eruption graph | Automatic `data/sql/db-world/2026_09_21_07_death_knight_pestilent_eruption.sql` | Additive negative bindings on rank chains 47541 and 55090 plus `spell_dk_pestilence` on 901059 | Successful hostile source hits trigger a 30-yard carrier that reuses existing disease and glyph logic | Two matching client `Spell.dbc` rows; Unholy Spec Manager acquisition references only passive 901058 |
| 901069 Pestilent Knives | Automatic `data/sql/db-world/2026_09_22_03_rogue_pestilent_knives.sql` | `spell_apoc_rogue_pestilent_knives` on 901069 | Bounded 50 percent weapon area effect reuses the main-hand Deadly Poison rank and stock full-stack interaction | Matching client `Spell.dbc`; Assassination Spec Manager acquisition is included and bot cast policy remains separate |
| 901014-901015 Divine Storm Echo graph | Automatic `data/sql/db-world/2026_09_18_02_divine_storm_echo.sql` | Scheduler on 53385 and existing `spell_pal_divine_storm` on 901015 | Delayed normalized 55 percent weapon attack reuses Divine Storm target, proc, and healing paths | Two matching client `Spell.dbc` rows; acquisition references unranked passive 901014 only and echo acquisition is forbidden |
| 901016 and 901060 Permanent Paladin seals | Automatic baseline plus `2026_09_22_01_permanent_paladin_seals.sql` | Exact pseudo-seal bindings on 901016 and 901060 | Reuses stock SoR damage 25742 and Vengeance effects 31803 and 42463 without entering real seal or judgement selection; same-seal combinations remain additive | Two matching client `Spell.dbc` rows; acquisition references either unranked passive and remains separate |
| 901017 Divine Steed | Automatic baseline plus `2026_09_20_01_divine_steed_cast_cancel.sql` | `spell_apoc_paladin_divine_steed` on 901017 plus player cast and lifecycle cleanup | Normal run-speed aura with display-only faction charger, no mounted state, and cancellation after another non-triggered player spell | Matching client `Spell.dbc`; acquisition is separate |
| 901018-901021 Paladin Vengeance variants | Automatic `data/sql/db-world/2026_09_18_04_paladin_vengeance_variants.sql` | No script binding; native proc-trigger auras and `spell_proc` rows | Three-stack Protection damage reduction/defense or Holy healing/mp5 buff | Four matching client `Spell.dbc` rows; acquisition references only passives 901018 and 901020 |
| 901022-901023 Extended Arsenal rank chain | Automatic `data/sql/db-world/2026_09_18_05_extended_arsenal.sql` | No script binding; native flat spell modifiers | Adds 3/6 yards and 1/2 chain targets to Hammer of the Righteous and Avenger's Shield | Two matching client `Spell.dbc` rows with rank labels; acquisition is separate |
| 901024-901026 Divine Toll graph | Automatic baseline plus `2026_09_22_00_spell_balance_adjustments.sql` | Parent orchestration, -31876 JotW gate, and additive stock-damage bindings | Reuses active-seal Judgement formulas for five impacts, reduces marked hit damage by 20 percent, and preserves downstream PvP and proc paths | External backend derives matching client data; acquisition and patch deployment are separate |
| 901027 Burning Conflagration | Automatic `data/sql/db-world/2026_09_20_04_burning_conflagration.sql` | Additional `-17962` Conflagrate rank-chain binding | Reuses the captured stock Immolate rank with full initial and periodic damage behavior | Matching client row and separate talent acquisition data required |
| 901028-901029 Haunting Affliction graph | Automatic baseline plus `2026_09_22_00_spell_balance_adjustments.sql` | Additional `-48181` Haunt rank-chain binding | Resolves and casts learned stock DoT ranks on every Haunt with curse and Seed exclusions; legacy marker 901029 is unused | Two matching client rows; acquisition references only passive 901028 |
| 901030 Permanent Metamorphosis | Automatic `data/sql/db-world/2026_09_20_03_permanent_metamorphosis.sql` | Global duration, mount pre-check, and player cleanup hooks | Makes stock aura 47241 infinite without replacing activation 59672 or its cooldown | Matching client row; Demonology Spec Manager acquisition is included |
| 901031-901032 Chaotic Inferno graph | Automatic `data/sql/db-world/2026_09_20_05_chaotic_inferno.sql` | Additional `-50796` Chaos Bolt rank-chain binding plus guardian AI and stat hook | Reuses stock Inferno Effect 22703 and Infernal model/scaling through non-pet guardian 900002 | Two matching client rows; acquisition references only passive 901031 |
| 901033 Demonic Equilibrium | Automatic baseline plus `2026_09_22_00_spell_balance_adjustments.sql` | Additional stock aura 25228 split binding | Replaces Soul Link's current split amount with 50 percent while the passive is active | Matching client row and separate talent acquisition data required |
| 901034 Unquenchable Flames | Automatic `data/sql/db-world/2026_09_20_07_unquenchable_flames.sql` | No script binding; native flat spell modifier | Adds 100 percent resist-dispel chance to exact Immolate and Shadowflame family masks | Matching client row and separate talent acquisition data required |
| 901035 Unyielding Shadows | Automatic `data/sql/db-world/2026_09_20_08_unyielding_shadows.sql` | No script binding; native flat spell modifier | Adds 100 percent resist-dispel chance to matching curses and Shadow debuffs while excluding UA | Matching client row and separate talent acquisition data required |

A server-only row can provide mechanics but not complete client presentation. A client-only row cannot provide server mechanics.

## Failure and recovery paths

| Failure | Result | Diagnostic or recovery |
|---|---|---|
| Missing custom table | Related cache remains empty | Module warning log; apply manual schema and restart |
| Invalid spell 901002 contract | Battleground assistance is disabled | `[BattlegroundStamina]` error at config load |
| Missing spell 901001 or binding | Blazing Barrier cannot load or validate correctly | Check `spell_dbc` and `spell_script_names` before startup |
| Missing spell 901003 or rank bindings | Pyroclastic Chain Reaction cannot load or does not affect Pyroblast | Check the module updater and `spell_script_names` entries `-11366` and `-44461` |
| Missing talent data for 901003 | The passive exists but cannot be acquired through the intended talent | Deploy matching server and client talent data separately |
| Missing spell 901004 or overload bindings | Missile Barrage remains normal or passive cleanup is absent | Check the module updater and exact 44401 and 901004 script bindings |
| Missing talent data for 901004 | The passive exists but cannot be acquired through the intended talent | Deploy matching server and client talent data separately |
| Missing spell 901005, binding, aura 36032, or visual 35426 | Hypernova cannot load fully or loses its script behavior | Check the Hypernova updater, base DBC, script validation, and client patch |
| Missing spell 901006, binding, or child barrier | Prismatic Barrier cannot load fully or spends its cost without activating barriers | Check the Prismatic Barrier updater, child spell rows, script bindings, and client patch |
| Missing Frost Bomb spell, binding, Permafrost rank chain, or aura 68391 | Frost Bomb fails script validation or loses explosion and slow behavior | Check the Frost Bomb updater, all three bindings, base mage spell data, and client patch |
| Missing Frozen Retaliation rank, `spell_ranks` row, `spell_proc` row, binding, or aura 44544 | One or both ranks fail to load, use the wrong chance, or cannot grant Fingers of Frost | Check both custom rows, the 901012 rank chain, separate proc rows, -901012 binding, base mage spell data, and client patch |
| Missing Divine Storm Echo passive, echo, or binding | Scheduling validation fails, the echo cannot cast, or proportional healing is absent | Check 901014, 901015, both exact bindings, the core Divine Storm script, and client patch |
| Missing permanent SoR passive, proc row, or binding | Overlay damage does not occur or script validation fails | Check 901016, its exact proc and script rows, base SoR damage 25742, and client patch |
| Missing Divine Steed row, binding, or non-save attribute | Sprint validation fails, display lifecycle is absent, or the aura can persist unexpectedly | Check 901017, its exact script and custom-attribute rows, and client patch |
| Missing Vengeance variant row or proc metadata | The corresponding passive cannot add or correctly scale its timed buff | Check 901018 through 901021, the exact `spell_proc` rows, non-save attributes, and client patch |
| Missing Extended Arsenal row or rank metadata | The passive cannot modify range and target count or the higher rank may not replace the lower rank | Check 901022 and 901023, their exact effect masks, the `spell_ranks` rows, and client patch |
| Missing Leeching Mixture graph, proc metadata, binding, or registration | Rogue poison damage cannot heal, attribution filtering drifts, or the one-second cap is absent | Check 901075 and 901076, Rogue poison metadata, helper coefficients, script binding, loader registration, and client export |
| Missing Gloomblade Infusion graph, proc metadata, binding, or registration | Broad Rogue damage does not produce the separate Shadow hit or recursion safeguards are absent | Check 901079 and 901080, broad proc flags, zero coefficient, script binding, Subtlety acquisition, loader registration, and client export |
| Missing Shadow Execution graph, proc metadata, either binding, or registration | Rogue abilities cannot add stacks or helper ticks use the unscaled base point | Check 901081 and 901082, direct Rogue proc flags, both exact bindings, zero coefficients, non-save metadata, loader registration, external single-rank acquisition, and client export |
| Missing Crimson Vial row or client export | The self-heal is unavailable or the client presents an incorrect cost, cooldown, cadence, or stealth contract | Check 901083, immediate-period and non-critical attributes, aura type 20, one-second amplitude, non-save metadata, external acquisition, and client export |
| Missing Improved Feint graph, rank-chain binding, or registration | Feint retains only stock behavior or the helper contract is incomplete | Check 901089 and 901090, negative -1966 binding, six-second native all-school aura, non-save metadata, loader registration, external passive acquisition, and client export |
| Missing Ambush Trapper row, proc metadata, binding, or registration | Trap activation cannot grant charges, or melee specials cannot trigger damage and mana | Check 901038 through 901041, both proc rows, both bindings, loader registration, scaling row, and client export |
| Missing Primal Resolve row, binding, or registration | Damage reduction or on-cast snare cleanup is unavailable | Check 901042, effect contracts, script binding, loader registration, and client export |
| Missing Alchemical Guard row, binding, or registration | Validation fails or the defensive cannot provide its native reduction and immunities | Check 901077, all three aura effects, cast attributes, binding, loader registration, and client export |
| Missing Apex Bond row, binding, or registration | Cast validation or effects are unavailable, or pet presence is not represented to the client | Check 901046, its implicit pet targets, script and custom-attribute rows, loader registration, and client export |
| Missing Blood of the Hunt row, helper, proc metadata, binding, or registration | Eligible melee specials or trap activations cannot heal, or the shared cooldown is absent | Check 901044 and 901045, proc row, binding, loader registration, HEAL scaling row, and client export |
| Missing Melee Specialization row or mismatched family masks | Reactive abilities remain gated or the damage modifier affects the wrong Hunter spells | Check 901047 effects, misc values, all six effect class-mask words, and client export |
| Missing Crimson Ward row, helper, proc metadata, binding, or registration | Incoming damage cannot create the shield, the amount or duration is wrong, or the shared cooldown is absent | Check 901050 and 901051, proc row, both bindings, custom attribute, loader registration, and client export |
| Missing Rupture graph, binding, bonus, or scaling row | Passive fails validation, does not apply, or helper damage and low-level scaling drift | Check 901048-901049 spell rows, proc and script rows, `spell_bonus_data`, `mod_spell_scaling`, and client export |
| Missing Frozen Resolve row, helper, binding, or registration | Periodic validation fails, stacks do not apply, or armor and reduction amounts drift | Check 901052 and 901053, deterministic die sides and base points, script and custom-attribute rows, loader registration, and client export |
| Missing Rime Shards graph, proc metadata, bindings, or registration | Source events do not proc, the burst is not target-centered, or the target curve drifts | Check 901054 and 901055, proc row, both bindings, maximum targets, visual lookup, loader registration, and client export |
| Missing Necrotic Veil graph, proc metadata, binding, or registration | Damage cannot build the absorb, the cap or duration drifts, or Physical damage consumes it | Check 901056 and 901057, proc row, magic school mask, non-save metadata, loader registration, and client export |
| Missing Pestilent Eruption graph, bindings, or registration | Eligible hits do not cast Pestilence, ranged Death Coil fails, or source helpers produce duplicates | Check 901058 and 901059, negative 47541 and 55090 bindings, core Pestilence binding, range 160, loader registration, and client export |
| Missing Divine Toll row, marker, visual, or additive binding | The cast fails validation, loses sequencing, permits repeated JotW, or deals unscaled stock damage | Check 901024 through 901026, -31876, all listed damage bindings, and external client export |
| Missing Burning Conflagration row or binding | The passive cannot validate or Conflagrate does not spread Immolate | Check 901027, binding -17962, loader registration, and matching client and talent data |
| Missing Permanent Metamorphosis row or Spec Manager acquisition | Demonology players do not receive passive 901030 or clients cannot display it | Check the 901030 updater, `mod_spec_spells`, loader registration, and client export |
| Missing Permanent Metamorphosis registration | Aura 47241 retains stock duration and lifecycle hooks do not run | Check `AddModApocalipseWarlockPermanentMetamorphosisScripts()` and rebuild the module |
| Missing Chaotic Inferno spell, summon, creature, properties, or registration | Chaos Bolt cannot summon, the impact is incomplete, or guardians lack ownership, scaling, or autonomous assist | Check 901031, 901032, creature 900002, summon properties, cloned support rows, `-50796`, loader registration, and both client rows |
| Missing Demonic Equilibrium row, binding, or registration | Soul Link remains at stock 20 percent even when 901033 is learned | Check 901033, binding 25228, loader registration, and matching client and talent data |
| Missing Unquenchable Flames row or native modifier fields | Immolate and Shadowflame retain stock dispel chance even when 901034 is learned | Check operation 28, amount 100, exact family masks, and matching client and talent data |
| Missing Unyielding Shadows row or native modifier fields | Curses and Shadow debuffs retain stock dispel chance when 901035 is learned | Check operation 28, amount 100, combined family mask, UA exclusion, and matching client and talent data |
| Missing acquisition data for 901005 | Hypernova exists but cannot be learned normally | Add acquisition through its separately owned workflow |
| Config reload during active battleground | New values are cached but existing auras are not immediately swept | Re-enter battleground, trigger an application hook, or restart according to operator plan |
| Bot lacks a valid session | Bot exception is not detected | Fix bot lifecycle; do not add heuristic fallback |
| Custom spell ID collision | Guarded migration should fail instead of overwriting another spell | Allocate a new ID and update code, SQL, config, scaling data, and docs together |

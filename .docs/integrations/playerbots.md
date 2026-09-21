# mod-playerbots integration

Status: Active

Last source review: 2026-09-17 against the sibling `mod-playerbots` checkout

## Boundary

This module is not an AI extension for `mod-playerbots`. It defines no bot strategy, trigger, action, value, multiplier, manager, or update loop. It uses AzerothCore gameplay hooks that also receive bot-controlled `Player` objects.

The deployment target is the custom playerbot AzerothCore branch used by `mod-playerbots`, not an independently validated stock AzerothCore build. The key explicit integration API is `WorldSession::IsBot()`.

## Bot detection contract

The module detects a bot only when all of these are true:

1. A `Player` exists.
2. `Player::GetSession()` returns a session.
3. `WorldSession::IsBot()` returns true.

This is used in:

- `src/mod_apocalipse.cpp` through `IsBotSession()`.
- `src/battleground_stamina/BattlegroundStaminaScripts.cpp` through `IsPlayerbot()`.

Do not replace this with account-name, security-level, online-state, or `PlayerbotAI` pointer heuristics.

## Behavior matrix

| Subsystem | Humans | Bots | Bot-specific difference |
|---|---|---|---|
| Spec Manager | Reconciled on login/talent events; receives system messages | Same grant, revoke, persistence, and talent-budget logic | Success and talent-reset chat messages are suppressed |
| Spell Scaling | Selected spells scale by player caster level | Same | None |
| PvP Balancing | Damage to player victims is reduced | Same, whether attacker or victim is a bot-backed player | None |
| Blazing Barrier | Same spell and talent behavior | Same | None |
| Pyroclastic Chain Reaction | Passive-gated Pyroblast interaction with 30 percent damage on propagated Living Bombs | Same when the bot has learned passive 901003 | None; talent acquisition remains external |
| Missile Barrage Overload | Accumulated proc count extends Arcane Missiles | Same when the bot has learned passive 901004 | Existing AI checks aura presence but does not wait for a higher count; acquisition remains external |
| Hypernova | Target-centered Arcane burst grants four Arcane Blast stacks | Same when the bot has learned spell 901005 | Knockback packets use the existing playerbot spline path; acquisition remains external |
| Prismatic Barrier | Activates Mana Shield, Ice Barrier, and Blazing Barrier together | Same when the bot has learned spell 901006 | None; acquisition and rotation policy remain external |
| Frost Bomb | Delayed target-centered Frost damage and Permafrost-scaled slow | Same when the bot has learned spell 901007 | None; acquisition and rotation policy remain external |
| Automatic Ice Lance | Mage-family Frost damage, including periodic and triggered damage, can trigger Ice Lance and independently expiring haste | Same when the bot has learned passive 901010 | None; acquisition remains external and the existing rotation needs no special cast action |
| Frozen Retaliation | Incoming combat damage can grant Fingers of Frost at the known rank's chance | Same when the bot has learned rank 901012 or 901013 | None; acquisition remains external and no cast action is needed |
| Ambush Trapper | Trap activation grants five charged melee-special damage and mana procs | Same when the bot has acquired passive 901038 | None; existing trap and melee-special actions need no change, and acquisition remains external |
| Primal Resolve | Active defensive removes current snares and reduces all damage taken | Same when the bot has acquired and casts 901042 | None in mechanics; acquisition and the required active cast-decision action remain external |
| Apex Bond | Active pet sustain heals the Hunter and living active pet and buffs pet damage | Same when the bot has acquired and casts 901046 | None; acquisition and cast-decision policy remain external |
| Blood of the Hunt | Melee specials and trap activations provide self-healing on one shared cooldown | Same when the bot has acquired passive 901044 | None; existing melee-special and trap actions need no change, and acquisition remains external |
| Melee Specialization | Counterattack bypasses its reactive aura-state gate; Raptor Strike and Mongoose Bite remain freely castable; those abilities and Wing Clip deal 30 percent increased damage | Same when the bot has acquired passive 901047 | None; native spell modifiers apply to existing melee actions and acquisition remains external |
| Divine Storm Echo | Divine Storm schedules a half-damage echo while passive 901014 is active | Same when the bot has acquired passive 901014 | None; existing Divine Storm actions need no change and acquisition remains external |
| Permanent Seal of Righteousness | Passive 901016 adds stock SoR damage beside another real seal and suppresses itself beside real SoR | Same when the bot has acquired passive 901016 | None; existing melee and judgement actions need no change and acquisition remains external |
| Divine Steed | Active 901017 doubles run speed for up to four seconds with a faction-specific cosmetic charger and ends after another successful non-triggered spell | Same when the bot has acquired and casts 901017 | None; no mounted state or AI dependency is introduced, and acquisition/rotation remain external |
| Paladin Vengeance variants | Critical damage or healing events refresh the corresponding three-stack buff | Same when the bot has acquired passive 901018 or 901020 | None; native proc handling applies and acquisition remains external |
| Extended Arsenal | Increases Hammer of the Righteous and Avenger's Shield range and chain targets | Same when the bot has acquired rank 901022 or 901023 | None; native spell modifiers apply and acquisition remains external |
| Divine Toll | Sequences one through five half-damage Judgement impacts with dynamic seal and proc behavior | Same when the bot has acquired and casts 901024 | None; acquisition and cast-decision policy remain external |
| Burning Conflagration | Successful Conflagrate hits spread the caster's exact Immolate rank to up to three nearby enemies | Same when the bot has acquired passive 901027 | None; existing Immolate and Conflagrate actions need no change and acquisition remains external |
| Chaotic Inferno | Every successful Chaos Bolt calls down a full Inferno impact and independent 20-second assisting guardian | Same when the bot has acquired passive 901031 | None; existing Chaos Bolt actions need no change, guardian AI is server-owned, and acquisition remains external |
| Demonic Equilibrium | Raises Soul Link damage transfer from 20 percent to 75 percent | Same when the bot has acquired passive 901033 | None; existing Soul Link actions need no change and acquisition remains external |
| Unquenchable Flames | Prevents dispels from removing the caster's Immolate and Shadowflame effects | Same when the bot has acquired passive 901034 | None; native spell-modifier handling applies and acquisition remains external |
| Unyielding Shadows | Prevents dispels from removing matching curses and Shadow debuffs while excluding Unstable Affliction | Same when the bot has acquired passive 901035 | None; native owner spell-modifier handling also covers matching demon effects, and acquisition remains external |
| Haunting Affliction | Successful Haunt hits apply eligible highest-known Affliction DoTs once per caster cooldown | Same when the bot has acquired passive 901028 | None; existing DoT triggers observe caster-owned auras and acquisition remains external |
| Permanent Metamorphosis | Activated Metamorphosis remains until normal or explicit cleanup while passive 901030 is active | Same through Demonology Spec Manager acquisition | Existing AI casts 59672, checks aura 47241, and recasts only after cleanup and the normal cooldown |
| Battleground Stamina | Eligible players receive assistance; non-combat-swappable gear is locked | Eligible bots receive assistance | Equipment lock is bypassed so bot auto-gearing can continue |

Player-owned pets and guardians are treated as player attackers by PvP balancing through `GetCharmerOrOwnerPlayerOrPlayerItself()`. This applies whether the owning player is human-controlled or bot-controlled.

## Equipment interaction

`BattlegroundStaminaPlayerScript` allows bot sessions through both can-equip and can-unequip hooks. It does not disable the stamina system for bots. After a bot equips or unequips an item, normal player equipment hooks recalculate the baseline and aura amount.

This separation is intentional:

- Human players cannot exploit preparation or battleground time by swapping most armor and accessories.
- Bot AI can continue its normal automatic equipment management.
- Both receive assistance based on current gear.

## Talent interaction

Bots pass through the same `ModSpecPlayer` hooks as humans. The Spec Manager can add hidden bonus talent points and managed talents, which may affect how bot class/spec logic sees learned spells. Changes to managed spell lists must therefore be tested with representative bot classes even though no playerbot AI code is changed here.

On talent learn, both Spec Manager and Battleground Stamina receive hooks. Spec reconciliation can change passive stamina or health modifiers; the battleground handler recalculates assistance from current player state. Neither subsystem should assume a fixed callback order.

## Performance and thread assumptions

These handlers execute through AzerothCore script dispatch rather than the bot AI decision loop. No per-tick scan is added by this module. Database queries in the Spec Manager occur on login and talent reconciliation, so a large simultaneous bot-login or talent-update event can multiply character-database traffic.

Before adding work to a bot-related hook:

1. Identify the custom core hook and execution context.
2. Keep operations bounded per event.
3. Avoid adding database access to frequent combat or AI update paths.
4. Preserve valid-session checks and reentrancy guards.
5. Test at representative bot population, not only with one human player.

## Verification scenarios

| Scenario | Expected result | Status at 2026-09-16 |
|---|---|---|
| Bot login with a dominant talent tree | Spec spells and hidden budget reconcile without chat spam | Not run in this review |
| Bot auto-equips armor in a battleground | Equip is allowed and stamina assistance recalculates | Not run in this review |
| Human attempts the same armor swap | Equip or unequip is denied | Not run in this review |
| Bot casts a configured low-level scaling spell | Same level multiplier as a human player caster | Not run in this review |
| Bot or bot-owned pet damages a player | PvP modifiers apply | Not run in this review |
| Bot changes talents while in a battleground | Spec layer and stamina assistance both reconcile without recursion | Not run in this review |
| Bot with passive 901003 casts Pyroblast into its own Living Bomb | Same 20 percent proc, refresh, explosion, and bounded spread as a human | Not run in this review |
| Bot with passive 901004 accumulates and releases Missile Barrage | Same charge count, added missiles, visual, and aggregate consumption as a human | Not run in this review |
| Bot casts Hypernova 901005 | Same damage, charge grant, target area, and spline knockback result as a human cast | Not run in this review |
| Bot casts Frost Bomb 901007 | Same detonation causes, area damage, proc behavior, and Permafrost-scaled slow as a human cast | Not run in this review |
| Bot with passive 901010 deals eligible Frost damage | Same automatic Ice Lance, Fingers of Frost consumption, and independent haste expirations as a human | Not run in this review |
| Bot with Frozen Retaliation 901012 or 901013 takes positive combat damage | Same rank-specific chance and Fingers of Frost refresh as a human | Not run in this review |
| Bot with passive 901038 activates a trap and lands Hunter melee specials | Same five charges, capped Physical damage, mana restoration, and expiration as a human | Not run in this review |
| Bot casts Primal Resolve 901042 while snared | Same snare removal, root exclusion, damage reduction, duration, and cooldown as a human | Not run in this review |
| Bot with passive 901044 activates a trap or deals damage with an eligible melee special | Same self-healing and shared two-second cooldown as a human | Not run in this review |
| Bot with passive 901014 casts Divine Storm 53385 | Same delayed half-damage echo, target selection, procs, and healing as a human | Not run in this review |
| Bot with passive 901016 uses melee attacks or judgements beside another seal | Same stock SoR overlay damage, real-SoR suppression, and Judgements of the Just behavior as a human | Not run in this review |
| Bot casts Divine Steed 901017, then another rotation spell | Same faction display, speed, cooldown, triggered-cast exclusion, and cancellation after the next successful non-triggered spell as a human | Not run in this review |
| Bot with passive 901018 or 901020 produces a qualifying critical event | Same stack addition, refresh, cap, and buff amounts as a human | Not run in this review |
| Bot with Extended Arsenal 901022 or 901023 casts Hammer or Avenger's Shield | Same rank-specific range and added target count as a human | Not run in this review |
| Bot casts Divine Toll 901024 with each supported seal | Same target validation, random sequence, retargeting, half damage, cooldown reset, and proc limits as a human | Not run in this review |
| Bot with passive 901027 casts Conflagrate into its own Immolate | Same rank capture, exclusions, random three-target cap, and full Immolate applications as a human | Not run in this review |
| Bot with passive 901031 lands one or several Chaos Bolts | Same impacts, cooldown-bounded 20-second guardians, normal-pet coexistence, scaling, assist, duration, and cleanup as a human | Not run in this review |
| Bot with passive 901033 takes damage with Soul Link active | Same 75 percent transfer to its living controlled demon as a human | Not run in this review |
| Bot with passive 901034 applies Immolate or Shadowflame | Same zero dispel chance for that bot-owned aura as a human-owned aura | Not run in this review |
| Bot with passive 901028 lands Haunt with and without curse or Seed conflicts | Same caster-global cooldown, learned DoT ranks, ownership, and exclusions as a human | Not run in this review |
| Demonology bot with passive 901030 casts Metamorphosis | Same infinite aura 47241 duration, normal 59672 cooldown, cleanup, and later recast behavior as a human | Not run in this review |
| Bot casts any learned Blizzard rank | Same 1.5 second cast and 12 second persistent ground effect as a human | Not run in this review |

## Related repository context

The sibling `mod-playerbots/AGENTS.md` and its `.docs/` pages describe bot ownership, AI engines, lifecycle, and threading. Read them when a proposed change crosses from generic `PlayerScript` behavior into playerbot AI or manager code. Keep each repository's documentation focused on the code it owns, and link the boundary rather than copying the full playerbot architecture here.

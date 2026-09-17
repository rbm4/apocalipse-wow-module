# mod-playerbots integration

Status: Active

Last source review: 2026-09-16 against the sibling `mod-playerbots` checkout

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

## Related repository context

The sibling `mod-playerbots/AGENTS.md` and its `.docs/` pages describe bot ownership, AI engines, lifecycle, and threading. Read them when a proposed change crosses from generic `PlayerScript` behavior into playerbot AI or manager code. Keep each repository's documentation focused on the code it owns, and link the boundary rather than copying the full playerbot architecture here.

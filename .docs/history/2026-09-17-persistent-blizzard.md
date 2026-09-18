# 2026-09-17: Persistent Blizzard migration

Status: Reverted

## Intent

The original proposal globally converted the player Blizzard rank chain from a channel into a persistent normal cast.

## Reversion

The class council rejected the global Blizzard redesign before deployment. The automatic migration and active feature documentation were removed. No SQL migration, client patch, worldserver startup, or in-game scenario was run for this design.

Future Blizzard behavior belongs to the Frost Bomb feature as a potential triggered ground effect and must not modify the stock player Blizzard rank chain globally.

## Verification

| Check | Result |
|---|---|
| Persistent Blizzard migration removed | Passed by repository inspection |
| Active documentation references removed | Passed by repository inspection |
| SQL execution | Not run |
| Client patch export | Not run |
| Runtime behavior | Not run |

## References

- Current owner: [`../custom-spells/frost-bomb.md`](../custom-spells/frost-bomb.md)
- Commit or PR: Not created

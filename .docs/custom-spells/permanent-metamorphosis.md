# Permanent Metamorphosis

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_warlock_permanent_metamorphosis.cpp`, `data/sql/db-world/2026_09_20_03_permanent_metamorphosis.sql`, `data/mod_apocalipse.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-20

## Purpose

Permanent Metamorphosis is a Demonology Warlock passive that removes the duration from an activated Metamorphosis transformation without replacing the normal activation spell or its cooldown.

## Acquisition contract

The Spec Manager grants passive 901030 to a Warlock whose dominant tree is Demonology. It continues to grant active Metamorphosis 59672 independently. The passive is unranked and must not replace either 59672 or transformation aura 47241 in talent, spellbook, or playerbot references.

## Human and bot applicability

Human and bot-controlled Warlocks use identical duration and cleanup hooks. Existing Demonology playerbot logic casts 59672 and checks transformation aura 47241, so it does not need a module-specific action. After cleanup, the bot can activate Metamorphosis again only when the normal cooldown permits.

## Spell graph

| Spell | Role | Contract |
|---:|---|---|
| 901030 | Permanent Metamorphosis | Permanent passive granted by the Demonology Spec Manager profile |
| 59672 | Metamorphosis | Existing player activation and normal cooldown owner |
| 47241 | Metamorphosis transformation | Existing aura whose maximum duration becomes infinite only for a passive owner |
| 50589 | Immolation Aura | Existing linked aura removed through normal Metamorphosis cleanup |

## Runtime flow

```text
Demonology Warlock has passive 901030
  -> casts existing Metamorphosis 59672
  -> transformation aura 47241 enters duration calculation
  -> AllSpellScript sets maximum duration to -1
  -> active form remains until stock death cleanup or explicit module cleanup
```

The script does not cast Metamorphosis automatically, bypass cooldowns, copy transformation effects, or alter stock spell data globally.

## Cleanup

The module makes an already-active aura 47241 infinite when the player learns 901030. It removes aura 47241 when:

- The player forgets passive 901030.
- The player's talents are reset while the passive is known.
- A passive owner logs in with a transformation restored from an earlier periodic save or interrupted shutdown.
- The player begins logout.
- The player attempts a mount spell while both the passive and transformation are active.

The mount cleanup runs in the strict global cast check before the core shapeshift check. This permits a mount that would otherwise be rejected by active Metamorphosis. Because cleanup must precede later mount checks, a mount attempt can end Metamorphosis even if a later rule rejects that mount. Dismounting does not restore the transformation.

Stock aura removal remains responsible for removing linked Immolation Aura and temporary Metamorphosis abilities. Death removes the non-death-persistent transformation normally. Map changes do not remove it.

## Database and client contract

The automatic world update collision-checks 901030 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`, installs the passive spell row, adds it to the Demonology Spec Manager profile, and synchronizes the backend name cache. The manual baseline contains the same Spec Manager seed for new installations.

A matching 901030 row must be exported into the deployed client `Spell.dbc` through the backend's existing database-driven exporter. Spells 59672 and 47241 remain stock rows and are not copied or globally modified.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Warlock without 901030 casts 59672 | Aura 47241 retains its stock duration | Not run |
| Warlock with 901030 casts 59672 | Normal cooldown starts and aura 47241 has infinite duration | Not run |
| Active transformed Warlock dies | Aura 47241 and linked Meta state are removed | Not run |
| Active transformed Warlock mounts | Aura 47241 is removed before shapeshift validation and mount proceeds when otherwise valid | Not run |
| Mount attempt later fails another check | Aura 47241 remains removed | Not run |
| Warlock dismounts | Metamorphosis does not return automatically | Not run |
| Passive is learned while stock Metamorphosis is active | Existing aura 47241 immediately becomes infinite | Not run |
| Passive is revoked or talents reset | Aura 47241 and linked Meta state are removed | Not run |
| Player logs out while transformed | Aura 47241 is removed and is not restored at login | Not run |
| Passive owner logs in after a periodic save and interrupted shutdown | Restored aura 47241 is removed before play resumes | Not run |
| Human and playerbot Warlock | Identical activation, cooldown, duration, and cleanup | Not run |

## Rollback

Stop worldserver, take the normal world-database backup, remove spell 901030 from `mod_spec_spells`, `wotlk_spells`, and `spell_dbc`, restore the previous client patch, rebuild without the source and loader registration, and restart. Existing stock Metamorphosis rows and cooldowns require no rollback.

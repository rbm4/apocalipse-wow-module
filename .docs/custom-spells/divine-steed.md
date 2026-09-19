# Divine Steed

Status: Implemented in source, build and runtime not verified

Owners: `src/mod_apocalipse_paladin_divine_steed.cpp`, `data/sql/db-world/2026_09_18_04_divine_steed.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-18

## Purpose

Divine Steed is an active paladin sprint that increases run speed by 100 percent for four seconds on a 20-second cooldown. It shows a faction-specific paladin charger while preserving ordinary combat, casting, pet, action-bar, indoor, and collision behavior.

## Acquisition boundary

The module defines active spell 901017 but does not teach it or modify trainers, talents, specialization data, items, or playerbot acquisition. The separate acquisition owner must grant exactly 901017 and provide matching client spell data.

## Human and bot applicability

Human and bot-controlled paladins use identical spell, speed, display, and cleanup behavior. The implementation performs no bot detection and no database work in combat. Playerbot rotation and acquisition policy remain external.

## Spell graph

| Spell | Role | Contract |
|---:|---|---|
| 901017 | Divine Steed | Four-second, non-dispellable self aura with a normal 100 percent run-speed effect, a 20-second cooldown, and a display-only dummy effect |
| 23214 | Existing Charger reference | Its verified mount display 14565 is reused for Alliance players; the spell itself is never cast |
| 34767 | Existing Thalassian Charger reference | Its verified mount display 20030 is reused for Horde players; the spell itself is never cast |

## Runtime flow

```text
cast 901017 while unmounted
  -> apply the four-second dummy and run-speed auras
  -> choose display 14565 for Alliance or 20030 for Horde
  -> write UNIT_FIELD_MOUNTDISPLAYID without Unit::Mount or UNIT_FLAG_MOUNT
  -> ordinary attacks and spells remain available
  -> on removal, clear only the display installed by this aura and only while not mechanically mounted
```

The spell has no `SPELL_AURA_MOUNTED`, mounted-speed aura, vehicle effect, or core exemption. `IsMounted()` remains false, so ordinary casting, auto-attacks, indoor use, pets, collision height, and action bars remain unchanged.

## Cleanup and mount interaction

Aura removal clears the display only when it still equals the faction-specific value recorded by that aura and the player is not mechanically mounted. If a real mount replaces the display before Divine Steed expires, the removal hook leaves the legitimate mount display intact.

`apoc_paladin_divine_steed_player` removes the aura before logout and after a map change, then clears a leaked module-owned display only when the player is not mechanically mounted. Normal aura cleanup handles expiration, manual cancellation, death, and dispel-independent removal. Spell 901017 is marked non-save in `spell_custom_attr` so it cannot persist through `character_aura`.

## Database and client contract

The automatic world update:

1. Collision-checks 901017 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`.
2. Inserts only a missing row and recognizes only the expected cooldown, duration, class, dummy, target, and run-speed signature as module-owned.
3. Installs the exact AuraScript binding and non-save custom attribute.
4. Synchronizes the backend spell-name cache used by the client export workflow.

A matching client `Spell.dbc` row is required for spellbook presentation, tooltip, icon, cooldown, duration, and effects. The checked-in backend `Spell.dbc` contains neither 901017 nor any other module-owned row at that ID. Live world tables and the selected deployment client remain pending collision checks.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Alliance player casts 901017 in combat | Display 14565 appears for four seconds and run speed doubles | Not run |
| Horde player casts 901017 in combat | Display 20030 appears for four seconds and run speed doubles | Not run |
| Indoor cast | Cast succeeds and uses the same mechanics | Not run |
| Melee, auto-attack, and ordinary spell casts during sprint | Combat continues because `IsMounted()` remains false | Not run |
| Player has a pet | Pet remains summoned | Not run |
| Aura expires, is cancelled, or player dies | Module-owned display and speed are removed | Not run |
| Player logs out or changes map during sprint | Aura and module-owned display are removed | Not run |
| Real mount replaces the display before sprint removal | Real mount display remains intact | Not run |
| Male and female models of every enabled paladin race | Rider attachment and animations remain acceptable | Not run |
| Human and playerbot paladin | Identical spell and cleanup behavior | Not run |

## Rollback

Stop worldserver, take the normal world-database backup, remove the exact 901017 script and custom-attribute rows, remove 901017 from `wotlk_spells` and `spell_dbc`, restore the previous client patch, rebuild without the source and loader registration, then restart. Acquisition data is external and must be rolled back by its owner.

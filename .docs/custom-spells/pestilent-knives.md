# Pestilent Knives

Status: Implemented in source and data, build and runtime not verified

Owners: `src/mod_apocalipse_rogue_pestilent_knives.cpp`, `data/sql/db-world/2026_09_22_03_rogue_pestilent_knives.sql`, `src/mod_apocalipse_loader.cpp`

Last source review: 2026-09-22

## Purpose

Pestilent Knives is an Assassination Rogue active using spell 901069. It costs 35 Energy, has a 20-second cooldown, and deals 50 percent weapon damage to up to ten enemies within 10 yards. Every enemy hit receives two applications of the Deadly Poison rank currently applied to the Rogue's main-hand weapon.

## Acquisition boundary

The world update assigns 901069 to Rogue specialization index 0 through `mod_spec_spells`. Spec Manager teaches and revokes it with the dominant Assassination tree. The active spell is the only custom ID in the graph and requires one matching client `Spell.dbc` row.

## Human and bot applicability

Humans and bot-controlled Rogues use identical damage, targeting, poison, resource, and cooldown mechanics. Acquisition is automatic through Spec Manager. The module does not add a playerbot cast-decision action, so whether a bot chooses the active remains playerbot policy.

## Spell contract

| Surface | Contract |
|---|---|
| Active | 901069 Pestilent Knives |
| Resource and cooldown | 35 Energy, 20 seconds, one-second global cooldown |
| Damage | 50 percent Physical weapon damage through the Fan of Knives weapon-percent effect contract |
| Area | Caster-centered 10-yard hostile area |
| Target cap | Ten enemies selected once for damage and poison handling |
| Poison source | Combat spell from the main-hand temporary enchant when it is a Rogue Deadly Poison rank |
| Poison result | Native weapon-enchant rolls are suppressed; two explicit Deadly Poison applications occur below five stacks and one occurs when already at five stacks |
| Art | Fan of Knives 51723 visual and icon copied from stock spell data during migration |
| Registration | `AddModApocalipseRoguePestilentKnivesScripts()` |

## Runtime flow

```text
Pestilent Knives cast
  -> normal cast checks charge 35 Energy and start the 20-second cooldown
  -> select at most ten hostile units within 10 yards
  -> each successful weapon-percent effect deals 50 percent weapon damage
  -> resolve the main-hand temporary enchant once for this cast
     -> no main-hand Deadly Poison means no poison applications
     -> target below five caster-owned Deadly Poison stacks receives two casts
     -> target already at five stacks receives one cast
  -> stock spell_rog_deadly_poison handles each application
     -> applies or refreshes the selected Deadly Poison rank
     -> when the pre-hit stack count is five, procs eligible poison from the other weapon
```

## Poison and full-stack contract

The spell suppresses automatic weapon-enchant rolls from its weapon hit so only the deliberate poison applications execute. The script does not synthesize a poison aura or hard-code a damage rank. At cast load it reads the main-hand item's temporary enchant, finds its Rogue poison combat spell, and accepts it only when its family flags match Deadly Poison. Triggered casts carry that same main-hand item as the cast item, allowing the stock `spell_rog_deadly_poison` script to identify the other equipped weapon for the normal full-stack interaction.

A target with zero through four stacks receives two Deadly Poison casts. This means a target beginning at four stacks reaches five on the first application and invokes the full-stack interaction on the second. A target beginning at five stacks receives only one cast, preventing the opposite poison from triggering twice. The cap is per enemy because each enemy's pre-hit stack count is evaluated independently.

Deadly Poison misses, immunity, resistance, same-caster aura ownership, rank damage, duration refresh, and opposite-poison eligibility remain stock core behavior. Poisons belonging to another Rogue do not count toward this Rogue's stack state.

## Damage, targeting, and overlap

The spell copies Fan of Knives' Physical weapon-percent shape, caster-centered targets, 10-yard radius, visual, and icon, but does not copy its family flag or dagger bonus. Its custom differences are 50 percent weapon damage, 35 Energy, a 20-second cooldown, and a ten-target cap. Random resize in the script and `MaxTargets = 10` in spell data both enforce the cap.

Weapon damage continues through core armor, critical strike, weapon modifier, proc, and AoE handling. PvP Balancing can modify final player-target damage through its existing direct-damage path. Pestilent Knives has no `mod_spell_scaling` row because its damage derives from weapon damage rather than a custom flat amount.

## Database and client contract

The automatic world update collision-checks 901069 in `spell_dbc`, `wotlk_spells_full`, and `wotlk_spells`. It installs the server spell row, script binding, Assassination acquisition row, and backend name cache. The migration reads Fan of Knives 51723 visual and icon from `wotlk_spells_full`, with local DBC-proven fallback values 12317 and 2904.

The deployed client row must preserve the same visual, icon, resource cost, cooldown, range, area target, radius, target cap, Rogue family mask, and 50 percent weapon-percent effect. Server data without the matching client patch is incomplete.

## Runtime verification matrix

| Scenario | Expected result | Status |
|---|---|---|
| Assassination specialization reconciliation | Rogue learns 901069; changing away revokes it | Not run |
| Cast with more than ten enemies nearby | Exactly ten or fewer enemies take damage and enter poison handling | Not run |
| Cast with no main-hand temporary poison | Weapon damage occurs and no poison is applied | Not run |
| Cast with off-hand Deadly Poison only | Weapon damage occurs and no Deadly Poison is applied | Not run |
| Main-hand Deadly Poison rank below maximum | That exact equipped rank is used | Not run |
| Target begins at zero through three stacks | Two stacks are added through normal poison casts | Not run |
| Target begins at four stacks | Target reaches five and opposite poison triggers once | Not run |
| Target begins at five stacks | Opposite poison triggers once, not twice | Not run |
| Several capped targets are hit | Each target can trigger the opposite poison once | Not run |
| Another Rogue owns five stacks | Those stacks do not alter this Rogue's handling | Not run |
| Human and playerbot Rogue | Mechanics are identical when cast | Not run |
| Resource and cooldown | Cast costs 35 Energy and starts a 20-second cooldown | Not run |
| Client patch | Fan of Knives art and correct tooltip data appear | Not run |

## Rollback

Stop worldserver and take the normal world-database backup. Remove 901069 from `mod_spec_spells`, `spell_script_names`, `wotlk_spells`, and `spell_dbc`. Rebuild without the source and loader registration, restore the previous client patch, and restart through the normal updater workflow.

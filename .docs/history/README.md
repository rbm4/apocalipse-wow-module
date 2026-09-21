# Engineering change history

## Purpose

This directory provides a durable, dated trace of completed work. It complements git history by recording the gameplay and operational contracts affected, verification actually performed, and follow-up that remains.

History records do not replace current feature or subsystem documentation. Current behavior belongs in the owner page; a history record explains what one completed unit of work changed.

## Rules

1. Add one `YYYY-MM-DD-<lowercase-kebab-scope>.md` file for each completed feature, fix, migration, or documentation foundation.
2. Copy [`../templates/history-entry.md`](../templates/history-entry.md).
3. Name behavior, not a ticket or contributor.
4. Link the current feature/subsystem page and any commit or PR.
5. State `Not run` for verification that was not performed.
6. Add the entry to the index below.
7. Do not edit old records to pretend they described later behavior. Update current docs and add a new record.
8. If work is reverted, retain the record and mark it `Reverted` with the new reference.

## Index

| Date | Change | Status | Current context |
|---|---|---|---|
| 2026-09-21 | Offline database policy | Completed | [`2026-09-21-offline-database-policy.md`](2026-09-21-offline-database-policy.md) |
| 2026-09-21 | Primal Resolve | Partial | [`2026-09-21-primal-resolve.md`](2026-09-21-primal-resolve.md) |
| 2026-09-21 | Melee Specialization | Partial | [`2026-09-21-melee-specialization.md`](2026-09-21-melee-specialization.md) |
| 2026-09-21 | Blood of the Hunt | Partial | [`2026-09-21-blood-of-the-hunt.md`](2026-09-21-blood-of-the-hunt.md) |
| 2026-09-21 | Apex Bond | Partial | [`2026-09-21-apex-bond.md`](2026-09-21-apex-bond.md) |
| 2026-09-21 | Ambush Trapper | Partial | [`2026-09-21-ambush-trapper.md`](2026-09-21-ambush-trapper.md) |
| 2026-09-20 | Unyielding Shadows | Partial | [`2026-09-20-unyielding-shadows.md`](2026-09-20-unyielding-shadows.md) |
| 2026-09-20 | Unquenchable Flames | Partial | [`2026-09-20-unquenchable-flames.md`](2026-09-20-unquenchable-flames.md) |
| 2026-09-20 | Demonic Equilibrium | Partial | [`2026-09-20-demonic-equilibrium.md`](2026-09-20-demonic-equilibrium.md) |
| 2026-09-20 | Chaotic Inferno | Partial | [`2026-09-20-chaotic-inferno.md`](2026-09-20-chaotic-inferno.md) |
| 2026-09-20 | Burning Conflagration | Partial | [`2026-09-20-burning-conflagration.md`](2026-09-20-burning-conflagration.md) |
| 2026-09-20 | Permanent Metamorphosis | Partial | [`2026-09-20-permanent-metamorphosis.md`](2026-09-20-permanent-metamorphosis.md) |
| 2026-09-20 | Haunting Affliction | Partial | [`2026-09-20-haunting-affliction.md`](2026-09-20-haunting-affliction.md) |
| 2026-09-20 | Divine Steed cast cancellation | Partial | [`2026-09-20-divine-steed-cast-cancellation.md`](2026-09-20-divine-steed-cast-cancellation.md) |
| 2026-09-20 | Frost Bomb damage and visual placement | Partial | [`2026-09-20-frost-bomb-damage-and-visual.md`](2026-09-20-frost-bomb-damage-and-visual.md) |
| 2026-09-19 | Divine Steed display-ID fix | Partial | [`2026-09-19-divine-steed-display-id-fix.md`](2026-09-19-divine-steed-display-id-fix.md) |
| 2026-09-18 | Custom-core API compatibility | Partial | [`2026-09-18-custom-core-api-compatibility.md`](2026-09-18-custom-core-api-compatibility.md) |
| 2026-09-18 | Divine Toll | Partial | [`2026-09-18-divine-toll.md`](2026-09-18-divine-toll.md) |
| 2026-09-18 | Extended Arsenal | Partial | [`2026-09-18-extended-arsenal.md`](2026-09-18-extended-arsenal.md) |
| 2026-09-18 | Paladin Vengeance variants | Partial | [`2026-09-18-paladin-vengeance-variants.md`](2026-09-18-paladin-vengeance-variants.md) |
| 2026-09-18 | Divine Steed | Partial | [`2026-09-18-divine-steed.md`](2026-09-18-divine-steed.md) |
| 2026-09-18 | Permanent Seal of Righteousness | Partial | [`2026-09-18-permanent-seal-of-righteousness.md`](2026-09-18-permanent-seal-of-righteousness.md) |
| 2026-09-18 | Divine Storm Echo | Partial | [`2026-09-18-divine-storm-echo.md`](2026-09-18-divine-storm-echo.md) |
| 2026-09-18 | Pyroclastic propagated damage | Partial | [`2026-09-18-pyroclastic-propagated-damage.md`](2026-09-18-pyroclastic-propagated-damage.md) |
| 2026-09-18 | Frost Bomb visual origin | Partial | [`2026-09-18-frost-bomb-visual-origin.md`](2026-09-18-frost-bomb-visual-origin.md) |
| 2026-09-18 | Automatic Ice Lance proc eligibility | Partial | [`2026-09-18-automatic-ice-lance-proc-eligibility.md`](2026-09-18-automatic-ice-lance-proc-eligibility.md) |
| 2026-09-18 | Prismatic Barrier Ice Barrier refresh | Partial | [`2026-09-18-prismatic-barrier-ice-refresh.md`](2026-09-18-prismatic-barrier-ice-refresh.md) |
| 2026-09-17 | Persistent Blizzard migration | Reverted | [`2026-09-17-persistent-blizzard.md`](2026-09-17-persistent-blizzard.md) |
| 2026-09-17 | Automatic Ice Lance migration rerun fix | Completed | [`2026-09-17-automatic-ice-lance-migration-rerun-fix.md`](2026-09-17-automatic-ice-lance-migration-rerun-fix.md) |
| 2026-09-17 | Frozen Retaliation | Partial | [`2026-09-17-frozen-retaliation.md`](2026-09-17-frozen-retaliation.md) |
| 2026-09-17 | Automatic Ice Lance | Partial | [`2026-09-17-automatic-ice-lance.md`](2026-09-17-automatic-ice-lance.md) |
| 2026-09-17 | Frost Bomb | Partial | [`2026-09-17-frost-bomb.md`](2026-09-17-frost-bomb.md) |
| 2026-09-17 | Prismatic Barrier | Partial | [`2026-09-17-prismatic-barrier.md`](2026-09-17-prismatic-barrier.md) |
| 2026-09-17 | Hypernova | Partial | [`2026-09-17-hypernova.md`](2026-09-17-hypernova.md) |
| 2026-09-17 | Missile Barrage Overload | Partial | [`2026-09-17-missile-barrage-overload.md`](2026-09-17-missile-barrage-overload.md) |
| 2026-09-17 | Pyroclastic Chain Reaction | Partial | [`2026-09-17-pyroclastic-chain-reaction.md`](2026-09-17-pyroclastic-chain-reaction.md) |
| 2026-09-16 | Battleground stamina spell migration repair | Completed | [`2026-09-16-battleground-stamina-spell-migration-repair.md`](2026-09-16-battleground-stamina-spell-migration-repair.md) |
| 2026-09-16 | Persistent documentation foundation | Completed | [`2026-09-16-documentation-foundation.md`](2026-09-16-documentation-foundation.md) |

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
| 2026-09-25 | Buckler Strike migration reapply fix | Completed | [`2026-09-25-buckler-strike-migration-reapply-fix.md`](2026-09-25-buckler-strike-migration-reapply-fix.md) |
| 2026-09-25 | Death Knight Rupture AP scaling | Partial | [`2026-09-25-death-knight-rupture-ap-scaling.md`](2026-09-25-death-knight-rupture-ap-scaling.md) |
| 2026-09-25 | Custom spell proc mask cleanup | Partial | [`2026-09-25-spell-proc-mask-cleanup.md`](2026-09-25-spell-proc-mask-cleanup.md) |
| 2026-09-25 | Shielded Reflexes | Partial | [`2026-09-25-shielded-reflexes.md`](2026-09-25-shielded-reflexes.md) |
| 2026-09-25 | Threat of Thassarian extension | Partial | [`2026-09-25-threat-of-thassarian-extension.md`](2026-09-25-threat-of-thassarian-extension.md) |
| 2026-09-25 | Bladeguard Rogue-family threat | Partial | [`2026-09-25-bladeguard-threat.md`](2026-09-25-bladeguard-threat.md) |
| 2026-09-25 | Buckler Strike damage, cooldown, and Blade Twisting balance | Partial | [`2026-09-25-buckler-strike-balance.md`](2026-09-25-buckler-strike-balance.md) |
| 2026-09-25 | Relentless Finale activation tracking fix | Partial | [`2026-09-25-relentless-finale-activation-tracking-fix.md`](2026-09-25-relentless-finale-activation-tracking-fix.md) |
| 2026-09-25 | Rogue shield skill rewards and client DBC | Partial | [`2026-09-25-rogue-shield-skill-rewards-and-client-dbc.md`](2026-09-25-rogue-shield-skill-rewards-and-client-dbc.md) |
| 2026-09-25 | Relentless Finale selected-target consumption fix | Partial | [`2026-09-25-relentless-finale-selected-target-fix.md`](2026-09-25-relentless-finale-selected-target-fix.md) |
| 2026-09-25 | Spell-script registration and validation follow-up | Partial | [`2026-09-25-spell-script-registration-and-validation-fix.md`](2026-09-25-spell-script-registration-and-validation-fix.md) |
| 2026-09-25 | Priest periodic-aura registration crash fix | Partial | [`2026-09-25-priest-dot-registration-crash-fix.md`](2026-09-25-priest-dot-registration-crash-fix.md) |
| 2026-09-24 | Shaman and Priest compilation fix | Partial | [`2026-09-24-shaman-priest-compilation-fix.md`](2026-09-24-shaman-priest-compilation-fix.md) |
| 2026-09-24 | Priest ability pack | Partial | [`2026-09-24-priest-ability-pack.md`](2026-09-24-priest-ability-pack.md) |
| 2026-09-24 | Shaman spell pack | Partial | [`2026-09-24-shaman-spell-pack.md`](2026-09-24-shaman-spell-pack.md) |
| 2026-09-22 | Crimson Ward amount-hook crash fix | Partial | [`2026-09-22-crimson-ward-amount-hook-crash-fix.md`](2026-09-22-crimson-ward-amount-hook-crash-fix.md) |
| 2026-09-22 | Pestilent Knives | Partial | [`2026-09-22-pestilent-knives.md`](2026-09-22-pestilent-knives.md) |
| 2026-09-22 | Daring Challenge | Partial | [`2026-09-22-daring-challenge.md`](2026-09-22-daring-challenge.md) |
| 2026-09-22 | Buckler Strike | Partial | [`2026-09-22-buckler-strike.md`](2026-09-22-buckler-strike.md) |
| 2026-09-22 | Gloomblade Infusion | Partial | [`2026-09-22-gloomblade-infusion.md`](2026-09-22-gloomblade-infusion.md) |
| 2026-09-22 | Shadow Execution | Partial | [`2026-09-22-shadow-execution.md`](2026-09-22-shadow-execution.md) |
| 2026-09-22 | Relentless Finale | Partial | [`2026-09-22-relentless-finale.md`](2026-09-22-relentless-finale.md) |
| 2026-09-22 | Crimson Vial | Partial | [`2026-09-22-crimson-vial.md`](2026-09-22-crimson-vial.md) |
| 2026-09-22 | Improved Feint | Partial | [`2026-09-22-improved-feint.md`](2026-09-22-improved-feint.md) |
| 2026-09-22 | Leeching Mixture | Partial | [`2026-09-22-leeching-mixture.md`](2026-09-22-leeching-mixture.md) |
| 2026-09-22 | Concentrated Venom | Partial | [`2026-09-22-concentrated-venom.md`](2026-09-22-concentrated-venom.md) |
| 2026-09-22 | Alchemical Guard | Partial | [`2026-09-22-alchemical-guard.md`](2026-09-22-alchemical-guard.md) |
| 2026-09-22 | Bladeguard | Partial | [`2026-09-22-bladeguard.md`](2026-09-22-bladeguard.md) |
| 2026-09-22 | Warlock and Divine Toll balance | Partial | [`2026-09-22-warlock-and-divine-toll-balance.md`](2026-09-22-warlock-and-divine-toll-balance.md) |
| 2026-09-21 | Pestilent Eruption | Partial | [`2026-09-21-pestilent-eruption.md`](2026-09-21-pestilent-eruption.md) |
| 2026-09-21 | Necrotic Veil | Partial | [`2026-09-21-necrotic-veil.md`](2026-09-21-necrotic-veil.md) |
| 2026-09-21 | Death Knight Rupture | Partial | [`2026-09-21-death-knight-rupture.md`](2026-09-21-death-knight-rupture.md) |
| 2026-09-21 | Rime Shards | Partial | [`2026-09-21-rime-shards.md`](2026-09-21-rime-shards.md) |
| 2026-09-21 | Frozen Resolve | Partial | [`2026-09-21-frozen-resolve.md`](2026-09-21-frozen-resolve.md) |
| 2026-09-21 | Crimson Ward | Partial | [`2026-09-21-crimson-ward.md`](2026-09-21-crimson-ward.md) |
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
| 2026-09-22 | Permanent Paladin seals | Partial | [`2026-09-22-permanent-paladin-seals.md`](2026-09-22-permanent-paladin-seals.md) |
| 2026-09-22 | Rogue shield proficiency | Partial | [`2026-09-22-rogue-shield-proficiency.md`](2026-09-22-rogue-shield-proficiency.md) |
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

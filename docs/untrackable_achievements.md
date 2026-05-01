# Untrackable Achievements

This document explains why certain achievements in `apworld/gcfw/rulesdata_achievements.py` are flagged `"untrackable": True` and grouped by the structural reason that prevents AP from gating them on guaranteed-reachable item state.

## What "untrackable" means

In this apworld, an achievement is **trackable** when AP logic can decide, from the player's collected item state, whether they could in principle satisfy the achievement. Reachability gates use `state.has(...)` checks on AP items.

An achievement is **untrackable** when satisfying it depends on something AP cannot observe through item state — such as in-battle RNG outcomes, transient combat state, micro-mechanics from the mod, or thresholds that exceed what the apworld's counter pools can express.

For untrackable achievements, the `requirements` field still gates the achievement on the *minimum* items needed to even attempt it (e.g. the relevant skill, the relevant battle mode), but AP cannot guarantee success — the player must still execute the in-game challenge.

There are 105 untrackable achievements as of this document. They fall into the categories below.

## Category 1 — RNG-driven gem creation

Gem grade and effective damage are influenced by random rolls during gem creation/combination. AP cannot guarantee a player will roll the right grade or damage even with optimal items.

| Achievement | AP ID | Description | Why untrackable |
|---|---|---|---|
| Adept Grade | 2009 | Create a grade 8 gem | Gem grade is RNG-influenced during fusion |
| Fifth Grader | 2174 | Create a grade 5 gem | RNG-influenced grade |
| Round Cut | 2453 | Create a grade 12 gem | RNG-influenced grade |
| Round Cut Plus | 2454 | Create a grade 16 gem | RNG-influenced grade |
| Quick Circle | 2428 | Create a grade 12 gem before wave 12 | RNG + tight time window |
| Hacked Gem | 2229 | Grade-3 gem with 1,200 effective max damage | Damage roll RNG |
| Hyper Gem | 2252 | Grade-3 gem with 600 effective max damage | Damage roll RNG |
| Super Gem | 2530 | Grade-3 gem with 300 effective max damage | Damage roll RNG |
| Wicked Gem | 2622 | Grade-3 gem with 900 effective max damage | Damage roll RNG |
| The Peeler | 2551 | Grade-12 pure armor-tearing gem | Grade RNG + creation conditions |
| Deckard Would Be Proud | 2118 | Build a 6-component prismatic talisman | Random talisman fragment property RNG |
| Frag Rain | 2192 | Find 5 talisman fragments | Talisman fragment drops are RNG per battle |

## Category 2 — In-battle micro-state thresholds

These require specific transient state inside a single battle (per-gem hit counts, simultaneous monster states, specific kill conditions). AP item state can't represent in-battle execution.

| Achievement | AP ID | Description | Why untrackable |
|---|---|---|---|
| Black Blood | 2044 | Deal 5,000 poison damage to a shadow | Per-shadow poison-tick accumulator |
| Epidemic Gem | 2163 | Pure poison gem with 3,500 hits | Per-gem hit counter |
| Seen Battle | 2463 | Grade-1 gem with 500 hits | Per-gem hit counter |
| Time to Upgrade | 2567 | Grade-1 gem with 4,500 hits | Per-gem hit counter |
| Mana Greedy | 2324 | Leech 1,800 mana with grade-1 gem | Per-gem mana-leech accumulator |
| Hungry Little Gem | 2249 | Leech 3,600 mana with grade-1 gem | Per-gem mana-leech accumulator |
| Max Trap Max Leech | 2338 | Leech 6,300 mana with grade-1 gem (trap) | Per-gem mana-leech accumulator |
| Return of Investment | 2445 | Leech 900 mana with grade-1 gem | Per-gem mana-leech accumulator |
| Eagle Eye | 2141 | Amplified gem range of 18 | Real-time gem-stat threshold inside an amplifier |
| In Focus | 2272 | Amplify a gem with 8 other gems | Specific socket arrangement |
| Safe and Secure | 2458 | 7 gems in amplifiers connected to orb | Specific orb-amplifier topology |
| Power Node | 2410 | Activate the same shrine 5 times | Per-shrine activation counter |
| Helping Hand | 2241 | Watchtower kills a possessed monster | Specific kill source + monster combo |
| Out of Nowhere | 2393 | Kill a whited-out possessed monster with bolt | Three simultaneous conditions |
| Rising Tide | 2447 | Banish 150 monsters with 2+ wraiths alive | Banish counter under simultaneous-state predicate |
| Just Breathe In | 2290 | Pure poison gem with random priority + beam | Per-gem priority + enhancement combo |

## Category 3 — Per-battle kill counters with specific monster types

These count kills of specific monster types or via specific kill sources within one battle. The kill-source and monster-type filters aren't in AP's tracked item state.

| Achievement | AP ID | Description | Why untrackable |
|---|---|---|---|
| Antitheft | 2024 | Kill 90 monsters with orblet explosions | Orblet kill source counter |
| Bath Bomb | 2035 | Kill 30 monsters with orblet explosions | Orblet kill source counter |
| Liquid Explosive | 2311 | Kill 180 monsters with orblet explosions | Orblet kill source counter |
| Handle With Care | 2231 | Kill 300 monsters with orblet explosions | Orblet kill source counter |
| Exorcism | 2166 | Kill 199 possessed monsters in one battle | Possessed-monster filter |
| Hint of Darkness | 2245 | Kill 189 twisted monsters | Twisted-monster filter |
| Family Friendlier | 2170 | Kill 900 green-blooded monsters | Color filter |
| Blood Censorship | 2051 | Kill 2,100 green-blooded monsters | Color filter |
| Chlorophyll | 2091 | Kill 4,500 green-blooded monsters | Color filter |
| Green Path | 2223 | Kill 9,900 green-blooded monsters | Color filter |
| Fool Me Once | 2187 | Kill 390 banished monsters | Banish-status filter |
| Melting Pulse | 2342 | Hit 75 frozen monsters with shrines | Frozen state + shrine hit |
| Shattered Waves | 2473 | Hit 225 frozen monsters with shrines | Frozen state + shrine hit |
| Shaken Ice | 2465 | Hit 475 frozen monsters with shrines | Frozen state + shrine hit |
| Salvation | 2459 | Hit 150 whited-out monsters with shrines | Status + shrine hit |
| You Had Your Chance | 2629 | Kill 260 banished monsters with shrines | Banish + shrine kill |
| Scour You All | 2461 | Kill 660 banished monsters with shrines | Banish + shrine kill |
| One by One | 2389 | Deliver 750 one-hit kills | One-hit kill counter |

## Category 4 — Cumulative cross-battle stats

Counters that span every battle the player has ever played. AP only sees current item state, not historical kill counts.

| Achievement | AP ID | Description | Why untrackable |
|---|---|---|---|
| Hard Reset | 2232 | 5,000 shrine kills cumulatively | Cross-battle accumulator |
| Shrinemaster | 2482 | 20,000 shrine kills cumulatively | Cross-battle accumulator |
| Marked Targets | 2334 | 10,000 special-property monster kills cumulatively | Cross-battle accumulator |
| Cleansing the Wilderness | 2093 | 50,000 special-property monster kills cumulatively | Cross-battle accumulator |
| Unholy Stack | 2589 | 20,000 special-property monster kills cumulatively | Cross-battle accumulator |
| Something Special | 2503 | 2,000 special-property monster kills cumulatively | Cross-battle accumulator |
| Wavy | 2606 | 500 waves beaten cumulatively | Cross-battle accumulator |
| Chainsaw | 2086 | 3,200 xp from kill chains | Per-battle accumulator with no item proxy |
| Ful Ir | 2202 | 1,000 gem bombs across all battles | Cross-battle accumulator |
| Just Take My Mana! | 2294 | 900,000 mana spent on banishment cumulatively | Cross-battle accumulator |

## Category 5 — Banishment / orb cost mechanics

Banishment-related thresholds depend on real-time orb state and amp-discount stacking that AP can't observe.

| Achievement | AP ID | Description | Why untrackable |
|---|---|---|---|
| Desperate Clash | 2122 | Reach -16% banishment cost on orb | Real-time orb stat |
| Insane Investment | 2276 | Reach -20% banishment cost on orb | Real-time orb stat |
| It Hurts! | 2282 | Spend 9,000 mana on banishment | In-battle accumulator |
| Itchy Sphere | 2286 | Deliver 3,600 banishments | In-battle accumulator |

## Category 6 — Wave-count thresholds beyond trackable bounds

These require beating wave counts that the apworld's `minWave` counter can express, but the achievements depend on **finishing** rather than reaching, plus often involve mode constraints AP can't fully verify.

| Achievement | AP ID | Description | Why untrackable |
|---|---|---|---|
| Feels Like Endurance | 2172 | Beat 120 waves | Battle-completion under wave threshold |
| Long Run | 2315 | Beat 360 waves | Battle-completion (Endurance only) |
| Enhancing Challenge | 2156 | 200 waves with max Swarmling + Giant domination | Combined trait state + completion |
| Worst of Both Sizes | 2624 | 300 waves with max Swarmling + Giant domination | Combined trait state + completion |
| Enraged is the New Norm | 2159 | Enrage 240 waves | Per-wave manual-enrage counter |
| There's No Time | 2554 | Call 140 waves early | Per-wave wave-stone-stacking counter |

## Category 7 — Wizard level above counter cap

The `wizardLevel:N` counter in `rules.py` derives wizard level from collected progression XP items, capping around N=40 at default settings. Higher thresholds require post-game grinding AP cannot guarantee.

| Achievement | AP ID | Description | Why untrackable |
|---|---|---|---|
| Purple Wand | 2423 | Reach wizard level 200 | Above wizardLevel:N trackable cap |
| Red Wand | 2439 | Reach wizard level 500 | Above wizardLevel:N trackable cap |

## Category 8 — Talisman state requirements

These depend on what fragments are *socketed* in the talisman, the socket grid arrangement, or the player's shape collection — none of which AP tracks beyond fragment ownership.

| Achievement | AP ID | Description | Why untrackable |
|---|---|---|---|
| Multiline | 2353 | 5 different talisman properties | Depends on socketed-fragment property union |
| Quite a List | 2430 | 15 different talisman properties | Same |
| Gearing Up | 2206 | 5 fragments socketed | Socket-state, not ownership |
| Stockpile | 2521 | 30 fragments in inventory | Inventory size — non-progression items invisible to state.has |
| Shapeshifter | 2466 | Complete shape collection | Persistent shape-discovery state |
| Starter Pack | 2509 | 8 fragments in shape collection | Persistent shape-discovery state |
| Puzzling Bunch | 2425 | 16 fragments in shape collection | Persistent shape-discovery state |
| Half Full | 2230 | 32 fragments in shape collection | Persistent shape-discovery state |
| Sigil | 2483 | All sockets filled, every fragment ≥ level 5 | Upgrade level + socket state |

## Category 9 — Building counts and arrangements

These count buildings constructed in a single battle. AP doesn't track per-battle build counts.

| Achievement | AP ID | Description | Why untrackable |
|---|---|---|---|
| Power Sharing | 2412 | Build 5 amplifiers | Per-battle build counter |
| Power Flow | 2409 | Build 15 amplifiers | Per-battle build counter |
| Power Exchange | 2408 | Build 25 amplifiers | Per-battle build counter |
| Rageroom | 2433 | 100 walls + 100 enraged waves | Per-battle build + enrage counters |
| Healing Denied | 2236 | Destroy 3 healing beacons | Mod-feature spawning, not statically placed |
| Not So Omni Anymore | 2378 | Destroy 10 omnibeacons | Mod-feature spawning |
| Still No Match | 2515 | Destroy an omnibeacon | Mod-feature spawning |

## Category 10 — Constraint runs

"Beat N waves using only X" or "without using Y" — AP can verify the *capability* (player has the gem skill, the stage exists) but not the *constraint* (player actually limited themselves).

| Achievement | AP ID | Description | Why untrackable |
|---|---|---|---|
| Keeping Low | 2297 | Beat 40 waves using at most grade-2 gems | Self-imposed grade cap |
| It Has to Do | 2281 | Beat 50 waves using at most grade-2 gems | Self-imposed grade cap |
| Need Lots of Them | 2359 | Beat 60 waves using at most grade-2 gems | Self-imposed grade cap |
| Purist | 2422 | Beat 120 waves without strike or enhancement spells | Self-imposed spell ban |
| Trapland | 2577 | Complete a level using only traps and no poison gems | Self-imposed strategy limit |
| Flip Flop | 2184 | Win a flipped field battle | Mode + completion |
| Too Easy | 2574 | Win a Trial battle with 3 enraged waves | Trial mode + simultaneous condition |
| Worthy | 2625 | 70 fields lit in Trial mode | Persistent Trial-mode progress |

## Category 11 — Hidden Mod / reference / undocumented triggers

Achievements tied to Hidden Mod toggles, gag references, or specific micro-conditions that are best left as in-game discoveries.

| Achievement | AP ID | Description | Why untrackable |
|---|---|---|---|
| Heavily Modified | 2237 | Activate all Hidden Mods in one battle | Mod-toggle state |
| Green Eyed Ninja | 2222 | Hidden Mod-only achievement | Mod-only feature |
| Going Deviant | 2218 | "Rook to a9" reference | Specific micro-action |
| Slime Block | 2488 | Minecraft slimeball reference | Specific item-state condition |
| I Never Asked For This | 2254 | Win a battle with all skill points spent | Persistent SP-allocation state |
| Renzokuken | 2442 | FF8 reference: gem-bomb during Whiteout time-freeze | Mid-spell trigger |
| Splash Swim Splash | 2508 | Magikarp reference: 9 pure Slowing gems in inventory | Per-battle inventory snapshot |
| Hazardous Materials | 2235 | 1,000 monsters poisoned simultaneously | Simultaneous-state predicate |
| Oh Ven | 2382 | 90 monsters poisoned simultaneously | Simultaneous-state predicate |
| Behold Aurora | 2042 | Kill 5 wraiths with shrines while raining | Three simultaneous conditions |
| We Just Wanna Be Free | 2607 | "More than blue triangles" — undocumented | Undocumented trigger |
| Uraj and Khalis | 2592 | "Activate the lanterns" — undocumented | Undocumented trigger |
| Well Prepared | 2614 | 20,000 initial mana | Initial-mana threshold (talisman + skill stack) |

---

## Conventions

When marking a new achievement untrackable:

1. Set `"untrackable": True` in its entry.
2. Keep a minimal `"requirements"` list for the *prerequisites to attempt* — relevant skill items, battle mode, stage element. AP will gate the location on these but not on actual completion.
3. If the reason fits one of the categories above, no further annotation needed. If it's novel, add a short comment explaining why and update this document.

For category-7 items (wizard level), the trackable cap depends on `_count_xp_items` math in [rules.py](../apworld/gcfw/rules.py). Adjusting the cap requires changing how progression XP items are classified in [items.py](../apworld/gcfw/items.py).

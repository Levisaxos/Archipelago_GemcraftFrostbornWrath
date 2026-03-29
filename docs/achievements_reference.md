# GCFW Achievements Reference

Source: `do not commit/GCFW/scripts/com/giab/games/gcfw/achi/AchiCollection.as`
Checking logic: `IngameAchiChecker0.as` through `IngameAchiChecker7.as` (split by ID range)
Storage: `PlayerProgressData.gainedAchis[]` (boolean array indexed by achievement ID)

**Total: 636 achievements** (IDs 0-635, not all sequential)

Achievement constructor:
```
Achievement(id, iconTableX, iconTableY, reqBattleMode, reqBeforeWaveStartNum,
            reqTargetValue, isStatRelated, reqFieldStrId, description, title,
            skillPtValue, tags, [keyFragNum])
```

---

## Wizard Level Achievements

| ID | Title | Requirement |
|----|-------|-------------|
| 382 | White Wand | Wizard level 10 |
| 383 | Yellow Wand | Wizard level 20 |
| 384 | Orange Wand | Wizard level 40 |
| 385 | Green Wand | Wizard level 60 |
| 388 | Brown Wand | Wizard level 300 |
| 389 | Red Wand | Wizard level 500 |
| 419 | Black Wand | Wizard level 1,000 |

---

## Battle Trait Achievements (require trait at level 6+ and win battle)

| ID | Title | Trait Required | Trait Game ID |
|----|-------|----------------|---------------|
| 369 | So Enduring | Adaptive Carapace | 0 |
| 370 | Deluminati | Dark Masonry | 1 |
| 352 | Tumbling Billows | Swarmling Domination | 2 |
| 371 | Crowd Control | Overcrowd | 3 |
| 372 | Guarding the Fallen Gate | Corrupted Banishment | 4 |
| 373 | Time to Rise | Awakening | 5 |
| 374 | Ionized Air | Insulation | 6 |
| 353 | Hateful | Hatred | 7 |
| 375 | Face the Phobia | Swarmling Parasites | 8 |
| 376 | Just Fire More at Them | Thick Air | 10 |
| 379 | Spectrin Tetramer | Vital Link | 11 |
| 354 | On the Shoulders of Giants | Giant Domination | 12 |
| 397 | Thin Them Out | Strength in Numbers lv6+ | 13 |
| 398 | Forces Within my Comprehension | Ritual lv6+ | 14 |
| 355 | Stronger Than Before | Corrupted Banishment lv12 | 4 |
| 544 | Peek Into The Abyss | ALL traits at highest level | all |
| 563 | Mana is All I Need | No skill pts spent + a trait maxed | any |

Note: Haste (game ID 9) has no dedicated "level 6+" achievement.

---

## Skill-Dependent Achievements

### Skills Reference (AP IDs 300-323)

| Game ID | AP ID | Skill Name |
|---------|-------|------------|
| 0 | 300 | Mana Stream |
| 1 | 301 | True Colors |
| 2 | 302 | Fusion |
| 3 | 303 | Orb of Presence |
| 4 | 304 | Resonance |
| 5 | 305 | Demolition |
| 6 | 306 | Critical Hit |
| 7 | 307 | Mana Leech |
| 8 | 308 | Bleeding |
| 9 | 309 | Armor Tearing |
| 10 | 310 | Poison |
| 11 | 311 | Slowing |
| 12 | 312 | Freeze |
| 13 | 313 | Whiteout |
| 14 | 314 | Ice Shards |
| 15 | 315 | Bolt |
| 16 | 316 | Beam |
| 17 | 317 | Barrage |
| 18 | 318 | Fury |
| 19 | 319 | Amplifiers |
| 20 | 320 | Pylons |
| 21 | 321 | Lanterns |
| 22 | 322 | Traps |
| 23 | 323 | Seeker Sense |

### Pure Gem Type Achievements (require specific gem color = skill)

| ID | Title | Description | Skill Required |
|----|-------|-------------|----------------|
| 34 | Nox Mist | Win using only poison gems | Poison (10) |
| 31 | Targeting Weak Points | Win using only crit gems | Critical Hit (6) |
| 30 | Mana Magnet | Win using only mana leech gems | Mana Leech (7) |
| 32 | Shooting Where it Hurts | 90 waves, only crit gems | Critical Hit (6) |
| 22 | No Armor Area | 90 waves, only armor tearing gems | Armor Tearing (9) |
| 19 | Slowly but Surely | 90 waves, only slowing gems | Slowing (11) |

### Enhancement Spell Achievements

**Bolt (skill 15):**
| ID | Title | Description |
|----|-------|-------------|
| 160 | Out of Nowhere | Kill whited out possessed monster with bolt |
| 182 | Jinx Blast | Kill 30 whited out monsters with bolt |
| 340 | Rugged Defense | 16 bolt enhanced gems at once |

**Beam (skill 16):**
| ID | Title | Description |
|----|-------|-------------|
| 177 | Violet Ray | Kill 20 frozen monsters with beam |
| 180 | White Ray | Kill 90 frozen monsters with beam |
| 195 | Overheated | Kill a giant with beam shot |
| 294 | Dual Pulse | 2 beam enhanced gems at once |
| 297 | Fusion Core | 16 beam enhanced gems at once |
| 524 | Just Breathe In | Enhance pure poison gem (random priority) with beam |

**Barrage (skill 17):**
| ID | Title | Description |
|----|-------|-------------|
| 181 | Icecracker | Kill 90 frozen monsters with barrage |
| 321 | Barrage Battery | Max charge 300% for Barrage |
| 427 | Firefall | 16 barrage enhanced gems at once |
| 471 | Supply Line Cut | Kill swarm queen with barrage shell |
| 481 | Rage Control | Kill 400 enraged swarmlings with barrage |
| 625 | Rooting From Afar | Kill gatekeeper fang with barrage shell |

**Freeze Spell (skill 12):**
| ID | Title | Description |
|----|-------|-------------|
| 239 | Ice Snap | Gain 90 xp with Freeze crowd hits |
| 289 | Frozen Over | Gain 4,500 xp with Freeze crowd hits |
| 309 | Freezing Wounds | Freeze a monster 3 times |
| 314 | Refrost | Freeze 111 frozen monsters |
| 320 | Ice Cube | Max charge 300% for Freeze |
| 395 | Not So Fast | Freeze a specter |
| 479 | Frosting | Freeze a specter while snowing |

**Whiteout Spell (skill 13):**
| ID | Title | Description |
|----|-------|-------------|
| 133 | Snowdust Blindness | Gain 2,300 xp with Whiteout crowd hits |
| 271 | Salvation | Hit 150 whited out monsters with shrines |
| 310 | Outwhited | Gain 4,700 xp with Whiteout crowd hits |
| 313 | Hold Still | Freeze 130 whited out monsters |
| 530 | In a Blink of an Eye | Kill 100 monsters while time frozen |
| 585 | Mana Blinded | Leech 900 mana from whited out monsters |
| 588 | Just Give Me That Mana | Leech 7,200 mana from whited out monsters |

**Ice Shards Spell (skill 14):**
| ID | Title | Description |
|----|-------|-------------|
| 244 | Sliced Ice | Gain 1,800 xp with Ice Shards crowd hits |
| 328 | White Ring of Death | Gain 4,900 xp with Ice Shards crowd hits |
| 589 | Double Sharded | Cast 2 ice shards on same monster |
| 592 | Care to Die Already? | Cast 8 ice shards on same monster |
| 196 | Icepicked | Gain 3,200 xp with Ice Shards crowd hits |

### Building Achievements

**Towers (skill 19 - but towers are base building, no skill needed?):**
| ID | Title | Target |
|----|-------|--------|
| 66 | Towerful | Build 5 |
| 67 | Settlement | Build 15 |
| 68 | Fortress | Build 30 |
| 274 | Bastion | Build 90 |

**Walls (no specific skill):**
| ID | Title | Target |
|----|-------|--------|
| 79 | Minor Detour | Build 15 |
| 80 | Confusion Junction | Build 30 |
| 81 | Zigzag Corridor | Build 60 |

**Traps (skill 22):**
| ID | Title | Target |
|----|-------|--------|
| 71 | Sparse Snares | Build 10 |
| 72 | Entrenched | Build 20 |
| 74 | Razor Path | Build 60 |

**Amplifiers (skill 19):**
| ID | Title | Target |
|----|-------|--------|
| 75 | Power Sharing | Build 5 |
| 356 | Amplifinity | Build 45 |

**Pylons (skill 20):**
| ID | Title | Description |
|----|-------|-------------|
| 201 | Deathball | 1,000 pylon kills (all battles) |
| 222 | Bouncy Zap | 2,000 pylon kills (all battles) |
| 231 | Pylons of Destruction | 5,000 pylon kills (all battles) |

**Lanterns (skill 21):**
No dedicated "build N lanterns" achievements found in the data. Lanterns are tagged but appear in combo achievements.

### Gem Wasp Achievements (related to Fury skill 18 or gem bombs?)

| ID | Title | Description |
|----|-------|-------------|
| 216 | Pointed Pain | 50 wasp stings |
| 217 | Needle Storm | 350 wasp stings |
| 247 | Puncture Therapy | 950 wasp stings |
| 341 | Buzz Feed | 99 wasps on battlefield |
| 491 | Glowing Armada | 240 wasps at battle end |
| 538 | Rainbow Strike | Kill 900 with prismatic wasps |
| 539 | Multinerf | Kill 1,600 with prismatic wasps |
| 540 | Taste All The Affixes | Kill 2,500 with prismatic wasps |
| 565 | Miniblasts | Tear 1,250 armor with stings |
| 566 | Punching Deep | Tear 2,500 armor with stings |
| 594 | Stingy Downfall | 400 stings to a spire |

### Demolition (skill 5)

| ID | Title | Description |
|----|-------|-------------|
| 85 | Stones to Dust | Demolish 1 structure |
| 86 | Juggler | Use demolition 7 times |
| 601 | Groundfill | Demolish a trap |

### Seeker Sense (skill 23)

No dedicated achievements, but Seeker Sense multiplies shadow core drop amounts.

### Skill Mastery

| ID | Title | Description |
|----|-------|-------------|
| 367 | Regaining Knowledge | Acquire 5 skills |
| 368 | Skillful | Acquire all skills and raise to level 5+ |
| 564 | Mastery | Raise a skill to level 70 |

---

## Talisman Fragment Achievements

| ID | Title | Description |
|----|-------|-------------|
| 364 | First Puzzle Piece | Find 1 fragment |
| 365 | Fortunate | Find 2 fragments |
| 366 | Ground Luck | Find 3 fragments |
| 358 | Frag Rain | Find 5 fragments |
| 363 | Gearing Up | 5 fragments socketed |
| 359 | Amulet | Fill all sockets |
| 361 | Sigil | All sockets filled, fragments upgraded to lv5+ |
| 360 | Charm | All sockets filled, all upgraded to max |
| 505 | Quite a List | 15 different talisman properties |
| 506 | Almost Like Hacked | 20 different talisman properties |
| 631 | Starter Pack | 8 fragments in shape collection |
| 633 | Half Full | 32 fragments in shape collection |
| 634 | Shapeshifter | Complete shape collection |

---

## Shadow Core Achievements

| ID | Title | Description |
|----|-------|-------------|
| 348 | Core Haul | Find 180 shadow cores (in battle) |
| 350 | Boatload of Cores | Find 540 shadow cores (in battle) |
| 422 | How About Some Skill Points | 5,000 cores at battle start |
| 423 | Endgame Balance | 25,000 cores at battle start |

---

## Journey / Endurance / Trial Mode Progression

**Journey fields lit:**
| ID | Title | Fields |
|----|-------|--------|
| 509 | A Bright Start | 30 |
| 511 | Light My Path | 70 |
| 512 | Cartographer | 90 |

**Endurance fields lit:**
| ID | Title | Fields |
|----|-------|--------|
| 515 | Longrunner | 60 |
| 516 | Endured a Lot | 80 |

**Trial fields lit:**
| ID | Title | Fields |
|----|-------|--------|
| 519 | Expert | 50 |
| 520 | Worthy | 70 |

**Multi-mode:**
| ID | Title | Description |
|----|-------|-------------|
| 508 | Fully Lit | One field beaten in all 3 modes |

---

## Endurance Mode + Traits Combo

| ID | Title | Description |
|----|-------|-------------|
| 553 | Mixing Up | 50 waves on max Swarmling + Giant domination |
| 555 | Enhancing Challenge | 200 waves on max Swarmling + Giant domination |
| 556 | Worst of Both Sizes | 300 waves on max Swarmling + Giant domination |

---

## Trial Mode Achievements

| ID | Title | Description |
|----|-------|-------------|
| 559 | Get This Done Quick | Win Trial with 3+ waves early |
| 560 | Too Easy | Win Trial with 3+ waves enraged |

---

## Wave Beat / Endurance Achievements

| ID | Title | Waves |
|----|-------|-------|
| 132 | Getting Wet | 30 |
| 145 | Feels Like Endurance | 120 |
| 281 | Long Run | 360 |
| 569 | Elementary | 30 waves, max grade 2 gems |
| 570 | Keeping Low | 40 waves, max grade 2 gems |

---

## Kill Count Achievements

| ID | Title | Target |
|----|-------|--------|
| 122 | First Blood | Kill 1 monster |
| 428 | Path of Splats | Kill 400 |
| 429 | Bloodstream | Kill 4,000 |
| 430 | They Keep Coming | Kill 12,000 |
| 431 | Unending Flow | Kill 24,000 |

**Cross-battle kill stats:**
| ID | Title | Target |
|----|-------|--------|
| 119 | Crimson Journal | 100,000 total kills |
| 120 | The Killing Will Never Stop | 200,000 total kills |
| 125 | They Are Millions | 1,000,000 total kills |

---

## Orb / Defense Achievements

| ID | Title | Description |
|----|-------|-------------|
| 418 | Clean Orb | Win without any monster touching orb |
| 257 | Armored Orb | Strengthen orb by dropping gem on it |
| 258 | Added Protection | Strengthen orb with gem in amplifier |
| 259 | Safe and Secure | Strengthen orb with 7 gems in amplifiers |
| 261 | Tightly Secured | No monster touches orb for 60 waves |
| 262 | It's a Trap | No monster touches orb for 120 waves |
| 248 | You Shall Not Pass | No monster touches orb for 240 waves |
| 251 | Fierce Encounter | Reach -8% decreased banishment cost with orb |
| 279 | Insane Investment | Reach -20% decreased banishment cost with orb |

---

## Banishment Achievements

| ID | Title | Description |
|----|-------|-------------|
| 254 | Stinging Sphere | 100 banishments with orb |
| 255 | Thorned Sphere | 400 banishments with orb |
| 235 | Ouch! | Spend 900 mana on banishment |
| 420 | Don't Break it! | Spend 90,000 mana on banishment |
| 421 | Just Take My Mana! | Spend 900,000 mana on banishment |
| 551 | The Price of Obsession | Kill 590 banished monsters |
| 552 | Be Gone For Good | Kill 790 banished monsters |

---

## Gem Grade Achievements

| ID | Title | Grade |
|----|-------|-------|
| 43 | Third Grade | 3 |
| 44 | Fifth Grader | 5 |
| 29 | Prismatic | 6-component gem |
| 45-47 | various | grades 8, 12, 16 |
| 84 | Quick Circle | Grade 12 before wave 12 |

---

## Shrine Achievements

| ID | Title | Description |
|----|-------|-------------|
| 263 | Awakening | Activate a shrine |
| 264 | Earthquake | Activate shrines 4 times |
| 266 | Double Strike | Activate same shrine 2 times |
| 267 | Power Node | Activate same shrine 5 times |
| 412 | Weather Tower | Activate shrine while raining |
| 466 | End of the Tunnel | Kill apparition with shrine strike |

**Cross-battle shrine kills:**
| ID | Title | Target |
|----|-------|--------|
| 408 | Hard Reset | 5,000 |
| 432 | Don't Look at the Light | 10,000 |
| 433 | Shrinemaster | 20,000 |

---

## Hidden Mod Achievements (tagged `_tHiddenMod`)

These require game mods to be active:
| ID | Title | Description |
|----|-------|-------------|
| 541 | Flip Flop | Win a flipped field battle |
| 542 | Heavily Modified | Activate all mods |
| 605 | Not So Omni Anymore | Destroy 10 omnibeacons |
| 607 | Blood Censorship | Kill 2,100 green blooded monsters |
| 608 | Chlorophyll | Kill 4,500 green blooded monsters |
| 609 | Green Path | Kill 9,900 green blooded monsters |
| 610 | Bath Bomb | Kill 30 with orblet explosions |
| 611 | Antitheft | Kill 90 with orblet explosions |
| 612 | Liquid Explosive | Kill 180 with orblet explosions |
| 613 | Handle With Care | Kill 300 with orblet explosions |

---

## Reference / Easter Egg Achievements (tagged `_tReference`)

Pop culture references with obscure requirements:
| ID | Title | Reference Hint |
|----|-------|---------------|
| 202 | Ful Ir | "Blast like a fireball" (Ultima) |
| 209 | Oh Ven | "Spread the poison" |
| 614 | Green Eyed Ninja | "Entering: The Wilderness" |
| 615 | Splash Swim Splash | "Full of oxygen" |
| 618 | Renzokuken | "Break frozen time gem bombing limits" (FF8) |
| 620 | I Never Asked For This | "All aug points spent" (Deus Ex) |
| 621 | Deckard Would Be Proud | "Prismatic amulet" (Diablo) |
| 623 | Slime Block | "Nine slimeballs" (Minecraft) |
| 624 | Behold Aurora | "Igniculus and Light Ray" (Child of Light) |

---

## Miscellaneous Notable Achievements

| ID | Title | Description |
|----|-------|-------------|
| 319 | Shattered Orb | Lose a battle |
| 393 | That one! | Select a monster |
| 394 | There it is! | Select a building |
| 399 | Nature Takes Over | No own buildings at end of battle |
| 480 | Unarmed | No gems when wave 20 starts |
| 493 | Rageroom | Build 100 walls and start 100 enraged waves |
| 507 | Great Survivor | Kill wave-1 monster when wave 20 has started |
| 197 | Almost | Kill monster that would destroy orb via blink shot |

---

## Achievement Skill Point Rewards

Most achievements award 1 skill point. Some notable exceptions:
- **2 points:** 29, 28, 84, 117, 255, 278, 280, 286, 301, 320, 321, 332, 352-354, 369-376, 379, 397-398, 403, 406-407, 411, 421, 429, 430, 492, 522, 563, 570, 572, 580, many more
- **3 points:** 47, 63, 88-89, 92, 145, 166, 173, 248, 275, 281, 284, 285, 301, 308, 325, 333-334, 338, 353-354, 389, 397, 416, 419, 431, 520, 544, 555-556, 559-560, 570, many more

---

## Tags Used for Filtering

All available tags:
Amplifier, Apparition, Armor, Banishment, Barrage, Barricade, Beacon, Beam, Before wave,
Bleeding, Bolt, Bomb, Build, Click, Combine, CritHit, Damage, Destroy, Dwelling, Early,
Enhancement spell, Enrage, Field, Freeze, Gatekeeper, Gem, Giant, Grade, Ice Shards,
Jar of wasps, Kill, Lantern, Level, Mana, Mana shard, Marked, Monster, Monster egg,
Monster Nest, Obelisk, One hit, Orb, Orblet, Poison, Possessed, Pylon, Pure, Rain,
Reach stat, Shadow, Shadow core, Shrine, Skills, Sleeping hive, Slow, Snow, Specter,
Spire, Strike spell, Swarmling, Swarm queen, Talisman, Tomb, Tower, Traits, Trap,
Twisted, Wall, Wasp, Wallbreaker, Watchtower, Wave, Whiteout, Wizard hunter,
Wizard stash, Wraith, Xp, Journey Mode, Endurance Mode, Trial Mode,
_Reference, _Hidden Mod, _Hidden Mod Key

---

## Complete Achievement List (by ID order)

| ID | Title | Description | Pts | Tags |
|----|-------|-------------|-----|------|
| 0 | Dichromatic | Combine two gems of different colors | 1 | Gem |
| 1 | Mana Salvation | Salvage mana by destroying a gem | 1 | Gem, Destroy, Mana |
| 3 | A Shrubbery! | Place a shrub wall | 1 | Wall |
| 6 | Just Started | 10 battles won | 1 | Reach stat |
| 9 | Well Earned | 500 battles won | 1 | Reach stat |
| 11 | So Early | 1,000 waves started early (all battles) | 1 | Reach stat, Early, Wave |
| 12 | Getting Waves Done | 2,000 waves started early (all battles) | 1 | Reach stat, Early, Wave |
| 13 | No Time to Waste | 5,000 waves started early (all battles) | 1 | Reach stat, Early, Wave |
| 15 | Riding the Waves | 1,000 waves beaten (all battles) | 1 | Reach stat, Wave |
| 16 | Waves for Breakfast | 2,000 waves beaten (all battles) | 1 | Reach stat, Wave |
| 17 | Wave Smasher | 10,000 waves beaten (all battles) | 1 | Reach stat, Wave |
| 19 | Slowly but Surely | 90 waves, only slowing gems | 2 | Gem, Pure |
| 21 | Biohazard | Grade 12 pure poison gem | 2 | Gem, Grade, Pure, Poison |
| 22 | No Armor Area | 90 waves, only armor tearing gems | 2 | Gem, Pure, Armor |
| 23 | The Peeler | Grade 12 pure armor tearing gem | 1 | Gem, Grade, Pure, Armor |
| 24 | Powerful | Gem with raw min damage 300+ | 1 | Gem, Damage |
| 26 | Legendary | Gem with raw min damage 30,000+ | 2 | Gem, Damage |
| 27 | Tricolor | 3-component gem | 1 | Gem |
| 28 | Bloodrush | Call enraged wave early | 2 | Gem, Enrage |
| 29 | Prismatic | 6-component gem | 2 | Gem |
| 30 | Mana Magnet | Win using only mana leech gems | 1 | Gem, Pure |
| 31 | Targeting Weak Points | Win using only crit gems | 1 | Gem, Pure |
| 32 | Shooting Where it Hurts | 90 waves, only crit gems | 2 | Gem, Pure |
| 34 | Nox Mist | Win using only poison gems | 1 | Gem, Pure |
| 39 | Eagle Eye | Amplified gem range of 18 | 1 | Gem, Amplifier |
| 41 | Hyper Gem | Grade 3 gem, 600 eff max damage | 1 | Gem, Grade, Damage |
| 42 | Wicked Gem | Grade 3 gem, 900 eff max damage | 1 | Gem, Grade, Damage |
| 43 | Third Grade | Grade 3 gem | 1 | Gem, Grade |
| 44 | Fifth Grader | Grade 5 gem | 1 | Gem, Grade |
| 47 | Round Cut Plus | Grade 16 gem | 3 | Gem, Grade |
| 48 | Pat on the Back | Amplify a gem | 1 | Gem, Amplifier |
| 52 | Seen Battle | Grade 1 gem, 500 hits | 1 | Gem, Grade |
| 53 | Getting Serious | Grade 1 gem, 1,500 hits | 1 | Gem, Grade |
| 54 | Jewel Box | Fill all inventory slots | 1 | Gem |
| 56 | Swift Deployment | 20 gems before wave 5 | 2 | Before wave, Gem |
| 57 | Time to Upgrade | Grade 1 gem, 4,500 hits | 1 | Gem, Grade |
| 61 | Hacked Gem | Grade 3 gem, 1,200 eff max damage | 1 | Gem, Grade, Damage |
| 62 | Denested | Destroy 5 monster nests | 1 | Destroy, Monster Nest |
| 63 | Tomb Stomping | Break 4 tombs | 3 | Destroy, Tomb |
| 65 | Ambitious Builder | 500 structures built (all battles) | 1 | Reach stat, Build |
| 66 | Towerful | Build 5 towers | 1 | Build, Tower |
| 67 | Settlement | Build 15 towers | 1 | Build, Tower |
| 68 | Fortress | Build 30 towers | 1 | Build, Tower |
| 69 | Brickery | 1,000 structures (all battles) | 1 | Reach stat, Build |
| 70 | Megalithic | 2,000 structures (all battles) | 1 | Reach stat, Build |
| 71 | Sparse Snares | Build 10 traps | 1 | Build, Trap |
| 72 | Entrenched | Build 20 traps | 1 | Build, Trap |
| 74 | Razor Path | Build 60 traps | 1 | Build, Trap |
| 75 | Power Sharing | Build 5 amplifiers | 1 | Build, Amplifier |
| 78 | Omelette | 200 eggs cracked (all battles) | 1 | Reach stat, Monster egg |
| 79 | Minor Detour | Build 15 walls | 1 | Build, Wall |
| 80 | Confusion Junction | Build 30 walls | 1 | Build, Wall |
| 81 | Zigzag Corridor | Build 60 walls | 1 | Build, Wall |
| 82 | Too Curious | Break 2 tombs | 2 | Destroy, Tomb |
| 83 | Frittata | 500 eggs cracked (all battles) | 1 | Reach stat, Monster egg |
| 84 | Quick Circle | Grade 12 gem before wave 12 | 2 | Gem, Before wave |
| 85 | Stones to Dust | Demolish 1 structure | 1 | Destroy |
| 86 | Juggler | Use demolition 7 times | 1 | Destroy |
| 88 | Tasting the Darkness | Break 3 tombs | 3 | Destroy, Tomb |
| 89 | Tomb Raiding | Break tomb before wave 15 | 3 | Before wave, Tomb |
| 90 | Fire in the Hole | Destroy a monster nest | 1 | Destroy, Monster Nest |
| 92 | Nest Buster | Destroy 3 nests before wave 6 | 3 | Before wave, Destroy, Monster Nest |
| 93 | Nest Blaster | Destroy 2 nests before wave 12 | 2 | Before wave, Destroy, Monster Nest |
| 94 | Blackout | Destroy a beacon | 1 | Destroy, Beacon |
| 95 | Popping Lights | Destroy 5 beacons | 1 | Destroy, Beacon |
| 96 | Broken Siege | Destroy 8 beacons before wave 8 | 2 | Destroy, Beacon, Before wave |
| 101 | It was Abandoned Anyway | Destroy a dwelling | 1 | Destroy |
| 102 | Ruined Ghost Town | Destroy 5 dwellings | 1 | Destroy |
| 104 | Almost Ruined | Monster nest at 1 HP at end | 1 | Monster Nest, Damage |
| 106 | Mana Tap | 10,000 mana from shards (all battles) | 1 | Reach stat, Mana, Mana shard |
| 107 | Shard Siphon | 20,000 mana from shards (all battles) | 1 | Reach stat, Mana, Mana shard |
| 108 | Not Worth It | Harvest 9,000 mana from corrupted shard | 2 | Mana, Mana shard |
| 111 | Precious | Get gem from drop holder | 1 | Gem, Destroy |
| 112 | Dry Puddle | Harvest all mana from a shard | 1 | Mana, Mana shard, Destroy |
| 113 | Extorted | Harvest all mana from 3 shards | 1 | Mana, Mana shard, Destroy |
| 114 | The Mana Reaper | 100,000 mana from shards (all battles) | 1 | Reach stat, Mana, Mana shard |
| 115 | Eggs Royale | 1,000 eggs cracked (all battles) | 1 | Reach stat, Monster egg |
| 117 | Need More Rage | Upgrade gem in enraging socket | 2 | Gem, Enrage |
| 119 | Crimson Journal | 100,000 kills (all battles) | 1 | Reach stat, Kill, Monster |
| 120 | The Killing Will Never Stop | 200,000 kills (all battles) | 1 | Reach stat, Kill, Monster |
| 122 | First Blood | Kill 1 monster | 1 | Kill, Monster |
| 123 | Puncturing Shots | 75 one-hit kills | 1 | Kill, One hit |
| 125 | They Are Millions | 1,000,000 kills (all battles) | 1 | Reach stat, Kill, Monster |
| 129 | Minefield | Kill 300 monsters with traps | 1 | Monster, Kill, Trap |
| 132 | Getting Wet | Beat 30 waves | 1 | Wave |
| 133 | Snowdust Blindness | 2,300 xp with Whiteout crowd hits | 1 | Xp, Whiteout, Strike spell |
| 135 | Waspocalypse | Kill 1,080 with bombs and wasps | 1 | Kill, Monster, Bomb, Wasp |
| 138 | High Targets | 100 non-monsters killed (all battles) | 1 | Reach stat, Kill |
| 139 | Wings and Tentacles | 200 non-monsters killed (all battles) | 1 | Reach stat, Kill |
| 140 | Pest Control | Kill 333 swarmlings | 1 | Kill, Monster, Swarmling |
| 141 | Paranormal Paragon | 500 non-monsters killed (all battles) | 1 | Reach stat, Kill |
| 144 | Swarmling Season | Kill 999 swarmlings | 1 | Kill, Monster, Swarmling |
| 145 | Feels Like Endurance | Beat 120 waves | 2 | Wave |
| 148 | Exorcism | Kill 199 possessed monsters | 1 | Kill, Possessed, Monster |
| 149 | Stingy Cloud | 5,000 wasp kills (all battles) | 1 | Reach stat, Kill, Wasp |
| 150 | Bone Shredder | Kill 600 before wave 12 | 2 | Before wave, Kill, Monster |
| 151 | Still Chill | 1,500 xp with Freeze crowd hits | 1 | Xp, Freeze, Strike spell |
| 153 | Through All Layers | Kill monster with 200+ armor | 1 | Kill, Monster, Armor |
| 154 | Drone Warfare | 20,000 wasp kills (all battles) | 1 | Reach stat, Kill, Wasp |
| 157 | Can't Stop | Kill chain of 900 | 1 | Kill |
| 158 | Thin Ice | Kill 20 frozen monsters with traps | 1 | Kill, Monster, Freeze, Trap |
| 160 | Out of Nowhere | Kill whited out possessed with bolt | 1 | Kill, Whiteout, Possessed, Monster, Bolt, Enhancement |
| 161 | Hazardous Materials | "Put HEV on first" (1000 target) | 1 | Reference |
| 162 | Trapland | Kill monster with trap (reference) | 1 | Kill, Monster, Trap, Reference |
| 163 | I Saw Something | Kill an apparition | 1 | Kill, Apparition |
| 164 | Tiny but Deadly | 50,000 wasp kills (all battles) | 1 | Reach stat, Kill, Wasp |
| 166 | Darkness Walk With Me | Kill 3 shadows | 3 | Kill, Shadow |
| 167 | They Are Still Here | Kill 2 apparitions | 1 | Kill, Apparition |
| 168 | Don't Touch it! | Kill a specter | 1 | Kill, Specter |
| 169 | I Warned You... | Kill specter carrying gem | 1 | Kill, Specter, Gem |
| 172 | Twice the Terror | Kill 2 shadows | 2 | Kill, Shadow |
| 173 | Not Chasing Shadows Anymore | Kill 4 shadows | 3 | Kill, Shadow |
| 174 | Bye Bye Hideous | Kill a spire | 1 | Kill, Spire |
| 177 | Violet Ray | Kill 20 frozen with beam | 1 | Kill, Monster, Freeze, Enhancement, Beam |
| 180 | White Ray | Kill 90 frozen with beam | 1 | Kill, Freeze, Monster, Beam, Enhancement |
| 181 | Icecracker | Kill 90 frozen with barrage | 1 | Kill, Freeze, Monster, Barrage, Enhancement |
| 182 | Jinx Blast | Kill 30 whited out with bolt | 1 | Whiteout, Kill, Monster, Bolt, Enhancement |
| 185 | Marked Targets | 10,000 special property kills (all) | 1 | Reach stat, Kill, Monster |
| 186 | Unholy Stack | 20,000 special property kills (all) | 1 | Reach stat, Kill, Monster |
| 187 | Cleansing the Wilderness | 50,000 special property kills (all) | 1 | Reach stat, Kill, Monster |
| 188 | Avenged | Kill 15 monsters carrying orblets | 1 | Kill, Monster, Orblet |
| 189 | Ice Stand | Kill 5 frozen monsters carrying orblets | 1 | Freeze, Kill, Orblet |
| 190 | Wash Away | Kill 110 while raining | 1 | Rain, Kill, Monster |
| 191 | Acid Rain | Kill 85 poisoned while raining | 1 | Kill, Rain, Poison |
| 192 | Frozen Grave | Kill 220 while snowing | 1 | Kill, Monster, Snow |
| 193 | Snow Dust | Kill 95 frozen while snowing | 1 | Kill, Freeze, Snow, Monster |
| 195 | Overheated | Kill giant with beam shot | 1 | Kill, Enhancement, Beam, Monster, Giant |
| 196 | Icepicked | 3,200 xp with Ice Shards | 1 | Xp, Ice Shards, Strike spell |
| 197 | Almost | Kill monster attacking orb via blink | 1 | Kill, Monster, Orb |
| 198 | Like a Necro | Kill 25 with frozen corpse explosion | 1 | Freeze, Kill |
| 199 | Beastmaster | Kill monster with 100,000 HP and 1000 armor | 1 | Kill, Monster, Damage, Armor |
| 200 | Hedgehog | Kill swarmling with 100+ armor | 1 | Kill, Monster, Swarmling, Armor |
| 201 | Deathball | 1,000 pylon kills (all battles) | 1 | Reach stat, Kill, Pylon |
| 202 | Ful Ir | "Blast like a fireball" | 1 | Reference |
| 203 | Stirring Up the Nest | Only bomb and wasp kills | 1 | Bomb, Wasp, Kill |
| 204 | Green Vial | 75%+ kills from poison | 1 | Poison, Kill, Monster |
| 205 | Troll's Eye | Kill giant with one shot | 1 | Kill, One hit, Monster, Giant |
| 207 | Time Bent | 90 monsters slowed at once | 1 | Slow, Monster |
| 208 | Breath of Cold | 90 monsters frozen at once | 1 | Freeze |
| 209 | Oh Ven | Spread poison (90 target) | 1 | Reference |
| 210 | Meet the Spartans | 300 monsters on field at once | 1 | Monster |
| 212 | Lagging Already? | 900 monsters on field at once | 2 | Monster |
| 213 | Stumbling | Hit same monster with traps 100 times | 1 | Trap, Monster |
| 215 | Teleport Lag | Banish monster 5+ times | 1 | Banishment |
| 216 | Pointed Pain | 50 wasp stings | 1 | Wasp |
| 217 | Needle Storm | 350 wasp stings | 1 | Wasp |
| 219 | Drumroll | 200 wasp stings to buildings | 1 | Wasp |
| 220 | Sting Stack | 1,000 wasp stings to buildings | 1 | Wasp |
| 221 | Punctured Texture | 5,000 wasp stings to buildings | 1 | Wasp |
| 222 | Bouncy Zap | 2,000 pylon kills (all battles) | 1 | Reach stat, Kill, Pylon |
| 223 | Brought Some Mana | 5,000 initial mana | 1 | Mana |
| 226 | Filled 5 Times | Mana pool level 5 | 1 | Mana |
| 229 | Mana in a Bottle | 40,000 initial mana | 2 | Mana |
| 231 | Pylons of Destruction | 5,000 pylon kills (all battles) | 1 | Reach stat, Kill, Pylon |
| 234 | Keepers | 800 mana from drops | 1 | Mana |
| 235 | Ouch! | Spend 900 mana on banishment | 1 | Banishment, Mana |
| 237 | The Horror | Lose 3,333 mana to shadows | 1 | Shadow, Mana |
| 238 | Amplification | Spend 18,000 mana on amplifiers | 1 | Mana, Amplifier |
| 239 | Ice Snap | 90 xp with Freeze crowd hits | 1 | Xp, Strike spell, Freeze |
| 244 | Sliced Ice | 1,800 xp with Ice Shards | 1 | Xp, Ice Shards, Strike spell |
| 245 | Battle Heat | 200 xp with kill chains | 1 | Kill, Xp |
| 247 | Puncture Therapy | 950 wasp stings | 1 | Wasp |
| 248 | You Shall Not Pass | No orb touch for 240 waves | 3 | Orb, Wave |
| 249 | Boiling Red | Kill chain of 2,400 | 2 | Kill |
| 250 | Adventurer | 600 xp from drops | 1 | Xp |
| 251 | Fierce Encounter | -8% banishment cost with orb | 1 | Orb |
| 254 | Stinging Sphere | 100 orb banishments | 1 | Banishment, Orb |
| 255 | Thorned Sphere | 400 orb banishments | 2 | Banishment |
| 257 | Armored Orb | Drop gem on orb | 1 | Orb |
| 258 | Added Protection | Orb gem in amplifier | 1 | Orb, Amplifier, Gem |
| 259 | Safe and Secure | 7 orb amplifier gems | 1 | Orb, Amplifier, Gem |
| 261 | Tightly Secured | No orb touch for 60 waves | 1 | Orb, Wave |
| 262 | It's a Trap | No orb touch for 120 waves | 2 | Orb, Wave |
| 263 | Awakening | Activate a shrine | 1 | Shrine |
| 264 | Earthquake | Activate shrines 4 times | 1 | Shrine |
| 266 | Double Strike | Same shrine 2 times | 1 | Shrine |
| 267 | Power Node | Same shrine 5 times | 1 | Shrine |
| 268 | Takers | 1,600 mana from drops | 1 | Mana |
| 271 | Salvation | 150 whited out hit by shrines | 1 | Whiteout, Monster, Shrine |
| 273 | Shattered Waves | 225 frozen hit by shrines | 1 | Freeze, Monster, Shrine |
| 274 | Bastion | Build 90 towers | 1 | Build, Tower |
| 275 | Mana Singularity | Mana pool level 20 | 3 | Mana |
| 277 | Mythic Ancient Legendary | Gem min damage 300,000+ | 2 | Gem, Damage |
| 278 | Every Hit Counts | 3,750 one-hit kills | 2 | Kill, One hit |
| 279 | Insane Investment | -20% banishment cost with orb | 1 | Orb |
| 280 | No Land for Swarmlings | Kill 3,333 swarmlings | 2 | Kill, Monster, Swarmling |
| 281 | Long Run | Beat 360 waves | 3 | Wave |
| 284 | It's Lagging Alright | 1,200 monsters on field | 2 | Monster |
| 285 | Mana Hack | 80,000 initial mana | 3 | Mana |
| 286 | Zap Away | Cast 175 strike spells | 2 | Strike spell |
| 287 | Snatchers | 3,200 mana from drops | 1 | Mana |
| 288 | Killed So Many | 7,200 xp with kill chains | 1 | Xp, Kill |
| 289 | Frozen Over | 4,500 xp with Freeze crowd | 1 | Xp, Freeze, Strike spell |
| 290 | Strike Anywhere | Cast 1 strike spell | 1 | Strike spell |
| 291 | Scare Tactics | Cast 5 strike spells | 1 | Strike spell |
| 293 | Fire Away | Cast 1 enhancement spell | 1 | Enhancement, Gem |
| 294 | Dual Pulse | 2 beam enhanced gems | 1 | Enhancement, Beam, Gem |
| 297 | Fusion Core | 16 beam enhanced gems | 1 | Beam, Enhancement, Gem |
| 300 | Necrotrophic | 1,000 poison kills (all battles) | 1 | Reach stat, Kill, Poison |
| 301 | Clear Sky | 120 waves, no strike spells | 3 | Strike spell |
| 303 | No Beacon Zone | 200 beacons (all battles) | 1 | Reach stat, Destroy, Beacon |
| 305 | Beacons Be Gone | 500 beacons (all battles) | 1 | Reach stat, Destroy, Beacon |
| 306 | Shatter Them All | 1,000 beacons (all battles) | 1 | Reach stat, Destroy, Beacon |
| 307 | Deadly Curse | 5,000 poison kills (all battles) | 1 | Reach stat, Kill, Poison |
| 308 | Purist | 120 waves, no strike/enhancement spells | 3 | Strike spell, Enhancement |
| 309 | Freezing Wounds | Freeze monster 3 times | 1 | Strike spell, Freeze |
| 310 | Outwhited | 4,700 xp with Whiteout | 1 | Xp, Whiteout, Strike spell |
| 313 | Hold Still | Freeze 130 whited out monsters | 1 | Strike spell, Monster, Freeze, Whiteout |
| 314 | Refrost | Freeze 111 frozen monsters | 1 | Freeze |
| 316 | Inedible | Poison 111 frozen monsters | 1 | Poison, Freeze |
| 318 | Mass Awakening | Lure 2,500 from sleeping hive | 1 | Monster, Swarmling, Sleeping hive |
| 319 | Shattered Orb | Lose a battle | 1 | (none) |
| 320 | Ice Cube | 300% charge for Freeze | 2 | Freeze, Enhancement |
| 321 | Barrage Battery | 300% charge for Barrage | 2 | Barrage, Enhancement |
| 322 | Call in the Wave! | Call 1 wave early | 1 | Wave, Early |
| 323 | Short Tempered | Call 5 waves early | 1 | Wave, Early |
| 324 | Restless | Call 35 waves early | 1 | Wave, Early |
| 325 | Agitated | Call 70 waves early | 2 | Wave, Early |
| 326 | There's No Time | Call 140 waves early | 2 | Wave, Early |
| 327 | Socketed Rage | Enrage 1 wave | 1 | Wave, Enrage |
| 328 | White Ring of Death | 4,900 xp with Ice Shards | 1 | Xp, Ice Shards, Strike spell |
| 329 | Shaken Ice | 475 frozen hit by shrines | 2 | Freeze, Monster, Shrine |
| 330 | Nothing Prevails | 25,000 poison kills (all battles) | 1 | Reach stat, Kill, Poison |
| 332 | Uninvited | Summon 100 by enraging | 2 | Enrage, Wave, Monster |
| 333 | The Gathering | Summon 500 by enraging | 3 | Enrage, Wave, Monster |
| 334 | More Than Enough | Summon 1,000 by enraging | 3 | Enrage, Wave, Monster |
| 335 | Ten Angry Waves | Enrage 10 waves | 1 | Wave, Enrage |
| 337 | Raging Habit | Enrage 80 waves | 2 | Enrage, Wave |
| 338 | Enraged is the New Norm | Enrage 240 waves | 3 | Enrage, Wave |
| 340 | Rugged Defense | 16 bolt enhanced gems | 1 | Bolt, Enhancement, Gem |
| 341 | Buzz Feed | 99 wasps on field | 1 | Wasp |
| 342 | Boom | Throw 1 gem bomb | 1 | Bomb |
| 343 | Bang | Throw 30 gem bombs | 1 | Bomb |
| 344 | Getting Rid of Them | 48 gem bombs on beacons | 1 | Beacon, Bomb |
| 348 | Core Haul | Find 180 shadow cores | 1 | Shadow core |
| 350 | Boatload of Cores | Find 540 shadow cores | 1 | Shadow core |
| 351 | Haste Trait lv6+ | (see trait section) | 2 | Traits |
| 352 | Tumbling Billows | Swarmling Domination lv6+ | 2 | Traits |
| 353 | Hateful | Hatred lv6+ | 3 | Traits |
| 354 | On the Shoulders of Giants | Giant Domination lv6+ | 2 | Traits |
| 355 | Stronger Than Before | Corrupted Banishment lv12 | 1 | Banishment, Traits |
| 356 | Amplifinity | Build 45 amplifiers | 1 | Build, Amplifier |
| 358 | Frag Rain | Find 5 fragments | 2 | Talisman |
| 359 | Amulet | Fill all talisman sockets | 1 | Talisman |
| 360 | Charm | All sockets filled, max upgraded | 1 | Talisman |
| 361 | Sigil | All sockets, lv5+ upgraded | 3 | Talisman |
| 363 | Gearing Up | 5 fragments socketed | 1 | Talisman |
| 364 | First Puzzle Piece | Find 1 fragment | 1 | Talisman |
| 365 | Fortunate | Find 2 fragments | 1 | Talisman |
| 366 | Ground Luck | Find 3 fragments | 1 | Talisman |
| 367 | Regaining Knowledge | Acquire 5 skills | 1 | Skills |
| 368 | Skillful | All skills at level 5+ | 1 | Skills |
| 369 | So Enduring | Adaptive Carapace lv6+ | 2 | Traits |
| 370 | Deluminati | Dark Masonry lv6+ | 2 | Traits |
| 371 | Crowd Control | Overcrowd lv6+ | 2 | Traits |
| 372 | Guarding the Fallen Gate | Corrupted Banishment lv6+ | 2 | Traits |
| 373 | Time to Rise | Awakening lv6+ | 2 | Traits |
| 374 | Ionized Air | Insulation lv6+ | 2 | Traits |
| 375 | Face the Phobia | Swarmling Parasites lv6+ | 2 | Traits |
| 376 | Just Fire More at Them | Thick Air lv6+ | 2 | Traits |
| 377 | Knowledge Seeker | Open a wizard stash | 1 | Wizard stash |
| 378 | Stash No More | Destroy opened wizard stash | 1 | Wizard stash |
| 379 | Spectrin Tetramer | Vital Link lv6+ | 2 | Traits |
| 380 | In for a Trait | Activate a battle trait | 1 | Traits |
| 382 | White Wand | Wizard level 10 | 1 | Level |
| 383 | Yellow Wand | Wizard level 20 | 1 | Level |
| 384 | Orange Wand | Wizard level 40 | 1 | Level |
| 385 | Green Wand | Wizard level 60 | 1 | Level |
| 388 | Brown Wand | Wizard level 300 | 2 | Level |
| 389 | Red Wand | Wizard level 500 | 3 | Level |
| 390 | Let's Have a Look | Open a drop holder | 1 | Destroy |
| 391 | Raindrop | 18 gem bombs while raining | 1 | Bomb, Rain |
| 392 | Snowball | 27 gem bombs while snowing | 1 | Bomb, Snow |
| 393 | That one! | Select a monster | 1 | Click, Monster |
| 394 | There it is! | Select a building | 1 | Click |
| 395 | Not So Fast | Freeze a specter | 1 | Freeze, Specter |
| 397 | Thin Them Out | Strength in Numbers lv6+ | 2 | Traits |
| 398 | Forces Within my Comprehension | Ritual lv6+ | 2 | Traits |
| 399 | Nature Takes Over | No own buildings at battle end | 1 | Build, Destroy |
| 400 | Sharpened | Enhance gem in trap | 1 | Enhancement, Gem, Trap |
| 401 | Second Thoughts | Add different enhancement on enhanced gem | 1 | Gem, Enhancement |
| 402 | Special Purpose | Change gem target priority | 1 | Click, Gem |
| 403 | Fully Shining | 60 gems on field | 2 | Gem |
| 404 | Stormed Beacons | Destroy 15 beacons | 1 | Destroy, Beacon |
| 405 | Lost Signal | Destroy 35 beacons | 2 | Destroy, Beacon |
| 406 | One by One | 750 one-hit kills | 2 | Kill, One hit |
| 407 | Trembling | 1,500 trap kills | 2 | Monster, Kill, Trap |
| 408 | Hard Reset | 5,000 shrine kills (all) | 1 | Reach stat, Kill, Shrine |
| 409 | Beacon Hunt | Destroy 55 beacons | 2 | Destroy, Beacon |
| 410 | At my Fingertips | 75 strike spells | 2 | Strike spell |
| 411 | Flying Multikill | Kill apparition+specter+wraith+shadow in one battle | 2 | Apparition, Specter, Shadow, Wraith, Kill |
| 412 | Weather Tower | Activate shrine while raining | 1 | Shrine, Rain |
| 413 | Let it Go | Leave an apparition alive | 1 | Apparition |
| 416 | Is This a Match-3 or What? | 90 gems on field | 3 | Gem |
| 418 | Clean Orb | Win without orb touched | 1 | Orb |
| 419 | Black Wand | Wizard level 1,000 | 3 | Level |
| 420 | Don't Break it! | 90,000 mana on banishment | 1 | Banishment, Mana |
| 421 | Just Take My Mana! | 900,000 mana on banishment | 2 | Banishment, Mana |
| 422 | How About Some Skill Points | 5,000 cores at start | 1 | Shadow core |
| 423 | Endgame Balance | 25,000 cores at start | 2 | Shadow core |
| 427 | Firefall | 16 barrage enhanced gems | 1 | Barrage, Enhancement, Gem |
| 428 | Path of Splats | Kill 400 | 1 | Kill, Monster |
| 429 | Bloodstream | Kill 4,000 | 1 | Kill, Monster |
| 430 | They Keep Coming | Kill 12,000 | 2 | Kill, Monster |
| 431 | Unending Flow | Kill 24,000 | 3 | Kill, Monster |
| 432 | Don't Look at the Light | 10,000 shrine kills (all) | 1 | Reach stat, Kill, Shrine |
| 433 | Shrinemaster | 20,000 shrine kills (all) | 1 | Reach stat, Kill, Shrine |
| 436 | Ice Mage | 2,500 strike spells (all) | 1 | Reach stat, Strike spell |
| 437 | Frostborn | 5,000 strike spells (all) | 1 | Reach stat, Strike spell |
| 440 | Enhance Like No Tomorrow | 2,500 enhancement spells (all) | 1 | Reach stat, Enhancement |
| 441 | Charge Fire Repeat | 5,000 enhancement spells (all) | 1 | Reach stat, Enhancement |
| 444 | Drop the Ice | 50,000 strike spell hits (all) | 1 | Reach stat, Strike spell |
| 445 | Ice for Everyone | 100,000 strike spell hits (all) | 1 | Reach stat, Strike spell |
| 447 | Red Orange | Leech 700 from bleeding monsters | 1 | Bleeding, Mana |
| 450 | Mana Cult | Leech 6,500 from bleeding monsters | 1 | Bleeding, Mana |
| 454 | To the Last Drop | Leech 4,700 from poisoned monsters | 1 | Poison, Mana |
| 455 | Easy Kill | Kill 120 bleeding monsters | 1 | Bleeding, Monster, Kill |
| 456 | Hurtified | Kill 240 bleeding monsters | 1 | Bleeding, Monster, Kill |
| 460 | Skylark | Call every wave early | 1 | Wave, Early |
| 461 | Mana First | Deplete shard with 300+ swarmlings | 1 | Mana shard, Destroy, Monster, Swarmling |
| 462 | Might Need it Later | Enhance gem in amplifier | 1 | Enhancement, Amplifier |
| 463 | Enhancement Storage | Enhance gem in inventory | 1 | Enhancement |
| 466 | End of the Tunnel | Kill apparition with shrine | 1 | Apparition, Shrine |
| 471 | Supply Line Cut | Kill swarm queen with barrage | 1 | Barrage, Swarm queen |
| 472 | Prismatic Takeaway | Specter steals 6-component gem | 1 | Gem, Specter |
| 474 | Damage Support | Pure bleeding gem, 2,500 hits | 1 | Pure, Bleeding, Gem |
| 475 | Shred Some Armor | Pure armor tearing gem, 3,000 hits | 1 | Pure, Armor, Gem |
| 476 | Epidemic Gem | Pure poison gem, 3,500 hits | 1 | Pure, Poison, Gem |
| 477 | Army Glue | Pure slowing gem, 4,000 hits | 1 | Pure, Slow, Gem |
| 478 | Got the Price Back | Pure mana leech gem, 4,500 hits | 1 | Pure, Mana, Gem |
| 479 | Frosting | Freeze specter while snowing | 1 | Freeze, Specter, Snow |
| 480 | Unarmed | No gems when wave 20 starts | 1 | Gem, Wave |
| 481 | Rage Control | Kill 400 enraged swarmlings with barrage | 1 | Enrage, Kill, Swarmling, Monster, Barrage |
| 482 | Can't Take Any Risks | Kill bleeding giant with poison | 1 | Bleeding, Monster, Giant, Poison, Kill |
| 485 | Impudence | 6 gems destroyed/stolen | 1 | Gem |
| 486 | Take Them I Have More | 12 gems destroyed/stolen | 1 | Gem |
| 487 | Enough is Enough | 24 gems destroyed/stolen | 1 | Gem |
| 489 | Glitter Cloud | Kill apparition with gem bomb | 1 | Bomb, Apparition, Kill |
| 490 | Final Touch | Kill spire with wasp | 1 | Kill, Spire, Wasp |
| 491 | Glowing Armada | 240 wasps at battle end | 1 | Wasp |
| 492 | Am I a Joke to You? | Start enraged wave early with wizard hunter | 2 | Enrage, Early, Wizard hunter |
| 493 | Rageroom | 100 walls + 100 enraged waves | 1 | Build, Wall, Enrage, Wave |
| 494 | One Hit is All it Takes | Kill wraith with one hit | 1 | Kill, Wraith, One hit |
| 498 | You Could Be my Apprentice | Watchtower kills wizard hunter | 1 | Watchtower, Wizard hunter |
| 499 | Get Them | Watchtower kills 39 monsters | 1 | Watchtower, Monster |
| 500 | Helping Hand | Watchtower kills possessed monster | 1 | Watchtower, Possessed, Monster |
| 501 | Going for the Weak | Watchtower kills poisoned monster | 1 | Watchtower, Poison |
| 502 | That Was Rude | Watchtower steals 1,000+ hit gem | 1 | Watchtower, Gem |
| 503 | ? | (checked at start, details in checker) | 1 | ? |
| 505 | Quite a List | 15 talisman properties | 1 | Talisman |
| 506 | Almost Like Hacked | 20 talisman properties | 1 | Talisman |
| 507 | Great Survivor | Kill wave-1 monster when wave 20 started | 1 | Wave, Kill, Monster |
| 508 | Fully Lit | Field beaten in all 3 modes | 1 | Journey, Endurance, Trial |
| 509 | A Bright Start | 30 Journey fields | 1 | Journey Mode |
| 511 | Light My Path | 70 Journey fields | 1 | Journey Mode |
| 512 | Cartographer | 90 Journey fields | 1 | Journey Mode |
| 515 | Longrunner | 60 Endurance fields | 1 | Endurance Mode |
| 516 | Endured a Lot | 80 Endurance fields | 1 | Endurance Mode |
| 519 | Expert | 50 Trial fields | 3 | Trial Mode |
| 520 | Worthy | 70 Trial fields | 3 | Trial Mode |
| 522 | No You Won't! | Destroy watchtower before it fires | 2 | Destroy, Watchtower |
| 524 | Just Breathe In | Enhance pure poison (random) with beam | 1 | Gem, Pure, Poison, Beam |
| 527 | Eggnog | Crack egg while time frozen | 1 | Monster egg |
| 530 | In a Blink of an Eye | Kill 100 while time frozen | 1 | Kill, Monster |
| 533 | Ok Flier | Kill 340 with 2+ wraiths | 1 | Kill, Monster, Wraith |
| 534 | Hunt For Hard Targets | Kill 680 with 2+ wraiths | 1 | Kill, Monster, Wraith |
| 535 | I am Tougher | Kill 1,360 with 2+ wraiths | 1 | Kill, Monster, Wraith |
| 536 | Derangement | Decrease gem range | 1 | Gem |
| 538 | Rainbow Strike | Kill 900 with prismatic wasps | 1 | Kill, Monster, Wasp |
| 539 | Multinerf | Kill 1,600 with prismatic wasps | 1 | Kill, Monster, Wasp |
| 540 | Taste All The Affixes | Kill 2,500 with prismatic wasps | 1 | Kill, Monster, Wasp |
| 541 | Flip Flop | Win flipped field (mod) | 1 | Hidden Mod |
| 542 | Heavily Modified | Activate all mods | 1 | Hidden Mod |
| 543 | You're Safe With Me | Win with 10+ orblets remaining | 1 | Orblet |
| 544 | Peek Into The Abyss | Kill with all traits maxed | 1 | Kill, Monster, Traits |
| 546 | You Had Your Chance | Kill 260 banished with shrines | 1 | Banishment, Kill, Monster, Shrine |
| 547 | And Don't Come Back | Kill 460 banished with shrines | 1 | Banishment, Kill, Monster, Shrine |
| 548 | Scour You All | Kill 660 banished with shrines | 1 | Banishment, Kill, Monster, Shrine |
| 551 | The Price of Obsession | Kill 590 banished | 1 | Banishment, Kill, Monster |
| 552 | Be Gone For Good | Kill 790 banished | 1 | Banishment, Kill, Monster |
| 553 | Mixing Up | 50 waves, max Swarmling+Giant dom | 2 | Wave, Endurance, Traits |
| 555 | Enhancing Challenge | 200 waves, max Swarmling+Giant dom | 3 | Wave, Endurance, Traits |
| 556 | Worst of Both Sizes | 300 waves, max Swarmling+Giant dom | 3 | Wave, Endurance, Traits |
| 557 | ? | (checked at true victory) | ? | ? |
| 559 | Get This Done Quick | Win Trial, 3+ waves early | 3 | Trial, Early, Wave |
| 560 | Too Easy | Win Trial, 3+ waves enraged | 3 | Trial, Wave, Enrage |
| 561 | Has Stood Long Enough | Destroy nest after last wave started | 1 | Destroy, Monster Nest, Wave |
| 562 | Twice the Shock | Hit same monster 2x with shrines | 1 | Monster, Shrine |
| 563 | Mana is All I Need | Win with no skill pts + trait maxed | 2 | Skills, Traits |
| 564 | Mastery | Raise a skill to level 70 | 1 | Skills |
| 565 | Miniblasts | Tear 1,250 armor with stings | 1 | Armor, Wasp |
| 566 | Punching Deep | Tear 2,500 armor with stings | 1 | Armor, Wasp |
| 569 | Elementary | 30 waves, max grade 2 gems | 1 | Gem, Grade, Wave |
| 570 | Keeping Low | 40 waves, max grade 2 gems | 2 | Gem, Grade, Wave |
| 573 | Eggcracker | Don't let any queen egg hatch | 1 | Monster egg, Swarm queen |
| 574 | Let Them Hatch | Don't crack any queen egg | 1 | Monster egg, Swarm queen |
| 575 | Well Trained for This | Kill wraith with 1,000+ kill gem | 1 | Wraith, Kill, Gem |
| 576 | Sharp Shot | Kill shadow with 5,000+ hit gem | 1 | Shadow, Kill, Gem |
| 577 | Double Splash | Kill 2 non-monsters with one bomb | 1 | Kill, Bomb |
| 578 | Omnibomb | Destroy building + kill non-monster with one bomb | 1 | Kill, Destroy, Bomb |
| 579 | Urban Warfare | Destroy dwelling + kill monster with one bomb | 1 | Kill, Monster, Destroy, Dwelling, Bomb |
| 580 | Keep Losing Keep Harvesting | Deplete shard while shadow present | 1 | Mana shard, Shadow |
| 581 | One Less Problem | Destroy nest while wraith present | 1 | Destroy, Monster Nest, Wraith |
| 582 | Tomb No Matter What | Open tomb while spire present | 1 | Tomb, Spire |
| 583 | Landing Spot | Demolish 20+ walls with falling spires | 1 | Spire, Wall |
| 584 | Rising Tide | Banish 150 with 2+ wraiths | 1 | Banishment, Monster, Wraith |
| 585 | Mana Blinded | Leech 900 from whited out | 1 | Whiteout, Mana |
| 588 | Just Give Me That Mana | Leech 7,200 from whited out | 1 | Whiteout, Mana |
| 589 | Double Sharded | 2 ice shards on same monster | 1 | Monster, Ice Shards |
| 592 | Care to Die Already? | 8 ice shards on same monster | 1 | Monster, Ice Shards |
| 593 | Busted | One-bomb full HP obelisk | 1 | Obelisk, Destroy, Bomb, One hit |
| 594 | Stingy Downfall | 400 stings to a spire | 1 | Spire, Wasp |
| 595 | Put Those Down Now! | 10 orblets carried at once | 1 | Orblet |
| 599 | Hungry Little Gem | Leech 3,600 with grade 1 gem | 1 | Gem, Grade, Mana |
| 600 | Max Trap Max leech | Leech 6,300 with grade 1 gem | 1 | Gem, Grade, Mana |
| 601 | Groundfill | Demolish a trap | 1 | Destroy, Trap |
| 603 | Quicksave | Instantly drop gem to inventory | 1 | Gem |
| 605 | Not So Omni Anymore | Destroy 10 omnibeacons (mod) | 1 | Destroy, Hidden Mod, Beacon |
| 607 | Blood Censorship | Kill 2,100 green blooded (mod) | 1 | Kill, Hidden Mod, Monster |
| 608 | Chlorophyll | Kill 4,500 green blooded (mod) | 1 | Kill, Hidden Mod, Monster |
| 609 | Green Path | Kill 9,900 green blooded (mod) | 1 | Kill, Hidden Mod, Monster |
| 610 | Bath Bomb | Kill 30 with orblet explosions (mod) | 1 | Hidden Mod, Orblet, Kill, Monster |
| 611 | Antitheft | Kill 90 with orblet explosions (mod) | 1 | Hidden Mod, Orblet, Kill, Monster |
| 612 | Liquid Explosive | Kill 180 with orblet explosions (mod) | 1 | Hidden Mod, Orblet, Kill, Monster |
| 613 | Handle With Care | Kill 300 with orblet explosions (mod) | 1 | Hidden Mod, Orblet, Kill, Monster |
| 614 | Green Eyed Ninja | "The Wilderness" | 1 | Reference |
| 615 | Splash Swim Splash | "Full of oxygen" | 1 | Reference |
| 618 | Renzokuken | Frozen time gem bombing (FF8) | 1 | Reference |
| 620 | I Never Asked For This | "All aug points spent" (Deus Ex) | 1 | Reference |
| 621 | Deckard Would Be Proud | "Prismatic amulet" (Diablo) | 1 | Reference |
| 623 | Slime Block | "Nine slimeballs" (Minecraft) | 1 | Reference |
| 624 | Behold Aurora | "Igniculus and Light Ray" (Child of Light) | 1 | Reference |
| 625 | Rooting From Afar | Kill gatekeeper fang with barrage | 1 | Gatekeeper, Kill, Barrage |
| 626 | Spitting Darkness | Leave gatekeeper to launch 100 projectiles | 1 | Gatekeeper |
| 629 | Implosion | Kill gatekeeper fang with bomb | 1 | Gatekeeper, Kill, Bomb |
| 630 | That Was Your Last Move | Kill wizard hunter attacking building | 1 | Wizard hunter |
| 631 | Starter Pack | 8 shapes in collection | 1 | Talisman |
| 633 | Half Full | 32 shapes in collection | 1 | Talisman |
| 634 | Shapeshifter | Complete shape collection | 1 | Talisman |
| 635 | ? | (checked at true victory) | ? | ? |

Note: IDs 351, 503-504, 557-558, 635 and a few others are defined but their descriptions were in sections not fully captured. Check the checker files for exact conditions.

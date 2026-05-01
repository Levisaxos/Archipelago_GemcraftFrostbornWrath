# Achievement TODOs

Auto-extracted from `#todo` comments in `rulesdata_achievements.py` (41 items).
Re-run the extractor (any future tooling) to refresh this file.

## Power gating (18)

- **AP 2012 — Agitated** (line 158): Check for powergating
- **AP 2019 — Amplification** (line 231): Check with power gating
- **AP 2022 — And Don't Come Back** (line 265): add power gating
- **AP 2031 — Barbed Sphere** (line 356): requires an amount of power i'm assuming.
- **AP 2034 — Bastion** (line 385): Power gating - requires amount of mana, perhaps even the build skill?
- **AP 2037 — Bazaar** (line 416): power gating - requires mana
- **AP 2038 — Be Gone For Good** (line 426): requires an amount of power i'm assuming.
- **AP 2039 — Beacon Hunt** (line 437): add power gating
- **AP 2043 — Biohazard** (line 479): add power gating
- **AP 2058 — Blue Wand** (line 629): add power gating and fieldcount
- **AP 2069 — Brought Some Mana** (line 745): power gating / starting mana
- **AP 2072 — Busted** (line 776): add power gating
- **AP 2095 — Close Quarter** (line 1004): minmana through power gating?
- **AP 2247 — Hope has fallen** (line 2492): Power gating?
- **AP 2546 — The Gathering** (line 5467): determine what is required to do this.. min waves + power gating.
- **AP 2547 — The Horror** (line 5477): power gating. Need 3333 mana to loose and survive other things
- **AP 2551 — The Peeler** (line 5517): minGemGrade should be connected to power gate?
- **AP 2552 — The Price of Obsession** (line 5527): Add power gating

## Time / wave estimates (7)

- **AP 2006 — Addicted** (line 98): check how much time is needed for a shrine to reach 12 charges and set minwave accordingly
- **AP 2027 — At my Fingertips** (line 316): Determine how much time it would take to case strikespells and match minWave with that.
- **AP 2036 — Battle Heat** (line 406): calculate how many klls it takes to get 200xp from killchains
- **AP 2059 — Boatload of Cores** (line 641): Random, figure out on which levels this is most likely and at atleast those to requirements.   done by minwave?
- **AP 2066 — Bright Weakening** (line 713): Determine how much time/enemies are required to gain 1200 xp from whiteout.
- **AP 2096 — Cold Wisdom** (line 1012): Determine how many enemies we need to hit to get 700xp with freeze spell
- **AP 2116 — Deal Some Damage Too** (line 1201): minwave for enough time to reload bolt 5 times.

## Level / element lookups (4)

- **AP 2011 — Ages Old Memories** (line 148): is this only L5?
- **AP 2067 — Broken Seal** (line 722): find levels with sealed gems.
- **AP 2068 — Broken Siege** (line 735): beacon:8. Make a list of all levels with beacons... not sure how
- **AP 2296 — Keepers** (line 2982): do apparation, corrupted shard and mana shard count for this?

## Talisman requirements (2)

- **AP 2032 — Barrage Battery** (line 366): requires talismans. Find out if we can set talismans to specific settings so with the 25 progressive talismans we can always get to 300%
- **AP 2118 — Deckard Would Be Proud** (line 1221): Can we make this happen with 25 static talismans?

## Shadow core requirements (2)

- **AP 2021 — Amulet** (line 252): Make more talismans progression, shadowcores progression?
- **AP 2089 — Charm** (line 941): shadowcore requirement?

## Gem grade implementation (1)

- **AP 2009 — Adept Grade** (line 128): determine how much mana is needed to get to grade 8 and implement accordingly

## Miscellaneous (7)

- **AP 2010 — Adventurer** (line 138): What battle?
- **AP 2020 — Amplifinity** (line 240): Check how much mana it takes to build 45 amps
- **AP 2044 — Black Blood** (line 489): find out if it has to be poison damage or damage by a poison gem.
- **AP 2061 — Bone Shredder** (line 661): Add monstercount before wave 12 to rulesdata_levels and set minMonstersBeforeWave12:600.
- **AP 2080 — Care to Die Already?** (line 857): needs monster with enough hp to survive 8 ice shards casts.
- **AP 2086 — Chainsaw** (line 911): Same as other kill chains
- **AP 2107 — Corrosive Stings** (line 1114): total wave armor > 5000 ?

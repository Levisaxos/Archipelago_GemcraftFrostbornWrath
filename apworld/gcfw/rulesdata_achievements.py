"""
GemCraft Frostborn Wrath - Achievement Requirements

All 636 achievements with their requirements, AP IDs, and metadata.
This is the single source of truth for achievement data.

Fields per achievement:
  ap_id            - Archipelago item ID (2000-2636)
  description      - Human-readable description (raw text from the game)
  details          - (optional) Plain-language explanation of what the player
                     actually has to do, when the description is vague,
                     references obscure mechanics, or is a pop-culture pun.
                     If the description already makes the action obvious,
                     this field is omitted to keep the file lean.
  untrackable      - (optional) True → location is forced EXCLUDED, no access
                     rules are set, and it can only hold a filler item. Used
                     when the achievement either (a) depends on RNG that AP
                     generation cannot guarantee (random talisman fragment
                     drops, shape collection, hidden mod toggles), or (b)
                     depends on a mechanic the AP layer doesn't model yet
                     (gem grade caps, wizard level, mana pool, etc.).
                     Replaces the old `always_as_filler` field name.
  requirements     - List of requirement strings for logic checks. See
                     rules.py for the supported vocabulary.
  reward           - Reward string, e.g. "skillPoints:2"
  required_power   - (optional) Integer mechanical-build power threshold
                     (matches STAGE_TIER_POWER curve in power.py). Set on
                     achievements that need real player loadout strength
                     (mana pool, wizard level, raw damage, HP/armor walls).
                     Omit for time-only / element-only achievements.
  required_effort  - Effort level: "Trivial", "Minor", "Major", "Extreme"
"""

achievement_requirements = {
    # AP ID: 2000
    "A Bright Start": {
        "ap_id": 2000,
        "game_id": 509,
        "description": "Have 30 fields lit in Journey mode.",
        "requirements": ["fieldToken: 30"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2001
    "A Shrubbery!": {
        "ap_id": 2001,
        "game_id": 3,
        "description": "Place a shrub wall.",
        "details": "Place a shrub-style wall.",
        "requirements": ["Wall element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2002
    "Ablatio Retinae": {
        "ap_id": 2002,
        "game_id": 311,
        "description": "Whiteout 111 whited out monsters.",
        "requirements": ["Whiteout skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2003
    "Absolute Zero": {
        "ap_id": 2003,
        "game_id": 126,
        "description": "Kill 273 frozen monsters.",
        "requirements": ["Freeze skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2004
    "Acid Rain": {
        "ap_id": 2004,
        "game_id": 191,
        "description": "Kill 85 poisoned monsters while it's raining.",
        "details": "Kill 85 poisoned monsters during rain weather.",
        "requirements": ["Poison skill", "Rain element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2005
    "Added Protection": {
        "ap_id": 2005,
        "game_id": 258,
        "description": "Strengthen your orb with a gem in an amplifier.",
        "details": "Place a gem in an amplifier adjacent to the orb.",
        "requirements": ["Amplifiers skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2006
    "Addicted": {
        "ap_id": 2006,
        "game_id": 265,
        "description": "Activate shrines a total of 12 times.",
        "details": "Activate shrines a total of 12 times across battles.",
        "requirements": ["Shrine element"],
        "reward": "skillPoints:2",
        "required_effort": "Minor",
    },
    # AP ID: 2007
    "Adept": {
        "ap_id": 2007,
        "game_id": 518,
        "description": "Have 30 fields lit in Trial mode.",
        "untrackable": True,
        "requirements": ["Trial", "fieldToken: 30"],
        "reward": "skillPoints:3",
        "required_effort": "Minor",
    },
    # AP ID: 2008
    "Adept Enhancer": {
        "ap_id": 2008,
        "game_id": 438,
        "description": "Reach 500 enhancement spells cast through all the battles.",
        "details": "Cumulative across all battles: cast 500 enhancement spells.",
        "requirements": ["enhancementSpells:1"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2009
    "Adept Grade": {
        "ap_id": 2009,
        "game_id": 45,
        "description": "Create a grade 8 gem.",
        "details": "Create a grade-8 gem (gem grade is RNG-influenced; flagged untrackable).",
        "untrackable": True,
        "requirements": ["minGemGrade: 8"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2010
    "Adventurer": {
        "ap_id": 2010,
        "game_id": 250,
        "description": "Gain 600 xp from drops.",
        "details": "Gain 600 xp from drops in one battle.",
        "requirements": ["Drop Holder element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2011
    "Ages Old Memories": {
        "ap_id": 2011,
        "game_id": 103,
        "description": "Unlock a wizard tower.",
        "details": "Unlock a wizard tower.",
        "requirements": ["Wizard Tower element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2012
    "Agitated": {
        "ap_id": 2012,
        "game_id": 325,
        "description": "Call 70 waves early.",
        "details": "Call 70 waves early in one battle.",
        "requirements": ["minWave: 70"],
        "reward": "skillPoints:2",
        "required_power": 80,
        "required_effort": "Major",
    },
    # AP ID: 2013
    "All Your Mana Belongs to Us": {
        "ap_id": 2013,
        "game_id": 33,
        "description": "Beat 90 waves using only mana leeching gems.",
        "details": "Beat 90 waves using only mana-leech gems.",
        "requirements": ["Mana Leech skill", "minWave: 90"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2014
    "Almost": {
        "ap_id": 2014,
        "game_id": 197,
        "description": "Kill a monster with shots blinking to the monster attacking your orb that would otherwise destroy your orb.",
        "details": "Kill a monster whose attack would otherwise destroy your orb (watchtower or wizard hunter blink shot).",
        "requirements": ["Watchtower element", "Wizard Hunter element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2015
    "Almost Like Hacked": {
        "ap_id": 2015,
        "game_id": 506,
        "description": "Have at least 20 different talisman properties.",
        "details": "Talisman must hold 20 different distinct properties at once (cumulative across socketed fragments).",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2016
    "Almost Ruined": {
        "ap_id": 2016,
        "game_id": 104,
        "description": "Leave a monster nest at 1 hit point at the end of the battle.",
        "details": "Leave a monster nest at exactly 1 HP at the end of the battle.",
        "requirements": ["Monster Nest element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2017
    "Am I a Joke to You?": {
        "ap_id": 2017,
        "game_id": 492,
        "description": "Start an enraged wave early while there is a wizard hunter on the battlefield.",
        "details": "Call an enraged wave early while a Wizard Hunter is on the battlefield.",
        "requirements": ["Wizard Hunter element"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2018
    "Ambitious Builder": {
        "ap_id": 2018,
        "game_id": 65,
        "description": "Reach 500 structures built through all the battles.",
        "details": "Cumulative across all battles: build 500 structures.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2019
    "Amplification": {
        "ap_id": 2019,
        "game_id": 238,
        "description": "Spend 18.000 mana on amplifiers.",
        "details": "Spend 18,000 mana on amplifiers in one battle.",
        "untrackable": True,
        "requirements": ["Amplifiers skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2020
    "Amplifinity": {
        "ap_id": 2020,
        "game_id": 356,
        "description": "Build 45 amplifiers.",
        "details": "Build 45 amplifiers in one battle.",
        "untrackable": True,
        "requirements": ["Amplifiers skill"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2021
    "Amulet": {
        "ap_id": 2021,
        "game_id": 359,
        "description": "Fill all the sockets in your talisman.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2022
    "And Don't Come Back": {
        "ap_id": 2022,
        "game_id": 547,
        "description": "Kill 460 banished monsters with shrines.",
        "details": "Kill 460 banished monsters with shrines.",
        "untrackable": True,
        "requirements": ["Shrine element"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2023
    "Angry Wasps": {
        "ap_id": 2023,
        "game_id": 142,
        "description": "Reach 1.000 gem wasp kills through all the battles.",
        "details": "Cumulative across all battles: 1,000 wasp kills.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2024
    "Antitheft": {
        "ap_id": 2024,
        "game_id": 611,
        "description": "Kill 90 monsters with orblet explosions.",
        "untrackable": True,
        "requirements": ["Orb of Presence skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2025
    "Armored Orb": {
        "ap_id": 2025,
        "game_id": 257,
        "description": "Strengthen your orb by dropping a gem on it.",
        "details": "Drop a gem onto the orb of presence to strengthen it.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2026
    "Army Glue": {
        "ap_id": 2026,
        "game_id": 477,
        "description": "Have a pure slowing gem with 4.000 hits.",
        "details": "Reach 4,000 hits on a pure slowing gem.",
        "requirements": ["Slowing skill", "Beam skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2027
    "At my Fingertips": {
        "ap_id": 2027,
        "game_id": 410,
        "description": "Cast 75 strike spells.",
        "details": "Cast 75 strike spells in one battle.",
        "requirements": ["strikeSpells:1"],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 2028
    "Avenged": {
        "ap_id": 2028,
        "game_id": 188,
        "description": "Kill 15 monsters carrying orblets.",
        "details": "Kill 15 monsters carrying orblets.",
        "requirements": ["Orb of Presence skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2029
    "Awakening": {
        "ap_id": 2029,
        "game_id": 263,
        "description": "Activate a shrine.",
        "details": "Activate a shrine for the first time.",
        "requirements": ["Shrine element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2030
    "Bang": {
        "ap_id": 2030,
        "game_id": 343,
        "description": "Throw 30 gem bombs.",
        "details": "Throw 30 gem bombs in one battle.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2031
    "Barbed Sphere": {
        "ap_id": 2031,
        "game_id": 256,
        "description": "Deliver 1.200 banishments with your orb.",
        "untrackable": True,
        "requirements": ["minMonsters:1200"],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 2032
    "Barrage Battery": {
        "ap_id": 2032,
        "game_id": 321,
        "description": "Have a Maximum Charge of 300% for the Barrage Spell.",
        "details": "Charge the Barrage spell to 300%.",
        "requirements": ["Barrage skill"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2033
    "Basic Gem Tactics": {
        "ap_id": 2033,
        "game_id": 304,
        "description": "Beat 120 waves and don't use any gem enhancement spells.",
        "untrackable": True,
        "requirements": ["minWave: 120"],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 2034
    "Bastion": {
        "ap_id": 2034,
        "game_id": 274,
        "description": "Build 90 towers.",
        "details": "Build 90 towers in one battle.",
        "requirements": ["Tower element"],
        "reward": "skillPoints:1",
        "required_power": 80,
        "required_effort": "Extreme",
    },
    # AP ID: 2035
    "Bath Bomb": {
        "ap_id": 2035,
        "game_id": 610,
        "description": "Kill 30 monsters with orblet explosions.",
        "untrackable": True,
        "requirements": ["Orb of Presence skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2036
    "Battle Heat": {
        "ap_id": 2036,
        "game_id": 245,
        "description": "Gain 200 xp with kill chains.",
        "details": "Gain 200 xp from kill chains in one battle.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2037
    "Bazaar": {
        "ap_id": 2037,
        "game_id": 58,
        "description": "Have 30 gems on the battlefield.",
        "details": "Have 30 gems on the field at once.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_power": 30,
        "required_effort": "Minor",
    },
    # AP ID: 2038
    "Be Gone For Good": {
        "ap_id": 2038,
        "game_id": 552,
        "description": "Kill 790 banished monsters.",
        "details": "Kill 790 banished monsters.",
        "untrackable": True,
        "requirements": ["minMonsters:790"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2039
    "Beacon Hunt": {
        "ap_id": 2039,
        "game_id": 409,
        "description": "Destroy 55 beacons.",
        "details": "Destroy 55 beacons in one battle.",
        "requirements": ["Dark Masonry trait"],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2040
    "Beacons Be Gone": {
        "ap_id": 2040,
        "game_id": 305,
        "description": "Reach 500 beacons destroyed through all the battles.",
        "details": "Cumulative across all battles: destroy 500 beacons.",
        "requirements": ["Dark Masonry trait"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2041
    "Beastmaster": {
        "ap_id": 2041,
        "game_id": 199,
        "description": "Kill a monster having at least 100.000 hit points and 1000 armor.",
        "details": "Kill a single monster with at least 100,000 HP and 1,000 armor.",
        "requirements": ["minMonsterHP:100000", "minMonsterArmor:1000"],
        "reward": "skillPoints:1",
        "required_power": 450,
        "required_effort": "Extreme",
    },
    # AP ID: 2042
    "Behold Aurora": {
        "ap_id": 2042,
        "game_id": 624,
        "description": "Go Igniculus and Light Ray (All)+++!",
        "details": "Reference: Light Ray + Igniculus from Child of Light. In-game: kill 5 wraiths with shrines while raining (or as listed by the IngameAchiChecker logic).",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2043
    "Biohazard": {
        "ap_id": 2043,
        "game_id": 21,
        "description": "Create a grade 12 pure poison gem.",
        "details": "Create a grade-12 pure poison gem (untrackable).",
        "untrackable": True,
        "requirements": ["Poison skill", "minGemGrade: 12"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2044
    "Black Blood": {
        "ap_id": 2044,
        "game_id": 417,
        "description": "Deal 5.000 poison damage to a shadow.",
        "requirements": ["Poison skill", ["Ritual trait", "Shadow element"], "Shadow element"],
        "reward": "skillPoints:2",
        "required_power": 30,
        "required_effort": "Trivial",
    },
    # AP ID: 2045
    "Black Wand": {
        "ap_id": 2045,
        "game_id": 419,
        "description": "Reach wizard level 1.000.",
        "details": "Reach wizard level 1,000.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2046
    "Blackout": {
        "ap_id": 2046,
        "game_id": 94,
        "description": "Destroy a beacon.",
        "details": "Destroy a beacon.",
        "requirements": [["Beacon element"], ["Dark Masonry Trait"]],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2047
    "Blastwave": {
        "ap_id": 2047,
        "game_id": 349,
        "description": "Reach 1.000 shrine kills through all the battles.",
        "untrackable": True,
        "requirements": ["Shrine element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2048
    "Bleed Out": {
        "ap_id": 2048,
        "game_id": 457,
        "description": "Kill 480 bleeding monsters.",
        "requirements": ["Bleeding skill"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2049
    "Bleeding For Everyone": {
        "ap_id": 2049,
        "game_id": 523,
        "description": "Enhance a pure bleeding gem having random priority with beam.",
        "requirements": ["Beam skill", "Bleeding skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2050
    "Blind Hit": {
        "ap_id": 2050,
        "game_id": 183,
        "description": "Kill 30 whited out monsters with beam.",
        "requirements": ["Beam skill", "Whiteout skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2051
    "Blood Censorship": {
        "ap_id": 2051,
        "game_id": 607,
        "description": "Kill 2.100 green blooded monsters.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2052
    "Blood Clot": {
        "ap_id": 2052,
        "game_id": 35,
        "description": "Beat 90 waves using only bleeding gems.",
        "requirements": ["Bleeding skill", "minWave: 90"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2053
    "Blood Magic": {
        "ap_id": 2053,
        "game_id": 36,
        "description": "Win a battle using only bleeding gems.",
        "requirements": ["Bleeding skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2054
    "Blood on my Hands": {
        "ap_id": 2054,
        "game_id": 118,
        "description": "Reach 20.000 monsters killed through all the battles.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2055
    "Bloodmaster": {
        "ap_id": 2055,
        "game_id": 246,
        "description": "Gain 1.200 xp with kill chains.",
        "details": "Gain 1,200 xp from kill chains in one battle.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2056
    "Bloodrush": {
        "ap_id": 2056,
        "game_id": 28,
        "description": "Call an enraged wave early.",
        "details": "Call an enraged wave early.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2057
    "Bloodstream": {
        "ap_id": 2057,
        "game_id": 429,
        "description": "Kill 4.000 monsters.",
        "details": "Kill 4,000 monsters in one battle.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_power": 30,
        "required_effort": "Minor",
    },
    # AP ID: 2058
    "Blue Wand": {
        "ap_id": 2058,
        "game_id": 386,
        "description": "Reach wizard level 100.",
        "details": "Reach wizard level 100.",
        "requirements": ["wizardLevel: 100"],
        "reward": "skillPoints:1",
        "required_power": 160,
        "required_effort": "Major",
    },
    # AP ID: 2059
    "Boatload of Cores": {
        "ap_id": 2059,
        "game_id": 350,
        "description": "Find 540 shadow cores.",
        "details": "Find 540 shadow cores in one battle.",
        "requirements": ["shadowCore: 10"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2060
    "Boiling Red": {
        "ap_id": 2060,
        "game_id": 249,
        "description": "Reach a kill chain of 2400.",
        "details": "Reach a kill chain of 2,400 in one battle.",
        "untrackable": True,
        "requirements": ["minMonsters:2400"],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2061
    "Bone Shredder": {
        "ap_id": 2061,
        "game_id": 150,
        "description": "Kill 600 monsters before wave 12 starts.",
        "details": "Kill 600 monsters before wave 12 starts. Pick a monster-dense stage with at least 12 waves.",
        "requirements": ["minMonsters:600", "beforeWave:12"],
        "reward": "skillPoints:2",
        "required_power": 30,
        "required_effort": "Trivial",
    },
    # AP ID: 2062
    "Boom": {
        "ap_id": 2062,
        "game_id": 342,
        "description": "Throw a gem bomb.",
        "details": "Throw 1 gem bomb.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2063
    "Bouncy Zap": {
        "ap_id": 2063,
        "game_id": 222,
        "description": "Reach 2.000 pylon kills through all the battles.",
        "details": "Cumulative across all battles: kill 2,000 monsters with pylons.",
        "requirements": ["Pylons skill"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2064
    "Breath of Cold": {
        "ap_id": 2064,
        "game_id": 208,
        "description": "Have 90 monsters frozen at the same time.",
        "details": "Have 90 monsters frozen at the same instant.",
        "requirements": ["Freeze skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2065
    "Brickery": {
        "ap_id": 2065,
        "game_id": 69,
        "description": "Reach 1.000 structures built through all the battles.",
        "details": "Cumulative across all battles: build 1,000 structures.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2066
    "Bright Weakening": {
        "ap_id": 2066,
        "game_id": 242,
        "description": "Gain 1.200 xp with Whiteout spell crowd hits.",
        "requirements": ["Whiteout skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2067
    "Broken Seal": {
        "ap_id": 2067,
        "game_id": 121,
        "description": "Free a sealed gem.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2068
    "Broken Siege": {
        "ap_id": 2068,
        "game_id": 96,
        "description": "Destroy 8 beacons before wave 8.",
        "details": "Destroy 8 beacons before wave 8 starts.",
        "requirements": ["Beacon element"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2069
    "Brought Some Mana": {
        "ap_id": 2069,
        "game_id": 223,
        "description": "Have 5.000 initial mana.",
        "details": "Have at least 5,000 starting mana.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_power": 80,
        "required_effort": "Trivial",
    },
    # AP ID: 2070
    "Brown Wand": {
        "ap_id": 2070,
        "game_id": 388,
        "description": "Reach wizard level 300.",
        "details": "Reach wizard level 300.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2071
    "Build Along": {
        "ap_id": 2071,
        "game_id": 64,
        "description": "Reach 200 structures built through all the battles.",
        "details": "Cumulative across all battles: build 200 structures.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2072
    "Busted": {
        "ap_id": 2072,
        "game_id": 593,
        "description": "Destroy a full health possession obelisk with one gem bomb blast.",
        "details": "Destroy a full-HP obelisk with a single gem bomb.",
        "requirements": ["Obelisk element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2073
    "Buzz Feed": {
        "ap_id": 2073,
        "game_id": 341,
        "description": "Have 99 gem wasps on the battlefield.",
        "details": "Have 99 wasps on the field at once.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2074
    "By Three They Go": {
        "ap_id": 2074,
        "game_id": 484,
        "description": "Have 3 of your gems destroyed or stolen.",
        "requirements": ["Ritual trait", "Specter element", "Watchtower element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2075
    "Bye Bye Hideous": {
        "ap_id": 2075,
        "game_id": 174,
        "description": "Kill a spire.",
        "details": "Kill a spire (any method).",
        "requirements": ["Ritual trait", "Spire element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2076
    "Call in the Wave!": {
        "ap_id": 2076,
        "game_id": 322,
        "description": "Call a wave early.",
        "details": "Call 1 wave early.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2077
    "Can't Crawl Away": {
        "ap_id": 2077,
        "game_id": 184,
        "description": "Kill 30 whited out monsters with barrage.",
        "requirements": ["Barrage skill", "Whiteout skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2078
    "Can't Stop": {
        "ap_id": 2078,
        "game_id": 157,
        "description": "Reach a kill chain of 900.",
        "details": "Reach a kill chain of 900 in one battle.",
        "untrackable": True,
        "requirements": ["minMonsters:900"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2079
    "Can't Take Any Risks": {
        "ap_id": 2079,
        "game_id": 482,
        "description": "Kill a bleeding giant with poison.",
        "details": "Kill a bleeding giant with poison damage.",
        "requirements": ["Bleeding skill", "Poison skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2080
    "Care to Die Already?": {
        "ap_id": 2080,
        "game_id": 592,
        "description": "Cast 8 ice shards on the same monster.",
        "details": "Cast 8 ice shards onto the same monster.",
        "requirements": ["Ice Shards skill"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2081
    "Carnage": {
        "ap_id": 2081,
        "game_id": 156,
        "description": "Reach a kill chain of 600.",
        "untrackable": True,
        "requirements": ["minMonsters:600"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2082
    "Cartographer": {
        "ap_id": 2082,
        "game_id": 512,
        "description": "Have 90 fields lit in Journey mode.",
        "requirements": ["fieldToken: 90"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2083
    "Catalyst": {
        "ap_id": 2083,
        "game_id": 50,
        "description": "Give a Gem 200 Poison Damage by Amplification.",
        "requirements": ["Amplifiers skill", "Poison skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2084
    "Catch and Release": {
        "ap_id": 2084,
        "game_id": 521,
        "description": "Destroy a jar of wasps, but don't have any wasp kills.",
        "requirements": ["Jar of Wasps element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2085
    "Century Egg": {
        "ap_id": 2085,
        "game_id": 18,
        "description": "Reach 100 monster eggs cracked through all the battles.",
        "requirements": ["Swarm Queen element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2086
    "Chainsaw": {
        "ap_id": 2086,
        "game_id": 272,
        "description": "Gain 3.200 xp with kill chains.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2087
    "Charge Fire Repeat": {
        "ap_id": 2087,
        "game_id": 441,
        "description": "Reach 5.000 enhancement spells cast through all the battles.",
        "details": "Cumulative across all battles: cast 5,000 enhancement spells.",
        "requirements": ["enhancementSpells:1"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2088
    "Charged for the Kill": {
        "ap_id": 2088,
        "game_id": 165,
        "description": "Reach 200 pylon kills through all the battles.",
        "requirements": ["Pylons skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2089
    "Charm": {
        "ap_id": 2089,
        "game_id": 360,
        "description": "Fill all the sockets in your talisman with fragments upgraded to their limit.",
        "details": "All talisman sockets filled, every fragment upgraded to its maximum level.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2090
    "Chilling Edges": {
        "ap_id": 2090,
        "game_id": 243,
        "description": "Gain 140 xp with Ice Shards spell crowd hits.",
        "requirements": ["Ice Shards skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2091
    "Chlorophyll": {
        "ap_id": 2091,
        "game_id": 608,
        "description": "Kill 4.500 green blooded monsters.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2092
    "Clean Orb": {
        "ap_id": 2092,
        "game_id": 418,
        "description": "Win a battle without any monster getting to your orb.",
        "details": "Win a battle without any monster touching the orb of presence.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2093
    "Cleansing the Wilderness": {
        "ap_id": 2093,
        "game_id": 187,
        "description": "Reach 50.000 monsters with special properties killed through all the battles.",
        "details": "Cumulative across all battles: 50,000 kills on monsters with special properties.",
        "untrackable": True,
        "requirements": ["Endurance", ["Possessed Monster element", "Twisted Monster element", "Marked Monster element"], "minWave: 70"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2094
    "Clear Sky": {
        "ap_id": 2094,
        "game_id": 301,
        "description": "Beat 120 waves and don't use any  spells.",
        "details": "Beat 120 waves without casting any strike spells.",
        "untrackable": True,
        "requirements": ["minWave: 120", "Endurance"],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 2095
    "Close Quarter": {
        "ap_id": 2095,
        "game_id": 252,
        "description": "Reach -12% decreased banishment cost with your orb.",
        "untrackable": True,
        "requirements": ["Amplifiers skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2096
    "Cold Wisdom": {
        "ap_id": 2096,
        "game_id": 240,
        "description": "Gain 700 xp with Freeze spell crowd hits.",
        "requirements": ["Freeze skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2097
    "Come Again": {
        "ap_id": 2097,
        "game_id": 549,
        "description": "Kill 190 banished monsters.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2098
    "Come Out": {
        "ap_id": 2098,
        "game_id": 109,
        "description": "Lure 20 swarmlings out of a sleeping hive.",
        "requirements": ["Sleeping Hive element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2099
    "Come Out, Come Out": {
        "ap_id": 2099,
        "game_id": 110,
        "description": "Lure 100 swarmlings out of a sleeping hive.",
        "requirements": ["Sleeping Hive element"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2100
    "Confusion Junction": {
        "ap_id": 2100,
        "game_id": 80,
        "description": "Build 30 walls.",
        "details": "Build 30 walls in one battle.",
        "requirements": ["Wall element"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2101
    "Connected": {
        "ap_id": 2101,
        "game_id": 59,
        "description": "Build an amplifier.",
        "requirements": ["Amplifiers skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2102
    "Connecting the Dots": {
        "ap_id": 2102,
        "game_id": 510,
        "description": "Have 50 fields lit in Journey mode.",
        "requirements": ["fieldToken: 50"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2103
    "Core Haul": {
        "ap_id": 2103,
        "game_id": 348,
        "description": "Find 180 shadow cores.",
        "details": "Find 180 shadow cores in one battle.",
        "requirements": ["shadowCore: 3"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2104
    "Core Pack": {
        "ap_id": 2104,
        "game_id": 346,
        "description": "Find 20 shadow cores.",
        "requirements": ["shadowCore: 5"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2105
    "Core Pile": {
        "ap_id": 2105,
        "game_id": 347,
        "description": "Find 60 shadow cores.",
        "requirements": ["shadowCore: 5"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2106
    "Core Pouch": {
        "ap_id": 2106,
        "game_id": 345,
        "description": "Have 100 shadow cores at the start of the battle.",
        "requirements": ["shadowCore: 100"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2107
    "Corrosive Stings": {
        "ap_id": 2107,
        "game_id": 567,
        "description": "Tear a total of 5.000 armor with wasp stings.",
        "requirements": ["Armor Tearing skill"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2108
    "Couldn't Decide": {
        "ap_id": 2108,
        "game_id": 537,
        "description": "Kill 400 monsters with prismatic gem wasps.",
        "requirements": ["gemSkills: 6"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2109
    "Crimson Journal": {
        "ap_id": 2109,
        "game_id": 119,
        "description": "Reach 100.000 monsters killed through all the battles.",
        "details": "Cumulative across all battles: 100,000 monster kills.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2110
    "Crowd Control": {
        "ap_id": 2110,
        "game_id": 371,
        "description": "Have the Overcrowd trait set to level 6 or higher and win the battle.",
        "details": "Win a battle with the Overcrowd trait at level 6 or higher.",
        "requirements": ["Overcrowd trait"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2111
    "Crowded Queue": {
        "ap_id": 2111,
        "game_id": 211,
        "description": "Have 600 monsters on the battlefield at the same time.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_power": 80,
        "required_effort": "Minor",
    },
    # AP ID: 2112
    "Crunchy Bites": {
        "ap_id": 2112,
        "game_id": 206,
        "description": "Kill 160 frozen swarmlings.",
        "requirements": ["Freeze skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2113
    "Damage Support": {
        "ap_id": 2113,
        "game_id": 474,
        "description": "Have a pure bleeding gem with 2.500 hits.",
        "details": "Reach 2,500 hits on a pure bleeding gem.",
        "requirements": ["Bleeding skill", "Beam skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2114
    "Darkness Walk With Me": {
        "ap_id": 2114,
        "game_id": 166,
        "description": "Kill 3 shadows.",
        "details": "Kill 3 shadows in one battle.",
        "requirements": [["Ritual trait", "Shadow element"]],
        "reward": "skillPoints:3",
        "required_effort": "Minor",
    },
    # AP ID: 2115
    "Deadly Curse": {
        "ap_id": 2115,
        "game_id": 307,
        "description": "Reach 5.000 poison kills through all the battles.",
        "details": "Cumulative across all battles: 5,000 kills with poison.",
        "requirements": ["Poison skill"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2116
    "Deal Some Damage Too": {
        "ap_id": 2116,
        "game_id": 469,
        "description": "Have 5 traps with bolt enhanced gems in them.",
        "requirements": ["Bolt skill", "Traps skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2117
    "Deathball": {
        "ap_id": 2117,
        "game_id": 201,
        "description": "Reach 1.000 pylon kills through all the battles.",
        "details": "Cumulative across all battles: kill 1,000 monsters with pylons.",
        "requirements": ["Pylons skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2118
    "Deckard Would Be Proud": {
        "ap_id": 2118,
        "game_id": 621,
        "description": "All I could get for a prismatic amulet",
        "details": "Reference: Diablo. Build a 6-component prismatic talisman (random property RNG).",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2119
    "Deluminati": {
        "ap_id": 2119,
        "game_id": 370,
        "description": "Have the Dark Masonry trait set to level 6 or higher and win the battle.",
        "details": "Win a battle with the Dark Masonry trait at level 6 or higher.",
        "requirements": ["Dark Masonry trait"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2120
    "Denested": {
        "ap_id": 2120,
        "game_id": 62,
        "description": "Destroy 5 monster nests.",
        "requirements": ["Monster Nest element"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2121
    "Derangement": {
        "ap_id": 2121,
        "game_id": 536,
        "description": "Decrease the range of a gem.",
        "details": "Decrease a gem's range with a duplicator (or similar mechanic).",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2122
    "Desperate Clash": {
        "ap_id": 2122,
        "game_id": 253,
        "description": "Reach -16% decreased banishment cost with your orb.",
        "untrackable": True,
        "requirements": ["Amplifiers skill"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2123
    "Diabolic Trophy": {
        "ap_id": 2123,
        "game_id": 143,
        "description": "Kill 666 swarmlings.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2124
    "Dichromatic": {
        "ap_id": 2124,
        "game_id": 0,
        "description": "Combine two gems of different colors.",
        "details": "Combine two gems of different colors.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2125
    "Disciple": {
        "ap_id": 2125,
        "game_id": 517,
        "description": "Have 10 fields lit in Trial mode.",
        "requirements": ["Trial", "fieldToken: 10"],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 2126
    "Disco Ball": {
        "ap_id": 2126,
        "game_id": 526,
        "description": "Have a gem of 6 components in a lantern.",
        "requirements": ["Lanterns skill", "gemSkills: 6"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2127
    "Don't Break it!": {
        "ap_id": 2127,
        "game_id": 420,
        "description": "Spend 90.000 mana on banishment.",
        "details": "Spend a cumulative total of 90,000 mana on banishments.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2128
    "Don't Look at the Light": {
        "ap_id": 2128,
        "game_id": 432,
        "description": "Reach 10.000 shrine kills through all the battles.",
        "details": "Cumulative across all battles: kill 10,000 monsters with shrines.",
        "untrackable": True,
        "requirements": ["Shrine element"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2129
    "Don't Touch it!": {
        "ap_id": 2129,
        "game_id": 168,
        "description": "Kill a specter.",
        "details": "Kill a specter (any method).",
        "requirements": [["Ritual trait", "Specter element"]],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2130
    "Doom Drop": {
        "ap_id": 2130,
        "game_id": 159,
        "description": "Kill a possessed giant with barrage.",
        "untrackable": True,
        "requirements": ["Barrage skill", "Possessed Monster element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2131
    "Double Punch": {
        "ap_id": 2131,
        "game_id": 298,
        "description": "Have 2 bolt enhanced gems at the same time.",
        "requirements": ["Bolt skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2132
    "Double Sharded": {
        "ap_id": 2132,
        "game_id": 589,
        "description": "Cast 2 ice shards on the same monster.",
        "details": "Cast 2 ice shards onto the same monster.",
        "requirements": ["Ice Shards skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2133
    "Double Splash": {
        "ap_id": 2133,
        "game_id": 577,
        "description": "Kill two non-monster creatures with one gem bomb.",
        "details": "Kill 2 non-monsters with one gem bomb.",
        "requirements": ["Ritual trait"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2134
    "Double Strike": {
        "ap_id": 2134,
        "game_id": 266,
        "description": "Activate the same shrine 2 times.",
        "details": "Activate the same shrine 2 times in one battle.",
        "requirements": ["Shrine element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2135
    "Drone Warfare": {
        "ap_id": 2135,
        "game_id": 154,
        "description": "Reach 20.000 gem wasp kills through all the battles.",
        "details": "Cumulative across all battles: 20,000 wasp kills.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2136
    "Drop the Ice": {
        "ap_id": 2136,
        "game_id": 444,
        "description": "Reach 50.000 strike spell hits through all the battles.",
        "details": "Cumulative across all battles: 50,000 strike spell hits.",
        "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill", "strikeSpells: 1"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2137
    "Drumroll": {
        "ap_id": 2137,
        "game_id": 219,
        "description": "Deal 200 gem wasp stings to buildings.",
        "details": "Land 200 wasp stings on enemy buildings.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2138
    "Dry Puddle": {
        "ap_id": 2138,
        "game_id": 112,
        "description": "Harvest all mana from a mana shard.",
        "details": "Fully harvest a mana shard in one battle.",
        "requirements": ["Mana Shard element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2139
    "Dual Downfall": {
        "ap_id": 2139,
        "game_id": 175,
        "description": "Kill 2 spires.",
        "requirements": ["Ritual trait", "Spire element"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2140
    "Dual Pulse": {
        "ap_id": 2140,
        "game_id": 294,
        "description": "Have 2 beam enhanced gems at the same time.",
        "details": "Have 2 beam-enhanced gems active at once.",
        "requirements": ["Beam skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2141
    "Eagle Eye": {
        "ap_id": 2141,
        "game_id": 39,
        "description": "Reach an amplified gem range of 18.",
        "details": "Have a gem reach 18+ range while inside an amplifier.",
        "untrackable": True,
        "requirements": ["Amplifiers skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2142
    "Early Bird": {
        "ap_id": 2142,
        "game_id": 10,
        "description": "Reach 500 waves started early through all the battles.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2143
    "Early Harvest": {
        "ap_id": 2143,
        "game_id": 116,
        "description": "Harvest 2.500 mana from shards before wave 3 starts.",
        "requirements": ["Mana Shard element"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2144
    "Earthquake": {
        "ap_id": 2144,
        "game_id": 264,
        "description": "Activate shrines a total of 4 times.",
        "details": "Activate shrines 4 times total in one battle (any combination).",
        "requirements": ["Shrine element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2145
    "Easy Kill": {
        "ap_id": 2145,
        "game_id": 455,
        "description": "Kill 120 bleeding monsters.",
        "details": "Kill 120 bleeding monsters.",
        "requirements": ["Bleeding skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2146
    "Eat my Light": {
        "ap_id": 2146,
        "game_id": 465,
        "description": "Kill a wraith with a shrine strike.",
        "requirements": ["Ritual trait", "Shrine element", "Wraith element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2147
    "Eggcracker": {
        "ap_id": 2147,
        "game_id": 573,
        "description": "Don't let any egg laid by a swarm queen to hatch on its own.",
        "details": "Beat the battle without letting any swarm queen egg hatch.",
        "requirements": ["Swarm Queen element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2148
    "Eggnog": {
        "ap_id": 2148,
        "game_id": 527,
        "description": "Crack a monster egg open while time is frozen.",
        "details": "Crack a monster egg while time is frozen (Whiteout active).",
        "requirements": ["Swarm Queen element", "Freeze skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2149
    "Eggs Royale": {
        "ap_id": 2149,
        "game_id": 115,
        "description": "Reach 1.000 monster eggs cracked through all the battles.",
        "details": "Cumulative across all battles: crack 1,000 eggs.",
        "requirements": ["Swarm Queen element"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2150
    "Elementary": {
        "ap_id": 2150,
        "game_id": 569,
        "description": "Beat 30 waves using at most grade 2 gems.",
        "details": "Beat 30 waves with only grade-2 or lower gems.",
        "requirements": ["minWave: 30"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2151
    "End of the Tunnel": {
        "ap_id": 2151,
        "game_id": 466,
        "description": "Kill an apparition with a shrine strike.",
        "details": "Kill an apparition with a shrine activation.",
        "requirements": ["Ritual trait", "Apparition element", "Shrine element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2152
    "Endgame Balance": {
        "ap_id": 2152,
        "game_id": 423,
        "description": "Have 25.000 shadow cores at the start of the battle.",
        "details": "Start a battle with at least 25,000 shadow cores in your stash.",
        "requirements": ["shadowCore: 50"],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2153
    "Endured a Lot": {
        "ap_id": 2153,
        "game_id": 516,
        "description": "Have 80 fields lit in Endurance mode.",
        "requirements": ["Endurance", "fieldToken: 80"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2154
    "Enhance Like No Tomorrow": {
        "ap_id": 2154,
        "game_id": 440,
        "description": "Reach 2.500 enhancement spells cast through all the battles.",
        "details": "Cumulative across all battles: cast 2,500 enhancement spells.",
        "requirements": ["enhancementSpells:1"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2155
    "Enhancement Storage": {
        "ap_id": 2155,
        "game_id": 463,
        "description": "Enhance a gem in the inventory.",
        "details": "Cast Bolt/Beam/Barrage on a gem in your inventory.",
        "requirements": ["enhancementSpells:1"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2156
    "Enhancing Challenge": {
        "ap_id": 2156,
        "game_id": 555,
        "description": "Beat 200 waves on max Swarmling and Giant domination traits.",
        "details": "Beat 200 waves in Endurance with Swarmling Domination AND Giant Domination both at max level.",
        "untrackable": True,
        "requirements": ["Swarmling Domination trait", "Giant Domination trait", "minWave: 200", "Endurance"],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2157
    "Enough Frozen Time Trickery": {
        "ap_id": 2157,
        "game_id": 529,
        "description": "Kill a shadow while time is frozen.",
        "requirements": ["Shadow element", "Freeze skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2158
    "Enough is Enough": {
        "ap_id": 2158,
        "game_id": 487,
        "description": "Have 24 of your gems destroyed or stolen.",
        "details": "Have 24 of your gems destroyed or stolen by enemies.",
        "requirements": ["Ritual trait", "Specter element", "Watchtower element"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2159
    "Enraged is the New Norm": {
        "ap_id": 2159,
        "game_id": 338,
        "description": "Enrage 240 waves.",
        "details": "Manually enrage 240 waves cumulatively.",
        "untrackable": True,
        "requirements": ["minWave: 240", "Endurance"],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2160
    "Ensnared": {
        "ap_id": 2160,
        "game_id": 127,
        "description": "Kill 12 monsters with gems in traps.",
        "requirements": ["Traps skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2161
    "Enter The Gate": {
        "ap_id": 2161,
        "game_id": 635,
        "description": "Kill the gatekeeper.",
        "requirements": ["Gatekeeper element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2162
    "Entrenched": {
        "ap_id": 2162,
        "game_id": 72,
        "description": "Build 20 traps.",
        "details": "Build 20 traps in one battle.",
        "requirements": ["Traps skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2163
    "Epidemic Gem": {
        "ap_id": 2163,
        "game_id": 476,
        "description": "Have a pure poison gem with 3.500 hits.",
        "details": "Reach 3,500 hits on a pure poison gem.",
        "untrackable": True,
        "requirements": ["Poison skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2164
    "Even if You Thaw": {
        "ap_id": 2164,
        "game_id": 312,
        "description": "Whiteout 120 frozen monsters.",
        "requirements": ["Freeze skill", "Whiteout skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2165
    "Every Hit Counts": {
        "ap_id": 2165,
        "game_id": 278,
        "description": "Deliver 3750 one hit kills.",
        "details": "Score 3,750 one-hit kills cumulatively.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2166
    "Exorcism": {
        "ap_id": 2166,
        "game_id": 148,
        "description": "Kill 199 possessed monsters.",
        "details": "Kill 199 possessed monsters in one battle.",
        "untrackable": True,
        "requirements": ["Possessed Monster element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2167
    "Expert": {
        "ap_id": 2167,
        "game_id": 519,
        "description": "Have 50 fields lit in Trial mode.",
        "requirements": ["Trial", "fieldToken: 50"],
        "reward": "skillPoints:3",
        "required_effort": "Major",
    },
    # AP ID: 2168
    "Extorted": {
        "ap_id": 2168,
        "game_id": 113,
        "description": "Harvest all mana from 3 mana shards.",
        "details": "Fully harvest 3 mana shards in one battle.",
        "requirements": ["Mana Shard element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2169
    "Face the Phobia": {
        "ap_id": 2169,
        "game_id": 375,
        "description": "Have the Swarmling Parasites trait set to level 6 or higher and win the battle.",
        "details": "Win a battle with the Swarmling Parasites trait at level 6 or higher.",
        "requirements": ["Swarmling Parasites trait"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2170
    "Family Friendlier": {
        "ap_id": 2170,
        "game_id": 606,
        "description": "Kill 900 green blooded monsters.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2171
    "Farewell": {
        "ap_id": 2171,
        "game_id": 496,
        "description": "Kill an apparition with one hit.",
        "requirements": ["Ritual trait", "Apparition element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2172
    "Feels Like Endurance": {
        "ap_id": 2172,
        "game_id": 145,
        "description": "Beat 120 waves.",
        "untrackable": True,
        "requirements": ["minWave: 120"],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2173
    "Fierce Encounter": {
        "ap_id": 2173,
        "game_id": 251,
        "description": "Reach -8% decreased banishment cost with your orb.",
        "details": "Reach -8% banishment cost on the orb (requires gems with banishment effects in orb amplifiers).",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2174
    "Fifth Grader": {
        "ap_id": 2174,
        "game_id": 44,
        "description": "Create a grade 5 gem.",
        "details": "Create a grade-5 gem.",
        "untrackable": True,
        "requirements": ["minGemGrade: 5"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2175
    "Filled 5 Times": {
        "ap_id": 2175,
        "game_id": 226,
        "description": "Reach mana pool level 5.",
        "details": "Reach mana pool level 5.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2176
    "Final Cut": {
        "ap_id": 2176,
        "game_id": 458,
        "description": "Kill 960 bleeding monsters.",
        "requirements": ["Bleeding skill"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2177
    "Final Touch": {
        "ap_id": 2177,
        "game_id": 490,
        "description": "Kill a spire with a gem wasp.",
        "details": "Kill a spire using a wasp.",
        "requirements": ["Ritual trait", "Spire element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2178
    "Finders": {
        "ap_id": 2178,
        "game_id": 233,
        "description": "Gain 200 mana from drops.",
        "requirements": ["Mana Shard element", "Corrupted Mana Shard element", "Drop Holder element", "Apparition element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2179
    "Fire Away": {
        "ap_id": 2179,
        "game_id": 293,
        "description": "Cast a gem enhancement spell.",
        "details": "Cast 1 enhancement spell.",
        "requirements": ["enhancementSpells:1"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2180
    "Fire in the Hole": {
        "ap_id": 2180,
        "game_id": 90,
        "description": "Destroy a monster nest.",
        "requirements": ["Monster Nest element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2181
    "Firefall": {
        "ap_id": 2181,
        "game_id": 427,
        "description": "Have 16 barrage enhanced gems at the same time.",
        "details": "Have 16 barrage-enhanced gems active at once.",
        "requirements": ["Barrage skill"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2182
    "First Blood": {
        "ap_id": 2182,
        "game_id": 122,
        "description": "Kill a monster.",
        "details": "Kill 1 monster.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2183
    "First Puzzle Piece": {
        "ap_id": 2183,
        "game_id": 364,
        "description": "Find a talisman fragment.",        
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2184
    "Flip Flop": {
        "ap_id": 2184,
        "game_id": 541,
        "description": "Win a flipped field battle.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2185
    "Flows Through my Veins": {
        "ap_id": 2185,
        "game_id": 227,
        "description": "Reach mana pool level 10.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_power": 30,
        "required_effort": "Minor",
    },
    # AP ID: 2186
    "Flying Multikill": {
        "ap_id": 2186,
        "game_id": 411,
        "description": "Destroy 1 apparition, 1 specter, 1 wraith and 1 shadow in the same battle.",
        "details": "Kill an apparition, specter, wraith, AND shadow all in one battle.",
        "requirements": ["Ritual trait", "Apparition element", "Shadow element", "Specter element", "Wraith element"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2187
    "Fool Me Once": {
        "ap_id": 2187,
        "game_id": 550,
        "description": "Kill 390 banished monsters.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2188
    "Forces Within my Comprehension": {
        "ap_id": 2188,
        "game_id": 398,
        "description": "Have the Ritual trait set to level 6 or higher and win the battle.",
        "details": "Win a battle with the Ritual trait at level 6 or higher.",
        "requirements": ["Ritual trait"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2189
    "Forged in Battle": {
        "ap_id": 2189,
        "game_id": 8,
        "description": "Reach 200 battles won.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2190
    "Fortress": {
        "ap_id": 2190,
        "game_id": 68,
        "description": "Build 30 towers.",
        "details": "Build 30 towers in one battle.",
        "requirements": ["Tower element"],
        "reward": "skillPoints:1",
        "required_power": 30,
        "required_effort": "Major",
    },
    # AP ID: 2191
    "Fortunate": {
        "ap_id": 2191,
        "game_id": 365,
        "description": "Find 2 talisman fragments.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2192
    "Frag Rain": {
        "ap_id": 2192,
        "game_id": 358,
        "description": "Find 5 talisman fragments.",
        "details": "Find 5 talisman fragments (random drops; varies per seed).",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 2193
    "Freezing Wounds": {
        "ap_id": 2193,
        "game_id": 309,
        "description": "Freeze a monster 3 times.",
        "details": "Freeze the same monster 3 times.",
        "requirements": ["Freeze skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2194
    "Friday Night": {
        "ap_id": 2194,
        "game_id": 295,
        "description": "Have 4 beam enhanced gems at the same time.",
        "requirements": ["Beam skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2195
    "Frittata": {
        "ap_id": 2195,
        "game_id": 83,
        "description": "Reach 500 monster eggs cracked through all the battles.",
        "details": "Cumulative across all battles: crack 500 eggs.",
        "requirements": ["Swarm Queen element"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2196
    "From Above": {
        "ap_id": 2196,
        "game_id": 130,
        "description": "Kill 40 monsters with gem bombs and wasps.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2197
    "Frostborn": {
        "ap_id": 2197,
        "game_id": 437,
        "description": "Reach 5.000 strike spells cast through all the battles.",
        "details": "Cumulative across all battles: cast 5,000 strike spells.",
        "requirements": ["Whiteout skill", "Ice Shards skill", "Freeze skill", "strikeSpells: 1"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2198
    "Frosting": {
        "ap_id": 2198,
        "game_id": 479,
        "description": "Freeze a specter while it's snowing.",
        "details": "Freeze a specter during snow weather.",
        "requirements": ["Freeze skill", "Ritual trait", "Specter element", "Snow element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2199
    "Frozen Crowd": {
        "ap_id": 2199,
        "game_id": 443,
        "description": "Reach 10.000 strike spell hits through all the battles.",
        "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill", "strikeSpells: 1"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2200
    "Frozen Grave": {
        "ap_id": 2200,
        "game_id": 192,
        "description": "Kill 220 monsters while it's snowing.",
        "details": "Kill 220 monsters during snow weather.",
        "requirements": ["Snow element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2201
    "Frozen Over": {
        "ap_id": 2201,
        "game_id": 289,
        "description": "Gain 4.500 xp with Freeze spell crowd hits.",
        "details": "Gain 4,500 xp from Freeze crowd hits in one battle.",
        "requirements": ["Freeze skill"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2202
    "Ful Ir": {
        "ap_id": 2202,
        "game_id": 202,
        "description": "Blast like a fireball",
        "details": "Reference: Ultima 'fireball' spell. Throw 1000 gem bombs across all battles.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2203
    "Fully Lit": {
        "ap_id": 2203,
        "game_id": 508,
        "description": "Have a field beaten in all three battle modes.",
        "details": "Have one field beaten in all three modes (Journey, Endurance, Trial).",
        "requirements": ["Endurance", "Trial"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2204
    "Fully Shining": {
        "ap_id": 2204,
        "game_id": 403,
        "description": "Have 60 gems on the battlefield.",
        "details": "Have 60 gems on the field at once.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_power": 80,
        "required_effort": "Major",
    },
    # AP ID: 2205
    "Fusion Core": {
        "ap_id": 2205,
        "game_id": 297,
        "description": "Have 16 beam enhanced gems at the same time.",
        "details": "Have 16 beam-enhanced gems active at once.",
        "requirements": ["Beam skill"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2206
    "Gearing Up": {
        "ap_id": 2206,
        "game_id": 363,
        "description": "Have 5 fragments socketed in your talisman.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2207
    "Gem Lust": {
        "ap_id": 2207,
        "game_id": 170,
        "description": "Kill 2 specters.",
        "requirements": ["Ritual trait", "Specter element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2208
    "Gemhancement": {
        "ap_id": 2208,
        "game_id": 439,
        "description": "Reach 1.000 enhancement spells cast through all the battles.",
        "requirements": ["enhancementSpells:1"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2209
    "Get Them": {
        "ap_id": 2209,
        "game_id": 499,
        "description": "Have a watchtower kill 39 monsters.",
        "details": "Have a watchtower kill 39 monsters in one battle.",
        "requirements": ["Watchtower element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2210
    "Get This Done Quick": {
        "ap_id": 2210,
        "game_id": 559,
        "description": "Win a Trial battle with at least 3 waves started early.",
        "details": "Win a Trial battle with at least 3 waves called early.",
        "requirements": ["minWave: 3", "Trial"],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 2211
    "Getting My Feet Wet": {
        "ap_id": 2211,
        "game_id": 513,
        "description": "Have 20 fields lit in Endurance mode.",
        "requirements": ["Endurance", "fieldToken: 20"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2212
    "Getting Rid of Them": {
        "ap_id": 2212,
        "game_id": 344,
        "description": "Drop 48 gem bombs on beacons.",
        "details": "Throw 48 gem bombs at beacons in one battle.",
        "requirements": ["Beacon element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2213
    "Getting Serious": {
        "ap_id": 2213,
        "game_id": 53,
        "description": "Have a grade 1 gem with 1.500 hits.",
        "details": "Reach 1,500 hits on a grade-1 gem.",
        "requirements": ["Beam skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2214
    "Getting Waves Done": {
        "ap_id": 2214,
        "game_id": 12,
        "description": "Reach 2.000 waves started early through all the battles.",
        "details": "Cumulative across all battles: 2,000 waves called early.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2215
    "Getting Wet": {
        "ap_id": 2215,
        "game_id": 132,
        "description": "Beat 30 waves.",
        "requirements": ["minWave: 30"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2216
    "Glitter Cloud": {
        "ap_id": 2216,
        "game_id": 489,
        "description": "Kill an apparition with a gem bomb.",
        "details": "Kill an apparition using a gem bomb.",
        "requirements": ["Ritual trait", "Apparition element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2217
    "Glowing Armada": {
        "ap_id": 2217,
        "game_id": 491,
        "description": "Have 240 gem wasps on the battlefield when the battle ends.",
        "details": "End a battle with 240 wasps on the field.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2218
    "Going Deviant": {
        "ap_id": 2218,
        "game_id": 616,
        "description": "Rook to a9",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2219
    "Going for the Weak": {
        "ap_id": 2219,
        "game_id": 501,
        "description": "Have a watchtower kill a poisoned monster.",
        "details": "Have a watchtower kill a poisoned monster.",
        "requirements": ["Poison skill", "Watchtower element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2220
    "Got the Price Back": {
        "ap_id": 2220,
        "game_id": 478,
        "description": "Have a pure mana leeching gem with 4.500 hits.",
        "details": "Reach 4,500 hits on a pure mana-leech gem.",
        "requirements": ["Mana Leech skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2221
    "Great Survivor": {
        "ap_id": 2221,
        "game_id": 507,
        "description": "Kill a monster from wave 1 when wave 20 has already started.",
        "details": "Kill a wave-1 monster after wave 20 has already started (the monster survived 19+ waves).",
        "requirements": ["minWave:20"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2222
    "Green Eyed Ninja": {
        "ap_id": 2222,
        "game_id": 614,
        "description": "Entering: The Wilderness",
        "details": "Reference: 'Entering: The Wilderness'. Hidden Mod-only achievement.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2223
    "Green Path": {
        "ap_id": 2223,
        "game_id": 609,
        "description": "Kill 9.900 green blooded monsters.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2224
    "Green Vial": {
        "ap_id": 2224,
        "game_id": 204,
        "description": "Have more than 75% of the monster kills caused by poison.",
        "details": "In one battle, at least 75% of kills are from poison damage.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2225
    "Green Wand": {
        "ap_id": 2225,
        "game_id": 385,
        "description": "Reach wizard level 60.",
        "details": "Reach wizard level 60.",
        "requirements": ["wizardLevel: 60"],
        "reward": "skillPoints:1",
        "required_power": 80,
        "required_effort": "Minor",
    },
    # AP ID: 2226
    "Ground Luck": {
        "ap_id": 2226,
        "game_id": 366,
        "description": "Find 3 talisman fragments.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2227
    "Groundfill": {
        "ap_id": 2227,
        "game_id": 601,
        "description": "Demolish a trap.",
        "details": "Demolish a trap.",
        "requirements": ["Traps skill", "Demolition skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2228
    "Guarding the Fallen Gate": {
        "ap_id": 2228,
        "game_id": 372,
        "description": "Have the Corrupted Banishment trait set to level 6 or higher and win the battle.",
        "details": "Win a battle with the Corrupted Banishment trait at level 6 or higher.",
        "requirements": ["Corrupted Banishment trait"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2229
    "Hacked Gem": {
        "ap_id": 2229,
        "game_id": 61,
        "description": "Have a grade 3 gem with 1.200 effective max damage.",
        "details": "Create a grade-3 gem with at least 1200 effective max damage.",
        "untrackable": True,
        "requirements": ["minGemGrade: 3"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2230
    "Half Full": {
        "ap_id": 2230,
        "game_id": 633,
        "description": "Add 32 talisman fragments to your shape collection.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2231
    "Handle With Care": {
        "ap_id": 2231,
        "game_id": 613,
        "description": "Kill 300 monsters with orblet explosions.",
        "untrackable": True,
        "requirements": ["Orb of Presence skill"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2232
    "Hard Reset": {
        "ap_id": 2232,
        "game_id": 408,
        "description": "Reach 5.000 shrine kills through all the battles.",
        "details": "Cumulative across all battles: kill 5,000 monsters with shrines.",
        "untrackable": True,
        "requirements": ["Shrine element"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2233
    "Has Stood Long Enough": {
        "ap_id": 2233,
        "game_id": 561,
        "description": "Destroy a monster nest after the last wave has started.",
        "details": "Destroy a monster nest after the very last wave has started.",
        "requirements": ["Monster Nest element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2234
    "Hateful": {
        "ap_id": 2234,
        "game_id": 353,
        "description": "Have the Hatred trait set to level 6 or higher and win the battle.",
        "details": "Win a battle with the Hatred trait at level 6 or higher.",
        "requirements": ["Hatred trait"],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 2235
    "Hazardous Materials": {
        "ap_id": 2235,
        "game_id": 161,
        "description": "Put your HEV on first",
        "details": "Reference: Half-Life HEV suit. Reach 1000 specific stat (mod logic only — exact trigger undocumented). Have atleast 1.000 enemies poisoned and alive on a field",
        "untrackable": True,
        "requirements": ["Poison skill"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2236
    "Healing Denied": {
        "ap_id": 2236,
        "game_id": 467,
        "description": "Destroy 3 healing beacons.",
        "requirements": ["Beacon element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2237
    "Heavily Modified": {
        "ap_id": 2237,
        "game_id": 542,
        "description": "Activate all mods.",
        "details": "Activate every Hidden Mod toggle in one battle.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2238
    "Heavy Hitting": {
        "ap_id": 2238,
        "game_id": 299,
        "description": "Have 4 bolt enhanced gems at the same time.",
        "requirements": ["Bolt skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2239
    "Heavy Support": {
        "ap_id": 2239,
        "game_id": 98,
        "description": "Have 20 beacons on the field at the same time.",
        "requirements": ["Dark Masonry trait", "Beacon element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2240
    "Hedgehog": {
        "ap_id": 2240,
        "game_id": 200,
        "description": "Kill a swarmling having at least 100 armor.",
        "details": "Kill a swarmling that has at least 100 armor.",
        "requirements": ["minSwarmlingArmor:100"],
        "reward": "skillPoints:1",
        "required_power": 30,
        "required_effort": "Trivial",
    },
    # AP ID: 2241
    "Helping Hand": {
        "ap_id": 2241,
        "game_id": 500,
        "description": "Have a watchtower kill a possessed monster.",
        "details": "Have a watchtower kill a possessed monster.",
        "untrackable": True,
        "requirements": ["Possessed Monster element", "Watchtower element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2242
    "Hiding Spot": {
        "ap_id": 2242,
        "game_id": 100,
        "description": "Open 3 drop holders before wave 3.",
        "requirements": ["Drop Holder element"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2243
    "High Stakes": {
        "ap_id": 2243,
        "game_id": 381,
        "description": "Set a battle trait to level 12.",
        "requirements": ["BattleTraits: 1"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2244
    "High Targets": {
        "ap_id": 2244,
        "game_id": 138,
        "description": "Reach 100 non-monsters killed through all the battles.",
        "details": "Cumulative across all battles: 100 non-monster kills.",
        "requirements": ["Ritual trait"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2245
    "Hint of Darkness": {
        "ap_id": 2245,
        "game_id": 147,
        "description": "Kill 189 twisted monsters.",
        "untrackable": True,
        "requirements": ["Twisted Monster element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2246
    "Hold Still": {
        "ap_id": 2246,
        "game_id": 313,
        "description": "Freeze 130 whited out monsters.",
        "details": "Freeze 130 already-whited-out monsters (Whiteout first, then Freeze).",
        "requirements": ["Freeze skill", "Whiteout skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2247
    "Hope has fallen": {
        "ap_id": 2247,
        "game_id": 622,
        "description": "Dismantled bunkhouses",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2248
    "How About Some Skill Points": {
        "ap_id": 2248,
        "game_id": 422,
        "description": "Have 5.000 shadow cores at the start of the battle.",
        "details": "Start a battle with at least 5,000 shadow cores in your stash.",
        "requirements": ["shadowCore: 20"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2249
    "Hungry Little Gem": {
        "ap_id": 2249,
        "game_id": 599,
        "description": "Leech 3.600 mana with a grade 1 gem.",
        "details": "Leech 3,600 mana with a grade-1 gem (in a trap).",
        "untrackable": True,
        "requirements": ["Mana Leech skill", "minGemGrade: 1"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2250
    "Hunt For Hard Targets": {
        "ap_id": 2250,
        "game_id": 534,
        "description": "Kill 680 monsters while there are at least 2 wraiths in the air.",
        "details": "Kill 680 monsters with at least 2 wraiths alive.",
        "requirements": ["Ritual trait", "Wraith element"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2251
    "Hurtified": {
        "ap_id": 2251,
        "game_id": 456,
        "description": "Kill 240 bleeding monsters.",
        "details": "Kill 240 bleeding monsters.",
        "requirements": ["Bleeding skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2252
    "Hyper Gem": {
        "ap_id": 2252,
        "game_id": 41,
        "description": "Have a grade 3 gem with 600 effective max damage.",
        "details": "Create a grade-3 gem with at least 600 effective max damage.",
        "untrackable": True,
        "requirements": ["minGemGrade: 3"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2253
    "I Have Experience": {
        "ap_id": 2253,
        "game_id": 7,
        "description": "Reach 50 battles won.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2254
    "I Never Asked For This": {
        "ap_id": 2254,
        "game_id": 620,
        "description": "All my aug points spent",
        "details": "Reference: Deus Ex. Win a battle with all skill points spent (no unspent points).",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2255
    "I Saw Something": {
        "ap_id": 2255,
        "game_id": 163,
        "description": "Kill an apparition.",
        "details": "Kill an apparition.",
        "requirements": ["Ritual trait", "Apparition element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2256
    "I Warned You...": {
        "ap_id": 2256,
        "game_id": 169,
        "description": "Kill a specter while it carries a gem.",
        "details": "Kill a specter while it is carrying a gem.",
        "requirements": ["Ritual trait", "Specter element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2257
    "I am Tougher": {
        "ap_id": 2257,
        "game_id": 535,
        "description": "Kill 1.360 monsters while there are at least 2 wraiths in the air.",
        "details": "Kill 1,360 monsters with at least 2 wraiths alive.",
        "requirements": ["Ritual trait", "Wraith element"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2258
    "Ice Cube": {
        "ap_id": 2258,
        "game_id": 320,
        "description": "Have a Maximum Charge of 300% for the Freeze Spell.",
        "details": "Charge the Freeze spell to 300%.",
        "requirements": ["Freeze skill"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2259
    "Ice Mage": {
        "ap_id": 2259,
        "game_id": 436,
        "description": "Reach 2.500 strike spells cast through all the battles.",
        "details": "Cumulative across all battles: cast 2,500 strike spells.",
        "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill", "strikeSpells: 1"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2260
    "Ice Snap": {
        "ap_id": 2260,
        "game_id": 239,
        "description": "Gain 90 xp with Freeze spell crowd hits.",
        "details": "Gain 90 xp from Freeze crowd hits.",
        "requirements": ["Freeze skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2261
    "Ice Stand": {
        "ap_id": 2261,
        "game_id": 189,
        "description": "Kill 5 frozen monsters carrying orblets.",
        "details": "Kill 5 frozen monsters that are carrying orblets.",
        "requirements": ["Freeze skill", "Orb of Presence skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2262
    "Ice for Everyone": {
        "ap_id": 2262,
        "game_id": 445,
        "description": "Reach 100.000 strike spell hits through all the battles.",
        "details": "Cumulative across all battles: 100,000 strike spell hits.",
        "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill", "strikeSpells: 1"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2263
    "Icecracker": {
        "ap_id": 2263,
        "game_id": 181,
        "description": "Kill 90 frozen monsters with barrage.",
        "details": "Kill 90 frozen monsters using Barrage-enhanced gems.",
        "requirements": ["Barrage skill", "Freeze skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2264
    "Icepicked": {
        "ap_id": 2264,
        "game_id": 196,
        "description": "Gain 3.200 xp with Ice Shards spell crowd hits.",
        "details": "Gain 3,200 xp from Ice Shards crowd hits.",
        "requirements": ["Ice Shards skill"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2265
    "Icy Fingers": {
        "ap_id": 2265,
        "game_id": 434,
        "description": "Reach 500 strike spells cast through all the battles.",
        "requirements": ["Whiteout skill", "Freeze skill", "Ice Shards skill", "strikeSpells: 1"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2266
    "Impaling Charges": {
        "ap_id": 2266,
        "game_id": 124,
        "description": "Deliver 250 one hit kills.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2267
    "Impenetrable": {
        "ap_id": 2267,
        "game_id": 339,
        "description": "Have 8 bolt enhanced gems at the same time.",
        "requirements": ["Bolt skill"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2268
    "Implosion": {
        "ap_id": 2268,
        "game_id": 629,
        "description": "Kill a gatekeeper fang with a gem bomb.",
        "details": "Kill a gatekeeper fang using a gem bomb.",
        "requirements": ["Gatekeeper element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2269
    "Impressive": {
        "ap_id": 2269,
        "game_id": 558,
        "description": "Win a Trial battle without any monster reaching your Orb.",
        "requirements": ["Trial"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2270
    "Impudence": {
        "ap_id": 2270,
        "game_id": 485,
        "description": "Have 6 of your gems destroyed or stolen.",
        "details": "Have 6 of your gems destroyed or stolen by enemies in one battle.",
        "requirements": ["Ritual trait", "Specter element", "Watchtower element"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2271
    "In Flames": {
        "ap_id": 2271,
        "game_id": 415,
        "description": "Kill 400 spawnlings.",
        "requirements": ["Tomb element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2272
    "In Focus": {
        "ap_id": 2272,
        "game_id": 49,
        "description": "Amplify a gem with 8 other gems.",
        "untrackable": True,
        "requirements": ["Amplifiers skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2273
    "In a Blink of an Eye": {
        "ap_id": 2273,
        "game_id": 530,
        "description": "Kill 100 monsters while time is frozen.",
        "details": "Kill 100 monsters during a single time-frozen window.",
        "requirements": ["Freeze skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2274
    "In for a Trait": {
        "ap_id": 2274,
        "game_id": 380,
        "description": "Activate a battle trait.",
        "details": "Activate at least one battle trait at the start of a battle.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2275
    "Inedible": {
        "ap_id": 2275,
        "game_id": 316,
        "description": "Poison 111 frozen monsters.",
        "details": "Poison 111 already-frozen monsters.",
        "requirements": ["Freeze skill", "Poison skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2276
    "Insane Investment": {
        "ap_id": 2276,
        "game_id": 279,
        "description": "Reach -20% decreased banishment cost with your orb.",
        "details": "Reach -20% banishment cost on the orb.",
        "untrackable": True,
        "requirements": ["Amplifiers skill"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2277
    "Instant Spawn": {
        "ap_id": 2277,
        "game_id": 528,
        "description": "Have a shadow spawn a monster while time is frozen.",
        "requirements": ["Ritual trait", "Shadow element", "Freeze skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2278
    "Ionized Air": {
        "ap_id": 2278,
        "game_id": 374,
        "description": "Have the Insulation trait set to level 6 or higher and win the battle.",
        "details": "Win a battle with the Insulation trait at level 6 or higher.",
        "requirements": ["Insulation trait"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2279
    "Is Anyone in There?": {
        "ap_id": 2279,
        "game_id": 87,
        "description": "Break a tomb open.",
        "requirements": ["Tomb element"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2280
    "Is This a Match-3 or What?": {
        "ap_id": 2280,
        "game_id": 416,
        "description": "Have 90 gems on the battlefield.",
        "details": "Have 90 gems on the field at once.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_power": 160,
        "required_effort": "Extreme",
    },
    # AP ID: 2281
    "It Has to Do": {
        "ap_id": 2281,
        "game_id": 571,
        "description": "Beat 50 waves using at most grade 2 gems.",
        "untrackable": True,
        "requirements": ["minWave: 50"],
        "reward": "skillPoints:3",
        "required_effort": "Major",
    },
    # AP ID: 2282
    "It Hurts!": {
        "ap_id": 2282,
        "game_id": 236,
        "description": "Spend 9.000 mana on banishment.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2283
    "It was Abandoned Anyway": {
        "ap_id": 2283,
        "game_id": 101,
        "description": "Destroy a dwelling.",
        "requirements": ["Abandoned Dwelling element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2284
    "It's Lagging Alright": {
        "ap_id": 2284,
        "game_id": 284,
        "description": "Have 1.200 monsters on the battlefield at the same time.",
        "details": "Have 1,200 monsters on the field at the same time.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_power": 300,
        "required_effort": "Extreme",
    },
    # AP ID: 2285
    "It's a Trap": {
        "ap_id": 2285,
        "game_id": 262,
        "description": "Don't let any monster touch your orb for 120 beaten waves.",
        "details": "Survive 120 consecutive waves without any monster reaching the orb.",
        "requirements": ["minWave: 120"],
        "reward": "skillPoints:1",
        "required_power": 160,
        "required_effort": "Major",
    },
    # AP ID: 2286
    "Itchy Sphere": {
        "ap_id": 2286,
        "game_id": 230,
        "description": "Deliver 3.600 banishments with your orb.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2287
    "Jewel Box": {
        "ap_id": 2287,
        "game_id": 54,
        "description": "Fill all inventory slots with gems.",
        "details": "Fill every inventory slot with gems.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2288
    "Jinx Blast": {
        "ap_id": 2288,
        "game_id": 182,
        "description": "Kill 30 whited out monsters with bolt.",
        "details": "Kill 30 whited-out monsters using Bolt-enhanced gems.",
        "requirements": ["Bolt skill", "Whiteout skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2289
    "Juggler": {
        "ap_id": 2289,
        "game_id": 86,
        "description": "Use demolition 7 times.",
        "details": "Use the Demolition spell 7 times in a single battle.",
        "requirements": ["Demolition skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2290
    "Just Breathe In": {
        "ap_id": 2290,
        "game_id": 524,
        "description": "Enhance a pure poison gem having random priority with beam.",
        "details": "Enhance a pure poison gem with Beam (random target priority).",
        "untrackable": True,
        "requirements": ["Beam skill", "Poison skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2291
    "Just Fire More at Them": {
        "ap_id": 2291,
        "game_id": 376,
        "description": "Have the Thick Air trait set to level 6 or higher and win the battle.",
        "details": "Win a battle with the Thick Air trait at level 6 or higher.",
        "requirements": ["Thick Air trait"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2292
    "Just Give Me That Mana": {
        "ap_id": 2292,
        "game_id": 588,
        "description": "Leech 7.200 mana from whited out monsters.",
        "details": "Leech 7,200 mana from whited-out monsters.",
        "requirements": ["Mana Leech skill", "Whiteout skill"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2293
    "Just Started": {
        "ap_id": 2293,
        "game_id": 6,
        "description": "Reach 10 battles won.",
        "details": "Cumulative across all battles: win 10 battles.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2294
    "Just Take My Mana!": {
        "ap_id": 2294,
        "game_id": 421,
        "description": "Spend 900.000 mana on banishment.",
        "details": "Spend a cumulative total of 900,000 mana on banishments.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2295
    "Keep Losing Keep Harvesting": {
        "ap_id": 2295,
        "game_id": 580,
        "description": "Deplete a mana shard while there is a shadow on the battlefield.",
        "details": "Deplete a mana shard while a shadow is on the field.",
        "requirements": ["Ritual trait", "Mana Shard element", "Shadow element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2296
    "Keepers": {
        "ap_id": 2296,
        "game_id": 234,
        "description": "Gain 800 mana from drops.",
        "details": "Gain 800 mana from drops in one battle.",
        "requirements": ["Apparition element", "Corrupted Mana Shard element", "Mana Shard element", "Drop Holder element"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2297
    "Keeping Low": {
        "ap_id": 2297,
        "game_id": 570,
        "description": "Beat 40 waves using at most grade 2 gems.",
        "details": "Beat 40 waves with only grade-2 or lower gems.",
        "untrackable": True,
        "requirements": ["minWave: 40"],
        "reward": "skillPoints:2",
        "required_effort": "Minor",
    },
    # AP ID: 2298
    "Killed So Many": {
        "ap_id": 2298,
        "game_id": 288,
        "description": "Gain 7.200 xp with kill chains.",
        "details": "Gain 7,200 xp from kill chains across all battles.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2299
    "Knowledge Seeker": {
        "ap_id": 2299,
        "game_id": 377,
        "description": "Open a wizard stash.",
        "details": "Open a wizard stash (built-in feature on stash maps).",
        "requirements": ["Wizard Stash element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2300
    "Lagging Already?": {
        "ap_id": 2300,
        "game_id": 212,
        "description": "Have 900 monsters on the battlefield at the same time.",
        "details": "Have 900 monsters on the field at the same time.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_power": 160,
        "required_effort": "Major",
    },
    # AP ID: 2301
    "Landing Spot": {
        "ap_id": 2301,
        "game_id": 583,
        "description": "Demolish 20 or more walls with falling spires.",
        "details": "Demolish 20+ walls using falling spires (the spire crash kills the wall).",
        "requirements": ["Ritual trait", "Spire element", "Wall element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2302
    "Laser Slicer": {
        "ap_id": 2302,
        "game_id": 296,
        "description": "Have 8 beam enhanced gems at the same time.",
        "requirements": ["Beam skill"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2303
    "Last Minute Mana": {
        "ap_id": 2303,
        "game_id": 451,
        "description": "Leech 500 mana from poisoned monsters.",
        "requirements": ["Mana Leech skill", "Poison skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2304
    "Legendary": {
        "ap_id": 2304,
        "game_id": 26,
        "description": "Create a gem with a raw minimum damage of 30.000 or higher.",
        "details": "Create a gem with at least 30,000 minimum raw damage.",
        "requirements": ["gemSkills: 1"],
        "reward": "skillPoints:2",
        "required_power": 160,
        "required_effort": "Extreme",
    },
    # AP ID: 2305
    "Let Them Hatch": {
        "ap_id": 2305,
        "game_id": 574,
        "description": "Don't crack any egg laid by a swarm queen.",
        "details": "Beat the battle without cracking any swarm queen egg yourself.",
        "requirements": ["Swarm Queen element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2306
    "Let it Go": {
        "ap_id": 2306,
        "game_id": 413,
        "description": "Leave an apparition alive.",
        "details": "End a battle with at least one apparition still alive.",
        "requirements": ["Ritual trait", "Apparition element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2307
    "Let's Have a Look": {
        "ap_id": 2307,
        "game_id": 390,
        "description": "Open a drop holder.",
        "details": "Open a drop holder.",
        "requirements": ["Drop Holder element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2308
    "Light My Path": {
        "ap_id": 2308,
        "game_id": 511,
        "description": "Have 70 fields lit in Journey mode.",
        "requirements": ["fieldToken: 70"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2309
    "Like a Necro": {
        "ap_id": 2309,
        "game_id": 198,
        "description": "Kill 25 monsters with frozen corpse explosion.",
        "details": "Kill 25 monsters using frozen-corpse explosions.",
        "requirements": ["Freeze skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2310
    "Limited Vision": {
        "ap_id": 2310,
        "game_id": 241,
        "description": "Gain 100 xp with Whiteout spell crowd hits.",
        "requirements": ["Whiteout skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2311
    "Liquid Explosive": {
        "ap_id": 2311,
        "game_id": 612,
        "description": "Kill 180 monsters with orblet explosions.",
        "untrackable": True,
        "requirements": ["Orb of Presence skill"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2312
    "Locked and Loaded": {
        "ap_id": 2312,
        "game_id": 596,
        "description": "Have 3 pylons charged up to 3 shots each.",
        "requirements": ["Pylons skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2313
    "Long Crawl": {
        "ap_id": 2313,
        "game_id": 37,
        "description": "Win a battle using only slowing gems.",
        "requirements": ["Slowing skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2314
    "Long Lasting": {
        "ap_id": 2314,
        "game_id": 283,
        "description": "Reach 500 poison kills through all the battles.",
        "requirements": ["Poison skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2315
    "Long Run": {
        "ap_id": 2315,
        "game_id": 281,
        "description": "Beat 360 waves.",
        "untrackable": True,
        "requirements": ["minWave: 360", "Endurance"],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2316
    "Longrunner": {
        "ap_id": 2316,
        "game_id": 515,
        "description": "Have 60 fields lit in Endurance mode.",
        "requirements": ["Endurance", "fieldToken: 60"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2317
    "Lost Signal": {
        "ap_id": 2317,
        "game_id": 405,
        "description": "Destroy 35 beacons.",
        "details": "Destroy 35 beacons in one battle.",
        "requirements": ["Beacon element"],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 2318
    "Lots of Crit Hits": {
        "ap_id": 2318,
        "game_id": 473,
        "description": "Have a pure critical hit gem with 2.000 hits.",
        "requirements": ["Critical Hit skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2319
    "Lots of Scratches": {
        "ap_id": 2319,
        "game_id": 155,
        "description": "Reach a kill chain of 300.",
        "requirements": ["minMonsters:300"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2320
    "Major Shutdown": {
        "ap_id": 2320,
        "game_id": 60,
        "description": "Destroy 3 monster nests.",
        "requirements": ["Monster Nest element"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2321
    "Mana Blinded": {
        "ap_id": 2321,
        "game_id": 585,
        "description": "Leech 900 mana from whited out monsters.",
        "details": "Leech 900 mana from whited-out monsters.",
        "requirements": ["Mana Leech skill", "Whiteout skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2322
    "Mana Cult": {
        "ap_id": 2322,
        "game_id": 450,
        "description": "Leech 6.500 mana from bleeding monsters.",
        "details": "Leech 6,500 mana from bleeding monsters.",
        "requirements": ["Bleeding skill", "Mana Leech skill"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2323
    "Mana First": {
        "ap_id": 2323,
        "game_id": 461,
        "description": "Deplete a shard when there are more than 300 swarmlings on the battlefield.",
        "details": "Deplete a mana shard while at least 300 swarmlings are on the field.",
        "requirements": ["Mana Shard element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2324
    "Mana Greedy": {
        "ap_id": 2324,
        "game_id": 598,
        "description": "Leech 1.800 mana with a grade 1 gem.",
        "untrackable": True,
        "requirements": ["Mana Leech skill", "minGemGrade: 1"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2325
    "Mana Hack": {
        "ap_id": 2325,
        "game_id": 285,
        "description": "Have 80.000 initial mana.",
        "details": "Have at least 80,000 starting mana.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_power": 600,
        "required_effort": "Extreme",
    },
    # AP ID: 2326
    "Mana Magnet": {
        "ap_id": 2326,
        "game_id": 30,
        "description": "Win a battle using only mana leeching gems.",
        "details": "Win a battle using only mana-leech gems.",
        "requirements": ["Mana Leech skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2327
    "Mana Salvation": {
        "ap_id": 2327,
        "game_id": 1,
        "description": "Salvage mana by destroying a gem.",
        "details": "Salvage mana by destroying a gem.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2328
    "Mana Singularity": {
        "ap_id": 2328,
        "game_id": 275,
        "description": "Reach mana pool level 20.",
        "details": "Reach mana pool level 20.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_power": 300,
        "required_effort": "Extreme",
    },
    # AP ID: 2329
    "Mana Tap": {
        "ap_id": 2329,
        "game_id": 106,
        "description": "Reach 10.000 mana harvested from shards through all the battles.",
        "details": "Cumulative across all battles: harvest 10,000 mana from shards.",
        "requirements": ["Mana Shard element"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2330
    "Mana Trader": {
        "ap_id": 2330,
        "game_id": 225,
        "description": "Salvage 8.000 mana from gems.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2331
    "Mana in a Bottle": {
        "ap_id": 2331,
        "game_id": 229,
        "description": "Have 40.000 initial mana.",
        "details": "Have at least 40,000 starting mana.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_power": 450,
        "required_effort": "Major",
    },
    # AP ID: 2332
    "Mana is All I Need": {
        "ap_id": 2332,
        "game_id": 563,
        "description": "Win a battle with no skill point spent and a battle trait maxed.",
        "details": "Win a battle with 0 skill points spent AND at least one battle trait at maximum level.",
        "requirements": ["BattleTraits: 1"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2333
    "Mana of the Dying": {
        "ap_id": 2333,
        "game_id": 453,
        "description": "Leech 2.300 mana from poisoned monsters.",
        "requirements": ["Mana Leech skill", "Poison skill"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2334
    "Marked Targets": {
        "ap_id": 2334,
        "game_id": 185,
        "description": "Reach 10.000 monsters with special properties killed through all the battles.",
        "details": "Cumulative across all battles: 10,000 kills on monsters with special properties.",
        "untrackable": True,
        "requirements": ["Endurance", "Possessed Monster element", "Twisted Monster element", "Marked Monster element", "minWave: 70"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2335
    "Marmalade": {
        "ap_id": 2335,
        "game_id": 483,
        "description": "Don't destroy any of the jars of wasps.",
        "requirements": ["Jar of Wasps element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2336
    "Mass Awakening": {
        "ap_id": 2336,
        "game_id": 318,
        "description": "Lure 2.500 swarmlings out of a sleeping hive.",
        "details": "Cumulative across all battles: lure 2,500 monsters from sleeping hives.",
        "requirements": ["Sleeping Hive element"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2337
    "Mastery": {
        "ap_id": 2337,
        "game_id": 564,
        "description": "Raise a skill to level 70.",
        "details": "Raise any single skill to level 70.",
        "requirements": ["Skills:1"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2338
    "Max Trap Max leech": {
        "ap_id": 2338,
        "game_id": 600,
        "description": "Leech 6.300 mana with a grade 1 gem.",
        "details": "Leech 6,300 mana with a grade-1 gem in a trap.",
        "untrackable": True,
        "requirements": ["Mana Leech skill", "minGemGrade: 1"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2339
    "Meet the Spartans": {
        "ap_id": 2339,
        "game_id": 210,
        "description": "Have 300 monsters on the battlefield at the same time.",
        "details": "Have 300 monsters on the field at the same time.",
        "requirements": ["minMonsters:300"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2340
    "Megalithic": {
        "ap_id": 2340,
        "game_id": 70,
        "description": "Reach 2.000 structures built through all the battles.",
        "details": "Cumulative across all battles: build 2,000 structures.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2341
    "Melting Armor": {
        "ap_id": 2341,
        "game_id": 568,
        "description": "Tear a total of 10.000 armor with wasp stings.",
        "requirements": ["Armor Tearing skill"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2342
    "Melting Pulse": {
        "ap_id": 2342,
        "game_id": 270,
        "description": "Hit 75 frozen monsters with shrines.",
        "untrackable": True,
        "requirements": ["Freeze skill", "Shrine element"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2343
    "Might Need it Later": {
        "ap_id": 2343,
        "game_id": 462,
        "description": "Enhance a gem in an amplifier.",
        "details": "Cast Bolt/Beam/Barrage on a gem inside an amplifier.",
        "requirements": ["Amplifiers skill", "enhancementSpells:1"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2344
    "Mighty": {
        "ap_id": 2344,
        "game_id": 25,
        "description": "Create a gem with a raw minimum damage of 3.000 or higher.",
        "requirements": ["gemSkills: 1"],
        "reward": "skillPoints:1",
        "required_power": 80,
        "required_effort": "Major",
    },
    # AP ID: 2345
    "Minefield": {
        "ap_id": 2345,
        "game_id": 129,
        "description": "Kill 300 monsters with gems in traps.",
        "details": "Kill 300 monsters with traps in one battle.",
        "requirements": ["Traps skill"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2346
    "Miniblasts": {
        "ap_id": 2346,
        "game_id": 565,
        "description": "Tear a total of 1.250 armor with wasp stings.",
        "details": "Tear 1,250 armor with wasp stings.",
        "requirements": ["Armor Tearing skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2347
    "Minor Detour": {
        "ap_id": 2347,
        "game_id": 79,
        "description": "Build 15 walls.",
        "details": "Build 15 walls in one battle.",
        "requirements": ["Wall element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2348
    "Mixing Up": {
        "ap_id": 2348,
        "game_id": 553,
        "description": "Beat 50 waves on max Swarmling and Giant domination traits.",
        "details": "Beat 50 waves in Endurance with Swarmling Domination AND Giant Domination both at max level.",
        "requirements": ["Swarmling Domination trait", "Giant Domination trait", "minWave: 50"],
        "reward": "skillPoints:2",
        "required_power": 160,
        "required_effort": "Extreme",
    },
    # AP ID: 2349
    "More Than Enough": {
        "ap_id": 2349,
        "game_id": 334,
        "description": "Summon 1.000 monsters by enraging waves.",
        "details": "Summon 1,000 monsters by enraging waves.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2350
    "More Wounds": {
        "ap_id": 2350,
        "game_id": 446,
        "description": "Kill 125 bleeding monsters with barrage.",
        "requirements": ["Barrage skill", "Bleeding skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2351
    "Morning March": {
        "ap_id": 2351,
        "game_id": 317,
        "description": "Lure 500 swarmlings out of a sleeping hive.",
        "requirements": ["Sleeping Hive element"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2352
    "Multifreeze": {
        "ap_id": 2352,
        "game_id": 442,
        "description": "Reach 5.000 strike spell hits through all the battles.",
        "requirements": ["Ice Shards skill", "Whiteout skill", "Freeze skill", "strikeSpells: 1"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2353
    "Multiline": {
        "ap_id": 2353,
        "game_id": 503,
        "description": "Have at least 5 different talisman properties.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2354
    "Multinerf": {
        "ap_id": 2354,
        "game_id": 539,
        "description": "Kill 1.600 monsters with prismatic gem wasps.",
        "details": "Kill 1,600 monsters with prismatic wasps.",
        "requirements": ["gemSkills: 6"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2355
    "Mythic Ancient Legendary": {
        "ap_id": 2355,
        "game_id": 277,
        "description": "Create a gem with a raw minimum damage of 300.000 or higher.",
        "details": "Create a gem with at least 300,000 minimum raw damage.",
        "requirements": ["gemSkills: 1"],
        "reward": "skillPoints:2",
        "required_power": 300,
        "required_effort": "Extreme",
    },
    # AP ID: 2356
    "Nature Takes Over": {
        "ap_id": 2356,
        "game_id": 399,
        "description": "Have no own buildings on the field at the end of the battle.",
        "details": "End a battle with no friendly buildings remaining (demolish them all yourself).",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2357
    "Near Death": {
        "ap_id": 2357,
        "game_id": 488,
        "description": "Suffer mana loss from a shadow projectile when under 200 mana.",
        "requirements": ["Shadow element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2358
    "Necrotrophic": {
        "ap_id": 2358,
        "game_id": 300,
        "description": "Reach 1.000 poison kills through all the battles.",
        "details": "Cumulative across all battles: 1,000 kills with poison.",
        "requirements": ["Poison skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2359
    "Need Lots of Them": {
        "ap_id": 2359,
        "game_id": 572,
        "description": "Beat 60 waves using at most grade 2 gems.",
        "untrackable": True,
        "requirements": ["minWave: 60"],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2360
    "Need More Rage": {
        "ap_id": 2360,
        "game_id": 117,
        "description": "Upgrade a gem in the enraging socket.",
        "details": "Upgrade a gem while it sits in an enraging socket.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2361
    "Needle Storm": {
        "ap_id": 2361,
        "game_id": 217,
        "description": "Deal 350 gem wasp stings to creatures.",
        "details": "Land 350 wasp stings on monsters.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2362
    "Nest Blaster": {
        "ap_id": 2362,
        "game_id": 93,
        "description": "Destroy 2 monster nests before wave 12.",
        "details": "Destroy 2 monster nests before wave 12 starts.",
        "requirements": ["Monster Nest element"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2363
    "Nest Buster": {
        "ap_id": 2363,
        "game_id": 92,
        "description": "Destroy 3 monster nests before wave 6.",
        "details": "Destroy 3 monster nests before wave 6 starts.",
        "requirements": ["Monster Nest element"],
        "reward": "skillPoints:3",
        "required_effort": "Minor",
    },
    # AP ID: 2364
    "No Armor Area": {
        "ap_id": 2364,
        "game_id": 22,
        "description": "Beat 90 waves using only armor tearing gems.",
        "details": "Beat 90 waves using only armor-tearing gems.",
        "requirements": ["Armor Tearing skill", "minWave: 90"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2365
    "No Beacon Zone": {
        "ap_id": 2365,
        "game_id": 303,
        "description": "Reach 200 beacons destroyed through all the battles.",
        "details": "Cumulative across all battles: destroy 200 beacons.",
        "requirements": ["Beacon element"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2366
    "No Honor Among Thieves": {
        "ap_id": 2366,
        "game_id": 497,
        "description": "Have a watchtower kill a specter.",
        "requirements": ["Ritual trait", "Specter element", "Watchtower element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2367
    "No Land for Swarmlings": {
        "ap_id": 2367,
        "game_id": 280,
        "description": "Kill 3.333 swarmlings.",
        "details": "Kill 3,333 swarmlings cumulatively.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2368
    "No More Rounds": {
        "ap_id": 2368,
        "game_id": 545,
        "description": "Kill 60 banished monsters with shrines.",
        "untrackable": True,
        "requirements": ["Shrine element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2369
    "No Need to Aim": {
        "ap_id": 2369,
        "game_id": 425,
        "description": "Have 4 barrage enhanced gems at the same time.",
        "requirements": ["Barrage skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2370
    "No Place to Hide": {
        "ap_id": 2370,
        "game_id": 292,
        "description": "Cast 25 strike spells.",
        "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2371
    "No Stone Unturned": {
        "ap_id": 2371,
        "game_id": 99,
        "description": "Open 5 drop holders.",
        "requirements": ["Drop Holder element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2372
    "No Time to Rest": {
        "ap_id": 2372,
        "game_id": 351,
        "description": "Have the Haste trait set to level 6 or higher and win the battle.",
        "requirements": ["Haste trait"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2373
    "No Time to Waste": {
        "ap_id": 2373,
        "game_id": 13,
        "description": "Reach 5.000 waves started early through all the battles.",
        "details": "Cumulative across all battles: 5,000 waves called early.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2374
    "No Use of Vitality": {
        "ap_id": 2374,
        "game_id": 152,
        "description": "Kill a monster having at least 20.000 hit points.",
        "requirements": ["minMonsterHP:20000"],
        "reward": "skillPoints:1",
        "required_power": 160,
        "required_effort": "Trivial",
    },
    # AP ID: 2375
    "No You Won't!": {
        "ap_id": 2375,
        "game_id": 522,
        "description": "Destroy a watchtower before it could fire.",
        "details": "Destroy a watchtower before it gets to fire.",
        "requirements": ["Bolt skill", "Watchtower element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2376
    "Not Chasing Shadows Anymore": {
        "ap_id": 2376,
        "game_id": 173,
        "description": "Kill 4 shadows.",
        "details": "Kill 4 shadows in one battle.",
        "requirements": ["Ritual trait", "Shadow element"],
        "reward": "skillPoints:3",
        "required_effort": "Major",
    },
    # AP ID: 2377
    "Not So Fast": {
        "ap_id": 2377,
        "game_id": 395,
        "description": "Freeze a specter.",
        "requirements": ["Freeze skill", "Ritual trait", "Specter element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2378
    "Not So Omni Anymore": {
        "ap_id": 2378,
        "game_id": 605,
        "description": "Destroy 10 omnibeacons.",
        "untrackable": True,
        "requirements": ["Beacon element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2379
    "Not Worth It": {
        "ap_id": 2379,
        "game_id": 108,
        "description": "Harvest 9.000 mana from a corrupted mana shard.",
        "details": "Harvest 9,000 mana from a corrupted mana shard.",
        "requirements": ["Corrupted Mana Shard element", "Mana Shard element"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2380
    "Nothing Prevails": {
        "ap_id": 2380,
        "game_id": 330,
        "description": "Reach 25.000 poison kills through all the battles.",
        "details": "Cumulative across all battles: 25,000 kills with poison.",
        "requirements": ["Poison skill"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2381
    "Nox Mist": {
        "ap_id": 2381,
        "game_id": 34,
        "description": "Win a battle using only poison gems.",
        "details": "Win a battle using only poison gems.",
        "requirements": ["Poison skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2382
    "Oh Ven": {
        "ap_id": 2382,
        "game_id": 209,
        "description": "Spread the poison",
        "details": "Reference: Ultima 'poison' spell. Spread poison to 90 monsters in a single battle. 90 monsters poisoned at the same time",
        "untrackable": True,
        "requirements": ["Poison skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2383
    "Ok Flier": {
        "ap_id": 2383,
        "game_id": 533,
        "description": "Kill 340 monsters while there are at least 2 wraiths in the air.",
        "details": "Kill 340 monsters while at least 2 wraiths are alive on the field.",
        "requirements": ["Ritual trait", "Wraith element"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2384
    "Omelette": {
        "ap_id": 2384,
        "game_id": 78,
        "description": "Reach 200 monster eggs cracked through all the battles.",
        "details": "Cumulative across all battles: crack 200 eggs.",
        "requirements": ["Swarm Queen element"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2385
    "Omnibomb": {
        "ap_id": 2385,
        "game_id": 578,
        "description": "Destroy a building and a non-monster creature with one gem bomb.",
        "details": "Destroy a building AND kill a non-monster with the same gem bomb.",
        "requirements": ["Ritual trait"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2386
    "On the Shoulders of Giants": {
        "ap_id": 2386,
        "game_id": 354,
        "description": "Have the Giant Domination trait set to level 6 or higher and win the battle.",
        "details": "Win a battle with the Giant Domination trait at level 6 or higher.",
        "requirements": ["Giant Domination trait"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2387
    "One Hit is All it Takes": {
        "ap_id": 2387,
        "game_id": 494,
        "description": "Kill a wraith with one hit.",
        "details": "Kill a wraith with a single hit.",
        "requirements": ["Ritual trait", "Wraith element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2388
    "One Less Problem": {
        "ap_id": 2388,
        "game_id": 581,
        "description": "Destroy a monster nest while there is a wraith on the battlefield.",
        "details": "Destroy a monster nest while a wraith is alive on the field.",
        "requirements": ["Ritual trait", "Monster Nest element", "Wraith element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2389
    "One by One": {
        "ap_id": 2389,
        "game_id": 406,
        "description": "Deliver 750 one hit kills.",
        "details": "Score 750 one-hit kills cumulatively.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 2390
    "Orange Wand": {
        "ap_id": 2390,
        "game_id": 384,
        "description": "Reach wizard level 40.",
        "details": "Reach wizard level 40.",
        "requirements": ["wizardLevel: 40"],
        "reward": "skillPoints:1",
        "required_power": 30,
        "required_effort": "Minor",
    },
    # AP ID: 2391
    "Ouch!": {
        "ap_id": 2391,
        "game_id": 235,
        "description": "Spend 900 mana on banishment.",
        "details": "Spend a cumulative total of 900 mana on banishments in one battle.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2392
    "Out of Misery": {
        "ap_id": 2392,
        "game_id": 194,
        "description": "Kill a monster that is whited out, poisoned, frozen and slowed at the same time.",
        "requirements": ["Freeze skill", "Poison skill", "Slowing skill", "Whiteout skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2393
    "Out of Nowhere": {
        "ap_id": 2393,
        "game_id": 160,
        "description": "Kill a whited out possessed monster with bolt.",
        "details": "Kill a whited-out possessed monster with a Bolt shot.",
        "untrackable": True,
        "requirements": ["Bolt skill", "Whiteout skill", "Possessed Monster element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2394
    "Outwhited": {
        "ap_id": 2394,
        "game_id": 310,
        "description": "Gain 4.700 xp with Whiteout spell crowd hits.",
        "details": "Gain 4,700 xp from Whiteout crowd hits in one battle.",
        "requirements": ["Whiteout skill"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2395
    "Overheated": {
        "ap_id": 2395,
        "game_id": 195,
        "description": "Kill a giant with beam shot.",
        "details": "Kill a giant with a single Beam shot.",
        "requirements": ["Beam skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2396
    "Overpecked": {
        "ap_id": 2396,
        "game_id": 214,
        "description": "Deal 100 gem wasp stings to the same monster.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2397
    "Painful Leech": {
        "ap_id": 2397,
        "game_id": 449,
        "description": "Leech 3.200 mana from bleeding monsters.",
        "requirements": ["Bleeding skill", "Mana Leech skill"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2398
    "Paranormal Paragon": {
        "ap_id": 2398,
        "game_id": 141,
        "description": "Reach 500 non-monsters killed through all the battles.",
        "details": "Cumulative across all battles: 500 non-monster kills.",
        "requirements": ["Ritual trait"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2399
    "Pat on the Back": {
        "ap_id": 2399,
        "game_id": 48,
        "description": "Amplify a gem.",
        "details": "Place a gem inside an amplifier (i.e. amplify a gem at least once).",
        "requirements": ["Amplifiers skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2400
    "Path of Splats": {
        "ap_id": 2400,
        "game_id": 428,
        "description": "Kill 400 monsters.",
        "details": "Kill 400 monsters in one battle.",
        "requirements": ["minMonsters:400"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2401
    "Peek Into The Abyss": {
        "ap_id": 2401,
        "game_id": 544,
        "description": "Kill a monster with all battle traits set to the highest level.",
        "details": "Win a battle with every battle trait at its maximum level.",
        "requirements": ["Adaptive Carapace trait", "Dark Masonry trait", "Swarmling Domination trait", "Overcrowd trait", "Corrupted Banishment trait", "Awakening trait", "Insulation trait", "Hatred trait", "Swarmling Parasites trait", "Haste trait", "Thick Air trait", "Vital Link trait", "Giant Domination trait", "Strength in Numbers trait", "Ritual trait"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2402
    "Pest Control": {
        "ap_id": 2402,
        "game_id": 140,
        "description": "Kill 333 swarmlings.",
        "details": "Kill 333 swarmlings in one battle.",
        "requirements": ["minSwarmlings:333"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2403
    "Plentiful": {
        "ap_id": 2403,
        "game_id": 357,
        "description": "Have 1.000 shadow cores at the start of the battle.",
        "requirements": ["shadowCore: 1000"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2404
    "Pointed Pain": {
        "ap_id": 2404,
        "game_id": 216,
        "description": "Deal 50 gem wasp stings to creatures.",
        "details": "Land 50 wasp stings on monsters in one battle.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2405
    "Popped": {
        "ap_id": 2405,
        "game_id": 628,
        "description": "Kill at least 30 gatekeeper fangs.",
        "requirements": ["Gatekeeper element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2406
    "Popped Eggs": {
        "ap_id": 2406,
        "game_id": 470,
        "description": "Kill a swarm queen with a bolt.",
        "requirements": ["Bolt skill", "Swarm Queen element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2407
    "Popping Lights": {
        "ap_id": 2407,
        "game_id": 95,
        "description": "Destroy 5 beacons.",
        "details": "Destroy 5 beacons in one battle.",
        "requirements": ["Beacon element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2408
    "Power Exchange": {
        "ap_id": 2408,
        "game_id": 77,
        "description": "Build 25 amplifiers.",
        "untrackable": True,
        "requirements": ["Amplifiers skill"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2409
    "Power Flow": {
        "ap_id": 2409,
        "game_id": 76,
        "description": "Build 15 amplifiers.",
        "untrackable": True,
        "requirements": ["Amplifiers skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2410
    "Power Node": {
        "ap_id": 2410,
        "game_id": 267,
        "description": "Activate the same shrine 5 times.",
        "details": "Activate the same shrine 5 times in one battle.",
        "untrackable": True,
        "requirements": ["Shrine element"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2411
    "Power Overwhelming": {
        "ap_id": 2411,
        "game_id": 228,
        "description": "Reach mana pool level 15.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_power": 160,
        "required_effort": "Major",
    },
    # AP ID: 2412
    "Power Sharing": {
        "ap_id": 2412,
        "game_id": 75,
        "description": "Build 5 amplifiers.",
        "details": "Build 5 amplifiers in one battle.",
        "untrackable": True,
        "requirements": ["Amplifiers skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2413
    "Powerful": {
        "ap_id": 2413,
        "game_id": 24,
        "description": "Create a gem with a raw minimum damage of 300 or higher.",
        "details": "Create a gem with at least 300 minimum raw damage.",
        "requirements": ["gemSkills: 1"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2414
    "Precious": {
        "ap_id": 2414,
        "game_id": 111,
        "description": "Get a gem from a drop holder.",
        "details": "Get a free gem from a drop holder.",
        "requirements": ["Drop Holder element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2415
    "Prismatic": {
        "ap_id": 2415,
        "game_id": 29,
        "description": "Create a gem of 6 components.",
        "details": "Combine a 6-component gem.",
        "requirements": ["gemSkills: 6"],
        "reward": "skillPoints:2",
        "required_effort": "Minor",
    },
    # AP ID: 2416
    "Prismatic Takeaway": {
        "ap_id": 2416,
        "game_id": 472,
        "description": "Have a specter steal a gem of 6 components.",
        "details": "Let a specter steal a 6-component gem (then kill it or end the battle).",
        "requirements": ["Specter element", "gemSkills: 6"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2417
    "Punching Deep": {
        "ap_id": 2417,
        "game_id": 566,
        "description": "Tear a total of 2.500 armor with wasp stings.",
        "details": "Tear 2,500 armor with wasp stings.",
        "requirements": ["Armor Tearing skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2418
    "Puncture Therapy": {
        "ap_id": 2418,
        "game_id": 247,
        "description": "Deal 950 gem wasp stings to creatures.",
        "details": "Land 950 wasp stings on monsters.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2419
    "Punctured Texture": {
        "ap_id": 2419,
        "game_id": 221,
        "description": "Deal 5.000 gem wasp stings to buildings.",
        "details": "Land 5,000 wasp stings on enemy buildings (cross-battle).",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2420
    "Puncturing Shots": {
        "ap_id": 2420,
        "game_id": 123,
        "description": "Deliver 75 one hit kills.",
        "details": "Score 75 one-hit kills in one battle.",
        "requirements": ["minMonsters:75"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2421
    "Purged": {
        "ap_id": 2421,
        "game_id": 146,
        "description": "Kill 179 marked monsters.",
        "untrackable": True,
        "requirements": ["Marked Monster element", "minWave: 70"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2422
    "Purist": {
        "ap_id": 2422,
        "game_id": 308,
        "description": "Beat 120 waves and don't use any strike or gem enhancement spells.",
        "details": "Beat 120 waves without casting any strike OR enhancement spells.",
        "untrackable": True,
        "requirements": ["minWave: 120"],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 2423
    "Purple Wand": {
        "ap_id": 2423,
        "game_id": 387,
        "description": "Reach wizard level 200.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2424
    "Put Those Down Now!": {
        "ap_id": 2424,
        "game_id": 595,
        "description": "Have 10 orblets carried by monsters at the same time.",
        "details": "Have 10 orblets carried by monsters at once.",
        "requirements": ["Orb of Presence skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2425
    "Puzzling Bunch": {
        "ap_id": 2425,
        "game_id": 632,
        "description": "Add 16 talisman fragments to your shape collection.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2426
    "Pylons of Destruction": {
        "ap_id": 2426,
        "game_id": 231,
        "description": "Reach 5.000 pylon kills through all the battles.",
        "details": "Cumulative across all battles: kill 5,000 monsters with pylons.",
        "requirements": ["Pylons skill"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2427
    "Quadpierced": {
        "ap_id": 2427,
        "game_id": 590,
        "description": "Cast 4 ice shards on the same monster.",
        "requirements": ["Ice Shards skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2428
    "Quick Circle": {
        "ap_id": 2428,
        "game_id": 84,
        "description": "Create a grade 12 gem before wave 12.",
        "details": "Create a grade-12 gem before wave 12 starts.",
        "untrackable": True,
        "requirements": ["minGemGrade: 12"],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2429
    "Quicksave": {
        "ap_id": 2429,
        "game_id": 603,
        "description": "Instantly drop a gem to your inventory.",
        "details": "Drop a gem directly into your inventory using the instant-pickup hotkey.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2430
    "Quite a List": {
        "ap_id": 2430,
        "game_id": 505,
        "description": "Have at least 15 different talisman properties.",
        "details": "Talisman must hold 15 different distinct properties at once.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2431
    "Rage Control": {
        "ap_id": 2431,
        "game_id": 481,
        "description": "Kill 400 enraged swarmlings with barrage.",
        "requirements": ["Barrage skill", "minSwarmlings:400"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2432
    "Rageout": {
        "ap_id": 2432,
        "game_id": 336,
        "description": "Enrage 30 waves.",
        "requirements": ["minWave: 30"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2433
    "Rageroom": {
        "ap_id": 2433,
        "game_id": 493,
        "description": "Build 100 walls and start 100 enraged waves.",
        "details": "In one battle: build 100 walls AND start 100 enraged waves.",
        "untrackable": True,
        "requirements": ["Wall element", "minWave: 100"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2434
    "Raging Habit": {
        "ap_id": 2434,
        "game_id": 337,
        "description": "Enrage 80 waves.",
        "details": "Manually enrage 80 waves cumulatively across all battles (or in one battle, depending on stat).",
        "requirements": ["minWave: 80"],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 2435
    "Rainbow Strike": {
        "ap_id": 2435,
        "game_id": 538,
        "description": "Kill 900 monsters with prismatic gem wasps.",
        "details": "Kill 900 monsters with prismatic (6-component) wasps.",
        "requirements": ["gemSkills: 6"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2436
    "Raindrop": {
        "ap_id": 2436,
        "game_id": 391,
        "description": "Drop 18 gem bombs while it's raining.",
        "details": "Throw 18 gem bombs during rain weather.",
        "requirements": ["Rain element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2437
    "Razor Path": {
        "ap_id": 2437,
        "game_id": 74,
        "description": "Build 60 traps.",
        "details": "Build 60 traps in one battle.",
        "requirements": ["Traps skill"],
        "reward": "skillPoints:1",
        "required_power": 80,
        "required_effort": "Extreme",
    },
    # AP ID: 2438
    "Red Orange": {
        "ap_id": 2438,
        "game_id": 447,
        "description": "Leech 700 mana from bleeding monsters.",
        "details": "Leech 700 mana from bleeding monsters.",
        "requirements": ["Bleeding skill", "Mana Leech skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2439
    "Red Wand": {
        "ap_id": 2439,
        "game_id": 389,
        "description": "Reach wizard level 500.",
        "details": "Reach wizard level 500.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2440
    "Refrost": {
        "ap_id": 2440,
        "game_id": 314,
        "description": "Freeze 111 frozen monsters.",
        "details": "Freeze 111 already-frozen monsters (re-freeze).",
        "requirements": ["Freeze skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2441
    "Regaining Knowledge": {
        "ap_id": 2441,
        "game_id": 367,
        "description": "Acquire 5 skills.",
        "details": "Acquire any 5 skills.",
        "requirements": ["Skills:5"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2442
    "Renzokuken": {
        "ap_id": 2442,
        "game_id": 618,
        "description": "Break your frozen time gem bombing limits",
        "details": "Reference: FF8 Squall limit break. Throw N gem bombs while time is frozen by Whiteout.",
        "untrackable": True,
        "requirements": ["Freeze skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2443
    "Resourceful": {
        "ap_id": 2443,
        "game_id": 105,
        "description": "Reach 5.000 mana harvested from shards through all the battles.",
        "requirements": ["Mana Shard element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2444
    "Restless": {
        "ap_id": 2444,
        "game_id": 324,
        "description": "Call 35 waves early.",
        "details": "Call 35 waves early in one battle.",
        "requirements": ["minWave: 35"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2445
    "Return of Investment": {
        "ap_id": 2445,
        "game_id": 597,
        "description": "Leech 900 mana with a grade 1 gem.",
        "untrackable": True,
        "requirements": ["Mana Leech skill", "minGemGrade: 1"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2446
    "Riding the Waves": {
        "ap_id": 2446,
        "game_id": 15,
        "description": "Reach 1.000 waves beaten through all the battles.",
        "details": "Cumulative across all battles: beat 1,000 waves.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2447
    "Rising Tide": {
        "ap_id": 2447,
        "game_id": 584,
        "description": "Banish 150 monsters while there are 2 or more wraiths on the battlefield.",
        "details": "Banish 150 monsters with at least 2 wraiths alive.",
        "untrackable": True,
        "requirements": ["Ritual trait"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2448
    "Roof Knocking": {
        "ap_id": 2448,
        "game_id": 218,
        "description": "Deal 20 gem wasp stings to buildings.",
        "requirements": ["Monster Nest element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2449
    "Root Canal": {
        "ap_id": 2449,
        "game_id": 91,
        "description": "Destroy 2 monster nests.",
        "requirements": ["Monster Nest element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2450
    "Rooting From Afar": {
        "ap_id": 2450,
        "game_id": 625,
        "description": "Kill a gatekeeper fang with a barrage shell.",
        "details": "Kill a gatekeeper fang using a Barrage shell hit.",
        "requirements": ["Barrage skill", "Gatekeeper element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2451
    "Rotten Aura": {
        "ap_id": 2451,
        "game_id": 452,
        "description": "Leech 1.100 mana from poisoned monsters.",
        "requirements": ["Mana Leech skill", "Poison skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2452
    "Rough Path": {
        "ap_id": 2452,
        "game_id": 128,
        "description": "Kill 60 monsters with gems in traps.",
        "requirements": ["Traps skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2453
    "Round Cut": {
        "ap_id": 2453,
        "game_id": 46,
        "description": "Create a grade 12 gem.",
        "untrackable": True,
        "requirements": ["minGemGrade: 12"],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2454
    "Round Cut Plus": {
        "ap_id": 2454,
        "game_id": 47,
        "description": "Create a grade 16 gem.",
        "details": "Create a grade-16 gem.",
        "untrackable": True,
        "requirements": ["minGemGrade: 16"],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2455
    "Route Planning": {
        "ap_id": 2455,
        "game_id": 4,
        "description": "Destroy 5 barricades.",
        "requirements": ["Barricade element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2456
    "Rugged Defense": {
        "ap_id": 2456,
        "game_id": 340,
        "description": "Have 16 bolt enhanced gems at the same time.",
        "details": "Have 16 bolt-enhanced gems active at once.",
        "requirements": ["Bolt skill"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2457
    "Ruined Ghost Town": {
        "ap_id": 2457,
        "game_id": 102,
        "description": "Destroy 5 dwellings.",
        "requirements": ["Abandoned Dwelling element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2458
    "Safe and Secure": {
        "ap_id": 2458,
        "game_id": 259,
        "description": "Strengthen your orb with 7 gems in amplifiers.",
        "details": "Have 7 gems in amplifiers connected to the orb.",
        "untrackable": True,
        "requirements": ["Amplifiers skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2459
    "Salvation": {
        "ap_id": 2459,
        "game_id": 271,
        "description": "Hit 150 whited out monsters with shrines.",
        "details": "Hit 150 whited-out monsters with shrines.",
        "untrackable": True,
        "requirements": ["Whiteout skill", "Shrine element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2460
    "Scare Tactics": {
        "ap_id": 2460,
        "game_id": 291,
        "description": "Cast 5 strike spells.",
        "details": "Cast 5 strike spells in one battle.",
        "requirements": ["strikeSpells:1"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2461
    "Scour You All": {
        "ap_id": 2461,
        "game_id": 548,
        "description": "Kill 660 banished monsters with shrines.",
        "details": "Kill 660 banished monsters with shrines.",
        "untrackable": True,
        "requirements": ["Shrine element"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2462
    "Second Thoughts": {
        "ap_id": 2462,
        "game_id": 401,
        "description": "Add a different enhancement on an enhanced gem.",
        "details": "Cast a different enhancement spell on an already-enhanced gem.",
        "requirements": ["enhancementSpells:2"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2463
    "Seen Battle": {
        "ap_id": 2463,
        "game_id": 52,
        "description": "Have a grade 1 gem with 500 hits.",
        "details": "Reach 500 hits on a grade-1 gem.",
        "untrackable": True,
        "requirements": ["minGemGrade: 1"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2464
    "Settlement": {
        "ap_id": 2464,
        "game_id": 67,
        "description": "Build 15 towers.",
        "details": "Build 15 towers in one battle.",
        "requirements": ["Tower element"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2465
    "Shaken Ice": {
        "ap_id": 2465,
        "game_id": 329,
        "description": "Hit 475 frozen monsters with shrines.",
        "details": "Hit 475 frozen monsters with shrines.",
        "untrackable": True,
        "requirements": ["Freeze skill", "Shrine element"],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2466
    "Shapeshifter": {
        "ap_id": 2466,
        "game_id": 634,
        "description": "Complete your talisman fragment shape collection.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2467
    "Shard Siphon": {
        "ap_id": 2467,
        "game_id": 107,
        "description": "Reach 20.000 mana harvested from shards through all the battles.",
        "details": "Cumulative across all battles: harvest 20,000 mana from shards.",
        "requirements": ["Mana Shard element"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2468
    "Shardalot": {
        "ap_id": 2468,
        "game_id": 591,
        "description": "Cast 6 ice shards on the same monster.",
        "requirements": ["Ice Shards skill"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2469
    "Sharp Shot": {
        "ap_id": 2469,
        "game_id": 576,
        "description": "Kill a shadow with a shot fired by a gem having at least 5.000 hits.",
        "details": "Kill a shadow using a gem that has hit at least 5,000 times.",
        "requirements": [["Shadow element", "Ritual trait"]],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2470
    "Sharpened": {
        "ap_id": 2470,
        "game_id": 400,
        "description": "Enhance a gem in a trap.",
        "details": "Cast Bolt/Beam/Barrage on a gem that's inside a trap.",
        "requirements": ["Traps skill", "enhancementSpells:1"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2471
    "Shatter Them All": {
        "ap_id": 2471,
        "game_id": 306,
        "description": "Reach 1.000 beacons destroyed through all the battles.",
        "details": "Cumulative across all battles: destroy 1,000 beacons.",
        "requirements": ["Beacon element"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2472
    "Shattered Orb": {
        "ap_id": 2472,
        "game_id": 319,
        "description": "Lose a battle.",
        "details": "Lose a battle (orb destroyed).",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2473
    "Shattered Waves": {
        "ap_id": 2473,
        "game_id": 273,
        "description": "Hit 225 frozen monsters with shrines.",
        "details": "Hit 225 frozen monsters with shrines.",
        "untrackable": True,
        "requirements": ["Freeze skill", "Shrine element", "minMonsters:225"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2474
    "Shattering": {
        "ap_id": 2474,
        "game_id": 179,
        "description": "Kill 90 frozen monsters with bolt.",
        "requirements": ["Bolt skill", "Freeze skill", "minMonsters:90"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2475
    "Shavings All Around": {
        "ap_id": 2475,
        "game_id": 38,
        "description": "Win a battle using only armor tearing gems.",
        "requirements": ["Armor Tearing skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2476
    "Shell Shock": {
        "ap_id": 2476,
        "game_id": 426,
        "description": "Have 8 barrage enhanced gems at the same time.",
        "requirements": ["Barrage skill"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2477
    "Shieldbreaker": {
        "ap_id": 2477,
        "game_id": 468,
        "description": "Destroy 3 shield beacons.",
        "requirements": ["Beacon element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2478
    "Shooting Where it Hurts": {
        "ap_id": 2478,
        "game_id": 32,
        "description": "Beat 90 waves using only critical hit gems.",
        "details": "Beat 90 waves using only critical-hit gems.",
        "requirements": ["Critical Hit skill", "minWave: 90"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2479
    "Short Tempered": {
        "ap_id": 2479,
        "game_id": 323,
        "description": "Call 5 waves early.",
        "details": "Call 5 waves early in one battle.",
        "requirements": ["minWave: 5"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2480
    "Shovel Swing": {
        "ap_id": 2480,
        "game_id": 269,
        "description": "Hit 15 frozen monsters with shrines.",
        "requirements": ["Freeze skill", "Shrine element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2481
    "Shred Some Armor": {
        "ap_id": 2481,
        "game_id": 475,
        "description": "Have a pure armor tearing gem with 3.000 hits.",
        "details": "Reach 3,000 hits on a pure armor-tearing gem.",
        "requirements": ["Armor Tearing skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2482
    "Shrinemaster": {
        "ap_id": 2482,
        "game_id": 433,
        "description": "Reach 20.000 shrine kills through all the battles.",
        "details": "Cumulative across all battles: kill 20,000 monsters with shrines.",
        "untrackable": True,
        "requirements": ["Shrine element"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2483
    "Sigil": {
        "ap_id": 2483,
        "game_id": 361,
        "description": "Fill all the sockets in your talisman with fragments upgraded to level 5 or higher.",
        "details": "All talisman sockets filled, every fragment upgraded to level 5+.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2484
    "Size Matters": {
        "ap_id": 2484,
        "game_id": 554,
        "description": "Beat 100 waves on max Swarmling and Giant domination traits.",
        "requirements": ["Swarmling Domination trait", "Giant Domination trait", "minWave: 100"],
        "reward": "skillPoints:2",
        "required_power": 300,
        "required_effort": "Extreme",
    },
    # AP ID: 2485
    "Skillful": {
        "ap_id": 2485,
        "game_id": 368,
        "description": "Acquire and raise all skills to level 5 or above.",
        "details": "Acquire all skills and raise each to level 5+.",
        "requirements": ["Skills:24"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2486
    "Skylark": {
        "ap_id": 2486,
        "game_id": 460,
        "description": "Call every wave early in a battle.",
        "details": "Call every wave early in a single battle (no waves arrive on their own timer).",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2487
    "Sliced Ice": {
        "ap_id": 2487,
        "game_id": 244,
        "description": "Gain 1.800 xp with Ice Shards spell crowd hits.",
        "details": "Gain 1,800 xp from Ice Shards crowd hits.",
        "requirements": ["Ice Shards skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2488
    "Slime Block": {
        "ap_id": 2488,
        "game_id": 623,
        "description": "Nine slimeballs is all it takes",
        "details": "Reference: Minecraft. Have 9 specific items (slimeball-equivalent — undocumented).",
        "untrackable": True,
        "requirements": ["minMonsterHP:20000"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2489
    "Slow Creep": {
        "ap_id": 2489,
        "game_id": 315,
        "description": "Poison 130 whited out monsters.",
        "requirements": ["Poison skill", "Whiteout skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2490
    "Slow Drain": {
        "ap_id": 2490,
        "game_id": 414,
        "description": "Deal 10.000 poison damage to a monster.",
        "requirements": ["Poison skill"],
        "reward": "skillPoints:2",
        "required_power": 30,
        "required_effort": "Trivial",
    },
    # AP ID: 2491
    "Slow Motion": {
        "ap_id": 2491,
        "game_id": 525,
        "description": "Enhance a pure slowing gem having random priority with beam.",
        "requirements": ["Beam skill", "Slowing skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2492
    "Slowly but Surely": {
        "ap_id": 2492,
        "game_id": 19,
        "description": "Beat 90 waves using only slowing gems.",
        "details": "Beat 90 waves using only slowing gems.",
        "requirements": ["Slowing skill", "minWave: 90"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2493
    "Smoke in the Sky": {
        "ap_id": 2493,
        "game_id": 137,
        "description": "Reach 20 non-monsters killed through all the battles.",
        "requirements": ["Ritual trait"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2494
    "Snatchers": {
        "ap_id": 2494,
        "game_id": 287,
        "description": "Gain 3.200 mana from drops.",
        "details": "Gain 3,200 mana from drops in one battle.",
        "requirements": ["Drop Holder element"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2495
    "Snow Blower": {
        "ap_id": 2495,
        "game_id": 178,
        "description": "Kill 20 frozen monsters with barrage.",
        "requirements": ["Barrage skill", "Freeze skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2496
    "Snow Dust": {
        "ap_id": 2496,
        "game_id": 193,
        "description": "Kill 95 frozen monsters while it's snowing.",
        "details": "Kill 95 frozen monsters during snow weather.",
        "requirements": ["Freeze skill", "Snow element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2497
    "Snowball": {
        "ap_id": 2497,
        "game_id": 392,
        "description": "Drop 27 gem bombs while it's snowing.",
        "details": "Throw 27 gem bombs during snow weather.",
        "requirements": ["Snow element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2498
    "Snowdust Blindness": {
        "ap_id": 2498,
        "game_id": 133,
        "description": "Gain 2.300 xp with Whiteout spell crowd hits.",
        "details": "Gain 2,300 xp from Whiteout crowd hits.",
        "requirements": ["Whiteout skill"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2499
    "So Attached": {
        "ap_id": 2499,
        "game_id": 557,
        "description": "Win a Trial battle without losing any orblets.",
        "requirements": ["Trial"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2500
    "So Early": {
        "ap_id": 2500,
        "game_id": 11,
        "description": "Reach 1.000 waves started early through all the battles.",
        "details": "Cumulative across all battles: 1,000 waves called early.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2501
    "So Enduring": {
        "ap_id": 2501,
        "game_id": 369,
        "description": "Have the Adaptive Carapace trait set to level 6 or higher and win the battle.",
        "details": "Win a battle with the Adaptive Carapace trait at level 6 or higher.",
        "requirements": ["Adaptive Carapace trait"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2502
    "Socketed Rage": {
        "ap_id": 2502,
        "game_id": 327,
        "description": "Enrage a wave.",
        "details": "Enrage 1 wave.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2503
    "Something Special": {
        "ap_id": 2503,
        "game_id": 176,
        "description": "Reach 2.000 monsters with special properties killed through all the battles.",
        "untrackable": True,
        "requirements": ["Endurance", ["Possessed Monster element", "Twisted Monster element", "Marked Monster element"], "minWave: 70"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2504
    "Sparse Snares": {
        "ap_id": 2504,
        "game_id": 71,
        "description": "Build 10 traps.",
        "details": "Build 10 traps in one battle.",
        "requirements": ["Traps skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2505
    "Special Purpose": {
        "ap_id": 2505,
        "game_id": 402,
        "description": "Change the target priority of a gem.",
        "details": "Change a gem's target priority by clicking it.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2506
    "Spectrin Tetramer": {
        "ap_id": 2506,
        "game_id": 379,
        "description": "Have the Vital Link trait set to level 6 or higher and win the battle.",
        "details": "Win a battle with the Vital Link trait at level 6 or higher.",
        "requirements": ["Vital Link trait"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2507
    "Spitting Darkness": {
        "ap_id": 2507,
        "game_id": 626,
        "description": "Leave a gatekeeper fang alive until it can launch 100 projectiles.",
        "details": "Leave a gatekeeper alive long enough that it launches 100 projectiles.",
        "requirements": ["Gatekeeper element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2508
    "Splash Swim Splash": {
        "ap_id": 2508,
        "game_id": 615,
        "description": "Full of oxygen",
        "details": "Pokemon Magikarp reference. In-game trigger (IngameAchiChecker6.as case 615): fill all 9 inventory slots with pure Slowing gems. Inventory state isn't reliably gateable by AP logic, so kept untrackable.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2509
    "Starter Pack": {
        "ap_id": 2509,
        "game_id": 631,
        "description": "Add 8 talisman fragments to your shape collection.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2510
    "Stash No More": {
        "ap_id": 2510,
        "game_id": 378,
        "description": "Destroy a previously opened wizard stash.",
        "details": "Destroy an opened wizard stash in the same battle you opened it.",
        "requirements": ["Wizard Stash element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2511
    "Stay Some More": {
        "ap_id": 2511,
        "game_id": 531,
        "description": "Cast freeze on an apparition 3 times.",
        "requirements": ["Freeze skill", "Ritual trait"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2512
    "Still Alive": {
        "ap_id": 2512,
        "game_id": 136,
        "description": "Beat 60 waves.",
        "requirements": ["minWave: 60"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2513
    "Still Chill": {
        "ap_id": 2513,
        "game_id": 151,
        "description": "Gain 1.500 xp with Freeze spell crowd hits.",
        "details": "Gain 1,500 xp from Freeze crowd hits.",
        "requirements": ["Freeze skill"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2514
    "Still Lit": {
        "ap_id": 2514,
        "game_id": 97,
        "description": "Have 15 or more beacons standing at the end of the battle.",
        "requirements": ["Dark Masonry trait"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2515
    "Still No Match": {
        "ap_id": 2515,
        "game_id": 604,
        "description": "Destroy an omnibeacon.",
        "untrackable": True,
        "requirements": ["Beacon element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2516
    "Sting Stack": {
        "ap_id": 2516,
        "game_id": 220,
        "description": "Deal 1.000 gem wasp stings to buildings.",
        "details": "Land 1,000 wasp stings on enemy buildings.",
        "requirements": ["Monster Nest element"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2517
    "Stinging Sphere": {
        "ap_id": 2517,
        "game_id": 254,
        "description": "Deliver 100 banishments with your orb.",
        "details": "Banish 100 monsters using the orb (orb gem with banishment effect).",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2518
    "Stingy Cloud": {
        "ap_id": 2518,
        "game_id": 149,
        "description": "Reach 5.000 gem wasp kills through all the battles.",
        "details": "Cumulative across all battles: 5,000 wasp kills.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2519
    "Stingy Downfall": {
        "ap_id": 2519,
        "game_id": 594,
        "description": "Deal 400 wasp stings to a spire.",
        "details": "Land 400 wasp stings on a single spire.",
        "requirements": ["Ritual trait", "Spire element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2520
    "Stirring Up the Nest": {
        "ap_id": 2520,
        "game_id": 203,
        "description": "Deliver gem bomb and wasp kills only.",
        "details": "In one battle, all kills come from gem bombs and wasps only.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2521
    "Stockpile": {
        "ap_id": 2521,
        "game_id": 362,
        "description": "Have 30 fragments in your talisman inventory.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2522
    "Stolen Shine": {
        "ap_id": 2522,
        "game_id": 586,
        "description": "Leech 2.700 mana from whited out monsters.",
        "requirements": ["Mana Leech skill", "Whiteout skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2523
    "Stone Monument": {
        "ap_id": 2523,
        "game_id": 282,
        "description": "Build 240 walls.",
        "requirements": ["Wall element"],
        "reward": "skillPoints:1",
        "required_power": 80,
        "required_effort": "Extreme",
    },
    # AP ID: 2524
    "Stones to Dust": {
        "ap_id": 2524,
        "game_id": 85,
        "description": "Demolish one of your structures.",
        "details": "Demolish your own structure once.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2525
    "Stormbringer": {
        "ap_id": 2525,
        "game_id": 435,
        "description": "Reach 1.000 strike spells cast through all the battles.",
        "requirements": ["strikeSpells:1"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2526
    "Stormed Beacons": {
        "ap_id": 2526,
        "game_id": 404,
        "description": "Destroy 15 beacons.",
        "details": "Destroy 15 beacons in one battle.",
        "requirements": ["Dark Masonry trait"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2527
    "Strike Anywhere": {
        "ap_id": 2527,
        "game_id": 290,
        "description": "Cast a strike spell.",
        "details": "Cast 1 strike spell.",
        "requirements": ["strikeSpells:1"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2528
    "Stronger Than Before": {
        "ap_id": 2528,
        "game_id": 355,
        "description": "Set corrupted banishment to level 12 and banish a monster 3 times.",
        "details": "Win with Corrupted Banishment trait at level 12.",
        "requirements": ["Corrupted Banishment trait"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2529
    "Stumbling": {
        "ap_id": 2529,
        "game_id": 213,
        "description": "Hit the same monster with traps 100 times.",
        "details": "Hit the same monster with traps 100 times.",
        "requirements": ["Traps skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2530
    "Super Gem": {
        "ap_id": 2530,
        "game_id": 40,
        "description": "Create a grade 3 gem with 300 effective max damage.",
        "untrackable": True,
        "requirements": ["minGemGrade: 3"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2531
    "Supply Line Cut": {
        "ap_id": 2531,
        "game_id": 471,
        "description": "Kill a swarm queen with a barrage shell.",
        "details": "Kill the swarm queen using a Barrage shell hit.",
        "requirements": ["Barrage skill", "Swarm Queen element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2532
    "Swarmling Season": {
        "ap_id": 2532,
        "game_id": 144,
        "description": "Kill 999 swarmlings.",
        "details": "Kill 999 swarmlings in one battle.",
        "requirements": ["minSwarmlings:999"],
        "reward": "skillPoints:1",
        "required_power": 30,
        "required_effort": "Major",
    },
    # AP ID: 2533
    "Swift Death": {
        "ap_id": 2533,
        "game_id": 627,
        "description": "Kill the gatekeeper with a bolt.",
        "requirements": ["Bolt skill", "Gatekeeper element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2534
    "Swift Deployment": {
        "ap_id": 2534,
        "game_id": 56,
        "description": "Have 20 gems on the battlefield before wave 5.",
        "details": "Have 20 gems on the field before wave 5 starts.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2535
    "Take Them I Have More": {
        "ap_id": 2535,
        "game_id": 486,
        "description": "Have 12 of your gems destroyed or stolen.",
        "details": "Have 12 of your gems destroyed or stolen by enemies.",
        "requirements": ["Ritual trait", "Specter element", "Watchtower element"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2536
    "Takers": {
        "ap_id": 2536,
        "game_id": 268,
        "description": "Gain 1.600 mana from drops.",
        "details": "Gain 1,600 mana from drops in one battle.",
        "requirements": ["Drop Holder element"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2537
    "Tapped Essence": {
        "ap_id": 2537,
        "game_id": 448,
        "description": "Leech 1.500 mana from bleeding monsters.",
        "requirements": ["Bleeding skill", "Mana Leech skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2538
    "Targeting Weak Points": {
        "ap_id": 2538,
        "game_id": 31,
        "description": "Win a battle using only critical hit gems.",
        "details": "Win a battle using only critical-hit gems.",
        "requirements": ["Critical Hit skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2539
    "Taste All The Affixes": {
        "ap_id": 2539,
        "game_id": 540,
        "description": "Kill 2.500 monsters with prismatic gem wasps.",
        "details": "Kill 2,500 monsters with prismatic wasps.",
        "requirements": ["gemSkills: 6"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2540
    "Tasting the Darkness": {
        "ap_id": 2540,
        "game_id": 88,
        "description": "Break 3 tombs open.",
        "details": "Break 3 tombs in one battle.",
        "requirements": ["Tomb element"],
        "reward": "skillPoints:3",
        "required_effort": "Minor",
    },
    # AP ID: 2541
    "Teleport Lag": {
        "ap_id": 2541,
        "game_id": 215,
        "description": "Banish a monster at least 5 times.",
        "details": "Banish the same monster 5 or more times.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2542
    "Ten Angry Waves": {
        "ap_id": 2542,
        "game_id": 335,
        "description": "Enrage 10 waves.",
        "details": "Manually enrage 10 waves in a single battle.",
        "requirements": ["minWave: 10"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2543
    "That Was Rude": {
        "ap_id": 2543,
        "game_id": 502,
        "description": "Lose a gem with more than 1.000 hits to a watchtower.",
        "details": "Have a watchtower steal back a gem that has hit at least 1,000 times.",
        "requirements": ["Watchtower element"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2544
    "That Was Your Last Move": {
        "ap_id": 2544,
        "game_id": 630,
        "description": "Kill a wizard hunter while it's attacking one of your buildings.",
        "details": "Kill a wizard hunter while it is attacking one of your buildings.",
        "requirements": ["Wizard Hunter element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2545
    "That one!": {
        "ap_id": 2545,
        "game_id": 393,
        "description": "Select a monster.",
        "details": "Click on (select) a monster.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2546
    "The Gathering": {
        "ap_id": 2546,
        "game_id": 333,
        "description": "Summon 500 monsters by enraging waves.",
        "details": "Summon 500 monsters by enraging waves.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Major",
    },
    # AP ID: 2547
    "The Horror": {
        "ap_id": 2547,
        "game_id": 237,
        "description": "Lose 3.333 mana to shadows.",
        "details": "Lose 3,333 mana to shadows.",
        "requirements": ["Ritual trait", "Shadow element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2548
    "The Killing Will Never Stop": {
        "ap_id": 2548,
        "game_id": 120,
        "description": "Reach 200.000 monsters killed through all the battles.",
        "details": "Cumulative across all battles: 200,000 monster kills.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2549
    "The Mana Reaper": {
        "ap_id": 2549,
        "game_id": 114,
        "description": "Reach 100.000 mana harvested from shards through all the battles.",
        "details": "Cumulative across all battles: harvest 100,000 mana from shards.",
        "requirements": ["Mana Shard element"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2550
    "The Messenger Must Die": {
        "ap_id": 2550,
        "game_id": 171,
        "description": "Kill a shadow.",
        "requirements": ["Ritual trait", "Shadow element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2551
    "The Peeler": {
        "ap_id": 2551,
        "game_id": 23,
        "description": "Create a grade 12 pure armor tearing gem.",
        "details": "Create a grade-12 pure armor-tearing gem (untrackable).",
        "untrackable": True,
        "requirements": ["Armor Tearing skill", "minGemGrade: 12"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2552
    "The Price of Obsession": {
        "ap_id": 2552,
        "game_id": 551,
        "description": "Kill 590 banished monsters.",
        "details": "Kill 590 banished monsters.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2553
    "There it is!": {
        "ap_id": 2553,
        "game_id": 394,
        "description": "Select a building.",
        "details": "Click on (select) a building.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2554
    "There's No Time": {
        "ap_id": 2554,
        "game_id": 326,
        "description": "Call 140 waves early.",
        "details": "Call 140 waves early in one battle.",
        "untrackable": True,
        "requirements": ["minWave: 140", "Endurance"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2555
    "They Are Millions": {
        "ap_id": 2555,
        "game_id": 125,
        "description": "Reach 1.000.000 monsters killed through all the battles.",
        "details": "Cumulative across all battles: 1,000,000 monster kills.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2556
    "They Are Still Here": {
        "ap_id": 2556,
        "game_id": 167,
        "description": "Kill 2 apparitions.",
        "details": "Kill 2 apparitions in one battle.",
        "requirements": ["Ritual trait", "Apparition element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2557
    "They Keep Coming": {
        "ap_id": 2557,
        "game_id": 430,
        "description": "Kill 12.000 monsters.",
        "details": "Kill 12,000 monsters in one battle.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_power": 80,
        "required_effort": "Major",
    },
    # AP ID: 2558
    "Thin Ice": {
        "ap_id": 2558,
        "game_id": 158,
        "description": "Kill 20 frozen monsters with gems in traps.",
        "details": "Kill 20 frozen monsters with traps.",
        "requirements": ["Freeze skill", "Traps skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2559
    "Thin Them Out": {
        "ap_id": 2559,
        "game_id": 397,
        "description": "Have the Strength in Numbers trait set to level 6 or higher and win the battle.",
        "details": "Win a battle with the Strength in Numbers trait at level 6 or higher.",
        "requirements": ["Strength in Numbers trait"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2560
    "Third Grade": {
        "ap_id": 2560,
        "game_id": 43,
        "description": "Create a grade 3 gem.",
        "details": "Create a grade-3 gem.",
        "untrackable": True,
        "requirements": ["minGemGrade: 3"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2561
    "Thorned Sphere": {
        "ap_id": 2561,
        "game_id": 255,
        "description": "Deliver 400 banishments with your orb.",
        "details": "Banish 400 monsters using the orb.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Minor",
    },
    # AP ID: 2562
    "Through All Layers": {
        "ap_id": 2562,
        "game_id": 153,
        "description": "Kill a monster having at least 200 armor.",
        "details": "Kill a monster that has at least 200 armor.",
        "requirements": ["minMonsterArmor:200"],
        "reward": "skillPoints:1",
        "required_power": 30,
        "required_effort": "Trivial",
    },
    # AP ID: 2563
    "Thunderstruck": {
        "ap_id": 2563,
        "game_id": 131,
        "description": "Kill 120 monsters with gem bombs and wasps.",
        "requirements": ["minMonsters:120"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2564
    "Tightly Secured": {
        "ap_id": 2564,
        "game_id": 261,
        "description": "Don't let any monster touch your orb for 60 beaten waves.",
        "details": "60 consecutive waves with no monster touching the orb.",
        "requirements": ["minWave: 60"],
        "reward": "skillPoints:1",
        "required_power": 80,
        "required_effort": "Minor",
    },
    # AP ID: 2565
    "Time Bent": {
        "ap_id": 2565,
        "game_id": 207,
        "description": "Have 90 monsters slowed at the same time.",
        "details": "Have 90 monsters slowed at the same instant.",
        "requirements": ["Slowing skill", "minMonsters:90"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2566
    "Time to Rise": {
        "ap_id": 2566,
        "game_id": 373,
        "description": "Have the Awakening trait set to level 6 or higher and win the battle.",
        "details": "Win a battle with the Awakening trait at level 6 or higher.",
        "requirements": ["Awakening trait"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2567
    "Time to Upgrade": {
        "ap_id": 2567,
        "game_id": 57,
        "description": "Have a grade 1 gem with 4.500 hits.",
        "details": "Reach 4,500 hits on a grade-1 gem.",
        "untrackable": True,
        "requirements": ["minGemGrade: 1"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2568
    "Tiny but Deadly": {
        "ap_id": 2568,
        "game_id": 164,
        "description": "Reach 50.000 gem wasp kills through all the battles.",
        "details": "Cumulative across all battles: 50,000 wasp kills.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2569
    "To the Last Drop": {
        "ap_id": 2569,
        "game_id": 454,
        "description": "Leech 4.700 mana from poisoned monsters.",
        "details": "Leech 4,700 mana from poisoned monsters.",
        "requirements": ["Mana Leech skill", "Poison skill"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2570
    "Tomb No Matter What": {
        "ap_id": 2570,
        "game_id": 582,
        "description": "Open a tomb while there is a spire on the battlefield.",
        "details": "Open a tomb while a spire is active on the field.",
        "requirements": ["Tomb element", "Spire element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2571
    "Tomb Raiding": {
        "ap_id": 2571,
        "game_id": 89,
        "description": "Break a tomb open before wave 15.",
        "details": "Break a tomb before wave 15 starts.",
        "requirements": ["Tomb element"],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 2572
    "Tomb Stomping": {
        "ap_id": 2572,
        "game_id": 63,
        "description": "Break 4 tombs open.",
        "details": "Break 4 tombs in one battle.",
        "requirements": ["Tomb element"],
        "reward": "skillPoints:3",
        "required_effort": "Major",
    },
    # AP ID: 2573
    "Too Curious": {
        "ap_id": 2573,
        "game_id": 82,
        "description": "Break 2 tombs open.",
        "details": "Break 2 tombs in one battle.",
        "requirements": ["Tomb element"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2574
    "Too Easy": {
        "ap_id": 2574,
        "game_id": 560,
        "description": "Win a Trial battle with at least 3 waves enraged.",
        "details": "Win a Trial battle with at least 3 waves enraged.",
        "untrackable": True,
        "requirements": ["minWave: 3", "Trial"],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 2575
    "Too Long to Hold Your Breath": {
        "ap_id": 2575,
        "game_id": 20,
        "description": "Beat 90 waves using only poison gems.",
        "requirements": ["Poison skill", "minWave: 90"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2576
    "Towerful": {
        "ap_id": 2576,
        "game_id": 66,
        "description": "Build 5 towers.",
        "details": "Build 5 towers in one battle.",
        "requirements": ["Tower element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2577
    "Trapland": {
        "ap_id": 2577,
        "game_id": 162,
        "description": "And it's bloody too",
        "details": "Reference: Trapland video game. Kill a monster using a trap. Complete a level using only traps and no poison gems",
        "untrackable": True,
        "requirements": ["Traps skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2578
    "Trembling": {
        "ap_id": 2578,
        "game_id": 407,
        "description": "Kill 1.500 monsters with gems in traps.",
        "details": "Kill 1,500 monsters with traps in one battle.",
        "requirements": ["Traps skill"],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2579
    "Tricolor": {
        "ap_id": 2579,
        "game_id": 27,
        "description": "Create a gem of 3 components.",
        "details": "Combine a 3-component gem.",
        "requirements": ["gemSkills: 3"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2580
    "Troll's Eye": {
        "ap_id": 2580,
        "game_id": 205,
        "description": "Kill a giant with one shot.",
        "details": "Kill a giant in a single hit.",
        "requirements": ["Bolt skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2581
    "Tumbling Billows": {
        "ap_id": 2581,
        "game_id": 352,
        "description": "Have the Swarmling Domination trait set to level 6 or higher and win the battle.",
        "details": "Win a battle with the Swarmling Domination trait at level 6 or higher.",
        "requirements": ["Swarmling Domination trait"],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2582
    "Twice the Blast": {
        "ap_id": 2582,
        "game_id": 424,
        "description": "Have 2 barrage enhanced gems at the same time.",
        "requirements": ["Barrage skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2583
    "Twice the Shock": {
        "ap_id": 2583,
        "game_id": 562,
        "description": "Hit the same monster 2 times with shrines.",
        "details": "Hit the same monster 2x with shrines.",
        "requirements": ["Shrine element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2584
    "Twice the Steepness": {
        "ap_id": 2584,
        "game_id": 532,
        "description": "Kill 170 monsters while there are at least 2 wraiths in the air.",
        "requirements": ["Ritual trait"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2585
    "Twice the Terror": {
        "ap_id": 2585,
        "game_id": 172,
        "description": "Kill 2 shadows.",
        "details": "Kill 2 shadows in one battle.",
        "requirements": [["Ritual trait", "Shadow element"]],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2586
    "Unarmed": {
        "ap_id": 2586,
        "game_id": 480,
        "description": "Have no gems when wave 20 starts.",
        "details": "Have zero gems on the battlefield when wave 20 starts.",
        "requirements": ["minWave: 20"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2587
    "Under Pressure": {
        "ap_id": 2587,
        "game_id": 396,
        "description": "Shoot down 340 shadow projectiles.",
        "requirements": [["Ritual trait", "Shadow element"]],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2588
    "Unending Flow": {
        "ap_id": 2588,
        "game_id": 431,
        "description": "Kill 24.000 monsters.",
        "details": "Kill 24,000 monsters in one battle.",
        "requirements": ["minMonsters:24000"],
        "reward": "skillPoints:3",
        "required_power": 160,
        "required_effort": "Extreme",
    },
    # AP ID: 2589
    "Unholy Stack": {
        "ap_id": 2589,
        "game_id": 186,
        "description": "Reach 20.000 monsters with special properties killed through all the battles.",
        "details": "Cumulative across all battles: 20,000 kills on monsters with special properties.",
        "untrackable": True,
        "requirements": ["Endurance", ["Possessed Monster element", "Twisted Monster element", "Marked Monster element"], "minWave: 70"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2590
    "Uninvited": {
        "ap_id": 2590,
        "game_id": 332,
        "description": "Summon 100 monsters by enraging waves.",
        "details": "Summon 100 monsters by enraging waves.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Minor",
    },
    # AP ID: 2591
    "Unsupportive": {
        "ap_id": 2591,
        "game_id": 302,
        "description": "Reach 100 beacons destroyed through all the battles.",
        "requirements": [["Dark Masonry trait", "Beacon element"]],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2592
    "Uraj and Khalis": {
        "ap_id": 2592,
        "game_id": 619,
        "description": "Activate the lanterns",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2593
    "Urban Warfare": {
        "ap_id": 2593,
        "game_id": 579,
        "description": "Destroy a dwelling and kill a monster with one gem bomb.",
        "details": "Destroy a dwelling AND kill a monster with the same gem bomb.",
        "requirements": ["Abandoned Dwelling element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2594
    "Vantage Point Down": {
        "ap_id": 2594,
        "game_id": 602,
        "description": "Demolish a pylon.",
        "requirements": ["Pylons skill", "Demolition skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2595
    "Versatile Charm": {
        "ap_id": 2595,
        "game_id": 504,
        "description": "Have at least 10 different talisman properties.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2596
    "Violet Ray": {
        "ap_id": 2596,
        "game_id": 177,
        "description": "Kill 20 frozen monsters with beam.",
        "details": "Kill 20 frozen monsters using Beam-enhanced gems.",
        "requirements": ["Beam skill", "Freeze skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2597
    "Warming Up": {
        "ap_id": 2597,
        "game_id": 51,
        "description": "Have a grade 1 gem with 100 hits.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2598
    "Wash Away": {
        "ap_id": 2598,
        "game_id": 190,
        "description": "Kill 110 monsters while it's raining.",
        "details": "Kill 110 monsters during rain weather.",
        "requirements": ["Rain element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2599
    "Wasp Defense": {
        "ap_id": 2599,
        "game_id": 459,
        "description": "Smash 3 jars of wasps before wave 3.",
        "requirements": ["Jar of Wasps element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2600
    "Wasp Storm": {
        "ap_id": 2600,
        "game_id": 134,
        "description": "Kill 360 monsters with gem bombs and wasps.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2601
    "Waspocalypse": {
        "ap_id": 2601,
        "game_id": 135,
        "description": "Kill 1.080 monsters with gem bombs and wasps.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2602
    "Watch Your Step": {
        "ap_id": 2602,
        "game_id": 73,
        "description": "Build 40 traps.",
        "requirements": ["Traps skill"],
        "reward": "skillPoints:1",
        "required_power": 30,
        "required_effort": "Major",
    },
    # AP ID: 2603
    "Wave Pecking": {
        "ap_id": 2603,
        "game_id": 331,
        "description": "Summon 20 monsters by enraging waves.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2604
    "Wave Smasher": {
        "ap_id": 2604,
        "game_id": 17,
        "description": "Reach 10.000 waves beaten through all the battles.",
        "details": "Cumulative across all battles: beat 10,000 waves.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2605
    "Waves for Breakfast": {
        "ap_id": 2605,
        "game_id": 16,
        "description": "Reach 2.000 waves beaten through all the battles.",
        "details": "Cumulative across all battles: beat 2,000 waves.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2606
    "Wavy": {
        "ap_id": 2606,
        "game_id": 14,
        "description": "Reach 500 waves beaten through all the battles.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2607
    "We Just Wanna Be Free": {
        "ap_id": 2607,
        "game_id": 617,
        "description": "More than blue triangles",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2608
    "Weakened Wallet": {
        "ap_id": 2608,
        "game_id": 587,
        "description": "Leech 5.400 mana from whited out monsters.",
        "requirements": ["Mana Leech skill", "Whiteout skill"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2609
    "Weather Tower": {
        "ap_id": 2609,
        "game_id": 412,
        "description": "Activate a shrine while raining.",
        "details": "Activate a shrine during rain weather.",
        "requirements": ["Shrine element", "Rain element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2610
    "Weather of Wasps": {
        "ap_id": 2610,
        "game_id": 276,
        "description": "Deal 3950 gem wasp stings to creatures.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2611
    "Well Defended": {
        "ap_id": 2611,
        "game_id": 260,
        "description": "Don't let any monster touch your orb for 20 beaten waves.",
        "requirements": ["minWave:20"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2612
    "Well Earned": {
        "ap_id": 2612,
        "game_id": 9,
        "description": "Reach 500 battles won.",
        "details": "Cumulative across all battles: win 500 battles.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2613
    "Well Laid": {
        "ap_id": 2613,
        "game_id": 55,
        "description": "Have 10 gems on the battlefield.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2614
    "Well Prepared": {
        "ap_id": 2614,
        "game_id": 224,
        "description": "Have 20.000 initial mana.",
        "untrackable": True,
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2615
    "Well Trained for This": {
        "ap_id": 2615,
        "game_id": 575,
        "description": "Kill a wraith with a shot fired by a gem having at least 1.000 kills.",
        "details": "Kill a wraith using a gem that has hit at least 1,000 times.",
        "requirements": ["Ritual trait", "Wraith element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2616
    "Whacked": {
        "ap_id": 2616,
        "game_id": 495,
        "description": "Kill a specter with one hit.",
        "requirements": ["Ritual trait", "Specter element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2617
    "What Are You Waiting For?": {
        "ap_id": 2617,
        "game_id": 5,
        "description": "Have all spells charged to 200%.",
        "requirements": ["strikeSpells:3"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2618
    "White Ray": {
        "ap_id": 2618,
        "game_id": 180,
        "description": "Kill 90 frozen monsters with beam.",
        "details": "Kill 90 frozen monsters using Beam-enhanced gems.",
        "requirements": ["Beam skill", "Freeze skill"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2619
    "White Ring of Death": {
        "ap_id": 2619,
        "game_id": 328,
        "description": "Gain 4.900 xp with Ice Shards spell crowd hits.",
        "details": "Gain 4,900 xp from Ice Shards crowd hits in one battle.",
        "requirements": ["Ice Shards skill"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2620
    "White Wand": {
        "ap_id": 2620,
        "game_id": 382,
        "description": "Reach wizard level 10.",
        "details": "Reach wizard level 10.",
        "requirements": ["wizardLevel: 10"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2621
    "Why Not": {
        "ap_id": 2621,
        "game_id": 464,
        "description": "Enhance a gem in the enraging socket.",
        "requirements": ["enhancementSpells:1"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2622
    "Wicked Gem": {
        "ap_id": 2622,
        "game_id": 42,
        "description": "Have a grade 3 gem with 900 effective max damage.",
        "details": "Create a grade-3 gem with at least 900 effective max damage.",
        "untrackable": True,
        "requirements": ["minGemGrade: 3"],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2623
    "Wings and Tentacles": {
        "ap_id": 2623,
        "game_id": 139,
        "description": "Reach 200 non-monsters killed through all the battles.",
        "details": "Cumulative across all battles: 200 non-monster kills.",
        "requirements": ["Ritual trait"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2624
    "Worst of Both Sizes": {
        "ap_id": 2624,
        "game_id": 556,
        "description": "Beat 300 waves on max Swarmling and Giant domination traits.",
        "details": "Beat 300 waves in Endurance with Swarmling Domination AND Giant Domination both at max level.",
        "untrackable": True,
        "requirements": ["Swarmling Domination trait", "Giant Domination trait", "minWave: 300", "Endurance"],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2625
    "Worthy": {
        "ap_id": 2625,
        "game_id": 520,
        "description": "Have 70 fields lit in Trial mode.",
        "untrackable": True,
        "requirements": ["Trial", "fieldToken: 70"],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2626
    "Xp Harvest": {
        "ap_id": 2626,
        "game_id": 514,
        "description": "Have 40 fields lit in Endurance mode.",
        "requirements": ["Endurance", "fieldToken: 40"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2627
    "Yellow Wand": {
        "ap_id": 2627,
        "game_id": 383,
        "description": "Reach wizard level 20.",
        "details": "Reach wizard level 20.",
        "requirements": ["wizardLevel: 20"],
        "reward": "skillPoints:1",
        "required_power": 30,
        "required_effort": "Minor",
    },
    # AP ID: 2628
    "You Could Be my Apprentice": {
        "ap_id": 2628,
        "game_id": 498,
        "description": "Have a watchtower kill a wizard hunter.",
        "details": "Have a watchtower kill a wizard hunter.",
        "requirements": ["Watchtower element", "Wizard Hunter element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2629
    "You Had Your Chance": {
        "ap_id": 2629,
        "game_id": 546,
        "description": "Kill 260 banished monsters with shrines.",
        "details": "Kill 260 banished monsters with shrines.",
        "untrackable": True,
        "requirements": ["Shrine element"],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2630
    "You Shall Not Pass": {
        "ap_id": 2630,
        "game_id": 248,
        "description": "Don't let any monster touch your orb for 240 beaten waves.",
        "details": "Survive 240 consecutive waves without any monster reaching the orb.",
        "requirements": ["minWave: 240", "Endurance"],
        "reward": "skillPoints:3",
        "required_power": 300,
        "required_effort": "Extreme",
    },
    # AP ID: 2631
    "You're Safe With Me": {
        "ap_id": 2631,
        "game_id": 543,
        "description": "Win a battle with at least 10 orblets remaining.",
        "details": "Win a battle with at least 10 orblets remaining unharvested.",
        "requirements": ["Orb of Presence skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2632
    "Your Mana is Mine": {
        "ap_id": 2632,
        "game_id": 232,
        "description": "Leech 10.000 mana with gems.",
        "requirements": ["Mana Leech skill"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2633
    "Zap Away": {
        "ap_id": 2633,
        "game_id": 286,
        "description": "Cast 175 strike spells.",
        "details": "Cast 175 strike spells in one battle.",
        "requirements": ["strikeSpells:1"],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2634
    "Zapped": {
        "ap_id": 2634,
        "game_id": 2,
        "description": "Get your Orb destroyed by a wizard tower.",
        "requirements": ["Wizard Tower element"],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2635
    "Zigzag Corridor": {
        "ap_id": 2635,
        "game_id": 81,
        "description": "Build 60 walls.",
        "details": "Build 60 walls in one battle.",
        "requirements": ["Wall element"],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
}

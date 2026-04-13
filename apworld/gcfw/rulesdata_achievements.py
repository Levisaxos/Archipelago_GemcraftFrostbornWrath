"""
GemCraft Frostborn Wrath - Achievement Requirements

All 636 achievements with their requirements, AP IDs, and metadata.
This is the single source of truth for achievement data.

Fields per achievement:
  ap_id           - Archipelago item ID (2000-2636)
  description     - Human-readable description
  requirements    - List of requirement strings for logic checks
  reward          - Reward string, e.g. "skillPoints:2"
  required_effort - Effort level: "Trivial", "Minor", "Major", "Extreme"
"""

achievement_requirements = {
    # AP ID: 2000
    "A Bright Start": {
        "ap_id": 2000,
        "description": "Have 30 fields lit in Journey mode.",
        "requirements": ['fieldToken: 30'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2001
    "A Shrubbery!": {
        "ap_id": 2001,
        "description": "Place a shrub wall.",
        "requirements": ['Wall element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2002
    "Ablatio Retinae": {
        "ap_id": 2002,
        "description": "Whiteout 111 whited out monsters.",
        "requirements": ['Whiteout skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2003
    "Absolute Zero": {
        "ap_id": 2003,
        "description": "Kill 273 frozen monsters.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2004
    "Acid Rain": {
        "ap_id": 2004,
        "description": "Kill 85 poisoned monsters while it's raining.",
        "requirements": ['Poison skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2005
    "Added Protection": {
        "ap_id": 2005,
        "description": "Strengthen your orb with a gem in an amplifier.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2006
    "Addicted": {
        "ap_id": 2006,
        "description": "Activate shrines a total of 12 times.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:2",
        "required_effort": "Minor",
    },
    # AP ID: 2007
    "Adept": {
        "ap_id": 2007,
        "description": "Have 30 fields lit in Trial mode.",
        "requirements": ['Trial', 'fieldToken: 30'],
        "reward": "skillPoints:3",
        "required_effort": "Minor",
    },
    # AP ID: 2008
    "Adept Enhancer": {
        "ap_id": 2008,
        "description": "Reach 500 enhancement spells cast through all the ...",
        "requirements": [
            'Beam skill',
            'Bolt skill',
            'Barrage skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2009
    "Adept Grade": {
        "ap_id": 2009,
        "description": "Create a grade 8 gem.",
        "requirements": ['minGemGrade: 8'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2010
    "Adventurer": {
        "ap_id": 2010,
        "description": "Gain 600 xp from drops.",
        "requirements": [
            'Apparition element',
            'Corrupted Mana Shard element',
            'Drop Holder element',
            'Mana Shard element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2011
    "Ages Old Memories": {
        "ap_id": 2011,
        "description": "Unlock a wizard tower.",
        "requirements": ['Wizard Tower element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2012
    "Agitated": {
        "ap_id": 2012,
        "description": "Call 70 waves early.",
        "requirements": ['minWave: 70'],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 2013
    "All Your Mana Belongs to Us": {
        "ap_id": 2013,
        "description": "Beat 90 waves using only mana leeching gems.",
        "requirements": [
            'Mana Leech skill',
            'minWave: 90',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2014
    "Almost": {
        "ap_id": 2014,
        "description": "Kill a monster with shots blinking to the monster ...",
        "requirements": [
            'Watchtower element',
            'Wizard Hunter element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2015
    "Almost Like Hacked": {
        "ap_id": 2015,
        "description": "Have at least 20 different talisman properties.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2016
    "Almost Ruined": {
        "ap_id": 2016,
        "description": "Leave a monster nest at 1 hit point at the end of ...",
        "requirements": ['Monster Nest element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2017
    "Am I a Joke to You?": {
        "ap_id": 2017,
        "description": "Start an enraged wave early while there is a wizar...",
        "requirements": ['Wizard Hunter element'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2018
    "Ambitious Builder": {
        "ap_id": 2018,
        "description": "Reach 500 structures built through all the battles...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2019
    "Amplification": {
        "ap_id": 2019,
        "description": "Spend 18.000 mana on amplifiers.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2020
    "Amplifinity": {
        "ap_id": 2020,
        "description": "Build 45 amplifiers.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2021
    "Amulet": {
        "ap_id": 2021,
        "description": "Fill all the sockets in your talisman.",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2022
    "And Don't Come Back": {
        "ap_id": 2022,
        "description": "Kill 460 banished monsters with shrines.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2023
    "Angry Wasps": {
        "ap_id": 2023,
        "description": "Reach 1.000 gem wasp kills through all the battles...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2024
    "Antitheft": {
        "ap_id": 2024,
        "description": "Kill 90 monsters with orblet explosions.",
        "requirements": ['Orb of Presence skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2025
    "Armored Orb": {
        "ap_id": 2025,
        "description": "Strengthen your orb by dropping a gem on it.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2026
    "Army Glue": {
        "ap_id": 2026,
        "description": "Have a pure slowing gem with 4.000 hits.",
        "requirements": ['Slowing skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2027
    "At my Fingertips": {
        "ap_id": 2027,
        "description": "Cast 75 strike spells.",
        "requirements": [
            'Ice Shards skill',
            'Whiteout skill',
            'Freeze skill',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 2028
    "Avenged": {
        "ap_id": 2028,
        "description": "Kill 15 monsters carrying orblets.",
        "requirements": ['Orb of Presence skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2029
    "Awakening": {
        "ap_id": 2029,
        "description": "Activate a shrine.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2030
    "Bang": {
        "ap_id": 2030,
        "description": "Throw 30 gem bombs.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2031
    "Barbed Sphere": {
        "ap_id": 2031,
        "description": "Deliver 1.200 banishments with your orb.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 2032
    "Barrage Battery": {
        "ap_id": 2032,
        "description": "Have a Maximum Charge of 300% for the Barrage Spel...",
        "requirements": ['Barrage skill'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2033
    "Basic Gem Tactics": {
        "ap_id": 2033,
        "description": "Beat 120 waves and don't use any gem enhancement s...",
        "requirements": ['minWave: 120'],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 2034
    "Bastion": {
        "ap_id": 2034,
        "description": "Build 90 towers.",
        "requirements": ['Tower element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2035
    "Bath Bomb": {
        "ap_id": 2035,
        "description": "Kill 30 monsters with orblet explosions.",
        "requirements": ['Orb of Presence skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2036
    "Battle Heat": {
        "ap_id": 2036,
        "description": "Gain 200 xp with kill chains.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2037
    "Bazaar": {
        "ap_id": 2037,
        "description": "Have 30 gems on the battlefield.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Minor",
    },
    # AP ID: 2038
    "Be Gone For Good": {
        "ap_id": 2038,
        "description": "Kill 790 banished monsters.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2039
    "Beacon Hunt": {
        "ap_id": 2039,
        "description": "Destroy 55 beacons.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2040
    "Beacons Be Gone": {
        "ap_id": 2040,
        "description": "Reach 500 beacons destroyed through all the battle...",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2041
    "Beastmaster": {
        "ap_id": 2041,
        "description": "Kill a monster having at least 100.000 hit points ...",
        "requirements": ['A monster with atleast 100.000hp and 1000 amror'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2042
    "Behold Aurora": {
        "ap_id": 2042,
        "description": "Go Igniculus and Light Ray (All)+++!",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2043
    "Biohazard": {
        "ap_id": 2043,
        "description": "Create a grade 12 pure poison gem.",
        "requirements": [
            'Poison skill',
            'minGemGrade: 12',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2044
    "Black Blood": {
        "ap_id": 2044,
        "description": "Deal 5.000 poison damage to a shadow.",
        "requirements": [
            'Poison skill',
            'Ritual trait',
            'Shadow element',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2045
    "Black Wand": {
        "ap_id": 2045,
        "description": "Reach wizard level 1.000.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2046
    "Blackout": {
        "ap_id": 2046,
        "description": "Destroy a beacon.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2047
    "Blastwave": {
        "ap_id": 2047,
        "description": "Reach 1.000 shrine kills through all the battles.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2048
    "Bleed Out": {
        "ap_id": 2048,
        "description": "Kill 480 bleeding monsters.",
        "requirements": ['Bleeding skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2049
    "Bleeding For Everyone": {
        "ap_id": 2049,
        "description": "Enhance a pure bleeding gem having random priority...",
        "requirements": [
            'Beam skill',
            'Bleeding skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2050
    "Blind Hit": {
        "ap_id": 2050,
        "description": "Kill 30 whited out monsters with beam.",
        "requirements": [
            'Beam skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2051
    "Blood Censorship": {
        "ap_id": 2051,
        "description": "Kill 2.100 green blooded monsters.",
        "requirements": ['Requires "hidden codes"'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2052
    "Blood Clot": {
        "ap_id": 2052,
        "description": "Beat 90 waves using only bleeding gems.",
        "requirements": [
            'Bleeding skill',
            'minWave: 90',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2053
    "Blood Magic": {
        "ap_id": 2053,
        "description": "Win a battle using only bleeding gems.",
        "requirements": ['Bleeding skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2054
    "Blood on my Hands": {
        "ap_id": 2054,
        "description": "Reach 20.000 monsters killed through all the battl...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2055
    "Bloodmaster": {
        "ap_id": 2055,
        "description": "Gain 1.200 xp with kill chains.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2056
    "Bloodrush": {
        "ap_id": 2056,
        "description": "Call an enraged wave early.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2057
    "Bloodstream": {
        "ap_id": 2057,
        "description": "Kill 4.000 monsters.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2058
    "Blue Wand": {
        "ap_id": 2058,
        "description": "Reach wizard level 100.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2059
    "Boatload of Cores": {
        "ap_id": 2059,
        "description": "Find 540 shadow cores.",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2060
    "Boiling Red": {
        "ap_id": 2060,
        "description": "Reach a kill chain of 2400.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2061
    "Bone Shredder": {
        "ap_id": 2061,
        "description": "Kill 600 monsters before wave 12 starts.",
        "requirements": ['Atleast 600 monsters before wave 10'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2062
    "Boom": {
        "ap_id": 2062,
        "description": "Throw a gem bomb.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2063
    "Bouncy Zap": {
        "ap_id": 2063,
        "description": "Reach 2.000 pylon kills through all the battles.",
        "requirements": ['Pylons skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2064
    "Breath of Cold": {
        "ap_id": 2064,
        "description": "Have 90 monsters frozen at the same time.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2065
    "Brickery": {
        "ap_id": 2065,
        "description": "Reach 1.000 structures built through all the battl...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2066
    "Bright Weakening": {
        "ap_id": 2066,
        "description": "Gain 1.200 xp with Whiteout spell crowd hits.",
        "requirements": ['Whiteout skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2067
    "Broken Seal": {
        "ap_id": 2067,
        "description": "Free a sealed gem.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2068
    "Broken Siege": {
        "ap_id": 2068,
        "description": "Destroy 8 beacons before wave 8.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2069
    "Brought Some Mana": {
        "ap_id": 2069,
        "description": "Have 5.000 initial mana.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2070
    "Brown Wand": {
        "ap_id": 2070,
        "description": "Reach wizard level 300.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2071
    "Build Along": {
        "ap_id": 2071,
        "description": "Reach 200 structures built through all the battles...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2072
    "Busted": {
        "ap_id": 2072,
        "description": "Destroy a full health possession obelisk with one ...",
        "requirements": ['Obelisk element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2073
    "Buzz Feed": {
        "ap_id": 2073,
        "description": "Have 99 gem wasps on the battlefield.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2074
    "By Three They Go": {
        "ap_id": 2074,
        "description": "Have 3 of your gems destroyed or stolen.",
        "requirements": [
            'Ritual trait',
            'Specter element',
            'Watchtower element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2075
    "Bye Bye Hideous": {
        "ap_id": 2075,
        "description": "Kill a spire.",
        "requirements": [
            'Ritual trait',
            'Spire element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2076
    "Call in the Wave!": {
        "ap_id": 2076,
        "description": "Call a wave early.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2077
    "Can't Crawl Away": {
        "ap_id": 2077,
        "description": "Kill 30 whited out monsters with barrage.",
        "requirements": [
            'Barrage skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2078
    "Can't Stop": {
        "ap_id": 2078,
        "description": "Reach a kill chain of 900.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2079
    "Can't Take Any Risks": {
        "ap_id": 2079,
        "description": "Kill a bleeding giant with poison.",
        "requirements": [
            'Bleeding skill',
            'Poison skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2080
    "Care to Die Already?": {
        "ap_id": 2080,
        "description": "Cast 8 ice shards on the same monster.",
        "requirements": ['Ice Shards skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2081
    "Carnage": {
        "ap_id": 2081,
        "description": "Reach a kill chain of 600.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2082
    "Cartographer": {
        "ap_id": 2082,
        "description": "Have 90 fields lit in Journey mode.",
        "requirements": ['fieldToken: 90'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2083
    "Catalyst": {
        "ap_id": 2083,
        "description": "Give a Gem 200 Poison Damage by Amplification.",
        "requirements": [
            'Amplifiers skill',
            'Poison skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2084
    "Catch and Release": {
        "ap_id": 2084,
        "description": "Destroy a jar of wasps, but don't have any wasp ki...",
        "requirements": ['Field X2'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2085
    "Century Egg": {
        "ap_id": 2085,
        "description": "Reach 100 monster eggs cracked through all the bat...",
        "requirements": ['Swarm Queen element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2086
    "Chainsaw": {
        "ap_id": 2086,
        "description": "Gain 3.200 xp with kill chains.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2087
    "Charge Fire Repeat": {
        "ap_id": 2087,
        "description": "Reach 5.000 enhancement spells cast through all th...",
        "requirements": [
            'Bolt skill',
            'Beam skill',
            'Barrage skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2088
    "Charged for the Kill": {
        "ap_id": 2088,
        "description": "Reach 200 pylon kills through all the battles.",
        "requirements": ['Pylons skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2089
    "Charm": {
        "ap_id": 2089,
        "description": "Fill all the sockets in your talisman with fragmen...",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2090
    "Chilling Edges": {
        "ap_id": 2090,
        "description": "Gain 140 xp with Ice Shards spell crowd hits.",
        "requirements": ['Ice Shards skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2091
    "Chlorophyll": {
        "ap_id": 2091,
        "description": "Kill 4.500 green blooded monsters.",
        "requirements": ['Requires "hidden codes"'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2092
    "Clean Orb": {
        "ap_id": 2092,
        "description": "Win a battle without any monster getting to your o...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2093
    "Cleansing the Wilderness": {
        "ap_id": 2093,
        "description": "Reach 50.000 monsters with special properties kill...",
        "requirements": [
            'Endurance',
            'Possessed Monster element',
            'Twisted Monster element',
            'Marked Monster element',
            'minWave: 70',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2094
    "Clear Sky": {
        "ap_id": 2094,
        "description": "Beat 120 waves and don't use any strike spells.",
        "requirements": ['minWave: 120'],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 2095
    "Close Quarter": {
        "ap_id": 2095,
        "description": "Reach -12% decreased banishment cost with your orb...",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2096
    "Cold Wisdom": {
        "ap_id": 2096,
        "description": "Gain 700 xp with Freeze spell crowd hits.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2097
    "Come Again": {
        "ap_id": 2097,
        "description": "Kill 190 banished monsters.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2098
    "Come Out": {
        "ap_id": 2098,
        "description": "Lure 20 swarmlings out of a sleeping hive.",
        "requirements": ['Sleeping Hive element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2099
    "Come Out, Come Out": {
        "ap_id": 2099,
        "description": "Lure 100 swarmlings out of a sleeping hive.",
        "requirements": ['Sleeping Hive element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2100
    "Confusion Junction": {
        "ap_id": 2100,
        "description": "Build 30 walls.",
        "requirements": ['Wall element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2101
    "Connected": {
        "ap_id": 2101,
        "description": "Build an amplifier.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2102
    "Connecting the Dots": {
        "ap_id": 2102,
        "description": "Have 50 fields lit in Journey mode.",
        "requirements": ['fieldToken: 50'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2103
    "Core Haul": {
        "ap_id": 2103,
        "description": "Find 180 shadow cores.",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2104
    "Core Pack": {
        "ap_id": 2104,
        "description": "Find 20 shadow cores.",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2105
    "Core Pile": {
        "ap_id": 2105,
        "description": "Find 60 shadow cores.",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2106
    "Core Pouch": {
        "ap_id": 2106,
        "description": "Have 100 shadow cores at the start of the battle.",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2107
    "Corrosive Stings": {
        "ap_id": 2107,
        "description": "Tear a total of 5.000 armor with wasp stings.",
        "requirements": ['Armor Tearing skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2108
    "Couldn't Decide": {
        "ap_id": 2108,
        "description": "Kill 400 monsters with prismatic gem wasps.",
        "requirements": ['gemSkills: 6'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2109
    "Crimson Journal": {
        "ap_id": 2109,
        "description": "Reach 100.000 monsters killed through all the batt...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2110
    "Crowd Control": {
        "ap_id": 2110,
        "description": "Have the Overcrowd trait set to level 6 or higher ...",
        "requirements": ['Overcrowd trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2111
    "Crowded Queue": {
        "ap_id": 2111,
        "description": "Have 600 monsters on the battlefield at the same t...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2112
    "Crunchy Bites": {
        "ap_id": 2112,
        "description": "Kill 160 frozen swarmlings.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2113
    "Damage Support": {
        "ap_id": 2113,
        "description": "Have a pure bleeding gem with 2.500 hits.",
        "requirements": ['Bleeding skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2114
    "Darkness Walk With Me": {
        "ap_id": 2114,
        "description": "Kill 3 shadows.",
        "requirements": [
            'Ritual trait',
            'Shadow element',
        ],
        "reward": "skillPoints:3",
        "required_effort": "Minor",
    },
    # AP ID: 2115
    "Deadly Curse": {
        "ap_id": 2115,
        "description": "Reach 5.000 poison kills through all the battles.",
        "requirements": ['Poison skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2116
    "Deal Some Damage Too": {
        "ap_id": 2116,
        "description": "Have 5 traps with bolt enhanced gems in them.",
        "requirements": [
            'Bolt skill',
            'Traps skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2117
    "Deathball": {
        "ap_id": 2117,
        "description": "Reach 1.000 pylon kills through all the battles.",
        "requirements": ['Pylons skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2118
    "Deckard Would Be Proud": {
        "ap_id": 2118,
        "description": "All I could get for a prismatic amulet",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2119
    "Deluminati": {
        "ap_id": 2119,
        "description": "Have the Dark Masonry trait set to level 6 or high...",
        "requirements": ['Dark Masonry trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2120
    "Denested": {
        "ap_id": 2120,
        "description": "Destroy 5 monster nests.",
        "requirements": ['Monster Nest element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2121
    "Derangement": {
        "ap_id": 2121,
        "description": "Decrease the range of a gem.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2122
    "Desperate Clash": {
        "ap_id": 2122,
        "description": "Reach -16% decreased banishment cost with your orb...",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2123
    "Diabolic Trophy": {
        "ap_id": 2123,
        "description": "Kill 666 swarmlings.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2124
    "Dichromatic": {
        "ap_id": 2124,
        "description": "Combine two gems of different colors.",
        "requirements": ['gemSkills: 2'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2125
    "Disciple": {
        "ap_id": 2125,
        "description": "Have 10 fields lit in Trial mode.",
        "requirements": ['Trial', 'fieldToken: 10'],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 2126
    "Disco Ball": {
        "ap_id": 2126,
        "description": "Have a gem of 6 components in a lantern.",
        "requirements": [
            'Lanterns skill',
            'gemSkills: 6',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2127
    "Don't Break it!": {
        "ap_id": 2127,
        "description": "Spend 90.000 mana on banishment.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2128
    "Don't Look at the Light": {
        "ap_id": 2128,
        "description": "Reach 10.000 shrine kills through all the battles.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2129
    "Don't Touch it!": {
        "ap_id": 2129,
        "description": "Kill a specter.",
        "requirements": [
            'Ritual trait',
            'Specter element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2130
    "Doom Drop": {
        "ap_id": 2130,
        "description": "Kill a possessed giant with barrage.",
        "requirements": [
            'Barrage skill',
            'Possessed Monster element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2131
    "Double Punch": {
        "ap_id": 2131,
        "description": "Have 2 bolt enhanced gems at the same time.",
        "requirements": ['Bolt skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2132
    "Double Sharded": {
        "ap_id": 2132,
        "description": "Cast 2 ice shards on the same monster.",
        "requirements": ['Ice Shards skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2133
    "Double Splash": {
        "ap_id": 2133,
        "description": "Kill two non-monster creatures with one gem bomb.",
        "requirements": ['Ritual trait'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2134
    "Double Strike": {
        "ap_id": 2134,
        "description": "Activate the same shrine 2 times.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2135
    "Drone Warfare": {
        "ap_id": 2135,
        "description": "Reach 20.000 gem wasp kills through all the battle...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2136
    "Drop the Ice": {
        "ap_id": 2136,
        "description": "Reach 50.000 strike spell hits through all the bat...",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2137
    "Drumroll": {
        "ap_id": 2137,
        "description": "Deal 200 gem wasp stings to buildings.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2138
    "Dry Puddle": {
        "ap_id": 2138,
        "description": "Harvest all mana from a mana shard.",
        "requirements": ['Mana Shard element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2139
    "Dual Downfall": {
        "ap_id": 2139,
        "description": "Kill 2 spires.",
        "requirements": [
            'Ritual trait',
            'Spire element',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2140
    "Dual Pulse": {
        "ap_id": 2140,
        "description": "Have 2 beam enhanced gems at the same time.",
        "requirements": ['Beam skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2141
    "Eagle Eye": {
        "ap_id": 2141,
        "description": "Reach an amplified gem range of 18.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2142
    "Early Bird": {
        "ap_id": 2142,
        "description": "Reach 500 waves started early through all the batt...",
        "requirements": [
            'minWave: 500',
            'Endurance',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2143
    "Early Harvest": {
        "ap_id": 2143,
        "description": "Harvest 2.500 mana from shards before wave 3 start...",
        "requirements": ['Mana Shard element'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2144
    "Earthquake": {
        "ap_id": 2144,
        "description": "Activate shrines a total of 4 times.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2145
    "Easy Kill": {
        "ap_id": 2145,
        "description": "Kill 120 bleeding monsters.",
        "requirements": ['Bleeding skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2146
    "Eat my Light": {
        "ap_id": 2146,
        "description": "Kill a wraith with a shrine strike.",
        "requirements": [
            'Ritual trait',
            'Shrine element',
            'Wraith element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2147
    "Eggcracker": {
        "ap_id": 2147,
        "description": "Don't let any egg laid by a swarm queen to hatch o...",
        "requirements": ['Swarm Queen element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2148
    "Eggnog": {
        "ap_id": 2148,
        "description": "Crack a monster egg open while time is frozen.",
        "requirements": ['Swarm Queen element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2149
    "Eggs Royale": {
        "ap_id": 2149,
        "description": "Reach 1.000 monster eggs cracked through all the b...",
        "requirements": ['Swarm Queen element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2150
    "Elementary": {
        "ap_id": 2150,
        "description": "Beat 30 waves using at most grade 2 gems.",
        "requirements": ['minWave: 30'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2151
    "End of the Tunnel": {
        "ap_id": 2151,
        "description": "Kill an apparition with a shrine strike.",
        "requirements": [
            'Ritual trait',
            'Apparition element',
            'Shrine element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2152
    "Endgame Balance": {
        "ap_id": 2152,
        "description": "Have 25.000 shadow cores at the start of the battl...",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2153
    "Endured a Lot": {
        "ap_id": 2153,
        "description": "Have 80 fields lit in Endurance mode.",
        "requirements": ['Endurance', 'fieldToken: 80'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2154
    "Enhance Like No Tomorrow": {
        "ap_id": 2154,
        "description": "Reach 2.500 enhancement spells cast through all th...",
        "requirements": [
            'Bolt skill',
            'Beam skill',
            'Barrage skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2155
    "Enhancement Storage": {
        "ap_id": 2155,
        "description": "Enhance a gem in the inventory.",
        "requirements": [
            'Bolt skill',
            'Beam skill',
            'Barrage skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2156
    "Enhancing Challenge": {
        "ap_id": 2156,
        "description": "Beat 200 waves on max Swarmling and Giant dominati...",
        "requirements": [
            'Swarmling Domination trait',
            'Giant Domination trait',
            'minWave: 200',
            'Endurance',
        ],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2157
    "Enough Frozen Time Trickery": {
        "ap_id": 2157,
        "description": "Kill a shadow while time is frozen.",
        "requirements": ['Shadow element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2158
    "Enough is Enough": {
        "ap_id": 2158,
        "description": "Have 24 of your gems destroyed or stolen.",
        "requirements": [
            'Ritual trait',
            'Specter element',
            'Watchtower element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2159
    "Enraged is the New Norm": {
        "ap_id": 2159,
        "description": "Enrage 240 waves.",
        "requirements": [
            'minWave: 240',
            'Endurance',
        ],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2160
    "Ensnared": {
        "ap_id": 2160,
        "description": "Kill 12 monsters with gems in traps.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2161
    "Enter The Gate": {
        "ap_id": 2161,
        "description": "Kill the gatekeeper.",
        "requirements": [
            'Gatekeeper element',
            'Field A4',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2162
    "Entrenched": {
        "ap_id": 2162,
        "description": "Build 20 traps.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2163
    "Epidemic Gem": {
        "ap_id": 2163,
        "description": "Have a pure poison gem with 3.500 hits.",
        "requirements": ['Poison skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2164
    "Even if You Thaw": {
        "ap_id": 2164,
        "description": "Whiteout 120 frozen monsters.",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2165
    "Every Hit Counts": {
        "ap_id": 2165,
        "description": "Deliver 3750 one hit kills.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2166
    "Exorcism": {
        "ap_id": 2166,
        "description": "Kill 199 possessed monsters.",
        "requirements": ['Possessed Monster element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2167
    "Expert": {
        "ap_id": 2167,
        "description": "Have 50 fields lit in Trial mode.",
        "requirements": ['Trial', 'fieldToken: 50'],
        "reward": "skillPoints:3",
        "required_effort": "Major",
    },
    # AP ID: 2168
    "Extorted": {
        "ap_id": 2168,
        "description": "Harvest all mana from 3 mana shards.",
        "requirements": ['Mana Shard element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2169
    "Face the Phobia": {
        "ap_id": 2169,
        "description": "Have the Swarmling Parasites trait set to level 6 ...",
        "requirements": ['Swarmling Parasites trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2170
    "Family Friendlier": {
        "ap_id": 2170,
        "description": "Kill 900 green blooded monsters.",
        "requirements": ['Requires "hidden codes"'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2171
    "Farewell": {
        "ap_id": 2171,
        "description": "Kill an apparition with one hit.",
        "requirements": [
            'Ritual trait',
            'Apparition element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2172
    "Feels Like Endurance": {
        "ap_id": 2172,
        "description": "Beat 120 waves.",
        "requirements": ['minWave: 120'],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2173
    "Fierce Encounter": {
        "ap_id": 2173,
        "description": "Reach -8% decreased banishment cost with your orb.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2174
    "Fifth Grader": {
        "ap_id": 2174,
        "description": "Create a grade 5 gem.",
        "requirements": ['minGemGrade: 5'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2175
    "Filled 5 Times": {
        "ap_id": 2175,
        "description": "Reach mana pool level 5.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2176
    "Final Cut": {
        "ap_id": 2176,
        "description": "Kill 960 bleeding monsters.",
        "requirements": ['Bleeding skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2177
    "Final Touch": {
        "ap_id": 2177,
        "description": "Kill a spire with a gem wasp.",
        "requirements": [
            'Ritual trait',
            'Spire element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2178
    "Finders": {
        "ap_id": 2178,
        "description": "Gain 200 mana from drops.",
        "requirements": [
            'Mana Shard element',
            'Corrupted Mana Shard element',
            'Drop Holder element',
            'Apparition element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2179
    "Fire Away": {
        "ap_id": 2179,
        "description": "Cast a gem enhancement spell.",
        "requirements": [
            'Bolt skill',
            'Beam skill',
            'Barrage skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2180
    "Fire in the Hole": {
        "ap_id": 2180,
        "description": "Destroy a monster nest.",
        "requirements": ['Monster Nest element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2181
    "Firefall": {
        "ap_id": 2181,
        "description": "Have 16 barrage enhanced gems at the same time.",
        "requirements": ['Barrage skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2182
    "First Blood": {
        "ap_id": 2182,
        "description": "Kill a monster.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2183
    "First Puzzle Piece": {
        "ap_id": 2183,
        "description": "Find a talisman fragment.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2184
    "Flip Flop": {
        "ap_id": 2184,
        "description": "Win a flipped field battle.",
        "requirements": ['Requires "hidden codes"'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2185
    "Flows Through my Veins": {
        "ap_id": 2185,
        "description": "Reach mana pool level 10.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2186
    "Flying Multikill": {
        "ap_id": 2186,
        "description": "Destroy 1 apparition, 1 specter, 1 wraith and 1 sh...",
        "requirements": [
            'Ritual trait',
            'Apparition element',
            'Shadow element',
            'Specter element',
            'Wraith element',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2187
    "Fool Me Once": {
        "ap_id": 2187,
        "description": "Kill 390 banished monsters.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2188
    "Forces Within my Comprehension": {
        "ap_id": 2188,
        "description": "Have the Ritual trait set to level 6 or higher and...",
        "requirements": ['Ritual trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2189
    "Forged in Battle": {
        "ap_id": 2189,
        "description": "Reach 200 battles won.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2190
    "Fortress": {
        "ap_id": 2190,
        "description": "Build 30 towers.",
        "requirements": ['Tower element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2191
    "Fortunate": {
        "ap_id": 2191,
        "description": "Find 2 talisman fragments.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2192
    "Frag Rain": {
        "ap_id": 2192,
        "description": "Find 5 talisman fragments.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 2193
    "Freezing Wounds": {
        "ap_id": 2193,
        "description": "Freeze a monster 3 times.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2194
    "Friday Night": {
        "ap_id": 2194,
        "description": "Have 4 beam enhanced gems at the same time.",
        "requirements": ['Beam skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2195
    "Frittata": {
        "ap_id": 2195,
        "description": "Reach 500 monster eggs cracked through all the bat...",
        "requirements": ['Swarm Queen element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2196
    "From Above": {
        "ap_id": 2196,
        "description": "Kill 40 monsters with gem bombs and wasps.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2197
    "Frostborn": {
        "ap_id": 2197,
        "description": "Reach 5.000 strike spells cast through all the bat...",
        "requirements": [
            'Whiteout skill',
            'Ice Shards skill',
            'Freeze skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2198
    "Frosting": {
        "ap_id": 2198,
        "description": "Freeze a specter while it's snowing.",
        "requirements": [
            'Freeze skill',
            'Ritual trait',
            'Specter element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2199
    "Frozen Crowd": {
        "ap_id": 2199,
        "description": "Reach 10.000 strike spell hits through all the bat...",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2200
    "Frozen Grave": {
        "ap_id": 2200,
        "description": "Kill 220 monsters while it's snowing.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2201
    "Frozen Over": {
        "ap_id": 2201,
        "description": "Gain 4.500 xp with Freeze spell crowd hits.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2202
    "Ful Ir": {
        "ap_id": 2202,
        "description": "Blast like a fireball",
        "requirements": ['Kill 15 monsters simultaneously with 1 gem bomb'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2203
    "Fully Lit": {
        "ap_id": 2203,
        "description": "Have a field beaten in all three battle modes.",
        "requirements": ['Endurance and trial'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2204
    "Fully Shining": {
        "ap_id": 2204,
        "description": "Have 60 gems on the battlefield.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 2205
    "Fusion Core": {
        "ap_id": 2205,
        "description": "Have 16 beam enhanced gems at the same time.",
        "requirements": ['Beam skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2206
    "Gearing Up": {
        "ap_id": 2206,
        "description": "Have 5 fragments socketed in your talisman.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2207
    "Gem Lust": {
        "ap_id": 2207,
        "description": "Kill 2 specters.",
        "requirements": [
            'Ritual trait',
            'Specter element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2208
    "Gemhancement": {
        "ap_id": 2208,
        "description": "Reach 1.000 enhancement spells cast through all th...",
        "requirements": [
            'Bolt skill',
            'Beam skill',
            'Barrage skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2209
    "Get Them": {
        "ap_id": 2209,
        "description": "Have a watchtower kill 39 monsters.",
        "requirements": ['Watchtower element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2210
    "Get This Done Quick": {
        "ap_id": 2210,
        "description": "Win a Trial battle with at least 3 waves started e...",
        "requirements": [
            'minWave: 3',
            'Trial',
        ],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 2211
    "Getting My Feet Wet": {
        "ap_id": 2211,
        "description": "Have 20 fields lit in Endurance mode.",
        "requirements": ['Endurance', 'fieldToken: 20'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2212
    "Getting Rid of Them": {
        "ap_id": 2212,
        "description": "Drop 48 gem bombs on beacons.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2213
    "Getting Serious": {
        "ap_id": 2213,
        "description": "Have a grade 1 gem with 1.500 hits.",
        "requirements": ['minGemGrade: 1'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2214
    "Getting Waves Done": {
        "ap_id": 2214,
        "description": "Reach 2.000 waves started early through all the ba...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2215
    "Getting Wet": {
        "ap_id": 2215,
        "description": "Beat 30 waves.",
        "requirements": ['minWave: 30'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2216
    "Glitter Cloud": {
        "ap_id": 2216,
        "description": "Kill an apparition with a gem bomb.",
        "requirements": [
            'Ritual trait',
            'Apparition element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2217
    "Glowing Armada": {
        "ap_id": 2217,
        "description": "Have 240 gem wasps on the battlefield when the bat...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2218
    "Going Deviant": {
        "ap_id": 2218,
        "description": "Rook to a9",
        "requirements": ['Scroll to edge of the world map'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2219
    "Going for the Weak": {
        "ap_id": 2219,
        "description": "Have a watchtower kill a poisoned monster.",
        "requirements": [
            'Poison skill',
            'Watchtower element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2220
    "Got the Price Back": {
        "ap_id": 2220,
        "description": "Have a pure mana leeching gem with 4.500 hits.",
        "requirements": ['Mana Leech skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2221
    "Great Survivor": {
        "ap_id": 2221,
        "description": "Kill a monster from wave 1 when wave 20 has alread...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2222
    "Green Eyed Ninja": {
        "ap_id": 2222,
        "description": "Entering: The Wilderness",
        "requirements": ['Field N1, U1 or R5'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2223
    "Green Path": {
        "ap_id": 2223,
        "description": "Kill 9.900 green blooded monsters.",
        "requirements": ['Requires "hidden codes"'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2224
    "Green Vial": {
        "ap_id": 2224,
        "description": "Have more than 75% of the monster kills caused by ...",
        "requirements": ['Poison skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2225
    "Green Wand": {
        "ap_id": 2225,
        "description": "Reach wizard level 60.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2226
    "Ground Luck": {
        "ap_id": 2226,
        "description": "Find 3 talisman fragments.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2227
    "Groundfill": {
        "ap_id": 2227,
        "description": "Demolish a trap.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2228
    "Guarding the Fallen Gate": {
        "ap_id": 2228,
        "description": "Have the Corrupted Banishment trait set to level 6...",
        "requirements": ['Corrupted Banishment trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2229
    "Hacked Gem": {
        "ap_id": 2229,
        "description": "Have a grade 3 gem with 1.200 effective max damage...",
        "requirements": ['minGemGrade: 3'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2230
    "Half Full": {
        "ap_id": 2230,
        "description": "Add 32 talisman fragments to your shape collection...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2231
    "Handle With Care": {
        "ap_id": 2231,
        "description": "Kill 300 monsters with orblet explosions.",
        "requirements": ['Orb of Presence skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2232
    "Hard Reset": {
        "ap_id": 2232,
        "description": "Reach 5.000 shrine kills through all the battles.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2233
    "Has Stood Long Enough": {
        "ap_id": 2233,
        "description": "Destroy a monster nest after the last wave has sta...",
        "requirements": ['Monster Nest element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2234
    "Hateful": {
        "ap_id": 2234,
        "description": "Have the Hatred trait set to level 6 or higher and...",
        "requirements": ['Hatred trait'],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 2235
    "Hazardous Materials": {
        "ap_id": 2235,
        "description": "Put your HEV on first",
        "requirements": [
            'Poison skill',
            'Have atleast 1.000 enemies poisoned and alive on a field',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2236
    "Healing Denied": {
        "ap_id": 2236,
        "description": "Destroy 3 healing beacons.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2237
    "Heavily Modified": {
        "ap_id": 2237,
        "description": "Activate all mods.",
        "requirements": ['Requires "hidden codes"'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2238
    "Heavy Hitting": {
        "ap_id": 2238,
        "description": "Have 4 bolt enhanced gems at the same time.",
        "requirements": ['Bolt skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2239
    "Heavy Support": {
        "ap_id": 2239,
        "description": "Have 20 beacons on the field at the same time.",
        "requirements": [
            'Dark Masonry trait',
            'Beacon element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2240
    "Hedgehog": {
        "ap_id": 2240,
        "description": "Kill a swarmling having at least 100 armor.",
        "requirements": ['a swarmling with atleast 100 armor'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2241
    "Helping Hand": {
        "ap_id": 2241,
        "description": "Have a watchtower kill a possessed monster.",
        "requirements": [
            'Possessed Monster element',
            'Watchtower element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2242
    "Hiding Spot": {
        "ap_id": 2242,
        "description": "Open 3 drop holders before wave 3.",
        "requirements": ['Drop Holder element'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2243
    "High Stakes": {
        "ap_id": 2243,
        "description": "Set a battle trait to level 12.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2244
    "High Targets": {
        "ap_id": 2244,
        "description": "Reach 100 non-monsters killed through all the batt...",
        "requirements": ['Ritual trait'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2245
    "Hint of Darkness": {
        "ap_id": 2245,
        "description": "Kill 189 twisted monsters.",
        "requirements": ['Twisted Monster element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2246
    "Hold Still": {
        "ap_id": 2246,
        "description": "Freeze 130 whited out monsters.",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2247
    "Hope has fallen": {
        "ap_id": 2247,
        "description": "Dismantled bunkhouses",
        "requirements": ['Field E3'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2248
    "How About Some Skill Points": {
        "ap_id": 2248,
        "description": "Have 5.000 shadow cores at the start of the battle...",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2249
    "Hungry Little Gem": {
        "ap_id": 2249,
        "description": "Leech 3.600 mana with a grade 1 gem.",
        "requirements": [
            'Mana Leech skill',
            'minGemGrade: 1',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2250
    "Hunt For Hard Targets": {
        "ap_id": 2250,
        "description": "Kill 680 monsters while there are at least 2 wrait...",
        "requirements": [
            'Ritual trait',
            'Wraith element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2251
    "Hurtified": {
        "ap_id": 2251,
        "description": "Kill 240 bleeding monsters.",
        "requirements": ['Bleeding skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2252
    "Hyper Gem": {
        "ap_id": 2252,
        "description": "Have a grade 3 gem with 600 effective max damage.",
        "requirements": ['minGemGrade: 3'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2253
    "I Have Experience": {
        "ap_id": 2253,
        "description": "Reach 50 battles won.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2254
    "I Never Asked For This": {
        "ap_id": 2254,
        "description": "All my aug points spent",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2255
    "I Saw Something": {
        "ap_id": 2255,
        "description": "Kill an apparition.",
        "requirements": [
            'Ritual trait',
            'Apparition element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2256
    "I Warned You...": {
        "ap_id": 2256,
        "description": "Kill a specter while it carries a gem.",
        "requirements": [
            'Ritual trait',
            'Specter element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2257
    "I am Tougher": {
        "ap_id": 2257,
        "description": "Kill 1.360 monsters while there are at least 2 wra...",
        "requirements": [
            'Ritual trait',
            'Wraith element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2258
    "Ice Cube": {
        "ap_id": 2258,
        "description": "Have a Maximum Charge of 300% for the Freeze Spell...",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2259
    "Ice Mage": {
        "ap_id": 2259,
        "description": "Reach 2.500 strike spells cast through all the bat...",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2260
    "Ice Snap": {
        "ap_id": 2260,
        "description": "Gain 90 xp with Freeze spell crowd hits.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2261
    "Ice Stand": {
        "ap_id": 2261,
        "description": "Kill 5 frozen monsters carrying orblets.",
        "requirements": [
            'Freeze skill',
            'Orb of Presence skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2262
    "Ice for Everyone": {
        "ap_id": 2262,
        "description": "Reach 100.000 strike spell hits through all the ba...",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2263
    "Icecracker": {
        "ap_id": 2263,
        "description": "Kill 90 frozen monsters with barrage.",
        "requirements": [
            'Barrage skill',
            'Freeze skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2264
    "Icepicked": {
        "ap_id": 2264,
        "description": "Gain 3.200 xp with Ice Shards spell crowd hits.",
        "requirements": ['Ice Shards skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2265
    "Icy Fingers": {
        "ap_id": 2265,
        "description": "Reach 500 strike spells cast through all the battl...",
        "requirements": [
            'Whiteout skill',
            'Freeze skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2266
    "Impaling Charges": {
        "ap_id": 2266,
        "description": "Deliver 250 one hit kills.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2267
    "Impenetrable": {
        "ap_id": 2267,
        "description": "Have 8 bolt enhanced gems at the same time.",
        "requirements": ['Bolt skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2268
    "Implosion": {
        "ap_id": 2268,
        "description": "Kill a gatekeeper fang with a gem bomb.",
        "requirements": [
            'Gatekeeper element',
            'Field A4',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2269
    "Impressive": {
        "ap_id": 2269,
        "description": "Win a Trial battle without any monster reaching yo...",
        "requirements": ['Trial'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2270
    "Impudence": {
        "ap_id": 2270,
        "description": "Have 6 of your gems destroyed or stolen.",
        "requirements": [
            'Ritual trait',
            'Specter element',
            'Watchtower element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2271
    "In Flames": {
        "ap_id": 2271,
        "description": "Kill 400 spawnlings.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2272
    "In Focus": {
        "ap_id": 2272,
        "description": "Amplify a gem with 8 other gems.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2273
    "In a Blink of an Eye": {
        "ap_id": 2273,
        "description": "Kill 100 monsters while time is frozen.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2274
    "In for a Trait": {
        "ap_id": 2274,
        "description": "Activate a battle trait.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2275
    "Inedible": {
        "ap_id": 2275,
        "description": "Poison 111 frozen monsters.",
        "requirements": [
            'Freeze skill',
            'Poison skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2276
    "Insane Investment": {
        "ap_id": 2276,
        "description": "Reach -20% decreased banishment cost with your orb...",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2277
    "Instant Spawn": {
        "ap_id": 2277,
        "description": "Have a shadow spawn a monster while time is frozen...",
        "requirements": [
            'Ritual trait',
            'Shadow element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2278
    "Ionized Air": {
        "ap_id": 2278,
        "description": "Have the Insulation trait set to level 6 or higher...",
        "requirements": ['Insulation trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2279
    "Is Anyone in There?": {
        "ap_id": 2279,
        "description": "Break a tomb open.",
        "requirements": ['Tomb element'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2280
    "Is This a Match-3 or What?": {
        "ap_id": 2280,
        "description": "Have 90 gems on the battlefield.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2281
    "It Has to Do": {
        "ap_id": 2281,
        "description": "Beat 50 waves using at most grade 2 gems.",
        "requirements": ['minWave: 50'],
        "reward": "skillPoints:3",
        "required_effort": "Major",
    },
    # AP ID: 2282
    "It Hurts!": {
        "ap_id": 2282,
        "description": "Spend 9.000 mana on banishment.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2283
    "It was Abandoned Anyway": {
        "ap_id": 2283,
        "description": "Destroy a dwelling.",
        "requirements": ['Abandoned Dwelling element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2284
    "It's Lagging Alright": {
        "ap_id": 2284,
        "description": "Have 1.200 monsters on the battlefield at the same...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2285
    "It's a Trap": {
        "ap_id": 2285,
        "description": "Don't let any monster touch your orb for 120 beate...",
        "requirements": ['minWave: 120'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2286
    "Itchy Sphere": {
        "ap_id": 2286,
        "description": "Deliver 3.600 banishments with your orb.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2287
    "Jewel Box": {
        "ap_id": 2287,
        "description": "Fill all inventory slots with gems.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2288
    "Jinx Blast": {
        "ap_id": 2288,
        "description": "Kill 30 whited out monsters with bolt.",
        "requirements": [
            'Bolt skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2289
    "Juggler": {
        "ap_id": 2289,
        "description": "Use demolition 7 times.",
        "requirements": ['Demolition skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2290
    "Just Breathe In": {
        "ap_id": 2290,
        "description": "Enhance a pure poison gem having random priority w...",
        "requirements": [
            'Beam skill',
            'Poison skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2291
    "Just Fire More at Them": {
        "ap_id": 2291,
        "description": "Have the Thick Air trait set to level 6 or higher ...",
        "requirements": ['Thick Air trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2292
    "Just Give Me That Mana": {
        "ap_id": 2292,
        "description": "Leech 7.200 mana from whited out monsters.",
        "requirements": [
            'Mana Leech skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2293
    "Just Started": {
        "ap_id": 2293,
        "description": "Reach 10 battles won.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2294
    "Just Take My Mana!": {
        "ap_id": 2294,
        "description": "Spend 900.000 mana on banishment.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2295
    "Keep Losing Keep Harvesting": {
        "ap_id": 2295,
        "description": "Deplete a mana shard while there is a shadow on th...",
        "requirements": [
            'Ritual trait',
            'Mana Shard element',
            'Shadow element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2296
    "Keepers": {
        "ap_id": 2296,
        "description": "Gain 800 mana from drops.",
        "requirements": [
            'Apparition element',
            'Corrupted Mana Shard element',
            'Mana Shard element',
            'Drop Holder element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2297
    "Keeping Low": {
        "ap_id": 2297,
        "description": "Beat 40 waves using at most grade 2 gems.",
        "requirements": ['minWave: 40'],
        "reward": "skillPoints:2",
        "required_effort": "Minor",
    },
    # AP ID: 2298
    "Killed So Many": {
        "ap_id": 2298,
        "description": "Gain 7.200 xp with kill chains.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2299
    "Knowledge Seeker": {
        "ap_id": 2299,
        "description": "Open a wizard stash.",
        "requirements": ['Wizard Stash element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2300
    "Lagging Already?": {
        "ap_id": 2300,
        "description": "Have 900 monsters on the battlefield at the same t...",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 2301
    "Landing Spot": {
        "ap_id": 2301,
        "description": "Demolish 20 or more walls with falling spires.",
        "requirements": [
            'Ritual trait',
            'Spire element',
            'Wall element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2302
    "Laser Slicer": {
        "ap_id": 2302,
        "description": "Have 8 beam enhanced gems at the same time.",
        "requirements": ['Beam skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2303
    "Last Minute Mana": {
        "ap_id": 2303,
        "description": "Leech 500 mana from poisoned monsters.",
        "requirements": [
            'Mana Leech skill',
            'Poison skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2304
    "Legendary": {
        "ap_id": 2304,
        "description": "Create a gem with a raw minimum damage of 30.000 o...",
        "requirements": ['gemSkills: 1'],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2305
    "Let Them Hatch": {
        "ap_id": 2305,
        "description": "Don't crack any egg laid by a swarm queen.",
        "requirements": ['Swarm Queen element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2306
    "Let it Go": {
        "ap_id": 2306,
        "description": "Leave an apparition alive.",
        "requirements": [
            'Ritual trait',
            'Apparition element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2307
    "Let's Have a Look": {
        "ap_id": 2307,
        "description": "Open a drop holder.",
        "requirements": ['Drop Holder element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2308
    "Light My Path": {
        "ap_id": 2308,
        "description": "Have 70 fields lit in Journey mode.",
        "requirements": ['fieldToken: 70'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2309
    "Like a Necro": {
        "ap_id": 2309,
        "description": "Kill 25 monsters with frozen corpse explosion.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2310
    "Limited Vision": {
        "ap_id": 2310,
        "description": "Gain 100 xp with Whiteout spell crowd hits.",
        "requirements": ['Whiteout skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2311
    "Liquid Explosive": {
        "ap_id": 2311,
        "description": "Kill 180 monsters with orblet explosions.",
        "requirements": ['Orb of Presence skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2312
    "Locked and Loaded": {
        "ap_id": 2312,
        "description": "Have 3 pylons charged up to 3 shots each.",
        "requirements": ['Pylons skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2313
    "Long Crawl": {
        "ap_id": 2313,
        "description": "Win a battle using only slowing gems.",
        "requirements": ['Slowing skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2314
    "Long Lasting": {
        "ap_id": 2314,
        "description": "Reach 500 poison kills through all the battles.",
        "requirements": ['Poison skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2315
    "Long Run": {
        "ap_id": 2315,
        "description": "Beat 360 waves.",
        "requirements": [
            'minWave: 360',
            'Endurance',
        ],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2316
    "Longrunner": {
        "ap_id": 2316,
        "description": "Have 60 fields lit in Endurance mode.",
        "requirements": ['Endurance', 'fieldToken: 60'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2317
    "Lost Signal": {
        "ap_id": 2317,
        "description": "Destroy 35 beacons.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 2318
    "Lots of Crit Hits": {
        "ap_id": 2318,
        "description": "Have a pure critical hit gem with 2.000 hits.",
        "requirements": ['Critical Hit skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2319
    "Lots of Scratches": {
        "ap_id": 2319,
        "description": "Reach a kill chain of 300.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2320
    "Major Shutdown": {
        "ap_id": 2320,
        "description": "Destroy 3 monster nests.",
        "requirements": ['Monster Nest element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2321
    "Mana Blinded": {
        "ap_id": 2321,
        "description": "Leech 900 mana from whited out monsters.",
        "requirements": [
            'Mana Leech skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2322
    "Mana Cult": {
        "ap_id": 2322,
        "description": "Leech 6.500 mana from bleeding monsters.",
        "requirements": [
            'Bleeding skill',
            'Mana Leech skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2323
    "Mana First": {
        "ap_id": 2323,
        "description": "Deplete a shard when there are more than 300 swarm...",
        "requirements": ['Mana Shard element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2324
    "Mana Greedy": {
        "ap_id": 2324,
        "description": "Leech 1.800 mana with a grade 1 gem.",
        "requirements": [
            'Mana Leech skill',
            'minGemGrade: 1',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2325
    "Mana Hack": {
        "ap_id": 2325,
        "description": "Have 80.000 initial mana.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2326
    "Mana Magnet": {
        "ap_id": 2326,
        "description": "Win a battle using only mana leeching gems.",
        "requirements": ['Mana Leech skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2327
    "Mana Salvation": {
        "ap_id": 2327,
        "description": "Salvage mana by destroying a gem.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2328
    "Mana Singularity": {
        "ap_id": 2328,
        "description": "Reach mana pool level 20.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2329
    "Mana Tap": {
        "ap_id": 2329,
        "description": "Reach 10.000 mana harvested from shards through al...",
        "requirements": ['Mana Shard element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2330
    "Mana Trader": {
        "ap_id": 2330,
        "description": "Salvage 8.000 mana from gems.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2331
    "Mana in a Bottle": {
        "ap_id": 2331,
        "description": "Have 40.000 initial mana.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 2332
    "Mana is All I Need": {
        "ap_id": 2332,
        "description": "Win a battle with no skill point spent and a battl...",
        "requirements": ['Any battle trait\n\n'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2333
    "Mana of the Dying": {
        "ap_id": 2333,
        "description": "Leech 2.300 mana from poisoned monsters.",
        "requirements": [
            'Mana Leech skill',
            'Poison skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2334
    "Marked Targets": {
        "ap_id": 2334,
        "description": "Reach 10.000 monsters with special properties kill...",
        "requirements": [
            'Endurance',
            'Possessed Monster element',
            'Twisted Monster element',
            'Marked Monster element',
            'minWave: 70',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2335
    "Marmalade": {
        "ap_id": 2335,
        "description": "Don't destroy any of the jars of wasps.",
        "requirements": ['Field X2'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2336
    "Mass Awakening": {
        "ap_id": 2336,
        "description": "Lure 2.500 swarmlings out of a sleeping hive.",
        "requirements": ['Sleeping Hive element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2337
    "Mastery": {
        "ap_id": 2337,
        "description": "Raise a skill to level 70.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2338
    "Max Trap Max leech": {
        "ap_id": 2338,
        "description": "Leech 6.300 mana with a grade 1 gem.",
        "requirements": [
            'Mana Leech skill',
            'minGemGrade: 1',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2339
    "Meet the Spartans": {
        "ap_id": 2339,
        "description": "Have 300 monsters on the battlefield at the same t...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2340
    "Megalithic": {
        "ap_id": 2340,
        "description": "Reach 2.000 structures built through all the battl...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2341
    "Melting Armor": {
        "ap_id": 2341,
        "description": "Tear a total of 10.000 armor with wasp stings.",
        "requirements": ['Armor Tearing skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2342
    "Melting Pulse": {
        "ap_id": 2342,
        "description": "Hit 75 frozen monsters with shrines.",
        "requirements": [
            'Freeze skill',
            'Shrine element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2343
    "Might Need it Later": {
        "ap_id": 2343,
        "description": "Enhance a gem in an amplifier.",
        "requirements": [
            'Amplifiers skill',
            'Bolt skill',
            'Beam skill',
            'Barrage skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2344
    "Mighty": {
        "ap_id": 2344,
        "description": "Create a gem with a raw minimum damage of 3.000 or...",
        "requirements": ['gemSkills: 1'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2345
    "Minefield": {
        "ap_id": 2345,
        "description": "Kill 300 monsters with gems in traps.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2346
    "Miniblasts": {
        "ap_id": 2346,
        "description": "Tear a total of 1.250 armor with wasp stings.",
        "requirements": ['Armor Tearing skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2347
    "Minor Detour": {
        "ap_id": 2347,
        "description": "Build 15 walls.",
        "requirements": ['Wall element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2348
    "Mixing Up": {
        "ap_id": 2348,
        "description": "Beat 50 waves on max Swarmling and Giant dominatio...",
        "requirements": [
            'Swarmling Domination trait',
            'Giant Domination trait',
            'minWave: 50',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2349
    "More Than Enough": {
        "ap_id": 2349,
        "description": "Summon 1.000 monsters by enraging waves.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2350
    "More Wounds": {
        "ap_id": 2350,
        "description": "Kill 125 bleeding monsters with barrage.",
        "requirements": [
            'Barrage skill',
            'Bleeding skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2351
    "Morning March": {
        "ap_id": 2351,
        "description": "Lure 500 swarmlings out of a sleeping hive.",
        "requirements": ['Sleeping Hive element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2352
    "Multifreeze": {
        "ap_id": 2352,
        "description": "Reach 5.000 strike spell hits through all the batt...",
        "requirements": [
            'Ice Shards skill',
            'Whiteout skill',
            'Freeze skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2353
    "Multiline": {
        "ap_id": 2353,
        "description": "Have at least 5 different talisman properties.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2354
    "Multinerf": {
        "ap_id": 2354,
        "description": "Kill 1.600 monsters with prismatic gem wasps.",
        "requirements": ['gemSkills: 6'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2355
    "Mythic Ancient Legendary": {
        "ap_id": 2355,
        "description": "Create a gem with a raw minimum damage of 300.000 ...",
        "requirements": ['gemSkills: 1'],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2356
    "Nature Takes Over": {
        "ap_id": 2356,
        "description": "Have no own buildings on the field at the end of t...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2357
    "Near Death": {
        "ap_id": 2357,
        "description": "Suffer mana loss from a shadow projectile when und...",
        "requirements": ['Shadow element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2358
    "Necrotrophic": {
        "ap_id": 2358,
        "description": "Reach 1.000 poison kills through all the battles.",
        "requirements": ['Poison skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2359
    "Need Lots of Them": {
        "ap_id": 2359,
        "description": "Beat 60 waves using at most grade 2 gems.",
        "requirements": ['minWave: 60'],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2360
    "Need More Rage": {
        "ap_id": 2360,
        "description": "Upgrade a gem in the enraging socket.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2361
    "Needle Storm": {
        "ap_id": 2361,
        "description": "Deal 350 gem wasp stings to creatures.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2362
    "Nest Blaster": {
        "ap_id": 2362,
        "description": "Destroy 2 monster nests before wave 12.",
        "requirements": ['Monster Nest element'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2363
    "Nest Buster": {
        "ap_id": 2363,
        "description": "Destroy 3 monster nests before wave 6.",
        "requirements": ['Monster Nest element'],
        "reward": "skillPoints:3",
        "required_effort": "Minor",
    },
    # AP ID: 2364
    "No Armor Area": {
        "ap_id": 2364,
        "description": "Beat 90 waves using only armor tearing gems.",
        "requirements": [
            'Armor Tearing skill',
            'minWave: 90',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2365
    "No Beacon Zone": {
        "ap_id": 2365,
        "description": "Reach 200 beacons destroyed through all the battle...",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2366
    "No Honor Among Thieves": {
        "ap_id": 2366,
        "description": "Have a watchtower kill a specter.",
        "requirements": [
            'Ritual trait',
            'Specter element',
            'Watchtower element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2367
    "No Land for Swarmlings": {
        "ap_id": 2367,
        "description": "Kill 3.333 swarmlings.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2368
    "No More Rounds": {
        "ap_id": 2368,
        "description": "Kill 60 banished monsters with shrines.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2369
    "No Need to Aim": {
        "ap_id": 2369,
        "description": "Have 4 barrage enhanced gems at the same time.",
        "requirements": ['Barrage skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2370
    "No Place to Hide": {
        "ap_id": 2370,
        "description": "Cast 25 strike spells.",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2371
    "No Stone Unturned": {
        "ap_id": 2371,
        "description": "Open 5 drop holders.",
        "requirements": ['Drop Holder element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2372
    "No Time to Rest": {
        "ap_id": 2372,
        "description": "Have the Haste trait set to level 6 or higher and ...",
        "requirements": ['Haste trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2373
    "No Time to Waste": {
        "ap_id": 2373,
        "description": "Reach 5.000 waves started early through all the ba...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2374
    "No Use of Vitality": {
        "ap_id": 2374,
        "description": "Kill a monster having at least 20.000 hit points.",
        "requirements": ['A monster with atleast 20.000hp'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2375
    "No You Won't!": {
        "ap_id": 2375,
        "description": "Destroy a watchtower before it could fire.",
        "requirements": [
            'Bolt skill',
            'Watchtower element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2376
    "Not Chasing Shadows Anymore": {
        "ap_id": 2376,
        "description": "Kill 4 shadows.",
        "requirements": [
            'Ritual trait',
            'Shadow element',
        ],
        "reward": "skillPoints:3",
        "required_effort": "Major",
    },
    # AP ID: 2377
    "Not So Fast": {
        "ap_id": 2377,
        "description": "Freeze a specter.",
        "requirements": [
            'Freeze skill',
            'Ritual trait',
            'Specter element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2378
    "Not So Omni Anymore": {
        "ap_id": 2378,
        "description": "Destroy 10 omnibeacons.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2379
    "Not Worth It": {
        "ap_id": 2379,
        "description": "Harvest 9.000 mana from a corrupted mana shard.",
        "requirements": ['Corrupted Mana Shard element'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2380
    "Nothing Prevails": {
        "ap_id": 2380,
        "description": "Reach 25.000 poison kills through all the battles.",
        "requirements": ['Poison skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2381
    "Nox Mist": {
        "ap_id": 2381,
        "description": "Win a battle using only poison gems.",
        "requirements": ['Poison skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2382
    "Oh Ven": {
        "ap_id": 2382,
        "description": "Spread the poison",
        "requirements": [
            'Poison skill',
            '90 monsters poisoned at the same time',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2383
    "Ok Flier": {
        "ap_id": 2383,
        "description": "Kill 340 monsters while there are at least 2 wrait...",
        "requirements": [
            'Ritual trait',
            'Wraith element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2384
    "Omelette": {
        "ap_id": 2384,
        "description": "Reach 200 monster eggs cracked through all the bat...",
        "requirements": ['Swarm Queen element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2385
    "Omnibomb": {
        "ap_id": 2385,
        "description": "Destroy a building and a non-monster creature with...",
        "requirements": ['Ritual trait'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2386
    "On the Shoulders of Giants": {
        "ap_id": 2386,
        "description": "Have the Giant Domination trait set to level 6 or ...",
        "requirements": ['Giant Domination trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2387
    "One Hit is All it Takes": {
        "ap_id": 2387,
        "description": "Kill a wraith with one hit.",
        "requirements": [
            'Ritual trait',
            'Wraith element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2388
    "One Less Problem": {
        "ap_id": 2388,
        "description": "Destroy a monster nest while there is a wraith on ...",
        "requirements": [
            'Ritual trait',
            'Monster Nest element',
            'Wraith element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2389
    "One by One": {
        "ap_id": 2389,
        "description": "Deliver 750 one hit kills.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 2390
    "Orange Wand": {
        "ap_id": 2390,
        "description": "Reach wizard level 40.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2391
    "Ouch!": {
        "ap_id": 2391,
        "description": "Spend 900 mana on banishment.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2392
    "Out of Misery": {
        "ap_id": 2392,
        "description": "Kill a monster that is whited out, poisoned, froze...",
        "requirements": [
            'Freeze skill',
            'Poison skill',
            'Slowing skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2393
    "Out of Nowhere": {
        "ap_id": 2393,
        "description": "Kill a whited out possessed monster with bolt.",
        "requirements": [
            'Bolt skill',
            'Whiteout skill',
            'Possessed Monster element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2394
    "Outwhited": {
        "ap_id": 2394,
        "description": "Gain 4.700 xp with Whiteout spell crowd hits.",
        "requirements": ['Whiteout skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2395
    "Overheated": {
        "ap_id": 2395,
        "description": "Kill a giant with beam shot.",
        "requirements": ['Beam skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2396
    "Overpecked": {
        "ap_id": 2396,
        "description": "Deal 100 gem wasp stings to the same monster.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2397
    "Painful Leech": {
        "ap_id": 2397,
        "description": "Leech 3.200 mana from bleeding monsters.",
        "requirements": [
            'Bleeding skill',
            'Mana Leech skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2398
    "Paranormal Paragon": {
        "ap_id": 2398,
        "description": "Reach 500 non-monsters killed through all the batt...",
        "requirements": ['Ritual trait'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2399
    "Pat on the Back": {
        "ap_id": 2399,
        "description": "Amplify a gem.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2400
    "Path of Splats": {
        "ap_id": 2400,
        "description": "Kill 400 monsters.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2401
    "Peek Into The Abyss": {
        "ap_id": 2401,
        "description": "Kill a monster with all battle traits set to the h...",
        "requirements": [
            'Adaptive Carapace trait',
            'Dark Masonry trait',
            'Swarmling Domination trait',
            'Overcrowd trait',
            'Corrupted Banishment trait',
            'Awakening trait',
            'Insulation trait',
            'Hatred trait',
            'Swarmling Parasites trait',
            'Haste trait',
            'Thick Air trait',
            'Vital Link trait',
            'Giant Domination trait',
            'Strength in Numbers trait',
            'Ritual trait',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2402
    "Pest Control": {
        "ap_id": 2402,
        "description": "Kill 333 swarmlings.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2403
    "Plentiful": {
        "ap_id": 2403,
        "description": "Have 1.000 shadow cores at the start of the battle...",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2404
    "Pointed Pain": {
        "ap_id": 2404,
        "description": "Deal 50 gem wasp stings to creatures.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2405
    "Popped": {
        "ap_id": 2405,
        "description": "Kill at least 30 gatekeeper fangs.",
        "requirements": [
            'Gatekeeper element',
            'Field A4',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2406
    "Popped Eggs": {
        "ap_id": 2406,
        "description": "Kill a swarm queen with a bolt.",
        "requirements": [
            'Bolt skill',
            'Swarm Queen element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2407
    "Popping Lights": {
        "ap_id": 2407,
        "description": "Destroy 5 beacons.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2408
    "Power Exchange": {
        "ap_id": 2408,
        "description": "Build 25 amplifiers.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2409
    "Power Flow": {
        "ap_id": 2409,
        "description": "Build 15 amplifiers.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2410
    "Power Node": {
        "ap_id": 2410,
        "description": "Activate the same shrine 5 times.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2411
    "Power Overwhelming": {
        "ap_id": 2411,
        "description": "Reach mana pool level 15.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 2412
    "Power Sharing": {
        "ap_id": 2412,
        "description": "Build 5 amplifiers.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2413
    "Powerful": {
        "ap_id": 2413,
        "description": "Create a gem with a raw minimum damage of 300 or h...",
        "requirements": ['gemSkills: 1'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2414
    "Precious": {
        "ap_id": 2414,
        "description": "Get a gem from a drop holder.",
        "requirements": ['Drop Holder element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2415
    "Prismatic": {
        "ap_id": 2415,
        "description": "Create a gem of 6 components.",
        "requirements": ['gemSkills: 6'],
        "reward": "skillPoints:2",
        "required_effort": "Minor",
    },
    # AP ID: 2416
    "Prismatic Takeaway": {
        "ap_id": 2416,
        "description": "Have a specter steal a gem of 6 components.",
        "requirements": [
            'Specter element',
            'gemSkills: 6',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2417
    "Punching Deep": {
        "ap_id": 2417,
        "description": "Tear a total of 2.500 armor with wasp stings.",
        "requirements": ['Armor Tearing skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2418
    "Puncture Therapy": {
        "ap_id": 2418,
        "description": "Deal 950 gem wasp stings to creatures.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2419
    "Punctured Texture": {
        "ap_id": 2419,
        "description": "Deal 5.000 gem wasp stings to buildings.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2420
    "Puncturing Shots": {
        "ap_id": 2420,
        "description": "Deliver 75 one hit kills.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2421
    "Purged": {
        "ap_id": 2421,
        "description": "Kill 179 marked monsters.",
        "requirements": ['Marked Monster element', 'minWave: 70'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2422
    "Purist": {
        "ap_id": 2422,
        "description": "Beat 120 waves and don't use any strike or gem enh...",
        "requirements": ['minWave: 120'],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 2423
    "Purple Wand": {
        "ap_id": 2423,
        "description": "Reach wizard level 200.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2424
    "Put Those Down Now!": {
        "ap_id": 2424,
        "description": "Have 10 orblets carried by monsters at the same ti...",
        "requirements": ['Orb of Presence skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2425
    "Puzzling Bunch": {
        "ap_id": 2425,
        "description": "Add 16 talisman fragments to your shape collection...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2426
    "Pylons of Destruction": {
        "ap_id": 2426,
        "description": "Reach 5.000 pylon kills through all the battles.",
        "requirements": ['Pylons skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2427
    "Quadpierced": {
        "ap_id": 2427,
        "description": "Cast 4 ice shards on the same monster.",
        "requirements": ['Ice Shards skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2428
    "Quick Circle": {
        "ap_id": 2428,
        "description": "Create a grade 12 gem before wave 12.",
        "requirements": ['minGemGrade: 12'],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2429
    "Quicksave": {
        "ap_id": 2429,
        "description": "Instantly drop a gem to your inventory.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2430
    "Quite a List": {
        "ap_id": 2430,
        "description": "Have at least 15 different talisman properties.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2431
    "Rage Control": {
        "ap_id": 2431,
        "description": "Kill 400 enraged swarmlings with barrage.",
        "requirements": ['Barrage skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2432
    "Rageout": {
        "ap_id": 2432,
        "description": "Enrage 30 waves.",
        "requirements": ['minWave: 30'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2433
    "Rageroom": {
        "ap_id": 2433,
        "description": "Build 100 walls and start 100 enraged waves.",
        "requirements": [
            'Wall element',
            'minWave: 100',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2434
    "Raging Habit": {
        "ap_id": 2434,
        "description": "Enrage 80 waves.",
        "requirements": ['minWave: 80'],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 2435
    "Rainbow Strike": {
        "ap_id": 2435,
        "description": "Kill 900 monsters with prismatic gem wasps.",
        "requirements": ['gemSkills: 6'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2436
    "Raindrop": {
        "ap_id": 2436,
        "description": "Drop 18 gem bombs while it's raining.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2437
    "Razor Path": {
        "ap_id": 2437,
        "description": "Build 60 traps.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2438
    "Red Orange": {
        "ap_id": 2438,
        "description": "Leech 700 mana from bleeding monsters.",
        "requirements": [
            'Bleeding skill',
            'Mana Leech skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2439
    "Red Wand": {
        "ap_id": 2439,
        "description": "Reach wizard level 500.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2440
    "Refrost": {
        "ap_id": 2440,
        "description": "Freeze 111 frozen monsters.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2441
    "Regaining Knowledge": {
        "ap_id": 2441,
        "description": "Acquire 5 skills.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2442
    "Renzokuken": {
        "ap_id": 2442,
        "description": "Break your frozen time gem bombing limits",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2443
    "Resourceful": {
        "ap_id": 2443,
        "description": "Reach 5.000 mana harvested from shards through all...",
        "requirements": ['Mana Shard element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2444
    "Restless": {
        "ap_id": 2444,
        "description": "Call 35 waves early.",
        "requirements": ['minWave: 35'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2445
    "Return of Investment": {
        "ap_id": 2445,
        "description": "Leech 900 mana with a grade 1 gem.",
        "requirements": [
            'Mana Leech skill',
            'minGemGrade: 1',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2446
    "Riding the Waves": {
        "ap_id": 2446,
        "description": "Reach 1.000 waves beaten through all the battles.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2447
    "Rising Tide": {
        "ap_id": 2447,
        "description": "Banish 150 monsters while there are 2 or more wrai...",
        "requirements": [
            'Ritual trait',
            'Wraith element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2448
    "Roof Knocking": {
        "ap_id": 2448,
        "description": "Deal 20 gem wasp stings to buildings.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2449
    "Root Canal": {
        "ap_id": 2449,
        "description": "Destroy 2 monster nests.",
        "requirements": ['Monster Nest element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2450
    "Rooting From Afar": {
        "ap_id": 2450,
        "description": "Kill a gatekeeper fang with a barrage shell.",
        "requirements": [
            'Barrage skill',
            'Gatekeeper element',
            'Field A4',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2451
    "Rotten Aura": {
        "ap_id": 2451,
        "description": "Leech 1.100 mana from poisoned monsters.",
        "requirements": [
            'Mana Leech skill',
            'Poison skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2452
    "Rough Path": {
        "ap_id": 2452,
        "description": "Kill 60 monsters with gems in traps.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2453
    "Round Cut": {
        "ap_id": 2453,
        "description": "Create a grade 12 gem.",
        "requirements": ['minGemGrade: 12'],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2454
    "Round Cut Plus": {
        "ap_id": 2454,
        "description": "Create a grade 16 gem.",
        "requirements": ['minGemGrade: 16'],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2455
    "Route Planning": {
        "ap_id": 2455,
        "description": "Destroy 5 barricades.",
        "requirements": ['Barricade element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2456
    "Rugged Defense": {
        "ap_id": 2456,
        "description": "Have 16 bolt enhanced gems at the same time.",
        "requirements": ['Bolt skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2457
    "Ruined Ghost Town": {
        "ap_id": 2457,
        "description": "Destroy 5 dwellings.",
        "requirements": ['Abandoned Dwelling element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2458
    "Safe and Secure": {
        "ap_id": 2458,
        "description": "Strengthen your orb with 7 gems in amplifiers.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2459
    "Salvation": {
        "ap_id": 2459,
        "description": "Hit 150 whited out monsters with shrines.",
        "requirements": [
            'Whiteout skill',
            'Shrine element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2460
    "Scare Tactics": {
        "ap_id": 2460,
        "description": "Cast 5 strike spells.",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2461
    "Scour You All": {
        "ap_id": 2461,
        "description": "Kill 660 banished monsters with shrines.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2462
    "Second Thoughts": {
        "ap_id": 2462,
        "description": "Add a different enhancement on an enhanced gem.",
        "requirements": [
            'Bolt skill',
            'Beam skill',
            'Barrage skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2463
    "Seen Battle": {
        "ap_id": 2463,
        "description": "Have a grade 1 gem with 500 hits.",
        "requirements": ['minGemGrade: 1'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2464
    "Settlement": {
        "ap_id": 2464,
        "description": "Build 15 towers.",
        "requirements": ['Tower element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2465
    "Shaken Ice": {
        "ap_id": 2465,
        "description": "Hit 475 frozen monsters with shrines.",
        "requirements": [
            'Freeze skill',
            'Shrine element',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2466
    "Shapeshifter": {
        "ap_id": 2466,
        "description": "Complete your talisman fragment shape collection.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2467
    "Shard Siphon": {
        "ap_id": 2467,
        "description": "Reach 20.000 mana harvested from shards through al...",
        "requirements": ['Mana Shard element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2468
    "Shardalot": {
        "ap_id": 2468,
        "description": "Cast 6 ice shards on the same monster.",
        "requirements": ['Ice Shards skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2469
    "Sharp Shot": {
        "ap_id": 2469,
        "description": "Kill a shadow with a shot fired by a gem having at...",
        "requirements": [
            'Ritual trait',
            'Shadow element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2470
    "Sharpened": {
        "ap_id": 2470,
        "description": "Enhance a gem in a trap.",
        "requirements": [
            'Traps skill',
            'Beam skill',
            'Bolt skill',
            'Barrage skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2471
    "Shatter Them All": {
        "ap_id": 2471,
        "description": "Reach 1.000 beacons destroyed through all the batt...",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2472
    "Shattered Orb": {
        "ap_id": 2472,
        "description": "Lose a battle.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2473
    "Shattered Waves": {
        "ap_id": 2473,
        "description": "Hit 225 frozen monsters with shrines.",
        "requirements": [
            'Freeze skill',
            'Shrine element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2474
    "Shattering": {
        "ap_id": 2474,
        "description": "Kill 90 frozen monsters with bolt.",
        "requirements": [
            'Bolt skill',
            'Freeze skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2475
    "Shavings All Around": {
        "ap_id": 2475,
        "description": "Win a battle using only armor tearing gems.",
        "requirements": ['Armor Tearing skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2476
    "Shell Shock": {
        "ap_id": 2476,
        "description": "Have 8 barrage enhanced gems at the same time.",
        "requirements": ['Barrage skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2477
    "Shieldbreaker": {
        "ap_id": 2477,
        "description": "Destroy 3 shield beacons.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2478
    "Shooting Where it Hurts": {
        "ap_id": 2478,
        "description": "Beat 90 waves using only critical hit gems.",
        "requirements": [
            'Critical Hit skill',
            'minWave: 90',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2479
    "Short Tempered": {
        "ap_id": 2479,
        "description": "Call 5 waves early.",
        "requirements": ['minWave: 5'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2480
    "Shovel Swing": {
        "ap_id": 2480,
        "description": "Hit 15 frozen monsters with shrines.",
        "requirements": [
            'Freeze skill',
            'Shrine element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2481
    "Shred Some Armor": {
        "ap_id": 2481,
        "description": "Have a pure armor tearing gem with 3.000 hits.",
        "requirements": ['Armor Tearing skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2482
    "Shrinemaster": {
        "ap_id": 2482,
        "description": "Reach 20.000 shrine kills through all the battles.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2483
    "Sigil": {
        "ap_id": 2483,
        "description": "Fill all the sockets in your talisman with fragmen...",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2484
    "Size Matters": {
        "ap_id": 2484,
        "description": "Beat 100 waves on max Swarmling and Giant dominati...",
        "requirements": [
            'Swarmling Domination trait',
            'Giant Domination trait',
            'minWave: 100',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2485
    "Skillful": {
        "ap_id": 2485,
        "description": "Acquire and raise all skills to level 5 or above.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2486
    "Skylark": {
        "ap_id": 2486,
        "description": "Call every wave early in a battle.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2487
    "Sliced Ice": {
        "ap_id": 2487,
        "description": "Gain 1.800 xp with Ice Shards spell crowd hits.",
        "requirements": ['Ice Shards skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2488
    "Slime Block": {
        "ap_id": 2488,
        "description": "Nine slimeballs is all it takes",
        "requirements": ['A monster with atleast 20.000hp'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2489
    "Slow Creep": {
        "ap_id": 2489,
        "description": "Poison 130 whited out monsters.",
        "requirements": [
            'Poison skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2490
    "Slow Drain": {
        "ap_id": 2490,
        "description": "Deal 10.000 poison damage to a monster.",
        "requirements": ['Poison skill'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2491
    "Slow Motion": {
        "ap_id": 2491,
        "description": "Enhance a pure slowing gem having random priority ...",
        "requirements": [
            'Beam skill',
            'Slowing skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2492
    "Slowly but Surely": {
        "ap_id": 2492,
        "description": "Beat 90 waves using only slowing gems.",
        "requirements": [
            'Slowing skill',
            'minWave: 90',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2493
    "Smoke in the Sky": {
        "ap_id": 2493,
        "description": "Reach 20 non-monsters killed through all the battl...",
        "requirements": ['Ritual trait'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2494
    "Snatchers": {
        "ap_id": 2494,
        "description": "Gain 3.200 mana from drops.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2495
    "Snow Blower": {
        "ap_id": 2495,
        "description": "Kill 20 frozen monsters with barrage.",
        "requirements": [
            'Barrage skill',
            'Freeze skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2496
    "Snow Dust": {
        "ap_id": 2496,
        "description": "Kill 95 frozen monsters while it's snowing.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2497
    "Snowball": {
        "ap_id": 2497,
        "description": "Drop 27 gem bombs while it's snowing.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2498
    "Snowdust Blindness": {
        "ap_id": 2498,
        "description": "Gain 2.300 xp with Whiteout spell crowd hits.",
        "requirements": ['Whiteout skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2499
    "So Attached": {
        "ap_id": 2499,
        "description": "Win a Trial battle without losing any orblets.",
        "requirements": ['Trial'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2500
    "So Early": {
        "ap_id": 2500,
        "description": "Reach 1.000 waves started early through all the ba...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2501
    "So Enduring": {
        "ap_id": 2501,
        "description": "Have the Adaptive Carapace trait set to level 6 or...",
        "requirements": ['Adaptive Carapace trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2502
    "Socketed Rage": {
        "ap_id": 2502,
        "description": "Enrage a wave.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2503
    "Something Special": {
        "ap_id": 2503,
        "description": "Reach 2.000 monsters with special properties kille...",
        "requirements": [
            'Endurance',
            'Possessed Monster element',
            'Twisted Monster element',
            'Marked Monster element',
            'minWave: 70',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2504
    "Sparse Snares": {
        "ap_id": 2504,
        "description": "Build 10 traps.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2505
    "Special Purpose": {
        "ap_id": 2505,
        "description": "Change the target priority of a gem.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2506
    "Spectrin Tetramer": {
        "ap_id": 2506,
        "description": "Have the Vital Link trait set to level 6 or higher...",
        "requirements": ['Vital Link trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2507
    "Spitting Darkness": {
        "ap_id": 2507,
        "description": "Leave a gatekeeper fang alive until it can launch ...",
        "requirements": [
            'Gatekeeper element',
            'Field A4',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2508
    "Splash Swim Splash": {
        "ap_id": 2508,
        "description": "Full of oxygen",
        "requirements": ['Click on water in a field\nRequires a field with water'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2509
    "Starter Pack": {
        "ap_id": 2509,
        "description": "Add 8 talisman fragments to your shape collection.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2510
    "Stash No More": {
        "ap_id": 2510,
        "description": "Destroy a previously opened wizard stash.",
        "requirements": ['Wizard Stash element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2511
    "Stay Some More": {
        "ap_id": 2511,
        "description": "Cast freeze on an apparition 3 times.",
        "requirements": [
            'Freeze skill',
            'Ritual trait',
            'Apparition element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2512
    "Still Alive": {
        "ap_id": 2512,
        "description": "Beat 60 waves.",
        "requirements": ['minWave: 60'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2513
    "Still Chill": {
        "ap_id": 2513,
        "description": "Gain 1.500 xp with Freeze spell crowd hits.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2514
    "Still Lit": {
        "ap_id": 2514,
        "description": "Have 15 or more beacons standing at the end of the...",
        "requirements": [
            'Dark Masonry trait',
            'Beacon element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2515
    "Still No Match": {
        "ap_id": 2515,
        "description": "Destroy an omnibeacon.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2516
    "Sting Stack": {
        "ap_id": 2516,
        "description": "Deal 1.000 gem wasp stings to buildings.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2517
    "Stinging Sphere": {
        "ap_id": 2517,
        "description": "Deliver 100 banishments with your orb.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2518
    "Stingy Cloud": {
        "ap_id": 2518,
        "description": "Reach 5.000 gem wasp kills through all the battles...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2519
    "Stingy Downfall": {
        "ap_id": 2519,
        "description": "Deal 400 wasp stings to a spire.",
        "requirements": [
            'Ritual trait',
            'Spire element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2520
    "Stirring Up the Nest": {
        "ap_id": 2520,
        "description": "Deliver gem bomb and wasp kills only.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2521
    "Stockpile": {
        "ap_id": 2521,
        "description": "Have 30 fragments in your talisman inventory.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2522
    "Stolen Shine": {
        "ap_id": 2522,
        "description": "Leech 2.700 mana from whited out monsters.",
        "requirements": [
            'Mana Leech skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2523
    "Stone Monument": {
        "ap_id": 2523,
        "description": "Build 240 walls.",
        "requirements": ['Wall element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2524
    "Stones to Dust": {
        "ap_id": 2524,
        "description": "Demolish one of your structures.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2525
    "Stormbringer": {
        "ap_id": 2525,
        "description": "Reach 1.000 strike spells cast through all the bat...",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2526
    "Stormed Beacons": {
        "ap_id": 2526,
        "description": "Destroy 15 beacons.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2527
    "Strike Anywhere": {
        "ap_id": 2527,
        "description": "Cast a strike spell.",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2528
    "Stronger Than Before": {
        "ap_id": 2528,
        "description": "Set corrupted banishment to level 12 and banish a ...",
        "requirements": ['Corrupted Banishment trait'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2529
    "Stumbling": {
        "ap_id": 2529,
        "description": "Hit the same monster with traps 100 times.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2530
    "Super Gem": {
        "ap_id": 2530,
        "description": "Create a grade 3 gem with 300 effective max damage...",
        "requirements": ['minGemGrade: 3'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2531
    "Supply Line Cut": {
        "ap_id": 2531,
        "description": "Kill a swarm queen with a barrage shell.",
        "requirements": [
            'Barrage skill',
            'Swarm Queen element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2532
    "Swarmling Season": {
        "ap_id": 2532,
        "description": "Kill 999 swarmlings.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2533
    "Swift Death": {
        "ap_id": 2533,
        "description": "Kill the gatekeeper with a bolt.",
        "requirements": [
            'Bolt skill',
            'Gatekeeper element',
            'Field A4',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2534
    "Swift Deployment": {
        "ap_id": 2534,
        "description": "Have 20 gems on the battlefield before wave 5.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2535
    "Take Them I Have More": {
        "ap_id": 2535,
        "description": "Have 12 of your gems destroyed or stolen.",
        "requirements": [
            'Ritual trait',
            'Specter element',
            'Watchtower element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2536
    "Takers": {
        "ap_id": 2536,
        "description": "Gain 1.600 mana from drops.",
        "requirements": [
            'Apparition element',
            'Corrupted Mana Shard element',
            'Drop Holder element',
            'Mana Shard element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2537
    "Tapped Essence": {
        "ap_id": 2537,
        "description": "Leech 1.500 mana from bleeding monsters.",
        "requirements": [
            'Bleeding skill',
            'Mana Leech skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2538
    "Targeting Weak Points": {
        "ap_id": 2538,
        "description": "Win a battle using only critical hit gems.",
        "requirements": ['Critical Hit skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2539
    "Taste All The Affixes": {
        "ap_id": 2539,
        "description": "Kill 2.500 monsters with prismatic gem wasps.",
        "requirements": ['gemSkills: 6'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2540
    "Tasting the Darkness": {
        "ap_id": 2540,
        "description": "Break 3 tombs open.",
        "requirements": ['Tomb element'],
        "reward": "skillPoints:3",
        "required_effort": "Minor",
    },
    # AP ID: 2541
    "Teleport Lag": {
        "ap_id": 2541,
        "description": "Banish a monster at least 5 times.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2542
    "Ten Angry Waves": {
        "ap_id": 2542,
        "description": "Enrage 10 waves.",
        "requirements": ['minWave: 10'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2543
    "That Was Rude": {
        "ap_id": 2543,
        "description": "Lose a gem with more than 1.000 hits to a watchtow...",
        "requirements": ['Watchtower element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2544
    "That Was Your Last Move": {
        "ap_id": 2544,
        "description": "Kill a wizard hunter while it's attacking one of y...",
        "requirements": ['Wizard Hunter element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2545
    "That one!": {
        "ap_id": 2545,
        "description": "Select a monster.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2546
    "The Gathering": {
        "ap_id": 2546,
        "description": "Summon 500 monsters by enraging waves.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Major",
    },
    # AP ID: 2547
    "The Horror": {
        "ap_id": 2547,
        "description": "Lose 3.333 mana to shadows.",
        "requirements": [
            'Ritual trait',
            'Shadow element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2548
    "The Killing Will Never Stop": {
        "ap_id": 2548,
        "description": "Reach 200.000 monsters killed through all the batt...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2549
    "The Mana Reaper": {
        "ap_id": 2549,
        "description": "Reach 100.000 mana harvested from shards through a...",
        "requirements": ['Mana Shard element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2550
    "The Messenger Must Die": {
        "ap_id": 2550,
        "description": "Kill a shadow.",
        "requirements": [
            'Ritual trait',
            'Shadow element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2551
    "The Peeler": {
        "ap_id": 2551,
        "description": "Create a grade 12 pure armor tearing gem.",
        "requirements": [
            'Armor Tearing skill',
            'minGemGrade: 12',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2552
    "The Price of Obsession": {
        "ap_id": 2552,
        "description": "Kill 590 banished monsters.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2553
    "There it is!": {
        "ap_id": 2553,
        "description": "Select a building.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2554
    "There's No Time": {
        "ap_id": 2554,
        "description": "Call 140 waves early.",
        "requirements": [
            'minWave: 140',
            'Endurance',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2555
    "They Are Millions": {
        "ap_id": 2555,
        "description": "Reach 1.000.000 monsters killed through all the ba...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2556
    "They Are Still Here": {
        "ap_id": 2556,
        "description": "Kill 2 apparitions.",
        "requirements": [
            'Ritual trait',
            'Apparition element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2557
    "They Keep Coming": {
        "ap_id": 2557,
        "description": "Kill 12.000 monsters.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 2558
    "Thin Ice": {
        "ap_id": 2558,
        "description": "Kill 20 frozen monsters with gems in traps.",
        "requirements": [
            'Freeze skill',
            'Traps skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2559
    "Thin Them Out": {
        "ap_id": 2559,
        "description": "Have the Strength in Numbers trait set to level 6 ...",
        "requirements": ['Strength in Numbers trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2560
    "Third Grade": {
        "ap_id": 2560,
        "description": "Create a grade 3 gem.",
        "requirements": ['minGemGrade: 3'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2561
    "Thorned Sphere": {
        "ap_id": 2561,
        "description": "Deliver 400 banishments with your orb.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Minor",
    },
    # AP ID: 2562
    "Through All Layers": {
        "ap_id": 2562,
        "description": "Kill a monster having at least 200 armor.",
        "requirements": ['A monster with atleast 200 armor'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2563
    "Thunderstruck": {
        "ap_id": 2563,
        "description": "Kill 120 monsters with gem bombs and wasps.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2564
    "Tightly Secured": {
        "ap_id": 2564,
        "description": "Don't let any monster touch your orb for 60 beaten...",
        "requirements": ['minWave: 60'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2565
    "Time Bent": {
        "ap_id": 2565,
        "description": "Have 90 monsters slowed at the same time.",
        "requirements": ['Slowing skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2566
    "Time to Rise": {
        "ap_id": 2566,
        "description": "Have the Awakening trait set to level 6 or higher ...",
        "requirements": ['Awakening trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2567
    "Time to Upgrade": {
        "ap_id": 2567,
        "description": "Have a grade 1 gem with 4.500 hits.",
        "requirements": ['minGemGrade: 1'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2568
    "Tiny but Deadly": {
        "ap_id": 2568,
        "description": "Reach 50.000 gem wasp kills through all the battle...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2569
    "To the Last Drop": {
        "ap_id": 2569,
        "description": "Leech 4.700 mana from poisoned monsters.",
        "requirements": [
            'Mana Leech skill',
            'Poison skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2570
    "Tomb No Matter What": {
        "ap_id": 2570,
        "description": "Open a tomb while there is a spire on the battlefi...",
        "requirements": [
            'Ritual trait',
            'Spire element',
            'Tomb element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2571
    "Tomb Raiding": {
        "ap_id": 2571,
        "description": "Break a tomb open before wave 15.",
        "requirements": ['Tomb element'],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 2572
    "Tomb Stomping": {
        "ap_id": 2572,
        "description": "Break 4 tombs open.",
        "requirements": ['Tomb element'],
        "reward": "skillPoints:3",
        "required_effort": "Major",
    },
    # AP ID: 2573
    "Too Curious": {
        "ap_id": 2573,
        "description": "Break 2 tombs open.",
        "requirements": ['Tomb element'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2574
    "Too Easy": {
        "ap_id": 2574,
        "description": "Win a Trial battle with at least 3 waves enraged.",
        "requirements": [
            'minWave: 3',
            'Trial',
        ],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 2575
    "Too Long to Hold Your Breath": {
        "ap_id": 2575,
        "description": "Beat 90 waves using only poison gems.",
        "requirements": [
            'Poison skill',
            'minWave: 90',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2576
    "Towerful": {
        "ap_id": 2576,
        "description": "Build 5 towers.",
        "requirements": ['Tower element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2577
    "Trapland": {
        "ap_id": 2577,
        "description": "And it's bloody too",
        "requirements": [
            'Traps skill',
            'Complete a level using only traps and no poison gems',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2578
    "Trembling": {
        "ap_id": 2578,
        "description": "Kill 1.500 monsters with gems in traps.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2579
    "Tricolor": {
        "ap_id": 2579,
        "description": "Create a gem of 3 components.",
        "requirements": ['gemSkills: 3'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2580
    "Troll's Eye": {
        "ap_id": 2580,
        "description": "Kill a giant with one shot.",
        "requirements": ['Bolt skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2581
    "Tumbling Billows": {
        "ap_id": 2581,
        "description": "Have the Swarmling Domination trait set to level 6...",
        "requirements": ['Swarmling Domination trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2582
    "Twice the Blast": {
        "ap_id": 2582,
        "description": "Have 2 barrage enhanced gems at the same time.",
        "requirements": ['Barrage skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2583
    "Twice the Shock": {
        "ap_id": 2583,
        "description": "Hit the same monster 2 times with shrines.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2584
    "Twice the Steepness": {
        "ap_id": 2584,
        "description": "Kill 170 monsters while there are at least 2 wrait...",
        "requirements": [
            'Ritual trait',
            'Wraith element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2585
    "Twice the Terror": {
        "ap_id": 2585,
        "description": "Kill 2 shadows.",
        "requirements": [
            'Ritual trait',
            'Shadow element',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 2586
    "Unarmed": {
        "ap_id": 2586,
        "description": "Have no gems when wave 20 starts.",
        "requirements": ['minWave: 20'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2587
    "Under Pressure": {
        "ap_id": 2587,
        "description": "Shoot down 340 shadow projectiles.",
        "requirements": [
            'Ritual trait',
            'Shadow element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2588
    "Unending Flow": {
        "ap_id": 2588,
        "description": "Kill 24.000 monsters.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2589
    "Unholy Stack": {
        "ap_id": 2589,
        "description": "Reach 20.000 monsters with special properties kill...",
        "requirements": [
            'Endurance',
            'Possessed Monster element',
            'Twisted Monster element',
            'Marked Monster element',
            'minWave: 70',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2590
    "Uninvited": {
        "ap_id": 2590,
        "description": "Summon 100 monsters by enraging waves.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Minor",
    },
    # AP ID: 2591
    "Unsupportive": {
        "ap_id": 2591,
        "description": "Reach 100 beacons destroyed through all the battle...",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2592
    "Uraj and Khalis": {
        "ap_id": 2592,
        "description": "Activate the lanterns",
        "requirements": [
            'Lanterns skill',
            'Field H3',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2593
    "Urban Warfare": {
        "ap_id": 2593,
        "description": "Destroy a dwelling and kill a monster with one gem...",
        "requirements": ['Abandoned Dwelling element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2594
    "Vantage Point Down": {
        "ap_id": 2594,
        "description": "Demolish a pylon.",
        "requirements": ['Pylons skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2595
    "Versatile Charm": {
        "ap_id": 2595,
        "description": "Have at least 10 different talisman properties.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2596
    "Violet Ray": {
        "ap_id": 2596,
        "description": "Kill 20 frozen monsters with beam.",
        "requirements": [
            'Beam skill',
            'Freeze skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2597
    "Warming Up": {
        "ap_id": 2597,
        "description": "Have a grade 1 gem with 100 hits.",
        "requirements": ['minGemGrade: 1'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2598
    "Wash Away": {
        "ap_id": 2598,
        "description": "Kill 110 monsters while it's raining.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2599
    "Wasp Defense": {
        "ap_id": 2599,
        "description": "Smash 3 jars of wasps before wave 3.",
        "requirements": ['Field X2'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2600
    "Wasp Storm": {
        "ap_id": 2600,
        "description": "Kill 360 monsters with gem bombs and wasps.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2601
    "Waspocalypse": {
        "ap_id": 2601,
        "description": "Kill 1.080 monsters with gem bombs and wasps.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2602
    "Watch Your Step": {
        "ap_id": 2602,
        "description": "Build 40 traps.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2603
    "Wave Pecking": {
        "ap_id": 2603,
        "description": "Summon 20 monsters by enraging waves.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2604
    "Wave Smasher": {
        "ap_id": 2604,
        "description": "Reach 10.000 waves beaten through all the battles.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2605
    "Waves for Breakfast": {
        "ap_id": 2605,
        "description": "Reach 2.000 waves beaten through all the battles.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2606
    "Wavy": {
        "ap_id": 2606,
        "description": "Reach 500 waves beaten through all the battles.",
        "requirements": [
            'minWave: 500',
            'Endurance',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2607
    "We Just Wanna Be Free": {
        "ap_id": 2607,
        "description": "More than blue triangles",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2608
    "Weakened Wallet": {
        "ap_id": 2608,
        "description": "Leech 5.400 mana from whited out monsters.",
        "requirements": [
            'Mana Leech skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2609
    "Weather Tower": {
        "ap_id": 2609,
        "description": "Activate a shrine while raining.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2610
    "Weather of Wasps": {
        "ap_id": 2610,
        "description": "Deal 3950 gem wasp stings to creatures.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2611
    "Well Defended": {
        "ap_id": 2611,
        "description": "Don't let any monster touch your orb for 20 beaten...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2612
    "Well Earned": {
        "ap_id": 2612,
        "description": "Reach 500 battles won.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2613
    "Well Laid": {
        "ap_id": 2613,
        "description": "Have 10 gems on the battlefield.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2614
    "Well Prepared": {
        "ap_id": 2614,
        "description": "Have 20.000 initial mana.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2615
    "Well Trained for This": {
        "ap_id": 2615,
        "description": "Kill a wraith with a shot fired by a gem having at...",
        "requirements": [
            'Ritual trait',
            'Wraith element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2616
    "Whacked": {
        "ap_id": 2616,
        "description": "Kill a specter with one hit.",
        "requirements": [
            'Ritual trait',
            'Specter element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2617
    "What Are You Waiting For?": {
        "ap_id": 2617,
        "description": "Have all spells charged to 200%.",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2618
    "White Ray": {
        "ap_id": 2618,
        "description": "Kill 90 frozen monsters with beam.",
        "requirements": [
            'Beam skill',
            'Freeze skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2619
    "White Ring of Death": {
        "ap_id": 2619,
        "description": "Gain 4.900 xp with Ice Shards spell crowd hits.",
        "requirements": ['Ice Shards skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2620
    "White Wand": {
        "ap_id": 2620,
        "description": "Reach wizard level 10.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2621
    "Why Not": {
        "ap_id": 2621,
        "description": "Enhance a gem in the enraging socket.",
        "requirements": [
            'Bolt skill',
            'Beam skill',
            'Barrage skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2622
    "Wicked Gem": {
        "ap_id": 2622,
        "description": "Have a grade 3 gem with 900 effective max damage.",
        "requirements": ['minGemGrade: 3'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 2623
    "Wings and Tentacles": {
        "ap_id": 2623,
        "description": "Reach 200 non-monsters killed through all the batt...",
        "requirements": ['Ritual trait'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 2624
    "Worst of Both Sizes": {
        "ap_id": 2624,
        "description": "Beat 300 waves on max Swarmling and Giant dominati...",
        "requirements": [
            'Swarmling Domination trait',
            'Giant Domination trait',
            'minWave: 300',
            'Endurance',
        ],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2625
    "Worthy": {
        "ap_id": 2625,
        "description": "Have 70 fields lit in Trial mode.",
        "requirements": ['Trial', 'fieldToken: 70'],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2626
    "Xp Harvest": {
        "ap_id": 2626,
        "description": "Have 40 fields lit in Endurance mode.",
        "requirements": ['Endurance', 'fieldToken: 40'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2627
    "Yellow Wand": {
        "ap_id": 2627,
        "description": "Reach wizard level 20.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2628
    "You Could Be my Apprentice": {
        "ap_id": 2628,
        "description": "Have a watchtower kill a wizard hunter.",
        "requirements": [
            'Watchtower element',
            'Wizard Hunter element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2629
    "You Had Your Chance": {
        "ap_id": 2629,
        "description": "Kill 260 banished monsters with shrines.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 2630
    "You Shall Not Pass": {
        "ap_id": 2630,
        "description": "Don't let any monster touch your orb for 240 beate...",
        "requirements": [
            'minWave: 240',
            'Endurance',
        ],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 2631
    "You're Safe With Me": {
        "ap_id": 2631,
        "description": "Win a battle with at least 10 orblets remaining.",
        "requirements": ['Orb of Presence skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2632
    "Your Mana is Mine": {
        "ap_id": 2632,
        "description": "Leech 10.000 mana with gems.",
        "requirements": ['Mana Leech skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2633
    "Zap Away": {
        "ap_id": 2633,
        "description": "Cast 175 strike spells.",
        "requirements": [
            'Ice Shards skill',
            'Whiteout skill',
            'Freeze skill',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 2634
    "Zapped": {
        "ap_id": 2634,
        "description": "Get your Orb destroyed by a wizard tower.",
        "requirements": ['Wizard Tower element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 2635
    "Zigzag Corridor": {
        "ap_id": 2635,
        "description": "Build 60 walls.",
        "requirements": ['Wall element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
}

"""
GemCraft Frostborn Wrath - Achievement Requirements

All 636 achievements with their requirements, AP IDs, and metadata.
This is the single source of truth for achievement data.

Fields per achievement:
  ap_id           - Archipelago item ID (1000-1635)
  description     - Human-readable description
  requirements    - List of requirement strings for logic checks
  reward          - Reward string, e.g. "skillPoints:2"
  required_effort - Effort level: "Trivial", "Minor", "Major", "Extreme"
"""

achievement_requirements = {
    # AP ID: 1000
    "A Bright Start": {
        "ap_id": 1000,
        "description": "Have 30 fields lit in Journey mode.",
        "requirements": ['fieldToken: 30'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1001
    "A Shrubbery!": {
        "ap_id": 1001,
        "description": "Place a shrub wall.",
        "requirements": ['Wall element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1002
    "Ablatio Retinae": {
        "ap_id": 1002,
        "description": "Whiteout 111 whited out monsters.",
        "requirements": ['Whiteout skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1003
    "Absolute Zero": {
        "ap_id": 1003,
        "description": "Kill 273 frozen monsters.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1004
    "Acid Rain": {
        "ap_id": 1004,
        "description": "Kill 85 poisoned monsters while it's raining.",
        "requirements": ['Poison skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1005
    "Added Protection": {
        "ap_id": 1005,
        "description": "Strengthen your orb with a gem in an amplifier.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1006
    "Addicted": {
        "ap_id": 1006,
        "description": "Activate shrines a total of 12 times.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:2",
        "required_effort": "Minor",
    },
    # AP ID: 1007
    "Adept": {
        "ap_id": 1007,
        "description": "Have 30 fields lit in Trial mode.",
        "requirements": ['Trial', 'fieldToken: 30'],
        "reward": "skillPoints:3",
        "required_effort": "Minor",
    },
    # AP ID: 1008
    "Adept Enhancer": {
        "ap_id": 1008,
        "description": "Reach 500 enhancement spells cast through all the ...",
        "requirements": [
            'Beam skill',
            'Bolt skill',
            'Barrage skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1009
    "Adept Grade": {
        "ap_id": 1009,
        "description": "Create a grade 8 gem.",
        "requirements": ['minGemGrade: 8'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1010
    "Adventurer": {
        "ap_id": 1010,
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
    # AP ID: 1011
    "Ages Old Memories": {
        "ap_id": 1011,
        "description": "Unlock a wizard tower.",
        "requirements": ['Wizard Tower element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1012
    "Agitated": {
        "ap_id": 1012,
        "description": "Call 70 waves early.",
        "requirements": ['minWave: 70'],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 1013
    "All Your Mana Belongs to Us": {
        "ap_id": 1013,
        "description": "Beat 90 waves using only mana leeching gems.",
        "requirements": [
            'Mana Leech skill',
            'minWave: 90',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1014
    "Almost": {
        "ap_id": 1014,
        "description": "Kill a monster with shots blinking to the monster ...",
        "requirements": [
            'Watchtower element',
            'Wizard Hunter element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1015
    "Almost Like Hacked": {
        "ap_id": 1015,
        "description": "Have at least 20 different talisman properties.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1016
    "Almost Ruined": {
        "ap_id": 1016,
        "description": "Leave a monster nest at 1 hit point at the end of ...",
        "requirements": ['Monster Nest element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1017
    "Am I a Joke to You?": {
        "ap_id": 1017,
        "description": "Start an enraged wave early while there is a wizar...",
        "requirements": ['Wizard Hunter element'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1018
    "Ambitious Builder": {
        "ap_id": 1018,
        "description": "Reach 500 structures built through all the battles...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1019
    "Amplification": {
        "ap_id": 1019,
        "description": "Spend 18.000 mana on amplifiers.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1020
    "Amplifinity": {
        "ap_id": 1020,
        "description": "Build 45 amplifiers.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1021
    "Amulet": {
        "ap_id": 1021,
        "description": "Fill all the sockets in your talisman.",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1022
    "And Don't Come Back": {
        "ap_id": 1022,
        "description": "Kill 460 banished monsters with shrines.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1023
    "Angry Wasps": {
        "ap_id": 1023,
        "description": "Reach 1.000 gem wasp kills through all the battles...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1024
    "Antitheft": {
        "ap_id": 1024,
        "description": "Kill 90 monsters with orblet explosions.",
        "requirements": ['Orb of Presence skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1025
    "Armored Orb": {
        "ap_id": 1025,
        "description": "Strengthen your orb by dropping a gem on it.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1026
    "Army Glue": {
        "ap_id": 1026,
        "description": "Have a pure slowing gem with 4.000 hits.",
        "requirements": ['Slowing skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1027
    "At my Fingertips": {
        "ap_id": 1027,
        "description": "Cast 75 strike spells.",
        "requirements": [
            'Ice Shards skill',
            'Whiteout skill',
            'Freeze skill',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 1028
    "Avenged": {
        "ap_id": 1028,
        "description": "Kill 15 monsters carrying orblets.",
        "requirements": ['Orb of Presence skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1029
    "Awakening": {
        "ap_id": 1029,
        "description": "Activate a shrine.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1030
    "Bang": {
        "ap_id": 1030,
        "description": "Throw 30 gem bombs.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1031
    "Barbed Sphere": {
        "ap_id": 1031,
        "description": "Deliver 1.200 banishments with your orb.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 1032
    "Barrage Battery": {
        "ap_id": 1032,
        "description": "Have a Maximum Charge of 300% for the Barrage Spel...",
        "requirements": ['Barrage skill'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1033
    "Basic Gem Tactics": {
        "ap_id": 1033,
        "description": "Beat 120 waves and don't use any gem enhancement s...",
        "requirements": ['minWave: 120'],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 1034
    "Bastion": {
        "ap_id": 1034,
        "description": "Build 90 towers.",
        "requirements": ['Tower element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1035
    "Bath Bomb": {
        "ap_id": 1035,
        "description": "Kill 30 monsters with orblet explosions.",
        "requirements": ['Orb of Presence skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1036
    "Battle Heat": {
        "ap_id": 1036,
        "description": "Gain 200 xp with kill chains.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1037
    "Bazaar": {
        "ap_id": 1037,
        "description": "Have 30 gems on the battlefield.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Minor",
    },
    # AP ID: 1038
    "Be Gone For Good": {
        "ap_id": 1038,
        "description": "Kill 790 banished monsters.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1039
    "Beacon Hunt": {
        "ap_id": 1039,
        "description": "Destroy 55 beacons.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 1040
    "Beacons Be Gone": {
        "ap_id": 1040,
        "description": "Reach 500 beacons destroyed through all the battle...",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1041
    "Beastmaster": {
        "ap_id": 1041,
        "description": "Kill a monster having at least 100.000 hit points ...",
        "requirements": ['A monster with atleast 100.000hp and 1000 amror'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1042
    "Behold Aurora": {
        "ap_id": 1042,
        "description": "Go Igniculus and Light Ray (All)+++!",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1043
    "Biohazard": {
        "ap_id": 1043,
        "description": "Create a grade 12 pure poison gem.",
        "requirements": [
            'Poison skill',
            'minGemGrade: 12',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1044
    "Black Blood": {
        "ap_id": 1044,
        "description": "Deal 5.000 poison damage to a shadow.",
        "requirements": [
            'Poison skill',
            'Ritual trait',
            'Shadow element',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1045
    "Black Wand": {
        "ap_id": 1045,
        "description": "Reach wizard level 1.000.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 1046
    "Blackout": {
        "ap_id": 1046,
        "description": "Destroy a beacon.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1047
    "Blastwave": {
        "ap_id": 1047,
        "description": "Reach 1.000 shrine kills through all the battles.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1048
    "Bleed Out": {
        "ap_id": 1048,
        "description": "Kill 480 bleeding monsters.",
        "requirements": ['Bleeding skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1049
    "Bleeding For Everyone": {
        "ap_id": 1049,
        "description": "Enhance a pure bleeding gem having random priority...",
        "requirements": [
            'Beam skill',
            'Bleeding skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1050
    "Blind Hit": {
        "ap_id": 1050,
        "description": "Kill 30 whited out monsters with beam.",
        "requirements": [
            'Beam skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1051
    "Blood Censorship": {
        "ap_id": 1051,
        "description": "Kill 2.100 green blooded monsters.",
        "requirements": ['Requires "hidden codes"'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1052
    "Blood Clot": {
        "ap_id": 1052,
        "description": "Beat 90 waves using only bleeding gems.",
        "requirements": [
            'Bleeding skill',
            'minWave: 90',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1053
    "Blood Magic": {
        "ap_id": 1053,
        "description": "Win a battle using only bleeding gems.",
        "requirements": ['Bleeding skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1054
    "Blood on my Hands": {
        "ap_id": 1054,
        "description": "Reach 20.000 monsters killed through all the battl...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1055
    "Bloodmaster": {
        "ap_id": 1055,
        "description": "Gain 1.200 xp with kill chains.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1056
    "Bloodrush": {
        "ap_id": 1056,
        "description": "Call an enraged wave early.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1057
    "Bloodstream": {
        "ap_id": 1057,
        "description": "Kill 4.000 monsters.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1058
    "Blue Wand": {
        "ap_id": 1058,
        "description": "Reach wizard level 100.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1059
    "Boatload of Cores": {
        "ap_id": 1059,
        "description": "Find 540 shadow cores.",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1060
    "Boiling Red": {
        "ap_id": 1060,
        "description": "Reach a kill chain of 2400.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 1061
    "Bone Shredder": {
        "ap_id": 1061,
        "description": "Kill 600 monsters before wave 12 starts.",
        "requirements": ['Atleast 600 monsters before wave 10'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1062
    "Boom": {
        "ap_id": 1062,
        "description": "Throw a gem bomb.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1063
    "Bouncy Zap": {
        "ap_id": 1063,
        "description": "Reach 2.000 pylon kills through all the battles.",
        "requirements": ['Pylons skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1064
    "Breath of Cold": {
        "ap_id": 1064,
        "description": "Have 90 monsters frozen at the same time.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1065
    "Brickery": {
        "ap_id": 1065,
        "description": "Reach 1.000 structures built through all the battl...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1066
    "Bright Weakening": {
        "ap_id": 1066,
        "description": "Gain 1.200 xp with Whiteout spell crowd hits.",
        "requirements": ['Whiteout skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1067
    "Broken Seal": {
        "ap_id": 1067,
        "description": "Free a sealed gem.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1068
    "Broken Siege": {
        "ap_id": 1068,
        "description": "Destroy 8 beacons before wave 8.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1069
    "Brought Some Mana": {
        "ap_id": 1069,
        "description": "Have 5.000 initial mana.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1070
    "Brown Wand": {
        "ap_id": 1070,
        "description": "Reach wizard level 300.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 1071
    "Build Along": {
        "ap_id": 1071,
        "description": "Reach 200 structures built through all the battles...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1072
    "Busted": {
        "ap_id": 1072,
        "description": "Destroy a full health possession obelisk with one ...",
        "requirements": ['Obelisk element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1073
    "Buzz Feed": {
        "ap_id": 1073,
        "description": "Have 99 gem wasps on the battlefield.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1074
    "By Three They Go": {
        "ap_id": 1074,
        "description": "Have 3 of your gems destroyed or stolen.",
        "requirements": [
            'Ritual trait',
            'Specter element',
            'Watchtower element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1075
    "Bye Bye Hideous": {
        "ap_id": 1075,
        "description": "Kill a spire.",
        "requirements": [
            'Ritual trait',
            'Spire element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1076
    "Call in the Wave!": {
        "ap_id": 1076,
        "description": "Call a wave early.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1077
    "Can't Crawl Away": {
        "ap_id": 1077,
        "description": "Kill 30 whited out monsters with barrage.",
        "requirements": [
            'Barrage skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1078
    "Can't Stop": {
        "ap_id": 1078,
        "description": "Reach a kill chain of 900.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1079
    "Can't Take Any Risks": {
        "ap_id": 1079,
        "description": "Kill a bleeding giant with poison.",
        "requirements": [
            'Bleeding skill',
            'Poison skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1080
    "Care to Die Already?": {
        "ap_id": 1080,
        "description": "Cast 8 ice shards on the same monster.",
        "requirements": ['Ice Shards skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1081
    "Carnage": {
        "ap_id": 1081,
        "description": "Reach a kill chain of 600.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1082
    "Cartographer": {
        "ap_id": 1082,
        "description": "Have 90 fields lit in Journey mode.",
        "requirements": ['fieldToken: 90'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1083
    "Catalyst": {
        "ap_id": 1083,
        "description": "Give a Gem 200 Poison Damage by Amplification.",
        "requirements": [
            'Amplifiers skill',
            'Poison skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1084
    "Catch and Release": {
        "ap_id": 1084,
        "description": "Destroy a jar of wasps, but don't have any wasp ki...",
        "requirements": ['Field X2'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1085
    "Century Egg": {
        "ap_id": 1085,
        "description": "Reach 100 monster eggs cracked through all the bat...",
        "requirements": ['Swarm Queen element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1086
    "Chainsaw": {
        "ap_id": 1086,
        "description": "Gain 3.200 xp with kill chains.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1087
    "Charge Fire Repeat": {
        "ap_id": 1087,
        "description": "Reach 5.000 enhancement spells cast through all th...",
        "requirements": [
            'Bolt skill',
            'Beam skill',
            'Barrage skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1088
    "Charged for the Kill": {
        "ap_id": 1088,
        "description": "Reach 200 pylon kills through all the battles.",
        "requirements": ['Pylons skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1089
    "Charm": {
        "ap_id": 1089,
        "description": "Fill all the sockets in your talisman with fragmen...",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1090
    "Chilling Edges": {
        "ap_id": 1090,
        "description": "Gain 140 xp with Ice Shards spell crowd hits.",
        "requirements": ['Ice Shards skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1091
    "Chlorophyll": {
        "ap_id": 1091,
        "description": "Kill 4.500 green blooded monsters.",
        "requirements": ['Requires "hidden codes"'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1092
    "Clean Orb": {
        "ap_id": 1092,
        "description": "Win a battle without any monster getting to your o...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1093
    "Cleansing the Wilderness": {
        "ap_id": 1093,
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
    # AP ID: 1094
    "Clear Sky": {
        "ap_id": 1094,
        "description": "Beat 120 waves and don't use any strike spells.",
        "requirements": ['minWave: 120'],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 1095
    "Close Quarter": {
        "ap_id": 1095,
        "description": "Reach -12% decreased banishment cost with your orb...",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1096
    "Cold Wisdom": {
        "ap_id": 1096,
        "description": "Gain 700 xp with Freeze spell crowd hits.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1097
    "Come Again": {
        "ap_id": 1097,
        "description": "Kill 190 banished monsters.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1098
    "Come Out": {
        "ap_id": 1098,
        "description": "Lure 20 swarmlings out of a sleeping hive.",
        "requirements": ['Sleeping Hive element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1099
    "Come Out, Come Out": {
        "ap_id": 1099,
        "description": "Lure 100 swarmlings out of a sleeping hive.",
        "requirements": ['Sleeping Hive element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1100
    "Confusion Junction": {
        "ap_id": 1100,
        "description": "Build 30 walls.",
        "requirements": ['Wall element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1101
    "Connected": {
        "ap_id": 1101,
        "description": "Build an amplifier.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1102
    "Connecting the Dots": {
        "ap_id": 1102,
        "description": "Have 50 fields lit in Journey mode.",
        "requirements": ['fieldToken: 50'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1103
    "Core Haul": {
        "ap_id": 1103,
        "description": "Find 180 shadow cores.",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1104
    "Core Pack": {
        "ap_id": 1104,
        "description": "Find 20 shadow cores.",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1105
    "Core Pile": {
        "ap_id": 1105,
        "description": "Find 60 shadow cores.",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1106
    "Core Pouch": {
        "ap_id": 1106,
        "description": "Have 100 shadow cores at the start of the battle.",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1107
    "Corrosive Stings": {
        "ap_id": 1107,
        "description": "Tear a total of 5.000 armor with wasp stings.",
        "requirements": ['Armor Tearing skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1108
    "Couldn't Decide": {
        "ap_id": 1108,
        "description": "Kill 400 monsters with prismatic gem wasps.",
        "requirements": ['gemSkills: 6'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1109
    "Crimson Journal": {
        "ap_id": 1109,
        "description": "Reach 100.000 monsters killed through all the batt...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1110
    "Crowd Control": {
        "ap_id": 1110,
        "description": "Have the Overcrowd trait set to level 6 or higher ...",
        "requirements": ['Overcrowd trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1111
    "Crowded Queue": {
        "ap_id": 1111,
        "description": "Have 600 monsters on the battlefield at the same t...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1112
    "Crunchy Bites": {
        "ap_id": 1112,
        "description": "Kill 160 frozen swarmlings.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1113
    "Damage Support": {
        "ap_id": 1113,
        "description": "Have a pure bleeding gem with 2.500 hits.",
        "requirements": ['Bleeding skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1114
    "Darkness Walk With Me": {
        "ap_id": 1114,
        "description": "Kill 3 shadows.",
        "requirements": [
            'Ritual trait',
            'Shadow element',
        ],
        "reward": "skillPoints:3",
        "required_effort": "Minor",
    },
    # AP ID: 1115
    "Deadly Curse": {
        "ap_id": 1115,
        "description": "Reach 5.000 poison kills through all the battles.",
        "requirements": ['Poison skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1116
    "Deal Some Damage Too": {
        "ap_id": 1116,
        "description": "Have 5 traps with bolt enhanced gems in them.",
        "requirements": [
            'Bolt skill',
            'Traps skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1117
    "Deathball": {
        "ap_id": 1117,
        "description": "Reach 1.000 pylon kills through all the battles.",
        "requirements": ['Pylons skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1118
    "Deckard Would Be Proud": {
        "ap_id": 1118,
        "description": "All I could get for a prismatic amulet",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1119
    "Deluminati": {
        "ap_id": 1119,
        "description": "Have the Dark Masonry trait set to level 6 or high...",
        "requirements": ['Dark Masonry trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1120
    "Denested": {
        "ap_id": 1120,
        "description": "Destroy 5 monster nests.",
        "requirements": ['Monster Nest element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1121
    "Derangement": {
        "ap_id": 1121,
        "description": "Decrease the range of a gem.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1122
    "Desperate Clash": {
        "ap_id": 1122,
        "description": "Reach -16% decreased banishment cost with your orb...",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1123
    "Diabolic Trophy": {
        "ap_id": 1123,
        "description": "Kill 666 swarmlings.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1124
    "Dichromatic": {
        "ap_id": 1124,
        "description": "Combine two gems of different colors.",
        "requirements": ['gemSkills: 2'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1125
    "Disciple": {
        "ap_id": 1125,
        "description": "Have 10 fields lit in Trial mode.",
        "requirements": ['Trial', 'fieldToken: 10'],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 1126
    "Disco Ball": {
        "ap_id": 1126,
        "description": "Have a gem of 6 components in a lantern.",
        "requirements": [
            'Lanterns skill',
            'gemSkills: 6',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1127
    "Don't Break it!": {
        "ap_id": 1127,
        "description": "Spend 90.000 mana on banishment.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1128
    "Don't Look at the Light": {
        "ap_id": 1128,
        "description": "Reach 10.000 shrine kills through all the battles.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1129
    "Don't Touch it!": {
        "ap_id": 1129,
        "description": "Kill a specter.",
        "requirements": [
            'Ritual trait',
            'Specter element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1130
    "Doom Drop": {
        "ap_id": 1130,
        "description": "Kill a possessed giant with barrage.",
        "requirements": [
            'Barrage skill',
            'Possessed Monster element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1131
    "Double Punch": {
        "ap_id": 1131,
        "description": "Have 2 bolt enhanced gems at the same time.",
        "requirements": ['Bolt skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1132
    "Double Sharded": {
        "ap_id": 1132,
        "description": "Cast 2 ice shards on the same monster.",
        "requirements": ['Ice Shards skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1133
    "Double Splash": {
        "ap_id": 1133,
        "description": "Kill two non-monster creatures with one gem bomb.",
        "requirements": ['Ritual trait'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1134
    "Double Strike": {
        "ap_id": 1134,
        "description": "Activate the same shrine 2 times.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1135
    "Drone Warfare": {
        "ap_id": 1135,
        "description": "Reach 20.000 gem wasp kills through all the battle...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1136
    "Drop the Ice": {
        "ap_id": 1136,
        "description": "Reach 50.000 strike spell hits through all the bat...",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1137
    "Drumroll": {
        "ap_id": 1137,
        "description": "Deal 200 gem wasp stings to buildings.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1138
    "Dry Puddle": {
        "ap_id": 1138,
        "description": "Harvest all mana from a mana shard.",
        "requirements": ['Mana Shard element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1139
    "Dual Downfall": {
        "ap_id": 1139,
        "description": "Kill 2 spires.",
        "requirements": [
            'Ritual trait',
            'Spire element',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1140
    "Dual Pulse": {
        "ap_id": 1140,
        "description": "Have 2 beam enhanced gems at the same time.",
        "requirements": ['Beam skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1141
    "Eagle Eye": {
        "ap_id": 1141,
        "description": "Reach an amplified gem range of 18.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1142
    "Early Bird": {
        "ap_id": 1142,
        "description": "Reach 500 waves started early through all the batt...",
        "requirements": [
            'minWave: 500',
            'Endurance',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1143
    "Early Harvest": {
        "ap_id": 1143,
        "description": "Harvest 2.500 mana from shards before wave 3 start...",
        "requirements": ['Mana Shard element'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1144
    "Earthquake": {
        "ap_id": 1144,
        "description": "Activate shrines a total of 4 times.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1145
    "Easy Kill": {
        "ap_id": 1145,
        "description": "Kill 120 bleeding monsters.",
        "requirements": ['Bleeding skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1146
    "Eat my Light": {
        "ap_id": 1146,
        "description": "Kill a wraith with a shrine strike.",
        "requirements": [
            'Ritual trait',
            'Shrine element',
            'Wraith element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1147
    "Eggcracker": {
        "ap_id": 1147,
        "description": "Don't let any egg laid by a swarm queen to hatch o...",
        "requirements": ['Swarm Queen element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1148
    "Eggnog": {
        "ap_id": 1148,
        "description": "Crack a monster egg open while time is frozen.",
        "requirements": ['Swarm Queen element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1149
    "Eggs Royale": {
        "ap_id": 1149,
        "description": "Reach 1.000 monster eggs cracked through all the b...",
        "requirements": ['Swarm Queen element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1150
    "Elementary": {
        "ap_id": 1150,
        "description": "Beat 30 waves using at most grade 2 gems.",
        "requirements": ['minWave: 30'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1151
    "End of the Tunnel": {
        "ap_id": 1151,
        "description": "Kill an apparition with a shrine strike.",
        "requirements": [
            'Ritual trait',
            'Apparition element',
            'Shrine element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1152
    "Endgame Balance": {
        "ap_id": 1152,
        "description": "Have 25.000 shadow cores at the start of the battl...",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 1153
    "Endured a Lot": {
        "ap_id": 1153,
        "description": "Have 80 fields lit in Endurance mode.",
        "requirements": ['Endurance', 'fieldToken: 80'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1154
    "Enhance Like No Tomorrow": {
        "ap_id": 1154,
        "description": "Reach 2.500 enhancement spells cast through all th...",
        "requirements": [
            'Bolt skill',
            'Beam skill',
            'Barrage skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1155
    "Enhancement Storage": {
        "ap_id": 1155,
        "description": "Enhance a gem in the inventory.",
        "requirements": [
            'Bolt skill',
            'Beam skill',
            'Barrage skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1156
    "Enhancing Challenge": {
        "ap_id": 1156,
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
    # AP ID: 1157
    "Enough Frozen Time Trickery": {
        "ap_id": 1157,
        "description": "Kill a shadow while time is frozen.",
        "requirements": ['Shadow element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1158
    "Enough is Enough": {
        "ap_id": 1158,
        "description": "Have 24 of your gems destroyed or stolen.",
        "requirements": [
            'Ritual trait',
            'Specter element',
            'Watchtower element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1159
    "Enraged is the New Norm": {
        "ap_id": 1159,
        "description": "Enrage 240 waves.",
        "requirements": [
            'minWave: 240',
            'Endurance',
        ],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 1160
    "Ensnared": {
        "ap_id": 1160,
        "description": "Kill 12 monsters with gems in traps.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1161
    "Enter The Gate": {
        "ap_id": 1161,
        "description": "Kill the gatekeeper.",
        "requirements": [
            'Gatekeeper element',
            'Field A4',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1162
    "Entrenched": {
        "ap_id": 1162,
        "description": "Build 20 traps.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1163
    "Epidemic Gem": {
        "ap_id": 1163,
        "description": "Have a pure poison gem with 3.500 hits.",
        "requirements": ['Poison skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1164
    "Even if You Thaw": {
        "ap_id": 1164,
        "description": "Whiteout 120 frozen monsters.",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1165
    "Every Hit Counts": {
        "ap_id": 1165,
        "description": "Deliver 3750 one hit kills.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 1166
    "Exorcism": {
        "ap_id": 1166,
        "description": "Kill 199 possessed monsters.",
        "requirements": ['Possessed Monster element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1167
    "Expert": {
        "ap_id": 1167,
        "description": "Have 50 fields lit in Trial mode.",
        "requirements": ['Trial', 'fieldToken: 50'],
        "reward": "skillPoints:3",
        "required_effort": "Major",
    },
    # AP ID: 1168
    "Extorted": {
        "ap_id": 1168,
        "description": "Harvest all mana from 3 mana shards.",
        "requirements": ['Mana Shard element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1169
    "Face the Phobia": {
        "ap_id": 1169,
        "description": "Have the Swarmling Parasites trait set to level 6 ...",
        "requirements": ['Swarmling Parasites trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1170
    "Family Friendlier": {
        "ap_id": 1170,
        "description": "Kill 900 green blooded monsters.",
        "requirements": ['Requires "hidden codes"'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1171
    "Farewell": {
        "ap_id": 1171,
        "description": "Kill an apparition with one hit.",
        "requirements": [
            'Ritual trait',
            'Apparition element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1172
    "Feels Like Endurance": {
        "ap_id": 1172,
        "description": "Beat 120 waves.",
        "requirements": ['minWave: 120'],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 1173
    "Fierce Encounter": {
        "ap_id": 1173,
        "description": "Reach -8% decreased banishment cost with your orb.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1174
    "Fifth Grader": {
        "ap_id": 1174,
        "description": "Create a grade 5 gem.",
        "requirements": ['minGemGrade: 5'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1175
    "Filled 5 Times": {
        "ap_id": 1175,
        "description": "Reach mana pool level 5.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1176
    "Final Cut": {
        "ap_id": 1176,
        "description": "Kill 960 bleeding monsters.",
        "requirements": ['Bleeding skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1177
    "Final Touch": {
        "ap_id": 1177,
        "description": "Kill a spire with a gem wasp.",
        "requirements": [
            'Ritual trait',
            'Spire element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1178
    "Finders": {
        "ap_id": 1178,
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
    # AP ID: 1179
    "Fire Away": {
        "ap_id": 1179,
        "description": "Cast a gem enhancement spell.",
        "requirements": [
            'Bolt skill',
            'Beam skill',
            'Barrage skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1180
    "Fire in the Hole": {
        "ap_id": 1180,
        "description": "Destroy a monster nest.",
        "requirements": ['Monster Nest element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1181
    "Firefall": {
        "ap_id": 1181,
        "description": "Have 16 barrage enhanced gems at the same time.",
        "requirements": ['Barrage skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1182
    "First Blood": {
        "ap_id": 1182,
        "description": "Kill a monster.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1183
    "First Puzzle Piece": {
        "ap_id": 1183,
        "description": "Find a talisman fragment.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1184
    "Flip Flop": {
        "ap_id": 1184,
        "description": "Win a flipped field battle.",
        "requirements": ['Requires "hidden codes"'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1185
    "Flows Through my Veins": {
        "ap_id": 1185,
        "description": "Reach mana pool level 10.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1186
    "Flying Multikill": {
        "ap_id": 1186,
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
    # AP ID: 1187
    "Fool Me Once": {
        "ap_id": 1187,
        "description": "Kill 390 banished monsters.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1188
    "Forces Within my Comprehension": {
        "ap_id": 1188,
        "description": "Have the Ritual trait set to level 6 or higher and...",
        "requirements": ['Ritual trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1189
    "Forged in Battle": {
        "ap_id": 1189,
        "description": "Reach 200 battles won.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1190
    "Fortress": {
        "ap_id": 1190,
        "description": "Build 30 towers.",
        "requirements": ['Tower element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1191
    "Fortunate": {
        "ap_id": 1191,
        "description": "Find 2 talisman fragments.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1192
    "Frag Rain": {
        "ap_id": 1192,
        "description": "Find 5 talisman fragments.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 1193
    "Freezing Wounds": {
        "ap_id": 1193,
        "description": "Freeze a monster 3 times.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1194
    "Friday Night": {
        "ap_id": 1194,
        "description": "Have 4 beam enhanced gems at the same time.",
        "requirements": ['Beam skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1195
    "Frittata": {
        "ap_id": 1195,
        "description": "Reach 500 monster eggs cracked through all the bat...",
        "requirements": ['Swarm Queen element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1196
    "From Above": {
        "ap_id": 1196,
        "description": "Kill 40 monsters with gem bombs and wasps.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1197
    "Frostborn": {
        "ap_id": 1197,
        "description": "Reach 5.000 strike spells cast through all the bat...",
        "requirements": [
            'Whiteout skill',
            'Ice Shards skill',
            'Freeze skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1198
    "Frosting": {
        "ap_id": 1198,
        "description": "Freeze a specter while it's snowing.",
        "requirements": [
            'Freeze skill',
            'Ritual trait',
            'Specter element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1199
    "Frozen Crowd": {
        "ap_id": 1199,
        "description": "Reach 10.000 strike spell hits through all the bat...",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1200
    "Frozen Grave": {
        "ap_id": 1200,
        "description": "Kill 220 monsters while it's snowing.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1201
    "Frozen Over": {
        "ap_id": 1201,
        "description": "Gain 4.500 xp with Freeze spell crowd hits.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1202
    "Ful Ir": {
        "ap_id": 1202,
        "description": "Blast like a fireball",
        "requirements": ['Kill 15 monsters simultaneously with 1 gem bomb'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1203
    "Fully Lit": {
        "ap_id": 1203,
        "description": "Have a field beaten in all three battle modes.",
        "requirements": ['Endurance and trial'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1204
    "Fully Shining": {
        "ap_id": 1204,
        "description": "Have 60 gems on the battlefield.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 1205
    "Fusion Core": {
        "ap_id": 1205,
        "description": "Have 16 beam enhanced gems at the same time.",
        "requirements": ['Beam skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1206
    "Gearing Up": {
        "ap_id": 1206,
        "description": "Have 5 fragments socketed in your talisman.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1207
    "Gem Lust": {
        "ap_id": 1207,
        "description": "Kill 2 specters.",
        "requirements": [
            'Ritual trait',
            'Specter element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1208
    "Gemhancement": {
        "ap_id": 1208,
        "description": "Reach 1.000 enhancement spells cast through all th...",
        "requirements": [
            'Bolt skill',
            'Beam skill',
            'Barrage skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1209
    "Get Them": {
        "ap_id": 1209,
        "description": "Have a watchtower kill 39 monsters.",
        "requirements": ['Watchtower element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1210
    "Get This Done Quick": {
        "ap_id": 1210,
        "description": "Win a Trial battle with at least 3 waves started e...",
        "requirements": [
            'minWave: 3',
            'Trial',
        ],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 1211
    "Getting My Feet Wet": {
        "ap_id": 1211,
        "description": "Have 20 fields lit in Endurance mode.",
        "requirements": ['Endurance', 'fieldToken: 20'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1212
    "Getting Rid of Them": {
        "ap_id": 1212,
        "description": "Drop 48 gem bombs on beacons.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1213
    "Getting Serious": {
        "ap_id": 1213,
        "description": "Have a grade 1 gem with 1.500 hits.",
        "requirements": ['minGemGrade: 1'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1214
    "Getting Waves Done": {
        "ap_id": 1214,
        "description": "Reach 2.000 waves started early through all the ba...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1215
    "Getting Wet": {
        "ap_id": 1215,
        "description": "Beat 30 waves.",
        "requirements": ['minWave: 30'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1216
    "Glitter Cloud": {
        "ap_id": 1216,
        "description": "Kill an apparition with a gem bomb.",
        "requirements": [
            'Ritual trait',
            'Apparition element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1217
    "Glowing Armada": {
        "ap_id": 1217,
        "description": "Have 240 gem wasps on the battlefield when the bat...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1218
    "Going Deviant": {
        "ap_id": 1218,
        "description": "Rook to a9",
        "requirements": ['Scroll to edge of the world map'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1219
    "Going for the Weak": {
        "ap_id": 1219,
        "description": "Have a watchtower kill a poisoned monster.",
        "requirements": [
            'Poison skill',
            'Watchtower element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1220
    "Got the Price Back": {
        "ap_id": 1220,
        "description": "Have a pure mana leeching gem with 4.500 hits.",
        "requirements": ['Mana Leech skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1221
    "Great Survivor": {
        "ap_id": 1221,
        "description": "Kill a monster from wave 1 when wave 20 has alread...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1222
    "Green Eyed Ninja": {
        "ap_id": 1222,
        "description": "Entering: The Wilderness",
        "requirements": ['Field N1, U1 or R5'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1223
    "Green Path": {
        "ap_id": 1223,
        "description": "Kill 9.900 green blooded monsters.",
        "requirements": ['Requires "hidden codes"'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1224
    "Green Vial": {
        "ap_id": 1224,
        "description": "Have more than 75% of the monster kills caused by ...",
        "requirements": ['Poison skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1225
    "Green Wand": {
        "ap_id": 1225,
        "description": "Reach wizard level 60.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1226
    "Ground Luck": {
        "ap_id": 1226,
        "description": "Find 3 talisman fragments.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1227
    "Groundfill": {
        "ap_id": 1227,
        "description": "Demolish a trap.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1228
    "Guarding the Fallen Gate": {
        "ap_id": 1228,
        "description": "Have the Corrupted Banishment trait set to level 6...",
        "requirements": ['Corrupted Banishment trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1229
    "Hacked Gem": {
        "ap_id": 1229,
        "description": "Have a grade 3 gem with 1.200 effective max damage...",
        "requirements": ['minGemGrade: 3'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1230
    "Half Full": {
        "ap_id": 1230,
        "description": "Add 32 talisman fragments to your shape collection...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1231
    "Handle With Care": {
        "ap_id": 1231,
        "description": "Kill 300 monsters with orblet explosions.",
        "requirements": ['Orb of Presence skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1232
    "Hard Reset": {
        "ap_id": 1232,
        "description": "Reach 5.000 shrine kills through all the battles.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1233
    "Has Stood Long Enough": {
        "ap_id": 1233,
        "description": "Destroy a monster nest after the last wave has sta...",
        "requirements": ['Monster Nest element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1234
    "Hateful": {
        "ap_id": 1234,
        "description": "Have the Hatred trait set to level 6 or higher and...",
        "requirements": ['Hatred trait'],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 1235
    "Hazardous Materials": {
        "ap_id": 1235,
        "description": "Put your HEV on first",
        "requirements": [
            'Poison skill',
            'Have atleast 1.000 enemies poisoned and alive on a field',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1236
    "Healing Denied": {
        "ap_id": 1236,
        "description": "Destroy 3 healing beacons.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1237
    "Heavily Modified": {
        "ap_id": 1237,
        "description": "Activate all mods.",
        "requirements": ['Requires "hidden codes"'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1238
    "Heavy Hitting": {
        "ap_id": 1238,
        "description": "Have 4 bolt enhanced gems at the same time.",
        "requirements": ['Bolt skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1239
    "Heavy Support": {
        "ap_id": 1239,
        "description": "Have 20 beacons on the field at the same time.",
        "requirements": [
            'Dark Masonry trait',
            'Beacon element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1240
    "Hedgehog": {
        "ap_id": 1240,
        "description": "Kill a swarmling having at least 100 armor.",
        "requirements": ['a swarmling with atleast 100 armor'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1241
    "Helping Hand": {
        "ap_id": 1241,
        "description": "Have a watchtower kill a possessed monster.",
        "requirements": [
            'Possessed Monster element',
            'Watchtower element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1242
    "Hiding Spot": {
        "ap_id": 1242,
        "description": "Open 3 drop holders before wave 3.",
        "requirements": ['Drop Holder element'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1243
    "High Stakes": {
        "ap_id": 1243,
        "description": "Set a battle trait to level 12.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1244
    "High Targets": {
        "ap_id": 1244,
        "description": "Reach 100 non-monsters killed through all the batt...",
        "requirements": ['Ritual trait'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1245
    "Hint of Darkness": {
        "ap_id": 1245,
        "description": "Kill 189 twisted monsters.",
        "requirements": ['Twisted Monster element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1246
    "Hold Still": {
        "ap_id": 1246,
        "description": "Freeze 130 whited out monsters.",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1247
    "Hope has fallen": {
        "ap_id": 1247,
        "description": "Dismantled bunkhouses",
        "requirements": ['Field E3'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1248
    "How About Some Skill Points": {
        "ap_id": 1248,
        "description": "Have 5.000 shadow cores at the start of the battle...",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1249
    "Hungry Little Gem": {
        "ap_id": 1249,
        "description": "Leech 3.600 mana with a grade 1 gem.",
        "requirements": [
            'Mana Leech skill',
            'minGemGrade: 1',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1250
    "Hunt For Hard Targets": {
        "ap_id": 1250,
        "description": "Kill 680 monsters while there are at least 2 wrait...",
        "requirements": [
            'Ritual trait',
            'Wraith element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1251
    "Hurtified": {
        "ap_id": 1251,
        "description": "Kill 240 bleeding monsters.",
        "requirements": ['Bleeding skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1252
    "Hyper Gem": {
        "ap_id": 1252,
        "description": "Have a grade 3 gem with 600 effective max damage.",
        "requirements": ['minGemGrade: 3'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1253
    "I Have Experience": {
        "ap_id": 1253,
        "description": "Reach 50 battles won.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1254
    "I Never Asked For This": {
        "ap_id": 1254,
        "description": "All my aug points spent",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1255
    "I Saw Something": {
        "ap_id": 1255,
        "description": "Kill an apparition.",
        "requirements": [
            'Ritual trait',
            'Apparition element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1256
    "I Warned You...": {
        "ap_id": 1256,
        "description": "Kill a specter while it carries a gem.",
        "requirements": [
            'Ritual trait',
            'Specter element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1257
    "I am Tougher": {
        "ap_id": 1257,
        "description": "Kill 1.360 monsters while there are at least 2 wra...",
        "requirements": [
            'Ritual trait',
            'Wraith element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1258
    "Ice Cube": {
        "ap_id": 1258,
        "description": "Have a Maximum Charge of 300% for the Freeze Spell...",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1259
    "Ice Mage": {
        "ap_id": 1259,
        "description": "Reach 2.500 strike spells cast through all the bat...",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1260
    "Ice Snap": {
        "ap_id": 1260,
        "description": "Gain 90 xp with Freeze spell crowd hits.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1261
    "Ice Stand": {
        "ap_id": 1261,
        "description": "Kill 5 frozen monsters carrying orblets.",
        "requirements": [
            'Freeze skill',
            'Orb of Presence skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1262
    "Ice for Everyone": {
        "ap_id": 1262,
        "description": "Reach 100.000 strike spell hits through all the ba...",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1263
    "Icecracker": {
        "ap_id": 1263,
        "description": "Kill 90 frozen monsters with barrage.",
        "requirements": [
            'Barrage skill',
            'Freeze skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1264
    "Icepicked": {
        "ap_id": 1264,
        "description": "Gain 3.200 xp with Ice Shards spell crowd hits.",
        "requirements": ['Ice Shards skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1265
    "Icy Fingers": {
        "ap_id": 1265,
        "description": "Reach 500 strike spells cast through all the battl...",
        "requirements": [
            'Whiteout skill',
            'Freeze skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1266
    "Impaling Charges": {
        "ap_id": 1266,
        "description": "Deliver 250 one hit kills.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1267
    "Impenetrable": {
        "ap_id": 1267,
        "description": "Have 8 bolt enhanced gems at the same time.",
        "requirements": ['Bolt skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1268
    "Implosion": {
        "ap_id": 1268,
        "description": "Kill a gatekeeper fang with a gem bomb.",
        "requirements": [
            'Gatekeeper element',
            'Field A4',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1269
    "Impressive": {
        "ap_id": 1269,
        "description": "Win a Trial battle without any monster reaching yo...",
        "requirements": ['Trial'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1270
    "Impudence": {
        "ap_id": 1270,
        "description": "Have 6 of your gems destroyed or stolen.",
        "requirements": [
            'Ritual trait',
            'Specter element',
            'Watchtower element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1271
    "In Flames": {
        "ap_id": 1271,
        "description": "Kill 400 spawnlings.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1272
    "In Focus": {
        "ap_id": 1272,
        "description": "Amplify a gem with 8 other gems.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1273
    "In a Blink of an Eye": {
        "ap_id": 1273,
        "description": "Kill 100 monsters while time is frozen.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1274
    "In for a Trait": {
        "ap_id": 1274,
        "description": "Activate a battle trait.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1275
    "Inedible": {
        "ap_id": 1275,
        "description": "Poison 111 frozen monsters.",
        "requirements": [
            'Freeze skill',
            'Poison skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1276
    "Insane Investment": {
        "ap_id": 1276,
        "description": "Reach -20% decreased banishment cost with your orb...",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1277
    "Instant Spawn": {
        "ap_id": 1277,
        "description": "Have a shadow spawn a monster while time is frozen...",
        "requirements": [
            'Ritual trait',
            'Shadow element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1278
    "Ionized Air": {
        "ap_id": 1278,
        "description": "Have the Insulation trait set to level 6 or higher...",
        "requirements": ['Insulation trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1279
    "Is Anyone in There?": {
        "ap_id": 1279,
        "description": "Break a tomb open.",
        "requirements": ['Tomb element'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1280
    "Is This a Match-3 or What?": {
        "ap_id": 1280,
        "description": "Have 90 gems on the battlefield.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 1281
    "It Has to Do": {
        "ap_id": 1281,
        "description": "Beat 50 waves using at most grade 2 gems.",
        "requirements": ['minWave: 50'],
        "reward": "skillPoints:3",
        "required_effort": "Major",
    },
    # AP ID: 1282
    "It Hurts!": {
        "ap_id": 1282,
        "description": "Spend 9.000 mana on banishment.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1283
    "It was Abandoned Anyway": {
        "ap_id": 1283,
        "description": "Destroy a dwelling.",
        "requirements": ['Abandoned Dwelling element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1284
    "It's Lagging Alright": {
        "ap_id": 1284,
        "description": "Have 1.200 monsters on the battlefield at the same...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1285
    "It's a Trap": {
        "ap_id": 1285,
        "description": "Don't let any monster touch your orb for 120 beate...",
        "requirements": ['minWave: 120'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1286
    "Itchy Sphere": {
        "ap_id": 1286,
        "description": "Deliver 3.600 banishments with your orb.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 1287
    "Jewel Box": {
        "ap_id": 1287,
        "description": "Fill all inventory slots with gems.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1288
    "Jinx Blast": {
        "ap_id": 1288,
        "description": "Kill 30 whited out monsters with bolt.",
        "requirements": [
            'Bolt skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1289
    "Juggler": {
        "ap_id": 1289,
        "description": "Use demolition 7 times.",
        "requirements": ['Demolition skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1290
    "Just Breathe In": {
        "ap_id": 1290,
        "description": "Enhance a pure poison gem having random priority w...",
        "requirements": [
            'Beam skill',
            'Poison skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1291
    "Just Fire More at Them": {
        "ap_id": 1291,
        "description": "Have the Thick Air trait set to level 6 or higher ...",
        "requirements": ['Thick Air trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1292
    "Just Give Me That Mana": {
        "ap_id": 1292,
        "description": "Leech 7.200 mana from whited out monsters.",
        "requirements": [
            'Mana Leech skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1293
    "Just Started": {
        "ap_id": 1293,
        "description": "Reach 10 battles won.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1294
    "Just Take My Mana!": {
        "ap_id": 1294,
        "description": "Spend 900.000 mana on banishment.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 1295
    "Keep Losing Keep Harvesting": {
        "ap_id": 1295,
        "description": "Deplete a mana shard while there is a shadow on th...",
        "requirements": [
            'Ritual trait',
            'Mana Shard element',
            'Shadow element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1296
    "Keepers": {
        "ap_id": 1296,
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
    # AP ID: 1297
    "Keeping Low": {
        "ap_id": 1297,
        "description": "Beat 40 waves using at most grade 2 gems.",
        "requirements": ['minWave: 40'],
        "reward": "skillPoints:2",
        "required_effort": "Minor",
    },
    # AP ID: 1298
    "Killed So Many": {
        "ap_id": 1298,
        "description": "Gain 7.200 xp with kill chains.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1299
    "Knowledge Seeker": {
        "ap_id": 1299,
        "description": "Open a wizard stash.",
        "requirements": ['Wizard Stash element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1300
    "Lagging Already?": {
        "ap_id": 1300,
        "description": "Have 900 monsters on the battlefield at the same t...",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 1301
    "Landing Spot": {
        "ap_id": 1301,
        "description": "Demolish 20 or more walls with falling spires.",
        "requirements": [
            'Ritual trait',
            'Spire element',
            'Wall element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1302
    "Laser Slicer": {
        "ap_id": 1302,
        "description": "Have 8 beam enhanced gems at the same time.",
        "requirements": ['Beam skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1303
    "Last Minute Mana": {
        "ap_id": 1303,
        "description": "Leech 500 mana from poisoned monsters.",
        "requirements": [
            'Mana Leech skill',
            'Poison skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1304
    "Legendary": {
        "ap_id": 1304,
        "description": "Create a gem with a raw minimum damage of 30.000 o...",
        "requirements": ['gemSkills: 1'],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 1305
    "Let Them Hatch": {
        "ap_id": 1305,
        "description": "Don't crack any egg laid by a swarm queen.",
        "requirements": ['Swarm Queen element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1306
    "Let it Go": {
        "ap_id": 1306,
        "description": "Leave an apparition alive.",
        "requirements": [
            'Ritual trait',
            'Apparition element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1307
    "Let's Have a Look": {
        "ap_id": 1307,
        "description": "Open a drop holder.",
        "requirements": ['Drop Holder element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1308
    "Light My Path": {
        "ap_id": 1308,
        "description": "Have 70 fields lit in Journey mode.",
        "requirements": ['fieldToken: 70'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1309
    "Like a Necro": {
        "ap_id": 1309,
        "description": "Kill 25 monsters with frozen corpse explosion.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1310
    "Limited Vision": {
        "ap_id": 1310,
        "description": "Gain 100 xp with Whiteout spell crowd hits.",
        "requirements": ['Whiteout skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1311
    "Liquid Explosive": {
        "ap_id": 1311,
        "description": "Kill 180 monsters with orblet explosions.",
        "requirements": ['Orb of Presence skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1312
    "Locked and Loaded": {
        "ap_id": 1312,
        "description": "Have 3 pylons charged up to 3 shots each.",
        "requirements": ['Pylons skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1313
    "Long Crawl": {
        "ap_id": 1313,
        "description": "Win a battle using only slowing gems.",
        "requirements": ['Slowing skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1314
    "Long Lasting": {
        "ap_id": 1314,
        "description": "Reach 500 poison kills through all the battles.",
        "requirements": ['Poison skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1315
    "Long Run": {
        "ap_id": 1315,
        "description": "Beat 360 waves.",
        "requirements": [
            'minWave: 360',
            'Endurance',
        ],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 1316
    "Longrunner": {
        "ap_id": 1316,
        "description": "Have 60 fields lit in Endurance mode.",
        "requirements": ['Endurance', 'fieldToken: 60'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1317
    "Lost Signal": {
        "ap_id": 1317,
        "description": "Destroy 35 beacons.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 1318
    "Lots of Crit Hits": {
        "ap_id": 1318,
        "description": "Have a pure critical hit gem with 2.000 hits.",
        "requirements": ['Critical Hit skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1319
    "Lots of Scratches": {
        "ap_id": 1319,
        "description": "Reach a kill chain of 300.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1320
    "Major Shutdown": {
        "ap_id": 1320,
        "description": "Destroy 3 monster nests.",
        "requirements": ['Monster Nest element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1321
    "Mana Blinded": {
        "ap_id": 1321,
        "description": "Leech 900 mana from whited out monsters.",
        "requirements": [
            'Mana Leech skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1322
    "Mana Cult": {
        "ap_id": 1322,
        "description": "Leech 6.500 mana from bleeding monsters.",
        "requirements": [
            'Bleeding skill',
            'Mana Leech skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1323
    "Mana First": {
        "ap_id": 1323,
        "description": "Deplete a shard when there are more than 300 swarm...",
        "requirements": ['Mana Shard element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1324
    "Mana Greedy": {
        "ap_id": 1324,
        "description": "Leech 1.800 mana with a grade 1 gem.",
        "requirements": [
            'Mana Leech skill',
            'minGemGrade: 1',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1325
    "Mana Hack": {
        "ap_id": 1325,
        "description": "Have 80.000 initial mana.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 1326
    "Mana Magnet": {
        "ap_id": 1326,
        "description": "Win a battle using only mana leeching gems.",
        "requirements": ['Mana Leech skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1327
    "Mana Salvation": {
        "ap_id": 1327,
        "description": "Salvage mana by destroying a gem.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1328
    "Mana Singularity": {
        "ap_id": 1328,
        "description": "Reach mana pool level 20.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 1329
    "Mana Tap": {
        "ap_id": 1329,
        "description": "Reach 10.000 mana harvested from shards through al...",
        "requirements": ['Mana Shard element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1330
    "Mana Trader": {
        "ap_id": 1330,
        "description": "Salvage 8.000 mana from gems.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1331
    "Mana in a Bottle": {
        "ap_id": 1331,
        "description": "Have 40.000 initial mana.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 1332
    "Mana is All I Need": {
        "ap_id": 1332,
        "description": "Win a battle with no skill point spent and a battl...",
        "requirements": ['Any battle trait\n\n'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1333
    "Mana of the Dying": {
        "ap_id": 1333,
        "description": "Leech 2.300 mana from poisoned monsters.",
        "requirements": [
            'Mana Leech skill',
            'Poison skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1334
    "Marked Targets": {
        "ap_id": 1334,
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
    # AP ID: 1335
    "Marmalade": {
        "ap_id": 1335,
        "description": "Don't destroy any of the jars of wasps.",
        "requirements": ['Field X2'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1336
    "Mass Awakening": {
        "ap_id": 1336,
        "description": "Lure 2.500 swarmlings out of a sleeping hive.",
        "requirements": ['Sleeping Hive element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1337
    "Mastery": {
        "ap_id": 1337,
        "description": "Raise a skill to level 70.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1338
    "Max Trap Max leech": {
        "ap_id": 1338,
        "description": "Leech 6.300 mana with a grade 1 gem.",
        "requirements": [
            'Mana Leech skill',
            'minGemGrade: 1',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1339
    "Meet the Spartans": {
        "ap_id": 1339,
        "description": "Have 300 monsters on the battlefield at the same t...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1340
    "Megalithic": {
        "ap_id": 1340,
        "description": "Reach 2.000 structures built through all the battl...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1341
    "Melting Armor": {
        "ap_id": 1341,
        "description": "Tear a total of 10.000 armor with wasp stings.",
        "requirements": ['Armor Tearing skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1342
    "Melting Pulse": {
        "ap_id": 1342,
        "description": "Hit 75 frozen monsters with shrines.",
        "requirements": [
            'Freeze skill',
            'Shrine element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1343
    "Might Need it Later": {
        "ap_id": 1343,
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
    # AP ID: 1344
    "Mighty": {
        "ap_id": 1344,
        "description": "Create a gem with a raw minimum damage of 3.000 or...",
        "requirements": ['gemSkills: 1'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1345
    "Minefield": {
        "ap_id": 1345,
        "description": "Kill 300 monsters with gems in traps.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1346
    "Miniblasts": {
        "ap_id": 1346,
        "description": "Tear a total of 1.250 armor with wasp stings.",
        "requirements": ['Armor Tearing skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1347
    "Minor Detour": {
        "ap_id": 1347,
        "description": "Build 15 walls.",
        "requirements": ['Wall element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1348
    "Mixing Up": {
        "ap_id": 1348,
        "description": "Beat 50 waves on max Swarmling and Giant dominatio...",
        "requirements": [
            'Swarmling Domination trait',
            'Giant Domination trait',
            'minWave: 50',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 1349
    "More Than Enough": {
        "ap_id": 1349,
        "description": "Summon 1.000 monsters by enraging waves.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 1350
    "More Wounds": {
        "ap_id": 1350,
        "description": "Kill 125 bleeding monsters with barrage.",
        "requirements": [
            'Barrage skill',
            'Bleeding skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1351
    "Morning March": {
        "ap_id": 1351,
        "description": "Lure 500 swarmlings out of a sleeping hive.",
        "requirements": ['Sleeping Hive element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1352
    "Multifreeze": {
        "ap_id": 1352,
        "description": "Reach 5.000 strike spell hits through all the batt...",
        "requirements": [
            'Ice Shards skill',
            'Whiteout skill',
            'Freeze skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1353
    "Multiline": {
        "ap_id": 1353,
        "description": "Have at least 5 different talisman properties.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1354
    "Multinerf": {
        "ap_id": 1354,
        "description": "Kill 1.600 monsters with prismatic gem wasps.",
        "requirements": ['gemSkills: 6'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1355
    "Mythic Ancient Legendary": {
        "ap_id": 1355,
        "description": "Create a gem with a raw minimum damage of 300.000 ...",
        "requirements": ['gemSkills: 1'],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 1356
    "Nature Takes Over": {
        "ap_id": 1356,
        "description": "Have no own buildings on the field at the end of t...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1357
    "Near Death": {
        "ap_id": 1357,
        "description": "Suffer mana loss from a shadow projectile when und...",
        "requirements": ['Shadow element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1358
    "Necrotrophic": {
        "ap_id": 1358,
        "description": "Reach 1.000 poison kills through all the battles.",
        "requirements": ['Poison skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1359
    "Need Lots of Them": {
        "ap_id": 1359,
        "description": "Beat 60 waves using at most grade 2 gems.",
        "requirements": ['minWave: 60'],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 1360
    "Need More Rage": {
        "ap_id": 1360,
        "description": "Upgrade a gem in the enraging socket.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1361
    "Needle Storm": {
        "ap_id": 1361,
        "description": "Deal 350 gem wasp stings to creatures.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1362
    "Nest Blaster": {
        "ap_id": 1362,
        "description": "Destroy 2 monster nests before wave 12.",
        "requirements": ['Monster Nest element'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1363
    "Nest Buster": {
        "ap_id": 1363,
        "description": "Destroy 3 monster nests before wave 6.",
        "requirements": ['Monster Nest element'],
        "reward": "skillPoints:3",
        "required_effort": "Minor",
    },
    # AP ID: 1364
    "No Armor Area": {
        "ap_id": 1364,
        "description": "Beat 90 waves using only armor tearing gems.",
        "requirements": [
            'Armor Tearing skill',
            'minWave: 90',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1365
    "No Beacon Zone": {
        "ap_id": 1365,
        "description": "Reach 200 beacons destroyed through all the battle...",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1366
    "No Honor Among Thieves": {
        "ap_id": 1366,
        "description": "Have a watchtower kill a specter.",
        "requirements": [
            'Ritual trait',
            'Specter element',
            'Watchtower element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1367
    "No Land for Swarmlings": {
        "ap_id": 1367,
        "description": "Kill 3.333 swarmlings.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 1368
    "No More Rounds": {
        "ap_id": 1368,
        "description": "Kill 60 banished monsters with shrines.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1369
    "No Need to Aim": {
        "ap_id": 1369,
        "description": "Have 4 barrage enhanced gems at the same time.",
        "requirements": ['Barrage skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1370
    "No Place to Hide": {
        "ap_id": 1370,
        "description": "Cast 25 strike spells.",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1371
    "No Stone Unturned": {
        "ap_id": 1371,
        "description": "Open 5 drop holders.",
        "requirements": ['Drop Holder element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1372
    "No Time to Rest": {
        "ap_id": 1372,
        "description": "Have the Haste trait set to level 6 or higher and ...",
        "requirements": ['Haste trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1373
    "No Time to Waste": {
        "ap_id": 1373,
        "description": "Reach 5.000 waves started early through all the ba...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1374
    "No Use of Vitality": {
        "ap_id": 1374,
        "description": "Kill a monster having at least 20.000 hit points.",
        "requirements": ['A monster with atleast 20.000hp'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1375
    "No You Won't!": {
        "ap_id": 1375,
        "description": "Destroy a watchtower before it could fire.",
        "requirements": [
            'Bolt skill',
            'Watchtower element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1376
    "Not Chasing Shadows Anymore": {
        "ap_id": 1376,
        "description": "Kill 4 shadows.",
        "requirements": [
            'Ritual trait',
            'Shadow element',
        ],
        "reward": "skillPoints:3",
        "required_effort": "Major",
    },
    # AP ID: 1377
    "Not So Fast": {
        "ap_id": 1377,
        "description": "Freeze a specter.",
        "requirements": [
            'Freeze skill',
            'Ritual trait',
            'Specter element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1378
    "Not So Omni Anymore": {
        "ap_id": 1378,
        "description": "Destroy 10 omnibeacons.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1379
    "Not Worth It": {
        "ap_id": 1379,
        "description": "Harvest 9.000 mana from a corrupted mana shard.",
        "requirements": ['Corrupted Mana Shard element'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1380
    "Nothing Prevails": {
        "ap_id": 1380,
        "description": "Reach 25.000 poison kills through all the battles.",
        "requirements": ['Poison skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1381
    "Nox Mist": {
        "ap_id": 1381,
        "description": "Win a battle using only poison gems.",
        "requirements": ['Poison skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1382
    "Oh Ven": {
        "ap_id": 1382,
        "description": "Spread the poison",
        "requirements": [
            'Poison skill',
            '90 monsters poisoned at the same time',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1383
    "Ok Flier": {
        "ap_id": 1383,
        "description": "Kill 340 monsters while there are at least 2 wrait...",
        "requirements": [
            'Ritual trait',
            'Wraith element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1384
    "Omelette": {
        "ap_id": 1384,
        "description": "Reach 200 monster eggs cracked through all the bat...",
        "requirements": ['Swarm Queen element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1385
    "Omnibomb": {
        "ap_id": 1385,
        "description": "Destroy a building and a non-monster creature with...",
        "requirements": ['Ritual trait'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1386
    "On the Shoulders of Giants": {
        "ap_id": 1386,
        "description": "Have the Giant Domination trait set to level 6 or ...",
        "requirements": ['Giant Domination trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1387
    "One Hit is All it Takes": {
        "ap_id": 1387,
        "description": "Kill a wraith with one hit.",
        "requirements": [
            'Ritual trait',
            'Wraith element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1388
    "One Less Problem": {
        "ap_id": 1388,
        "description": "Destroy a monster nest while there is a wraith on ...",
        "requirements": [
            'Ritual trait',
            'Monster Nest element',
            'Wraith element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1389
    "One by One": {
        "ap_id": 1389,
        "description": "Deliver 750 one hit kills.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 1390
    "Orange Wand": {
        "ap_id": 1390,
        "description": "Reach wizard level 40.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1391
    "Ouch!": {
        "ap_id": 1391,
        "description": "Spend 900 mana on banishment.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1392
    "Out of Misery": {
        "ap_id": 1392,
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
    # AP ID: 1393
    "Out of Nowhere": {
        "ap_id": 1393,
        "description": "Kill a whited out possessed monster with bolt.",
        "requirements": [
            'Bolt skill',
            'Whiteout skill',
            'Possessed Monster element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1394
    "Outwhited": {
        "ap_id": 1394,
        "description": "Gain 4.700 xp with Whiteout spell crowd hits.",
        "requirements": ['Whiteout skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1395
    "Overheated": {
        "ap_id": 1395,
        "description": "Kill a giant with beam shot.",
        "requirements": ['Beam skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1396
    "Overpecked": {
        "ap_id": 1396,
        "description": "Deal 100 gem wasp stings to the same monster.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1397
    "Painful Leech": {
        "ap_id": 1397,
        "description": "Leech 3.200 mana from bleeding monsters.",
        "requirements": [
            'Bleeding skill',
            'Mana Leech skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1398
    "Paranormal Paragon": {
        "ap_id": 1398,
        "description": "Reach 500 non-monsters killed through all the batt...",
        "requirements": ['Ritual trait'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1399
    "Pat on the Back": {
        "ap_id": 1399,
        "description": "Amplify a gem.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1400
    "Path of Splats": {
        "ap_id": 1400,
        "description": "Kill 400 monsters.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1401
    "Peek Into The Abyss": {
        "ap_id": 1401,
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
    # AP ID: 1402
    "Pest Control": {
        "ap_id": 1402,
        "description": "Kill 333 swarmlings.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1403
    "Plentiful": {
        "ap_id": 1403,
        "description": "Have 1.000 shadow cores at the start of the battle...",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1404
    "Pointed Pain": {
        "ap_id": 1404,
        "description": "Deal 50 gem wasp stings to creatures.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1405
    "Popped": {
        "ap_id": 1405,
        "description": "Kill at least 30 gatekeeper fangs.",
        "requirements": [
            'Gatekeeper element',
            'Field A4',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1406
    "Popped Eggs": {
        "ap_id": 1406,
        "description": "Kill a swarm queen with a bolt.",
        "requirements": [
            'Bolt skill',
            'Swarm Queen element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1407
    "Popping Lights": {
        "ap_id": 1407,
        "description": "Destroy 5 beacons.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1408
    "Power Exchange": {
        "ap_id": 1408,
        "description": "Build 25 amplifiers.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1409
    "Power Flow": {
        "ap_id": 1409,
        "description": "Build 15 amplifiers.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1410
    "Power Node": {
        "ap_id": 1410,
        "description": "Activate the same shrine 5 times.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1411
    "Power Overwhelming": {
        "ap_id": 1411,
        "description": "Reach mana pool level 15.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 1412
    "Power Sharing": {
        "ap_id": 1412,
        "description": "Build 5 amplifiers.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1413
    "Powerful": {
        "ap_id": 1413,
        "description": "Create a gem with a raw minimum damage of 300 or h...",
        "requirements": ['gemSkills: 1'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1414
    "Precious": {
        "ap_id": 1414,
        "description": "Get a gem from a drop holder.",
        "requirements": ['Drop Holder element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1415
    "Prismatic": {
        "ap_id": 1415,
        "description": "Create a gem of 6 components.",
        "requirements": ['gemSkills: 6'],
        "reward": "skillPoints:2",
        "required_effort": "Minor",
    },
    # AP ID: 1416
    "Prismatic Takeaway": {
        "ap_id": 1416,
        "description": "Have a specter steal a gem of 6 components.",
        "requirements": [
            'Specter element',
            'gemSkills: 6',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1417
    "Punching Deep": {
        "ap_id": 1417,
        "description": "Tear a total of 2.500 armor with wasp stings.",
        "requirements": ['Armor Tearing skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1418
    "Puncture Therapy": {
        "ap_id": 1418,
        "description": "Deal 950 gem wasp stings to creatures.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1419
    "Punctured Texture": {
        "ap_id": 1419,
        "description": "Deal 5.000 gem wasp stings to buildings.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1420
    "Puncturing Shots": {
        "ap_id": 1420,
        "description": "Deliver 75 one hit kills.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1421
    "Purged": {
        "ap_id": 1421,
        "description": "Kill 179 marked monsters.",
        "requirements": ['Marked Monster element', 'minWave: 70'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1422
    "Purist": {
        "ap_id": 1422,
        "description": "Beat 120 waves and don't use any strike or gem enh...",
        "requirements": ['minWave: 120'],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 1423
    "Purple Wand": {
        "ap_id": 1423,
        "description": "Reach wizard level 200.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 1424
    "Put Those Down Now!": {
        "ap_id": 1424,
        "description": "Have 10 orblets carried by monsters at the same ti...",
        "requirements": ['Orb of Presence skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1425
    "Puzzling Bunch": {
        "ap_id": 1425,
        "description": "Add 16 talisman fragments to your shape collection...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1426
    "Pylons of Destruction": {
        "ap_id": 1426,
        "description": "Reach 5.000 pylon kills through all the battles.",
        "requirements": ['Pylons skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1427
    "Quadpierced": {
        "ap_id": 1427,
        "description": "Cast 4 ice shards on the same monster.",
        "requirements": ['Ice Shards skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1428
    "Quick Circle": {
        "ap_id": 1428,
        "description": "Create a grade 12 gem before wave 12.",
        "requirements": ['minGemGrade: 12'],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 1429
    "Quicksave": {
        "ap_id": 1429,
        "description": "Instantly drop a gem to your inventory.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1430
    "Quite a List": {
        "ap_id": 1430,
        "description": "Have at least 15 different talisman properties.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1431
    "Rage Control": {
        "ap_id": 1431,
        "description": "Kill 400 enraged swarmlings with barrage.",
        "requirements": ['Barrage skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1432
    "Rageout": {
        "ap_id": 1432,
        "description": "Enrage 30 waves.",
        "requirements": ['minWave: 30'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1433
    "Rageroom": {
        "ap_id": 1433,
        "description": "Build 100 walls and start 100 enraged waves.",
        "requirements": [
            'Wall element',
            'minWave: 100',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1434
    "Raging Habit": {
        "ap_id": 1434,
        "description": "Enrage 80 waves.",
        "requirements": ['minWave: 80'],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 1435
    "Rainbow Strike": {
        "ap_id": 1435,
        "description": "Kill 900 monsters with prismatic gem wasps.",
        "requirements": ['gemSkills: 6'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1436
    "Raindrop": {
        "ap_id": 1436,
        "description": "Drop 18 gem bombs while it's raining.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1437
    "Razor Path": {
        "ap_id": 1437,
        "description": "Build 60 traps.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1438
    "Red Orange": {
        "ap_id": 1438,
        "description": "Leech 700 mana from bleeding monsters.",
        "requirements": [
            'Bleeding skill',
            'Mana Leech skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1439
    "Red Wand": {
        "ap_id": 1439,
        "description": "Reach wizard level 500.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 1440
    "Refrost": {
        "ap_id": 1440,
        "description": "Freeze 111 frozen monsters.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1441
    "Regaining Knowledge": {
        "ap_id": 1441,
        "description": "Acquire 5 skills.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1442
    "Renzokuken": {
        "ap_id": 1442,
        "description": "Break your frozen time gem bombing limits",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1443
    "Resourceful": {
        "ap_id": 1443,
        "description": "Reach 5.000 mana harvested from shards through all...",
        "requirements": ['Mana Shard element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1444
    "Restless": {
        "ap_id": 1444,
        "description": "Call 35 waves early.",
        "requirements": ['minWave: 35'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1445
    "Return of Investment": {
        "ap_id": 1445,
        "description": "Leech 900 mana with a grade 1 gem.",
        "requirements": [
            'Mana Leech skill',
            'minGemGrade: 1',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1446
    "Riding the Waves": {
        "ap_id": 1446,
        "description": "Reach 1.000 waves beaten through all the battles.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1447
    "Rising Tide": {
        "ap_id": 1447,
        "description": "Banish 150 monsters while there are 2 or more wrai...",
        "requirements": [
            'Ritual trait',
            'Wraith element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1448
    "Roof Knocking": {
        "ap_id": 1448,
        "description": "Deal 20 gem wasp stings to buildings.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1449
    "Root Canal": {
        "ap_id": 1449,
        "description": "Destroy 2 monster nests.",
        "requirements": ['Monster Nest element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1450
    "Rooting From Afar": {
        "ap_id": 1450,
        "description": "Kill a gatekeeper fang with a barrage shell.",
        "requirements": [
            'Barrage skill',
            'Gatekeeper element',
            'Field A4',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1451
    "Rotten Aura": {
        "ap_id": 1451,
        "description": "Leech 1.100 mana from poisoned monsters.",
        "requirements": [
            'Mana Leech skill',
            'Poison skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1452
    "Rough Path": {
        "ap_id": 1452,
        "description": "Kill 60 monsters with gems in traps.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1453
    "Round Cut": {
        "ap_id": 1453,
        "description": "Create a grade 12 gem.",
        "requirements": ['minGemGrade: 12'],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 1454
    "Round Cut Plus": {
        "ap_id": 1454,
        "description": "Create a grade 16 gem.",
        "requirements": ['minGemGrade: 16'],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 1455
    "Route Planning": {
        "ap_id": 1455,
        "description": "Destroy 5 barricades.",
        "requirements": ['Barricade element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1456
    "Rugged Defense": {
        "ap_id": 1456,
        "description": "Have 16 bolt enhanced gems at the same time.",
        "requirements": ['Bolt skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1457
    "Ruined Ghost Town": {
        "ap_id": 1457,
        "description": "Destroy 5 dwellings.",
        "requirements": ['Abandoned Dwelling element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1458
    "Safe and Secure": {
        "ap_id": 1458,
        "description": "Strengthen your orb with 7 gems in amplifiers.",
        "requirements": ['Amplifiers skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1459
    "Salvation": {
        "ap_id": 1459,
        "description": "Hit 150 whited out monsters with shrines.",
        "requirements": [
            'Whiteout skill',
            'Shrine element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1460
    "Scare Tactics": {
        "ap_id": 1460,
        "description": "Cast 5 strike spells.",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1461
    "Scour You All": {
        "ap_id": 1461,
        "description": "Kill 660 banished monsters with shrines.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1462
    "Second Thoughts": {
        "ap_id": 1462,
        "description": "Add a different enhancement on an enhanced gem.",
        "requirements": [
            'Bolt skill',
            'Beam skill',
            'Barrage skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1463
    "Seen Battle": {
        "ap_id": 1463,
        "description": "Have a grade 1 gem with 500 hits.",
        "requirements": ['minGemGrade: 1'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1464
    "Settlement": {
        "ap_id": 1464,
        "description": "Build 15 towers.",
        "requirements": ['Tower element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1465
    "Shaken Ice": {
        "ap_id": 1465,
        "description": "Hit 475 frozen monsters with shrines.",
        "requirements": [
            'Freeze skill',
            'Shrine element',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 1466
    "Shapeshifter": {
        "ap_id": 1466,
        "description": "Complete your talisman fragment shape collection.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1467
    "Shard Siphon": {
        "ap_id": 1467,
        "description": "Reach 20.000 mana harvested from shards through al...",
        "requirements": ['Mana Shard element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1468
    "Shardalot": {
        "ap_id": 1468,
        "description": "Cast 6 ice shards on the same monster.",
        "requirements": ['Ice Shards skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1469
    "Sharp Shot": {
        "ap_id": 1469,
        "description": "Kill a shadow with a shot fired by a gem having at...",
        "requirements": [
            'Ritual trait',
            'Shadow element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1470
    "Sharpened": {
        "ap_id": 1470,
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
    # AP ID: 1471
    "Shatter Them All": {
        "ap_id": 1471,
        "description": "Reach 1.000 beacons destroyed through all the batt...",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1472
    "Shattered Orb": {
        "ap_id": 1472,
        "description": "Lose a battle.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1473
    "Shattered Waves": {
        "ap_id": 1473,
        "description": "Hit 225 frozen monsters with shrines.",
        "requirements": [
            'Freeze skill',
            'Shrine element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1474
    "Shattering": {
        "ap_id": 1474,
        "description": "Kill 90 frozen monsters with bolt.",
        "requirements": [
            'Bolt skill',
            'Freeze skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1475
    "Shavings All Around": {
        "ap_id": 1475,
        "description": "Win a battle using only armor tearing gems.",
        "requirements": ['Armor Tearing skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1476
    "Shell Shock": {
        "ap_id": 1476,
        "description": "Have 8 barrage enhanced gems at the same time.",
        "requirements": ['Barrage skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1477
    "Shieldbreaker": {
        "ap_id": 1477,
        "description": "Destroy 3 shield beacons.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1478
    "Shooting Where it Hurts": {
        "ap_id": 1478,
        "description": "Beat 90 waves using only critical hit gems.",
        "requirements": [
            'Critical Hit skill',
            'minWave: 90',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1479
    "Short Tempered": {
        "ap_id": 1479,
        "description": "Call 5 waves early.",
        "requirements": ['minWave: 5'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1480
    "Shovel Swing": {
        "ap_id": 1480,
        "description": "Hit 15 frozen monsters with shrines.",
        "requirements": [
            'Freeze skill',
            'Shrine element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1481
    "Shred Some Armor": {
        "ap_id": 1481,
        "description": "Have a pure armor tearing gem with 3.000 hits.",
        "requirements": ['Armor Tearing skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1482
    "Shrinemaster": {
        "ap_id": 1482,
        "description": "Reach 20.000 shrine kills through all the battles.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1483
    "Sigil": {
        "ap_id": 1483,
        "description": "Fill all the sockets in your talisman with fragmen...",
        "requirements": ['Shadow Core element'],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 1484
    "Size Matters": {
        "ap_id": 1484,
        "description": "Beat 100 waves on max Swarmling and Giant dominati...",
        "requirements": [
            'Swarmling Domination trait',
            'Giant Domination trait',
            'minWave: 100',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 1485
    "Skillful": {
        "ap_id": 1485,
        "description": "Acquire and raise all skills to level 5 or above.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1486
    "Skylark": {
        "ap_id": 1486,
        "description": "Call every wave early in a battle.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1487
    "Sliced Ice": {
        "ap_id": 1487,
        "description": "Gain 1.800 xp with Ice Shards spell crowd hits.",
        "requirements": ['Ice Shards skill'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1488
    "Slime Block": {
        "ap_id": 1488,
        "description": "Nine slimeballs is all it takes",
        "requirements": ['A monster with atleast 20.000hp'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1489
    "Slow Creep": {
        "ap_id": 1489,
        "description": "Poison 130 whited out monsters.",
        "requirements": [
            'Poison skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1490
    "Slow Drain": {
        "ap_id": 1490,
        "description": "Deal 10.000 poison damage to a monster.",
        "requirements": ['Poison skill'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1491
    "Slow Motion": {
        "ap_id": 1491,
        "description": "Enhance a pure slowing gem having random priority ...",
        "requirements": [
            'Beam skill',
            'Slowing skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1492
    "Slowly but Surely": {
        "ap_id": 1492,
        "description": "Beat 90 waves using only slowing gems.",
        "requirements": [
            'Slowing skill',
            'minWave: 90',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1493
    "Smoke in the Sky": {
        "ap_id": 1493,
        "description": "Reach 20 non-monsters killed through all the battl...",
        "requirements": ['Ritual trait'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1494
    "Snatchers": {
        "ap_id": 1494,
        "description": "Gain 3.200 mana from drops.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1495
    "Snow Blower": {
        "ap_id": 1495,
        "description": "Kill 20 frozen monsters with barrage.",
        "requirements": [
            'Barrage skill',
            'Freeze skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1496
    "Snow Dust": {
        "ap_id": 1496,
        "description": "Kill 95 frozen monsters while it's snowing.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1497
    "Snowball": {
        "ap_id": 1497,
        "description": "Drop 27 gem bombs while it's snowing.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1498
    "Snowdust Blindness": {
        "ap_id": 1498,
        "description": "Gain 2.300 xp with Whiteout spell crowd hits.",
        "requirements": ['Whiteout skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1499
    "So Attached": {
        "ap_id": 1499,
        "description": "Win a Trial battle without losing any orblets.",
        "requirements": ['Trial'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1500
    "So Early": {
        "ap_id": 1500,
        "description": "Reach 1.000 waves started early through all the ba...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1501
    "So Enduring": {
        "ap_id": 1501,
        "description": "Have the Adaptive Carapace trait set to level 6 or...",
        "requirements": ['Adaptive Carapace trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1502
    "Socketed Rage": {
        "ap_id": 1502,
        "description": "Enrage a wave.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1503
    "Something Special": {
        "ap_id": 1503,
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
    # AP ID: 1504
    "Sparse Snares": {
        "ap_id": 1504,
        "description": "Build 10 traps.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1505
    "Special Purpose": {
        "ap_id": 1505,
        "description": "Change the target priority of a gem.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1506
    "Spectrin Tetramer": {
        "ap_id": 1506,
        "description": "Have the Vital Link trait set to level 6 or higher...",
        "requirements": ['Vital Link trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1507
    "Spitting Darkness": {
        "ap_id": 1507,
        "description": "Leave a gatekeeper fang alive until it can launch ...",
        "requirements": [
            'Gatekeeper element',
            'Field A4',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1508
    "Splash Swim Splash": {
        "ap_id": 1508,
        "description": "Full of oxygen",
        "requirements": ['Click on water in a field\nRequires a field with water'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1509
    "Starter Pack": {
        "ap_id": 1509,
        "description": "Add 8 talisman fragments to your shape collection.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1510
    "Stash No More": {
        "ap_id": 1510,
        "description": "Destroy a previously opened wizard stash.",
        "requirements": ['Wizard Stash element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1511
    "Stay Some More": {
        "ap_id": 1511,
        "description": "Cast freeze on an apparition 3 times.",
        "requirements": [
            'Freeze skill',
            'Ritual trait',
            'Apparition element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1512
    "Still Alive": {
        "ap_id": 1512,
        "description": "Beat 60 waves.",
        "requirements": ['minWave: 60'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1513
    "Still Chill": {
        "ap_id": 1513,
        "description": "Gain 1.500 xp with Freeze spell crowd hits.",
        "requirements": ['Freeze skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1514
    "Still Lit": {
        "ap_id": 1514,
        "description": "Have 15 or more beacons standing at the end of the...",
        "requirements": [
            'Dark Masonry trait',
            'Beacon element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1515
    "Still No Match": {
        "ap_id": 1515,
        "description": "Destroy an omnibeacon.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1516
    "Sting Stack": {
        "ap_id": 1516,
        "description": "Deal 1.000 gem wasp stings to buildings.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1517
    "Stinging Sphere": {
        "ap_id": 1517,
        "description": "Deliver 100 banishments with your orb.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1518
    "Stingy Cloud": {
        "ap_id": 1518,
        "description": "Reach 5.000 gem wasp kills through all the battles...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1519
    "Stingy Downfall": {
        "ap_id": 1519,
        "description": "Deal 400 wasp stings to a spire.",
        "requirements": [
            'Ritual trait',
            'Spire element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1520
    "Stirring Up the Nest": {
        "ap_id": 1520,
        "description": "Deliver gem bomb and wasp kills only.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1521
    "Stockpile": {
        "ap_id": 1521,
        "description": "Have 30 fragments in your talisman inventory.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1522
    "Stolen Shine": {
        "ap_id": 1522,
        "description": "Leech 2.700 mana from whited out monsters.",
        "requirements": [
            'Mana Leech skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1523
    "Stone Monument": {
        "ap_id": 1523,
        "description": "Build 240 walls.",
        "requirements": ['Wall element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1524
    "Stones to Dust": {
        "ap_id": 1524,
        "description": "Demolish one of your structures.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1525
    "Stormbringer": {
        "ap_id": 1525,
        "description": "Reach 1.000 strike spells cast through all the bat...",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1526
    "Stormed Beacons": {
        "ap_id": 1526,
        "description": "Destroy 15 beacons.",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1527
    "Strike Anywhere": {
        "ap_id": 1527,
        "description": "Cast a strike spell.",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1528
    "Stronger Than Before": {
        "ap_id": 1528,
        "description": "Set corrupted banishment to level 12 and banish a ...",
        "requirements": ['Corrupted Banishment trait'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1529
    "Stumbling": {
        "ap_id": 1529,
        "description": "Hit the same monster with traps 100 times.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1530
    "Super Gem": {
        "ap_id": 1530,
        "description": "Create a grade 3 gem with 300 effective max damage...",
        "requirements": ['minGemGrade: 3'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1531
    "Supply Line Cut": {
        "ap_id": 1531,
        "description": "Kill a swarm queen with a barrage shell.",
        "requirements": [
            'Barrage skill',
            'Swarm Queen element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1532
    "Swarmling Season": {
        "ap_id": 1532,
        "description": "Kill 999 swarmlings.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1533
    "Swift Death": {
        "ap_id": 1533,
        "description": "Kill the gatekeeper with a bolt.",
        "requirements": [
            'Bolt skill',
            'Gatekeeper element',
            'Field A4',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1534
    "Swift Deployment": {
        "ap_id": 1534,
        "description": "Have 20 gems on the battlefield before wave 5.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1535
    "Take Them I Have More": {
        "ap_id": 1535,
        "description": "Have 12 of your gems destroyed or stolen.",
        "requirements": [
            'Ritual trait',
            'Specter element',
            'Watchtower element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1536
    "Takers": {
        "ap_id": 1536,
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
    # AP ID: 1537
    "Tapped Essence": {
        "ap_id": 1537,
        "description": "Leech 1.500 mana from bleeding monsters.",
        "requirements": [
            'Bleeding skill',
            'Mana Leech skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1538
    "Targeting Weak Points": {
        "ap_id": 1538,
        "description": "Win a battle using only critical hit gems.",
        "requirements": ['Critical Hit skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1539
    "Taste All The Affixes": {
        "ap_id": 1539,
        "description": "Kill 2.500 monsters with prismatic gem wasps.",
        "requirements": ['gemSkills: 6'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1540
    "Tasting the Darkness": {
        "ap_id": 1540,
        "description": "Break 3 tombs open.",
        "requirements": ['Tomb element'],
        "reward": "skillPoints:3",
        "required_effort": "Minor",
    },
    # AP ID: 1541
    "Teleport Lag": {
        "ap_id": 1541,
        "description": "Banish a monster at least 5 times.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1542
    "Ten Angry Waves": {
        "ap_id": 1542,
        "description": "Enrage 10 waves.",
        "requirements": ['minWave: 10'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1543
    "That Was Rude": {
        "ap_id": 1543,
        "description": "Lose a gem with more than 1.000 hits to a watchtow...",
        "requirements": ['Watchtower element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1544
    "That Was Your Last Move": {
        "ap_id": 1544,
        "description": "Kill a wizard hunter while it's attacking one of y...",
        "requirements": ['Wizard Hunter element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1545
    "That one!": {
        "ap_id": 1545,
        "description": "Select a monster.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1546
    "The Gathering": {
        "ap_id": 1546,
        "description": "Summon 500 monsters by enraging waves.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Major",
    },
    # AP ID: 1547
    "The Horror": {
        "ap_id": 1547,
        "description": "Lose 3.333 mana to shadows.",
        "requirements": [
            'Ritual trait',
            'Shadow element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1548
    "The Killing Will Never Stop": {
        "ap_id": 1548,
        "description": "Reach 200.000 monsters killed through all the batt...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1549
    "The Mana Reaper": {
        "ap_id": 1549,
        "description": "Reach 100.000 mana harvested from shards through a...",
        "requirements": ['Mana Shard element'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1550
    "The Messenger Must Die": {
        "ap_id": 1550,
        "description": "Kill a shadow.",
        "requirements": [
            'Ritual trait',
            'Shadow element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1551
    "The Peeler": {
        "ap_id": 1551,
        "description": "Create a grade 12 pure armor tearing gem.",
        "requirements": [
            'Armor Tearing skill',
            'minGemGrade: 12',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1552
    "The Price of Obsession": {
        "ap_id": 1552,
        "description": "Kill 590 banished monsters.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1553
    "There it is!": {
        "ap_id": 1553,
        "description": "Select a building.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1554
    "There's No Time": {
        "ap_id": 1554,
        "description": "Call 140 waves early.",
        "requirements": [
            'minWave: 140',
            'Endurance',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1555
    "They Are Millions": {
        "ap_id": 1555,
        "description": "Reach 1.000.000 monsters killed through all the ba...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1556
    "They Are Still Here": {
        "ap_id": 1556,
        "description": "Kill 2 apparitions.",
        "requirements": [
            'Ritual trait',
            'Apparition element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1557
    "They Keep Coming": {
        "ap_id": 1557,
        "description": "Kill 12.000 monsters.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Major",
    },
    # AP ID: 1558
    "Thin Ice": {
        "ap_id": 1558,
        "description": "Kill 20 frozen monsters with gems in traps.",
        "requirements": [
            'Freeze skill',
            'Traps skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1559
    "Thin Them Out": {
        "ap_id": 1559,
        "description": "Have the Strength in Numbers trait set to level 6 ...",
        "requirements": ['Strength in Numbers trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1560
    "Third Grade": {
        "ap_id": 1560,
        "description": "Create a grade 3 gem.",
        "requirements": ['minGemGrade: 3'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1561
    "Thorned Sphere": {
        "ap_id": 1561,
        "description": "Deliver 400 banishments with your orb.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Minor",
    },
    # AP ID: 1562
    "Through All Layers": {
        "ap_id": 1562,
        "description": "Kill a monster having at least 200 armor.",
        "requirements": ['A monster with atleast 200 armor'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1563
    "Thunderstruck": {
        "ap_id": 1563,
        "description": "Kill 120 monsters with gem bombs and wasps.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1564
    "Tightly Secured": {
        "ap_id": 1564,
        "description": "Don't let any monster touch your orb for 60 beaten...",
        "requirements": ['minWave: 60'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1565
    "Time Bent": {
        "ap_id": 1565,
        "description": "Have 90 monsters slowed at the same time.",
        "requirements": ['Slowing skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1566
    "Time to Rise": {
        "ap_id": 1566,
        "description": "Have the Awakening trait set to level 6 or higher ...",
        "requirements": ['Awakening trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1567
    "Time to Upgrade": {
        "ap_id": 1567,
        "description": "Have a grade 1 gem with 4.500 hits.",
        "requirements": ['minGemGrade: 1'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1568
    "Tiny but Deadly": {
        "ap_id": 1568,
        "description": "Reach 50.000 gem wasp kills through all the battle...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1569
    "To the Last Drop": {
        "ap_id": 1569,
        "description": "Leech 4.700 mana from poisoned monsters.",
        "requirements": [
            'Mana Leech skill',
            'Poison skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1570
    "Tomb No Matter What": {
        "ap_id": 1570,
        "description": "Open a tomb while there is a spire on the battlefi...",
        "requirements": [
            'Ritual trait',
            'Spire element',
            'Tomb element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1571
    "Tomb Raiding": {
        "ap_id": 1571,
        "description": "Break a tomb open before wave 15.",
        "requirements": ['Tomb element'],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 1572
    "Tomb Stomping": {
        "ap_id": 1572,
        "description": "Break 4 tombs open.",
        "requirements": ['Tomb element'],
        "reward": "skillPoints:3",
        "required_effort": "Major",
    },
    # AP ID: 1573
    "Too Curious": {
        "ap_id": 1573,
        "description": "Break 2 tombs open.",
        "requirements": ['Tomb element'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1574
    "Too Easy": {
        "ap_id": 1574,
        "description": "Win a Trial battle with at least 3 waves enraged.",
        "requirements": [
            'minWave: 3',
            'Trial',
        ],
        "reward": "skillPoints:3",
        "required_effort": "Trivial",
    },
    # AP ID: 1575
    "Too Long to Hold Your Breath": {
        "ap_id": 1575,
        "description": "Beat 90 waves using only poison gems.",
        "requirements": [
            'Poison skill',
            'minWave: 90',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1576
    "Towerful": {
        "ap_id": 1576,
        "description": "Build 5 towers.",
        "requirements": ['Tower element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1577
    "Trapland": {
        "ap_id": 1577,
        "description": "And it's bloody too",
        "requirements": [
            'Traps skill',
            'Complete a level using only traps and no poison gems',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1578
    "Trembling": {
        "ap_id": 1578,
        "description": "Kill 1.500 monsters with gems in traps.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 1579
    "Tricolor": {
        "ap_id": 1579,
        "description": "Create a gem of 3 components.",
        "requirements": ['gemSkills: 3'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1580
    "Troll's Eye": {
        "ap_id": 1580,
        "description": "Kill a giant with one shot.",
        "requirements": ['Bolt skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1581
    "Tumbling Billows": {
        "ap_id": 1581,
        "description": "Have the Swarmling Domination trait set to level 6...",
        "requirements": ['Swarmling Domination trait'],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1582
    "Twice the Blast": {
        "ap_id": 1582,
        "description": "Have 2 barrage enhanced gems at the same time.",
        "requirements": ['Barrage skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1583
    "Twice the Shock": {
        "ap_id": 1583,
        "description": "Hit the same monster 2 times with shrines.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1584
    "Twice the Steepness": {
        "ap_id": 1584,
        "description": "Kill 170 monsters while there are at least 2 wrait...",
        "requirements": [
            'Ritual trait',
            'Wraith element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1585
    "Twice the Terror": {
        "ap_id": 1585,
        "description": "Kill 2 shadows.",
        "requirements": [
            'Ritual trait',
            'Shadow element',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Trivial",
    },
    # AP ID: 1586
    "Unarmed": {
        "ap_id": 1586,
        "description": "Have no gems when wave 20 starts.",
        "requirements": ['minWave: 20'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1587
    "Under Pressure": {
        "ap_id": 1587,
        "description": "Shoot down 340 shadow projectiles.",
        "requirements": [
            'Ritual trait',
            'Shadow element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1588
    "Unending Flow": {
        "ap_id": 1588,
        "description": "Kill 24.000 monsters.",
        "requirements": [],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 1589
    "Unholy Stack": {
        "ap_id": 1589,
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
    # AP ID: 1590
    "Uninvited": {
        "ap_id": 1590,
        "description": "Summon 100 monsters by enraging waves.",
        "requirements": [],
        "reward": "skillPoints:2",
        "required_effort": "Minor",
    },
    # AP ID: 1591
    "Unsupportive": {
        "ap_id": 1591,
        "description": "Reach 100 beacons destroyed through all the battle...",
        "requirements": ['Beacon element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1592
    "Uraj and Khalis": {
        "ap_id": 1592,
        "description": "Activate the lanterns",
        "requirements": [
            'Lanterns skill',
            'Field H3',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1593
    "Urban Warfare": {
        "ap_id": 1593,
        "description": "Destroy a dwelling and kill a monster with one gem...",
        "requirements": ['Abandoned Dwelling element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1594
    "Vantage Point Down": {
        "ap_id": 1594,
        "description": "Demolish a pylon.",
        "requirements": ['Pylons skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1595
    "Versatile Charm": {
        "ap_id": 1595,
        "description": "Have at least 10 different talisman properties.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1596
    "Violet Ray": {
        "ap_id": 1596,
        "description": "Kill 20 frozen monsters with beam.",
        "requirements": [
            'Beam skill',
            'Freeze skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1597
    "Warming Up": {
        "ap_id": 1597,
        "description": "Have a grade 1 gem with 100 hits.",
        "requirements": ['minGemGrade: 1'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1598
    "Wash Away": {
        "ap_id": 1598,
        "description": "Kill 110 monsters while it's raining.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1599
    "Wasp Defense": {
        "ap_id": 1599,
        "description": "Smash 3 jars of wasps before wave 3.",
        "requirements": ['Field X2'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1600
    "Wasp Storm": {
        "ap_id": 1600,
        "description": "Kill 360 monsters with gem bombs and wasps.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1601
    "Waspocalypse": {
        "ap_id": 1601,
        "description": "Kill 1.080 monsters with gem bombs and wasps.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1602
    "Watch Your Step": {
        "ap_id": 1602,
        "description": "Build 40 traps.",
        "requirements": ['Traps skill'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1603
    "Wave Pecking": {
        "ap_id": 1603,
        "description": "Summon 20 monsters by enraging waves.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1604
    "Wave Smasher": {
        "ap_id": 1604,
        "description": "Reach 10.000 waves beaten through all the battles.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1605
    "Waves for Breakfast": {
        "ap_id": 1605,
        "description": "Reach 2.000 waves beaten through all the battles.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1606
    "Wavy": {
        "ap_id": 1606,
        "description": "Reach 500 waves beaten through all the battles.",
        "requirements": [
            'minWave: 500',
            'Endurance',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1607
    "We Just Wanna Be Free": {
        "ap_id": 1607,
        "description": "More than blue triangles",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1608
    "Weakened Wallet": {
        "ap_id": 1608,
        "description": "Leech 5.400 mana from whited out monsters.",
        "requirements": [
            'Mana Leech skill',
            'Whiteout skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1609
    "Weather Tower": {
        "ap_id": 1609,
        "description": "Activate a shrine while raining.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1610
    "Weather of Wasps": {
        "ap_id": 1610,
        "description": "Deal 3950 gem wasp stings to creatures.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1611
    "Well Defended": {
        "ap_id": 1611,
        "description": "Don't let any monster touch your orb for 20 beaten...",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1612
    "Well Earned": {
        "ap_id": 1612,
        "description": "Reach 500 battles won.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1613
    "Well Laid": {
        "ap_id": 1613,
        "description": "Have 10 gems on the battlefield.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1614
    "Well Prepared": {
        "ap_id": 1614,
        "description": "Have 20.000 initial mana.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1615
    "Well Trained for This": {
        "ap_id": 1615,
        "description": "Kill a wraith with a shot fired by a gem having at...",
        "requirements": [
            'Ritual trait',
            'Wraith element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1616
    "Whacked": {
        "ap_id": 1616,
        "description": "Kill a specter with one hit.",
        "requirements": [
            'Ritual trait',
            'Specter element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1617
    "What Are You Waiting For?": {
        "ap_id": 1617,
        "description": "Have all spells charged to 200%.",
        "requirements": [
            'Freeze skill',
            'Whiteout skill',
            'Ice Shards skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1618
    "White Ray": {
        "ap_id": 1618,
        "description": "Kill 90 frozen monsters with beam.",
        "requirements": [
            'Beam skill',
            'Freeze skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1619
    "White Ring of Death": {
        "ap_id": 1619,
        "description": "Gain 4.900 xp with Ice Shards spell crowd hits.",
        "requirements": ['Ice Shards skill'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1620
    "White Wand": {
        "ap_id": 1620,
        "description": "Reach wizard level 10.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1621
    "Why Not": {
        "ap_id": 1621,
        "description": "Enhance a gem in the enraging socket.",
        "requirements": [
            'Bolt skill',
            'Beam skill',
            'Barrage skill',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1622
    "Wicked Gem": {
        "ap_id": 1622,
        "description": "Have a grade 3 gem with 900 effective max damage.",
        "requirements": ['minGemGrade: 3'],
        "reward": "skillPoints:1",
        "required_effort": "Extreme",
    },
    # AP ID: 1623
    "Wings and Tentacles": {
        "ap_id": 1623,
        "description": "Reach 200 non-monsters killed through all the batt...",
        "requirements": ['Ritual trait'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
    # AP ID: 1624
    "Worst of Both Sizes": {
        "ap_id": 1624,
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
    # AP ID: 1625
    "Worthy": {
        "ap_id": 1625,
        "description": "Have 70 fields lit in Trial mode.",
        "requirements": ['Trial', 'fieldToken: 70'],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 1626
    "Xp Harvest": {
        "ap_id": 1626,
        "description": "Have 40 fields lit in Endurance mode.",
        "requirements": ['Endurance', 'fieldToken: 40'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1627
    "Yellow Wand": {
        "ap_id": 1627,
        "description": "Reach wizard level 20.",
        "requirements": [],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1628
    "You Could Be my Apprentice": {
        "ap_id": 1628,
        "description": "Have a watchtower kill a wizard hunter.",
        "requirements": [
            'Watchtower element',
            'Wizard Hunter element',
        ],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1629
    "You Had Your Chance": {
        "ap_id": 1629,
        "description": "Kill 260 banished monsters with shrines.",
        "requirements": ['Shrine element'],
        "reward": "skillPoints:1",
        "required_effort": "Minor",
    },
    # AP ID: 1630
    "You Shall Not Pass": {
        "ap_id": 1630,
        "description": "Don't let any monster touch your orb for 240 beate...",
        "requirements": [
            'minWave: 240',
            'Endurance',
        ],
        "reward": "skillPoints:3",
        "required_effort": "Extreme",
    },
    # AP ID: 1631
    "You're Safe With Me": {
        "ap_id": 1631,
        "description": "Win a battle with at least 10 orblets remaining.",
        "requirements": ['Orb of Presence skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1632
    "Your Mana is Mine": {
        "ap_id": 1632,
        "description": "Leech 10.000 mana with gems.",
        "requirements": ['Mana Leech skill'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1633
    "Zap Away": {
        "ap_id": 1633,
        "description": "Cast 175 strike spells.",
        "requirements": [
            'Ice Shards skill',
            'Whiteout skill',
            'Freeze skill',
        ],
        "reward": "skillPoints:2",
        "required_effort": "Extreme",
    },
    # AP ID: 1634
    "Zapped": {
        "ap_id": 1634,
        "description": "Get your Orb destroyed by a wizard tower.",
        "requirements": ['Wizard Tower element'],
        "reward": "skillPoints:1",
        "required_effort": "Trivial",
    },
    # AP ID: 1635
    "Zigzag Corridor": {
        "ap_id": 1635,
        "description": "Build 60 walls.",
        "requirements": ['Wall element'],
        "reward": "skillPoints:1",
        "required_effort": "Major",
    },
}

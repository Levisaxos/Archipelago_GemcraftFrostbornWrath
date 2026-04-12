"""
GemCraft Frostborn Wrath — Achievement Pack 5

Contains approximately 106 achievements.
Each achievement has a "grindiness" property ("Trivial", "Minor", "Major", "Extreme") for easy adjustment.
"""

achievement_requirements = {
    # ID 0: Put Those Down Now!
    "Put Those Down Now!": {
        "ap_id": 1424,
        "description": "Have 10 orblets carried by monsters at the same time.",
        "requirements": [
        'Orb of Presence skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 1: Puzzling Bunch
    "Puzzling Bunch": {
        "ap_id": 1425,
        "description": "Add 16 talisman fragments to your shape collection.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 2: Pylons of Destruction
    "Pylons of Destruction": {
        "ap_id": 1426,
        "description": "Reach 5.000 pylon kills through all the battles.",
        "requirements": [
        'Pylons skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 3: Quadpierced
    "Quadpierced": {
        "ap_id": 1427,
        "description": "Cast 4 ice shards on the same monster.",
        "requirements": [
        'Ice Shards skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 4: Quick Circle
    "Quick Circle": {
        "ap_id": 1428,
        "description": "Create a grade 12 gem before wave 12.",
        "requirements": [
        'minGemGrade: 12'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Extreme",
    },
    # ID 5: Quicksave
    "Quicksave": {
        "ap_id": 1429,
        "description": "Instantly drop a gem to your inventory.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 6: Quite a List
    "Quite a List": {
        "ap_id": 1430,
        "description": "Have at least 15 different talisman properties.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 7: Rage Control
    "Rage Control": {
        "ap_id": 1431,
        "description": "Kill 400 enraged swarmlings with barrage.",
        "requirements": [
        'Barrage skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 8: Rageout
    "Rageout": {
        "ap_id": 1432,
        "description": "Enrage 30 waves.",
        "requirements": [
        'minWave: 30'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 9: Rageroom
    "Rageroom": {
        "ap_id": 1433,
        "description": "Build 100 walls and start 100 enraged waves.",
        "requirements": [
        'Wall element',
        'minWave: 100'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 10: Raging Habit
    "Raging Habit": {
        "ap_id": 1434,
        "description": "Enrage 80 waves.",
        "requirements": [
        'minWave: 80'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Major",
    },
    # ID 11: Rainbow Strike
    "Rainbow Strike": {
        "ap_id": 1435,
        "description": "Kill 900 monsters with prismatic gem wasps.",
        "requirements": [
        'Critical Hit skill',
        'Mana Leech skill',
        'Bleeding skill',
        'Armor Tearing skill',
        'Slowing skill',
        'Poison skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 12: Raindrop
    "Raindrop": {
        "ap_id": 1436,
        "description": "Drop 18 gem bombs while it's raining.",
        "requirements": [
        'gemCount: 18'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 13: Razor Path
    "Razor Path": {
        "ap_id": 1437,
        "description": "Build 60 traps.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 14: Red Orange
    "Red Orange": {
        "ap_id": 1438,
        "description": "Leech 700 mana from bleeding monsters.",
        "requirements": [
        'Bleeding skill',
        'Mana Leech skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 15: Red Wand
    "Red Wand": {
        "ap_id": 1439,
        "description": "Reach wizard level 500.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Extreme",
    },
    # ID 16: Refrost
    "Refrost": {
        "ap_id": 1440,
        "description": "Freeze 111 frozen monsters.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 17: Regaining Knowledge
    "Regaining Knowledge": {
        "ap_id": 1441,
        "description": "Acquire 5 skills.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 18: Renzokuken
    "Renzokuken": {
        "ap_id": 1442,
        "description": "Break your frozen time gem bombing limits",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 19: Resourceful
    "Resourceful": {
        "ap_id": 1443,
        "description": "Reach 5.000 mana harvested from shards through all the battl...",
        "requirements": [
        'Mana Shard element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 20: Restless
    "Restless": {
        "ap_id": 1444,
        "description": "Call 35 waves early.",
        "requirements": [
        'minWave: 35'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 21: Return of Investment
    "Return of Investment": {
        "ap_id": 1445,
        "description": "Leech 900 mana with a grade 1 gem.",
        "requirements": [
        'Mana Leech skill',
        'minGemGrade: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 22: Riding the Waves
    "Riding the Waves": {
        "ap_id": 1446,
        "description": "Reach 1.000 waves beaten through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 23: Rising Tide
    "Rising Tide": {
        "ap_id": 1447,
        "description": "Banish 150 monsters while there are 2 or more wraiths on the...",
        "requirements": [
        'Ritual trait',
        'Wraith element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 24: Roof Knocking
    "Roof Knocking": {
        "ap_id": 1448,
        "description": "Deal 20 gem wasp stings to buildings.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 25: Root Canal
    "Root Canal": {
        "ap_id": 1449,
        "description": "Destroy 2 monster nests.",
        "requirements": [
        'Monster Nest element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 26: Rooting From Afar
    "Rooting From Afar": {
        "ap_id": 1450,
        "description": "Kill a gatekeeper fang with a barrage shell.",
        "requirements": [
        'Barrage skill',
        'Gatekeeper element',
        'Field A4'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 27: Rotten Aura
    "Rotten Aura": {
        "ap_id": 1451,
        "description": "Leech 1.100 mana from poisoned monsters.",
        "requirements": [
        'Mana Leech skill',
        'Poison skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 28: Rough Path
    "Rough Path": {
        "ap_id": 1452,
        "description": "Kill 60 monsters with gems in traps.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 29: Round Cut
    "Round Cut": {
        "ap_id": 1453,
        "description": "Create a grade 12 gem.",
        "requirements": [
        'minGemGrade: 12'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Extreme",
    },
    # ID 30: Round Cut Plus
    "Round Cut Plus": {
        "ap_id": 1454,
        "description": "Create a grade 16 gem.",
        "requirements": [
        'minGemGrade: 16'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Extreme",
    },
    # ID 31: Route Planning
    "Route Planning": {
        "ap_id": 1455,
        "description": "Destroy 5 barricades.",
        "requirements": [
        'Barricade element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 32: Rugged Defense
    "Rugged Defense": {
        "ap_id": 1456,
        "description": "Have 16 bolt enhanced gems at the same time.",
        "requirements": [
        'Bolt skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 33: Ruined Ghost Town
    "Ruined Ghost Town": {
        "ap_id": 1457,
        "description": "Destroy 5 dwellings.",
        "requirements": [
        'Abandoned Dwelling element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 34: Safe and Secure
    "Safe and Secure": {
        "ap_id": 1458,
        "description": "Strengthen your orb with 7 gems in amplifiers.",
        "requirements": [
        'Amplifiers skill',
        'gemCount: 7'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 35: Salvation
    "Salvation": {
        "ap_id": 1459,
        "description": "Hit 150 whited out monsters with shrines.",
        "requirements": [
        'Whiteout skill',
        'Shrine element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 36: Scare Tactics
    "Scare Tactics": {
        "ap_id": 1460,
        "description": "Cast 5 strike spells.",
        "requirements": [
        'strikeSpells:1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 37: Scour You All
    "Scour You All": {
        "ap_id": 1461,
        "description": "Kill 660 banished monsters with shrines.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 38: Second Thoughts
    "Second Thoughts": {
        "ap_id": 1462,
        "description": "Add a different enhancement on an enhanced gem.",
        "requirements": [
        'enhancementSpells: 2'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 39: Seen Battle
    "Seen Battle": {
        "ap_id": 1463,
        "description": "Have a grade 1 gem with 500 hits.",
        "requirements": [
        'minGemGrade: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 40: Settlement
    "Settlement": {
        "ap_id": 1464,
        "description": "Build 15 towers.",
        "requirements": [
        'Tower element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 41: Shaken Ice
    "Shaken Ice": {
        "ap_id": 1465,
        "description": "Hit 475 frozen monsters with shrines.",
        "requirements": [
        'Freeze skill',
        'Shrine element'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Extreme",
    },
    # ID 42: Shapeshifter
    "Shapeshifter": {
        "ap_id": 1466,
        "description": "Complete your talisman fragment shape collection.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 43: Shard Siphon
    "Shard Siphon": {
        "ap_id": 1467,
        "description": "Reach 20.000 mana harvested from shards through all the batt...",
        "requirements": [
        'Mana Shard element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 44: Shardalot
    "Shardalot": {
        "ap_id": 1468,
        "description": "Cast 6 ice shards on the same monster.",
        "requirements": [
        'Ice Shards skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 45: Sharp Shot
    "Sharp Shot": {
        "ap_id": 1469,
        "description": "Kill a shadow with a shot fired by a gem having at least 5.0...",
        "requirements": [
        'Ritual trait',
        'Shadow element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 46: Sharpened
    "Sharpened": {
        "ap_id": 1470,
        "description": "Enhance a gem in a trap.",
        "requirements": [
        'Traps skill',
        'Beam skill',
        'Bolt skill',
        'Barrage skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 47: Shatter Them All
    "Shatter Them All": {
        "ap_id": 1471,
        "description": "Reach 1.000 beacons destroyed through all the battles.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 48: Shattered Orb
    "Shattered Orb": {
        "ap_id": 1472,
        "description": "Lose a battle.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 49: Shattered Waves
    "Shattered Waves": {
        "ap_id": 1473,
        "description": "Hit 225 frozen monsters with shrines.",
        "requirements": [
        'Freeze skill',
        'Shrine element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 50: Shattering
    "Shattering": {
        "ap_id": 1474,
        "description": "Kill 90 frozen monsters with bolt.",
        "requirements": [
        'Bolt skill',
        'Freeze skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 51: Shavings All Around
    "Shavings All Around": {
        "ap_id": 1475,
        "description": "Win a battle using only armor tearing gems.",
        "requirements": [
        'Armor Tearing skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 52: Shell Shock
    "Shell Shock": {
        "ap_id": 1476,
        "description": "Have 8 barrage enhanced gems at the same time.",
        "requirements": [
        'Barrage skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 53: Shieldbreaker
    "Shieldbreaker": {
        "ap_id": 1477,
        "description": "Destroy 3 shield beacons.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 54: Shooting Where it Hurts
    "Shooting Where it Hurts": {
        "ap_id": 1478,
        "description": "Beat 90 waves using only critical hit gems.",
        "requirements": [
        'Critical Hit skill',
        'minWave: 90'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 55: Short Tempered
    "Short Tempered": {
        "ap_id": 1479,
        "description": "Call 5 waves early.",
        "requirements": [
        'minWave: 5'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 56: Shovel Swing
    "Shovel Swing": {
        "ap_id": 1480,
        "description": "Hit 15 frozen monsters with shrines.",
        "requirements": [
        'Freeze skill',
        'Shrine element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 57: Shred Some Armor
    "Shred Some Armor": {
        "ap_id": 1481,
        "description": "Have a pure armor tearing gem with 3.000 hits.",
        "requirements": [
        'Armor Tearing skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 58: Shrinemaster
    "Shrinemaster": {
        "ap_id": 1482,
        "description": "Reach 20.000 shrine kills through all the battles.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 59: Sigil
    "Sigil": {
        "ap_id": 1483,
        "description": "Fill all the sockets in your talisman with fragments upgrade...",
        "requirements": [
        'Shadow Core element'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Extreme",
    },
    # ID 60: Size Matters
    "Size Matters": {
        "ap_id": 1484,
        "description": "Beat 100 waves on max Swarmling and Giant domination traits.",
        "requirements": [
        'Swarmling Domination trait',
        'Giant Domination trait',
        'minWave: 100'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Extreme",
    },
    # ID 61: Skillful
    "Skillful": {
        "ap_id": 1485,
        "description": "Acquire and raise all skills to level 5 or above.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 62: Skylark
    "Skylark": {
        "ap_id": 1486,
        "description": "Call every wave early in a battle.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 63: Sliced Ice
    "Sliced Ice": {
        "ap_id": 1487,
        "description": "Gain 1.800 xp with Ice Shards spell crowd hits.",
        "requirements": [
        'Ice Shards skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 64: Slime Block
    "Slime Block": {
        "ap_id": 1488,
        "description": "Nine slimeballs is all it takes",
        "requirements": [
        'A monster with atleast 20.000hp'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 65: Slow Creep
    "Slow Creep": {
        "ap_id": 1489,
        "description": "Poison 130 whited out monsters.",
        "requirements": [
        'Poison skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 66: Slow Drain
    "Slow Drain": {
        "ap_id": 1490,
        "description": "Deal 10.000 poison damage to a monster.",
        "requirements": [
        'Poison skill'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 67: Slow Motion
    "Slow Motion": {
        "ap_id": 1491,
        "description": "Enhance a pure slowing gem having random priority with beam.",
        "requirements": [
        'Beam skill',
        'Slowing skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 68: Slowly but Surely
    "Slowly but Surely": {
        "ap_id": 1492,
        "description": "Beat 90 waves using only slowing gems.",
        "requirements": [
        'Slowing skill',
        'minWave: 90'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 69: Smoke in the Sky
    "Smoke in the Sky": {
        "ap_id": 1493,
        "description": "Reach 20 non-monsters killed through all the battles.",
        "requirements": [
        'Ritual trait'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 70: Snatchers
    "Snatchers": {
        "ap_id": 1494,
        "description": "Gain 3.200 mana from drops.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 71: Snow Blower
    "Snow Blower": {
        "ap_id": 1495,
        "description": "Kill 20 frozen monsters with barrage.",
        "requirements": [
        'Barrage skill',
        'Freeze skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 72: Snow Dust
    "Snow Dust": {
        "ap_id": 1496,
        "description": "Kill 95 frozen monsters while it's snowing.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 73: Snowball
    "Snowball": {
        "ap_id": 1497,
        "description": "Drop 27 gem bombs while it's snowing.",
        "requirements": [
        'gemCount: 27'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 74: Snowdust Blindness
    "Snowdust Blindness": {
        "ap_id": 1498,
        "description": "Gain 2.300 xp with Whiteout spell crowd hits.",
        "requirements": [
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 75: So Attached
    "So Attached": {
        "ap_id": 1499,
        "description": "Win a Trial battle without losing any orblets.",
        "requirements": [
        'Trial'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 76: So Early
    "So Early": {
        "ap_id": 1500,
        "description": "Reach 1.000 waves started early through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 77: So Enduring
    "So Enduring": {
        "ap_id": 1501,
        "description": "Have the Adaptive Carapace trait set to level 6 or higher an...",
        "requirements": [
        'Adaptive Carapace trait'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 78: Socketed Rage
    "Socketed Rage": {
        "ap_id": 1502,
        "description": "Enrage a wave.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 79: Something Special
    "Something Special": {
        "ap_id": 1503,
        "description": "Reach 2.000 monsters with special properties killed through ...",
        "requirements": [
        'Possessed Monster element',
        'Twisted Monster element',
        'Marked Monster element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 80: Sparse Snares
    "Sparse Snares": {
        "ap_id": 1504,
        "description": "Build 10 traps.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 81: Special Purpose
    "Special Purpose": {
        "ap_id": 1505,
        "description": "Change the target priority of a gem.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 82: Spectrin Tetramer
    "Spectrin Tetramer": {
        "ap_id": 1506,
        "description": "Have the Vital Link trait set to level 6 or higher and win t...",
        "requirements": [
        'Vital Link trait'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 83: Spitting Darkness
    "Spitting Darkness": {
        "ap_id": 1507,
        "description": "Leave a gatekeeper fang alive until it can launch 100 projec...",
        "requirements": [
        'Gatekeeper element',
        'Field A4'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 84: Splash Swim Splash
    "Splash Swim Splash": {
        "ap_id": 1508,
        "description": "Full of oxygen",
        "requirements": [
        'Click on water in a field\nRequires a field with water'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 85: Starter Pack
    "Starter Pack": {
        "ap_id": 1509,
        "description": "Add 8 talisman fragments to your shape collection.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 86: Stash No More
    "Stash No More": {
        "ap_id": 1510,
        "description": "Destroy a previously opened wizard stash.",
        "requirements": [
        'Wizard Stash element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 87: Stay Some More
    "Stay Some More": {
        "ap_id": 1511,
        "description": "Cast freeze on an apparition 3 times.",
        "requirements": [
        'Freeze skill',
        'Ritual trait',
        'Apparition element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 88: Still Alive
    "Still Alive": {
        "ap_id": 1512,
        "description": "Beat 60 waves.",
        "requirements": [
        'minWave: 60'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 89: Still Chill
    "Still Chill": {
        "ap_id": 1513,
        "description": "Gain 1.500 xp with Freeze spell crowd hits.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 90: Still Lit
    "Still Lit": {
        "ap_id": 1514,
        "description": "Have 15 or more beacons standing at the end of the battle.",
        "requirements": [
        'Dark Masonry trait',
        'Beacon element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 91: Still No Match
    "Still No Match": {
        "ap_id": 1515,
        "description": "Destroy an omnibeacon.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 92: Sting Stack
    "Sting Stack": {
        "ap_id": 1516,
        "description": "Deal 1.000 gem wasp stings to buildings.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 93: Stinging Sphere
    "Stinging Sphere": {
        "ap_id": 1517,
        "description": "Deliver 100 banishments with your orb.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 94: Stingy Cloud
    "Stingy Cloud": {
        "ap_id": 1518,
        "description": "Reach 5.000 gem wasp kills through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 95: Stingy Downfall
    "Stingy Downfall": {
        "ap_id": 1519,
        "description": "Deal 400 wasp stings to a spire.",
        "requirements": [
        'Ritual trait',
        'Spire element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 96: Stirring Up the Nest
    "Stirring Up the Nest": {
        "ap_id": 1520,
        "description": "Deliver gem bomb and wasp kills only.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 97: Stockpile
    "Stockpile": {
        "ap_id": 1521,
        "description": "Have 30 fragments in your talisman inventory.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 98: Stolen Shine
    "Stolen Shine": {
        "ap_id": 1522,
        "description": "Leech 2.700 mana from whited out monsters.",
        "requirements": [
        'Mana Leech skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 99: Stone Monument
    "Stone Monument": {
        "ap_id": 1523,
        "description": "Build 240 walls.",
        "requirements": [
        'Wall element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 100: Stones to Dust
    "Stones to Dust": {
        "ap_id": 1524,
        "description": "Demolish one of your structures.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 101: Stormbringer
    "Stormbringer": {
        "ap_id": 1525,
        "description": "Reach 1.000 strike spells cast through all the battles.",
        "requirements": [
        'strikeSpells: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 102: Stormed Beacons
    "Stormed Beacons": {
        "ap_id": 1526,
        "description": "Destroy 15 beacons.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 103: Strike Anywhere
    "Strike Anywhere": {
        "ap_id": 1527,
        "description": "Cast a strike spell.",
        "requirements": [
        'strikeSpells:1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 104: Stronger Than Before
    "Stronger Than Before": {
        "ap_id": 1528,
        "description": "Set corrupted banishment to level 12 and banish a monster 3 ...",
        "requirements": [
        'Corrupted Banishment trait'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 105: Stumbling
    "Stumbling": {
        "ap_id": 1529,
        "description": "Hit the same monster with traps 100 times.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
}

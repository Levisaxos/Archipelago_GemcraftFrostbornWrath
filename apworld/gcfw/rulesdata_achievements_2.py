"""
GemCraft Frostborn Wrath — Achievement Pack 2

Contains approximately 106 achievements.
Each achievement has a "grindiness" property ("Trivial", "Minor", "Major", "Extreme") for easy adjustment.
"""

achievement_requirements = {
    # ID 0: Core Pouch
    "Core Pouch": {
        "ap_id": 1106,
        "description": "Have 100 shadow cores at the start of the battle.",
        "requirements": [
        'Shadow Core element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 1: Corrosive Stings
    "Corrosive Stings": {
        "ap_id": 1107,
        "description": "Tear a total of 5.000 armor with wasp stings.",
        "requirements": [
        'Armor Tearing skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 2: Couldn't Decide
    "Couldn't Decide": {
        "ap_id": 1108,
        "description": "Kill 400 monsters with prismatic gem wasps.",
        "requirements": [
        'Critical Hit skill',
        'Mana Leech skill',
        'Bleeding skill',
        'Armor Tearing skill',
        'Poison skill',
        'Slowing skill',
        'gemCount: 6'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 3: Crimson Journal
    "Crimson Journal": {
        "ap_id": 1109,
        "description": "Reach 100.000 monsters killed through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 4: Crowd Control
    "Crowd Control": {
        "ap_id": 1110,
        "description": "Have the Overcrowd trait set to level 6 or higher and win th...",
        "requirements": [
        'Overcrowd trait'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 5: Crowded Queue
    "Crowded Queue": {
        "ap_id": 1111,
        "description": "Have 600 monsters on the battlefield at the same time.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 6: Crunchy Bites
    "Crunchy Bites": {
        "ap_id": 1112,
        "description": "Kill 160 frozen swarmlings.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 7: Damage Support
    "Damage Support": {
        "ap_id": 1113,
        "description": "Have a pure bleeding gem with 2.500 hits.",
        "requirements": [
        'Bleeding skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 8: Darkness Walk With Me
    "Darkness Walk With Me": {
        "ap_id": 1114,
        "description": "Kill 3 shadows.",
        "requirements": [
        'Ritual trait',
        'Shadow element'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Minor",
    },
    # ID 9: Deadly Curse
    "Deadly Curse": {
        "ap_id": 1115,
        "description": "Reach 5.000 poison kills through all the battles.",
        "requirements": [
        'Poison skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 10: Deal Some Damage Too
    "Deal Some Damage Too": {
        "ap_id": 1116,
        "description": "Have 5 traps with bolt enhanced gems in them.",
        "requirements": [
        'Bolt skill',
        'Traps skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 11: Deathball
    "Deathball": {
        "ap_id": 1117,
        "description": "Reach 1.000 pylon kills through all the battles.",
        "requirements": [
        'Pylons skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 12: Deckard Would Be Proud
    "Deckard Would Be Proud": {
        "ap_id": 1118,
        "description": "All I could get for a prismatic amulet",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 13: Deluminati
    "Deluminati": {
        "ap_id": 1119,
        "description": "Have the Dark Masonry trait set to level 6 or higher and win...",
        "requirements": [
        'Dark Masonry trait'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 14: Denested
    "Denested": {
        "ap_id": 1120,
        "description": "Destroy 5 monster nests.",
        "requirements": [
        'Monster Nest element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 15: Derangement
    "Derangement": {
        "ap_id": 1121,
        "description": "Decrease the range of a gem.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 16: Desperate Clash
    "Desperate Clash": {
        "ap_id": 1122,
        "description": "Reach -16% decreased banishment cost with your orb.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 17: Diabolic Trophy
    "Diabolic Trophy": {
        "ap_id": 1123,
        "description": "Kill 666 swarmlings.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 18: Dichromatic
    "Dichromatic": {
        "ap_id": 1124,
        "description": "Combine two gems of different colors.",
        "requirements": [
        'gemCount: 2'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 19: Disciple
    "Disciple": {
        "ap_id": 1125,
        "description": "Have 10 fields lit in Trial mode.",
        "requirements": [
        'Trial'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Trivial",
    },
    # ID 20: Disco Ball
    "Disco Ball": {
        "ap_id": 1126,
        "description": "Have a gem of 6 components in a lantern.",
        "requirements": [
        'Lanterns skill',
        'Critical Hit skill',
        'Mana Leech skill',
        'Bleeding skill',
        'Armor Tearing skill',
        'Poison skill',
        'Slowing skill',
        'gemCount: 6'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 21: Don't Break it!
    "Don't Break it!": {
        "ap_id": 1127,
        "description": "Spend 90.000 mana on banishment.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 22: Don't Look at the Light
    "Don't Look at the Light": {
        "ap_id": 1128,
        "description": "Reach 10.000 shrine kills through all the battles.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 23: Don't Touch it!
    "Don't Touch it!": {
        "ap_id": 1129,
        "description": "Kill a specter.",
        "requirements": [
        'Ritual trait',
        'Specter element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 24: Doom Drop
    "Doom Drop": {
        "ap_id": 1130,
        "description": "Kill a possessed giant with barrage.",
        "requirements": [
        'Barrage skill',
        'Possessed Monster element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 25: Double Punch
    "Double Punch": {
        "ap_id": 1131,
        "description": "Have 2 bolt enhanced gems at the same time.",
        "requirements": [
        'Bolt skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 26: Double Sharded
    "Double Sharded": {
        "ap_id": 1132,
        "description": "Cast 2 ice shards on the same monster.",
        "requirements": [
        'Ice Shards skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 27: Double Splash
    "Double Splash": {
        "ap_id": 1133,
        "description": "Kill two non-monster creatures with one gem bomb.",
        "requirements": [
        'Ritual trait'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 28: Double Strike
    "Double Strike": {
        "ap_id": 1134,
        "description": "Activate the same shrine 2 times.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 29: Drone Warfare
    "Drone Warfare": {
        "ap_id": 1135,
        "description": "Reach 20.000 gem wasp kills through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 30: Drop the Ice
    "Drop the Ice": {
        "ap_id": 1136,
        "description": "Reach 50.000 strike spell hits through all the battles.",
        "requirements": [
        'strikeSpells: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 31: Drumroll
    "Drumroll": {
        "ap_id": 1137,
        "description": "Deal 200 gem wasp stings to buildings.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 32: Dry Puddle
    "Dry Puddle": {
        "ap_id": 1138,
        "description": "Harvest all mana from a mana shard.",
        "requirements": [
        'Mana Shard element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 33: Dual Downfall
    "Dual Downfall": {
        "ap_id": 1139,
        "description": "Kill 2 spires.",
        "requirements": [
        'Ritual trait',
        'Spire element'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 34: Dual Pulse
    "Dual Pulse": {
        "ap_id": 1140,
        "description": "Have 2 beam enhanced gems at the same time.",
        "requirements": [
        'Beam skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 35: Eagle Eye
    "Eagle Eye": {
        "ap_id": 1141,
        "description": "Reach an amplified gem range of 18.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 36: Early Bird
    "Early Bird": {
        "ap_id": 1142,
        "description": "Reach 500 waves started early through all the battles.",
        "requirements": [
        'minWave: 500'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 37: Early Harvest
    "Early Harvest": {
        "ap_id": 1143,
        "description": "Harvest 2.500 mana from shards before wave 3 starts.",
        "requirements": [
        'Mana Shard element'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 38: Earthquake
    "Earthquake": {
        "ap_id": 1144,
        "description": "Activate shrines a total of 4 times.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 39: Easy Kill
    "Easy Kill": {
        "ap_id": 1145,
        "description": "Kill 120 bleeding monsters.",
        "requirements": [
        'Bleeding skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 40: Eat my Light
    "Eat my Light": {
        "ap_id": 1146,
        "description": "Kill a wraith with a shrine strike.",
        "requirements": [
        'Ritual trait',
        'Shrine element',
        'Wraith element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 41: Eggcracker
    "Eggcracker": {
        "ap_id": 1147,
        "description": "Don't let any egg laid by a swarm queen to hatch on its own.",
        "requirements": [
        'Swarm Queen element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 42: Eggnog
    "Eggnog": {
        "ap_id": 1148,
        "description": "Crack a monster egg open while time is frozen.",
        "requirements": [
        'Swarm Queen element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 43: Eggs Royale
    "Eggs Royale": {
        "ap_id": 1149,
        "description": "Reach 1.000 monster eggs cracked through all the battles.",
        "requirements": [
        'Swarm Queen element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 44: Elementary
    "Elementary": {
        "ap_id": 1150,
        "description": "Beat 30 waves using at most grade 2 gems.",
        "requirements": [
        'minWave: 30'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 45: End of the Tunnel
    "End of the Tunnel": {
        "ap_id": 1151,
        "description": "Kill an apparition with a shrine strike.",
        "requirements": [
        'Ritual trait',
        'Apparition element',
        'Shrine element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 46: Endgame Balance
    "Endgame Balance": {
        "ap_id": 1152,
        "description": "Have 25.000 shadow cores at the start of the battle.",
        "requirements": [
        'Shadow Core element'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Extreme",
    },
    # ID 47: Endured a Lot
    "Endured a Lot": {
        "ap_id": 1153,
        "description": "Have 80 fields lit in Endurance mode.",
        "requirements": [
        'Endurance'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 48: Enhance Like No Tomorrow
    "Enhance Like No Tomorrow": {
        "ap_id": 1154,
        "description": "Reach 2.500 enhancement spells cast through all the battles.",
        "requirements": [
        'enhancementSpells: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 49: Enhancement Storage
    "Enhancement Storage": {
        "ap_id": 1155,
        "description": "Enhance a gem in the inventory.",
        "requirements": [
        'enhancementSpells: 3'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 50: Enhancing Challenge
    "Enhancing Challenge": {
        "ap_id": 1156,
        "description": "Beat 200 waves on max Swarmling and Giant domination traits.",
        "requirements": [
        'Swarmling Domination trait',
        'Giant Domination trait',
        'minWave: 200',
        'Endurance'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Extreme",
    },
    # ID 51: Enough Frozen Time Trickery
    "Enough Frozen Time Trickery": {
        "ap_id": 1157,
        "description": "Kill a shadow while time is frozen.",
        "requirements": [
        'Shadow element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 52: Enough is Enough
    "Enough is Enough": {
        "ap_id": 1158,
        "description": "Have 24 of your gems destroyed or stolen.",
        "requirements": [
        'Ritual trait',
        'Specter element',
        'Watchtower element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 53: Enraged is the New Norm
    "Enraged is the New Norm": {
        "ap_id": 1159,
        "description": "Enrage 240 waves.",
        "requirements": [
        'minWave: 240'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Extreme",
    },
    # ID 54: Ensnared
    "Ensnared": {
        "ap_id": 1160,
        "description": "Kill 12 monsters with gems in traps.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 55: Enter The Gate
    "Enter The Gate": {
        "ap_id": 1161,
        "description": "Kill the gatekeeper.",
        "requirements": [
        'Gatekeeper element',
        'Field A4'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 56: Entrenched
    "Entrenched": {
        "ap_id": 1162,
        "description": "Build 20 traps.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 57: Epidemic Gem
    "Epidemic Gem": {
        "ap_id": 1163,
        "description": "Have a pure poison gem with 3.500 hits.",
        "requirements": [
        'Poison skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 58: Even if You Thaw
    "Even if You Thaw": {
        "ap_id": 1164,
        "description": "Whiteout 120 frozen monsters.",
        "requirements": [
        'Freeze skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 59: Every Hit Counts
    "Every Hit Counts": {
        "ap_id": 1165,
        "description": "Deliver 3750 one hit kills.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Extreme",
    },
    # ID 60: Exorcism
    "Exorcism": {
        "ap_id": 1166,
        "description": "Kill 199 possessed monsters.",
        "requirements": [
        'Possessed Monster element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 61: Expert
    "Expert": {
        "ap_id": 1167,
        "description": "Have 50 fields lit in Trial mode.",
        "requirements": [
        'Trial'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Major",
    },
    # ID 62: Extorted
    "Extorted": {
        "ap_id": 1168,
        "description": "Harvest all mana from 3 mana shards.",
        "requirements": [
        'Mana Shard element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 63: Face the Phobia
    "Face the Phobia": {
        "ap_id": 1169,
        "description": "Have the Swarmling Parasites trait set to level 6 or higher ...",
        "requirements": [
        'Swarmling Parasites trait'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 64: Family Friendlier
    "Family Friendlier": {
        "ap_id": 1170,
        "description": "Kill 900 green blooded monsters.",
        "requirements": [
        'Requires "hidden codes"'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 65: Farewell
    "Farewell": {
        "ap_id": 1171,
        "description": "Kill an apparition with one hit.",
        "requirements": [
        'Ritual trait',
        'Apparition element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 66: Feels Like Endurance
    "Feels Like Endurance": {
        "ap_id": 1172,
        "description": "Beat 120 waves.",
        "requirements": [
        'minWave: 120'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Extreme",
    },
    # ID 67: Fierce Encounter
    "Fierce Encounter": {
        "ap_id": 1173,
        "description": "Reach -8% decreased banishment cost with your orb.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 68: Fifth Grader
    "Fifth Grader": {
        "ap_id": 1174,
        "description": "Create a grade 5 gem.",
        "requirements": [
        'minGemGrade: 5'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 69: Filled 5 Times
    "Filled 5 Times": {
        "ap_id": 1175,
        "description": "Reach mana pool level 5.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 70: Final Cut
    "Final Cut": {
        "ap_id": 1176,
        "description": "Kill 960 bleeding monsters.",
        "requirements": [
        'Bleeding skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 71: Final Touch
    "Final Touch": {
        "ap_id": 1177,
        "description": "Kill a spire with a gem wasp.",
        "requirements": [
        'Ritual trait',
        'Spire element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 72: Finders
    "Finders": {
        "ap_id": 1178,
        "description": "Gain 200 mana from drops.",
        "requirements": [
        'Mana Shard element',
        'Corrupted Mana Shard element',
        'Drop Holder element',
        'Apparition element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 73: Fire Away
    "Fire Away": {
        "ap_id": 1179,
        "description": "Cast a gem enhancement spell.",
        "requirements": [
        'enhancementSpells: 2'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 74: Fire in the Hole
    "Fire in the Hole": {
        "ap_id": 1180,
        "description": "Destroy a monster nest.",
        "requirements": [
        'Monster Nest element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 75: Firefall
    "Firefall": {
        "ap_id": 1181,
        "description": "Have 16 barrage enhanced gems at the same time.",
        "requirements": [
        'Barrage skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 76: First Blood
    "First Blood": {
        "ap_id": 1182,
        "description": "Kill a monster.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 77: First Puzzle Piece
    "First Puzzle Piece": {
        "ap_id": 1183,
        "description": "Find a talisman fragment.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 78: Flip Flop
    "Flip Flop": {
        "ap_id": 1184,
        "description": "Win a flipped field battle.",
        "requirements": [
        'Requires "hidden codes"'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 79: Flows Through my Veins
    "Flows Through my Veins": {
        "ap_id": 1185,
        "description": "Reach mana pool level 10.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 80: Flying Multikill
    "Flying Multikill": {
        "ap_id": 1186,
        "description": "Destroy 1 apparition, 1 specter, 1 wraith and 1 shadow in th...",
        "requirements": [
        'Ritual trait',
        'Apparition element',
        'Shadow element',
        'Specter element',
        'Wraith element'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 81: Fool Me Once
    "Fool Me Once": {
        "ap_id": 1187,
        "description": "Kill 390 banished monsters.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 82: Forces Within my Comprehension
    "Forces Within my Comprehension": {
        "ap_id": 1188,
        "description": "Have the Ritual trait set to level 6 or higher and win the b...",
        "requirements": [
        'Ritual trait'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 83: Forged in Battle
    "Forged in Battle": {
        "ap_id": 1189,
        "description": "Reach 200 battles won.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 84: Fortress
    "Fortress": {
        "ap_id": 1190,
        "description": "Build 30 towers.",
        "requirements": [
        'Tower element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 85: Fortunate
    "Fortunate": {
        "ap_id": 1191,
        "description": "Find 2 talisman fragments.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 86: Frag Rain
    "Frag Rain": {
        "ap_id": 1192,
        "description": "Find 5 talisman fragments.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Major",
    },
    # ID 87: Freezing Wounds
    "Freezing Wounds": {
        "ap_id": 1193,
        "description": "Freeze a monster 3 times.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 88: Friday Night
    "Friday Night": {
        "ap_id": 1194,
        "description": "Have 4 beam enhanced gems at the same time.",
        "requirements": [
        'Beam skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 89: Frittata
    "Frittata": {
        "ap_id": 1195,
        "description": "Reach 500 monster eggs cracked through all the battles.",
        "requirements": [
        'Swarm Queen element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 90: From Above
    "From Above": {
        "ap_id": 1196,
        "description": "Kill 40 monsters with gem bombs and wasps.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 91: Frostborn
    "Frostborn": {
        "ap_id": 1197,
        "description": "Reach 5.000 strike spells cast through all the battles.",
        "requirements": [
        'strikeSpells: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 92: Frosting
    "Frosting": {
        "ap_id": 1198,
        "description": "Freeze a specter while it's snowing.",
        "requirements": [
        'Freeze skill',
        'Ritual trait',
        'Specter element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 93: Frozen Crowd
    "Frozen Crowd": {
        "ap_id": 1199,
        "description": "Reach 10.000 strike spell hits through all the battles.",
        "requirements": [
        'strikeSpells: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 94: Frozen Grave
    "Frozen Grave": {
        "ap_id": 1200,
        "description": "Kill 220 monsters while it's snowing.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 95: Frozen Over
    "Frozen Over": {
        "ap_id": 1201,
        "description": "Gain 4.500 xp with Freeze spell crowd hits.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 96: Ful Ir
    "Ful Ir": {
        "ap_id": 1202,
        "description": "Blast like a fireball",
        "requirements": [
        'Kill 15 monsters simultaneously with 1 gem bomb'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 97: Fully Lit
    "Fully Lit": {
        "ap_id": 1203,
        "description": "Have a field beaten in all three battle modes.",
        "requirements": [
        'Endurance and trial'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 98: Fully Shining
    "Fully Shining": {
        "ap_id": 1204,
        "description": "Have 60 gems on the battlefield.",
        "requirements": [
        'gemCount: 60'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Major",
    },
    # ID 99: Fusion Core
    "Fusion Core": {
        "ap_id": 1205,
        "description": "Have 16 beam enhanced gems at the same time.",
        "requirements": [
        'Beam skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 100: Gearing Up
    "Gearing Up": {
        "ap_id": 1206,
        "description": "Have 5 fragments socketed in your talisman.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 101: Gem Lust
    "Gem Lust": {
        "ap_id": 1207,
        "description": "Kill 2 specters.",
        "requirements": [
        'Ritual trait',
        'Specter element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 102: Gemhancement
    "Gemhancement": {
        "ap_id": 1208,
        "description": "Reach 1.000 enhancement spells cast through all the battles.",
        "requirements": [
        'enhancementSpells: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 103: Get Them
    "Get Them": {
        "ap_id": 1209,
        "description": "Have a watchtower kill 39 monsters.",
        "requirements": [
        'Watchtower element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 104: Get This Done Quick
    "Get This Done Quick": {
        "ap_id": 1210,
        "description": "Win a Trial battle with at least 3 waves started early.",
        "requirements": [
        'minWave: 3',
        'Trial'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Trivial",
    },
    # ID 105: Getting My Feet Wet
    "Getting My Feet Wet": {
        "ap_id": 1211,
        "description": "Have 20 fields lit in Endurance mode.",
        "requirements": [
        'Endurance'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
}

"""
GemCraft Frostborn Wrath — Achievement Pack 3

Contains approximately 106 achievements.
Each achievement has a "grindiness" property ("Trivial", "Minor", "Major", "Extreme") for easy adjustment.
"""

achievement_requirements = {
    # ID 0: Getting Rid of Them
    "Getting Rid of Them": {
        "ap_id": 1212,
        "description": "Drop 48 gem bombs on beacons.",
        "requirements": [
        'Beacon element',
        'gemCount: 48'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 1: Getting Serious
    "Getting Serious": {
        "ap_id": 1213,
        "description": "Have a grade 1 gem with 1.500 hits.",
        "requirements": [
        'minGemGrade: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 2: Getting Waves Done
    "Getting Waves Done": {
        "ap_id": 1214,
        "description": "Reach 2.000 waves started early through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 3: Getting Wet
    "Getting Wet": {
        "ap_id": 1215,
        "description": "Beat 30 waves.",
        "requirements": [
        'minWave: 30'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 4: Glitter Cloud
    "Glitter Cloud": {
        "ap_id": 1216,
        "description": "Kill an apparition with a gem bomb.",
        "requirements": [
        'Ritual trait',
        'Apparition element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 5: Glowing Armada
    "Glowing Armada": {
        "ap_id": 1217,
        "description": "Have 240 gem wasps on the battlefield when the battle ends.",
        "requirements": [
        'gemCount: 240'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 6: Going Deviant
    "Going Deviant": {
        "ap_id": 1218,
        "description": "Rook to a9",
        "requirements": [
        'Scroll to edge of the world map'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 7: Going for the Weak
    "Going for the Weak": {
        "ap_id": 1219,
        "description": "Have a watchtower kill a poisoned monster.",
        "requirements": [
        'Poison skill',
        'Watchtower element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 8: Got the Price Back
    "Got the Price Back": {
        "ap_id": 1220,
        "description": "Have a pure mana leeching gem with 4.500 hits.",
        "requirements": [
        'Mana Leech skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 9: Great Survivor
    "Great Survivor": {
        "ap_id": 1221,
        "description": "Kill a monster from wave 1 when wave 20 has already started.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 10: Green Eyed Ninja
    "Green Eyed Ninja": {
        "ap_id": 1222,
        "description": "Entering: The Wilderness",
        "requirements": [
        'Field N1, U1 or R5'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 11: Green Path
    "Green Path": {
        "ap_id": 1223,
        "description": "Kill 9.900 green blooded monsters.",
        "requirements": [
        'Requires "hidden codes"'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 12: Green Vial
    "Green Vial": {
        "ap_id": 1224,
        "description": "Have more than 75% of the monster kills caused by poison.",
        "requirements": [
        'Poison skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 13: Green Wand
    "Green Wand": {
        "ap_id": 1225,
        "description": "Reach wizard level 60.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 14: Ground Luck
    "Ground Luck": {
        "ap_id": 1226,
        "description": "Find 3 talisman fragments.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 15: Groundfill
    "Groundfill": {
        "ap_id": 1227,
        "description": "Demolish a trap.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 16: Guarding the Fallen Gate
    "Guarding the Fallen Gate": {
        "ap_id": 1228,
        "description": "Have the Corrupted Banishment trait set to level 6 or higher...",
        "requirements": [
        'Corrupted Banishment trait'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 17: Hacked Gem
    "Hacked Gem": {
        "ap_id": 1229,
        "description": "Have a grade 3 gem with 1.200 effective max damage.",
        "requirements": [
        'minGemGrade: 3'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 18: Half Full
    "Half Full": {
        "ap_id": 1230,
        "description": "Add 32 talisman fragments to your shape collection.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 19: Handle With Care
    "Handle With Care": {
        "ap_id": 1231,
        "description": "Kill 300 monsters with orblet explosions.",
        "requirements": [
        'Orb of Presence skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 20: Hard Reset
    "Hard Reset": {
        "ap_id": 1232,
        "description": "Reach 5.000 shrine kills through all the battles.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 21: Has Stood Long Enough
    "Has Stood Long Enough": {
        "ap_id": 1233,
        "description": "Destroy a monster nest after the last wave has started.",
        "requirements": [
        'Monster Nest element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 22: Hateful
    "Hateful": {
        "ap_id": 1234,
        "description": "Have the Hatred trait set to level 6 or higher and win the b...",
        "requirements": [
        'Hatred trait'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Trivial",
    },
    # ID 23: Hazardous Materials
    "Hazardous Materials": {
        "ap_id": 1235,
        "description": "Put your HEV on first",
        "requirements": [
        'Poison skill',
        'Have atleast 1.000 enemies poisoned and alive on a field'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 24: Healing Denied
    "Healing Denied": {
        "ap_id": 1236,
        "description": "Destroy 3 healing beacons.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 25: Heavily Modified
    "Heavily Modified": {
        "ap_id": 1237,
        "description": "Activate all mods.",
        "requirements": [
        'Requires "hidden codes"'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 26: Heavy Hitting
    "Heavy Hitting": {
        "ap_id": 1238,
        "description": "Have 4 bolt enhanced gems at the same time.",
        "requirements": [
        'Bolt skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 27: Heavy Support
    "Heavy Support": {
        "ap_id": 1239,
        "description": "Have 20 beacons on the field at the same time.",
        "requirements": [
        'Dark Masonry trait',
        'Beacon element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 28: Hedgehog
    "Hedgehog": {
        "ap_id": 1240,
        "description": "Kill a swarmling having at least 100 armor.",
        "requirements": [
        'a swarmling with atleast 100 armor'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 29: Helping Hand
    "Helping Hand": {
        "ap_id": 1241,
        "description": "Have a watchtower kill a possessed monster.",
        "requirements": [
        'Possessed Monster element',
        'Watchtower element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 30: Hiding Spot
    "Hiding Spot": {
        "ap_id": 1242,
        "description": "Open 3 drop holders before wave 3.",
        "requirements": [
        'Drop Holder element'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 31: High Stakes
    "High Stakes": {
        "ap_id": 1243,
        "description": "Set a battle trait to level 12.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 32: High Targets
    "High Targets": {
        "ap_id": 1244,
        "description": "Reach 100 non-monsters killed through all the battles.",
        "requirements": [
        'Ritual trait'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 33: Hint of Darkness
    "Hint of Darkness": {
        "ap_id": 1245,
        "description": "Kill 189 twisted monsters.",
        "requirements": [
        'Twisted Monster element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 34: Hold Still
    "Hold Still": {
        "ap_id": 1246,
        "description": "Freeze 130 whited out monsters.",
        "requirements": [
        'Freeze skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 35: Hope has fallen
    "Hope has fallen": {
        "ap_id": 1247,
        "description": "Dismantled bunkhouses",
        "requirements": [
        'Field E3'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 36: How About Some Skill Points
    "How About Some Skill Points": {
        "ap_id": 1248,
        "description": "Have 5.000 shadow cores at the start of the battle.",
        "requirements": [
        'Shadow Core element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 37: Hungry Little Gem
    "Hungry Little Gem": {
        "ap_id": 1249,
        "description": "Leech 3.600 mana with a grade 1 gem.",
        "requirements": [
        'Mana Leech skill',
        'minGemGrade: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 38: Hunt For Hard Targets
    "Hunt For Hard Targets": {
        "ap_id": 1250,
        "description": "Kill 680 monsters while there are at least 2 wraiths in the ...",
        "requirements": [
        'Ritual trait',
        'Wraith element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 39: Hurtified
    "Hurtified": {
        "ap_id": 1251,
        "description": "Kill 240 bleeding monsters.",
        "requirements": [
        'Bleeding skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 40: Hyper Gem
    "Hyper Gem": {
        "ap_id": 1252,
        "description": "Have a grade 3 gem with 600 effective max damage.",
        "requirements": [
        'minGemGrade: 3'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 41: I Have Experience
    "I Have Experience": {
        "ap_id": 1253,
        "description": "Reach 50 battles won.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 42: I Never Asked For This
    "I Never Asked For This": {
        "ap_id": 1254,
        "description": "All my aug points spent",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 43: I Saw Something
    "I Saw Something": {
        "ap_id": 1255,
        "description": "Kill an apparition.",
        "requirements": [
        'Ritual trait',
        'Apparition element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 44: I Warned You...
    "I Warned You...": {
        "ap_id": 1256,
        "description": "Kill a specter while it carries a gem.",
        "requirements": [
        'Ritual trait',
        'Specter element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 45: I am Tougher
    "I am Tougher": {
        "ap_id": 1257,
        "description": "Kill 1.360 monsters while there are at least 2 wraiths in th...",
        "requirements": [
        'Ritual trait',
        'Wraith element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 46: Ice Cube
    "Ice Cube": {
        "ap_id": 1258,
        "description": "Have a Maximum Charge of 300% for the Freeze Spell.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 47: Ice Mage
    "Ice Mage": {
        "ap_id": 1259,
        "description": "Reach 2.500 strike spells cast through all the battles.",
        "requirements": [
        'strikeSpells: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 48: Ice Snap
    "Ice Snap": {
        "ap_id": 1260,
        "description": "Gain 90 xp with Freeze spell crowd hits.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 49: Ice Stand
    "Ice Stand": {
        "ap_id": 1261,
        "description": "Kill 5 frozen monsters carrying orblets.",
        "requirements": [
        'Freeze skill',
        'Orb of Presence skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 50: Ice for Everyone
    "Ice for Everyone": {
        "ap_id": 1262,
        "description": "Reach 100.000 strike spell hits through all the battles.",
        "requirements": [
        'strikeSpells: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 51: Icecracker
    "Icecracker": {
        "ap_id": 1263,
        "description": "Kill 90 frozen monsters with barrage.",
        "requirements": [
        'Barrage skill',
        'Freeze skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 52: Icepicked
    "Icepicked": {
        "ap_id": 1264,
        "description": "Gain 3.200 xp with Ice Shards spell crowd hits.",
        "requirements": [
        'Ice Shards skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 53: Icy Fingers
    "Icy Fingers": {
        "ap_id": 1265,
        "description": "Reach 500 strike spells cast through all the battles.",
        "requirements": [
        'strikeSpells:1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 54: Impaling Charges
    "Impaling Charges": {
        "ap_id": 1266,
        "description": "Deliver 250 one hit kills.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 55: Impenetrable
    "Impenetrable": {
        "ap_id": 1267,
        "description": "Have 8 bolt enhanced gems at the same time.",
        "requirements": [
        'Bolt skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 56: Implosion
    "Implosion": {
        "ap_id": 1268,
        "description": "Kill a gatekeeper fang with a gem bomb.",
        "requirements": [
        'Gatekeeper element',
        'Field A4'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 57: Impressive
    "Impressive": {
        "ap_id": 1269,
        "description": "Win a Trial battle without any monster reaching your Orb.",
        "requirements": [
        'Trial'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 58: Impudence
    "Impudence": {
        "ap_id": 1270,
        "description": "Have 6 of your gems destroyed or stolen.",
        "requirements": [
        'Ritual trait',
        'Specter element',
        'Watchtower element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 59: In Flames
    "In Flames": {
        "ap_id": 1271,
        "description": "Kill 400 spawnlings.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 60: In Focus
    "In Focus": {
        "ap_id": 1272,
        "description": "Amplify a gem with 8 other gems.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 61: In a Blink of an Eye
    "In a Blink of an Eye": {
        "ap_id": 1273,
        "description": "Kill 100 monsters while time is frozen.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 62: In for a Trait
    "In for a Trait": {
        "ap_id": 1274,
        "description": "Activate a battle trait.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 63: Inedible
    "Inedible": {
        "ap_id": 1275,
        "description": "Poison 111 frozen monsters.",
        "requirements": [
        'Freeze skill',
        'Poison skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 64: Insane Investment
    "Insane Investment": {
        "ap_id": 1276,
        "description": "Reach -20% decreased banishment cost with your orb.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 65: Instant Spawn
    "Instant Spawn": {
        "ap_id": 1277,
        "description": "Have a shadow spawn a monster while time is frozen.",
        "requirements": [
        'Ritual trait',
        'Shadow element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 66: Ionized Air
    "Ionized Air": {
        "ap_id": 1278,
        "description": "Have the Insulation trait set to level 6 or higher and win t...",
        "requirements": [
        'Insulation trait'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 67: Is Anyone in There?
    "Is Anyone in There?": {
        "ap_id": 1279,
        "description": "Break a tomb open.",
        "requirements": [
        'Tomb element'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 68: Is This a Match-3 or What?
    "Is This a Match-3 or What?": {
        "ap_id": 1280,
        "description": "Have 90 gems on the battlefield.",
        "requirements": [
        'gemCount: 90'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Extreme",
    },
    # ID 69: It Has to Do
    "It Has to Do": {
        "ap_id": 1281,
        "description": "Beat 50 waves using at most grade 2 gems.",
        "requirements": [
        'minWave: 50'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Major",
    },
    # ID 70: It Hurts!
    "It Hurts!": {
        "ap_id": 1282,
        "description": "Spend 9.000 mana on banishment.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 71: It was Abandoned Anyway
    "It was Abandoned Anyway": {
        "ap_id": 1283,
        "description": "Destroy a dwelling.",
        "requirements": [
        'Abandoned Dwelling element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 72: It's Lagging Alright
    "It's Lagging Alright": {
        "ap_id": 1284,
        "description": "Have 1.200 monsters on the battlefield at the same time.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 73: It's a Trap
    "It's a Trap": {
        "ap_id": 1285,
        "description": "Don't let any monster touch your orb for 120 beaten waves.",
        "requirements": [
        'minWave: 120'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 74: Itchy Sphere
    "Itchy Sphere": {
        "ap_id": 1286,
        "description": "Deliver 3.600 banishments with your orb.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Extreme",
    },
    # ID 75: Jewel Box
    "Jewel Box": {
        "ap_id": 1287,
        "description": "Fill all inventory slots with gems.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 76: Jinx Blast
    "Jinx Blast": {
        "ap_id": 1288,
        "description": "Kill 30 whited out monsters with bolt.",
        "requirements": [
        'Bolt skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 77: Juggler
    "Juggler": {
        "ap_id": 1289,
        "description": "Use demolition 7 times.",
        "requirements": [
        'Demolition skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 78: Just Breathe In
    "Just Breathe In": {
        "ap_id": 1290,
        "description": "Enhance a pure poison gem having random priority with beam.",
        "requirements": [
        'Beam skill',
        'Poison skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 79: Just Fire More at Them
    "Just Fire More at Them": {
        "ap_id": 1291,
        "description": "Have the Thick Air trait set to level 6 or higher and win th...",
        "requirements": [
        'Thick Air trait'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 80: Just Give Me That Mana
    "Just Give Me That Mana": {
        "ap_id": 1292,
        "description": "Leech 7.200 mana from whited out monsters.",
        "requirements": [
        'Mana Leech skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 81: Just Started
    "Just Started": {
        "ap_id": 1293,
        "description": "Reach 10 battles won.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 82: Just Take My Mana!
    "Just Take My Mana!": {
        "ap_id": 1294,
        "description": "Spend 900.000 mana on banishment.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Extreme",
    },
    # ID 83: Keep Losing Keep Harvesting
    "Keep Losing Keep Harvesting": {
        "ap_id": 1295,
        "description": "Deplete a mana shard while there is a shadow on the battlefi...",
        "requirements": [
        'Ritual trait',
        'Mana Shard element',
        'Shadow element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 84: Keepers
    "Keepers": {
        "ap_id": 1296,
        "description": "Gain 800 mana from drops.",
        "requirements": [
        'Apparition element',
        'Corrupted Mana Shard element',
        'Mana Shard element',
        'Drop Holder element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 85: Keeping Low
    "Keeping Low": {
        "ap_id": 1297,
        "description": "Beat 40 waves using at most grade 2 gems.",
        "requirements": [
        'minWave: 40'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Minor",
    },
    # ID 86: Killed So Many
    "Killed So Many": {
        "ap_id": 1298,
        "description": "Gain 7.200 xp with kill chains.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 87: Knowledge Seeker
    "Knowledge Seeker": {
        "ap_id": 1299,
        "description": "Open a wizard stash.",
        "requirements": [
        'Wizard Stash element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 88: Lagging Already?
    "Lagging Already?": {
        "ap_id": 1300,
        "description": "Have 900 monsters on the battlefield at the same time.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Major",
    },
    # ID 89: Landing Spot
    "Landing Spot": {
        "ap_id": 1301,
        "description": "Demolish 20 or more walls with falling spires.",
        "requirements": [
        'Ritual trait',
        'Spire element',
        'Wall element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 90: Laser Slicer
    "Laser Slicer": {
        "ap_id": 1302,
        "description": "Have 8 beam enhanced gems at the same time.",
        "requirements": [
        'Beam skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 91: Last Minute Mana
    "Last Minute Mana": {
        "ap_id": 1303,
        "description": "Leech 500 mana from poisoned monsters.",
        "requirements": [
        'Mana Leech skill',
        'Poison skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 92: Legendary
    "Legendary": {
        "ap_id": 1304,
        "description": "Create a gem with a raw minimum damage of 30.000 or higher.",
        "requirements": [
        'gemCount: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Extreme",
    },
    # ID 93: Let Them Hatch
    "Let Them Hatch": {
        "ap_id": 1305,
        "description": "Don't crack any egg laid by a swarm queen.",
        "requirements": [
        'Swarm Queen element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 94: Let it Go
    "Let it Go": {
        "ap_id": 1306,
        "description": "Leave an apparition alive.",
        "requirements": [
        'Ritual trait',
        'Apparition element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 95: Let's Have a Look
    "Let's Have a Look": {
        "ap_id": 1307,
        "description": "Open a drop holder.",
        "requirements": [
        'Drop Holder element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 96: Light My Path
    "Light My Path": {
        "ap_id": 1308,
        "description": "Have 70 fields lit in Journey mode.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 97: Like a Necro
    "Like a Necro": {
        "ap_id": 1309,
        "description": "Kill 25 monsters with frozen corpse explosion.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 98: Limited Vision
    "Limited Vision": {
        "ap_id": 1310,
        "description": "Gain 100 xp with Whiteout spell crowd hits.",
        "requirements": [
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 99: Liquid Explosive
    "Liquid Explosive": {
        "ap_id": 1311,
        "description": "Kill 180 monsters with orblet explosions.",
        "requirements": [
        'Orb of Presence skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 100: Locked and Loaded
    "Locked and Loaded": {
        "ap_id": 1312,
        "description": "Have 3 pylons charged up to 3 shots each.",
        "requirements": [
        'Pylons skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 101: Long Crawl
    "Long Crawl": {
        "ap_id": 1313,
        "description": "Win a battle using only slowing gems.",
        "requirements": [
        'Slowing skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 102: Long Lasting
    "Long Lasting": {
        "ap_id": 1314,
        "description": "Reach 500 poison kills through all the battles.",
        "requirements": [
        'Poison skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 103: Long Run
    "Long Run": {
        "ap_id": 1315,
        "description": "Beat 360 waves.",
        "requirements": [
        'minWave: 360'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Extreme",
    },
    # ID 104: Longrunner
    "Longrunner": {
        "ap_id": 1316,
        "description": "Have 60 fields lit in Endurance mode.",
        "requirements": [
        'Endurance'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 105: Lost Signal
    "Lost Signal": {
        "ap_id": 1317,
        "description": "Destroy 35 beacons.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Major",
    },
}

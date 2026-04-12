"""
GemCraft Frostborn Wrath — Achievement Pack 4

Contains approximately 106 achievements.
Each achievement has a "grindiness" property ("Trivial", "Minor", "Major", "Extreme") for easy adjustment.
"""

achievement_requirements = {
    # ID 0: Lots of Crit Hits
    "Lots of Crit Hits": {
        "ap_id": 1318,
        "description": "Have a pure critical hit gem with 2.000 hits.",
        "requirements": [
        'Critical Hit skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 1: Lots of Scratches
    "Lots of Scratches": {
        "ap_id": 1319,
        "description": "Reach a kill chain of 300.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 2: Major Shutdown
    "Major Shutdown": {
        "ap_id": 1320,
        "description": "Destroy 3 monster nests.",
        "requirements": [
        'Monster Nest element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 3: Mana Blinded
    "Mana Blinded": {
        "ap_id": 1321,
        "description": "Leech 900 mana from whited out monsters.",
        "requirements": [
        'Mana Leech skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 4: Mana Cult
    "Mana Cult": {
        "ap_id": 1322,
        "description": "Leech 6.500 mana from bleeding monsters.",
        "requirements": [
        'Bleeding skill',
        'Mana Leech skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 5: Mana First
    "Mana First": {
        "ap_id": 1323,
        "description": "Deplete a shard when there are more than 300 swarmlings on t...",
        "requirements": [
        'Mana Shard element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 6: Mana Greedy
    "Mana Greedy": {
        "ap_id": 1324,
        "description": "Leech 1.800 mana with a grade 1 gem.",
        "requirements": [
        'Mana Leech skill',
        'minGemGrade: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 7: Mana Hack
    "Mana Hack": {
        "ap_id": 1325,
        "description": "Have 80.000 initial mana.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Extreme",
    },
    # ID 8: Mana Magnet
    "Mana Magnet": {
        "ap_id": 1326,
        "description": "Win a battle using only mana leeching gems.",
        "requirements": [
        'Mana Leech skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 9: Mana Salvation
    "Mana Salvation": {
        "ap_id": 1327,
        "description": "Salvage mana by destroying a gem.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 10: Mana Singularity
    "Mana Singularity": {
        "ap_id": 1328,
        "description": "Reach mana pool level 20.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Extreme",
    },
    # ID 11: Mana Tap
    "Mana Tap": {
        "ap_id": 1329,
        "description": "Reach 10.000 mana harvested from shards through all the batt...",
        "requirements": [
        'Mana Shard element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 12: Mana Trader
    "Mana Trader": {
        "ap_id": 1330,
        "description": "Salvage 8.000 mana from gems.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 13: Mana in a Bottle
    "Mana in a Bottle": {
        "ap_id": 1331,
        "description": "Have 40.000 initial mana.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Major",
    },
    # ID 14: Mana is All I Need
    "Mana is All I Need": {
        "ap_id": 1332,
        "description": "Win a battle with no skill point spent and a battle trait ma...",
        "requirements": [
        'Any battle trait\n\n'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 15: Mana of the Dying
    "Mana of the Dying": {
        "ap_id": 1333,
        "description": "Leech 2.300 mana from poisoned monsters.",
        "requirements": [
        'Mana Leech skill',
        'Poison skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 16: Marked Targets
    "Marked Targets": {
        "ap_id": 1334,
        "description": "Reach 10.000 monsters with special properties killed through...",
        "requirements": [
        'Possessed Monster element',
        'Twisted Monster element',
        'Marked Monster element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 17: Marmalade
    "Marmalade": {
        "ap_id": 1335,
        "description": "Don't destroy any of the jars of wasps.",
        "requirements": [
        'Field X2'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 18: Mass Awakening
    "Mass Awakening": {
        "ap_id": 1336,
        "description": "Lure 2.500 swarmlings out of a sleeping hive.",
        "requirements": [
        'Sleeping Hive element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 19: Mastery
    "Mastery": {
        "ap_id": 1337,
        "description": "Raise a skill to level 70.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 20: Max Trap Max leech
    "Max Trap Max leech": {
        "ap_id": 1338,
        "description": "Leech 6.300 mana with a grade 1 gem.",
        "requirements": [
        'Mana Leech skill',
        'minGemGrade: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 21: Meet the Spartans
    "Meet the Spartans": {
        "ap_id": 1339,
        "description": "Have 300 monsters on the battlefield at the same time.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 22: Megalithic
    "Megalithic": {
        "ap_id": 1340,
        "description": "Reach 2.000 structures built through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 23: Melting Armor
    "Melting Armor": {
        "ap_id": 1341,
        "description": "Tear a total of 10.000 armor with wasp stings.",
        "requirements": [
        'Armor Tearing skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 24: Melting Pulse
    "Melting Pulse": {
        "ap_id": 1342,
        "description": "Hit 75 frozen monsters with shrines.",
        "requirements": [
        'Freeze skill',
        'Shrine element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 25: Might Need it Later
    "Might Need it Later": {
        "ap_id": 1343,
        "description": "Enhance a gem in an amplifier.",
        "requirements": [
        'Amplifiers skill',
        'Bolt skill',
        'Beam skill',
        'Barrage skill'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 26: Mighty
    "Mighty": {
        "ap_id": 1344,
        "description": "Create a gem with a raw minimum damage of 3.000 or higher.",
        "requirements": [
        'gemCount: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 27: Minefield
    "Minefield": {
        "ap_id": 1345,
        "description": "Kill 300 monsters with gems in traps.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 28: Miniblasts
    "Miniblasts": {
        "ap_id": 1346,
        "description": "Tear a total of 1.250 armor with wasp stings.",
        "requirements": [
        'Armor Tearing skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 29: Minor Detour
    "Minor Detour": {
        "ap_id": 1347,
        "description": "Build 15 walls.",
        "requirements": [
        'Wall element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 30: Mixing Up
    "Mixing Up": {
        "ap_id": 1348,
        "description": "Beat 50 waves on max Swarmling and Giant domination traits.",
        "requirements": [
        'Swarmling Domination trait',
        'Giant Domination trait',
        'minWave: 50'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Extreme",
    },
    # ID 31: More Than Enough
    "More Than Enough": {
        "ap_id": 1349,
        "description": "Summon 1.000 monsters by enraging waves.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Extreme",
    },
    # ID 32: More Wounds
    "More Wounds": {
        "ap_id": 1350,
        "description": "Kill 125 bleeding monsters with barrage.",
        "requirements": [
        'Barrage skill',
        'Bleeding skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 33: Morning March
    "Morning March": {
        "ap_id": 1351,
        "description": "Lure 500 swarmlings out of a sleeping hive.",
        "requirements": [
        'Sleeping Hive element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 34: Multifreeze
    "Multifreeze": {
        "ap_id": 1352,
        "description": "Reach 5.000 strike spell hits through all the battles.",
        "requirements": [
        'strikeSpells:1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 35: Multiline
    "Multiline": {
        "ap_id": 1353,
        "description": "Have at least 5 different talisman properties.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 36: Multinerf
    "Multinerf": {
        "ap_id": 1354,
        "description": "Kill 1.600 monsters with prismatic gem wasps.",
        "requirements": [
        'Mana Leech skill',
        'Critical Hit skill',
        'Bleeding skill',
        'Armor Tearing skill',
        'Poison skill',
        'Slowing skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 37: Mythic Ancient Legendary
    "Mythic Ancient Legendary": {
        "ap_id": 1355,
        "description": "Create a gem with a raw minimum damage of 300.000 or higher.",
        "requirements": [
        'gemCount: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Extreme",
    },
    # ID 38: Nature Takes Over
    "Nature Takes Over": {
        "ap_id": 1356,
        "description": "Have no own buildings on the field at the end of the battle.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 39: Near Death
    "Near Death": {
        "ap_id": 1357,
        "description": "Suffer mana loss from a shadow projectile when under 200 man...",
        "requirements": [
        'Shadow element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 40: Necrotrophic
    "Necrotrophic": {
        "ap_id": 1358,
        "description": "Reach 1.000 poison kills through all the battles.",
        "requirements": [
        'Poison skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 41: Need Lots of Them
    "Need Lots of Them": {
        "ap_id": 1359,
        "description": "Beat 60 waves using at most grade 2 gems.",
        "requirements": [
        'minWave: 60'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Extreme",
    },
    # ID 42: Need More Rage
    "Need More Rage": {
        "ap_id": 1360,
        "description": "Upgrade a gem in the enraging socket.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 43: Needle Storm
    "Needle Storm": {
        "ap_id": 1361,
        "description": "Deal 350 gem wasp stings to creatures.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 44: Nest Blaster
    "Nest Blaster": {
        "ap_id": 1362,
        "description": "Destroy 2 monster nests before wave 12.",
        "requirements": [
        'Monster Nest element'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 45: Nest Buster
    "Nest Buster": {
        "ap_id": 1363,
        "description": "Destroy 3 monster nests before wave 6.",
        "requirements": [
        'Monster Nest element'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Minor",
    },
    # ID 46: No Armor Area
    "No Armor Area": {
        "ap_id": 1364,
        "description": "Beat 90 waves using only armor tearing gems.",
        "requirements": [
        'Armor Tearing skill',
        'minWave: 90'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 47: No Beacon Zone
    "No Beacon Zone": {
        "ap_id": 1365,
        "description": "Reach 200 beacons destroyed through all the battles.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 48: No Honor Among Thieves
    "No Honor Among Thieves": {
        "ap_id": 1366,
        "description": "Have a watchtower kill a specter.",
        "requirements": [
        'Ritual trait',
        'Specter element',
        'Watchtower element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 49: No Land for Swarmlings
    "No Land for Swarmlings": {
        "ap_id": 1367,
        "description": "Kill 3.333 swarmlings.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Extreme",
    },
    # ID 50: No More Rounds
    "No More Rounds": {
        "ap_id": 1368,
        "description": "Kill 60 banished monsters with shrines.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 51: No Need to Aim
    "No Need to Aim": {
        "ap_id": 1369,
        "description": "Have 4 barrage enhanced gems at the same time.",
        "requirements": [
        'Barrage skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 52: No Place to Hide
    "No Place to Hide": {
        "ap_id": 1370,
        "description": "Cast 25 strike spells.",
        "requirements": [
        'strikeSpells: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 53: No Stone Unturned
    "No Stone Unturned": {
        "ap_id": 1371,
        "description": "Open 5 drop holders.",
        "requirements": [
        'Drop Holder element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 54: No Time to Rest
    "No Time to Rest": {
        "ap_id": 1372,
        "description": "Have the Haste trait set to level 6 or higher and win the ba...",
        "requirements": [
        'Haste trait'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 55: No Time to Waste
    "No Time to Waste": {
        "ap_id": 1373,
        "description": "Reach 5.000 waves started early through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 56: No Use of Vitality
    "No Use of Vitality": {
        "ap_id": 1374,
        "description": "Kill a monster having at least 20.000 hit points.",
        "requirements": [
        'A monster with atleast 20.000hp'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 57: No You Won't!
    "No You Won't!": {
        "ap_id": 1375,
        "description": "Destroy a watchtower before it could fire.",
        "requirements": [
        'Bolt skill',
        'Watchtower element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 58: Not Chasing Shadows Anymore
    "Not Chasing Shadows Anymore": {
        "ap_id": 1376,
        "description": "Kill 4 shadows.",
        "requirements": [
        'Ritual trait',
        'Shadow element'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Major",
    },
    # ID 59: Not So Fast
    "Not So Fast": {
        "ap_id": 1377,
        "description": "Freeze a specter.",
        "requirements": [
        'Freeze skill',
        'Ritual trait',
        'Specter element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 60: Not So Omni Anymore
    "Not So Omni Anymore": {
        "ap_id": 1378,
        "description": "Destroy 10 omnibeacons.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 61: Not Worth It
    "Not Worth It": {
        "ap_id": 1379,
        "description": "Harvest 9.000 mana from a corrupted mana shard.",
        "requirements": [
        'Corrupted Mana Shard element'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 62: Nothing Prevails
    "Nothing Prevails": {
        "ap_id": 1380,
        "description": "Reach 25.000 poison kills through all the battles.",
        "requirements": [
        'Poison skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 63: Nox Mist
    "Nox Mist": {
        "ap_id": 1381,
        "description": "Win a battle using only poison gems.",
        "requirements": [
        'Poison skill'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 64: Oh Ven
    "Oh Ven": {
        "ap_id": 1382,
        "description": "Spread the poison",
        "requirements": [
        'Poison skill',
        '90 monsters poisoned at the same time'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 65: Ok Flier
    "Ok Flier": {
        "ap_id": 1383,
        "description": "Kill 340 monsters while there are at least 2 wraiths in the ...",
        "requirements": [
        'Ritual trait',
        'Wraith element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 66: Omelette
    "Omelette": {
        "ap_id": 1384,
        "description": "Reach 200 monster eggs cracked through all the battles.",
        "requirements": [
        'Swarm Queen element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 67: Omnibomb
    "Omnibomb": {
        "ap_id": 1385,
        "description": "Destroy a building and a non-monster creature with one gem b...",
        "requirements": [
        'Ritual trait'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 68: On the Shoulders of Giants
    "On the Shoulders of Giants": {
        "ap_id": 1386,
        "description": "Have the Giant Domination trait set to level 6 or higher and...",
        "requirements": [
        'Giant Domination trait'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 69: One Hit is All it Takes
    "One Hit is All it Takes": {
        "ap_id": 1387,
        "description": "Kill a wraith with one hit.",
        "requirements": [
        'Ritual trait',
        'Wraith element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 70: One Less Problem
    "One Less Problem": {
        "ap_id": 1388,
        "description": "Destroy a monster nest while there is a wraith on the battle...",
        "requirements": [
        'Ritual trait',
        'Monster Nest element',
        'Wraith element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 71: One by One
    "One by One": {
        "ap_id": 1389,
        "description": "Deliver 750 one hit kills.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Major",
    },
    # ID 72: Orange Wand
    "Orange Wand": {
        "ap_id": 1390,
        "description": "Reach wizard level 40.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 73: Ouch!
    "Ouch!": {
        "ap_id": 1391,
        "description": "Spend 900 mana on banishment.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 74: Out of Misery
    "Out of Misery": {
        "ap_id": 1392,
        "description": "Kill a monster that is whited out, poisoned, frozen and slow...",
        "requirements": [
        'Freeze skill',
        'Poison skill',
        'Slowing skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 75: Out of Nowhere
    "Out of Nowhere": {
        "ap_id": 1393,
        "description": "Kill a whited out possessed monster with bolt.",
        "requirements": [
        'Bolt skill',
        'Whiteout skill',
        'Possessed Monster element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 76: Outwhited
    "Outwhited": {
        "ap_id": 1394,
        "description": "Gain 4.700 xp with Whiteout spell crowd hits.",
        "requirements": [
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 77: Overheated
    "Overheated": {
        "ap_id": 1395,
        "description": "Kill a giant with beam shot.",
        "requirements": [
        'Beam skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 78: Overpecked
    "Overpecked": {
        "ap_id": 1396,
        "description": "Deal 100 gem wasp stings to the same monster.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 79: Painful Leech
    "Painful Leech": {
        "ap_id": 1397,
        "description": "Leech 3.200 mana from bleeding monsters.",
        "requirements": [
        'Bleeding skill',
        'Mana Leech skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 80: Paranormal Paragon
    "Paranormal Paragon": {
        "ap_id": 1398,
        "description": "Reach 500 non-monsters killed through all the battles.",
        "requirements": [
        'Ritual trait'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 81: Pat on the Back
    "Pat on the Back": {
        "ap_id": 1399,
        "description": "Amplify a gem.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 82: Path of Splats
    "Path of Splats": {
        "ap_id": 1400,
        "description": "Kill 400 monsters.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 83: Peek Into The Abyss
    "Peek Into The Abyss": {
        "ap_id": 1401,
        "description": "Kill a monster with all battle traits set to the highest lev...",
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
        'Ritual trait'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 84: Pest Control
    "Pest Control": {
        "ap_id": 1402,
        "description": "Kill 333 swarmlings.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 85: Plentiful
    "Plentiful": {
        "ap_id": 1403,
        "description": "Have 1.000 shadow cores at the start of the battle.",
        "requirements": [
        'Shadow Core element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 86: Pointed Pain
    "Pointed Pain": {
        "ap_id": 1404,
        "description": "Deal 50 gem wasp stings to creatures.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 87: Popped
    "Popped": {
        "ap_id": 1405,
        "description": "Kill at least 30 gatekeeper fangs.",
        "requirements": [
        'Gatekeeper element',
        'Field A4'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 88: Popped Eggs
    "Popped Eggs": {
        "ap_id": 1406,
        "description": "Kill a swarm queen with a bolt.",
        "requirements": [
        'Bolt skill',
        'Swarm Queen element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 89: Popping Lights
    "Popping Lights": {
        "ap_id": 1407,
        "description": "Destroy 5 beacons.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 90: Power Exchange
    "Power Exchange": {
        "ap_id": 1408,
        "description": "Build 25 amplifiers.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 91: Power Flow
    "Power Flow": {
        "ap_id": 1409,
        "description": "Build 15 amplifiers.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 92: Power Node
    "Power Node": {
        "ap_id": 1410,
        "description": "Activate the same shrine 5 times.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 93: Power Overwhelming
    "Power Overwhelming": {
        "ap_id": 1411,
        "description": "Reach mana pool level 15.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Major",
    },
    # ID 94: Power Sharing
    "Power Sharing": {
        "ap_id": 1412,
        "description": "Build 5 amplifiers.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 95: Powerful
    "Powerful": {
        "ap_id": 1413,
        "description": "Create a gem with a raw minimum damage of 300 or higher.",
        "requirements": [
        'gemCount: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 96: Precious
    "Precious": {
        "ap_id": 1414,
        "description": "Get a gem from a drop holder.",
        "requirements": [
        'Drop Holder element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 97: Prismatic
    "Prismatic": {
        "ap_id": 1415,
        "description": "Create a gem of 6 components.",
        "requirements": [
        'Critical Hit skill',
        'Mana Leech skill',
        'Bleeding skill',
        'Armor Tearing skill',
        'Poison skill',
        'Slowing skill',
        'gemCount: 6'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 2,
        "grindiness": "Minor",
    },
    # ID 98: Prismatic Takeaway
    "Prismatic Takeaway": {
        "ap_id": 1416,
        "description": "Have a specter steal a gem of 6 components.",
        "requirements": [
        'Critical Hit skill',
        'Mana Leech skill',
        'Bleeding skill',
        'Armor Tearing skill',
        'Poison skill',
        'Slowing skill',
        'Specter element',
        'gemCount: 6'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 99: Punching Deep
    "Punching Deep": {
        "ap_id": 1417,
        "description": "Tear a total of 2.500 armor with wasp stings.",
        "requirements": [
        'Armor Tearing skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 100: Puncture Therapy
    "Puncture Therapy": {
        "ap_id": 1418,
        "description": "Deal 950 gem wasp stings to creatures.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 101: Punctured Texture
    "Punctured Texture": {
        "ap_id": 1419,
        "description": "Deal 5.000 gem wasp stings to buildings.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 102: Puncturing Shots
    "Puncturing Shots": {
        "ap_id": 1420,
        "description": "Deliver 75 one hit kills.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 103: Purged
    "Purged": {
        "ap_id": 1421,
        "description": "Kill 179 marked monsters.",
        "requirements": [
        'Marked Monster element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 104: Purist
    "Purist": {
        "ap_id": 1422,
        "description": "Beat 120 waves and don't use any strike or gem enhancement s...",
        "requirements": [
        'minWave: 120'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Trivial",
    },
    # ID 105: Purple Wand
    "Purple Wand": {
        "ap_id": 1423,
        "description": "Reach wizard level 200.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Extreme",
    },
}

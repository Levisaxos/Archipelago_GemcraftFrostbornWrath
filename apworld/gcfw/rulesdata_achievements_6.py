"""
GemCraft Frostborn Wrath — Achievement Pack 6

Contains approximately 106 achievements.
Each achievement has a "grindiness" property ("Trivial", "Minor", "Major", "Extreme") for easy adjustment.
"""

achievement_requirements = {
    # ID 0: Super Gem
    "Super Gem": {
        "ap_id": 1530,
        "description": "Create a grade 3 gem with 300 effective max damage.",
        "requirements": [
        'minGemGrade: 3'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 1: Supply Line Cut
    "Supply Line Cut": {
        "ap_id": 1531,
        "description": "Kill a swarm queen with a barrage shell.",
        "requirements": [
        'Barrage skill',
        'Swarm Queen element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 2: Swarmling Season
    "Swarmling Season": {
        "ap_id": 1532,
        "description": "Kill 999 swarmlings.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 3: Swift Death
    "Swift Death": {
        "ap_id": 1533,
        "description": "Kill the gatekeeper with a bolt.",
        "requirements": [
        'Bolt skill',
        'Gatekeeper element',
        'Field A4'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 4: Swift Deployment
    "Swift Deployment": {
        "ap_id": 1534,
        "description": "Have 20 gems on the battlefield before wave 5.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 5: Take Them I Have More
    "Take Them I Have More": {
        "ap_id": 1535,
        "description": "Have 12 of your gems destroyed or stolen.",
        "requirements": [
        'Ritual trait',
        'Specter element',
        'Watchtower element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 6: Takers
    "Takers": {
        "ap_id": 1536,
        "description": "Gain 1.600 mana from drops.",
        "requirements": [
        'Apparition element',
        'Corrupted Mana Shard element',
        'Drop Holder element',
        'Mana Shard element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 7: Tapped Essence
    "Tapped Essence": {
        "ap_id": 1537,
        "description": "Leech 1.500 mana from bleeding monsters.",
        "requirements": [
        'Bleeding skill',
        'Mana Leech skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 8: Targeting Weak Points
    "Targeting Weak Points": {
        "ap_id": 1538,
        "description": "Win a battle using only critical hit gems.",
        "requirements": [
        'Critical Hit skill'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 9: Taste All The Affixes
    "Taste All The Affixes": {
        "ap_id": 1539,
        "description": "Kill 2.500 monsters with prismatic gem wasps.",
        "requirements": [
        'Critical Hit skill',
        'Mana Leech skill',
        'Bleeding skill',
        'Armor Tearing skill',
        'Poison skill',
        'Slowing skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 10: Tasting the Darkness
    "Tasting the Darkness": {
        "ap_id": 1540,
        "description": "Break 3 tombs open.",
        "requirements": [
        'Tomb element'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Minor",
    },
    # ID 11: Teleport Lag
    "Teleport Lag": {
        "ap_id": 1541,
        "description": "Banish a monster at least 5 times.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 12: Ten Angry Waves
    "Ten Angry Waves": {
        "ap_id": 1542,
        "description": "Enrage 10 waves.",
        "requirements": [
        'minWave: 10'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 13: That Was Rude
    "That Was Rude": {
        "ap_id": 1543,
        "description": "Lose a gem with more than 1.000 hits to a watchtower.",
        "requirements": [
        'Watchtower element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 14: That Was Your Last Move
    "That Was Your Last Move": {
        "ap_id": 1544,
        "description": "Kill a wizard hunter while it's attacking one of your buildi...",
        "requirements": [
        'Wizard Hunter'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 15: That one!
    "That one!": {
        "ap_id": 1545,
        "description": "Select a monster.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 16: The Gathering
    "The Gathering": {
        "ap_id": 1546,
        "description": "Summon 500 monsters by enraging waves.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Major",
    },
    # ID 17: The Horror
    "The Horror": {
        "ap_id": 1547,
        "description": "Lose 3.333 mana to shadows.",
        "requirements": [
        'Ritual trait',
        'Shadow element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 18: The Killing Will Never Stop
    "The Killing Will Never Stop": {
        "ap_id": 1548,
        "description": "Reach 200.000 monsters killed through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 19: The Mana Reaper
    "The Mana Reaper": {
        "ap_id": 1549,
        "description": "Reach 100.000 mana harvested from shards through all the bat...",
        "requirements": [
        'Mana Shard element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 20: The Messenger Must Die
    "The Messenger Must Die": {
        "ap_id": 1550,
        "description": "Kill a shadow.",
        "requirements": [
        'Ritual trait',
        'Shadow element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 21: The Peeler
    "The Peeler": {
        "ap_id": 1551,
        "description": "Create a grade 12 pure armor tearing gem.",
        "requirements": [
        'Armor Tearing skill',
        'minGemGrade: 12'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 22: The Price of Obsession
    "The Price of Obsession": {
        "ap_id": 1552,
        "description": "Kill 590 banished monsters.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 23: There it is!
    "There it is!": {
        "ap_id": 1553,
        "description": "Select a building.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 24: There's No Time
    "There's No Time": {
        "ap_id": 1554,
        "description": "Call 140 waves early.",
        "requirements": [
        'minWave: 140'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 25: They Are Millions
    "They Are Millions": {
        "ap_id": 1555,
        "description": "Reach 1.000.000 monsters killed through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 26: They Are Still Here
    "They Are Still Here": {
        "ap_id": 1556,
        "description": "Kill 2 apparitions.",
        "requirements": [
        'Ritual trait',
        'Apparition element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 27: They Keep Coming
    "They Keep Coming": {
        "ap_id": 1557,
        "description": "Kill 12.000 monsters.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Major",
    },
    # ID 28: Thin Ice
    "Thin Ice": {
        "ap_id": 1558,
        "description": "Kill 20 frozen monsters with gems in traps.",
        "requirements": [
        'Freeze skill',
        'Traps skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 29: Thin Them Out
    "Thin Them Out": {
        "ap_id": 1559,
        "description": "Have the Strength in Numbers trait set to level 6 or higher ...",
        "requirements": [
        'Strength in Numbers trait'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 30: Third Grade
    "Third Grade": {
        "ap_id": 1560,
        "description": "Create a grade 3 gem.",
        "requirements": [
        'minGemGrade: 3'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 31: Thorned Sphere
    "Thorned Sphere": {
        "ap_id": 1561,
        "description": "Deliver 400 banishments with your orb.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Minor",
    },
    # ID 32: Through All Layers
    "Through All Layers": {
        "ap_id": 1562,
        "description": "Kill a monster having at least 200 armor.",
        "requirements": [
        'A monster with atleast 200 armor'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 33: Thunderstruck
    "Thunderstruck": {
        "ap_id": 1563,
        "description": "Kill 120 monsters with gem bombs and wasps.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 34: Tightly Secured
    "Tightly Secured": {
        "ap_id": 1564,
        "description": "Don't let any monster touch your orb for 60 beaten waves.",
        "requirements": [
        'minWave: 60'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 35: Time Bent
    "Time Bent": {
        "ap_id": 1565,
        "description": "Have 90 monsters slowed at the same time.",
        "requirements": [
        'Slowing skill'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 36: Time to Rise
    "Time to Rise": {
        "ap_id": 1566,
        "description": "Have the Awakening trait set to level 6 or higher and win th...",
        "requirements": [
        'Awakening trait'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 37: Time to Upgrade
    "Time to Upgrade": {
        "ap_id": 1567,
        "description": "Have a grade 1 gem with 4.500 hits.",
        "requirements": [
        'minGemGrade: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 38: Tiny but Deadly
    "Tiny but Deadly": {
        "ap_id": 1568,
        "description": "Reach 50.000 gem wasp kills through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 39: To the Last Drop
    "To the Last Drop": {
        "ap_id": 1569,
        "description": "Leech 4.700 mana from poisoned monsters.",
        "requirements": [
        'Mana Leech skill',
        'Poison skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 40: Tomb No Matter What
    "Tomb No Matter What": {
        "ap_id": 1570,
        "description": "Open a tomb while there is a spire on the battlefield.",
        "requirements": [
        'Ritual trait',
        'Spire element',
        'Tomb element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 41: Tomb Raiding
    "Tomb Raiding": {
        "ap_id": 1571,
        "description": "Break a tomb open before wave 15.",
        "requirements": [
        'Tomb element'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Trivial",
    },
    # ID 42: Tomb Stomping
    "Tomb Stomping": {
        "ap_id": 1572,
        "description": "Break 4 tombs open.",
        "requirements": [
        'Tomb element'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Major",
    },
    # ID 43: Too Curious
    "Too Curious": {
        "ap_id": 1573,
        "description": "Break 2 tombs open.",
        "requirements": [
        'Tomb element'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 44: Too Easy
    "Too Easy": {
        "ap_id": 1574,
        "description": "Win a Trial battle with at least 3 waves enraged.",
        "requirements": [
        'minWave: 3',
        'Trial'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Trivial",
    },
    # ID 45: Too Long to Hold Your Breath
    "Too Long to Hold Your Breath": {
        "ap_id": 1575,
        "description": "Beat 90 waves using only poison gems.",
        "requirements": [
        'Poison skill',
        'minWave: 90'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 46: Towerful
    "Towerful": {
        "ap_id": 1576,
        "description": "Build 5 towers.",
        "requirements": [
        'Tower element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 47: Trapland
    "Trapland": {
        "ap_id": 1577,
        "description": "And it's bloody too",
        "requirements": [
        'Traps skill',
        'Complete a level using only traps and no poison gems'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 48: Trembling
    "Trembling": {
        "ap_id": 1578,
        "description": "Kill 1.500 monsters with gems in traps.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Extreme",
    },
    # ID 49: Tricolor
    "Tricolor": {
        "ap_id": 1579,
        "description": "Create a gem of 3 components.",
        "requirements": [
        'gemCount: 3'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 50: Troll's Eye
    "Troll's Eye": {
        "ap_id": 1580,
        "description": "Kill a giant with one shot.",
        "requirements": [
        'Bolt skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 51: Tumbling Billows
    "Tumbling Billows": {
        "ap_id": 1581,
        "description": "Have the Swarmling Domination trait set to level 6 or higher...",
        "requirements": [
        'Swarmling Domination trait'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 52: Twice the Blast
    "Twice the Blast": {
        "ap_id": 1582,
        "description": "Have 2 barrage enhanced gems at the same time.",
        "requirements": [
        'Barrage skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 53: Twice the Shock
    "Twice the Shock": {
        "ap_id": 1583,
        "description": "Hit the same monster 2 times with shrines.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 54: Twice the Steepness
    "Twice the Steepness": {
        "ap_id": 1584,
        "description": "Kill 170 monsters while there are at least 2 wraiths in the ...",
        "requirements": [
        'Ritual trait',
        'Wraith element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 55: Twice the Terror
    "Twice the Terror": {
        "ap_id": 1585,
        "description": "Kill 2 shadows.",
        "requirements": [
        'Ritual trait',
        'Shadow element'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 56: Unarmed
    "Unarmed": {
        "ap_id": 1586,
        "description": "Have no gems when wave 20 starts.",
        "requirements": [
        'minWave: 20'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 57: Under Pressure
    "Under Pressure": {
        "ap_id": 1587,
        "description": "Shoot down 340 shadow projectiles.",
        "requirements": [
        'Ritual trait',
        'Shadow element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 58: Unending Flow
    "Unending Flow": {
        "ap_id": 1588,
        "description": "Kill 24.000 monsters.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Extreme",
    },
    # ID 59: Unholy Stack
    "Unholy Stack": {
        "ap_id": 1589,
        "description": "Reach 20.000 monsters with special properties killed through...",
        "requirements": [
        'Possessed Monster element',
        'Twisted Monster element',
        'Marked Monster element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 60: Uninvited
    "Uninvited": {
        "ap_id": 1590,
        "description": "Summon 100 monsters by enraging waves.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Minor",
    },
    # ID 61: Unsupportive
    "Unsupportive": {
        "ap_id": 1591,
        "description": "Reach 100 beacons destroyed through all the battles.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 62: Uraj and Khalis
    "Uraj and Khalis": {
        "ap_id": 1592,
        "description": "Activate the lanterns",
        "requirements": [
        'Lanterns skill',
        'Field H3'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 63: Urban Warfare
    "Urban Warfare": {
        "ap_id": 1593,
        "description": "Destroy a dwelling and kill a monster with one gem bomb.",
        "requirements": [
        'Abandoned Dwelling element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 64: Vantage Point Down
    "Vantage Point Down": {
        "ap_id": 1594,
        "description": "Demolish a pylon.",
        "requirements": [
        'Pylons skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 65: Versatile Charm
    "Versatile Charm": {
        "ap_id": 1595,
        "description": "Have at least 10 different talisman properties.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 66: Violet Ray
    "Violet Ray": {
        "ap_id": 1596,
        "description": "Kill 20 frozen monsters with beam.",
        "requirements": [
        'Beam skill',
        'Freeze skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 67: Warming Up
    "Warming Up": {
        "ap_id": 1597,
        "description": "Have a grade 1 gem with 100 hits.",
        "requirements": [
        'minGemGrade: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 68: Wash Away
    "Wash Away": {
        "ap_id": 1598,
        "description": "Kill 110 monsters while it's raining.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 69: Wasp Defense
    "Wasp Defense": {
        "ap_id": 1599,
        "description": "Smash 3 jars of wasps before wave 3.",
        "requirements": [
        'Field X2'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 70: Wasp Storm
    "Wasp Storm": {
        "ap_id": 1600,
        "description": "Kill 360 monsters with gem bombs and wasps.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 71: Waspocalypse
    "Waspocalypse": {
        "ap_id": 1601,
        "description": "Kill 1.080 monsters with gem bombs and wasps.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 72: Watch Your Step
    "Watch Your Step": {
        "ap_id": 1602,
        "description": "Build 40 traps.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 73: Wave Pecking
    "Wave Pecking": {
        "ap_id": 1603,
        "description": "Summon 20 monsters by enraging waves.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 74: Wave Smasher
    "Wave Smasher": {
        "ap_id": 1604,
        "description": "Reach 10.000 waves beaten through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 75: Waves for Breakfast
    "Waves for Breakfast": {
        "ap_id": 1605,
        "description": "Reach 2.000 waves beaten through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 76: Wavy
    "Wavy": {
        "ap_id": 1606,
        "description": "Reach 500 waves beaten through all the battles.",
        "requirements": [
        'minWave: 500'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 77: We Just Wanna Be Free
    "We Just Wanna Be Free": {
        "ap_id": 1607,
        "description": "More than blue triangles",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 78: Weakened Wallet
    "Weakened Wallet": {
        "ap_id": 1608,
        "description": "Leech 5.400 mana from whited out monsters.",
        "requirements": [
        'Mana Leech skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 79: Weather Tower
    "Weather Tower": {
        "ap_id": 1609,
        "description": "Activate a shrine while raining.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 80: Weather of Wasps
    "Weather of Wasps": {
        "ap_id": 1610,
        "description": "Deal 3950 gem wasp stings to creatures.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 81: Well Defended
    "Well Defended": {
        "ap_id": 1611,
        "description": "Don't let any monster touch your orb for 20 beaten waves.",
        "requirements": [
        'minWave:20'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 82: Well Earned
    "Well Earned": {
        "ap_id": 1612,
        "description": "Reach 500 battles won.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 83: Well Laid
    "Well Laid": {
        "ap_id": 1613,
        "description": "Have 10 gems on the battlefield.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 84: Well Prepared
    "Well Prepared": {
        "ap_id": 1614,
        "description": "Have 20.000 initial mana.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 85: Well Trained for This
    "Well Trained for This": {
        "ap_id": 1615,
        "description": "Kill a wraith with a shot fired by a gem having at least 1.0...",
        "requirements": [
        'Ritual trait',
        'Wraith element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 86: Whacked
    "Whacked": {
        "ap_id": 1616,
        "description": "Kill a specter with one hit.",
        "requirements": [
        'Ritual trait',
        'Specter element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 87: What Are You Waiting For?
    "What Are You Waiting For?": {
        "ap_id": 1617,
        "description": "Have all spells charged to 200%.",
        "requirements": [
        'Freeze skill',
        'Whiteout skill',
        'Ice Shards skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 88: White Ray
    "White Ray": {
        "ap_id": 1618,
        "description": "Kill 90 frozen monsters with beam.",
        "requirements": [
        'Beam skill',
        'Freeze skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 89: White Ring of Death
    "White Ring of Death": {
        "ap_id": 1619,
        "description": "Gain 4.900 xp with Ice Shards spell crowd hits.",
        "requirements": [
        'Ice Shards skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 90: White Wand
    "White Wand": {
        "ap_id": 1620,
        "description": "Reach wizard level 10.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 91: Why Not
    "Why Not": {
        "ap_id": 1621,
        "description": "Enhance a gem in the enraging socket.",
        "requirements": [
        'enhancementSpells: 3'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 92: Wicked Gem
    "Wicked Gem": {
        "ap_id": 1622,
        "description": "Have a grade 3 gem with 900 effective max damage.",
        "requirements": [
        'minGemGrade: 3'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 93: Wings and Tentacles
    "Wings and Tentacles": {
        "ap_id": 1623,
        "description": "Reach 200 non-monsters killed through all the battles.",
        "requirements": [
        'Ritual trait'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 94: Worst of Both Sizes
    "Worst of Both Sizes": {
        "ap_id": 1624,
        "description": "Beat 300 waves on max Swarmling and Giant domination traits.",
        "requirements": [
        'Swarmling Domination trait',
        'Giant Domination trait',
        'minWave: 300',
        'Endurance'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Extreme",
    },
    # ID 95: Worthy
    "Worthy": {
        "ap_id": 1625,
        "description": "Have 70 fields lit in Trial mode.",
        "requirements": [
        'Trial'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Extreme",
    },
    # ID 96: Xp Harvest
    "Xp Harvest": {
        "ap_id": 1626,
        "description": "Have 40 fields lit in Endurance mode.",
        "requirements": [
        'Endurance'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 97: Yellow Wand
    "Yellow Wand": {
        "ap_id": 1627,
        "description": "Reach wizard level 20.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 98: You Could Be my Apprentice
    "You Could Be my Apprentice": {
        "ap_id": 1628,
        "description": "Have a watchtower kill a wizard hunter.",
        "requirements": [
        'Watchtower element',
        'Wizard hunter'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 99: You Had Your Chance
    "You Had Your Chance": {
        "ap_id": 1629,
        "description": "Kill 260 banished monsters with shrines.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 100: You Shall Not Pass
    "You Shall Not Pass": {
        "ap_id": 1630,
        "description": "Don't let any monster touch your orb for 240 beaten waves.",
        "requirements": [
        'minWave: 240'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Extreme",
    },
    # ID 101: You're Safe With Me
    "You're Safe With Me": {
        "ap_id": 1631,
        "description": "Win a battle with at least 10 orblets remaining.",
        "requirements": [
        'Orb of Presence skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 102: Your Mana is Mine
    "Your Mana is Mine": {
        "ap_id": 1632,
        "description": "Leech 10.000 mana with gems.",
        "requirements": [
        'Mana Leech skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 103: Zap Away
    "Zap Away": {
        "ap_id": 1633,
        "description": "Cast 175 strike spells.",
        "requirements": [
        'Freeze skill|Whiteout skill|Ice Shards skill'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Extreme",
    },
    # ID 104: Zapped
    "Zapped": {
        "ap_id": 1634,
        "description": "Get your Orb destroyed by a wizard tower.",
        "requirements": [
        'Wizard Tower element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 105: Zigzag Corridor
    "Zigzag Corridor": {
        "ap_id": 1635,
        "description": "Build 60 walls.",
        "requirements": [
        'Wall element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
}

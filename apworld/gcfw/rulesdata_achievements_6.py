"""
GemCraft Frostborn Wrath — Achievement Pack 6

Contains approximately 106 achievements.
Each achievement has a "grindiness" property ("Trivial", "Minor", "Major", "Extreme") for easy adjustment.
"""

achievement_requirements = {
    # ID 0: Super Gem
    "Super Gem": {
        "description": "Create a grade 3 gem with 300 effective max damage.",
        "requirements": [
        'minGemGrade: 3'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 1: Supply Line Cut
    "Supply Line Cut": {
        "description": "Kill a swarm queen with a barrage shell.",
        "requirements": [
        'Barrage skill',
        'Swarm Queen element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 2: Swarmling Season
    "Swarmling Season": {
        "description": "Kill 999 swarmlings.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 3: Swift Death
    "Swift Death": {
        "description": "Kill the gatekeeper with a bolt.",
        "requirements": [
        'Bolt skill',
        'Gatekeeper element',
        'Field A4'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 4: Swift Deployment
    "Swift Deployment": {
        "description": "Have 20 gems on the battlefield before wave 5.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 5: Take Them I Have More
    "Take Them I Have More": {
        "description": "Have 12 of your gems destroyed or stolen.",
        "requirements": [
        'Ritual trait',
        'Specter element',
        'Watchtower element'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 6: Takers
    "Takers": {
        "description": "Gain 1.600 mana from drops.",
        "requirements": [
        'Apparition element',
        'Corrupted Mana Shard element',
        'Drop Holder element',
        'Mana Shard element'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 7: Tapped Essence
    "Tapped Essence": {
        "description": "Leech 1.500 mana from bleeding monsters.",
        "requirements": [
        'Bleeding skill',
        'Mana Leech skill'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 8: Targeting Weak Points
    "Targeting Weak Points": {
        "description": "Win a battle using only critical hit gems.",
        "requirements": [
        'Critical Hit skill'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 9: Taste All The Affixes
    "Taste All The Affixes": {
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
        "grindiness": "Extreme",
    },
    # ID 10: Tasting the Darkness
    "Tasting the Darkness": {
        "description": "Break 3 tombs open.",
        "requirements": [
        'Tomb element'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 11: Teleport Lag
    "Teleport Lag": {
        "description": "Banish a monster at least 5 times.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 12: Ten Angry Waves
    "Ten Angry Waves": {
        "description": "Enrage 10 waves.",
        "requirements": [
        'minWave: 10'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 13: That Was Rude
    "That Was Rude": {
        "description": "Lose a gem with more than 1.000 hits to a watchtower.",
        "requirements": [
        'Watchtower element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 14: That Was Your Last Move
    "That Was Your Last Move": {
        "description": "Kill a wizard hunter while it's attacking one of your buildi...",
        "requirements": [
        'Wizard Hunter'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 15: That one!
    "That one!": {
        "description": "Select a monster.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 16: The Gathering
    "The Gathering": {
        "description": "Summon 500 monsters by enraging waves.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 17: The Horror
    "The Horror": {
        "description": "Lose 3.333 mana to shadows.",
        "requirements": [
        'Ritual trait',
        'Shadow element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 18: The Killing Will Never Stop
    "The Killing Will Never Stop": {
        "description": "Reach 200.000 monsters killed through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 19: The Mana Reaper
    "The Mana Reaper": {
        "description": "Reach 100.000 mana harvested from shards through all the bat...",
        "requirements": [
        'Mana Shard element'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 20: The Messenger Must Die
    "The Messenger Must Die": {
        "description": "Kill a shadow.",
        "requirements": [
        'Ritual trait',
        'Shadow element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 21: The Peeler
    "The Peeler": {
        "description": "Create a grade 12 pure armor tearing gem.",
        "requirements": [
        'Armor Tearing skill',
        'minGemGrade: 12'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 22: The Price of Obsession
    "The Price of Obsession": {
        "description": "Kill 590 banished monsters.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 23: There it is!
    "There it is!": {
        "description": "Select a building.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 24: There's No Time
    "There's No Time": {
        "description": "Call 140 waves early.",
        "requirements": [
        'minWave: 140'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 25: They Are Millions
    "They Are Millions": {
        "description": "Reach 1.000.000 monsters killed through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 26: They Are Still Here
    "They Are Still Here": {
        "description": "Kill 2 apparitions.",
        "requirements": [
        'Ritual trait',
        'Apparition element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 27: They Keep Coming
    "They Keep Coming": {
        "description": "Kill 12.000 monsters.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 28: Thin Ice
    "Thin Ice": {
        "description": "Kill 20 frozen monsters with gems in traps.",
        "requirements": [
        'Freeze skill',
        'Traps skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 29: Thin Them Out
    "Thin Them Out": {
        "description": "Have the Strength in Numbers trait set to level 6 or higher ...",
        "requirements": [
        'Strength in Numbers trait'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 30: Third Grade
    "Third Grade": {
        "description": "Create a grade 3 gem.",
        "requirements": [
        'minGemGrade: 3'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 31: Thorned Sphere
    "Thorned Sphere": {
        "description": "Deliver 400 banishments with your orb.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 32: Through All Layers
    "Through All Layers": {
        "description": "Kill a monster having at least 200 armor.",
        "requirements": [
        'A monster with atleast 200 armor'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 33: Thunderstruck
    "Thunderstruck": {
        "description": "Kill 120 monsters with gem bombs and wasps.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 34: Tightly Secured
    "Tightly Secured": {
        "description": "Don't let any monster touch your orb for 60 beaten waves.",
        "requirements": [
        'minWave: 60'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 35: Time Bent
    "Time Bent": {
        "description": "Have 90 monsters slowed at the same time.",
        "requirements": [
        'Slowing skill'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 36: Time to Rise
    "Time to Rise": {
        "description": "Have the Awakening trait set to level 6 or higher and win th...",
        "requirements": [
        'Awakening trait'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 37: Time to Upgrade
    "Time to Upgrade": {
        "description": "Have a grade 1 gem with 4.500 hits.",
        "requirements": [
        'minGemGrade: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 38: Tiny but Deadly
    "Tiny but Deadly": {
        "description": "Reach 50.000 gem wasp kills through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 39: To the Last Drop
    "To the Last Drop": {
        "description": "Leech 4.700 mana from poisoned monsters.",
        "requirements": [
        'Mana Leech skill',
        'Poison skill'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 40: Tomb No Matter What
    "Tomb No Matter What": {
        "description": "Open a tomb while there is a spire on the battlefield.",
        "requirements": [
        'Ritual trait',
        'Spire element',
        'Tomb element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 41: Tomb Raiding
    "Tomb Raiding": {
        "description": "Break a tomb open before wave 15.",
        "requirements": [
        'Tomb element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 42: Tomb Stomping
    "Tomb Stomping": {
        "description": "Break 4 tombs open.",
        "requirements": [
        'Tomb element'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 43: Too Curious
    "Too Curious": {
        "description": "Break 2 tombs open.",
        "requirements": [
        'Tomb element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 44: Too Easy
    "Too Easy": {
        "description": "Win a Trial battle with at least 3 waves enraged.",
        "requirements": [
        'minWave: 3',
        'Trial'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 45: Too Long to Hold Your Breath
    "Too Long to Hold Your Breath": {
        "description": "Beat 90 waves using only poison gems.",
        "requirements": [
        'Poison skill',
        'minWave: 90'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 46: Towerful
    "Towerful": {
        "description": "Build 5 towers.",
        "requirements": [
        'Tower element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 47: Trapland
    "Trapland": {
        "description": "And it's bloody too",
        "requirements": [
        'Traps skill',
        'Complete a level using only traps and no poison gems'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 48: Trembling
    "Trembling": {
        "description": "Kill 1.500 monsters with gems in traps.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 49: Tricolor
    "Tricolor": {
        "description": "Create a gem of 3 components.",
        "requirements": [
        'gemCount: 3'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 50: Troll's Eye
    "Troll's Eye": {
        "description": "Kill a giant with one shot.",
        "requirements": [
        'Bolt skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 51: Tumbling Billows
    "Tumbling Billows": {
        "description": "Have the Swarmling Domination trait set to level 6 or higher...",
        "requirements": [
        'Swarmling Domination trait'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 52: Twice the Blast
    "Twice the Blast": {
        "description": "Have 2 barrage enhanced gems at the same time.",
        "requirements": [
        'Barrage skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 53: Twice the Shock
    "Twice the Shock": {
        "description": "Hit the same monster 2 times with shrines.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 54: Twice the Steepness
    "Twice the Steepness": {
        "description": "Kill 170 monsters while there are at least 2 wraiths in the ...",
        "requirements": [
        'Ritual trait',
        'Wraith element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 55: Twice the Terror
    "Twice the Terror": {
        "description": "Kill 2 shadows.",
        "requirements": [
        'Ritual trait',
        'Shadow element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 56: Unarmed
    "Unarmed": {
        "description": "Have no gems when wave 20 starts.",
        "requirements": [
        'minWave: 20'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 57: Under Pressure
    "Under Pressure": {
        "description": "Shoot down 340 shadow projectiles.",
        "requirements": [
        'Ritual trait',
        'Shadow element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 58: Unending Flow
    "Unending Flow": {
        "description": "Kill 24.000 monsters.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 59: Unholy Stack
    "Unholy Stack": {
        "description": "Reach 20.000 monsters with special properties killed through...",
        "requirements": [
        'Possessed Monster element',
        'Twisted Monster element',
        'Marked Monster element'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 60: Uninvited
    "Uninvited": {
        "description": "Summon 100 monsters by enraging waves.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 61: Unsupportive
    "Unsupportive": {
        "description": "Reach 100 beacons destroyed through all the battles.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 62: Uraj and Khalis
    "Uraj and Khalis": {
        "description": "Activate the lanterns",
        "requirements": [
        'Lanterns skill',
        'Field H3'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 63: Urban Warfare
    "Urban Warfare": {
        "description": "Destroy a dwelling and kill a monster with one gem bomb.",
        "requirements": [
        'Abandoned Dwelling element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 64: Vantage Point Down
    "Vantage Point Down": {
        "description": "Demolish a pylon.",
        "requirements": [
        'Pylons skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 65: Versatile Charm
    "Versatile Charm": {
        "description": "Have at least 10 different talisman properties.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 66: Violet Ray
    "Violet Ray": {
        "description": "Kill 20 frozen monsters with beam.",
        "requirements": [
        'Beam skill',
        'Freeze skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 67: Warming Up
    "Warming Up": {
        "description": "Have a grade 1 gem with 100 hits.",
        "requirements": [
        'minGemGrade: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 68: Wash Away
    "Wash Away": {
        "description": "Kill 110 monsters while it's raining.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 69: Wasp Defense
    "Wasp Defense": {
        "description": "Smash 3 jars of wasps before wave 3.",
        "requirements": [
        'Field X2'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 70: Wasp Storm
    "Wasp Storm": {
        "description": "Kill 360 monsters with gem bombs and wasps.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 71: Waspocalypse
    "Waspocalypse": {
        "description": "Kill 1.080 monsters with gem bombs and wasps.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 72: Watch Your Step
    "Watch Your Step": {
        "description": "Build 40 traps.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 73: Wave Pecking
    "Wave Pecking": {
        "description": "Summon 20 monsters by enraging waves.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 74: Wave Smasher
    "Wave Smasher": {
        "description": "Reach 10.000 waves beaten through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 75: Waves for Breakfast
    "Waves for Breakfast": {
        "description": "Reach 2.000 waves beaten through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 76: Wavy
    "Wavy": {
        "description": "Reach 500 waves beaten through all the battles.",
        "requirements": [
        'minWave: 500'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 77: We Just Wanna Be Free
    "We Just Wanna Be Free": {
        "description": "More than blue triangles",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 78: Weakened Wallet
    "Weakened Wallet": {
        "description": "Leech 5.400 mana from whited out monsters.",
        "requirements": [
        'Mana Leech skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 79: Weather Tower
    "Weather Tower": {
        "description": "Activate a shrine while raining.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 80: Weather of Wasps
    "Weather of Wasps": {
        "description": "Deal 3950 gem wasp stings to creatures.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 81: Well Defended
    "Well Defended": {
        "description": "Don't let any monster touch your orb for 20 beaten waves.",
        "requirements": [
        'minWave:20'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 82: Well Earned
    "Well Earned": {
        "description": "Reach 500 battles won.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 83: Well Laid
    "Well Laid": {
        "description": "Have 10 gems on the battlefield.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 84: Well Prepared
    "Well Prepared": {
        "description": "Have 20.000 initial mana.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 85: Well Trained for This
    "Well Trained for This": {
        "description": "Kill a wraith with a shot fired by a gem having at least 1.0...",
        "requirements": [
        'Ritual trait',
        'Wraith element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 86: Whacked
    "Whacked": {
        "description": "Kill a specter with one hit.",
        "requirements": [
        'Ritual trait',
        'Specter element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 87: What Are You Waiting For?
    "What Are You Waiting For?": {
        "description": "Have all spells charged to 200%.",
        "requirements": [
        'Freeze skill',
        'Whiteout skill',
        'Ice Shards skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 88: White Ray
    "White Ray": {
        "description": "Kill 90 frozen monsters with beam.",
        "requirements": [
        'Beam skill',
        'Freeze skill'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 89: White Ring of Death
    "White Ring of Death": {
        "description": "Gain 4.900 xp with Ice Shards spell crowd hits.",
        "requirements": [
        'Ice Shards skill'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 90: White Wand
    "White Wand": {
        "description": "Reach wizard level 10.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 91: Why Not
    "Why Not": {
        "description": "Enhance a gem in the enraging socket.",
        "requirements": [
        'enhancementSpells: 3'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 92: Wicked Gem
    "Wicked Gem": {
        "description": "Have a grade 3 gem with 900 effective max damage.",
        "requirements": [
        'minGemGrade: 3'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 93: Wings and Tentacles
    "Wings and Tentacles": {
        "description": "Reach 200 non-monsters killed through all the battles.",
        "requirements": [
        'Ritual trait'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 94: Worst of Both Sizes
    "Worst of Both Sizes": {
        "description": "Beat 300 waves on max Swarmling and Giant domination traits.",
        "requirements": [
        'Swarmling Domination trait',
        'Giant Domination trait',
        'minWave: 300',
        'Endurance'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 95: Worthy
    "Worthy": {
        "description": "Have 70 fields lit in Trial mode.",
        "requirements": [
        'Trial'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 96: Xp Harvest
    "Xp Harvest": {
        "description": "Have 40 fields lit in Endurance mode.",
        "requirements": [
        'Endurance'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 97: Yellow Wand
    "Yellow Wand": {
        "description": "Reach wizard level 20.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 98: You Could Be my Apprentice
    "You Could Be my Apprentice": {
        "description": "Have a watchtower kill a wizard hunter.",
        "requirements": [
        'Watchtower element',
        'Wizard hunter'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 99: You Had Your Chance
    "You Had Your Chance": {
        "description": "Kill 260 banished monsters with shrines.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 100: You Shall Not Pass
    "You Shall Not Pass": {
        "description": "Don't let any monster touch your orb for 240 beaten waves.",
        "requirements": [
        'minWave: 240'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 101: You're Safe With Me
    "You're Safe With Me": {
        "description": "Win a battle with at least 10 orblets remaining.",
        "requirements": [
        'Orb of Presence skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 102: Your Mana is Mine
    "Your Mana is Mine": {
        "description": "Leech 10.000 mana with gems.",
        "requirements": [
        'Mana Leech skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 103: Zap Away
    "Zap Away": {
        "description": "Cast 175 strike spells.",
        "requirements": [
        'Freeze skill|Whiteout skill|Ice Shards skill'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 104: Zapped
    "Zapped": {
        "description": "Get your Orb destroyed by a wizard tower.",
        "requirements": [
        'Wizard Tower element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 105: Zigzag Corridor
    "Zigzag Corridor": {
        "description": "Build 60 walls.",
        "requirements": [
        'Wall element'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
}

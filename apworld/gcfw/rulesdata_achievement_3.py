"""
GemCraft Frostborn Wrath — Grindiness Level 3 Achievements

Contains 84 achievements at grindiness level 3.
Organized by achievement ID for easy reference.
"""

achievement_requirements = {
    # ID 8: Forged in Battle
    "Forged in Battle": {
        "description": "Reach 200 battles won.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 12: Getting Waves Done
    "Getting Waves Done": {
        "description": "Reach 2.000 waves started early through all the battles.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 16: Waves for Breakfast
    "Waves for Breakfast": {
        "description": "Reach 2.000 waves beaten through all the battles.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 25: Mighty
    "Mighty": {
        "description": "Create a gem with a raw minimum damage of 3.000 or higher.",
        "requirements": ["gemCount: 1"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 41: Hyper Gem
    "Hyper Gem": {
        "description": "Have a grade 3 gem with 600 effective max damage.",
        "requirements": ["minGemGrade: 3"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 45: Adept Grade
    "Adept Grade": {
        "description": "Create a grade 8 gem.",
        "requirements": ["minGemGrade: 8"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 53: Getting Serious
    "Getting Serious": {
        "description": "Have a grade 1 gem with 1.500 hits.",
        "requirements": ["minGemGrade: 1"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 61: Hacked Gem
    "Hacked Gem": {
        "description": "Have a grade 3 gem with 1.200 effective max damage.",
        "requirements": ["minGemGrade: 3"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 62: Denested
    "Denested": {
        "description": "Destroy 5 monster nests.",
        "requirements": ["Monster Nest element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 63: Tomb Stomping
    "Tomb Stomping": {
        "description": "Break 4 tombs open.",
        "requirements": ["Tomb element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 68: Fortress
    "Fortress": {
        "description": "Build 30 towers.",
        "requirements": ["Tower element"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 69: Brickery
    "Brickery": {
        "description": "Reach 1.000 structures built through all the battles.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 73: Watch Your Step
    "Watch Your Step": {
        "description": "Build 40 traps.",
        "requirements": ["Traps skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 77: Power Exchange
    "Power Exchange": {
        "description": "Build 25 amplifiers.",
        "requirements": ["Amplifiers skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 81: Zigzag Corridor
    "Zigzag Corridor": {
        "description": "Build 60 walls.",
        "requirements": ["Wall element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 83: Frittata
    "Frittata": {
        "description": "Reach 500 monster eggs cracked through all the battles.",
        "requirements": ["Swarm Queen element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 107: Shard Siphon
    "Shard Siphon": {
        "description": "Reach 20.000 mana harvested from shards through all the batt...",
        "requirements": ["Mana Shard element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 120: The Killing Will Never Stop
    "The Killing Will Never Stop": {
        "description": "Reach 200.000 monsters killed through all the battles.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 129: Minefield
    "Minefield": {
        "description": "Kill 300 monsters with gems in traps.",
        "requirements": ["Traps skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 133: Snowdust Blindness
    "Snowdust Blindness": {
        "description": "Gain 2.300 xp with Whiteout spell crowd hits.",
        "requirements": ["Whiteout skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 134: Wasp Storm
    "Wasp Storm": {
        "description": "Kill 360 monsters with gem bombs and wasps.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 139: Wings and Tentacles
    "Wings and Tentacles": {
        "description": "Reach 200 non-monsters killed through all the battles.",
        "requirements": ["Ritual trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 144: Swarmling Season
    "Swarmling Season": {
        "description": "Kill 999 swarmlings.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 151: Still Chill
    "Still Chill": {
        "description": "Gain 1.500 xp with Freeze spell crowd hits.",
        "requirements": ["Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 154: Drone Warfare
    "Drone Warfare": {
        "description": "Reach 20.000 gem wasp kills through all the battles.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 157: Can't Stop
    "Can't Stop": {
        "description": "Reach a kill chain of 900.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 173: Not Chasing Shadows Anymore
    "Not Chasing Shadows Anymore": {
        "description": "Kill 4 shadows.",
        "requirements": ["Ritual trait", "Shadow element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 186: Unholy Stack
    "Unholy Stack": {
        "description": "Reach 20.000 monsters with special properties killed through...",
        "requirements": ["Possessed Monster element", "Twisted Monster element", "Marked Monster element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 196: Icepicked
    "Icepicked": {
        "description": "Gain 3.200 xp with Ice Shards spell crowd hits.",
        "requirements": ["Ice Shards skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 212: Lagging Already?
    "Lagging Already?": {
        "description": "Have 900 monsters on the battlefield at the same time.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 220: Sting Stack
    "Sting Stack": {
        "description": "Deal 1.000 gem wasp stings to buildings.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 222: Bouncy Zap
    "Bouncy Zap": {
        "description": "Reach 2.000 pylon kills through all the battles.",
        "requirements": ["Pylons skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 228: Power Overwhelming
    "Power Overwhelming": {
        "description": "Reach mana pool level 15.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 229: Mana in a Bottle
    "Mana in a Bottle": {
        "description": "Have 40.000 initial mana.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 247: Puncture Therapy
    "Puncture Therapy": {
        "description": "Deal 950 gem wasp stings to creatures.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 253: Desperate Clash
    "Desperate Clash": {
        "description": "Reach -16% decreased banishment cost with your orb.",
        "requirements": ["Amplifiers skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 256: Barbed Sphere
    "Barbed Sphere": {
        "description": "Deliver 1.200 banishments with your orb.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 262: It's a Trap
    "It's a Trap": {
        "description": "Don't let any monster touch your orb for 120 beaten waves.",
        "requirements": ["minWave: 120"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 268: Takers
    "Takers": {
        "description": "Gain 1.600 mana from drops.",
        "requirements": ["Apparition element", "Corrupted Mana Shard element", "Drop Holder element", "Mana Shard element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 272: Chainsaw
    "Chainsaw": {
        "description": "Gain 3.200 xp with kill chains.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 273: Shattered Waves
    "Shattered Waves": {
        "description": "Hit 225 frozen monsters with shrines.",
        "requirements": ["Freeze skill", "Shrine element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 296: Laser Slicer
    "Laser Slicer": {
        "description": "Have 8 beam enhanced gems at the same time.",
        "requirements": ["Beam skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 305: Beacons Be Gone
    "Beacons Be Gone": {
        "description": "Reach 500 beacons destroyed through all the battles.",
        "requirements": ["Beacon element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 307: Deadly Curse
    "Deadly Curse": {
        "description": "Reach 5.000 poison kills through all the battles.",
        "requirements": ["Poison skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 317: Morning March
    "Morning March": {
        "description": "Lure 500 swarmlings out of a sleeping hive.",
        "requirements": ["Sleeping Hive element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 325: Agitated
    "Agitated": {
        "description": "Call 70 waves early.",
        "requirements": ["minWave: 70"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 333: The Gathering
    "The Gathering": {
        "description": "Summon 500 monsters by enraging waves.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 337: Raging Habit
    "Raging Habit": {
        "description": "Enrage 80 waves.",
        "requirements": ["minWave: 80"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 339: Impenetrable
    "Impenetrable": {
        "description": "Have 8 bolt enhanced gems at the same time.",
        "requirements": ["Bolt skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 348: Core Haul
    "Core Haul": {
        "description": "Find 180 shadow cores.",
        "requirements": ["Shadow Core element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 358: Frag Rain
    "Frag Rain": {
        "description": "Find 5 talisman fragments.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 362: Stockpile
    "Stockpile": {
        "description": "Have 30 fragments in your talisman inventory.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 386: Blue Wand
    "Blue Wand": {
        "description": "Reach wizard level 100.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 403: Fully Shining
    "Fully Shining": {
        "description": "Have 60 gems on the battlefield.",
        "requirements": ["gemCount: 60"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 405: Lost Signal
    "Lost Signal": {
        "description": "Destroy 35 beacons.",
        "requirements": ["Beacon element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 406: One by One
    "One by One": {
        "description": "Deliver 750 one hit kills.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 410: At my Fingertips
    "At my Fingertips": {
        "description": "Cast 75 strike spells.",
        "requirements": ["Ice Shards skill", "Whiteout skill", "Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 422: How About Some Skill Points
    "How About Some Skill Points": {
        "description": "Have 5.000 shadow cores at the start of the battle.",
        "requirements": ["Shadow Core element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 426: Shell Shock
    "Shell Shock": {
        "description": "Have 8 barrage enhanced gems at the same time.",
        "requirements": ["Barrage skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 430: They Keep Coming
    "They Keep Coming": {
        "description": "Kill 12.000 monsters.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 432: Don't Look at the Light
    "Don't Look at the Light": {
        "description": "Reach 10.000 shrine kills through all the battles.",
        "requirements": ["Shrine element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 436: Ice Mage
    "Ice Mage": {
        "description": "Reach 2.500 strike spells cast through all the battles.",
        "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 440: Enhance Like No Tomorrow
    "Enhance Like No Tomorrow": {
        "description": "Reach 2.500 enhancement spells cast through all the battles.",
        "requirements": ["Bolt skill", "Beam skill", "Barrage skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 444: Drop the Ice
    "Drop the Ice": {
        "description": "Reach 50.000 strike spell hits through all the battles.",
        "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 449: Painful Leech
    "Painful Leech": {
        "description": "Leech 3.200 mana from bleeding monsters.",
        "requirements": ["Bleeding skill", "Mana Leech skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 453: Mana of the Dying
    "Mana of the Dying": {
        "description": "Leech 2.300 mana from poisoned monsters.",
        "requirements": ["Mana Leech skill", "Poison skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 457: Bleed Out
    "Bleed Out": {
        "description": "Kill 480 bleeding monsters.",
        "requirements": ["Bleeding skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 486: Take Them I Have More
    "Take Them I Have More": {
        "description": "Have 12 of your gems destroyed or stolen.",
        "requirements": ["Ritual trait", "Specter element", "Watchtower element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 505: Quite a List
    "Quite a List": {
        "description": "Have at least 15 different talisman properties.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 511: Light My Path
    "Light My Path": {
        "description": "Have 70 fields lit in Journey mode.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 515: Longrunner
    "Longrunner": {
        "description": "Have 60 fields lit in Endurance mode.",
        "requirements": ["Endurance"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 519: Expert
    "Expert": {
        "description": "Have 50 fields lit in Trial mode.",
        "requirements": ["Trial"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 534: Hunt For Hard Targets
    "Hunt For Hard Targets": {
        "description": "Kill 680 monsters while there are at least 2 wraiths in the ...",
        "requirements": ["Ritual trait", "Wraith element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 539: Multinerf
    "Multinerf": {
        "description": "Kill 1.600 monsters with prismatic gem wasps.",
        "requirements": ["Mana Leech skill", "Critical Hit skill", "Bleeding skill", "Armor Tearing skill", "Poison skill", "Slowing skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 547: And Don't Come Back
    "And Don't Come Back": {
        "description": "Kill 460 banished monsters with shrines.",
        "requirements": ["Shrine element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 551: The Price of Obsession
    "The Price of Obsession": {
        "description": "Kill 590 banished monsters.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 567: Corrosive Stings
    "Corrosive Stings": {
        "description": "Tear a total of 5.000 armor with wasp stings.",
        "requirements": ["Armor Tearing skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 571: It Has to Do
    "It Has to Do": {
        "description": "Beat 50 waves using at most grade 2 gems.",
        "requirements": ["minWave: 50"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 587: Weakened Wallet
    "Weakened Wallet": {
        "description": "Leech 5.400 mana from whited out monsters.",
        "requirements": ["Mana Leech skill", "Whiteout skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 591: Shardalot
    "Shardalot": {
        "description": "Cast 6 ice shards on the same monster.",
        "requirements": ["Ice Shards skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 599: Hungry Little Gem
    "Hungry Little Gem": {
        "description": "Leech 3.600 mana with a grade 1 gem.",
        "requirements": ["Mana Leech skill", "minGemGrade: 1"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 608: Chlorophyll
    "Chlorophyll": {
        "description": "Kill 4.500 green blooded monsters.",
        "requirements": ["Requires \"hidden codes\""],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 612: Liquid Explosive
    "Liquid Explosive": {
        "description": "Kill 180 monsters with orblet explosions.",
        "requirements": ["Orb of Presence skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 633: Half Full
    "Half Full": {
        "description": "Add 32 talisman fragments to your shape collection.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
}

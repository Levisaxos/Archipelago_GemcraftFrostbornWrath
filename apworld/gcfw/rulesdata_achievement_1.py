"""
GemCraft Frostborn Wrath — Grindiness Level 1 Achievements

Contains 362 achievements at grindiness level 1.
Organized by achievement ID for easy reference.
"""

achievement_requirements = {
    # ID 0: Dichromatic
    "Dichromatic": {
        "description": "Combine two gems of different colors.",
        "requirements": ["gemCount: 2"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 1: Mana Salvation
    "Mana Salvation": {
        "description": "Salvage mana by destroying a gem.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 2: Zapped
    "Zapped": {
        "description": "Get your Orb destroyed by a wizard tower.",
        "requirements": ["Wizard Tower element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 3: A Shrubbery!
    "A Shrubbery!": {
        "description": "Place a shrub wall.",
        "requirements": ["Wall element"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 4: Route Planning
    "Route Planning": {
        "description": "Destroy 5 barricades.",
        "requirements": ["Barricade element"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 5: What Are You Waiting For?
    "What Are You Waiting For?": {
        "description": "Have all spells charged to 200%.",
        "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 6: Just Started
    "Just Started": {
        "description": "Reach 10 battles won.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 10: Early Bird
    "Early Bird": {
        "description": "Reach 500 waves started early through all the battles.",
        "requirements": ["minWave: 500"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 14: Wavy
    "Wavy": {
        "description": "Reach 500 waves beaten through all the battles.",
        "requirements": ["minWave: 500"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 18: Century Egg
    "Century Egg": {
        "description": "Reach 100 monster eggs cracked through all the battles.",
        "requirements": ["Swarm Queen element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 19: Slowly but Surely
    "Slowly but Surely": {
        "description": "Beat 90 waves using only slowing gems.",
        "requirements": ["Slowing skill", "minWave: 90"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 20: Too Long to Hold Your Breath
    "Too Long to Hold Your Breath": {
        "description": "Beat 90 waves using only poison gems.",
        "requirements": ["Poison skill", "minWave: 90"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 21: Biohazard
    "Biohazard": {
        "description": "Create a grade 12 pure poison gem.",
        "requirements": ["Poison skill", "minGemGrade: 12"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 22: No Armor Area
    "No Armor Area": {
        "description": "Beat 90 waves using only armor tearing gems.",
        "requirements": ["Armor Tearing skill", "minWave: 90"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 23: The Peeler
    "The Peeler": {
        "description": "Create a grade 12 pure armor tearing gem.",
        "requirements": ["Armor Tearing skill", "minGemGrade: 12"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 24: Powerful
    "Powerful": {
        "description": "Create a gem with a raw minimum damage of 300 or higher.",
        "requirements": ["gemCount: 1"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 27: Tricolor
    "Tricolor": {
        "description": "Create a gem of 3 components.",
        "requirements": ["gemCount: 3"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 28: Bloodrush
    "Bloodrush": {
        "description": "Call an enraged wave early.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 30: Mana Magnet
    "Mana Magnet": {
        "description": "Win a battle using only mana leeching gems.",
        "requirements": ["Mana Leech skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 31: Targeting Weak Points
    "Targeting Weak Points": {
        "description": "Win a battle using only critical hit gems.",
        "requirements": ["Critical Hit skill"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 32: Shooting Where it Hurts
    "Shooting Where it Hurts": {
        "description": "Beat 90 waves using only critical hit gems.",
        "requirements": ["Critical Hit skill", "minWave: 90"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 33: All Your Mana Belongs to Us
    "All Your Mana Belongs to Us": {
        "description": "Beat 90 waves using only mana leeching gems.",
        "requirements": ["Mana Leech skill", "minWave: 90"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 34: Nox Mist
    "Nox Mist": {
        "description": "Win a battle using only poison gems.",
        "requirements": ["Poison skill"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 35: Blood Clot
    "Blood Clot": {
        "description": "Beat 90 waves using only bleeding gems.",
        "requirements": ["Bleeding skill", "minWave: 90"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 36: Blood Magic
    "Blood Magic": {
        "description": "Win a battle using only bleeding gems.",
        "requirements": ["Bleeding skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 37: Long Crawl
    "Long Crawl": {
        "description": "Win a battle using only slowing gems.",
        "requirements": ["Slowing skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 38: Shavings All Around
    "Shavings All Around": {
        "description": "Win a battle using only armor tearing gems.",
        "requirements": ["Armor Tearing skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 39: Eagle Eye
    "Eagle Eye": {
        "description": "Reach an amplified gem range of 18.",
        "requirements": ["Amplifiers skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 40: Super Gem
    "Super Gem": {
        "description": "Create a grade 3 gem with 300 effective max damage.",
        "requirements": ["minGemGrade: 3"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 43: Third Grade
    "Third Grade": {
        "description": "Create a grade 3 gem.",
        "requirements": ["minGemGrade: 3"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 48: Pat on the Back
    "Pat on the Back": {
        "description": "Amplify a gem.",
        "requirements": ["Amplifiers skill"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 49: In Focus
    "In Focus": {
        "description": "Amplify a gem with 8 other gems.",
        "requirements": ["Amplifiers skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 50: Catalyst
    "Catalyst": {
        "description": "Give a Gem 200 Poison Damage by Amplification.",
        "requirements": ["Amplifiers skill", "Poison skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 51: Warming Up
    "Warming Up": {
        "description": "Have a grade 1 gem with 100 hits.",
        "requirements": ["minGemGrade: 1"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 54: Jewel Box
    "Jewel Box": {
        "description": "Fill all inventory slots with gems.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 55: Well Laid
    "Well Laid": {
        "description": "Have 10 gems on the battlefield.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 56: Swift Deployment
    "Swift Deployment": {
        "description": "Have 20 gems on the battlefield before wave 5.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 59: Connected
    "Connected": {
        "description": "Build an amplifier.",
        "requirements": ["Amplifiers skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 64: Build Along
    "Build Along": {
        "description": "Reach 200 structures built through all the battles.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 66: Towerful
    "Towerful": {
        "description": "Build 5 towers.",
        "requirements": ["Tower element"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 71: Sparse Snares
    "Sparse Snares": {
        "description": "Build 10 traps.",
        "requirements": ["Traps skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 75: Power Sharing
    "Power Sharing": {
        "description": "Build 5 amplifiers.",
        "requirements": ["Amplifiers skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 79: Minor Detour
    "Minor Detour": {
        "description": "Build 15 walls.",
        "requirements": ["Wall element"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 82: Too Curious
    "Too Curious": {
        "description": "Break 2 tombs open.",
        "requirements": ["Tomb element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 85: Stones to Dust
    "Stones to Dust": {
        "description": "Demolish one of your structures.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 86: Juggler
    "Juggler": {
        "description": "Use demolition 7 times.",
        "requirements": ["Demolition skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 87: Is Anyone in There?
    "Is Anyone in There?": {
        "description": "Break a tomb open.",
        "requirements": ["Tomb element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 89: Tomb Raiding
    "Tomb Raiding": {
        "description": "Break a tomb open before wave 15.",
        "requirements": ["Tomb element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 90: Fire in the Hole
    "Fire in the Hole": {
        "description": "Destroy a monster nest.",
        "requirements": ["Monster Nest element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 91: Root Canal
    "Root Canal": {
        "description": "Destroy 2 monster nests.",
        "requirements": ["Monster Nest element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 93: Nest Blaster
    "Nest Blaster": {
        "description": "Destroy 2 monster nests before wave 12.",
        "requirements": ["Monster Nest element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 94: Blackout
    "Blackout": {
        "description": "Destroy a beacon.",
        "requirements": ["Beacon element"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 95: Popping Lights
    "Popping Lights": {
        "description": "Destroy 5 beacons.",
        "requirements": ["Beacon element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 96: Broken Siege
    "Broken Siege": {
        "description": "Destroy 8 beacons before wave 8.",
        "requirements": ["Beacon element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 97: Still Lit
    "Still Lit": {
        "description": "Have 15 or more beacons standing at the end of the battle.",
        "requirements": ["Dark Masonry trait", "Beacon element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 98: Heavy Support
    "Heavy Support": {
        "description": "Have 20 beacons on the field at the same time.",
        "requirements": ["Dark Masonry trait", "Beacon element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 99: No Stone Unturned
    "No Stone Unturned": {
        "description": "Open 5 drop holders.",
        "requirements": ["Drop Holder element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 100: Hiding Spot
    "Hiding Spot": {
        "description": "Open 3 drop holders before wave 3.",
        "requirements": ["Drop Holder element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 101: It was Abandoned Anyway
    "It was Abandoned Anyway": {
        "description": "Destroy a dwelling.",
        "requirements": ["Abandoned Dwelling element"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 102: Ruined Ghost Town
    "Ruined Ghost Town": {
        "description": "Destroy 5 dwellings.",
        "requirements": ["Abandoned Dwelling element"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 103: Ages Old Memories
    "Ages Old Memories": {
        "description": "Unlock a wizard tower.",
        "requirements": ["Wizard Tower element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 104: Almost Ruined
    "Almost Ruined": {
        "description": "Leave a monster nest at 1 hit point at the end of the battle...",
        "requirements": ["Monster Nest element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 105: Resourceful
    "Resourceful": {
        "description": "Reach 5.000 mana harvested from shards through all the battl...",
        "requirements": ["Mana Shard element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 108: Not Worth It
    "Not Worth It": {
        "description": "Harvest 9.000 mana from a corrupted mana shard.",
        "requirements": ["Corrupted Mana Shard element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 109: Come Out
    "Come Out": {
        "description": "Lure 20 swarmlings out of a sleeping hive.",
        "requirements": ["Sleeping Hive element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 111: Precious
    "Precious": {
        "description": "Get a gem from a drop holder.",
        "requirements": ["Drop Holder element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 112: Dry Puddle
    "Dry Puddle": {
        "description": "Harvest all mana from a mana shard.",
        "requirements": ["Mana Shard element"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 113: Extorted
    "Extorted": {
        "description": "Harvest all mana from 3 mana shards.",
        "requirements": ["Mana Shard element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 116: Early Harvest
    "Early Harvest": {
        "description": "Harvest 2.500 mana from shards before wave 3 starts.",
        "requirements": ["Mana Shard element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 117: Need More Rage
    "Need More Rage": {
        "description": "Upgrade a gem in the enraging socket.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 118: Blood on my Hands
    "Blood on my Hands": {
        "description": "Reach 20.000 monsters killed through all the battles.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 121: Broken Seal
    "Broken Seal": {
        "description": "Free a sealed gem.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 122: First Blood
    "First Blood": {
        "description": "Kill a monster.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 123: Puncturing Shots
    "Puncturing Shots": {
        "description": "Deliver 75 one hit kills.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 126: Absolute Zero
    "Absolute Zero": {
        "description": "Kill 273 frozen monsters.",
        "requirements": ["Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 127: Ensnared
    "Ensnared": {
        "description": "Kill 12 monsters with gems in traps.",
        "requirements": ["Traps skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 130: From Above
    "From Above": {
        "description": "Kill 40 monsters with gem bombs and wasps.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 132: Getting Wet
    "Getting Wet": {
        "description": "Beat 30 waves.",
        "requirements": ["minWave: 30"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 137: Smoke in the Sky
    "Smoke in the Sky": {
        "description": "Reach 20 non-monsters killed through all the battles.",
        "requirements": ["Ritual trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 140: Pest Control
    "Pest Control": {
        "description": "Kill 333 swarmlings.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 142: Angry Wasps
    "Angry Wasps": {
        "description": "Reach 1.000 gem wasp kills through all the battles.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 146: Purged
    "Purged": {
        "description": "Kill 179 marked monsters.",
        "requirements": ["Marked Monster element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 147: Hint of Darkness
    "Hint of Darkness": {
        "description": "Kill 189 twisted monsters.",
        "requirements": ["Twisted Monster element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 148: Exorcism
    "Exorcism": {
        "description": "Kill 199 possessed monsters.",
        "requirements": ["Possessed Monster element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 150: Bone Shredder
    "Bone Shredder": {
        "description": "Kill 600 monsters before wave 12 starts.",
        "requirements": ["Atleast 600 monsters before wave 10"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 152: No Use of Vitality
    "No Use of Vitality": {
        "description": "Kill a monster having at least 20.000 hit points.",
        "requirements": ["A monster with atleast 20.000hp"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 153: Through All Layers
    "Through All Layers": {
        "description": "Kill a monster having at least 200 armor.",
        "requirements": ["A monster with atleast 200 armor"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 155: Lots of Scratches
    "Lots of Scratches": {
        "description": "Reach a kill chain of 300.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 158: Thin Ice
    "Thin Ice": {
        "description": "Kill 20 frozen monsters with gems in traps.",
        "requirements": ["Freeze skill", "Traps skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 159: Doom Drop
    "Doom Drop": {
        "description": "Kill a possessed giant with barrage.",
        "requirements": ["Barrage skill", "Possessed Monster element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 160: Out of Nowhere
    "Out of Nowhere": {
        "description": "Kill a whited out possessed monster with bolt.",
        "requirements": ["Bolt skill", "Whiteout skill", "Possessed Monster element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 162: Trapland
    "Trapland": {
        "description": "And it's bloody too",
        "requirements": ["Traps skill", "Complete a level using only traps and no poison gems"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 163: I Saw Something
    "I Saw Something": {
        "description": "Kill an apparition.",
        "requirements": ["Ritual trait", "Apparition element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 165: Charged for the Kill
    "Charged for the Kill": {
        "description": "Reach 200 pylon kills through all the battles.",
        "requirements": ["Pylons skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 167: They Are Still Here
    "They Are Still Here": {
        "description": "Kill 2 apparitions.",
        "requirements": ["Ritual trait", "Apparition element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 168: Don't Touch it!
    "Don't Touch it!": {
        "description": "Kill a specter.",
        "requirements": ["Ritual trait", "Specter element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 169: I Warned You...
    "I Warned You...": {
        "description": "Kill a specter while it carries a gem.",
        "requirements": ["Ritual trait", "Specter element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 170: Gem Lust
    "Gem Lust": {
        "description": "Kill 2 specters.",
        "requirements": ["Ritual trait", "Specter element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 171: The Messenger Must Die
    "The Messenger Must Die": {
        "description": "Kill a shadow.",
        "requirements": ["Ritual trait", "Shadow element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 172: Twice the Terror
    "Twice the Terror": {
        "description": "Kill 2 shadows.",
        "requirements": ["Ritual trait", "Shadow element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 174: Bye Bye Hideous
    "Bye Bye Hideous": {
        "description": "Kill a spire.",
        "requirements": ["Ritual trait", "Spire element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 175: Dual Downfall
    "Dual Downfall": {
        "description": "Kill 2 spires.",
        "requirements": ["Ritual trait", "Spire element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 176: Something Special
    "Something Special": {
        "description": "Reach 2.000 monsters with special properties killed through ...",
        "requirements": ["Possessed Monster element", "Twisted Monster element", "Marked Monster element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 177: Violet Ray
    "Violet Ray": {
        "description": "Kill 20 frozen monsters with beam.",
        "requirements": ["Beam skill", "Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 178: Snow Blower
    "Snow Blower": {
        "description": "Kill 20 frozen monsters with barrage.",
        "requirements": ["Barrage skill", "Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 179: Shattering
    "Shattering": {
        "description": "Kill 90 frozen monsters with bolt.",
        "requirements": ["Bolt skill", "Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 182: Jinx Blast
    "Jinx Blast": {
        "description": "Kill 30 whited out monsters with bolt.",
        "requirements": ["Bolt skill", "Whiteout skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 183: Blind Hit
    "Blind Hit": {
        "description": "Kill 30 whited out monsters with beam.",
        "requirements": ["Beam skill", "Whiteout skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 184: Can't Crawl Away
    "Can't Crawl Away": {
        "description": "Kill 30 whited out monsters with barrage.",
        "requirements": ["Barrage skill", "Whiteout skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 188: Avenged
    "Avenged": {
        "description": "Kill 15 monsters carrying orblets.",
        "requirements": ["Orb of Presence skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 189: Ice Stand
    "Ice Stand": {
        "description": "Kill 5 frozen monsters carrying orblets.",
        "requirements": ["Freeze skill", "Orb of Presence skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 190: Wash Away
    "Wash Away": {
        "description": "Kill 110 monsters while it's raining.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 191: Acid Rain
    "Acid Rain": {
        "description": "Kill 85 poisoned monsters while it's raining.",
        "requirements": ["Poison skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 192: Frozen Grave
    "Frozen Grave": {
        "description": "Kill 220 monsters while it's snowing.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 193: Snow Dust
    "Snow Dust": {
        "description": "Kill 95 frozen monsters while it's snowing.",
        "requirements": ["Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 194: Out of Misery
    "Out of Misery": {
        "description": "Kill a monster that is whited out, poisoned, frozen and slow...",
        "requirements": ["Freeze skill", "Poison skill", "Slowing skill", "Whiteout skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 195: Overheated
    "Overheated": {
        "description": "Kill a giant with beam shot.",
        "requirements": ["Beam skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 197: Almost
    "Almost": {
        "description": "Kill a monster with shots blinking to the monster attacking ...",
        "requirements": ["Watchtower element", "Wizard hunter"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 198: Like a Necro
    "Like a Necro": {
        "description": "Kill 25 monsters with frozen corpse explosion.",
        "requirements": ["Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 200: Hedgehog
    "Hedgehog": {
        "description": "Kill a swarmling having at least 100 armor.",
        "requirements": ["a swarmling with atleast 100 armor"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 202: Ful Ir
    "Ful Ir": {
        "description": "Blast like a fireball",
        "requirements": ["Kill 15 monsters simultaneously with 1 gem bomb"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 203: Stirring Up the Nest
    "Stirring Up the Nest": {
        "description": "Deliver gem bomb and wasp kills only.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 204: Green Vial
    "Green Vial": {
        "description": "Have more than 75% of the monster kills caused by poison.",
        "requirements": ["Poison skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 205: Troll's Eye
    "Troll's Eye": {
        "description": "Kill a giant with one shot.",
        "requirements": ["Bolt skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 206: Crunchy Bites
    "Crunchy Bites": {
        "description": "Kill 160 frozen swarmlings.",
        "requirements": ["Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 207: Time Bent
    "Time Bent": {
        "description": "Have 90 monsters slowed at the same time.",
        "requirements": ["Slowing skill"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 208: Breath of Cold
    "Breath of Cold": {
        "description": "Have 90 monsters frozen at the same time.",
        "requirements": ["Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 209: Oh Ven
    "Oh Ven": {
        "description": "Spread the poison",
        "requirements": ["Poison skill", "90 monsters poisoned at the same time"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 210: Meet the Spartans
    "Meet the Spartans": {
        "description": "Have 300 monsters on the battlefield at the same time.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 213: Stumbling
    "Stumbling": {
        "description": "Hit the same monster with traps 100 times.",
        "requirements": ["Traps skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 214: Overpecked
    "Overpecked": {
        "description": "Deal 100 gem wasp stings to the same monster.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 215: Teleport Lag
    "Teleport Lag": {
        "description": "Banish a monster at least 5 times.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 216: Pointed Pain
    "Pointed Pain": {
        "description": "Deal 50 gem wasp stings to creatures.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 218: Roof Knocking
    "Roof Knocking": {
        "description": "Deal 20 gem wasp stings to buildings.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 223: Brought Some Mana
    "Brought Some Mana": {
        "description": "Have 5.000 initial mana.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 225: Mana Trader
    "Mana Trader": {
        "description": "Salvage 8.000 mana from gems.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 226: Filled 5 Times
    "Filled 5 Times": {
        "description": "Reach mana pool level 5.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 232: Your Mana is Mine
    "Your Mana is Mine": {
        "description": "Leech 10.000 mana with gems.",
        "requirements": ["Mana Leech skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 233: Finders
    "Finders": {
        "description": "Gain 200 mana from drops.",
        "requirements": ["Mana Shard element", "Corrupted Mana Shard element", "Drop Holder element", "Apparition element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 235: Ouch!
    "Ouch!": {
        "description": "Spend 900 mana on banishment.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 237: The Horror
    "The Horror": {
        "description": "Lose 3.333 mana to shadows.",
        "requirements": ["Ritual trait", "Shadow element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 238: Amplification
    "Amplification": {
        "description": "Spend 18.000 mana on amplifiers.",
        "requirements": ["Amplifiers skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 239: Ice Snap
    "Ice Snap": {
        "description": "Gain 90 xp with Freeze spell crowd hits.",
        "requirements": ["Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 241: Limited Vision
    "Limited Vision": {
        "description": "Gain 100 xp with Whiteout spell crowd hits.",
        "requirements": ["Whiteout skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 243: Chilling Edges
    "Chilling Edges": {
        "description": "Gain 140 xp with Ice Shards spell crowd hits.",
        "requirements": ["Ice Shards skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 245: Battle Heat
    "Battle Heat": {
        "description": "Gain 200 xp with kill chains.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 250: Adventurer
    "Adventurer": {
        "description": "Gain 600 xp from drops.",
        "requirements": ["Apparition element", "Corrupted Mana Shard element", "Drop Holder element", "Mana Shard element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 251: Fierce Encounter
    "Fierce Encounter": {
        "description": "Reach -8% decreased banishment cost with your orb.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 254: Stinging Sphere
    "Stinging Sphere": {
        "description": "Deliver 100 banishments with your orb.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 257: Armored Orb
    "Armored Orb": {
        "description": "Strengthen your orb by dropping a gem on it.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 258: Added Protection
    "Added Protection": {
        "description": "Strengthen your orb with a gem in an amplifier.",
        "requirements": ["Amplifiers skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 259: Safe and Secure
    "Safe and Secure": {
        "description": "Strengthen your orb with 7 gems in amplifiers.",
        "requirements": ["Amplifiers skill", "gemCount: 7"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 260: Well Defended
    "Well Defended": {
        "description": "Don't let any monster touch your orb for 20 beaten waves.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 263: Awakening
    "Awakening": {
        "description": "Activate a shrine.",
        "requirements": ["Shrine element"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 264: Earthquake
    "Earthquake": {
        "description": "Activate shrines a total of 4 times.",
        "requirements": ["Shrine element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 266: Double Strike
    "Double Strike": {
        "description": "Activate the same shrine 2 times.",
        "requirements": ["Shrine element"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 269: Shovel Swing
    "Shovel Swing": {
        "description": "Hit 15 frozen monsters with shrines.",
        "requirements": ["Freeze skill", "Shrine element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 271: Salvation
    "Salvation": {
        "description": "Hit 150 whited out monsters with shrines.",
        "requirements": ["Whiteout skill", "Shrine element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 283: Long Lasting
    "Long Lasting": {
        "description": "Reach 500 poison kills through all the battles.",
        "requirements": ["Poison skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 290: Strike Anywhere
    "Strike Anywhere": {
        "description": "Cast a strike spell.",
        "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 291: Scare Tactics
    "Scare Tactics": {
        "description": "Cast 5 strike spells.",
        "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 293: Fire Away
    "Fire Away": {
        "description": "Cast a gem enhancement spell.",
        "requirements": ["Bolt skill", "Beam skill", "Barrage skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 294: Dual Pulse
    "Dual Pulse": {
        "description": "Have 2 beam enhanced gems at the same time.",
        "requirements": ["Beam skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 298: Double Punch
    "Double Punch": {
        "description": "Have 2 bolt enhanced gems at the same time.",
        "requirements": ["Bolt skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 301: Clear Sky
    "Clear Sky": {
        "description": "Beat 120 waves and don't use any strike spells.",
        "requirements": ["minWave: 120"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 302: Unsupportive
    "Unsupportive": {
        "description": "Reach 100 beacons destroyed through all the battles.",
        "requirements": ["Beacon element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 304: Basic Gem Tactics
    "Basic Gem Tactics": {
        "description": "Beat 120 waves and don't use any gem enhancement spells.",
        "requirements": ["minWave: 120"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 308: Purist
    "Purist": {
        "description": "Beat 120 waves and don't use any strike or gem enhancement s...",
        "requirements": ["minWave: 120"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 309: Freezing Wounds
    "Freezing Wounds": {
        "description": "Freeze a monster 3 times.",
        "requirements": ["Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 311: Ablatio Retinae
    "Ablatio Retinae": {
        "description": "Whiteout 111 whited out monsters.",
        "requirements": ["Whiteout skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 312: Even if You Thaw
    "Even if You Thaw": {
        "description": "Whiteout 120 frozen monsters.",
        "requirements": ["Freeze skill", "Whiteout skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 313: Hold Still
    "Hold Still": {
        "description": "Freeze 130 whited out monsters.",
        "requirements": ["Freeze skill", "Whiteout skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 314: Refrost
    "Refrost": {
        "description": "Freeze 111 frozen monsters.",
        "requirements": ["Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 315: Slow Creep
    "Slow Creep": {
        "description": "Poison 130 whited out monsters.",
        "requirements": ["Poison skill", "Whiteout skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 316: Inedible
    "Inedible": {
        "description": "Poison 111 frozen monsters.",
        "requirements": ["Freeze skill", "Poison skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 319: Shattered Orb
    "Shattered Orb": {
        "description": "Lose a battle.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 320: Ice Cube
    "Ice Cube": {
        "description": "Have a Maximum Charge of 300% for the Freeze Spell.",
        "requirements": ["Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 321: Barrage Battery
    "Barrage Battery": {
        "description": "Have a Maximum Charge of 300% for the Barrage Spell.",
        "requirements": ["Barrage skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 322: Call in the Wave!
    "Call in the Wave!": {
        "description": "Call a wave early.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 323: Short Tempered
    "Short Tempered": {
        "description": "Call 5 waves early.",
        "requirements": ["minWave: 5"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 327: Socketed Rage
    "Socketed Rage": {
        "description": "Enrage a wave.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 331: Wave Pecking
    "Wave Pecking": {
        "description": "Summon 20 monsters by enraging waves.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 335: Ten Angry Waves
    "Ten Angry Waves": {
        "description": "Enrage 10 waves.",
        "requirements": ["minWave: 10"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 341: Buzz Feed
    "Buzz Feed": {
        "description": "Have 99 gem wasps on the battlefield.",
        "requirements": ["gemCount: 99"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 342: Boom
    "Boom": {
        "description": "Throw a gem bomb.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 343: Bang
    "Bang": {
        "description": "Throw 30 gem bombs.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 344: Getting Rid of Them
    "Getting Rid of Them": {
        "description": "Drop 48 gem bombs on beacons.",
        "requirements": ["Beacon element", "gemCount: 48"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 345: Core Pouch
    "Core Pouch": {
        "description": "Have 100 shadow cores at the start of the battle.",
        "requirements": ["Shadow Core element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 346: Core Pack
    "Core Pack": {
        "description": "Find 20 shadow cores.",
        "requirements": ["Shadow Core element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 349: Blastwave
    "Blastwave": {
        "description": "Reach 1.000 shrine kills through all the battles.",
        "requirements": ["Shrine element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 351: No Time to Rest
    "No Time to Rest": {
        "description": "Have the Haste trait set to level 6 or higher and win the ba...",
        "requirements": ["Haste trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 352: Tumbling Billows
    "Tumbling Billows": {
        "description": "Have the Swarmling Domination trait set to level 6 or higher...",
        "requirements": ["Swarmling Domination trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 353: Hateful
    "Hateful": {
        "description": "Have the Hatred trait set to level 6 or higher and win the b...",
        "requirements": ["Hatred trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 354: On the Shoulders of Giants
    "On the Shoulders of Giants": {
        "description": "Have the Giant Domination trait set to level 6 or higher and...",
        "requirements": ["Giant Domination trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 355: Stronger Than Before
    "Stronger Than Before": {
        "description": "Set corrupted banishment to level 12 and banish a monster 3 ...",
        "requirements": ["Corrupted Banishment trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 364: First Puzzle Piece
    "First Puzzle Piece": {
        "description": "Find a talisman fragment.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 365: Fortunate
    "Fortunate": {
        "description": "Find 2 talisman fragments.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 367: Regaining Knowledge
    "Regaining Knowledge": {
        "description": "Acquire 5 skills.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 368: Skillful
    "Skillful": {
        "description": "Acquire and raise all skills to level 5 or above.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 369: So Enduring
    "So Enduring": {
        "description": "Have the Adaptive Carapace trait set to level 6 or higher an...",
        "requirements": ["Adaptive Carapace trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 370: Deluminati
    "Deluminati": {
        "description": "Have the Dark Masonry trait set to level 6 or higher and win...",
        "requirements": ["Dark Masonry trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 371: Crowd Control
    "Crowd Control": {
        "description": "Have the Overcrowd trait set to level 6 or higher and win th...",
        "requirements": ["Overcrowd trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 372: Guarding the Fallen Gate
    "Guarding the Fallen Gate": {
        "description": "Have the Corrupted Banishment trait set to level 6 or higher...",
        "requirements": ["Corrupted Banishment trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 373: Time to Rise
    "Time to Rise": {
        "description": "Have the Awakening trait set to level 6 or higher and win th...",
        "requirements": ["Awakening trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 374: Ionized Air
    "Ionized Air": {
        "description": "Have the Insulation trait set to level 6 or higher and win t...",
        "requirements": ["Insulation trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 375: Face the Phobia
    "Face the Phobia": {
        "description": "Have the Swarmling Parasites trait set to level 6 or higher ...",
        "requirements": ["Swarmling Parasites trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 376: Just Fire More at Them
    "Just Fire More at Them": {
        "description": "Have the Thick Air trait set to level 6 or higher and win th...",
        "requirements": ["Thick Air trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 377: Knowledge Seeker
    "Knowledge Seeker": {
        "description": "Open a wizard stash.",
        "requirements": ["Wizard Stash element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 378: Stash No More
    "Stash No More": {
        "description": "Destroy a previously opened wizard stash.",
        "requirements": ["Wizard Stash element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 379: Spectrin Tetramer
    "Spectrin Tetramer": {
        "description": "Have the Vital Link trait set to level 6 or higher and win t...",
        "requirements": ["Vital Link trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 380: In for a Trait
    "In for a Trait": {
        "description": "Activate a battle trait.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 381: High Stakes
    "High Stakes": {
        "description": "Set a battle trait to level 12.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 382: White Wand
    "White Wand": {
        "description": "Reach wizard level 10.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 390: Let's Have a Look
    "Let's Have a Look": {
        "description": "Open a drop holder.",
        "requirements": ["Drop Holder element"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 391: Raindrop
    "Raindrop": {
        "description": "Drop 18 gem bombs while it's raining.",
        "requirements": ["gemCount: 18"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 392: Snowball
    "Snowball": {
        "description": "Drop 27 gem bombs while it's snowing.",
        "requirements": ["gemCount: 27"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 393: That one!
    "That one!": {
        "description": "Select a monster.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 394: There it is!
    "There it is!": {
        "description": "Select a building.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 395: Not So Fast
    "Not So Fast": {
        "description": "Freeze a specter.",
        "requirements": ["Freeze skill", "Ritual trait", "Specter element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 396: Under Pressure
    "Under Pressure": {
        "description": "Shoot down 340 shadow projectiles.",
        "requirements": ["Ritual trait", "Shadow element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 397: Thin Them Out
    "Thin Them Out": {
        "description": "Have the Strength in Numbers trait set to level 6 or higher ...",
        "requirements": ["Strength in Numbers trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 398: Forces Within my Comprehension
    "Forces Within my Comprehension": {
        "description": "Have the Ritual trait set to level 6 or higher and win the b...",
        "requirements": ["Ritual trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 399: Nature Takes Over
    "Nature Takes Over": {
        "description": "Have no own buildings on the field at the end of the battle.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 400: Sharpened
    "Sharpened": {
        "description": "Enhance a gem in a trap.",
        "requirements": ["Traps skill", "Beam skill", "Bolt skill", "Barrage skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 401: Second Thoughts
    "Second Thoughts": {
        "description": "Add a different enhancement on an enhanced gem.",
        "requirements": ["Bolt skill", "Beam skill", "Barrage skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 402: Special Purpose
    "Special Purpose": {
        "description": "Change the target priority of a gem.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 411: Flying Multikill
    "Flying Multikill": {
        "description": "Destroy 1 apparition, 1 specter, 1 wraith and 1 shadow in th...",
        "requirements": ["Ritual trait", "Apparition element", "Shadow element", "Specter element", "Wraith element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 412: Weather Tower
    "Weather Tower": {
        "description": "Activate a shrine while raining.",
        "requirements": ["Shrine element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 413: Let it Go
    "Let it Go": {
        "description": "Leave an apparition alive.",
        "requirements": ["Ritual trait", "Apparition element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 414: Slow Drain
    "Slow Drain": {
        "description": "Deal 10.000 poison damage to a monster.",
        "requirements": ["Poison skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 415: In Flames
    "In Flames": {
        "description": "Kill 400 spawnlings.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 417: Black Blood
    "Black Blood": {
        "description": "Deal 5.000 poison damage to a shadow.",
        "requirements": ["Poison skill", "Ritual trait", "Shadow element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 418: Clean Orb
    "Clean Orb": {
        "description": "Win a battle without any monster getting to your orb.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 424: Twice the Blast
    "Twice the Blast": {
        "description": "Have 2 barrage enhanced gems at the same time.",
        "requirements": ["Barrage skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 428: Path of Splats
    "Path of Splats": {
        "description": "Kill 400 monsters.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 434: Icy Fingers
    "Icy Fingers": {
        "description": "Reach 500 strike spells cast through all the battles.",
        "requirements": ["Whiteout skill", "Freeze skill", "Ice Shards skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 438: Adept Enhancer
    "Adept Enhancer": {
        "description": "Reach 500 enhancement spells cast through all the battles.",
        "requirements": ["Beam skill", "Bolt skill", "Barrage skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 442: Multifreeze
    "Multifreeze": {
        "description": "Reach 5.000 strike spell hits through all the battles.",
        "requirements": ["Ice Shards skill", "Whiteout skill", "Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 446: More Wounds
    "More Wounds": {
        "description": "Kill 125 bleeding monsters with barrage.",
        "requirements": ["Barrage skill", "Bleeding skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 447: Red Orange
    "Red Orange": {
        "description": "Leech 700 mana from bleeding monsters.",
        "requirements": ["Bleeding skill", "Mana Leech skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 451: Last Minute Mana
    "Last Minute Mana": {
        "description": "Leech 500 mana from poisoned monsters.",
        "requirements": ["Mana Leech skill", "Poison skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 455: Easy Kill
    "Easy Kill": {
        "description": "Kill 120 bleeding monsters.",
        "requirements": ["Bleeding skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 459: Wasp Defense
    "Wasp Defense": {
        "description": "Smash 3 jars of wasps before wave 3.",
        "requirements": ["Field X2"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 460: Skylark
    "Skylark": {
        "description": "Call every wave early in a battle.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 461: Mana First
    "Mana First": {
        "description": "Deplete a shard when there are more than 300 swarmlings on t...",
        "requirements": ["Mana Shard element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 462: Might Need it Later
    "Might Need it Later": {
        "description": "Enhance a gem in an amplifier.",
        "requirements": ["Amplifiers skill", "Bolt skill", "Beam skill", "Barrage skill"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 463: Enhancement Storage
    "Enhancement Storage": {
        "description": "Enhance a gem in the inventory.",
        "requirements": ["Bolt skill", "Beam skill", "Barrage skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 464: Why Not
    "Why Not": {
        "description": "Enhance a gem in the enraging socket.",
        "requirements": ["Bolt skill", "Beam skill", "Barrage skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 465: Eat my Light
    "Eat my Light": {
        "description": "Kill a wraith with a shrine strike.",
        "requirements": ["Ritual trait", "Shrine element", "Wraith element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 466: End of the Tunnel
    "End of the Tunnel": {
        "description": "Kill an apparition with a shrine strike.",
        "requirements": ["Ritual trait", "Apparition element", "Shrine element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 467: Healing Denied
    "Healing Denied": {
        "description": "Destroy 3 healing beacons.",
        "requirements": ["Beacon element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 468: Shieldbreaker
    "Shieldbreaker": {
        "description": "Destroy 3 shield beacons.",
        "requirements": ["Beacon element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 469: Deal Some Damage Too
    "Deal Some Damage Too": {
        "description": "Have 5 traps with bolt enhanced gems in them.",
        "requirements": ["Bolt skill", "Traps skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 470: Popped Eggs
    "Popped Eggs": {
        "description": "Kill a swarm queen with a bolt.",
        "requirements": ["Bolt skill", "Swarm Queen element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 471: Supply Line Cut
    "Supply Line Cut": {
        "description": "Kill a swarm queen with a barrage shell.",
        "requirements": ["Barrage skill", "Swarm Queen element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 472: Prismatic Takeaway
    "Prismatic Takeaway": {
        "description": "Have a specter steal a gem of 6 components.",
        "requirements": ["Critical Hit skill", "Mana Leech skill", "Bleeding skill", "Armor Tearing skill", "Poison skill", "Slowing skill", "Specter element", "gemCount: 6"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 473: Lots of Crit Hits
    "Lots of Crit Hits": {
        "description": "Have a pure critical hit gem with 2.000 hits.",
        "requirements": ["Critical Hit skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 474: Damage Support
    "Damage Support": {
        "description": "Have a pure bleeding gem with 2.500 hits.",
        "requirements": ["Bleeding skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 475: Shred Some Armor
    "Shred Some Armor": {
        "description": "Have a pure armor tearing gem with 3.000 hits.",
        "requirements": ["Armor Tearing skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 476: Epidemic Gem
    "Epidemic Gem": {
        "description": "Have a pure poison gem with 3.500 hits.",
        "requirements": ["Poison skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 477: Army Glue
    "Army Glue": {
        "description": "Have a pure slowing gem with 4.000 hits.",
        "requirements": ["Slowing skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 478: Got the Price Back
    "Got the Price Back": {
        "description": "Have a pure mana leeching gem with 4.500 hits.",
        "requirements": ["Mana Leech skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 479: Frosting
    "Frosting": {
        "description": "Freeze a specter while it's snowing.",
        "requirements": ["Freeze skill", "Ritual trait", "Specter element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 480: Unarmed
    "Unarmed": {
        "description": "Have no gems when wave 20 starts.",
        "requirements": ["minWave: 20"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 481: Rage Control
    "Rage Control": {
        "description": "Kill 400 enraged swarmlings with barrage.",
        "requirements": ["Barrage skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 482: Can't Take Any Risks
    "Can't Take Any Risks": {
        "description": "Kill a bleeding giant with poison.",
        "requirements": ["Bleeding skill", "Poison skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 483: Marmalade
    "Marmalade": {
        "description": "Don't destroy any of the jars of wasps.",
        "requirements": ["Field X2"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 484: By Three They Go
    "By Three They Go": {
        "description": "Have 3 of your gems destroyed or stolen.",
        "requirements": ["Ritual trait", "Specter element", "Watchtower element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 488: Near Death
    "Near Death": {
        "description": "Suffer mana loss from a shadow projectile when under 200 man...",
        "requirements": ["Shadow element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 489: Glitter Cloud
    "Glitter Cloud": {
        "description": "Kill an apparition with a gem bomb.",
        "requirements": ["Ritual trait", "Apparition element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 490: Final Touch
    "Final Touch": {
        "description": "Kill a spire with a gem wasp.",
        "requirements": ["Ritual trait", "Spire element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 491: Glowing Armada
    "Glowing Armada": {
        "description": "Have 240 gem wasps on the battlefield when the battle ends.",
        "requirements": ["gemCount: 240"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 492: Am I a Joke to You?
    "Am I a Joke to You?": {
        "description": "Start an enraged wave early while there is a wizard hunter o...",
        "requirements": ["Wizard hunter"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 493: Rageroom
    "Rageroom": {
        "description": "Build 100 walls and start 100 enraged waves.",
        "requirements": ["Wall element", "minWave: 100"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 494: One Hit is All it Takes
    "One Hit is All it Takes": {
        "description": "Kill a wraith with one hit.",
        "requirements": ["Ritual trait", "Wraith element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 495: Whacked
    "Whacked": {
        "description": "Kill a specter with one hit.",
        "requirements": ["Ritual trait", "Specter element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 496: Farewell
    "Farewell": {
        "description": "Kill an apparition with one hit.",
        "requirements": ["Ritual trait", "Apparition element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 497: No Honor Among Thieves
    "No Honor Among Thieves": {
        "description": "Have a watchtower kill a specter.",
        "requirements": ["Ritual trait", "Specter element", "Watchtower element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 498: You Could Be my Apprentice
    "You Could Be my Apprentice": {
        "description": "Have a watchtower kill a wizard hunter.",
        "requirements": ["Watchtower element", "Wizard hunter"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 499: Get Them
    "Get Them": {
        "description": "Have a watchtower kill 39 monsters.",
        "requirements": ["Watchtower element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 500: Helping Hand
    "Helping Hand": {
        "description": "Have a watchtower kill a possessed monster.",
        "requirements": ["Possessed Monster element", "Watchtower element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 501: Going for the Weak
    "Going for the Weak": {
        "description": "Have a watchtower kill a poisoned monster.",
        "requirements": ["Poison skill", "Watchtower element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 502: That Was Rude
    "That Was Rude": {
        "description": "Lose a gem with more than 1.000 hits to a watchtower.",
        "requirements": ["Watchtower element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 503: Multiline
    "Multiline": {
        "description": "Have at least 5 different talisman properties.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 507: Great Survivor
    "Great Survivor": {
        "description": "Kill a monster from wave 1 when wave 20 has already started.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 509: A Bright Start
    "A Bright Start": {
        "description": "Have 30 fields lit in Journey mode.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 513: Getting My Feet Wet
    "Getting My Feet Wet": {
        "description": "Have 20 fields lit in Endurance mode.",
        "requirements": ["Endurance"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 517: Disciple
    "Disciple": {
        "description": "Have 10 fields lit in Trial mode.",
        "requirements": ["Trial"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 521: Catch and Release
    "Catch and Release": {
        "description": "Destroy a jar of wasps, but don't have any wasp kills.",
        "requirements": ["Field X2"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 522: No You Won't!
    "No You Won't!": {
        "description": "Destroy a watchtower before it could fire.",
        "requirements": ["Bolt skill", "Watchtower element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 523: Bleeding For Everyone
    "Bleeding For Everyone": {
        "description": "Enhance a pure bleeding gem having random priority with beam...",
        "requirements": ["Beam skill", "Bleeding skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 524: Just Breathe In
    "Just Breathe In": {
        "description": "Enhance a pure poison gem having random priority with beam.",
        "requirements": ["Beam skill", "Poison skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 525: Slow Motion
    "Slow Motion": {
        "description": "Enhance a pure slowing gem having random priority with beam.",
        "requirements": ["Beam skill", "Slowing skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 526: Disco Ball
    "Disco Ball": {
        "description": "Have a gem of 6 components in a lantern.",
        "requirements": ["Lanterns skill", "Critical Hit skill", "Mana Leech skill", "Bleeding skill", "Armor Tearing skill", "Poison skill", "Slowing skill", "gemCount: 6"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 527: Eggnog
    "Eggnog": {
        "description": "Crack a monster egg open while time is frozen.",
        "requirements": ["Swarm Queen element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 528: Instant Spawn
    "Instant Spawn": {
        "description": "Have a shadow spawn a monster while time is frozen.",
        "requirements": ["Ritual trait", "Shadow element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 529: Enough Frozen Time Trickery
    "Enough Frozen Time Trickery": {
        "description": "Kill a shadow while time is frozen.",
        "requirements": ["Shadow element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 530: In a Blink of an Eye
    "In a Blink of an Eye": {
        "description": "Kill 100 monsters while time is frozen.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 531: Stay Some More
    "Stay Some More": {
        "description": "Cast freeze on an apparition 3 times.",
        "requirements": ["Freeze skill", "Ritual trait", "Apparition element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 532: Twice the Steepness
    "Twice the Steepness": {
        "description": "Kill 170 monsters while there are at least 2 wraiths in the ...",
        "requirements": ["Ritual trait", "Wraith element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 536: Derangement
    "Derangement": {
        "description": "Decrease the range of a gem.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 537: Couldn't Decide
    "Couldn't Decide": {
        "description": "Kill 400 monsters with prismatic gem wasps.",
        "requirements": ["Critical Hit skill", "Mana Leech skill", "Bleeding skill", "Armor Tearing skill", "Poison skill", "Slowing skill", "gemCount: 6"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 542: Heavily Modified
    "Heavily Modified": {
        "description": "Activate all mods.",
        "requirements": ["Requires \"hidden codes\""],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 543: You're Safe With Me
    "You're Safe With Me": {
        "description": "Win a battle with at least 10 orblets remaining.",
        "requirements": ["Orb of Presence skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 545: No More Rounds
    "No More Rounds": {
        "description": "Kill 60 banished monsters with shrines.",
        "requirements": ["Shrine element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 549: Come Again
    "Come Again": {
        "description": "Kill 190 banished monsters.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 557: So Attached
    "So Attached": {
        "description": "Win a Trial battle without losing any orblets.",
        "requirements": ["Trial"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 558: Impressive
    "Impressive": {
        "description": "Win a Trial battle without any monster reaching your Orb.",
        "requirements": ["Trial"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 559: Get This Done Quick
    "Get This Done Quick": {
        "description": "Win a Trial battle with at least 3 waves started early.",
        "requirements": ["minWave: 3", "Trial"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 560: Too Easy
    "Too Easy": {
        "description": "Win a Trial battle with at least 3 waves enraged.",
        "requirements": ["minWave: 3", "Trial"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 561: Has Stood Long Enough
    "Has Stood Long Enough": {
        "description": "Destroy a monster nest after the last wave has started.",
        "requirements": ["Monster Nest element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 562: Twice the Shock
    "Twice the Shock": {
        "description": "Hit the same monster 2 times with shrines.",
        "requirements": ["Shrine element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 563: Mana is All I Need
    "Mana is All I Need": {
        "description": "Win a battle with no skill point spent and a battle trait ma...",
        "requirements": ["Any battle trait\n\n"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 564: Mastery
    "Mastery": {
        "description": "Raise a skill to level 70.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 565: Miniblasts
    "Miniblasts": {
        "description": "Tear a total of 1.250 armor with wasp stings.",
        "requirements": ["Armor Tearing skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 569: Elementary
    "Elementary": {
        "description": "Beat 30 waves using at most grade 2 gems.",
        "requirements": ["minWave: 30"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 573: Eggcracker
    "Eggcracker": {
        "description": "Don't let any egg laid by a swarm queen to hatch on its own.",
        "requirements": ["Swarm Queen element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 574: Let Them Hatch
    "Let Them Hatch": {
        "description": "Don't crack any egg laid by a swarm queen.",
        "requirements": ["Swarm Queen element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 575: Well Trained for This
    "Well Trained for This": {
        "description": "Kill a wraith with a shot fired by a gem having at least 1.0...",
        "requirements": ["Ritual trait", "Wraith element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 576: Sharp Shot
    "Sharp Shot": {
        "description": "Kill a shadow with a shot fired by a gem having at least 5.0...",
        "requirements": ["Ritual trait", "Shadow element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 577: Double Splash
    "Double Splash": {
        "description": "Kill two non-monster creatures with one gem bomb.",
        "requirements": ["Ritual trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 578: Omnibomb
    "Omnibomb": {
        "description": "Destroy a building and a non-monster creature with one gem b...",
        "requirements": ["Ritual trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 579: Urban Warfare
    "Urban Warfare": {
        "description": "Destroy a dwelling and kill a monster with one gem bomb.",
        "requirements": ["Abandoned Dwelling element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 580: Keep Losing Keep Harvesting
    "Keep Losing Keep Harvesting": {
        "description": "Deplete a mana shard while there is a shadow on the battlefi...",
        "requirements": ["Ritual trait", "Mana Shard element", "Shadow element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 581: One Less Problem
    "One Less Problem": {
        "description": "Destroy a monster nest while there is a wraith on the battle...",
        "requirements": ["Ritual trait", "Monster Nest element", "Wraith element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 582: Tomb No Matter What
    "Tomb No Matter What": {
        "description": "Open a tomb while there is a spire on the battlefield.",
        "requirements": ["Ritual trait", "Spire element", "Tomb element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 583: Landing Spot
    "Landing Spot": {
        "description": "Demolish 20 or more walls with falling spires.",
        "requirements": ["Ritual trait", "Spire element", "Wall element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 584: Rising Tide
    "Rising Tide": {
        "description": "Banish 150 monsters while there are 2 or more wraiths on the...",
        "requirements": ["Ritual trait", "Wraith element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 585: Mana Blinded
    "Mana Blinded": {
        "description": "Leech 900 mana from whited out monsters.",
        "requirements": ["Mana Leech skill", "Whiteout skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 589: Double Sharded
    "Double Sharded": {
        "description": "Cast 2 ice shards on the same monster.",
        "requirements": ["Ice Shards skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 593: Busted
    "Busted": {
        "description": "Destroy a full health possession obelisk with one gem bomb b...",
        "requirements": ["Obelisk element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 594: Stingy Downfall
    "Stingy Downfall": {
        "description": "Deal 400 wasp stings to a spire.",
        "requirements": ["Ritual trait", "Spire element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 595: Put Those Down Now!
    "Put Those Down Now!": {
        "description": "Have 10 orblets carried by monsters at the same time.",
        "requirements": ["Orb of Presence skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 596: Locked and Loaded
    "Locked and Loaded": {
        "description": "Have 3 pylons charged up to 3 shots each.",
        "requirements": ["Pylons skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 597: Return of Investment
    "Return of Investment": {
        "description": "Leech 900 mana with a grade 1 gem.",
        "requirements": ["Mana Leech skill", "minGemGrade: 1"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 601: Groundfill
    "Groundfill": {
        "description": "Demolish a trap.",
        "requirements": ["Traps skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 602: Vantage Point Down
    "Vantage Point Down": {
        "description": "Demolish a pylon.",
        "requirements": ["Pylons skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 603: Quicksave
    "Quicksave": {
        "description": "Instantly drop a gem to your inventory.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 604: Still No Match
    "Still No Match": {
        "description": "Destroy an omnibeacon.",
        "requirements": ["Beacon element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 605: Not So Omni Anymore
    "Not So Omni Anymore": {
        "description": "Destroy 10 omnibeacons.",
        "requirements": ["Beacon element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 606: Family Friendlier
    "Family Friendlier": {
        "description": "Kill 900 green blooded monsters.",
        "requirements": ["Requires \"hidden codes\""],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 610: Bath Bomb
    "Bath Bomb": {
        "description": "Kill 30 monsters with orblet explosions.",
        "requirements": ["Orb of Presence skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 614: Green Eyed Ninja
    "Green Eyed Ninja": {
        "description": "Entering: The Wilderness",
        "requirements": ["Field N1, U1 or R5"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 615: Splash Swim Splash
    "Splash Swim Splash": {
        "description": "Full of oxygen",
        "requirements": ["Click on water in a field\nRequires a field with water"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 616: Going Deviant
    "Going Deviant": {
        "description": "Rook to a9",
        "requirements": ["Scroll to edge of the world map"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 617: We Just Wanna Be Free
    "We Just Wanna Be Free": {
        "description": "More than blue triangles",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 618: Renzokuken
    "Renzokuken": {
        "description": "Break your frozen time gem bombing limits",
        "requirements": ["Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 619: Uraj and Khalis
    "Uraj and Khalis": {
        "description": "Activate the lanterns",
        "requirements": ["Lanterns skill", "Field H3"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 620: I Never Asked For This
    "I Never Asked For This": {
        "description": "All my aug points spent",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 621: Deckard Would Be Proud
    "Deckard Would Be Proud": {
        "description": "All I could get for a prismatic amulet",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 622: Hope has fallen
    "Hope has fallen": {
        "description": "Dismantled bunkhouses",
        "requirements": ["Field E3"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 623: Slime Block
    "Slime Block": {
        "description": "Nine slimeballs is all it takes",
        "requirements": ["A monster with atleast 20.000hp"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 624: Behold Aurora
    "Behold Aurora": {
        "description": "Go Igniculus and Light Ray (All)+++!",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 625: Rooting From Afar
    "Rooting From Afar": {
        "description": "Kill a gatekeeper fang with a barrage shell.",
        "requirements": ["Barrage skill", "Gatekeeper element", "Field A4"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 626: Spitting Darkness
    "Spitting Darkness": {
        "description": "Leave a gatekeeper fang alive until it can launch 100 projec...",
        "requirements": ["Gatekeeper element", "Field A4"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 627: Swift Death
    "Swift Death": {
        "description": "Kill the gatekeeper with a bolt.",
        "requirements": ["Bolt skill", "Gatekeeper element", "Field A4"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 628: Popped
    "Popped": {
        "description": "Kill at least 30 gatekeeper fangs.",
        "requirements": ["Gatekeeper element", "Field A4"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 629: Implosion
    "Implosion": {
        "description": "Kill a gatekeeper fang with a gem bomb.",
        "requirements": ["Gatekeeper element", "Field A4"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 630: That Was Your Last Move
    "That Was Your Last Move": {
        "description": "Kill a wizard hunter while it's attacking one of your buildi...",
        "requirements": ["Wizard Hunter"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 631: Starter Pack
    "Starter Pack": {
        "description": "Add 8 talisman fragments to your shape collection.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 634: Shapeshifter
    "Shapeshifter": {
        "description": "Complete your talisman fragment shape collection.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 635: Enter The Gate
    "Enter The Gate": {
        "description": "Kill the gatekeeper.",
        "requirements": ["Gatekeeper element", "Field A4"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
}

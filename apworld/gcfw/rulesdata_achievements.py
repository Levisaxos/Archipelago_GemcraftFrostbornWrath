"""
GemCraft Frostborn Wrath — Achievement Requirements System

This file defines all requirement data for achievements in GCFW Archipelago.
It is designed to be readable by non-programmers with proper comments.

Structure:
- achievement_requirements: All 636 achievements grouped by grindiness (1-5)
- achievement_unlocks: Dependency chains (what achievements grant)

Configuration imported from rulesdata_settings.py:
- WAVE_TIERS: Maps tier numbers (0-12) to wave count thresholds
- GRINDINESS_TIERS: Cumulative grindiness level definitions (1-5, plus off)
- tier_progression_requirements: Tier 0-12 progression gates
- game_level_elements: Level-specific environmental features
- non_monster_elements: Trait-gated gameplay unlocks (require specific traits)
- game_skills_categories: Skills/traits grouped by type (BattleTraits, GemSkills, OtherSkills)
"""

from .rulesdata_settings import (
    WAVE_TIERS,
    GRINDINESS_TIERS,
    tier_progression_requirements,
    game_level_elements,
    non_monster_elements,
    game_skills_categories,
)

# =====================================================================
# ACHIEVEMENT REQUIREMENTS (by grindiness level)
# =====================================================================
# All 636 achievements organized by grindiness difficulty.
# Each grindiness level is cumulative with previous levels.
#
achievement_requirements = {
    "grindiness_1": {
        # ID 0: Dichromatic
        "Dichromatic": {
            "description": "Combine two gems of different colors.",
            "requirements": ["gemCount: 2"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 1: Mana Salvation
        "Mana Salvation": {
            "description": "Salvage mana by destroying a gem.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 2: Zapped
        "Zapped": {
            "description": "Get your Orb destroyed by a wizard tower.",
            "requirements": ["Wizard Tower element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 3: A Shrubbery!
        "A Shrubbery!": {
            "description": "Place a shrub wall.",
            "requirements": ["Wall element"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 4: Route Planning
        "Route Planning": {
            "description": "Destroy 5 barricades.",
            "requirements": ["Barricade element"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 5: What Are You Waiting For?
        "What Are You Waiting For?": {
            "description": "Have all spells charged to 200%.",
            "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 6: Just Started
        "Just Started": {
            "description": "Reach 10 battles won.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 10: Early Bird
        "Early Bird": {
            "description": "Reach 500 waves started early through all the batt...",
            "requirements": ["minWave: 500"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 14: Wavy
        "Wavy": {
            "description": "Reach 500 waves beaten through all the battles.",
            "requirements": ["minWave: 500"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 18: Century Egg
        "Century Egg": {
            "description": "Reach 100 monster eggs cracked through all the bat...",
            "requirements": ["Swarm Queen element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 19: Slowly but Surely
        "Slowly but Surely": {
            "description": "Beat 90 waves using only slowing gems.",
            "requirements": ["Slowing skill", "minWave: 90"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 20: Too Long to Hold Your Breath
        "Too Long to Hold Your Breath": {
            "description": "Beat 90 waves using only poison gems.",
            "requirements": ["Poison skill", "minWave: 90"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 21: Biohazard
        "Biohazard": {
            "description": "Create a grade 12 pure poison gem.",
            "requirements": ["Poison skill", "minGemGrade: 12"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 22: No Armor Area
        "No Armor Area": {
            "description": "Beat 90 waves using only armor tearing gems.",
            "requirements": ["Armor Tearing skill", "minWave: 90"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 23: The Peeler
        "The Peeler": {
            "description": "Create a grade 12 pure armor tearing gem.",
            "requirements": ["Armor Tearing skill", "minGemGrade: 12"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 24: Powerful
        "Powerful": {
            "description": "Create a gem with a raw minimum damage of 300 or h...",
            "requirements": ["gemCount: 1"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 27: Tricolor
        "Tricolor": {
            "description": "Create a gem of 3 components.",
            "requirements": ["gemCount: 3"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 28: Bloodrush
        "Bloodrush": {
            "description": "Call an enraged wave early.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 30: Mana Magnet
        "Mana Magnet": {
            "description": "Win a battle using only mana leeching gems.",
            "requirements": ["Mana Leech skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 31: Targeting Weak Points
        "Targeting Weak Points": {
            "description": "Win a battle using only critical hit gems.",
            "requirements": ["Critical Hit skill"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 32: Shooting Where it Hurts
        "Shooting Where it Hurts": {
            "description": "Beat 90 waves using only critical hit gems.",
            "requirements": ["Critical Hit skill", "minWave: 90"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 33: All Your Mana Belongs to Us
        "All Your Mana Belongs to Us": {
            "description": "Beat 90 waves using only mana leeching gems.",
            "requirements": ["Mana Leech skill", "minWave: 90"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 34: Nox Mist
        "Nox Mist": {
            "description": "Win a battle using only poison gems.",
            "requirements": ["Poison skill"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 35: Blood Clot
        "Blood Clot": {
            "description": "Beat 90 waves using only bleeding gems.",
            "requirements": ["Bleeding skill", "minWave: 90"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 36: Blood Magic
        "Blood Magic": {
            "description": "Win a battle using only bleeding gems.",
            "requirements": ["Bleeding skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 37: Long Crawl
        "Long Crawl": {
            "description": "Win a battle using only slowing gems.",
            "requirements": ["Slowing skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 38: Shavings All Around
        "Shavings All Around": {
            "description": "Win a battle using only armor tearing gems.",
            "requirements": ["Armor Tearing skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 39: Eagle Eye
        "Eagle Eye": {
            "description": "Reach an amplified gem range of 18.",
            "requirements": ["Amplifiers skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 40: Super Gem
        "Super Gem": {
            "description": "Create a grade 3 gem with 300 effective max damage...",
            "requirements": ["minGemGrade: 3"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 43: Third Grade
        "Third Grade": {
            "description": "Create a grade 3 gem.",
            "requirements": ["minGemGrade: 3"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 48: Pat on the Back
        "Pat on the Back": {
            "description": "Amplify a gem.",
            "requirements": ["Amplifiers skill"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 49: In Focus
        "In Focus": {
            "description": "Amplify a gem with 8 other gems.",
            "requirements": ["Amplifiers skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 50: Catalyst
        "Catalyst": {
            "description": "Give a Gem 200 Poison Damage by Amplification.",
            "requirements": ["Amplifiers skill", "Poison skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 51: Warming Up
        "Warming Up": {
            "description": "Have a grade 1 gem with 100 hits.",
            "requirements": ["minGemGrade: 1"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 54: Jewel Box
        "Jewel Box": {
            "description": "Fill all inventory slots with gems.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 55: Well Laid
        "Well Laid": {
            "description": "Have 10 gems on the battlefield.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 56: Swift Deployment
        "Swift Deployment": {
            "description": "Have 20 gems on the battlefield before wave 5.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 59: Connected
        "Connected": {
            "description": "Build an amplifier.",
            "requirements": ["Amplifiers skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 64: Build Along
        "Build Along": {
            "description": "Reach 200 structures built through all the battles...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 66: Towerful
        "Towerful": {
            "description": "Build 5 towers.",
            "requirements": ["Tower element"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 71: Sparse Snares
        "Sparse Snares": {
            "description": "Build 10 traps.",
            "requirements": ["Traps skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 75: Power Sharing
        "Power Sharing": {
            "description": "Build 5 amplifiers.",
            "requirements": ["Amplifiers skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 79: Minor Detour
        "Minor Detour": {
            "description": "Build 15 walls.",
            "requirements": ["Wall element"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 82: Too Curious
        "Too Curious": {
            "description": "Break 2 tombs open.",
            "requirements": ["Tomb element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 85: Stones to Dust
        "Stones to Dust": {
            "description": "Demolish one of your structures.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 86: Juggler
        "Juggler": {
            "description": "Use demolition 7 times.",
            "requirements": ["Demolition skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 87: Is Anyone in There?
        "Is Anyone in There?": {
            "description": "Break a tomb open.",
            "requirements": ["Tomb element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 89: Tomb Raiding
        "Tomb Raiding": {
            "description": "Break a tomb open before wave 15.",
            "requirements": ["Tomb element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 90: Fire in the Hole
        "Fire in the Hole": {
            "description": "Destroy a monster nest.",
            "requirements": ["Monster Nest element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 91: Root Canal
        "Root Canal": {
            "description": "Destroy 2 monster nests.",
            "requirements": ["Monster Nest element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 93: Nest Blaster
        "Nest Blaster": {
            "description": "Destroy 2 monster nests before wave 12.",
            "requirements": ["Monster Nest element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 94: Blackout
        "Blackout": {
            "description": "Destroy a beacon.",
            "requirements": ["Beacon element"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 95: Popping Lights
        "Popping Lights": {
            "description": "Destroy 5 beacons.",
            "requirements": ["Beacon element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 96: Broken Siege
        "Broken Siege": {
            "description": "Destroy 8 beacons before wave 8.",
            "requirements": ["Beacon element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 97: Still Lit
        "Still Lit": {
            "description": "Have 15 or more beacons standing at the end of the...",
            "requirements": ["Dark Masonry trait", "Beacon element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 98: Heavy Support
        "Heavy Support": {
            "description": "Have 20 beacons on the field at the same time.",
            "requirements": ["Dark Masonry trait", "Beacon element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 99: No Stone Unturned
        "No Stone Unturned": {
            "description": "Open 5 drop holders.",
            "requirements": ["Drop Holder element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 100: Hiding Spot
        "Hiding Spot": {
            "description": "Open 3 drop holders before wave 3.",
            "requirements": ["Drop Holder element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 101: It was Abandoned Anyway
        "It was Abandoned Anyway": {
            "description": "Destroy a dwelling.",
            "requirements": ["Abandoned Dwelling element"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 102: Ruined Ghost Town
        "Ruined Ghost Town": {
            "description": "Destroy 5 dwellings.",
            "requirements": ["Abandoned Dwelling element"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 103: Ages Old Memories
        "Ages Old Memories": {
            "description": "Unlock a wizard tower.",
            "requirements": ["Wizard Tower element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 104: Almost Ruined
        "Almost Ruined": {
            "description": "Leave a monster nest at 1 hit point at the end of ...",
            "requirements": ["Monster Nest element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 105: Resourceful
        "Resourceful": {
            "description": "Reach 5.000 mana harvested from shards through all...",
            "requirements": ["Mana Shard element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 108: Not Worth It
        "Not Worth It": {
            "description": "Harvest 9.000 mana from a corrupted mana shard.",
            "requirements": ["Corrupted Mana Shard element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 109: Come Out
        "Come Out": {
            "description": "Lure 20 swarmlings out of a sleeping hive.",
            "requirements": ["Sleeping Hive element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 111: Precious
        "Precious": {
            "description": "Get a gem from a drop holder.",
            "requirements": ["Drop Holder element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 112: Dry Puddle
        "Dry Puddle": {
            "description": "Harvest all mana from a mana shard.",
            "requirements": ["Mana Shard element"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 113: Extorted
        "Extorted": {
            "description": "Harvest all mana from 3 mana shards.",
            "requirements": ["Mana Shard element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 116: Early Harvest
        "Early Harvest": {
            "description": "Harvest 2.500 mana from shards before wave 3 start...",
            "requirements": ["Mana Shard element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 117: Need More Rage
        "Need More Rage": {
            "description": "Upgrade a gem in the enraging socket.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 118: Blood on my Hands
        "Blood on my Hands": {
            "description": "Reach 20.000 monsters killed through all the battl...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 121: Broken Seal
        "Broken Seal": {
            "description": "Free a sealed gem.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 122: First Blood
        "First Blood": {
            "description": "Kill a monster.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 123: Puncturing Shots
        "Puncturing Shots": {
            "description": "Deliver 75 one hit kills.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 126: Absolute Zero
        "Absolute Zero": {
            "description": "Kill 273 frozen monsters.",
            "requirements": ["Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 127: Ensnared
        "Ensnared": {
            "description": "Kill 12 monsters with gems in traps.",
            "requirements": ["Traps skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 130: From Above
        "From Above": {
            "description": "Kill 40 monsters with gem bombs and wasps.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 132: Getting Wet
        "Getting Wet": {
            "description": "Beat 30 waves.",
            "requirements": ["minWave: 30"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 137: Smoke in the Sky
        "Smoke in the Sky": {
            "description": "Reach 20 non-monsters killed through all the battl...",
            "requirements": ["Ritual trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 140: Pest Control
        "Pest Control": {
            "description": "Kill 333 swarmlings.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 142: Angry Wasps
        "Angry Wasps": {
            "description": "Reach 1.000 gem wasp kills through all the battles...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 146: Purged
        "Purged": {
            "description": "Kill 179 marked monsters.",
            "requirements": ["Marked Monster element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 147: Hint of Darkness
        "Hint of Darkness": {
            "description": "Kill 189 twisted monsters.",
            "requirements": ["Twisted Monster element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 148: Exorcism
        "Exorcism": {
            "description": "Kill 199 possessed monsters.",
            "requirements": ["Possessed Monster element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 150: Bone Shredder
        "Bone Shredder": {
            "description": "Kill 600 monsters before wave 12 starts.",
            "requirements": ["Atleast 600 monsters before wave 10"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 152: No Use of Vitality
        "No Use of Vitality": {
            "description": "Kill a monster having at least 20.000 hit points.",
            "requirements": ["A monster with atleast 20.000hp"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 153: Through All Layers
        "Through All Layers": {
            "description": "Kill a monster having at least 200 armor.",
            "requirements": ["A monster with atleast 200 armor"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 155: Lots of Scratches
        "Lots of Scratches": {
            "description": "Reach a kill chain of 300.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 158: Thin Ice
        "Thin Ice": {
            "description": "Kill 20 frozen monsters with gems in traps.",
            "requirements": ["Freeze skill", "Traps skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 159: Doom Drop
        "Doom Drop": {
            "description": "Kill a possessed giant with barrage.",
            "requirements": ["Barrage skill", "Possessed Monster element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 160: Out of Nowhere
        "Out of Nowhere": {
            "description": "Kill a whited out possessed monster with bolt.",
            "requirements": ["Bolt skill", "Whiteout skill", "Possessed Monster element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 162: Trapland
        "Trapland": {
            "description": "And it's bloody too",
            "requirements": ["Traps skill", "Complete a level using only traps and no poison gems"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 163: I Saw Something
        "I Saw Something": {
            "description": "Kill an apparition.",
            "requirements": ["Ritual trait", "Apparition element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 165: Charged for the Kill
        "Charged for the Kill": {
            "description": "Reach 200 pylon kills through all the battles.",
            "requirements": ["Pylons skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 167: They Are Still Here
        "They Are Still Here": {
            "description": "Kill 2 apparitions.",
            "requirements": ["Ritual trait", "Apparition element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 168: Don't Touch it!
        "Don't Touch it!": {
            "description": "Kill a specter.",
            "requirements": ["Ritual trait", "Specter element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 169: I Warned You...
        "I Warned You...": {
            "description": "Kill a specter while it carries a gem.",
            "requirements": ["Ritual trait", "Specter element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 170: Gem Lust
        "Gem Lust": {
            "description": "Kill 2 specters.",
            "requirements": ["Ritual trait", "Specter element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 171: The Messenger Must Die
        "The Messenger Must Die": {
            "description": "Kill a shadow.",
            "requirements": ["Ritual trait", "Shadow element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 172: Twice the Terror
        "Twice the Terror": {
            "description": "Kill 2 shadows.",
            "requirements": ["Ritual trait", "Shadow element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 174: Bye Bye Hideous
        "Bye Bye Hideous": {
            "description": "Kill a spire.",
            "requirements": ["Ritual trait", "Spire element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 175: Dual Downfall
        "Dual Downfall": {
            "description": "Kill 2 spires.",
            "requirements": ["Ritual trait", "Spire element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 176: Something Special
        "Something Special": {
            "description": "Reach 2.000 monsters with special properties kille...",
            "requirements": ["Possessed Monster element", "Twisted Monster element", "Marked Monster element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 177: Violet Ray
        "Violet Ray": {
            "description": "Kill 20 frozen monsters with beam.",
            "requirements": ["Beam skill", "Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 178: Snow Blower
        "Snow Blower": {
            "description": "Kill 20 frozen monsters with barrage.",
            "requirements": ["Barrage skill", "Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 179: Shattering
        "Shattering": {
            "description": "Kill 90 frozen monsters with bolt.",
            "requirements": ["Bolt skill", "Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 182: Jinx Blast
        "Jinx Blast": {
            "description": "Kill 30 whited out monsters with bolt.",
            "requirements": ["Bolt skill", "Whiteout skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 183: Blind Hit
        "Blind Hit": {
            "description": "Kill 30 whited out monsters with beam.",
            "requirements": ["Beam skill", "Whiteout skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 184: Can't Crawl Away
        "Can't Crawl Away": {
            "description": "Kill 30 whited out monsters with barrage.",
            "requirements": ["Barrage skill", "Whiteout skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 188: Avenged
        "Avenged": {
            "description": "Kill 15 monsters carrying orblets.",
            "requirements": ["Orb of Presence skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 189: Ice Stand
        "Ice Stand": {
            "description": "Kill 5 frozen monsters carrying orblets.",
            "requirements": ["Freeze skill", "Orb of Presence skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 190: Wash Away
        "Wash Away": {
            "description": "Kill 110 monsters while it's raining.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 191: Acid Rain
        "Acid Rain": {
            "description": "Kill 85 poisoned monsters while it's raining.",
            "requirements": ["Poison skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 192: Frozen Grave
        "Frozen Grave": {
            "description": "Kill 220 monsters while it's snowing.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 193: Snow Dust
        "Snow Dust": {
            "description": "Kill 95 frozen monsters while it's snowing.",
            "requirements": ["Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 194: Out of Misery
        "Out of Misery": {
            "description": "Kill a monster that is whited out, poisoned, froze...",
            "requirements": ["Freeze skill", "Poison skill", "Slowing skill", "Whiteout skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 195: Overheated
        "Overheated": {
            "description": "Kill a giant with beam shot.",
            "requirements": ["Beam skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 197: Almost
        "Almost": {
            "description": "Kill a monster with shots blinking to the monster ...",
            "requirements": ["Watchtower element", "Wizard hunter"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 198: Like a Necro
        "Like a Necro": {
            "description": "Kill 25 monsters with frozen corpse explosion.",
            "requirements": ["Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 200: Hedgehog
        "Hedgehog": {
            "description": "Kill a swarmling having at least 100 armor.",
            "requirements": ["a swarmling with atleast 100 armor"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 202: Ful Ir
        "Ful Ir": {
            "description": "Blast like a fireball",
            "requirements": ["Kill 15 monsters simultaneously with 1 gem bomb"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 203: Stirring Up the Nest
        "Stirring Up the Nest": {
            "description": "Deliver gem bomb and wasp kills only.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 204: Green Vial
        "Green Vial": {
            "description": "Have more than 75% of the monster kills caused by ...",
            "requirements": ["Poison skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 205: Troll's Eye
        "Troll's Eye": {
            "description": "Kill a giant with one shot.",
            "requirements": ["Bolt skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 206: Crunchy Bites
        "Crunchy Bites": {
            "description": "Kill 160 frozen swarmlings.",
            "requirements": ["Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 207: Time Bent
        "Time Bent": {
            "description": "Have 90 monsters slowed at the same time.",
            "requirements": ["Slowing skill"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 208: Breath of Cold
        "Breath of Cold": {
            "description": "Have 90 monsters frozen at the same time.",
            "requirements": ["Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 209: Oh Ven
        "Oh Ven": {
            "description": "Spread the poison",
            "requirements": ["Poison skill", "90 monsters poisoned at the same time"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 210: Meet the Spartans
        "Meet the Spartans": {
            "description": "Have 300 monsters on the battlefield at the same t...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 213: Stumbling
        "Stumbling": {
            "description": "Hit the same monster with traps 100 times.",
            "requirements": ["Traps skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 214: Overpecked
        "Overpecked": {
            "description": "Deal 100 gem wasp stings to the same monster.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 215: Teleport Lag
        "Teleport Lag": {
            "description": "Banish a monster at least 5 times.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 216: Pointed Pain
        "Pointed Pain": {
            "description": "Deal 50 gem wasp stings to creatures.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 218: Roof Knocking
        "Roof Knocking": {
            "description": "Deal 20 gem wasp stings to buildings.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 223: Brought Some Mana
        "Brought Some Mana": {
            "description": "Have 5.000 initial mana.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 225: Mana Trader
        "Mana Trader": {
            "description": "Salvage 8.000 mana from gems.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 226: Filled 5 Times
        "Filled 5 Times": {
            "description": "Reach mana pool level 5.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 232: Your Mana is Mine
        "Your Mana is Mine": {
            "description": "Leech 10.000 mana with gems.",
            "requirements": ["Mana Leech skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 233: Finders
        "Finders": {
            "description": "Gain 200 mana from drops.",
            "requirements": ["Mana Shard element", "Corrupted Mana Shard element", "Drop Holder element", "Apparition element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 235: Ouch!
        "Ouch!": {
            "description": "Spend 900 mana on banishment.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 237: The Horror
        "The Horror": {
            "description": "Lose 3.333 mana to shadows.",
            "requirements": ["Ritual trait", "Shadow element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 238: Amplification
        "Amplification": {
            "description": "Spend 18.000 mana on amplifiers.",
            "requirements": ["Amplifiers skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 239: Ice Snap
        "Ice Snap": {
            "description": "Gain 90 xp with Freeze spell crowd hits.",
            "requirements": ["Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 241: Limited Vision
        "Limited Vision": {
            "description": "Gain 100 xp with Whiteout spell crowd hits.",
            "requirements": ["Whiteout skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 243: Chilling Edges
        "Chilling Edges": {
            "description": "Gain 140 xp with Ice Shards spell crowd hits.",
            "requirements": ["Ice Shards skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 245: Battle Heat
        "Battle Heat": {
            "description": "Gain 200 xp with kill chains.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 250: Adventurer
        "Adventurer": {
            "description": "Gain 600 xp from drops.",
            "requirements": ["Apparition element", "Corrupted Mana Shard element", "Drop Holder element", "Mana Shard element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 251: Fierce Encounter
        "Fierce Encounter": {
            "description": "Reach -8% decreased banishment cost with your orb.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 254: Stinging Sphere
        "Stinging Sphere": {
            "description": "Deliver 100 banishments with your orb.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 257: Armored Orb
        "Armored Orb": {
            "description": "Strengthen your orb by dropping a gem on it.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 258: Added Protection
        "Added Protection": {
            "description": "Strengthen your orb with a gem in an amplifier.",
            "requirements": ["Amplifiers skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 259: Safe and Secure
        "Safe and Secure": {
            "description": "Strengthen your orb with 7 gems in amplifiers.",
            "requirements": ["Amplifiers skill", "gemCount: 7"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 260: Well Defended
        "Well Defended": {
            "description": "Don't let any monster touch your orb for 20 beaten...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 263: Awakening
        "Awakening": {
            "description": "Activate a shrine.",
            "requirements": ["Shrine element"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 264: Earthquake
        "Earthquake": {
            "description": "Activate shrines a total of 4 times.",
            "requirements": ["Shrine element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 266: Double Strike
        "Double Strike": {
            "description": "Activate the same shrine 2 times.",
            "requirements": ["Shrine element"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 269: Shovel Swing
        "Shovel Swing": {
            "description": "Hit 15 frozen monsters with shrines.",
            "requirements": ["Freeze skill", "Shrine element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 271: Salvation
        "Salvation": {
            "description": "Hit 150 whited out monsters with shrines.",
            "requirements": ["Whiteout skill", "Shrine element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 283: Long Lasting
        "Long Lasting": {
            "description": "Reach 500 poison kills through all the battles.",
            "requirements": ["Poison skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 290: Strike Anywhere
        "Strike Anywhere": {
            "description": "Cast a strike spell.",
            "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 291: Scare Tactics
        "Scare Tactics": {
            "description": "Cast 5 strike spells.",
            "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 293: Fire Away
        "Fire Away": {
            "description": "Cast a gem enhancement spell.",
            "requirements": ["Bolt skill", "Beam skill", "Barrage skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 294: Dual Pulse
        "Dual Pulse": {
            "description": "Have 2 beam enhanced gems at the same time.",
            "requirements": ["Beam skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 298: Double Punch
        "Double Punch": {
            "description": "Have 2 bolt enhanced gems at the same time.",
            "requirements": ["Bolt skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 301: Clear Sky
        "Clear Sky": {
            "description": "Beat 120 waves and don't use any strike spells.",
            "requirements": ["minWave: 120"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 302: Unsupportive
        "Unsupportive": {
            "description": "Reach 100 beacons destroyed through all the battle...",
            "requirements": ["Beacon element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 304: Basic Gem Tactics
        "Basic Gem Tactics": {
            "description": "Beat 120 waves and don't use any gem enhancement s...",
            "requirements": ["minWave: 120"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 308: Purist
        "Purist": {
            "description": "Beat 120 waves and don't use any strike or gem enh...",
            "requirements": ["minWave: 120"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 309: Freezing Wounds
        "Freezing Wounds": {
            "description": "Freeze a monster 3 times.",
            "requirements": ["Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 311: Ablatio Retinae
        "Ablatio Retinae": {
            "description": "Whiteout 111 whited out monsters.",
            "requirements": ["Whiteout skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 312: Even if You Thaw
        "Even if You Thaw": {
            "description": "Whiteout 120 frozen monsters.",
            "requirements": ["Freeze skill", "Whiteout skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 313: Hold Still
        "Hold Still": {
            "description": "Freeze 130 whited out monsters.",
            "requirements": ["Freeze skill", "Whiteout skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 314: Refrost
        "Refrost": {
            "description": "Freeze 111 frozen monsters.",
            "requirements": ["Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 315: Slow Creep
        "Slow Creep": {
            "description": "Poison 130 whited out monsters.",
            "requirements": ["Poison skill", "Whiteout skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 316: Inedible
        "Inedible": {
            "description": "Poison 111 frozen monsters.",
            "requirements": ["Freeze skill", "Poison skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 319: Shattered Orb
        "Shattered Orb": {
            "description": "Lose a battle.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 320: Ice Cube
        "Ice Cube": {
            "description": "Have a Maximum Charge of 300% for the Freeze Spell...",
            "requirements": ["Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 321: Barrage Battery
        "Barrage Battery": {
            "description": "Have a Maximum Charge of 300% for the Barrage Spel...",
            "requirements": ["Barrage skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 322: Call in the Wave!
        "Call in the Wave!": {
            "description": "Call a wave early.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 323: Short Tempered
        "Short Tempered": {
            "description": "Call 5 waves early.",
            "requirements": ["minWave: 5"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 327: Socketed Rage
        "Socketed Rage": {
            "description": "Enrage a wave.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 331: Wave Pecking
        "Wave Pecking": {
            "description": "Summon 20 monsters by enraging waves.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 335: Ten Angry Waves
        "Ten Angry Waves": {
            "description": "Enrage 10 waves.",
            "requirements": ["minWave: 10"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 341: Buzz Feed
        "Buzz Feed": {
            "description": "Have 99 gem wasps on the battlefield.",
            "requirements": ["gemCount: 99"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 342: Boom
        "Boom": {
            "description": "Throw a gem bomb.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 343: Bang
        "Bang": {
            "description": "Throw 30 gem bombs.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 344: Getting Rid of Them
        "Getting Rid of Them": {
            "description": "Drop 48 gem bombs on beacons.",
            "requirements": ["Beacon element", "gemCount: 48"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 345: Core Pouch
        "Core Pouch": {
            "description": "Have 100 shadow cores at the start of the battle.",
            "requirements": ["Shadow Core element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 346: Core Pack
        "Core Pack": {
            "description": "Find 20 shadow cores.",
            "requirements": ["Shadow Core element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 349: Blastwave
        "Blastwave": {
            "description": "Reach 1.000 shrine kills through all the battles.",
            "requirements": ["Shrine element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 351: No Time to Rest
        "No Time to Rest": {
            "description": "Have the Haste trait set to level 6 or higher and ...",
            "requirements": ["Haste trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 352: Tumbling Billows
        "Tumbling Billows": {
            "description": "Have the Swarmling Domination trait set to level 6...",
            "requirements": ["Swarmling Domination trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 353: Hateful
        "Hateful": {
            "description": "Have the Hatred trait set to level 6 or higher and...",
            "requirements": ["Hatred trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 354: On the Shoulders of Giants
        "On the Shoulders of Giants": {
            "description": "Have the Giant Domination trait set to level 6 or ...",
            "requirements": ["Giant Domination trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 355: Stronger Than Before
        "Stronger Than Before": {
            "description": "Set corrupted banishment to level 12 and banish a ...",
            "requirements": ["Corrupted Banishment trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 364: First Puzzle Piece
        "First Puzzle Piece": {
            "description": "Find a talisman fragment.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 365: Fortunate
        "Fortunate": {
            "description": "Find 2 talisman fragments.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 367: Regaining Knowledge
        "Regaining Knowledge": {
            "description": "Acquire 5 skills.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 368: Skillful
        "Skillful": {
            "description": "Acquire and raise all skills to level 5 or above.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 369: So Enduring
        "So Enduring": {
            "description": "Have the Adaptive Carapace trait set to level 6 or...",
            "requirements": ["Adaptive Carapace trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 370: Deluminati
        "Deluminati": {
            "description": "Have the Dark Masonry trait set to level 6 or high...",
            "requirements": ["Dark Masonry trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 371: Crowd Control
        "Crowd Control": {
            "description": "Have the Overcrowd trait set to level 6 or higher ...",
            "requirements": ["Overcrowd trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 372: Guarding the Fallen Gate
        "Guarding the Fallen Gate": {
            "description": "Have the Corrupted Banishment trait set to level 6...",
            "requirements": ["Corrupted Banishment trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 373: Time to Rise
        "Time to Rise": {
            "description": "Have the Awakening trait set to level 6 or higher ...",
            "requirements": ["Awakening trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 374: Ionized Air
        "Ionized Air": {
            "description": "Have the Insulation trait set to level 6 or higher...",
            "requirements": ["Insulation trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 375: Face the Phobia
        "Face the Phobia": {
            "description": "Have the Swarmling Parasites trait set to level 6 ...",
            "requirements": ["Swarmling Parasites trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 376: Just Fire More at Them
        "Just Fire More at Them": {
            "description": "Have the Thick Air trait set to level 6 or higher ...",
            "requirements": ["Thick Air trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 377: Knowledge Seeker
        "Knowledge Seeker": {
            "description": "Open a wizard stash.",
            "requirements": ["Wizard Stash element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 378: Stash No More
        "Stash No More": {
            "description": "Destroy a previously opened wizard stash.",
            "requirements": ["Wizard Stash element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 379: Spectrin Tetramer
        "Spectrin Tetramer": {
            "description": "Have the Vital Link trait set to level 6 or higher...",
            "requirements": ["Vital Link trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 380: In for a Trait
        "In for a Trait": {
            "description": "Activate a battle trait.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 381: High Stakes
        "High Stakes": {
            "description": "Set a battle trait to level 12.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 382: White Wand
        "White Wand": {
            "description": "Reach wizard level 10.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 390: Let's Have a Look
        "Let's Have a Look": {
            "description": "Open a drop holder.",
            "requirements": ["Drop Holder element"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 391: Raindrop
        "Raindrop": {
            "description": "Drop 18 gem bombs while it's raining.",
            "requirements": ["gemCount: 18"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 392: Snowball
        "Snowball": {
            "description": "Drop 27 gem bombs while it's snowing.",
            "requirements": ["gemCount: 27"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 393: That one!
        "That one!": {
            "description": "Select a monster.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 394: There it is!
        "There it is!": {
            "description": "Select a building.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 395: Not So Fast
        "Not So Fast": {
            "description": "Freeze a specter.",
            "requirements": ["Freeze skill", "Ritual trait", "Specter element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 396: Under Pressure
        "Under Pressure": {
            "description": "Shoot down 340 shadow projectiles.",
            "requirements": ["Ritual trait", "Shadow element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 397: Thin Them Out
        "Thin Them Out": {
            "description": "Have the Strength in Numbers trait set to level 6 ...",
            "requirements": ["Strength in Numbers trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 398: Forces Within my Comprehension
        "Forces Within my Comprehension": {
            "description": "Have the Ritual trait set to level 6 or higher and...",
            "requirements": ["Ritual trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 399: Nature Takes Over
        "Nature Takes Over": {
            "description": "Have no own buildings on the field at the end of t...",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 400: Sharpened
        "Sharpened": {
            "description": "Enhance a gem in a trap.",
            "requirements": ["Traps skill", "Beam skill", "Bolt skill", "Barrage skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 401: Second Thoughts
        "Second Thoughts": {
            "description": "Add a different enhancement on an enhanced gem.",
            "requirements": ["Bolt skill", "Beam skill", "Barrage skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 402: Special Purpose
        "Special Purpose": {
            "description": "Change the target priority of a gem.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 411: Flying Multikill
        "Flying Multikill": {
            "description": "Destroy 1 apparition, 1 specter, 1 wraith and 1 sh...",
            "requirements": ["Ritual trait", "Apparition element", "Shadow element", "Specter element", "Wraith element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 412: Weather Tower
        "Weather Tower": {
            "description": "Activate a shrine while raining.",
            "requirements": ["Shrine element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 413: Let it Go
        "Let it Go": {
            "description": "Leave an apparition alive.",
            "requirements": ["Ritual trait", "Apparition element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 414: Slow Drain
        "Slow Drain": {
            "description": "Deal 10.000 poison damage to a monster.",
            "requirements": ["Poison skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 415: In Flames
        "In Flames": {
            "description": "Kill 400 spawnlings.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 417: Black Blood
        "Black Blood": {
            "description": "Deal 5.000 poison damage to a shadow.",
            "requirements": ["Poison skill", "Ritual trait", "Shadow element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 418: Clean Orb
        "Clean Orb": {
            "description": "Win a battle without any monster getting to your o...",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 424: Twice the Blast
        "Twice the Blast": {
            "description": "Have 2 barrage enhanced gems at the same time.",
            "requirements": ["Barrage skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 428: Path of Splats
        "Path of Splats": {
            "description": "Kill 400 monsters.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 434: Icy Fingers
        "Icy Fingers": {
            "description": "Reach 500 strike spells cast through all the battl...",
            "requirements": ["Whiteout skill", "Freeze skill", "Ice Shards skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 438: Adept Enhancer
        "Adept Enhancer": {
            "description": "Reach 500 enhancement spells cast through all the ...",
            "requirements": ["Beam skill", "Bolt skill", "Barrage skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 442: Multifreeze
        "Multifreeze": {
            "description": "Reach 5.000 strike spell hits through all the batt...",
            "requirements": ["Ice Shards skill", "Whiteout skill", "Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 446: More Wounds
        "More Wounds": {
            "description": "Kill 125 bleeding monsters with barrage.",
            "requirements": ["Barrage skill", "Bleeding skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 447: Red Orange
        "Red Orange": {
            "description": "Leech 700 mana from bleeding monsters.",
            "requirements": ["Bleeding skill", "Mana Leech skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 451: Last Minute Mana
        "Last Minute Mana": {
            "description": "Leech 500 mana from poisoned monsters.",
            "requirements": ["Mana Leech skill", "Poison skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 455: Easy Kill
        "Easy Kill": {
            "description": "Kill 120 bleeding monsters.",
            "requirements": ["Bleeding skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 459: Wasp Defense
        "Wasp Defense": {
            "description": "Smash 3 jars of wasps before wave 3.",
            "requirements": ["Field X2"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 460: Skylark
        "Skylark": {
            "description": "Call every wave early in a battle.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 461: Mana First
        "Mana First": {
            "description": "Deplete a shard when there are more than 300 swarm...",
            "requirements": ["Mana Shard element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 462: Might Need it Later
        "Might Need it Later": {
            "description": "Enhance a gem in an amplifier.",
            "requirements": ["Amplifiers skill", "Bolt skill", "Beam skill", "Barrage skill"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 463: Enhancement Storage
        "Enhancement Storage": {
            "description": "Enhance a gem in the inventory.",
            "requirements": ["Bolt skill", "Beam skill", "Barrage skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 464: Why Not
        "Why Not": {
            "description": "Enhance a gem in the enraging socket.",
            "requirements": ["Bolt skill", "Beam skill", "Barrage skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 465: Eat my Light
        "Eat my Light": {
            "description": "Kill a wraith with a shrine strike.",
            "requirements": ["Ritual trait", "Shrine element", "Wraith element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 466: End of the Tunnel
        "End of the Tunnel": {
            "description": "Kill an apparition with a shrine strike.",
            "requirements": ["Ritual trait", "Apparition element", "Shrine element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 467: Healing Denied
        "Healing Denied": {
            "description": "Destroy 3 healing beacons.",
            "requirements": ["Beacon element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 468: Shieldbreaker
        "Shieldbreaker": {
            "description": "Destroy 3 shield beacons.",
            "requirements": ["Beacon element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 469: Deal Some Damage Too
        "Deal Some Damage Too": {
            "description": "Have 5 traps with bolt enhanced gems in them.",
            "requirements": ["Bolt skill", "Traps skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 470: Popped Eggs
        "Popped Eggs": {
            "description": "Kill a swarm queen with a bolt.",
            "requirements": ["Bolt skill", "Swarm Queen element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 471: Supply Line Cut
        "Supply Line Cut": {
            "description": "Kill a swarm queen with a barrage shell.",
            "requirements": ["Barrage skill", "Swarm Queen element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 472: Prismatic Takeaway
        "Prismatic Takeaway": {
            "description": "Have a specter steal a gem of 6 components.",
            "requirements": ["Critical Hit skill", "Mana Leech skill", "Bleeding skill", "Armor Tearing skill", "Poison skill", "Slowing skill", "Specter element", "gemCount: 6"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 473: Lots of Crit Hits
        "Lots of Crit Hits": {
            "description": "Have a pure critical hit gem with 2.000 hits.",
            "requirements": ["Critical Hit skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 474: Damage Support
        "Damage Support": {
            "description": "Have a pure bleeding gem with 2.500 hits.",
            "requirements": ["Bleeding skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 475: Shred Some Armor
        "Shred Some Armor": {
            "description": "Have a pure armor tearing gem with 3.000 hits.",
            "requirements": ["Armor Tearing skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 476: Epidemic Gem
        "Epidemic Gem": {
            "description": "Have a pure poison gem with 3.500 hits.",
            "requirements": ["Poison skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 477: Army Glue
        "Army Glue": {
            "description": "Have a pure slowing gem with 4.000 hits.",
            "requirements": ["Slowing skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 478: Got the Price Back
        "Got the Price Back": {
            "description": "Have a pure mana leeching gem with 4.500 hits.",
            "requirements": ["Mana Leech skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 479: Frosting
        "Frosting": {
            "description": "Freeze a specter while it's snowing.",
            "requirements": ["Freeze skill", "Ritual trait", "Specter element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 480: Unarmed
        "Unarmed": {
            "description": "Have no gems when wave 20 starts.",
            "requirements": ["minWave: 20"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 481: Rage Control
        "Rage Control": {
            "description": "Kill 400 enraged swarmlings with barrage.",
            "requirements": ["Barrage skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 482: Can't Take Any Risks
        "Can't Take Any Risks": {
            "description": "Kill a bleeding giant with poison.",
            "requirements": ["Bleeding skill", "Poison skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 483: Marmalade
        "Marmalade": {
            "description": "Don't destroy any of the jars of wasps.",
            "requirements": ["Field X2"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 484: By Three They Go
        "By Three They Go": {
            "description": "Have 3 of your gems destroyed or stolen.",
            "requirements": ["Ritual trait", "Specter element", "Watchtower element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 488: Near Death
        "Near Death": {
            "description": "Suffer mana loss from a shadow projectile when und...",
            "requirements": ["Shadow element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 489: Glitter Cloud
        "Glitter Cloud": {
            "description": "Kill an apparition with a gem bomb.",
            "requirements": ["Ritual trait", "Apparition element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 490: Final Touch
        "Final Touch": {
            "description": "Kill a spire with a gem wasp.",
            "requirements": ["Ritual trait", "Spire element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 491: Glowing Armada
        "Glowing Armada": {
            "description": "Have 240 gem wasps on the battlefield when the bat...",
            "requirements": ["gemCount: 240"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 492: Am I a Joke to You?
        "Am I a Joke to You?": {
            "description": "Start an enraged wave early while there is a wizar...",
            "requirements": ["Wizard hunter"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 493: Rageroom
        "Rageroom": {
            "description": "Build 100 walls and start 100 enraged waves.",
            "requirements": ["Wall element", "minWave: 100"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 494: One Hit is All it Takes
        "One Hit is All it Takes": {
            "description": "Kill a wraith with one hit.",
            "requirements": ["Ritual trait", "Wraith element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 495: Whacked
        "Whacked": {
            "description": "Kill a specter with one hit.",
            "requirements": ["Ritual trait", "Specter element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 496: Farewell
        "Farewell": {
            "description": "Kill an apparition with one hit.",
            "requirements": ["Ritual trait", "Apparition element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 497: No Honor Among Thieves
        "No Honor Among Thieves": {
            "description": "Have a watchtower kill a specter.",
            "requirements": ["Ritual trait", "Specter element", "Watchtower element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 498: You Could Be my Apprentice
        "You Could Be my Apprentice": {
            "description": "Have a watchtower kill a wizard hunter.",
            "requirements": ["Watchtower element", "Wizard hunter"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 499: Get Them
        "Get Them": {
            "description": "Have a watchtower kill 39 monsters.",
            "requirements": ["Watchtower element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 500: Helping Hand
        "Helping Hand": {
            "description": "Have a watchtower kill a possessed monster.",
            "requirements": ["Possessed Monster element", "Watchtower element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 501: Going for the Weak
        "Going for the Weak": {
            "description": "Have a watchtower kill a poisoned monster.",
            "requirements": ["Poison skill", "Watchtower element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 502: That Was Rude
        "That Was Rude": {
            "description": "Lose a gem with more than 1.000 hits to a watchtow...",
            "requirements": ["Watchtower element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 503: Multiline
        "Multiline": {
            "description": "Have at least 5 different talisman properties.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 507: Great Survivor
        "Great Survivor": {
            "description": "Kill a monster from wave 1 when wave 20 has alread...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 509: A Bright Start
        "A Bright Start": {
            "description": "Have 30 fields lit in Journey mode.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 513: Getting My Feet Wet
        "Getting My Feet Wet": {
            "description": "Have 20 fields lit in Endurance mode.",
            "requirements": ["Endurance"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 517: Disciple
        "Disciple": {
            "description": "Have 10 fields lit in Trial mode.",
            "requirements": ["Trial"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 521: Catch and Release
        "Catch and Release": {
            "description": "Destroy a jar of wasps, but don't have any wasp ki...",
            "requirements": ["Field X2"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 522: No You Won't!
        "No You Won't!": {
            "description": "Destroy a watchtower before it could fire.",
            "requirements": ["Bolt skill", "Watchtower element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 523: Bleeding For Everyone
        "Bleeding For Everyone": {
            "description": "Enhance a pure bleeding gem having random priority...",
            "requirements": ["Beam skill", "Bleeding skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 524: Just Breathe In
        "Just Breathe In": {
            "description": "Enhance a pure poison gem having random priority w...",
            "requirements": ["Beam skill", "Poison skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 525: Slow Motion
        "Slow Motion": {
            "description": "Enhance a pure slowing gem having random priority ...",
            "requirements": ["Beam skill", "Slowing skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 526: Disco Ball
        "Disco Ball": {
            "description": "Have a gem of 6 components in a lantern.",
            "requirements": ["Lanterns skill", "Critical Hit skill", "Mana Leech skill", "Bleeding skill", "Armor Tearing skill", "Poison skill", "Slowing skill", "gemCount: 6"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 527: Eggnog
        "Eggnog": {
            "description": "Crack a monster egg open while time is frozen.",
            "requirements": ["Swarm Queen element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 528: Instant Spawn
        "Instant Spawn": {
            "description": "Have a shadow spawn a monster while time is frozen...",
            "requirements": ["Ritual trait", "Shadow element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 529: Enough Frozen Time Trickery
        "Enough Frozen Time Trickery": {
            "description": "Kill a shadow while time is frozen.",
            "requirements": ["Shadow element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 530: In a Blink of an Eye
        "In a Blink of an Eye": {
            "description": "Kill 100 monsters while time is frozen.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 531: Stay Some More
        "Stay Some More": {
            "description": "Cast freeze on an apparition 3 times.",
            "requirements": ["Freeze skill", "Ritual trait", "Apparition element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 532: Twice the Steepness
        "Twice the Steepness": {
            "description": "Kill 170 monsters while there are at least 2 wrait...",
            "requirements": ["Ritual trait", "Wraith element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 536: Derangement
        "Derangement": {
            "description": "Decrease the range of a gem.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 537: Couldn't Decide
        "Couldn't Decide": {
            "description": "Kill 400 monsters with prismatic gem wasps.",
            "requirements": ["Critical Hit skill", "Mana Leech skill", "Bleeding skill", "Armor Tearing skill", "Poison skill", "Slowing skill", "gemCount: 6"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 542: Heavily Modified
        "Heavily Modified": {
            "description": "Activate all mods.",
            "requirements": ["Requires \"hidden codes\""],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 543: You're Safe With Me
        "You're Safe With Me": {
            "description": "Win a battle with at least 10 orblets remaining.",
            "requirements": ["Orb of Presence skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 545: No More Rounds
        "No More Rounds": {
            "description": "Kill 60 banished monsters with shrines.",
            "requirements": ["Shrine element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 549: Come Again
        "Come Again": {
            "description": "Kill 190 banished monsters.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 557: So Attached
        "So Attached": {
            "description": "Win a Trial battle without losing any orblets.",
            "requirements": ["Trial"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 558: Impressive
        "Impressive": {
            "description": "Win a Trial battle without any monster reaching yo...",
            "requirements": ["Trial"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 559: Get This Done Quick
        "Get This Done Quick": {
            "description": "Win a Trial battle with at least 3 waves started e...",
            "requirements": ["minWave: 3", "Trial"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 560: Too Easy
        "Too Easy": {
            "description": "Win a Trial battle with at least 3 waves enraged.",
            "requirements": ["minWave: 3", "Trial"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 561: Has Stood Long Enough
        "Has Stood Long Enough": {
            "description": "Destroy a monster nest after the last wave has sta...",
            "requirements": ["Monster Nest element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 562: Twice the Shock
        "Twice the Shock": {
            "description": "Hit the same monster 2 times with shrines.",
            "requirements": ["Shrine element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 563: Mana is All I Need
        "Mana is All I Need": {
            "description": "Win a battle with no skill point spent and a battl...",
            "requirements": ["Any battle trait\n\n"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 564: Mastery
        "Mastery": {
            "description": "Raise a skill to level 70.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 565: Miniblasts
        "Miniblasts": {
            "description": "Tear a total of 1.250 armor with wasp stings.",
            "requirements": ["Armor Tearing skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 569: Elementary
        "Elementary": {
            "description": "Beat 30 waves using at most grade 2 gems.",
            "requirements": ["minWave: 30"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 573: Eggcracker
        "Eggcracker": {
            "description": "Don't let any egg laid by a swarm queen to hatch o...",
            "requirements": ["Swarm Queen element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 574: Let Them Hatch
        "Let Them Hatch": {
            "description": "Don't crack any egg laid by a swarm queen.",
            "requirements": ["Swarm Queen element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 575: Well Trained for This
        "Well Trained for This": {
            "description": "Kill a wraith with a shot fired by a gem having at...",
            "requirements": ["Ritual trait", "Wraith element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 576: Sharp Shot
        "Sharp Shot": {
            "description": "Kill a shadow with a shot fired by a gem having at...",
            "requirements": ["Ritual trait", "Shadow element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 577: Double Splash
        "Double Splash": {
            "description": "Kill two non-monster creatures with one gem bomb.",
            "requirements": ["Ritual trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 578: Omnibomb
        "Omnibomb": {
            "description": "Destroy a building and a non-monster creature with...",
            "requirements": ["Ritual trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 579: Urban Warfare
        "Urban Warfare": {
            "description": "Destroy a dwelling and kill a monster with one gem...",
            "requirements": ["Abandoned Dwelling element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 580: Keep Losing Keep Harvesting
        "Keep Losing Keep Harvesting": {
            "description": "Deplete a mana shard while there is a shadow on th...",
            "requirements": ["Ritual trait", "Mana Shard element", "Shadow element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 581: One Less Problem
        "One Less Problem": {
            "description": "Destroy a monster nest while there is a wraith on ...",
            "requirements": ["Ritual trait", "Monster Nest element", "Wraith element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 582: Tomb No Matter What
        "Tomb No Matter What": {
            "description": "Open a tomb while there is a spire on the battlefi...",
            "requirements": ["Ritual trait", "Spire element", "Tomb element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 583: Landing Spot
        "Landing Spot": {
            "description": "Demolish 20 or more walls with falling spires.",
            "requirements": ["Ritual trait", "Spire element", "Wall element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 584: Rising Tide
        "Rising Tide": {
            "description": "Banish 150 monsters while there are 2 or more wrai...",
            "requirements": ["Ritual trait", "Wraith element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 585: Mana Blinded
        "Mana Blinded": {
            "description": "Leech 900 mana from whited out monsters.",
            "requirements": ["Mana Leech skill", "Whiteout skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 589: Double Sharded
        "Double Sharded": {
            "description": "Cast 2 ice shards on the same monster.",
            "requirements": ["Ice Shards skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 593: Busted
        "Busted": {
            "description": "Destroy a full health possession obelisk with one ...",
            "requirements": ["Obelisk element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 594: Stingy Downfall
        "Stingy Downfall": {
            "description": "Deal 400 wasp stings to a spire.",
            "requirements": ["Ritual trait", "Spire element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 595: Put Those Down Now!
        "Put Those Down Now!": {
            "description": "Have 10 orblets carried by monsters at the same ti...",
            "requirements": ["Orb of Presence skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 596: Locked and Loaded
        "Locked and Loaded": {
            "description": "Have 3 pylons charged up to 3 shots each.",
            "requirements": ["Pylons skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 597: Return of Investment
        "Return of Investment": {
            "description": "Leech 900 mana with a grade 1 gem.",
            "requirements": ["Mana Leech skill", "minGemGrade: 1"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 601: Groundfill
        "Groundfill": {
            "description": "Demolish a trap.",
            "requirements": ["Traps skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 602: Vantage Point Down
        "Vantage Point Down": {
            "description": "Demolish a pylon.",
            "requirements": ["Pylons skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 603: Quicksave
        "Quicksave": {
            "description": "Instantly drop a gem to your inventory.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 604: Still No Match
        "Still No Match": {
            "description": "Destroy an omnibeacon.",
            "requirements": ["Beacon element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 605: Not So Omni Anymore
        "Not So Omni Anymore": {
            "description": "Destroy 10 omnibeacons.",
            "requirements": ["Beacon element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 606: Family Friendlier
        "Family Friendlier": {
            "description": "Kill 900 green blooded monsters.",
            "requirements": ["Requires \"hidden codes\""],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 610: Bath Bomb
        "Bath Bomb": {
            "description": "Kill 30 monsters with orblet explosions.",
            "requirements": ["Orb of Presence skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 614: Green Eyed Ninja
        "Green Eyed Ninja": {
            "description": "Entering: The Wilderness",
            "requirements": ["Field N1, U1 or R5"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 615: Splash Swim Splash
        "Splash Swim Splash": {
            "description": "Full of oxygen",
            "requirements": ["Click on water in a field\nRequires a field with water"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 616: Going Deviant
        "Going Deviant": {
            "description": "Rook to a9",
            "requirements": ["Scroll to edge of the world map"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 617: We Just Wanna Be Free
        "We Just Wanna Be Free": {
            "description": "More than blue triangles",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 618: Renzokuken
        "Renzokuken": {
            "description": "Break your frozen time gem bombing limits",
            "requirements": ["Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 619: Uraj and Khalis
        "Uraj and Khalis": {
            "description": "Activate the lanterns",
            "requirements": ["Lanterns skill", "Field H3"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 620: I Never Asked For This
        "I Never Asked For This": {
            "description": "All my aug points spent",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 621: Deckard Would Be Proud
        "Deckard Would Be Proud": {
            "description": "All I could get for a prismatic amulet",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 622: Hope has fallen
        "Hope has fallen": {
            "description": "Dismantled bunkhouses",
            "requirements": ["Field E3"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 623: Slime Block
        "Slime Block": {
            "description": "Nine slimeballs is all it takes",
            "requirements": ["A monster with atleast 20.000hp"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 624: Behold Aurora
        "Behold Aurora": {
            "description": "Go Igniculus and Light Ray (All)+++!",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 625: Rooting From Afar
        "Rooting From Afar": {
            "description": "Kill a gatekeeper fang with a barrage shell.",
            "requirements": ["Barrage skill", "Gatekeeper element", "Field A4"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 626: Spitting Darkness
        "Spitting Darkness": {
            "description": "Leave a gatekeeper fang alive until it can launch ...",
            "requirements": ["Gatekeeper element", "Field A4"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 627: Swift Death
        "Swift Death": {
            "description": "Kill the gatekeeper with a bolt.",
            "requirements": ["Bolt skill", "Gatekeeper element", "Field A4"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 628: Popped
        "Popped": {
            "description": "Kill at least 30 gatekeeper fangs.",
            "requirements": ["Gatekeeper element", "Field A4"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 629: Implosion
        "Implosion": {
            "description": "Kill a gatekeeper fang with a gem bomb.",
            "requirements": ["Gatekeeper element", "Field A4"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 630: That Was Your Last Move
        "That Was Your Last Move": {
            "description": "Kill a wizard hunter while it's attacking one of y...",
            "requirements": ["Wizard Hunter"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 631: Starter Pack
        "Starter Pack": {
            "description": "Add 8 talisman fragments to your shape collection.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 634: Shapeshifter
        "Shapeshifter": {
            "description": "Complete your talisman fragment shape collection.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 635: Enter The Gate
        "Enter The Gate": {
            "description": "Kill the gatekeeper.",
            "requirements": ["Gatekeeper element", "Field A4"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

    },

    "grindiness_2": {
        # ID 7: I Have Experience
        "I Have Experience": {
            "description": "Reach 50 battles won.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 11: So Early
        "So Early": {
            "description": "Reach 1.000 waves started early through all the ba...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 15: Riding the Waves
        "Riding the Waves": {
            "description": "Reach 1.000 waves beaten through all the battles.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 29: Prismatic
        "Prismatic": {
            "description": "Create a gem of 6 components.",
            "requirements": ["Critical Hit skill", "Mana Leech skill", "Bleeding skill", "Armor Tearing skill", "Poison skill", "Slowing skill", "gemCount: 6"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 44: Fifth Grader
        "Fifth Grader": {
            "description": "Create a grade 5 gem.",
            "requirements": ["minGemGrade: 5"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 52: Seen Battle
        "Seen Battle": {
            "description": "Have a grade 1 gem with 500 hits.",
            "requirements": ["minGemGrade: 1"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 58: Bazaar
        "Bazaar": {
            "description": "Have 30 gems on the battlefield.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 60: Major Shutdown
        "Major Shutdown": {
            "description": "Destroy 3 monster nests.",
            "requirements": ["Monster Nest element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 65: Ambitious Builder
        "Ambitious Builder": {
            "description": "Reach 500 structures built through all the battles...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 67: Settlement
        "Settlement": {
            "description": "Build 15 towers.",
            "requirements": ["Tower element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 72: Entrenched
        "Entrenched": {
            "description": "Build 20 traps.",
            "requirements": ["Traps skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 76: Power Flow
        "Power Flow": {
            "description": "Build 15 amplifiers.",
            "requirements": ["Amplifiers skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 78: Omelette
        "Omelette": {
            "description": "Reach 200 monster eggs cracked through all the bat...",
            "requirements": ["Swarm Queen element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 80: Confusion Junction
        "Confusion Junction": {
            "description": "Build 30 walls.",
            "requirements": ["Wall element"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 88: Tasting the Darkness
        "Tasting the Darkness": {
            "description": "Break 3 tombs open.",
            "requirements": ["Tomb element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 92: Nest Buster
        "Nest Buster": {
            "description": "Destroy 3 monster nests before wave 6.",
            "requirements": ["Monster Nest element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 106: Mana Tap
        "Mana Tap": {
            "description": "Reach 10.000 mana harvested from shards through al...",
            "requirements": ["Mana Shard element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 110: Come Out, Come Out
        "Come Out, Come Out": {
            "description": "Lure 100 swarmlings out of a sleeping hive.",
            "requirements": ["Sleeping Hive element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 119: Crimson Journal
        "Crimson Journal": {
            "description": "Reach 100.000 monsters killed through all the batt...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 124: Impaling Charges
        "Impaling Charges": {
            "description": "Deliver 250 one hit kills.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 128: Rough Path
        "Rough Path": {
            "description": "Kill 60 monsters with gems in traps.",
            "requirements": ["Traps skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 131: Thunderstruck
        "Thunderstruck": {
            "description": "Kill 120 monsters with gem bombs and wasps.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 136: Still Alive
        "Still Alive": {
            "description": "Beat 60 waves.",
            "requirements": ["minWave: 60"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 138: High Targets
        "High Targets": {
            "description": "Reach 100 non-monsters killed through all the batt...",
            "requirements": ["Ritual trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 143: Diabolic Trophy
        "Diabolic Trophy": {
            "description": "Kill 666 swarmlings.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 149: Stingy Cloud
        "Stingy Cloud": {
            "description": "Reach 5.000 gem wasp kills through all the battles...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 156: Carnage
        "Carnage": {
            "description": "Reach a kill chain of 600.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 166: Darkness Walk With Me
        "Darkness Walk With Me": {
            "description": "Kill 3 shadows.",
            "requirements": ["Ritual trait", "Shadow element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 180: White Ray
        "White Ray": {
            "description": "Kill 90 frozen monsters with beam.",
            "requirements": ["Beam skill", "Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 181: Icecracker
        "Icecracker": {
            "description": "Kill 90 frozen monsters with barrage.",
            "requirements": ["Barrage skill", "Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 185: Marked Targets
        "Marked Targets": {
            "description": "Reach 10.000 monsters with special properties kill...",
            "requirements": ["Possessed Monster element", "Twisted Monster element", "Marked Monster element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 201: Deathball
        "Deathball": {
            "description": "Reach 1.000 pylon kills through all the battles.",
            "requirements": ["Pylons skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 211: Crowded Queue
        "Crowded Queue": {
            "description": "Have 600 monsters on the battlefield at the same t...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 217: Needle Storm
        "Needle Storm": {
            "description": "Deal 350 gem wasp stings to creatures.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 219: Drumroll
        "Drumroll": {
            "description": "Deal 200 gem wasp stings to buildings.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 224: Well Prepared
        "Well Prepared": {
            "description": "Have 20.000 initial mana.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 227: Flows Through my Veins
        "Flows Through my Veins": {
            "description": "Reach mana pool level 10.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 234: Keepers
        "Keepers": {
            "description": "Gain 800 mana from drops.",
            "requirements": ["Apparition element", "Corrupted Mana Shard element", "Mana Shard element", "Drop Holder element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 236: It Hurts!
        "It Hurts!": {
            "description": "Spend 9.000 mana on banishment.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 240: Cold Wisdom
        "Cold Wisdom": {
            "description": "Gain 700 xp with Freeze spell crowd hits.",
            "requirements": ["Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 242: Bright Weakening
        "Bright Weakening": {
            "description": "Gain 1.200 xp with Whiteout spell crowd hits.",
            "requirements": ["Whiteout skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 244: Sliced Ice
        "Sliced Ice": {
            "description": "Gain 1.800 xp with Ice Shards spell crowd hits.",
            "requirements": ["Ice Shards skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 246: Bloodmaster
        "Bloodmaster": {
            "description": "Gain 1.200 xp with kill chains.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 252: Close Quarter
        "Close Quarter": {
            "description": "Reach -12% decreased banishment cost with your orb...",
            "requirements": ["Amplifiers skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 255: Thorned Sphere
        "Thorned Sphere": {
            "description": "Deliver 400 banishments with your orb.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 261: Tightly Secured
        "Tightly Secured": {
            "description": "Don't let any monster touch your orb for 60 beaten...",
            "requirements": ["minWave: 60"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 265: Addicted
        "Addicted": {
            "description": "Activate shrines a total of 12 times.",
            "requirements": ["Shrine element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 267: Power Node
        "Power Node": {
            "description": "Activate the same shrine 5 times.",
            "requirements": ["Shrine element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 270: Melting Pulse
        "Melting Pulse": {
            "description": "Hit 75 frozen monsters with shrines.",
            "requirements": ["Freeze skill", "Shrine element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 292: No Place to Hide
        "No Place to Hide": {
            "description": "Cast 25 strike spells.",
            "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 295: Friday Night
        "Friday Night": {
            "description": "Have 4 beam enhanced gems at the same time.",
            "requirements": ["Beam skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 299: Heavy Hitting
        "Heavy Hitting": {
            "description": "Have 4 bolt enhanced gems at the same time.",
            "requirements": ["Bolt skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 300: Necrotrophic
        "Necrotrophic": {
            "description": "Reach 1.000 poison kills through all the battles.",
            "requirements": ["Poison skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 303: No Beacon Zone
        "No Beacon Zone": {
            "description": "Reach 200 beacons destroyed through all the battle...",
            "requirements": ["Beacon element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 324: Restless
        "Restless": {
            "description": "Call 35 waves early.",
            "requirements": ["minWave: 35"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 332: Uninvited
        "Uninvited": {
            "description": "Summon 100 monsters by enraging waves.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 336: Rageout
        "Rageout": {
            "description": "Enrage 30 waves.",
            "requirements": ["minWave: 30"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 347: Core Pile
        "Core Pile": {
            "description": "Find 60 shadow cores.",
            "requirements": ["Shadow Core element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 357: Plentiful
        "Plentiful": {
            "description": "Have 1.000 shadow cores at the start of the battle...",
            "requirements": ["Shadow Core element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 363: Gearing Up
        "Gearing Up": {
            "description": "Have 5 fragments socketed in your talisman.",
            "requirements": [],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 366: Ground Luck
        "Ground Luck": {
            "description": "Find 3 talisman fragments.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 383: Yellow Wand
        "Yellow Wand": {
            "description": "Reach wizard level 20.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 384: Orange Wand
        "Orange Wand": {
            "description": "Reach wizard level 40.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 385: Green Wand
        "Green Wand": {
            "description": "Reach wizard level 60.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 404: Stormed Beacons
        "Stormed Beacons": {
            "description": "Destroy 15 beacons.",
            "requirements": ["Beacon element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 408: Hard Reset
        "Hard Reset": {
            "description": "Reach 5.000 shrine kills through all the battles.",
            "requirements": ["Shrine element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 425: No Need to Aim
        "No Need to Aim": {
            "description": "Have 4 barrage enhanced gems at the same time.",
            "requirements": ["Barrage skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 429: Bloodstream
        "Bloodstream": {
            "description": "Kill 4.000 monsters.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 435: Stormbringer
        "Stormbringer": {
            "description": "Reach 1.000 strike spells cast through all the bat...",
            "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 439: Gemhancement
        "Gemhancement": {
            "description": "Reach 1.000 enhancement spells cast through all th...",
            "requirements": ["Bolt skill", "Beam skill", "Barrage skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 443: Frozen Crowd
        "Frozen Crowd": {
            "description": "Reach 10.000 strike spell hits through all the bat...",
            "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 448: Tapped Essence
        "Tapped Essence": {
            "description": "Leech 1.500 mana from bleeding monsters.",
            "requirements": ["Bleeding skill", "Mana Leech skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 452: Rotten Aura
        "Rotten Aura": {
            "description": "Leech 1.100 mana from poisoned monsters.",
            "requirements": ["Mana Leech skill", "Poison skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 456: Hurtified
        "Hurtified": {
            "description": "Kill 240 bleeding monsters.",
            "requirements": ["Bleeding skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 485: Impudence
        "Impudence": {
            "description": "Have 6 of your gems destroyed or stolen.",
            "requirements": ["Ritual trait", "Specter element", "Watchtower element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 504: Versatile Charm
        "Versatile Charm": {
            "description": "Have at least 10 different talisman properties.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 510: Connecting the Dots
        "Connecting the Dots": {
            "description": "Have 50 fields lit in Journey mode.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 514: Xp Harvest
        "Xp Harvest": {
            "description": "Have 40 fields lit in Endurance mode.",
            "requirements": ["Endurance"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 518: Adept
        "Adept": {
            "description": "Have 30 fields lit in Trial mode.",
            "requirements": ["Trial"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 533: Ok Flier
        "Ok Flier": {
            "description": "Kill 340 monsters while there are at least 2 wrait...",
            "requirements": ["Ritual trait", "Wraith element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 538: Rainbow Strike
        "Rainbow Strike": {
            "description": "Kill 900 monsters with prismatic gem wasps.",
            "requirements": ["Critical Hit skill", "Mana Leech skill", "Bleeding skill", "Armor Tearing skill", "Slowing skill", "Poison skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 546: You Had Your Chance
        "You Had Your Chance": {
            "description": "Kill 260 banished monsters with shrines.",
            "requirements": ["Shrine element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 550: Fool Me Once
        "Fool Me Once": {
            "description": "Kill 390 banished monsters.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 566: Punching Deep
        "Punching Deep": {
            "description": "Tear a total of 2.500 armor with wasp stings.",
            "requirements": ["Armor Tearing skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 570: Keeping Low
        "Keeping Low": {
            "description": "Beat 40 waves using at most grade 2 gems.",
            "requirements": ["minWave: 40"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 586: Stolen Shine
        "Stolen Shine": {
            "description": "Leech 2.700 mana from whited out monsters.",
            "requirements": ["Mana Leech skill", "Whiteout skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 590: Quadpierced
        "Quadpierced": {
            "description": "Cast 4 ice shards on the same monster.",
            "requirements": ["Ice Shards skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 598: Mana Greedy
        "Mana Greedy": {
            "description": "Leech 1.800 mana with a grade 1 gem.",
            "requirements": ["Mana Leech skill", "minGemGrade: 1"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 607: Blood Censorship
        "Blood Censorship": {
            "description": "Kill 2.100 green blooded monsters.",
            "requirements": ["Requires \"hidden codes\""],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 611: Antitheft
        "Antitheft": {
            "description": "Kill 90 monsters with orblet explosions.",
            "requirements": ["Orb of Presence skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 632: Puzzling Bunch
        "Puzzling Bunch": {
            "description": "Add 16 talisman fragments to your shape collection...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

    },

    "grindiness_3": {
        # ID 8: Forged in Battle
        "Forged in Battle": {
            "description": "Reach 200 battles won.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 12: Getting Waves Done
        "Getting Waves Done": {
            "description": "Reach 2.000 waves started early through all the ba...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 16: Waves for Breakfast
        "Waves for Breakfast": {
            "description": "Reach 2.000 waves beaten through all the battles.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 25: Mighty
        "Mighty": {
            "description": "Create a gem with a raw minimum damage of 3.000 or...",
            "requirements": ["gemCount: 1"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 41: Hyper Gem
        "Hyper Gem": {
            "description": "Have a grade 3 gem with 600 effective max damage.",
            "requirements": ["minGemGrade: 3"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 45: Adept Grade
        "Adept Grade": {
            "description": "Create a grade 8 gem.",
            "requirements": ["minGemGrade: 8"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 53: Getting Serious
        "Getting Serious": {
            "description": "Have a grade 1 gem with 1.500 hits.",
            "requirements": ["minGemGrade: 1"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 61: Hacked Gem
        "Hacked Gem": {
            "description": "Have a grade 3 gem with 1.200 effective max damage...",
            "requirements": ["minGemGrade: 3"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 62: Denested
        "Denested": {
            "description": "Destroy 5 monster nests.",
            "requirements": ["Monster Nest element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 63: Tomb Stomping
        "Tomb Stomping": {
            "description": "Break 4 tombs open.",
            "requirements": ["Tomb element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 68: Fortress
        "Fortress": {
            "description": "Build 30 towers.",
            "requirements": ["Tower element"],
            "modes": {
                "journey": true,
                "endurance": true,
                "trial": true,
            },
        },

        # ID 69: Brickery
        "Brickery": {
            "description": "Reach 1.000 structures built through all the battl...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 73: Watch Your Step
        "Watch Your Step": {
            "description": "Build 40 traps.",
            "requirements": ["Traps skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 77: Power Exchange
        "Power Exchange": {
            "description": "Build 25 amplifiers.",
            "requirements": ["Amplifiers skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 81: Zigzag Corridor
        "Zigzag Corridor": {
            "description": "Build 60 walls.",
            "requirements": ["Wall element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 83: Frittata
        "Frittata": {
            "description": "Reach 500 monster eggs cracked through all the bat...",
            "requirements": ["Swarm Queen element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 107: Shard Siphon
        "Shard Siphon": {
            "description": "Reach 20.000 mana harvested from shards through al...",
            "requirements": ["Mana Shard element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 120: The Killing Will Never Stop
        "The Killing Will Never Stop": {
            "description": "Reach 200.000 monsters killed through all the batt...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 129: Minefield
        "Minefield": {
            "description": "Kill 300 monsters with gems in traps.",
            "requirements": ["Traps skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 133: Snowdust Blindness
        "Snowdust Blindness": {
            "description": "Gain 2.300 xp with Whiteout spell crowd hits.",
            "requirements": ["Whiteout skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 134: Wasp Storm
        "Wasp Storm": {
            "description": "Kill 360 monsters with gem bombs and wasps.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 139: Wings and Tentacles
        "Wings and Tentacles": {
            "description": "Reach 200 non-monsters killed through all the batt...",
            "requirements": ["Ritual trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 144: Swarmling Season
        "Swarmling Season": {
            "description": "Kill 999 swarmlings.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 151: Still Chill
        "Still Chill": {
            "description": "Gain 1.500 xp with Freeze spell crowd hits.",
            "requirements": ["Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 154: Drone Warfare
        "Drone Warfare": {
            "description": "Reach 20.000 gem wasp kills through all the battle...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 157: Can't Stop
        "Can't Stop": {
            "description": "Reach a kill chain of 900.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 173: Not Chasing Shadows Anymore
        "Not Chasing Shadows Anymore": {
            "description": "Kill 4 shadows.",
            "requirements": ["Ritual trait", "Shadow element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 186: Unholy Stack
        "Unholy Stack": {
            "description": "Reach 20.000 monsters with special properties kill...",
            "requirements": ["Possessed Monster element", "Twisted Monster element", "Marked Monster element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 196: Icepicked
        "Icepicked": {
            "description": "Gain 3.200 xp with Ice Shards spell crowd hits.",
            "requirements": ["Ice Shards skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 212: Lagging Already?
        "Lagging Already?": {
            "description": "Have 900 monsters on the battlefield at the same t...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 220: Sting Stack
        "Sting Stack": {
            "description": "Deal 1.000 gem wasp stings to buildings.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 222: Bouncy Zap
        "Bouncy Zap": {
            "description": "Reach 2.000 pylon kills through all the battles.",
            "requirements": ["Pylons skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 228: Power Overwhelming
        "Power Overwhelming": {
            "description": "Reach mana pool level 15.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 229: Mana in a Bottle
        "Mana in a Bottle": {
            "description": "Have 40.000 initial mana.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 247: Puncture Therapy
        "Puncture Therapy": {
            "description": "Deal 950 gem wasp stings to creatures.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 253: Desperate Clash
        "Desperate Clash": {
            "description": "Reach -16% decreased banishment cost with your orb...",
            "requirements": ["Amplifiers skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 256: Barbed Sphere
        "Barbed Sphere": {
            "description": "Deliver 1.200 banishments with your orb.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 262: It's a Trap
        "It's a Trap": {
            "description": "Don't let any monster touch your orb for 120 beate...",
            "requirements": ["minWave: 120"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 268: Takers
        "Takers": {
            "description": "Gain 1.600 mana from drops.",
            "requirements": ["Apparition element", "Corrupted Mana Shard element", "Drop Holder element", "Mana Shard element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 272: Chainsaw
        "Chainsaw": {
            "description": "Gain 3.200 xp with kill chains.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 273: Shattered Waves
        "Shattered Waves": {
            "description": "Hit 225 frozen monsters with shrines.",
            "requirements": ["Freeze skill", "Shrine element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 296: Laser Slicer
        "Laser Slicer": {
            "description": "Have 8 beam enhanced gems at the same time.",
            "requirements": ["Beam skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 305: Beacons Be Gone
        "Beacons Be Gone": {
            "description": "Reach 500 beacons destroyed through all the battle...",
            "requirements": ["Beacon element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 307: Deadly Curse
        "Deadly Curse": {
            "description": "Reach 5.000 poison kills through all the battles.",
            "requirements": ["Poison skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 317: Morning March
        "Morning March": {
            "description": "Lure 500 swarmlings out of a sleeping hive.",
            "requirements": ["Sleeping Hive element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 325: Agitated
        "Agitated": {
            "description": "Call 70 waves early.",
            "requirements": ["minWave: 70"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 333: The Gathering
        "The Gathering": {
            "description": "Summon 500 monsters by enraging waves.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 337: Raging Habit
        "Raging Habit": {
            "description": "Enrage 80 waves.",
            "requirements": ["minWave: 80"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 339: Impenetrable
        "Impenetrable": {
            "description": "Have 8 bolt enhanced gems at the same time.",
            "requirements": ["Bolt skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 348: Core Haul
        "Core Haul": {
            "description": "Find 180 shadow cores.",
            "requirements": ["Shadow Core element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 358: Frag Rain
        "Frag Rain": {
            "description": "Find 5 talisman fragments.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 362: Stockpile
        "Stockpile": {
            "description": "Have 30 fragments in your talisman inventory.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 386: Blue Wand
        "Blue Wand": {
            "description": "Reach wizard level 100.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 403: Fully Shining
        "Fully Shining": {
            "description": "Have 60 gems on the battlefield.",
            "requirements": ["gemCount: 60"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 405: Lost Signal
        "Lost Signal": {
            "description": "Destroy 35 beacons.",
            "requirements": ["Beacon element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 406: One by One
        "One by One": {
            "description": "Deliver 750 one hit kills.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 410: At my Fingertips
        "At my Fingertips": {
            "description": "Cast 75 strike spells.",
            "requirements": ["Ice Shards skill", "Whiteout skill", "Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 422: How About Some Skill Points
        "How About Some Skill Points": {
            "description": "Have 5.000 shadow cores at the start of the battle...",
            "requirements": ["Shadow Core element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 426: Shell Shock
        "Shell Shock": {
            "description": "Have 8 barrage enhanced gems at the same time.",
            "requirements": ["Barrage skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 430: They Keep Coming
        "They Keep Coming": {
            "description": "Kill 12.000 monsters.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 432: Don't Look at the Light
        "Don't Look at the Light": {
            "description": "Reach 10.000 shrine kills through all the battles.",
            "requirements": ["Shrine element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 436: Ice Mage
        "Ice Mage": {
            "description": "Reach 2.500 strike spells cast through all the bat...",
            "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 440: Enhance Like No Tomorrow
        "Enhance Like No Tomorrow": {
            "description": "Reach 2.500 enhancement spells cast through all th...",
            "requirements": ["Bolt skill", "Beam skill", "Barrage skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 444: Drop the Ice
        "Drop the Ice": {
            "description": "Reach 50.000 strike spell hits through all the bat...",
            "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 449: Painful Leech
        "Painful Leech": {
            "description": "Leech 3.200 mana from bleeding monsters.",
            "requirements": ["Bleeding skill", "Mana Leech skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 453: Mana of the Dying
        "Mana of the Dying": {
            "description": "Leech 2.300 mana from poisoned monsters.",
            "requirements": ["Mana Leech skill", "Poison skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 457: Bleed Out
        "Bleed Out": {
            "description": "Kill 480 bleeding monsters.",
            "requirements": ["Bleeding skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 486: Take Them I Have More
        "Take Them I Have More": {
            "description": "Have 12 of your gems destroyed or stolen.",
            "requirements": ["Ritual trait", "Specter element", "Watchtower element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 505: Quite a List
        "Quite a List": {
            "description": "Have at least 15 different talisman properties.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 511: Light My Path
        "Light My Path": {
            "description": "Have 70 fields lit in Journey mode.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 515: Longrunner
        "Longrunner": {
            "description": "Have 60 fields lit in Endurance mode.",
            "requirements": ["Endurance"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 519: Expert
        "Expert": {
            "description": "Have 50 fields lit in Trial mode.",
            "requirements": ["Trial"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 534: Hunt For Hard Targets
        "Hunt For Hard Targets": {
            "description": "Kill 680 monsters while there are at least 2 wrait...",
            "requirements": ["Ritual trait", "Wraith element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 539: Multinerf
        "Multinerf": {
            "description": "Kill 1.600 monsters with prismatic gem wasps.",
            "requirements": ["Mana Leech skill", "Critical Hit skill", "Bleeding skill", "Armor Tearing skill", "Poison skill", "Slowing skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 547: And Don't Come Back
        "And Don't Come Back": {
            "description": "Kill 460 banished monsters with shrines.",
            "requirements": ["Shrine element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 551: The Price of Obsession
        "The Price of Obsession": {
            "description": "Kill 590 banished monsters.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 567: Corrosive Stings
        "Corrosive Stings": {
            "description": "Tear a total of 5.000 armor with wasp stings.",
            "requirements": ["Armor Tearing skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 571: It Has to Do
        "It Has to Do": {
            "description": "Beat 50 waves using at most grade 2 gems.",
            "requirements": ["minWave: 50"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 587: Weakened Wallet
        "Weakened Wallet": {
            "description": "Leech 5.400 mana from whited out monsters.",
            "requirements": ["Mana Leech skill", "Whiteout skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 591: Shardalot
        "Shardalot": {
            "description": "Cast 6 ice shards on the same monster.",
            "requirements": ["Ice Shards skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 599: Hungry Little Gem
        "Hungry Little Gem": {
            "description": "Leech 3.600 mana with a grade 1 gem.",
            "requirements": ["Mana Leech skill", "minGemGrade: 1"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 608: Chlorophyll
        "Chlorophyll": {
            "description": "Kill 4.500 green blooded monsters.",
            "requirements": ["Requires \"hidden codes\""],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 612: Liquid Explosive
        "Liquid Explosive": {
            "description": "Kill 180 monsters with orblet explosions.",
            "requirements": ["Orb of Presence skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 633: Half Full
        "Half Full": {
            "description": "Add 32 talisman fragments to your shape collection...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

    },

    "grindiness_4": {
        # ID 9: Well Earned
        "Well Earned": {
            "description": "Reach 500 battles won.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 13: No Time to Waste
        "No Time to Waste": {
            "description": "Reach 5.000 waves started early through all the ba...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 17: Wave Smasher
        "Wave Smasher": {
            "description": "Reach 10.000 waves beaten through all the battles.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 46: Round Cut
        "Round Cut": {
            "description": "Create a grade 12 gem.",
            "requirements": ["minGemGrade: 12"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 57: Time to Upgrade
        "Time to Upgrade": {
            "description": "Have a grade 1 gem with 4.500 hits.",
            "requirements": ["minGemGrade: 1"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 70: Megalithic
        "Megalithic": {
            "description": "Reach 2.000 structures built through all the battl...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 74: Razor Path
        "Razor Path": {
            "description": "Build 60 traps.",
            "requirements": ["Traps skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 114: The Mana Reaper
        "The Mana Reaper": {
            "description": "Reach 100.000 mana harvested from shards through a...",
            "requirements": ["Mana Shard element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 115: Eggs Royale
        "Eggs Royale": {
            "description": "Reach 1.000 monster eggs cracked through all the b...",
            "requirements": ["Swarm Queen element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 125: They Are Millions
        "They Are Millions": {
            "description": "Reach 1.000.000 monsters killed through all the ba...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 135: Waspocalypse
        "Waspocalypse": {
            "description": "Kill 1.080 monsters with gem bombs and wasps.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 141: Paranormal Paragon
        "Paranormal Paragon": {
            "description": "Reach 500 non-monsters killed through all the batt...",
            "requirements": ["Ritual trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 164: Tiny but Deadly
        "Tiny but Deadly": {
            "description": "Reach 50.000 gem wasp kills through all the battle...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 187: Cleansing the Wilderness
        "Cleansing the Wilderness": {
            "description": "Reach 50.000 monsters with special properties kill...",
            "requirements": ["Possessed Monster element", "Twisted Monster element", "Marked Monster element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 221: Punctured Texture
        "Punctured Texture": {
            "description": "Deal 5.000 gem wasp stings to buildings.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 230: Itchy Sphere
        "Itchy Sphere": {
            "description": "Deliver 3.600 banishments with your orb.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 231: Pylons of Destruction
        "Pylons of Destruction": {
            "description": "Reach 5.000 pylon kills through all the battles.",
            "requirements": ["Pylons skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 248: You Shall Not Pass
        "You Shall Not Pass": {
            "description": "Don't let any monster touch your orb for 240 beate...",
            "requirements": ["minWave: 240"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 249: Boiling Red
        "Boiling Red": {
            "description": "Reach a kill chain of 2400.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 274: Bastion
        "Bastion": {
            "description": "Build 90 towers.",
            "requirements": ["Tower element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 275: Mana Singularity
        "Mana Singularity": {
            "description": "Reach mana pool level 20.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 276: Weather of Wasps
        "Weather of Wasps": {
            "description": "Deal 3950 gem wasp stings to creatures.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 277: Mythic Ancient Legendary
        "Mythic Ancient Legendary": {
            "description": "Create a gem with a raw minimum damage of 300.000 ...",
            "requirements": ["gemCount: 1"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 278: Every Hit Counts
        "Every Hit Counts": {
            "description": "Deliver 3750 one hit kills.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 279: Insane Investment
        "Insane Investment": {
            "description": "Reach -20% decreased banishment cost with your orb...",
            "requirements": ["Amplifiers skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 280: No Land for Swarmlings
        "No Land for Swarmlings": {
            "description": "Kill 3.333 swarmlings.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 281: Long Run
        "Long Run": {
            "description": "Beat 360 waves.",
            "requirements": ["minWave: 360"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 282: Stone Monument
        "Stone Monument": {
            "description": "Build 240 walls.",
            "requirements": ["Wall element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 284: It's Lagging Alright
        "It's Lagging Alright": {
            "description": "Have 1.200 monsters on the battlefield at the same...",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 285: Mana Hack
        "Mana Hack": {
            "description": "Have 80.000 initial mana.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 286: Zap Away
        "Zap Away": {
            "description": "Cast 175 strike spells.",
            "requirements": ["Ice Shards skill", "Whiteout skill", "Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 287: Snatchers
        "Snatchers": {
            "description": "Gain 3.200 mana from drops.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 288: Killed So Many
        "Killed So Many": {
            "description": "Gain 7.200 xp with kill chains.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 289: Frozen Over
        "Frozen Over": {
            "description": "Gain 4.500 xp with Freeze spell crowd hits.",
            "requirements": ["Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 297: Fusion Core
        "Fusion Core": {
            "description": "Have 16 beam enhanced gems at the same time.",
            "requirements": ["Beam skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 306: Shatter Them All
        "Shatter Them All": {
            "description": "Reach 1.000 beacons destroyed through all the batt...",
            "requirements": ["Beacon element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 310: Outwhited
        "Outwhited": {
            "description": "Gain 4.700 xp with Whiteout spell crowd hits.",
            "requirements": ["Whiteout skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 318: Mass Awakening
        "Mass Awakening": {
            "description": "Lure 2.500 swarmlings out of a sleeping hive.",
            "requirements": ["Sleeping Hive element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 326: There's No Time
        "There's No Time": {
            "description": "Call 140 waves early.",
            "requirements": ["minWave: 140"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 328: White Ring of Death
        "White Ring of Death": {
            "description": "Gain 4.900 xp with Ice Shards spell crowd hits.",
            "requirements": ["Ice Shards skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 329: Shaken Ice
        "Shaken Ice": {
            "description": "Hit 475 frozen monsters with shrines.",
            "requirements": ["Freeze skill", "Shrine element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 330: Nothing Prevails
        "Nothing Prevails": {
            "description": "Reach 25.000 poison kills through all the battles.",
            "requirements": ["Poison skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 334: More Than Enough
        "More Than Enough": {
            "description": "Summon 1.000 monsters by enraging waves.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 338: Enraged is the New Norm
        "Enraged is the New Norm": {
            "description": "Enrage 240 waves.",
            "requirements": ["minWave: 240"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 340: Rugged Defense
        "Rugged Defense": {
            "description": "Have 16 bolt enhanced gems at the same time.",
            "requirements": ["Bolt skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 350: Boatload of Cores
        "Boatload of Cores": {
            "description": "Find 540 shadow cores.",
            "requirements": ["Shadow Core element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 356: Amplifinity
        "Amplifinity": {
            "description": "Build 45 amplifiers.",
            "requirements": ["Amplifiers skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 359: Amulet
        "Amulet": {
            "description": "Fill all the sockets in your talisman.",
            "requirements": ["Shadow Core element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 387: Purple Wand
        "Purple Wand": {
            "description": "Reach wizard level 200.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 388: Brown Wand
        "Brown Wand": {
            "description": "Reach wizard level 300.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 389: Red Wand
        "Red Wand": {
            "description": "Reach wizard level 500.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 407: Trembling
        "Trembling": {
            "description": "Kill 1.500 monsters with gems in traps.",
            "requirements": ["Traps skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 409: Beacon Hunt
        "Beacon Hunt": {
            "description": "Destroy 55 beacons.",
            "requirements": ["Beacon element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 416: Is This a Match-3 or What?
        "Is This a Match-3 or What?": {
            "description": "Have 90 gems on the battlefield.",
            "requirements": ["gemCount: 90"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 420: Don't Break it!
        "Don't Break it!": {
            "description": "Spend 90.000 mana on banishment.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 423: Endgame Balance
        "Endgame Balance": {
            "description": "Have 25.000 shadow cores at the start of the battl...",
            "requirements": ["Shadow Core element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 427: Firefall
        "Firefall": {
            "description": "Have 16 barrage enhanced gems at the same time.",
            "requirements": ["Barrage skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 431: Unending Flow
        "Unending Flow": {
            "description": "Kill 24.000 monsters.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 433: Shrinemaster
        "Shrinemaster": {
            "description": "Reach 20.000 shrine kills through all the battles.",
            "requirements": ["Shrine element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 437: Frostborn
        "Frostborn": {
            "description": "Reach 5.000 strike spells cast through all the bat...",
            "requirements": ["Whiteout skill", "Ice Shards skill", "Freeze skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 441: Charge Fire Repeat
        "Charge Fire Repeat": {
            "description": "Reach 5.000 enhancement spells cast through all th...",
            "requirements": ["Bolt skill", "Beam skill", "Barrage skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 445: Ice for Everyone
        "Ice for Everyone": {
            "description": "Reach 100.000 strike spell hits through all the ba...",
            "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 450: Mana Cult
        "Mana Cult": {
            "description": "Leech 6.500 mana from bleeding monsters.",
            "requirements": ["Bleeding skill", "Mana Leech skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 454: To the Last Drop
        "To the Last Drop": {
            "description": "Leech 4.700 mana from poisoned monsters.",
            "requirements": ["Mana Leech skill", "Poison skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 458: Final Cut
        "Final Cut": {
            "description": "Kill 960 bleeding monsters.",
            "requirements": ["Bleeding skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 487: Enough is Enough
        "Enough is Enough": {
            "description": "Have 24 of your gems destroyed or stolen.",
            "requirements": ["Ritual trait", "Specter element", "Watchtower element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 506: Almost Like Hacked
        "Almost Like Hacked": {
            "description": "Have at least 20 different talisman properties.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 512: Cartographer
        "Cartographer": {
            "description": "Have 90 fields lit in Journey mode.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 516: Endured a Lot
        "Endured a Lot": {
            "description": "Have 80 fields lit in Endurance mode.",
            "requirements": ["Endurance"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 520: Worthy
        "Worthy": {
            "description": "Have 70 fields lit in Trial mode.",
            "requirements": ["Trial"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 535: I am Tougher
        "I am Tougher": {
            "description": "Kill 1.360 monsters while there are at least 2 wra...",
            "requirements": ["Ritual trait", "Wraith element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 540: Taste All The Affixes
        "Taste All The Affixes": {
            "description": "Kill 2.500 monsters with prismatic gem wasps.",
            "requirements": ["Critical Hit skill", "Mana Leech skill", "Bleeding skill", "Armor Tearing skill", "Poison skill", "Slowing skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 548: Scour You All
        "Scour You All": {
            "description": "Kill 660 banished monsters with shrines.",
            "requirements": ["Shrine element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 552: Be Gone For Good
        "Be Gone For Good": {
            "description": "Kill 790 banished monsters.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 553: Mixing Up
        "Mixing Up": {
            "description": "Beat 50 waves on max Swarmling and Giant dominatio...",
            "requirements": ["Swarmling Domination trait", "Giant Domination trait", "minWave: 50"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 556: Worst of Both Sizes
        "Worst of Both Sizes": {
            "description": "Beat 300 waves on max Swarmling and Giant dominati...",
            "requirements": ["Swarmling Domination trait", "Giant Domination trait", "minWave: 300", "Endurance"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 568: Melting Armor
        "Melting Armor": {
            "description": "Tear a total of 10.000 armor with wasp stings.",
            "requirements": ["Armor Tearing skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 572: Need Lots of Them
        "Need Lots of Them": {
            "description": "Beat 60 waves using at most grade 2 gems.",
            "requirements": ["minWave: 60"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 588: Just Give Me That Mana
        "Just Give Me That Mana": {
            "description": "Leech 7.200 mana from whited out monsters.",
            "requirements": ["Mana Leech skill", "Whiteout skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 592: Care to Die Already?
        "Care to Die Already?": {
            "description": "Cast 8 ice shards on the same monster.",
            "requirements": ["Ice Shards skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 600: Max Trap Max leech
        "Max Trap Max leech": {
            "description": "Leech 6.300 mana with a grade 1 gem.",
            "requirements": ["Mana Leech skill", "minGemGrade: 1"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 609: Green Path
        "Green Path": {
            "description": "Kill 9.900 green blooded monsters.",
            "requirements": ["Requires \"hidden codes\""],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 613: Handle With Care
        "Handle With Care": {
            "description": "Kill 300 monsters with orblet explosions.",
            "requirements": ["Orb of Presence skill"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

    },

    "grindiness_5": {
        # ID 26: Legendary
        "Legendary": {
            "description": "Create a gem with a raw minimum damage of 30.000 o...",
            "requirements": ["gemCount: 1"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 42: Wicked Gem
        "Wicked Gem": {
            "description": "Have a grade 3 gem with 900 effective max damage.",
            "requirements": ["minGemGrade: 3"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 47: Round Cut Plus
        "Round Cut Plus": {
            "description": "Create a grade 16 gem.",
            "requirements": ["minGemGrade: 16"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 84: Quick Circle
        "Quick Circle": {
            "description": "Create a grade 12 gem before wave 12.",
            "requirements": ["minGemGrade: 12"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 145: Feels Like Endurance
        "Feels Like Endurance": {
            "description": "Beat 120 waves.",
            "requirements": ["minWave: 120"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 161: Hazardous Materials
        "Hazardous Materials": {
            "description": "Put your HEV on first",
            "requirements": ["Poison skill", "Have atleast 1.000 enemies poisoned and alive on a field"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 199: Beastmaster
        "Beastmaster": {
            "description": "Kill a monster having at least 100.000 hit points ...",
            "requirements": ["A monster with atleast 100.000hp and 1000 amror"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 360: Charm
        "Charm": {
            "description": "Fill all the sockets in your talisman with fragmen...",
            "requirements": ["Shadow Core element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 361: Sigil
        "Sigil": {
            "description": "Fill all the sockets in your talisman with fragmen...",
            "requirements": ["Shadow Core element"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 419: Black Wand
        "Black Wand": {
            "description": "Reach wizard level 1.000.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 421: Just Take My Mana!
        "Just Take My Mana!": {
            "description": "Spend 900.000 mana on banishment.",
            "requirements": [],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 508: Fully Lit
        "Fully Lit": {
            "description": "Have a field beaten in all three battle modes.",
            "requirements": ["Endurance and trial"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 541: Flip Flop
        "Flip Flop": {
            "description": "Win a flipped field battle.",
            "requirements": ["Requires \"hidden codes\""],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 544: Peek Into The Abyss
        "Peek Into The Abyss": {
            "description": "Kill a monster with all battle traits set to the h...",
            "requirements": ["Adaptive Carapace trait", "Dark Masonry trait", "Swarmling Domination trait", "Overcrowd trait", "Corrupted Banishment trait", "Awakening trait", "Insulation trait", "Hatred trait", "Swarmling Parasites trait", "Haste trait", "Thick Air trait", "Vital Link trait", "Giant Domination trait", "Strength in Numbers trait", "Ritual trait"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 554: Size Matters
        "Size Matters": {
            "description": "Beat 100 waves on max Swarmling and Giant dominati...",
            "requirements": ["Swarmling Domination trait", "Giant Domination trait", "minWave: 100"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

        # ID 555: Enhancing Challenge
        "Enhancing Challenge": {
            "description": "Beat 200 waves on max Swarmling and Giant dominati...",
            "requirements": ["Swarmling Domination trait", "Giant Domination trait", "minWave: 200", "Endurance"],
            "modes": {
                "journey": none,
                "endurance": none,
                "trial": none,
            },
        },

    },

}

# =====================================================================
# ACHIEVEMENT UNLOCKS (Dependency Chains)
# =====================================================================
# Defines what each achievement grants and what it requires to unlock.
# This models achievement dependencies and chains.
#
# For now, this is a stub. It will be populated based on achievement analysis.
#
achievement_unlocks = {
    # TODO: Extract from achievement descriptions which achievements grant
    # traits, skills, game elements, etc.
    #
    # Example format:
    # "Ritual": {
    #     "type": "trait",
    #     "granted_by": ["Smoke in the Sky", "High Targets", ...],
    # },
    # "Shadow": {
    #     "type": "game_element",
    #     "requires": ["Ritual"],  # Hard dependency
    #     "granted_by": [...],
    # },
}
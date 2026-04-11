"""
GemCraft Frostborn Wrath — Grindiness Level 5 Achievements

Contains 16 achievements at grindiness level 5.
Organized by achievement ID for easy reference.
"""

achievement_requirements = {
    # ID 26: Legendary
    "Legendary": {
        "description": "Create a gem with a raw minimum damage of 30.000 or higher.",
        "requirements": ["gemCount: 1"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 42: Wicked Gem
    "Wicked Gem": {
        "description": "Have a grade 3 gem with 900 effective max damage.",
        "requirements": ["minGemGrade: 3"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 47: Round Cut Plus
    "Round Cut Plus": {
        "description": "Create a grade 16 gem.",
        "requirements": ["minGemGrade: 16"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 84: Quick Circle
    "Quick Circle": {
        "description": "Create a grade 12 gem before wave 12.",
        "requirements": ["minGemGrade: 12"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 145: Feels Like Endurance
    "Feels Like Endurance": {
        "description": "Beat 120 waves.",
        "requirements": ["minWave: 120"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 161: Hazardous Materials
    "Hazardous Materials": {
        "description": "Put your HEV on first",
        "requirements": ["Poison skill", "Have atleast 1.000 enemies poisoned and alive on a field"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 199: Beastmaster
    "Beastmaster": {
        "description": "Kill a monster having at least 100.000 hit points and 1000 a...",
        "requirements": ["A monster with atleast 100.000hp and 1000 amror"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 360: Charm
    "Charm": {
        "description": "Fill all the sockets in your talisman with fragments upgrade...",
        "requirements": ["Shadow Core element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 361: Sigil
    "Sigil": {
        "description": "Fill all the sockets in your talisman with fragments upgrade...",
        "requirements": ["Shadow Core element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 419: Black Wand
    "Black Wand": {
        "description": "Reach wizard level 1.000.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 421: Just Take My Mana!
    "Just Take My Mana!": {
        "description": "Spend 900.000 mana on banishment.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 508: Fully Lit
    "Fully Lit": {
        "description": "Have a field beaten in all three battle modes.",
        "requirements": ["Endurance and trial"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 541: Flip Flop
    "Flip Flop": {
        "description": "Win a flipped field battle.",
        "requirements": ["Requires \"hidden codes\""],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 544: Peek Into The Abyss
    "Peek Into The Abyss": {
        "description": "Kill a monster with all battle traits set to the highest lev...",
        "requirements": ["Adaptive Carapace trait", "Dark Masonry trait", "Swarmling Domination trait", "Overcrowd trait", "Corrupted Banishment trait", "Awakening trait", "Insulation trait", "Hatred trait", "Swarmling Parasites trait", "Haste trait", "Thick Air trait", "Vital Link trait", "Giant Domination trait", "Strength in Numbers trait", "Ritual trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 554: Size Matters
    "Size Matters": {
        "description": "Beat 100 waves on max Swarmling and Giant domination traits.",
        "requirements": ["Swarmling Domination trait", "Giant Domination trait", "minWave: 100"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 555: Enhancing Challenge
    "Enhancing Challenge": {
        "description": "Beat 200 waves on max Swarmling and Giant domination traits.",
        "requirements": ["Swarmling Domination trait", "Giant Domination trait", "minWave: 200", "Endurance"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
}

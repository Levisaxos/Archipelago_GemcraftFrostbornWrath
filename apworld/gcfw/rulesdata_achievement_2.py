"""
GemCraft Frostborn Wrath — Grindiness Level 2 Achievements

Contains 91 achievements at grindiness level 2.
Organized by achievement ID for easy reference.
"""

achievement_requirements = {
    # ID 7: I Have Experience
    "I Have Experience": {
        "description": "Reach 50 battles won.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 11: So Early
    "So Early": {
        "description": "Reach 1.000 waves started early through all the battles.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 15: Riding the Waves
    "Riding the Waves": {
        "description": "Reach 1.000 waves beaten through all the battles.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 29: Prismatic
    "Prismatic": {
        "description": "Create a gem of 6 components.",
        "requirements": ["Critical Hit skill", "Mana Leech skill", "Bleeding skill", "Armor Tearing skill", "Poison skill", "Slowing skill", "gemCount: 6"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 44: Fifth Grader
    "Fifth Grader": {
        "description": "Create a grade 5 gem.",
        "requirements": ["minGemGrade: 5"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 52: Seen Battle
    "Seen Battle": {
        "description": "Have a grade 1 gem with 500 hits.",
        "requirements": ["minGemGrade: 1"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 58: Bazaar
    "Bazaar": {
        "description": "Have 30 gems on the battlefield.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 60: Major Shutdown
    "Major Shutdown": {
        "description": "Destroy 3 monster nests.",
        "requirements": ["Monster Nest element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 65: Ambitious Builder
    "Ambitious Builder": {
        "description": "Reach 500 structures built through all the battles.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 67: Settlement
    "Settlement": {
        "description": "Build 15 towers.",
        "requirements": ["Tower element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 72: Entrenched
    "Entrenched": {
        "description": "Build 20 traps.",
        "requirements": ["Traps skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 76: Power Flow
    "Power Flow": {
        "description": "Build 15 amplifiers.",
        "requirements": ["Amplifiers skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 78: Omelette
    "Omelette": {
        "description": "Reach 200 monster eggs cracked through all the battles.",
        "requirements": ["Swarm Queen element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 80: Confusion Junction
    "Confusion Junction": {
        "description": "Build 30 walls.",
        "requirements": ["Wall element"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 88: Tasting the Darkness
    "Tasting the Darkness": {
        "description": "Break 3 tombs open.",
        "requirements": ["Tomb element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 92: Nest Buster
    "Nest Buster": {
        "description": "Destroy 3 monster nests before wave 6.",
        "requirements": ["Monster Nest element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 106: Mana Tap
    "Mana Tap": {
        "description": "Reach 10.000 mana harvested from shards through all the batt...",
        "requirements": ["Mana Shard element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 110: Come Out, Come Out
    "Come Out, Come Out": {
        "description": "Lure 100 swarmlings out of a sleeping hive.",
        "requirements": ["Sleeping Hive element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 119: Crimson Journal
    "Crimson Journal": {
        "description": "Reach 100.000 monsters killed through all the battles.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 124: Impaling Charges
    "Impaling Charges": {
        "description": "Deliver 250 one hit kills.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 128: Rough Path
    "Rough Path": {
        "description": "Kill 60 monsters with gems in traps.",
        "requirements": ["Traps skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 131: Thunderstruck
    "Thunderstruck": {
        "description": "Kill 120 monsters with gem bombs and wasps.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 136: Still Alive
    "Still Alive": {
        "description": "Beat 60 waves.",
        "requirements": ["minWave: 60"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 138: High Targets
    "High Targets": {
        "description": "Reach 100 non-monsters killed through all the battles.",
        "requirements": ["Ritual trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 143: Diabolic Trophy
    "Diabolic Trophy": {
        "description": "Kill 666 swarmlings.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 149: Stingy Cloud
    "Stingy Cloud": {
        "description": "Reach 5.000 gem wasp kills through all the battles.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 156: Carnage
    "Carnage": {
        "description": "Reach a kill chain of 600.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 166: Darkness Walk With Me
    "Darkness Walk With Me": {
        "description": "Kill 3 shadows.",
        "requirements": ["Ritual trait", "Shadow element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 180: White Ray
    "White Ray": {
        "description": "Kill 90 frozen monsters with beam.",
        "requirements": ["Beam skill", "Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 181: Icecracker
    "Icecracker": {
        "description": "Kill 90 frozen monsters with barrage.",
        "requirements": ["Barrage skill", "Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 185: Marked Targets
    "Marked Targets": {
        "description": "Reach 10.000 monsters with special properties killed through...",
        "requirements": ["Possessed Monster element", "Twisted Monster element", "Marked Monster element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 201: Deathball
    "Deathball": {
        "description": "Reach 1.000 pylon kills through all the battles.",
        "requirements": ["Pylons skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 211: Crowded Queue
    "Crowded Queue": {
        "description": "Have 600 monsters on the battlefield at the same time.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 217: Needle Storm
    "Needle Storm": {
        "description": "Deal 350 gem wasp stings to creatures.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 219: Drumroll
    "Drumroll": {
        "description": "Deal 200 gem wasp stings to buildings.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 224: Well Prepared
    "Well Prepared": {
        "description": "Have 20.000 initial mana.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 227: Flows Through my Veins
    "Flows Through my Veins": {
        "description": "Reach mana pool level 10.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 234: Keepers
    "Keepers": {
        "description": "Gain 800 mana from drops.",
        "requirements": ["Apparition element", "Corrupted Mana Shard element", "Mana Shard element", "Drop Holder element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 236: It Hurts!
    "It Hurts!": {
        "description": "Spend 9.000 mana on banishment.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 240: Cold Wisdom
    "Cold Wisdom": {
        "description": "Gain 700 xp with Freeze spell crowd hits.",
        "requirements": ["Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 242: Bright Weakening
    "Bright Weakening": {
        "description": "Gain 1.200 xp with Whiteout spell crowd hits.",
        "requirements": ["Whiteout skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 244: Sliced Ice
    "Sliced Ice": {
        "description": "Gain 1.800 xp with Ice Shards spell crowd hits.",
        "requirements": ["Ice Shards skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 246: Bloodmaster
    "Bloodmaster": {
        "description": "Gain 1.200 xp with kill chains.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 252: Close Quarter
    "Close Quarter": {
        "description": "Reach -12% decreased banishment cost with your orb.",
        "requirements": ["Amplifiers skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 255: Thorned Sphere
    "Thorned Sphere": {
        "description": "Deliver 400 banishments with your orb.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 261: Tightly Secured
    "Tightly Secured": {
        "description": "Don't let any monster touch your orb for 60 beaten waves.",
        "requirements": ["minWave: 60"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 265: Addicted
    "Addicted": {
        "description": "Activate shrines a total of 12 times.",
        "requirements": ["Shrine element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 267: Power Node
    "Power Node": {
        "description": "Activate the same shrine 5 times.",
        "requirements": ["Shrine element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 270: Melting Pulse
    "Melting Pulse": {
        "description": "Hit 75 frozen monsters with shrines.",
        "requirements": ["Freeze skill", "Shrine element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 292: No Place to Hide
    "No Place to Hide": {
        "description": "Cast 25 strike spells.",
        "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 295: Friday Night
    "Friday Night": {
        "description": "Have 4 beam enhanced gems at the same time.",
        "requirements": ["Beam skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 299: Heavy Hitting
    "Heavy Hitting": {
        "description": "Have 4 bolt enhanced gems at the same time.",
        "requirements": ["Bolt skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 300: Necrotrophic
    "Necrotrophic": {
        "description": "Reach 1.000 poison kills through all the battles.",
        "requirements": ["Poison skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 303: No Beacon Zone
    "No Beacon Zone": {
        "description": "Reach 200 beacons destroyed through all the battles.",
        "requirements": ["Beacon element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 324: Restless
    "Restless": {
        "description": "Call 35 waves early.",
        "requirements": ["minWave: 35"],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 332: Uninvited
    "Uninvited": {
        "description": "Summon 100 monsters by enraging waves.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 336: Rageout
    "Rageout": {
        "description": "Enrage 30 waves.",
        "requirements": ["minWave: 30"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 347: Core Pile
    "Core Pile": {
        "description": "Find 60 shadow cores.",
        "requirements": ["Shadow Core element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 357: Plentiful
    "Plentiful": {
        "description": "Have 1.000 shadow cores at the start of the battle.",
        "requirements": ["Shadow Core element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 363: Gearing Up
    "Gearing Up": {
        "description": "Have 5 fragments socketed in your talisman.",
        "requirements": [],
        "modes": {
            "journey": True,
            "endurance": True,
            "trial": True,
        },
    },
    # ID 366: Ground Luck
    "Ground Luck": {
        "description": "Find 3 talisman fragments.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 383: Yellow Wand
    "Yellow Wand": {
        "description": "Reach wizard level 20.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 384: Orange Wand
    "Orange Wand": {
        "description": "Reach wizard level 40.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 385: Green Wand
    "Green Wand": {
        "description": "Reach wizard level 60.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 404: Stormed Beacons
    "Stormed Beacons": {
        "description": "Destroy 15 beacons.",
        "requirements": ["Beacon element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 408: Hard Reset
    "Hard Reset": {
        "description": "Reach 5.000 shrine kills through all the battles.",
        "requirements": ["Shrine element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 425: No Need to Aim
    "No Need to Aim": {
        "description": "Have 4 barrage enhanced gems at the same time.",
        "requirements": ["Barrage skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 429: Bloodstream
    "Bloodstream": {
        "description": "Kill 4.000 monsters.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 435: Stormbringer
    "Stormbringer": {
        "description": "Reach 1.000 strike spells cast through all the battles.",
        "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 439: Gemhancement
    "Gemhancement": {
        "description": "Reach 1.000 enhancement spells cast through all the battles.",
        "requirements": ["Bolt skill", "Beam skill", "Barrage skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 443: Frozen Crowd
    "Frozen Crowd": {
        "description": "Reach 10.000 strike spell hits through all the battles.",
        "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 448: Tapped Essence
    "Tapped Essence": {
        "description": "Leech 1.500 mana from bleeding monsters.",
        "requirements": ["Bleeding skill", "Mana Leech skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 452: Rotten Aura
    "Rotten Aura": {
        "description": "Leech 1.100 mana from poisoned monsters.",
        "requirements": ["Mana Leech skill", "Poison skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 456: Hurtified
    "Hurtified": {
        "description": "Kill 240 bleeding monsters.",
        "requirements": ["Bleeding skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 485: Impudence
    "Impudence": {
        "description": "Have 6 of your gems destroyed or stolen.",
        "requirements": ["Ritual trait", "Specter element", "Watchtower element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 504: Versatile Charm
    "Versatile Charm": {
        "description": "Have at least 10 different talisman properties.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 510: Connecting the Dots
    "Connecting the Dots": {
        "description": "Have 50 fields lit in Journey mode.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 514: Xp Harvest
    "Xp Harvest": {
        "description": "Have 40 fields lit in Endurance mode.",
        "requirements": ["Endurance"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 518: Adept
    "Adept": {
        "description": "Have 30 fields lit in Trial mode.",
        "requirements": ["Trial"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 533: Ok Flier
    "Ok Flier": {
        "description": "Kill 340 monsters while there are at least 2 wraiths in the ...",
        "requirements": ["Ritual trait", "Wraith element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 538: Rainbow Strike
    "Rainbow Strike": {
        "description": "Kill 900 monsters with prismatic gem wasps.",
        "requirements": ["Critical Hit skill", "Mana Leech skill", "Bleeding skill", "Armor Tearing skill", "Slowing skill", "Poison skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 546: You Had Your Chance
    "You Had Your Chance": {
        "description": "Kill 260 banished monsters with shrines.",
        "requirements": ["Shrine element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 550: Fool Me Once
    "Fool Me Once": {
        "description": "Kill 390 banished monsters.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 566: Punching Deep
    "Punching Deep": {
        "description": "Tear a total of 2.500 armor with wasp stings.",
        "requirements": ["Armor Tearing skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 570: Keeping Low
    "Keeping Low": {
        "description": "Beat 40 waves using at most grade 2 gems.",
        "requirements": ["minWave: 40"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 586: Stolen Shine
    "Stolen Shine": {
        "description": "Leech 2.700 mana from whited out monsters.",
        "requirements": ["Mana Leech skill", "Whiteout skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 590: Quadpierced
    "Quadpierced": {
        "description": "Cast 4 ice shards on the same monster.",
        "requirements": ["Ice Shards skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 598: Mana Greedy
    "Mana Greedy": {
        "description": "Leech 1.800 mana with a grade 1 gem.",
        "requirements": ["Mana Leech skill", "minGemGrade: 1"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 607: Blood Censorship
    "Blood Censorship": {
        "description": "Kill 2.100 green blooded monsters.",
        "requirements": ["Requires \"hidden codes\""],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 611: Antitheft
    "Antitheft": {
        "description": "Kill 90 monsters with orblet explosions.",
        "requirements": ["Orb of Presence skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 632: Puzzling Bunch
    "Puzzling Bunch": {
        "description": "Add 16 talisman fragments to your shape collection.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
}

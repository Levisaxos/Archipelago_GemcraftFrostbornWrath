"""
GemCraft Frostborn Wrath — Grindiness Level 4 Achievements

Contains 83 achievements at grindiness level 4.
Organized by achievement ID for easy reference.
"""

achievement_requirements = {
    # ID 9: Well Earned
    "Well Earned": {
        "description": "Reach 500 battles won.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 13: No Time to Waste
    "No Time to Waste": {
        "description": "Reach 5.000 waves started early through all the battles.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 17: Wave Smasher
    "Wave Smasher": {
        "description": "Reach 10.000 waves beaten through all the battles.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 46: Round Cut
    "Round Cut": {
        "description": "Create a grade 12 gem.",
        "requirements": ["minGemGrade: 12"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 57: Time to Upgrade
    "Time to Upgrade": {
        "description": "Have a grade 1 gem with 4.500 hits.",
        "requirements": ["minGemGrade: 1"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 70: Megalithic
    "Megalithic": {
        "description": "Reach 2.000 structures built through all the battles.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 74: Razor Path
    "Razor Path": {
        "description": "Build 60 traps.",
        "requirements": ["Traps skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 114: The Mana Reaper
    "The Mana Reaper": {
        "description": "Reach 100.000 mana harvested from shards through all the bat...",
        "requirements": ["Mana Shard element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 115: Eggs Royale
    "Eggs Royale": {
        "description": "Reach 1.000 monster eggs cracked through all the battles.",
        "requirements": ["Swarm Queen element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 125: They Are Millions
    "They Are Millions": {
        "description": "Reach 1.000.000 monsters killed through all the battles.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 135: Waspocalypse
    "Waspocalypse": {
        "description": "Kill 1.080 monsters with gem bombs and wasps.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 141: Paranormal Paragon
    "Paranormal Paragon": {
        "description": "Reach 500 non-monsters killed through all the battles.",
        "requirements": ["Ritual trait"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 164: Tiny but Deadly
    "Tiny but Deadly": {
        "description": "Reach 50.000 gem wasp kills through all the battles.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 187: Cleansing the Wilderness
    "Cleansing the Wilderness": {
        "description": "Reach 50.000 monsters with special properties killed through...",
        "requirements": ["Possessed Monster element", "Twisted Monster element", "Marked Monster element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 221: Punctured Texture
    "Punctured Texture": {
        "description": "Deal 5.000 gem wasp stings to buildings.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 230: Itchy Sphere
    "Itchy Sphere": {
        "description": "Deliver 3.600 banishments with your orb.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 231: Pylons of Destruction
    "Pylons of Destruction": {
        "description": "Reach 5.000 pylon kills through all the battles.",
        "requirements": ["Pylons skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 248: You Shall Not Pass
    "You Shall Not Pass": {
        "description": "Don't let any monster touch your orb for 240 beaten waves.",
        "requirements": ["minWave: 240"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 249: Boiling Red
    "Boiling Red": {
        "description": "Reach a kill chain of 2400.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 274: Bastion
    "Bastion": {
        "description": "Build 90 towers.",
        "requirements": ["Tower element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 275: Mana Singularity
    "Mana Singularity": {
        "description": "Reach mana pool level 20.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 276: Weather of Wasps
    "Weather of Wasps": {
        "description": "Deal 3950 gem wasp stings to creatures.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 277: Mythic Ancient Legendary
    "Mythic Ancient Legendary": {
        "description": "Create a gem with a raw minimum damage of 300.000 or higher.",
        "requirements": ["gemCount: 1"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 278: Every Hit Counts
    "Every Hit Counts": {
        "description": "Deliver 3750 one hit kills.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 279: Insane Investment
    "Insane Investment": {
        "description": "Reach -20% decreased banishment cost with your orb.",
        "requirements": ["Amplifiers skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 280: No Land for Swarmlings
    "No Land for Swarmlings": {
        "description": "Kill 3.333 swarmlings.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 281: Long Run
    "Long Run": {
        "description": "Beat 360 waves.",
        "requirements": ["minWave: 360"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 282: Stone Monument
    "Stone Monument": {
        "description": "Build 240 walls.",
        "requirements": ["Wall element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 284: It's Lagging Alright
    "It's Lagging Alright": {
        "description": "Have 1.200 monsters on the battlefield at the same time.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 285: Mana Hack
    "Mana Hack": {
        "description": "Have 80.000 initial mana.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 286: Zap Away
    "Zap Away": {
        "description": "Cast 175 strike spells.",
        "requirements": ["Ice Shards skill", "Whiteout skill", "Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 287: Snatchers
    "Snatchers": {
        "description": "Gain 3.200 mana from drops.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 288: Killed So Many
    "Killed So Many": {
        "description": "Gain 7.200 xp with kill chains.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 289: Frozen Over
    "Frozen Over": {
        "description": "Gain 4.500 xp with Freeze spell crowd hits.",
        "requirements": ["Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 297: Fusion Core
    "Fusion Core": {
        "description": "Have 16 beam enhanced gems at the same time.",
        "requirements": ["Beam skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 306: Shatter Them All
    "Shatter Them All": {
        "description": "Reach 1.000 beacons destroyed through all the battles.",
        "requirements": ["Beacon element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 310: Outwhited
    "Outwhited": {
        "description": "Gain 4.700 xp with Whiteout spell crowd hits.",
        "requirements": ["Whiteout skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 318: Mass Awakening
    "Mass Awakening": {
        "description": "Lure 2.500 swarmlings out of a sleeping hive.",
        "requirements": ["Sleeping Hive element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 326: There's No Time
    "There's No Time": {
        "description": "Call 140 waves early.",
        "requirements": ["minWave: 140"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 328: White Ring of Death
    "White Ring of Death": {
        "description": "Gain 4.900 xp with Ice Shards spell crowd hits.",
        "requirements": ["Ice Shards skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 329: Shaken Ice
    "Shaken Ice": {
        "description": "Hit 475 frozen monsters with shrines.",
        "requirements": ["Freeze skill", "Shrine element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 330: Nothing Prevails
    "Nothing Prevails": {
        "description": "Reach 25.000 poison kills through all the battles.",
        "requirements": ["Poison skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 334: More Than Enough
    "More Than Enough": {
        "description": "Summon 1.000 monsters by enraging waves.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 338: Enraged is the New Norm
    "Enraged is the New Norm": {
        "description": "Enrage 240 waves.",
        "requirements": ["minWave: 240"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 340: Rugged Defense
    "Rugged Defense": {
        "description": "Have 16 bolt enhanced gems at the same time.",
        "requirements": ["Bolt skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 350: Boatload of Cores
    "Boatload of Cores": {
        "description": "Find 540 shadow cores.",
        "requirements": ["Shadow Core element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 356: Amplifinity
    "Amplifinity": {
        "description": "Build 45 amplifiers.",
        "requirements": ["Amplifiers skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 359: Amulet
    "Amulet": {
        "description": "Fill all the sockets in your talisman.",
        "requirements": ["Shadow Core element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 387: Purple Wand
    "Purple Wand": {
        "description": "Reach wizard level 200.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 388: Brown Wand
    "Brown Wand": {
        "description": "Reach wizard level 300.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 389: Red Wand
    "Red Wand": {
        "description": "Reach wizard level 500.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 407: Trembling
    "Trembling": {
        "description": "Kill 1.500 monsters with gems in traps.",
        "requirements": ["Traps skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 409: Beacon Hunt
    "Beacon Hunt": {
        "description": "Destroy 55 beacons.",
        "requirements": ["Beacon element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 416: Is This a Match-3 or What?
    "Is This a Match-3 or What?": {
        "description": "Have 90 gems on the battlefield.",
        "requirements": ["gemCount: 90"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 420: Don't Break it!
    "Don't Break it!": {
        "description": "Spend 90.000 mana on banishment.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 423: Endgame Balance
    "Endgame Balance": {
        "description": "Have 25.000 shadow cores at the start of the battle.",
        "requirements": ["Shadow Core element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 427: Firefall
    "Firefall": {
        "description": "Have 16 barrage enhanced gems at the same time.",
        "requirements": ["Barrage skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 431: Unending Flow
    "Unending Flow": {
        "description": "Kill 24.000 monsters.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 433: Shrinemaster
    "Shrinemaster": {
        "description": "Reach 20.000 shrine kills through all the battles.",
        "requirements": ["Shrine element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 437: Frostborn
    "Frostborn": {
        "description": "Reach 5.000 strike spells cast through all the battles.",
        "requirements": ["Whiteout skill", "Ice Shards skill", "Freeze skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 441: Charge Fire Repeat
    "Charge Fire Repeat": {
        "description": "Reach 5.000 enhancement spells cast through all the battles.",
        "requirements": ["Bolt skill", "Beam skill", "Barrage skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 445: Ice for Everyone
    "Ice for Everyone": {
        "description": "Reach 100.000 strike spell hits through all the battles.",
        "requirements": ["Freeze skill", "Whiteout skill", "Ice Shards skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 450: Mana Cult
    "Mana Cult": {
        "description": "Leech 6.500 mana from bleeding monsters.",
        "requirements": ["Bleeding skill", "Mana Leech skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 454: To the Last Drop
    "To the Last Drop": {
        "description": "Leech 4.700 mana from poisoned monsters.",
        "requirements": ["Mana Leech skill", "Poison skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 458: Final Cut
    "Final Cut": {
        "description": "Kill 960 bleeding monsters.",
        "requirements": ["Bleeding skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 487: Enough is Enough
    "Enough is Enough": {
        "description": "Have 24 of your gems destroyed or stolen.",
        "requirements": ["Ritual trait", "Specter element", "Watchtower element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 506: Almost Like Hacked
    "Almost Like Hacked": {
        "description": "Have at least 20 different talisman properties.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 512: Cartographer
    "Cartographer": {
        "description": "Have 90 fields lit in Journey mode.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 516: Endured a Lot
    "Endured a Lot": {
        "description": "Have 80 fields lit in Endurance mode.",
        "requirements": ["Endurance"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 520: Worthy
    "Worthy": {
        "description": "Have 70 fields lit in Trial mode.",
        "requirements": ["Trial"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 535: I am Tougher
    "I am Tougher": {
        "description": "Kill 1.360 monsters while there are at least 2 wraiths in th...",
        "requirements": ["Ritual trait", "Wraith element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 540: Taste All The Affixes
    "Taste All The Affixes": {
        "description": "Kill 2.500 monsters with prismatic gem wasps.",
        "requirements": ["Critical Hit skill", "Mana Leech skill", "Bleeding skill", "Armor Tearing skill", "Poison skill", "Slowing skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 548: Scour You All
    "Scour You All": {
        "description": "Kill 660 banished monsters with shrines.",
        "requirements": ["Shrine element"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 552: Be Gone For Good
    "Be Gone For Good": {
        "description": "Kill 790 banished monsters.",
        "requirements": [],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 553: Mixing Up
    "Mixing Up": {
        "description": "Beat 50 waves on max Swarmling and Giant domination traits.",
        "requirements": ["Swarmling Domination trait", "Giant Domination trait", "minWave: 50"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 556: Worst of Both Sizes
    "Worst of Both Sizes": {
        "description": "Beat 300 waves on max Swarmling and Giant domination traits.",
        "requirements": ["Swarmling Domination trait", "Giant Domination trait", "minWave: 300", "Endurance"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 568: Melting Armor
    "Melting Armor": {
        "description": "Tear a total of 10.000 armor with wasp stings.",
        "requirements": ["Armor Tearing skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 572: Need Lots of Them
    "Need Lots of Them": {
        "description": "Beat 60 waves using at most grade 2 gems.",
        "requirements": ["minWave: 60"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 588: Just Give Me That Mana
    "Just Give Me That Mana": {
        "description": "Leech 7.200 mana from whited out monsters.",
        "requirements": ["Mana Leech skill", "Whiteout skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 592: Care to Die Already?
    "Care to Die Already?": {
        "description": "Cast 8 ice shards on the same monster.",
        "requirements": ["Ice Shards skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 600: Max Trap Max leech
    "Max Trap Max leech": {
        "description": "Leech 6.300 mana with a grade 1 gem.",
        "requirements": ["Mana Leech skill", "minGemGrade: 1"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 609: Green Path
    "Green Path": {
        "description": "Kill 9.900 green blooded monsters.",
        "requirements": ["Requires \"hidden codes\""],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
    # ID 613: Handle With Care
    "Handle With Care": {
        "description": "Kill 300 monsters with orblet explosions.",
        "requirements": ["Orb of Presence skill"],
        "modes": {
            "journey": None,
            "endurance": None,
            "trial": None,
        },
    },
}

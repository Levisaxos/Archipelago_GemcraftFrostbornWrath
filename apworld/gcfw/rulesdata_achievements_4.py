"""
GemCraft Frostborn Wrath — Achievement Pack 4

Contains approximately 106 achievements.
Each achievement has a "grindiness" property ("Trivial", "Minor", "Major", "Extreme") for easy adjustment.
"""

achievement_requirements = {
    # ID 0: Lots of Crit Hits
    "Lots of Crit Hits": {
        "description": "Have a pure critical hit gem with 2.000 hits.",
        "requirements": [
        'Critical Hit skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 1: Lots of Scratches
    "Lots of Scratches": {
        "description": "Reach a kill chain of 300.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 2: Major Shutdown
    "Major Shutdown": {
        "description": "Destroy 3 monster nests.",
        "requirements": [
        'Monster Nest element'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 3: Mana Blinded
    "Mana Blinded": {
        "description": "Leech 900 mana from whited out monsters.",
        "requirements": [
        'Mana Leech skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 4: Mana Cult
    "Mana Cult": {
        "description": "Leech 6.500 mana from bleeding monsters.",
        "requirements": [
        'Bleeding skill',
        'Mana Leech skill'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 5: Mana First
    "Mana First": {
        "description": "Deplete a shard when there are more than 300 swarmlings on t...",
        "requirements": [
        'Mana Shard element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 6: Mana Greedy
    "Mana Greedy": {
        "description": "Leech 1.800 mana with a grade 1 gem.",
        "requirements": [
        'Mana Leech skill',
        'minGemGrade: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 7: Mana Hack
    "Mana Hack": {
        "description": "Have 80.000 initial mana.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 8: Mana Magnet
    "Mana Magnet": {
        "description": "Win a battle using only mana leeching gems.",
        "requirements": [
        'Mana Leech skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 9: Mana Salvation
    "Mana Salvation": {
        "description": "Salvage mana by destroying a gem.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 10: Mana Singularity
    "Mana Singularity": {
        "description": "Reach mana pool level 20.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 11: Mana Tap
    "Mana Tap": {
        "description": "Reach 10.000 mana harvested from shards through all the batt...",
        "requirements": [
        'Mana Shard element'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 12: Mana Trader
    "Mana Trader": {
        "description": "Salvage 8.000 mana from gems.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 13: Mana in a Bottle
    "Mana in a Bottle": {
        "description": "Have 40.000 initial mana.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 14: Mana is All I Need
    "Mana is All I Need": {
        "description": "Win a battle with no skill point spent and a battle trait ma...",
        "requirements": [
        'Any battle trait\n\n'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 15: Mana of the Dying
    "Mana of the Dying": {
        "description": "Leech 2.300 mana from poisoned monsters.",
        "requirements": [
        'Mana Leech skill',
        'Poison skill'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 16: Marked Targets
    "Marked Targets": {
        "description": "Reach 10.000 monsters with special properties killed through...",
        "requirements": [
        'Possessed Monster element',
        'Twisted Monster element',
        'Marked Monster element'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 17: Marmalade
    "Marmalade": {
        "description": "Don't destroy any of the jars of wasps.",
        "requirements": [
        'Field X2'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 18: Mass Awakening
    "Mass Awakening": {
        "description": "Lure 2.500 swarmlings out of a sleeping hive.",
        "requirements": [
        'Sleeping Hive element'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 19: Mastery
    "Mastery": {
        "description": "Raise a skill to level 70.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 20: Max Trap Max leech
    "Max Trap Max leech": {
        "description": "Leech 6.300 mana with a grade 1 gem.",
        "requirements": [
        'Mana Leech skill',
        'minGemGrade: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 21: Meet the Spartans
    "Meet the Spartans": {
        "description": "Have 300 monsters on the battlefield at the same time.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 22: Megalithic
    "Megalithic": {
        "description": "Reach 2.000 structures built through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 23: Melting Armor
    "Melting Armor": {
        "description": "Tear a total of 10.000 armor with wasp stings.",
        "requirements": [
        'Armor Tearing skill'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 24: Melting Pulse
    "Melting Pulse": {
        "description": "Hit 75 frozen monsters with shrines.",
        "requirements": [
        'Freeze skill',
        'Shrine element'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 25: Might Need it Later
    "Might Need it Later": {
        "description": "Enhance a gem in an amplifier.",
        "requirements": [
        'Amplifiers skill',
        'Bolt skill',
        'Beam skill',
        'Barrage skill'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 26: Mighty
    "Mighty": {
        "description": "Create a gem with a raw minimum damage of 3.000 or higher.",
        "requirements": [
        'gemCount: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 27: Minefield
    "Minefield": {
        "description": "Kill 300 monsters with gems in traps.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 28: Miniblasts
    "Miniblasts": {
        "description": "Tear a total of 1.250 armor with wasp stings.",
        "requirements": [
        'Armor Tearing skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 29: Minor Detour
    "Minor Detour": {
        "description": "Build 15 walls.",
        "requirements": [
        'Wall element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 30: Mixing Up
    "Mixing Up": {
        "description": "Beat 50 waves on max Swarmling and Giant domination traits.",
        "requirements": [
        'Swarmling Domination trait',
        'Giant Domination trait',
        'minWave: 50'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 31: More Than Enough
    "More Than Enough": {
        "description": "Summon 1.000 monsters by enraging waves.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 32: More Wounds
    "More Wounds": {
        "description": "Kill 125 bleeding monsters with barrage.",
        "requirements": [
        'Barrage skill',
        'Bleeding skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 33: Morning March
    "Morning March": {
        "description": "Lure 500 swarmlings out of a sleeping hive.",
        "requirements": [
        'Sleeping Hive element'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 34: Multifreeze
    "Multifreeze": {
        "description": "Reach 5.000 strike spell hits through all the battles.",
        "requirements": [
        'strikeSpells:1'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 35: Multiline
    "Multiline": {
        "description": "Have at least 5 different talisman properties.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 36: Multinerf
    "Multinerf": {
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
        "grindiness": "Major",
    },
    # ID 37: Mythic Ancient Legendary
    "Mythic Ancient Legendary": {
        "description": "Create a gem with a raw minimum damage of 300.000 or higher.",
        "requirements": [
        'gemCount: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 38: Nature Takes Over
    "Nature Takes Over": {
        "description": "Have no own buildings on the field at the end of the battle.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 39: Near Death
    "Near Death": {
        "description": "Suffer mana loss from a shadow projectile when under 200 man...",
        "requirements": [
        'Shadow element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 40: Necrotrophic
    "Necrotrophic": {
        "description": "Reach 1.000 poison kills through all the battles.",
        "requirements": [
        'Poison skill'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 41: Need Lots of Them
    "Need Lots of Them": {
        "description": "Beat 60 waves using at most grade 2 gems.",
        "requirements": [
        'minWave: 60'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 42: Need More Rage
    "Need More Rage": {
        "description": "Upgrade a gem in the enraging socket.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 43: Needle Storm
    "Needle Storm": {
        "description": "Deal 350 gem wasp stings to creatures.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 44: Nest Blaster
    "Nest Blaster": {
        "description": "Destroy 2 monster nests before wave 12.",
        "requirements": [
        'Monster Nest element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 45: Nest Buster
    "Nest Buster": {
        "description": "Destroy 3 monster nests before wave 6.",
        "requirements": [
        'Monster Nest element'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 46: No Armor Area
    "No Armor Area": {
        "description": "Beat 90 waves using only armor tearing gems.",
        "requirements": [
        'Armor Tearing skill',
        'minWave: 90'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 47: No Beacon Zone
    "No Beacon Zone": {
        "description": "Reach 200 beacons destroyed through all the battles.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 48: No Honor Among Thieves
    "No Honor Among Thieves": {
        "description": "Have a watchtower kill a specter.",
        "requirements": [
        'Ritual trait',
        'Specter element',
        'Watchtower element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 49: No Land for Swarmlings
    "No Land for Swarmlings": {
        "description": "Kill 3.333 swarmlings.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 50: No More Rounds
    "No More Rounds": {
        "description": "Kill 60 banished monsters with shrines.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 51: No Need to Aim
    "No Need to Aim": {
        "description": "Have 4 barrage enhanced gems at the same time.",
        "requirements": [
        'Barrage skill'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 52: No Place to Hide
    "No Place to Hide": {
        "description": "Cast 25 strike spells.",
        "requirements": [
        'strikeSpells: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 53: No Stone Unturned
    "No Stone Unturned": {
        "description": "Open 5 drop holders.",
        "requirements": [
        'Drop Holder element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 54: No Time to Rest
    "No Time to Rest": {
        "description": "Have the Haste trait set to level 6 or higher and win the ba...",
        "requirements": [
        'Haste trait'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 55: No Time to Waste
    "No Time to Waste": {
        "description": "Reach 5.000 waves started early through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 56: No Use of Vitality
    "No Use of Vitality": {
        "description": "Kill a monster having at least 20.000 hit points.",
        "requirements": [
        'A monster with atleast 20.000hp'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 57: No You Won't!
    "No You Won't!": {
        "description": "Destroy a watchtower before it could fire.",
        "requirements": [
        'Bolt skill',
        'Watchtower element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 58: Not Chasing Shadows Anymore
    "Not Chasing Shadows Anymore": {
        "description": "Kill 4 shadows.",
        "requirements": [
        'Ritual trait',
        'Shadow element'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 59: Not So Fast
    "Not So Fast": {
        "description": "Freeze a specter.",
        "requirements": [
        'Freeze skill',
        'Ritual trait',
        'Specter element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 60: Not So Omni Anymore
    "Not So Omni Anymore": {
        "description": "Destroy 10 omnibeacons.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 61: Not Worth It
    "Not Worth It": {
        "description": "Harvest 9.000 mana from a corrupted mana shard.",
        "requirements": [
        'Corrupted Mana Shard element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 62: Nothing Prevails
    "Nothing Prevails": {
        "description": "Reach 25.000 poison kills through all the battles.",
        "requirements": [
        'Poison skill'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 63: Nox Mist
    "Nox Mist": {
        "description": "Win a battle using only poison gems.",
        "requirements": [
        'Poison skill'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 64: Oh Ven
    "Oh Ven": {
        "description": "Spread the poison",
        "requirements": [
        'Poison skill',
        '90 monsters poisoned at the same time'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 65: Ok Flier
    "Ok Flier": {
        "description": "Kill 340 monsters while there are at least 2 wraiths in the ...",
        "requirements": [
        'Ritual trait',
        'Wraith element'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 66: Omelette
    "Omelette": {
        "description": "Reach 200 monster eggs cracked through all the battles.",
        "requirements": [
        'Swarm Queen element'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 67: Omnibomb
    "Omnibomb": {
        "description": "Destroy a building and a non-monster creature with one gem b...",
        "requirements": [
        'Ritual trait'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 68: On the Shoulders of Giants
    "On the Shoulders of Giants": {
        "description": "Have the Giant Domination trait set to level 6 or higher and...",
        "requirements": [
        'Giant Domination trait'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 69: One Hit is All it Takes
    "One Hit is All it Takes": {
        "description": "Kill a wraith with one hit.",
        "requirements": [
        'Ritual trait',
        'Wraith element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 70: One Less Problem
    "One Less Problem": {
        "description": "Destroy a monster nest while there is a wraith on the battle...",
        "requirements": [
        'Ritual trait',
        'Monster Nest element',
        'Wraith element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 71: One by One
    "One by One": {
        "description": "Deliver 750 one hit kills.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 72: Orange Wand
    "Orange Wand": {
        "description": "Reach wizard level 40.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 73: Ouch!
    "Ouch!": {
        "description": "Spend 900 mana on banishment.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 74: Out of Misery
    "Out of Misery": {
        "description": "Kill a monster that is whited out, poisoned, frozen and slow...",
        "requirements": [
        'Freeze skill',
        'Poison skill',
        'Slowing skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 75: Out of Nowhere
    "Out of Nowhere": {
        "description": "Kill a whited out possessed monster with bolt.",
        "requirements": [
        'Bolt skill',
        'Whiteout skill',
        'Possessed Monster element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 76: Outwhited
    "Outwhited": {
        "description": "Gain 4.700 xp with Whiteout spell crowd hits.",
        "requirements": [
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 77: Overheated
    "Overheated": {
        "description": "Kill a giant with beam shot.",
        "requirements": [
        'Beam skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 78: Overpecked
    "Overpecked": {
        "description": "Deal 100 gem wasp stings to the same monster.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 79: Painful Leech
    "Painful Leech": {
        "description": "Leech 3.200 mana from bleeding monsters.",
        "requirements": [
        'Bleeding skill',
        'Mana Leech skill'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 80: Paranormal Paragon
    "Paranormal Paragon": {
        "description": "Reach 500 non-monsters killed through all the battles.",
        "requirements": [
        'Ritual trait'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 81: Pat on the Back
    "Pat on the Back": {
        "description": "Amplify a gem.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 82: Path of Splats
    "Path of Splats": {
        "description": "Kill 400 monsters.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 83: Peek Into The Abyss
    "Peek Into The Abyss": {
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
        "grindiness": "Extreme",
    },
    # ID 84: Pest Control
    "Pest Control": {
        "description": "Kill 333 swarmlings.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 85: Plentiful
    "Plentiful": {
        "description": "Have 1.000 shadow cores at the start of the battle.",
        "requirements": [
        'Shadow Core element'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 86: Pointed Pain
    "Pointed Pain": {
        "description": "Deal 50 gem wasp stings to creatures.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 87: Popped
    "Popped": {
        "description": "Kill at least 30 gatekeeper fangs.",
        "requirements": [
        'Gatekeeper element',
        'Field A4'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 88: Popped Eggs
    "Popped Eggs": {
        "description": "Kill a swarm queen with a bolt.",
        "requirements": [
        'Bolt skill',
        'Swarm Queen element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 89: Popping Lights
    "Popping Lights": {
        "description": "Destroy 5 beacons.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 90: Power Exchange
    "Power Exchange": {
        "description": "Build 25 amplifiers.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 91: Power Flow
    "Power Flow": {
        "description": "Build 15 amplifiers.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 92: Power Node
    "Power Node": {
        "description": "Activate the same shrine 5 times.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 93: Power Overwhelming
    "Power Overwhelming": {
        "description": "Reach mana pool level 15.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 94: Power Sharing
    "Power Sharing": {
        "description": "Build 5 amplifiers.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 95: Powerful
    "Powerful": {
        "description": "Create a gem with a raw minimum damage of 300 or higher.",
        "requirements": [
        'gemCount: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 96: Precious
    "Precious": {
        "description": "Get a gem from a drop holder.",
        "requirements": [
        'Drop Holder element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 97: Prismatic
    "Prismatic": {
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
        "grindiness": "Minor",
    },
    # ID 98: Prismatic Takeaway
    "Prismatic Takeaway": {
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
        "grindiness": "Trivial",
    },
    # ID 99: Punching Deep
    "Punching Deep": {
        "description": "Tear a total of 2.500 armor with wasp stings.",
        "requirements": [
        'Armor Tearing skill'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 100: Puncture Therapy
    "Puncture Therapy": {
        "description": "Deal 950 gem wasp stings to creatures.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 101: Punctured Texture
    "Punctured Texture": {
        "description": "Deal 5.000 gem wasp stings to buildings.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 102: Puncturing Shots
    "Puncturing Shots": {
        "description": "Deliver 75 one hit kills.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 103: Purged
    "Purged": {
        "description": "Kill 179 marked monsters.",
        "requirements": [
        'Marked Monster element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 104: Purist
    "Purist": {
        "description": "Beat 120 waves and don't use any strike or gem enhancement s...",
        "requirements": [
        'minWave: 120'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 105: Purple Wand
    "Purple Wand": {
        "description": "Reach wizard level 200.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
}

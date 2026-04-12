"""
GemCraft Frostborn Wrath — Achievement Pack 3

Contains approximately 106 achievements.
Each achievement has a "grindiness" property ("Trivial", "Minor", "Major", "Extreme") for easy adjustment.
"""

achievement_requirements = {
    # ID 0: Getting Rid of Them
    "Getting Rid of Them": {
        "description": "Drop 48 gem bombs on beacons.",
        "requirements": [
        'Beacon element',
        'gemCount: 48'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 1: Getting Serious
    "Getting Serious": {
        "description": "Have a grade 1 gem with 1.500 hits.",
        "requirements": [
        'minGemGrade: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 2: Getting Waves Done
    "Getting Waves Done": {
        "description": "Reach 2.000 waves started early through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 3: Getting Wet
    "Getting Wet": {
        "description": "Beat 30 waves.",
        "requirements": [
        'minWave: 30'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 4: Glitter Cloud
    "Glitter Cloud": {
        "description": "Kill an apparition with a gem bomb.",
        "requirements": [
        'Ritual trait',
        'Apparition element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 5: Glowing Armada
    "Glowing Armada": {
        "description": "Have 240 gem wasps on the battlefield when the battle ends.",
        "requirements": [
        'gemCount: 240'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 6: Going Deviant
    "Going Deviant": {
        "description": "Rook to a9",
        "requirements": [
        'Scroll to edge of the world map'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 7: Going for the Weak
    "Going for the Weak": {
        "description": "Have a watchtower kill a poisoned monster.",
        "requirements": [
        'Poison skill',
        'Watchtower element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 8: Got the Price Back
    "Got the Price Back": {
        "description": "Have a pure mana leeching gem with 4.500 hits.",
        "requirements": [
        'Mana Leech skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 9: Great Survivor
    "Great Survivor": {
        "description": "Kill a monster from wave 1 when wave 20 has already started.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 10: Green Eyed Ninja
    "Green Eyed Ninja": {
        "description": "Entering: The Wilderness",
        "requirements": [
        'Field N1, U1 or R5'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 11: Green Path
    "Green Path": {
        "description": "Kill 9.900 green blooded monsters.",
        "requirements": [
        'Requires "hidden codes"'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 12: Green Vial
    "Green Vial": {
        "description": "Have more than 75% of the monster kills caused by poison.",
        "requirements": [
        'Poison skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 13: Green Wand
    "Green Wand": {
        "description": "Reach wizard level 60.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 14: Ground Luck
    "Ground Luck": {
        "description": "Find 3 talisman fragments.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 15: Groundfill
    "Groundfill": {
        "description": "Demolish a trap.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 16: Guarding the Fallen Gate
    "Guarding the Fallen Gate": {
        "description": "Have the Corrupted Banishment trait set to level 6 or higher...",
        "requirements": [
        'Corrupted Banishment trait'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 17: Hacked Gem
    "Hacked Gem": {
        "description": "Have a grade 3 gem with 1.200 effective max damage.",
        "requirements": [
        'minGemGrade: 3'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 18: Half Full
    "Half Full": {
        "description": "Add 32 talisman fragments to your shape collection.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 19: Handle With Care
    "Handle With Care": {
        "description": "Kill 300 monsters with orblet explosions.",
        "requirements": [
        'Orb of Presence skill'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 20: Hard Reset
    "Hard Reset": {
        "description": "Reach 5.000 shrine kills through all the battles.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 21: Has Stood Long Enough
    "Has Stood Long Enough": {
        "description": "Destroy a monster nest after the last wave has started.",
        "requirements": [
        'Monster Nest element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 22: Hateful
    "Hateful": {
        "description": "Have the Hatred trait set to level 6 or higher and win the b...",
        "requirements": [
        'Hatred trait'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 23: Hazardous Materials
    "Hazardous Materials": {
        "description": "Put your HEV on first",
        "requirements": [
        'Poison skill',
        'Have atleast 1.000 enemies poisoned and alive on a field'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 24: Healing Denied
    "Healing Denied": {
        "description": "Destroy 3 healing beacons.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 25: Heavily Modified
    "Heavily Modified": {
        "description": "Activate all mods.",
        "requirements": [
        'Requires "hidden codes"'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 26: Heavy Hitting
    "Heavy Hitting": {
        "description": "Have 4 bolt enhanced gems at the same time.",
        "requirements": [
        'Bolt skill'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 27: Heavy Support
    "Heavy Support": {
        "description": "Have 20 beacons on the field at the same time.",
        "requirements": [
        'Dark Masonry trait',
        'Beacon element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 28: Hedgehog
    "Hedgehog": {
        "description": "Kill a swarmling having at least 100 armor.",
        "requirements": [
        'a swarmling with atleast 100 armor'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 29: Helping Hand
    "Helping Hand": {
        "description": "Have a watchtower kill a possessed monster.",
        "requirements": [
        'Possessed Monster element',
        'Watchtower element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 30: Hiding Spot
    "Hiding Spot": {
        "description": "Open 3 drop holders before wave 3.",
        "requirements": [
        'Drop Holder element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 31: High Stakes
    "High Stakes": {
        "description": "Set a battle trait to level 12.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 32: High Targets
    "High Targets": {
        "description": "Reach 100 non-monsters killed through all the battles.",
        "requirements": [
        'Ritual trait'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 33: Hint of Darkness
    "Hint of Darkness": {
        "description": "Kill 189 twisted monsters.",
        "requirements": [
        'Twisted Monster element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 34: Hold Still
    "Hold Still": {
        "description": "Freeze 130 whited out monsters.",
        "requirements": [
        'Freeze skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 35: Hope has fallen
    "Hope has fallen": {
        "description": "Dismantled bunkhouses",
        "requirements": [
        'Field E3'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 36: How About Some Skill Points
    "How About Some Skill Points": {
        "description": "Have 5.000 shadow cores at the start of the battle.",
        "requirements": [
        'Shadow Core element'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 37: Hungry Little Gem
    "Hungry Little Gem": {
        "description": "Leech 3.600 mana with a grade 1 gem.",
        "requirements": [
        'Mana Leech skill',
        'minGemGrade: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 38: Hunt For Hard Targets
    "Hunt For Hard Targets": {
        "description": "Kill 680 monsters while there are at least 2 wraiths in the ...",
        "requirements": [
        'Ritual trait',
        'Wraith element'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 39: Hurtified
    "Hurtified": {
        "description": "Kill 240 bleeding monsters.",
        "requirements": [
        'Bleeding skill'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 40: Hyper Gem
    "Hyper Gem": {
        "description": "Have a grade 3 gem with 600 effective max damage.",
        "requirements": [
        'minGemGrade: 3'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 41: I Have Experience
    "I Have Experience": {
        "description": "Reach 50 battles won.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 42: I Never Asked For This
    "I Never Asked For This": {
        "description": "All my aug points spent",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 43: I Saw Something
    "I Saw Something": {
        "description": "Kill an apparition.",
        "requirements": [
        'Ritual trait',
        'Apparition element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 44: I Warned You...
    "I Warned You...": {
        "description": "Kill a specter while it carries a gem.",
        "requirements": [
        'Ritual trait',
        'Specter element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 45: I am Tougher
    "I am Tougher": {
        "description": "Kill 1.360 monsters while there are at least 2 wraiths in th...",
        "requirements": [
        'Ritual trait',
        'Wraith element'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 46: Ice Cube
    "Ice Cube": {
        "description": "Have a Maximum Charge of 300% for the Freeze Spell.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 47: Ice Mage
    "Ice Mage": {
        "description": "Reach 2.500 strike spells cast through all the battles.",
        "requirements": [
        'strikeSpells: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 48: Ice Snap
    "Ice Snap": {
        "description": "Gain 90 xp with Freeze spell crowd hits.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 49: Ice Stand
    "Ice Stand": {
        "description": "Kill 5 frozen monsters carrying orblets.",
        "requirements": [
        'Freeze skill',
        'Orb of Presence skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 50: Ice for Everyone
    "Ice for Everyone": {
        "description": "Reach 100.000 strike spell hits through all the battles.",
        "requirements": [
        'strikeSpells: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 51: Icecracker
    "Icecracker": {
        "description": "Kill 90 frozen monsters with barrage.",
        "requirements": [
        'Barrage skill',
        'Freeze skill'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 52: Icepicked
    "Icepicked": {
        "description": "Gain 3.200 xp with Ice Shards spell crowd hits.",
        "requirements": [
        'Ice Shards skill'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 53: Icy Fingers
    "Icy Fingers": {
        "description": "Reach 500 strike spells cast through all the battles.",
        "requirements": [
        'strikeSpells:1'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 54: Impaling Charges
    "Impaling Charges": {
        "description": "Deliver 250 one hit kills.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 55: Impenetrable
    "Impenetrable": {
        "description": "Have 8 bolt enhanced gems at the same time.",
        "requirements": [
        'Bolt skill'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 56: Implosion
    "Implosion": {
        "description": "Kill a gatekeeper fang with a gem bomb.",
        "requirements": [
        'Gatekeeper element',
        'Field A4'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 57: Impressive
    "Impressive": {
        "description": "Win a Trial battle without any monster reaching your Orb.",
        "requirements": [
        'Trial'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 58: Impudence
    "Impudence": {
        "description": "Have 6 of your gems destroyed or stolen.",
        "requirements": [
        'Ritual trait',
        'Specter element',
        'Watchtower element'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 59: In Flames
    "In Flames": {
        "description": "Kill 400 spawnlings.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 60: In Focus
    "In Focus": {
        "description": "Amplify a gem with 8 other gems.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 61: In a Blink of an Eye
    "In a Blink of an Eye": {
        "description": "Kill 100 monsters while time is frozen.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 62: In for a Trait
    "In for a Trait": {
        "description": "Activate a battle trait.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 63: Inedible
    "Inedible": {
        "description": "Poison 111 frozen monsters.",
        "requirements": [
        'Freeze skill',
        'Poison skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 64: Insane Investment
    "Insane Investment": {
        "description": "Reach -20% decreased banishment cost with your orb.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 65: Instant Spawn
    "Instant Spawn": {
        "description": "Have a shadow spawn a monster while time is frozen.",
        "requirements": [
        'Ritual trait',
        'Shadow element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 66: Ionized Air
    "Ionized Air": {
        "description": "Have the Insulation trait set to level 6 or higher and win t...",
        "requirements": [
        'Insulation trait'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 67: Is Anyone in There?
    "Is Anyone in There?": {
        "description": "Break a tomb open.",
        "requirements": [
        'Tomb element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 68: Is This a Match-3 or What?
    "Is This a Match-3 or What?": {
        "description": "Have 90 gems on the battlefield.",
        "requirements": [
        'gemCount: 90'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 69: It Has to Do
    "It Has to Do": {
        "description": "Beat 50 waves using at most grade 2 gems.",
        "requirements": [
        'minWave: 50'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 70: It Hurts!
    "It Hurts!": {
        "description": "Spend 9.000 mana on banishment.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 71: It was Abandoned Anyway
    "It was Abandoned Anyway": {
        "description": "Destroy a dwelling.",
        "requirements": [
        'Abandoned Dwelling element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 72: It's Lagging Alright
    "It's Lagging Alright": {
        "description": "Have 1.200 monsters on the battlefield at the same time.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 73: It's a Trap
    "It's a Trap": {
        "description": "Don't let any monster touch your orb for 120 beaten waves.",
        "requirements": [
        'minWave: 120'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 74: Itchy Sphere
    "Itchy Sphere": {
        "description": "Deliver 3.600 banishments with your orb.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 75: Jewel Box
    "Jewel Box": {
        "description": "Fill all inventory slots with gems.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 76: Jinx Blast
    "Jinx Blast": {
        "description": "Kill 30 whited out monsters with bolt.",
        "requirements": [
        'Bolt skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 77: Juggler
    "Juggler": {
        "description": "Use demolition 7 times.",
        "requirements": [
        'Demolition skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 78: Just Breathe In
    "Just Breathe In": {
        "description": "Enhance a pure poison gem having random priority with beam.",
        "requirements": [
        'Beam skill',
        'Poison skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 79: Just Fire More at Them
    "Just Fire More at Them": {
        "description": "Have the Thick Air trait set to level 6 or higher and win th...",
        "requirements": [
        'Thick Air trait'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 80: Just Give Me That Mana
    "Just Give Me That Mana": {
        "description": "Leech 7.200 mana from whited out monsters.",
        "requirements": [
        'Mana Leech skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 81: Just Started
    "Just Started": {
        "description": "Reach 10 battles won.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 82: Just Take My Mana!
    "Just Take My Mana!": {
        "description": "Spend 900.000 mana on banishment.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 83: Keep Losing Keep Harvesting
    "Keep Losing Keep Harvesting": {
        "description": "Deplete a mana shard while there is a shadow on the battlefi...",
        "requirements": [
        'Ritual trait',
        'Mana Shard element',
        'Shadow element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 84: Keepers
    "Keepers": {
        "description": "Gain 800 mana from drops.",
        "requirements": [
        'Apparition element',
        'Corrupted Mana Shard element',
        'Mana Shard element',
        'Drop Holder element'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 85: Keeping Low
    "Keeping Low": {
        "description": "Beat 40 waves using at most grade 2 gems.",
        "requirements": [
        'minWave: 40'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 86: Killed So Many
    "Killed So Many": {
        "description": "Gain 7.200 xp with kill chains.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 87: Knowledge Seeker
    "Knowledge Seeker": {
        "description": "Open a wizard stash.",
        "requirements": [
        'Wizard Stash element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 88: Lagging Already?
    "Lagging Already?": {
        "description": "Have 900 monsters on the battlefield at the same time.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 89: Landing Spot
    "Landing Spot": {
        "description": "Demolish 20 or more walls with falling spires.",
        "requirements": [
        'Ritual trait',
        'Spire element',
        'Wall element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 90: Laser Slicer
    "Laser Slicer": {
        "description": "Have 8 beam enhanced gems at the same time.",
        "requirements": [
        'Beam skill'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 91: Last Minute Mana
    "Last Minute Mana": {
        "description": "Leech 500 mana from poisoned monsters.",
        "requirements": [
        'Mana Leech skill',
        'Poison skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 92: Legendary
    "Legendary": {
        "description": "Create a gem with a raw minimum damage of 30.000 or higher.",
        "requirements": [
        'gemCount: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 93: Let Them Hatch
    "Let Them Hatch": {
        "description": "Don't crack any egg laid by a swarm queen.",
        "requirements": [
        'Swarm Queen element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 94: Let it Go
    "Let it Go": {
        "description": "Leave an apparition alive.",
        "requirements": [
        'Ritual trait',
        'Apparition element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 95: Let's Have a Look
    "Let's Have a Look": {
        "description": "Open a drop holder.",
        "requirements": [
        'Drop Holder element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 96: Light My Path
    "Light My Path": {
        "description": "Have 70 fields lit in Journey mode.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 97: Like a Necro
    "Like a Necro": {
        "description": "Kill 25 monsters with frozen corpse explosion.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 98: Limited Vision
    "Limited Vision": {
        "description": "Gain 100 xp with Whiteout spell crowd hits.",
        "requirements": [
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 99: Liquid Explosive
    "Liquid Explosive": {
        "description": "Kill 180 monsters with orblet explosions.",
        "requirements": [
        'Orb of Presence skill'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 100: Locked and Loaded
    "Locked and Loaded": {
        "description": "Have 3 pylons charged up to 3 shots each.",
        "requirements": [
        'Pylons skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 101: Long Crawl
    "Long Crawl": {
        "description": "Win a battle using only slowing gems.",
        "requirements": [
        'Slowing skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 102: Long Lasting
    "Long Lasting": {
        "description": "Reach 500 poison kills through all the battles.",
        "requirements": [
        'Poison skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 103: Long Run
    "Long Run": {
        "description": "Beat 360 waves.",
        "requirements": [
        'minWave: 360'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 104: Longrunner
    "Longrunner": {
        "description": "Have 60 fields lit in Endurance mode.",
        "requirements": [
        'Endurance'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 105: Lost Signal
    "Lost Signal": {
        "description": "Destroy 35 beacons.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
}

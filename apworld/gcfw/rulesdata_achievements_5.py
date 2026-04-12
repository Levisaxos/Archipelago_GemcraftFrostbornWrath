"""
GemCraft Frostborn Wrath — Achievement Pack 5

Contains approximately 106 achievements.
Each achievement has a "grindiness" property ("Trivial", "Minor", "Major", "Extreme") for easy adjustment.
"""

achievement_requirements = {
    # ID 0: Put Those Down Now!
    "Put Those Down Now!": {
        "description": "Have 10 orblets carried by monsters at the same time.",
        "requirements": [
        'Orb of Presence skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 1: Puzzling Bunch
    "Puzzling Bunch": {
        "description": "Add 16 talisman fragments to your shape collection.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 2: Pylons of Destruction
    "Pylons of Destruction": {
        "description": "Reach 5.000 pylon kills through all the battles.",
        "requirements": [
        'Pylons skill'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 3: Quadpierced
    "Quadpierced": {
        "description": "Cast 4 ice shards on the same monster.",
        "requirements": [
        'Ice Shards skill'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 4: Quick Circle
    "Quick Circle": {
        "description": "Create a grade 12 gem before wave 12.",
        "requirements": [
        'minGemGrade: 12'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 5: Quicksave
    "Quicksave": {
        "description": "Instantly drop a gem to your inventory.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 6: Quite a List
    "Quite a List": {
        "description": "Have at least 15 different talisman properties.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 7: Rage Control
    "Rage Control": {
        "description": "Kill 400 enraged swarmlings with barrage.",
        "requirements": [
        'Barrage skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 8: Rageout
    "Rageout": {
        "description": "Enrage 30 waves.",
        "requirements": [
        'minWave: 30'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 9: Rageroom
    "Rageroom": {
        "description": "Build 100 walls and start 100 enraged waves.",
        "requirements": [
        'Wall element',
        'minWave: 100'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 10: Raging Habit
    "Raging Habit": {
        "description": "Enrage 80 waves.",
        "requirements": [
        'minWave: 80'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 11: Rainbow Strike
    "Rainbow Strike": {
        "description": "Kill 900 monsters with prismatic gem wasps.",
        "requirements": [
        'Critical Hit skill',
        'Mana Leech skill',
        'Bleeding skill',
        'Armor Tearing skill',
        'Slowing skill',
        'Poison skill'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 12: Raindrop
    "Raindrop": {
        "description": "Drop 18 gem bombs while it's raining.",
        "requirements": [
        'gemCount: 18'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 13: Razor Path
    "Razor Path": {
        "description": "Build 60 traps.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 14: Red Orange
    "Red Orange": {
        "description": "Leech 700 mana from bleeding monsters.",
        "requirements": [
        'Bleeding skill',
        'Mana Leech skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 15: Red Wand
    "Red Wand": {
        "description": "Reach wizard level 500.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 16: Refrost
    "Refrost": {
        "description": "Freeze 111 frozen monsters.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 17: Regaining Knowledge
    "Regaining Knowledge": {
        "description": "Acquire 5 skills.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 18: Renzokuken
    "Renzokuken": {
        "description": "Break your frozen time gem bombing limits",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 19: Resourceful
    "Resourceful": {
        "description": "Reach 5.000 mana harvested from shards through all the battl...",
        "requirements": [
        'Mana Shard element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 20: Restless
    "Restless": {
        "description": "Call 35 waves early.",
        "requirements": [
        'minWave: 35'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Minor",
    },
    # ID 21: Return of Investment
    "Return of Investment": {
        "description": "Leech 900 mana with a grade 1 gem.",
        "requirements": [
        'Mana Leech skill',
        'minGemGrade: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 22: Riding the Waves
    "Riding the Waves": {
        "description": "Reach 1.000 waves beaten through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 23: Rising Tide
    "Rising Tide": {
        "description": "Banish 150 monsters while there are 2 or more wraiths on the...",
        "requirements": [
        'Ritual trait',
        'Wraith element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 24: Roof Knocking
    "Roof Knocking": {
        "description": "Deal 20 gem wasp stings to buildings.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 25: Root Canal
    "Root Canal": {
        "description": "Destroy 2 monster nests.",
        "requirements": [
        'Monster Nest element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 26: Rooting From Afar
    "Rooting From Afar": {
        "description": "Kill a gatekeeper fang with a barrage shell.",
        "requirements": [
        'Barrage skill',
        'Gatekeeper element',
        'Field A4'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 27: Rotten Aura
    "Rotten Aura": {
        "description": "Leech 1.100 mana from poisoned monsters.",
        "requirements": [
        'Mana Leech skill',
        'Poison skill'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 28: Rough Path
    "Rough Path": {
        "description": "Kill 60 monsters with gems in traps.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 29: Round Cut
    "Round Cut": {
        "description": "Create a grade 12 gem.",
        "requirements": [
        'minGemGrade: 12'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 30: Round Cut Plus
    "Round Cut Plus": {
        "description": "Create a grade 16 gem.",
        "requirements": [
        'minGemGrade: 16'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 31: Route Planning
    "Route Planning": {
        "description": "Destroy 5 barricades.",
        "requirements": [
        'Barricade element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 32: Rugged Defense
    "Rugged Defense": {
        "description": "Have 16 bolt enhanced gems at the same time.",
        "requirements": [
        'Bolt skill'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 33: Ruined Ghost Town
    "Ruined Ghost Town": {
        "description": "Destroy 5 dwellings.",
        "requirements": [
        'Abandoned Dwelling element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 34: Safe and Secure
    "Safe and Secure": {
        "description": "Strengthen your orb with 7 gems in amplifiers.",
        "requirements": [
        'Amplifiers skill',
        'gemCount: 7'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 35: Salvation
    "Salvation": {
        "description": "Hit 150 whited out monsters with shrines.",
        "requirements": [
        'Whiteout skill',
        'Shrine element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 36: Scare Tactics
    "Scare Tactics": {
        "description": "Cast 5 strike spells.",
        "requirements": [
        'strikeSpells:1'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 37: Scour You All
    "Scour You All": {
        "description": "Kill 660 banished monsters with shrines.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 38: Second Thoughts
    "Second Thoughts": {
        "description": "Add a different enhancement on an enhanced gem.",
        "requirements": [
        'enhancementSpells: 2'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 39: Seen Battle
    "Seen Battle": {
        "description": "Have a grade 1 gem with 500 hits.",
        "requirements": [
        'minGemGrade: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 40: Settlement
    "Settlement": {
        "description": "Build 15 towers.",
        "requirements": [
        'Tower element'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 41: Shaken Ice
    "Shaken Ice": {
        "description": "Hit 475 frozen monsters with shrines.",
        "requirements": [
        'Freeze skill',
        'Shrine element'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 42: Shapeshifter
    "Shapeshifter": {
        "description": "Complete your talisman fragment shape collection.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 43: Shard Siphon
    "Shard Siphon": {
        "description": "Reach 20.000 mana harvested from shards through all the batt...",
        "requirements": [
        'Mana Shard element'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 44: Shardalot
    "Shardalot": {
        "description": "Cast 6 ice shards on the same monster.",
        "requirements": [
        'Ice Shards skill'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 45: Sharp Shot
    "Sharp Shot": {
        "description": "Kill a shadow with a shot fired by a gem having at least 5.0...",
        "requirements": [
        'Ritual trait',
        'Shadow element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 46: Sharpened
    "Sharpened": {
        "description": "Enhance a gem in a trap.",
        "requirements": [
        'Traps skill',
        'Beam skill',
        'Bolt skill',
        'Barrage skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 47: Shatter Them All
    "Shatter Them All": {
        "description": "Reach 1.000 beacons destroyed through all the battles.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 48: Shattered Orb
    "Shattered Orb": {
        "description": "Lose a battle.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 49: Shattered Waves
    "Shattered Waves": {
        "description": "Hit 225 frozen monsters with shrines.",
        "requirements": [
        'Freeze skill',
        'Shrine element'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 50: Shattering
    "Shattering": {
        "description": "Kill 90 frozen monsters with bolt.",
        "requirements": [
        'Bolt skill',
        'Freeze skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 51: Shavings All Around
    "Shavings All Around": {
        "description": "Win a battle using only armor tearing gems.",
        "requirements": [
        'Armor Tearing skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 52: Shell Shock
    "Shell Shock": {
        "description": "Have 8 barrage enhanced gems at the same time.",
        "requirements": [
        'Barrage skill'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 53: Shieldbreaker
    "Shieldbreaker": {
        "description": "Destroy 3 shield beacons.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 54: Shooting Where it Hurts
    "Shooting Where it Hurts": {
        "description": "Beat 90 waves using only critical hit gems.",
        "requirements": [
        'Critical Hit skill',
        'minWave: 90'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 55: Short Tempered
    "Short Tempered": {
        "description": "Call 5 waves early.",
        "requirements": [
        'minWave: 5'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 56: Shovel Swing
    "Shovel Swing": {
        "description": "Hit 15 frozen monsters with shrines.",
        "requirements": [
        'Freeze skill',
        'Shrine element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 57: Shred Some Armor
    "Shred Some Armor": {
        "description": "Have a pure armor tearing gem with 3.000 hits.",
        "requirements": [
        'Armor Tearing skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 58: Shrinemaster
    "Shrinemaster": {
        "description": "Reach 20.000 shrine kills through all the battles.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 59: Sigil
    "Sigil": {
        "description": "Fill all the sockets in your talisman with fragments upgrade...",
        "requirements": [
        'Shadow Core element'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 60: Size Matters
    "Size Matters": {
        "description": "Beat 100 waves on max Swarmling and Giant domination traits.",
        "requirements": [
        'Swarmling Domination trait',
        'Giant Domination trait',
        'minWave: 100'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 61: Skillful
    "Skillful": {
        "description": "Acquire and raise all skills to level 5 or above.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 62: Skylark
    "Skylark": {
        "description": "Call every wave early in a battle.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 63: Sliced Ice
    "Sliced Ice": {
        "description": "Gain 1.800 xp with Ice Shards spell crowd hits.",
        "requirements": [
        'Ice Shards skill'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 64: Slime Block
    "Slime Block": {
        "description": "Nine slimeballs is all it takes",
        "requirements": [
        'A monster with atleast 20.000hp'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 65: Slow Creep
    "Slow Creep": {
        "description": "Poison 130 whited out monsters.",
        "requirements": [
        'Poison skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 66: Slow Drain
    "Slow Drain": {
        "description": "Deal 10.000 poison damage to a monster.",
        "requirements": [
        'Poison skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 67: Slow Motion
    "Slow Motion": {
        "description": "Enhance a pure slowing gem having random priority with beam.",
        "requirements": [
        'Beam skill',
        'Slowing skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 68: Slowly but Surely
    "Slowly but Surely": {
        "description": "Beat 90 waves using only slowing gems.",
        "requirements": [
        'Slowing skill',
        'minWave: 90'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 69: Smoke in the Sky
    "Smoke in the Sky": {
        "description": "Reach 20 non-monsters killed through all the battles.",
        "requirements": [
        'Ritual trait'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 70: Snatchers
    "Snatchers": {
        "description": "Gain 3.200 mana from drops.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 71: Snow Blower
    "Snow Blower": {
        "description": "Kill 20 frozen monsters with barrage.",
        "requirements": [
        'Barrage skill',
        'Freeze skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 72: Snow Dust
    "Snow Dust": {
        "description": "Kill 95 frozen monsters while it's snowing.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 73: Snowball
    "Snowball": {
        "description": "Drop 27 gem bombs while it's snowing.",
        "requirements": [
        'gemCount: 27'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 74: Snowdust Blindness
    "Snowdust Blindness": {
        "description": "Gain 2.300 xp with Whiteout spell crowd hits.",
        "requirements": [
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 75: So Attached
    "So Attached": {
        "description": "Win a Trial battle without losing any orblets.",
        "requirements": [
        'Trial'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 76: So Early
    "So Early": {
        "description": "Reach 1.000 waves started early through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 77: So Enduring
    "So Enduring": {
        "description": "Have the Adaptive Carapace trait set to level 6 or higher an...",
        "requirements": [
        'Adaptive Carapace trait'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 78: Socketed Rage
    "Socketed Rage": {
        "description": "Enrage a wave.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 79: Something Special
    "Something Special": {
        "description": "Reach 2.000 monsters with special properties killed through ...",
        "requirements": [
        'Possessed Monster element',
        'Twisted Monster element',
        'Marked Monster element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 80: Sparse Snares
    "Sparse Snares": {
        "description": "Build 10 traps.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 81: Special Purpose
    "Special Purpose": {
        "description": "Change the target priority of a gem.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 82: Spectrin Tetramer
    "Spectrin Tetramer": {
        "description": "Have the Vital Link trait set to level 6 or higher and win t...",
        "requirements": [
        'Vital Link trait'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 83: Spitting Darkness
    "Spitting Darkness": {
        "description": "Leave a gatekeeper fang alive until it can launch 100 projec...",
        "requirements": [
        'Gatekeeper element',
        'Field A4'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 84: Splash Swim Splash
    "Splash Swim Splash": {
        "description": "Full of oxygen",
        "requirements": [
        'Click on water in a field\nRequires a field with water'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 85: Starter Pack
    "Starter Pack": {
        "description": "Add 8 talisman fragments to your shape collection.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 86: Stash No More
    "Stash No More": {
        "description": "Destroy a previously opened wizard stash.",
        "requirements": [
        'Wizard Stash element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 87: Stay Some More
    "Stay Some More": {
        "description": "Cast freeze on an apparition 3 times.",
        "requirements": [
        'Freeze skill',
        'Ritual trait',
        'Apparition element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 88: Still Alive
    "Still Alive": {
        "description": "Beat 60 waves.",
        "requirements": [
        'minWave: 60'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 89: Still Chill
    "Still Chill": {
        "description": "Gain 1.500 xp with Freeze spell crowd hits.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 90: Still Lit
    "Still Lit": {
        "description": "Have 15 or more beacons standing at the end of the battle.",
        "requirements": [
        'Dark Masonry trait',
        'Beacon element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 91: Still No Match
    "Still No Match": {
        "description": "Destroy an omnibeacon.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 92: Sting Stack
    "Sting Stack": {
        "description": "Deal 1.000 gem wasp stings to buildings.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 93: Stinging Sphere
    "Stinging Sphere": {
        "description": "Deliver 100 banishments with your orb.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 94: Stingy Cloud
    "Stingy Cloud": {
        "description": "Reach 5.000 gem wasp kills through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 95: Stingy Downfall
    "Stingy Downfall": {
        "description": "Deal 400 wasp stings to a spire.",
        "requirements": [
        'Ritual trait',
        'Spire element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 96: Stirring Up the Nest
    "Stirring Up the Nest": {
        "description": "Deliver gem bomb and wasp kills only.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 97: Stockpile
    "Stockpile": {
        "description": "Have 30 fragments in your talisman inventory.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 98: Stolen Shine
    "Stolen Shine": {
        "description": "Leech 2.700 mana from whited out monsters.",
        "requirements": [
        'Mana Leech skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 99: Stone Monument
    "Stone Monument": {
        "description": "Build 240 walls.",
        "requirements": [
        'Wall element'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 100: Stones to Dust
    "Stones to Dust": {
        "description": "Demolish one of your structures.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 101: Stormbringer
    "Stormbringer": {
        "description": "Reach 1.000 strike spells cast through all the battles.",
        "requirements": [
        'strikeSpells: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 102: Stormed Beacons
    "Stormed Beacons": {
        "description": "Destroy 15 beacons.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 103: Strike Anywhere
    "Strike Anywhere": {
        "description": "Cast a strike spell.",
        "requirements": [
        'strikeSpells:1'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 104: Stronger Than Before
    "Stronger Than Before": {
        "description": "Set corrupted banishment to level 12 and banish a monster 3 ...",
        "requirements": [
        'Corrupted Banishment trait'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 105: Stumbling
    "Stumbling": {
        "description": "Hit the same monster with traps 100 times.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
}

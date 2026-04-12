"""
GemCraft Frostborn Wrath — Achievement Pack 2

Contains approximately 106 achievements.
Each achievement has a "grindiness" property ("Trivial", "Minor", "Major", "Extreme") for easy adjustment.
"""

achievement_requirements = {
    # ID 0: Core Pouch
    "Core Pouch": {
        "description": "Have 100 shadow cores at the start of the battle.",
        "requirements": [
        'Shadow Core element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 1: Corrosive Stings
    "Corrosive Stings": {
        "description": "Tear a total of 5.000 armor with wasp stings.",
        "requirements": [
        'Armor Tearing skill'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 2: Couldn't Decide
    "Couldn't Decide": {
        "description": "Kill 400 monsters with prismatic gem wasps.",
        "requirements": [
        'Critical Hit skill',
        'Mana Leech skill',
        'Bleeding skill',
        'Armor Tearing skill',
        'Poison skill',
        'Slowing skill',
        'gemCount: 6'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 3: Crimson Journal
    "Crimson Journal": {
        "description": "Reach 100.000 monsters killed through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 4: Crowd Control
    "Crowd Control": {
        "description": "Have the Overcrowd trait set to level 6 or higher and win th...",
        "requirements": [
        'Overcrowd trait'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 5: Crowded Queue
    "Crowded Queue": {
        "description": "Have 600 monsters on the battlefield at the same time.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 6: Crunchy Bites
    "Crunchy Bites": {
        "description": "Kill 160 frozen swarmlings.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 7: Damage Support
    "Damage Support": {
        "description": "Have a pure bleeding gem with 2.500 hits.",
        "requirements": [
        'Bleeding skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 8: Darkness Walk With Me
    "Darkness Walk With Me": {
        "description": "Kill 3 shadows.",
        "requirements": [
        'Ritual trait',
        'Shadow element'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 9: Deadly Curse
    "Deadly Curse": {
        "description": "Reach 5.000 poison kills through all the battles.",
        "requirements": [
        'Poison skill'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 10: Deal Some Damage Too
    "Deal Some Damage Too": {
        "description": "Have 5 traps with bolt enhanced gems in them.",
        "requirements": [
        'Bolt skill',
        'Traps skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 11: Deathball
    "Deathball": {
        "description": "Reach 1.000 pylon kills through all the battles.",
        "requirements": [
        'Pylons skill'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 12: Deckard Would Be Proud
    "Deckard Would Be Proud": {
        "description": "All I could get for a prismatic amulet",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 13: Deluminati
    "Deluminati": {
        "description": "Have the Dark Masonry trait set to level 6 or higher and win...",
        "requirements": [
        'Dark Masonry trait'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 14: Denested
    "Denested": {
        "description": "Destroy 5 monster nests.",
        "requirements": [
        'Monster Nest element'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 15: Derangement
    "Derangement": {
        "description": "Decrease the range of a gem.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 16: Desperate Clash
    "Desperate Clash": {
        "description": "Reach -16% decreased banishment cost with your orb.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 17: Diabolic Trophy
    "Diabolic Trophy": {
        "description": "Kill 666 swarmlings.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 18: Dichromatic
    "Dichromatic": {
        "description": "Combine two gems of different colors.",
        "requirements": [
        'gemCount: 2'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 19: Disciple
    "Disciple": {
        "description": "Have 10 fields lit in Trial mode.",
        "requirements": [
        'Trial'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 20: Disco Ball
    "Disco Ball": {
        "description": "Have a gem of 6 components in a lantern.",
        "requirements": [
        'Lanterns skill',
        'Critical Hit skill',
        'Mana Leech skill',
        'Bleeding skill',
        'Armor Tearing skill',
        'Poison skill',
        'Slowing skill',
        'gemCount: 6'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 21: Don't Break it!
    "Don't Break it!": {
        "description": "Spend 90.000 mana on banishment.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 22: Don't Look at the Light
    "Don't Look at the Light": {
        "description": "Reach 10.000 shrine kills through all the battles.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 23: Don't Touch it!
    "Don't Touch it!": {
        "description": "Kill a specter.",
        "requirements": [
        'Ritual trait',
        'Specter element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 24: Doom Drop
    "Doom Drop": {
        "description": "Kill a possessed giant with barrage.",
        "requirements": [
        'Barrage skill',
        'Possessed Monster element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 25: Double Punch
    "Double Punch": {
        "description": "Have 2 bolt enhanced gems at the same time.",
        "requirements": [
        'Bolt skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 26: Double Sharded
    "Double Sharded": {
        "description": "Cast 2 ice shards on the same monster.",
        "requirements": [
        'Ice Shards skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 27: Double Splash
    "Double Splash": {
        "description": "Kill two non-monster creatures with one gem bomb.",
        "requirements": [
        'Ritual trait'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 28: Double Strike
    "Double Strike": {
        "description": "Activate the same shrine 2 times.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 29: Drone Warfare
    "Drone Warfare": {
        "description": "Reach 20.000 gem wasp kills through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 30: Drop the Ice
    "Drop the Ice": {
        "description": "Reach 50.000 strike spell hits through all the battles.",
        "requirements": [
        'strikeSpells: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 31: Drumroll
    "Drumroll": {
        "description": "Deal 200 gem wasp stings to buildings.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 32: Dry Puddle
    "Dry Puddle": {
        "description": "Harvest all mana from a mana shard.",
        "requirements": [
        'Mana Shard element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 33: Dual Downfall
    "Dual Downfall": {
        "description": "Kill 2 spires.",
        "requirements": [
        'Ritual trait',
        'Spire element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 34: Dual Pulse
    "Dual Pulse": {
        "description": "Have 2 beam enhanced gems at the same time.",
        "requirements": [
        'Beam skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 35: Eagle Eye
    "Eagle Eye": {
        "description": "Reach an amplified gem range of 18.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 36: Early Bird
    "Early Bird": {
        "description": "Reach 500 waves started early through all the battles.",
        "requirements": [
        'minWave: 500'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 37: Early Harvest
    "Early Harvest": {
        "description": "Harvest 2.500 mana from shards before wave 3 starts.",
        "requirements": [
        'Mana Shard element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 38: Earthquake
    "Earthquake": {
        "description": "Activate shrines a total of 4 times.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 39: Easy Kill
    "Easy Kill": {
        "description": "Kill 120 bleeding monsters.",
        "requirements": [
        'Bleeding skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 40: Eat my Light
    "Eat my Light": {
        "description": "Kill a wraith with a shrine strike.",
        "requirements": [
        'Ritual trait',
        'Shrine element',
        'Wraith element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 41: Eggcracker
    "Eggcracker": {
        "description": "Don't let any egg laid by a swarm queen to hatch on its own.",
        "requirements": [
        'Swarm Queen element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 42: Eggnog
    "Eggnog": {
        "description": "Crack a monster egg open while time is frozen.",
        "requirements": [
        'Swarm Queen element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 43: Eggs Royale
    "Eggs Royale": {
        "description": "Reach 1.000 monster eggs cracked through all the battles.",
        "requirements": [
        'Swarm Queen element'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 44: Elementary
    "Elementary": {
        "description": "Beat 30 waves using at most grade 2 gems.",
        "requirements": [
        'minWave: 30'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 45: End of the Tunnel
    "End of the Tunnel": {
        "description": "Kill an apparition with a shrine strike.",
        "requirements": [
        'Ritual trait',
        'Apparition element',
        'Shrine element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 46: Endgame Balance
    "Endgame Balance": {
        "description": "Have 25.000 shadow cores at the start of the battle.",
        "requirements": [
        'Shadow Core element'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 47: Endured a Lot
    "Endured a Lot": {
        "description": "Have 80 fields lit in Endurance mode.",
        "requirements": [
        'Endurance'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 48: Enhance Like No Tomorrow
    "Enhance Like No Tomorrow": {
        "description": "Reach 2.500 enhancement spells cast through all the battles.",
        "requirements": [
        'enhancementSpells: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 49: Enhancement Storage
    "Enhancement Storage": {
        "description": "Enhance a gem in the inventory.",
        "requirements": [
        'enhancementSpells: 3'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 50: Enhancing Challenge
    "Enhancing Challenge": {
        "description": "Beat 200 waves on max Swarmling and Giant domination traits.",
        "requirements": [
        'Swarmling Domination trait',
        'Giant Domination trait',
        'minWave: 200',
        'Endurance'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 51: Enough Frozen Time Trickery
    "Enough Frozen Time Trickery": {
        "description": "Kill a shadow while time is frozen.",
        "requirements": [
        'Shadow element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 52: Enough is Enough
    "Enough is Enough": {
        "description": "Have 24 of your gems destroyed or stolen.",
        "requirements": [
        'Ritual trait',
        'Specter element',
        'Watchtower element'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 53: Enraged is the New Norm
    "Enraged is the New Norm": {
        "description": "Enrage 240 waves.",
        "requirements": [
        'minWave: 240'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 54: Ensnared
    "Ensnared": {
        "description": "Kill 12 monsters with gems in traps.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 55: Enter The Gate
    "Enter The Gate": {
        "description": "Kill the gatekeeper.",
        "requirements": [
        'Gatekeeper element',
        'Field A4'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 56: Entrenched
    "Entrenched": {
        "description": "Build 20 traps.",
        "requirements": [
        'Traps skill'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 57: Epidemic Gem
    "Epidemic Gem": {
        "description": "Have a pure poison gem with 3.500 hits.",
        "requirements": [
        'Poison skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 58: Even if You Thaw
    "Even if You Thaw": {
        "description": "Whiteout 120 frozen monsters.",
        "requirements": [
        'Freeze skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 59: Every Hit Counts
    "Every Hit Counts": {
        "description": "Deliver 3750 one hit kills.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 60: Exorcism
    "Exorcism": {
        "description": "Kill 199 possessed monsters.",
        "requirements": [
        'Possessed Monster element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 61: Expert
    "Expert": {
        "description": "Have 50 fields lit in Trial mode.",
        "requirements": [
        'Trial'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 62: Extorted
    "Extorted": {
        "description": "Harvest all mana from 3 mana shards.",
        "requirements": [
        'Mana Shard element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 63: Face the Phobia
    "Face the Phobia": {
        "description": "Have the Swarmling Parasites trait set to level 6 or higher ...",
        "requirements": [
        'Swarmling Parasites trait'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 64: Family Friendlier
    "Family Friendlier": {
        "description": "Kill 900 green blooded monsters.",
        "requirements": [
        'Requires "hidden codes"'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 65: Farewell
    "Farewell": {
        "description": "Kill an apparition with one hit.",
        "requirements": [
        'Ritual trait',
        'Apparition element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 66: Feels Like Endurance
    "Feels Like Endurance": {
        "description": "Beat 120 waves.",
        "requirements": [
        'minWave: 120'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 67: Fierce Encounter
    "Fierce Encounter": {
        "description": "Reach -8% decreased banishment cost with your orb.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 68: Fifth Grader
    "Fifth Grader": {
        "description": "Create a grade 5 gem.",
        "requirements": [
        'minGemGrade: 5'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 69: Filled 5 Times
    "Filled 5 Times": {
        "description": "Reach mana pool level 5.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 70: Final Cut
    "Final Cut": {
        "description": "Kill 960 bleeding monsters.",
        "requirements": [
        'Bleeding skill'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 71: Final Touch
    "Final Touch": {
        "description": "Kill a spire with a gem wasp.",
        "requirements": [
        'Ritual trait',
        'Spire element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 72: Finders
    "Finders": {
        "description": "Gain 200 mana from drops.",
        "requirements": [
        'Mana Shard element',
        'Corrupted Mana Shard element',
        'Drop Holder element',
        'Apparition element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 73: Fire Away
    "Fire Away": {
        "description": "Cast a gem enhancement spell.",
        "requirements": [
        'enhancementSpells: 2'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 74: Fire in the Hole
    "Fire in the Hole": {
        "description": "Destroy a monster nest.",
        "requirements": [
        'Monster Nest element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 75: Firefall
    "Firefall": {
        "description": "Have 16 barrage enhanced gems at the same time.",
        "requirements": [
        'Barrage skill'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 76: First Blood
    "First Blood": {
        "description": "Kill a monster.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 77: First Puzzle Piece
    "First Puzzle Piece": {
        "description": "Find a talisman fragment.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Trivial",
    },
    # ID 78: Flip Flop
    "Flip Flop": {
        "description": "Win a flipped field battle.",
        "requirements": [
        'Requires "hidden codes"'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 79: Flows Through my Veins
    "Flows Through my Veins": {
        "description": "Reach mana pool level 10.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 80: Flying Multikill
    "Flying Multikill": {
        "description": "Destroy 1 apparition, 1 specter, 1 wraith and 1 shadow in th...",
        "requirements": [
        'Ritual trait',
        'Apparition element',
        'Shadow element',
        'Specter element',
        'Wraith element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 81: Fool Me Once
    "Fool Me Once": {
        "description": "Kill 390 banished monsters.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 82: Forces Within my Comprehension
    "Forces Within my Comprehension": {
        "description": "Have the Ritual trait set to level 6 or higher and win the b...",
        "requirements": [
        'Ritual trait'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 83: Forged in Battle
    "Forged in Battle": {
        "description": "Reach 200 battles won.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 84: Fortress
    "Fortress": {
        "description": "Build 30 towers.",
        "requirements": [
        'Tower element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Major",
    },
    # ID 85: Fortunate
    "Fortunate": {
        "description": "Find 2 talisman fragments.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 86: Frag Rain
    "Frag Rain": {
        "description": "Find 5 talisman fragments.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 87: Freezing Wounds
    "Freezing Wounds": {
        "description": "Freeze a monster 3 times.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 88: Friday Night
    "Friday Night": {
        "description": "Have 4 beam enhanced gems at the same time.",
        "requirements": [
        'Beam skill'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 89: Frittata
    "Frittata": {
        "description": "Reach 500 monster eggs cracked through all the battles.",
        "requirements": [
        'Swarm Queen element'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 90: From Above
    "From Above": {
        "description": "Kill 40 monsters with gem bombs and wasps.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 91: Frostborn
    "Frostborn": {
        "description": "Reach 5.000 strike spells cast through all the battles.",
        "requirements": [
        'strikeSpells: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 92: Frosting
    "Frosting": {
        "description": "Freeze a specter while it's snowing.",
        "requirements": [
        'Freeze skill',
        'Ritual trait',
        'Specter element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 93: Frozen Crowd
    "Frozen Crowd": {
        "description": "Reach 10.000 strike spell hits through all the battles.",
        "requirements": [
        'strikeSpells: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 94: Frozen Grave
    "Frozen Grave": {
        "description": "Kill 220 monsters while it's snowing.",
        "requirements": [],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 95: Frozen Over
    "Frozen Over": {
        "description": "Gain 4.500 xp with Freeze spell crowd hits.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 96: Ful Ir
    "Ful Ir": {
        "description": "Blast like a fireball",
        "requirements": [
        'Kill 15 monsters simultaneously with 1 gem bomb'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 97: Fully Lit
    "Fully Lit": {
        "description": "Have a field beaten in all three battle modes.",
        "requirements": [
        'Endurance and trial'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 98: Fully Shining
    "Fully Shining": {
        "description": "Have 60 gems on the battlefield.",
        "requirements": [
        'gemCount: 60'
    ],
        "modes": ['journey'],
        "grindiness": "Major",
    },
    # ID 99: Fusion Core
    "Fusion Core": {
        "description": "Have 16 beam enhanced gems at the same time.",
        "requirements": [
        'Beam skill'
    ],
        "modes": ['journey'],
        "grindiness": "Extreme",
    },
    # ID 100: Gearing Up
    "Gearing Up": {
        "description": "Have 5 fragments socketed in your talisman.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "grindiness": "Minor",
    },
    # ID 101: Gem Lust
    "Gem Lust": {
        "description": "Kill 2 specters.",
        "requirements": [
        'Ritual trait',
        'Specter element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 102: Gemhancement
    "Gemhancement": {
        "description": "Reach 1.000 enhancement spells cast through all the battles.",
        "requirements": [
        'enhancementSpells: 1'
    ],
        "modes": ['journey'],
        "grindiness": "Minor",
    },
    # ID 103: Get Them
    "Get Them": {
        "description": "Have a watchtower kill 39 monsters.",
        "requirements": [
        'Watchtower element'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 104: Get This Done Quick
    "Get This Done Quick": {
        "description": "Win a Trial battle with at least 3 waves started early.",
        "requirements": [
        'minWave: 3',
        'Trial'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
    # ID 105: Getting My Feet Wet
    "Getting My Feet Wet": {
        "description": "Have 20 fields lit in Endurance mode.",
        "requirements": [
        'Endurance'
    ],
        "modes": ['journey'],
        "grindiness": "Trivial",
    },
}

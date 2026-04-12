"""
GemCraft Frostborn Wrath — Achievement Pack 1

Contains approximately 106 achievements.
Each achievement has a "grindiness" property ("Trivial", "Minor", "Major", "Extreme") for easy adjustment.
"""

achievement_requirements = {
    # ID 0: A Bright Start
    "A Bright Start": {
        "ap_id": 1000,
        "description": "Have 30 fields lit in Journey mode.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 1: A Shrubbery!
    "A Shrubbery!": {
        "ap_id": 1001,
        "description": "Place a shrub wall.",
        "requirements": [
        'Wall element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 2: Ablatio Retinae
    "Ablatio Retinae": {
        "ap_id": 1002,
        "description": "Whiteout 111 whited out monsters.",
        "requirements": [
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 3: Absolute Zero
    "Absolute Zero": {
        "ap_id": 1003,
        "description": "Kill 273 frozen monsters.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 4: Acid Rain
    "Acid Rain": {
        "ap_id": 1004,
        "description": "Kill 85 poisoned monsters while it's raining.",
        "requirements": [
        'Poison skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 5: Added Protection
    "Added Protection": {
        "ap_id": 1005,
        "description": "Strengthen your orb with a gem in an amplifier.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 6: Addicted
    "Addicted": {
        "ap_id": 1006,
        "description": "Activate shrines a total of 12 times.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Minor",
    },
    # ID 7: Adept
    "Adept": {
        "ap_id": 1007,
        "description": "Have 30 fields lit in Trial mode.",
        "requirements": [
        'Trial'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Minor",
    },
    # ID 8: Adept Enhancer
    "Adept Enhancer": {
        "ap_id": 1008,
        "description": "Reach 500 enhancement spells cast through all the battles.",
        "requirements": [
        'enhancementSpells: 2'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 9: Adept Grade
    "Adept Grade": {
        "ap_id": 1009,
        "description": "Create a grade 8 gem.",
        "requirements": [
        'minGemGrade: 8'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 10: Adventurer
    "Adventurer": {
        "ap_id": 1010,
        "description": "Gain 600 xp from drops.",
        "requirements": [
        'Apparition element',
        'Corrupted Mana Shard element',
        'Drop Holder element',
        'Mana Shard element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 11: Ages Old Memories
    "Ages Old Memories": {
        "ap_id": 1011,
        "description": "Unlock a wizard tower.",
        "requirements": [
        'Wizard Tower element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 12: Agitated
    "Agitated": {
        "ap_id": 1012,
        "description": "Call 70 waves early.",
        "requirements": [
        'minWave: 70'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Major",
    },
    # ID 13: All Your Mana Belongs to Us
    "All Your Mana Belongs to Us": {
        "ap_id": 1013,
        "description": "Beat 90 waves using only mana leeching gems.",
        "requirements": [
        'Mana Leech skill',
        'minWave: 90'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 14: Almost
    "Almost": {
        "ap_id": 1014,
        "description": "Kill a monster with shots blinking to the monster attacking ...",
        "requirements": [
        'Watchtower element',
        'Wizard hunter'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 15: Almost Like Hacked
    "Almost Like Hacked": {
        "ap_id": 1015,
        "description": "Have at least 20 different talisman properties.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 16: Almost Ruined
    "Almost Ruined": {
        "ap_id": 1016,
        "description": "Leave a monster nest at 1 hit point at the end of the battle...",
        "requirements": [
        'Monster Nest element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 17: Am I a Joke to You?
    "Am I a Joke to You?": {
        "ap_id": 1017,
        "description": "Start an enraged wave early while there is a wizard hunter o...",
        "requirements": [
        'Wizard hunter'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 18: Ambitious Builder
    "Ambitious Builder": {
        "ap_id": 1018,
        "description": "Reach 500 structures built through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 19: Amplification
    "Amplification": {
        "ap_id": 1019,
        "description": "Spend 18.000 mana on amplifiers.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 20: Amplifinity
    "Amplifinity": {
        "ap_id": 1020,
        "description": "Build 45 amplifiers.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 21: Amulet
    "Amulet": {
        "ap_id": 1021,
        "description": "Fill all the sockets in your talisman.",
        "requirements": [
        'Shadow Core element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 22: And Don't Come Back
    "And Don't Come Back": {
        "ap_id": 1022,
        "description": "Kill 460 banished monsters with shrines.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 23: Angry Wasps
    "Angry Wasps": {
        "ap_id": 1023,
        "description": "Reach 1.000 gem wasp kills through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 24: Antitheft
    "Antitheft": {
        "ap_id": 1024,
        "description": "Kill 90 monsters with orblet explosions.",
        "requirements": [
        'Orb of Presence skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 25: Armored Orb
    "Armored Orb": {
        "ap_id": 1025,
        "description": "Strengthen your orb by dropping a gem on it.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 26: Army Glue
    "Army Glue": {
        "ap_id": 1026,
        "description": "Have a pure slowing gem with 4.000 hits.",
        "requirements": [
        'Slowing skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 27: At my Fingertips
    "At my Fingertips": {
        "ap_id": 1027,
        "description": "Cast 75 strike spells.",
        "requirements": [
        'strikeSpells: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Major",
    },
    # ID 28: Avenged
    "Avenged": {
        "ap_id": 1028,
        "description": "Kill 15 monsters carrying orblets.",
        "requirements": [
        'Orb of Presence skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 29: Awakening
    "Awakening": {
        "ap_id": 1029,
        "description": "Activate a shrine.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 30: Bang
    "Bang": {
        "ap_id": 1030,
        "description": "Throw 30 gem bombs.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 31: Barbed Sphere
    "Barbed Sphere": {
        "ap_id": 1031,
        "description": "Deliver 1.200 banishments with your orb.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Major",
    },
    # ID 32: Barrage Battery
    "Barrage Battery": {
        "ap_id": 1032,
        "description": "Have a Maximum Charge of 300% for the Barrage Spell.",
        "requirements": [
        'Barrage skill'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 33: Basic Gem Tactics
    "Basic Gem Tactics": {
        "ap_id": 1033,
        "description": "Beat 120 waves and don't use any gem enhancement spells.",
        "requirements": [
        'minWave: 120'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Trivial",
    },
    # ID 34: Bastion
    "Bastion": {
        "ap_id": 1034,
        "description": "Build 90 towers.",
        "requirements": [
        'Tower element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 35: Bath Bomb
    "Bath Bomb": {
        "ap_id": 1035,
        "description": "Kill 30 monsters with orblet explosions.",
        "requirements": [
        'Orb of Presence skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 36: Battle Heat
    "Battle Heat": {
        "ap_id": 1036,
        "description": "Gain 200 xp with kill chains.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 37: Bazaar
    "Bazaar": {
        "ap_id": 1037,
        "description": "Have 30 gems on the battlefield.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Minor",
    },
    # ID 38: Be Gone For Good
    "Be Gone For Good": {
        "ap_id": 1038,
        "description": "Kill 790 banished monsters.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 39: Beacon Hunt
    "Beacon Hunt": {
        "ap_id": 1039,
        "description": "Destroy 55 beacons.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Extreme",
    },
    # ID 40: Beacons Be Gone
    "Beacons Be Gone": {
        "ap_id": 1040,
        "description": "Reach 500 beacons destroyed through all the battles.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 41: Beastmaster
    "Beastmaster": {
        "ap_id": 1041,
        "description": "Kill a monster having at least 100.000 hit points and 1000 a...",
        "requirements": [
        'A monster with atleast 100.000hp and 1000 amror'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 42: Behold Aurora
    "Behold Aurora": {
        "ap_id": 1042,
        "description": "Go Igniculus and Light Ray (All)+++!",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 43: Biohazard
    "Biohazard": {
        "ap_id": 1043,
        "description": "Create a grade 12 pure poison gem.",
        "requirements": [
        'Poison skill',
        'minGemGrade: 12'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 44: Black Blood
    "Black Blood": {
        "ap_id": 1044,
        "description": "Deal 5.000 poison damage to a shadow.",
        "requirements": [
        'Poison skill',
        'Ritual trait',
        'Shadow element'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 45: Black Wand
    "Black Wand": {
        "ap_id": 1045,
        "description": "Reach wizard level 1.000.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Extreme",
    },
    # ID 46: Blackout
    "Blackout": {
        "ap_id": 1046,
        "description": "Destroy a beacon.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 47: Blastwave
    "Blastwave": {
        "ap_id": 1047,
        "description": "Reach 1.000 shrine kills through all the battles.",
        "requirements": [
        'Shrine element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 48: Bleed Out
    "Bleed Out": {
        "ap_id": 1048,
        "description": "Kill 480 bleeding monsters.",
        "requirements": [
        'Bleeding skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 49: Bleeding For Everyone
    "Bleeding For Everyone": {
        "ap_id": 1049,
        "description": "Enhance a pure bleeding gem having random priority with beam...",
        "requirements": [
        'Beam skill',
        'Bleeding skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 50: Blind Hit
    "Blind Hit": {
        "ap_id": 1050,
        "description": "Kill 30 whited out monsters with beam.",
        "requirements": [
        'Beam skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 51: Blood Censorship
    "Blood Censorship": {
        "ap_id": 1051,
        "description": "Kill 2.100 green blooded monsters.",
        "requirements": [
        'Requires "hidden codes"'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 52: Blood Clot
    "Blood Clot": {
        "ap_id": 1052,
        "description": "Beat 90 waves using only bleeding gems.",
        "requirements": [
        'Bleeding skill',
        'minWave: 90'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 53: Blood Magic
    "Blood Magic": {
        "ap_id": 1053,
        "description": "Win a battle using only bleeding gems.",
        "requirements": [
        'Bleeding skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 54: Blood on my Hands
    "Blood on my Hands": {
        "ap_id": 1054,
        "description": "Reach 20.000 monsters killed through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 55: Bloodmaster
    "Bloodmaster": {
        "ap_id": 1055,
        "description": "Gain 1.200 xp with kill chains.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 56: Bloodrush
    "Bloodrush": {
        "ap_id": 1056,
        "description": "Call an enraged wave early.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 57: Bloodstream
    "Bloodstream": {
        "ap_id": 1057,
        "description": "Kill 4.000 monsters.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 58: Blue Wand
    "Blue Wand": {
        "ap_id": 1058,
        "description": "Reach wizard level 100.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 59: Boatload of Cores
    "Boatload of Cores": {
        "ap_id": 1059,
        "description": "Find 540 shadow cores.",
        "requirements": [
        'Shadow Core element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 60: Boiling Red
    "Boiling Red": {
        "ap_id": 1060,
        "description": "Reach a kill chain of 2400.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Extreme",
    },
    # ID 61: Bone Shredder
    "Bone Shredder": {
        "ap_id": 1061,
        "description": "Kill 600 monsters before wave 12 starts.",
        "requirements": [
        'Atleast 600 monsters before wave 10'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 62: Boom
    "Boom": {
        "ap_id": 1062,
        "description": "Throw a gem bomb.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 63: Bouncy Zap
    "Bouncy Zap": {
        "ap_id": 1063,
        "description": "Reach 2.000 pylon kills through all the battles.",
        "requirements": [
        'Pylons skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 64: Breath of Cold
    "Breath of Cold": {
        "ap_id": 1064,
        "description": "Have 90 monsters frozen at the same time.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 65: Brickery
    "Brickery": {
        "ap_id": 1065,
        "description": "Reach 1.000 structures built through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 66: Bright Weakening
    "Bright Weakening": {
        "ap_id": 1066,
        "description": "Gain 1.200 xp with Whiteout spell crowd hits.",
        "requirements": [
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 67: Broken Seal
    "Broken Seal": {
        "ap_id": 1067,
        "description": "Free a sealed gem.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 68: Broken Siege
    "Broken Siege": {
        "ap_id": 1068,
        "description": "Destroy 8 beacons before wave 8.",
        "requirements": [
        'Beacon element'
    ],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Trivial",
    },
    # ID 69: Brought Some Mana
    "Brought Some Mana": {
        "ap_id": 1069,
        "description": "Have 5.000 initial mana.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 70: Brown Wand
    "Brown Wand": {
        "ap_id": 1070,
        "description": "Reach wizard level 300.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 2,
        "grindiness": "Extreme",
    },
    # ID 71: Build Along
    "Build Along": {
        "ap_id": 1071,
        "description": "Reach 200 structures built through all the battles.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 72: Busted
    "Busted": {
        "ap_id": 1072,
        "description": "Destroy a full health possession obelisk with one gem bomb b...",
        "requirements": [
        'Obelisk element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 73: Buzz Feed
    "Buzz Feed": {
        "ap_id": 1073,
        "description": "Have 99 gem wasps on the battlefield.",
        "requirements": [
        'gemCount: 99'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 74: By Three They Go
    "By Three They Go": {
        "ap_id": 1074,
        "description": "Have 3 of your gems destroyed or stolen.",
        "requirements": [
        'Ritual trait',
        'Specter element',
        'Watchtower element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 75: Bye Bye Hideous
    "Bye Bye Hideous": {
        "ap_id": 1075,
        "description": "Kill a spire.",
        "requirements": [
        'Ritual trait',
        'Spire element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 76: Call in the Wave!
    "Call in the Wave!": {
        "ap_id": 1076,
        "description": "Call a wave early.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 77: Can't Crawl Away
    "Can't Crawl Away": {
        "ap_id": 1077,
        "description": "Kill 30 whited out monsters with barrage.",
        "requirements": [
        'Barrage skill',
        'Whiteout skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 78: Can't Stop
    "Can't Stop": {
        "ap_id": 1078,
        "description": "Reach a kill chain of 900.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 79: Can't Take Any Risks
    "Can't Take Any Risks": {
        "ap_id": 1079,
        "description": "Kill a bleeding giant with poison.",
        "requirements": [
        'Bleeding skill',
        'Poison skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 80: Care to Die Already?
    "Care to Die Already?": {
        "ap_id": 1080,
        "description": "Cast 8 ice shards on the same monster.",
        "requirements": [
        'Ice Shards skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 81: Carnage
    "Carnage": {
        "ap_id": 1081,
        "description": "Reach a kill chain of 600.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 82: Cartographer
    "Cartographer": {
        "ap_id": 1082,
        "description": "Have 90 fields lit in Journey mode.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 83: Catalyst
    "Catalyst": {
        "ap_id": 1083,
        "description": "Give a Gem 200 Poison Damage by Amplification.",
        "requirements": [
        'Amplifiers skill',
        'Poison skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 84: Catch and Release
    "Catch and Release": {
        "ap_id": 1084,
        "description": "Destroy a jar of wasps, but don't have any wasp kills.",
        "requirements": [
        'Field X2'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 85: Century Egg
    "Century Egg": {
        "ap_id": 1085,
        "description": "Reach 100 monster eggs cracked through all the battles.",
        "requirements": [
        'Swarm Queen element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 86: Chainsaw
    "Chainsaw": {
        "ap_id": 1086,
        "description": "Gain 3.200 xp with kill chains.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 87: Charge Fire Repeat
    "Charge Fire Repeat": {
        "ap_id": 1087,
        "description": "Reach 5.000 enhancement spells cast through all the battles.",
        "requirements": [
        'enhancementSpells: 1'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 88: Charged for the Kill
    "Charged for the Kill": {
        "ap_id": 1088,
        "description": "Reach 200 pylon kills through all the battles.",
        "requirements": [
        'Pylons skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 89: Charm
    "Charm": {
        "ap_id": 1089,
        "description": "Fill all the sockets in your talisman with fragments upgrade...",
        "requirements": [
        'Shadow Core element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 90: Chilling Edges
    "Chilling Edges": {
        "ap_id": 1090,
        "description": "Gain 140 xp with Ice Shards spell crowd hits.",
        "requirements": [
        'Ice Shards skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 91: Chlorophyll
    "Chlorophyll": {
        "ap_id": 1091,
        "description": "Kill 4.500 green blooded monsters.",
        "requirements": [
        'Requires "hidden codes"'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 92: Clean Orb
    "Clean Orb": {
        "ap_id": 1092,
        "description": "Win a battle without any monster getting to your orb.",
        "requirements": [],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 93: Cleansing the Wilderness
    "Cleansing the Wilderness": {
        "ap_id": 1093,
        "description": "Reach 50.000 monsters with special properties killed through...",
        "requirements": [
        'Possessed Monster element',
        'Twisted Monster element',
        'Marked Monster element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Extreme",
    },
    # ID 94: Clear Sky
    "Clear Sky": {
        "ap_id": 1094,
        "description": "Beat 120 waves and don't use any strike spells.",
        "requirements": [
        'minWave: 120'
    ],
        "modes": ['journey'],
        "skillPoints": 3,
        "grindiness": "Trivial",
    },
    # ID 95: Close Quarter
    "Close Quarter": {
        "ap_id": 1095,
        "description": "Reach -12% decreased banishment cost with your orb.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 96: Cold Wisdom
    "Cold Wisdom": {
        "ap_id": 1096,
        "description": "Gain 700 xp with Freeze spell crowd hits.",
        "requirements": [
        'Freeze skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 97: Come Again
    "Come Again": {
        "ap_id": 1097,
        "description": "Kill 190 banished monsters.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 98: Come Out
    "Come Out": {
        "ap_id": 1098,
        "description": "Lure 20 swarmlings out of a sleeping hive.",
        "requirements": [
        'Sleeping Hive element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 99: Come Out, Come Out
    "Come Out, Come Out": {
        "ap_id": 1099,
        "description": "Lure 100 swarmlings out of a sleeping hive.",
        "requirements": [
        'Sleeping Hive element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 100: Confusion Junction
    "Confusion Junction": {
        "ap_id": 1100,
        "description": "Build 30 walls.",
        "requirements": [
        'Wall element'
    ],
        "modes": ['journey', 'endurance', 'trial'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 101: Connected
    "Connected": {
        "ap_id": 1101,
        "description": "Build an amplifier.",
        "requirements": [
        'Amplifiers skill'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 102: Connecting the Dots
    "Connecting the Dots": {
        "ap_id": 1102,
        "description": "Have 50 fields lit in Journey mode.",
        "requirements": [],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
    # ID 103: Core Haul
    "Core Haul": {
        "ap_id": 1103,
        "description": "Find 180 shadow cores.",
        "requirements": [
        'Shadow Core element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Major",
    },
    # ID 104: Core Pack
    "Core Pack": {
        "ap_id": 1104,
        "description": "Find 20 shadow cores.",
        "requirements": [
        'Shadow Core element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Trivial",
    },
    # ID 105: Core Pile
    "Core Pile": {
        "ap_id": 1105,
        "description": "Find 60 shadow cores.",
        "requirements": [
        'Shadow Core element'
    ],
        "modes": ['journey'],
        "skillPoints": 1,
        "grindiness": "Minor",
    },
}

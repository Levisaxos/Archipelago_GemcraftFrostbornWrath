"""
GemCraft Frostborn Wrath - Progression Talisman Fragments

Static reference data for the 25 progression talisman fragments
(4 corner + 12 edge + 9 inner).  These are the fragments selected
by power._build_progression_corner_edge_names + _build_matching_talisman_grid
based on highest rarity per type.

Each entry holds the fragment's deterministic seed-derived stats, computed
by re-running TalismanFragment.calculateProperties() and getOriginalShapeId()
against the in-game seed.  Values are bit-identical to what the player gets.

Fields:
  ap_id            - Archipelago item ID (matches items.py)
  type             - EDGE / CORNER / INNER
  rarity           - 1-100, drives slot count, power range, upgrade cap
  seed             - PseudoRnd seed (fixed per fragment, baked into game)
  upgrade_level    - starting upgrade level (almost always 0; A5/A6 ship at 3)
  upgrade_level_max- max upgrades the player can apply with shadow cores
  shape_id         - 0-15 inner / 16-47 edge / 48-63 corner; controls icon
                     and link directions (links_up/down/left/right)
  rune_id          - 0-9; 0-4 = visible rune drawn on fragment
  properties       - list of (TalismanPropertyId, current_value) pairs.
                     Order matches the in-game property slot order.  At
                     upgrade_level=0 only the first property carries value;
                     subsequent properties activate as the fragment is
                     upgraded (each upgrade lights up one more slot).
  properties_at_max- same list, but values computed at upgrade_level_max.
"""

# Property ID -> human-readable name
TALISMAN_PROPERTY_NAMES = {
     0: "Skill: Construction",
     1: "Skill: Component",
     2: "Skill: Focus",
     3: "Skill: Enhancement",
     4: "Skill: Strike Spells",
     5: "Skill: Wrath",
     6: "Skill: ALL",
     7: "Damage to Swarmlings",
     8: "Damage to Reavers",
     9: "Damage to Giants",
    10: "XP Gained",
    11: "WizLevel to XP/Mana",
    12: "Initial Mana",
    13: "Damage to Flying",
    14: "Damage to Buildings",
    15: "Beam Damage",
    16: "Bolt Damage",
    17: "Barrage Damage",
    18: "Freeze Duration",
    19: "Whiteout Duration",
    20: "Iceshards Extra HP Taken",
    21: "Max Freeze Charge",
    22: "Max Whiteout Charge",
    23: "Max Iceshards Charge",
    24: "Max Bolt Charge",
    25: "Max Beam Charge",
    26: "Max Barrage Charge",
    27: "Max Shrine Charge",
    28: "Mana for Early Waves",
    29: "Wasp Chance from Bombs",
    30: "Slower Killchain Cooldown",
    31: "Heavier Orblets",
    32: "Faster Orblet Rollback",
    33: "Mana Shard Harvesting Speed",
    34: "Wasps Faster Attack",
    35: "Freeze Armor%",
    36: "Freeze CritDmg%",
    37: "Freeze Corpse Explosion HP%",
    38: "Whiteout PoisonBoost%",
    39: "Whiteout ManaLeechBoost%",
    40: "Whiteout XPBoost%",
    41: "Iceshards HPLoss%",
    42: "Iceshards ArmorLoss%",
    43: "Iceshards Bleeding%",
    44: "Iceshards SlowingDur%",
}

# Shape ID -> link directions (linkUp, linkDown, linkLeft, linkRight)
# Values: -1 = inward link, 0 = no link, 1 = outward link
# Used to determine which fragments can be socketed adjacent to each other
# in the talisman grid.
TALISMAN_SHAPE_LINKS = {
    # shape_id : (up, down, left, right)
     0: (-1, -1, -1, -1),  # INNER
     1: (-1, -1,  1, -1),  # INNER
     2: (-1,  1, -1, -1),  # INNER
     3: (-1,  1,  1, -1),  # INNER
     4: (-1, -1, -1,  1),  # INNER
     5: (-1, -1,  1,  1),  # INNER
     6: (-1,  1, -1,  1),  # INNER
     7: (-1,  1,  1,  1),  # INNER
     8: ( 1, -1, -1, -1),  # INNER
     9: ( 1, -1,  1, -1),  # INNER
    10: ( 1,  1, -1, -1),  # INNER
    11: ( 1,  1,  1, -1),  # INNER
    12: ( 1, -1, -1,  1),  # INNER
    13: ( 1, -1,  1,  1),  # INNER
    14: ( 1,  1, -1,  1),  # INNER
    15: ( 1,  1,  1,  1),  # INNER
    16: ( 0, -1, -1, -1),  # EDGE
    17: ( 0, -1,  1, -1),  # EDGE
    18: ( 0,  1, -1, -1),  # EDGE
    19: ( 0,  1,  1, -1),  # EDGE
    20: ( 0, -1, -1,  1),  # EDGE
    21: ( 0, -1,  1,  1),  # EDGE
    22: ( 0,  1, -1,  1),  # EDGE
    23: ( 0,  1,  1,  1),  # EDGE
    24: (-1, -1, -1,  0),  # EDGE
    25: ( 1, -1, -1,  0),  # EDGE
    26: (-1, -1,  1,  0),  # EDGE
    27: ( 1, -1,  1,  0),  # EDGE
    28: (-1,  1, -1,  0),  # EDGE
    29: ( 1,  1, -1,  0),  # EDGE
    30: (-1,  1,  1,  0),  # EDGE
    31: ( 1,  1,  1,  0),  # EDGE
    32: (-1,  0, -1, -1),  # EDGE
    33: (-1,  0, -1,  1),  # EDGE
    34: ( 1,  0, -1, -1),  # EDGE
    35: ( 1,  0, -1,  1),  # EDGE
    36: (-1,  0,  1, -1),  # EDGE
    37: (-1,  0,  1,  1),  # EDGE
    38: ( 1,  0,  1, -1),  # EDGE
    39: ( 1,  0,  1,  1),  # EDGE
    40: (-1, -1,  0, -1),  # EDGE
    41: (-1,  1,  0, -1),  # EDGE
    42: (-1, -1,  0,  1),  # EDGE
    43: (-1,  1,  0,  1),  # EDGE
    44: ( 1, -1,  0, -1),  # EDGE
    45: ( 1,  1,  0, -1),  # EDGE
    46: ( 1, -1,  0,  1),  # EDGE
    47: ( 1,  1,  0,  1),  # EDGE
    48: ( 0, -1,  0, -1),  # CORNER
    49: ( 0, -1,  0,  1),  # CORNER
    50: ( 0,  1,  0, -1),  # CORNER
    51: ( 0,  1,  0,  1),  # CORNER
    52: ( 0, -1, -1,  0),  # CORNER
    53: ( 0, -1,  1,  0),  # CORNER
    54: ( 0,  1, -1,  0),  # CORNER
    55: ( 0,  1,  1,  0),  # CORNER
    56: (-1,  0, -1,  0),  # CORNER
    57: ( 1,  0, -1,  0),  # CORNER
    58: (-1,  0,  1,  0),  # CORNER
    59: ( 1,  0,  1,  0),  # CORNER
    60: (-1,  0,  0, -1),  # CORNER
    61: (-1,  0,  0,  1),  # CORNER
    62: ( 1,  0,  0, -1),  # CORNER
    63: ( 1,  0,  0,  1),  # CORNER
}

# AP item name -> static fragment data
progression_talismans = {
    "C5 Talisman Fragment": {
        "str_id": "C5",
        "ap_id": 947,
        "type": "CORNER",
        "rarity": 88,
        "seed": 5697989,
        "upgrade_level": 0,
        "upgrade_level_max": 12,
        "shape_id": 54,
        "rune_id": 7,  # no rune
        "properties": [
            (16,      8),  # Bolt Damage
            (42,      0),  # Iceshards ArmorLoss%
            (44,      0),  # Iceshards SlowingDur%
            ( 7,      0),  # Damage to Swarmlings
            (12,      0),  # Initial Mana
            ( 8,      0),  # Damage to Reavers
            (15,      0),  # Beam Damage
            (41,      0),  # Iceshards HPLoss%
            (13,      0),  # Damage to Flying
            ( 9,      0),  # Damage to Giants
            ( 6,      0),  # Skill: ALL
        ],
        "properties_at_max": [
            (16,     19),  # Bolt Damage
            (42,      7),  # Iceshards ArmorLoss%
            (44,      7),  # Iceshards SlowingDur%
            ( 7,     24),  # Damage to Swarmlings
            (12,    187),  # Initial Mana
            ( 8,     24),  # Damage to Reavers
            (15,     18),  # Beam Damage
            (41,      4),  # Iceshards HPLoss%
            (13,     14),  # Damage to Flying
            ( 9,     23),  # Damage to Giants
            ( 6,      1),  # Skill: ALL
        ],
    },
    "C2 Talisman Fragment": {
        "str_id": "C2",
        "ap_id": 946,
        "type": "CORNER",
        "rarity": 85,
        "seed": 4202319,
        "upgrade_level": 0,
        "upgrade_level_max": 12,
        "shape_id": 52,
        "rune_id": 5,  # no rune
        "properties": [
            (13,      7),  # Damage to Flying
            (10,      0),  # XP Gained
            (30,      0),  # Slower Killchain Cooldown
            ( 7,      0),  # Damage to Swarmlings
            (15,      0),  # Beam Damage
            (38,      0),  # Whiteout PoisonBoost%
            (25,      0),  # Max Beam Charge
            ( 8,      0),  # Damage to Reavers
            (44,      0),  # Iceshards SlowingDur%
            ( 9,      0),  # Damage to Giants
            ( 2,      0),  # Skill: Focus
        ],
        "properties_at_max": [
            (13,     14),  # Damage to Flying
            (10,     23),  # XP Gained
            (30,      7),  # Slower Killchain Cooldown
            ( 7,     24),  # Damage to Swarmlings
            (15,     18),  # Beam Damage
            (38,     11),  # Whiteout PoisonBoost%
            (25,     18),  # Max Beam Charge
            ( 8,     22),  # Damage to Reavers
            (44,      7),  # Iceshards SlowingDur%
            ( 9,     24),  # Damage to Giants
            ( 2,      1),  # Skill: Focus
        ],
    },
    "E5 Talisman Fragment": {
        "str_id": "E5",
        "ap_id": 943,
        "type": "CORNER",
        "rarity": 71,
        "seed": 7958565,
        "upgrade_level": 0,
        "upgrade_level_max": 11,
        "shape_id": 51,
        "rune_id": 2,  # rune visible
        "properties": [
            (10,      9),  # XP Gained
            ( 7,      0),  # Damage to Swarmlings
            (12,      0),  # Initial Mana
            ( 9,      0),  # Damage to Giants
            (22,      0),  # Max Whiteout Charge
            ( 8,      0),  # Damage to Reavers
            (20,      0),  # Iceshards Extra HP Taken
            (41,      0),  # Iceshards HPLoss%
            (30,      0),  # Slower Killchain Cooldown
            ( 4,      0),  # Skill: Strike Spells
        ],
        "properties_at_max": [
            (10,     21),  # XP Gained
            ( 7,     21),  # Damage to Swarmlings
            (12,    145),  # Initial Mana
            ( 9,     21),  # Damage to Giants
            (22,     15),  # Max Whiteout Charge
            ( 8,     20),  # Damage to Reavers
            (20,   8206),  # Iceshards Extra HP Taken
            (41,      3),  # Iceshards HPLoss%
            (30,      7),  # Slower Killchain Cooldown
            ( 4,      1),  # Skill: Strike Spells
        ],
    },
    "M4 Talisman Fragment": {
        "str_id": "M4",
        "ap_id": 927,
        "type": "CORNER",
        "rarity": 59,
        "seed": 7892093,
        "upgrade_level": 0,
        "upgrade_level_max": 9,
        "shape_id": 60,
        "rune_id": 3,  # rune visible
        "properties": [
            (11,     13),  # WizLevel to XP/Mana
            ( 7,      0),  # Damage to Swarmlings
            (13,      0),  # Damage to Flying
            (17,      0),  # Barrage Damage
            (39,      0),  # Whiteout ManaLeechBoost%
            (26,      0),  # Max Barrage Charge
            ( 9,      0),  # Damage to Giants
            (25,      0),  # Max Beam Charge
        ],
        "properties_at_max": [
            (11,     33),  # WizLevel to XP/Mana
            ( 7,     19),  # Damage to Swarmlings
            (13,     12),  # Damage to Flying
            (17,     15),  # Barrage Damage
            (39,      5),  # Whiteout ManaLeechBoost%
            (26,     13),  # Max Barrage Charge
            ( 9,     19),  # Damage to Giants
            (25,     11),  # Max Beam Charge
        ],
    },
    "D2 Talisman Fragment": {
        "str_id": "D2",
        "ap_id": 944,
        "type": "EDGE",
        "rarity": 82,
        "seed": 3425853,
        "upgrade_level": 0,
        "upgrade_level_max": 11,
        "shape_id": 29,
        "rune_id": 1,  # rune visible
        "properties": [
            (15,      8),  # Beam Damage
            (12,      0),  # Initial Mana
            (25,      0),  # Max Beam Charge
            (27,      0),  # Max Shrine Charge
            (24,      0),  # Max Bolt Charge
            (14,      0),  # Damage to Buildings
            (23,      0),  # Max Iceshards Charge
            ( 7,      0),  # Damage to Swarmlings
            (33,      0),  # Mana Shard Harvesting Speed
            ( 6,      0),  # Skill: ALL
        ],
        "properties_at_max": [
            (15,     19),  # Beam Damage
            (12,    170),  # Initial Mana
            (25,     18),  # Max Beam Charge
            (27,     17),  # Max Shrine Charge
            (24,     17),  # Max Bolt Charge
            (14,     14),  # Damage to Buildings
            (23,     18),  # Max Iceshards Charge
            ( 7,     22),  # Damage to Swarmlings
            (33,     13),  # Mana Shard Harvesting Speed
            ( 6,      1),  # Skill: ALL
        ],
    },
    "K2 Talisman Fragment": {
        "str_id": "K2",
        "ap_id": 931,
        "type": "EDGE",
        "rarity": 80,
        "seed": 9995680,
        "upgrade_level": 0,
        "upgrade_level_max": 11,
        "shape_id": 24,
        "rune_id": 8,  # no rune
        "properties": [
            ( 7,     10),  # Damage to Swarmlings
            (31,      0),  # Heavier Orblets
            (11,      0),  # WizLevel to XP/Mana
            (32,      0),  # Faster Orblet Rollback
            (15,      0),  # Beam Damage
            (21,      0),  # Max Freeze Charge
            (16,      0),  # Bolt Damage
            ( 8,      0),  # Damage to Reavers
            (26,      0),  # Max Barrage Charge
            ( 6,      0),  # Skill: ALL
        ],
        "properties_at_max": [
            ( 7,     23),  # Damage to Swarmlings
            (31,      8),  # Heavier Orblets
            (11,     37),  # WizLevel to XP/Mana
            (32,      8),  # Faster Orblet Rollback
            (15,     18),  # Beam Damage
            (21,     18),  # Max Freeze Charge
            (16,     18),  # Bolt Damage
            ( 8,     21),  # Damage to Reavers
            (26,     18),  # Max Barrage Charge
            ( 6,      1),  # Skill: ALL
        ],
    },
    "O1 Talisman Fragment": {
        "str_id": "O1",
        "ap_id": 921,
        "type": "EDGE",
        "rarity": 80,
        "seed": 9995950,
        "upgrade_level": 0,
        "upgrade_level_max": 11,
        "shape_id": 46,
        "rune_id": 1,  # rune visible
        "properties": [
            (14,      7),  # Damage to Buildings
            (23,      0),  # Max Iceshards Charge
            (16,      0),  # Bolt Damage
            (37,      0),  # Freeze Corpse Explosion HP%
            (11,      0),  # WizLevel to XP/Mana
            (26,      0),  # Max Barrage Charge
            ( 7,      0),  # Damage to Swarmlings
            (21,      0),  # Max Freeze Charge
            ( 8,      0),  # Damage to Reavers
            ( 4,      0),  # Skill: Strike Spells
        ],
        "properties_at_max": [
            (14,     14),  # Damage to Buildings
            (23,     17),  # Max Iceshards Charge
            (16,     18),  # Bolt Damage
            (37,      4),  # Freeze Corpse Explosion HP%
            (11,     39),  # WizLevel to XP/Mana
            (26,     18),  # Max Barrage Charge
            ( 7,     23),  # Damage to Swarmlings
            (21,     18),  # Max Freeze Charge
            ( 8,     23),  # Damage to Reavers
            ( 4,      1),  # Skill: Strike Spells
        ],
    },
    "X3 Talisman Fragment": {
        "str_id": "X3",
        "ap_id": 903,
        "type": "EDGE",
        "rarity": 80,
        "seed": 9998290,
        "upgrade_level": 0,
        "upgrade_level_max": 11,
        "shape_id": 38,
        "rune_id": 1,  # rune visible
        "properties": [
            ( 8,      9),  # Damage to Reavers
            ( 9,      0),  # Damage to Giants
            (16,      0),  # Bolt Damage
            (17,      0),  # Barrage Damage
            (27,      0),  # Max Shrine Charge
            (21,      0),  # Max Freeze Charge
            (31,      0),  # Heavier Orblets
            (26,      0),  # Max Barrage Charge
            (12,      0),  # Initial Mana
            ( 0,      0),  # Skill: Construction
        ],
        "properties_at_max": [
            ( 8,     22),  # Damage to Reavers
            ( 9,     23),  # Damage to Giants
            (16,     18),  # Bolt Damage
            (17,     18),  # Barrage Damage
            (27,     17),  # Max Shrine Charge
            (21,     18),  # Max Freeze Charge
            (31,      8),  # Heavier Orblets
            (26,     18),  # Max Barrage Charge
            (12,    165),  # Initial Mana
            ( 0,      1),  # Skill: Construction
        ],
    },
    "I1 Talisman Fragment": {
        "str_id": "I1",
        "ap_id": 936,
        "type": "EDGE",
        "rarity": 79,
        "seed": 6047887,
        "upgrade_level": 0,
        "upgrade_level_max": 10,
        "shape_id": 38,
        "rune_id": 1,  # rune visible
        "properties": [
            (28,     10),  # Mana for Early Waves
            ( 8,      0),  # Damage to Reavers
            (21,      0),  # Max Freeze Charge
            ( 9,      0),  # Damage to Giants
            (16,      0),  # Bolt Damage
            (26,      0),  # Max Barrage Charge
            (31,      0),  # Heavier Orblets
            (15,      0),  # Beam Damage
            ( 4,      0),  # Skill: Strike Spells
        ],
        "properties_at_max": [
            (28,     31),  # Mana for Early Waves
            ( 8,     23),  # Damage to Reavers
            (21,     17),  # Max Freeze Charge
            ( 9,     21),  # Damage to Giants
            (16,     19),  # Bolt Damage
            (26,     16),  # Max Barrage Charge
            (31,      8),  # Heavier Orblets
            (15,     18),  # Beam Damage
            ( 4,      1),  # Skill: Strike Spells
        ],
    },
    "E1 Talisman Fragment": {
        "str_id": "E1",
        "ap_id": 942,
        "type": "EDGE",
        "rarity": 73,
        "seed": 1034270,
        "upgrade_level": 0,
        "upgrade_level_max": 10,
        "shape_id": 26,
        "rune_id": 1,  # rune visible
        "properties": [
            (31,      2),  # Heavier Orblets
            (32,      0),  # Faster Orblet Rollback
            (26,      0),  # Max Barrage Charge
            (38,      0),  # Whiteout PoisonBoost%
            ( 7,      0),  # Damage to Swarmlings
            (11,      0),  # WizLevel to XP/Mana
            (13,      0),  # Damage to Flying
            (25,      0),  # Max Beam Charge
            ( 5,      0),  # Skill: Wrath
        ],
        "properties_at_max": [
            (31,      8),  # Heavier Orblets
            (32,      7),  # Faster Orblet Rollback
            (26,     15),  # Max Barrage Charge
            (38,     10),  # Whiteout PoisonBoost%
            ( 7,     21),  # Damage to Swarmlings
            (11,     35),  # WizLevel to XP/Mana
            (13,     13),  # Damage to Flying
            (25,     16),  # Max Beam Charge
            ( 5,      1),  # Skill: Wrath
        ],
    },
    "L5 Talisman Fragment": {
        "str_id": "L5",
        "ap_id": 930,
        "type": "EDGE",
        "rarity": 71,
        "seed": 5981897,
        "upgrade_level": 0,
        "upgrade_level_max": 10,
        "shape_id": 41,
        "rune_id": 5,  # no rune
        "properties": [
            (31,      2),  # Heavier Orblets
            (26,      0),  # Max Barrage Charge
            (27,      0),  # Max Shrine Charge
            (25,      0),  # Max Beam Charge
            (23,      0),  # Max Iceshards Charge
            (17,      0),  # Barrage Damage
            (12,      0),  # Initial Mana
            (14,      0),  # Damage to Buildings
            ( 5,      0),  # Skill: Wrath
        ],
        "properties_at_max": [
            (31,      7),  # Heavier Orblets
            (26,     15),  # Max Barrage Charge
            (27,     16),  # Max Shrine Charge
            (25,     16),  # Max Beam Charge
            (23,     16),  # Max Iceshards Charge
            (17,     17),  # Barrage Damage
            (12,    149),  # Initial Mana
            (14,     13),  # Damage to Buildings
            ( 5,      1),  # Skill: Wrath
        ],
    },
    "J2 Talisman Fragment": {
        "str_id": "J2",
        "ap_id": 934,
        "type": "EDGE",
        "rarity": 69,
        "seed": 4059357,
        "upgrade_level": 0,
        "upgrade_level_max": 9,
        "shape_id": 43,
        "rune_id": 3,  # rune visible
        "properties": [
            (15,      8),  # Beam Damage
            (32,      0),  # Faster Orblet Rollback
            (10,      0),  # XP Gained
            (25,      0),  # Max Beam Charge
            ( 8,      0),  # Damage to Reavers
            (11,      0),  # WizLevel to XP/Mana
            (12,      0),  # Initial Mana
            ( 0,      0),  # Skill: Construction
        ],
        "properties_at_max": [
            (15,     16),  # Beam Damage
            (32,      8),  # Faster Orblet Rollback
            (10,     20),  # XP Gained
            (25,     15),  # Max Beam Charge
            ( 8,     19),  # Damage to Reavers
            (11,     36),  # WizLevel to XP/Mana
            (12,    163),  # Initial Mana
            ( 0,      1),  # Skill: Construction
        ],
    },
    "M2 Talisman Fragment": {
        "str_id": "M2",
        "ap_id": 926,
        "type": "EDGE",
        "rarity": 66,
        "seed": 2756634,
        "upgrade_level": 0,
        "upgrade_level_max": 9,
        "shape_id": 37,
        "rune_id": 4,  # rune visible
        "properties": [
            (22,      4),  # Max Whiteout Charge
            (25,      0),  # Max Beam Charge
            (31,      0),  # Heavier Orblets
            (27,      0),  # Max Shrine Charge
            (21,      0),  # Max Freeze Charge
            (15,      0),  # Beam Damage
            (24,      0),  # Max Bolt Charge
            ( 0,      0),  # Skill: Construction
        ],
        "properties_at_max": [
            (22,     14),  # Max Whiteout Charge
            (25,     15),  # Max Beam Charge
            (31,      7),  # Heavier Orblets
            (27,     16),  # Max Shrine Charge
            (21,     15),  # Max Freeze Charge
            (15,     17),  # Beam Damage
            (24,     14),  # Max Bolt Charge
            ( 0,      1),  # Skill: Construction
        ],
    },
    "F1 Talisman Fragment": {
        "str_id": "F1",
        "ap_id": 940,
        "type": "EDGE",
        "rarity": 58,
        "seed": 3210578,
        "upgrade_level": 0,
        "upgrade_level_max": 8,
        "shape_id": 46,
        "rune_id": 7,  # no rune
        "properties": [
            (21,      3),  # Max Freeze Charge
            (25,      0),  # Max Beam Charge
            (27,      0),  # Max Shrine Charge
            (15,      0),  # Beam Damage
            ( 8,      0),  # Damage to Reavers
            (38,      0),  # Whiteout PoisonBoost%
            (35,      0),  # Freeze Armor%
        ],
        "properties_at_max": [
            (21,     14),  # Max Freeze Charge
            (25,     14),  # Max Beam Charge
            (27,     15),  # Max Shrine Charge
            (15,     14),  # Beam Damage
            ( 8,     18),  # Damage to Reavers
            (38,      9),  # Whiteout PoisonBoost%
            (35,      2),  # Freeze Armor%
        ],
    },
    "N4 Talisman Fragment": {
        "str_id": "N4",
        "ap_id": 925,
        "type": "EDGE",
        "rarity": 51,
        "seed": 2470718,
        "upgrade_level": 0,
        "upgrade_level_max": 8,
        "shape_id": 40,
        "rune_id": 7,  # no rune
        "properties": [
            (26,      4),  # Max Barrage Charge
            (13,      0),  # Damage to Flying
            (24,      0),  # Max Bolt Charge
            (14,      0),  # Damage to Buildings
            ( 8,      0),  # Damage to Reavers
            ( 9,      0),  # Damage to Giants
            (32,      0),  # Faster Orblet Rollback
        ],
        "properties_at_max": [
            (26,     13),  # Max Barrage Charge
            (13,     12),  # Damage to Flying
            (24,     12),  # Max Bolt Charge
            (14,     12),  # Damage to Buildings
            ( 8,     19),  # Damage to Reavers
            ( 9,     18),  # Damage to Giants
            (32,      4),  # Faster Orblet Rollback
        ],
    },
    "P2 Talisman Fragment": {
        "str_id": "P2",
        "ap_id": 919,
        "type": "EDGE",
        "rarity": 45,
        "seed": 1874734,
        "upgrade_level": 0,
        "upgrade_level_max": 6,
        "shape_id": 20,
        "rune_id": 4,  # rune visible
        "properties": [
            (21,      4),  # Max Freeze Charge
            (24,      0),  # Max Bolt Charge
            (22,      0),  # Max Whiteout Charge
            (15,      0),  # Beam Damage
            (26,      0),  # Max Barrage Charge
        ],
        "properties_at_max": [
            (21,     13),  # Max Freeze Charge
            (24,     10),  # Max Bolt Charge
            (22,     10),  # Max Whiteout Charge
            (15,     15),  # Beam Damage
            (26,     10),  # Max Barrage Charge
        ],
    },
    "A6 Talisman Fragment": {
        "str_id": "A6",
        "ap_id": 952,
        "type": "INNER",
        "rarity": 100,
        "seed": 1438882,
        "upgrade_level": 3,
        "upgrade_level_max": 12,
        "shape_id": 3,
        "rune_id": 3,  # rune visible
        "properties": [
            (13,     15),  # Damage to Flying
            (12,    153),  # Initial Mana
            (17,     13),  # Barrage Damage
            ( 9,     11),  # Damage to Giants
            (37,      0),  # Freeze Corpse Explosion HP%
            (40,      0),  # Whiteout XPBoost%
            (34,      0),  # Wasps Faster Attack
            (28,      0),  # Mana for Early Waves
            (35,      0),  # Freeze Armor%
            (10,      0),  # XP Gained
            ( 6,      0),  # Skill: ALL
        ],
        "properties_at_max": [
            (13,     15),  # Damage to Flying
            (12,    200),  # Initial Mana
            (17,     20),  # Barrage Damage
            ( 9,     25),  # Damage to Giants
            (37,      5),  # Freeze Corpse Explosion HP%
            (40,     20),  # Whiteout XPBoost%
            (34,     10),  # Wasps Faster Attack
            (28,     35),  # Mana for Early Waves
            (35,      5),  # Freeze Armor%
            (10,     25),  # XP Gained
            ( 6,      1),  # Skill: ALL
        ],
    },
    "F5 Talisman Fragment": {
        "str_id": "F5",
        "ap_id": 941,
        "type": "INNER",
        "rarity": 97,
        "seed": 2720683,
        "upgrade_level": 0,
        "upgrade_level_max": 11,
        "shape_id": 9,
        "rune_id": 8,  # no rune
        "properties": [
            (29,      2),  # Wasp Chance from Bombs
            (12,      0),  # Initial Mana
            (13,      0),  # Damage to Flying
            (40,      0),  # Whiteout XPBoost%
            ( 9,      0),  # Damage to Giants
            ( 7,      0),  # Damage to Swarmlings
            (32,      0),  # Faster Orblet Rollback
            (16,      0),  # Bolt Damage
            (28,      0),  # Mana for Early Waves
            ( 6,      0),  # Skill: ALL
        ],
        "properties_at_max": [
            (29,      6),  # Wasp Chance from Bombs
            (12,    194),  # Initial Mana
            (13,     15),  # Damage to Flying
            (40,     20),  # Whiteout XPBoost%
            ( 9,     25),  # Damage to Giants
            ( 7,     25),  # Damage to Swarmlings
            (32,     10),  # Faster Orblet Rollback
            (16,     20),  # Bolt Damage
            (28,     35),  # Mana for Early Waves
            ( 6,      1),  # Skill: ALL
        ],
    },
    "A5 Talisman Fragment": {
        "str_id": "A5",
        "ap_id": 951,
        "type": "INNER",
        "rarity": 96,
        "seed": 9737695,
        "upgrade_level": 3,
        "upgrade_level_max": 11,
        "shape_id": 7,
        "rune_id": 1,  # rune visible
        "properties": [
            (30,      8),  # Slower Killchain Cooldown
            (40,     16),  # Whiteout XPBoost%
            (16,     13),  # Bolt Damage
            (15,      9),  # Beam Damage
            ( 9,      0),  # Damage to Giants
            (12,      0),  # Initial Mana
            ( 7,      0),  # Damage to Swarmlings
            (34,      0),  # Wasps Faster Attack
            (13,      0),  # Damage to Flying
            ( 6,      0),  # Skill: ALL
        ],
        "properties_at_max": [
            (30,      8),  # Slower Killchain Cooldown
            (40,     20),  # Whiteout XPBoost%
            (16,     20),  # Bolt Damage
            (15,     19),  # Beam Damage
            ( 9,     25),  # Damage to Giants
            (12,    193),  # Initial Mana
            ( 7,     24),  # Damage to Swarmlings
            (34,     10),  # Wasps Faster Attack
            (13,     15),  # Damage to Flying
            ( 6,      1),  # Skill: ALL
        ],
    },
    "D3 Talisman Fragment": {
        "str_id": "D3",
        "ap_id": 945,
        "type": "INNER",
        "rarity": 89,
        "seed": 1258641,
        "upgrade_level": 0,
        "upgrade_level_max": 10,
        "shape_id": 10,
        "rune_id": 4,  # rune visible
        "properties": [
            ( 9,     10),  # Damage to Giants
            (14,      0),  # Damage to Buildings
            (30,      0),  # Slower Killchain Cooldown
            (32,      0),  # Faster Orblet Rollback
            (16,      0),  # Bolt Damage
            ( 7,      0),  # Damage to Swarmlings
            (34,      0),  # Wasps Faster Attack
            (31,      0),  # Heavier Orblets
            ( 4,      0),  # Skill: Strike Spells
        ],
        "properties_at_max": [
            ( 9,     24),  # Damage to Giants
            (14,     14),  # Damage to Buildings
            (30,      7),  # Slower Killchain Cooldown
            (32,      9),  # Faster Orblet Rollback
            (16,     19),  # Bolt Damage
            ( 7,     24),  # Damage to Swarmlings
            (34,      9),  # Wasps Faster Attack
            (31,      9),  # Heavier Orblets
            ( 4,      1),  # Skill: Strike Spells
        ],
    },
    "A1 Talisman Fragment": {
        "str_id": "A1",
        "ap_id": 950,
        "type": "INNER",
        "rarity": 88,
        "seed": 6257243,
        "upgrade_level": 0,
        "upgrade_level_max": 10,
        "shape_id": 14,
        "rune_id": 2,  # rune visible
        "properties": [
            (36,      1),  # Freeze CritDmg%
            ( 7,      0),  # Damage to Swarmlings
            ( 8,      0),  # Damage to Reavers
            (12,      0),  # Initial Mana
            (35,      0),  # Freeze Armor%
            (40,      0),  # Whiteout XPBoost%
            (10,      0),  # XP Gained
            ( 9,      0),  # Damage to Giants
            ( 6,      0),  # Skill: ALL
        ],
        "properties_at_max": [
            (36,      6),  # Freeze CritDmg%
            ( 7,     24),  # Damage to Swarmlings
            ( 8,     24),  # Damage to Reavers
            (12,    184),  # Initial Mana
            (35,      5),  # Freeze Armor%
            (40,     18),  # Whiteout XPBoost%
            (10,     23),  # XP Gained
            ( 9,     24),  # Damage to Giants
            ( 6,      1),  # Skill: ALL
        ],
    },
    "B3 Talisman Fragment": {
        "str_id": "B3",
        "ap_id": 949,
        "type": "INNER",
        "rarity": 80,
        "seed": 9397020,
        "upgrade_level": 0,
        "upgrade_level_max": 10,
        "shape_id": 1,
        "rune_id": 3,  # rune visible
        "properties": [
            (11,     14),  # WizLevel to XP/Mana
            (37,      0),  # Freeze Corpse Explosion HP%
            (17,      0),  # Barrage Damage
            (29,      0),  # Wasp Chance from Bombs
            (33,      0),  # Mana Shard Harvesting Speed
            (32,      0),  # Faster Orblet Rollback
            (40,      0),  # Whiteout XPBoost%
            (12,      0),  # Initial Mana
            ( 6,      0),  # Skill: ALL
        ],
        "properties_at_max": [
            (11,     37),  # WizLevel to XP/Mana
            (37,      4),  # Freeze Corpse Explosion HP%
            (17,     18),  # Barrage Damage
            (29,      5),  # Wasp Chance from Bombs
            (33,     13),  # Mana Shard Harvesting Speed
            (32,      8),  # Faster Orblet Rollback
            (40,     17),  # Whiteout XPBoost%
            (12,    180),  # Initial Mana
            ( 6,      1),  # Skill: ALL
        ],
    },
    "H5 Talisman Fragment": {
        "str_id": "H5",
        "ap_id": 937,
        "type": "INNER",
        "rarity": 79,
        "seed": 5860063,
        "upgrade_level": 0,
        "upgrade_level_max": 9,
        "shape_id": 3,
        "rune_id": 1,  # rune visible
        "properties": [
            ( 9,      8),  # Damage to Giants
            (12,      0),  # Initial Mana
            (34,      0),  # Wasps Faster Attack
            (31,      0),  # Heavier Orblets
            (13,      0),  # Damage to Flying
            (32,      0),  # Faster Orblet Rollback
            (17,      0),  # Barrage Damage
            ( 1,      0),  # Skill: Component
        ],
        "properties_at_max": [
            ( 9,     21),  # Damage to Giants
            (12,    162),  # Initial Mana
            (34,      8),  # Wasps Faster Attack
            (31,      8),  # Heavier Orblets
            (13,     13),  # Damage to Flying
            (32,      9),  # Faster Orblet Rollback
            (17,     17),  # Barrage Damage
            ( 1,      1),  # Skill: Component
        ],
    },
    "B1 Talisman Fragment": {
        "str_id": "B1",
        "ap_id": 948,
        "type": "INNER",
        "rarity": 74,
        "seed": 5649923,
        "upgrade_level": 0,
        "upgrade_level_max": 9,
        "shape_id": 7,
        "rune_id": 1,  # rune visible
        "properties": [
            (11,     12),  # WizLevel to XP/Mana
            (13,      0),  # Damage to Flying
            (32,      0),  # Faster Orblet Rollback
            ( 9,      0),  # Damage to Giants
            (12,      0),  # Initial Mana
            (15,      0),  # Beam Damage
            (34,      0),  # Wasps Faster Attack
            ( 1,      0),  # Skill: Component
        ],
        "properties_at_max": [
            (11,     40),  # WizLevel to XP/Mana
            (13,     12),  # Damage to Flying
            (32,      8),  # Faster Orblet Rollback
            ( 9,     20),  # Damage to Giants
            (12,    160),  # Initial Mana
            (15,     16),  # Beam Damage
            (34,      8),  # Wasps Faster Attack
            ( 1,      1),  # Skill: Component
        ],
    },
    "G4 Talisman Fragment": {
        "str_id": "G4",
        "ap_id": 939,
        "type": "INNER",
        "rarity": 55,
        "seed": 3492165,
        "upgrade_level": 0,
        "upgrade_level_max": 7,
        "shape_id": 4,
        "rune_id": 4,  # rune visible
        "properties": [
            ( 7,      7),  # Damage to Swarmlings
            (37,      0),  # Freeze Corpse Explosion HP%
            (13,      0),  # Damage to Flying
            (16,      0),  # Bolt Damage
            (15,      0),  # Beam Damage
            (12,      0),  # Initial Mana
        ],
        "properties_at_max": [
            ( 7,     17),  # Damage to Swarmlings
            (37,      3),  # Freeze Corpse Explosion HP%
            (13,     12),  # Damage to Flying
            (16,     16),  # Bolt Damage
            (15,     15),  # Beam Damage
            (12,     82),  # Initial Mana
        ],
    },
}

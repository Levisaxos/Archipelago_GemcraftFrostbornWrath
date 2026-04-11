"""
GemCraft Frostborn Wrath — Rules Settings & Configuration

This file contains all configuration constants used across the rules system.
It is the single source of truth for tier definitions, grindiness levels, etc.
Everything here is designed to be readable by non-programmers.
"""

# =====================================================================
# WAVE-BASED TIER DEFINITIONS
# =====================================================================
# Maps stage progression tiers (0-12) to wave count thresholds.
# Used by levels, bonuses, and achievements to define gates.
#
# Format: "tier_N": {"minWaveCount": X}
# Usage: Write "of_tier_11" instead of "minWave: 84" in requirements
#
WAVE_TIERS = {
    "tier_0": {"minWaveCount": 14},
    "tier_1": {"minWaveCount": 22},
    "tier_2": {"minWaveCount": 28},
    "tier_3": {"minWaveCount": 33},
    "tier_4": {"minWaveCount": 40},
    "tier_5": {"minWaveCount": 48},
    "tier_6": {"minWaveCount": 54},
    "tier_7": {"minWaveCount": 60},
    "tier_8": {"minWaveCount": 70},
    "tier_9": {"minWaveCount": 72},
    "tier_10": {"minWaveCount": 78},
    "tier_11": {"minWaveCount": 84},
    "tier_12": {"minWaveCount": 96},
}

# =====================================================================
# GRINDINESS TIER DEFINITIONS
# =====================================================================
# Cumulative difficulty levels. Players select 1 when generating world.
#
# Selection → Which grindiness achievements are included:
#   "off"  → None
#   "1"    → Level 1 only
#   "2"    → Levels 1-2
#   "3"    → Levels 1-3
#   "4"    → Levels 1-4
#   "5"    → Levels 1-5 (all)
#
GRINDINESS_TIERS = {
    "off": [],
    "1": ["grindiness_1"],
    "2": ["grindiness_1", "grindiness_2"],
    "3": ["grindiness_1", "grindiness_2", "grindiness_3"],
    "4": ["grindiness_1", "grindiness_2", "grindiness_3", "grindiness_4"],
    "5": ["grindiness_1", "grindiness_2", "grindiness_3", "grindiness_4", "grindiness_5"],
}

# =====================================================================
# TIER PROGRESSION REQUIREMENTS (Tiers 0-12)
# =====================================================================
# Defines stage progression gates based on wave count thresholds.
# Each tier unlocks certain stages and their associated locations.
#
# Once a level is unlocked by reaching its tier, all checks are accessible:
# - Journey completion
# - Bonus completion
# - Wizard Stash location
#
tier_progression_requirements = {
    "Tier_0": {
        "description": "Starting tier - free access",
        "requirements": ["of_tier_0"],
        "wave_gate": "of_tier_0",
    },
    "Tier_1": {
        "description": "Early progression",
        "requirements": ["of_tier_1"],
        "wave_gate": "of_tier_1",
    },
    "Tier_2": {
        "description": "Stage tier 2 access",
        "requirements": ["of_tier_2"],
        "wave_gate": "of_tier_2",
    },
    "Tier_3": {
        "description": "Stage tier 3 access",
        "requirements": ["of_tier_3"],
        "wave_gate": "of_tier_3",
    },
    "Tier_4": {
        "description": "Stage tier 4 access (includes K4 - Swarm Queen)",
        "requirements": ["of_tier_4"],
        "wave_gate": "of_tier_4",
    },
    "Tier_5": {
        "description": "Stage tier 5 access",
        "requirements": ["of_tier_5"],
        "wave_gate": "of_tier_5",
    },
    "Tier_6": {
        "description": "Stage tier 6 access",
        "requirements": ["of_tier_6"],
        "wave_gate": "of_tier_6",
    },
    "Tier_7": {
        "description": "Stage tier 7 access",
        "requirements": ["of_tier_7"],
        "wave_gate": "of_tier_7",
    },
    "Tier_8": {
        "description": "Stage tier 8 access",
        "requirements": ["of_tier_8"],
        "wave_gate": "of_tier_8",
    },
    "Tier_9": {
        "description": "Stage tier 9 access",
        "requirements": ["of_tier_9"],
        "wave_gate": "of_tier_9",
    },
    "Tier_10": {
        "description": "Stage tier 10 access",
        "requirements": ["of_tier_10"],
        "wave_gate": "of_tier_10",
    },
    "Tier_11": {
        "description": "Stage tier 11 access",
        "requirements": ["of_tier_11"],
        "wave_gate": "of_tier_11",
    },
    "Tier_12": {
        "description": "Stage tier 12 access (includes A4 - Gatekeeper final boss)",
        "requirements": ["of_tier_12"],
        "wave_gate": "of_tier_12",
    },
}

# =====================================================================
# GAME ELEMENTS — Level Features
# =====================================================================
# Environmental elements that appear in specific stages.
# Each element appears in certain levels (to be filled in).
# Used by achievements that require encountering these elements.
#
# Format: "ElementName": {"levels": ["stage1", "stage2", ...]}
#
game_level_elements = {
    "Abandoned Dwelling": {"levels": ["J1", "G1", "V2", "J2", "S1", "X3"]},
    "Barricade": {"levels": ["D2", "V2", "E3", "H1", "H2", "T1", "W3", "X2", "Z1"]},
    "Beacon": {"levels": ["G1", "B4", "C2", "F1", "K2", "O1", "Q3", "U4", "Y2"]},
    "Corrupted Mana Shard": {"levels": ["E4", "C2", "X3", "Z5"]},
    "Drop Holder": {"levels": ["L5", "Q4", "B3", "F4", "M2", "P1", "U3"]},
    "Gatekeeper": {"levels": ["D4", "G4", "J4", "M4", "P6", "S4", "V4", "Y4"]},
    "Mana Shard": {"levels": ["C1", "A1", "D1", "F2", "H3", "K4", "R2", "W1"]},
    "Marked Monster": {"levels": ["E4", "C4", "N4", "X3"]},
    "Monster Nest": {"levels": ["S1", "G1", "G2", "P4", "B1", "F3", "L3", "U2", "Z4"]},
    "Obelisk": {"levels": ["A4", "C4", "G3", "M1", "Y3"]},
    "Possessed Monster": {"levels": ["A4", "C4", "G3", "M1", "Y3"]},
    "Shrine": {"levels": ["C3", "F1", "J3", "N2", "R4", "W2", "Y1"]},
    "Sleeping Hive": {"levels": ["E2", "S2", "W4", "O3"]},
    "Swarm Queen": {"levels": ["E2", "S2", "W4"]},
    "Tomb": {"levels": ["G1", "K3", "B5", "I4", "N3", "Q1", "T4"]},
    "Twisted Monster": {"levels": ["P5", "X4", "Z5"]},
    "Watchtower": {"levels": ["K1"]},
}

# =====================================================================
# NON-MONSTER ELEMENTS — Trait-Gated Features
# =====================================================================
# Special game elements that are unlocked by obtaining specific traits.
# These represent gameplay/mechanic unlocks rather than level features.
# Currently all require the Ritual battle trait, but can add level restrictions later.
#
# Format: "ElementName": {"requires_trait": "TraitName", "levels": [...]}
#
non_monster_elements = {
    "Shadow": {"requires_trait": "Ritual", "levels": ["G3"]},
    "Specter": {"requires_trait": "Ritual", "levels": []},
    "Spire": {"requires_trait": "Ritual", "levels": ["E2"]},
    "Wizard Hunter": {"requires_trait": "Ritual", "levels": ["L4"]},
    "Wraith": {"requires_trait": "Ritual", "levels": []},
}

# =====================================================================
# GAME SKILLS & BATTLE TRAITS
# =====================================================================
# Grouped by category for use in achievement requirements.
# Achievements can require "BattleTraits:2" meaning "at least 2 battle traits"
# or "GemSkills:3" meaning "at least 3 gem skills", etc.
#
game_skills_categories = {
    "BattleTraits": {
        "description": "Battle traits that modify combat mechanics",
        "members": [
            "Adaptive Carapace",
            "Awakening",
            "Corrupted Banishment",
            "Dark Masonry",
            "Giant Domination",
            "Haste",
            "Hatred",
            "Insulation",
            "Overcrowd",
            "Ritual",
            "Strength in Numbers",
            "Swarmling Domination",
            "Swarmling Parasites",
            "Thick Air",
            "Vital Link",
        ],
    },
    "GemSkills": {
        "description": "Gem-related abilities (basic gem types)",
        "members": [
            "Critical Hit",
            "Mana Leech",
            "Bleeding",
            "Armor Tearing",
            "Poison",
            "Slowing",
        ],
    },
    "OtherSkills": {
        "description": "Other skills and abilities",
        "members": [
            "Amplifiers",
            "Barrage",
            "Beam",
            "Bolt",
            "Demolition",
            "Freeze",
            "Ice Shards",
            "Lanterns",
            "Orb of Presence",
            "Pylons",
            "Traps",
            "Whiteout",
        ],
    },
}

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
    "Abandoned Dwelling": {"levels": ["F1", "I2", "J2", "M1", "M3", "O4", "Q4", "R4", "R6", "S2", "T4", "U4", "X2", "X3", "Z4"]},
    "Barricade": {"levels": ["B1", "B3", "B4", "C1", "C3", "D1", "E1", "E3", "E5", "F3", "F4", "F5", "H3", "H5", "I1", "I3", "I4", "K2", "L3", "L4", "M3", "N2", "O2", "O4", "P4", "Q2", "Q4", "Q5", "R1", "R3", "W4", "X3", "Y2", "Y4"]},
    "Beacon": {"levels": ["A3", "A4", "C1", "C4", "H2", "J4", "L1", "O2", "P2", "S2", "S4", "T1", "T3", "V2", "X4", "Z1"]},
    "Corrupted Mana Shard": {"levels": ["C2", "E4"]},
    "Drop Holder": {"levels": ["F1", "I2", "J2", "L2", "M3", "O2", "O4", "Q4", "S2", "X2", "Z4"]},
    "Gatekeeper": {"levels": ["A4"]},
    "Mana Shard": {"levels": ["C2", "J2", "J4", "K3", "L3", "M3", "N2", "N3", "U3", "U4", "X3", "X4", "Y2", "Y4", "Z3", "Z5"]},
    "Monster Nest": {"levels": ["B1", "B2", "B5", "C1", "C3", "D2", "D4", "E2", "E3", "G2", "H1", "J1", "K3", "K5", "L1", "L5", "M1", "M2", "N3", "N4", "O3", "O4", "P2", "P4", "P5", "R6", "S1", "S3", "T1", "T3", "U4", "V3", "X1", "X3", "Z1", "Z2", "Z3", "Z4"]},
    "Obelisk": {"levels": ["A4", "C4"]},
    "Shrine": {"levels": ["B4", "H2", "J2", "J4", "L3", "M4", "N3", "R4", "U3", "V2"]},
    "Sleeping Hive": {"levels": ["B4", "Y1"]},
    "Swarm Queen": {"levels": ["K4"]},
    "Tomb": {"levels": ["B1", "E5", "F3", "I2", "J3", "M3"]},
    "Watchtower": {"levels": ["K1"]},
    "Wizard Tower": {"levels": ["L5"]},
    # Hidden Codes: not supported by the mod — empty levels marks it as excluded.
    "Hidden Codes": {"levels": []},
    # Sealed gem: gem locked in a map socket that can be freed. Fill in levels once confirmed.
    "Sealed gem": {"levels": []},
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
    "Shadow": {"requires_trait": "Ritual", "levels": ["A4", "C5", "E4", "G3"]},
    "Specter": {"requires_trait": "Ritual", "levels": ["E4", "Y4"]},
    "Spire": {"requires_trait": "Ritual", "levels": ["E2"]},
    "Wizard Hunter": {"requires_trait": "Ritual", "levels": ["L4"]},
    "Wraith": {"requires_trait": "Ritual", "levels": ["A4", "X4"]},
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
    "Skills": {
        "description": "Gem-related abilities (basic gem types)",
        "members": [
            "GemSkills",
            "OtherSkills"
        ]
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

# =====================================================================
# SKILL GROUP COUNTERS — Requirement Type
# =====================================================================
# Used for achievements that need "any N skills from this group" instead of specific skills.
# Format: "skillGroupName: N" where N is the count needed.
# Example: "strikeSpells: 1" means "need any 1 strike spell"
#
skill_groups = {
    "strikeSpells": {
        "description": "Strike spells (Freeze, Whiteout, Ice Shards)",
        "members": ["Freeze", "Whiteout", "Ice Shards"],
    },
    "enhancementSpells": {
        "description": "Enhancement spells (Bolt, Beam, Barrage)",
        "members": ["Bolt", "Beam", "Barrage"],
    },
    "gemTypes": {
        "description": "Gem skill types (all gem types)",
        "members": ["Critical Hit", "Mana Leech", "Bleeding", "Armor Tearing", "Poison", "Slowing"],
    },
}

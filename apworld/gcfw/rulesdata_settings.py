"""
GemCraft Frostborn Wrath — Rules Settings & Configuration

This file contains all configuration constants used across the rules system.
It is the single source of truth for tier definitions, grindiness levels, etc.
Everything here is designed to be readable by non-programmers.
"""

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
    "Jar of Wasps": {"levels": ["X1", "X2"]},    
    "Sealed gem": {"levels": ["C1"]},
    "Rain": {"levels": ["F2", "F3", "F4", "F5", "I4", "J1", "J2", "J3", "J4", "L1", "L2", "L3", "M1", "M2", "M3", "M4", "N1", "N2", "N3", "N4", "N5", "O1", "O2", "O3", "O4", "P1", "P2", "P3", "P4", "P5", "P6", "Q4", "R3", "R6"]},
    "Snow": {"levels": ["Q4", "T1", "T2", "T3", "T4", "T5", "U1", "U2", "U3", "U4", "X1", "X2", "X3", "X4", "Y1", "Y2", "Y3", "Y4", "Z1", "Z2", "Z3"]},
    "Hidden Codes": {"levels": [], "unsupported": True},
    # Tower, Wall — universal building types, present on every stage. The eTower / eWall tokens fall through to "always satisfied" (rules.py default for unmapped elements) — no entry needed here.
    # Wizard Stash — every stage has one but they're locked behind per-stage key items. The eWizardStash token gets special-cased in rules.py against the wizard-stash key item pool.
}

# =====================================================================
# NON-MONSTER ELEMENTS — Trait-Gated Features
# =====================================================================
# Special game elements that are unlocked by obtaining specific traits.
# These represent gameplay/mechanic unlocks rather than level features.
# Currently all require the Ritual battle trait, but can add level restrictions later.
#
# Format: "ElementName": {"levels": [...]}
#
non_monster_elements = {
    "Shadow":        {"levels": ["A4", "C5", "E4", "G3"]},
    "Specter":       {"levels": ["E4", "Y4"]},
    "Spire":         {"levels": ["E2"]},
    "Wizard Hunter": {"levels": ["L4"]},
    "Wraith":        {"levels": ["A4", "X4"]},
    "Apparition":    {"levels": ["Q1", "R6"]},
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
    "gemSkills": {
        "description": "Gem skill types (all gem types)",
        "members": ["Critical Hit", "Mana Leech", "Bleeding", "Armor Tearing", "Poison", "Slowing"],
    },
}
"""
GemCraft Frostborn Wrath — Rules Settings & Configuration

This file contains all configuration constants used across the rules system.
It is the single source of truth for tier definitions, grindiness levels, etc.
Everything here is designed to be readable by non-programmers.
"""

# Per-stage element presence is now tracked entirely in rulesdata_levels.py
# via <Pascal>Count fields (e.g. DropHolderCount, ShadowCount, RainCount).
# Element token vocabulary lives in requirement_tokens.element_prefix_map;
# rules.py and __init__.py derive reachability from the per-stage counts.

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
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
            "Fury",
            "Fusion",
            "Ice Shards",
            "Lanterns",
            "Mana Stream",
            "Orb of Presence",
            "Pylons",
            "Resonance",
            "Seeker Sense",
            "Traps",
            "True Colors",
            "Whiteout",
        ],
    },
}
# GemSkills (6) + OtherSkills (18) = the 24 in-game skills (SkillId 0..23).
# This total must stay 24: the `skills:24` achievement (Skillful) means "all
# skills", matching the vanilla checker that loops all 24 selectedSkillLevels.
# Fury (18) and Seeker Sense (23) were previously missing here, which forced
# the skills counter to pad with battle traits — see requirement_tokens.py.

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

# =====================================================================
# DIFFICULTY / PROGRESSION TUNING
# =====================================================================
# Levels unlock based on the player's wizard level, which rises by clearing
# levels. Everything a non-programmer would want to tweak lives here. Tweak a
# number, re-run export_difficulty_gates.py to refresh the shipped data.

# Stages the player always begins with (the W tile). Required wizard level 0.
starter_stages = ["W1", "W2", "W3", "W4"]

# Difficulty changes how much XP you earn per field. On harder difficulties you
# enrage with stronger gems, so each field grants MORE XP and you reach a higher
# wizard level overall. The per-field shape comes from the real wave simulation
# (extract_level_monster_data.field_xp_by_difficulty); the numbers below say
# what wizard level a player is expected to reach after clearing the whole map
# on each difficulty. The exporter scales the simulated per-field XP so the
# full-map total lands on these wizard levels — i.e. these ARE the calibration
# targets, matching real in-game wizard levels from actual playthroughs.
#
# Because even the lowest target (Easy) is well above 100, every achievement
# WL:x gate (which tops out around 100) is reachable on every difficulty.
difficulty_target_final_wl = {
    "Easy":    120,
    "Medium":  147,
    "Hard":    164,
    "Extreme": 199,
}

# There is ONE gate (required wizard level) per level, the same on every
# difficulty. It is pinned to the SLOWEST difficulty's pace (Easy — the lowest
# final wizard level) so every difficulty can reach it (the seed is always
# solvable), times a small safety factor for head-room. Harder difficulties earn
# XP faster and simply blow past it; Easy is the intended/binding pace.
gate_safety = 0.9

# Minimum wizard level before an achievement enters logic, by its effort tier.
# Achievements keep their real in-game requirements (enforced by the mod); the
# apworld just paces WHEN they become expected, via this WL gate. Must stay
# below the slowest difficulty's reachable WL (Easy, ~119) so every difficulty
# can reach them.
achievement_min_wl = {
    "Trivial": 0,
    "Minor":   15,
    "Major":   35,
    "Extreme": 55,
}
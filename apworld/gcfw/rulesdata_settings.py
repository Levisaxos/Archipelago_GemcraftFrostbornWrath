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

# NEW MODEL: difficulty no longer scales the averages. Logic/gating uses a single
# baseline = the RAW wave-sim XP per field (`minxp` in difficulty_gates.json), the
# same on every difficulty. Difficulty is instead a multiplier on the player's
# REAL earned XP, applied mod-side (Easy earns more, Extreme ~= the raw sim). So
# every difficulty targets the SAME full-map WL, which is exactly what the raw sim
# yields (~86). The exporter should emit `eff_xp = minxp` (scale factor 1.0).
#
# NOTE: data/difficulty_gates.json has been hand-updated to this model (eff_xp =
# minxp, gates rescaled). Re-running the OLD exporter that scales to per-difficulty
# targets would OVERWRITE it — update the exporter to the minxp model first.
#
# !! NOT AUTHORITATIVE ANY MORE !! The live pipeline is
#    py-scripts/apply_xp_curve.py, which reads the target from
#    mods/ArchipelagoMod/src/data/json/xp_curve.json ("targetFinalWl").
# The dict below is only still read by the STALE export_difficulty_gates.py.
# Change the target in xp_curve.json; this copy is kept in sync by hand purely
# so the old exporter isn't silently wrong if anyone ever revives it.
difficulty_target_final_wl = {
    "Easy":    100,
    "Medium":  100,
    "Hard":    100,
    "Extreme": 100,
}

# NOTE: the per-TILE XP-curve multiplier does NOT live here — the apworld has no
# use for it. It's a game-tuning constant owned by the mod:
#     mods/ArchipelagoMod/src/data/json/xp_curve.json
# The mod applies it to earned monster XP at runtime; the same file is read by
# do not commit/py-scripts/apply_xp_curve.py, which bakes the resulting curve
# into data/difficulty_gates.json (eff_xp + gate, rescaled to targetFinalWl).
# The apworld only ever reads those finished numbers.

# There is ONE gate (required wizard level) per level, the same on every
# difficulty. With a single baseline it's simply derived from the raw-sim
# cumulative XP, times a small safety factor for head-room. Since real earned XP
# (bare minimum, no traits) already runs ~1.5x the raw sim, every difficulty can
# reach the gates; Extreme (0.5x real) is the binding/tightest pace.
gate_safety = 0.9

# Minimum wizard level before an achievement enters logic, by its effort tier.
# Achievements keep their real in-game requirements (enforced by the mod); the
# apworld just paces WHEN they become expected, via this WL gate. On the raw-sim
# baseline the full-map WL is ~86, so these stay below it and remain reachable.
achievement_min_wl = {
    "Trivial": 0,
    "Minor":   8,
    "Major":   23,
    "Extreme": 38,
}
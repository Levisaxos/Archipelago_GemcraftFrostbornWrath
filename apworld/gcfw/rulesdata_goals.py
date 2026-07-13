"""
GemCraft Frostborn Wrath — Goal Requirements

Defines all available goals and what's required to achieve them.
This is the single source of truth for victory conditions.
"""

# =====================================================================
# GOAL DEFINITIONS
# =====================================================================
# Each goal defines:
#   - display_name: Human-readable name
#   - description: What the player must do to win
#   - requirements: What must be accessible/completed
#   - tier: Minimum stage tier required (for reference)

goal_requirements = {
    "kill_gatekeeper": {
        "display_name": "Kill Gatekeeper",
        "description": "Defeat the Gatekeeper, the final boss on stage A4",
        "requirements": ["Complete A4 - Journey"],
        "notes": "A4 is in tier 12. Requires completing sufficient stages from all previous tiers.",
        "tier": 12,
    },

    "kill_swarm_queen": {
        "display_name": "Kill Swarm Queen",
        "description": "Defeat the Swarm Queen, the final boss on stage K4",
        "requirements": ["Complete K4 - Journey"],
        "notes": "K4 is in tier 4. A mid-game goal, easier than defeating the Gatekeeper.",
        "tier": 4,
    },

    "fields_count": {
        "display_name": "Fields Count",
        "description": "Complete a specific number of Journey stages",
        "requirements": [
            "Fields Required: Set by player (default 80/122 stages)",
        ],
        "notes": "Requires completing N Journey mode stages. Count is set by the 'Fields Required' option.",
        "tier": 0,
    },
}

# =====================================================================
# GOAL SELECTION (YAML)
# =====================================================================
# Players select a goal in their YAML file:
#
# goal: 0  → Kill Gatekeeper (hardest, tier 12)
# goal: 1  → Kill Swarm Queen (medium, tier 4)
# goal: 2  → Complete N fields
#

# =====================================================================
# STAGE / TIER ACCESS
# =====================================================================
# Stage access is gated by the player's derived wizard level (see
# difficulty_gates.py), NOT by a tier-token percentage. The requirements /
# notes / tier fields in goal_requirements below are descriptive only —
# rules.py hardcodes the real access rules and ignores those strings.

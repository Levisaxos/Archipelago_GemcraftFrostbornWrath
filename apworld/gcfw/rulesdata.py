from __future__ import annotations
import json
from importlib.resources import files

from dataclasses import dataclass, field
from typing import Dict, List


# global bc json loads are costly
GAME_DATA = json.loads(files(__package__).joinpath("data/game_data.json").read_text(encoding="utf-8"))


# ---------------------------------------------------------------------------
# Skill categories (by in-game grouping; component -> "gems" and strike + enhancement -> "spells"
# ---------------------------------------------------------------------------
SKILL_CATEGORIES: Dict[str, List[str]] = {
    "focus":     ["True Colors", "Fusion", "Orb of Presence", "Resonance"],
    "gems":      ["Critical Hit", "Mana Leech", "Bleeding", "Armor Tearing", "Poison", "Slowing"],
    "spells":    ["Freeze", "Whiteout", "Ice Shards", "Bolt", "Beam", "Barrage"],
    "buildings": ["Amplifiers", "Pylons", "Lanterns", "Traps"],
    "wrath":     ["Mana Stream", "Demolition", "Fury", "Seeker Sense"]  # <- all of these suck except mana stream LMAO
}

# Tier skill gating was removed — achievement locations spread skills naturally,
# and per-stage gemSkills requirements in game_data.json `required_skills` handle
# gem gates. The TIER_SKILL_REQUIREMENTS / CUMULATIVE_SKILL_REQUIREMENTS tables
# that previously lived here are gone; reinstate from git history if needed.


@dataclass
class StageRule:
    # Skill names required by WIZLOCK (the game locks these stages until the skills are unlocked).
    skills: List[str] = field(default_factory=list)


# Stages with no field token item. Empty: every stage including W1-W4
# now has its own Field Token (item_ap_ids 1-4 / 5-8). The chosen
# starting stages (see options.StartingStages) are the only stages without
# a token gate, and it's reached directly from Menu in
# __init__.create_regions — no FREE_STAGES entry needed.
FREE_STAGES: set = set()


# ---------------------------------------------------------------------------
# Per-stage access rules
# ---------------------------------------------------------------------------
# Every stage must have an entry. Set skills=[] if the game has no WIZLOCK
# requirement for that stage.
#
# Explicit WIZLOCK data taken from game_data.json required_skills fields.


STAGE_RULES: Dict[str, StageRule] = {}
for stage in GAME_DATA["stages"]:
    sid = stage["str_id"]
    STAGE_RULES[sid] = StageRule(skills=stage["required_skills"])
del stage, sid


# ---------------------------------------------------------------------------
# Progressive tile ordering — single source of truth for the unlock order of
# every progressive granularity (gempouches, field tokens, stash keys).
#
# The Nth received copy of a progressive item unlocks the Nth tile prefix
# below. Pick exactly one variant to be active; the others stay commented
# out for easy switching. All three categories pick up the active list
# automatically.
#
# Candidate orderings (derived in `do not commit/py-scripts/tile_difficulty_analysis.py`):
#   - canonical    : hand-curated, A intentionally last. Roughly natural
#                    progression but mis-ranks tiles 21–25 (Z/Y/X/U/T).
#   - avg_waves    : tiles sorted by mean wave_count across their stages.
#   - avg_hp_enemy : tiles sorted by mean per-enemy HP (hpFirstWave * hpMult^i).
#   - sum_hp_tile  : tiles sorted by total HP of every enemy on the tile.
# ---------------------------------------------------------------------------

# Active ordering: by average waves per tile.
PROGRESSIVE_TILE_ORDER: List[str] = [
    "W", "S", "V", "Q", "R", "T", "U", "O", "Y", "P", "X", "Z", "K",
    "N", "L", "G", "J", "M", "H", "E", "D", "F", "I", "B", "C", "A",
]

# --- Alternative orderings (uncomment one and comment out the active one above) ---

# Canonical hand-curated order (W → S → V → R → ... → A last):
# PROGRESSIVE_TILE_ORDER: List[str] = [
#     "W", "S", "V", "R", "Q", "P", "O", "N", "M", "L", "K", "J", "I", "H",
#     "G", "F", "E", "D", "C", "B", "Z", "Y", "X", "U", "T", "A",
# ]

# By average HP per enemy (asc):
# PROGRESSIVE_TILE_ORDER: List[str] = [
#     "W", "S", "V", "Q", "R", "U", "T", "Y", "O", "P", "X", "K", "Z",
#     "G", "L", "N", "J", "M", "H", "E", "D", "I", "B", "C", "F", "A",
# ]

# By total HP per tile (asc):
# PROGRESSIVE_TILE_ORDER: List[str] = [
#     "W", "S", "V", "Q", "U", "R", "T", "O", "Y", "X", "P", "K", "Z",
#     "G", "L", "J", "N", "M", "H", "E", "D", "I", "B", "C", "F", "A",
# ]

# Backward-compatible alias — old code still references this name. Both
# point to the same list, so editing PROGRESSIVE_TILE_ORDER updates both.
GEM_POUCH_PLAY_ORDER: List[str] = PROGRESSIVE_TILE_ORDER
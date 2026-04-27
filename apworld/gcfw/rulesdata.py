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
    # Tier this stage belongs to (0 = free from W1, 1+ = gated by previous tier).
    tier: int = 0
    # Skill names required by WIZLOCK (the game locks these stages until the skills are unlocked).
    skills: List[str] = field(default_factory=list)


# ---------------------------------------------------------------------------
# Tier system
# ---------------------------------------------------------------------------
# Stages are grouped into tiers based on difficulty (derived from former
# wizard-level thresholds).  Each tier requires the player to have collected
# a minimum number of field tokens from the *immediately previous* tier.
#
# FREE_STAGES (W2-W4) are accessible from W1 without any token — they are
# the tutorial zone and mirror the real game's natural map progression.
# They have no field token item and are not counted in any tier gate.
#
# Other Tier 0 stages (S1-S4, V1) require their own field token but
# have no tier requirement on top.
#
# Tier 1+ stages require their own field token AND N tokens from the
# previous tier, where N scales with difficulty.

# Stages accessible from W1 without needing their field token.
# W2/W3/W4 have no field token item; they are always unlocked on connect.
FREE_STAGES: set = {"W2", "W3", "W4"}

# Wave-count thresholds defining tier 0..12 boundaries. A stage's tier is the
# highest t whose threshold[t] <= wave_count. Same table used by
# `do not commit/py-scripts/generate_rulesdata_split.py`.
_TIER_WAVE_THRESHOLDS: List[int] = [14, 22, 28, 33, 40, 48, 54, 60, 70, 72, 78, 84, 96]


def _tier_from_wave_count(wave_count: int) -> int:
    for t in range(len(_TIER_WAVE_THRESHOLDS) - 1, -1, -1):
        if wave_count >= _TIER_WAVE_THRESHOLDS[t]:
            return t
    return 0


# Tier definitions: tier_number → list of stage str_ids in that tier.
# Derived from each stage's wave_count in game_data.json; W1 (entry stage)
# and FREE_STAGES (W2-W4, no token items) are excluded.
# TODO: rebalance tiers - t4 is too big and t8 is too small.
TIERS: Dict[int, List[str]] = {t: [] for t in range(len(_TIER_WAVE_THRESHOLDS))}
for _stage in GAME_DATA["stages"]:
    _sid = _stage["str_id"]
    if _sid == "W1" or _sid in FREE_STAGES:
        continue
    TIERS[_tier_from_wave_count(int(_stage["wave_count"]))].append(_sid)
del _stage, _sid


# ---------------------------------------------------------------------------
# Per-stage access rules
# ---------------------------------------------------------------------------
# Every stage must have an entry.  Set tier=0 and no skills for stages that
# are freely accessible from W1.  Set skills=[] if the game has no WIZLOCK
# requirement for that stage.
#
# Tier assignments derived from wave counts via the former wizard-level table.
# Explicit WIZLOCK data taken from game_data.json required_skills fields.


STAGE_RULES: Dict[str, StageRule] = {}
for stage in GAME_DATA["stages"]:
    sid = stage["str_id"]
    if sid == "W1" or sid in FREE_STAGES:
        # Free / entry stages don't belong to any tier (no token item).
        STAGE_RULES[sid] = StageRule(tier=-1, skills=stage["required_skills"])
    else:
        STAGE_RULES[sid] = StageRule(
            tier=_tier_from_wave_count(int(stage["wave_count"])),
            skills=stage["required_skills"],
        )
del stage, sid
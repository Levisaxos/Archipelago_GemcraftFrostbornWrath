"""
Difficulty gates: the data + wizard-level curve the rules use.

Levels are gated by the player's wizard level (which rises by clearing levels)
rather than by field tokens. Clearing a stage grants difficulty-scaled XP (a
"Beat <sid>" event); a stage unlocks once wizard level >= its gate.

Data is precomputed in data/difficulty_gates.json by
do not commit/py-scripts/export_difficulty_gates.py (re-run after changing the
difficulty tuning in rulesdata_settings.py).
"""

import json
import math
from importlib.resources import files

_DATA = json.loads(
    files(__package__).joinpath("data/difficulty_gates.json").read_text(encoding="utf-8")
)

DIFFICULTIES = _DATA["difficulties"]   # ["Easy","Medium","Hard","Extreme"]
STARTERS = set(_DATA["starters"])
GATE = _DATA["gate"]                   # {sid: required wizard level}
EFF_XP = _DATA["eff_xp"]               # {difficulty: {sid: xp}}
ACH_MIN_WL = _DATA.get("achievement_min_wl", {})  # {effort tier: min WL}


def player_level_xp_req(level: int) -> int:
    """Total XP needed to reach wizard `level` (Calculator.calculatePlayerLevelXpReq)."""
    d2 = 30 + (level - 1) * 5
    d = 600 + d2 / 2 * (level - 1)
    return -10 + 10 * math.floor(0.8 * (300 + d / 2 * (level - 1)) / 10 + 0.5)


def level_from_xp(xp: float, _cap: int = 3000) -> int:
    """Highest wizard level whose XP requirement is <= xp."""
    lvl = 0
    while lvl < _cap and player_level_xp_req(lvl + 1) <= xp:
        lvl += 1
    return lvl

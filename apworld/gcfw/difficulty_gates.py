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


# ---------------------------------------------------------------------------
# Canonical Wizard-Level formula  (LOCKED — invariant 1 of the WL-derived brief)
# ---------------------------------------------------------------------------
# WL is DERIVED from the fields you have CLEARED. It is never received as an item
# and never read from the game's live wizard level.
#
#     WL         = level_from_xp( base_xp * trait_mult )
#     base_xp    = sum of eff_xp[difficulty][sid] over every cleared field sid
#     trait_mult = 1.2 ** (number of the 4 XP-scaling traits currently held)
#
# The multiplier is RETROACTIVE and state-dependent: holding a trait multiplies
# the XP of ALL cleared fields (including ones cleared before the trait dropped),
# so collecting one jumps WL — the intended "power spike".
# Max-trait-replay: a trait's presence grants the full 1.2; its in-game upgrade
# level is ignored.
#
# Both the apworld (`_wl_of` in rules.py, via this function) and the mod MUST
# reproduce this bit-for-bit. Parity rules:
#   * use the EXACT literal multipliers in XP_TRAIT_MULTIPLIER (never Math.pow —
#     its last-bit result can differ across runtimes),
#   * port player_level_xp_req / level_from_xp verbatim.
# data/wl_test_vectors.json is the shared contract both sides validate against
# (regenerate with py-scripts/export_wl_test_vectors.py after any formula change).

# The 4 XP-scaling traits (findable `progression`; Overcrowd may be precollected
# via starting_overcrowd). Order is irrelevant — only the COUNT held matters.
XP_TRAIT_ITEM_NAMES = (
    "Haste Battle Trait",
    "Overcrowd Battle Trait",
    "Ritual Battle Trait",
    "Dark Masonry Battle Trait",
)

# index = number of XP traits held (0..4); value = 1.2**index as an exact literal
# so the apworld and the AS3 mod multiply by identical IEEE-754 doubles.
XP_TRAIT_MULTIPLIER = (1.0, 1.2, 1.44, 1.728, 2.0736)


def difficulty_name(value: int) -> str:
    """Resolve a difficulty option index (0..3) to its EFF_XP key."""
    return DIFFICULTIES[value]


def derived_wl(cleared_sids, num_xp_traits_held: int, difficulty: str) -> int:
    """Canonical WL from cleared fields + held XP traits. See the spec above.

    cleared_sids:       iterable of str_ids the player has cleared.
    num_xp_traits_held: how many of XP_TRAIT_ITEM_NAMES are collected (0..4).
    difficulty:         an EFF_XP key ("Easy".."Extreme"); use difficulty_name().
    """
    eff = EFF_XP[difficulty]
    base = 0
    for sid in cleared_sids:
        base += eff.get(sid, 0)
    n = num_xp_traits_held
    if n < 0:
        n = 0
    elif n > 4:
        n = 4
    total = base * XP_TRAIT_MULTIPLIER[n]
    return level_from_xp(total)

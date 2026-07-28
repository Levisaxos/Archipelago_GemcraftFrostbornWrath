"""
Difficulty gates: the data + wizard-level curve the rules use.

Levels are gated by the player's wizard level (which rises by clearing levels)
rather than by field tokens. Clearing a stage grants difficulty-scaled XP (a
"Beat <sid>" event); a stage unlocks once wizard level >= its gate.

Data is precomputed in data/difficulty_gates.json by
do not commit/py-scripts/export_difficulty_gates.py (re-run after changing the
difficulty tuning in rulesdata_settings.py).
"""

import bisect
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


# Precomputed monotonic XP thresholds for levels 1.._LEVEL_CAP. `level_from_xp`
# is on the fill hot path (called once per WL gate check, ~60k times per seed);
# the old level-by-level climb called player_level_xp_req ~150x per call (millions
# of calls per generation). A binary search over this table is O(log n) and
# returns the EXACT same value — the thresholds are the exact player_level_xp_req
# outputs, so WL stays bit-identical (parity with the mod's WizardLevelCalc).
_LEVEL_CAP = 3000
_LEVEL_XP_REQ = [player_level_xp_req(_l) for _l in range(1, _LEVEL_CAP + 1)]


def level_from_xp(xp: float, _cap: int = _LEVEL_CAP) -> int:
    """Highest wizard level whose XP requirement is <= xp."""
    n = bisect.bisect_right(_LEVEL_XP_REQ, xp)
    return n if n <= _cap else _cap


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
# HARNESS GATE: a held trait only counts once the wizard is strong enough to run
# it alongside the ones already active — collecting all 4 early doesn't grant the
# full 2.0736x when you lack the power to stack them. The k-th trait applies only
# if the WL you have ALREADY reached (with the first k-1 traits applied) meets
# XP_TRAIT_MIN_WL[k]. This is a GREEDY step-up: traits bootstrap each other (the
# boost from trait k-1 can push you over the threshold for trait k), and every
# comparison is against a WL the player actually sees. So the effective count is
# never received/held-count directly — it is derived through effective_trait_wl.
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

# DROPPED 2026-07-19: the XP-trait multiplier no longer affects Wizard Level.
# All entries are 1.0, so WL = level_from_xp(base_xp) regardless of how many
# XP-scaling traits are held (the harness-gate loop below still runs but is a
# no-op). Rationale: the retroactive multiplier was the one piece of the WL
# formula that couldn't be made cheap/boolean; dropping it lets WL be a plain
# accumulated sum, and the XP CURVE (mod-owned
# mods/ArchipelagoMod/src/data/json/xp_curve.json, baked into eff_xp/gate here
# by py-scripts/apply_xp_curve.py) now shapes early-vs-late pacing instead. Ships to the mod as [1,1,1,1,1] via
# slot_data (ApReceiver reads xp_trait_multiplier), so the mod's derived WL
# drops it too with NO mod code change. To restore, put the 1.2**index values
# back and regenerate wl_test_vectors.json.
# NOTE: this is the LOGIC multiplier only. The game's real in-game trait XP
# boost (traitsXpMult, vanilla) is a separate mechanic and is untouched.
XP_TRAIT_MULTIPLIER = (1.0, 1.0, 1.0, 1.0, 1.0)

# Min derived WL required to "harness" the k-th XP-scaling trait (see the HARNESS
# GATE note above). index = target trait count; the k-th trait counts only if the
# WL already reached with (k-1) traits applied is >= XP_TRAIT_MIN_WL[k]. index 0
# is a placeholder (holding 0 traits is always fine). Ships to the mod via
# slot_data as xp_trait_min_wl; both sides walk it identically in effective_trait_wl.
XP_TRAIT_MIN_WL = (0, 10, 20, 30, 40)


def effective_trait_wl(base_xp, num_xp_traits_held: int) -> int:
    """Derived WL from base cleared-field XP + held XP traits, WITH the harness
    gate (greedy step-up). Apply traits one at a time, counting the k-th only if
    the WL already reached (with k-1 traits) meets XP_TRAIT_MIN_WL[k]. Both the
    apworld hot path (_wl_of) and the AS3 mod (WizardLevelCalc.derivedWl) MUST
    reproduce this bit-for-bit. See difficulty_gates spec + wl_test_vectors.json.
    """
    held = num_xp_traits_held
    if held < 0:
        held = 0
    elif held > 4:
        held = 4
    n = 0
    wl = level_from_xp(base_xp * XP_TRAIT_MULTIPLIER[0])
    while n < held and wl >= XP_TRAIT_MIN_WL[n + 1]:
        n += 1
        wl = level_from_xp(base_xp * XP_TRAIT_MULTIPLIER[n])
    return wl


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
    return effective_trait_wl(base, num_xp_traits_held)

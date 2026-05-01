"""
Power-gating model for AP fill.

Single source of truth for tunable weights and thresholds. Editing this file
is the intended way to recalibrate; everything else just calls helpers from
here.

Concepts:
  - Player power = sum over collected items of (item_type_weight × count).
    Talisman fragments are weighted by rarity, everything else by a flat per-
    item weight.
  - Required power = the threshold an achievement gates against. Each
    achievement either declares an explicit `required_power` field or falls
    back to the effort → power map.
  - PowerScale yaml option multiplies the *thresholds* (not the weights):
      50  → halved thresholds, easier seed
     100  → baseline
     200  → doubled thresholds, harder seed

  Mathematically equivalent to inverse-multiplying the weights, but parallel to
  EnemyHpMultiplier where higher = harder.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from BaseClasses import CollectionState
    from .rulesdata import GAME_DATA  # only for typing
    from . import GemcraftFrostbornWrathWorld

# ---------------------------------------------------------------------------
# Weights — what each AP item contributes to the player's power score.
# Relative to 1 SP = 1.0 power.
# ---------------------------------------------------------------------------

WEIGHT_SP                = 1.0
WEIGHT_GEM_SKILL         = 6.0   # IDs 706-711 — unlock entire gem types
WEIGHT_OTHER_SKILL       = 2.5   # IDs 700-723 minus gem skills
WEIGHT_BATTLE_TRAIT      = 0.0   # neutral — traits make battles harder too
WEIGHT_XP_TOME_LEVEL     = 0.35  # per wizard level granted by an XP tome
WEIGHT_SHADOW_CORE_ITEM  = 0.1   # per Shadow Cores stash item received
WEIGHT_TALISMAN_DIVISOR  = 25.0  # per fragment: rarity / 25 (rarity-100 → 4)
WEIGHT_GEMPOUCH          = 6.0   # per pouch (distinct or progressive copy) —
                                  # unlocks gem orbs for an entire prefix,
                                  # comparable to a gem skill

# ---------------------------------------------------------------------------
# Required-power thresholds per stage tier (0..12).
# Tier curve roughly tracks the exponential difficulty growth — see the
# brainstorm doc for the per-tier monster-HP/wave-count justification.
# ---------------------------------------------------------------------------

# Calibrated to be reachable with progression-class items only (skills + SP
# bundles). Talismans, XP tomes, and shadow cores remain `useful`/`filler` and
# don't count toward state during the main fill phase. Reduced ~40% from the
# previous curve so stage locations open up earlier in fill spheres — that
# way useful items end up at stages too, not concentrated on the (un-gated,
# always-reachable) achievement locations.
STAGE_TIER_POWER: list[int] = [0, 3, 7, 15, 27, 42, 60, 84, 114, 150, 192, 246, 312]

# ---------------------------------------------------------------------------
# Achievement gating is per-achievement only.
#
# `required_effort` (Trivial / Minor / Major / Extreme) on an achievement is
# strictly a TIME-investment label — used for filtering achievements via the
# yaml `achievement_required_effort` option. It does NOT contribute to power.
#
# Power gating is opt-in per achievement via the `required_power` field in
# rulesdata_achievements.py. Use it for achievements that need a specific
# build / mechanical capability, such as:
#   - "Reach 9000 starting mana"        → high power (talismans + skills)
#   - "Kill enemy with > 20000 HP"      → high power (damage scaling)
#   - "Reach level 100"                 → power (needs many open levels + xp)
# Time-only achievements (e.g. "Win 50 battles", "Lit 90 fields", "5000
# shrine kills") get no `required_power` — their gating comes from the
# per-achievement element/skill requirements + the time it takes to grind.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Static item-name lists for power computation. Built once at import time so
# state lookups don't repeat string concatenation.
# ---------------------------------------------------------------------------

GEM_SKILL_NAMES: list[str] = [
    "Critical Hit Skill",
    "Mana Leech Skill",
    "Bleeding Skill",
    "Armor Tearing Skill",
    "Poison Skill",
    "Slowing Skill",
]


def _build_skill_names() -> tuple[list[str], list[str]]:
    """Return (gem_skill_names, other_skill_names) from rulesdata."""
    from .rulesdata import GAME_DATA
    gem_set = set(GEM_SKILL_NAMES)
    gem: list[str] = []
    other: list[str] = []
    for skill in GAME_DATA["skills"]:
        name = f"{skill['name']} Skill"
        (gem if name in gem_set else other).append(name)
    return gem, other


def _build_battle_trait_names() -> list[str]:
    from .rulesdata import GAME_DATA
    return [f"{t['name']} Battle Trait" for t in GAME_DATA["battle_traits"]]


def _build_xp_tome_names() -> list[str]:
    return (
        [f"Tattered Scroll #{i+1}" for i in range(32)]
        + [f"Worn Tome #{i+1}" for i in range(6)]
        + [f"Ancient Grimoire #{i+1}" for i in range(2)]
        + [f"Extra XP Item #{i+1}" for i in range(60)]
    )


def _build_shadow_core_names() -> list[str]:
    from .rulesdata import GAME_DATA
    names: list[str] = []
    for sc in GAME_DATA.get("shadow_core_stashes", []):
        names.append(f"{sc['str_id']} Shadow Cores")
    for sc in GAME_DATA.get("extra_shadow_core_stashes", []):
        names.append(sc["name"])
    return names


def _build_talisman_rarity_table() -> dict[str, int]:
    """Map talisman fragment item-name → rarity (parsed from tal_data)."""
    from .rulesdata import GAME_DATA
    table: dict[str, int] = {}
    for frag in GAME_DATA.get("talisman_fragments", []):
        rarity = int(str(frag["tal_data"]).split("/")[1])
        table[f"{frag['str_id']} Talisman Fragment"] = rarity
    for frag in GAME_DATA.get("extra_talisman_fragments", []):
        rarity = int(str(frag["tal_data"]).split("/")[1])
        table[frag["name"]] = rarity
    return table


def _build_talisman_type_sets() -> tuple:
    """Return (edge_names, corner_names) sets parsed from tal_data type field.

    tal_data format: "seed/rarity/type/upgradeLevel" — type matches
    com.giab.games.gcfw.constants.TalismanFragmentType:
        EDGE = 0, CORNER = 1, INNER = 2.
    """
    from .rulesdata import GAME_DATA
    edge: set = set()
    corner: set = set()
    for frag in GAME_DATA.get("talisman_fragments", []):
        type_id = int(str(frag["tal_data"]).split("/")[2])
        name = f"{frag['str_id']} Talisman Fragment"
        if type_id == 0:
            edge.add(name)
        elif type_id == 1:
            corner.add(name)
    for frag in GAME_DATA.get("extra_talisman_fragments", []):
        type_id = int(str(frag["tal_data"]).split("/")[2])
        name = frag["name"]
        if type_id == 0:
            edge.add(name)
        elif type_id == 1:
            corner.add(name)
    return edge, corner


_GEM_SKILL_NAMES, _OTHER_SKILL_NAMES = _build_skill_names()
_BATTLE_TRAIT_NAMES = _build_battle_trait_names()
_XP_TOME_NAMES = _build_xp_tome_names()
_SHADOW_CORE_NAMES = _build_shadow_core_names()
_TALISMAN_RARITY: dict[str, int] = _build_talisman_rarity_table()
EDGE_TALISMAN_NAMES, CORNER_TALISMAN_NAMES = _build_talisman_type_sets()


def _build_matching_talisman_grid() -> tuple:
    """Pick the 9 highest-rarity INNER fragments and assign them to grid
    positions 1..9 (row-major). Returns:
      - GRID: tuple of 9 fragment names indexed by position-1 (so GRID[0]
        is position 1).
      - ROWS: list of 3 frozensets, one per row of the 3x3 grid:
            row 1 = positions {1,2,3} = "icon group 1" (e.g. squares)
            row 2 = positions {4,5,6} = "icon group 2" (e.g. circles)
            row 3 = positions {7,8,9} = "icon group 3" (e.g. triangles)
        A complete row = all 3 fragments of one icon group.
      - COLUMNS: list of 3 frozensets, one per column:
            col 1 = positions {1,4,7} (one from each icon group)
            col 2 = positions {2,5,8}
            col 3 = positions {3,6,9}
        A complete column = the 1st (or 2nd, or 3rd) fragment from each icon.

    Position assignment is by descending rarity, name as tiebreak — same
    selection criterion the user picked. If you want a different layout,
    edit this function and rerun gen_prereqs.py.
    """
    from .rulesdata import GAME_DATA
    inner: list[tuple[str, int]] = []
    for frag in GAME_DATA.get("talisman_fragments", []):
        type_id = int(str(frag["tal_data"]).split("/")[2])
        rarity = int(str(frag["tal_data"]).split("/")[1])
        if type_id == 2:
            inner.append((f"{frag['str_id']} Talisman Fragment", rarity))
    inner.sort(key=lambda x: (-x[1], x[0]))
    grid = tuple(name for name, _ in inner[:9])
    if len(grid) < 9:
        raise RuntimeError(
            f"Need 9 INNER fragments, only found {len(grid)}"
        )
    rows = [
        frozenset({grid[0], grid[1], grid[2]}),  # positions 1,2,3 — icon 1
        frozenset({grid[3], grid[4], grid[5]}),  # positions 4,5,6 — icon 2
        frozenset({grid[6], grid[7], grid[8]}),  # positions 7,8,9 — icon 3
    ]
    columns = [
        frozenset({grid[0], grid[3], grid[6]}),  # positions 1,4,7
        frozenset({grid[1], grid[4], grid[7]}),  # positions 2,5,8
        frozenset({grid[2], grid[5], grid[8]}),  # positions 3,6,9
    ]
    return grid, rows, columns


_MATCHING_TALISMAN_GRID, MATCHING_TALISMAN_ROWS, MATCHING_TALISMAN_COLUMNS = _build_matching_talisman_grid()
MATCHING_TALISMAN_NAMES: frozenset = frozenset(_MATCHING_TALISMAN_GRID)


def _build_progression_corner_edge_names() -> tuple:
    """Pick the 4 highest-rarity CORNER fragments and the 12 highest-rarity
    EDGE fragments from talisman_fragments.  These are the progression-class
    items that gate the talismanCornerFragment / talismanEdgeFragment
    achievement counters (matching the talisman's 25-slot layout: 4 corners
    + 12 edges + 9 inner = 25).  Mirrors the inner-grid selection above:
    sort by descending rarity, name as tiebreak, take the top N."""
    from .rulesdata import GAME_DATA
    corner: list[tuple[str, int]] = []
    edge: list[tuple[str, int]] = []
    for frag in GAME_DATA.get("talisman_fragments", []):
        parts = str(frag["tal_data"]).split("/")
        rarity = int(parts[1])
        type_id = int(parts[2])
        name = f"{frag['str_id']} Talisman Fragment"
        if type_id == 0:
            edge.append((name, rarity))
        elif type_id == 1:
            corner.append((name, rarity))
    corner.sort(key=lambda x: (-x[1], x[0]))
    edge.sort(key=lambda x: (-x[1], x[0]))
    if len(corner) < 4:
        raise RuntimeError(f"Need 4 CORNER fragments, only found {len(corner)}")
    if len(edge) < 12:
        raise RuntimeError(f"Need 12 EDGE fragments, only found {len(edge)}")
    return (
        frozenset(name for name, _ in corner[:4]),
        frozenset(name for name, _ in edge[:12]),
    )


PROGRESSION_CORNER_TALISMAN_NAMES, PROGRESSION_EDGE_TALISMAN_NAMES = _build_progression_corner_edge_names()

# Union of all 25 progression talisman fragments (4 corner + 12 edge + 9 inner).
# Matches the talisman's full slot layout in the game.  Used by the
# talismanFragments:N gate.
PROGRESSION_ALL_TALISMAN_NAMES: frozenset = (
    PROGRESSION_CORNER_TALISMAN_NAMES
    | PROGRESSION_EDGE_TALISMAN_NAMES
    | MATCHING_TALISMAN_NAMES
)


def build_weight_map(xp_per_tome_average: float = 1.0) -> dict[str, float]:
    """Build item-name → power-per-item map for a specific xp_per_tome_average.

    Cached on the world via build_weight_map_for_world(); call this directly
    only when you need a one-off (e.g. tests / calibration).
    """
    weights: dict[str, float] = {}

    # SP bundles — bundle size baked into the weight.
    for size in range(1, 11):
        weights[f"Skillpoint Bundle {size}"] = WEIGHT_SP * size

    for name in _GEM_SKILL_NAMES:
        weights[name] = WEIGHT_GEM_SKILL
    for name in _OTHER_SKILL_NAMES:
        weights[name] = WEIGHT_OTHER_SKILL

    if WEIGHT_BATTLE_TRAIT != 0.0:
        for name in _BATTLE_TRAIT_NAMES:
            weights[name] = WEIGHT_BATTLE_TRAIT

    if WEIGHT_XP_TOME_LEVEL != 0.0 and xp_per_tome_average > 0:
        tome_w = WEIGHT_XP_TOME_LEVEL * xp_per_tome_average
        for name in _XP_TOME_NAMES:
            weights[name] = tome_w

    if WEIGHT_SHADOW_CORE_ITEM != 0.0:
        for name in _SHADOW_CORE_NAMES:
            weights[name] = WEIGHT_SHADOW_CORE_ITEM

    if WEIGHT_TALISMAN_DIVISOR > 0:
        for name, rarity in _TALISMAN_RARITY.items():
            weights[name] = rarity / WEIGHT_TALISMAN_DIVISOR

    # Gempouches — both forms get the same weight. Items are always declared
    # in the table (see items.py); only ones in the actual pool will appear in
    # state.prog_items, so we can list them all unconditionally.
    if WEIGHT_GEMPOUCH != 0.0:
        from .rulesdata import GEM_POUCH_PLAY_ORDER
        for prefix in GEM_POUCH_PLAY_ORDER:
            weights[f"Gempouch ({prefix})"] = WEIGHT_GEMPOUCH
        weights["Progressive Gempouch"] = WEIGHT_GEMPOUCH

    return weights


def build_weight_map_for_world(world: "GemcraftFrostbornWrathWorld") -> dict[str, float]:
    """Build (and cache on the world) the weight map for this world's options."""
    cached = getattr(world, "_gcfw_power_weights", None)
    if cached is not None:
        return cached
    xp_target = getattr(world.options.xp_tome_bonus, "value", 100)
    xp_per_tome_avg = max(1.0, xp_target / 40.0)
    weights = build_weight_map(xp_per_tome_avg)
    world._gcfw_power_weights = weights
    return weights


def compute_player_power(state: "CollectionState", player: int,
                         weight_map: dict[str, float]) -> float:
    """Compute the current player's power by walking only the items the
    player has (state.prog_items[player]) instead of the full master lists.
    With ~50-200 items typically held, this is ~10x faster per call than
    iterating the static name lists.
    """
    counter = state.prog_items.get(player)
    if not counter:
        return 0.0
    power = 0.0
    for name, count in counter.items():
        w = weight_map.get(name)
        if w:
            power += w * count
    return power


def power_scale(world: "GemcraftFrostbornWrathWorld") -> float:
    """Return the per-world threshold multiplier from the PowerScale option."""
    return world.options.power_scale.value / 100.0


def required_achievement_power(ach_data: dict) -> int:
    """Required power to reach an achievement location.

    Power gating is opt-in: an achievement needs power only if it has an
    explicit `required_power` field in rulesdata_achievements.py. Effort
    labels are unrelated to power — they're a time-investment filter only.
    """
    explicit = ach_data.get("required_power")
    if explicit is not None:
        return int(explicit)
    return 0


def has_power(state: "CollectionState", world: "GemcraftFrostbornWrathWorld",
              required: int, weight_map: dict[str, float] = None) -> bool:
    """True when the player's current power meets the (scaled) requirement.

    `weight_map` should be the per-world map from build_weight_map_for_world();
    pass it in so we don't re-resolve it for every fill-time check. If omitted
    we fetch from the cache (still O(1) but adds a getattr + branch).
    """
    if required <= 0:
        return True
    if weight_map is None:
        weight_map = build_weight_map_for_world(world)
    threshold = required * power_scale(world)
    return compute_player_power(state, world.player, weight_map) >= threshold

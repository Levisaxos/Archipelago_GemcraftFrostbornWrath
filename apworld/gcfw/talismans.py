"""
Talisman shape / grid constants derived from rulesdata.

Builds, at import time, the static name sets that other modules use to
classify talisman fragments by their slot type (edge / corner / inner) and
to count complete rows / columns of the matching 3x3 grid.

  tal_data format: "seed/rarity/type/upgradeLevel" — type matches
  com.giab.games.gcfw.constants.TalismanFragmentType:
      EDGE = 0, CORNER = 1, INNER = 2.
"""

from __future__ import annotations


def _build_talisman_type_sets() -> tuple:
    """Return (edge_names, corner_names) sets parsed from tal_data type field."""
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

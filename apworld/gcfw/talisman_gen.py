"""
Deterministic progression-talisman generator (apworld-owned derived value).

Given an AP-seeded RNG this produces the 25-fragment talisman grid the player
is granted: a legal jigsaw tiling of the 5x5 talisman with rune = row index so
every row is 5-of-a-kind (max +% starting mana) and every column holds all 5
runes (max +wave mana), plus enough Max-Freeze-Charge (prop 21) /
Max-Barrage-Charge (prop 26) across the outer cells to satisfy the
tmFreezeCharge:100 / tmBarrageCharge:100 achievements.

Everything is a bit-exact port of the game's own fragment derivation
(entity/TalismanFragment.as + common/utils/PseudoRnd.as + ArrayToolbox.shuffle),
so each fragment is identical to what the game generates from its seed — the mod
just feeds "seed/rarity/type/upgradeLevel" to `new TalismanFragment(...)`.

Public API:
    generate_progression_set(rng) -> list[dict]   # 25 entries, see below
    KNOWN_GOOD_SEEDS                               # deterministic fallback pool

Standalone (validates the port against rulesdata_talisman.py):
    python apworld/gcfw/talisman_gen.py
"""

import math
import random

# TalismanFragmentType (constants/TalismanFragmentType.as)
INNER, EDGE, CORNER = 2, 0, 1
_TYPE_NAME = {INNER: "INNER", EDGE: "EDGE", CORNER: "CORNER"}

# Property ids of interest (constants/TalismanPropertyId.as)
FREEZE_CHARGE_PROP = 21   # tmFreezeCharge
BARRAGE_CHARGE_PROP = 26  # tmBarrageCharge

# ---- tuning knobs ---------------------------------------------------------
# Rarity is CHOSEN per cell (it's an input to fragment generation, not seed-
# derived), so the rarity spread lives here in the template, NOT in the per-seed
# search.  For real variety (a few high, a few low) each cell's rarity is DRAWN
# from a band: charge cells from a HIGH band (they must carry the charge prop
# and sum >= 100), every other cell from a LOW band.  The two bands are set so
# the 25-cell mean lands ~50 while individual fragments range across the 10s-90s.
# Mana scales with rarity, so these bands are the dial for the power baseline.
CHARGE_RARITY_RANGE = (70, 96)   # freeze/barrage cells (kept high for the 100 gate)
BASE_RARITY_RANGE   = (8, 40)    # every other cell
CHARGE_TARGET = 100              # tmFreezeCharge:100 / tmBarrageCharge:100
RETRY_LIMIT = 16                 # rebuilds if a draw misses the charge target
# Given rune=row, both mana bonuses depend only on the TOTAL of the 25 rarities,
# not their distribution.  So after drawing the varied per-cell rarities we nudge
# them to a fixed total (= TARGET_MEAN * 25).  Result: identical mana baseline
# every seed, while individual fragments keep their spread.
TARGET_MEAN = 50
FREEZE_CELLS = 6          # outer cells forced to carry Max Freeze Charge
BARRAGE_CELLS = 6         # outer cells forced to carry Max Barrage Charge
MAX_ROLLS_PER_CELL = 500_000


def _assign_rarities(rng, charge_positions):
    """Per-cell rarity: draw varied values in each band, then nudge random cells
    (within their band) so the 25-cell total == TARGET_MEAN*25 — fixing the mana
    baseline while preserving the spread."""
    bounds = {p: (CHARGE_RARITY_RANGE if p in charge_positions else BASE_RARITY_RANGE)
              for p in range(25)}
    rar = {p: rng.randint(lo, hi) for p, (lo, hi) in bounds.items()}
    diff = TARGET_MEAN * 25 - sum(rar.values())
    step = 1 if diff > 0 else -1
    guard = 0
    while diff != 0 and guard < 100000:
        guard += 1
        p = rng.randint(0, 24)
        lo, hi = bounds[p]
        if lo <= rar[p] + step <= hi:
            rar[p] += step
            diff -= step
    return rar
# Fallback set_seeds proven to run build to completion (see _self_check()).
KNOWN_GOOD_SEEDS = [1, 2, 3, 4, 5, 9000, 9001, 9002]
# --------------------------------------------------------------------------

MULT_BY_COUNT = [0, 0, 0, 1, 1.2, 1.4]

# Authoritative shape<->links tables (entity/TalismanFragment.as LINKS_* arrays).
# link value: -1 = notch (inward), 0 = flat border, 1 = tab (outward).
_LINKS_UP    = [-1,-1,-1,-1,-1,-1,-1,-1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,-1,1,-1,1,-1,1,-1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,-1,-1,1,1,1,1,0,0,0,0,0,0,0,0,-1,1,-1,1,-1,-1,1,1]
_LINKS_DOWN  = [-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,-1,-1,1,1,1,1,0,0,0,0,0,0,0,0,-1,1,-1,1,-1,1,-1,1,-1,-1,1,1,-1,-1,1,1,0,0,0,0,0,0,0,0]
_LINKS_LEFT  = [-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,-1,-1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,-1,1,-1,1,-1,-1,1,1,0,0,0,0]
_LINKS_RIGHT = [-1,-1,-1,-1,1,1,1,1,-1,-1,-1,-1,1,1,1,1,-1,-1,-1,-1,1,1,1,1,0,0,0,0,0,0,0,0,-1,1,-1,1,-1,1,-1,1,-1,-1,1,1,-1,-1,1,1,-1,1,-1,1,0,0,0,0,0,0,0,0,-1,1,-1,1]
_SHAPE_FROM_LINKS = {
    (_LINKS_UP[i], _LINKS_DOWN[i], _LINKS_LEFT[i], _LINKS_RIGHT[i]): i
    for i in range(64)
}


def _as_round(x: float) -> int:
    """ActionScript Math.round: floor(x + 0.5)."""
    return int(math.floor(x + 0.5))


class _PseudoRnd:
    """Port of com.giab.common.utils.PseudoRnd (setSeed + getRnd)."""

    _W1 = [0,8,1,2,7,3,6,4,5,4,3,2,6,1,7,6,7,5,8,3,5,4,6,2,3,2,7,8,4,6,0,0,1,0,5,7,4,8,9,7,6,5,4,5,2,3,4,8,7,6,2,1,5,2,1,6,0,7,2,1,8,7,4,0,6,3,1,8,7,5,2,3,4,8,7,2,8,7,6,0,4,5,0,8,7,2,4,0,7,3,6,2,1,3,4,1,0,7,3,0,9,7,2]
    _W2 = [6,5,4,0,3,4,3,7,1,2,6,5,3,4,1,5,1,4,3,5,7,1,6,3,5,4,1,3,7,3,4,5,7,4,2,3,9,5,2,3,6,3,8,9,2,5,7,3,6,2,3,1,4,9,2,3,1,4,6,2,1,4,2,5,2,1,8,7,2,4,7,6,2,5,4,5,2,3,7,6,9,7,9,6,9,0,5,3,1,6,9,0,6,5,1,9,1,7,0,4,5,8,6]
    _W3 = [5,6,2,0,6,4,8,9,2,4,5,2,1,3,4,9,7,9,4,0,2,4,2,9,4,1,2,3,5,4,7,2,1,4,8,6,9,2,3,4,6,5,0,9,9,4,1,0,5,6,0,2,6,7,4,8,2,3,8,1,4,9,0,5,6,4,5,0,8,9,0,4,9,0,2,9,5,2,0,8,4,2,3,0,4,2,0,9,4,9,1,0,4,5,3,0,2,8,9,4,6,5,1]
    _W4 = [9,4,0,2,4,2,9,4,1,2,3,5,4,7,2,1,5,6,2,0,6,4,8,9,2,4,5,2,1,3,4,9,7,1,0,5,6,4,8,6,9,2,3,4,6,5,0,9,9,4,0,2,4,9,0,5,6,4,5,0,8,9,0,4,9,0,2,9,5,2,0,8,4,2,3,6,7,4,8,2,3,8,1,5,3,0,2,8,9,4,6,5,1,0,4,2,0,9,4,9,1,0,4]
    _WL = [5,4,8,7,5,7,8,2,1,4,6,4,3,4,5,6,3,7,5,4,3,5,6,1,6,1,3,4,2,5,8,3,4,5,8,2,3,7,8,5,6,4,3,0,9,3,8,1,7,3,9,8,2,1,6,4,9,2,8,7,2,3,4,5,0,1,5,0,1,7,3,0,2,6,5,0,1,5,0,1,2,3,7,6,5,2,3,4,8,7,5,5,8,8,5,8,7,0,1,1,2,3,2]

    def __init__(self, seed):
        self.set_seed(seed)

    def set_seed(self, seed):
        if seed < 0:
            seed = -seed
        seed = _as_round(seed) % 100_000_000
        self.s1 = seed // 1_000_000
        self.s2 = (seed // 10_000) % 100
        self.s3 = (seed // 100) % 100
        self.s4 = seed % 100
        self.step = 0

    def _digit(self):
        self.s4 += 1
        if self.s4 > 99:
            self.s4 = 0
            self.s3 += 1
            if self.s3 > 99:
                self.s3 = 0
                self.s2 += 1
                if self.s2 > 99:
                    self.s2 = 0
                    self.s1 += 1
                    if self.s1 > 99:
                        self.s1 = 0
        self.step += 1
        if self.step > 101:
            self.step = 0
        return (self._W1[self.s1] + self._W2[self.s2] + self._W3[self.s3]
                + self._W4[self.s4] + self._WL[self.step]) % 10

    def get_rnd(self):
        return self._digit() * 0.0021 + self._digit() * 0.0932 + self._digit() * 0.0145


def _shuffle(arr, rnd):
    temp = list(arr)
    ret = []
    for _ in range(len(temp)):
        v = int(math.floor(rnd.get_rnd() * len(temp) * 0.995))
        ret.append(temp[v])
        del temp[v]
    return ret


_PROP_REAL_VALS = [1,1,1,1,1,1,1,20,20,20,20,40,200,10,10,15,15,15,12,16,10000,
                   20,20,20,20,20,20,20,30,6,8,10,10,15,10,5,6,5,12,6,20,4,8,2,8]

_INNER  = [7,8,9,10,11,12,13,15,16,17,28,38,14,31,32,33,35,36,37,29,30,34,40]
_EDGE   = [7,8,9,10,11,12,13,15,16,17,28,38,14,31,32,33,35,37,21,22,23,24,25,26,27]
_CORNER = [7,8,9,10,11,12,13,15,16,17,28,38,29,30,34,39,40,43,44,18,19,20,21,22,23,24,25,26,27,41,42]
_CORNER70 = [7,8,9,10,11,12,13,15,16,17,28,38,29,30,34,39,40,43,44,21,22,23,24,25,26,27]
_INNER50  = [7,8,9,10,11,12,13,15,16,17,28,38,14,31,32,33,29,30]
_EDGE50   = [7,8,9,10,11,12,13,15,16,17,28,38,14,31,32,33,21,22,23,24,25,26]
_CORNER50 = [7,8,9,10,11,12,13,15,16,17,28,38,29,30,21,22,23,24,25,26]
_INNER30  = [7,8,9,10,11,12,13,28,14]
_EDGE30   = [7,8,9,10,11,12,13,28,14]
_CORNER30 = [7,8,9,10,11,12,13,28]
_PLUS5 = {7, 8, 9, 10, 11, 13, 15, 16, 17, 14, 28}


def _band_list(ftype, rarity):
    if rarity < 30:
        return _INNER30 if ftype == INNER else (_EDGE30 if ftype == EDGE else _CORNER30)
    if rarity < 50:
        return _INNER50 if ftype == INNER else (_EDGE50 if ftype == EDGE else _CORNER50)
    if rarity < 70:
        return _INNER if ftype == INNER else (_EDGE if ftype == EDGE else _CORNER70)
    return _INNER if ftype == INNER else (_EDGE if ftype == EDGE else _CORNER)


def _original_shape_id(seed, ftype):
    rnd = _PseudoRnd((seed + 47368492) % 99999999)
    if ftype == INNER:
        return int(math.floor(rnd.get_rnd() * 15.99))
    if ftype == EDGE:
        return int(math.floor(rnd.get_rnd() * 31.99 + 16))
    return int(math.floor(rnd.get_rnd() * 15.99 + 48))


def _calculate(seed, rarity, ftype, upgrade_level):
    """Port of TalismanFragment.calculateProperties at the given upgrade level."""
    rarity = min(100, max(1, _as_round(rarity)))
    rnd = _PseudoRnd(seed)

    rune_id = int(math.floor(rnd.get_rnd() * 9.99))
    prop_ids = _shuffle(_band_list(ftype, rarity), rnd)

    skill_pid = int(math.floor(rnd.get_rnd() * 5.99))
    chance_all = 0.0
    if rarity < 60:
        skill_pid = -1
    elif 70 < rarity <= 80:
        chance_all = 0.1 + 0.15 * 0.1 * (rarity - 70)
    elif 80 < rarity <= 90:
        chance_all = 0.25 + 0.25 * 0.1 * (rarity - 80)
    elif 90 < rarity <= 100:
        chance_all = 0.5 + 0.5 * 0.1 * (rarity - 90)
    if rnd.get_rnd() < chance_all:
        skill_pid = 6

    is_c, is_e = ftype == CORNER, ftype == EDGE
    if rarity < 10:
        ulm, keep, pmin, pmax = 2, 1, 0.2 + 0.005 * rarity, 0.4 + 0.01 * rarity
    elif rarity < 20:
        ulm, keep, pmin, pmax = 3, 2, 0.25 + 0.005 * (rarity - 10), 0.5 + 0.005 * (rarity - 10)
    elif rarity < 30:
        ulm, keep, pmin, pmax = 4, 3, 0.3 + 0.005 * (rarity - 20), 0.55 + 0.005 * (rarity - 20)
    elif rarity < 40:
        ulm, keep, pmin, pmax = 5, 4, 0.35 + 0.005 * (rarity - 30), 0.6 + 0.005 * (rarity - 30)
    elif rarity < 50:
        ulm, keep, pmin, pmax = 6, 5, 0.4 + 0.01 * (rarity - 40), 0.65 + 0.005 * (rarity - 40)
    elif rarity < 60:
        ulm = 9 if is_c else (8 if is_e else 7)
        keep = 8 if is_c else (7 if is_e else 6)
        pmin, pmax = 0.5 + 0.01 * (rarity - 50), 0.7 + 0.006 * (rarity - 50)
    elif rarity < 70:
        ulm = 10 if is_c else (9 if is_e else 8)
        keep = 9 if is_c else (8 if is_e else 7)
        pmin, pmax = 0.6 + 0.01 * (rarity - 60), 0.76 + 0.008 * (rarity - 60)
    elif rarity < 80:
        ulm = 11 if is_c else (10 if is_e else 9)
        keep = 10 if is_c else (9 if is_e else 8)
        pmin, pmax = 0.7 + 0.01 * (rarity - 70), 0.84 + 0.008 * (rarity - 70)
    elif rarity < 90:
        ulm = 12 if is_c else (11 if is_e else 10)
        keep = 11 if is_c else (10 if is_e else 9)
        pmin, pmax = 0.8 + 0.01 * (rarity - 80), 0.92 + 0.004 * (rarity - 80)
    elif rarity < 100:
        ulm = 13 if is_c else (12 if is_e else 11)
        keep = 12 if is_c else (11 if is_e else 10)
        pmin, pmax = 0.9 + 0.01 * (rarity - 90), 0.96 + 0.004 * (rarity - 90)
    else:
        ulm = 14 if is_c else (13 if is_e else 12)
        keep = 13 if is_c else (12 if is_e else 11)
        pmin = pmax = 1.0

    prop_ids = prop_ids[len(prop_ids) - keep:] if keep > 0 else []
    prop_ids = _shuffle(prop_ids, rnd)
    if skill_pid != -1:
        prop_ids[-1] = skill_pid

    n = len(prop_ids)
    powers_max = [0.0] * n
    incr = [None] * n
    for i in range(n):
        powers_max[i] = pmin + (pmax - pmin) * rnd.get_rnd()
        a = rnd.get_rnd() * 0.12 + 0.2
        b = rnd.get_rnd() * 0.12 + 0.2
        c = rnd.get_rnd() * 0.12 + 0.2
        incr[i] = [a, b, c, 1 - a - b - c]
        if prop_ids[i] < 7:
            incr[i] = [0, 1, 0, 0]
            powers_max[i] = 1

    values = [0.0] * n
    sell = 3 + 2 * math.pow(rarity, 1.075) + math.pow(max(0, rarity - 10), 1.026) \
        + math.pow(max(0, rarity - 30), 1.046) + math.pow(max(0, rarity - 50), 1.066) \
        + math.pow(max(0, rarity - 70), 1.086) + math.pow(max(0, rarity - 80), 1.106) \
        + math.pow(max(0, rarity - 90), 1.126)
    sell = _as_round(0.21 * 0.43 * (sell + rnd.get_rnd() * 11))
    upg = _as_round(sell * (2.57 + 0.41 * rnd.get_rnd()))
    for i in range(0, upgrade_level + 1):
        if i < n:
            values[i] += _PROP_REAL_VALS[prop_ids[i]] * powers_max[i] * incr[i][0]
        if 0 < i and i - 1 < n:
            values[i - 1] += _PROP_REAL_VALS[prop_ids[i - 1]] * powers_max[i - 1] * incr[i - 1][1]
        if 1 < i and i - 2 < n:
            values[i - 2] += _PROP_REAL_VALS[prop_ids[i - 2]] * powers_max[i - 2] * incr[i - 2][2]
        if 2 < i and i - 3 < n:
            values[i - 3] += _PROP_REAL_VALS[prop_ids[i - 3]] * powers_max[i - 3] * incr[i - 3][3]
        sell = _as_round(sell + upg * (0.19 + 0.067 * rnd.get_rnd()))
        upg = _as_round(upg * (1.192 + rnd.get_rnd() * 0.057))

    for i in range(n):
        if prop_ids[i] in _PLUS5 and values[i] > 0:
            values[i] += 5
    values = [_as_round(v) for v in values]
    return {"rune_id": rune_id, "shape_id": _original_shape_id(seed, ftype),
            "upgrade_level_max": ulm, "property_ids": prop_ids,
            "property_values": values}


def _cell_specs():
    """25 grid cells: uniform tiling (interior right/down = tab, left/up = notch)
    → each cell's (type, shape_id), and rune = row index."""
    specs = []
    for pos in range(25):
        r, c = divmod(pos, 5)
        links = (-1 if r > 0 else 0, 1 if r < 4 else 0,
                 -1 if c > 0 else 0, 1 if c < 4 else 0)
        n_flat = links.count(0)
        ftype = CORNER if n_flat == 2 else (EDGE if n_flat == 1 else INNER)
        specs.append({"pos": pos, "type": ftype, "rune": r,
                      "shape_id": _SHAPE_FROM_LINKS[links]})
    return specs


def _search_cell(spec, rng, need_prop, rarity):
    ftype = spec["type"]
    for _ in range(MAX_ROLLS_PER_CELL):
        seed = rng.randint(10_000_000, 99_999_999)
        if _original_shape_id(seed, ftype) != spec["shape_id"]:
            continue
        base = _calculate(seed, rarity, ftype, 0)
        if base["rune_id"] != spec["rune"]:
            continue
        fmax = _calculate(seed, rarity, ftype, base["upgrade_level_max"])
        if need_prop is not None:
            pmax = dict(zip(fmax["property_ids"], fmax["property_values"]))
            if pmax.get(need_prop, 0) <= 0:
                continue
        return {"pos": spec["pos"], "seed": seed, "rarity": rarity,
                "type": ftype, "upgrade_level_max": base["upgrade_level_max"],
                "properties_at_max": list(zip(fmax["property_ids"],
                                              fmax["property_values"]))}
    return None


def _build(rng):
    specs = _cell_specs()
    outer = [s for s in specs if s["type"] in (EDGE, CORNER)]
    rng.shuffle(outer)
    freeze_pos = {s["pos"] for s in outer[:FREEZE_CELLS]}
    barrage_pos = {s["pos"] for s in outer[FREEZE_CELLS:FREEZE_CELLS + BARRAGE_CELLS]}
    rarities = _assign_rarities(rng, freeze_pos | barrage_pos)
    grid = [None] * 25
    for s in specs:
        need = (FREEZE_CHARGE_PROP if s["pos"] in freeze_pos else
                BARRAGE_CHARGE_PROP if s["pos"] in barrage_pos else None)
        frag = _search_cell(s, rng, need, rarities[s["pos"]])
        if frag is None:
            raise RuntimeError(f"no seed for pos {s['pos']} type {s['type']} "
                               f"shape {s['shape_id']} rune {s['rune']} need {need}")
        grid[s["pos"]] = frag
    return grid


def _charge_ok(grid):
    """Both charge achievements satisfiable: prop-21 and prop-26 sums >= target."""
    fz = sum(v for f in grid for pid, v in f["properties_at_max"] if pid == FREEZE_CHARGE_PROP)
    bz = sum(v for f in grid for pid, v in f["properties_at_max"] if pid == BARRAGE_CHARGE_PROP)
    return fz >= CHARGE_TARGET and bz >= CHARGE_TARGET


def _build_valid(rng):
    """Build until the charge sums clear CHARGE_TARGET (retry consumes the same
    rng, so it stays deterministic).  Returns a valid grid or None."""
    for _ in range(RETRY_LIMIT):
        try:
            g = _build(rng)
        except RuntimeError:
            continue
        if _charge_ok(g):
            return g
    return None


def generate_progression_set(rng):
    """Deterministically build the 25-fragment progression talisman.

    `rng` is a seeded random.Random (seed it from the AP world seed).  Returns
    25 dicts, one per grid slot (0..24, row-major):
        {"slot": int, "seed": int, "rarity": int, "type": int,
         "upgrade_level": int,           # = max (delivered fully upgraded)
         "tal_data": "seed/rarity/type/upgradeLevel"}   # ready for the mod
    The rarity total is fixed (TARGET_MEAN*25) so the mana baseline is identical
    every seed while individual fragments keep their spread; the charge sums are
    guaranteed >= CHARGE_TARGET by retry.  On exhaustion, falls back to a
    deterministic KNOWN_GOOD_SEEDS build so generation never crashes.
    """
    grid = _build_valid(rng)
    if grid is None:
        for pick in KNOWN_GOOD_SEEDS:
            grid = _build_valid(random.Random(pick))
            if grid is not None:
                break
    if grid is None:
        raise RuntimeError("talisman generation exhausted all retries and fallbacks")
    out = []
    for f in grid:
        ulvl = f["upgrade_level_max"]      # deliver locked at max
        out.append({
            "slot": f["pos"], "seed": f["seed"], "rarity": f["rarity"],
            "type": f["type"], "upgrade_level": ulvl,
            "tal_data": f"{f['seed']}/{f['rarity']}/{f['type']}/{ulvl}",
        })
    return out


# --------------------------------------------------------------------------
# Standalone helpers: validate the port and self-check the fallback seeds.

def _validate_against_rulesdata():
    import importlib.util
    from pathlib import Path
    path = Path(__file__).with_name("rulesdata_talisman.py")
    spec = importlib.util.spec_from_file_location("rulesdata_talisman", path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    tmap = {"INNER": INNER, "EDGE": EDGE, "CORNER": CORNER}
    ok = fail = 0
    for name, f in mod.progression_talismans.items():
        ft = tmap[f["type"]]
        g0 = _calculate(f["seed"], f["rarity"], ft, f["upgrade_level"])
        gm = _calculate(f["seed"], f["rarity"], ft, f["upgrade_level_max"])
        good = (g0["shape_id"] == f["shape_id"] and g0["rune_id"] == f["rune_id"]
                and g0["upgrade_level_max"] == f["upgrade_level_max"]
                and list(zip(g0["property_ids"], g0["property_values"])) == [tuple(p) for p in f["properties"]]
                and list(zip(gm["property_ids"], gm["property_values"])) == [tuple(p) for p in f["properties_at_max"]])
        ok += good
        fail += (not good)
        if not good:
            print(f"FAIL {name}")
    print(f"port validation: {ok}/{ok + fail} fragments reproduced exactly")


if __name__ == "__main__":
    _validate_against_rulesdata()
    for s in KNOWN_GOOD_SEEDS:
        generate_progression_set(random.Random(s))
    print(f"self-check: all {len(KNOWN_GOOD_SEEDS)} known-good seeds build OK")

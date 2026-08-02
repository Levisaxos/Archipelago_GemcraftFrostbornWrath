"""
Granularity-aware item-name resolution for stash keys, field tokens, and
gem pouches. Each helper takes a stage str_id and the option value
(int from the corresponding Choice option) and returns the item name that
gates that stage under the chosen granularity.

The companion *_pool functions return the list of item names that should
be added to the multiworld's item pool for the chosen granularity (one
entry per item to create).

Each granularity has a "_progressive" sibling: the pool gets N copies of a
single fungible item name, and the Nth received copy unlocks the Nth entry
in PROGRESSIVE_TILE_ORDER (or per-stage order). Rule gating uses
`state.count(name) >= N` instead of `state.has(name)`, so the same helper
contract (`{X}_for_stage`, `{X}_count_for_stage`) covers both modes.

ID ranges (allocated above existing 1400-1521 stash-stage range):
    1522-1547  stash tile keys                 (26)
    1561       stash master key
    1562-1587  field tile tokens               (26)
    1614       gem pouch master
    1616       field token per-stage progressive  (122 copies)
    1617       field token per-tile progressive   (26 copies)
    1619       stash key per-stage progressive    (122 copies)
    1620       stash key per-tile progressive     (26 copies)
"""

from __future__ import annotations

from typing import List

from .rulesdata import GAME_DATA, PROGRESSIVE_TILE_ORDER, STAGE_RULES


# Granularity option int values — keep in sync with options.py Choice values.
FIELD_PER_STAGE             = 0
FIELD_PER_STAGE_PROGRESSIVE = 1
FIELD_PER_TILE              = 2
FIELD_PER_TILE_PROGRESSIVE  = 3

# per_stage retired — stash keys can no longer be per-stage. Values are
# contiguous and mirror the gem-pouch encoding below; the mod decodes the same
# ints (data/ServerOptions.as, FieldLogicEvaluator.as, McSlotSettings.as).
STASH_OFF                   = 0
STASH_PER_TILE              = 1
STASH_PER_TILE_PROGRESSIVE  = 2
STASH_GLOBAL                = 5

POUCH_OFF                  = 0
POUCH_PER_TILE             = 1
POUCH_PER_TILE_PROGRESSIVE = 2
POUCH_GLOBAL               = 5


# Active tile prefixes in play order (W, S, V, R, ...). See PROGRESSIVE_TILE_ORDER
# in rulesdata.py for the canonical ordering.
TILE_PREFIXES: List[str] = list(PROGRESSIVE_TILE_ORDER)

# Per-stage progressive unlock order: walk PROGRESSIVE_TILE_ORDER, within each
# tile take stages in alphabetical str_id order. The Nth received copy of
# "Progressive Field Token (per-stage)" / "Progressive Stash Stage Key" unlocks
# the stage at this position.
def _build_stage_progressive_order() -> List[str]:
    out: List[str] = []
    for prefix in TILE_PREFIXES:
        out.extend(sorted(
            s["str_id"] for s in GAME_DATA["stages"] if s["str_id"][0] == prefix
        ))
    return out


STAGE_PROGRESSIVE_ORDER: List[str] = _build_stage_progressive_order()


# ID assignments for coarse items.
def _tile_index(prefix: str) -> int:
    return TILE_PREFIXES.index(prefix)


STASH_TILE_KEY_BASE   = 1522
STASH_MASTER_KEY_ID   = 1561
FIELD_TILE_TOKEN_BASE = 1562
POUCH_MASTER_ID       = 1614

FIELD_PER_STAGE_PROGRESSIVE_ID = 1616
FIELD_PER_TILE_PROGRESSIVE_ID  = 1617
STASH_PER_STAGE_PROGRESSIVE_ID = 1619
STASH_PER_TILE_PROGRESSIVE_ID  = 1620


# Singleton progressive item names. Singular for all stages — the count-based
# rule gates which Nth copy is required for which stage.
PROG_GEMPOUCH_PER_TILE_NAME    = "Progressive Gempouch"             # existing
PROG_FIELD_PER_STAGE_NAME      = "Progressive Field Token (per-stage)"
PROG_FIELD_PER_TILE_NAME       = "Progressive Field Token (per-tile)"
PROG_STASH_PER_STAGE_NAME      = "Progressive Stash Stage Key"
PROG_STASH_PER_TILE_NAME       = "Progressive Stash Tile Key"


def stash_tile_key_id(prefix: str) -> int:
    return STASH_TILE_KEY_BASE + _tile_index(prefix)


def field_tile_token_id(prefix: str) -> int:
    return FIELD_TILE_TOKEN_BASE + _tile_index(prefix)


# ----------------------------------------------------------------------- #
# Stash keys
# ----------------------------------------------------------------------- #
def stash_key_for_stage(sid: str, granularity: int) -> str | None:
    """Item name whose presence (state.count >= stash_key_count_for_stage)
    unlocks `sid`'s wizard stash check under the chosen granularity. Returns
    None when granularity is STASH_OFF — callers must treat the gate as
    unconditionally satisfied."""
    if granularity == STASH_OFF:
        return None
    if granularity == STASH_PER_TILE:
        return f"Wizard Stash Tile {sid[0]} Key"
    if granularity == STASH_PER_TILE_PROGRESSIVE:
        return PROG_STASH_PER_TILE_NAME
    if granularity == STASH_GLOBAL:
        return "Wizard Stash Master Key"
    raise ValueError(f"Unknown stash_key_granularity: {granularity}")


def stash_key_count_for_stage(sid: str, granularity: int, starter_sid: str = None) -> int:
    """Number of copies of `stash_key_for_stage(sid, granularity)` required to
    unlock `sid`'s stash. 1 for distinct/global, N=position-in-starter-aware-
    order for progressive variants, 0 for STASH_OFF (no gate)."""
    if granularity == STASH_OFF:
        return 0
    if granularity == STASH_PER_TILE_PROGRESSIVE:
        order = (progressive_tile_order_for_starter(starter_sid)
                 if starter_sid is not None else TILE_PREFIXES)
        return order.index(sid[0]) + 1
    return 1


def stash_keys_for_pool(granularity: int) -> List[str]:
    if granularity == STASH_OFF:
        return []
    if granularity == STASH_PER_TILE:
        return [f"Wizard Stash Tile {p} Key" for p in TILE_PREFIXES]
    if granularity == STASH_PER_TILE_PROGRESSIVE:
        return [PROG_STASH_PER_TILE_NAME] * len(TILE_PREFIXES)
    if granularity == STASH_GLOBAL:
        return ["Wizard Stash Master Key"]
    raise ValueError(f"Unknown stash_key_granularity: {granularity}")


# ----------------------------------------------------------------------- #
# Field tokens
# ----------------------------------------------------------------------- #
def field_token_for_stage(sid: str, granularity: int) -> str:
    """Item name that gates entry to `sid`. For progressive variants the
    same singleton name is returned for every stage in the same group;
    field_token_count_for_stage gives the count threshold."""
    if granularity == FIELD_PER_STAGE:
        return f"{sid} Field Token"
    if granularity == FIELD_PER_STAGE_PROGRESSIVE:
        return PROG_FIELD_PER_STAGE_NAME
    if granularity == FIELD_PER_TILE:
        return f"{sid[0]} Tile Field Token"
    if granularity == FIELD_PER_TILE_PROGRESSIVE:
        return PROG_FIELD_PER_TILE_NAME
    raise ValueError(f"Unknown field_token_granularity: {granularity}")


def _starter_set(starter) -> set:
    """Normalize a single starter sid, an iterable of sids, or None into a set."""
    if starter is None:
        return set()
    if isinstance(starter, str):
        return {starter}
    return set(starter)


def field_token_count_for_stage(sid: str, granularity: int, starter=None) -> int:
    """Number of copies of `field_token_for_stage(sid, granularity)` required
    to unlock `sid`. 1 for distinct, N=position-in-starter-aware-order for
    progressive. With a set of starters the chosen groups are fronted to
    positions 0..N-1, so each starter's count matches its precollected copies."""
    if granularity == FIELD_PER_STAGE_PROGRESSIVE:
        order = (progressive_stage_order_for_starter(starter)
                 if starter is not None else STAGE_PROGRESSIVE_ORDER)
        return order.index(sid) + 1
    if granularity == FIELD_PER_TILE_PROGRESSIVE:
        order = (progressive_tile_order_for_starter(starter)
                 if starter is not None else TILE_PREFIXES)
        return order.index(sid[0]) + 1
    return 1


def field_tokens_for_pool(granularity: int, exclude_starters) -> List[str]:
    """Field-token items to add to the pool, omitting the item(s) covering the
    chosen starter group(s) (precollected instead). `exclude_starters` may be a
    single sid or a set of them. Progressive pools shrink by the number of
    precollected copies so item/location counts stay balanced."""
    excl = _starter_set(exclude_starters)
    if granularity == FIELD_PER_STAGE:
        return [
            f"{s['str_id']} Field Token"
            for s in GAME_DATA["stages"]
            if s["str_id"] not in excl
        ]
    if granularity == FIELD_PER_STAGE_PROGRESSIVE:
        return [PROG_FIELD_PER_STAGE_NAME] * (len(STAGE_PROGRESSIVE_ORDER) - len(excl))
    if granularity == FIELD_PER_TILE:
        prefixes = {s[0] for s in excl}
        return [f"{p} Tile Field Token" for p in TILE_PREFIXES if p not in prefixes]
    if granularity == FIELD_PER_TILE_PROGRESSIVE:
        prefixes = {s[0] for s in excl}
        return [PROG_FIELD_PER_TILE_NAME] * (len(TILE_PREFIXES) - len(prefixes))
    raise ValueError(f"Unknown field_token_granularity: {granularity}")


def starter_field_tokens_to_precollect(starter, granularity: int) -> List[str]:
    """Items to precollect so the starter group(s) are reachable from frame 0.
    `starter` may be a single sid or a set. Progressive variants precollect one
    copy per distinct starter group (the unlock order fronts those groups)."""
    starters = _starter_set(starter)
    if granularity == FIELD_PER_STAGE:
        return [f"{s} Field Token" for s in sorted(starters)]
    if granularity == FIELD_PER_STAGE_PROGRESSIVE:
        return [PROG_FIELD_PER_STAGE_NAME] * len(starters)
    if granularity == FIELD_PER_TILE:
        prefixes = {s[0] for s in starters}
        return [f"{p} Tile Field Token" for p in sorted(prefixes)]
    if granularity == FIELD_PER_TILE_PROGRESSIVE:
        prefixes = {s[0] for s in starters}
        return [PROG_FIELD_PER_TILE_NAME] * len(prefixes)
    raise ValueError(f"Unknown field_token_granularity: {granularity}")


def starter_field_token(sid: str, granularity: int) -> str:
    """Legacy single-item helper kept for callers that only ever see distinct
    granularities. For progressive variants prefer
    starter_field_tokens_to_precollect, which returns the full M-copy list."""
    return field_token_for_stage(sid, granularity)


def progressive_tile_order_for_starter(starter) -> List[str]:
    """Starter-first reordering of TILE_PREFIXES for progressive count
    thresholds. The chosen starter tiles are fronted (positions 0..k-1) in
    canonical order; the rest follow. `starter` may be a single sid or a set."""
    prefixes = {s[0] for s in _starter_set(starter)}
    fronted = [p for p in TILE_PREFIXES if p in prefixes]
    rest = [p for p in TILE_PREFIXES if p not in prefixes]
    return fronted + rest


def progressive_stage_order_for_starter(starter) -> List[str]:
    """Starter-first reordering of STAGE_PROGRESSIVE_ORDER. The chosen starter
    stages are fronted (positions 0..k-1) in canonical order; the rest follow.
    `starter` may be a single sid or a set."""
    starters = _starter_set(starter)
    fronted = [s for s in STAGE_PROGRESSIVE_ORDER if s in starters]
    rest = [s for s in STAGE_PROGRESSIVE_ORDER if s not in starters]
    return fronted + rest


def free_stages_for_starter(starter, granularity: int) -> List[str]:
    """Stages immediately playable at session start, given the starter group(s)'
    covering token(s) are precollected. `starter` may be a single sid or a set.
    per_stage -> exactly the chosen stages; per_tile -> the whole tile(s) they
    sit on (for a W-only set that's just the W tile)."""
    starters = _starter_set(starter)
    if granularity in (FIELD_PER_STAGE, FIELD_PER_STAGE_PROGRESSIVE):
        return sorted(starters)
    if granularity in (FIELD_PER_TILE, FIELD_PER_TILE_PROGRESSIVE):
        prefixes = {s[0] for s in starters}
        return [s["str_id"] for s in GAME_DATA["stages"]
                if s["str_id"][0] in prefixes]
    raise ValueError(f"Unknown field_token_granularity: {granularity}")


# ----------------------------------------------------------------------- #
# Gem pouches
# ----------------------------------------------------------------------- #
def pouch_for_stage(sid: str, granularity: int) -> str | None:
    """Return the pouch item name that gates gems on stage `sid`, or None
    when no item-based gating applies (off mode, or progressive modes where
    the caller must use a count-based rule via pouch_count_for_stage)."""
    if granularity == POUCH_OFF:
        return None
    if granularity == POUCH_PER_TILE:
        return f"Gempouch ({sid[0]})"
    if granularity == POUCH_PER_TILE_PROGRESSIVE:
        return PROG_GEMPOUCH_PER_TILE_NAME
    if granularity == POUCH_GLOBAL:
        return "Master Gempouch"
    raise ValueError(f"Unknown gem_pouch_granularity: {granularity}")


def pouch_count_for_stage(sid: str, granularity: int, starter_sid: str = None) -> int:
    """Number of copies of `pouch_for_stage(sid, granularity)` required for
    gems on `sid`. 1 for distinct/global, N=position-in-starter-aware-order
    for progressive."""
    if granularity == POUCH_PER_TILE_PROGRESSIVE:
        order = (progressive_tile_order_for_starter(starter_sid)
                 if starter_sid is not None else TILE_PREFIXES)
        return order.index(sid[0]) + 1
    return 1


def pouches_for_pool(granularity: int) -> List[str]:
    if granularity == POUCH_OFF:
        return []
    if granularity == POUCH_PER_TILE:
        return [f"Gempouch ({p})" for p in TILE_PREFIXES]
    if granularity == POUCH_PER_TILE_PROGRESSIVE:
        return [PROG_GEMPOUCH_PER_TILE_NAME] * len(TILE_PREFIXES)
    if granularity == POUCH_GLOBAL:
        return ["Master Gempouch"]
    raise ValueError(f"Unknown gem_pouch_granularity: {granularity}")

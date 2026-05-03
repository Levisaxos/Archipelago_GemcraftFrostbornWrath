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
in PROGRESSIVE_TILE_ORDER (or per-stage / per-tier order). Rule gating uses
`state.count(name) >= N` instead of `state.has(name)`, so the same helper
contract (`{X}_for_stage`, `{X}_count_for_stage`) covers both modes.

ID ranges (allocated above existing 1400-1521 stash-stage range):
    1522-1547  stash tile keys                 (26)
    1548-1560  stash tier keys                 (13)
    1561       stash master key
    1562-1587  field tile tokens               (26)
    1588-1600  field tier tokens               (13)
    1601-1613  gem pouch tier                  (13)
    1614       gem pouch master
    1615       gem pouch per-tier progressive  (13 copies)
    1616       field token per-stage progressive  (122 copies)
    1617       field token per-tile progressive   (26 copies)
    1618       field token per-tier progressive   (13 copies)
    1619       stash key per-stage progressive    (122 copies)
    1620       stash key per-tile progressive     (26 copies)
    1621       stash key per-tier progressive     (13 copies)
"""

from __future__ import annotations

from typing import List

from .rulesdata import GAME_DATA, PROGRESSIVE_TILE_ORDER, STAGE_RULES


# Granularity option int values — keep in sync with options.py Choice values.
FIELD_PER_STAGE             = 0
FIELD_PER_STAGE_PROGRESSIVE = 1
FIELD_PER_TILE              = 2
FIELD_PER_TILE_PROGRESSIVE  = 3
FIELD_PER_TIER              = 4
FIELD_PER_TIER_PROGRESSIVE  = 5

STASH_PER_STAGE             = 0
STASH_PER_STAGE_PROGRESSIVE = 1
STASH_PER_TILE              = 2
STASH_PER_TILE_PROGRESSIVE  = 3
STASH_PER_TIER              = 4
STASH_PER_TIER_PROGRESSIVE  = 5
STASH_GLOBAL                = 6

POUCH_OFF                  = 0
POUCH_PER_TILE             = 1
POUCH_PER_TILE_PROGRESSIVE = 2
POUCH_PER_TIER             = 3
POUCH_PER_TIER_PROGRESSIVE = 4
POUCH_GLOBAL               = 5


# Active tile prefixes in play order (W, S, V, R, ...). See PROGRESSIVE_TILE_ORDER
# in rulesdata.py for the canonical ordering.
TILE_PREFIXES: List[str] = list(PROGRESSIVE_TILE_ORDER)

# Active tiers (only those that actually have stages assigned).
ACTIVE_TIERS: List[int] = sorted({
    STAGE_RULES[s["str_id"]].tier
    for s in GAME_DATA["stages"]
    if STAGE_RULES[s["str_id"]].tier >= 0
})

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
STASH_TIER_KEY_BASE   = 1548
STASH_MASTER_KEY_ID   = 1561
FIELD_TILE_TOKEN_BASE = 1562
FIELD_TIER_TOKEN_BASE = 1588
POUCH_TIER_BASE       = 1601
POUCH_MASTER_ID       = 1614

POUCH_PER_TIER_PROGRESSIVE_ID  = 1615
FIELD_PER_STAGE_PROGRESSIVE_ID = 1616
FIELD_PER_TILE_PROGRESSIVE_ID  = 1617
FIELD_PER_TIER_PROGRESSIVE_ID  = 1618
STASH_PER_STAGE_PROGRESSIVE_ID = 1619
STASH_PER_TILE_PROGRESSIVE_ID  = 1620
STASH_PER_TIER_PROGRESSIVE_ID  = 1621


# Singleton progressive item names. Singular for all stages — the count-based
# rule gates which Nth copy is required for which stage.
PROG_GEMPOUCH_PER_TILE_NAME    = "Progressive Gempouch"             # existing
PROG_GEMPOUCH_PER_TIER_NAME    = "Progressive Gempouch (per-tier)"  # new
PROG_FIELD_PER_STAGE_NAME      = "Progressive Field Token (per-stage)"
PROG_FIELD_PER_TILE_NAME       = "Progressive Field Token (per-tile)"
PROG_FIELD_PER_TIER_NAME       = "Progressive Field Token (per-tier)"
PROG_STASH_PER_STAGE_NAME      = "Progressive Stash Stage Key"
PROG_STASH_PER_TILE_NAME       = "Progressive Stash Tile Key"
PROG_STASH_PER_TIER_NAME       = "Progressive Stash Tier Key"


def stash_tile_key_id(prefix: str) -> int:
    return STASH_TILE_KEY_BASE + _tile_index(prefix)


def stash_tier_key_id(tier: int) -> int:
    return STASH_TIER_KEY_BASE + tier


def field_tile_token_id(prefix: str) -> int:
    return FIELD_TILE_TOKEN_BASE + _tile_index(prefix)


def field_tier_token_id(tier: int) -> int:
    return FIELD_TIER_TOKEN_BASE + tier


def pouch_tier_id(tier: int) -> int:
    return POUCH_TIER_BASE + tier


# ----------------------------------------------------------------------- #
# Stash keys
# ----------------------------------------------------------------------- #
def stash_key_for_stage(sid: str, granularity: int) -> str:
    """Item name whose presence (state.count >= stash_key_count_for_stage)
    unlocks `sid`'s wizard stash check under the chosen granularity."""
    if granularity == STASH_PER_STAGE:
        return f"Wizard Stash {sid} Key"
    if granularity == STASH_PER_STAGE_PROGRESSIVE:
        return PROG_STASH_PER_STAGE_NAME
    if granularity == STASH_PER_TILE:
        return f"Wizard Stash Tile {sid[0]} Key"
    if granularity == STASH_PER_TILE_PROGRESSIVE:
        return PROG_STASH_PER_TILE_NAME
    if granularity == STASH_PER_TIER:
        return f"Wizard Stash Tier {STAGE_RULES[sid].tier} Key"
    if granularity == STASH_PER_TIER_PROGRESSIVE:
        return PROG_STASH_PER_TIER_NAME
    if granularity == STASH_GLOBAL:
        return "Wizard Stash Master Key"
    raise ValueError(f"Unknown stash_key_granularity: {granularity}")


def stash_key_count_for_stage(sid: str, granularity: int) -> int:
    """Number of copies of `stash_key_for_stage(sid, granularity)` required to
    unlock `sid`'s stash. 1 for distinct/global, N=position-in-order for
    progressive variants."""
    if granularity == STASH_PER_STAGE_PROGRESSIVE:
        return STAGE_PROGRESSIVE_ORDER.index(sid) + 1
    if granularity == STASH_PER_TILE_PROGRESSIVE:
        return _tile_index(sid[0]) + 1
    if granularity == STASH_PER_TIER_PROGRESSIVE:
        return ACTIVE_TIERS.index(STAGE_RULES[sid].tier) + 1
    return 1


def stash_keys_for_pool(granularity: int) -> List[str]:
    if granularity == STASH_PER_STAGE:
        return [f"Wizard Stash {s['str_id']} Key" for s in GAME_DATA["stages"]]
    if granularity == STASH_PER_STAGE_PROGRESSIVE:
        return [PROG_STASH_PER_STAGE_NAME] * len(STAGE_PROGRESSIVE_ORDER)
    if granularity == STASH_PER_TILE:
        return [f"Wizard Stash Tile {p} Key" for p in TILE_PREFIXES]
    if granularity == STASH_PER_TILE_PROGRESSIVE:
        return [PROG_STASH_PER_TILE_NAME] * len(TILE_PREFIXES)
    if granularity == STASH_PER_TIER:
        return [f"Wizard Stash Tier {t} Key" for t in ACTIVE_TIERS]
    if granularity == STASH_PER_TIER_PROGRESSIVE:
        return [PROG_STASH_PER_TIER_NAME] * len(ACTIVE_TIERS)
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
    if granularity == FIELD_PER_TIER:
        return f"Tier {STAGE_RULES[sid].tier} Field Token"
    if granularity == FIELD_PER_TIER_PROGRESSIVE:
        return PROG_FIELD_PER_TIER_NAME
    raise ValueError(f"Unknown field_token_granularity: {granularity}")


def field_token_count_for_stage(sid: str, granularity: int) -> int:
    """Number of copies of `field_token_for_stage(sid, granularity)` required
    to unlock `sid`. 1 for distinct, N=position-in-order for progressive."""
    if granularity == FIELD_PER_STAGE_PROGRESSIVE:
        return STAGE_PROGRESSIVE_ORDER.index(sid) + 1
    if granularity == FIELD_PER_TILE_PROGRESSIVE:
        return _tile_index(sid[0]) + 1
    if granularity == FIELD_PER_TIER_PROGRESSIVE:
        return ACTIVE_TIERS.index(STAGE_RULES[sid].tier) + 1
    return 1


def field_tokens_for_pool(granularity: int, exclude_starter_sid: str) -> List[str]:
    """Return the list of field-token items to add to the pool, omitting the
    item(s) covering the chosen starter (which are precollected instead).
    For progressive variants, M = starter's index + 1 copies are precollected
    so the pool gets `total - M`."""
    if granularity == FIELD_PER_STAGE:
        return [
            f"{s['str_id']} Field Token"
            for s in GAME_DATA["stages"]
            if s["str_id"] != exclude_starter_sid
        ]
    if granularity == FIELD_PER_STAGE_PROGRESSIVE:
        m = STAGE_PROGRESSIVE_ORDER.index(exclude_starter_sid) + 1
        return [PROG_FIELD_PER_STAGE_NAME] * (len(STAGE_PROGRESSIVE_ORDER) - m)
    if granularity == FIELD_PER_TILE:
        starter_prefix = exclude_starter_sid[0]
        return [f"{p} Tile Field Token" for p in TILE_PREFIXES if p != starter_prefix]
    if granularity == FIELD_PER_TILE_PROGRESSIVE:
        m = _tile_index(exclude_starter_sid[0]) + 1
        return [PROG_FIELD_PER_TILE_NAME] * (len(TILE_PREFIXES) - m)
    if granularity == FIELD_PER_TIER:
        starter_tier = STAGE_RULES[exclude_starter_sid].tier
        return [f"Tier {t} Field Token" for t in ACTIVE_TIERS if t != starter_tier]
    if granularity == FIELD_PER_TIER_PROGRESSIVE:
        starter_tier = STAGE_RULES[exclude_starter_sid].tier
        m = ACTIVE_TIERS.index(starter_tier) + 1
        return [PROG_FIELD_PER_TIER_NAME] * (len(ACTIVE_TIERS) - m)
    raise ValueError(f"Unknown field_token_granularity: {granularity}")


def starter_field_tokens_to_precollect(starter_sid: str, granularity: int) -> List[str]:
    """Items the apworld must precollect so the starter stage is reachable
    under the given granularity. For progressives this is M copies of the
    singleton (M = starter's index in the unlock order + 1)."""
    if granularity == FIELD_PER_STAGE:
        return [f"{starter_sid} Field Token"]
    if granularity == FIELD_PER_STAGE_PROGRESSIVE:
        m = STAGE_PROGRESSIVE_ORDER.index(starter_sid) + 1
        return [PROG_FIELD_PER_STAGE_NAME] * m
    if granularity == FIELD_PER_TILE:
        return [f"{starter_sid[0]} Tile Field Token"]
    if granularity == FIELD_PER_TILE_PROGRESSIVE:
        m = _tile_index(starter_sid[0]) + 1
        return [PROG_FIELD_PER_TILE_NAME] * m
    if granularity == FIELD_PER_TIER:
        return [f"Tier {STAGE_RULES[starter_sid].tier} Field Token"]
    if granularity == FIELD_PER_TIER_PROGRESSIVE:
        m = ACTIVE_TIERS.index(STAGE_RULES[starter_sid].tier) + 1
        return [PROG_FIELD_PER_TIER_NAME] * m
    raise ValueError(f"Unknown field_token_granularity: {granularity}")


def starter_field_token(sid: str, granularity: int) -> str:
    """Legacy single-item helper kept for callers that only ever see distinct
    granularities. For progressive variants prefer
    starter_field_tokens_to_precollect, which returns the full M-copy list."""
    return field_token_for_stage(sid, granularity)


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
    if granularity == POUCH_PER_TIER:
        return f"Tier {STAGE_RULES[sid].tier} Gempouch"
    if granularity == POUCH_PER_TIER_PROGRESSIVE:
        return PROG_GEMPOUCH_PER_TIER_NAME
    if granularity == POUCH_GLOBAL:
        return "Master Gempouch"
    raise ValueError(f"Unknown gem_pouch_granularity: {granularity}")


def pouch_count_for_stage(sid: str, granularity: int) -> int:
    """Number of copies of `pouch_for_stage(sid, granularity)` required for
    gems on `sid`. 1 for distinct/global, N=position-in-order for progressive."""
    if granularity == POUCH_PER_TILE_PROGRESSIVE:
        return _tile_index(sid[0]) + 1
    if granularity == POUCH_PER_TIER_PROGRESSIVE:
        return ACTIVE_TIERS.index(STAGE_RULES[sid].tier) + 1
    return 1


def pouches_for_pool(granularity: int) -> List[str]:
    if granularity == POUCH_OFF:
        return []
    if granularity == POUCH_PER_TILE:
        return [f"Gempouch ({p})" for p in TILE_PREFIXES]
    if granularity == POUCH_PER_TILE_PROGRESSIVE:
        return [PROG_GEMPOUCH_PER_TILE_NAME] * len(TILE_PREFIXES)
    if granularity == POUCH_PER_TIER:
        return [f"Tier {t} Gempouch" for t in ACTIVE_TIERS]
    if granularity == POUCH_PER_TIER_PROGRESSIVE:
        return [PROG_GEMPOUCH_PER_TIER_NAME] * len(ACTIVE_TIERS)
    if granularity == POUCH_GLOBAL:
        return ["Master Gempouch"]
    raise ValueError(f"Unknown gem_pouch_granularity: {granularity}")

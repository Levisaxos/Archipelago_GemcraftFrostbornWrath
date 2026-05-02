"""
Granularity-aware item-name resolution for stash keys, field tokens, and
gem pouches. Each helper takes a stage str_id and the option value
(int from the corresponding Choice option) and returns the item name that
gates that stage under the chosen granularity.

The companion *_pool functions return the list of item names that should
be added to the multiworld's item pool for the chosen granularity (one
entry per item to create).

ID ranges (allocated above existing stash-key range 1400-1521):
    1522-1547  stash tile keys     (26, one per stage prefix)
    1548-1560  stash tier keys     (13, tiers 0-12)
    1561       stash master key
    1562-1587  field tile tokens   (26)
    1588-1600  field tier tokens   (13)
    1601-1613  gem pouch tier      (13)
    1614       gem pouch master
"""

from __future__ import annotations

from typing import List

from .rulesdata import GAME_DATA, GEM_POUCH_PLAY_ORDER, STAGE_RULES


# Granularity option int values — keep in sync with options.py Choice values.
FIELD_PER_STAGE = 0
FIELD_PER_TILE  = 1
FIELD_PER_TIER  = 2

STASH_PER_STAGE = 0
STASH_PER_TILE  = 1
STASH_PER_TIER  = 2
STASH_GLOBAL    = 3

POUCH_OFF                  = 0
POUCH_PER_TILE_DISTINCT    = 1
POUCH_PER_TILE_PROGRESSIVE = 2
POUCH_PER_TIER             = 3
POUCH_GLOBAL               = 4


# Active tile prefixes in play order (W, S, V, R, ...).
TILE_PREFIXES: List[str] = list(GEM_POUCH_PLAY_ORDER)

# Active tiers (only those that actually have stages assigned).
ACTIVE_TIERS: List[int] = sorted({
    STAGE_RULES[s["str_id"]].tier
    for s in GAME_DATA["stages"]
    if STAGE_RULES[s["str_id"]].tier >= 0
})


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
    if granularity == STASH_PER_STAGE:
        return f"Wizard Stash {sid} Key"
    if granularity == STASH_PER_TILE:
        return f"Wizard Stash Tile {sid[0]} Key"
    if granularity == STASH_PER_TIER:
        return f"Wizard Stash Tier {STAGE_RULES[sid].tier} Key"
    if granularity == STASH_GLOBAL:
        return "Wizard Stash Master Key"
    raise ValueError(f"Unknown stash_key_granularity: {granularity}")


def stash_keys_for_pool(granularity: int) -> List[str]:
    if granularity == STASH_PER_STAGE:
        return [f"Wizard Stash {s['str_id']} Key" for s in GAME_DATA["stages"]]
    if granularity == STASH_PER_TILE:
        return [f"Wizard Stash Tile {p} Key" for p in TILE_PREFIXES]
    if granularity == STASH_PER_TIER:
        return [f"Wizard Stash Tier {t} Key" for t in ACTIVE_TIERS]
    if granularity == STASH_GLOBAL:
        return ["Wizard Stash Master Key"]
    raise ValueError(f"Unknown stash_key_granularity: {granularity}")


# ----------------------------------------------------------------------- #
# Field tokens
# ----------------------------------------------------------------------- #
def field_token_for_stage(sid: str, granularity: int) -> str:
    if granularity == FIELD_PER_STAGE:
        return f"{sid} Field Token"
    if granularity == FIELD_PER_TILE:
        return f"{sid[0]} Tile Field Token"
    if granularity == FIELD_PER_TIER:
        return f"Tier {STAGE_RULES[sid].tier} Field Token"
    raise ValueError(f"Unknown field_token_granularity: {granularity}")


def field_tokens_for_pool(granularity: int, exclude_starter_sid: str) -> List[str]:
    """Return the list of field-token items to add to the pool, omitting the
    item that covers the chosen starter (which is precollected instead)."""
    if granularity == FIELD_PER_STAGE:
        return [
            f"{s['str_id']} Field Token"
            for s in GAME_DATA["stages"]
            if s["str_id"] != exclude_starter_sid
        ]
    if granularity == FIELD_PER_TILE:
        starter_prefix = exclude_starter_sid[0]
        return [f"{p} Tile Field Token" for p in TILE_PREFIXES if p != starter_prefix]
    if granularity == FIELD_PER_TIER:
        starter_tier = STAGE_RULES[exclude_starter_sid].tier
        return [f"Tier {t} Field Token" for t in ACTIVE_TIERS if t != starter_tier]
    raise ValueError(f"Unknown field_token_granularity: {granularity}")


def starter_field_token(sid: str, granularity: int) -> str:
    """Item name for the field-token that should be precollected to grant
    starter-stage access under this granularity. Same as `field_token_for_stage`
    but kept separate for clarity at call sites."""
    return field_token_for_stage(sid, granularity)


# ----------------------------------------------------------------------- #
# Gem pouches
# ----------------------------------------------------------------------- #
def pouch_for_stage(sid: str, granularity: int) -> str | None:
    """Return the pouch item name that gates gems on stage `sid`, or None if
    pouches are off."""
    if granularity == POUCH_OFF:
        return None
    if granularity == POUCH_PER_TILE_DISTINCT:
        return f"Gempouch ({sid[0]})"
    if granularity == POUCH_PER_TILE_PROGRESSIVE:
        # Caller handles via state.count("Progressive Gempouch") >= prefix_index+1
        return None
    if granularity == POUCH_PER_TIER:
        return f"Tier {STAGE_RULES[sid].tier} Gempouch"
    if granularity == POUCH_GLOBAL:
        return "Master Gempouch"
    raise ValueError(f"Unknown gem_pouch_granularity: {granularity}")


def pouches_for_pool(granularity: int) -> List[str]:
    if granularity == POUCH_OFF:
        return []
    if granularity == POUCH_PER_TILE_DISTINCT:
        return [f"Gempouch ({p})" for p in TILE_PREFIXES]
    if granularity == POUCH_PER_TILE_PROGRESSIVE:
        return ["Progressive Gempouch"] * len(TILE_PREFIXES)
    if granularity == POUCH_PER_TIER:
        return [f"Tier {t} Gempouch" for t in ACTIVE_TIERS]
    if granularity == POUCH_GLOBAL:
        return ["Master Gempouch"]
    raise ValueError(f"Unknown gem_pouch_granularity: {granularity}")

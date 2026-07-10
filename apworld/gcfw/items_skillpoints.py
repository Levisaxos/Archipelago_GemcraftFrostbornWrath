from __future__ import annotations

from typing import Dict, List, Optional, Tuple

from BaseClasses import ItemClassification

from .items import ItemData


SP_BUNDLE_BASE_ID = 1700

# Fixed-value skillpoint filler. Three chunky "bundle" tiers plus a common
# single Skillpoint. Values are constant per-seed — there is no budget math:
# the total SP a seed grants scales purely with how many checks it has (more
# achievements -> more single Skillpoints), mirroring vanilla "do more, get
# more". The bundles are always a fixed 40 (32 + 8 + 2 = 860 SP); the single
# fills whatever filler slots remain after real items, XP tomes, and the 40
# bundles.
#
# (item_name, ap_id_offset, sp_value, fixed_count)
#   fixed_count is None for the single Skillpoint — its count is computed at
#   generation time to fill the remaining location slots.
# Order/index aligns with the AP id offset from SP_BUNDLE_BASE_ID and with the
# sp_bundle_values slot_data array the mod reads (indexed by apId - 1700).
SP_ITEMS: Tuple[Tuple[str, int, int, Optional[int]], ...] = (
    ("Skillpoint Bundle (Small)",  0, 5,   32),
    ("Skillpoint Bundle (Medium)", 1, 25,  8),
    ("Skillpoint Bundle (Big)",    2, 250, 2),
    ("Skillpoint",                 3, 1,   None),
)

# All four SP item names (used by rules.py to sum collected SP).
SP_ITEM_NAMES: Tuple[str, ...] = tuple(x[0] for x in SP_ITEMS)
# The three always-present fixed bundles (excludes the variable single).
SP_BUNDLE_NAMES: Tuple[str, ...] = tuple(x[0] for x in SP_ITEMS if x[3] is not None)
# The single-skillpoint filler item that soaks up leftover location slots.
SP_SINGLE_NAME: str = "Skillpoint"


def sp_slot_data_values() -> List[int]:
    """The [Small, Medium, Big, Single] SP values shipped to the mod, indexed
    by apId - SP_BUNDLE_BASE_ID. Constant every seed."""
    return [x[2] for x in SP_ITEMS]


def sp_bundle_item_table() -> Dict[str, ItemData]:
    """One AP item per SP tier at IDs 1700..1703. All `filler`: under the
    WL-derived model, achievement access rules are pure wizard-level, so
    skillPoints:N is no longer a generation gate and these gate nothing.
    They're the pool balancer that fills leftover location slots. The mod
    still tracks them client-side for the skillPoints:N tooltip display
    regardless of classification.

    The SP value granted by each item is a fixed constant (see SP_ITEMS) and
    is shipped to the mod via slot_data (sp_bundle_values)."""
    table: Dict[str, ItemData] = {}
    for name, offset, _value, _count in SP_ITEMS:
        table[name] = ItemData(
            SP_BUNDLE_BASE_ID + offset,
            ItemClassification.filler,
        )
    return table


def fixed_bundle_names() -> List[str]:
    """Flat list of the 40 always-present fixed bundles (Small x32, Medium x8,
    Big x2), in declaration order. The caller places these first, then tops up
    any remaining filler slots with single Skillpoints."""
    names: List[str] = []
    for name, _offset, _value, count in SP_ITEMS:
        if count is not None:
            names.extend([name] * count)
    return names

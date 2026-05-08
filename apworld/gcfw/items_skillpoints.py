from __future__ import annotations

from typing import Dict, List, Tuple

from BaseClasses import ItemClassification

from .items import ItemData


SP_BUNDLE_BASE_ID = 1700

# Four named bundle tiers. Order matters — index aligns with AP id offset
# from SP_BUNDLE_BASE_ID and with the slot_data array sent to the mod.
# (name, ap_id_offset, slot_pct, sp_pct)
TIERS: Tuple[Tuple[str, int, float, float], ...] = (
    ("Small",  0, 0.60, 0.30),
    ("Medium", 1, 0.25, 0.30),
    ("Large",  2, 0.12, 0.25),
    ("Huge",   3, 0.03, 0.15),
)
TIER_NAMES: Tuple[str, ...] = tuple(t[0] for t in TIERS)


def sp_bundle_item_name(tier: str) -> str:
    return f"Skillpoint Bundle ({tier})"


SP_BUNDLE_NAMES: Tuple[str, ...] = tuple(sp_bundle_item_name(t) for t in TIER_NAMES)


def sp_bundle_item_table() -> Dict[str, ItemData]:
    """One AP item per tier at IDs 1700..1703. All progression_skip_balancing
    so every bundle is visible to state.has/state.count for skillPoints:N
    achievement gates without invoking AP's cross-player balancing.

    The SP value granted by each bundle is determined per-seed by
    compute_tier_distribution and shipped to the mod via slot_data —
    the AP item itself just identifies the tier slot."""
    table: Dict[str, ItemData] = {}
    for name, offset, _slot_pct, _sp_pct in TIERS:
        table[sp_bundle_item_name(name)] = ItemData(
            SP_BUNDLE_BASE_ID + offset,
            ItemClassification.progression_skip_balancing,
        )
    return table


def compute_tier_distribution(total_sp: int, slot_count: int) -> Tuple[List[int], List[int]]:
    """Return (values, counts) — both length 4, indexed in TIERS order.

    counts[i] = number of bundle items of tier i to place; sums to slot_count.
    values[i] = SP each bundle of that tier grants when collected.

    Slot allocation uses TIERS slot_pct; SP allocation uses TIERS sp_pct.
    Per-tier SP value = round(pile / count). Empty tiers (count rounded to 0
    on small filler pools) have their SP pile folded into the next-lower
    populated tier so SP isn't lost. Some rounding drift between the resulting
    sum(c*v) and total_sp is tolerated (typically < 2 %)."""
    counts = [0, 0, 0, 0]
    values = [0, 0, 0, 0]
    if slot_count <= 0 or total_sp <= 0:
        return values, counts

    slot_pcts = [t[2] for t in TIERS]
    sp_pcts = [t[3] for t in TIERS]

    # Slot counts: round, with Small absorbing the rounding remainder so the
    # sum is exactly slot_count.
    counts = [int(round(p * slot_count)) for p in slot_pcts]
    counts[0] += slot_count - sum(counts)
    counts[0] = max(0, counts[0])

    # SP piles. If a tier rounds out to 0 slots (very small filler pools),
    # move its pile down to the next-lower tier rather than dropping SP.
    piles = [sp_pcts[i] * total_sp for i in range(4)]
    for i in (3, 2, 1):
        if counts[i] == 0:
            piles[i - 1] += piles[i]
            piles[i] = 0

    # Per-tier SP value (clamped >=1 so a populated tier never grants 0).
    for i in range(4):
        if counts[i] > 0:
            values[i] = max(1, int(round(piles[i] / counts[i])))

    return values, counts


def generate_sp_bundles(rng, counts: List[int]) -> List[str]:
    """Expand per-tier counts into a flat list of bundle item names and shuffle.
    Counts come from compute_tier_distribution."""
    names: List[str] = []
    for i, tier_name in enumerate(TIER_NAMES):
        names.extend([sp_bundle_item_name(tier_name)] * counts[i])
    rng.shuffle(names)
    return names

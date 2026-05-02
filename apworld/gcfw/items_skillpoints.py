from __future__ import annotations

from typing import Dict, List

from BaseClasses import ItemClassification

from .items import ItemData


SP_BUNDLE_BASE_ID = 1700
SP_BUNDLE_SIZES: List[int] = list(range(1, 11))  # 1..10

# Relative weights per bundle size, skewed toward small with rare big bundles.
# Index 0 = size 1 SP, index 9 = size 10 SP.
SP_BUNDLE_WEIGHTS: List[float] = [25, 22, 18, 12, 8, 6, 4, 3, 1.5, 0.5]


def sp_bundle_item_name(size: int) -> str:
    return f"Skillpoint Bundle {size}"


def sp_bundle_item_table() -> Dict[str, ItemData]:
    """Skillpoint bundle items, all `progression_skip_balancing` so 100% of
    generated SP is visible to state.has/state.count and counts toward the
    skillPoints:N achievement gate. `skip_balancing` keeps Archipelago's
    cross-player balancing off (we ship many copies; balancing has no value).

    History: previously only odd sizes were progression — that capped the
    state-visible SP at ~half of generated, which made high-SP gates like
    Mastery (skillPoints:200) randomly unsatisfiable depending on the
    bundle-size lottery. Promoting all sizes to progression eliminates that
    failure class without changing total SP."""
    table: Dict[str, ItemData] = {}
    for size in SP_BUNDLE_SIZES:
        ap_id = SP_BUNDLE_BASE_ID + (size - 1)
        table[sp_bundle_item_name(size)] = ItemData(
            ap_id, ItemClassification.progression_skip_balancing)
    return table


def generate_sp_bundles(rng, total_sp: int, slot_count: int) -> List[str]:
    """Pick exactly `slot_count` bundle sizes from SP_BUNDLE_SIZES whose sum equals
    `total_sp`. Sizes are sampled with SP_BUNDLE_WEIGHTS, then corrected so the
    final sum lands on `total_sp` (sizes stay clamped to [1, 10]).

    If total_sp is unreachable inside [slot_count, 10*slot_count], returns the
    closest achievable distribution (clamped to all-1s or all-10s)."""
    if slot_count <= 0:
        return []

    min_sum = slot_count * SP_BUNDLE_SIZES[0]   # all 1s
    max_sum = slot_count * SP_BUNDLE_SIZES[-1]  # all 10s
    target = max(min_sum, min(max_sum, total_sp))

    sizes: List[int] = [
        rng.choices(SP_BUNDLE_SIZES, weights=SP_BUNDLE_WEIGHTS, k=1)[0]
        for _ in range(slot_count)
    ]

    delta = target - sum(sizes)
    # Walk indices in random order, nudging each ±1 until the sum lands.
    order = list(range(slot_count))
    while delta != 0:
        rng.shuffle(order)
        progressed = False
        for i in order:
            if delta == 0:
                break
            if delta > 0 and sizes[i] < SP_BUNDLE_SIZES[-1]:
                sizes[i] += 1
                delta -= 1
                progressed = True
            elif delta < 0 and sizes[i] > SP_BUNDLE_SIZES[0]:
                sizes[i] -= 1
                delta += 1
                progressed = True
        if not progressed:
            # Saturated at floor or ceiling — can't move further.
            break

    return [sp_bundle_item_name(s) for s in sizes]

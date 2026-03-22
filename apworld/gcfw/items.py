from __future__ import annotations

import json
from dataclasses import dataclass
from importlib.resources import files
from typing import Dict

from BaseClasses import Item, ItemClassification


class GCFWItem(Item):
    game = "GemCraft: Frostborn Wrath"


@dataclass
class ItemData:
    id: int
    classification: ItemClassification


def _load_item_table() -> Dict[str, ItemData]:
    data = json.loads(files(__package__).joinpath("data/game_data.json").read_text(encoding="utf-8"))

    table: Dict[str, ItemData] = {}

    for stage in data["stages"]:
        if stage["item_ap_id"] is None:
            continue
        name = f"{stage['str_id']} Field Token"
        # All tokens are progression — every token opens a region from W1,
        # immediately advancing the sphere regardless of XP.
        table[name] = ItemData(stage["item_ap_id"], ItemClassification.progression)

    # Skills — all progression: each is locked to a zone and all are required for A4
    # Note: gem types (Crit, Leech, Bleed, Armor Tear, Poison, Slow) are skills 7–12
    # (AP IDs 306–311) and do not need separate gem unlock items.
    for skill in data["skills"]:
        name = f"{skill['name']} Skill"
        table[name] = ItemData(skill["ap_id"], ItemClassification.progression)

    # Battle traits
    for trait in data["battle_traits"]:
        name = f"{trait['name']} Battle Trait"
        table[name] = ItemData(trait["ap_id"], ItemClassification.useful)

    # XP tiers — each gives wizard levels used to gate stage locations.
    # Small=2, Medium=5, Large=10 wizard levels.
    # The threshold check (_wizard_level >= N) accepts any combination, so
    # 1 Large, 2 Medium, 5 Small, 4 Small+1 Medium, etc. are all valid paths.
    # Large and Medium are both progression so the fill algorithm guarantees
    # they land in accessible locations — making the 1-Large AND 2-Medium
    # routes both reliable in practice (not just in theory).
    # Small is useful: it contributes to thresholds and fills gaps, but you
    # accumulate it naturally without it needing to be guaranteed early.
    table["Small XP Bonus"]  = ItemData(500, ItemClassification.progression)
    table["Medium XP Bonus"] = ItemData(501, ItemClassification.progression)
    table["Large XP Bonus"]  = ItemData(502, ItemClassification.progression)

    # Generic filler
    table["Shadow Core"] = ItemData(503, ItemClassification.filler)

    return table


item_table: Dict[str, ItemData] = _load_item_table()

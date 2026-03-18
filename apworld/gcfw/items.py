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
        table[name] = ItemData(stage["item_ap_id"], ItemClassification.progression)

    # Gem unlocks — Crit is progression because every non-W1 level requires it.
    # Others are useful until specific level requirements are researched.
    for gem in data["gem_unlocks"]:
        name = f"{gem['name']} Gem Unlock"
        cls = (ItemClassification.progression if gem["name"] == "Crit"
               else ItemClassification.useful)
        table[name] = ItemData(gem["ap_id"], cls)

    # Skills — all progression: each is locked to a zone and all are required for A4
    for skill in data["skills"]:
        name = f"{skill['name']} Skill"
        table[name] = ItemData(skill["ap_id"], ItemClassification.progression)

    # XP tiers (filler — help meet wizard level requirements)
    table["Small XP Bonus"]  = ItemData(500, ItemClassification.filler)
    table["Medium XP Bonus"] = ItemData(501, ItemClassification.filler)
    table["Large XP Bonus"]  = ItemData(502, ItemClassification.filler)

    # Generic filler
    table["Shadow Core"] = ItemData(503, ItemClassification.filler)

    return table


item_table: Dict[str, ItemData] = _load_item_table()

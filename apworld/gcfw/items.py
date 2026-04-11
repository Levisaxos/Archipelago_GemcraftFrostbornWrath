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

    # Battle traits — classified as progression since achievements require them
    for trait in data["battle_traits"]:
        name = f"{trait['name']} Battle Trait"
        table[name] = ItemData(trait["ap_id"], ItemClassification.progression)

    # XP tiers — 2 Ancient Grimoires + 6 Worn Tomes + 32 Tattered Scrolls.
    # Per-tome level values are configured from slot_data (xp_tome_bonus option).
    table["Tattered Scroll"]  = ItemData(500, ItemClassification.useful)
    table["Worn Tome"]        = ItemData(501, ItemClassification.useful)
    table["Ancient Grimoire"] = ItemData(502, ItemClassification.useful)

    # Specific talisman fragments — named by original field (IDs 700–752).
    for frag in data["talisman_fragments"]:
        table[f"{frag['str_id']} Talisman Fragment"] = ItemData(frag["item_ap_id"], ItemClassification.useful)

    # Extra talisman fragments — named "Extra Talisman Fragment #N" (IDs 753–799).
    for frag in data["extra_talisman_fragments"]:
        table[frag["name"]] = ItemData(frag["item_ap_id"], ItemClassification.useful)

    # Specific shadow core stashes — named by original field (IDs 800–816).
    for sc in data["shadow_core_stashes"]:
        table[f"{sc['str_id']} Shadow Cores"] = ItemData(sc["item_ap_id"], ItemClassification.filler)

    # Extra shadow core stashes — named "Extra Shadow Cores #N" (IDs 817–868).
    for sc in data["extra_shadow_core_stashes"]:
        table[sc["name"]] = ItemData(sc["item_ap_id"], ItemClassification.filler)

    return table


def _generate_achievement_items() -> Dict[str, ItemData]:
    """Generate achievement items (IDs 1000-1635) from rulesdata."""
    from .rulesdata_achievement_1 import achievement_requirements as ach1
    from .rulesdata_achievement_2 import achievement_requirements as ach2
    from .rulesdata_achievement_3 import achievement_requirements as ach3
    from .rulesdata_achievement_4 import achievement_requirements as ach4
    from .rulesdata_achievement_5 import achievement_requirements as ach5

    achievements_by_tier = {
        1: ach1,
        2: ach2,
        3: ach3,
        4: ach4,
        5: ach5,
    }

    table: Dict[str, ItemData] = {}
    item_id = 1000

    for tier in range(1, 6):
        for ach_name in sorted(achievements_by_tier[tier].keys()):
            table[f"Achievement: {ach_name}"] = ItemData(item_id, ItemClassification.useful)
            item_id += 1

    return table


item_table: Dict[str, ItemData] = _load_item_table()
achievement_item_table: Dict[str, ItemData] = _generate_achievement_items()

# Merge achievement items into main item table
item_table.update(achievement_item_table)

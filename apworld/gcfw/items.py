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
    # (AP IDs 706–711 after ID restructuring) and do not need separate gem unlock items.
    for skill in data["skills"]:
        name = f"{skill['name']} Skill"
        table[name] = ItemData(skill["ap_id"], ItemClassification.progression)

    # Map tiles (AP IDs 600–625) — progression items that unlock map regions
    for tile in data["map_tiles"]:
        name = f"Map Tile {tile['game_id']}"
        table[name] = ItemData(tile["ap_id"], ItemClassification.progression)

    # Battle traits — classified as progression since achievements require them
    for trait in data["battle_traits"]:
        name = f"{trait['name']} Battle Trait"
        table[name] = ItemData(trait["ap_id"], ItemClassification.progression)

    # XP tiers — allocated to 1100–1199 (100 items):
    # Base: 32 Tattered Scrolls + 6 Worn Tomes + 2 Ancient Grimoires = 40 items
    # Extra: 60 additional XP filler items for future expansion
    # Per-tome level values are configured from slot_data (xp_tome_bonus option).
    xp_id = 1100
    # 32 Tattered Scrolls (1100–1131)
    for i in range(32):
        table[f"Tattered Scroll #{i+1}"] = ItemData(xp_id, ItemClassification.useful)
        xp_id += 1
    # 6 Worn Tomes (1132–1137)
    for i in range(6):
        table[f"Worn Tome #{i+1}"] = ItemData(xp_id, ItemClassification.useful)
        xp_id += 1
    # 2 Ancient Grimoires (1138–1139)
    for i in range(2):
        table[f"Ancient Grimoire #{i+1}"] = ItemData(xp_id, ItemClassification.useful)
        xp_id += 1
    # 60 Extra XP filler items (1140–1199)
    for i in range(60):
        table[f"Extra XP Item #{i+1}"] = ItemData(xp_id, ItemClassification.useful)
        xp_id += 1

    # Specific talisman fragments — named by original field (IDs 900–952).
    for frag in data["talisman_fragments"]:
        table[f"{frag['str_id']} Talisman Fragment"] = ItemData(frag["item_ap_id"], ItemClassification.useful)

    # Extra talisman fragments — named "Extra Talisman Fragment #N" (IDs 1200–1299).
    for frag in data["extra_talisman_fragments"]:
        table[frag["name"]] = ItemData(frag["item_ap_id"], ItemClassification.useful)

    # Specific shadow core stashes — named by original field (IDs 1000–1046).
    for sc in data["shadow_core_stashes"]:
        table[f"{sc['str_id']} Shadow Cores"] = ItemData(sc["item_ap_id"], ItemClassification.filler)

    # Extra shadow core stashes — named "Extra Shadow Cores #N" (IDs 1300–1399).
    for sc in data["extra_shadow_core_stashes"]:
        table[sc["name"]] = ItemData(sc["item_ap_id"], ItemClassification.filler)

    return table


def _generate_achievement_items() -> Dict[str, ItemData]:
    """Load achievement items (IDs 2000-2636) from rulesdata packs with hardcoded ap_ids."""
    from .rulesdata_achievements import achievement_requirements as all_achievements

    table: Dict[str, ItemData] = {}

    # Use hardcoded ap_id from each achievement, sorted by name for consistency
    for ach_name in sorted(all_achievements.keys()):
        ach_data = all_achievements[ach_name]
        if "ap_id" in ach_data:
            item_id = ach_data["ap_id"]
            table[f"Achievement: {ach_name}"] = ItemData(item_id, ItemClassification.useful)

    return table


item_table: Dict[str, ItemData] = _load_item_table()
achievement_item_table: Dict[str, ItemData] = _generate_achievement_items()

# Merge achievement items into main item table
item_table.update(achievement_item_table)

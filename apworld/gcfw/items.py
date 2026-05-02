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
    #
    # Half of each tier is `progression` so AP fill respects wizardLevel:N
    # gates; the other half is `useful` (still placed, just not state-tracked).
    # Convention: odd-numbered (#1, #3, #5...) = progression; even = useful.
    # That keeps the split roughly 50/50 within each tier.
    def _xp_cls(idx: int) -> ItemClassification:
        return ItemClassification.progression if idx % 2 == 0 else ItemClassification.useful

    xp_id = 1100
    # 32 Tattered Scrolls (1100–1131): 16 progression + 16 useful
    for i in range(32):
        table[f"Tattered Scroll #{i+1}"] = ItemData(xp_id, _xp_cls(i))
        xp_id += 1
    # 6 Worn Tomes (1132–1137): 3 progression + 3 useful
    for i in range(6):
        table[f"Worn Tome #{i+1}"] = ItemData(xp_id, _xp_cls(i))
        xp_id += 1
    # 2 Ancient Grimoires (1138–1139): 1 progression + 1 useful
    for i in range(2):
        table[f"Ancient Grimoire #{i+1}"] = ItemData(xp_id, _xp_cls(i))
        xp_id += 1
    # 60 Extra XP filler items (1140–1199): 30 progression + 30 useful
    for i in range(60):
        table[f"Extra XP Item #{i+1}"] = ItemData(xp_id, _xp_cls(i))
        xp_id += 1

    # Specific talisman fragments — named by original field (IDs 900–952).
    # 25 fragments are promoted to progression to match the talisman's slot
    # layout (4 corner + 12 edge + 9 inner): these gate the
    # talismanCornerFragment:N / talismanEdgeFragment:N / talismanCenterFragment:N
    # achievement counters.  Selection: highest-rarity in each type (see
    # talismans._build_progression_corner_edge_names + _build_matching_talisman_grid).
    # The remaining ~28 fragments are useful — they still drop, just don't gate.
    from .talismans import (
        MATCHING_TALISMAN_NAMES,
        PROGRESSION_CORNER_TALISMAN_NAMES,
        PROGRESSION_EDGE_TALISMAN_NAMES,
    )
    progression_talismans = (
        MATCHING_TALISMAN_NAMES
        | PROGRESSION_CORNER_TALISMAN_NAMES
        | PROGRESSION_EDGE_TALISMAN_NAMES
    )
    for frag in data["talisman_fragments"]:
        name = f"{frag['str_id']} Talisman Fragment"
        cls = (ItemClassification.progression
               if name in progression_talismans
               else ItemClassification.useful)
        table[name] = ItemData(frag["item_ap_id"], cls)

    # Extra talisman fragments — named "Extra Talisman Fragment #N" (IDs 1200–1299).
    for frag in data["extra_talisman_fragments"]:
        table[frag["name"]] = ItemData(frag["item_ap_id"], ItemClassification.useful)

    # Shadow core stashes — half progression / half filler (alternating by
    # registration order).  Progression items are state-tracked so the
    # shadowCore:N gate can sum collected core amounts; the other half is
    # filler placed wherever AP wants.  Final progression-cores total is
    # roughly 50% of pool capacity (~19,870 of 39,740 cores).
    def _sc_cls(idx: int) -> ItemClassification:
        return ItemClassification.progression if idx % 2 == 0 else ItemClassification.filler

    # Specific shadow core stashes — named by original field (IDs 1000–1046).
    for i, sc in enumerate(data["shadow_core_stashes"]):
        table[f"{sc['str_id']} Shadow Cores"] = ItemData(sc["item_ap_id"], _sc_cls(i))

    # Extra shadow core stashes — named "Extra Shadow Cores #N" (IDs 1300–1399).
    for i, sc in enumerate(data["extra_shadow_core_stashes"]):
        table[sc["name"]] = ItemData(sc["item_ap_id"], _sc_cls(i))

    # Per-stage Wizard Stash key items (IDs 1400–1521). Progression: each
    # gates its matching "Complete {strId} - Wizard stash" location. All 122
    # stages including W1-W4 get a key — there's no off mode.
    for stage in data["stages"]:
        key_id = 1400 + stage["loc_ap_id"] - 1
        table[f"Wizard Stash {stage['str_id']} Key"] = ItemData(
            key_id, ItemClassification.progression)

    # Gempouches (IDs 626–652). Always declared so name→id resolution works
    # regardless of the gem_pouch_gating option; create_items() decides which
    # subset actually goes into the pool.
    #   - Distinct: 26 named pouches (one per stage-prefix letter, in play
    #     order from game_data.json) at IDs 626..651.
    #   - Progressive: a single "Progressive Gempouch" item at ID 652, added
    #     to the pool 26 times.
    from .rulesdata import GEM_POUCH_PLAY_ORDER
    for i, prefix in enumerate(GEM_POUCH_PLAY_ORDER):
        table[f"Gempouch ({prefix})"] = ItemData(
            626 + i, ItemClassification.progression)
    table["Progressive Gempouch"] = ItemData(
        652, ItemClassification.progression)

    return table


item_table: Dict[str, ItemData] = _load_item_table()

# SP bundle items (IDs 1700–1709) — filler that grants 1..10 skill points each.
from .items_skillpoints import sp_bundle_item_table
item_table.update(sp_bundle_item_table())

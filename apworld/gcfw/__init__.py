from __future__ import annotations

import json
from importlib.resources import files
from typing import Dict, List

from BaseClasses import Region

from worlds.AutoWorld import WebWorld, World

from .items import GCFWItem, ItemData, item_table
from .locations import GCFWLocation, LocationData, location_table
from .options import GCFWOptions
from .rules import ORPHANED_STAGES, set_rules


def _load_stages():
    data = json.loads(files(__package__).joinpath("data/game_data.json").read_text(encoding="utf-8"))
    return data["stages"]


class GCFWWebWorld(WebWorld):
    theme = "ocean"


class GemcraftFrostbornWrathWorld(World):
    """GemCraft: Frostborn Wrath is a hex-grid tower defense game with gem crafting.
    Complete stages to receive field tokens that unlock further stages, all shuffled
    into an Archipelago multiworld."""

    game = "GemCraft: Frostborn Wrath"
    web = GCFWWebWorld()
    options_dataclass = GCFWOptions
    options: GCFWOptions
    topology_present = True

    item_name_to_id: Dict[str, int] = {name: data.id for name, data in item_table.items()}
    location_name_to_id: Dict[str, int] = {name: data.id for name, data in location_table.items()}

    def create_item(self, name: str) -> GCFWItem:
        data = item_table[name]
        return GCFWItem(name, data.classification, data.id, self.player)

    def create_items(self) -> None:
        stages = _load_stages()
        pool: List[GCFWItem] = []

        # Field tokens
        for stage in stages:
            if stage["loc_ap_id"] > 109:
                continue
            if stage["item_ap_id"] is None:
                continue  # W1 — no token
            pool.append(self.create_item(f"{stage['str_id']} Field Token"))

        # Skills
        for name, data in item_table.items():
            if name.endswith(" Skill"):
                pool.append(self.create_item(name))

        # Pad remaining slots with cycling XP tiers, then Shadow Cores
        xp_tiers = ["Large XP Bonus", "Medium XP Bonus", "Small XP Bonus"]
        location_count = len(location_table)
        i = 0
        while len(pool) < location_count:
            pool.append(self.create_item(xp_tiers[i % len(xp_tiers)]))
            i += 1

        self.multiworld.itempool += pool

    def create_regions(self) -> None:
        stages = _load_stages()
        stage_map = {s["str_id"]: s for s in stages if s["loc_ap_id"] <= 109}

        menu_region = Region("Menu", self.player, self.multiworld)
        self.multiworld.regions.append(menu_region)

        # Create one region per in-scope stage
        stage_regions: Dict[str, Region] = {}
        for str_id, stage in stage_map.items():
            region = Region(str_id, self.player, self.multiworld)
            for suffix in ("Journey", "Bonus"):
                loc_name = f"Complete {str_id} - {suffix}"
                loc_data = location_table[loc_name]
                region.locations.append(GCFWLocation(self.player, loc_name, loc_data.id, region))
            stage_regions[str_id] = region
            self.multiworld.regions.append(region)

        # Connect Menu → W1 (starting stage, no rule)
        menu_region.connect(stage_regions["W1"], "Start")

        # Connect Menu → orphaned stages (no known parent, treat as always accessible)
        for str_id in ORPHANED_STAGES:
            if str_id in stage_regions:
                menu_region.connect(stage_regions[str_id], f"Start {str_id}")

    def set_rules(self) -> None:
        set_rules(self)

    def generate_basic(self) -> None:
        # Completion condition is set inside set_rules (after regions exist)
        pass

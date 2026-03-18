from __future__ import annotations

import json
from importlib.resources import files
from typing import Dict, List

from BaseClasses import ItemClassification, LocationProgressType, Region

from worlds.AutoWorld import WebWorld, World

from .items import GCFWItem, ItemData, item_table
from .locations import GCFWLocation, LocationData, location_table
from .options import GCFWOptions
from .rules import set_rules


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

        # Gem unlocks
        for name in item_table:
            if name.endswith(" Gem Unlock"):
                pool.append(self.create_item(name))

        # Skills
        for name in item_table:
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
                loc = GCFWLocation(self.player, loc_name, loc_data.id, region)
                region.locations.append(loc)
            # Victory event lives inside the A4 region (ID=None → event, not networked)
            if str_id == "A4":
                region.locations.append(GCFWLocation(self.player, "Complete A4 - Frostborn Wrath Victory", None, region))
            stage_regions[str_id] = region
            self.multiworld.regions.append(region)

        # Connect Menu → W1 (only starting stage — orphaned zones are handled in set_rules)
        menu_region.connect(stage_regions["W1"], "Start")

    def set_rules(self) -> None:
        set_rules(self)

    def generate_basic(self) -> None:
        # Place the Victory event so the spoiler log shows A4 as the goal.
        victory_loc = self.multiworld.get_location("Complete A4 - Frostborn Wrath Victory", self.player)
        victory_loc.place_locked_item(
            GCFWItem("Victory", ItemClassification.progression, None, self.player)
        )

        # --- Zone-based skill placement ---
        # One skill is locked to a random location inside each non-W, non-A zone.
        # We have exactly 24 skills and 24 such zones, so they map 1-to-1.
        stages = _load_stages()

        # Group in-scope stage str_ids by their zone letter (first character)
        zone_stages: Dict[str, List[str]] = {}
        for stage in stages:
            if stage["loc_ap_id"] > 109:
                continue
            zone = stage["str_id"][0]
            zone_stages.setdefault(zone, []).append(stage["str_id"])

        # The zones that get a skill: every zone except W (starting) and A (endgame)
        skill_zones = sorted(z for z in zone_stages if z not in ("W", "A"))

        all_skills = [name for name in item_table if name.endswith(" Skill")]
        shuffled_skills = list(all_skills)
        self.random.shuffle(shuffled_skills)

        placed_skills: set = set()
        for zone, skill_name in zip(skill_zones, shuffled_skills):
            stage_ids = list(zone_stages[zone])
            self.random.shuffle(stage_ids)
            placed = False
            for chosen_stage in stage_ids:
                suffixes = ["Journey", "Bonus"]
                self.random.shuffle(suffixes)
                for suffix in suffixes:
                    loc_name = f"Complete {chosen_stage} - {suffix}"
                    loc = self.multiworld.get_location(loc_name, self.player)
                    if loc.item is None:
                        loc.place_locked_item(self.create_item(skill_name))
                        placed_skills.add(skill_name)
                        placed = True
                        break
                if placed:
                    break

        # Remove placed skills from the shared item pool so counts stay balanced
        for skill_name in placed_skills:
            for item in self.multiworld.itempool:
                if item.player == self.player and item.name == skill_name:
                    self.multiworld.itempool.remove(item)
                    break

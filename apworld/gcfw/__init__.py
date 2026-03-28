from __future__ import annotations

import json
from importlib.resources import files
from typing import Dict, List

from BaseClasses import ItemClassification, Region

from worlds.AutoWorld import WebWorld, World

from .items import GCFWItem, ItemData, item_table
from .locations import GCFWLocation, LocationData, location_table
from .options import GCFWOptions
from .rules import set_rules
from .rulesdata import FREE_STAGES, TIERS, TIER_REQUIREMENTS


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
            if stage["item_ap_id"] is None:
                continue  # W1 — no token
            token = self.create_item(f"{stage['str_id']} Field Token")
            if stage["str_id"] in FREE_STAGES:
                # W2-W4: give at start so the mod unlocks them on connect.
                # They still count as Tier 0 tokens for tier progression.
                self.multiworld.push_precollected(token)
            else:
                pool.append(token)

        # Skills (includes gem-type unlocks at positions 7–12)
        for name in item_table:
            if name.endswith(" Skill"):
                pool.append(self.create_item(name))

        # Battle traits
        for name in item_table:
            if name.endswith(" Battle Trait"):
                pool.append(self.create_item(name))

        # Pad remaining slots with XP tiers: 2 Large, 10 Medium, rest Small.
        # Players also earn wizard levels naturally from completing stages, so
        # the pool only needs to supplement — 2+10+N Small is sufficient.
        location_count = len(location_table)
        xp_counts = {"Ancient Grimoire": 2, "Worn Tome": 10}
        for name, count in xp_counts.items():
            for _ in range(count):
                pool.append(self.create_item(name))
        while len(pool) < location_count:
            pool.append(self.create_item("Tattered Scroll"))

        self.multiworld.itempool += pool

    def create_regions(self) -> None:
        stages = _load_stages()
        # All stages get a region (needed for the region graph).
        # W1 has no AP item/locations but is the world entry point.
        all_stage_map = {s["str_id"]: s for s in stages}

        menu_region = Region("Menu", self.player, self.multiworld)
        self.multiworld.regions.append(menu_region)

        # Create one region per stage — every stage has AP locations (Journey + Bonus).
        # All locations are normal progress type; XP and token gates are on region connections.
        stage_regions: Dict[str, Region] = {}
        for str_id, stage in all_stage_map.items():
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

        # Connect Menu → W1 (starting stage — all other stages connect from W1 in set_rules)
        menu_region.connect(stage_regions["W1"], "Start")

    def set_rules(self) -> None:
        set_rules(self)

    def generate_basic(self) -> None:
        # Place the Victory event so the spoiler log shows A4 as the goal.
        victory_loc = self.multiworld.get_location("Complete A4 - Frostborn Wrath Victory", self.player)
        victory_loc.place_locked_item(
            GCFWItem("Victory", ItemClassification.progression, None, self.player)
        )

        # Skills stay in the shared item pool — placed anywhere by Archipelago's fill algorithm.

    @classmethod
    def stage_fill_hook(cls, multiworld, progitempool, usefulitempool, filleritempool, fill_locations):
        # goal: look at the TIER_REQUIREMENTS table and use that to force the fill to put enough stages of
        # each tier in order first before filling the rest of the items. this should make gens 100% consistent.

        # for each tier, in reverse order (hardcoded as 12 tiers right now; TODO make more robust)
        # (reverse order since progitempool is popped off of to choose items, so im moving items to the end;
        # so moving tier 11 to the end then tier 10 then etc etc down to tier 1 so that in the end tier 1's unlocks
        # are at the end, which means they will be placed first you get the idea)
        for t in range(12, 0, -1):
            prev_tier, level_req = TIER_REQUIREMENTS[t]
            moved_levels = 0
            # ok test time
            # level_req = len(TIERS[prev_tier])
            prog_idx = 0
            while moved_levels < level_req:
                this_item_name = progitempool[prog_idx].name
                if this_item_name.endswith(" Field Token"):
                    this_field = this_item_name[:2]
                    if this_field in TIERS[prev_tier]:
                        # move to end
                        # print(f"Moving {this_field} to end")
                        progitempool.append(progitempool.pop(prog_idx))

                        moved_levels += 1
                        prog_idx -= 1  # to counteract the +=1 below
                prog_idx += 1  # this should never exceed the length of the progitempool. assuming reasonable tier tables.

            # IF we want skills to appear earlier, then after each tier (except the very first tiers (0 or 1 (i was getting skills *too* early >_>))
            # move a skill into the space between this tier and the next tier.
            if t > 2:
                prog_idx = 0
                moved_skill = False
                while not moved_skill:
                    this_item_name = progitempool[prog_idx].name
                    if this_item_name.endswith(" Skill"):
                        # move to end
                        # print(f"Moving {this_field} to end")
                        progitempool.append(progitempool.pop(prog_idx))
                        moved_skill = True  # isnt this what continue is for. or break. idk im never confident in using those in nested loops lol
                    prog_idx += 1

        # print("PRINTING WHOLE PROG POOL IN ORDER:")
        # for i in progitempool:
        #     print(f"{i.name}")


    def fill_slot_data(self) -> Dict:
        stages = _load_stages()
        # Map item AP ID → stage str_id so the mod can call unlockStage() on receipt.
        # Field token map: item AP ID → stage str_id
        token_map = {
            str(s["item_ap_id"]): s["str_id"]
            for s in stages
            if s["item_ap_id"] is not None
        }
        # Free stages: W1 (starting, no token) + W2-W4 (tutorial zone, no token).
        # The mod should unlock these on connect.
        free_stages = [
            s["str_id"]
            for s in stages
            if s["item_ap_id"] is None
        ] + sorted(FREE_STAGES)
        return {
            "goal":                  self.options.goal.value,
            "token_map":             token_map,
            "free_stages":           free_stages,
            "force_early_skills":      bool(self.options.force_early_skills.value),
            "death_link":              bool(self.options.death_link.value),
            "death_link_punishment":   self.options.death_link_punishment.value,
            "gem_loss_percent":        self.options.gem_loss_percent.value,
            "wave_surge_count":        self.options.wave_surge_count.value,
            "wave_surge_gem_level":    self.options.wave_surge_gem_level.value,
            "death_link_grace_period": self.options.death_link_grace_period.value,
            "death_link_cooldown":     self.options.death_link_cooldown.value,
        }

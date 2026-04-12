from __future__ import annotations

import json
from dataclasses import dataclass
from importlib.resources import files
from typing import Dict

from BaseClasses import Location


class GCFWLocation(Location):
    game = "GemCraft: Frostborn Wrath"


@dataclass
class LocationData:
    id: int
    stage_str_id: str


def _load_location_table() -> Dict[str, LocationData]:
    data = json.loads(files(__package__).joinpath("data/game_data.json").read_text(encoding="utf-8"))

    table: Dict[str, LocationData] = {}

    for stage in data["stages"]:
        # All stages are completable and send AP checks — including W1 which has
        # no field token item but IS the starting location (accessible from Menu).
        str_id = stage["str_id"]
        table[f"Complete {str_id} - Journey"]      = LocationData(stage["loc_ap_id"],             str_id)
        table[f"Complete {str_id} - Bonus"]        = LocationData(stage["loc_ap_id"] + 500,       str_id)
        table[f"Complete {str_id} - Wizard stash"] = LocationData(stage["wiz_stash_loc_ap_id"],   str_id)

    return table


def _generate_achievement_locations() -> Dict[str, LocationData]:
    """Load achievement locations (IDs 1000-1635) from rulesdata packs with hardcoded ap_ids."""
    from .rulesdata_achievements_1 import achievement_requirements as pack1
    from .rulesdata_achievements_2 import achievement_requirements as pack2
    from .rulesdata_achievements_3 import achievement_requirements as pack3
    from .rulesdata_achievements_4 import achievement_requirements as pack4
    from .rulesdata_achievements_5 import achievement_requirements as pack5
    from .rulesdata_achievements_6 import achievement_requirements as pack6

    achievement_packs = [pack1, pack2, pack3, pack4, pack5, pack6]

    table: Dict[str, LocationData] = {}

    # Merge all packs
    all_achievements = {}
    for pack in achievement_packs:
        all_achievements.update(pack)

    # Use hardcoded ap_id from each achievement, sorted by name for consistency
    for ach_name in sorted(all_achievements.keys()):
        ach_data = all_achievements[ach_name]
        if "ap_id" in ach_data:
            loc_id = ach_data["ap_id"]
            # Achievements are not tied to a specific stage, use empty string
            table[f"Achievement: {ach_name}"] = LocationData(loc_id, "")

    return table


location_table: Dict[str, LocationData] = _load_location_table()
achievement_location_table: Dict[str, LocationData] = _generate_achievement_locations()

# Merge achievement locations into main location table
location_table.update(achievement_location_table)

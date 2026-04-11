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
    """Generate achievement locations (IDs 2000-2635) from rulesdata."""
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

    table: Dict[str, LocationData] = {}
    loc_id = 2000

    for tier in range(1, 6):
        for ach_name in sorted(achievements_by_tier[tier].keys()):
            # Achievements are not tied to a specific stage, use empty string
            table[f"Achievement: {ach_name}"] = LocationData(loc_id, "")
            loc_id += 1

    return table


location_table: Dict[str, LocationData] = _load_location_table()
achievement_location_table: Dict[str, LocationData] = _generate_achievement_locations()

# Merge achievement locations into main location table
location_table.update(achievement_location_table)

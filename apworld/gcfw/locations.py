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
        table[f"Complete {str_id} - Journey"] = LocationData(stage["loc_ap_id"],       str_id)
        table[f"Complete {str_id} - Bonus"]   = LocationData(stage["loc_ap_id"] + 500, str_id)

    return table


location_table: Dict[str, LocationData] = _load_location_table()

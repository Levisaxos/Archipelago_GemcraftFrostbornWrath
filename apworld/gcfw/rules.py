from __future__ import annotations

import json
from importlib.resources import files
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from . import GemcraftFrostbornWrathWorld


def _load_stages():
    data = json.loads(files(__package__).joinpath("data/game_data.json").read_text(encoding="utf-8"))
    return data["stages"]


# Stages with no parent in the unlock graph — treated as always accessible from start.
ORPHANED_STAGES = {"Z1", "Z2", "Z3", "Z4", "I2", "I3", "I4", "F3", "F4"}


def set_rules(world: "GemcraftFrostbornWrathWorld") -> None:
    """Connect stage regions and assign access rules based on the field token dependency graph."""
    player = world.player
    multiworld = world.multiworld
    stages = _load_stages()

    # Build str_id → stage lookup
    stage_map = {s["str_id"]: s for s in stages if s["loc_ap_id"] <= 109}

    menu_region = multiworld.get_region("Menu", player)

    for stage in stages:
        if stage["loc_ap_id"] > 109:
            continue

        str_id = stage["str_id"]
        parent_region = multiworld.get_region(str_id, player)

        for child_id in stage.get("unlocks", []):
            if child_id not in stage_map:
                continue  # child is SECRET/trial, skip

            child_region = multiworld.get_region(child_id, player)
            child_stage = stage_map[child_id]
            child_token = child_stage["item_ap_id"]

            if child_token is not None:
                token_name = f"{child_id} Field Token"
                connection = parent_region.connect(child_region, f"{str_id} -> {child_id}")
                connection.access_rule = (
                    lambda state, tok=token_name: state.has(tok, player)
                )
            else:
                # Child has no token requirement (shouldn't happen for non-W1 stages, but be safe)
                parent_region.connect(child_region, f"{str_id} -> {child_id}")

        # Orphaned stages and W1 connect from Menu (handled in create_regions)

    # Goal: reach A4
    goal_location = multiworld.get_location("Complete A4 - Journey", player)
    multiworld.completion_condition[player] = lambda state: state.can_reach(
        goal_location, "Location", player
    )

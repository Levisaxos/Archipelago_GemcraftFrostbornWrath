from __future__ import annotations

import json
from importlib.resources import files
from typing import TYPE_CHECKING

from .rulesdata import STAGE_RULES, WIZARD_LEVEL_GATING_ENABLED

if TYPE_CHECKING:
    from . import GemcraftFrostbornWrathWorld


def _wizard_level(state, player: int) -> int:
    """Total wizard levels from all XP Bonus items the player has received."""
    return (
        state.count("Tattered Scroll",  player) * 1 +
        state.count("Worn Tome",         player) * 3 +
        state.count("Ancient Grimoire",  player) * 9
    )


def set_rules(world: "GemcraftFrostbornWrathWorld") -> None:
    """
    Apply access rules to all regions and locations.

    Region connections: W1 → every other stage, gated by that stage's field token.
    Location rules: wizard-level threshold + WIZLOCK skill requirements from STAGE_RULES.
    Victory: A4 reachable AND all 24 skills collected.
    """
    player = world.player
    multiworld = world.multiworld

    data = json.loads(files(__package__).joinpath("data/game_data.json").read_text(encoding="utf-8"))
    stages = data["stages"]
    stage_map = {s["str_id"]: s for s in stages}

    w1_region = multiworld.get_region("W1", player)

    # --- Region connections: W1 → every non-W1 stage, gated by field token only ---
    for stage in stages:
        str_id = stage["str_id"]
        if str_id == "W1":
            continue
        child_region = multiworld.get_region(str_id, player)
        token = stage.get("item_ap_id")
        connection = w1_region.connect(child_region, f"W1 -> {str_id}")
        if token is not None:
            token_name = f"{str_id} Field Token"
            connection.access_rule = lambda state, tok=token_name: state.has(tok, player)

    # --- Location rules: wizard level + WIZLOCK skill requirements ---
    for str_id in stage_map:
        rule = STAGE_RULES.get(str_id)
        if rule is None:
            continue

        conditions = []

        if WIZARD_LEVEL_GATING_ENABLED and rule.min_wizard_level > 0:
            conditions.append(
                lambda state, t=rule.min_wizard_level: _wizard_level(state, player) >= t
            )

        for skill in rule.skills:
            item_name = f"{skill} Skill"
            conditions.append(lambda state, i=item_name: state.has(i, player))

        if not conditions:
            continue

        def make_rule(conds):
            return lambda state: all(c(state) for c in conds)

        for suffix in ("Journey", "Bonus"):
            loc_name = f"Complete {str_id} - {suffix}"
            location = multiworld.get_location(loc_name, player)
            location.access_rule = make_rule(conditions)

    # --- Victory: A4 accessible AND all 24 skills collected ---
    all_skill_names = [f"{skill['name']} Skill" for skill in data["skills"]]
    victory_location = multiworld.get_location("Complete A4 - Frostborn Wrath Victory", player)
    victory_location.access_rule = lambda state: all(state.has(s, player) for s in all_skill_names)

    multiworld.completion_condition[player] = lambda state: state.has("Victory", player)

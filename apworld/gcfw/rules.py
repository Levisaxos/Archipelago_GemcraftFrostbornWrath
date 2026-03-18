from __future__ import annotations

import json
from importlib.resources import files
from typing import TYPE_CHECKING

from .rulesdata import DEFAULT_RULE, STAGE_RULES

if TYPE_CHECKING:
    from . import GemcraftFrostbornWrathWorld


# Tune this to make XP requirements harder or easier.
# min_xp for a stage = wave_count * XP_PER_WAVE
# XP item values: Small=1, Medium=3, Large=9
XP_PER_WAVE: int = 2

# Stages with no parent in the unlock graph — treated as always accessible from start.
ORPHANED_STAGES = {"Z1", "Z2", "Z3", "Z4", "I2", "I3", "I4", "F3", "F4"}


def _load_stages():
    data = json.loads(files(__package__).joinpath("data/game_data.json").read_text(encoding="utf-8"))
    return data["stages"]


def _xp_score(state, player: int) -> int:
    """Total XP score from all XP Bonus items the player has received."""
    return (
        state.count("Small XP Bonus",  player) * 1 +
        state.count("Medium XP Bonus", player) * 3 +
        state.count("Large XP Bonus",  player) * 9
    )


def set_rules(world: "GemcraftFrostbornWrathWorld") -> None:
    """Connect stage regions and assign access rules based on the field token
    dependency graph, plus gem/skill/XP requirements from rulesdata and wave counts."""
    player = world.player
    multiworld = world.multiworld
    stages = _load_stages()

    # Build str_id → stage lookup
    stage_map = {s["str_id"]: s for s in stages if s["loc_ap_id"] <= 109}

    # --- Region connections: field token gates ---
    for stage in stages:
        if stage["loc_ap_id"] > 109:
            continue

        str_id = stage["str_id"]
        parent_region = multiworld.get_region(str_id, player)

        for child_id in stage.get("unlocks", []):
            if child_id not in stage_map:
                continue  # SECRET/trial-locked, skip

            child_region = multiworld.get_region(child_id, player)
            child_token = stage_map[child_id]["item_ap_id"]

            if child_token is not None:
                token_name = f"{child_id} Field Token"
                connection = parent_region.connect(child_region, f"{str_id} -> {child_id}")
                connection.access_rule = (
                    lambda state, tok=token_name: state.has(tok, player)
                )
            else:
                parent_region.connect(child_region, f"{str_id} -> {child_id}")

    # --- Orphaned stages: connect from W1, gated by their own field token ---
    # These stages have no parent in the unlock graph. Rather than connecting them
    # from Menu (which would flood sphere 0 and dilute W1's required progression),
    # we attach them to W1 so their tokens must be found on the critical path first.
    w1_region = multiworld.get_region("W1", player)
    for str_id in ORPHANED_STAGES:
        if str_id not in stage_map:
            continue
        child_region = multiworld.get_region(str_id, player)
        child_token = stage_map[str_id]["item_ap_id"]
        if child_token is not None:
            token_name = f"{str_id} Field Token"
            connection = w1_region.connect(child_region, f"W1 -> {str_id} (orphan)")
            connection.access_rule = (
                lambda state, tok=token_name: state.has(tok, player)
            )
        else:
            w1_region.connect(child_region, f"W1 -> {str_id} (orphan)")

    # --- Location rules: gem / skill / XP requirements ---
    for str_id, stage in stage_map.items():
        conditions = []

        # Auto-wire WIZLOCK skill requirements from game_data (e.g. L5: Freeze/Bolt/Beam/Barrage)
        for skill in stage.get("required_skills", []):
            item_name = f"{skill} Skill"
            conditions.append(lambda state, i=item_name: state.has(i, player))

        # STAGE_RULES / DEFAULT_RULE overrides (gems, skills, XP)
        rule = STAGE_RULES.get(str_id, DEFAULT_RULE)
        if rule is not None:
            for gem in rule.gems:
                item_name = f"{gem} Gem Unlock"
                conditions.append(lambda state, i=item_name: state.has(i, player))

            for skill in rule.skills:
                item_name = f"{skill} Skill"
                conditions.append(lambda state, i=item_name: state.has(i, player))

            # XP gate: use manual override if set, otherwise derive from wave count
            min_xp = rule.min_xp if rule.min_xp > 0 else stage.get("wave_count", 0) * XP_PER_WAVE
            if min_xp > 0:
                threshold = min_xp
                conditions.append(lambda state, t=threshold: _xp_score(state, player) >= t)

        if not conditions:
            continue

        def make_rule(conds):
            return lambda state: all(c(state) for c in conds)

        for suffix in ("Journey", "Bonus"):
            loc_name = f"Complete {str_id} - {suffix}"
            location = multiworld.get_location(loc_name, player)
            location.access_rule = make_rule(conditions)

    # Goal: Victory event requires A4 to be reachable AND all 24 skills collected.
    # The Victory item is placed at "Complete A4 - Frostborn Wrath Victory" inside the A4 region,
    # so reaching it already implies A4 is accessible. The skills check is the extra gate.
    data = json.loads(files(__package__).joinpath("data/game_data.json").read_text(encoding="utf-8"))
    all_skill_names = [f"{skill['name']} Skill" for skill in data["skills"]]

    victory_location = multiworld.get_location("Complete A4 - Frostborn Wrath Victory", player)
    victory_location.access_rule = lambda state: all(state.has(skill, player) for skill in all_skill_names)

    multiworld.completion_condition[player] = lambda state: state.has("Victory", player)

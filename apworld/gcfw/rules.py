from __future__ import annotations

import json
from importlib.resources import files
from typing import TYPE_CHECKING

from .rulesdata import DEFAULT_RULE, STAGE_RULES, min_wizard_level_for_waves

if TYPE_CHECKING:
    from . import GemcraftFrostbornWrathWorld


# Wizard-level requirements are applied to LOCATIONS (not region connections).
# Region connections are gated by the field token ONLY, so every token placed
# immediately opens that stage's region and advances the sphere. Wizard-level
# gates control whether the checks inside that stage can be collected.
# XP item values: Small=2, Medium=5, Large=10 wizard levels.
# Tier table lives in rulesdata.WIZARD_LEVEL_TIERS (editable without touching code).


def _load_stages():
    data = json.loads(files(__package__).joinpath("data/game_data.json").read_text(encoding="utf-8"))
    return data["stages"]


def _wizard_level(state, player: int) -> int:
    """Total wizard levels from all XP Bonus items the player has received."""
    return (
        state.count("Small XP Bonus",  player) * 2 +
        state.count("Medium XP Bonus", player) * 5 +
        state.count("Large XP Bonus",  player) * 10
    )


def set_rules(world: "GemcraftFrostbornWrathWorld") -> None:
    """Connect all stages from W1 gated by field token only. Wizard-level
    requirements are placed on the locations inside each stage."""
    player = world.player
    multiworld = world.multiworld
    stages = _load_stages()

    stage_map = {s["str_id"]: s for s in stages}
    w1_region = multiworld.get_region("W1", player)

    # --- Region connections: W1 → every non-W1 stage, token only ---
    # Wizard levels are NOT on connections — putting them here would prevent a
    # token from opening new locations until levels are also present,
    # deadlocking the fill.
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

    # --- Location rules: wizard levels (tier table) + gem / skill requirements ---
    for str_id, stage in stage_map.items():
        rule = STAGE_RULES.get(str_id, DEFAULT_RULE)

        # Wizard level threshold: STAGE_RULES override takes priority over tier table.
        waves = stage.get("wave_count") or 0
        if rule is not None and rule.min_xp > 0:
            min_wiz = rule.min_xp
        else:
            min_wiz = min_wizard_level_for_waves(waves)

        conditions = []

        if min_wiz > 0:
            conditions.append(lambda state, t=min_wiz: _wizard_level(state, player) >= t)

        # Auto-wire WIZLOCK skill requirements from game_data
        for skill in stage.get("required_skills", []):
            item_name = f"{skill} Skill"
            conditions.append(lambda state, i=item_name: state.has(i, player))

        # STAGE_RULES gem / skill overrides
        if rule is not None:
            for gem in rule.gems:
                item_name = f"{gem} Gem Unlock"
                conditions.append(lambda state, i=item_name: state.has(i, player))

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

    # Goal: Victory requires A4 reachable AND all 24 skills collected.
    data = json.loads(files(__package__).joinpath("data/game_data.json").read_text(encoding="utf-8"))
    all_skill_names = [f"{skill['name']} Skill" for skill in data["skills"]]

    victory_location = multiworld.get_location("Complete A4 - Frostborn Wrath Victory", player)
    victory_location.access_rule = lambda state: all(state.has(skill, player) for skill in all_skill_names)

    multiworld.completion_condition[player] = lambda state: state.has("Victory", player)

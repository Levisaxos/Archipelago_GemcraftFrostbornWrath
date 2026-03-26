from __future__ import annotations

import json
from importlib.resources import files
from typing import TYPE_CHECKING, List

from .rulesdata import FREE_STAGES, STAGE_RULES, TIERS, TIER_REQUIREMENTS

if TYPE_CHECKING:
    from . import GemcraftFrostbornWrathWorld


def _has_tier_tokens(state, player: int, tier_token_names: List[str], count: int) -> bool:
    """Check whether the player has collected at least *count* field tokens
    from the given list of tier token names."""
    return sum(1 for name in tier_token_names if state.has(name, player)) >= count


def set_rules(world: "GemcraftFrostbornWrathWorld") -> None:
    """
    Apply access rules to all regions and locations.

    Region connections (from W1 hub):
      - FREE_STAGES (W2-W5): no token or tier requirement (tutorial zone).
      - Other Tier 0 stages: own field token only (no tier gate).
      - Tier 1+ stages: own field token AND N tokens from previous tier.
    Location rules: WIZLOCK skill requirements only (L5).
    Victory: A4 reachable AND all 24 skills collected.
    """
    player = world.player
    multiworld = world.multiworld

    data = json.loads(files(__package__).joinpath("data/game_data.json").read_text(encoding="utf-8"))
    stages = data["stages"]
    stage_map = {s["str_id"]: s for s in stages}

    w1_region = multiworld.get_region("W1", player)

    # Pre-build token name lists per tier for use in access rules.
    tier_token_names: dict[int, List[str]] = {}
    for tier_num, stage_ids in TIERS.items():
        tier_token_names[tier_num] = [f"{sid} Field Token" for sid in stage_ids]

    # --- Region connections: W1 → every non-W1 stage ---
    for stage in stages:
        str_id = stage["str_id"]
        if str_id == "W1":
            continue
        child_region = multiworld.get_region(str_id, player)
        connection = w1_region.connect(child_region, f"W1 -> {str_id}")

        rule = STAGE_RULES.get(str_id)
        tier = rule.tier if rule else 0
        token_name = f"{str_id} Field Token"

        if str_id in FREE_STAGES:
            # Free stages (W2-W5): accessible from W1 with no requirements.
            # Their tokens still exist as items for Tier 1 gate.
            pass
        elif tier == 0:
            # Other Tier 0: require own field token only (no tier gate).
            connection.access_rule = (
                lambda state, tok=token_name: state.has(tok, player)
            )
        else:
            # Tier 1+: require own field token + N tokens from previous tier.
            prev_tier, tokens_needed = TIER_REQUIREMENTS[tier]
            prev_tokens = tier_token_names[prev_tier]
            connection.access_rule = (
                lambda state, tok=token_name, pt=prev_tokens, n=tokens_needed: (
                    state.has(tok, player) and _has_tier_tokens(state, player, pt, n)
                )
            )

    # --- Location rules: WIZLOCK skill requirements only ---
    for str_id, rule in STAGE_RULES.items():
        if not rule.skills:
            continue

        conditions = []
        for skill in rule.skills:
            item_name = f"{skill} Skill"
            conditions.append(lambda state, i=item_name: state.has(i, player))

        def make_rule(conds):
            return lambda state: all(c(state) for c in conds)

        for suffix in ("Journey", "Bonus"):
            loc_name = f"Complete {str_id} - {suffix}"
            location = multiworld.get_location(loc_name, player)
            location.access_rule = make_rule(conditions)

    # --- A4 locations + Victory: require all 24 skills ---
    all_skill_names = [f"{skill['name']} Skill" for skill in data["skills"]]
    all_skills_rule = lambda state: all(state.has(s, player) for s in all_skill_names)

    for suffix in ("Journey", "Bonus"):
        loc = multiworld.get_location(f"Complete A4 - {suffix}", player)
        existing_rule = loc.access_rule
        loc.access_rule = lambda state, er=existing_rule: er(state) and all_skills_rule(state)

    victory_location = multiworld.get_location("Complete A4 - Frostborn Wrath Victory", player)
    victory_location.access_rule = all_skills_rule

    multiworld.completion_condition[player] = lambda state: state.has("Victory", player)

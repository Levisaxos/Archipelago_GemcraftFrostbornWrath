from __future__ import annotations

import json
from importlib.resources import files
from typing import TYPE_CHECKING, List

from .rulesdata import GAME_DATA, FREE_STAGES, SKILL_CATEGORIES, STAGE_RULES, TIERS, TIER_REQUIREMENTS, TIER_SKILL_REQUIREMENTS

if TYPE_CHECKING:
    from . import GemcraftFrostbornWrathWorld


# Pre-build token name lists per tier for use in access rules.
# this is never gonna change just make it a global instead of rebuilding it every time set_rules is run
TIER_TOKEN_NAMES: dict[int, List[str]] = {}
for tier_num, stage_ids in TIERS.items():
    TIER_TOKEN_NAMES[tier_num] = [f"{sid} Field Token" for sid in stage_ids]

# Pre-build skill name lists per category.
TIER_SKILL_NAMES: dict[str, List[str]] = {
    cat: [f"{s} Skill" for s in skills]
    for cat, skills in SKILL_CATEGORIES.items()
}


def _has_tier_tokens(state, player: int, tier: int, token_percent: int) -> bool:
    """Check whether the player has collected enough field tokens from the
    previous tier AND at least one skill from each required skill category
    for this tier (and all lower tiers, recursively)."""
    prev = tier-1
    count = len(TIERS[prev]) * token_percent // 100
    # Check token requirement from previous tier.
    if sum(1 for name in TIER_TOKEN_NAMES[prev] if state.has(name, player)) < count:
        return False
    # Check skill category requirements for this tier.
    for category in TIER_SKILL_REQUIREMENTS.get(tier, []):
        if not state.has_any(TIER_SKILL_NAMES[category], player):
            return False
    # Recurse to ensure all lower tiers are also satisfied.
    if prev == 0:
        return True
    return _has_tier_tokens(state, player, prev, token_percent)


def set_rules(world: "GemcraftFrostbornWrathWorld") -> None:
    """
    Apply access rules to all regions and locations.

    Region connections (from W1 hub):
      - FREE_STAGES (W2-W4): no token or tier requirement (tutorial zone).
      - Other Tier 0 stages: own field token only (no tier gate).
      - Tier 1+ stages: own field token AND N tokens from previous tier. (AND prev tier unlocked)
    Location rules: WIZLOCK skill requirements only (L5).
    Victory: A4 reachable AND all 24 skills collected.
    """
    player = world.player
    multiworld = world.multiworld

    stages = GAME_DATA["stages"]
    stage_map = {s["str_id"]: s for s in stages}

    token_percent = world.options.tier_requirements_percent.value

    w1_region = multiworld.get_region("W1", player)

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

        # print(f"{token_name}: tier {tier}")
        if str_id in FREE_STAGES:
            # Free stages (W2-W4): accessible from W1 with no requirements.
            # They have no token items; the mod unlocks them on connect.
            pass
        elif tier == 0:
            # Other Tier 0: require own field token only (no tier gate).
            connection.access_rule = (
                lambda state, tok=token_name: state.has(tok, player)
            )
        else:
            # Tier 1+: require own field token + N tokens from previous tier.
            # prev_tier, tokens_needed = TIER_REQUIREMENTS[tier]
            # prev_tokens = tier_token_names[prev_tier]
            connection.access_rule = (
                lambda state, tok=token_name, ti=tier, tper = token_percent: (
                    state.has(tok, player) and _has_tier_tokens(state, player, ti, tper)
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
    all_skill_names = [f"{skill['name']} Skill" for skill in GAME_DATA["skills"]]
    all_skills_rule = lambda state: all(state.has(s, player) for s in all_skill_names)

    for suffix in ("Journey", "Bonus"):
        loc = multiworld.get_location(f"Complete A4 - {suffix}", player)
        existing_rule = loc.access_rule
        loc.access_rule = lambda state, er=existing_rule: er(state) and all_skills_rule(state)

    if world.options.goal.value == 0:
        victory_location = multiworld.get_location("Complete A4 - Frostborn Wrath Victory", player)
        victory_location.access_rule = all_skills_rule
    # full_talisman victory has no access rule — fragments drop from any battle

    multiworld.completion_condition[player] = lambda state: state.has("Victory", player)

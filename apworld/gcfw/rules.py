from __future__ import annotations

import json
from importlib.resources import files
from typing import TYPE_CHECKING, List

from .rulesdata import GAME_DATA, FREE_STAGES, SKILL_CATEGORIES, STAGE_RULES, TIERS, CUMULATIVE_SKILL_REQUIREMENTS
from .rulesdata_settings import WAVE_TIERS, GRINDINESS_TIERS, game_skills_categories, game_level_elements, non_monster_elements, skill_groups
from .rulesdata_goals import goal_requirements
from .rulesdata_levels import level_requirements as LEVEL_DATA
from .options import AchievementProgression

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


def _has_tier_tokens(state, player: int, tier: int, token_percent: int,
                     skill_reqs_enabled: bool = False) -> bool:
    """Check whether the player has collected enough field tokens from the
    previous tier AND (if skill_reqs_enabled) the required skills for this tier."""
    prev = tier-1
    count = len(TIERS[prev]) * token_percent // 100
    # Check token requirement from previous tier.
    if sum(1 for name in TIER_TOKEN_NAMES[prev] if state.has(name, player)) < count:
        return False
    if skill_reqs_enabled:
        # Check skill category requirements for this tier.
        for category, count_req in CUMULATIVE_SKILL_REQUIREMENTS.get(tier, {}).items():
            total_category = [state.has(skill_name, player) for skill_name in TIER_SKILL_NAMES[category]].count(True)
            if total_category < count_req:
                return False
    # Recurse to ensure all lower tiers are also satisfied.
    if prev == 0:
        if skill_reqs_enabled:
            for category, count_req in CUMULATIVE_SKILL_REQUIREMENTS.get(0, {}).items():
                total_category = [state.has(s, player) for s in TIER_SKILL_NAMES[category]].count(True)
                if total_category < count_req:
                    return False
        return True
    return _has_tier_tokens(state, player, prev, token_percent, skill_reqs_enabled)


def _normalize_requirements(requirements: list) -> list:
    """Convert requirements to DNF: list of AND-groups (outer=OR, inner=AND).
    Flat list of strings is treated as a single AND-group for backward compatibility."""
    if not requirements:
        return []
    if isinstance(requirements[0], list):
        return requirements
    return [requirements]


def _simplify_requirements(normalized: list) -> list:
    """If any AND-group contains a trait requirement, strip element reqs from all groups.
    Prevents circular dependencies where trait items may sit behind element-locked locations."""
    has_trait = any(" trait" in req.lower() for group in normalized for req in group)
    if not has_trait:
        return normalized
    return [[req for req in group if not req.endswith(" element")] for group in normalized]


def _can_reach_any_stage(state, player: int, stages: list) -> bool:
    """Return True if the player can reach any completion location across the given stages."""
    for stage in stages:
        for suffix in ("Journey", "Bonus", "Wizard stash"):
            try:
                if state.can_reach(f"Complete {stage} - {suffix}", "Location", player):
                    return True
            except KeyError:
                pass
    return False


def _is_gating_req(req: str, is_progressive: bool) -> bool:
    """Return True if this requirement string actually gates access to something."""
    req = req.strip()
    if req.startswith("Achievement:"):
        return is_progressive
    if req.endswith(" element"):
        elem_name = req[:-8]
        return (elem_name in non_monster_elements or
                (elem_name in game_level_elements and bool(game_level_elements[elem_name].get("levels"))))
    if ":" in req:
        group_name = req.split(":")[0].strip()
        if group_name in skill_groups or group_name in game_skills_categories:
            return True
        return group_name in ("minWave", "minMonsters", "minMonsterHP", "minMonsterArmor", "minSwarmlingArmor", "Skills")
    if " trait" in req.lower() or " skill" in req.lower():
        skill_name = req.replace(" skill", "").replace(" Skill", "").replace(" trait", "").replace(" Trait", "").strip()
        return any(skill_name in cat.get("members", []) for cat in game_skills_categories.values())
    return False


def _eval_req(req: str, state, player: int, is_progressive: bool) -> bool:
    """Evaluate a single requirement string against the current collection state."""
    req = req.strip()

    if req.startswith("Achievement:"):
        return state.has(req, player) if is_progressive else True

    if req.endswith(" element"):
        elem_name = req[:-8]
        if elem_name in non_monster_elements:
            trait = non_monster_elements[elem_name].get("requires_trait")
            if trait:
                return state.has(f"{trait} Battle Trait", player)
            return _can_reach_any_stage(state, player, non_monster_elements[elem_name].get("levels", []))
        if elem_name in game_level_elements:
            stages = game_level_elements[elem_name].get("levels", [])
            if stages:
                return _can_reach_any_stage(state, player, stages)
        return True

    if ":" in req:
        group_name, count_str = req.split(":", 1)
        group_name = group_name.strip()
        try:
            count_needed = int(count_str.strip())
        except ValueError:
            return True
        if group_name in skill_groups:
            members = skill_groups[group_name].get("members", [])
            return sum(1 for m in members if state.has(f"{m} Skill", player)) >= count_needed
        if group_name in game_skills_categories:
            members = game_skills_categories[group_name].get("members", [])
            suffix = " Battle Trait" if group_name == "BattleTraits" else " Skill"
            return sum(1 for m in members if state.has(f"{m}{suffix}", player)) >= count_needed
        if group_name == "Skills":
            all_skill_names = [m for cat in game_skills_categories.values() for m in cat.get("members", [])]
            suffix_map = {m: (" Battle Trait" if cat == "BattleTraits" else " Skill")
                          for cat, data in game_skills_categories.items() for m in data.get("members", [])}
            return sum(1 for m in all_skill_names if state.has(f"{m}{suffix_map[m]}", player)) >= count_needed
        if group_name == "minWave":
            qualifying = [sid for sid, d in LEVEL_DATA.items() if d.get("wave_count", 0) >= count_needed]
            return _can_reach_any_stage(state, player, qualifying)
        if group_name == "minMonsters":
            qualifying = [sid for sid, d in LEVEL_DATA.items() if d.get("estMonsters", 0) >= count_needed]
            return _can_reach_any_stage(state, player, qualifying)
        if group_name == "minMonsterHP":
            qualifying = [sid for sid, d in LEVEL_DATA.items()
                          if max(d.get("maxGiantHP", 0), d.get("maxReaverHP", 0)) >= count_needed]
            return _can_reach_any_stage(state, player, qualifying)
        if group_name == "minMonsterArmor":
            qualifying = [sid for sid, d in LEVEL_DATA.items()
                          if max(d.get("maxGiantArmor", 0), d.get("maxReaverArmor", 0)) >= count_needed]
            return _can_reach_any_stage(state, player, qualifying)
        if group_name == "minSwarmlingArmor":
            qualifying = [sid for sid, d in LEVEL_DATA.items() if d.get("maxSwarmlingArmor", 0) >= count_needed]
            return _can_reach_any_stage(state, player, qualifying)
        return True  # Unknown counter (fieldToken, gemCount, etc.) — metadata only

    if " trait" in req.lower() or " skill" in req.lower():
        skill_name = req.replace(" skill", "").replace(" Skill", "").replace(" trait", "").replace(" Trait", "").strip()
        for category, category_data in game_skills_categories.items():
            if skill_name in category_data.get("members", []):
                suffix = " Battle Trait" if category == "BattleTraits" else " Skill"
                return state.has(f"{skill_name}{suffix}", player)

    return True  # Metadata requirement (gemCount, minWave, etc.) — not gated


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
    skill_reqs_enabled = bool(world.options.tier_skill_requirements.value)

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
            if skill_reqs_enabled:
                gem_reqs = CUMULATIVE_SKILL_REQUIREMENTS.get(0, {})
                connection.access_rule = (
                    lambda state, tok=token_name, reqs=gem_reqs: (
                        state.has(tok, player) and
                        all(
                            sum(1 for s in TIER_SKILL_NAMES[cat] if state.has(s, player)) >= n
                            for cat, n in reqs.items() if n > 0
                        )
                    )
                )
            else:
                connection.access_rule = (
                    lambda state, tok=token_name: state.has(tok, player)
                )
        else:
            # Tier 1+: require own field token + N tokens from previous tier.
            connection.access_rule = (
                lambda state, tok=token_name, ti=tier, tper=token_percent, sre=skill_reqs_enabled: (
                    state.has(tok, player) and _has_tier_tokens(state, player, ti, tper, sre)
                )
            )

    # --- Location rules: WIZLOCK skill requirements only ---
    for str_id, rule in STAGE_RULES.items():
        if not rule.skills:
            continue

        conditions = []
        for skill in rule.skills:
            if ":" in skill:
                group_name, count_str = skill.split(":", 1)
                group_name = group_name.strip()
                count_needed = int(count_str.strip())
                if group_name in skill_groups:
                    group_members = skill_groups[group_name].get("members", [])
                    conditions.append(lambda state, mems=group_members, n=count_needed:
                        sum(1 for m in mems if state.has(f"{m} Skill", player)) >= n)
            else:
                item_name = f"{skill} Skill"
                conditions.append(lambda state, i=item_name: state.has(i, player))

        def make_rule(conds):
            return lambda state: all(c(state) for c in conds)

        for suffix in ("Journey", "Bonus"):
            loc_name = f"Complete {str_id} - {suffix}"
            location = multiworld.get_location(loc_name, player)
            location.access_rule = make_rule(conditions)

    # --- Victory location rules ---
    # References goal_requirements from rulesdata_goals.py for definitions

    goal_value = world.options.goal.value

    if goal_value == 0:
        # kill_gatekeeper: Requires completing A4 - Journey (tier 12)
        req = goal_requirements["kill_gatekeeper"]
        a4_journey_loc = "Complete A4 - Journey"
        victory_location = multiworld.get_location("Complete A4 - Frostborn Wrath Victory", player)
        victory_location.access_rule = lambda state, loc=a4_journey_loc: state.can_reach(loc, "Location", player)

    elif goal_value == 1:
        # full_talisman: No access rule — fragments drop from any battle, player chooses when to claim
        pass

    elif goal_value == 2:
        # kill_swarm_queen: Requires completing K4 - Journey (tier 4)
        req = goal_requirements["kill_swarm_queen"]
        k4_journey_loc = "Complete K4 - Journey"
        victory_location = multiworld.get_location("Kill Swarm Queen Victory", player)
        victory_location.access_rule = lambda state, loc=k4_journey_loc: state.can_reach(loc, "Location", player)

    elif goal_value == 3:
        # fields_count: Complete N specific stages (configurable)
        req = goal_requirements["fields_count"]
        required = world.options.fields_required.value
        journey_locs = [f"Complete {s['str_id']} - Journey" for s in stages]
        victory_location = multiworld.get_location("Fields Count Victory", player)
        victory_location.access_rule = lambda state, locs=journey_locs, req=required: \
            sum(1 for loc in locs if state.can_reach(loc, "Location", player)) >= req

    elif goal_value == 4:
        # fields_percentage: Complete X% of all stages (configurable)
        from math import floor
        req = goal_requirements["fields_percentage"]
        required = floor(world.options.fields_required_percentage.value * len(stages) / 100)
        journey_locs = [f"Complete {s['str_id']} - Journey" for s in stages]
        victory_location = multiworld.get_location("Fields Percentage Victory", player)
        victory_location.access_rule = lambda state, locs=journey_locs, req=required: \
            sum(1 for loc in locs if state.can_reach(loc, "Location", player)) >= req

    # --- Achievement location access rules ---
    try:
        from .rulesdata_achievements import achievement_requirements as all_achievements

        is_progressive = world.options.achievement_progression.value == AchievementProgression.option_progressive
        max_effort_level = world.options.achievement_required_effort.value
        effort_hierarchy = ["Trivial", "Minor", "Major", "Extreme"]
        max_effort_index = min(max_effort_level - 1, len(effort_hierarchy) - 1)
        max_effort_str = effort_hierarchy[max_effort_index] if max_effort_level > 0 else None

        for ach_name, ach_data in all_achievements.items():
            ach_effort = ach_data.get("required_effort", "Trivial")
            if max_effort_str:
                effort_index = effort_hierarchy.index(ach_effort) if ach_effort in effort_hierarchy else 0
                max_index = effort_hierarchy.index(max_effort_str) if max_effort_str in effort_hierarchy else 0
                if effort_index > max_index:
                    continue

            if ach_data.get("always_as_filler", False):
                continue

            try:
                location = multiworld.get_location(f"Achievement: {ach_name}", player)
                raw = ach_data.get("requirements", [])
                normalized = _simplify_requirements(_normalize_requirements(raw))

                has_gating = any(
                    _is_gating_req(req, is_progressive)
                    for group in normalized
                    for req in group
                )
                if has_gating:
                    def make_rule(groups, prog):
                        return lambda state: any(
                            all(_eval_req(r, state, player, prog) for r in group)
                            for group in groups
                        )
                    location.access_rule = make_rule(normalized, is_progressive)

            except Exception:
                pass

    except Exception as e:
        print(f"ERROR setting achievement access rules: {e}")
        import traceback
        traceback.print_exc()

    multiworld.completion_condition[player] = lambda state: state.has("Victory", player)

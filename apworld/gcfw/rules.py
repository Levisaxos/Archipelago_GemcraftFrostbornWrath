from __future__ import annotations

import json
from importlib.resources import files
from typing import TYPE_CHECKING, List

from .rulesdata import GAME_DATA, FREE_STAGES, SKILL_CATEGORIES, STAGE_RULES, TIERS, CUMULATIVE_SKILL_REQUIREMENTS
from .rulesdata_settings import WAVE_TIERS, GRINDINESS_TIERS, game_skills_categories, game_level_elements, non_monster_elements, skill_groups
from .rulesdata_goals import goal_requirements
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
    for category, count_req in CUMULATIVE_SKILL_REQUIREMENTS.get(tier, []).items():
        total_category = [state.has(skill_name, player) for skill_name in TIER_SKILL_NAMES[category]].count(True)
        if total_category < count_req:
            return False
    # Recurse to ensure all lower tiers are also satisfied.
    if prev == 0:
        return True
    return _has_tier_tokens(state, player, prev, token_percent)


def _extract_skill_requirements(requirements: list) -> list:
    """
    Extract skill names from achievement requirements.
    Returns list of skill item names like ["Critical Hit Skill", "Poison Skill"] or ["Ritual Battle Trait"].
    Traits are formatted as "{trait_name} Battle Trait" while skills use "{skill_name} Skill".

    Supports skill group counters:
    - "Freeze skill" → ["Freeze Skill"] (single requirement)
    - "strikeSpells: 1" → ["strikeSpells: 1"] (need 1 strike spell)
    - "enhancementSpells: 2" → ["enhancementSpells: 2"] (need 2 enhancement spells)
    - "gemTypes: 1" → ["gemTypes: 1"] (need 1 gem type)

    Supports OR logic with pipe-separated requirements (for non-skill contexts):
    - "Achievement: X|Achievement: Y" → [("Achievement: X", "Achievement: Y")] (OR tuple)
    """
    skill_requirements = []

    for req in requirements:
        req = req.strip()

        # Skip achievement requirements (handled separately)
        if req.startswith("Achievement:"):
            continue

        # Check for skill group counter requirements (e.g., "strikeSpells: 1")
        is_group_counter = False
        for group_name in skill_groups.keys():
            if req.startswith(f"{group_name}:"):
                skill_requirements.append(req)
                is_group_counter = True
                break

        if is_group_counter:
            continue

        # Handle single skill/trait requirements
        is_trait = " trait" in req.lower()
        is_skill = " skill" in req.lower()

        # Skip non-skill/trait requirements
        if not is_trait and not is_skill:
            continue

        # Extract skill/trait name (remove " skill", " Skill", " trait", or " Trait" suffix)
        skill_name = req.replace(" skill", "").replace(" Skill", "").replace(" trait", "").replace(" Trait", "").strip()

        # Check each skill category to verify it's a valid skill or trait
        found = False
        for category, category_data in game_skills_categories.items():
            if skill_name in category_data.get("members", []):
                # Format depends on category: Battle Traits use " Battle Trait", others use " Skill"
                if category == "BattleTraits":
                    skill_requirements.append(f"{skill_name} Battle Trait")
                else:
                    skill_requirements.append(f"{skill_name} Skill")
                found = True
                break

    return skill_requirements


def _extract_achievement_requirements(requirements: list, progressive_mode: bool) -> list:
    """
    Extract achievement requirements from the requirements list.
    Only returns them if progressive mode is enabled.
    Returns list of achievement item names like ["Achievement: Kill 10 Waves"]

    Supports OR logic with pipe-separated requirements:
    - "Achievement: X" → ["Achievement: X"] (single requirement)
    - "Achievement: X|Achievement: Y" → [("Achievement: X", "Achievement: Y")] (OR tuple)
    """
    if not progressive_mode:
        return []  # Ignore achievement requirements if not in progressive mode

    achievement_requirements = []
    for req in requirements:
        req = req.strip()

        # Handle pipe-separated OR requirements
        if "|" in req and req.startswith("Achievement:"):
            or_group = []
            for or_req in req.split("|"):
                or_req = or_req.strip()
                if or_req.startswith("Achievement:"):
                    or_group.append(or_req)
            if or_group:
                achievement_requirements.append(tuple(or_group))
            continue

        # Single achievement requirement
        if req.startswith("Achievement:"):
            achievement_requirements.append(req)

    return achievement_requirements


def _extract_element_requirements(requirements: list) -> list:
    """
    Extract element requirements (game_level_elements or non_monster_elements).
    Returns which elements are required.

    Supports OR logic with pipe-separated requirements:
    - "Fire element" → ["Fire"] (single requirement)
    - "Fire element|Ice element" → [("Fire", "Ice")] (OR tuple)
    """
    element_requirements = []

    for req in requirements:
        req = req.strip()

        # Handle pipe-separated OR requirements
        if "|" in req and " element" in req:
            or_group = []
            for or_req in req.split("|"):
                or_req = or_req.strip()
                if not or_req.endswith(" element"):
                    continue
                elem_name = or_req[:-8]  # Remove " element"

                if elem_name in game_level_elements:
                    if game_level_elements[elem_name].get("levels", []):
                        or_group.append(elem_name)
                elif elem_name in non_monster_elements:
                    or_group.append(elem_name)

            if or_group:
                element_requirements.append(tuple(or_group))
            continue

        # Single element requirement
        if not req.endswith(" element"):
            continue

        elem_name = req[:-8]  # Remove " element"

        # Check if element has levels defined
        if elem_name in game_level_elements:
            if game_level_elements[elem_name].get("levels", []):
                # Element has levels, can be gated
                element_requirements.append(elem_name)
        elif elem_name in non_monster_elements:
            # Non-monster elements can be gated by their trait requirement
            element_requirements.append(elem_name)

    return element_requirements


def _build_achievement_access_rule(requirements: list, player: int):
    """
    Build an access rule function for an achievement based on its requirements.
    Checks if player has obtained all required skills and traits.

    Returns a lambda that checks requirements, or None if no skill/trait requirements.
    """
    skill_requirements = []

    for req in requirements:
        req = req.strip()

        is_trait = " trait" in req.lower()
        is_skill = " skill" in req.lower()

        # Skip non-skill/trait requirements (gemCount, minWave, element requirements, etc.)
        if not is_trait and not is_skill:
            continue

        # Extract skill/trait name (remove " skill", " Skill", " trait", or " Trait" suffix)
        skill_name = req.replace(" skill", "").replace(" Skill", "").replace(" trait", "").replace(" Trait", "").strip()

        # Check each skill category to verify it's a valid skill or trait
        found = False
        for category, category_data in game_skills_categories.items():
            if skill_name in category_data.get("members", []):
                # Format depends on category: Battle Traits use " Battle Trait", others use " Skill"
                if category == "BattleTraits":
                    skill_requirements.append(f"{skill_name} Battle Trait")
                else:
                    skill_requirements.append(f"{skill_name} Skill")
                found = True
                break

        # If not in our categories, skip it
        if not found:
            continue

    if not skill_requirements:
        return None

    # Return a lambda that checks if all required skills/traits are obtained
    def check_skills(state):
        return all(state.has(skill, player) for skill in skill_requirements)

    return check_skills


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
    # Achievements require specific skills to be obtained first
    try:
        from .rulesdata_achievements_1 import achievement_requirements as pack1
        from .rulesdata_achievements_2 import achievement_requirements as pack2
        from .rulesdata_achievements_3 import achievement_requirements as pack3
        from .rulesdata_achievements_4 import achievement_requirements as pack4
        from .rulesdata_achievements_5 import achievement_requirements as pack5
        from .rulesdata_achievements_6 import achievement_requirements as pack6

        achievement_packs = [pack1, pack2, pack3, pack4, pack5, pack6]

        # Merge all achievement packs into single dict
        all_achievements = {}
        for pack in achievement_packs:
            all_achievements.update(pack)

        # Simplify achievements: if they have trait requirements, remove element requirements
        # This avoids circular dependencies where trait items might be in trait-locked locations
        for ach_name, ach_data in all_achievements.items():
            requirements = ach_data.get("requirements", [])
            if requirements:
                # Check if this achievement has a trait requirement
                has_trait = any("trait" in req.lower() for req in requirements)

                if has_trait:
                    # Keep only trait and skill requirements, remove element and stat requirements
                    simplified = []
                    for req in requirements:
                        req_lower = req.lower()
                        # Keep traits and skills
                        if "trait" in req_lower or "skill" in req_lower or req.startswith("Achievement:"):
                            simplified.append(req)
                        # Remove elements and stats (gemCount, minWave, minGemGrade, etc.)

                    ach_data["requirements"] = simplified

        with_rules = 0
        without_rules = 0
        not_found = 0
        skipped_modes = 0

        is_progressive = world.options.achievement_progression.value == AchievementProgression.option_progressive
        max_grindiness_level = world.options.achievement_grindiness.value

        # Grindiness hierarchy: higher number = more grinding required
        grindiness_hierarchy = ["Trivial", "Minor", "Major", "Extreme"]
        max_grindiness_index = min(max_grindiness_level - 1, len(grindiness_hierarchy) - 1)
        max_grindiness_str = grindiness_hierarchy[max_grindiness_index] if max_grindiness_level > 0 else None

        # Get enabled modes (placeholder - TODO: add mode options to yaml if needed)
        enabled_modes = {"journey"}  # Always include journey
        # TODO: Add endurance_enabled and trial_enabled options if needed

        for ach_name, ach_data in all_achievements.items():
            # Skip if grindiness level exceeds selected max
            ach_grindiness = ach_data.get("grindiness", "Trivial")
            if max_grindiness_str:
                grindiness_index = grindiness_hierarchy.index(ach_grindiness) if ach_grindiness in grindiness_hierarchy else 0
                max_index = grindiness_hierarchy.index(max_grindiness_str) if max_grindiness_str in grindiness_hierarchy else 0
                if grindiness_index > max_index:
                    continue

            # Skip if achievement is only available in disabled modes
            ach_modes = set(ach_data.get("modes", ["journey"]))
            if not ach_modes.intersection(enabled_modes):
                skipped_modes += 1
                continue

            loc_name = f"Achievement: {ach_name}"
            try:
                location = multiworld.get_location(loc_name, player)
                requirements = ach_data.get("requirements", [])

                skill_requirements = _extract_skill_requirements(requirements)
                achievement_requirements = _extract_achievement_requirements(requirements, is_progressive)
                element_requirements = _extract_element_requirements(requirements)

                has_skills = len(skill_requirements) > 0
                has_achievements = len(achievement_requirements) > 0
                has_elements = len(element_requirements) > 0

                # Build all requirement lists for access rule
                all_requirements = []

                if has_achievements:
                    all_requirements.append(("achievement", achievement_requirements))
                if has_skills:
                    all_requirements.append(("skill", skill_requirements))
                if has_elements:
                        # For elements, create requirements based on where they appear
                        trait_requirements = []
                        stage_requirements = []  # List of (element_name_or_tuple, stages_list) tuples

                        for elem_or_group in element_requirements:
                            # Handle OR groups (tuples) or single elements
                            if isinstance(elem_or_group, tuple):
                                # OR group: collect traits/stages for all elements, check as OR
                                or_traits = []
                                or_stages = []
                                for elem in elem_or_group:
                                    if elem in non_monster_elements:
                                        trait = non_monster_elements[elem].get("requires_trait")
                                        if trait:
                                            or_traits.append(f"{trait} Battle Trait")
                                        stages = non_monster_elements[elem].get("levels", [])
                                        if stages:
                                            or_stages.append((elem, stages))
                                    elif elem in game_level_elements:
                                        stages = game_level_elements[elem].get("levels", [])
                                        if stages:
                                            or_stages.append((elem, stages))

                                if or_traits:
                                    trait_requirements.append(tuple(or_traits))
                                if or_stages:
                                    stage_requirements.append(("OR", or_stages))
                            else:
                                # Single element
                                elem = elem_or_group
                                if elem in non_monster_elements:
                                    trait = non_monster_elements[elem].get("requires_trait")
                                    if trait:
                                        trait_requirements.append(f"{trait} Battle Trait")
                                    # Also check if it has stage mappings
                                    stages = non_monster_elements[elem].get("levels", [])
                                    if stages:
                                        stage_requirements.append((elem, stages))

                                # Check game-level elements for stage mappings
                                elif elem in game_level_elements:
                                    stages = game_level_elements[elem].get("levels", [])
                                    if stages:
                                        stage_requirements.append((elem, stages))

                        # Add trait requirements
                        if trait_requirements:
                            all_requirements.append(("trait", trait_requirements))

                        # Add stage requirements (OR logic: can reach ANY of the stages with this element)
                        if stage_requirements:
                            all_requirements.append(("stages", stage_requirements))

                if all_requirements:
                    # Create unified access rule checking all requirement types
                    def make_rule(req_list, ach_name_debug):
                        def check_requirements(state):
                            for req_type, req_values in req_list:
                                if req_type == "skill" or req_type == "trait":
                                    # Check each requirement (AND logic for list items)
                                    for req in req_values:
                                        if isinstance(req, tuple):
                                            # OR logic: at least one must be true
                                            if not any(state.has(item, player) for item in req):
                                                return False
                                        elif isinstance(req, str) and ":" in req:
                                            # Skill group counter requirement (e.g., "strikeSpells: 1")
                                            group_name, count_str = req.split(":", 1)
                                            group_name = group_name.strip()
                                            count_needed = int(count_str.strip())

                                            if group_name in skill_groups:
                                                # Count how many skills from this group the player has
                                                group_members = skill_groups[group_name].get("members", [])
                                                count_owned = sum(
                                                    1 for member in group_members
                                                    if state.has(f"{member} Skill", player)
                                                )
                                                if count_owned < count_needed:
                                                    return False
                                        else:
                                            # Single requirement: must be true
                                            if not state.has(req, player):
                                                return False
                                elif req_type == "stages":
                                    # For stages: must be able to reach ANY stage in ANY element's stage list
                                    # req_values is list of (element_name_or_"OR", stages) tuples
                                    can_reach_all_elements = True
                                    for elem_marker, stages_list in req_values:
                                        if elem_marker == "OR":
                                            # OR group: need to reach ANY of these stages
                                            can_reach_or_element = False
                                            for elem_name, stages in stages_list:
                                                # Check if can reach ANY location in ANY of the stages
                                                for stage in stages:
                                                    for suffix in ("Journey", "Bonus", "Wizard stash"):
                                                        loc_name = f"Complete {stage} - {suffix}"
                                                        try:
                                                            if state.can_reach(loc_name, "Location", player):
                                                                can_reach_or_element = True
                                                                break
                                                        except KeyError:
                                                            pass
                                                    if can_reach_or_element:
                                                        break
                                                if can_reach_or_element:
                                                    break
                                            if not can_reach_or_element:
                                                can_reach_all_elements = False
                                                break
                                        else:
                                            # Single element: need to reach this element's stages
                                            elem_name = elem_marker
                                            can_reach_element = False
                                            for stage in stages_list:
                                                for suffix in ("Journey", "Bonus", "Wizard stash"):
                                                    loc_name = f"Complete {stage} - {suffix}"
                                                    try:
                                                        if state.can_reach(loc_name, "Location", player):
                                                            can_reach_element = True
                                                            break
                                                    except KeyError:
                                                        pass
                                                if can_reach_element:
                                                    break
                                            if not can_reach_element:
                                                can_reach_all_elements = False
                                                break
                                    if not can_reach_all_elements:
                                        return False
                            return True
                        return check_requirements

                    location.access_rule = make_rule(all_requirements, ach_name)
                    with_rules += 1

                else:
                    without_rules += 1
            except Exception as e:
                # Location might not exist if achievement was filtered out
                not_found += 1

    except Exception as e:
        print(f"ERROR setting achievement access rules: {e}")
        import traceback
        traceback.print_exc()

    multiworld.completion_condition[player] = lambda state: state.has("Victory", player)

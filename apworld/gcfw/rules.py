from __future__ import annotations

from typing import TYPE_CHECKING, List

from .rulesdata import GAME_DATA, STAGE_RULES, TIERS, GEM_POUCH_PLAY_ORDER
from .rulesdata_settings import (
    game_level_elements, non_monster_elements,
    skill_groups,
)
from .requirement_tokens import (
    item_prefix_map, element_prefix_map,
    mode_tokens, level_stat_counters, skill_counter_pools,
)
from .rulesdata_goals import goal_requirements
from .rulesdata_levels import level_requirements as LEVEL_DATA
from .options import AchievementProgression
from .power import (
    has_power,
    required_achievement_power,
    build_weight_map_for_world,
    EDGE_TALISMAN_NAMES,
    CORNER_TALISMAN_NAMES,
    PROGRESSION_CORNER_TALISMAN_NAMES,
    PROGRESSION_EDGE_TALISMAN_NAMES,
    PROGRESSION_ALL_TALISMAN_NAMES,
    MATCHING_TALISMAN_NAMES,
)


def _restrict_talisman_shapes(loc, exclude_edge: bool, exclude_corner: bool) -> None:
    """Layer an item_rule that excludes EDGE and/or CORNER talisman fragments
    by name. Composes with whatever item_rule was already on the location.
    """
    if not exclude_edge and not exclude_corner:
        return
    prev = loc.item_rule  # default is `lambda i: True`

    def new_rule(item, p=prev, ee=exclude_edge, ec=exclude_corner):
        if ee and item.name in EDGE_TALISMAN_NAMES:
            return False
        if ec and item.name in CORNER_TALISMAN_NAMES:
            return False
        return p(item)

    loc.item_rule = new_rule

if TYPE_CHECKING:
    from . import GemcraftFrostbornWrathWorld


# Pre-build token name lists per tier for use in access rules.
# Built once at module load — TIERS is immutable after rulesdata.py imports.
TIER_TOKEN_NAMES: dict[int, List[str]] = {}
for tier_num, stage_ids in TIERS.items():
    TIER_TOKEN_NAMES[tier_num] = [f"{sid} Field Token" for sid in stage_ids]


# Per-stage wizard-stash key item names. Every stage has a stash; the stash
# is locked until the player collects its key. Used by the eWizardStash
# token — pass the gate iff the player holds at least one key.
WIZ_STASH_KEY_NAMES: List[str] = [
    f"Wizard Stash {s['str_id']} Key" for s in GAME_DATA.get("stages", [])
]


# XP item names — every registered XP item, both progression and useful.
# Half are progression (see items.py _xp_cls); state.has only sees those.
# The wizardLevel:N gate counts how many progression XP items the player
# has collected — passes when (N+1)//2 items are in state.
XP_ITEM_NAMES: List[str] = (
    [f"Tattered Scroll #{i+1}" for i in range(32)]
    + [f"Worn Tome #{i+1}" for i in range(6)]
    + [f"Ancient Grimoire #{i+1}" for i in range(2)]
    + [f"Extra XP Item #{i+1}" for i in range(60)]
)


# Shadow core stash item names → core amount they grant.  Used by the
# shadowCore:N gate (sums amounts of held progression stashes; useful and
# filler items are invisible to state.has so contribute 0).
SHADOW_CORE_AMOUNT_BY_NAME: dict[str, int] = {}
for _sc in GAME_DATA.get("shadow_core_stashes", []):
    SHADOW_CORE_AMOUNT_BY_NAME[f"{_sc['str_id']} Shadow Cores"] = int(_sc["total"])
for _sc in GAME_DATA.get("extra_shadow_core_stashes", []):
    SHADOW_CORE_AMOUNT_BY_NAME[_sc["name"]] = int(_sc["amount"])
del _sc


def _count_xp_items(state, player: int) -> int:
    return sum(1 for n in XP_ITEM_NAMES if state.has(n, player))


def _sum_shadow_cores(state, player: int) -> int:
    """Sum of core amounts for held shadow-core stash items.  Only items
    classified as progression count — others don't enter state.prog_items."""
    return sum(amt for name, amt in SHADOW_CORE_AMOUNT_BY_NAME.items()
               if state.has(name, player))


def _count_complete_talisman_rows(state, player: int) -> int:
    """Count complete rows of the matching 3x3 grid the player owns.

    A row = all 3 fragments of one icon group. With 9 progression fragments
    split into 3 fixed icon groups (see power.MATCHING_TALISMAN_ROWS),
    the player can have 0..3 complete rows.
    """
    from .power import MATCHING_TALISMAN_ROWS
    return sum(
        1 for row in MATCHING_TALISMAN_ROWS
        if all(state.has(n, player) for n in row)
    )


def _count_complete_talisman_columns(state, player: int) -> int:
    """Count complete columns of the matching 3x3 grid the player owns.

    A column = one specific fragment from each icon group (positions
    {1,4,7}, {2,5,8}, or {3,6,9}). See power.MATCHING_TALISMAN_COLUMNS.
    """
    from .power import MATCHING_TALISMAN_COLUMNS
    return sum(
        1 for col in MATCHING_TALISMAN_COLUMNS
        if all(state.has(n, player) for n in col)
    )


def _count_skill_points(state, player: int) -> int:
    """Sum SP across all collected Skillpoint Bundle items.
    Each 'Skillpoint Bundle N' contributes N skill points; the pool may
    contain multiple copies of the same bundle size."""
    total = 0
    for size in range(1, 11):
        total += size * state.count(f"Skillpoint Bundle {size}", player)
    return total


# Prefix-encoded requirement vocabulary + counter dispatch tables live in
# requirement_tokens.py (skill / trait / element prefix maps,
# mode_tokens, level_stat_counters).  Adding a new token / counter is
# a one-line entry there — no evaluator change required.

def _is_prefix_token(token: str, allowed: str) -> bool:
    """Return True if `token` starts with one of the prefix letters in `allowed`
    and the second char is uppercase (e.g. 'eBeacon', 'tHaste')."""
    return len(token) >= 2 and token[0] in allowed and token[1].isupper()


# Talisman counter -> name set used to count collected fragments.
# These all map to the 25 progression talisman fragments (4 corner + 12 edge
# + 9 inner) — the items that actually mark the talisman's slot layout.
# Non-progression fragments still drop but don't gate anything: state.has()
# only sees progression items, so counting useful/filler fragments here would
# silently always return 0.
_TALISMAN_FRAGMENT_COUNTERS: dict[str, frozenset] = {
    "talismanCornerFragment": PROGRESSION_CORNER_TALISMAN_NAMES,  # 4 items
    "talismanEdgeFragment":   PROGRESSION_EDGE_TALISMAN_NAMES,    # 12 items
    "talismanCenterFragment": MATCHING_TALISMAN_NAMES,            # 9 items
    "talismanFragments":      PROGRESSION_ALL_TALISMAN_NAMES,     # 25 items
}


def _count_talisman_fragments(state, player: int, names) -> int:
    return sum(1 for n in names if state.has(n, player))


def _eval_element_reachable(elem_name: str, state, player: int) -> bool:
    """Resolve element-presence reachability. Used by both the legacy
    'X element' form and the new 'eX' prefix form."""
    # Wizard Stash — every stage has one structurally, but each is locked
    # until the player collects its per-stage key.  Pass the gate iff the
    # player holds at least one wizard-stash key.
    if elem_name == "Wizard Stash":
        return any(state.has(n, player) for n in WIZ_STASH_KEY_NAMES)
    if elem_name in non_monster_elements:
        elem_data = non_monster_elements[elem_name]
        trait = elem_data.get("requires_trait")
        levels = elem_data.get("levels", [])
        if trait:
            if not state.has(f"{trait} Battle Trait", player):
                return False
            return not levels or _can_reach_any_stage(state, player, levels)
        return _can_reach_any_stage(state, player, levels)
    if elem_name in game_level_elements:
        stages = game_level_elements[elem_name].get("levels", [])
        if stages:
            return _can_reach_any_stage(state, player, stages)
    return True


def _eval_element_count(elem_pascal: str, count_needed: int, state, player: int) -> bool:
    """Resolve eX:N form: a reachable stage exists where <X>Count >= N.
    Looked up against LEVEL_DATA's per-element count fields populated in
    rulesdata_levels.py."""
    field = elem_pascal + "Count"
    qualifying = [sid for sid, d in LEVEL_DATA.items() if d.get(field, 0) >= count_needed]
    return _can_reach_any_stage(state, player, qualifying)


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
    Prevents circular dependencies where trait items may sit behind element-locked locations.

    Exception: non_monster_elements with a non-empty `levels` list are preserved.
    Their access rule (have-trait AND any-original-level-reachable) is strictly
    stronger than the trait alone — matching the mod-side RitualSpawnPatcher
    gate — so stripping them would lose the level constraint."""
    has_trait = any(" trait" in req.lower() for group in normalized for req in group)
    if not has_trait:
        return normalized

    def keep(req: str) -> bool:
        if not req.endswith(" element"):
            return True
        elem_name = req[:-8]
        if elem_name in non_monster_elements and non_monster_elements[elem_name].get("levels"):
            return True
        return False

    return [[req for req in group if keep(req)] for group in normalized]


def _can_reach_any_stage(state, player: int, stages: list) -> bool:
    """Return True if the player can reach any completion location across the given stages."""
    for stage in stages:
        for suffix in ("Journey", "Wizard stash"):
            try:
                if state.can_reach(f"Complete {stage} - {suffix}", "Location", player):
                    return True
            except KeyError:
                pass
    return False


def _can_clear_stage_cached(state, player: int, sid: str) -> bool:
    """Return True if the player can clear (reach Journey for) `sid`.

    Memoised on the state via a signature derived from prog_items (length +
    sum of counts). The signature changes whenever AP collects or removes
    any item, so cached values from a previous fill state are invalidated
    automatically.

    The recursive can_reach chain triggered by per-stage prereq rules is
    O(chain_depth) deep with up to 4 fanout per level — without memoisation
    each top-level access_rule call re-evaluates ancestors many times. The
    cache turns the cumulative cost over a fill sweep from ~depth^fanout to
    O(num_stages).
    """
    items = state.prog_items.get(player)
    if items is None:
        sig = (player, 0, 0)
    else:
        sig = (player, len(items), sum(items.values()))

    cache = getattr(state, "_gcfw_clear_cache", None)
    if cache is None or cache[0] != sig:
        cache = (sig, {})
        state._gcfw_clear_cache = cache
    data = cache[1]

    if sid in data:
        return data[sid]
    # Cycle guard — our prereq DAG is acyclic by construction, but if a
    # broken edit ever introduces a cycle this prevents infinite recursion.
    data[sid] = False
    try:
        ok = state.can_reach(f"Complete {sid} - Journey", "Location", player)
    except KeyError:
        ok = False
    data[sid] = ok
    return ok


def _can_clear_any_stage(state, player: int, stages) -> bool:
    """Return True if the player can clear (reach Journey) any of the given
    stages. Stricter than `_can_reach_any_stage` — stash reachability does
    not count, only Journey clears.

    Used by the per-stage prereq gate so that satisfying a prereq forces
    an actual stage clear, not just possession of the prereq's Field Token.
    Backed by `_can_clear_stage_cached` for speed.
    """
    for sid in stages:
        if _can_clear_stage_cached(state, player, sid):
            return True
    return False


# Item-collection counter heads that aren't covered by any of the
# requirement_tokens tables.  Each is handled inline in _eval_req.
_OTHER_COUNTER_HEADS: frozenset = frozenset({
    "fieldToken", "shadowCore", "wizardLevel",
    "skillPoints", "talismanRow", "talismanColumn",
})


def _is_gating_req(req: str, is_progressive: bool) -> bool:
    """Return True if this requirement string actually gates access to something."""
    req = req.strip()
    if req.startswith("Field_"):
        return True
    if req.startswith("Achievement:"):
        return is_progressive
    # Prefix vocabulary — single lookup across all maps.
    if (req in mode_tokens
            or req in item_prefix_map
            or req in element_prefix_map):
        return True
    if ":" in req:
        head = req.split(":", 1)[0].strip()
        if head in element_prefix_map or _is_prefix_token(head, "e"):
            return True  # element / weather / group with count
        if (head in level_stat_counters
                or head in _TALISMAN_FRAGMENT_COUNTERS
                or head in skill_counter_pools):
            return True
        return head in _OTHER_COUNTER_HEADS
    return False


def _eval_req(req: str, state, player: int, is_progressive: bool) -> bool:
    """Evaluate a single requirement string against the current collection state."""
    req = req.strip()

    # Field_<sid> means "stage <sid>'s Journey is reachable" (i.e. the player
    # can clear it in-logic). NOT just "has Field Token <sid>" — token
    # possession alone doesn't guarantee the prereq stage is beatable. Cached
    # via _can_clear_stage_cached so deeper chains don't re-evaluate ancestors.
    if req.startswith("Field_"):
        return _can_clear_stage_cached(state, player, req[len("Field_"):])

    if req.startswith("Achievement:"):
        if not is_progressive:
            return True
        # Achievement items no longer exist (SP is filler instead). For
        # progressive chains, check that the parent achievement's LOCATION
        # is reachable — equivalent to "the player could have collected it".
        try:
            return state.can_reach(req, "Location", player)
        except KeyError:
            return False

    # --- Prefix vocabulary (s/t/e/w/m) -------------------------------
    # Tokens without a colon are dispatched by the maps in requirement_tokens.
    # Mode gates always-fail in this journey-only mod.
    if req in mode_tokens:
        return False
    if req in item_prefix_map:
        # Direct AP-item check.  Map values are full item names ("Bolt
        # Skill" / "Haste Battle Trait") so no string construction here.
        return state.has(item_prefix_map[req], player)
    if req in element_prefix_map:
        # Element/group/weather token (single-element lists for `eBeacon`,
        # multi-element list for `eNonMonsters`). Reachable if any member is.
        return any(_eval_element_reachable(n, state, player)
                   for n in element_prefix_map[req])

    if ":" in req:
        group_name, count_str = req.split(":", 1)
        group_name = group_name.strip()
        try:
            count_needed = int(count_str.strip())
        except ValueError:
            return True

        # Group token with count (e.g. eNonMonsters:1) — the count is
        # ignored; we just check whether any group member is reachable.
        # Has to be checked BEFORE the generic eX:N count branch, since
        # `eNonMonsters` is also an "e"-prefix token.
        if group_name in element_prefix_map and len(element_prefix_map[group_name]) > 1:
            return any(_eval_element_reachable(n, state, player)
                       for n in element_prefix_map[group_name])

        # eX:N — single-element with count.  The token body is already
        # PascalCase so the level-data field is just `<body>Count`.
        if _is_prefix_token(group_name, "e"):
            return _eval_element_count(group_name[1:], count_needed, state, player)

        # Skill / trait / category / total counters — all unified into
        # one pool table (built in requirement_tokens.py from skill_groups
        # + game_skills_categories).  Covers strikeSpells, enhancementSpells,
        # gemSkills, BattleTraits / battleTraits, GemSkills, OtherSkills,
        # skills / Skills.
        if group_name in skill_counter_pools:
            pool = skill_counter_pools[group_name]
            return sum(1 for name in pool if state.has(name, player)) >= count_needed

        # Stage-stat gates: "<counter>:N" passes if any reachable stage's
        # field(s) >= N.  Tuple values are max-aggregated across the fields.
        # Add new gates by adding entries to level_stat_counters in
        # requirement_tokens.py — no code change needed.
        if group_name in level_stat_counters:
            fields = level_stat_counters[group_name]
            if isinstance(fields, str):
                fields = (fields,)
            qualifying = [sid for sid, d in LEVEL_DATA.items()
                          if max(d.get(f, 0) for f in fields) >= count_needed]
            return _can_reach_any_stage(state, player, qualifying)

        # Talisman-fragment counters by type.
        if group_name in _TALISMAN_FRAGMENT_COUNTERS:
            return _count_talisman_fragments(
                state, player, _TALISMAN_FRAGMENT_COUNTERS[group_name],
            ) >= count_needed

        # Other item-collection counters — each counts a different pool.
        if group_name == "fieldToken":
            collected = sum(
                1
                for tier_tokens in TIER_TOKEN_NAMES.values()
                for name in tier_tokens
                if state.has(name, player)
            )
            return collected >= count_needed
        if group_name == "shadowCore":
            # Sum core amounts of held progression shadow-core stash items.
            # Half of stashes are progression (see items.py _sc_cls); useful/
            # filler stashes are invisible to state.has and contribute 0.
            return _sum_shadow_cores(state, player) >= count_needed
        if group_name == "wizardLevel":
            # Half of XP items are progression; player needs ceil(N/2) of
            # those collected before the wizardLevel:N gate opens.  Max
            # reachable N at default settings: 40 (20 progression XP items).
            needed_items = (count_needed + 1) // 2
            return _count_xp_items(state, player) >= needed_items
        if group_name == "talismanRow":
            return _count_complete_talisman_rows(state, player) >= count_needed
        if group_name == "talismanColumn":
            return _count_complete_talisman_columns(state, player) >= count_needed
        if group_name == "skillPoints":
            return _count_skill_points(state, player) >= count_needed

        return True  # Unknown counter (minGemGrade, etc.) — metadata only

    return True  # Metadata requirement — not gated


def set_rules(world: "GemcraftFrostbornWrathWorld") -> None:
    """
    Apply access rules to all regions and locations.

    Region connections (from the chosen starting stage):
      - All other stages: require their own field token to enter.
      - The starting stage itself has no token requirement (Menu connects
        directly to it in __init__.create_regions).

    Location rules:
      - Journey:        WIZLOCK skills (where applicable) + tier-power gate.
      - Wizard stash:   WIZLOCK skills (where applicable) + key item +
                        stash-power gate (≈ 65% of tier-power).
      - Achievements:   per-achievement requirements + per-achievement power
                        gate (default from required_effort, optional override
                        via the `required_power` field).

    Victory: A4 reachable AND all 24 skills collected (handled below).
    """
    from worlds.generic.Rules import add_rule

    player = world.player
    multiworld = world.multiworld

    stages = GAME_DATA["stages"]

    # The chosen starting stage (from world.options.starting_stage) is the
    # one stage whose Field prereqs we ignore — it's the menu connection,
    # so its `requirements` list in rulesdata_levels.py shouldn't gate it.
    start_sid = world.start_sid

    # Build the per-world power weight map ONCE — every has_power(...) call
    # below reuses it. Walking state.prog_items[player] with a precomputed
    # weight map is ~10x cheaper per fill check than iterating master lists.
    weight_map = build_weight_map_for_world(world)

    start_region = multiworld.get_region(start_sid, player)

    # --- Region connections: starting stage → every other stage ---
    # A stage's own Field Token is required to physically enter the stage.
    # Stage-to-stage progression order is enforced separately by the
    # prerequisite gates further down (per-world stage_prereqs).
    for stage in stages:
        str_id = stage["str_id"]
        if str_id == start_sid:
            continue
        child_region = multiworld.get_region(str_id, player)
        connection = start_region.connect(child_region, f"{start_sid} -> {str_id}")

        token_name = f"{str_id} Field Token"
        connection.access_rule = (
            lambda state, tok=token_name: state.has(tok, player)
        )

    # --- Location rules: WIZLOCK skill requirements only ---
    # gem_pouch_gating selects which gem-related requirements actually gate:
    #   off         → gemSkills:N is active, gemPouch:<prefix> is a no-op
    #   distinct    → gemSkills:N is a no-op, gemPouch:<prefix> requires the
    #                 named pouch item
    #   progressive → gemSkills:N is a no-op, gemPouch:<prefix> requires
    #                 enough Progressive Gempouch copies for that prefix's
    #                 position in GEM_POUCH_PLAY_ORDER.
    pouch_mode = world.options.gem_pouch_gating.value
    pouch_index = {p: i for i, p in enumerate(GEM_POUCH_PLAY_ORDER)}

    for str_id, rule in STAGE_RULES.items():
        if not rule.skills:
            continue

        conditions = []
        for skill in rule.skills:
            if ":" in skill:
                group_name, count_str = skill.split(":", 1)
                group_name = group_name.strip()
                if group_name == "gemPouch":
                    if pouch_mode == 0:
                        continue  # off — pouches don't gate
                    prefix = count_str.strip()
                    if pouch_mode == 1:  # distinct
                        item_name = f"Gempouch ({prefix})"
                        conditions.append(lambda state, i=item_name: state.has(i, player))
                    else:  # progressive
                        needed = pouch_index.get(prefix, -1) + 1
                        if needed > 0:
                            conditions.append(
                                lambda state, n=needed: state.count("Progressive Gempouch", player) >= n
                            )
                    continue
                if group_name == "gemSkills" and pouch_mode != 0:
                    continue  # pouches replace the gem-skill gate
                count_needed = int(count_str.strip())
                if group_name in skill_groups:
                    group_members = skill_groups[group_name].get("members", [])
                    conditions.append(lambda state, mems=group_members, n=count_needed:
                        sum(1 for m in mems if state.has(f"{m} Skill", player)) >= n)
            else:
                item_name = f"{skill} Skill"
                conditions.append(lambda state, i=item_name: state.has(i, player))

        if not conditions:
            continue

        def make_rule(conds):
            return lambda state: all(c(state) for c in conds)

        for suffix in ("Journey", "Wizard stash"):
            loc_name = f"Complete {str_id} - {suffix}"
            location = multiworld.get_location(loc_name, player)
            location.access_rule = make_rule(conditions)

    # --- Per-stage requirement gates (Journey + Wizard stash) ---
    # Each non-start stage's `requirements` list in rulesdata_levels.py is
    # written in DNF (outer-OR over inner AND-groups). Field_<sid> entries
    # resolve to "stage <sid>'s Journey is clearable in-logic" via _eval_req,
    # so token possession alone isn't enough — the prereq stage must actually
    # be beatable through the chain.
    #
    # The chosen starting stage skips this gate entirely (it's the menu
    # connection; its own listed prereqs are intentionally ignored).
    for stage in stages:
        sid = stage["str_id"]
        journey_loc = multiworld.get_location(f"Complete {sid} - Journey", player)
        stash_loc   = multiworld.get_location(f"Complete {sid} - Wizard stash", player)

        if sid != start_sid:
            requirements = LEVEL_DATA[sid].get("requirements", [])
            if requirements:
                normalized = _normalize_requirements(requirements)

                def make_stage_rule(groups):
                    return lambda state: any(
                        all(_eval_req(r, state, player, is_progressive=False) for r in group)
                        for group in groups
                    )

                rule = make_stage_rule(normalized)
                add_rule(journey_loc, rule)
                add_rule(stash_loc, rule)

        # Wizard-stash key item is always required (no off mode).
        key_name = f"Wizard Stash {sid} Key"
        add_rule(stash_loc, lambda state, n=key_name: state.has(n, player))

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

        from . import _should_skip_achievement

        for ach_name, ach_data in all_achievements.items():
            ach_effort = ach_data.get("required_effort", "Trivial")
            if max_effort_str:
                effort_index = effort_hierarchy.index(ach_effort) if ach_effort in effort_hierarchy else 0
                max_index = effort_hierarchy.index(max_effort_str) if max_effort_str in effort_hierarchy else 0
                if effort_index > max_index:
                    continue

            # Untrackable / Trial / disabled-Endurance achievements have no AP
            # location, so there's nothing to attach an access rule to.
            if _should_skip_achievement(ach_data, world.options):
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

                # Power gate — independent of element/skill requirements.
                # Defaults to ACHIEVEMENT_EFFORT_POWER[required_effort] unless
                # the achievement has an explicit `required_power` override.
                ach_power = required_achievement_power(ach_data)
                if ach_power > 0:
                    add_rule(location,
                        lambda state, p=ach_power, wm=weight_map:
                            has_power(state, world, p, wm))

                # Achievements are filler-quality and reachable across the
                # spectrum. Exclude edge/corner talismans so they end up at
                # higher-tier stage locations (where the player has cores).
                _restrict_talisman_shapes(location, True, True)

            except Exception:
                pass

    except Exception as e:
        print(f"ERROR setting achievement access rules: {e}")
        import traceback
        traceback.print_exc()

    multiworld.completion_condition[player] = lambda state: state.has("Victory", player)

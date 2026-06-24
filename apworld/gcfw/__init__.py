from __future__ import annotations

from typing import Dict, List

from BaseClasses import ItemClassification, LocationProgressType, Region
from Options import DeathLink, OptionGroup

from worlds.AutoWorld import WebWorld, World

from .items import GCFWItem, item_table
from .locations import GCFWLocation, location_table
from .options import (
    GCFWOptions,
    FieldTokenPlacement,
    Goal,
    XpTomeBonus,
    DeathLinkPunishment,
    GemLossPercent,
    WaveSurgeCount,
    WaveSurgeGemLevel,
    SpawnHordeCount,
    SpawnSpecialElements,
    SpawnSpecialCount,
    DeathLinkGracePeriod,
    DeathLinkCooldown,
    AchievementRequiredEffort,
    SkillpointMultiplier,
    GemPouchGranularity,
    FieldTokenGranularity,
    StashKeyGranularity,
    STARTING_STAGE_BY_VALUE,
)
from .items_skillpoints import (
    compute_tier_distribution as _compute_sp_bundle_distribution,
    generate_sp_bundles,
    TIER_NAMES as _SP_TIER_NAMES,
)
from ._timing import phase, log as _timing_log, report_top_rules
from .rules import set_rules
from .rulesdata import (
    GAME_DATA,
    SKILL_CATEGORIES,
    GEM_POUCH_PLAY_ORDER,
    STAGE_RULES,
)
from .rulesdata_levels import level_requirements as LEVEL_DATA


def _load_game_data():
    return GAME_DATA


def _resolve_fields_required_count(world) -> int:
    """Resolved absolute stage threshold for the active goal.

    Single source of truth so the mod doesn't have to recompute.
    Must match the formulas in rules.py for the corresponding goal.
    """
    from math import floor
    goal_value = world.options.goal.value
    if goal_value == 3:
        # fields_count: option already holds the absolute count.
        return int(world.options.fields_required.value)
    if goal_value == 4:
        # fields_percentage: matches rules.py:1579 formula exactly.
        pct = int(world.options.fields_required_percentage.value)
        total = len(GAME_DATA["stages"])
        return int(floor(pct * total / 100))
    return 0


def _load_stages():
    return _load_game_data()["stages"]


def _requirements_contain(reqs: list, target: str) -> bool:
    """Recursively check whether `target` appears as a requirement string
    anywhere in a (possibly nested) requirements list."""
    for r in reqs:
        if isinstance(r, list):
            if _requirements_contain(r, target):
                return True
        elif r == target:
            return True
    return False


def _should_skip_achievement(ach_data: dict, options) -> bool:
    """
    Return True if this achievement should be omitted entirely from AP gen —
    no item in the pool, no location created. The player still earns vanilla
    skill points when triggering it in-game; the mod simply doesn't intercept.

    Triggers:
      - Achievement has `"untrackable": True` (RNG-dependent, hidden mods, etc.).
      - Requires Trial mode (Archipelago has no hooks into Trial mode).
      - Requires Endurance mode AND the player disabled Endurance.
    """
    if ach_data.get("untrackable", False):
        return True
    requirements = ach_data.get("requirements", [])
    # Both Trial and Endurance are unsupported by AP-side gating — the
    # mod is journey-only.  Achievements containing either token are
    # always pruned at gen time so they never appear in the multiworld.
    if _requirements_contain(requirements, "mTrial"):
        return True
    if _requirements_contain(requirements, "mEndurance"):
        return True
    return False


# Module-level cache for stage-stat counter ceilings used by the
# structural-reachability filter.  Populated lazily on first call to
# avoid import-order sensitivity; LEVEL_DATA never changes at runtime,
# so the cache is set-once.
_STAT_COUNTER_CEILINGS: dict | None = None


def _get_stat_counter_ceilings() -> dict:
    """Map of `level_stat_counters` head -> max value any stage carries
    for that head's field(s).  A `<head>:N` requirement is structurally
    unsatisfiable iff N exceeds this ceiling.  Mirrors the qualifying-
    stage selection in rules.py `_eval_req` (level_stat_counters branch)."""
    global _STAT_COUNTER_CEILINGS
    if _STAT_COUNTER_CEILINGS is None:
        from .requirement_tokens import level_stat_counters
        result = {}
        for head, fields in level_stat_counters.items():
            if isinstance(fields, str):
                fields = (fields,)
            result[head] = max(
                (max(d.get(f, 0) for f in fields) for d in LEVEL_DATA.values()),
                default=0,
            )
        _STAT_COUNTER_CEILINGS = result
    return _STAT_COUNTER_CEILINGS


def _stages_for_req(req: str):
    """Mirror rules._compile_req's static_set: return the frozenset of stage
    str_ids that satisfy a per-stage token, or None if the token is global
    (no stage binding). Used by _group_can_be_met to detect AND-groups
    whose per-stage tokens have empty stage-set intersection — those
    compile to _always_false in rules._compile_dnf (lines 1555-1563), so
    the achievement location is permanently unreachable in this seed.
    """
    from .requirement_tokens import (
        item_prefix_map, element_prefix_map, level_stat_counters,
    )
    from .rules import (
        _qualifying_stages_for_element,
        _qualifying_stages_for_stat,
        _element_count_field,
    )

    req = req.strip()

    if req.startswith("Field_"):
        return frozenset({req[len("Field_"):]})

    if req.startswith("Achievement:"):
        return None  # state-dependent ach-reachable closure

    if req in item_prefix_map:
        return None  # item/trait token — global

    def _disjunction_stages(elem_names, count_needed: int):
        union = set()
        for n in elem_names:
            if n == "Wizard Stash":
                return None  # state-dependent stash path
            # _qualifying_stages_for_element takes the PascalCase form
            # ("WizardHunter"), not the display name ("Wizard Hunter").
            # Same conversion rules.py:1229 does inline.
            elem_pascal = _element_count_field(n)[:-len("Count")]
            stages = _qualifying_stages_for_element(elem_pascal, count_needed)
            if stages is None:
                return None  # universally present — no constraint
            union.update(stages)
        return frozenset(union)

    if req in element_prefix_map:
        return _disjunction_stages(element_prefix_map[req], 1)

    if ":" in req:
        head, count_str = req.split(":", 1)
        head = head.strip()
        try:
            count_needed = int(count_str.strip())
        except ValueError:
            return None
        if head in element_prefix_map and len(element_prefix_map[head]) > 1:
            return _disjunction_stages(element_prefix_map[head], 1)
        if len(head) >= 2 and head[0] == "e" and head[1].isupper():
            # Canonical PascalCase comes from the display name in
            # element_prefix_map (eAmplifiers → "Amplifier" → "AmplifierCount").
            # Stripping just the "e" leaves the plural for building elements
            # and misses the singular Count field.
            if head in element_prefix_map:
                elem_pascal = _element_count_field(
                    element_prefix_map[head][0]
                )[:-len("Count")]
            else:
                elem_pascal = head[1:]
            stages = _qualifying_stages_for_element(elem_pascal, count_needed)
            if stages is None:
                return None
            return frozenset(stages)
        if head in level_stat_counters:
            return frozenset(_qualifying_stages_for_stat(head, count_needed))

    return None  # everything else is global / has no stage binding


def _can_achievement_be_met(requirements: list) -> bool:
    """
    Check if an achievement can be met based on its requirements (DNF format).
    Returns True if any AND-group can be met, False only if all groups are blocked.

    Three structural blockers are checked from level data:
      * Element presence/count: the achievement names an element (eBeacon,
        eShrine:2, ...) but no stage hosts it at the required count.
        Universal-presence elements (Tower / Wall / Wizard Stash / Marked
        Monster — no Count field anywhere) are never blocked.
      * Stage-stat counter ceiling: the achievement names a counter
        (minWave, minMonsters, markedMonster, ...) at a value no stage
        actually reaches.  Frag Rain (minWave:245 with max WaveCount=100)
        is the canonical case.
      * Same-stage AND-binding: per-stage tokens inside an AND-group must
        all be satisfied on a single stage (rules._compile_dnf intersects
        their static_sets). "Flying Multikill" needs tRitual + 4 monsters
        on one stage; if no such stage exists the access rule compiles to
        _always_false and the location becomes a dead slot for fill.

    Mirrors the runtime check in rules.py `_eval_req` / `_compile_dnf`:
    a `<head>:N` requirement passes iff at least one stage qualifies, AND
    every per-stage token in an AND-group shares at least one stage.
    """
    from .requirement_tokens import element_prefix_map
    from .rules import _element_count_field, _PRESENT_COUNT_FIELDS

    stat_ceilings = _get_stat_counter_ceilings()

    def _element_blocked(elem_name: str, count_needed: int) -> bool:
        """True if this element is structurally unreachable at the required
        count.  Universal-presence elements (no Count field anywhere) are
        never blocked."""
        if elem_name == "Wizard Stash":
            return False  # gated by per-stage keys, not by stage presence
        field = _element_count_field(elem_name)
        if field not in _PRESENT_COUNT_FIELDS:
            return False  # universal / untracked — assume reachable
        return not any(d.get(field, 0) >= count_needed for d in LEVEL_DATA.values())

    def _req_blocked(req: str) -> bool:
        """True if a single requirement string is structurally unsatisfiable
        from level data alone."""
        head = req.split(":", 1)[0].strip()
        count_needed = 1
        if ":" in req:
            try:
                count_needed = int(req.split(":", 1)[1].strip())
            except ValueError:
                count_needed = 1

        # Element / weather / group token (with or without count).
        elem_names = element_prefix_map.get(head)
        if elem_names is not None:
            # Group tokens (eNonMonsters, multi-member) ignore count and
            # pass if any single member is reachable — mirrors rules.py.
            if len(elem_names) > 1:
                return all(_element_blocked(n, 1) for n in elem_names)
            return all(_element_blocked(n, count_needed) for n in elem_names)

        # Stage-stat counter — block iff N exceeds the ceiling.
        if head in stat_ceilings and ":" in req:
            return count_needed > stat_ceilings[head]

        return False  # other tokens (item-pool counters, modes, etc.)

    def _group_can_be_met(group: list) -> bool:
        # Per-token block check (presence/count + counter ceilings).
        for req in group:
            if isinstance(req, list):
                if not _can_achievement_be_met(req):
                    return False
                continue
            if _req_blocked(req.strip()):
                return False
        # Same-stage AND-binding: intersect per-stage tokens' stage-sets.
        # Mirrors rules._compile_dnf:1555-1563 — without this, achievements
        # whose AND-groups need multiple per-stage tokens (eShrine + eWraith
        # + tRitual, etc.) pass the per-token check but compile to
        # _always_false because no single stage hosts every required token
        # together. Dead access rules leave the location unfillable in
        # remaining_fill and cause FillError once junk runs out of homes.
        intersection = None
        for req in group:
            if isinstance(req, list):
                continue
            stages = _stages_for_req(req)
            if stages is None:
                continue
            if intersection is None:
                intersection = set(stages)
            else:
                intersection &= stages
                if not intersection:
                    return False
        return True

    if not requirements:
        return True
    # Normalize to DNF: if first element is a list, treat as OR-of-AND-groups
    if isinstance(requirements[0], list):
        return any(_group_can_be_met(group) for group in requirements)
    return _group_can_be_met(requirements)


def _get_filter_reason(requirements: list) -> str:
    """
    Determine why an achievement was filtered out.
    Returns a string describing the first blocker encountered.
    """
    from .requirement_tokens import element_prefix_map
    from .rules import _element_count_field, _PRESENT_COUNT_FIELDS

    stat_ceilings = _get_stat_counter_ceilings()

    def _flatten(reqs):
        for r in reqs:
            if isinstance(r, list):
                yield from _flatten(r)
            else:
                yield r

    for req in _flatten(requirements):
        req = str(req).strip()
        head = req.split(":", 1)[0].strip()
        count_needed = 1
        if ":" in req:
            try:
                count_needed = int(req.split(":", 1)[1].strip())
            except ValueError:
                count_needed = 1

        # Element / weather / group token.
        elem_names = element_prefix_map.get(head)
        if elem_names is not None:
            for elem_name in elem_names:
                if elem_name == "Wizard Stash":
                    continue
                field = _element_count_field(elem_name)
                if field in _PRESENT_COUNT_FIELDS:
                    if not any(d.get(field, 0) >= count_needed for d in LEVEL_DATA.values()):
                        return f"No stage hosts element '{elem_name}' (need >= {count_needed})"
            continue

        # Stage-stat counter ceiling.
        if head in stat_ceilings and ":" in req:
            ceiling = stat_ceilings[head]
            if count_needed > ceiling:
                return f"No stage has {head} >= {count_needed} (max={ceiling})"
    return "Unknown reason"


class GCFWWebWorld(WebWorld):
    theme = "ocean"


class GemcraftFrostbornWrathWorld(World):
    """GemCraft: Frostborn Wrath is a hex-grid tower defense game with gem crafting.
    Complete stages to receive field tokens that unlock further stages, all shuffled
    into an Archipelago multiworld."""

    game = "GemCraft: Frostborn Wrath"
    web = GCFWWebWorld()
    options_dataclass = GCFWOptions
    options: GCFWOptions
    topology_present = True

    option_groups = [
        OptionGroup("Game Options", [
            Goal,
            FieldTokenGranularity,
            StashKeyGranularity,
            GemPouchGranularity,
            FieldTokenPlacement,
            XpTomeBonus,
            AchievementRequiredEffort,
            SkillpointMultiplier,
        ]),
        OptionGroup("DeathLink Options", [
            DeathLink,
            DeathLinkPunishment,
            GemLossPercent,
            WaveSurgeCount,
            WaveSurgeGemLevel,
            SpawnHordeCount,
            SpawnSpecialElements,
            SpawnSpecialCount,
            DeathLinkGracePeriod,
            DeathLinkCooldown,
        ]),
    ]

    item_name_to_id: Dict[str, int] = {name: data.id for name, data in item_table.items()}
    location_name_to_id: Dict[str, int] = {name: data.id for name, data in location_table.items()}

    def generate_early(self) -> None:
        with phase(f"p{self.player} generate_early"):
            # Universal Tracker re-gen passthrough: when UT triggers a fresh
            # generation via `interpret_slot_data` returning the slot_data
            # dict, that dict lands here under `multiworld.re_gen_passthrough`.
            # Overwrite YAML-rolled option values with the actual seed's
            # resolved values so UT doesn't re-roll randomness (notably
            # `starting_stage`) each reconnect. Every option that influences
            # regions, rules, or item-pool composition is listed — omitting
            # one means UT diverges from the server world along that axis.
            re_gen_passthrough = getattr(self.multiworld, "re_gen_passthrough", {})
            if self.game in re_gen_passthrough:
                slot_data = re_gen_passthrough[self.game]
                for key in (
                    "goal",
                    "fields_required",
                    "fields_required_percentage",
                    "starting_stage",
                    "field_token_placement",
                    "field_token_granularity",
                    "stash_key_granularity",
                    "gem_pouch_granularity",
                    "achievement_required_effort",
                    "disable_endurance",
                    "disable_trial",
                    "starting_overcrowd",
                    "starting_wizard_level",
                    "xp_tome_bonus",
                    "skillpoint_multiplier",
                ):
                    if key in slot_data:
                        opt = getattr(self.options, key, None)
                        if opt is not None:
                            opt.value = slot_data[key]

            # Under Universal Tracker the multiworld is regenerated as a single
            # player (just the tracked slot), so `players == 1` even for a real
            # multiplayer seed. Detect that via the same re_gen_passthrough signal
            # used above and skip the player-count guards, otherwise UT crashes on
            # a 'different_world'/'own_world' slot.
            generation_for_UT = self.game in re_gen_passthrough

            if (not generation_for_UT
                    and self.options.field_token_placement.value == FieldTokenPlacement.option_different_world
                    and self.multiworld.players == 1):
                raise Exception(f"{self.player_name}: field_token_placement 'different_world' requires more than one player.")
            if (not generation_for_UT
                    and self.options.field_token_placement.value == FieldTokenPlacement.option_own_world
                    and self.multiworld.players == 1):
                raise Exception(f"{self.player_name}: field_token_placement 'own_world' requires more than one player.")

    _JOURNEY_PRIORITY_FRACTION = 0.75

    def pre_fill(self) -> None:
        with phase(f"p{self.player} pre_fill"):
            from Fill import FillError, fill_restrictive

            # Bias 75% of Journey checks to hold progression items via main fill.
            # priority_locations is multiworld-safe — items can come from any
            # player's pool; only the destination is preferred.
            journey_locs = [
                loc for loc in self.multiworld.get_locations(self.player)
                if loc.name.endswith(" - Journey")
            ]
            if journey_locs:
                self.multiworld.random.shuffle(journey_locs)
                sample_size = max(1, int(len(journey_locs) * self._JOURNEY_PRIORITY_FRACTION))
                for loc in journey_locs[:sample_size]:
                    loc.progress_type = LocationProgressType.PRIORITY

            placement = self.options.field_token_placement.value
            if placement != FieldTokenPlacement.option_own_world:
                return  # any_world: nothing to do; different_world: handled in stage_pre_fill

            tokens = [item for item in self.multiworld.itempool
                      if item.player == self.player and item.name.endswith(" Field Token")]
            for token in tokens:
                self.multiworld.itempool.remove(token)

            target_locations = self.multiworld.get_unfilled_locations(self.player)
            state = self.multiworld.get_all_state(use_cache=False)
            fill_restrictive(self.multiworld, state, target_locations, tokens,
                             lock=True, allow_partial=False)

    @classmethod
    def stage_pre_fill(cls, multiworld: "MultiWorld") -> None:
        from Fill import FillError, fill_restrictive

        # Handle different_world token placement here (after all worlds' pre_fill methods
        # have run) so that other worlds' pre_fill claims their locations first.
        gcfw_worlds = [
            world for world in multiworld.worlds.values()
            if isinstance(world, GemcraftFrostbornWrathWorld)
            and world.options.field_token_placement.value == FieldTokenPlacement.option_different_world
        ]

        for world in gcfw_worlds:
            tokens = [item for item in multiworld.itempool
                      if item.player == world.player and item.name.endswith(" Field Token")]
            for token in tokens:
                multiworld.itempool.remove(token)

            state = multiworld.get_all_state(use_cache=False)

            if multiworld.players > 1:
                other_locations = [loc for loc in multiworld.get_unfilled_locations()
                                   if loc.player != world.player]
                fill_restrictive(multiworld, state, other_locations, tokens,
                                 lock=True, allow_partial=True)

            if tokens:
                own_locations = multiworld.get_unfilled_locations(world.player)
                fill_restrictive(multiworld, state, own_locations, tokens,
                                 lock=True, allow_partial=False)

    def create_item(self, name: str) -> GCFWItem:
        data = item_table[name]
        return GCFWItem(name, data.classification, data.id, self.player)

    def create_items(self) -> None:
        import time as _t; _t0 = _t.perf_counter()
        stages = _load_stages()
        pool: List[GCFWItem] = []

        # Field tokens — count and names depend on field_token_granularity:
        #   per_stage: 122 tokens (one per stage), starter's token precollected
        #   per_tile:  26 tokens (one per stage prefix), starter's tile precollected
        #   per_tier:  N tokens (one per active tier), starter's tier precollected
        # The starter's covering token is always pushed to precollected items
        # so Menu->starter is satisfied without the player having to find it.
        from . import gating as _gating
        ft_gran = self.options.field_token_granularity.value
        # Progressive variants need M copies precollected (M = starter's index
        # in the unlock order + 1) so the starter is reachable from frame 0.
        # Distinct variants precollect a single covering item.
        for tok_name in _gating.starter_field_tokens_to_precollect(self.start_sid, ft_gran):
            self.multiworld.push_precollected(self.create_item(tok_name))
        for token_name in _gating.field_tokens_for_pool(ft_gran, self.start_sid):
            pool.append(self.create_item(token_name))

        # Skills (includes gem-type unlocks at positions 7–12)
        for name in item_table:
            if name.endswith(" Skill"):
                pool.append(self.create_item(name))

        # Battle traits — one copy per player. Each GCFW player needs 15 traits
        # in their own pool; AP routes ownership and cross-player drops automatically.
        # When `starting_overcrowd` is on, Overcrowd is precollected (removed from
        # this player's pool) and an Extra XP Item is added in its place to keep
        # the item count == location count.
        battle_trait_items = [name for name in item_table if name.endswith(" Battle Trait")]
        for name in battle_trait_items:
            if name == "Overcrowd Battle Trait" and self.options.starting_overcrowd:
                self.multiworld.push_precollected(self.create_item(name))
                pool.append(self.create_item("Extra XP Item #1"))
            else:
                pool.append(self.create_item(name))

        # Location-specific talisman fragments (53) and shadow core stashes (17)
        for name in item_table:
            if name.endswith(" Talisman Fragment") and name != "Talisman Fragment":
                pool.append(self.create_item(name))
            elif name.endswith(" Shadow Cores"):
                pool.append(self.create_item(name))

        gd = _load_game_data()

        # Extra talisman fragments — currently empty (vanilla drops cover the
        # rest); loop kept for forward compatibility.
        for frag in gd["extra_talisman_fragments"]:
            pool.append(self.create_item(frag["name"]))

        # Extra shadow core stashes (IDs 1300–1317)
        for sc in gd["extra_shadow_core_stashes"]:
            pool.append(self.create_item(sc["name"]))

        # XP tomes — fixed counts scaled so option=50→50 levels, option=300→300 levels.
        # 32 Tattered + 6 Worn + 2 Ancient = 40 tomes; at multiplier 1 (option=50): 32+12+6=50.
        for name, count in (("Ancient Grimoire", 2), ("Worn Tome", 6), ("Tattered Scroll", 32)):
            for i in range(count):
                pool.append(self.create_item(f"{name} #{i+1}"))

        # Achievements — locations only (no longer 1:1 items). SP is filler now,
        # so achievement *locations* still get checks but the items at those
        # locations come from the general pool. Still need to mutate
        # achievement requirements here because rules.py reads them at set_rules time.
        required_effort = self.options.achievement_required_effort.value
        if required_effort > 0:
            from .rulesdata_achievements import achievement_requirements as all_achievements

            def _reqs_have_trait(reqs):
                for r in reqs:
                    if isinstance(r, list):
                        if _reqs_have_trait(r):
                            return True
                    elif "trait" in r.lower():
                        return True
                return False

            def _strip_elements(reqs):
                result = []
                for r in reqs:
                    if isinstance(r, list):
                        inner = _strip_elements(r)
                        if inner:
                            result.append(inner)
                    else:
                        r_lower = r.lower()
                        if "trait" in r_lower or "skill" in r_lower or r.startswith("Achievement:"):
                            result.append(r)
                return result

            # Simplify achievements: if they have trait requirements, remove element requirements
            # This avoids circular dependencies where trait items might be in trait-locked locations
            for ach_name, ach_data in all_achievements.items():
                requirements = ach_data.get("requirements", [])
                if requirements and _reqs_have_trait(requirements):
                    ach_data["requirements"] = _strip_elements(requirements)

            # Track which achievements get an actual AP location for the chain
            # injection step. Mirror the filters create_regions uses so the two
            # stay in sync.
            included_achievements = set()
            effort_hierarchy = ["Trivial", "Minor", "Major", "Extreme"]
            max_effort_str = effort_hierarchy[min(required_effort - 1, len(effort_hierarchy) - 1)]
            for ach_name, ach_data in all_achievements.items():
                ach_effort = ach_data.get("required_effort", "Trivial")
                if ach_effort in effort_hierarchy:
                    if effort_hierarchy.index(ach_effort) > effort_hierarchy.index(max_effort_str):
                        continue
                if _should_skip_achievement(ach_data, self.options):
                    continue
                if not _can_achievement_be_met(ach_data.get("requirements", [])):
                    continue
                included_achievements.add(ach_name)

        # Wizard Stash keys — count and names depend on stash_key_granularity:
        #   per_stage: 122 keys (one per stage)
        #   per_tile:  26 keys (one per stage prefix)
        #   per_tier:  N keys (one per active tier, N = len(ACTIVE_TIERS))
        #   global:    1 master key
        from . import gating as _gating
        for key_name in _gating.stash_keys_for_pool(self.options.stash_key_granularity.value):
            pool.append(self.create_item(key_name))

        # Gempouches — added based on gem_pouch_granularity option.
        # No pouch is precollected: the starter stage (whichever prefix the
        # seed picks) is bootstrappable via Hollow Gems supplied by the mod's
        # HollowGemInjector when the matching pouch is missing. So every
        # pouch goes into the pool and gets randomized.
        for pouch_name in _gating.pouches_for_pool(self.options.gem_pouch_granularity.value):
            pool.append(self.create_item(pouch_name))

        # SP bundle filler — fills all remaining unfilled location slots.
        # Total SP scales with skillpoint_multiplier (default 100 → 2500 SP).
        # Bundles are split across four named tiers (Small/Medium/Large/Huge)
        # whose SP values are computed per-seed based on the actual filler-slot
        # count — see compute_tier_distribution. Tier values are stored on self
        # so fill_slot_data can ship them to the mod.
        # The -1 is for the Victory event location (filled by place_locked_item
        # in generate_basic — outside the regular pool).
        total_locations = sum(1 for region in self.multiworld.regions
                              if region.player == self.player
                              for _ in region.locations)
        remaining = total_locations - len(pool) - 1
        self.sp_bundle_values: List[int] = [0, 0, 0, 0]
        if remaining > 0:
            total_sp = 2500 * self.options.skillpoint_multiplier.value // 100
            values, counts = _compute_sp_bundle_distribution(total_sp, remaining)
            self.sp_bundle_values = values
            bundles = generate_sp_bundles(self.random, counts)
            for name in bundles:
                pool.append(self.create_item(name))

        self.multiworld.itempool += pool
        _timing_log(f"p{self.player} create_items: {(_t.perf_counter()-_t0)*1000:.1f} ms (pool={len(pool)})")

    def create_regions(self) -> None:
        import time as _t; _t0 = _t.perf_counter()
        # Resolve the chosen start stage. Its baked `requirements` in
        # rulesdata_levels.py are intentionally ignored at rule-time
        # (see rules.set_rules); Menu connects directly to its region.
        self.start_sid = STARTING_STAGE_BY_VALUE[self.options.starting_stage.value]

        stages = _load_stages()
        # All stages get a region (needed for the region graph).
        # W1 has no AP item/locations but is the world entry point.
        all_stage_map = {s["str_id"]: s for s in stages}

        menu_region = Region("Menu", self.player, self.multiworld)
        self.multiworld.regions.append(menu_region)

        # Create one region per stage — every stage has AP locations (Journey + Wizard stash).
        # All locations are normal progress type; XP and token gates are on region connections.
        # Wizard stash is additionally gated behind a per-stage "Wizard Stash {str_id} Unlock" item
        # (see _gate_wizard_stash_locations in rules.py).
        stage_regions: Dict[str, Region] = {}
        for str_id, stage in all_stage_map.items():
            region = Region(str_id, self.player, self.multiworld)
            journey_name = f"Complete {str_id} - Journey"
            journey_data = location_table[journey_name]
            region.locations.append(GCFWLocation(self.player, journey_name, journey_data.id, region))
            wiz_loc_name = f"Complete {str_id} - Wizard stash"
            wiz_loc_data = location_table[wiz_loc_name]
            region.locations.append(GCFWLocation(self.player, wiz_loc_name, wiz_loc_data.id, region))
            stage_regions[str_id] = region
            self.multiworld.regions.append(region)

        # Create achievements region with locations based on required_effort
        required_effort = self.options.achievement_required_effort.value
        if required_effort > 0:
            from .rulesdata_achievements import achievement_requirements as all_achievements

            achievements_region = Region("Achievements", self.player, self.multiworld)

            # Effort hierarchy for filtering
            effort_hierarchy = ["Trivial", "Minor", "Major", "Extreme"]
            max_effort_str = effort_hierarchy[min(required_effort - 1, len(effort_hierarchy) - 1)] if required_effort > 0 else "Trivial"

            # Add achievement locations filtered by required_effort level
            for ach_name, ach_data in all_achievements.items():
                # Filter by required_effort level
                ach_effort = ach_data.get("required_effort", "Trivial")
                if ach_effort in effort_hierarchy:
                    if effort_hierarchy.index(ach_effort) > effort_hierarchy.index(max_effort_str):
                        continue  # Skip achievements above selected effort level

                # Untrackable / Trial / disabled-Endurance — no AP location.
                if _should_skip_achievement(ach_data, self.options):
                    continue

                requirements = ach_data.get("requirements", [])
                if not _can_achievement_be_met(requirements):
                    continue  # Skip achievements with truly unavailable requirements

                loc_name = f"Achievement: {ach_name}"
                if loc_name in location_table:
                    loc_data = location_table[loc_name]
                    loc = GCFWLocation(self.player, loc_name, loc_data.id, achievements_region)
                    achievements_region.locations.append(loc)

            self.multiworld.regions.append(achievements_region)
            menu_region.connect(achievements_region, "Achievements")

        if self.options.goal.value == 0:
            kill_gatekeeper_region = Region("Kill Gatekeeper Goal", self.player, self.multiworld)
            kill_gatekeeper_region.locations.append(GCFWLocation(self.player, "Complete A4 - Frostborn Wrath Victory", None, kill_gatekeeper_region))
            self.multiworld.regions.append(kill_gatekeeper_region)
            menu_region.connect(kill_gatekeeper_region, "Kill Gatekeeper")            

        if self.options.goal.value == 2:
            kill_swarm_queen_region = Region("Kill Swarm Queen Goal", self.player, self.multiworld)
            kill_swarm_queen_region.locations.append(GCFWLocation(self.player, "Kill Swarm Queen Victory", None, kill_swarm_queen_region))
            self.multiworld.regions.append(kill_swarm_queen_region)
            menu_region.connect(kill_swarm_queen_region, "Kill swarm")            

        # full_talisman goal: victory event in a dedicated region (no item requirements)
        if self.options.goal.value == 1:
            talisman_region = Region("Talisman Goal", self.player, self.multiworld)
            talisman_region.locations.append(GCFWLocation(self.player, "Full Talisman Victory", None, talisman_region))
            self.multiworld.regions.append(talisman_region)
            menu_region.connect(talisman_region, "Talisman")

        # fields_count / fields_percentage goals: victory in dedicated regions
        if self.options.goal.value == 3:
            fields_count_region = Region("Fields Count Goal", self.player, self.multiworld)
            fields_count_region.locations.append(GCFWLocation(self.player, "Fields Count Victory", None, fields_count_region))
            self.multiworld.regions.append(fields_count_region)
            menu_region.connect(fields_count_region, "Fields Count")

        if self.options.goal.value == 4:
            fields_pct_region = Region("Fields Percentage Goal", self.player, self.multiworld)
            fields_pct_region.locations.append(GCFWLocation(self.player, "Fields Percentage Victory", None, fields_pct_region))
            self.multiworld.regions.append(fields_pct_region)
            menu_region.connect(fields_pct_region, "Fields Percentage")

        # Connect Menu → starting stage. All other stages connect from the
        # starting stage in set_rules.
        menu_region.connect(stage_regions[self.start_sid], "Start")
        _timing_log(f"p{self.player} create_regions: {(_t.perf_counter()-_t0)*1000:.1f} ms")

    def set_rules(self) -> None:
        with phase(f"p{self.player} set_rules"):
            set_rules(self)

    def generate_basic(self) -> None:
        import time as _t; _t0 = _t.perf_counter()
        # Place the Victory event at the goal-appropriate location.
        if self.options.goal.value == 0:
            victory_name = "Complete A4 - Frostborn Wrath Victory"
        elif self.options.goal.value == 2:
            victory_name = "Kill Swarm Queen Victory"
        elif self.options.goal.value == 3:
            victory_name = "Fields Count Victory"
        elif self.options.goal.value == 4:
            victory_name = "Fields Percentage Victory"
        else:
            victory_name = "Full Talisman Victory"
        victory_loc = self.multiworld.get_location(victory_name, self.player)
        victory_loc.place_locked_item(
            GCFWItem("Victory", ItemClassification.progression, None, self.player)
        )

        # Skills stay in the shared item pool — placed anywhere by Archipelago's fill algorithm.
        _timing_log(f"p{self.player} generate_basic: {(_t.perf_counter()-_t0)*1000:.1f} ms")

    # def fill_hook(self, progitempool, usefulitempool, filleritempool, fill_locations):
    #     # Reorder progitempool so fill_restrictive (which pops from the end) places items in
    #     # this sphere order:
    #     #   tier-0 tokens → skills for tier 1 → tier-1 tokens → skills for tier 2 → ...
    #     #
    #     # Without skill reordering, skills land in random positions and can end up being placed
    #     # last, at which point all low-tier locations are filled and the remaining locations are
    #     # in tiers 9-12 (which require more skills than are in the state) — causing a FillError.
    #     #
    #     # The 24 skills map exactly onto the 12×2 tier requirements
    #     # (6 spells + 4 focus + 6 gems + 4 buildings + 4 wrath = 24), so every skill gets a slot.
    #     #
    #     # In own_world mode, tokens are pre_fill'd and absent from the pool; only skills are
    #     # reordered here. In any_world mode, skills and tokens are interleaved correctly.
    #
    #     # Build reverse lookup: skill name → category
    #     skill_to_category: Dict[str, str] = {
    #         skill: cat
    #         for cat, skills in SKILL_CATEGORIES.items()
    #         for skill in skills
    #     }
    #
    #     # Collect this player's skill items per category
    #     category_skill_items: Dict[str, list] = {cat: [] for cat in SKILL_CATEGORIES}
    #     for item in progitempool:
    #         if item.player == self.player and item.name.endswith(" Skill"):
    #             cat = skill_to_category.get(item.name[:-6])
    #             if cat:
    #                 category_skill_items[cat].append(item)
    #
    #     category_ptr: Dict[str, int] = {cat: 0 for cat in SKILL_CATEGORIES}
    #
    #     # Iterate tiers from highest to lowest. Each append goes to the END of the pool,
    #     # so the last appended item is popped (placed) first by fill_restrictive.
    #     # After the loop the pool tail looks like:
    #     #   ... [tier-12_toks][skills_for_t12][tier-11_toks][skills_for_t11][tier-10_toks]...[skills_for_t1][tier-0_toks]
    #     # Popping from the right: tier-0 tokens first, then skills for tier 1, then tier-1 tokens, etc.
    #     for t in range(12, 0, -1):
    #         prev_tier = t - 1
    #         level_req = len(TIERS[prev_tier]) * self.options.tier_requirements_percent // 100
    #
    #         # Append skills that unlock tier t (one per required category).
    #         # These land just before the tier-(t-1) tokens in the pool tail, so they are
    #         # placed right after those tokens unlock the tier-(t-1) stage locations.
    #         for category in TIER_SKILL_REQUIREMENTS.get(t, []):
    #             ptr = category_ptr[category]
    #             if ptr < len(category_skill_items[category]):
    #                 skill_item = category_skill_items[category][ptr]
    #                 category_ptr[category] += 1
    #                 pool_idx = next(
    #                     (i for i, x in enumerate(progitempool) if x is skill_item), None
    #                 )
    #                 if pool_idx is not None:
    #                     progitempool.append(progitempool.pop(pool_idx))
    #
    #         # Append enough tier-(prev_tier) tokens to satisfy the tier-t requirement.
    #         moved_levels = 0
    #         prog_idx = 0
    #         while moved_levels < level_req:
    #             if prog_idx >= len(progitempool):
    #                 break  # tokens already placed via pre_fill (own_world); quota is fine
    #             this_item = progitempool[prog_idx]
    #             if (this_item.player == self.player
    #                     and this_item.name.endswith(" Field Token")):
    #                 this_field = this_item.name[:2]
    #                 if this_field in TIERS[prev_tier]:
    #                     progitempool.append(progitempool.pop(prog_idx))
    #                     moved_levels += 1
    #                     prog_idx -= 1
    #             prog_idx += 1
    #
    #     # Tier-12 tokens (A4, A5, A6) are never covered by the loop above (there is no t=13).
    #     # Without this they land in the unsorted leftover section and are placed last, meaning
    #     # tier-12 regions open too late and the fill may run out of accessible locations for
    #     # the final progression items.  Move all tier-12 tokens just before the tier-12 skills
    #     # so they are placed after all 24 skills are in state (opening tier-12 regions for filler).
    #     for prog_idx in range(len(progitempool) - 1, -1, -1):
    #         this_item = progitempool[prog_idx]
    #         if (this_item.player == self.player
    #                 and this_item.name.endswith(" Field Token")
    #                 and this_item.name[:2] in TIERS[12]):
    #             progitempool.append(progitempool.pop(prog_idx))


    @staticmethod
    def interpret_slot_data(slot_data: dict) -> dict:
        """Universal Tracker hook. Returning a non-None value tells UT to
        restart generation with the returned dict accessible via
        `multiworld.re_gen_passthrough[self.game]`. generate_early picks the
        resolved option values up from there so UT does NOT re-roll YAML
        randomness (notably `starting_stage`) on every reconnect."""
        return slot_data


    def fill_slot_data(self) -> Dict:
        # Main fill happens between generate_basic and fill_slot_data, so this
        # is where we dump the per-rule call counters.
        report_top_rules()
        import time as _t; _t0 = _t.perf_counter()
        gd = _load_game_data()
        stages = gd["stages"]

        # Field token map: item AP ID (str) → stage str_id
        token_map = {
            str(s["item_ap_id"]): s["str_id"]
            for s in stages
            if s["item_ap_id"] is not None
        }

        # Stages that are immediately playable from session start. The exact
        # set depends on granularity AND whether progressive: distinct modes
        # cover the starter's tile/tier/stage; progressive modes cover the
        # first M groups of the unlock order, where M = starter's position + 1
        # (i.e. the same M copies the apworld precollects). The mod uses this
        # list for HollowGemInjector, FirstPlayBypass, and free-buildings.
        #
        # NOTE: doing this via item-name equality breaks under progressive,
        # since every stage shares the same singleton item name. The helper
        # uses the same M-position logic that drives precollect.
        from . import gating as _gating
        ft_gran = self.options.field_token_granularity.value
        free_stages = _gating.free_stages_for_starter(self.start_sid, ft_gran)

        # Talisman map: item AP ID (str) → "seed/rarity/type/upgradeLevel" (IDs 900–952)
        talisman_map = {
            str(frag["item_ap_id"]): frag["tal_data"]
            for frag in gd["talisman_fragments"]
        }
        talisman_map.update({
            str(frag["item_ap_id"]): frag["tal_data"]
            for frag in gd["extra_talisman_fragments"]
        })

        # Talisman name map: item AP ID (str) → display name (IDs 900–952)
        talisman_name_map = {
            str(frag["item_ap_id"]): f"{frag['str_id']} Talisman Fragment"
            for frag in gd["talisman_fragments"]
        }
        talisman_name_map.update({
            str(frag["item_ap_id"]): frag["name"]
            for frag in gd["extra_talisman_fragments"]
        })

        # Wiz stash talisman data: str_id → "seed/rarity/type/upgradeLevel"
        # Used by NormalProgressionBlocker to identify and remove stash-granted fragments.
        wiz_stash_tal_data = {
            frag["str_id"]: frag["tal_data"]
            for frag in gd["talisman_fragments"]
        }

        # Shadow core map: item AP ID (str) → amount (IDs 1000–1016, 1300–1317)
        shadow_core_map = {
            str(sc["item_ap_id"]): sc["total"]
            for sc in gd["shadow_core_stashes"]
        }
        shadow_core_map.update({
            str(sc["item_ap_id"]): sc["amount"]
            for sc in gd["extra_shadow_core_stashes"]
        })

        # Shadow core name map: item AP ID (str) → display name (IDs 1000–1016, 1300–1317)
        shadow_core_name_map = {
            str(sc["item_ap_id"]): f"{sc['str_id']} Shadow Cores"
            for sc in gd["shadow_core_stashes"]
        }
        shadow_core_name_map.update({
            str(sc["item_ap_id"]): sc["name"]
            for sc in gd["extra_shadow_core_stashes"]
        })

        # XP tome levels — 32 Tattered + 6 Worn + 2 Ancient = 40 tomes.
        # At multiplier 1 (option=50): 32×1 + 6×2 + 2×3 = 50 levels exactly.
        # At multiplier 6 (option=300): 32×6 + 6×12 + 2×18 = 300 levels exactly.
        xp_target = self.options.xp_tome_bonus.value
        multiplier = xp_target / 50.0
        tattered_levels = max(1, round(multiplier))
        worn_levels     = max(1, round(multiplier * 2))
        ancient_levels  = max(1, round(multiplier * 3))

        # --- In-game tracker: per-achievement requirements map ---
        # Stage logic (WIZLOCK skills + prereq tokens + talisman counters)
        # is shipped via logic.json (generate_logic_json.py); slot_data here
        # only carries options + the per-achievement requirements list so the
        # mod's AchievementLogicEvaluator can mirror the in-logic display.
        # Mirror exactly the same effort / skip / structural-reachability
        # filters that create_regions applies when generating AP locations,
        # so the mod's AchievementLogicEvaluator tracks the same set as
        # Universal Tracker. Without these filters the mod shows
        # achievements that don't exist as AP locations (e.g. untrackable,
        # Trial-only, or structurally-impossible achievements), which
        # makes its "in-logic count" diverge from UT's.
        achievement_requirements_map: Dict[str, list] = {}
        required_effort = self.options.achievement_required_effort.value
        if required_effort > 0:
            from .rulesdata_achievements import achievement_requirements as all_achievements

            effort_hierarchy = ["Trivial", "Minor", "Major", "Extreme"]
            max_effort_idx = min(required_effort - 1, len(effort_hierarchy) - 1)

            for ach_name, ach_data in all_achievements.items():
                ach_effort = ach_data.get("required_effort", "Trivial")
                if ach_effort in effort_hierarchy:
                    if effort_hierarchy.index(ach_effort) > max_effort_idx:
                        continue
                if _should_skip_achievement(ach_data, self.options):
                    continue
                requirements = ach_data.get("requirements", [])
                if not requirements:
                    continue
                if not _can_achievement_be_met(requirements):
                    continue
                achievement_requirements_map[ach_name] = requirements

        # Per-stage element/monster lists for the in-game field tooltip.
        # Derived from per-stage Count fields in rulesdata_levels.py.
        # Members of eNonMonsters (Shadow / Specter / etc.) feed the
        # "monsters" tooltip column; everything else feeds "elements".
        # Tower / Wall / Wizard Stash are universal basics with no Count
        # field, so they fall out automatically.
        from .requirement_tokens import element_prefix_map
        from .rules import _element_count_field

        monster_names = set(element_prefix_map.get("eNonMonsters", []))
        stage_elements: Dict[str, List[str]] = {}
        stage_monsters: Dict[str, List[str]] = {}
        for token, names in element_prefix_map.items():
            if len(names) != 1:
                continue  # group tokens (eNonMonsters) handled via membership above
            elem_name = names[0]
            if elem_name == "Wizard Stash":
                continue
            field = _element_count_field(elem_name)
            target = stage_monsters if elem_name in monster_names else stage_elements
            for sid, data in LEVEL_DATA.items():
                if data.get(field, 0) > 0:
                    target.setdefault(sid, []).append(elem_name)
        for v in stage_elements.values():
            v.sort()
        for v in stage_monsters.values():
            v.sort()

        _timing_log(f"p{self.player} fill_slot_data: {(_t.perf_counter()-_t0)*1000:.1f} ms")
        return {
            "goal":                  self.options.goal.value,
            "starting_stage":        self.options.starting_stage.value,
            "field_token_placement": self.options.field_token_placement.value,
            "xp_tome_bonus":         self.options.xp_tome_bonus.value,
            "skillpoint_multiplier": self.options.skillpoint_multiplier.value,
            # Per-seed SP value granted by each Skillpoint Bundle tier, indexed
            # by AP id offset from 1700: [Small, Medium, Large, Huge]. Computed
            # in create_items so the four piles divide cleanly across the actual
            # filler-slot count. The mod uses this for grant amounts and for
            # the in-mod skillPoints:N achievement-gate counter.
            "sp_bundle_values":      list(getattr(self, "sp_bundle_values", [0, 0, 0, 0])),
            "sp_bundle_tier_names":  list(_SP_TIER_NAMES),
            "tattered_scroll_levels": tattered_levels,
            "worn_tome_levels":       worn_levels,
            "ancient_grimoire_levels": ancient_levels,
            "token_map":             token_map,
            "free_stages":           free_stages,
            # Per-stage logic (WIZLOCK skills, prereq Field tokens, talisman
            # row/column counts, skillPoints, etc.) lives in logic.json —
            # generated by py-scripts/generate_logic_json.py and embedded in
            # the mod SWF. slot_data only carries options and goal data now.
            "logic_rules_version":   2,
            "skill_categories":      SKILL_CATEGORIES,
            "stage_elements":        stage_elements,
            "stage_monsters":        stage_monsters,
            "talisman_map":          talisman_map,
            "talisman_name_map":     talisman_name_map,
            "wiz_stash_tal_data":    wiz_stash_tal_data,
            "shadow_core_map":       shadow_core_map,
            "shadow_core_name_map":  shadow_core_name_map,
            "achievement_required_effort": self.options.achievement_required_effort.value,
            "disable_endurance":       bool(self.options.disable_endurance.value),
            "disable_trial":           bool(self.options.disable_trial.value),
            "starting_wizard_level":   self.options.starting_wizard_level.value,
            "starting_overcrowd":      bool(self.options.starting_overcrowd.value),
            # Granularity settings for the three gating-item categories.
            # Mod uses these to interpret coarser items (e.g. a per_tile stash
            # key unlocks every stash with that prefix). Each granularity has
            # a "_progressive" sibling: a single fungible item id is added N
            # times to the pool; the Nth received copy unlocks the Nth entry
            # in PROGRESSIVE_TILE_ORDER (for per_tile / per_tier variants) or
            # in the per-stage progressive order (tile playOrder x within-tile
            # alphabetical).
            #   field_token_granularity: 0=per_stage, 1=per_stage_progressive,
            #                            2=per_tile,  3=per_tile_progressive,
            #                            4=per_tier,  5=per_tier_progressive
            #   stash_key_granularity:   0=off, 1=per_stage, 2=per_stage_progressive,
            #                            3=per_tile,  4=per_tile_progressive,
            #                            5=per_tier,  6=per_tier_progressive, 7=global
            #   gem_pouch_granularity:   0=off, 1=per_tile, 2=per_tile_progressive,
            #                            3=per_tier, 4=per_tier_progressive, 5=global
            "field_token_granularity": self.options.field_token_granularity.value,
            "stash_key_granularity":   self.options.stash_key_granularity.value,
            "gem_pouch_granularity":   self.options.gem_pouch_granularity.value,
            # Canonical play order — used for distinct gempouch ID assignment
            # (apId 626 + idx in this list) and for UI display ordering.
            "gem_pouch_play_order":    list(GEM_POUCH_PLAY_ORDER),
            # Canonical per-stage progressive order (kept for backward compat
            # with older mod builds; the starter-first variant below should be
            # used by all new progressive-mode logic).
            "stage_progressive_order": [
                s for prefix in GEM_POUCH_PLAY_ORDER
                for s in sorted(
                    st["str_id"] for st in GAME_DATA["stages"]
                    if st["str_id"][0] == prefix
                )
            ],
            # Starter-aware progressive orders — the Nth copy of a progressive
            # item unlocks the Nth entry of the matching list below. Position
            # 0 is always the starter's own group, so a single precollected
            # copy lands the player exactly on the starter and the first
            # *received* copy unlocks the next group in canonical order.
            "progressive_tile_order":  _gating.progressive_tile_order_for_starter(self.start_sid),
            "progressive_stage_order": _gating.progressive_stage_order_for_starter(self.start_sid),
            "progressive_tier_order":  _gating.progressive_tier_order_for_starter(self.start_sid),
            # Singleton item ids for each progressive variant. The mod uses
            # these to recognize which apId is "the progressive item" for
            # a given category and granularity, then count-tracks via
            # AV.sessionData.getItemCount(apId).
            "gem_pouch_progressive_id":             item_table["Progressive Gempouch"].id,
            "gem_pouch_per_tier_progressive_id":    item_table["Progressive Gempouch (per-tier)"].id,
            "field_token_per_stage_progressive_id": item_table["Progressive Field Token (per-stage)"].id,
            "field_token_per_tile_progressive_id":  item_table["Progressive Field Token (per-tile)"].id,
            "field_token_per_tier_progressive_id":  item_table["Progressive Field Token (per-tier)"].id,
            "stash_key_per_stage_progressive_id":   item_table["Progressive Stash Stage Key"].id,
            "stash_key_per_tile_progressive_id":    item_table["Progressive Stash Tile Key"].id,
            "stash_key_per_tier_progressive_id":    item_table["Progressive Stash Tier Key"].id,
            # Per-stage tier assignments so the mod can resolve coarse
            # tier-keyed items (e.g. "Tier 3 Field Token" → all tier-3 stages).
            "stage_tier_by_str_id": {
                s["str_id"]: STAGE_RULES[s["str_id"]].tier
                for s in GAME_DATA["stages"]
            },
            "enemy_hp_multiplier":          self.options.enemy_hp_multiplier.value,
            "enemy_armor_multiplier":       self.options.enemy_armor_multiplier.value,
            "enemy_shield_multiplier":      self.options.enemy_shield_multiplier.value,
            "enemies_per_wave_multiplier":  self.options.enemies_per_wave_multiplier.value,
            "extra_wave_count":             self.options.extra_wave_count.value,
            "fields_required":              self.options.fields_required.value,
            "fields_required_percentage":   self.options.fields_required_percentage.value,
            # Resolved absolute stage count for the active goal. Mod uses this
            # as the FieldCount/FieldPercentage threshold directly — no
            # client-side math, no risk of floor/ceil drift against rules.py.
            # 0 for goals that don't gate on a stage count.
            "fields_required_count":        _resolve_fields_required_count(self),
            "death_link":              bool(self.options.death_link.value),
            "death_link_punishment":   self.options.death_link_punishment.value,
            "gem_loss_percent":        self.options.gem_loss_percent.value,
            "wave_surge_count":        self.options.wave_surge_count.value,
            "wave_surge_gem_level":    self.options.wave_surge_gem_level.value,
            "spawn_horde_count":       self.options.spawn_horde_count.value,
            "spawn_special_elements":  sorted(self.options.spawn_special_elements.value),
            "spawn_special_count":     self.options.spawn_special_count.value,
            "death_link_grace_period": self.options.death_link_grace_period.value,
            "death_link_cooldown":     self.options.death_link_cooldown.value,
        }

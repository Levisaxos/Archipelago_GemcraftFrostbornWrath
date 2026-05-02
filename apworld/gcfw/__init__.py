from __future__ import annotations

from typing import Dict, List

from BaseClasses import ItemClassification, Region
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
    DeathLinkGracePeriod,
    DeathLinkCooldown,
    AchievementRequiredEffort,
    SkillpointMultiplier,
    GemPouchGating,
    STARTING_STAGE_BY_VALUE,
)
from .items_skillpoints import generate_sp_bundles
from ._timing import phase, log as _timing_log, report_top_rules
from .rules import set_rules
from .rulesdata import (
    GAME_DATA,
    SKILL_CATEGORIES,
    GEM_POUCH_PLAY_ORDER,
)
from .rulesdata_levels import level_requirements as LEVEL_DATA


def _load_game_data():
    return GAME_DATA


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


def _can_achievement_be_met(requirements: list) -> bool:
    """
    Check if an achievement can be met based on its requirements (DNF format).
    Returns True if any AND-group can be met, False only if all groups are blocked.

    Element-handling convention (mirrors rules.py `_eval_req`):
      An element is structurally reachable iff at least one stage in
      LEVEL_DATA carries its <Pascal>Count field with a positive value.
      Universal-presence elements (Tower / Wall / Wizard Stash / Marked
      Monster — no Count field anywhere) fall through to "always satisfied"
      and never block.
    """
    from .requirement_tokens import element_prefix_map
    from .rules import _element_count_field, _PRESENT_COUNT_FIELDS

    def _resolve_element_names(req: str):
        """Return the list of element names a requirement refers to, or
        None if the requirement isn't an element-style token."""
        head = req.split(":", 1)[0].strip()
        return element_prefix_map.get(head)

    def _element_blocked(elem_name: str) -> bool:
        """True if this element is structurally unreachable — the element is
        tracked per-stage but no stage actually hosts it.  Universal-presence
        elements (no Count field anywhere) are never blocked."""
        if elem_name == "Wizard Stash":
            return False  # gated by per-stage keys, not by stage presence
        field = _element_count_field(elem_name)
        if field not in _PRESENT_COUNT_FIELDS:
            return False  # universal / untracked — assume reachable
        # Tracked but no stage carries a positive count -> unreachable.
        return not any(d.get(field, 0) > 0 for d in LEVEL_DATA.values())

    def _group_can_be_met(group: list) -> bool:
        for req in group:
            if isinstance(req, list):
                if not _can_achievement_be_met(req):
                    return False
                continue
            req = req.strip()
            elem_names = _resolve_element_names(req)
            if elem_names is None:
                continue
            # Group passes if any one member is reachable.  All blocked = fail.
            if all(_element_blocked(n) for n in elem_names):
                return False
        return True

    if not requirements:
        return True
    # Normalize to DNF: if first element is a list, treat as OR-of-AND-groups
    if isinstance(requirements[0], list):
        return any(_group_can_be_met(group) for group in requirements)
    return _group_can_be_met(requirements)


def _detect_achievement_chains(all_achievements) -> dict:
    """
    Auto-detect progressive achievement chains by analyzing achievement names.

    Looks for patterns like:
    - "Kill 10 Waves", "Kill 20 Waves", "Kill 30 Waves" → chain with numerical progression
    - "Do X 5 Times", "Do X 10 Times" → chain with numerical progression
    - etc.

    Returns dict: {achievement_name -> previous_achievement_name_in_chain}
    Example: {"Kill 20 Waves": "Kill 10 Waves", "Kill 30 Waves": "Kill 20 Waves"}
    """
    import re

    chains = {}

    # Detect chains by looking for numerical patterns
    for ach_name in all_achievements.keys():
        # Look for patterns: "Word1 Word2 ... Number" or "Number ... Word"
        # Examples: "Kill 10 Waves", "Do Something 5 Times"
        match = re.search(r'(\d+)', ach_name)
        if not match:
            continue

        number = int(match.group(1))
        base_name = ach_name[:match.start()] + "X" + ach_name[match.end():]

        # Look for other achievements with different numbers but same base
        potential_chain = []
        for other_name in all_achievements.keys():
            other_match = re.search(r'(\d+)', other_name)
            if not other_match:
                continue

            other_base = other_name[:other_match.start()] + "X" + other_name[other_match.end():]
            other_num = int(other_match.group(1))

            if base_name == other_base and other_num != number:
                potential_chain.append((other_num, other_name))

        # If we found other achievements with the same pattern, this is likely a chain
        if potential_chain:
            potential_chain.sort(key=lambda x: x[0])

            # Find what achievement comes before this one in the chain
            for i, (num, name) in enumerate(potential_chain):
                if name == ach_name and i > 0:
                    # This achievement has a predecessor
                    prev_num, prev_name = potential_chain[i - 1]
                    chains[ach_name] = prev_name
                    break

    return chains


def _get_filter_reason(requirements: list) -> str:
    """
    Determine why an achievement was filtered out.
    Returns a string describing the reason.
    """
    from .requirement_tokens import element_prefix_map
    from .rules import _element_count_field, _PRESENT_COUNT_FIELDS

    def _flatten(reqs):
        for r in reqs:
            if isinstance(r, list):
                yield from _flatten(r)
            else:
                yield r

    for req in _flatten(requirements):
        req = str(req).strip()
        head = req.split(":", 1)[0].strip()
        elem_names = element_prefix_map.get(head)
        if elem_names is None:
            continue
        for elem_name in elem_names:
            field = _element_count_field(elem_name)
            if field in _PRESENT_COUNT_FIELDS:
                if not any(d.get(field, 0) > 0 for d in LEVEL_DATA.values()):
                    return f"No stage hosts element '{elem_name}'"
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
            FieldTokenPlacement,
            XpTomeBonus,
            AchievementRequiredEffort,
            SkillpointMultiplier,
            GemPouchGating,
        ]),
        OptionGroup("DeathLink Options", [
            DeathLink,
            DeathLinkPunishment,
            GemLossPercent,
            WaveSurgeCount,
            WaveSurgeGemLevel,
            DeathLinkGracePeriod,
            DeathLinkCooldown,
        ]),
    ]

    item_name_to_id: Dict[str, int] = {name: data.id for name, data in item_table.items()}
    location_name_to_id: Dict[str, int] = {name: data.id for name, data in location_table.items()}

    def generate_early(self) -> None:
        with phase(f"p{self.player} generate_early"):
            if (self.options.field_token_placement.value == FieldTokenPlacement.option_different_world and self.multiworld.players == 1):
                raise Exception(f"{self.player_name}: field_token_placement 'different_world' requires more than one player.")
            if (self.options.field_token_placement.value == FieldTokenPlacement.option_own_world and self.multiworld.players == 1):
                raise Exception(f"{self.player_name}: field_token_placement 'own_world' requires more than one player.")

    def pre_fill(self) -> None:
        with phase(f"p{self.player} pre_fill"):
            from Fill import FillError, fill_restrictive

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

        # Field tokens — W1/W2/W3/W4 have item_ap_id=None and are skipped.
        # All four are free stages; the mod unlocks them on connect.
        # No placeholder is added: the 118 token items + skills/traits/talismans/
        # cores/XP-tomes already match the 366 stage locations (since W1-W4 each
        # contribute 3 locations but 0 token items, the difference is filled by
        # the always-on items below).
        for stage in stages:
            if stage["item_ap_id"] is None:
                continue
            pool.append(self.create_item(f"{stage['str_id']} Field Token"))

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

        # Extra talisman fragments (IDs 753–799)
        for frag in gd["extra_talisman_fragments"]:
            pool.append(self.create_item(frag["name"]))

        # Extra shadow core stashes (IDs 817–868)
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

            # Progressive chains: each chained achievement requires its parent's
            # location to be reachable. rules.py:_eval_req checks via state.can_reach
            # for "Achievement:" requirements when in progressive mode.
            if self.options.achievement_progression.value == 0:  # 0 = progressive
                achievement_chains = _detect_achievement_chains(all_achievements)
                for ach_name in included_achievements:
                    parent_ach = achievement_chains.get(ach_name)
                    if parent_ach and parent_ach in included_achievements:
                        ach_data = all_achievements[ach_name]
                        ach_data["requirements"] = ach_data.get("requirements", []) + [f"Achievement: {parent_ach}"]

        # Per-stage Wizard Stash key items (122 items, IDs 1400–1521).
        # Progression: each gates its matching stash location in rules.py.
        for stage in stages:
            pool.append(self.create_item(f"Wizard Stash {stage['str_id']} Key"))

        # Gempouches — added based on gem_pouch_gating option.
        # No pouch is precollected: the starter stage (whichever prefix the
        # seed picks) is bootstrappable via Hollow Gems supplied by the mod's
        # HollowGemInjector when the matching pouch is missing. So every
        # pouch goes into the pool and gets randomized.
        pouch_mode = self.options.gem_pouch_gating.value
        if pouch_mode == 1:  # distinct
            for prefix in GEM_POUCH_PLAY_ORDER:
                pool.append(self.create_item(f"Gempouch ({prefix})"))
        elif pouch_mode == 2:  # progressive
            for _ in range(len(GEM_POUCH_PLAY_ORDER)):
                pool.append(self.create_item("Progressive Gempouch"))

        # SP bundle filler — fills all remaining unfilled location slots.
        # Total SP scales with skillpoint_multiplier (default 50 → 1000 SP, see
        # SkillpointMultiplier docstring for why default is 50%).
        # The -1 is for the Victory event location (filled by place_locked_item
        # in generate_basic — outside the regular pool).
        total_locations = sum(1 for region in self.multiworld.regions
                              if region.player == self.player
                              for _ in region.locations)
        remaining = total_locations - len(pool) - 1
        if remaining > 0:
            total_sp = 2000 * self.options.skillpoint_multiplier.value // 100
            bundles = generate_sp_bundles(self.random, total_sp, remaining)
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

        # The chosen starting stage is "free" — accessible from the menu with
        # no token, and its baked `requirements` are skipped both in apworld
        # set_rules and in the mod's FieldLogicEvaluator (which treats this
        # list as the auto-unlocked / no-requirements set). All other stages
        # (including the W/S stages not picked) gate normally.
        free_stages = [self.start_sid]

        # Talisman map: item AP ID (str) → "seed/rarity/type/upgradeLevel" (IDs 700–799)
        talisman_map = {
            str(frag["item_ap_id"]): frag["tal_data"]
            for frag in gd["talisman_fragments"]
        }
        talisman_map.update({
            str(frag["item_ap_id"]): frag["tal_data"]
            for frag in gd["extra_talisman_fragments"]
        })

        # Talisman name map: item AP ID (str) → display name (IDs 700–799)
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

        # Shadow core map: item AP ID (str) → amount (IDs 800–868)
        shadow_core_map = {
            str(sc["item_ap_id"]): sc["total"]
            for sc in gd["shadow_core_stashes"]
        }
        shadow_core_map.update({
            str(sc["item_ap_id"]): sc["amount"]
            for sc in gd["extra_shadow_core_stashes"]
        })

        # Shadow core name map: item AP ID (str) → display name (IDs 800–868)
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
        achievement_requirements_map: Dict[str, list] = {}
        required_effort = self.options.achievement_required_effort.value
        if required_effort > 0:
            from .rulesdata_achievements import achievement_requirements as all_achievements

            for ach_name, ach_data in all_achievements.items():
                requirements = ach_data.get("requirements", [])
                if requirements:
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
            "enforce_logic":           bool(self.options.enforce_logic.value),
            "disable_endurance":       bool(self.options.disable_endurance.value),
            "disable_trial":           bool(self.options.disable_trial.value),
            "starting_wizard_level":   self.options.starting_wizard_level.value,
            "starting_overcrowd":      bool(self.options.starting_overcrowd.value),
            # Gem-pouch gating: per-prefix gem-orb suppression. Mod uses these
            # to decide whether to spawn gem orbs on level start, and to
            # display "needs Gempouch X" in tooltips.
            #   gem_pouch_gating: 0=off, 1=distinct, 2=progressive
            #   gem_pouch_play_order: list of prefix letters in play order;
            #     for distinct, item AP id = 626 + index in this list;
            #     for progressive, the Nth Progressive Gempouch covers the
            #     first N prefixes in this list.
            "gem_pouch_gating":        self.options.gem_pouch_gating.value,
            "gem_pouch_play_order":    list(GEM_POUCH_PLAY_ORDER),
            "gem_pouch_progressive_id": item_table["Progressive Gempouch"].id,
            "enemy_hp_multiplier":          self.options.enemy_hp_multiplier.value,
            "enemy_armor_multiplier":       self.options.enemy_armor_multiplier.value,
            "enemy_shield_multiplier":      self.options.enemy_shield_multiplier.value,
            "enemies_per_wave_multiplier":  self.options.enemies_per_wave_multiplier.value,
            "extra_wave_count":             self.options.extra_wave_count.value,
            "fields_required":              self.options.fields_required.value,
            "fields_required_percentage":   self.options.fields_required_percentage.value,
            "death_link":              bool(self.options.death_link.value),
            "death_link_punishment":   self.options.death_link_punishment.value,
            "gem_loss_percent":        self.options.gem_loss_percent.value,
            "wave_surge_count":        self.options.wave_surge_count.value,
            "wave_surge_gem_level":    self.options.wave_surge_gem_level.value,
            "death_link_grace_period": self.options.death_link_grace_period.value,
            "death_link_cooldown":     self.options.death_link_cooldown.value,
        }

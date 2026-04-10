from __future__ import annotations

import json
from importlib.resources import files
from typing import Dict, List

from BaseClasses import ItemClassification, Region
from Options import DeathLink, OptionGroup

from worlds.AutoWorld import WebWorld, World

from .items import GCFWItem, ItemData, item_table
from .locations import GCFWLocation, LocationData, location_table
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
)
from .rules import set_rules
from .rulesdata import (
    TIERS,
    TIER_REQUIREMENTS,
    TIER_SKILL_REQUIREMENTS,
    GAME_DATA,
    SKILL_CATEGORIES,
    CUMULATIVE_SKILL_REQUIREMENTS,
    STAGE_RULES,
)


def _load_game_data():
    return GAME_DATA


def _load_stages():
    return _load_game_data()["stages"]


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
        if (self.options.field_token_placement.value == FieldTokenPlacement.option_different_world and self.multiworld.players == 1):
            raise Exception(f"{self.player_name}: field_token_placement 'different_world' requires more than one player.")
        if (self.options.field_token_placement.value == FieldTokenPlacement.option_own_world and self.multiworld.players == 1):
            raise Exception(f"{self.player_name}: field_token_placement 'own_world' requires more than one player.")

    def pre_fill(self) -> None:
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
        stages = _load_stages()
        pool: List[GCFWItem] = []

        # Field tokens — W1/W2/W3/W4 have item_ap_id=None and are skipped.
        # W2/W3/W4 are always accessible (free stages); the mod unlocks them on connect.
        for stage in stages:
            if stage["item_ap_id"] is None:
                continue
            pool.append(self.create_item(f"{stage['str_id']} Field Token"))

        # Skills (includes gem-type unlocks at positions 7–12)
        for name in item_table:
            if name.endswith(" Skill"):
                pool.append(self.create_item(name))

        # Battle traits — Overcrowd is precollected instead if starting_overcrowd is on.
        # A Tattered Scroll is added to keep item count == location count.
        for name in item_table:
            if name.endswith(" Battle Trait"):
                if name == "Overcrowd Battle Trait" and self.options.starting_overcrowd:
                    self.multiworld.push_precollected(self.create_item(name))
                    pool.append(self.create_item("Tattered Scroll"))
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
            for _ in range(count):
                pool.append(self.create_item(name))

        self.multiworld.itempool += pool

    def create_regions(self) -> None:
        stages = _load_stages()
        # All stages get a region (needed for the region graph).
        # W1 has no AP item/locations but is the world entry point.
        all_stage_map = {s["str_id"]: s for s in stages}

        menu_region = Region("Menu", self.player, self.multiworld)
        self.multiworld.regions.append(menu_region)

        # Create one region per stage — every stage has AP locations (Journey + Bonus).
        # All locations are normal progress type; XP and token gates are on region connections.
        stage_regions: Dict[str, Region] = {}
        for str_id, stage in all_stage_map.items():
            region = Region(str_id, self.player, self.multiworld)
            for suffix in ("Journey", "Bonus"):
                loc_name = f"Complete {str_id} - {suffix}"
                loc_data = location_table[loc_name]
                loc = GCFWLocation(self.player, loc_name, loc_data.id, region)
                region.locations.append(loc)
            wiz_loc_name = f"Complete {str_id} - Wizard stash"
            wiz_loc_data = location_table[wiz_loc_name]
            region.locations.append(GCFWLocation(self.player, wiz_loc_name, wiz_loc_data.id, region))
            # Victory event for beat_game goal lives inside the A4 region
            if str_id == "A4" and self.options.goal.value == 0:
                region.locations.append(GCFWLocation(self.player, "Complete A4 - Frostborn Wrath Victory", None, region))
            # Victory event for kill_swarm_queen goal lives inside the K4 region
            if str_id == "K4" and self.options.goal.value == 2:
                region.locations.append(GCFWLocation(self.player, "Kill Swarm Queen Victory", None, region))
            stage_regions[str_id] = region
            self.multiworld.regions.append(region)

        # full_talisman goal: victory event in a dedicated region (no item requirements)
        if self.options.goal.value == 1:
            talisman_region = Region("Talisman Goal", self.player, self.multiworld)
            talisman_region.locations.append(
                GCFWLocation(self.player, "Full Talisman Victory", None, talisman_region))
            self.multiworld.regions.append(talisman_region)
            menu_region.connect(talisman_region, "Talisman")

        # Connect Menu → W1 (starting stage — all other stages connect from W1 in set_rules)
        menu_region.connect(stage_regions["W1"], "Start")

    def set_rules(self) -> None:
        set_rules(self)

    def generate_basic(self) -> None:
        # Place the Victory event at the goal-appropriate location.
        if self.options.goal.value == 0:
            victory_name = "Complete A4 - Frostborn Wrath Victory"
        elif self.options.goal.value == 2:
            victory_name = "Kill Swarm Queen Victory"
        else:
            victory_name = "Full Talisman Victory"
        victory_loc = self.multiworld.get_location(victory_name, self.player)
        victory_loc.place_locked_item(
            GCFWItem("Victory", ItemClassification.progression, None, self.player)
        )

        # Skills stay in the shared item pool — placed anywhere by Archipelago's fill algorithm.

    def fill_hook(self, progitempool, usefulitempool, filleritempool, fill_locations):
        # Reorder progitempool so fill_restrictive (which pops from the end) places items in
        # this sphere order:
        #   tier-0 tokens → skills for tier 1 → tier-1 tokens → skills for tier 2 → ...
        #
        # Without skill reordering, skills land in random positions and can end up being placed
        # last, at which point all low-tier locations are filled and the remaining locations are
        # in tiers 9-12 (which require more skills than are in the state) — causing a FillError.
        #
        # The 24 skills map exactly onto the 12×2 tier requirements
        # (6 spells + 4 focus + 6 gems + 4 buildings + 4 wrath = 24), so every skill gets a slot.
        #
        # In own_world mode, tokens are pre_fill'd and absent from the pool; only skills are
        # reordered here. In any_world mode, skills and tokens are interleaved correctly.

        # Build reverse lookup: skill name → category
        skill_to_category: Dict[str, str] = {
            skill: cat
            for cat, skills in SKILL_CATEGORIES.items()
            for skill in skills
        }

        # Collect this player's skill items per category
        category_skill_items: Dict[str, list] = {cat: [] for cat in SKILL_CATEGORIES}
        for item in progitempool:
            if item.player == self.player and item.name.endswith(" Skill"):
                cat = skill_to_category.get(item.name[:-6])
                if cat:
                    category_skill_items[cat].append(item)

        category_ptr: Dict[str, int] = {cat: 0 for cat in SKILL_CATEGORIES}

        # Iterate tiers from highest to lowest. Each append goes to the END of the pool,
        # so the last appended item is popped (placed) first by fill_restrictive.
        # After the loop the pool tail looks like:
        #   ... [skills_for_t12][tier-11_toks][skills_for_t11][tier-10_toks]...[skills_for_t1][tier-0_toks]
        # Popping from the right: tier-0 tokens first, then skills for tier 1, then tier-1 tokens, etc.
        for t in range(12, 0, -1):
            prev_tier = t - 1
            level_req = len(TIERS[prev_tier]) * self.options.tier_requirements_percent // 100

            # Append skills that unlock tier t (one per required category).
            # These land just before the tier-(t-1) tokens in the pool tail, so they are
            # placed right after those tokens unlock the tier-(t-1) stage locations.
            for category in TIER_SKILL_REQUIREMENTS.get(t, []):
                ptr = category_ptr[category]
                if ptr < len(category_skill_items[category]):
                    skill_item = category_skill_items[category][ptr]
                    category_ptr[category] += 1
                    pool_idx = next(
                        (i for i, x in enumerate(progitempool) if x is skill_item), None
                    )
                    if pool_idx is not None:
                        progitempool.append(progitempool.pop(pool_idx))

            # Append enough tier-(prev_tier) tokens to satisfy the tier-t requirement.
            moved_levels = 0
            prog_idx = 0
            while moved_levels < level_req:
                if prog_idx >= len(progitempool):
                    break  # tokens already placed via pre_fill (own_world); quota is fine
                this_item = progitempool[prog_idx]
                if (this_item.player == self.player
                        and this_item.name.endswith(" Field Token")):
                    this_field = this_item.name[:2]
                    if this_field in TIERS[prev_tier]:
                        progitempool.append(progitempool.pop(prog_idx))
                        moved_levels += 1
                        prog_idx -= 1
                prog_idx += 1


    def fill_slot_data(self) -> Dict:
        gd = _load_game_data()
        stages = gd["stages"]

        # Field token map: item AP ID (str) → stage str_id
        token_map = {
            str(s["item_ap_id"]): s["str_id"]
            for s in stages
            if s["item_ap_id"] is not None
        }

        # Free stages: all stages with item_ap_id=None (W1, W2, W3, W4).
        free_stages = [s["str_id"] for s in stages if s["item_ap_id"] is None]

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

        # --- In-game tracker: logic rules for client-side reachability eval ---
        # The mod ships a LogicEvaluator that mirrors rules.py to compute which
        # stages are currently in logic. Keep this in sync with rules.py.
        stage_tier_map: Dict[str, int] = {
            sid: rule.tier
            for sid, rule in STAGE_RULES.items()
            if rule.tier >= 0
        }
        stage_skills_map: Dict[str, List[str]] = {
            sid: list(rule.skills)
            for sid, rule in STAGE_RULES.items()
            if rule.skills
        }
        tier_stage_counts: Dict[str, int] = {
            str(t): len(stages) for t, stages in TIERS.items()
        }
        cumulative_skill_reqs: Dict[str, Dict[str, int]] = {
            str(t): dict(reqs) for t, reqs in CUMULATIVE_SKILL_REQUIREMENTS.items()
        }

        return {
            "goal":                  self.options.goal.value,
            "tattered_scroll_levels": tattered_levels,
            "worn_tome_levels":       worn_levels,
            "ancient_grimoire_levels": ancient_levels,
            "token_map":             token_map,
            "free_stages":           free_stages,
            "token_requirement_percent": self.options.tier_requirements_percent.value,
            # Tracker logic rules (see LogicEvaluator.as)
            "logic_rules_version":   1,
            "skill_categories":      SKILL_CATEGORIES,
            "cumulative_skill_reqs": cumulative_skill_reqs,
            "stage_tier":            stage_tier_map,
            "stage_skills":          stage_skills_map,
            "tier_stage_counts":     tier_stage_counts,
            "talisman_map":          talisman_map,
            "talisman_name_map":     talisman_name_map,
            "wiz_stash_tal_data":    wiz_stash_tal_data,
            "shadow_core_map":       shadow_core_map,
            "shadow_core_name_map":  shadow_core_name_map,
            "enforce_logic":           bool(self.options.enforce_logic.value),
            "disable_endurance":       bool(self.options.disable_endurance.value),
            "disable_trial":           bool(self.options.disable_trial.value),
            "starting_wizard_level":   self.options.starting_wizard_level.value,
            "starting_overcrowd":      bool(self.options.starting_overcrowd.value),
            "death_link":              bool(self.options.death_link.value),
            "death_link_punishment":   self.options.death_link_punishment.value,
            "gem_loss_percent":        self.options.gem_loss_percent.value,
            "wave_surge_count":        self.options.wave_surge_count.value,
            "wave_surge_gem_level":    self.options.wave_surge_gem_level.value,
            "death_link_grace_period": self.options.death_link_grace_period.value,
            "death_link_cooldown":     self.options.death_link_cooldown.value,
        }

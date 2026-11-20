"""Structural invariants that must hold for every seed, independent of fill."""
import json
import unittest

from Options import OptionError
from BaseClasses import LocationProgressType
from test.general import gen_steps, setup_multiworld
from worlds.AutoWorld import AutoWorldRegister

from .bases import GCFWTestBase
from ..gating import is_field_token_name


class TestPoolMatchesLocations(GCFWTestBase):
    """Item pool size must equal the number of addressed locations, under every granularity combination."""
    auto_construct = False

    def test_pool_size(self) -> None:
        """Either the pool fits exactly, or generation refuses with an OptionError (progression alone exceeds the locations) — never an oversized pool that dies later in fill."""
        for ft in ("per_stage", "per_stage_progressive", "per_tile", "per_tile_progressive"):
            for sk in ("off", "per_tile", "per_tile_progressive", "global"):
                for gp in ("off", "per_tile", "per_tile_progressive", "global"):
                    for effort in ("off", "extreme"):
                        opts = {"field_token_granularity": ft, "stash_key_granularity": sk,
                                "gem_pouch_granularity": gp, "achievement_required_effort": effort,
                                "starting_overcrowd": effort == "off"}
                        with self.subTest(**opts):
                            try:
                                mw = setup_multiworld(AutoWorldRegister.world_types[self.game], gen_steps, options=opts)
                            except OptionError:
                                self.assertEqual(effort, "off", "only achievements-off pools may overflow")
                                continue
                            locations = [loc for loc in mw.get_locations(1) if loc.address is not None]
                            self.assertEqual(len(mw.itempool), len(locations))


class TestSlotData(GCFWTestBase):
    options = {"goal": "fields_count", "fields_required": 40, "random_starting_stages": 2}

    def test_slot_data_serializable_and_consistent(self) -> None:
        slot_data = self.world.fill_slot_data()
        json.dumps(slot_data)
        self.assertEqual(slot_data["goal"], 2)
        self.assertEqual(slot_data["fields_required"], 40)
        self.assertEqual(slot_data["fields_required_count"], 40)
        self.assertEqual(len(slot_data["starting_stages"]), 2)
        self.assertEqual(set(slot_data["starting_stages"]), self.world.start_sids)
        for sid in slot_data["starting_stages"]:
            self.assertIn(sid, slot_data["free_stages"])

    def test_starting_stages_reachable_with_nothing(self) -> None:
        for sid in self.world.start_sids:
            self.assertTrue(self.can_reach_region(sid), f"starting stage {sid} not reachable from an empty save")


class TestStartingOvercrowdPrecollected(GCFWTestBase):
    options = {"starting_overcrowd": True}

    def test_overcrowd_not_in_pool(self) -> None:
        names = [item.name for item in self.multiworld.itempool]
        self.assertNotIn("Overcrowd Battle Trait", names)
        self.assertIn("Overcrowd Battle Trait", [i.name for i in self.multiworld.precollected_items[self.player]])


class TestGrindyAchievementsExcluded(GCFWTestBase):
    options = {"achievement_required_effort": "extreme", "grindy_achievements": True}

    def test_grindy_locations_excluded(self) -> None:
        from ..rulesdata_achievements import achievement_requirements
        grindy = [loc for loc in self.multiworld.get_locations(self.player)
                  if loc.name.startswith("Achievement: ")
                  and achievement_requirements.get(loc.name[len("Achievement: "):], {}).get("grindy")]
        self.assertGreater(len(grindy), 0, "grindy_achievements on but no grindy locations created")
        for loc in grindy:
            self.assertEqual(loc.progress_type, LocationProgressType.EXCLUDED, loc.name)


class TestAchievementsOffHasNoAchievementLocations(GCFWTestBase):
    options = {"achievement_required_effort": "off"}

    def test_no_achievement_locations(self) -> None:
        names = [loc.name for loc in self.multiworld.get_locations(self.player)]
        self.assertFalse([n for n in names if n.startswith("Achievement: ")])


class TestRejectedOptions(unittest.TestCase):
    """Combinations generate_early must refuse loudly."""
    game = "GemCraft: Frostborn Wrath"

    def _gen(self, options, players=1):
        return setup_multiworld([AutoWorldRegister.world_types[self.game]] * players, ("generate_early",), options=options)

    def test_hard_without_endurance(self) -> None:
        for difficulty in ("hard", "extreme"):
            with self.subTest(difficulty=difficulty):
                with self.assertRaises(OptionError):
                    self._gen({"difficulty": difficulty, "disable_endurance": True})

    def test_empty_explicit_starting_stages(self) -> None:
        with self.assertRaises(OptionError):
            self._gen({"random_starting_stages": 0, "starting_stages": []})

    def test_solo_restricted_token_placement(self) -> None:
        for placement in ("own_world", "different_world"):
            with self.subTest(placement=placement):
                with self.assertRaises(Exception):
                    self._gen({"field_token_placement": placement})


class TestFieldTokenPlacementMultiworld(unittest.TestCase):
    """own_world / different_world need >1 slot, so they're tested on a 2-GCFW multiworld, through the full fill."""
    game = "GemCraft: Frostborn Wrath"

    def _fill(self, placement):
        from Fill import distribute_items_restrictive
        from .fuzz import build_multiworld  # applies local/non-local locality rules like Main.py
        mw = build_multiworld([{"field_token_placement": placement}] * 2)
        distribute_items_restrictive(mw)
        self.assertTrue(mw.can_beat_game(), f"{placement}: not beatable")
        return mw

    def test_own_world(self) -> None:
        mw = self._fill("own_world")
        for loc in mw.get_locations():
            if loc.item and loc.item.code is not None and is_field_token_name(loc.item.name):
                self.assertEqual(loc.item.player, loc.player, f"{loc.item} landed in another world at {loc}")

    def test_different_world(self) -> None:
        mw = self._fill("different_world")
        for loc in mw.get_locations():
            if loc.item and loc.item.code is not None and is_field_token_name(loc.item.name):
                self.assertNotEqual(loc.item.player, loc.player, f"{loc.item} stayed home at {loc}")

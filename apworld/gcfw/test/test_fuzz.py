"""A handful of random-settings seeds as part of the normal test run.

Set GCFW_FUZZ_SEEDS to change how many (default 10) and GCFW_FUZZ_START to pin the first seed (default: random, printed on failure).
For hundreds of seeds use the multi-process CLI instead: python -m worlds.gcfw.test.fuzz --seeds 300
"""
import os
import random
import unittest

from .fuzz import run_seed


class TestRandomSettings(unittest.TestCase):
    def test_random_seeds(self) -> None:
        count = int(os.environ.get("GCFW_FUZZ_SEEDS", "10"))
        start = int(os.environ.get("GCFW_FUZZ_START", random.randrange(1, 2 ** 31)))
        for seed in range(start, start + count):
            with self.subTest(seed=seed):
                res = run_seed(seed)
                if res.get("tight"):
                    continue  # tight by design (achievements off, or different_world + per-stage tokens): accepted
                self.assertTrue(res["ok"], f"seed {seed} (players={res['players']}) failed at {res.get('stage')}: "
                                           f"{res.get('error')}\nrepro: python -m worlds.gcfw.test.fuzz --repro {seed}\n"
                                           f"{res.get('traceback')}")

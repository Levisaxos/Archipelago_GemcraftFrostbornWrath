"""Option presets. Every class sets `options`, so WorldTestBase runs its three default tests on it:

- test_all_state_can_reach_everything: with every item, every location is reachable and the goal is beatable.
- test_empty_state_can_reach_something: a fresh save has at least one check in logic.
- test_fill: a full fill succeeds and the placement is beatable / meets accessibility.

Add a class here whenever a new option or option value is introduced.
"""
from .bases import GCFWTestBase


# --- Goals -------------------------------------------------------------------

class TestGoalKillGatekeeper(GCFWTestBase):
    options = {"goal": "kill_gatekeeper"}


class TestGoalKillSwarmQueen(GCFWTestBase):
    options = {"goal": "kill_swarm_queen"}


class TestGoalFieldsCountMin(GCFWTestBase):
    options = {"goal": "fields_count", "fields_required": 12}


class TestGoalFieldsCountAll(GCFWTestBase):
    options = {"goal": "fields_count", "fields_required": 122}


# --- Field token granularity -------------------------------------------------

class TestFieldTokensPerStage(GCFWTestBase):
    options = {"field_token_granularity": "per_stage"}


class TestFieldTokensPerStageProgressive(GCFWTestBase):
    options = {"field_token_granularity": "per_stage_progressive"}


class TestFieldTokensPerTile(GCFWTestBase):
    options = {"field_token_granularity": "per_tile"}


class TestFieldTokensPerTileProgressive(GCFWTestBase):
    options = {"field_token_granularity": "per_tile_progressive"}


# --- Stash keys / gem pouches ------------------------------------------------

class TestStashKeysOffPouchesOff(GCFWTestBase):
    options = {"stash_key_granularity": "off", "gem_pouch_granularity": "off"}


class TestStashKeysProgressivePouchesProgressive(GCFWTestBase):
    options = {"stash_key_granularity": "per_tile_progressive", "gem_pouch_granularity": "per_tile_progressive"}


class TestStashKeysGlobalPouchesGlobal(GCFWTestBase):
    options = {"stash_key_granularity": "global", "gem_pouch_granularity": "global"}


# --- Achievements ------------------------------------------------------------

class TestAchievementsOff(GCFWTestBase):
    options = {"achievement_required_effort": "off"}


class TestAchievementsTrivial(GCFWTestBase):
    options = {"achievement_required_effort": "trivial"}


class TestAchievementsExtremeGrindy(GCFWTestBase):
    options = {"achievement_required_effort": "extreme", "grindy_achievements": True}


class TestAchievementsNoEnduranceNoTrial(GCFWTestBase):
    options = {"achievement_required_effort": "extreme", "disable_endurance": True, "disable_trial": True, "difficulty": "medium"}


# --- Difficulty / starting state ---------------------------------------------

class TestDifficultyEasy(GCFWTestBase):
    options = {"difficulty": "easy"}


class TestDifficultyExtreme(GCFWTestBase):
    options = {"difficulty": "extreme"}


class TestStartingOvercrowdAndWizardLevel(GCFWTestBase):
    options = {"starting_overcrowd": True, "starting_wizard_level": 20}


class TestExplicitStartingStages(GCFWTestBase):
    options = {"random_starting_stages": 0, "starting_stages": ["W2", "W4"]}


class TestAllFourStartingStages(GCFWTestBase):
    options = {"random_starting_stages": 4}


class TestMinimalAccessibility(GCFWTestBase):
    options = {"accessibility": "minimal"}


# Achievements off + fine-grained gating (e.g. per_stage tokens + per_tile keys + per_tile pouches) is deliberately NOT a preset:
# with only 244 locations those seeds may legitimately run out of room. The fuzzer reports them as TIGHT instead of FAIL.

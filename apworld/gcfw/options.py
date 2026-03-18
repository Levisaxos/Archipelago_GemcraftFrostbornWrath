from dataclasses import dataclass

from Options import Choice, PerGameCommonOptions


class Goal(Choice):
    """What counts as completing GemCraft: Frostborn Wrath.

    beat_game: Defeat the final boss (complete A4 — placeholder pending Phase 0 research).
    """
    display_name = "Goal"
    option_beat_game = 0
    default = 0


class SkillPlacement(Choice):
    """Controls where the 24 skill items are placed.

    spread: Skills are placed anywhere in the world by the randomizer.
    per_zone: One skill is guaranteed to appear somewhere within each zone (A–Z).
    """
    display_name = "Skill Placement"
    option_spread = 0
    option_per_zone = 1
    default = 1


@dataclass
class GCFWOptions(PerGameCommonOptions):
    goal: Goal
    skill_placement: SkillPlacement

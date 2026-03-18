from dataclasses import dataclass

from Options import Choice, PerGameCommonOptions


class Goal(Choice):
    """What counts as completing GemCraft: Frostborn Wrath.

    beat_game: Defeat the final boss (complete A4 — placeholder pending Phase 0 research).
    """
    display_name = "Goal"
    option_beat_game = 0
    default = 0


@dataclass
class GCFWOptions(PerGameCommonOptions):
    goal: Goal

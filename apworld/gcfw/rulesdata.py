from __future__ import annotations

from dataclasses import dataclass, field
from typing import List, Optional


@dataclass
class StageRule:
    # Gem unlock names required (e.g. "Slow", "Poison")
    gems:    List[str] = field(default_factory=list)
    # Skill names required (e.g. "Beam", "Freeze")
    skills:  List[str] = field(default_factory=list)
    # Minimum wizard levels needed (overrides the tier table when > 0)
    min_xp:  int = 0


# ---------------------------------------------------------------------------
# Wizard-level tier table
# ---------------------------------------------------------------------------
# XP items give wizard levels: Small = 1, Medium = 3, Large = 9.
# Each stage's minimum wizard level is derived from its wave_count using the
# table below.  "about 10" stages are free (wave_count ≤ 20); the rest are
# gated by increasing wizard level thresholds.
#
# wave_count  →  min_wizard_level
#    0            0   (SECRET stages with unknown wave count — treated free)
#    1–20         0   (free: ~9 stages plus W1 start)
#   21–26        10   (e.g. 1 Large + 1 Small)
#   27–32        20   (e.g. 2 Large + 2 Small)
#   33–38        30   (e.g. 3 Large + 3 Small)
#   39–44        40   (e.g. 4 Large + 4 Small, or 3 Large + 13 Small)
#   45–52        50   (e.g. 5 Large + 5 Small)
#   53–58        60   (e.g. 6 Large + 6 Small, or 3 Large + 8 Medium + 5 Small)
#   59–64        70   (e.g. 7 Large + 7 Small)
#   65–70        80   (e.g. 8 Large + 8 Small)
#   71–76        90   (e.g. 9 Large, or 3 Large + 21 Medium)
#   77–82       100   (e.g. 3 Large + 20 Medium + 1 Small + many Small)
#   83–90       110   (mix of M+S to reach 110)
#   91+         120   (A4/A5/A6 endgame — need all XP items)
#
# To adjust a single stage, add it to STAGE_RULES below with an explicit
# min_xp value; that overrides the tier table for that stage only.

WIZARD_LEVEL_TIERS: list[tuple[int, int]] = [
    (20,    0),
    (26,   10),
    (32,   20),
    (38,   30),
    (44,   40),
    (52,   50),
    (58,   60),
    (64,   70),
    (70,   80),
    (76,   90),
    (82,  100),
    (90,  110),
    (9999, 120),
]


def min_wizard_level_for_waves(wave_count: int) -> int:
    """Return the minimum wizard level required for a stage by wave count."""
    if wave_count == 0:
        return 0  # SECRET stages with unknown wave count
    for max_wave, wiz_level in WIZARD_LEVEL_TIERS:
        if wave_count <= max_wave:
            return wiz_level
    return 120


# ---------------------------------------------------------------------------
# Applied to every stage that is not W1 and not listed in STAGE_RULES.
# Set to None to have no default requirements.
DEFAULT_RULE: Optional[StageRule] = None

# Per-stage overrides. Listing a stage here replaces the DEFAULT_RULE entirely.
# Use StageRule() (no arguments) to mark a stage as free (no requirements).
#
# Gem names:   "Crit", "Leech", "Bleed", "Armor Tear", "Poison", "Slow"
# Skill names: "Mana Stream", "True Colors", "Fusion", "Orb of Presence",
#              "Resonance", "Demolition", "Critical Hit", "Mana Leech",
#              "Bleeding", "Armor Tearing", "Poison", "Slowing", "Freeze",
#              "Whiteout", "Ice Shards", "Bolt", "Beam", "Barrage",
#              "Fury", "Amplifiers", "Pylons", "Lanterns", "Traps", "Seeker Sense"

STAGE_RULES: dict[str, StageRule] = {
    # W1 is free — no entry needed (DEFAULT_RULE=None covers it with no requirements)

    # --- Add per-stage overrides below as you research each level ---
    # Example — requires Crit + Slow gems, a skill, and 40 wizard levels:
    # "X4": StageRule(gems=["Crit", "Slow"], skills=["Beam"], min_xp=40),
}

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
# XP items give wizard levels: Small = 2, Medium = 5, Large = 10.
# Each stage's minimum wizard level is derived from its wave_count using the
# table below.  "about 10" stages are free (wave_count ≤ 20); the rest are
# gated in steps of 10, each step requiring one additional Large XP Bonus.
#
# wave_count  →  min_wizard_level
#    0            0   (SECRET stages with unknown wave count — treated free)
#    1–20         0   (free: ~9 stages plus W1 start)
#   21–26        10   (1 Large XP)
#   27–32        20   (2 Large XP)
#   33–38        30   (3 Large XP)
#   39–44        40   (4 Large XP)
#   45–52        50   (5 Large XP)
#   53–58        60   (6 Large XP)
#   59–64        70   (7 Large XP)
#   65–70        80   (8 Large XP)
#   71–76        90   (9 Large XP)
#   77–82       100   (10 Large XP)
#   83–90       110   (11 Large XP)
#   91+         120   (12 Large XP — A4/A5/A6 endgame)
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

from __future__ import annotations

from dataclasses import dataclass, field
from typing import List, Optional


@dataclass
class StageRule:
    # Gem unlock names required (e.g. "Slow", "Poison")
    gems:    List[str] = field(default_factory=list)
    # Skill names required (e.g. "Beam", "Freeze")
    skills:  List[str] = field(default_factory=list)
    # Minimum total XP score needed (Small=1, Medium=3, Large=9)
    min_xp:  int = 0


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
    # Example — requires Crit + Slow gems and a skill, plus some XP:
    # "X4": StageRule(gems=["Crit", "Slow"], skills=["Beam"], min_xp=40),
}

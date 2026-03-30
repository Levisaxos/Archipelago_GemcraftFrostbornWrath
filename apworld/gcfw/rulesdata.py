from __future__ import annotations
import json
from importlib.resources import files

from dataclasses import dataclass, field
from typing import Dict, List, Tuple


# global bc json loads are costly
GAME_DATA = json.loads(files(__package__).joinpath("data/game_data.json").read_text(encoding="utf-8"))


# ---------------------------------------------------------------------------
# Skill categories (the 4 rows of the in-game skill tree, 6 skills each)
# ---------------------------------------------------------------------------
SKILL_CATEGORIES: Dict[str, List[str]] = {
    "generic":   ["Mana Stream", "True Colors", "Fusion", "Orb of Presence", "Resonance", "Demolition"],
    "skills":    ["Critical Hit", "Mana Leech", "Bleeding", "Armor Tearing", "Poison", "Slowing"],
    "spells":    ["Freeze", "Whiteout", "Ice Shards", "Bolt", "Beam", "Barrage"],
    "buildings": ["Fury", "Amplifiers", "Pylons", "Lanterns", "Traps", "Seeker Sense"],
}

# Which skill category rows must have at least one skill collected before
# accessing each tier.  Tiers not listed have no skill gate.
#
# Tier 1: spells + buildings        Tier 7:  spells + generic
# Tier 2: skills                    Tier 8:  skills + buildings + generic
# Tier 3: spells                    Tier 9:  spells + buildings + generic
# Tier 4: skills + buildings        Tier 10: skills + generic
# Tier 5: spells + buildings        Tier 11: spells + buildings + generic
# Tier 6: skills                    Tier 12: skills + generic
TIER_SKILL_REQUIREMENTS: Dict[int, List[str]] = {
    1:  ["spells", "buildings"],
    2:  ["skills"],
    3:  ["spells"],
    4:  ["skills", "buildings"],
    5:  ["spells", "buildings"],
    6:  ["skills"],
    7:  ["spells", "generic"],
    8:  ["skills", "buildings", "generic"],
    9:  ["spells", "buildings", "generic"],
    10: ["skills", "generic"],
    11: ["spells", "buildings", "generic"],
    12: ["skills", "generic"],
}


@dataclass
class StageRule:
    # Tier this stage belongs to (0 = free from W1, 1+ = gated by previous tier).
    tier: int = 0
    # Skill names required by WIZLOCK (the game locks these stages until the skills are unlocked).
    skills: List[str] = field(default_factory=list)


# ---------------------------------------------------------------------------
# Tier system
# ---------------------------------------------------------------------------
# Stages are grouped into tiers based on difficulty (derived from former
# wizard-level thresholds).  Each tier requires the player to have collected
# a minimum number of field tokens from the *immediately previous* tier.
#
# FREE_STAGES (W2-W4) are accessible from W1 without any token — they are
# the tutorial zone and mirror the real game's natural map progression.
# Their field tokens still exist as items and count toward Tier 1's gate.
#
# Other Tier 0 stages (S1-S4, V1) require their own field token but
# have no tier requirement on top.
#
# Tier 1+ stages require their own field token AND N tokens from the
# previous tier, where N scales with difficulty.

# Stages accessible from W1 without needing their field token.
# Their tokens still exist as progression items (needed for Tier 1 gate).
FREE_STAGES: set = {"W2", "W3", "W4"}

# Tier definitions: tier_number → list of stage str_ids in that tier.
# TODO: refactor to be programatically generated using game_data.json
TIERS: Dict[int, List[str]] = {
    0:  ["W2", "W3", "W4", "S1", "S2", "S3", "S4", "V1"],
    1:  ["V2", "V3", "V4", "R1", "R2", "Q1", "Q2", "Q3", "Q4", "Q5", "T1"],
    2:  ["R3", "R4", "R5", "T2", "T3", "T4", "U1", "U2", "U3", "U4", "Y1", "Y3", "O3"],
    3:  ["R6", "Y2", "O1", "O2", "O4", "N1", "N2", "N3", "P1"],
    4:  ["T5", "Y4", "X1", "X3", "X4", "Z1", "Z2", "Z3",
         "P2", "P3", "P4", "P5", "P6", "L1", "L2", "L3", "K1", "K2", "K4"],
    5:  ["X2", "Z4", "Z5", "G1", "G2", "K3", "L4"],
    6:  ["G3", "G4", "J1", "J2", "J3", "J4", "K5"],
    7:  ["H1", "H2", "H3", "H5", "M1", "M2", "M3", "M4", "F1", "F2", "E2", "N5", "L5"],
    8:  ["H4", "N4", "E1", "D4"],
    9:  ["D1", "D2", "D3", "B1", "E3", "E4", "I1"],
    10: ["E5", "D5", "B2", "B4", "C1", "C2", "I2", "I3", "I4"],
    11: ["F3", "F4", "F5", "B3", "B5", "C3", "C4", "C5", "A1", "A2", "A3"],
    12: ["A4", "A5", "A6"],
}

# Tier requirements: tier_number → (previous_tier, tokens_needed_from_prev).
# Tier 0 has no entry (it is free).
TIER_REQUIREMENTS: Dict[int, Tuple[int, int]] = {
    1:  (0,  2),
    2:  (1,  2),
    3:  (2,  3),
    4:  (3,  3),
    5:  (4,  4),
    6:  (5,  3),
    7:  (6,  3),
    8:  (7,  4),
    9:  (8,  2),
    10: (9,  3),
    11: (10, 4),
    12: (11, 5),
}


# ---------------------------------------------------------------------------
# Per-stage access rules
# ---------------------------------------------------------------------------
# Every stage must have an entry.  Set tier=0 and no skills for stages that
# are freely accessible from W1.  Set skills=[] if the game has no WIZLOCK
# requirement for that stage.
#
# Tier assignments derived from wave counts via the former wizard-level table.
# Explicit WIZLOCK data taken from game_data.json required_skills fields.

# STAGE_RULES_OLD: dict[str, StageRule] = {
#
#     # ── Zone W — starting zone ────────────────────────────────────────────
#     "W1": StageRule(),                              # free (starting stage, no token)
#     "W2": StageRule(),                              # free (starting stage, no token)
#     "W3": StageRule(),                              # free (starting stage, no token)
#     "W4": StageRule(),                              # free (starting stage, no token)
#
#     # ── Zone S ────────────────────────────────────────────────────────────
#     "S1": StageRule(),                              # tier 0
#     "S2": StageRule(),                              # tier 0
#     "S3": StageRule(),                              # tier 0
#     "S4": StageRule(),                              # tier 0
#
#     # ── Zone V ────────────────────────────────────────────────────────────
#     "V1": StageRule(),                              # tier 0
#     "V2": StageRule(tier=1),                        # tier 1
#     "V3": StageRule(tier=1),                        # tier 1
#     "V4": StageRule(tier=1),                        # tier 1
#
#     # ── Zone R ────────────────────────────────────────────────────────────
#     "R1": StageRule(tier=1),                        # tier 1
#     "R2": StageRule(tier=1),                        # tier 1
#     "R3": StageRule(tier=2),                        # tier 2
#     "R4": StageRule(tier=2),                        # tier 2
#     "R5": StageRule(tier=2),                        # tier 2
#     "R6": StageRule(tier=3),                        # tier 3
#
#     # ── Zone Q ────────────────────────────────────────────────────────────
#     "Q1": StageRule(tier=1),                        # tier 1
#     "Q2": StageRule(tier=1),                        # tier 1
#     "Q3": StageRule(tier=1),                        # tier 1
#     "Q4": StageRule(tier=1),                        # tier 1
#     "Q5": StageRule(tier=1),                        # tier 1
#
#     # ── Zone T ────────────────────────────────────────────────────────────
#     "T1": StageRule(tier=1),                        # tier 1
#     "T2": StageRule(tier=2),                        # tier 2
#     "T3": StageRule(tier=2),                        # tier 2
#     "T4": StageRule(tier=2),                        # tier 2
#     "T5": StageRule(tier=4),                        # tier 4
#
#     # ── Zone U ────────────────────────────────────────────────────────────
#     "U1": StageRule(tier=2),                        # tier 2
#     "U2": StageRule(tier=2),                        # tier 2
#     "U3": StageRule(tier=2),                        # tier 2
#     "U4": StageRule(tier=2),                        # tier 2
#
#     # ── Zone Y ────────────────────────────────────────────────────────────
#     "Y1": StageRule(tier=2),                        # tier 2
#     "Y2": StageRule(tier=3),                        # tier 3
#     "Y3": StageRule(tier=2),                        # tier 2
#     "Y4": StageRule(tier=4),                        # tier 4
#
#     # ── Zone X ────────────────────────────────────────────────────────────
#     "X1": StageRule(tier=4),                        # tier 4
#     "X2": StageRule(tier=5),                        # tier 5
#     "X3": StageRule(tier=4),                        # tier 4
#     "X4": StageRule(tier=4),                        # tier 4
#
#     # ── Zone Z ────────────────────────────────────────────────────────────
#     "Z1": StageRule(tier=4),                        # tier 4
#     "Z2": StageRule(tier=4),                        # tier 4
#     "Z3": StageRule(tier=4),                        # tier 4
#     "Z4": StageRule(tier=5),                        # tier 5
#     "Z5": StageRule(tier=5),                        # tier 5
#
#     # ── Zone O ────────────────────────────────────────────────────────────
#     "O1": StageRule(tier=3),                        # tier 3
#     "O2": StageRule(tier=3),                        # tier 3
#     "O3": StageRule(tier=2),                        # tier 2
#     "O4": StageRule(tier=3),                        # tier 3
#
#     # ── Zone N ────────────────────────────────────────────────────────────
#     "N1": StageRule(tier=3),                        # tier 3
#     "N2": StageRule(tier=3),                        # tier 3
#     "N3": StageRule(tier=3),                        # tier 3
#     "N4": StageRule(tier=8),                        # tier 8 — significantly harder than N1-N3
#     "N5": StageRule(tier=7),                        # tier 7
#
#     # ── Zone P ────────────────────────────────────────────────────────────
#     "P1": StageRule(tier=3),                        # tier 3
#     "P2": StageRule(tier=4),                        # tier 4
#     "P3": StageRule(tier=4),                        # tier 4
#     "P4": StageRule(tier=4),                        # tier 4
#     "P5": StageRule(                                # tier 4 — WIZLOCK: trap & poison gem required
#         tier=4,
#         skills=["Traps", "Poison"],
#     ),
#     "P6": StageRule(tier=4),                        # tier 4
#
#     # ── Zone L ────────────────────────────────────────────────────────────
#     "L1": StageRule(tier=4),                        # tier 4
#     "L2": StageRule(tier=4),                        # tier 4
#     "L3": StageRule(tier=4),                        # tier 4
#     "L4": StageRule(tier=5),                        # tier 5
#     "L5": StageRule(                                # tier 7 — WIZLOCK: requires 4 skills
#         tier=7,
#         skills=["Freeze", "Bolt", "Beam", "Barrage"],
#     ),
#
#     # ── Zone K ────────────────────────────────────────────────────────────
#     "K1": StageRule(tier=4),                        # tier 4
#     "K2": StageRule(tier=4),                        # tier 4
#     "K3": StageRule(tier=5),                        # tier 5
#     "K4": StageRule(tier=4),                        # tier 4
#     "K5": StageRule(tier=6),                        # tier 6
#
#     # ── Zone H ────────────────────────────────────────────────────────────
#     "H1": StageRule(tier=7),                        # tier 7
#     "H2": StageRule(tier=7),                        # tier 7
#     "H3": StageRule(tier=7),                        # tier 7
#     "H4": StageRule(tier=8),                        # tier 8
#     "H5": StageRule(tier=7),                        # tier 7
#
#     # ── Zone G ────────────────────────────────────────────────────────────
#     "G1": StageRule(tier=5),                        # tier 5
#     "G2": StageRule(tier=5),                        # tier 5
#     "G3": StageRule(tier=6),                        # tier 6
#     "G4": StageRule(tier=6),                        # tier 6
#
#     # ── Zone J ────────────────────────────────────────────────────────────
#     "J1": StageRule(tier=6),                        # tier 6
#     "J2": StageRule(tier=6),                        # tier 6
#     "J3": StageRule(tier=6),                        # tier 6
#     "J4": StageRule(tier=6),                        # tier 6
#
#     # ── Zone M ────────────────────────────────────────────────────────────
#     "M1": StageRule(tier=7),                        # tier 7
#     "M2": StageRule(tier=7),                        # tier 7
#     "M3": StageRule(tier=7),                        # tier 7
#     "M4": StageRule(tier=7),                        # tier 7
#
#     # ── Zone F ────────────────────────────────────────────────────────────
#     "F1": StageRule(tier=7),                        # tier 7
#     "F2": StageRule(tier=7),                        # tier 7
#     "F3": StageRule(tier=11),                       # tier 11 — significantly harder than F1/F2
#     "F4": StageRule(tier=11),                       # tier 11
#     "F5": StageRule(tier=11),                       # tier 11
#
#     # ── Zone E ────────────────────────────────────────────────────────────
#     "E1": StageRule(tier=8),                        # tier 8
#     "E2": StageRule(tier=7),                        # tier 7
#     "E3": StageRule(tier=9),                        # tier 9
#     "E4": StageRule(tier=9),                        # tier 9
#     "E5": StageRule(tier=10),                       # tier 10
#
#     # ── Zone D ────────────────────────────────────────────────────────────
#     "D1": StageRule(tier=9),                        # tier 9
#     "D2": StageRule(tier=9),                        # tier 9
#     "D3": StageRule(tier=9),                        # tier 9
#     "D4": StageRule(tier=8),                        # tier 8
#     "D5": StageRule(tier=10),                       # tier 10
#
#     # ── Zone B ────────────────────────────────────────────────────────────
#     "B1": StageRule(tier=9),                        # tier 9
#     "B2": StageRule(tier=10),                       # tier 10
#     "B3": StageRule(tier=11),                       # tier 11
#     "B4": StageRule(tier=10),                       # tier 10
#     "B5": StageRule(tier=11),                       # tier 11
#
#     # ── Zone C ────────────────────────────────────────────────────────────
#     "C1": StageRule(tier=10),                       # tier 10
#     "C2": StageRule(tier=10),                       # tier 10
#     "C3": StageRule(tier=11),                       # tier 11
#     "C4": StageRule(tier=11),                       # tier 11
#     "C5": StageRule(tier=11),                       # tier 11
#
#     # ── Zone A — endgame ──────────────────────────────────────────────────
#     "A1": StageRule(tier=11),                       # tier 11
#     "A2": StageRule(tier=11),                       # tier 11
#     "A3": StageRule(tier=11),                       # tier 11
#     "A4": StageRule(tier=12),                       # tier 12 — final boss stage
#     "A5": StageRule(tier=12),                       # tier 12
#     "A6": StageRule(tier=12),                       # tier 12
#
#     # ── Zone I ────────────────────────────────────────────────────────────
#     "I1": StageRule(tier=9),                        # tier 9
#     "I2": StageRule(tier=10),                       # tier 10
#     "I3": StageRule(tier=10),                       # tier 10
#     "I4": StageRule(tier=10),                       # tier 10
# }

STAGE_RULES: dict[str, StageRule] = {}
for stage in GAME_DATA["stages"]:
    sid = stage["str_id"]
    req_skills = stage["required_skills"]
    # find tier of stage
    # (i think this is more efficient than finding the stage in game_data for each stage in the tier...)
    stage_tier = -1
    # print(sid)
    for t, stages in TIERS.items():
        # print(f"Checking T{t}")
        if sid in stages:
            # print("Found!")
            stage_tier = t
            break
    STAGE_RULES[sid] = StageRule(tier=stage_tier, skills=req_skills)
from __future__ import annotations

from dataclasses import dataclass, field
from typing import List


# Set to True once pre_fill() is implemented to seed free locations with enough
# XP items to bootstrap the wizard-level chain.  While False, min_wizard_level
# values are stored here for reference but NOT applied as access rules — only
# WIZLOCK skill requirements are enforced.
WIZARD_LEVEL_GATING_ENABLED: bool = True


@dataclass
class StageRule:
    # Minimum total wizard levels required to access this stage's locations.
    # Wizard levels come from XP items: Tattered Scroll = 1, Worn Tome = 3, Ancient Grimoire = 9.
    # Pool: 2 Grimoires (18 lvl) + 10 Tomes (30 lvl) + ~74 Scrolls (74 lvl) = 122 levels total.
    min_wizard_level: int = 0
    # Skill names required by WIZLOCK (the game locks these stages until the skills are unlocked).
    skills: List[str] = field(default_factory=list)


# ---------------------------------------------------------------------------
# Wizard-level quick reference
# ---------------------------------------------------------------------------
# Tattered Scroll  =  1 wizard level   (small)
# Worn Tome        =  3 wizard levels  (medium)   → 3 Scrolls equiv.
# Ancient Grimoire =  9 wizard levels  (large)    → 3 Tomes / 9 Scrolls equiv.
#
# Example combinations per threshold:
#   wiz ≥  10:  1 Grimoire + 1 Scroll  |  3 Tomes + 1 Scroll  |  10 Scrolls
#   wiz ≥  20:  2 Grimoires + 2 Scrolls  |  6 Tomes + 2 Scrolls
#   wiz ≥  30:  3 Grimoires + 3 Scrolls  |  1 Grimoire + 7 Tomes
#   wiz ≥  40:  4 Grimoires + 4 Scrolls  |  1 Grimoire + 10 Tomes + 1 Scroll
#   wiz ≥  50:  5 Grimoires + 5 Scrolls  |  2 Grimoires + 10 Tomes + 2 Scrolls
#   wiz ≥  60:  2 Grimoires + 14 Tomes   |  6 Grimoires + 6 Scrolls
#   wiz ≥  70:  2 Grimoires + 17 Tomes + 1 Scroll
#   wiz ≥  80:  2 Grimoires + 20 Tomes + 2 Scrolls
#   wiz ≥  90:  2 Grimoires + 24 Tomes
#   wiz ≥ 100:  2 Grimoires + 10 Tomes + 52 Scrolls  (many combos)
#   wiz ≥ 110:  near all XP items
#   wiz ≥ 120:  essentially all XP items in the pool


# ---------------------------------------------------------------------------
# Per-stage access rules
# ---------------------------------------------------------------------------
# Every stage must have an entry.  Set min_wizard_level=0 and no skills for
# stages that only require the field token (already handled by the region rule).
# Set skills=[] if the game has no WIZLOCK requirement for that stage.
#
# Wizard level thresholds derived from wave counts via the tier table
# (documented in comments as "wave NN").  Explicit WIZLOCK data taken from
# game_data.json required_skills fields.

STAGE_RULES: dict[str, StageRule] = {

    # ── Zone W — starting zone ────────────────────────────────────────────
    "W1": StageRule(),                              # wave  6 — free (starting stage, no token)
    "W2": StageRule(),                              # wave  8 — free
    "W3": StageRule(),                              # wave 12 — free
    "W4": StageRule(),                              # wave 14 — free
    "W5": StageRule(),                              # wave  0 — secret, wave count unknown

    # ── Zone S ────────────────────────────────────────────────────────────
    "S1": StageRule(),                              # wave 14 — free
    "S2": StageRule(),                              # wave 16 — free
    "S3": StageRule(),                              # wave 14 — free
    "S4": StageRule(),                              # wave 20 — free

    # ── Zone V ────────────────────────────────────────────────────────────
    "V1": StageRule(),                              # wave 20 — free
    "V2": StageRule(min_wizard_level=10),           # wave 22
    "V3": StageRule(min_wizard_level=10),           # wave 24
    "V4": StageRule(min_wizard_level=10),           # wave 24

    # ── Zone R ────────────────────────────────────────────────────────────
    "R1": StageRule(min_wizard_level=10),           # wave 22
    "R2": StageRule(min_wizard_level=10),           # wave 22
    "R3": StageRule(min_wizard_level=20),           # wave 30
    "R4": StageRule(min_wizard_level=20),           # wave 30
    "R5": StageRule(min_wizard_level=20),           # wave 32
    "R6": StageRule(min_wizard_level=30),           # wave 36

    # ── Zone Q ────────────────────────────────────────────────────────────
    "Q1": StageRule(min_wizard_level=10),           # wave 24
    "Q2": StageRule(min_wizard_level=10),           # wave 22
    "Q3": StageRule(min_wizard_level=10),           # wave 24
    "Q4": StageRule(min_wizard_level=10),           # wave 26
    "Q5": StageRule(min_wizard_level=10),           # wave 26

    # ── Zone T ────────────────────────────────────────────────────────────
    "T1": StageRule(min_wizard_level=10),           # wave 26
    "T2": StageRule(min_wizard_level=20),           # wave 28
    "T3": StageRule(min_wizard_level=20),           # wave 28
    "T4": StageRule(min_wizard_level=20),           # wave 30
    "T5": StageRule(min_wizard_level=40),           # wave 40

    # ── Zone U ────────────────────────────────────────────────────────────
    "U1": StageRule(min_wizard_level=20),           # wave 30
    "U2": StageRule(min_wizard_level=20),           # wave 32
    "U3": StageRule(min_wizard_level=20),           # wave 30
    "U4": StageRule(min_wizard_level=20),           # wave 30

    # ── Zone Y ────────────────────────────────────────────────────────────
    "Y1": StageRule(min_wizard_level=20),           # wave 32
    "Y2": StageRule(min_wizard_level=30),           # wave 35
    "Y3": StageRule(min_wizard_level=20),           # wave 30
    "Y4": StageRule(min_wizard_level=40),           # wave 40

    # ── Zone X ────────────────────────────────────────────────────────────
    "X1": StageRule(min_wizard_level=40),           # wave 42
    "X2": StageRule(min_wizard_level=50),           # wave 48
    "X3": StageRule(min_wizard_level=40),           # wave 44
    "X4": StageRule(min_wizard_level=40),           # wave 46

    # ── Zone Z ────────────────────────────────────────────────────────────
    "Z1": StageRule(min_wizard_level=40),           # wave 44
    "Z2": StageRule(min_wizard_level=40),           # wave 46
    "Z3": StageRule(min_wizard_level=40),           # wave 46
    "Z4": StageRule(min_wizard_level=50),           # wave 48
    "Z5": StageRule(min_wizard_level=50),           # wave 50

    # ── Zone O ────────────────────────────────────────────────────────────
    "O1": StageRule(min_wizard_level=30),           # wave 34
    "O2": StageRule(min_wizard_level=30),           # wave 35
    "O3": StageRule(min_wizard_level=20),           # wave 32
    "O4": StageRule(min_wizard_level=30),           # wave 33

    # ── Zone N ────────────────────────────────────────────────────────────
    "N1": StageRule(min_wizard_level=30),           # wave 35
    "N2": StageRule(min_wizard_level=30),           # wave 36
    "N3": StageRule(min_wizard_level=30),           # wave 38
    "N4": StageRule(min_wizard_level=80),           # wave 70 — significantly harder than N1-N3
    "N5": StageRule(min_wizard_level=70),           # wave 68

    # ── Zone P ────────────────────────────────────────────────────────────
    "P1": StageRule(min_wizard_level=30),           # wave 38
    "P2": StageRule(min_wizard_level=40),           # wave 42
    "P3": StageRule(min_wizard_level=40),           # wave 40
    "P4": StageRule(min_wizard_level=40),           # wave 40
    "P5": StageRule(min_wizard_level=40),           # wave 40
    "P6": StageRule(min_wizard_level=40),           # wave 40

    # ── Zone L ────────────────────────────────────────────────────────────
    "L1": StageRule(min_wizard_level=40),           # wave 44
    "L2": StageRule(min_wizard_level=40),           # wave 46
    "L3": StageRule(min_wizard_level=40),           # wave 46
    "L4": StageRule(min_wizard_level=50),           # wave 50
    "L5": StageRule(                                # wave 64 — WIZLOCK: requires 4 skills
        min_wizard_level=70,
        skills=["Freeze", "Bolt", "Beam", "Barrage"],
    ),

    # ── Zone K ────────────────────────────────────────────────────────────
    "K1": StageRule(min_wizard_level=40),           # wave 46
    "K2": StageRule(min_wizard_level=40),           # wave 46
    "K3": StageRule(min_wizard_level=50),           # wave 50
    "K4": StageRule(min_wizard_level=40),           # wave 46
    "K5": StageRule(min_wizard_level=60),           # wave 54

    # ── Zone H ────────────────────────────────────────────────────────────
    "H1": StageRule(min_wizard_level=70),           # wave 64
    "H2": StageRule(min_wizard_level=70),           # wave 66
    "H3": StageRule(min_wizard_level=70),           # wave 64
    "H4": StageRule(min_wizard_level=80),           # wave 70
    "H5": StageRule(min_wizard_level=70),           # wave 68

    # ── Zone G ────────────────────────────────────────────────────────────
    "G1": StageRule(min_wizard_level=50),           # wave 50
    "G2": StageRule(min_wizard_level=50),           # wave 52
    "G3": StageRule(min_wizard_level=60),           # wave 55
    "G4": StageRule(min_wizard_level=60),           # wave 56
    "G5": StageRule(),                              # wave  0 — secret, wave count unknown

    # ── Zone J ────────────────────────────────────────────────────────────
    "J1": StageRule(min_wizard_level=60),           # wave 55
    "J2": StageRule(min_wizard_level=60),           # wave 54
    "J3": StageRule(min_wizard_level=60),           # wave 56
    "J4": StageRule(min_wizard_level=60),           # wave 58

    # ── Zone M ────────────────────────────────────────────────────────────
    "M1": StageRule(min_wizard_level=70),           # wave 60
    "M2": StageRule(min_wizard_level=70),           # wave 62
    "M3": StageRule(min_wizard_level=70),           # wave 64
    "M4": StageRule(min_wizard_level=70),           # wave 66

    # ── Zone F ────────────────────────────────────────────────────────────
    "F1": StageRule(min_wizard_level=70),           # wave 60
    "F2": StageRule(min_wizard_level=70),           # wave 64
    "F3": StageRule(min_wizard_level=110),          # wave 85 — significantly harder than F1/F2
    "F4": StageRule(min_wizard_level=110),          # wave 88
    "F5": StageRule(min_wizard_level=110),          # wave 90

    # ── Zone E ────────────────────────────────────────────────────────────
    "E1": StageRule(min_wizard_level=80),           # wave 70
    "E2": StageRule(min_wizard_level=70),           # wave 62
    "E3": StageRule(min_wizard_level=90),           # wave 74
    "E4": StageRule(min_wizard_level=90),           # wave 74
    "E5": StageRule(min_wizard_level=100),          # wave 78

    # ── Zone D ────────────────────────────────────────────────────────────
    "D1": StageRule(min_wizard_level=90),           # wave 72
    "D2": StageRule(min_wizard_level=90),           # wave 75
    "D3": StageRule(min_wizard_level=90),           # wave 77
    "D4": StageRule(min_wizard_level=80),           # wave 70
    "D5": StageRule(min_wizard_level=100),          # wave 78

    # ── Zone B ────────────────────────────────────────────────────────────
    "B1": StageRule(min_wizard_level=90),           # wave 76
    "B2": StageRule(min_wizard_level=100),          # wave 80
    "B3": StageRule(min_wizard_level=110),          # wave 86
    "B4": StageRule(min_wizard_level=100),          # wave 80
    "B5": StageRule(min_wizard_level=110),          # wave 84

    # ── Zone C ────────────────────────────────────────────────────────────
    "C1": StageRule(min_wizard_level=100),          # wave 82
    "C2": StageRule(min_wizard_level=100),          # wave 80
    "C3": StageRule(min_wizard_level=110),          # wave 84
    "C4": StageRule(min_wizard_level=110),          # wave 87
    "C5": StageRule(min_wizard_level=110),          # wave 90

    # ── Zone A — endgame ──────────────────────────────────────────────────
    "A1": StageRule(min_wizard_level=110),          # wave  90
    "A2": StageRule(min_wizard_level=110),          # wave  90
    "A3": StageRule(min_wizard_level=110),          # wave  90
    "A4": StageRule(min_wizard_level=120),          # wave 100 — final boss stage
    "A5": StageRule(min_wizard_level=120),          # wave  96
    "A6": StageRule(min_wizard_level=120),          # wave  99

    # ── Zone I ────────────────────────────────────────────────────────────
    "I1": StageRule(min_wizard_level=90),           # wave 76
    "I2": StageRule(min_wizard_level=100),          # wave 78
    "I3": StageRule(min_wizard_level=100),          # wave 80
    "I4": StageRule(min_wizard_level=100),          # wave 82
}

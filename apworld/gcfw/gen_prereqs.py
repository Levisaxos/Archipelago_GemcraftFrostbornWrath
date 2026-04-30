"""
gen_prereqs.py — one-shot generator for stage prerequisite requirements.

Reads stage difficulty from rulesdata_levels.py, distributes the 122 stages
into 40 difficulty buckets, picks 3-4 prerequisite stages per stage so that
the longest chain root -> A4 is at most 39, and writes the result back into
rulesdata_levels.py as DNF requirement lists.

Run from the repo root:
    python apworld/gcfw/gen_prereqs.py

WARNING: rulesdata_levels.py is now the hand-tuned source of truth at
runtime. The 8 starting stages (W1-W4, S1-S4) carry SYMMETRIC OR-prereqs
(every starting stage lists the other 7) so any of them can be chosen as
start. This script does NOT produce that symmetric pattern — it would
overwrite it with single-prereq chains rooted at the default W1. If you
re-run it you will need to re-apply the symmetric-W/S edit afterwards.

Prefer editing rulesdata_levels.py directly. The selection here is
deterministic (same input → same graph), but the script's main use today
is bootstrapping a fresh DAG, not maintaining the live one.
"""
from __future__ import annotations

import hashlib
import math
import os
import sys
from collections import defaultdict


# --------------------------------------------------------------------------- #
# Tunables
# --------------------------------------------------------------------------- #
NUM_BUCKETS = 40
PREREQ_COUNT_MIN = 3
PREREQ_COUNT_MAX = 4
DEFAULT_ROOT_STAGE = "W1"  # baseline anchor for the standalone __main__ run
TERMINAL_STAGE = "A4"      # bucket 39, never appears in any other stage's prereq list
# Default early-tier pool (bucket 0 + bucket 1). The chosen root sits alone in
# bucket 0; the remaining seven occupy bucket 1, ensuring bucket 1 is non-empty
# for any root choice. All eight DO have Field Token items — see rulesdata.py
# FREE_STAGES (empty) and game_data.json item_ap_ids 1-4 / 5-8.
DEFAULT_EARLY_TIER = frozenset({"W1", "W2", "W3", "W4", "S1", "S2", "S3", "S4"})


# --------------------------------------------------------------------------- #
# Load level_requirements without going through apworld __init__.py
# (which transitively imports Archipelago's BaseClasses, unavailable here).
# --------------------------------------------------------------------------- #
def load_level_requirements() -> dict:
    here = os.path.dirname(os.path.abspath(__file__))
    settings_path = os.path.join(here, "rulesdata_settings.py")
    levels_path = os.path.join(here, "rulesdata_levels.py")

    settings_ns: dict = {}
    with open(settings_path, encoding="utf-8") as f:
        exec(compile(f.read(), settings_path, "exec"), settings_ns)

    levels_ns: dict = {"WAVE_TIERS": settings_ns["WAVE_TIERS"]}
    with open(levels_path, encoding="utf-8") as f:
        src = f.read().replace("from .rulesdata_settings", "# from .rulesdata_settings")
    exec(compile(src, levels_path, "exec"), levels_ns)
    return levels_ns["level_requirements"]


# --------------------------------------------------------------------------- #
# Difficulty + bucketing
# --------------------------------------------------------------------------- #
def difficulty(stage_data: dict) -> float:
    """Combine wave count and peak enemy HP into a single comparable score.

    Log-scales HP because it spans 6 orders of magnitude (9 to ~5M) — without
    that, every late-game stage would collapse into one bucket.
    """
    waves = stage_data["WaveCount"]
    peak_hp = max(
        stage_data.get("ReaverMaxHP", 0),
        stage_data.get("SwarmlingMaxHP", 0),
        stage_data.get("GiantMaxHP", 0),
    )
    return waves + 5.0 * math.log10(1.0 + peak_hp)


def stable_index(seed: str, n: int) -> int:
    """Deterministic 'random' index in [0, n) — same seed always yields the
    same value, regardless of Python version or run order.
    """
    h = hashlib.sha256(seed.encode("utf-8")).digest()
    return int.from_bytes(h[:8], "big") % n


def family_prefix(sid: str) -> str:
    return sid[0]


# --------------------------------------------------------------------------- #
# Prereq selection
# --------------------------------------------------------------------------- #
def assign_buckets(
    level_requirements: dict,
    root_stage: str = DEFAULT_ROOT_STAGE,
    early_tier: frozenset = DEFAULT_EARLY_TIER,
) -> list[list[str]]:
    """Return a list of NUM_BUCKETS buckets.

    Bucket 0: root_stage (sole entry point, no prereqs).
    Bucket 1: the rest of early_tier (each gets [root_stage] as prereq).
    Buckets 2..NUM_BUCKETS-2: remaining non-A4 stages spread by difficulty.
    Bucket NUM_BUCKETS-1: A4.

    `root_stage` must be in `early_tier`. Raises if not.
    """
    if root_stage not in early_tier:
        raise ValueError(f"root_stage {root_stage!r} must be in early_tier {sorted(early_tier)}")

    others = [
        sid for sid in level_requirements
        if sid not in early_tier and sid != TERMINAL_STAGE
    ]
    others.sort(key=lambda s: (difficulty(level_requirements[s]), s))

    buckets: list[list[str]] = [[] for _ in range(NUM_BUCKETS)]
    buckets[0].append(root_stage)
    other_early = sorted(s for s in early_tier if s != root_stage)
    buckets[1].extend(other_early)
    buckets[NUM_BUCKETS - 1].append(TERMINAL_STAGE)

    n_middle_buckets = NUM_BUCKETS - 3  # 37 (skip 0, 1, last)
    for i, sid in enumerate(others):
        bucket_idx = 2 + min(
            int(i * n_middle_buckets / len(others)),
            n_middle_buckets - 1,
        )
        buckets[bucket_idx].append(sid)
    return buckets


def pick_prereqs(
    sid: str,
    bucket_idx: int,
    buckets: list[list[str]],
) -> list[str]:
    """Select up to PREREQ_COUNT_MAX prereqs for stage `sid` in bucket `bucket_idx`.

    All prereqs come from bucket bucket_idx - 1. This is intentional: with OR
    semantics (player needs only ONE prereq satisfied), drawing any prereq
    from a much-earlier bucket would collapse the chain depth, defeating the
    "gradual unlock" goal. Strict adjacency keeps depth(stage) == bucket_idx,
    so the longest chain W1 -> A4 equals NUM_BUCKETS - 1 by construction.

    Additional prereqs prefer different stage-family prefixes from `sid` so
    the lists feel game-natural rather than e.g. all-from-the-S-family.

    If the previous bucket has fewer than PREREQ_COUNT_MAX candidates the
    stage just gets fewer prereqs — that's fine per user spec.
    A4 is never picked because it lives alone in the final bucket.
    """
    prev_bucket = [s for s in buckets[bucket_idx - 1] if s != TERMINAL_STAGE]
    if not prev_bucket:
        raise RuntimeError(f"Empty pool for bucket {bucket_idx}")

    # --- Mandatory prereq from bucket idx - 1, deterministic ---
    mandatory = prev_bucket[stable_index(f"{sid}|mandatory", len(prev_bucket))]
    picks: list[str] = [mandatory]

    # --- Additional candidates from same bucket ---
    additional_pool = [s for s in prev_bucket if s != mandatory]
    target_extra = stable_index(
        f"{sid}|count", PREREQ_COUNT_MAX - PREREQ_COUNT_MIN + 1,
    ) + (PREREQ_COUNT_MIN - 1)
    target_extra = min(target_extra, len(additional_pool))

    # --- Family-balanced selection ---
    sid_family = family_prefix(sid)
    by_family: dict[str, list[str]] = defaultdict(list)
    for s in additional_pool:
        by_family[family_prefix(s)].append(s)

    # Order families: non-self families first (preferred), then self-family.
    family_order = sorted(
        by_family.keys(),
        key=lambda f: (f == sid_family, stable_index(f"{sid}|fam|{f}", 1000)),
    )

    for fam in family_order:
        if len(picks) - 1 >= target_extra:
            break
        candidates = sorted(by_family[fam])
        if not candidates:
            continue
        idx = stable_index(f"{sid}|pick|{fam}", len(candidates))
        picks.append(candidates[idx])

    # Top up from leftover deterministically if family-pass under-filled
    if len(picks) - 1 < target_extra:
        leftover = sorted(s for s in additional_pool if s not in picks)
        for s in leftover:
            if len(picks) - 1 >= target_extra:
                break
            picks.append(s)

    return picks


# --------------------------------------------------------------------------- #
# Validation
# --------------------------------------------------------------------------- #
def compute_depth(prereqs: dict[str, list[str]], root_stage: str = DEFAULT_ROOT_STAGE) -> dict[str, int]:
    """Depth via OR-prereq semantics: depth(s) = 1 + min(depth(p) for p in prereqs(s)).
    root_stage has depth 0. Stages with no prereqs also get depth 0.
    """
    depth: dict[str, int] = {root_stage: 0}

    def resolve(sid: str, visiting: set[str]) -> int:
        if sid in depth:
            return depth[sid]
        if sid in visiting:
            raise RuntimeError(f"Cycle detected through {sid}")
        visiting.add(sid)
        ps = prereqs.get(sid, [])
        if not ps:
            depth[sid] = 0
        else:
            depth[sid] = 1 + min(resolve(p, visiting) for p in ps)
        visiting.discard(sid)
        return depth[sid]

    for sid in prereqs:
        resolve(sid, set())
    return depth


def validate(
    prereqs: dict[str, list[str]],
    all_stages: list[str],
    root_stage: str = DEFAULT_ROOT_STAGE,
) -> None:
    # 1. root_stage has no prereqs. Every other stage has at least one prereq,
    #    and at most PREREQ_COUNT_MAX. Min count is 1 — small early buckets
    #    can't always fill 3 candidates and that's expected.
    for sid in all_stages:
        if sid == root_stage:
            assert sid not in prereqs or not prereqs[sid], \
                f"{root_stage} should have no prereqs"
            continue
        assert sid in prereqs and prereqs[sid], \
            f"{sid} has no prereqs"
        assert 1 <= len(prereqs[sid]) <= PREREQ_COUNT_MAX, \
            f"{sid} has {len(prereqs[sid])} prereqs (max {PREREQ_COUNT_MAX})"

    # 2. A4 never appears as a prereq.
    for sid, ps in prereqs.items():
        assert TERMINAL_STAGE not in ps, \
            f"{sid} has {TERMINAL_STAGE} as prereq"

    # 3. Depth bound.
    depth = compute_depth(prereqs, root_stage)
    max_depth = max(depth.values())
    assert max_depth <= NUM_BUCKETS - 1, \
        f"max depth {max_depth} exceeds bound {NUM_BUCKETS - 1}"


# --------------------------------------------------------------------------- #
# Public API: derive prereq DAG + buckets in-memory (no file writes).
# --------------------------------------------------------------------------- #
def build_dag(
    level_requirements: dict,
    root_stage: str = DEFAULT_ROOT_STAGE,
    early_tier: frozenset = DEFAULT_EARLY_TIER,
) -> tuple[dict[str, list[str]], dict[str, int]]:
    """Derive the prereq DAG anchored at `root_stage`.

    Returns (prereqs_per_stage, bucket_of_stage):
      - prereqs_per_stage: {sid -> [prereq_sid, ...]}, OR-semantics. The root
        is absent from this mapping (it has no prereqs).
      - bucket_of_stage: {sid -> bucket_index in [0, NUM_BUCKETS-1]}.

    Calls validate() before returning so any cycle/depth violation surfaces
    immediately rather than at fill time.
    """
    buckets = assign_buckets(level_requirements, root_stage, early_tier)
    bucket_of: dict[str, int] = {}
    for b_idx, bucket in enumerate(buckets):
        for sid in bucket:
            bucket_of[sid] = b_idx

    prereqs: dict[str, list[str]] = {}
    for bucket_idx in range(1, NUM_BUCKETS):
        for sid in buckets[bucket_idx]:
            prereqs[sid] = pick_prereqs(sid, bucket_idx, buckets)

    validate(prereqs, list(level_requirements.keys()), root_stage)
    return prereqs, bucket_of


# --------------------------------------------------------------------------- #
# Output: rewrite rulesdata_levels.py in place, replacing each stage's
# `required_skills` field with `requirements` containing Field_<sid> tokens.
# --------------------------------------------------------------------------- #
import re


# 4-part split: each stage's depth bucket maps to a "part" (1-4). Stages in
# parts 2/3/4 carry talismanRow + talismanColumn requirements ramping up by 1
# per part. Part 1 stages get nothing extra. With NUM_BUCKETS=40 and 4 parts,
# bucket boundaries are 10/20/30.
PART_COUNT = 4
PART_BUCKET_BOUNDS = [
    (i * (NUM_BUCKETS // PART_COUNT)) for i in range(PART_COUNT + 1)
]  # → [0, 10, 20, 30, 40]


def part_for_bucket(bucket_idx: int) -> int:
    """Return part number 1..PART_COUNT for the given bucket index."""
    for p in range(PART_COUNT, 0, -1):
        if bucket_idx >= PART_BUCKET_BOUNDS[p - 1]:
            return p
    return 1


def talisman_reqs_for_part(part: int) -> list[str]:
    """Return the talisman requirement strings for stages in this part.
    Part 1: none. Part 2: +1 each. Part 3: +2 each. Part 4: +3 each.
    """
    if part <= 1:
        return []
    n = part - 1
    return [f"talismanRow:{n}", f"talismanColumn:{n}"]


def format_requirements(field_prereqs: list[str], extra_reqs: list[str]) -> str:
    """Return a DNF literal: outer-OR of inner AND-groups.

    Each Field prereq becomes its own AND-group containing the field plus
    all extra_reqs (talismanRow:N etc.). With no Field prereqs and no extras
    we return `[]`; with no Field prereqs but talismans, a single AND-group.
    Matches the runtime parser shape (rules._normalize_requirements).
    """
    extras_quoted = [f'"{r}"' for r in extra_reqs]
    if not field_prereqs:
        if not extra_reqs:
            return "[]"
        return "[[" + ", ".join(extras_quoted) + "]]"
    groups = [
        "[" + ", ".join([f'"Field_{p}"'] + extras_quoted) + "]"
        for p in field_prereqs
    ]
    return "[" + ", ".join(groups) + "]"


def rewrite_levels_file(
    prereqs: dict[str, list[str]],
    bucket_of: dict[str, int],
    all_stages: list[str],
) -> None:
    here = os.path.dirname(os.path.abspath(__file__))
    levels_path = os.path.join(here, "rulesdata_levels.py")
    with open(levels_path, encoding="utf-8") as f:
        src = f.read()

    updated = 0
    for sid in all_stages:
        prereq_list = prereqs.get(sid, [])  # W1 → []
        bidx = bucket_of[sid]
        extra = talisman_reqs_for_part(part_for_bucket(bidx))
        new_value = format_requirements(prereq_list, extra)
        # Match within this stage's block only — the `[^{}]*?` body is
        # safe because stage entries do not contain nested braces.
        # Match either "required_skills" (first run) or "requirements"
        # (subsequent runs) so the script is idempotent.
        pattern = re.compile(
            r'("' + re.escape(sid) + r'":\s*\{[^{}]*?)'
            r'"(?:required_skills|requirements)":\s*\[[^\]]*\]',
            re.DOTALL,
        )
        new_src, count = pattern.subn(
            r'\1"requirements": ' + new_value, src, count=1,
        )
        if count == 0:
            raise RuntimeError(
                f"{sid}: required_skills line not found in rulesdata_levels.py"
            )
        src = new_src
        updated += 1

    # Strip the per-stage `tier` field — no longer used (stage prereqs replace
    # the old tier-power gating). Keep WaveCount-based tier classification in
    # rulesdata.py / WAVE_TIERS for achievement counter requirements.
    tier_pattern = re.compile(r'\n\s*"tier":\s*-?\d+,', re.MULTILINE)
    src, tier_removed = tier_pattern.subn("", src)

    with open(levels_path, "w", encoding="utf-8") as f:
        f.write(src)
    print(f"Rewrote {updated} stage entries; stripped {tier_removed} tier fields")


# --------------------------------------------------------------------------- #
# Main
# --------------------------------------------------------------------------- #
def main() -> None:
    level_requirements = load_level_requirements()
    all_stages = list(level_requirements.keys())
    assert len(all_stages) == 122, f"Expected 122 stages, got {len(all_stages)}"
    assert DEFAULT_ROOT_STAGE in all_stages and TERMINAL_STAGE in all_stages

    buckets = assign_buckets(level_requirements, DEFAULT_ROOT_STAGE, DEFAULT_EARLY_TIER)

    # Audit bucket sizes
    print("Bucket sizes:")
    for i, b in enumerate(buckets):
        print(f"  [{i:2d}] ({len(b)}): {b}")
    print()

    bucket_of: dict[str, int] = {}
    for b_idx, bucket in enumerate(buckets):
        for sid in bucket:
            bucket_of[sid] = b_idx

    prereqs: dict[str, list[str]] = {}
    for bucket_idx in range(1, NUM_BUCKETS):
        for sid in buckets[bucket_idx]:
            prereqs[sid] = pick_prereqs(sid, bucket_idx, buckets)

    validate(prereqs, all_stages, DEFAULT_ROOT_STAGE)
    depth = compute_depth(prereqs, DEFAULT_ROOT_STAGE)
    max_depth = max(depth.values())

    print(f"Generated {len(prereqs)} stage prereq entries")
    print(f"Max depth: {max_depth}")
    print(f"Mean prereqs per stage: {sum(len(v) for v in prereqs.values()) / len(prereqs):.2f}")

    # Audit talisman-requirement distribution by part
    from collections import Counter
    part_counts = Counter(part_for_bucket(bucket_of[s]) for s in all_stages)
    print(f"Stages per part (talisman ramp): {dict(sorted(part_counts.items()))}")
    print()

    rewrite_levels_file(prereqs, bucket_of, all_stages)


if __name__ == "__main__":
    main()

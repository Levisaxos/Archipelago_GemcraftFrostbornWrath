"""
check_achievement_logic.py

Lists all achievements that have no requirements (can be collected from the
start of the game), grouped by effort level.

Compare this output against what the mod shows as in-logic (green dots) to
determine whether bugs are in the AS3 logic evaluator or in the apworld JSON.

NOTE: The AS3 evaluator currently treats a *missing* requirements field as
"never in logic" (returns false).  Achievements with no requirements field
and achievements with requirements: [] are both "always achievable" but are
handled differently.  This script separates the two cases so you can see
which ones need the JSON fixed vs which ones are a code issue.
"""

import json
from pathlib import Path
from collections import defaultdict

JSON_PATH = Path(__file__).parent / "mods/ArchipelagoMod/src/data/json/achievement_logic.json"

EFFORT_ORDER = ["Trivial", "Minor", "Major", "Extreme"]

def main():
    with open(JSON_PATH, encoding="utf-8") as f:
        data = json.load(f)

    achievements = data["achievements"]

    missing_field  = {}   # requirements key absent entirely
    empty_array    = {}   # requirements: []
    has_reqs       = {}   # has actual requirements

    for name, ach in achievements.items():
        if "requirements" not in ach:
            missing_field[name] = ach
        elif not ach["requirements"]:
            empty_array[name] = ach
        else:
            has_reqs[name] = ach

    total = len(achievements)
    print(f"Total achievements : {total}")
    print(f"No requirements field (MISSING) : {len(missing_field)}")
    print(f"Empty requirements []           : {len(empty_array)}")
    print(f"Has requirements                : {len(has_reqs)}")
    print()

    # ------------------------------------------------------------------ #
    # Section 1: achievements with no requirements field
    # These are treated as NOT in logic by the AS3 evaluator (bug/data gap)
    # ------------------------------------------------------------------ #
    print("=" * 70)
    print("ACHIEVEMENTS WITH MISSING requirements FIELD")
    print("(AS3 evaluator returns false for these — likely a data gap)")
    print("=" * 70)
    _print_grouped(missing_field)

    # ------------------------------------------------------------------ #
    # Section 2: achievements with requirements: []
    # These ARE correctly treated as always-in-logic by the AS3 evaluator
    # ------------------------------------------------------------------ #
    if empty_array:
        print()
        print("=" * 70)
        print("ACHIEVEMENTS WITH requirements: []  (empty — always in logic)")
        print("(AS3 evaluator correctly returns true for these)")
        print("=" * 70)
        _print_grouped(empty_array)
    else:
        print()
        print("(No achievements use requirements: [] — all use the missing-field pattern)")

    # ------------------------------------------------------------------ #
    # Section 3: quick summary of what requirements look like overall
    # ------------------------------------------------------------------ #
    print()
    print("=" * 70)
    print("REQUIREMENT TYPES FOUND (for reference)")
    print("=" * 70)
    req_types = defaultdict(int)
    for ach in has_reqs.values():
        for req in ach["requirements"]:
            key = _classify_req(req)
            req_types[key] += 1
    for rtype, count in sorted(req_types.items(), key=lambda x: -x[1]):
        print(f"  {count:4d}  {rtype}")


def _print_grouped(ach_dict):
    by_effort = defaultdict(list)
    for name, ach in ach_dict.items():
        effort = ach.get("required_effort", "Trivial")
        by_effort[effort].append((name, ach))

    for effort in EFFORT_ORDER:
        entries = sorted(by_effort.get(effort, []))
        if not entries:
            continue
        print(f"\n  [{effort}]  ({len(entries)} achievements)")
        for name, ach in entries:
            ap_id = ach.get("apId", "?")
            modes = ach.get("modes", [])
            mode_str = f"  modes={modes}" if modes else ""
            desc = ach.get("description", "")
            print(f"    {ap_id:>5}  {name}{mode_str}")
            if desc:
                print(f"           {desc}")


def _classify_req(req: str) -> str:
    """Bucket a requirement string into a category for the summary."""
    r = req.lower()
    if r.endswith(" skill"):       return "X skill"
    if r.endswith(" element"):     return "X element"
    if r.endswith(" battle trait"):return "X battle trait"
    if r.startswith("fieldtoken:"): return "fieldToken: N"
    if r.startswith("field "):     return "field <id>"
    if r.startswith("minwave:"):   return "minWave: N"
    if r.startswith("strikespells:"): return "strikeSpells: N"
    if r.startswith("enhancementspells:"): return "enhancementSpells: N"
    if r.startswith("gemskills:"): return "gemSkills: N"
    return req  # show literal for unknown patterns


if __name__ == "__main__":
    main()

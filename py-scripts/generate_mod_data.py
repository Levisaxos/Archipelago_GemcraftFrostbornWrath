#!/usr/bin/env python3
"""
Generate mod-side JSON data files for the GCFW Archipelago mod.

Reads the apworld's source-of-truth modules (rulesdata_achievements.py,
rulesdata_levels.py, rulesdata_settings.py) and produces:

  - achievement_logic.json  — every achievement's metadata and requirements
                               (using the current prefix-token vocabulary)
                               plus element_stages and levelStats
  - level_stats.json        — per-stage monster + element-count stats used
                               by the mod's FieldLogicEvaluator

Run this whenever rulesdata_achievements.py, rulesdata_levels.py, or the
element/non-monster lists in rulesdata_settings.py change.

Usage:
    python py-scripts/generate_mod_data.py
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path
from typing import Dict


REPO_DIR = Path(__file__).resolve().parent.parent
APWORLD_DIR = REPO_DIR / "apworld" / "gcfw"
OUTPUT_DIR = REPO_DIR / "mods" / "ArchipelagoMod" / "src" / "data" / "json"


def _exec_module(name: str, ns: dict | None = None) -> dict:
    """Exec an apworld module file standalone (no `from .X import Y` resolution)
    and return its module namespace.  Strips relative imports first so we can
    load each module without going through the apworld package init (which
    needs Archipelago framework imports we don't have here)."""
    path = APWORLD_DIR / f"{name}.py"
    src = path.read_text(encoding="utf-8")
    # Comment out package-relative imports — none are needed for the data-only
    # modules we load here.
    src = src.replace("from .rulesdata_settings", "# from .rulesdata_settings")
    src = src.replace("from .rulesdata_levels", "# from .rulesdata_levels")
    src = src.replace("from .rulesdata", "# from .rulesdata")
    src = src.replace("from .options", "# from .options")
    src = src.replace("from .power", "# from .power")
    src = src.replace("from .requirement_tokens", "# from .requirement_tokens")
    out = ns if ns is not None else {}
    exec(compile(src, str(path), "exec"), out)
    return out


def load_apworld_data():
    """Return (achievements, level_requirements) loaded from the apworld
    source files."""
    levels_ns = _exec_module("rulesdata_levels")
    ach_ns = _exec_module("rulesdata_achievements")
    return (
        ach_ns["achievement_requirements"],
        levels_ns["level_requirements"],
    )


# Element Count fields the mod surfaces as eX / wX presence tokens.
# (Display name -> stage-data Count field.)  Keep in sync with
# requirement_tokens.element_prefix_map; the mod also derives presence
# from the Count fields directly via FieldLogicEvaluator.
_ELEMENT_COUNT_FIELDS = {
    "Abandoned Dwelling":   "AbandonedDwellingCount",
    "Apparition":           "ApparitionCount",
    "Barricade":            "BarricadeCount",
    "Beacon":               "BeaconCount",
    "Corrupted Mana Shard": "CorruptedManaShardCount",
    "Drop Holder":          "DropHolderCount",
    "Gatekeeper":           "GatekeeperCount",
    "Jar of Wasps":         "JarOfWaspsCount",
    "Mana Shard":           "ManaShardCount",
    "Monster Nest":         "MonsterNestCount",
    "Obelisk":              "ObeliskCount",
    "Rain":                 "RainCount",
    "Sealed gem":           "SealedGemCount",
    "Shadow":               "ShadowCount",
    "Shrine":               "ShrineCount",
    "Sleeping Hive":        "SleepingHiveCount",
    "Snow":                 "SnowCount",
    "Specter":              "SpecterCount",
    "Spire":                "SpireCount",
    "Swarm Queen":          "SwarmQueenCount",
    "Tomb":                 "TombCount",
    "Watchtower":           "WatchtowerCount",
    "Wizard Hunter":        "WizardHunterCount",
    "Wizard Tower":         "WizardTowerCount",
    "Wraith":               "WraithCount",
}


# Stat fields to expose to the mod.  Includes the <Type>Count fields
# populated from the decompiled stage data plus the simulation-derived
# MonstersBeforeWave12 / MarkedMonsterCount fields.
_STAT_FIELDS = (
    # Core monster stats
    "WaveCount", "MonsterCount",
    "ReaverWaves", "ReaverCount", "ReaverMaxHP", "ReaverMaxArmor",
    "SwarmlingWaves", "SwarmlingCount", "SwarmlingMaxHP", "SwarmlingMaxArmor",
    "GiantWaves", "GiantCount", "GiantMaxHP", "GiantMaxArmor",
    # Simulation-derived
    "MonstersBeforeWave12", "MarkedMonsterCount",
) + tuple(_ELEMENT_COUNT_FIELDS.values())


def build_level_stats(level_requirements: Dict[str, dict]) -> Dict[str, dict]:
    """Per-stage stats for the mod's FieldLogicEvaluator.  Only includes
    fields that are present (and non-zero) on the source stage — matches
    the apworld's "no zero entries" convention."""
    out: Dict[str, dict] = {}
    for sid, data in level_requirements.items():
        stats: dict = {}
        for f in _STAT_FIELDS:
            v = data.get(f)
            if v is None:
                continue
            # Drop zero stats too — the apworld already prunes them, but
            # be defensive in case anything sneaks through.
            if isinstance(v, (int, float)) and v == 0:
                continue
            stats[f] = v
        out[sid] = stats
    return out


def build_element_stages(level_requirements: dict) -> dict:
    """element-name -> [stage_id, ...] derived from per-stage Count fields
    in rulesdata_levels.py.  An element is "present on" a stage iff the
    stage has its Count field > 0.  Stage list is sorted for deterministic
    JSON output."""
    out: Dict[str, list] = {name: [] for name in _ELEMENT_COUNT_FIELDS}
    for sid, data in level_requirements.items():
        for name, field in _ELEMENT_COUNT_FIELDS.items():
            if data.get(field, 0) > 0:
                out[name].append(sid)
    for name in out:
        out[name].sort()
    return out


def build_achievements(achievements: dict) -> dict:
    """Achievement table for the mod.  Strips Python-side fields that
    aren't needed at runtime (modes, etc.) and renames `ap_id` -> `apId`
    to match the AS3 reader."""
    out: Dict[str, dict] = {}
    for name, data in achievements.items():
        entry: dict = {
            "apId": int(data["ap_id"]),
            "game_id": int(data.get("game_id", -1)),
            "description": data.get("description", ""),
            "reward": data.get("reward", ""),
            "required_effort": data.get("required_effort", "Trivial"),
            "requirements": data.get("requirements", []),
        }
        if "details" in data and data["details"]:
            entry["details"] = data["details"]
        if data.get("untrackable"):
            entry["untrackable"] = True
        if "required_power" in data and data["required_power"]:
            entry["required_power"] = int(data["required_power"])
        out[name] = entry
    return out


def main():
    print("Loading apworld source data...")
    achievements, level_reqs = load_apworld_data()
    print(f"  {len(achievements)} achievements, {len(level_reqs)} stages, "
          f"{len(_ELEMENT_COUNT_FIELDS)} element types")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # achievement_logic.json
    out = {
        "achievements":     build_achievements(achievements),
        "element_stages":   build_element_stages(level_reqs),
        "stage_properties": {},  # reserved for future use
        "levelStats":       build_level_stats(level_reqs),
    }
    ach_path = OUTPUT_DIR / "achievement_logic.json"
    ach_path.write_text(json.dumps(out, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"  wrote {ach_path}  ({ach_path.stat().st_size} bytes)")

    # level_stats.json (also embedded standalone for FieldLogicEvaluator)
    stats_path = OUTPUT_DIR / "level_stats.json"
    stats_path.write_text(json.dumps(out["levelStats"], indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"  wrote {stats_path}  ({stats_path.stat().st_size} bytes)")

    print("Done.")


if __name__ == "__main__":
    main()

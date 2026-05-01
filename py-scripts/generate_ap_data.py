#!/usr/bin/env python3
"""
Generate Archipelago data files for the Gemcraft Frostborn Wrath mod.

Splits game_data.json into:
  - itemdata.json: Item/stage definitions (IDs, names, mappings)
  - logic.json: Logic/unlock requirements (unlocks, skills, gems, wave counts)

Run this script whenever the apworld data changes.
"""

import json
import os
import sys
from pathlib import Path


APWORLD_DIR = Path(__file__).resolve().parent.parent / "apworld" / "gcfw"


def load_game_data():
    """Load the game_data.json from the apworld data directory."""
    game_data_path = APWORLD_DIR / "data" / "game_data.json"

    if not game_data_path.exists():
        print(f"ERROR: game_data.json not found at {game_data_path}")
        sys.exit(1)

    with open(game_data_path, 'r', encoding='utf-8') as f:
        return json.load(f)


def load_level_requirements():
    """Load per-stage requirements (DNF Field_X token lists) from
    rulesdata_levels.py.  Strips any package-relative imports so we can
    exec the file standalone (no apworld __init__ needed)."""
    levels_path = APWORLD_DIR / "rulesdata_levels.py"
    src = levels_path.read_text(encoding="utf-8")
    src = src.replace("from .rulesdata_settings", "# from .rulesdata_settings")
    ns: dict = {}
    exec(compile(src, str(levels_path), "exec"), ns)
    return ns["level_requirements"]


def build_matching_talismans(game_data):
    """Pick the 9 highest-rarity INNER talisman fragments (matching grid),
    return {grid:[apId*9], rows:[[apId*3]*3], columns:[[apId*3]*3]} so the
    mod's FieldLogicEvaluator can resolve talismanRow:N / talismanColumn:N
    gates without going through the apworld at runtime.

    Selection rule: descending rarity, name as tiebreak.  Mirrors
    apworld/gcfw/power._build_matching_talisman_grid exactly."""
    inner = []
    for frag in game_data.get("talisman_fragments", []):
        parts = str(frag["tal_data"]).split("/")
        if int(parts[2]) != 2:
            continue
        rarity = int(parts[1])
        ap_id = int(frag["item_ap_id"])
        name = f"{frag['str_id']} Talisman Fragment"
        inner.append((name, rarity, ap_id))
    inner.sort(key=lambda x: (-x[1], x[0]))
    if len(inner) < 9:
        raise RuntimeError(f"Need 9 INNER fragments, only found {len(inner)}")
    grid_ids = [ap_id for _, _, ap_id in inner[:9]]
    return {
        "grid":    grid_ids,
        "rows":    [grid_ids[0:3], grid_ids[3:6], grid_ids[6:9]],
        "columns": [
            [grid_ids[0], grid_ids[3], grid_ids[6]],
            [grid_ids[1], grid_ids[4], grid_ids[7]],
            [grid_ids[2], grid_ids[5], grid_ids[8]],
        ],
    }


def extract_item_data(game_data):
    """Extract definitions/item data for itemdata.json."""
    item_data = {}

    # Copy over definition data directly
    if "skills" in game_data:
        item_data["skills"] = game_data["skills"]

    if "battle_traits" in game_data:
        item_data["battleTraits"] = game_data["battle_traits"]

    if "gem_unlocks" in game_data:
        item_data["gemUnlocks"] = game_data["gem_unlocks"]

    if "map_tiles" in game_data:
        item_data["mapTiles"] = game_data["map_tiles"]

    # Extract stage definitions (ID/mapping data only, no logic)
    if "stages" in game_data:
        stages = []
        for stage in game_data["stages"]:
            stage_def = {
                "strId": stage.get("str_id"),
                "type": stage.get("type"),
                "itemApId": stage.get("item_ap_id"),
                "locApId": stage.get("loc_ap_id"),
                "wizStashLocApId": stage.get("wiz_stash_loc_ap_id")
            }
            stages.append(stage_def)
        item_data["stages"] = stages

    if "talisman_fragments" in game_data:
        item_data["talismanFragments"] = game_data["talisman_fragments"]

    if "extra_talisman_fragments" in game_data:
        item_data["extraTalismanFragments"] = game_data["extra_talisman_fragments"]

    if "shadow_core_stashes" in game_data:
        item_data["shadowCoreStashes"] = game_data["shadow_core_stashes"]

    if "extra_shadow_core_stashes" in game_data:
        item_data["extraShadowCoreStashes"] = game_data["extra_shadow_core_stashes"]

    return item_data


def extract_logic_data(game_data, level_reqs):
    """Extract logic/unlock requirements for logic.json.

    Per-stage data:
      strId, unlocks, requiredSkills, availableGems, waveCount, note,
      requirements (DNF Field_X / counter-token lists from rulesdata_levels.py)

    Top-level data:
      stages, matchingTalismans
    """
    logic_data = {}

    if "stages" in game_data:
        stages = []
        for stage in game_data["stages"]:
            sid = stage.get("str_id")
            stage_logic = {
                "strId":          sid,
                "unlocks":        stage.get("unlocks", []),
                "requiredSkills": stage.get("required_skills", []),
                "availableGems":  stage.get("available_gems", []),
                "waveCount":      stage.get("wave_count"),
                "note":           stage.get("note"),
                # Per-stage AP-logic prereqs from rulesdata_levels.py.
                # The mod's FieldLogicEvaluator reads this to compute the
                # in-logic stage list (used by FieldsInLogicButton, tooltips,
                # StageTinter).  Shape: list of AND-groups (DNF), each entry
                # like "Field_X" / "talismanRow:N" / "minWave:N" / etc.
                "requirements":   (level_reqs.get(sid, {}) or {}).get("requirements", []),
            }
            # Drop empty / None for cleanliness.
            stage_logic = {
                k: v for k, v in stage_logic.items()
                if v is not None and v != [] and v != {}
            }
            stages.append(stage_logic)
        logic_data["stages"] = stages

    # Matching-talisman grid (used by talismanRow:N / talismanColumn:N gates).
    logic_data["matchingTalismans"] = build_matching_talismans(game_data)

    return logic_data


def save_json(data, filename):
    """Save data to a JSON file with nice formatting."""
    output_path = Path(__file__).parent.parent / "mods" / "ArchipelagoMod" / "src" / "data" / "json" / filename

    # Ensure directory exists
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Custom formatting: keep shadowCore amounts arrays on one line
    json_str = json.dumps(data, indent=2, ensure_ascii=False)

    # Replace multi-line arrays with single-line versions for better readability
    import re
    def format_array(key):
        def replacer(match):
            items = [item.strip().strip('"') for item in match.group(1).split(',') if item.strip()]
            formatted = ', '.join('"' + item + '"' if '"' not in item else item for item in items)
            return f'"{key}": [{formatted}]'
        return replacer

    # Format "amounts" arrays (numbers)
    json_str = re.sub(
        r'"amounts":\s*\[([\d\s,]*?)\]',
        lambda m: '"amounts": [' + ', '.join(n.strip() for n in m.group(1).split(',') if n.strip()) + ']',
        json_str,
        flags=re.DOTALL
    )

    # Format "availableGems" arrays (strings)
    json_str = re.sub(
        r'"availableGems":\s*\[(.*?)\]',
        lambda m: '"availableGems": [' + ', '.join(item.strip() for item in m.group(1).split(',') if item.strip()) + ']',
        json_str,
        flags=re.DOTALL
    )

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(json_str)

    print(f"[OK] Generated {filename} ({len(json_str)} chars)")
    return output_path


def main():
    """Main execution."""
    print("Generating Archipelago data files...")
    print()

    # Load source data
    game_data = load_game_data()
    print("[OK] Loaded game_data.json")
    level_reqs = load_level_requirements()
    print(f"[OK] Loaded rulesdata_levels.py ({len(level_reqs)} stages)")
    print()

    # Extract and save item data
    item_data = extract_item_data(game_data)
    item_path = save_json(item_data, "itemdata.json")

    # Extract and save logic data (with per-stage requirements + matching talismans)
    logic_data = extract_logic_data(game_data, level_reqs)
    logic_path = save_json(logic_data, "logic.json")

    print()
    print("Done! Generated:")
    print(f"  - {item_path}")
    print(f"  - {logic_path}")


if __name__ == "__main__":
    main()

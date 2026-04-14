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


def load_game_data():
    """Load the game_data.json from the apworld data directory."""
    game_data_path = Path(__file__).parent.parent / "apworld" / "gcfw" / "data" / "game_data.json"

    if not game_data_path.exists():
        print(f"ERROR: game_data.json not found at {game_data_path}")
        sys.exit(1)

    with open(game_data_path, 'r', encoding='utf-8') as f:
        return json.load(f)


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


def extract_logic_data(game_data):
    """Extract logic/unlock requirements for logic.json."""
    logic_data = {}

    # Extract stage logic (unlocks, skills, gems, etc.)
    if "stages" in game_data:
        stages = []
        for stage in game_data["stages"]:
            stage_logic = {
                "strId": stage.get("str_id"),
                "unlocks": stage.get("unlocks", []),
                "requiredSkills": stage.get("required_skills", []),
                "availableGems": stage.get("available_gems", []),
                "waveCount": stage.get("wave_count"),
                "note": stage.get("note")
            }
            # Remove None values for cleanliness
            stage_logic = {k: v for k, v in stage_logic.items() if v is not None}
            stages.append(stage_logic)
        logic_data["stages"] = stages

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
    print()

    # Extract and save item data
    item_data = extract_item_data(game_data)
    item_path = save_json(item_data, "itemdata.json")

    # Extract and save logic data
    logic_data = extract_logic_data(game_data)
    logic_path = save_json(logic_data, "logic.json")

    print()
    print("Done! Generated:")
    print(f"  - {item_path}")
    print(f"  - {logic_path}")


if __name__ == "__main__":
    main()

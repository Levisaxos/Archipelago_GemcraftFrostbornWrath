"""
Requirement-token vocabulary for achievement and stage logic.

The data file `rulesdata_achievements.py` writes requirements as compact
prefix-encoded tokens (sBolt, eBeacon, tHaste, ...). The maps below
translate those tokens to AP item names / game-side element names so the
evaluator can check item state, element reachability, etc.

Single source of truth for the requirement vocabulary. Adding a new gate
is a one-line entry in the appropriate map below — no evaluator changes
required.
"""

from .rulesdata_settings import skill_groups, game_skills_categories

# Skills (s-prefix) — token -> AP item name (full, ready for state.has).
skill_prefix_map = {
    "sAmplifiers":     "Amplifiers Skill",
    "sArmorTearing":   "Armor Tearing Skill",
    "sBarrage":        "Barrage Skill",
    "sBeam":           "Beam Skill",
    "sBleeding":       "Bleeding Skill",
    "sBolt":           "Bolt Skill",
    "sCriticalHit":    "Critical Hit Skill",
    "sDemolition":     "Demolition Skill",
    "sFreeze":         "Freeze Skill",
    "sIceShards":      "Ice Shards Skill",
    "sLanterns":       "Lanterns Skill",
    "sManaLeech":      "Mana Leech Skill",
    "sOrbOfPresence":  "Orb of Presence Skill",
    "sPoison":         "Poison Skill",
    "sPylons":         "Pylons Skill",
    "sSlowing":        "Slowing Skill",
    "sTraps":          "Traps Skill",
    "sWhiteout":       "Whiteout Skill",
}

# Battle traits (t-prefix) — token -> AP item name (full).
trait_prefix_map = {
    "tAdaptiveCarapace":    "Adaptive Carapace Battle Trait",
    "tAwakening":           "Awakening Battle Trait",
    "tCorruptedBanishment": "Corrupted Banishment Battle Trait",
    "tDarkMasonry":         "Dark Masonry Battle Trait",
    "tGiantDomination":     "Giant Domination Battle Trait",
    "tHaste":               "Haste Battle Trait",
    "tHatred":              "Hatred Battle Trait",
    "tInsulation":          "Insulation Battle Trait",
    "tOvercrowd":           "Overcrowd Battle Trait",
    "tRitual":              "Ritual Battle Trait",
    "tStrengthInNumbers":   "Strength in Numbers Battle Trait",
    "tSwarmlingDomination": "Swarmling Domination Battle Trait",
    "tSwarmlingParasites":  "Swarmling Parasites Battle Trait",
    "tThickAir":            "Thick Air Battle Trait",
    "tVitalLink":           "Vital Link Battle Trait",
}

# Combined view used by the evaluator: token -> AP item name.  Kept as
# two organized maps above, merged once here so the evaluator does a
# single lookup instead of two.
item_prefix_map = {**skill_prefix_map, **trait_prefix_map}

# Elements (e-prefix and w-prefix) — token -> list of element names.
# Single-element tokens map to a 1-element list. Group tokens map to the
# full set of names ("any reachable" semantics).
# Weather (wRain / wSnow) lives here too — it's just an element with a
# stage list, kept under w-prefix for readability in the data file.
element_prefix_map = {
    "eAbandonedDwelling":  ["Abandoned Dwelling"],
    "eApparition":         ["Apparition"],
    "eBarricade":          ["Barricade"],
    "eBeacon":             ["Beacon"],
    "eCorruptedManaShard": ["Corrupted Mana Shard"],
    "eDropHolder":         ["Drop Holder"],
    "eGatekeeper":         ["Gatekeeper"],
    "eJarOfWasps":         ["Jar of Wasps"],
    "eManaShard":          ["Mana Shard"],
    "eMarkedMonster":      ["Marked Monster"],
    "eMonsterNest":        ["Monster Nest"],
    "eObelisk":            ["Obelisk"],
    "ePossessedMonster":   ["Possessed Monster"],
    "eSealedGem":          ["Sealed gem"],
    "eShadow":             ["Shadow"],
    "eShrine":             ["Shrine"],
    "eSleepingHive":       ["Sleeping Hive"],
    "eSpecter":            ["Specter"],
    "eSpire":              ["Spire"],
    "eSwarmQueen":         ["Swarm Queen"],
    "eTomb":               ["Tomb"],
    "eTower":              ["Tower"],
    "eTwistedMonster":     ["Twisted Monster"],
    "eWall":               ["Wall"],
    "eWatchtower":         ["Watchtower"],
    "eWizardHunter":       ["Wizard Hunter"],
    "eWizardStash":        ["Wizard Stash"],
    "eWizardTower":        ["Wizard Tower"],
    "eWraith":             ["Wraith"],

    # Weather — addressed under w-prefix in the data file but evaluated
    # the same way as elements.
    "wRain":               ["Rain"],
    "wSnow":               ["Snow"],

    # Group token: any of the Ritual-spawned creatures.
    "eNonMonsters": [
        "Apparition", "Shadow", "Specter", "Spire", "Wizard Hunter", "Wraith",
    ],
}

# Mode tokens — journey-only mod, both unsatisfiable.
mode_tokens = frozenset({"mTrial", "mEndurance"})

# Counter -> level-data field (or tuple of fields, max-aggregated across
# the tuple). A token "<counter>:N" passes if any reachable stage's
# field(s) >= N.
#
# To add a new stage-stat gate: one entry here + the field on each
# applicable stage in rulesdata_levels.py. No evaluator change.
level_stat_counters = {
    "minWave":           "WaveCount",
    "beforeWave":        "WaveCount",
    "minMonsters":       "MonsterCount",
    "minSwarmlings":     "SwarmlingCount",
    "minSwarmlingArmor": "SwarmlingMaxArmor",
    "minGiants":         "GiantCount",
    "minReavers":        "ReaverCount",
    "minMonsterHP":      ("GiantMaxHP", "ReaverMaxHP"),
    "minMonsterArmor":   ("GiantMaxArmor", "ReaverMaxArmor"),
    # Fields below need to be populated per-stage in rulesdata_levels.py
    # before the corresponding achievements become reachable in logic.
    "markedMonster":           "MarkedMonsterCount",
    "minMonstersBeforeWave12": "MonstersBeforeWave12",
}


# Counter -> list of AP item names. A token "<counter>:N" passes if at
# least N of the pool's items are collected.
#
# Built once at module load from skill_groups + game_skills_categories
# so adding a new skill / trait stays a single edit in
# rulesdata_settings.py — this table updates automatically.
skill_counter_pools: dict = {}

for _name, _group in skill_groups.items():
    skill_counter_pools[_name] = [f"{m} Skill" for m in _group["members"]]

for _name, _cat in game_skills_categories.items():
    _suffix = " Battle Trait" if _name == "BattleTraits" else " Skill"
    _items = [f"{m}{_suffix}" for m in _cat["members"]]
    # Both canonical and lowercase-first-letter aliases (battleTraits
    # and BattleTraits both work in achievement data).
    skill_counter_pools[_name] = _items
    skill_counter_pools[_name[0].lower() + _name[1:]] = _items

# `skills:N` / `Skills:N` — total across every skill category.
_all_items = []
for _cat_name in ("BattleTraits", "GemSkills", "OtherSkills"):
    _all_items.extend(skill_counter_pools[_cat_name])
skill_counter_pools["skills"] = _all_items
skill_counter_pools["Skills"] = _all_items

del _name, _group, _cat, _suffix, _items, _cat_name, _all_items

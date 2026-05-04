from __future__ import annotations

from typing import TYPE_CHECKING, List

from .rulesdata import GAME_DATA, STAGE_RULES, TIERS, GEM_POUCH_PLAY_ORDER
from .requirement_tokens import (
    item_prefix_map, element_prefix_map,
    mode_tokens, level_stat_counters, skill_counter_pools,
)
from .rulesdata_goals import goal_requirements
from .rulesdata_levels import level_requirements as LEVEL_DATA
from .talismans import (
    EDGE_TALISMAN_NAMES,
    CORNER_TALISMAN_NAMES,
    PROGRESSION_CORNER_TALISMAN_NAMES,
    PROGRESSION_EDGE_TALISMAN_NAMES,
    PROGRESSION_ALL_TALISMAN_NAMES,
    MATCHING_TALISMAN_NAMES,
    MATCHING_TALISMAN_ROWS,
    MATCHING_TALISMAN_COLUMNS,
)


def _restrict_talisman_shapes(loc, exclude_edge: bool, exclude_corner: bool) -> None:
    """Layer an item_rule that excludes EDGE and/or CORNER talisman fragments
    by name. Composes with whatever item_rule was already on the location.
    """
    if not exclude_edge and not exclude_corner:
        return
    prev = loc.item_rule  # default is `lambda i: True`

    def new_rule(item, p=prev, ee=exclude_edge, ec=exclude_corner):
        if ee and item.name in EDGE_TALISMAN_NAMES:
            return False
        if ec and item.name in CORNER_TALISMAN_NAMES:
            return False
        return p(item)

    loc.item_rule = new_rule

if TYPE_CHECKING:
    from . import GemcraftFrostbornWrathWorld


# Per-world (sid, item-name) maps for field tokens and stash keys are
# granularity-dependent and built lazily at set_rules time. See
# `_get_world_token_map` and `_get_world_stash_key_map` for accessors.


# XP item names — every registered XP item, both progression and useful.
# Half are progression (see items.py _xp_cls); state.has only sees those.
# The wizardLevel:N gate counts how many progression XP items the player
# has collected — passes when (N+1)//2 items are in state.
XP_ITEM_NAMES: List[str] = (
    [f"Tattered Scroll #{i+1}" for i in range(32)]
    + [f"Worn Tome #{i+1}" for i in range(6)]
    + [f"Ancient Grimoire #{i+1}" for i in range(2)]
    + [f"Extra XP Item #{i+1}" for i in range(60)]
)


# Shadow core stash item names → core amount they grant.  Used by the
# shadowCore:N gate (sums amounts of held progression stashes; useful and
# filler items are invisible to state.has so contribute 0).
SHADOW_CORE_AMOUNT_BY_NAME: dict[str, int] = {}
for _sc in GAME_DATA.get("shadow_core_stashes", []):
    SHADOW_CORE_AMOUNT_BY_NAME[f"{_sc['str_id']} Shadow Cores"] = int(_sc["total"])
for _sc in GAME_DATA.get("extra_shadow_core_stashes", []):
    SHADOW_CORE_AMOUNT_BY_NAME[_sc["name"]] = int(_sc["amount"])
del _sc


def _count_xp_items(state, player: int) -> int:
    cache = _get_counter_cache(state, player)
    val = cache.get("xp")
    if val is None:
        val = sum(1 for n in XP_ITEM_NAMES if state.has(n, player))
        cache["xp"] = val
    return val


def _sum_shadow_cores(state, player: int) -> int:
    """Sum of core amounts for held shadow-core stash items.  All shadow-core
    stashes are progression so the held total reflects every collected stash."""
    cache = _get_counter_cache(state, player)
    val = cache.get("sc")
    if val is None:
        val = sum(amt for name, amt in SHADOW_CORE_AMOUNT_BY_NAME.items()
                  if state.has(name, player))
        cache["sc"] = val
    return val


# State-signature + per-state counter cache.
# All scalar counters used by access rules (talisman row/column, field
# tokens, XP, shadow cores, SP, talisman fragments, talisman properties)
# memoise their result against `_gcfw_state_sig`. The signature changes
# whenever AP collects/removes any progression item, so cached values
# from a previous fill state are invalidated automatically.
def _gcfw_state_sig(state, player: int):
    items = state.prog_items.get(player)
    if items is None:
        return (player, 0, 0)
    return (player, len(items), sum(items.values()))


def _get_counter_cache(state, player: int) -> dict:
    sig = _gcfw_state_sig(state, player)
    cache = getattr(state, "_gcfw_counter_cache", None)
    if cache is None or cache[0] != sig:
        cache = (sig, {})
        state._gcfw_counter_cache = cache
    return cache[1]


def _count_complete_talisman_rows(state, player: int) -> int:
    """Count complete rows of the matching 3x3 grid the player owns.

    A row = all 3 fragments of one icon group. With 9 progression fragments
    split into 3 fixed icon groups (see talismans.MATCHING_TALISMAN_ROWS),
    the player can have 0..3 complete rows.
    """
    cache = _get_counter_cache(state, player)
    val = cache.get("tr")
    if val is None:
        val = sum(
            1 for row in MATCHING_TALISMAN_ROWS
            if all(state.has(n, player) for n in row)
        )
        cache["tr"] = val
    return val


def _count_complete_talisman_columns(state, player: int) -> int:
    """Count complete columns of the matching 3x3 grid the player owns.

    A column = one specific fragment from each icon group (positions
    {1,4,7}, {2,5,8}, or {3,6,9}). See talismans.MATCHING_TALISMAN_COLUMNS.
    """
    cache = _get_counter_cache(state, player)
    val = cache.get("tc")
    if val is None:
        val = sum(
            1 for col in MATCHING_TALISMAN_COLUMNS
            if all(state.has(n, player) for n in col)
        )
        cache["tc"] = val
    return val


def _count_skill_points(state, player: int) -> int:
    """Sum SP across all collected Skillpoint Bundle items.
    Each 'Skillpoint Bundle N' contributes N skill points; the pool may
    contain multiple copies of the same bundle size."""
    cache = _get_counter_cache(state, player)
    val = cache.get("sp")
    if val is None:
        val = 0
        for size in range(1, 11):
            val += size * state.count(f"Skillpoint Bundle {size}", player)
        cache["sp"] = val
    return val


def _count_field_tokens(state, player: int) -> int:
    """Granularity-aware count of stages effectively beatable.
    A stage only counts when the player holds BOTH its field token and the
    gempouch needed to clear it (pouch granularity decides whether that's a
    per-tile, per-tier, or global pouch; with pouches off the pouch check
    short-circuits to True). Token granularity decides what 'its field
    token' means (per-stage / per-tile / per-tier)."""
    cache = _get_counter_cache(state, player)
    val = cache.get("ft")
    if val is not None:
        return val
    world = state.multiworld.worlds[player]
    pairs = getattr(world, "_field_token_pouch_pairs", None)
    if pairs is None:
        from . import gating as _g
        ft_gran = world.options.field_token_granularity.value
        starter_sid = world.start_sid
        pairs = [
            (
                _g.field_token_for_stage(s["str_id"], ft_gran),
                _g.field_token_count_for_stage(s["str_id"], ft_gran, starter_sid),
                _compile_gempouch_checker(world, s["str_id"]),
            )
            for s in GAME_DATA["stages"]
        ]
        world._field_token_pouch_pairs = pairs
    def _has_token(tok, n):
        return state.has(tok, player) if n == 1 else state.count(tok, player) >= n
    val = sum(
        1 for tok, n, pouch_ok in pairs
        if _has_token(tok, n) and pouch_ok(state)
    )
    cache["ft"] = val
    return val


# Prefix-encoded requirement vocabulary + counter dispatch tables live in
# requirement_tokens.py (skill / trait / element prefix maps,
# mode_tokens, level_stat_counters).  Adding a new token / counter is
# a one-line entry there — no evaluator change required.

def _is_prefix_token(token: str, allowed: str) -> bool:
    """Return True if `token` starts with one of the prefix letters in `allowed`
    and the second char is uppercase (e.g. 'eBeacon', 'tHaste')."""
    return len(token) >= 2 and token[0] in allowed and token[1].isupper()


# Talisman counter -> name set used to count collected fragments.
# These all map to the 25 progression talisman fragments (4 corner + 12 edge
# + 9 inner) — the items that actually mark the talisman's slot layout.
# Non-progression fragments still drop but don't gate anything: state.has()
# only sees progression items, so counting useful/filler fragments here would
# silently always return 0.
_TALISMAN_FRAGMENT_COUNTERS: dict[str, frozenset] = {
    "talismanCornerFragment": PROGRESSION_CORNER_TALISMAN_NAMES,  # 4 items
    "talismanEdgeFragment":   PROGRESSION_EDGE_TALISMAN_NAMES,    # 12 items
    "talismanCenterFragment": MATCHING_TALISMAN_NAMES,            # 9 items
    "talismanFragments":      PROGRESSION_ALL_TALISMAN_NAMES,     # 25 items
}


# Field-token floors layered on top of the talisman counter gates so the
# achievement locations that test these don't open before the player has
# made enough world progress (talismans were placing too early otherwise).
# count_needed -> minimum effectively-unlocked stages required.
_TALISMAN_ROW_TOKEN_FLOOR: dict[int, int] = {1: 20, 2: 40, 3: 60}
_TALISMAN_COLUMN_TOKEN_FLOOR: dict[int, int] = {1: 10, 2: 30, 3: 50}
_TALISMAN_FRAGMENTS_TOKEN_FLOOR: dict[int, int] = {25: 75}


# Skill/trait counter floors — same shape as the talisman floors above.
# count_needed -> minimum effectively-unlocked stages required. Floors are
# chosen to scale with how much progression each count implies (needing 6 of
# 6 gem skills is end-game; needing 1 is sphere 0).
_GEM_SKILLS_TOKEN_FLOOR: dict[int, int] = {3: 8, 4: 16, 5: 28, 6: 40}
_BATTLE_TRAITS_TOKEN_FLOOR: dict[int, int] = {5: 10, 8: 25, 10: 40, 12: 55, 13: 60}
_STRIKE_SPELLS_TOKEN_FLOOR: dict[int, int] = {2: 10, 3: 25}
_ENHANCEMENT_SPELLS_TOKEN_FLOOR: dict[int, int] = {2: 10, 3: 25}

# Lookup by the counter group_name token used in requirement strings. The
# eval / compile paths consult this single map rather than four conditionals.
_SKILL_COUNTER_FLOORS: dict[str, dict[int, int]] = {
    "gemSkills":         _GEM_SKILLS_TOKEN_FLOOR,
    "GemSkills":         _GEM_SKILLS_TOKEN_FLOOR,
    "battleTraits":      _BATTLE_TRAITS_TOKEN_FLOOR,
    "BattleTraits":      _BATTLE_TRAITS_TOKEN_FLOOR,
    "strikeSpells":      _STRIKE_SPELLS_TOKEN_FLOOR,
    "enhancementSpells": _ENHANCEMENT_SPELLS_TOKEN_FLOOR,
}


# Per-seed graduated token-floor gating for skill + battle-trait items.
# Each of the 24 skills + 15 traits is assigned a unique floor in {2, 4, ..., 78}
# at set_rules time; the assignment is shuffled with world.random so different
# seeds gate different items at different points in the run. Achievement /
# stage requirements that resolve `sX` / `tX` AND-gate the item check with
# `_count_field_tokens(state, player) >= floor`, pushing the requirements (and
# the locations that host them) later in the playthrough.
_SKILL_TRAIT_FLOOR_SCHEDULE: List[int] = list(range(2, 80, 2))


def _build_skill_trait_floors(world) -> None:
    """Populate world._skill_trait_floors: per-seed map of skill/trait item
    names to field-token floors. Call once at set_rules time before any
    requirement compilation that depends on the floors."""
    from .items import item_table
    items = [name for name in item_table
             if name.endswith(" Skill") or name.endswith(" Battle Trait")]
    schedule = list(_SKILL_TRAIT_FLOOR_SCHEDULE)
    while len(schedule) < len(items):
        # Defensive: if the item set ever grows past 39, repeat the max floor.
        schedule.append(schedule[-1])
    schedule = schedule[:len(items)]
    world.random.shuffle(items)
    world._skill_trait_floors = dict(zip(items, schedule))


def _count_talisman_fragments(state, player: int, names) -> int:
    cache = _get_counter_cache(state, player)
    key = ("tf", id(names))
    val = cache.get(key)
    if val is None:
        val = sum(1 for n in names if state.has(n, player))
        cache[key] = val
    return val


# Talisman PROPERTY contribution gates — `tm<Foo>:N` passes when the player
# owns enough fragments whose summed property values reach N at max upgrade.
# Used by Max-Charge achievements (Barrage Battery, Freeze Battery) where the
# in-game effect is `2 + 0.01 * sum(propertyValue)`, so N=100 corresponds to
# 300% max charge for that spell.
#
# The contribution table is built once at module load from the static
# rulesdata_talisman data — values are bit-identical to what the game
# computes from the seeds.
from .rulesdata_talisman import progression_talismans as _PROG_TALISMANS

# property_id -> {fragment_item_name: value_at_max_upgrade}
_TALISMAN_PROPERTY_CONTRIBUTIONS: dict[int, dict[str, int]] = {}
for _name, _frag in _PROG_TALISMANS.items():
    for _pid, _pval in _frag["properties_at_max"]:
        if _pval > 0:
            _TALISMAN_PROPERTY_CONTRIBUTIONS.setdefault(_pid, {})[_name] = _pval
del _name, _frag, _pid, _pval

# Token head -> TalismanPropertyId.  Add new entries here to expose more
# Max-Charge or other talisman-property gates.  Values match
# constants/TalismanPropertyId.as in the decompiled game.
_TALISMAN_PROPERTY_TOKENS: dict[str, int] = {
    "tmFreezeCharge":    21,  # Max Freeze Charge
    "tmWhiteoutCharge":  22,  # Max Whiteout Charge
    "tmIceshardsCharge": 23,  # Max Iceshards Charge
    "tmBoltCharge":      24,  # Max Bolt Charge
    "tmBeamCharge":      25,  # Max Beam Charge
    "tmBarrageCharge":   26,  # Max Barrage Charge
}


def _sum_talisman_property(prop_id: int, state, player: int) -> int:
    """Sum the value contributions of held progression fragments for a
    given talisman property ID (assumes the player will fully upgrade the
    fragments — same assumption talismanFragments:N already makes about
    socketing).  Only progression fragments are counted; useful/filler
    fragments are invisible to state.has."""
    cache = _get_counter_cache(state, player)
    key = ("tp", prop_id)
    val = cache.get(key)
    if val is None:
        contribs = _TALISMAN_PROPERTY_CONTRIBUTIONS.get(prop_id, {})
        val = sum(v for name, v in contribs.items() if state.has(name, player))
        cache[key] = val
    return val


# Count fields that appear on at least one stage in rulesdata_levels.py.
# Used to distinguish "element tracked per-stage but not on any reachable
# stage at the requested count" (block) from "element not tracked at all,
# i.e. universally present like Tower / Wall" (always satisfied).
_PRESENT_COUNT_FIELDS: frozenset = frozenset(
    f for d in LEVEL_DATA.values() for f, v in d.items()
    if f.endswith("Count") and isinstance(v, (int, float)) and v > 0
)


def _element_count_field(elem_name: str) -> str:
    """Display name -> per-stage Count field name in LEVEL_DATA.
    "Drop Holder" -> "DropHolderCount", "Sealed gem" -> "SealedGemCount"."""
    return "".join(p[0].upper() + p[1:] for p in elem_name.split() if p) + "Count"


def _get_world_stash_key_map(state, player: int) -> dict:
    """Per-world map of sid -> (stash-key item name, count needed),
    granularity-aware. Built once and cached on the world instance.
    For distinct/global modes count is always 1; progressive modes return
    the position-in-order count threshold."""
    world = state.multiworld.worlds[player]
    cached = getattr(world, "_sid_to_stash_key", None)
    if cached is None:
        from . import gating as _g
        sk_gran = world.options.stash_key_granularity.value
        starter_sid = world.start_sid
        cached = {
            s["str_id"]: (
                _g.stash_key_for_stage(s["str_id"], sk_gran),
                _g.stash_key_count_for_stage(s["str_id"], sk_gran, starter_sid),
            )
            for s in GAME_DATA["stages"]
        }
        world._sid_to_stash_key = cached
    return cached


def _get_world_field_token_map(state, player: int) -> dict:
    """Per-world map of sid -> (field-token item name, count needed),
    granularity-aware. Built once and cached on the world instance."""
    world = state.multiworld.worlds[player]
    cached = getattr(world, "_sid_to_field_token", None)
    if cached is None:
        from . import gating as _g
        ft_gran = world.options.field_token_granularity.value
        starter_sid = world.start_sid
        cached = {
            s["str_id"]: (
                _g.field_token_for_stage(s["str_id"], ft_gran),
                _g.field_token_count_for_stage(s["str_id"], ft_gran, starter_sid),
            )
            for s in GAME_DATA["stages"]
        }
        world._sid_to_field_token = cached
    return cached


def _any_stash_reachable(state, player: int) -> bool:
    """True iff the player holds at least one Wizard Stash key whose stage
    is also clearable (per-stage prereqs + WIZLOCK skills met). Mirrors the
    mod's `FieldLogicEvaluator.isStashGateMet`: holding a key for an
    unbeatable stage doesn't satisfy the eWizardStash gate.

    Uses Journey-location reachability (not Wizard-stash-location, which
    would be circular since that location's own access rule includes the
    key check)."""
    sid_to_key = _get_world_stash_key_map(state, player)
    for sid, (key_name, key_count) in sid_to_key.items():
        if key_count == 1:
            if not state.has(key_name, player):
                continue
        elif state.count(key_name, player) < key_count:
            continue
        try:
            if state.can_reach(f"Complete {sid} - Journey", "Location", player):
                return True
        except KeyError:
            continue
    return False


def _eval_element_reachable(elem_name: str, state, player: int) -> bool:
    """Resolve element-presence reachability — equivalent to eX:1."""
    if elem_name == "Wizard Stash" or elem_name == "Wizard Tower":
        # Wizard towers are the visual structure of wizard stashes — the
        # player can only interact with a wizard tower by opening its
        # containing stash, which requires the stash key.
        return _any_stash_reachable(state, player)
    return _eval_element_count(_element_count_field(elem_name)[:-len("Count")], 1, state, player)


# Gem-skill broadening: a bare `sX` gem-skill token (and the `gemSkills:N`
# counter) passes if the player owns the AP skill item OR can reach a stage
# whose starter pouch lists the matching gem.  Per-stage starter pouches
# come from `AvailableGems` in rulesdata_levels.py (extracted from the
# decompiled stage data by extract_level_gems_and_elements.py — the
# authoritative source).  strikeSpells / enhancementSpells / other skill
# counters stay strict-item-count.
#
# Token values are the display names so the dict still doubles as a
# label table for any UI/diagnostic that wants human-readable gem names.
_GEM_TOKEN_TO_GEM_NAME: dict = {
    "sBleeding":     "Bleed",
    "sCriticalHit":  "Crit",
    "sManaLeech":    "Leech",
    "sArmorTearing": "Armor Tear",
    "sPoison":       "Poison",
    "sSlowing":      "Slow",
}

# rulesdata_levels.py uses GemComponentType constant names — map them to
# the display-name vocabulary used by `_GEM_TOKEN_TO_GEM_NAME`.
_GEM_CONSTANT_TO_DISPLAY: dict = {
    "CRITHIT":       "Crit",
    "MANA_LEECHING": "Leech",
    "BLEEDING":      "Bleed",
    "ARMOR_TEARING": "Armor Tear",
    "POISON":        "Poison",
    "SLOWING":       "Slow",
}

# Gem name -> stage str_ids whose `AvailableGems` lists that gem.
_STAGES_BY_GEM: dict = {}
for _sid, _data in LEVEL_DATA.items():
    for _gem_const in _data.get("AvailableGems", []):
        _gem_disp = _GEM_CONSTANT_TO_DISPLAY.get(_gem_const)
        if _gem_disp is not None:
            _STAGES_BY_GEM.setdefault(_gem_disp, []).append(_sid)
if "_sid" in dir():
    del _sid
if "_data" in dir():
    del _data
if "_gem_const" in dir():
    del _gem_const
if "_gem_disp" in dir():
    del _gem_disp


def _has_gem_token(req: str, state, player: int) -> bool:
    """Broadened evaluator for gem-skill `s*` tokens."""
    item_name = item_prefix_map.get(req)
    if item_name and state.has(item_name, player):
        return True
    gem_name = _GEM_TOKEN_TO_GEM_NAME.get(req)
    if gem_name is None:
        return False
    return _can_reach_any_stage(state, player, _STAGES_BY_GEM.get(gem_name, []))


def _count_gem_skills_broadened(state, player: int) -> int:
    """Count of the 6 gem skills 'available' under the broadened rule —
    each one counts iff the skill item is held OR a starter-gem stage is
    reachable.  Used for the `gemSkills:N` counter."""
    n = 0
    for token, gem_name in _GEM_TOKEN_TO_GEM_NAME.items():
        if state.has(item_prefix_map[token], player):
            n += 1
            continue
        if _can_reach_any_stage(state, player, _STAGES_BY_GEM.get(gem_name, [])):
            n += 1
    return n


# Building-skill broadening: a bare `sTraps` / `sLanterns` / `sPylons` /
# `sAmplifiers` token passes if the player owns the AP skill item OR can
# reach a stage that hosts the matching pre-placed building (and holds the
# stage's gempouch — gems are required to charge these structures).  Per-
# stage building counts come from `rulesdata_levels.py`, populated by
# `extract_level_gems_and_elements.py` from the decompiled stage data.
_BUILDING_TOKEN_TO_FIELD: dict = {
    "sTraps":      "TrapCount",
    "sLanterns":   "LanternCount",
    "sPylons":     "PylonCount",
    "sAmplifiers": "AmplifierCount",
}

# Field name -> stage str_ids whose <field> > 0.
_STAGES_BY_BUILDING: dict = {
    field: [sid for sid, d in LEVEL_DATA.items() if d.get(field, 0) > 0]
    for field in set(_BUILDING_TOKEN_TO_FIELD.values())
}


def _has_building_token(req: str, state, player: int) -> bool:
    """Broadened evaluator for building-skill `s*` tokens (sTraps etc.)."""
    item_name = item_prefix_map.get(req)
    if item_name and state.has(item_name, player):
        return True
    field = _BUILDING_TOKEN_TO_FIELD.get(req)
    if field is None:
        return False
    return _can_reach_any_stage(state, player, _STAGES_BY_BUILDING.get(field, []))


def _eval_element_count(elem_pascal: str, count_needed: int, state, player: int) -> bool:
    """Resolve eX:N form: a reachable stage exists where <X>Count >= N.
    If the element isn't tracked per-stage (no <X>Count field anywhere in
    LEVEL_DATA), treat it as universally present (Tower / Wall / Marked
    Monster fall here)."""
    field = elem_pascal + "Count"
    if field not in _PRESENT_COUNT_FIELDS:
        return True
    if elem_pascal == "DropHolder" and not state.has("Bolt Skill", player):
        # Drop Holders are only opened by Bolt shots (DropHolder.takeDamage
        # requires a TowerBolt origin, decrements pBoltShotsNeeded).
        return False
    qualifying = [sid for sid, d in LEVEL_DATA.items() if d.get(field, 0) >= count_needed]
    if elem_pascal == "WizardTower":
        # Wizard towers are the visual structure of wizard stashes — even if
        # the stage is reachable, the player can only "unlock" the tower by
        # opening its stash, which requires the per-stage stash key. So gate
        # on both (stage reachable, stash key held) for any qualifying stage.
        from . import gating as _g
        world = state.multiworld.worlds[player]
        sk_gran = world.options.stash_key_granularity.value
        starter_sid = world.start_sid
        for sid in qualifying:
            key_name  = _g.stash_key_for_stage(sid, sk_gran)
            key_count = _g.stash_key_count_for_stage(sid, sk_gran, starter_sid)
            if key_count == 1:
                if not state.has(key_name, player):
                    continue
            elif state.count(key_name, player) < key_count:
                continue
            try:
                if state.can_reach(f"Complete {sid} - Journey", "Location", player):
                    return True
            except KeyError:
                continue
        return False
    return _can_reach_any_stage(state, player, qualifying)


def _normalize_requirements(requirements: list) -> list:
    """Convert requirements to DNF: list of AND-groups (outer=OR, inner=AND).
    Flat list of strings is treated as a single AND-group for backward compatibility."""
    if not requirements:
        return []
    if isinstance(requirements[0], list):
        return requirements
    return [requirements]


def _simplify_requirements(normalized: list) -> list:
    """Pass-through after the element-data refactor.  Previously stripped
    'X element' reqs when an AND-group also required a trait, with an
    exception for non-monster elements (Shadow / Specter / Wraith etc.)
    that had restricted level lists.  Per game behaviour all elements have
    restricted level sets and elements are independent of trait state, so
    keeping every requirement matches the mod-side semantics exactly."""
    return normalized


def _can_reach_any_stage(state, player: int, stages) -> bool:
    """Return True if the player can play any of the given stages.

    Routes through `_can_clear_stage_cached` (Journey reachability) — that's
    the canonical "stage region is unlocked" signal. Stash reachability adds
    only the per-stage key item check, which is orthogonal: if the player can
    reach Journey they can play the stage and trigger any element/stat-gated
    achievement that needs it.

    Two-level memoisation:
      1. Per-(stages-list, state-sig) OR result — keyed by id() of the
         compile-time qualifying list, so achievements that share the same
         list (e.g. all `ePoison:1` users) reuse one OR scan per signature.
      2. Per-stage `_can_clear_stage_cached` — each stage's clearability is
         computed once per state-sig and reused across all OR scans.
    """
    sig = _gcfw_state_sig(state, player)
    cache = getattr(state, "_gcfw_or_cache", None)
    if cache is None or cache[0] != sig:
        cache = (sig, {})
        state._gcfw_or_cache = cache
    data = cache[1]
    key = id(stages)
    if key in data:
        return data[key]
    result = False
    for sid in stages:
        if _can_clear_stage_cached(state, player, sid):
            result = True
            break
    data[key] = result
    return result


# Compiled stage-clearability rules: (player, sid) -> (state) -> bool.
# Populated in set_rules at compile time. Stages absent from this dict have
# no requirements (start stage / unconditional clears) and are always
# clearable — their region is reached unconditionally from Menu via
# start_region.
#
# This sidesteps `state.can_reach("Complete <sid> - Journey")` which goes
# through Archipelago's region graph + access_rule lookup machinery — pure
# overhead in our setup, since every stage region is unconditionally
# connected from start. Calling the compiled rule directly is ~5-10x cheaper.
#
# IMPORTANT: if the region graph ever gains *gated* connections (e.g. region
# A reachable only after item X), this short-circuit becomes wrong — the
# rule check alone won't see the region gate. Update accordingly.
#
# Keyed by (player, sid) so multi-world generations don't stomp each other —
# rules bind to a specific player at compile time.
_STAGE_CLEAR_RULES: dict = {}


def _can_clear_stage_cached(state, player: int, sid: str) -> bool:
    """Return True if the player can clear (reach Journey for) `sid`.

    Memoised on the state via a signature derived from prog_items (length +
    sum of counts). The signature changes whenever AP collects or removes
    any item, so cached values from a previous fill state are invalidated
    automatically.

    Calls the stage's compiled rule directly from `_STAGE_CLEAR_RULES`,
    skipping `state.can_reach`. See dict comment above for the assumption
    this relies on.
    """
    sig = _gcfw_state_sig(state, player)

    cache = getattr(state, "_gcfw_clear_cache", None)
    if cache is None or cache[0] != sig:
        cache = (sig, {})
        state._gcfw_clear_cache = cache
    data = cache[1]

    if sid in data:
        return data[sid]
    rule = _STAGE_CLEAR_RULES.get((player, sid))
    if rule is None:
        # No rule registered = stage is unconditionally clearable (start
        # stage, or stages with empty/missing requirements list).
        data[sid] = True
        return True
    # Cycle guard — our prereq DAG is acyclic by construction, but if a
    # broken edit ever introduces a cycle this prevents infinite recursion.
    data[sid] = False
    ok = rule(state)
    data[sid] = ok
    return ok


def _can_clear_any_stage(state, player: int, stages) -> bool:
    """Return True if the player can clear (reach Journey) any of the given
    stages. Stricter than `_can_reach_any_stage` — stash reachability does
    not count, only Journey clears.

    Used by the per-stage prereq gate so that satisfying a prereq forces
    an actual stage clear, not just possession of the prereq's Field Token.
    Backed by `_can_clear_stage_cached` for speed.
    """
    for sid in stages:
        if _can_clear_stage_cached(state, player, sid):
            return True
    return False


# Item-collection counter heads that aren't covered by any of the
# requirement_tokens tables.  Each is handled inline in _eval_req.
_OTHER_COUNTER_HEADS: frozenset = frozenset({
    "fieldToken", "shadowCore", "wizardLevel",
    "skillPoints", "talismanRow", "talismanColumn",
})


def _is_gating_req(req: str, is_progressive: bool) -> bool:
    """Return True if this requirement string actually gates access to something."""
    req = req.strip()
    if req.startswith("Field_"):
        return True
    if req.startswith("Achievement:"):
        return is_progressive
    # Prefix vocabulary — single lookup across all maps.
    if (req in mode_tokens
            or req in item_prefix_map
            or req in element_prefix_map):
        return True
    if ":" in req:
        head = req.split(":", 1)[0].strip()
        if head in element_prefix_map or _is_prefix_token(head, "e"):
            return True  # element / weather / group with count
        if (head in level_stat_counters
                or head in _TALISMAN_FRAGMENT_COUNTERS
                or head in _TALISMAN_PROPERTY_TOKENS
                or head in skill_counter_pools):
            return True
        return head in _OTHER_COUNTER_HEADS
    return False


def _eval_req(req: str, state, player: int, is_progressive: bool) -> bool:
    """Evaluate a single requirement string against the current collection state."""
    req = req.strip()

    # Field_<sid> means "stage <sid>'s Journey is reachable" (i.e. the player
    # can clear it in-logic). NOT just "has Field Token <sid>" — token
    # possession alone doesn't guarantee the prereq stage is beatable. Cached
    # via _can_clear_stage_cached so deeper chains don't re-evaluate ancestors.
    if req.startswith("Field_"):
        return _can_clear_stage_cached(state, player, req[len("Field_"):])

    if req.startswith("Achievement:"):
        if not is_progressive:
            return True
        # Achievement items no longer exist (SP is filler instead). For
        # progressive chains, check that the parent achievement's LOCATION
        # is reachable — equivalent to "the player could have collected it".
        try:
            return state.can_reach(req, "Location", player)
        except KeyError:
            return False

    # --- Prefix vocabulary (s/t/e/w/m) -------------------------------
    # Tokens without a colon are dispatched by the maps in requirement_tokens.
    # Mode gates always-fail in this journey-only mod.
    if req in mode_tokens:
        return False
    if req in item_prefix_map:
        # Direct AP-item check.  Map values are full item names ("Bolt
        # Skill" / "Haste Battle Trait") so no string construction here.
        # Gem-skill `sX` tokens broaden to also pass when a stage with
        # the matching starter gem is reachable; building-skill `sTraps`
        # / `sLanterns` / `sPylons` / `sAmplifiers` broaden the same way
        # for stages that host the pre-placed building.
        item_name = item_prefix_map[req]
        if req in _GEM_TOKEN_TO_GEM_NAME:
            if not _has_gem_token(req, state, player):
                return False
        elif req in _BUILDING_TOKEN_TO_FIELD:
            if not _has_building_token(req, state, player):
                return False
        elif not state.has(item_name, player):
            return False
        # Per-seed skill/trait floor: a token referencing this item only
        # passes once enough field tokens have been earned in-state.
        floors = getattr(state.multiworld.worlds[player], "_skill_trait_floors", None)
        if floors:
            floor = floors.get(item_name, 0)
            if floor and _count_field_tokens(state, player) < floor:
                return False
        return True
    if req in element_prefix_map:
        # Element/group/weather token (single-element lists for `eBeacon`,
        # multi-element list for `eNonMonsters`). Reachable if any member is.
        return any(_eval_element_reachable(n, state, player)
                   for n in element_prefix_map[req])

    if ":" in req:
        group_name, count_str = req.split(":", 1)
        group_name = group_name.strip()
        try:
            count_needed = int(count_str.strip())
        except ValueError:
            return True

        # Group token with count (e.g. eNonMonsters:1) — the count is
        # ignored; we just check whether any group member is reachable.
        # Has to be checked BEFORE the generic eX:N count branch, since
        # `eNonMonsters` is also an "e"-prefix token.
        if group_name in element_prefix_map and len(element_prefix_map[group_name]) > 1:
            return any(_eval_element_reachable(n, state, player)
                       for n in element_prefix_map[group_name])

        # eX:N — single-element with count.  The token body is already
        # PascalCase so the level-data field is just `<body>Count`.
        if _is_prefix_token(group_name, "e"):
            return _eval_element_count(group_name[1:], count_needed, state, player)

        # Skill / trait / category / total counters — all unified into
        # one pool table (built in requirement_tokens.py from skill_groups
        # + game_skills_categories).  Covers strikeSpells, enhancementSpells,
        # gemSkills, BattleTraits / battleTraits, GemSkills, OtherSkills,
        # skills / Skills.
        if group_name in skill_counter_pools:
            # `gemSkills:N` / `GemSkills:N` broaden the same way as the
            # bare `sX` tokens — a gem skill counts as "available" if
            # held OR a starter-gem stage is reachable.  All other
            # counter pools (strikeSpells, enhancementSpells,
            # BattleTraits, OtherSkills, skills) stay strict-item-count.
            if group_name in ("gemSkills", "GemSkills"):
                if _count_gem_skills_broadened(state, player) < count_needed:
                    return False
            else:
                pool = skill_counter_pools[group_name]
                if sum(1 for name in pool if state.has(name, player)) < count_needed:
                    return False
            floor_table = _SKILL_COUNTER_FLOORS.get(group_name)
            if floor_table is not None:
                floor = floor_table.get(count_needed)
                if floor is not None and _count_field_tokens(state, player) < floor:
                    return False
            return True

        # Stage-stat gates: "<counter>:N" passes if any reachable stage's
        # field(s) >= N.  Tuple values are max-aggregated across the fields.
        # Add new gates by adding entries to level_stat_counters in
        # requirement_tokens.py — no code change needed.
        if group_name in level_stat_counters:
            fields = level_stat_counters[group_name]
            if isinstance(fields, str):
                fields = (fields,)
            qualifying = [sid for sid, d in LEVEL_DATA.items()
                          if max(d.get(f, 0) for f in fields) >= count_needed]
            return _can_reach_any_stage(state, player, qualifying)

        # Talisman-fragment counters by type.
        if group_name in _TALISMAN_FRAGMENT_COUNTERS:
            if _count_talisman_fragments(
                state, player, _TALISMAN_FRAGMENT_COUNTERS[group_name],
            ) < count_needed:
                return False
            if group_name == "talismanFragments":
                floor = _TALISMAN_FRAGMENTS_TOKEN_FLOOR.get(count_needed)
                if floor is not None and _count_field_tokens(state, player) < floor:
                    return False
            return True

        # Talisman-property contribution gates: tm<Foo>:N — sum the property
        # values of held progression fragments at max upgrade and compare to N.
        if group_name in _TALISMAN_PROPERTY_TOKENS:
            return _sum_talisman_property(
                _TALISMAN_PROPERTY_TOKENS[group_name], state, player,
            ) >= count_needed

        # Other item-collection counters — each counts a different pool.
        if group_name == "fieldToken":
            return _count_field_tokens(state, player) >= count_needed
        if group_name == "shadowCore":
            # Sum core amounts of held shadow-core stash items.  All stashes
            # are progression so the full collected total counts toward the gate.
            return _sum_shadow_cores(state, player) >= count_needed
        if group_name == "wizardLevel":
            # Half of XP items are progression; player needs ceil(N/2) of
            # those collected before the wizardLevel:N gate opens.  Max
            # reachable N at default settings: 40 (20 progression XP items).
            needed_items = (count_needed + 1) // 2
            return _count_xp_items(state, player) >= needed_items
        if group_name == "talismanRow":
            if _count_complete_talisman_rows(state, player) < count_needed:
                return False
            floor = _TALISMAN_ROW_TOKEN_FLOOR.get(count_needed)
            if floor is not None and _count_field_tokens(state, player) < floor:
                return False
            return True
        if group_name == "talismanColumn":
            if _count_complete_talisman_columns(state, player) < count_needed:
                return False
            floor = _TALISMAN_COLUMN_TOKEN_FLOOR.get(count_needed)
            if floor is not None and _count_field_tokens(state, player) < floor:
                return False
            return True
        if group_name == "skillPoints":
            return _count_skill_points(state, player) >= count_needed

        return True  # Unknown counter (minGemGrade, etc.) — metadata only

    return True  # Metadata requirement — not gated


# ---------------------------------------------------------------------------
# Pre-compiled requirement closures.
#
# `_eval_req` runs the full token-dispatch ladder on every state evaluation —
# string startswith / dict-membership / split / int-parse / and N more dict
# checks — just to figure out *what kind* of token the string is. With ~2M
# rule calls per generation, that dispatch dominates fill time.
#
# `_compile_req` runs the dispatch ONCE at set_rules time and returns a
# closure that does only the work for that specific token. Per-call cost
# drops from ~150-300 µs (achievement rules) to ~1-5 µs.
#
# Pre-computed at compile time (no per-call allocation):
#   - eX:N qualifying stage list (was rebuilt every call, 122-stage scan)
#   - level_stat_counters qualifying stage list (same)
#   - skill_counter_pool list (was iterated every call)
#   - fieldToken flat name list (was nested-flattened every call)
#   - SP-bundle name list (was looped every call)
# ---------------------------------------------------------------------------

# `fieldToken:N` counter previously cached a flat list of per-stage token
# names here at module load. With per_tile / per_tier granularity, the set
# of token items is per-world, so the cache moved to a lazy per-world map
# computed by `_get_world_field_token_map` (see above).

# Cache of (elem_pascal, count_needed) → qualifying-stage list. Reused across
# achievement-rule compiles so each unique (element, count) pair only scans
# LEVEL_DATA once.
_QUALIFYING_STAGES_CACHE: dict = {}

# Pre-built SP-bundle name list, indexed by size 1..10.
_SP_BUNDLE_NAMES: tuple = tuple(f"Skillpoint Bundle {n}" for n in range(1, 11))


def _qualifying_stages_for_element(elem_pascal: str, count_needed: int):
    """Return cached list of stage str_ids whose <elem>Count >= count_needed.
    Returns None if the element isn't tracked per-stage (universally present)."""
    key = ("elem", elem_pascal, count_needed)
    if key in _QUALIFYING_STAGES_CACHE:
        return _QUALIFYING_STAGES_CACHE[key]
    field = elem_pascal + "Count"
    if field not in _PRESENT_COUNT_FIELDS:
        result = None  # element is universally present — no gate
    else:
        result = [sid for sid, d in LEVEL_DATA.items() if d.get(field, 0) >= count_needed]
    _QUALIFYING_STAGES_CACHE[key] = result
    return result


def _qualifying_stages_for_stat(group_name: str, count_needed: int) -> list:
    """Return cached list of stage str_ids whose level_stat_counters[group_name]
    field(s) (max-aggregated) >= count_needed."""
    key = ("stat", group_name, count_needed)
    if key in _QUALIFYING_STAGES_CACHE:
        return _QUALIFYING_STAGES_CACHE[key]
    fields = level_stat_counters[group_name]
    if isinstance(fields, str):
        fields = (fields,)
    result = [sid for sid, d in LEVEL_DATA.items()
              if max(d.get(f, 0) for f in fields) >= count_needed]
    _QUALIFYING_STAGES_CACHE[key] = result
    return result


# Sentinel "always true" closure — singleton to avoid lambda allocation.
def _always_true(state) -> bool:
    return True


def _always_false(state) -> bool:
    return False


def _compile_gempouch_checker(world, sid: str):
    """Return (state) -> bool: True iff the player has access to gems on
    the given stage. Granularity-aware — uses gating helpers so the rule
    automatically adapts to all variants (distinct + progressive + global)."""
    from . import gating as _g
    mode = world.options.gem_pouch_granularity.value
    if mode == _g.POUCH_OFF:
        return _always_true
    player = world.player
    item_name = _g.pouch_for_stage(sid, mode)
    if item_name is None:
        # Should not happen for non-off modes after the helper rewrite,
        # but fall through safely.
        return _always_true
    needed = _g.pouch_count_for_stage(sid, mode, world.start_sid)
    if needed == 1:
        return lambda state: state.has(item_name, player)
    return lambda state: state.count(item_name, player) >= needed


def _compile_gem_broadened(world, gem_name: str):
    """Compile a broadened gem-availability checker:
    True iff some stage that hosts `gem_name` in its `available_gems` list
    is in-logic AND the player owns the prefix's gempouch (when gating is on).
    Hollow gem on the starter stage doesn't grant other gem types — see
    HollowGemInjector / GemPouchSuppressor on the mod side; this filter
    keeps fill-time logic consistent with what the player can actually use.
    """
    stages = _STAGES_BY_GEM.get(gem_name, [])
    pairs = [(sid, _compile_gempouch_checker(world, sid)) for sid in stages]
    player = world.player
    def _check(state):
        for sid, pouch_ok in pairs:
            if pouch_ok(state) and _can_clear_stage_cached(state, player, sid):
                return True
        return False
    return _check


def _compile_building_broadened(world, field: str):
    """Compile a broadened building-availability checker:
    True iff some stage with <field> > 0 is in-logic AND the player owns
    that stage's gempouch (gems are required to charge the building).
    Mirrors `_compile_gem_broadened`; the only difference is the source
    list of stages — pre-placed buildings rather than starter-pouch gems.
    """
    stages = _STAGES_BY_BUILDING.get(field, [])
    pairs = [(sid, _compile_gempouch_checker(world, sid)) for sid in stages]
    player = world.player
    def _check(state):
        for sid, pouch_ok in pairs:
            if pouch_ok(state) and _can_clear_stage_cached(state, player, sid):
                return True
        return False
    return _check


def _compile_element_or(elem_names, player: int):
    """Compile an "any of these elements is reachable" check.

    Each element is one of:
      - "Wizard Stash" → any wizard-stash key held AND its stage clearable
      - present in level data → reachable iff any qualifying stage reachable
      - universally present (not in _PRESENT_COUNT_FIELDS) → always True
    """
    # Resolution: each member becomes either "STASH" sentinel, an "ALWAYS"
    # short-circuit, or a precomputed list of qualifying stage str_ids.
    members: list = []
    for n in elem_names:
        if n == "Wizard Stash":
            members.append(("STASH", None))
            continue
        elem_pascal = _element_count_field(n)[:-len("Count")]
        stages = _qualifying_stages_for_element(elem_pascal, 1)
        if stages is None:
            return _always_true  # one universal member → whole disjunction true
        members.append(("STAGES", stages))

    if not members:
        return _always_false

    # Specialise common shapes.
    if len(members) == 1:
        kind, stages = members[0]
        if kind == "STASH":
            return lambda state: _any_stash_reachable(state, player)
        return lambda state: _can_reach_any_stage(state, player, stages)

    def _multi(state):
        for kind, stages in members:
            if kind == "STASH":
                if _any_stash_reachable(state, player):
                    return True
            elif _can_reach_any_stage(state, player, stages):
                return True
        return False
    return _multi


def _compile_req(req: str, world, is_progressive: bool):
    """Compile a single requirement string to a `(state) -> bool` closure.

    Mirrors `_eval_req` branch-for-branch — keep them in sync. The returned
    closure binds all per-call constants (item names, qualifying stage lists,
    counter pools) so the only runtime work is the actual state lookups.

    Takes `world` (not just player) so gem-skill broadening can build the
    per-stage gempouch checker — the broadening must respect the player's
    actual access (gempouch held) rather than treating every reachable
    stage's `available_gems` as usable.
    """
    req = req.strip()
    player = world.player

    if req.startswith("Field_"):
        sid = req[len("Field_"):]
        return lambda state: _can_clear_stage_cached(state, player, sid)

    if req.startswith("Achievement:"):
        if not is_progressive:
            return _always_true
        loc_name = req
        def _ach_reachable(state):
            try:
                return state.can_reach(loc_name, "Location", player)
            except KeyError:
                return False
        return _ach_reachable

    if req in mode_tokens:
        return _always_false

    if req in item_prefix_map:
        item_name = item_prefix_map[req]
        floor = getattr(world, "_skill_trait_floors", {}).get(item_name, 0)
        if req in _GEM_TOKEN_TO_GEM_NAME:
            gem_name = _GEM_TOKEN_TO_GEM_NAME[req]
            broaden = _compile_gem_broadened(world, gem_name)
            if floor:
                def _gem_token_floored(state, n=item_name, b=broaden, f=floor):
                    if not (state.has(n, player) or b(state)):
                        return False
                    return _count_field_tokens(state, player) >= f
                return _gem_token_floored
            def _gem_token(state, n=item_name, b=broaden):
                if state.has(n, player):
                    return True
                return b(state)
            return _gem_token
        if req in _BUILDING_TOKEN_TO_FIELD:
            field = _BUILDING_TOKEN_TO_FIELD[req]
            broaden = _compile_building_broadened(world, field)
            if floor:
                def _bld_token_floored(state, n=item_name, b=broaden, f=floor):
                    if not (state.has(n, player) or b(state)):
                        return False
                    return _count_field_tokens(state, player) >= f
                return _bld_token_floored
            def _bld_token(state, n=item_name, b=broaden):
                if state.has(n, player):
                    return True
                return b(state)
            return _bld_token
        if floor:
            return lambda state, n=item_name, f=floor: (
                state.has(n, player) and _count_field_tokens(state, player) >= f
            )
        return lambda state, n=item_name: state.has(n, player)

    if req in element_prefix_map:
        return _compile_element_or(element_prefix_map[req], player)

    if ":" in req:
        group_name, count_str = req.split(":", 1)
        group_name = group_name.strip()
        try:
            count_needed = int(count_str.strip())
        except ValueError:
            return _always_true

        # Group token with count (eNonMonsters:1 etc.) — count is ignored,
        # mirrors _eval_req. Reachable iff any group member is reachable.
        if group_name in element_prefix_map and len(element_prefix_map[group_name]) > 1:
            return _compile_element_or(element_prefix_map[group_name], player)

        if _is_prefix_token(group_name, "e"):
            elem_pascal = group_name[1:]
            stages = _qualifying_stages_for_element(elem_pascal, count_needed)
            if stages is None:
                return _always_true
            return lambda state: _can_reach_any_stage(state, player, stages)

        if group_name in skill_counter_pools:
            floor_table = _SKILL_COUNTER_FLOORS.get(group_name)
            counter_floor = floor_table.get(count_needed) if floor_table else None
            if group_name in ("gemSkills", "GemSkills"):
                # Gempouch-aware count: each of the 6 gem skills counts iff
                # the skill item is held OR a stage hosting it in available_gems
                # is reachable AND the player has that prefix's gempouch.
                pairs = []
                for tok, gem_name in _GEM_TOKEN_TO_GEM_NAME.items():
                    pairs.append((item_prefix_map[tok], _compile_gem_broadened(world, gem_name)))
                if counter_floor is None:
                    def _gemskills_count_check(state):
                        n = 0
                        for item_name, broaden in pairs:
                            if state.has(item_name, player) or broaden(state):
                                n += 1
                        return n >= count_needed
                    return _gemskills_count_check
                def _gemskills_count_check_floored(state, fl=counter_floor):
                    n = 0
                    for item_name, broaden in pairs:
                        if state.has(item_name, player) or broaden(state):
                            n += 1
                    if n < count_needed:
                        return False
                    return _count_field_tokens(state, player) >= fl
                return _gemskills_count_check_floored
            pool = tuple(skill_counter_pools[group_name])
            if counter_floor is None:
                return lambda state: sum(1 for n in pool if state.has(n, player)) >= count_needed
            return lambda state, fl=counter_floor: (
                sum(1 for n in pool if state.has(n, player)) >= count_needed
                and _count_field_tokens(state, player) >= fl
            )

        if group_name in level_stat_counters:
            stages = _qualifying_stages_for_stat(group_name, count_needed)
            return lambda state: _can_reach_any_stage(state, player, stages)

        if group_name in _TALISMAN_FRAGMENT_COUNTERS:
            names = _TALISMAN_FRAGMENT_COUNTERS[group_name]
            floor = (_TALISMAN_FRAGMENTS_TOKEN_FLOOR.get(count_needed)
                     if group_name == "talismanFragments" else None)
            if floor is None:
                return lambda state: _count_talisman_fragments(state, player, names) >= count_needed
            return lambda state: (
                _count_talisman_fragments(state, player, names) >= count_needed
                and _count_field_tokens(state, player) >= floor
            )

        if group_name in _TALISMAN_PROPERTY_TOKENS:
            prop_id = _TALISMAN_PROPERTY_TOKENS[group_name]
            return lambda state: _sum_talisman_property(prop_id, state, player) >= count_needed

        if group_name == "fieldToken":
            return lambda state: _count_field_tokens(state, player) >= count_needed
        if group_name == "shadowCore":
            return lambda state: _sum_shadow_cores(state, player) >= count_needed
        if group_name == "wizardLevel":
            needed_items = (count_needed + 1) // 2
            return lambda state: _count_xp_items(state, player) >= needed_items
        if group_name == "talismanRow":
            floor = _TALISMAN_ROW_TOKEN_FLOOR.get(count_needed)
            if floor is None:
                return lambda state: _count_complete_talisman_rows(state, player) >= count_needed
            return lambda state: (
                _count_complete_talisman_rows(state, player) >= count_needed
                and _count_field_tokens(state, player) >= floor
            )
        if group_name == "talismanColumn":
            floor = _TALISMAN_COLUMN_TOKEN_FLOOR.get(count_needed)
            if floor is None:
                return lambda state: _count_complete_talisman_columns(state, player) >= count_needed
            return lambda state: (
                _count_complete_talisman_columns(state, player) >= count_needed
                and _count_field_tokens(state, player) >= floor
            )
        if group_name == "skillPoints":
            return lambda state: _count_skill_points(state, player) >= count_needed

        return _always_true  # Unknown counter

    return _always_true  # Metadata


def _compile_dnf(groups: list, world, is_progressive: bool):
    """Compile a DNF requirement structure (list of AND-groups, outer OR) into
    a single (state) -> bool closure. Optimises common shapes."""
    compiled_groups = [
        [_compile_req(r, world, is_progressive) for r in group]
        for group in groups
    ]
    if not compiled_groups:
        return _always_true
    if len(compiled_groups) == 1:
        compiled = compiled_groups[0]
        if len(compiled) == 1:
            return compiled[0]
        return lambda state: all(f(state) for f in compiled)
    return lambda state: any(all(f(state) for f in g) for g in compiled_groups)


def set_rules(world: "GemcraftFrostbornWrathWorld") -> None:
    """
    Apply access rules to all regions and locations.

    Region connections (from the chosen starting stage):
      - All other stages: require their own field token to enter.
      - The starting stage itself has no token requirement (Menu connects
        directly to it in __init__.create_regions).

    Location rules:
      - Journey:        WIZLOCK skills (where applicable).
      - Wizard stash:   WIZLOCK skills (where applicable) + key item.
      - Achievements:   per-achievement requirements (skills, elements, etc.).

    Victory: A4 reachable AND all 24 skills collected (handled below).
    """
    from worlds.generic.Rules import add_rule

    player = world.player
    multiworld = world.multiworld

    # Per-seed skill/trait floor map. Built before any access-rule compilation
    # so the resolvers in _eval_req / _compile_req can look up the floor for
    # the matching item name.
    _build_skill_trait_floors(world)

    stages = GAME_DATA["stages"]

    # The chosen starting stage (from world.options.starting_stage) is the
    # one stage whose Field prereqs we ignore — it's the menu connection,
    # so its `requirements` list in rulesdata_levels.py shouldn't gate it.
    start_sid = world.start_sid

    start_region = multiworld.get_region(start_sid, player)

    # --- Region connections: starting stage → every other stage ---
    # A stage's own field-token item is required to physically enter the stage.
    # The actual item name depends on field_token_granularity — per_stage uses
    # `<sid> Field Token`, per_tile uses `<prefix> Tile Field Token`, per_tier
    # uses `Tier <N> Field Token`.
    from . import gating as _gating
    ft_gran = world.options.field_token_granularity.value
    for stage in stages:
        str_id = stage["str_id"]
        if str_id == start_sid:
            continue
        child_region = multiworld.get_region(str_id, player)
        connection = start_region.connect(child_region, f"{start_sid} -> {str_id}")

        token_name  = _gating.field_token_for_stage(str_id, ft_gran)
        token_count = _gating.field_token_count_for_stage(str_id, ft_gran, start_sid)
        if token_count == 1:
            connection.access_rule = (
                lambda state, tok=token_name: state.has(tok, player)
            )
        else:
            connection.access_rule = (
                lambda state, tok=token_name, n=token_count:
                    state.count(tok, player) >= n
            )

    # --- Location rules: WIZLOCK skill requirements only ---
    # gem_pouch_granularity selects which gem-related requirements actually gate.
    # All variants use the same `pouch_for_stage` + `pouch_count_for_stage`
    # contract from gating.py — distinct modes resolve to state.has, progressive
    # modes to state.count >= N, off short-circuits.
    from . import gating as _g
    pouch_mode = world.options.gem_pouch_granularity.value

    for str_id, rule in STAGE_RULES.items():
        if not rule.skills:
            continue

        conditions = []
        for skill in rule.skills:
            if ":" in skill:
                group_name, count_str = skill.split(":", 1)
                group_name = group_name.strip()
                if group_name == "gemPouch":
                    if pouch_mode == _g.POUCH_OFF:
                        continue  # off — pouches don't gate
                    # The `prefix` after the colon was used by per-tile-distinct
                    # for naming; with the unified helper we look up the pouch
                    # item via the stage's own sid. Per-tile rules naturally
                    # produce the same prefix-keyed item, and per-tier / global
                    # ignore the prefix entirely.
                    pouch_item = _g.pouch_for_stage(str_id, pouch_mode)
                    if pouch_item is None:
                        continue
                    pouch_needed = _g.pouch_count_for_stage(str_id, pouch_mode, world.start_sid)
                    if pouch_needed == 1:
                        conditions.append(lambda state, i=pouch_item: state.has(i, player))
                    else:
                        conditions.append(
                            lambda state, i=pouch_item, n=pouch_needed:
                                state.count(i, player) >= n)
                    continue
            else:
                item_name = f"{skill} Skill"
                conditions.append(lambda state, i=item_name: state.has(i, player))

        if not conditions:
            continue

        def make_rule(conds):
            return lambda state: all(c(state) for c in conds)

        for suffix in ("Journey", "Wizard stash"):
            loc_name = f"Complete {str_id} - {suffix}"
            location = multiworld.get_location(loc_name, player)
            location.access_rule = make_rule(conditions)

    # --- Per-stage requirement gates (Journey + Wizard stash) ---
    # Each non-start stage's `requirements` list in rulesdata_levels.py is
    # written in DNF (outer-OR over inner AND-groups). Field_<sid> entries
    # resolve to "stage <sid>'s Journey is clearable in-logic" via _eval_req,
    # so token possession alone isn't enough — the prereq stage must actually
    # be beatable through the chain.
    #
    # The chosen starting stage skips this gate entirely (it's the menu
    # connection; its own listed prereqs are intentionally ignored).
    from ._timing import wrap_rule, phase as _phase
    import time as _t
    _t_stages = _t.perf_counter()
    for stage in stages:
        sid = stage["str_id"]
        journey_loc = multiworld.get_location(f"Complete {sid} - Journey", player)
        stash_loc   = multiworld.get_location(f"Complete {sid} - Wizard stash", player)

        if sid != start_sid:
            requirements = LEVEL_DATA[sid].get("requirements", [])
            token_name  = _gating.field_token_for_stage(sid, ft_gran)
            token_count = _gating.field_token_count_for_stage(sid, ft_gran, start_sid)
            # Token-presence check, count-aware so progressive variants gate
            # the Nth stage on N copies of the singleton.
            if token_count == 1:
                token_check = lambda state, t=token_name: state.has(t, player)
            else:
                token_check = lambda state, t=token_name, n=token_count: \
                    state.count(t, player) >= n
            # Mirror the location access rule: clearing a stage in-logic also
            # requires the gem pouch needed to play it. Without this term,
            # Field_<sid> chain prereqs would resolve True from token + DNF
            # alone, letting fill place items on chains the player can't
            # actually traverse. Off mode short-circuits to _always_true.
            pouch_ok = _compile_gempouch_checker(world, sid)
            # The cached rule must require the stage's covering field-token
            # item so chain prereqs (Field_<sid>) only resolve True when the
            # prereq stage is actually clearable. Without this, starter-tier
            # stages with no DNF prereqs (W2-W4, S1-S4 when not chosen as
            # start) would fall through to True unconditionally, letting AP
            # place late tokens on sphere-1 locations.
            if requirements:
                normalized = _normalize_requirements(requirements)
                dnf_rule = _compile_dnf(normalized, world, is_progressive=False)
                _STAGE_CLEAR_RULES[(player, sid)] = (
                    lambda state, tc=token_check, d=dnf_rule, p=pouch_ok:
                        tc(state) and p(state) and d(state)
                )
                add_rule(journey_loc, wrap_rule(f"stage:{sid}:journey", dnf_rule))
                add_rule(stash_loc,   wrap_rule(f"stage:{sid}:stash", dnf_rule))
            else:
                _STAGE_CLEAR_RULES[(player, sid)] = (
                    lambda state, tc=token_check, p=pouch_ok:
                        tc(state) and p(state)
                )

        # Wizard-stash key item is always required (no off mode). The actual
        # item name depends on stash_key_granularity — see gating.stash_key_for_stage.
        # For progressive variants the rule needs N copies via state.count.
        from . import gating as _gating
        sk_gran   = world.options.stash_key_granularity.value
        key_name  = _gating.stash_key_for_stage(sid, sk_gran)
        key_count = _gating.stash_key_count_for_stage(sid, sk_gran, start_sid)
        if key_count == 1:
            key_check = lambda state, n=key_name: state.has(n, player)
        else:
            key_check = lambda state, n=key_name, c=key_count: \
                state.count(n, player) >= c
        add_rule(stash_loc, wrap_rule(f"stash_key:{sid}", key_check))
    from ._timing import log as _tlog
    _tlog(f"  set_rules: stage rules ({len(stages)} stages): {(_t.perf_counter()-_t_stages)*1000:.1f} ms")

    # --- Victory location rules ---
    # References goal_requirements from rulesdata_goals.py for definitions

    goal_value = world.options.goal.value

    if goal_value == 0:
        # kill_gatekeeper: Requires completing A4 - Journey (tier 12)
        req = goal_requirements["kill_gatekeeper"]
        a4_journey_loc = "Complete A4 - Journey"
        victory_location = multiworld.get_location("Complete A4 - Frostborn Wrath Victory", player)
        victory_location.access_rule = lambda state, loc=a4_journey_loc: state.can_reach(loc, "Location", player)

    elif goal_value == 1:
        # full_talisman: No access rule — fragments drop from any battle, player chooses when to claim
        pass

    elif goal_value == 2:
        # kill_swarm_queen: Requires completing K4 - Journey (tier 4)
        req = goal_requirements["kill_swarm_queen"]
        k4_journey_loc = "Complete K4 - Journey"
        victory_location = multiworld.get_location("Kill Swarm Queen Victory", player)
        victory_location.access_rule = lambda state, loc=k4_journey_loc: state.can_reach(loc, "Location", player)

    elif goal_value == 3:
        # fields_count: Complete N specific stages (configurable)
        req = goal_requirements["fields_count"]
        required = world.options.fields_required.value
        journey_locs = [f"Complete {s['str_id']} - Journey" for s in stages]
        victory_location = multiworld.get_location("Fields Count Victory", player)
        victory_location.access_rule = lambda state, locs=journey_locs, req=required: \
            sum(1 for loc in locs if state.can_reach(loc, "Location", player)) >= req

    elif goal_value == 4:
        # fields_percentage: Complete X% of all stages (configurable)
        from math import floor
        req = goal_requirements["fields_percentage"]
        required = floor(world.options.fields_required_percentage.value * len(stages) / 100)
        journey_locs = [f"Complete {s['str_id']} - Journey" for s in stages]
        victory_location = multiworld.get_location("Fields Percentage Victory", player)
        victory_location.access_rule = lambda state, locs=journey_locs, req=required: \
            sum(1 for loc in locs if state.can_reach(loc, "Location", player)) >= req

    # --- Achievement location access rules ---
    _t_ach = _t.perf_counter()
    _ach_rules_added = 0
    try:
        from .rulesdata_achievements import achievement_requirements as all_achievements

        is_progressive = False
        max_effort_level = world.options.achievement_required_effort.value
        effort_hierarchy = ["Trivial", "Minor", "Major", "Extreme"]
        max_effort_index = min(max_effort_level - 1, len(effort_hierarchy) - 1)
        max_effort_str = effort_hierarchy[max_effort_index] if max_effort_level > 0 else None

        from . import _should_skip_achievement

        for ach_name, ach_data in all_achievements.items():
            ach_effort = ach_data.get("required_effort", "Trivial")
            if max_effort_str:
                effort_index = effort_hierarchy.index(ach_effort) if ach_effort in effort_hierarchy else 0
                max_index = effort_hierarchy.index(max_effort_str) if max_effort_str in effort_hierarchy else 0
                if effort_index > max_index:
                    continue

            # Untrackable / Trial / disabled-Endurance achievements have no AP
            # location, so there's nothing to attach an access rule to.
            if _should_skip_achievement(ach_data, world.options):
                continue

            try:
                location = multiworld.get_location(f"Achievement: {ach_name}", player)
                raw = ach_data.get("requirements", [])
                normalized = _simplify_requirements(_normalize_requirements(raw))

                has_gating = any(
                    _is_gating_req(req, is_progressive)
                    for group in normalized
                    for req in group
                )
                if has_gating:
                    location.access_rule = wrap_rule(
                        f"ach:{ach_name}",
                        _compile_dnf(normalized, world, is_progressive))
                    _ach_rules_added += 1

                # Achievements are filler-quality and reachable across the
                # spectrum. Exclude edge/corner talismans so they end up at
                # higher-tier stage locations (where the player has cores).
                _restrict_talisman_shapes(location, True, True)

            except Exception:
                pass

    except Exception as e:
        print(f"ERROR setting achievement access rules: {e}")
        import traceback
        traceback.print_exc()
    _tlog(f"  set_rules: achievement rules ({_ach_rules_added} gated): {(_t.perf_counter()-_t_ach)*1000:.1f} ms")

    multiworld.completion_condition[player] = lambda state: state.has("Victory", player)

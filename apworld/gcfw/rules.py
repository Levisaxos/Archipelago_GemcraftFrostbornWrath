from __future__ import annotations

from typing import TYPE_CHECKING, List

from .rulesdata import GAME_DATA, STAGE_RULES, TIERS, GEM_POUCH_PLAY_ORDER
from .requirement_tokens import (
    item_prefix_map, element_prefix_map, skill_prefix_map,
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


# Single bundle holds all three per-state-sig caches (counter values,
# stage-clearability, and OR-of-stages reachability) keyed off ONE
# `_gcfw_state_sig` computation per call. Previously each cache called
# the sig helper independently, paying `sum(items.values())` 2-3 times
# per achievement-rule eval. The bundle is invalidated atomically when
# the sig changes, so semantics stay identical.
def _get_caches(state, player: int):
    sig = _gcfw_state_sig(state, player)
    bundle = getattr(state, "_gcfw_caches", None)
    if bundle is None or bundle[0] != sig:
        bundle = (sig, {}, {}, {})
        state._gcfw_caches = bundle
    return bundle  # (sig, counter_dict, clear_dict, or_dict)


def _get_counter_cache(state, player: int) -> dict:
    return _get_caches(state, player)[1]


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
    Each 'Skillpoint Bundle (Tier)' contributes the per-seed SP value for
    that tier (computed in create_items, stored on the world). The pool
    may contain many copies of each tier."""
    cache = _get_counter_cache(state, player)
    val = cache.get("sp")
    if val is None:
        from .items_skillpoints import TIER_NAMES, sp_bundle_item_name
        world = state.multiworld.worlds[player]
        values = getattr(world, "sp_bundle_values", [0, 0, 0, 0])
        val = 0
        for i, tier in enumerate(TIER_NAMES):
            if values[i] > 0:
                val += values[i] * state.count(sp_bundle_item_name(tier), player)
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
        # Clearability check: free stages auto-pass the pouch gate because
        # Hollow Gems substitute at runtime. Strict gem-availability uses
        # _compile_gempouch_checker directly elsewhere.
        pouch_mode = world.options.gem_pouch_granularity.value
        pouch_free = (
            set(_g.free_stages_for_starter(starter_sid, ft_gran))
            if pouch_mode != _g.POUCH_OFF
            else set()
        )
        pairs = [
            (
                _g.field_token_for_stage(s["str_id"], ft_gran),
                _g.field_token_count_for_stage(s["str_id"], ft_gran, starter_sid),
                (_always_true if s["str_id"] in pouch_free
                 else _compile_gempouch_checker(world, s["str_id"])),
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


def _count_clearable_stages(state, player: int) -> int:
    """Count stages currently in logic — full reachability via
    `_can_clear_stage_cached`, not just token + pouch.  Used by the
    `fieldToken:N` achievement-requirement token where the player needs N
    stages they can actually play through.  Distinct from
    `_count_field_tokens` which is the floor-gate metric (token + pouch,
    no per-stage skill prereqs) used to phase progression items."""
    cache = _get_counter_cache(state, player)
    val = cache.get("clear")
    if val is not None:
        return val
    val = sum(
        1 for s in GAME_DATA["stages"]
        if _can_clear_stage_cached(state, player, s["str_id"])
    )
    cache["clear"] = val
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
    # Precollected skill/trait items (e.g. Overcrowd via `starting_overcrowd`)
    # are owned from frame 0; the floor was designed to stretch progression
    # for items received during play, so applying it to starting inventory
    # incorrectly hides their requirements from logic (visible in UT, which
    # runs this same set_rules path; the mod tracker has no floor system).
    precollected = world.multiworld.precollected_items[world.player]
    for item in precollected:
        if item.name in world._skill_trait_floors:
            world._skill_trait_floors[item.name] = 0


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
# i.e. universally present like Tower" (always satisfied).
_PRESENT_COUNT_FIELDS: frozenset = frozenset(
    f for d in LEVEL_DATA.values() for f, v in d.items()
    if f.endswith("Count") and isinstance(v, (int, float)) and v > 0
)

# Element tokens whose underlying mechanic isn't actually shipped in the
# randomizer yet — the eX token exists in the achievement vocabulary but
# evaluating against per-stage *Count fields would falsely block. Always
# treat as available, matching the mod's `_elementInLogic` (empty
# `_elementStages[name]` → True). Add new placeholders here as they
# arrive; remove an entry once the mechanic is wired up and Count data
# becomes meaningful for the gate.
_STUB_ELEMENTS: frozenset = frozenset({"Wall"})


def _element_count_field(elem_name: str) -> str:
    """Display name -> per-stage Count field name in LEVEL_DATA.
    "Drop Holder" -> "DropHolderCount", "Sealed gem" -> "SealedGemCount"."""
    return "".join(p[0].upper() + p[1:] for p in elem_name.split() if p) + "Count"


def _get_world_stash_key_map(state, player: int) -> dict | None:
    """Per-world map of sid -> (stash-key item name, count needed),
    granularity-aware. Built once and cached on the world instance.
    For distinct/global modes count is always 1; progressive modes return
    the position-in-order count threshold. Returns None when stash keys
    are off — callers must treat the gate as unconditionally satisfied."""
    world = state.multiworld.worlds[player]
    if not hasattr(world, "_sid_to_stash_key"):
        from . import gating as _g
        sk_gran = world.options.stash_key_granularity.value
        if sk_gran == _g.STASH_OFF:
            world._sid_to_stash_key = None
        else:
            starter_sid = world.start_sid
            world._sid_to_stash_key = {
                s["str_id"]: (
                    _g.stash_key_for_stage(s["str_id"], sk_gran),
                    _g.stash_key_count_for_stage(s["str_id"], sk_gran, starter_sid),
                )
                for s in GAME_DATA["stages"]
            }
    return world._sid_to_stash_key


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
    key check). When stash keys are off, every stash is open so this
    reduces to "any stage's Journey location is reachable"."""
    sid_to_key = _get_world_stash_key_map(state, player)
    if sid_to_key is None:
        for s in GAME_DATA["stages"]:
            try:
                if state.can_reach(f"Complete {s['str_id']} - Journey", "Location", player):
                    return True
            except KeyError:
                continue
        return False
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


# Forward map: stage str_id -> frozenset of gem display names available on
# that stage.  Derived once from `_STAGES_BY_GEM` for the per-stage gem-skill
# counter below.
_GEMS_BY_STAGE: dict = {}
for _gem_disp, _sids in _STAGES_BY_GEM.items():
    for _sid in _sids:
        _GEMS_BY_STAGE.setdefault(_sid, set()).add(_gem_disp)
_GEMS_BY_STAGE = {_sid: frozenset(_gems) for _sid, _gems in _GEMS_BY_STAGE.items()}
if "_gem_disp" in dir():
    del _gem_disp
if "_sids" in dir():
    del _sids
if "_sid" in dir():
    del _sid
if "_gems" in dir():
    del _gems


def _count_gem_skills_per_stage_max(state, player: int) -> int:
    """Per-stage max count for the `gemSkills:N` counter.

    A gem color counts on stage `s` iff the skill item is held (works on any
    stage) OR `s.AvailableGems` lists it (starter pouch).  Returns the max
    over all reachable stages of |held ∪ stage_gems|.  Held-only is the
    floor when no stage is reachable.  This is the correct rule for
    prismatic-style requirements: the N colors must coexist on one stage."""
    held = set()
    for token, gem_name in _GEM_TOKEN_TO_GEM_NAME.items():
        if state.has(item_prefix_map[token], player):
            held.add(gem_name)
    held_count = len(held)
    if held_count == 6:
        return 6
    max_n = held_count
    for sid, stage_gems in _GEMS_BY_STAGE.items():
        if not _can_reach_any_stage(state, player, [sid]):
            continue
        n = len(held | stage_gems)
        if n > max_n:
            max_n = n
            if max_n == 6:
                return 6
    return max_n


# Building-element broadening: bare `eTraps` / `eLanterns` / `ePylons` /
# `eAmplifiers` tokens pass if the player owns the matching skill item
# (lets them build the element on any reachable stage) OR can reach a
# stage that already hosts the pre-placed building.  Strict `sTraps`
# etc. still mean "Traps Skill held"; achievements that genuinely need
# the player to *build* a trap (Sparse Snares / Entrenched / etc.) keep
# the strict s-form.
_BUILDING_ELEMENT_TO_SKILL_ITEM: dict = {
    "eTraps":      skill_prefix_map["sTraps"],
    "eLanterns":   skill_prefix_map["sLanterns"],
    "ePylons":     skill_prefix_map["sPylons"],
    "eAmplifiers": skill_prefix_map["sAmplifiers"],
}

# Elements that require a specific skill to interact with at runtime — the
# player can only act on the pre-placed element on a reachable stage AND must
# hold the skill. Unlike building elements above, the skill does NOT broaden
# the stage set; it's an additional AND-gate, not an OR. Drop Holders are
# only openable by Bolt shots (DropHolder.takeDamage requires a TowerBolt
# origin; without Bolt the holder is inert). Any achievement that names
# eDropHolder thus needs Bolt held in addition to reaching a drop-holder stage.
_ELEMENT_INTERACT_SKILL: dict = {
    "eDropHolder": "Bolt Skill",
}
_ELEMENT_PASCAL_INTERACT_SKILL: dict = {
    req[1:]: skill for req, skill in _ELEMENT_INTERACT_SKILL.items()
}


def _eval_element_count(elem_pascal: str, count_needed: int, state, player: int) -> bool:
    """Resolve eX:N form: a reachable stage exists where <X>Count >= N.
    If the element isn't tracked per-stage (no <X>Count field anywhere in
    LEVEL_DATA), treat it as universally present (Tower / Marked Monster
    fall here)."""
    if elem_pascal in _STUB_ELEMENTS:
        # Stub elements: the eX token is in the achievement vocabulary as a
        # placeholder, but the underlying mechanic isn't implemented in the
        # randomizer yet. Always pass to match the mod's `_elementInLogic`
        # behavior (where an empty `_elementStages[name]` returns True).
        return True
    if elem_pascal == "WizardStash":
        # Every stage has a wizard stash, so `WizardStashCount` is not a
        # per-stage tracked field. Without this special-case the universal
        # early-return below would let `eWizardStash:N` pass even with zero
        # keys held — route through the same key + journey-reachability
        # gate as the bare `eWizardStash` token (`_any_stash_reachable`)
        # instead, counting distinct openable stashes for N > 1. Whether
        # a stash actually requires a key depends on the seed's
        # stash_key_granularity yaml option (STASH_OFF means no gate).
        if count_needed <= 1:
            return _any_stash_reachable(state, player)
        from . import gating as _g
        world = state.multiworld.worlds[player]
        sk_gran = world.options.stash_key_granularity.value
        if sk_gran == _g.STASH_OFF:
            n = 0
            for s in GAME_DATA["stages"]:
                try:
                    if state.can_reach(f"Complete {s['str_id']} - Journey",
                                       "Location", player):
                        n += 1
                        if n >= count_needed:
                            return True
                except KeyError:
                    continue
            return False
        starter_sid = world.start_sid
        n = 0
        for s in GAME_DATA["stages"]:
            sid = s["str_id"]
            key_name  = _g.stash_key_for_stage(sid, sk_gran)
            key_count = _g.stash_key_count_for_stage(sid, sk_gran, starter_sid)
            if key_count == 1:
                if not state.has(key_name, player):
                    continue
            elif state.count(key_name, player) < key_count:
                continue
            try:
                if state.can_reach(f"Complete {sid} - Journey", "Location", player):
                    n += 1
                    if n >= count_needed:
                        return True
            except KeyError:
                continue
        return False

    field = elem_pascal + "Count"
    if field not in _PRESENT_COUNT_FIELDS:
        return True
    interact_skill = _ELEMENT_PASCAL_INTERACT_SKILL.get(elem_pascal)
    if interact_skill is not None and not state.has(interact_skill, player):
        return False
    qualifying = [sid for sid, d in LEVEL_DATA.items() if d.get(field, 0) >= count_needed]
    if elem_pascal == "WizardTower":
        # Wizard towers are the visual structure of wizard stashes — even if
        # the stage is reachable, the player can only "unlock" the tower by
        # opening its stash, which requires the per-stage stash key. So gate
        # on both (stage reachable, stash key held) for any qualifying stage.
        # When stash keys are off, the key check is dropped.
        from . import gating as _g
        world = state.multiworld.worlds[player]
        sk_gran = world.options.stash_key_granularity.value
        if sk_gran == _g.STASH_OFF:
            return _can_reach_any_stage(state, player, qualifying)
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


def _strip_field_prereqs(normalized: list) -> list:
    """Remove `Field_<sid>` entries from every AND-group in a normalized
    DNF. Used under progressive field-token granularities, where the Nth
    singleton token unlocks the Nth stage in randomized order, making the
    vanilla Field_ chain artificial. Skill / counter clauses inside the
    same AND-group are real prerequisites and stay.

    An AND-group that empties out after stripping is kept as an empty
    list: `_compile_dnf` treats it as unconditionally true, which makes
    the whole DNF true — preserving the "any progressive token unlocks
    the next stage" intent for stages whose only prereq was a Field_
    chain (e.g. Z1 → [Field_W1])."""
    out: list = []
    for group in normalized:
        if not isinstance(group, list):
            out.append(group)
            continue
        out.append([r for r in group if not (isinstance(r, str) and r.startswith("Field_"))])
    return out


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
    data = _get_caches(state, player)[3]
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
    data = _get_caches(state, player)[2]

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
        # the matching starter gem is reachable.  Building skills (sTraps
        # etc.) stay strict — achievements that need pre-placed traps to
        # count use the lenient `eTraps` form instead.
        item_name = item_prefix_map[req]
        if req in _GEM_TOKEN_TO_GEM_NAME:
            if not _has_gem_token(req, state, player):
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
        # Building elements (eTraps / eLanterns / ePylons / eAmplifiers)
        # also pass when the player holds the matching skill — they can
        # build the element on any reachable stage.
        skill_item = _BUILDING_ELEMENT_TO_SKILL_ITEM.get(req)
        if skill_item is not None and state.has(skill_item, player):
            return True
        # Interact-skill elements (eDropHolder → Bolt) are AND-gated: the
        # element-reach must hold AND the player must own the skill that
        # actually enables interaction. Without the skill the element is
        # inert no matter how many stages host it.
        interact_skill = _ELEMENT_INTERACT_SKILL.get(req)
        if interact_skill is not None and not state.has(interact_skill, player):
            return False
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
            # `gemSkills:N` / `GemSkills:N` use a per-stage max: a gem skill
            # counts on stage `s` if held OR `s` has it in `AvailableGems`,
            # and the requirement passes if any reachable stage hits the
            # count.  Prismatic-class achievements need the N colors to
            # coexist on a single stage, not be scattered across reachable
            # stages.  All other counter pools (strikeSpells,
            # enhancementSpells, BattleTraits, OtherSkills, skills) stay
            # strict-item-count.
            if group_name in ("gemSkills", "GemSkills"):
                if _count_gem_skills_per_stage_max(state, player) < count_needed:
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
            # Stages in logic (full clearability), not just tokens held.
            # The floor-gate semantic (token + pouch) lives in
            # `_count_field_tokens` and is used elsewhere for progression
            # phasing; for the achievement-requirement token we want
            # "stages the player can actually play".
            return _count_clearable_stages(state, player) >= count_needed
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

# Pre-built SP-bundle name list — one entry per tier (Small, Medium, Large, Huge).
from .items_skillpoints import SP_BUNDLE_NAMES as _SP_BUNDLE_NAMES


def _qualifying_stages_for_element(elem_pascal: str, count_needed: int):
    """Return cached list of stage str_ids whose <elem>Count >= count_needed.
    Returns None if the element isn't tracked per-stage (universally present)."""
    key = ("elem", elem_pascal, count_needed)
    if key in _QUALIFYING_STAGES_CACHE:
        return _QUALIFYING_STAGES_CACHE[key]
    if elem_pascal in _STUB_ELEMENTS:
        # Stub element — token in the achievement vocabulary as a placeholder
        # but the underlying mechanic isn't implemented yet. Force the
        # "universally present" path so the compiled `_compile_element_or`
        # short-circuits to `_always_true`. Mirrors the runtime `_STUB_ELEMENTS`
        # bypass in `_eval_element_count`.
        result = None
    else:
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
    """Return (state) -> bool: True iff the player owns the actual gempouch
    item that grants the stage's listed gem types. Granularity-aware — uses
    gating helpers so the rule adapts to all variants (distinct + progressive
    + global).

    STRICT variant — does *not* exempt free stages. Hollow Gems substitute
    for a missing pouch at runtime so the stage can be *cleared*, but they
    don't grant the stage's gem types and so don't make those gems available
    for achievement requirements (e.g. sBolt broadening). For clearability
    checks (journey/stash access, _STAGE_CLEAR_RULES), the call site applies
    the free-stage exemption inline; do not move that exemption in here.
    See _compile_gem_broadened for the canonical "no Hollow Gem credit" use."""
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


# Per-predicate cost ranks used by `_compile_dnf` to short-circuit cheap
# checks first. Tiers reflect average per-call work in a typical fill:
#   0 = constant (always_true / always_false)
#   1 = single state.has / state.count lookup
#   2 = cached counter (state-sig memoised; first call per sig is the
#                       expensive one, all reused)
#   3 = stage reachability / element OR / Achievement: recursion
_COST_CONST: int = 0
_COST_HAS:   int = 1
_COST_COUNTER: int = 2
_COST_REACH:   int = 3


def _compile_element_or(elem_names, player: int):
    """Compile an "any of these elements is reachable" check.

    Returns just the closure for backwards compatibility.  See
    `_compile_element_or_full` for the AND-group-binding-aware version.
    """
    fn, _static = _compile_element_or_full(elem_names, player)
    return fn


def _compile_element_or_full(elem_names, player: int):
    """Compile an "any of these elements is reachable" check, returning
    `(fn, static_set_or_None)`.

    `static_set` is the union of qualifying stage str_ids if the disjunction
    is purely data-driven (no STASH, no universally-true member).  None
    signals "not bindable in an AND-group" — either because the closure is
    `_always_true`/`_always_false`, or because it routes through a
    state-dependent path (`_any_stash_reachable`) that doesn't reduce to a
    fixed stage set.

    Each element is one of:
      - "Wizard Stash" → any wizard-stash key held AND its stage clearable
      - present in level data → reachable iff any qualifying stage reachable
      - universally present (not in _PRESENT_COUNT_FIELDS) → always True
    """
    members: list = []
    for n in elem_names:
        if n == "Wizard Stash":
            members.append(("STASH", None))
            continue
        elem_pascal = _element_count_field(n)[:-len("Count")]
        stages = _qualifying_stages_for_element(elem_pascal, 1)
        if stages is None:
            return _always_true, None  # one universal member → whole disjunction true
        members.append(("STAGES", stages))

    if not members:
        return _always_false, None

    has_stash = any(k == "STASH" for k, _ in members)

    # Specialise common shapes.
    if len(members) == 1:
        kind, stages = members[0]
        if kind == "STASH":
            return lambda state: _any_stash_reachable(state, player), None
        return (lambda state: _can_reach_any_stage(state, player, stages),
                frozenset(stages))

    def _multi(state):
        for kind, stages in members:
            if kind == "STASH":
                if _any_stash_reachable(state, player):
                    return True
            elif _can_reach_any_stage(state, player, stages):
                return True
        return False

    if has_stash:
        return _multi, None
    union = set()
    for _kind, stages in members:
        union.update(stages)
    return _multi, frozenset(union)


def _compile_req(req: str, world, is_progressive: bool):
    """Compile a single requirement string to `((state) -> bool, cost, static_set)`.

    Mirrors `_eval_req` branch-for-branch — keep them in sync. The returned
    closure binds all per-call constants (item names, qualifying stage lists,
    counter pools) so the only runtime work is the actual state lookups.
    The cost is one of `_COST_CONST` / `_COST_HAS` / `_COST_COUNTER` /
    `_COST_REACH` and lets `_compile_dnf` sort cheap predicates first so AND
    short-circuits earlier in the common (False) case during fill.

    `static_set` carries the same-stage-binding hint:
      * `None` — token is global (no stage constraint).  The closure is the
        full answer.
      * `frozenset` of stage str_ids — token is per-stage and is satisfied
        iff a reachable stage in that frozen set exists.  `_compile_dnf`
        intersects these across an AND-group so multi-token requirements
        like `[eApparition, eShrine, minWave:50]` bind to a single stage.

    Takes `world` (not just player) so gem-skill broadening can build the
    per-stage gempouch checker — the broadening must respect the player's
    actual access (gempouch held) rather than treating every reachable
    stage's `available_gems` as usable.
    """
    req = req.strip()
    player = world.player

    if req.startswith("Field_"):
        sid = req[len("Field_"):]
        return (lambda state: _can_clear_stage_cached(state, player, sid),
                _COST_REACH, frozenset({sid}))

    if req.startswith("Achievement:"):
        if not is_progressive:
            return (_always_true, _COST_CONST, None)
        loc_name = req
        def _ach_reachable(state):
            try:
                return state.can_reach(loc_name, "Location", player)
            except KeyError:
                return False
        return (_ach_reachable, _COST_REACH, None)

    if req in mode_tokens:
        return (_always_false, _COST_CONST, None)

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
                return (_gem_token_floored, _COST_REACH, None)
            def _gem_token(state, n=item_name, b=broaden):
                if state.has(n, player):
                    return True
                return b(state)
            return (_gem_token, _COST_REACH, None)
        if floor:
            return (lambda state, n=item_name, f=floor: (
                state.has(n, player) and _count_field_tokens(state, player) >= f
            ), _COST_COUNTER, None)
        return (lambda state, n=item_name: state.has(n, player), _COST_HAS, None)

    if req in element_prefix_map:
        # Building elements (eTraps etc.) also pass when the matching skill
        # is held — broaden the compiled disjunction.  Holding the skill
        # makes the token satisfied on any stage, so it's not bindable.
        skill_item = _BUILDING_ELEMENT_TO_SKILL_ITEM.get(req)
        if skill_item is not None:
            fn = _compile_element_or(element_prefix_map[req], player)
            def _bld_elem(state, n=skill_item, f=fn):
                return state.has(n, player) or f(state)
            return (_bld_elem, _COST_REACH, None)
        fn, static_set = _compile_element_or_full(element_prefix_map[req], player)
        # Interact-skill elements (eDropHolder → Bolt) AND-gate the stage
        # reach with the skill. Static_set is preserved so AND-group stage
        # binding still works; the skill is just an additional state check.
        interact_skill = _ELEMENT_INTERACT_SKILL.get(req)
        if interact_skill is not None:
            def _interact_elem(state, n=interact_skill, f=fn):
                return state.has(n, player) and f(state)
            return (_interact_elem, _COST_REACH, static_set)
        return (fn,
                _COST_CONST if fn is _always_true else _COST_REACH,
                static_set)

    if ":" in req:
        group_name, count_str = req.split(":", 1)
        group_name = group_name.strip()
        try:
            count_needed = int(count_str.strip())
        except ValueError:
            return (_always_true, _COST_CONST, None)

        # Group token with count (eNonMonsters:1 etc.) — count is ignored,
        # mirrors _eval_req. Reachable iff any group member is reachable.
        if group_name in element_prefix_map and len(element_prefix_map[group_name]) > 1:
            fn, static_set = _compile_element_or_full(element_prefix_map[group_name], player)
            return (fn,
                    _COST_CONST if fn is _always_true else _COST_REACH,
                    static_set)

        if _is_prefix_token(group_name, "e"):
            elem_pascal = group_name[1:]
            stages = _qualifying_stages_for_element(elem_pascal, count_needed)
            if stages is None:
                return (_always_true, _COST_CONST, None)
            stages_fs = frozenset(stages)
            interact_skill = _ELEMENT_PASCAL_INTERACT_SKILL.get(elem_pascal)
            if interact_skill is not None:
                return (lambda state, n=interact_skill, s=stages: (
                    state.has(n, player) and _can_reach_any_stage(state, player, s)
                ), _COST_REACH, stages_fs)
            return (lambda state: _can_reach_any_stage(state, player, stages),
                    _COST_REACH, stages_fs)

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
                    return (_gemskills_count_check, _COST_REACH, None)
                def _gemskills_count_check_floored(state, fl=counter_floor):
                    n = 0
                    for item_name, broaden in pairs:
                        if state.has(item_name, player) or broaden(state):
                            n += 1
                    if n < count_needed:
                        return False
                    return _count_field_tokens(state, player) >= fl
                return (_gemskills_count_check_floored, _COST_REACH, None)
            pool = tuple(skill_counter_pools[group_name])
            if counter_floor is None:
                return (lambda state: sum(1 for n in pool if state.has(n, player)) >= count_needed,
                        _COST_COUNTER, None)
            return (lambda state, fl=counter_floor: (
                sum(1 for n in pool if state.has(n, player)) >= count_needed
                and _count_field_tokens(state, player) >= fl
            ), _COST_COUNTER, None)

        if group_name in level_stat_counters:
            stages = _qualifying_stages_for_stat(group_name, count_needed)
            stages_fs = frozenset(stages)
            return (lambda state: _can_reach_any_stage(state, player, stages),
                    _COST_REACH, stages_fs)

        if group_name in _TALISMAN_FRAGMENT_COUNTERS:
            names = _TALISMAN_FRAGMENT_COUNTERS[group_name]
            floor = (_TALISMAN_FRAGMENTS_TOKEN_FLOOR.get(count_needed)
                     if group_name == "talismanFragments" else None)
            if floor is None:
                return (lambda state: _count_talisman_fragments(state, player, names) >= count_needed,
                        _COST_COUNTER, None)
            return (lambda state: (
                _count_talisman_fragments(state, player, names) >= count_needed
                and _count_field_tokens(state, player) >= floor
            ), _COST_COUNTER, None)

        if group_name in _TALISMAN_PROPERTY_TOKENS:
            prop_id = _TALISMAN_PROPERTY_TOKENS[group_name]
            return (lambda state: _sum_talisman_property(prop_id, state, player) >= count_needed,
                    _COST_COUNTER, None)

        if group_name == "fieldToken":
            # Stages in logic, not tokens held — see `_eval_req` comment.
            return (lambda state: _count_clearable_stages(state, player) >= count_needed,
                    _COST_REACH, None)
        if group_name == "shadowCore":
            return (lambda state: _sum_shadow_cores(state, player) >= count_needed,
                    _COST_COUNTER, None)
        if group_name == "wizardLevel":
            needed_items = (count_needed + 1) // 2
            return (lambda state: _count_xp_items(state, player) >= needed_items,
                    _COST_COUNTER, None)
        if group_name == "talismanRow":
            floor = _TALISMAN_ROW_TOKEN_FLOOR.get(count_needed)
            if floor is None:
                return (lambda state: _count_complete_talisman_rows(state, player) >= count_needed,
                        _COST_COUNTER, None)
            return (lambda state: (
                _count_complete_talisman_rows(state, player) >= count_needed
                and _count_field_tokens(state, player) >= floor
            ), _COST_COUNTER, None)
        if group_name == "talismanColumn":
            floor = _TALISMAN_COLUMN_TOKEN_FLOOR.get(count_needed)
            if floor is None:
                return (lambda state: _count_complete_talisman_columns(state, player) >= count_needed,
                        _COST_COUNTER, None)
            return (lambda state: (
                _count_complete_talisman_columns(state, player) >= count_needed
                and _count_field_tokens(state, player) >= floor
            ), _COST_COUNTER, None)
        if group_name == "skillPoints":
            return (lambda state: _count_skill_points(state, player) >= count_needed,
                    _COST_COUNTER, None)

        return (_always_true, _COST_CONST, None)  # Unknown counter

    return (_always_true, _COST_CONST, None)  # Metadata


def _compose_and(compiled):
    """Compose a sorted (cheap-first) list of (state) -> bool closures into
    one AND closure. Specialised for N=1/2/3 to dodge generator overhead on
    the common shapes; falls back to `all(...)` for longer groups.
    """
    n = len(compiled)
    if n == 1:
        return compiled[0]
    if n == 2:
        f0, f1 = compiled
        return lambda state: f0(state) and f1(state)
    if n == 3:
        f0, f1, f2 = compiled
        return lambda state: f0(state) and f1(state) and f2(state)
    fs = tuple(compiled)
    return lambda state: all(f(state) for f in fs)


def _compose_or(group_fns):
    """Compose group-level OR closure with the same N=1/2/3 specialisation."""
    n = len(group_fns)
    if n == 1:
        return group_fns[0]
    if n == 2:
        g0, g1 = group_fns
        return lambda state: g0(state) or g1(state)
    if n == 3:
        g0, g1, g2 = group_fns
        return lambda state: g0(state) or g1(state) or g2(state)
    gs = tuple(group_fns)
    return lambda state: any(g(state) for g in gs)


def _compile_dnf(groups: list, world, is_progressive: bool):
    """Compile a DNF requirement structure (list of AND-groups, outer OR) into
    a single (state) -> bool closure.

    Two-level cost ordering for short-circuit:
      * AND-group: predicates sorted cheap-first so a False on a 1-µs
        `state.has` skips the 100-µs `_can_reach_any_stage` behind it.
      * Outer OR: groups sorted by their cheapest member so a True on a
        cheap group skips the expensive groups entirely. Stable-sort keeps
        author-intent order among groups with equal min-cost.

    Same-stage binding: tokens that compile with a `static_set` (per-stage
    qualifying stage list — eX, eX:N, multi-element OR, minWave:N, Field_X,
    etc.) collapse into a single consolidated reach check on the
    intersection of their stage sets.  This implements the rule that all
    per-stage requirements in an inner AND-group must be satisfied on the
    same stage — fixes false-positives where multiple eX tokens were each
    individually satisfied on different reachable stages.  Dynamic
    per-stage tokens (gem `sX` broadening, building `eX` with skill held,
    `gemSkills:N`) keep their individual closures and run alongside the
    consolidated check.
    """
    if not groups:
        return _always_true

    player = world.player
    compiled_groups: list = []
    group_min_costs: list = []
    for group in groups:
        items = [_compile_req(r, world, is_progressive) for r in group]
        # Partition into globals (no per-stage binding) and static per-stage
        # tokens (carry a frozenset that AND-binds across the group).
        # Drop _always_true entries; collapse on _always_false.
        globals_list: list = []
        static_sets: list = []
        dead_group = False
        for fn, cost, static_set in items:
            if fn is _always_true:
                continue
            if fn is _always_false:
                dead_group = True
                break
            if static_set is not None:
                static_sets.append(static_set)
            else:
                globals_list.append((fn, cost))
        if dead_group:
            continue  # this AND-group can never satisfy
        if not globals_list and not static_sets:
            # All predicates were always_true → group is unconditionally true,
            # so the whole DNF is true regardless of other groups.
            return _always_true
        if static_sets:
            intersection = static_sets[0]
            for s in static_sets[1:]:
                intersection = intersection & s
                if not intersection:
                    break
            if not intersection:
                # No stage satisfies all per-stage tokens in this AND-group.
                continue
            intersection = frozenset(intersection)
            # One consolidated reach check replaces every individual static
            # per-stage closure in this AND-group.
            globals_list.append(
                ((lambda state, _stages=intersection:
                      _can_reach_any_stage(state, player, _stages)),
                 _COST_REACH)
            )
        # Sort cheap predicates first inside the group.
        globals_list.sort(key=lambda t: t[1])
        compiled_groups.append([fn for fn, _ in globals_list])
        group_min_costs.append(globals_list[0][1])

    if not compiled_groups:
        # Every group was dead (always_false somewhere) → DNF is unsat.
        return _always_false

    # Stable-sort groups by their cheapest predicate cost so cheap groups
    # OR-evaluate first.
    order = sorted(range(len(compiled_groups)), key=lambda i: group_min_costs[i])
    sorted_groups = [compiled_groups[i] for i in order]

    group_fns = [_compose_and(g) for g in sorted_groups]
    return _compose_or(group_fns)


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
    # Stage + achievement rules now go straight to `location.access_rule`
    # via the compose_and / compose_or helpers — `add_rule` chained
    # closures together, but per-stage we already know the full set of
    # checks at compile time, so a single composed AND is faster.

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

    # --- Per-stage location rules (Journey + Wizard stash) ---
    # One pass per stage that builds the full per-location AND-chain in
    # one shot, instead of layering it via repeated `add_rule` calls.
    # Per-location components, in cheap-first order:
    #   1. WIZLOCK skill / pouch checks (state.has lambdas).
    #   2. Wizard-stash key check (stash location only; state.has lambda).
    #   3. DNF prereq closure (mixed cost, can recurse through Field_<sid>).
    # The combined closure is assigned directly to `location.access_rule`,
    # skipping the chain wrappers `add_rule` would have produced.
    #
    # gem_pouch_granularity selects which gem-related requirements actually gate.
    # All variants use the same `pouch_for_stage` + `pouch_count_for_stage`
    # contract from gating.py — distinct modes resolve to state.has, progressive
    # modes to state.count >= N, off short-circuits.
    from . import gating as _g
    pouch_mode = world.options.gem_pouch_granularity.value
    sk_gran    = world.options.stash_key_granularity.value

    from ._timing import wrap_rule, phase as _phase
    import time as _t
    _t_stages = _t.perf_counter()
    # Progressive field-token modes: the Nth copy of the singleton item
    # unlocks the Nth stage in the seed's randomized progression order, so
    # the token count IS the prereq chain. Vanilla GCFW Field_<sid> chains
    # from rulesdata_levels.py become artificial in those modes — a tile
    # at progressive position 5 with vanilla prereqs from a tile at
    # position 10 would otherwise be marked unreachable until the later
    # tile arrives. Skip the DNF entirely for progressive granularities.
    ft_progressive = ft_gran in (
        _gating.FIELD_PER_STAGE_PROGRESSIVE,
        _gating.FIELD_PER_TILE_PROGRESSIVE,
        _gating.FIELD_PER_TIER_PROGRESSIVE,
    )
    # Stages immediately playable at session start under the chosen
    # field-token granularity (per_stage → just the starter; per_tile →
    # the whole starter tile; per_tier → the whole starter tier). Their
    # covering field token is precollected, the mod treats them as
    # `_freeStages` with no DNF/skill gates, so apworld must too:
    #   - Skip the gem-pouch WIZLOCK clause (HollowGemInjector substitutes
    #     Hollow Gems at runtime when the matching pouch isn't held).
    #   - Skip the per-stage vanilla DNF prereqs (e.g. S1's `Field_W1`)
    #     so the whole starter group is in-logic from sphere 0, even when
    #     individual stages have vanilla chains pointing outside the group.
    # Without these exemptions UT shows the starter group's stages — and
    # any elements on them — as out-of-logic, while the in-game mod (which
    # does treat the whole _freeStages set as reachable) shows them in.
    #
    # NOTE: this only relaxes *clearability*. Hollow Gems do NOT grant the
    # stage's listed gem types, so gem availability (gemSkills broadening,
    # gem-typed achievement requirements) still goes through the strict
    # _compile_gempouch_checker — see _compile_gem_broadened for the
    # corresponding "no Hollow Gem credit" filter.
    free_sids = set(_gating.free_stages_for_starter(start_sid, ft_gran))
    pouch_free_sids = free_sids if pouch_mode != _g.POUCH_OFF else set()
    for stage in stages:
        sid = stage["str_id"]
        journey_loc = multiworld.get_location(f"Complete {sid} - Journey", player)
        stash_loc   = multiworld.get_location(f"Complete {sid} - Wizard stash", player)

        # ---- WIZLOCK conditions (cheap state.has / state.count) ----
        wizlock_conditions: list = []
        rule = STAGE_RULES.get(sid)
        if rule is not None and rule.skills:
            for skill in rule.skills:
                if ":" in skill:
                    group_name = skill.split(":", 1)[0].strip()
                    if group_name == "gemPouch":
                        if pouch_mode == _g.POUCH_OFF:
                            continue  # off — pouches don't gate
                        if sid in pouch_free_sids:
                            continue  # Hollow Gems substitute on free stages
                        pouch_item = _g.pouch_for_stage(sid, pouch_mode)
                        if pouch_item is None:
                            continue
                        pouch_needed = _g.pouch_count_for_stage(sid, pouch_mode, start_sid)
                        if pouch_needed == 1:
                            wizlock_conditions.append(
                                lambda state, i=pouch_item: state.has(i, player))
                        else:
                            wizlock_conditions.append(
                                lambda state, i=pouch_item, n=pouch_needed:
                                    state.count(i, player) >= n)
                        continue
                else:
                    item_name = f"{skill} Skill"
                    wizlock_conditions.append(
                        lambda state, i=item_name: state.has(i, player))

        # ---- Wizard-stash key (always; cheap state.has / state.count) ----
        # Off mode short-circuits to `_always_true`.
        if sk_gran == _gating.STASH_OFF:
            key_check = _always_true
        else:
            key_name  = _gating.stash_key_for_stage(sid, sk_gran)
            key_count = _gating.stash_key_count_for_stage(sid, sk_gran, start_sid)
            if key_count == 1:
                key_check = lambda state, n=key_name: state.has(n, player)
            else:
                key_check = lambda state, n=key_name, c=key_count: \
                    state.count(n, player) >= c
        # Diagnostic label only added when GCFW_TIMING=1 (otherwise no-op).
        key_check_w = wrap_rule(f"stash_key:{sid}", key_check)

        # ---- DNF prereq closure (mixed cost) + _STAGE_CLEAR_RULES entry ----
        dnf_rule = None  # None means "no DNF gate" (start stage / free stage / empty reqs)
        if sid != start_sid:
            requirements = LEVEL_DATA[sid].get("requirements", [])
            token_name  = _gating.field_token_for_stage(sid, ft_gran)
            token_count = _gating.field_token_count_for_stage(sid, ft_gran, start_sid)
            if token_count == 1:
                token_check = lambda state, t=token_name: state.has(t, player)
            else:
                token_check = lambda state, t=token_name, n=token_count: \
                    state.count(t, player) >= n
            # Off mode short-circuits this to `_always_true`. Free stages
            # (whose pouch is covered by Hollow Gems for clearing purposes)
            # also short-circuit — see pouch_free_sids comment above.
            pouch_ok = (_always_true if sid in pouch_free_sids
                        else _compile_gempouch_checker(world, sid))
            # Skip the vanilla DNF for free stages — the starter group
            # is reachable from sphere 0 by definition, regardless of any
            # vanilla `Field_<sid>` chains pointing at stages outside the
            # group. Mirrors FieldLogicEvaluator._stageReachable's blanket
            # `_freeStages` short-circuit.
            #
            # Under progressive granularities the Field_<sid> chain is
            # artificial (token count IS the chain), but skill / counter
            # clauses inside the same AND-group are still real per-stage
            # prereqs (L5 → all four damage skills; P5 → Traps). Strip
            # only the Field_ entries and compile the rest.
            if requirements and sid not in free_sids:
                normalized = _normalize_requirements(requirements)
                if ft_progressive:
                    normalized = _strip_field_prereqs(normalized)
                dnf_rule = _compile_dnf(normalized, world, is_progressive=ft_progressive)
                if dnf_rule is _always_true:
                    _STAGE_CLEAR_RULES[(player, sid)] = (
                        lambda state, tc=token_check, p=pouch_ok:
                            tc(state) and p(state)
                    )
                else:
                    _STAGE_CLEAR_RULES[(player, sid)] = (
                        lambda state, tc=token_check, d=dnf_rule, p=pouch_ok:
                            tc(state) and p(state) and d(state)
                    )
            else:
                dnf_rule = None
                _STAGE_CLEAR_RULES[(player, sid)] = (
                    lambda state, tc=token_check, p=pouch_ok:
                        tc(state) and p(state)
                )

        # Skip dnf in the location rule when it's _always_true — it would be
        # a wasted call. Otherwise wrap with a label so the diag report still
        # attributes calls to the per-stage DNF.
        dnf_rule_w = (wrap_rule(f"stage:{sid}", dnf_rule)
                      if dnf_rule is not None and dnf_rule is not _always_true
                      else None)

        # ---- Compose final access_rule per location ----
        # Order: cheap state.has first, DNF last. Drop any None / always_true
        # components so we don't pay an extra call for nothing.
        journey_components = list(wizlock_conditions)
        if dnf_rule_w is not None:
            journey_components.append(dnf_rule_w)
        if journey_components:
            journey_loc.access_rule = _compose_and(journey_components)

        stash_components = list(wizlock_conditions)
        stash_components.append(key_check_w)
        if dnf_rule_w is not None:
            stash_components.append(dnf_rule_w)
        stash_loc.access_rule = _compose_and(stash_components)
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

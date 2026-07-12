from __future__ import annotations

from typing import TYPE_CHECKING

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


# State-signature + per-state counter cache.
# All scalar counters used by access rules (talisman row/column, field
# tokens, XP, shadow cores, SP, talisman fragments, talisman properties)
# memoise their result against `_gcfw_state_sig`. The signature changes
# whenever AP collects/removes any progression item, so cached values
# from a previous fill state are invalidated automatically.
import os as _os
# Verification escape hatch: GCFW_NO_VERSTAMP=1 forces the old O(#items)
# content signature, so a fixed seed can be generated both ways and diffed to
# prove the version stamp changes only speed, not logic.
_USE_VERSTAMP = _os.environ.get("GCFW_NO_VERSTAMP", "0") != "1"


def _gcfw_state_sig(state, player: int):
    # Fast path: an O(1) per-player version stamp maintained by the world's
    # collect/remove overrides (see GemcraftFrostbornWrathWorld.collect). It
    # bumps exactly when this player's prog_items change, so it's an exact
    # invalidation key — but WAY cheaper than re-summing hundreds of item
    # counts on every one of the ~20M cache accesses a fill does.
    ver = getattr(state, "_gcfw_ver", None) if _USE_VERSTAMP else None
    if ver is not None:
        return (player, ver.get(player, 0))
    # Fallback (state never went through our collect, e.g. a bare copy):
    # content signature — correct, just O(#items).
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
    # Cache key: the O(1) per-player version int on the fast path (bundles are
    # already keyed by player in `allc`, so the key only needs to track this
    # player's item-version, not player identity). Avoids allocating a sig
    # TUPLE on every one of the ~20M accesses a fill does. Fallback path keeps
    # the content tuple for bare copies.
    ver = getattr(state, "_gcfw_ver", None) if _USE_VERSTAMP else None
    key = ver.get(player, 0) if ver is not None else _gcfw_state_sig(state, player)
    # Per-PLAYER bundle. CollectionState is shared across ALL players in a
    # multiworld and fill sweeps interleave reachability checks between players,
    # so a single shared slot got evicted on every player switch — the cache
    # thrashed to uselessness exactly when players > 1. That made WL /
    # stage-clear / field-token / reach-any recompute on essentially every call
    # (the ~60k-call fill hot path) and blew up super-linearly with player count
    # (solo fine; a same-game multiworld took hours). Keying the bundle by player
    # keeps each player's cache alive across the interleave; the signature still
    # invalidates a player's bundle whenever that player's prog_items change, so
    # semantics are byte-for-byte identical — only the storage keying changed.
    allc = getattr(state, "_gcfw_caches", None)
    if allc is None:
        allc = {}
        state._gcfw_caches = allc
    bundle = allc.get(player)
    if bundle is None or bundle[0] != key:
        bundle = (key, {}, {}, {})
        allc[player] = bundle
    return bundle  # (key, counter_dict, clear_dict, or_dict)


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
    """Sum SP across all collected SP filler items.
    Each SP item (3 fixed bundle tiers + the single Skillpoint) contributes
    its fixed SP value (see items_skillpoints.SP_ITEMS). The pool may contain
    many copies of each."""
    cache = _get_counter_cache(state, player)
    val = cache.get("sp")
    if val is None:
        from .items_skillpoints import SP_ITEMS
        val = 0
        for name, _offset, value, _count in SP_ITEMS:
            if value > 0:
                val += value * state.count(name, player)
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


# Field-token floor layered on top of the talismanFragments counter gate so
# the achievement locations that test it don't open before the player has made
# enough world progress. talismanRow / talismanColumn intentionally carry NO
# such floor — any additional gate (minWave, fieldToken, min_wl, ...) belongs in
# the achievement's own requirements list, not bound to the metric.
# count_needed -> minimum effectively-unlocked stages required.
_TALISMAN_FRAGMENTS_TOKEN_FLOOR: dict[int, int] = {25: 75}


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
_STUB_ELEMENTS: frozenset = frozenset({"Wall", "Tower"})


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
    cache = _get_counter_cache(state, player)
    val = cache.get("stash_reach")
    if val is not None:
        return val
    res = False
    sid_to_key = _get_world_stash_key_map(state, player)
    if sid_to_key is None:
        for s in GAME_DATA["stages"]:
            try:
                if state.can_reach(f"Complete {s['str_id']} - Journey", "Location", player):
                    res = True
                    break
            except KeyError:
                continue
    else:
        for sid, (key_name, key_count) in sid_to_key.items():
            if key_count == 1:
                if not state.has(key_name, player):
                    continue
            elif state.count(key_name, player) < key_count:
                continue
            try:
                if state.can_reach(f"Complete {sid} - Journey", "Location", player):
                    res = True
                    break
            except KeyError:
                continue
    cache["stash_reach"] = res
    return res


# Ritual Battle Trait grants an unconditional 2-Apparition scripted spawn
# in IngameInitializer.as:1612-1653, gated only on `waves.length > 3`.
# See _compile_element_or_full + the mod's
# patch/RitualSpawnPatcher.as for the matching runtime behavior.
_RITUAL_TRAIT_ITEM: str = "Ritual Battle Trait"
_RITUAL_MIN_WAVES: int  = 4
# Ritual pushes exactly this many apparitions (IngameInitializer.as:1649 —
# a hardcoded `for i < 2` loop, independent of the trait's creature-count
# value) on any stage with waves > 3. So an `eApparition:N` count token for
# N <= this is satisfiable by Ritual alone on any reachable waves>=4 stage,
# the same broadening the count-less `eApparition` path already applies.
_RITUAL_APPARITION_SPAWN_COUNT: int = 2
# Stages long enough for the Ritual scripted-spawn block to fire
# (IngameInitializer.as:1612 gates on waves.length > 3).
_RITUAL_STAGES: frozenset = frozenset(
    sid for sid, d in LEVEL_DATA.items()
    if int(d.get("WaveCount", 0)) >= _RITUAL_MIN_WAVES
)


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

    Prismatic-class achievements need N distinct gem colors to coexist on one
    stage. The stage's `AvailableGems` list IS the gem-pouch capacity, so the
    per-stage count is bounded by `|stage_gems|` — held skills let the player
    respawn colors but never grow the pouch. A stage only credits its
    `stage_gems` if (a) it's beatable in logic AND (b) the player owns its
    STRICT gempouch — Hollow Gems substitute for clearing free stages but do
    NOT grant real gem types (see _compile_gem_broadened). Unreachable or
    pouch-less stages contribute 0."""
    cache = _get_counter_cache(state, player)
    val = cache.get("gsp")
    if val is not None:
        return val
    held = set()
    for token, gem_name in _GEM_TOKEN_TO_GEM_NAME.items():
        if state.has(item_prefix_map[token], player):
            held.add(gem_name)
    world = state.multiworld.worlds[player]
    strict_pouch = getattr(world, "_strict_pouch_checkers", None)
    if strict_pouch is None:
        strict_pouch = {sid: _compile_gempouch_checker(world, sid)
                        for sid in _GEMS_BY_STAGE}
        world._strict_pouch_checkers = strict_pouch
    max_n = 0
    for sid, stage_gems in _GEMS_BY_STAGE.items():
        if not _can_clear_stage_cached(state, player, sid):
            continue
        if not strict_pouch[sid](state):
            continue
        n = min(len(stage_gems), len(held | stage_gems))
        if n > max_n:
            max_n = n
            if max_n == 6:
                break
    cache["gsp"] = max_n
    return max_n


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
# IMPORTANT: if the region graph gains *gated* connections (e.g. region
# A reachable only after item X), this short-circuit misses that gate unless
# the gate is ALSO composed into the rule here. The wizard-level SOFT gate is
# such a connection: it's composed onto stage entrances in set_rules AND folded
# into these rules right after (see the `_STAGE_CLEAR_RULES[(player, _sid)]`
# rewrap in the WL loop), so this direct call stays in parity with can_reach.
# Any future region-level gate must do the same.
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


# ---------------------------------------------------------------------------
# Pre-compiled requirement closures.
#
# An interpreted token-dispatch ladder (string startswith / dict-membership /
# split / int-parse / and N more dict checks) would run on every state
# evaluation just to figure out *what kind* of token the string is. With ~2M
# rule calls per generation, that dispatch would dominate fill time.
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


def _compile_can_create_any_gem(world):
    """Compile a checker: True iff the player can field real (non-hollow)
    gems on some in-logic stage — i.e. owns the gempouch for a clearable
    stage (or pouch gating is off, in which case any clearable stage works).

    Owning a gem-component skill (sManaLeech, sPoison, ...) is useless on its
    own: without a pouch to create real gems on a reachable field, the player
    only has the free Hollow Gem, which carries no components. So the
    gem-skill broadening AND-gates the skill branch against this check. The
    pouch test is cheap (`state.has`) and runs before the cached clear test,
    so the no-pouch case stays inexpensive even though it scans every stage.
    """
    player = world.player
    pairs = [(sid, _compile_gempouch_checker(world, sid)) for sid in LEVEL_DATA]
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
    # Apparition gets the same Ritual-trait broadening as in
    # `_eval_element_reachable`: any reachable stage long enough for
    # the Ritual scripted-spawn block to fire (waves > 3) satisfies it
    # whenever Ritual is owned. Other Ritual creatures stay strict
    # pre-placed — see the comment in `_eval_element_reachable`.
    has_apparition = "Apparition" in elem_names
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

    # Stage set used by the Apparition+Ritual state-dependent path
    # (IngameInitializer.as:1612 gates the Ritual block on waves.length > 3).
    ritual_stages = _RITUAL_STAGES if has_apparition else None

    # Specialise common shapes.
    if len(members) == 1 and not has_apparition:
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
        if has_apparition \
                and state.has(_RITUAL_TRAIT_ITEM, player) \
                and _can_reach_any_stage(state, player, ritual_stages):
            return True
        return False

    # Apparition's broadening is state-dependent (Ritual-trait ownership),
    # so static_set has to be None — AND-group stage-binding can't tighten
    # on a state-dependent member. Same convention as STASH.
    if has_stash or has_apparition:
        return _multi, None
    union = set()
    for _kind, stages in members:
        union.update(stages)
    return _multi, frozenset(union)


def _compile_req(req: str, world, is_progressive: bool):
    """Compile a single requirement string to `((state) -> bool, cost, static_set)`.

    The returned closure binds all per-call constants (item names, qualifying stage lists,
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
        if req in _GEM_TOKEN_TO_GEM_NAME:
            gem_name = _GEM_TOKEN_TO_GEM_NAME[req]
            broaden = _compile_gem_broadened(world, gem_name)
            can_create = _compile_can_create_any_gem(world)
            def _gem_token(state, n=item_name, b=broaden, c=can_create):
                # The skill grants the gem its component, but the player can
                # only act on it if they can create a real gem somewhere —
                # a clearable stage whose gempouch they own. Owning the skill
                # with no pouch on any reachable field leaves only the free
                # Hollow Gem, which has no components. `b` covers the no-skill
                # case where a stage's starter pouch already lists this gem.
                if state.has(n, player) and c(state):
                    return True
                return b(state)
            return (_gem_token, _COST_REACH, None)
        return (lambda state, n=item_name: state.has(n, player), _COST_HAS, None)

    if req in element_prefix_map:
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
            # Canonical PascalCase comes from the display name in element_prefix_map when present.
            # Stripping just the "e" prefix would mis-pluralise building elements: eAmplifiers / eLanterns / ePylons / eTraps map to singular display names ("Amplifier" etc.) whose LEVEL_DATA fields are also singular ("AmplifierCount"). The plural "AmplifiersCount" doesn't exist, so the gate falls through to `_always_true`.
            if group_name in element_prefix_map:
                elem_pascal = _element_count_field(
                    element_prefix_map[group_name][0]
                )[:-len("Count")]
            else:
                elem_pascal = group_name[1:]
            if elem_pascal == "WizardStash":
                # Every stage has a wizard stash, so `WizardStashCount` isn't a tracked per-stage field — `_qualifying_stages_for_element` would return None and fall through to `_always_true`, letting `eWizardStash:N` pass with zero keys held.
                # Mirror `_eval_element_count`'s special-case: route the count-≤1 form through `_any_stash_reachable`, and the count-N form through a per-seed key + journey-reachability check.
                if count_needed <= 1:
                    return (lambda state: _any_stash_reachable(state, player),
                            _COST_REACH, None)
                from . import gating as _g
                sk_gran = world.options.stash_key_granularity.value
                all_sids = tuple(s["str_id"] for s in GAME_DATA["stages"])
                if sk_gran == _g.STASH_OFF:
                    def _stash_count_no_keys(state, sids=all_sids, n_needed=count_needed):
                        n = 0
                        for sid in sids:
                            try:
                                if state.can_reach(f"Complete {sid} - Journey",
                                                   "Location", player):
                                    n += 1
                                    if n >= n_needed:
                                        return True
                            except KeyError:
                                continue
                        return False
                    return (_stash_count_no_keys, _COST_REACH, None)
                starter_sid = world.start_sid
                stash_specs = tuple(
                    (sid,
                     _g.stash_key_for_stage(sid, sk_gran),
                     _g.stash_key_count_for_stage(sid, sk_gran, starter_sid))
                    for sid in all_sids
                )
                def _stash_count_keyed(state, specs=stash_specs, n_needed=count_needed):
                    n = 0
                    for sid, key_name, key_count in specs:
                        if key_count == 1:
                            if not state.has(key_name, player):
                                continue
                        elif state.count(key_name, player) < key_count:
                            continue
                        try:
                            if state.can_reach(f"Complete {sid} - Journey",
                                               "Location", player):
                                n += 1
                                if n >= n_needed:
                                    return True
                        except KeyError:
                            continue
                    return False
                return (_stash_count_keyed, _COST_REACH, None)
            stages = _qualifying_stages_for_element(elem_pascal, count_needed)
            if stages is None:
                return (_always_true, _COST_CONST, None)
            stages_fs = frozenset(stages)
            interact_skill = _ELEMENT_PASCAL_INTERACT_SKILL.get(elem_pascal)
            if interact_skill is not None:
                return (lambda state, n=interact_skill, s=stages: (
                    state.has(n, player) and _can_reach_any_stage(state, player, s)
                ), _COST_REACH, stages_fs)
            # Apparition count within the Ritual scripted-spawn count is
            # satisfiable by Ritual alone on any reachable waves>=4 stage —
            # the same broadening `_compile_element_or_full` applies to the
            # count-less `eApparition`. State-dependent (Ritual ownership), so
            # static_set must be None: it can't bind to a fixed stage set.
            if (elem_pascal == "Apparition"
                    and count_needed <= _RITUAL_APPARITION_SPAWN_COUNT):
                return (lambda state, s=stages: (
                    _can_reach_any_stage(state, player, s)
                    or (state.has(_RITUAL_TRAIT_ITEM, player)
                        and _can_reach_any_stage(state, player, _RITUAL_STAGES))
                ), _COST_REACH, None)
            return (lambda state: _can_reach_any_stage(state, player, stages),
                    _COST_REACH, stages_fs)

        if group_name in skill_counter_pools:
            if group_name in ("gemSkills", "GemSkills"):
                # Pouch-capacity-bounded per-stage count: a stage hosts
                # `gemSkills:N` only if it's beatable in logic AND
                # `min(|stage_gems|, |held ∪ stage_gems|) >= N`. Held skills
                # let the player respawn colors but never enlarge the pouch,
                # so an unreachable 6-gem stage (e.g. P6) does NOT credit
                # `gemSkills:6` even when all 6 gem-skill items are owned.
                def _gemskills_count_check(state, k=count_needed):
                    return _count_gem_skills_per_stage_max(state, player) >= k
                return (_gemskills_count_check, _COST_REACH, None)
            pool = tuple(skill_counter_pools[group_name])
            return (lambda state: sum(1 for n in pool if state.has(n, player)) >= count_needed,
                    _COST_COUNTER, None)

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
            # Stages in logic, not tokens held (full clearability).
            return (lambda state: _count_clearable_stages(state, player) >= count_needed,
                    _COST_REACH, None)
        if group_name == "talismanRow":
            return (lambda state: _count_complete_talisman_rows(state, player) >= count_needed,
                    _COST_COUNTER, None)
        if group_name == "talismanColumn":
            return (lambda state: _count_complete_talisman_columns(state, player) >= count_needed,
                    _COST_COUNTER, None)
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


# Phase 5 — achievement progression-by-exception. When True, each included
# achievement is additionally gated on the SKILL/TRAIT tokens in its
# requirements (sFreeze, tRitual, skills:N, gemSkills:N, ...), so those skills
# and traits become genuinely required progression (justifying their
# `progression` class). Element / stat-counter / mode / Field_ / Achievement:
# tokens are deliberately IGNORED here — the WL gate and in-game play handle
# them — keeping the added constraint minimal.
#
# WARNING (see feedback_fill_errors): `skills:24` (Skillful) becomes an
# all-24-skills gate on that one location; if fill can't route all skills before
# it, generation FillErrors. Two switches so you can bisect:
#   ENABLE_ACH_SKILL_TRAIT_GATE   — master; False = WL-only achievement gating.
#   GATE_ALL_SKILLS_ACHIEVEMENT   — False skips "need the ENTIRE pool" counters
#                                   (Skillful's skills:24) while keeping every
#                                   other, easily-satisfiable skill/trait gate.
# At default (Trivial) effort the ONLY whole-pool gate is Skillful; the other
# ~124 gated achievements are single skills/traits or small-pool counters.
ENABLE_ACH_SKILL_TRAIT_GATE = True
GATE_ALL_SKILLS_ACHIEVEMENT  = True

# Whole-pool achievements that may NOT hold progression items. Their in-game
# condition demands an entire item pool at once (Skillful = all 24 skills;
# Peek Into The Abyss = 12 battle traits), so a progression item placed here
# would be walled behind that whole pool — the one real FillError source (see
# feedback_fill_errors). They REMAIN Archipelago checks (still gated + reachable
# once the pool is collected) but fill may only drop useful/filler here.
# The ~124 single/double-skill achievements are intentionally NOT listed — a
# progression item behind one or two skills is a trivial ordering for fill.
_NO_PROGRESSION_ACHIEVEMENTS = frozenset({
    "Skillful",             # skills:24
    "Peek Into The Abyss",  # battleTraits:12
})


# Bounded AP-item pools a counter token can demand (near-)fully. Gating a
# location on collecting most/all of one of these is the classic FillError
# shape — the item placed there is walled behind that whole pool — so such
# achievements are forced filler-only (see _ach_progression_blocked). The
# talisman-set counters matter especially: the full-requirement DNF gate now
# hard-enforces them (the old skill/trait-only gate did not), so without this
# they would silently become progression-eligible whole-pool gates. Values are
# pool maxima; only the FRACTION is used.
_DEADLOCK_COUNTER_POOLS = {
    "skills": 24, "Skills": 24,
    "otherSkills": 18, "OtherSkills": 18,
    "gemSkills": 6, "GemSkills": 6,
    "strikeSpells": 3, "enhancementSpells": 3,
    "battleTraits": 15, "BattleTraits": 15,
    "talismanFragments": 25,
    "talismanRow": 3, "talismanColumn": 3,
    "talismanCornerFragment": 4, "talismanEdgeFragment": 12,
    "talismanCenterFragment": 9,
}
_DEADLOCK_POOL_FRACTION = 0.6  # >= 60% of a pool in a branch => deadlock-prone


def _branch_has_wholepool_counter(group) -> bool:
    """True if an AND-group requires >= _DEADLOCK_POOL_FRACTION of any bounded
    AP-item pool in _DEADLOCK_COUNTER_POOLS."""
    for tok in group:
        if not isinstance(tok, str) or ":" not in tok:
            continue
        head, _, cnt = tok.partition(":")
        pool = _DEADLOCK_COUNTER_POOLS.get(head.strip())
        if pool is None:
            continue
        try:
            n = int(cnt.strip())
        except ValueError:
            continue
        if n >= max(2, _DEADLOCK_POOL_FRACTION * pool):
            return True
    return False


def _ach_progression_blocked(requirements) -> bool:
    """An achievement may NOT hold progression when EVERY OR-branch is gated on
    a large fraction of a bounded AP-item pool — otherwise a progression item
    could be walled behind most/all of that pool (the one real FillError source,
    see feedback_fill_errors). Generalises the hand-listed
    _NO_PROGRESSION_ACHIEVEMENTS and auto-covers the talisman-set counters that
    the DNF achievement gate newly hard-enforces."""
    if not requirements:
        return False
    groups = requirements if isinstance(requirements[0], list) else [requirements]
    return bool(groups) and all(_branch_has_wholepool_counter(g) for g in groups)


def _extract_min_wl(requirements):
    """Return the per-achievement WL floor from a `min_wl:N` token in
    `requirements`, or None if absent. Scans both flat (`["a", "b"]`) and DNF
    (`[["a", "b"], ...]`) shapes — the token is treated as a top-level pacing
    override, so the largest N found wins regardless of which OR-group it sits
    in. Overrides the effort-tier default (ACH_MIN_WL[effort]) in set_rules."""
    if not requirements:
        return None
    groups = requirements if isinstance(requirements[0], list) else [requirements]
    best = None
    for group in groups:
        for tok in group:
            if not isinstance(tok, str):
                continue
            head, _, cnt = tok.strip().partition(":")
            if head.strip() != "min_wl":
                continue
            try:
                n = int(cnt.strip())
            except ValueError:
                continue
            if best is None or n > best:
                best = n
    return best


def _compile_skill_trait_gate(requirements, player):
    """(state)->bool gating on ONLY the skill/trait tokens in `requirements`
    (DNF: OR of AND-groups). Returns None when there are no such tokens, so the
    caller adds no extra gate. Non-skill/trait tokens are treated as satisfied."""
    from .requirement_tokens import (
        skill_prefix_map, trait_prefix_map, skill_counter_pools,
    )
    if not requirements:
        return None
    groups = requirements if isinstance(requirements[0], list) else [requirements]
    any_token = False
    group_fns = []
    for group in groups:
        conds = []
        for tok in group:
            if not isinstance(tok, str):
                continue
            t = tok.strip()
            if t in skill_prefix_map:
                conds.append(lambda s, i=skill_prefix_map[t]: s.has(i, player))
                any_token = True
            elif t in trait_prefix_map:
                conds.append(lambda s, i=trait_prefix_map[t]: s.has(i, player))
                any_token = True
            elif ":" in t:
                head, _, cnt = t.partition(":")
                head = head.strip()
                if head in skill_counter_pools:
                    try:
                        need = int(cnt.strip())
                    except ValueError:
                        need = 1
                    pool = tuple(skill_counter_pools[head])
                    # Whole-pool gate (e.g. skills:24) is the FillError risk —
                    # skip it when GATE_ALL_SKILLS_ACHIEVEMENT is off.
                    if need >= len(pool) and not GATE_ALL_SKILLS_ACHIEVEMENT:
                        continue
                    conds.append(
                        lambda s, p=pool, n=need:
                            sum(1 for it in p if s.has(it, player)) >= n)
                    any_token = True
        # A group with no skill/trait tokens is freely satisfiable through that
        # OR-branch, so the achievement isn't skill/trait-gated at all.
        group_fns.append(_compose_and(conds) if conds else _always_true)
    if not any_token:
        return None
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

    # === WIZARD-LEVEL SOFT GATE (orthogonal to the field-token hard gate) ===
    # Field access has two independent gates:
    #   HARD: the field token (+ WIZLOCK skills / gem pouch / stash key / DNF
    #         prereqs) built into the stage rules above — what you must COLLECT.
    #   SOFT: wizard level — wl(state) >= gate[sid] — derived from cleared fields.
    # We COMPOSE the WL gate ONTO the existing hard-gate rules (we do NOT replace
    # them). A stage is in logic iff its token/WIZLOCK/prereq rules pass AND
    # wl(state) >= gate[sid]. Clearing a stage grants its difficulty-scaled XP via
    # the "Beat <sid>" event; wl(state) is the curve of total beaten XP, so
    # clearing what you can raises WL and opens more stages.
    # The 4 XP-scaling traits (Haste/Overcrowd/Ritual/Dark Masonry) multiply the
    # summed XP by up to 1.2^(count held) — RETROACTIVELY over all cleared fields —
    # so collecting one is a WL power spike, but each trait only counts once the
    # harness gate (XP_TRAIT_MIN_WL, greedy step-up) is met. Inlined here for fill
    # speed but must equal difficulty_gates.derived_wl / effective_trait_wl
    # bit-for-bit (validated by the vectors in wl_test_vectors.json).
    from . import difficulty_gates as _dg
    _diff = _dg.DIFFICULTIES[world.options.difficulty.value]
    _eff = _dg.EFF_XP[_diff]
    _xp_items = [(f"{s} Cleared", x) for s, x in _eff.items() if x]
    _xp_trait_names = _dg.XP_TRAIT_ITEM_NAMES

    def _wl_of(state, _items=_xp_items, _tn=_xp_trait_names,
               _eff_wl=_dg.effective_trait_wl, _p=player):
        # Memoise on the state signature: WL is a pure function of the collected
        # "<sid> Cleared" events + XP traits (all progression), so it only needs
        # recomputing when prog_items change. Without this the full XP sum +
        # curve is redone on every WL gate check — the fill hot path (~60k calls).
        cache = _get_counter_cache(state, _p)
        v = cache.get("wl")
        if v is not None:
            return v
        base = 0
        for _name, _x in _items:
            if state.has(_name, _p):
                base += _x
        n = 0
        for _t in _tn:
            if state.has(_t, _p):
                n += 1
        v = _eff_wl(base, n)
        cache["wl"] = v
        return v

    def _wl_rule(sid):
        # The starter GROUP is always reachable: the start stage AND its
        # immediately-playable tile/tier mates (free_sids, tokens precollected).
        # Exempting the whole group from the WL soft gate matches "play the
        # starter tile right away" and keeps parity with the shipped stage_gates
        # (fill_slot_data ships gate 0 for exactly this set).
        if sid == start_sid or sid in free_sids:
            return _always_true
        g = int(_dg.GATE.get(sid, 0))
        if g <= 0:
            return _always_true
        return lambda state, _g=g: _wl_of(state) >= _g

    for _stage in stages:
        _sid = _stage["str_id"]
        _wl = _wl_rule(_sid)
        # Compose the WL soft gate onto the stage-entry connection(s), which
        # already carry the field-token hard gate. Region reachability then
        # enforces token AND WL for every location in the stage. Skip the
        # compose when the stage has no WL gate (start stage / gate 0) so we
        # don't pay an extra always-true call.
        if _wl is not _always_true:
            for _ent in multiworld.get_region(_sid, player).entrances:
                _ent.access_rule = _compose_and([_ent.access_rule, _wl])
            # Also compose the WL gate into the direct-call clearability rule.
            # `_can_clear_stage_cached` calls _STAGE_CLEAR_RULES[sid] DIRECTLY
            # (bypassing can_reach for speed), so the entrance WL gate above is
            # invisible to it — and it backs the achievement requirement checks
            # (_can_reach_any_stage) and Field_<sid> prereqs. Without this a
            # token-unlocked but WL-locked stage (e.g. R2 held-token at WL 11,
            # gate 13) reads as clearable, so its gem/monster-gated achievements
            # (sPoison / sBleeding / minMonsters:400) show in logic while every
            # R2 stage location correctly stays out. This is exactly the region-
            # gate divergence the _STAGE_CLEAR_RULES comment warns about, and it
            # restores parity with the mod's isStageInLogic (soft gate applied).
            _clear = _STAGE_CLEAR_RULES.get((player, _sid))
            if _clear is not None:
                _STAGE_CLEAR_RULES[(player, _sid)] = (
                    lambda state, r=_clear, w=_wl: r(state) and w(state)
                )
            else:
                _STAGE_CLEAR_RULES[(player, _sid)] = _wl
        # The "Clear <sid>" XP event fires on CLEAR, so it mirrors the Journey
        # location's clearability rule (WIZLOCK skills + pouch + DNF prereqs);
        # region reachability already supplies token + WL. Without this the
        # event would be collectable on mere reach, over-estimating WL.
        try:
            _journey = multiworld.get_location(f"Complete {_sid} - Journey", player)
            _beat = multiworld.get_location(f"Clear {_sid}", player)
            _beat.access_rule = _journey.access_rule
        except KeyError:
            pass

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
        # kill_swarm_queen: Requires completing K4 - Journey (tier 4)
        req = goal_requirements["kill_swarm_queen"]
        k4_journey_loc = "Complete K4 - Journey"
        victory_location = multiworld.get_location("Kill Swarm Queen Victory", player)
        victory_location.access_rule = lambda state, loc=k4_journey_loc: state.can_reach(loc, "Location", player)

    elif goal_value == 2:
        # fields_count: Complete N specific stages (configurable)
        req = goal_requirements["fields_count"]
        required = world.options.fields_required.value
        journey_locs = [f"Complete {s['str_id']} - Journey" for s in stages]
        victory_location = multiworld.get_location("Fields Count Victory", player)
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

                # Two gates, composed (AND):
                #   SOFT (WL floor): derived WL >= the achievement's floor —
                #         paces WHEN the achievement is expected. A per-
                #         achievement `min_wl:N` token OVERRIDES the effort-tier
                #         default (ACH_MIN_WL[effort]); otherwise the tier
                #         default applies. `min_wl:N` compiles to _always_true
                #         inside the DNF below, so it's enforced only here.
                #   HARD (full requirement DNF): the SAME `_compile_dnf` used
                #         for stage-clear rules — elements (with same-stage
                #         binding), gemSkills:N / monster-stat counters,
                #         skills, traits, and Field_ clearability. This mirrors
                #         the mod's LogicEvaluator.evaluateRequirements so a
                #         progression item is only placed where the achievement
                #         is actually earnable in-game. is_progressive stays
                #         False (see above) so cross-achievement `Achievement:`
                #         tokens are ignored, matching the mod's don't-block
                #         behaviour for those.
                _components = []
                _reqs = ach_data.get("requirements", [])
                _wl_override = _extract_min_wl(_reqs)
                _min_wl = (_wl_override if _wl_override is not None
                           else int(_dg.ACH_MIN_WL.get(ach_effort, 0)))
                if _min_wl > 0:
                    _components.append(lambda state, _m=_min_wl: _wl_of(state) >= _m)
                if _reqs:
                    _dnf = _compile_dnf(_normalize_requirements(_reqs), world,
                                        is_progressive=is_progressive)
                    if _dnf is not _always_true:
                        _components.append(_dnf)
                if _components:
                    location.access_rule = _compose_and(_components)
                    _ach_rules_added += 1

                # Achievements are filler-quality and reachable across the
                # spectrum. Exclude edge/corner talismans so they end up at
                # higher-tier stage locations (where the player has cores).
                _restrict_talisman_shapes(location, True, True)

                # Whole-pool achievements may only hold useful/filler — never
                # progression — so no critical item is ever walled behind an
                # entire item pool. Covers the hand-listed cases (Skillful,
                # Peek Into The Abyss) plus any achievement whose every branch
                # is gated on a large fraction of a bounded AP-item pool
                # (talisman-set / whole-skill counters). Composes with the
                # talisman shape rule set just above.
                if (ach_name in _NO_PROGRESSION_ACHIEVEMENTS
                        or _ach_progression_blocked(_reqs)):
                    prev_rule = location.item_rule
                    location.item_rule = (
                        lambda item, p=prev_rule:
                            (not item.advancement) and p(item)
                    )

            except Exception:
                pass

    except Exception as e:
        print(f"ERROR setting achievement access rules: {e}")
        import traceback
        traceback.print_exc()
    _tlog(f"  set_rules: achievement rules ({_ach_rules_added} gated): {(_t.perf_counter()-_t_ach)*1000:.1f} ms")

    multiworld.completion_condition[player] = lambda state: state.has("Victory", player)

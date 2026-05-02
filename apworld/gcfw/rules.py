from __future__ import annotations

from typing import TYPE_CHECKING, List

from .rulesdata import GAME_DATA, STAGE_RULES, TIERS, GEM_POUCH_PLAY_ORDER
from .rulesdata_settings import skill_groups
from .requirement_tokens import (
    item_prefix_map, element_prefix_map,
    mode_tokens, level_stat_counters, skill_counter_pools,
)
from .rulesdata_goals import goal_requirements
from .rulesdata_levels import level_requirements as LEVEL_DATA
from .options import AchievementProgression
from .talismans import (
    EDGE_TALISMAN_NAMES,
    CORNER_TALISMAN_NAMES,
    PROGRESSION_CORNER_TALISMAN_NAMES,
    PROGRESSION_EDGE_TALISMAN_NAMES,
    PROGRESSION_ALL_TALISMAN_NAMES,
    MATCHING_TALISMAN_NAMES,
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
    return sum(1 for n in XP_ITEM_NAMES if state.has(n, player))


def _sum_shadow_cores(state, player: int) -> int:
    """Sum of core amounts for held shadow-core stash items.  Only items
    classified as progression count — others don't enter state.prog_items."""
    return sum(amt for name, amt in SHADOW_CORE_AMOUNT_BY_NAME.items()
               if state.has(name, player))


def _count_complete_talisman_rows(state, player: int) -> int:
    """Count complete rows of the matching 3x3 grid the player owns.

    A row = all 3 fragments of one icon group. With 9 progression fragments
    split into 3 fixed icon groups (see talismans.MATCHING_TALISMAN_ROWS),
    the player can have 0..3 complete rows.
    """
    from .talismans import MATCHING_TALISMAN_ROWS
    return sum(
        1 for row in MATCHING_TALISMAN_ROWS
        if all(state.has(n, player) for n in row)
    )


def _count_complete_talisman_columns(state, player: int) -> int:
    """Count complete columns of the matching 3x3 grid the player owns.

    A column = one specific fragment from each icon group (positions
    {1,4,7}, {2,5,8}, or {3,6,9}). See talismans.MATCHING_TALISMAN_COLUMNS.
    """
    from .talismans import MATCHING_TALISMAN_COLUMNS
    return sum(
        1 for col in MATCHING_TALISMAN_COLUMNS
        if all(state.has(n, player) for n in col)
    )


def _count_skill_points(state, player: int) -> int:
    """Sum SP across all collected Skillpoint Bundle items.
    Each 'Skillpoint Bundle N' contributes N skill points; the pool may
    contain multiple copies of the same bundle size."""
    total = 0
    for size in range(1, 11):
        total += size * state.count(f"Skillpoint Bundle {size}", player)
    return total


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


def _count_talisman_fragments(state, player: int, names) -> int:
    return sum(1 for n in names if state.has(n, player))


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
    contribs = _TALISMAN_PROPERTY_CONTRIBUTIONS.get(prop_id, {})
    return sum(v for name, v in contribs.items() if state.has(name, player))


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
    """Per-world map of sid -> stash-key item name, granularity-aware.
    Built once and cached on the world instance."""
    world = state.multiworld.worlds[player]
    cached = getattr(world, "_sid_to_stash_key", None)
    if cached is None:
        from . import gating as _g
        sk_gran = world.options.stash_key_granularity.value
        cached = {
            s["str_id"]: _g.stash_key_for_stage(s["str_id"], sk_gran)
            for s in GAME_DATA["stages"]
        }
        world._sid_to_stash_key = cached
    return cached


def _get_world_field_token_map(state, player: int) -> dict:
    """Per-world map of sid -> field-token item name, granularity-aware.
    Built once and cached on the world instance."""
    world = state.multiworld.worlds[player]
    cached = getattr(world, "_sid_to_field_token", None)
    if cached is None:
        from . import gating as _g
        ft_gran = world.options.field_token_granularity.value
        cached = {
            s["str_id"]: _g.field_token_for_stage(s["str_id"], ft_gran)
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
    for sid, key_name in sid_to_key.items():
        if not state.has(key_name, player):
            continue
        try:
            if state.can_reach(f"Complete {sid} - Journey", "Location", player):
                return True
        except KeyError:
            continue
    return False


def _eval_element_reachable(elem_name: str, state, player: int) -> bool:
    """Resolve element-presence reachability — equivalent to eX:1."""
    if elem_name == "Wizard Stash":
        # Every stage structurally has a stash, but each is locked until
        # the player collects its per-stage key AND can clear the stage.
        return _any_stash_reachable(state, player)
    return _eval_element_count(_element_count_field(elem_name)[:-len("Count")], 1, state, player)


# Gem-skill broadening: a bare `sX` gem-skill token (and the `gemSkills:N`
# counter) passes if the player owns the AP skill item OR can reach a stage
# whose starter pouch lists the matching gem.  Per-stage starter pouches
# come from `available_gems` in game_data.json (mirrored to the mod as
# `availableGems` in logic.json).  strikeSpells / enhancementSpells / other
# skill counters stay strict-item-count.
_GEM_TOKEN_TO_GEM_NAME: dict = {
    "sBleeding":     "Bleed",
    "sCriticalHit":  "Crit",
    "sManaLeech":    "Leech",
    "sArmorTearing": "Armor Tear",
    "sPoison":       "Poison",
    "sSlowing":      "Slow",
}

# Gem name -> stage str_ids whose `available_gems` lists that gem.
_STAGES_BY_GEM: dict = {}
for _stage in GAME_DATA.get("stages", []):
    for _gem in _stage.get("available_gems", []):
        _STAGES_BY_GEM.setdefault(_gem, []).append(_stage["str_id"])
if "_stage" in dir():
    del _stage
if "_gem" in dir():
    del _gem


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


def _eval_element_count(elem_pascal: str, count_needed: int, state, player: int) -> bool:
    """Resolve eX:N form: a reachable stage exists where <X>Count >= N.
    If the element isn't tracked per-stage (no <X>Count field anywhere in
    LEVEL_DATA), treat it as universally present (Tower / Wall / Marked
    Monster fall here)."""
    field = elem_pascal + "Count"
    if field not in _PRESENT_COUNT_FIELDS:
        return True
    qualifying = [sid for sid, d in LEVEL_DATA.items() if d.get(field, 0) >= count_needed]
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
    items = state.prog_items.get(player)
    sig = (player, len(items), sum(items.values())) if items else (player, 0, 0)
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
    items = state.prog_items.get(player)
    if items is None:
        sig = (player, 0, 0)
    else:
        sig = (player, len(items), sum(items.values()))

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
        # the matching starter gem is reachable.
        if req in _GEM_TOKEN_TO_GEM_NAME:
            return _has_gem_token(req, state, player)
        return state.has(item_prefix_map[req], player)
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
                return _count_gem_skills_broadened(state, player) >= count_needed
            pool = skill_counter_pools[group_name]
            return sum(1 for name in pool if state.has(name, player)) >= count_needed

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
            return _count_talisman_fragments(
                state, player, _TALISMAN_FRAGMENT_COUNTERS[group_name],
            ) >= count_needed

        # Talisman-property contribution gates: tm<Foo>:N — sum the property
        # values of held progression fragments at max upgrade and compare to N.
        if group_name in _TALISMAN_PROPERTY_TOKENS:
            return _sum_talisman_property(
                _TALISMAN_PROPERTY_TOKENS[group_name], state, player,
            ) >= count_needed

        # Other item-collection counters — each counts a different pool.
        if group_name == "fieldToken":
            # Counts stages effectively unlocked. At per_stage granularity,
            # this is one-token-per-stage. At per_tile/per_tier, holding a
            # single coarse token unlocks multiple stages, so each unlocked
            # stage is counted (via the per-world sid->token map).
            sid_to_tok = _get_world_field_token_map(state, player)
            collected = sum(1 for tok in sid_to_tok.values() if state.has(tok, player))
            return collected >= count_needed
        if group_name == "shadowCore":
            # Sum core amounts of held progression shadow-core stash items.
            # Half of stashes are progression (see items.py _sc_cls); useful/
            # filler stashes are invisible to state.has and contribute 0.
            return _sum_shadow_cores(state, player) >= count_needed
        if group_name == "wizardLevel":
            # Half of XP items are progression; player needs ceil(N/2) of
            # those collected before the wizardLevel:N gate opens.  Max
            # reachable N at default settings: 40 (20 progression XP items).
            needed_items = (count_needed + 1) // 2
            return _count_xp_items(state, player) >= needed_items
        if group_name == "talismanRow":
            return _count_complete_talisman_rows(state, player) >= count_needed
        if group_name == "talismanColumn":
            return _count_complete_talisman_columns(state, player) >= count_needed
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
    the given stage. Granularity-aware:
        off                  → always True (no gating)
        per_tile_distinct    → state.has("Gempouch (<prefix>)")
        per_tile_progressive → state.count("Progressive Gempouch") >= idx+1
        per_tier             → state.has("Tier <N> Gempouch") for stage's tier
        global               → state.has("Master Gempouch")
    """
    mode = world.options.gem_pouch_granularity.value
    if mode == 0:
        return _always_true
    player = world.player
    prefix = sid[0]
    if mode == 1:  # per_tile_distinct
        item_name = f"Gempouch ({prefix})"
        return lambda state: state.has(item_name, player)
    if mode == 2:  # per_tile_progressive
        try:
            idx = GEM_POUCH_PLAY_ORDER.index(prefix)
        except ValueError:
            return _always_true
        needed = idx + 1
        return lambda state: state.count("Progressive Gempouch", player) >= needed
    if mode == 3:  # per_tier
        tier = STAGE_RULES[sid].tier
        item_name = f"Tier {tier} Gempouch"
        return lambda state: state.has(item_name, player)
    if mode == 4:  # global
        return lambda state: state.has("Master Gempouch", player)
    return _always_true


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
        if req in _GEM_TOKEN_TO_GEM_NAME:
            item_name = item_prefix_map[req]
            gem_name = _GEM_TOKEN_TO_GEM_NAME[req]
            broaden = _compile_gem_broadened(world, gem_name)
            def _gem_token(state):
                if state.has(item_name, player):
                    return True
                return broaden(state)
            return _gem_token
        name = item_prefix_map[req]
        return lambda state: state.has(name, player)

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
            if group_name in ("gemSkills", "GemSkills"):
                # Gempouch-aware count: each of the 6 gem skills counts iff
                # the skill item is held OR a stage hosting it in available_gems
                # is reachable AND the player has that prefix's gempouch.
                pairs = []
                for tok, gem_name in _GEM_TOKEN_TO_GEM_NAME.items():
                    pairs.append((item_prefix_map[tok], _compile_gem_broadened(world, gem_name)))
                def _gemskills_count_check(state):
                    n = 0
                    for item_name, broaden in pairs:
                        if state.has(item_name, player) or broaden(state):
                            n += 1
                    return n >= count_needed
                return _gemskills_count_check
            pool = tuple(skill_counter_pools[group_name])
            return lambda state: sum(1 for n in pool if state.has(n, player)) >= count_needed

        if group_name in level_stat_counters:
            stages = _qualifying_stages_for_stat(group_name, count_needed)
            return lambda state: _can_reach_any_stage(state, player, stages)

        if group_name in _TALISMAN_FRAGMENT_COUNTERS:
            names = _TALISMAN_FRAGMENT_COUNTERS[group_name]
            return lambda state: _count_talisman_fragments(state, player, names) >= count_needed

        if group_name in _TALISMAN_PROPERTY_TOKENS:
            prop_id = _TALISMAN_PROPERTY_TOKENS[group_name]
            return lambda state: _sum_talisman_property(prop_id, state, player) >= count_needed

        if group_name == "fieldToken":
            # Granularity-aware: counts effectively-unlocked stages, where
            # each stage's covering token (per_stage / per_tile / per_tier)
            # is read from the per-world sid->token map.
            return lambda state: sum(
                1 for tok in _get_world_field_token_map(state, player).values()
                if state.has(tok, player)
            ) >= count_needed
        if group_name == "shadowCore":
            return lambda state: _sum_shadow_cores(state, player) >= count_needed
        if group_name == "wizardLevel":
            needed_items = (count_needed + 1) // 2
            return lambda state: _count_xp_items(state, player) >= needed_items
        if group_name == "talismanRow":
            return lambda state: _count_complete_talisman_rows(state, player) >= count_needed
        if group_name == "talismanColumn":
            return lambda state: _count_complete_talisman_columns(state, player) >= count_needed
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

        token_name = _gating.field_token_for_stage(str_id, ft_gran)
        connection.access_rule = (
            lambda state, tok=token_name: state.has(tok, player)
        )

    # --- Location rules: WIZLOCK skill requirements only ---
    # gem_pouch_granularity selects which gem-related requirements actually gate:
    #   off                  → gemSkills:N active, gemPouch:<prefix> is no-op
    #   per_tile_distinct    → gemSkills:N is a no-op, gemPouch:<prefix> needs
    #                          the named pouch item `Gempouch (<prefix>)`
    #   per_tile_progressive → gemSkills:N is a no-op, gemPouch:<prefix> needs
    #                          N copies of "Progressive Gempouch" where N is the
    #                          prefix's index in GEM_POUCH_PLAY_ORDER + 1
    #   per_tier             → gemSkills:N is a no-op, gemPouch:<prefix> needs
    #                          `Tier <N> Gempouch` for the stage's tier
    #   global               → gemSkills:N is a no-op, gemPouch:<prefix> needs
    #                          the single "Master Gempouch"
    pouch_mode = world.options.gem_pouch_granularity.value
    pouch_index = {p: i for i, p in enumerate(GEM_POUCH_PLAY_ORDER)}

    for str_id, rule in STAGE_RULES.items():
        if not rule.skills:
            continue

        conditions = []
        for skill in rule.skills:
            if ":" in skill:
                group_name, count_str = skill.split(":", 1)
                group_name = group_name.strip()
                if group_name == "gemPouch":
                    if pouch_mode == 0:
                        continue  # off — pouches don't gate
                    prefix = count_str.strip()
                    if pouch_mode == 1:  # per_tile_distinct
                        item_name = f"Gempouch ({prefix})"
                        conditions.append(lambda state, i=item_name: state.has(i, player))
                    elif pouch_mode == 2:  # per_tile_progressive
                        needed = pouch_index.get(prefix, -1) + 1
                        if needed > 0:
                            conditions.append(
                                lambda state, n=needed: state.count("Progressive Gempouch", player) >= n
                            )
                    elif pouch_mode == 3:  # per_tier
                        stage_tier = STAGE_RULES[str_id].tier
                        item_name = f"Tier {stage_tier} Gempouch"
                        conditions.append(lambda state, i=item_name: state.has(i, player))
                    elif pouch_mode == 4:  # global
                        conditions.append(lambda state: state.has("Master Gempouch", player))
                    continue
                if group_name == "gemSkills" and pouch_mode != 0:
                    continue  # pouches replace the gem-skill gate
                count_needed = int(count_str.strip())
                if group_name in skill_groups:
                    group_members = skill_groups[group_name].get("members", [])
                    conditions.append(lambda state, mems=group_members, n=count_needed:
                        sum(1 for m in mems if state.has(f"{m} Skill", player)) >= n)
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
            token_name = _gating.field_token_for_stage(sid, ft_gran)
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
                    lambda state, t=token_name, d=dnf_rule: state.has(t, player) and d(state)
                )
                add_rule(journey_loc, wrap_rule(f"stage:{sid}:journey", dnf_rule))
                add_rule(stash_loc,   wrap_rule(f"stage:{sid}:stash", dnf_rule))
            else:
                _STAGE_CLEAR_RULES[(player, sid)] = (
                    lambda state, t=token_name: state.has(t, player)
                )

        # Wizard-stash key item is always required (no off mode). The actual
        # item name depends on stash_key_granularity — see gating.stash_key_for_stage.
        from . import gating as _gating
        key_name = _gating.stash_key_for_stage(sid, world.options.stash_key_granularity.value)
        add_rule(stash_loc, wrap_rule(f"stash_key:{sid}",
                                       lambda state, n=key_name: state.has(n, player)))
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

        is_progressive = world.options.achievement_progression.value == AchievementProgression.option_progressive
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

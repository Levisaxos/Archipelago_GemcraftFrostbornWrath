"""
Vanilla stage-unlock tree for GemCraft: Frostborn Wrath.

Loads ``data/vanilla_tree.json`` (generated from ``StageCollection1.as`` by
``do not commit/py-scripts/export_vanilla_tree.py``) and exposes, for each
stage, the vanilla parent stage — the one whose win drop or wizard-stash drop
unlocks it in the unmodded game.

``rules.py`` uses :data:`VANILLA_PARENT` to gate a stage (and the achievements
bound to it) on its vanilla parent being cleared, and ships the resulting map
as ``field_parents`` in slot_data.
"""
from __future__ import annotations

import json
from importlib.resources import files

# Full decoded tree: {"stages": {sid: {"parent", "via", "depth", "type"}}}.
VANILLA_TREE: dict = json.loads(
    files(__package__).joinpath("data/vanilla_tree.json").read_text(encoding="utf-8")
)

# stage str_id -> vanilla parent str_id. Stages with no parent (the W1 root)
# are omitted, so ``VANILLA_PARENT.get(sid)`` returns None for them — exactly
# what rules._gate_parent expects.
VANILLA_PARENT: dict = {
    sid: info["parent"]
    for sid, info in VANILLA_TREE["stages"].items()
    if info.get("parent")
}

# stage str_id -> vanilla depth (number of ancestors that must be beaten first;
# W1 = 0). Beating a depth-D field implies at least D fields beaten before it,
# so depth is the "earliest fields-beaten count at which this field can be
# cleared". rules.py uses it to decide which field-unlock items are safe to
# place behind a `fieldsBeaten:N` achievement (depth >= N => never a
# prerequisite for reaching N).
DEPTH: dict = {sid: int(info["depth"]) for sid, info in VANILLA_TREE["stages"].items()}

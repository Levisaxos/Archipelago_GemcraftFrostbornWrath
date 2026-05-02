# Talisman Codex — Implementation Plan

Status: design / not yet implemented.

A "Codex" panel showing the 25 progression talisman fragments in a 5×5 grid.
Cells are gray when the player has never received that fragment, colored when
they have. The player can click any received-but-not-currently-owned cell to
re-add the fragment to their inventory; reclaimed fragments do not yield
shadow cores when destroyed (selling), but may still be added to the shape
collection (which gives no shadow cores anyway).

---

## Source-code findings

Locations refer to decompiled vanilla GCFW under `do not commit/GCFW/scripts/`
and the mod under `mods/ArchipelagoMod/src/`.

### Vanilla destroy / sell flow

- `selector/PnlTalisman.as:1737` — `destroyFragment(pFrag, ...)` is the
  sell-for-shadow-cores path. The grant line is:

      GV.ppd.shadowCoreAmount.s(GV.ppd.shadowCoreAmount.g() + pFrag.sellValue.g());

  Called from three sites — all UI-driven, all inside `PnlTalisman`:

  - `destroyFragmentUnderPointer()` at line 1397 (button + cursor)
  - keyboard handler at line 2200
  - keyboard handler at line 2330

- `selector/PnlTalisman.as:1779` — `addFragmentToShapeCollection(pFrag, ...)`
  is the "use for shape collection" path. Consumes the fragment, flips
  `GV.ppd.talFragShapeCollection[shapeId] = true`, **adds no shadow cores**.
  No suppression needed.

- `entity/TalismanFragment.as:12` — public fields used:
  `seed:int`, `rarity:ENumber`, `type:int`, `upgradeLevel:ENumber`,
  `sellValue:ENumber`, `bmpInInventory:Bitmap`, `getShapeId():int`.
  `sellValue` is deterministic per seed (rarity + per-seed RNG, lines 369–370).

### Mod patching capability

- `ANEBytecodeEditor.swc` is linked in `asconfig.json` but never used.
- Existing patches use per-frame polling (`HollowGemInjector`,
  `WizStashes.tickEnforceStashLock`) or post-event reverts
  (`ProgressionBlocker.onSaveSave`). The codex SC suppression fits the
  per-frame polling pattern cleanly — no bytecode editing needed.

### Existing talisman state plumbing

- `data/SaveData.as` — `receivedTalismans:Array`, `grantedApIds:Object`.
- `unlockers/TalismanUnlocker.as` —
  - `addFragmentFromTalData(talData, apId)` builds and inserts the fragment
    into `GV.ppd.talismanInventory`, sets `_grantedApIds[apId] = true`.
  - `setTalismanMap(map)` accepts the slot_data `talisman_map`
    (apId → "seed/rarity/type/upgradeLevel"). All 25 progression apIds
    (900–952) are present.
- `save/SaveManager.as:91-95, 116-118, 125` — persists `grantedTalismanApIds`
  as an int array per slot. `codexReclaimedSeeds` will follow the same
  pattern.
- `apworld/gcfw/__init__.py:692` (`fill_slot_data`) — emits `talisman_map`
  + `talisman_name_map`. We will add `progression_talisman_apids`.

---

## Approach

Two halves.

### 1. Codex panel (new UI)

Modeled on `ui/AvailableAchievementsPanel.as` (5×N grid, hover tooltip,
close button, scroll). Differences:

- Fixed 25-cell layout (5×5), no scroll.
- Cell visual states:
  - `notReceived` — desaturate filter + dim alpha; tooltip says "Not yet
    received".
  - `inInventory` — colored.
  - `inSlots` — colored, badge "equipped".
  - `reclaimable` (received and not currently owned and inventory has an
    empty slot) — colored, button-mode cursor, tooltip CTA.
- Click handler: for `reclaimable`, call the new
  `TalismanUnlocker.addFragmentBypassGranted(talData, apId, markCodex=true)`
  and refresh.
- Tooltip body: name (str_id), type, rarity, "Reclaimed via codex —
  destroying yields no shadow cores" when applicable, property list
  (current → max).

### 2. Shadow-core suppression watcher

Per-frame poll on the selector while `PnlTalisman` could be open. No
function replacement.

Each frame:

1. Snapshot `currentSnapshot:Object` — for every fragment in
   `talismanInventory ∪ talismanSlots` whose seed is in
   `codexReclaimedSeeds`, record `seed → sellValue.g()`.
2. Read `currentSC = GV.ppd.shadowCoreAmount.g()`.
3. For each seed present in the previous frame's snapshot but absent now:
   compute `delta = currentSC − _lastSC`. If `delta == previousSellValue`,
   refund: `GV.ppd.shadowCoreAmount.s(currentSC − delta)` and
   `GV.selectorCore.renderer.updateShadowCoreCounter(...)`.
4. Store snapshot + SC for the next frame.

The delta-equality check distinguishes the sell path
(SC went up by exactly sellValue) from the shape-collection path
(SC unchanged), so we only refund actual sell events.

---

## File-by-file changes

### apworld (Python)

**`apworld/gcfw/__init__.py`** — `fill_slot_data` (around line 692)

Add a new slot_data field:

    progression_talisman_apids = [
        frag["ap_id"] for frag in
        sorted(progression_talismans.values(), key=_codex_grid_key)
    ]
    # ... include in returned dict

The sort key `_codex_grid_key` produces the canonical 5×5 grid order. **See
open question 1 — layout still TBD.**

Optional richer payload (defer if not needed): `progression_talisman_meta`
mapping apid → `{type, rarity, properties_at_max, str_id, upgrade_level_max}`
so the codex tooltip doesn't need to re-derive properties on the mod side.

### mod (ActionScript)

**`mods/ArchipelagoMod/src/data/SaveData.as`**

- Add field `public var codexReclaimedSeeds:Object;`.
- Initialize `{}` in `initialize()`.

**`mods/ArchipelagoMod/src/save/SaveManager.as`**

- `loadSlotData` (line ~70): read `codexReclaimedTalismanSeeds` from
  the saved JSON and push to `_talismanUnlocker.codexReclaimedSeeds`.
- `saveSlotData` (line ~112): serialize `codexReclaimedSeeds` to an int
  array under the same key.
- `deleteSlot` (line ~152): clear the new field along with the others.

**`mods/ArchipelagoMod/src/unlockers/TalismanUnlocker.as`**

- New private field `_codexReclaimedSeeds:Object = {}`.
- New public getter/setter `codexReclaimedSeeds` (mirrors `grantedApIds`).
- New public function `markCodexReclaimed(seed:int)` that sets
  `_codexReclaimedSeeds[String(seed)] = true`.
- Refactor `addFragmentFromTalData` so the `_grantedApIds` dedup check is
  conditional. Add an entry point:

      public function reclaimFromCodex(apId:int):TalismanFragment {
          var talData:String = ...;
          var frag:TalismanFragment = _addFragmentNoDedup(talData, apId);
          if (frag != null) markCodexReclaimed(frag.seed);
          return frag;
      }

  Existing `grantFragment` and `syncTalismans` keep using the dedup'd path.

**`mods/ArchipelagoMod/src/data/ServerData.as` (or `data/AV.as`)**

- New field `progressionTalismanApIds:Array = []` populated from slot_data.

**`mods/ArchipelagoMod/src/net/ConnectionManager.as` (or `net/ApReceiver.as`,
wherever slot_data is parsed on `Connected`)**

- Read `progression_talisman_apids` and assign to ServerData.

**`mods/ArchipelagoMod/src/ui/TalismanCodexPanel.as`** *(new)*

- Constructor: takes `Logger, modName, TalismanUnlocker`.
- `setProgressionApIds(apIds:Array)` — called when slot_data arrives.
- `refresh()` — rebuilds cells.
- 5×5 grid, hover tooltip, close button. Cribs the visual style from
  `AvailableAchievementsPanel`.
- Cell builder constructs a transient `new TalismanFragment(seed, rarity,
  type, upgradeLevel)` to render the icon. **See open question 3** — icon
  bitmap may need a vanilla call to populate `bmpInInventory`.
- Click on `reclaimable` cell → `_talismanUnlocker.reclaimFromCodex(apId)`,
  toast, refresh.

**`mods/ArchipelagoMod/src/ui/ModButtons.as`**

- Add a fifth selector button — "Codex" — adjacent to `mc.btnTalisman`.
- New callback property `onCodexClick:Function`.
- Hide button when not connected to AP / standalone (open question 6).

**`mods/ArchipelagoMod/src/patch/TalismanSCBlocker.as`** *(new)*

- Watcher described in "Approach §2" above.
- Public `tickSelectorFrame()`.
- Reads `codexReclaimedSeeds` via `TalismanUnlocker`.
- Logs each refund: `"Refunded N shadow cores for reclaimed fragment seed=S"`.

**`mods/ArchipelagoMod/src/ArchipelagoMod.as`**

- `bind()`: instantiate `TalismanCodexPanel` and `TalismanSCBlocker`. Wire
  `_modButtons.onCodexClick = function():void { _codexPanel.toggle(); }`.
- `_onSelectorFrame` (around line 740): call
  `_talismanSCBlocker.tickSelectorFrame()` and refresh the codex panel
  state if open.

---

## Open questions / further investigation needed

1. **5×5 grid ordering.** "Same icon on columns / different on rows" plus
   "top row is one icon, second row is one different icon" reads as
   contradictory. The 25 fragments split as 4 corner + 12 edge + 9 inner —
   no clean 5×5 grouping by `type` or by `shape_id`. **Blocker for the
   panel layout.** Need confirmation:
   - sort by `type` then `rarity` desc?
   - group by `str_id` letter (A, B, C, …)?
   - rows correspond to some shape attribute we haven't surfaced?

2. **Reclaim level for A5 / A6.** These ship at `upgrade_level=3` per
   `rulesdata_talisman.py`. `addFragmentFromTalData` reads upgrade level
   straight from `talData`, so reclaim restores at level 3. Confirm this
   matches "the same as the original grant".

3. **Icon rendering at codex-build time.** `TalismanFragment.bmpInInventory`
   is populated lazily by something inside `PnlTalisman.init()`/render. To
   draw the icon in our codex panel, we likely need to either:
   - call the vanilla render path on a transient fragment, or
   - `bd.draw(frag.mc)` after building `frag.mc` ourselves.

   Worth ~15 minutes tracing once data plumbing is in place.

4. **Two reclaimed fragments destroyed in one frame.** The watcher's
   `delta == sellValue` check fails when two reclaimed fragments disappear
   simultaneously (delta = sum). Safe-failure mode: no refund (player keeps
   the cores). Decide: accept safe-fail, or add subset-sum matching to
   handle it precisely?

5. **Already-destroyed fragments before this feature ships.** `grantedApIds`
   is persisted, so the codex's "ever received" check works retroactively.
   But fragments the player *already destroyed* in past sessions will show
   as `reclaimable` — they kept the original SC, then can re-pull. Without
   per-destroy logging there's no way to know what was destroyed. Proposed:
   ship as a one-time grace; note in changelog. Confirm acceptable.

6. **Standalone mode.** Codex needs the 25-apid list + `talisman_map`,
   both AP-only. In standalone, hide the Codex button entirely. Confirm.

7. **Reclaim eligibility under shape-collection abuse loop.** Receive →
   add to shape coll (no SC) → reclaim → destroy for SC (refunded) →
   reclaim → ... gives net zero SC over time, so the loop is harmless.
   Confirm we accept it.

8. **Build of `PnlTalisman.scInitial` invariant.** At line 177 of
   `PnlTalisman`, `scInitial` snapshots SC on entry (used for the cancel
   button at line 504). Our SC refund mutates `shadowCoreAmount` mid-panel
   — verify the cancel button still behaves sensibly when refunds have
   occurred. Likely fine since cancel restores `scInitial` (overwrites our
   refund), but worth a manual test.

---

## Phasing suggestion

1. apworld slot_data field + mod plumbing for `progression_talisman_apids`
   (no UI yet). Validates the data path.
2. SaveData + SaveManager + TalismanUnlocker.reclaimFromCodex (no UI yet).
   Unit-testable via the in-mod debug panel.
3. `TalismanSCBlocker` watcher. Test with a `reclaimFromCodex` call from
   the debug panel, then sell — verify no SC gain.
4. `TalismanCodexPanel` + ModButtons wiring. Polish, tooltips, layout.
5. Standalone mode hide + edge-case sweep (questions 4, 5, 8).

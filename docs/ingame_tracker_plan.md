# In-Game Tracker — Stage Light Tinting

## Context
GCFW Archipelago players currently have no in-game indication of which stages contain reachable (in-logic) checks. They have to alt-tab to an external tracker or guess. This change adds a passive, always-visible signal directly on the world-map stage nodes by recoloring the existing completion-status lights the game already draws inside each `McFieldToken`.

The only UI surface is the map. No tooltip, no tracker window, no HUD — just a color on lights that are already there.

## Visual states (per stage)
- **In logic + has missing check** → **light faded green** tint on the token's lights
- **Not in logic + has missing check** → **light faded red** tint
- **Fully done** (all AP checks for this stage already sent) → **leave untouched** (the game's own "completed" rendering stays as-is)

Reachability is recomputed live whenever an item arrives from AP.

## Architecture overview
- **apworld** ships tier/rule data in `slot_data` at generation time — Python stays the single source of truth for logic rules.
- **mod** receives those rules on connect, tracks collected items locally, and evaluates per-stage reachability client-side.
- A new **StageTinter** plugs into the existing selector frame loop and recolors the token lights.

---

## Step 1 — apworld: extend `fill_slot_data`

**File:** `apworld/gcfw/__init__.py` (function `fill_slot_data`, ~line 269)

Import from `rulesdata.py`: `TIERS`, `CUMULATIVE_SKILL_REQUIREMENTS`, `STAGE_RULES`, `SKILL_CATEGORIES`.

Add to the returned dict:
```
"logic_rules_version": 1,
"skill_categories":        SKILL_CATEGORIES,                # category -> [skill names]
"cumulative_skill_reqs":   { "1": {...}, ..., "12": {...} },# str-keyed tier -> category -> int
"stage_tier":              { "S1": 0, "V2": 1, ... },       # from STAGE_RULES[sid].tier
"stage_skills":            { "P5": ["Traps","Poison"], ... },# only non-empty required_skills
"tier_stage_counts":       { "0": 5, "1": 11, ... },        # len(TIERS[t])
"tier_token_threshold_pct": self.options.tier_requirements_percent.value,
```
`free_stages` already ships. Keep keys string-indexed so AS3 Object lookups work directly. Verify the prev-tier token threshold formula in `apworld/gcfw/rules.py` and mirror it exactly in the AS3 evaluator.

## Step 2 — Mod: collected-state tracking

**New file:** `mods/ArchipelagoMod/src/tracker/CollectedState.as`

State:
- `_tokensByStrId : Object` — strId → true
- `_skillsCollected : Object` — skill name → true
- `_skillCountByCategory : Object` — category → int

Classify incoming items via:
- `ConnectionManager._tokenMap` (AP id → stage strId) for field tokens
- `SkillUnlocker.SKILL_NAMES` (AP id → skill name) for skills — reuse, don't duplicate

Hook into the existing callbacks in `ConnectionManager.as` (the `onFullSync` / `onItemReceived` paths around lines 378/383): after processing, call `_collectedState.onItem(apId)` then `_logicEvaluator.markDirty()` then `_stageTinter.markForceReapply()`. Wrap or chain — don't fork the callback setter.

## Step 3 — Mod: reachability evaluator

**New file:** `mods/ArchipelagoMod/src/tracker/LogicEvaluator.as`

Constructed once after slot_data lands; holds references to slot_data rules + `CollectedState`.

Public:
- `markDirty()`
- `isStageInLogic(strId:String):Boolean` — lazy recompute if dirty

Algorithm:
```
recompute():
  reachableTier = -1
  for t in 0..12:
    if t == 0:
      ok = true
    else:
      needed = ceil(tier_stage_counts[t-1] * tier_token_threshold_pct / 100)
      haveTokens = count of strIds in _tokensByStrId whose stage_tier == t-1
      ok = (haveTokens >= needed)
           AND for every category in cumulative_skill_reqs[t]:
                 _skillCountByCategory[cat] >= cumulative_skill_reqs[t][cat]
    if ok: reachableTier = t else break

  for strId in stage_tier:
    inLogic = (strId in free_stages) OR (stage_tier[strId] <= reachableTier)
    if inLogic AND strId in stage_skills:
      inLogic = all names in stage_skills[strId] present in _skillsCollected
    _inLogicByStrId[strId] = inLogic
```
Cheap — ~60 stages × 12 tiers. Recompute on every dirty flip.

## Step 4 — Mod: stage light tinter

**New file:** `mods/ArchipelagoMod/src/tracker/StageTinter.as`

The game's own completion lights live on `McFieldToken` at:
- `lightJourney` (line 30)
- `lightEndurance` (line 32)
- `lightTrial` (line 34)

`SelectorRenderer.adjustFieldTokens()` (lines 306–308 of the game source) rebuilds these via `gotoAndStop()` on every refresh, which **wipes any ColorTransform we set**. Therefore the tinter must reapply after every refresh, not just when state changes.

Public: `apply(mc:*)`, called from the selector frame loop in `ArchipelagoMod.as` immediately after `_firstPlayBypass.onSelectorFrame(mc)` (~line 479).

Logic:
```
cnt = mc.cntFieldTokens
for i in 0..cnt.numChildren-1:
    tok = cnt.getChildAt(i)
    sid = int(tok.id)
    meta = GV.stageCollection.stageMetas[sid]
    if meta == null: continue
    strId = meta.strId
    baseLoc = ConnectionManager.getStageLocId(strId)         // new public getter
    hasMissing = _cm.missingLocations[baseLoc]
              || _cm.missingLocations[baseLoc+500]
              || _cm.missingLocations[_cm.getStashLocId(strId)]
    if !hasMissing:
        // Done → leave game's rendering alone
        reset ColorTransform on the three lights
        continue
    tint = _evaluator.isStageInLogic(strId) ? GREEN_FADED : RED_FADED
    applyTint(tok.lightJourney,   tint)
    applyTint(tok.lightEndurance, tint)
    applyTint(tok.lightTrial,     tint)
```
Tint is a subtle `ColorTransform` — e.g. green: `redMultiplier=0.6, blueMultiplier=0.6, greenOffset=30`; red: `greenMultiplier=0.6, blueMultiplier=0.6, redOffset=30`. Final values tuned at runtime.

**Reapplication strategy:** run the tinter every selector frame (it's already cheap and the frame loop already runs). A per-stage `_lastState` cache avoids allocating a new `ColorTransform` each frame unless the desired state changed; only the assignment is repeated. No hook into `adjustFieldTokens()` needed.

## Step 5 — Wiring

In `ArchipelagoMod.as`:
- Instantiate `CollectedState`, `LogicEvaluator`, `StageTinter` after `ConnectionManager` + `SkillUnlocker` exist.
- Pass slot_data rules to `LogicEvaluator` inside the existing slot_data handler.
- Chain into `onFullSync` / `onItemReceived` to update `CollectedState` and mark dirty.
- Also `markForceReapply()` when a location send succeeds (in `ConnectionManager.as` ~line 565 where `_missingLocations[sentId]` is deleted) — a stage may transition from "has missing" → "done" and need its tint cleared.
- Call `_stageTinter.apply(mc)` from the selector frame loop (~line 479 of `ArchipelagoMod.as`).
- Add public getters on `ConnectionManager` for the currently-private `STAGE_LOC_AP_IDS` and wizard-stash lookup.

## Critical files
- `apworld/gcfw/__init__.py` — modify `fill_slot_data`
- `apworld/gcfw/rulesdata.py` — read-only reference
- `apworld/gcfw/rules.py` — verify prev-tier token threshold formula
- `mods/ArchipelagoMod/src/net/ConnectionManager.as` — chain callbacks, expose getters
- `mods/ArchipelagoMod/src/ArchipelagoMod.as` — wiring + frame-loop call
- `mods/ArchipelagoMod/src/unlockers/SkillUnlocker.as` — reuse `SKILL_NAMES`
- `mods/ArchipelagoMod/src/tracker/CollectedState.as` — new
- `mods/ArchipelagoMod/src/tracker/LogicEvaluator.as` — new
- `mods/ArchipelagoMod/src/tracker/StageTinter.as` — new

## Open risks
- `tier_token_threshold_pct` formula must match `rules.py` exactly — verify before shipping.
- `ColorTransform` on `lightJourney`/`lightEndurance`/`lightTrial` may interact oddly with the MovieClip's own frame rendering — test and fall back to overlay sprites if the tint washes out.
- Obfuscated property names (`cntFieldTokens`, `.id`, `lightJourney`, etc.) — stable today but worth a log-and-skip if `null`.
- `logic_rules_version` lets the mod bail gracefully if an older apworld is used with a newer schema (or vice versa).

## Verification
1. Add a debug `print` of new slot_data keys in `fill_slot_data`; run `do not commit\build_apworld.bat`; generate a seed and confirm schema in AP server log / `.archipelago` file.
2. Run `do not commit\build_mod.bat`, launch GCFW, connect to the seed.
3. Open the stage selector:
   - Early-game tier-0 stages (W2/W3/W4, S1–S4, V1) should show **green** lights.
   - Later stages (V2+) should show **red** lights.
   - Any already-completed AP check stages (shouldn't be any on a fresh seed) show normal game rendering.
4. Grant a progression item via `!getitem` or the debug panel. Expect: newly-reachable stages flip from red to green live, without reopening the selector.
5. Complete S1 in-game → once all three S1 AP locations are sent, S1 lights drop the tint and render as the game normally would (completed).
6. Verify P5 stays **red** even after its tier unlocks, until Traps **and** Poison skills are collected (tests `stage_skills` gate).
7. Verify tier-12 stages (A4/A5/A6) stay red early and only flip to green after tier-11 tokens + tier-12 skill row are collected.

# Future Possible Options

Options considered but deferred due to balancing complexity or required design work.

---

## GemCombineLimit

**Concept:** Cap the maximum gem grade the player can create (1–9). A cap of 5 means no
grade 6+ gems can be crafted mid-game, significantly increasing combat difficulty.

**Why deferred:**
Enforcing the cap requires items in the pool that progressively raise it, e.g.
"Gem Grade Cap +1" items from grade 5 upward. Designing how many of these items exist,
how they interact with XP tomes and skill unlocks, and what grade the player starts at
needs careful balancing to avoid seeds that are unbeatable or trivially easy at all tiers.

**Implementation notes:**
- apworld: new item type "Gem Grade Unlock" (grades 6–9 = 4 items), new option for
  starting grade cap (default 5).
- mod: intercept gem combining logic to enforce the current cap from slot_data.
- Needs thorough playtesting before enabling in public seeds.

---

## GemPlacementLimit

**Concept:** Cap the number of gems the player can have placed on the field at once
(e.g. max 10 towers active). Raises progressively via items in the pool.

**Why deferred:**
Same balancing concerns as GemCombineLimit — requires pool items to unlock higher
limits and careful thought about starting cap, progression curve, and interaction with
field size across different stages (some stages have far more tower slots than others).
Both options should be designed and balanced together as a pair.

**Implementation notes:**
- Closely related to GemCombineLimit; design both at the same time.
- mod: intercept tower placement to block when at cap; UI feedback needed.
- Stage-specific minimum tower slots must be researched to avoid unbeatable stages.

---

## ExtraWaveCount

**Concept:** Add N extra waves to every stage, making runs longer and granting more mana
but demanding sustained attention. A natural difficulty and pacing knob alongside the
HP/armor/shield multipliers.

**Why deferred:**
Wave lists are baked into stage data at the engine level (`Wave.numOfMonsters`,
`stageData.waves`). There is no runtime API to append new waves — the count is read once
at stage load and driving it up would require either patching the stage data object before
ingame initialisation or injecting synthetic wave entries. Neither path is safe to do
without deeper RE work.

**Implementation notes:**
- Explore `GV.ingameCore.stageData.waves` at stage-load time (before INGAME is fully
  entered) to see if the array is writable and whether appending a clone of the last wave
  is sufficient.
- If the wave sequence is iterated by index from a cached length, a one-shot patch at
  INGAME entry may work; otherwise requires a hooking point in the wave spawner.
- Range: 0–50 extra waves, default 0.

---

## EnemiesPerWaveMultiplier

**Concept:** Percentage multiplier on the number of monsters spawned per wave (e.g. 150%
= 1.5× enemies each wave). Pairs naturally with HP/armor/shield multipliers for a fuller
difficulty system.

**Why deferred:**
`Wave.numOfMonsters` is set at engine level when the wave is prepared and cannot be
patched after the fact via `monstersOnScene` (the extra spawns simply never exist).
Changing the count requires hooking the wave-preparation code or patching `stageData`
before the stage starts.

**Implementation notes:**
- Same investigation path as ExtraWaveCount — look at whether `stageData.waves[i].numOfMonsters`
  (or equivalent) is writable before the wave spawner reads it.
- If a pre-spawn hook exists, this becomes straightforward. If not, requires deeper engine RE.
- Range: 50–200%, default 100.

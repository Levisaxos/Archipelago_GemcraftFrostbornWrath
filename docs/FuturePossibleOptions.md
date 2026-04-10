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

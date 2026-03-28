# Wizard Stash Restrictions — Research & Implementation Plan

## Context

We want to extend wizard stashes in the Archipelago mod to support custom unlock restrictions — requiring specific gem types, active battle traits, or spell/skill usage to damage or open them. This would add depth to the randomizer by gating checks behind game mechanics.

---

## Research Findings

### Wizard Stashes (WizardStash.as)
- **File:** `do not commit/gcfw/scripts/com/giab/games/gcfw/entity/WizardStash.as`
- **Constructor:** `WizardStash(fieldX, fieldY, hp, armor, shield, hsbc, startAsOpen)`
- **Damage entry points:**
  - `sufferShotDamage(pShotData, pOriginGem, pIgnoreArmor, pDamage, pIsKillingShot)` — normal gem shots
  - `sufferGemBombDamage(pShotData)` — gem bomb damage (no origin gem reference!)
- **Opening:** When `hp < 1`, calls `GV.ingameDestroyer.openWizardStash(this)`
- **Footprint:** 3x2 grid spaces
- **Stage definition format:** `WIZSTASH,x,y,hp,armor,shield,hsbc` in `StageData.buildings`

### L5 Stash Specifics
- **Stage meta:** `StageCollection1.as`, line ~297
- **Type:** EPIC stage
- **Stash drop:** `TAL5981897/71/0/0` — a Talisman Fragment
- **Status persistence:** `PlayerProgressData.stageWizStashStauses[stageId]` — CLOSED(0), OPEN(1), DESTROYED(2)
- **Status only saved if the battle is WON**

### WizLocks — Existing Restriction Pattern
- **File:** `do not commit/gcfw/scripts/com/giab/games/gcfw/entity/WizLock.as`
- WizLocks already implement **type-based gating** — this is our precedent
- **Types** (`WizLockType.as`): SHOT(0), BARRAGE(1), BEAM(2), BOLT(3), FREEZE(4)
- Locks count received hits (`receivedAmount`) toward a requirement (`reqAmount`)
- BEAM type counts 1/3 per hit; all others count 1
- Also has `sufferSpell()` for strike spell hits
- **Key insight:** The game already gates building destruction on spell/enhancement type

### Gem Types Available at Hit Time
**YES — the origin gem is fully accessible when a stash is hit.**

In `sufferShotDamage`, `pOriginGem` (type `Gem`) provides:
- `elderComponents[]` — array of `GemComponentType` values
- `hueMain` — hue value for color identification
- `grade` — gem level
- `isInTower`, `isInTrap`, `isInLantern` — placement info

`pShotData` provides:
- `enhancementType` — BOLT, BEAM, BARRAGE, or NONE
- All damage stats, slow/bleed/poison values, etc.

### Gem Component Types
- **File:** `do not commit/gcfw/scripts/com/giab/games/gcfw/constants/GemComponentType.as`
- CRITHIT (0), MANA_LEECHING (1), BLEEDING (2), ARMOR_TEARING (3), POISON (4), SLOWING (5)

### Skills System
- **File:** `do not commit/gcfw/scripts/com/giab/games/gcfw/constants/SkillId.as`
- 24 skills total: MANA_STREAM(0), TRUE_COLORS(1), FUSION(2), ORB_OF_PRESENCE(3), RESONANCE(4), DEMOLITION(5), CRITHIT(6), MANA_LEECHING(7), BLEEDING(8), ARMOR_TEARING(9), POISON(10), SLOWING(11), FREEZE(12), WHITEOUT(13), ICESHARDS(14), BOLT(15), BEAM(16), BARRAGE(17), FURY(18), AMPLIFIERS(19), PYLONS(20), LANTERNS(21), TRAPS(22), SEEKER_SENSE(23)
- **Active check:** `GV.ppd.selectedSkillLevels[skillId].g() > -0.5`
- Skills unlock spells: FREEZE, WHITEOUT, ICESHARDS (strike spells), BOLT, BEAM, BARRAGE (gem enhancements)
- Skill levels and effective values accessible at runtime

### Battle Traits System
- **File:** `do not commit/gcfw/scripts/com/giab/games/gcfw/constants/BattleTraitId.as`
- 15 traits: ADAPTIVE_CARAPACE(0), DARK_MASONRY(1), SWARMLING_DOMINATION(2), OVERCROWD(3), CORRUPTED_BANISHMENT(4), AWAKENING(5), INSULATION(6), HATRED(7), SWARMLING_PARASITES(8), HASTE(9), THICK_AIR(10), VITAL_LINK(11), GIANT_DOMINATION(12), STRENGTH_IN_NUMBERS(13), RITUAL(14)
- **Active check:** `GV.ppd.selectedBattleTraitLevels[traitId].g() > 0`
- **Gained check:** `GV.ppd.gainedBattleTraits[traitId] == true`
- Max level: 12

---

## Feasibility Assessment

### 1. Require a specific gem type — VERY FEASIBLE
- `sufferShotDamage` receives `pOriginGem` with `elderComponents[]`
- Check if `elderComponents` contains the required `GemComponentType`
- **Caveat:** `sufferGemBombDamage` does NOT receive an origin gem — needs special handling

### 2. Require a battle trait to be active — VERY FEASIBLE
- Global state check: `GV.ppd.selectedBattleTraitLevels[traitId].g() > 0`
- Add guard clause before damage — if trait not active, ignore damage
- Player must set the trait before entering the level (or during, if UI allows)

### 3. Require a spell/enhancement — VERY FEASIBLE
- Shots carry `pShotData.enhancementType` (BOLT, BEAM, BARRAGE, NONE)
- Can require specific enhancement on the hitting shot
- Strike spells (FREEZE, WHITEOUT, ICESHARDS) could be checked via `sufferSpell()`-like mechanism

### 4. Require a skill to be active — VERY FEASIBLE
- Check `GV.ppd.selectedSkillLevels[skillId].g() > -0.5`
- Global state, checkable anytime

### 5. Combinations — FEASIBLE
- Any combination of the above (e.g., "requires Poison gem + HASTE trait active")

---

## Implementation Approach

### Hooking Strategy (Bezel Mod)
Since we mod via Bezel (AS3 hooks), we can intercept the stash damage functions:

1. **Hook `WizardStash.sufferShotDamage`** — add restriction checks before damage is applied
2. **Hook `WizardStash.sufferGemBombDamage`** — block or allow gem bombs per restriction rules
3. **Store restriction metadata** in the mod's data structures, keyed by stage ID + stash position

### Restriction Types We Could Support
| Type | Check Location | What to Inspect |
|------|---------------|-----------------|
| Gem color | `sufferShotDamage` | `pOriginGem.elderComponents[]` contains required `GemComponentType` |
| Battle trait | `sufferShotDamage` | `GV.ppd.selectedBattleTraitLevels[traitId].g() > 0` |
| Spell/enhancement | `sufferShotDamage` | `pShotData.enhancementType == required type` |
| Skill active | `sufferShotDamage` | `GV.ppd.selectedSkillLevels[skillId].g() > -0.5` |
| Gem bomb | `sufferGemBombDamage` | Block entirely if any restriction is set (no origin gem available) |

### Key Files to Create/Modify
| File | Purpose |
|------|---------|
| `mods/ArchipelagoMod/src/ArchipelagoMod.as` | Main mod — register hooks for stash damage |
| `mods/ArchipelagoMod/src/StashRestrictions.as` (new) | Restriction definitions, storage, and checking logic |
| `mods/ArchipelagoMod/src/ConnectionManager.as` | Receive restriction data from Archipelago server |
| `apworld/gcfw/` | Define restriction options in the YAML/world config |

### Key Source Files for Reference
| File | What to reference |
|------|-------------------|
| `do not commit/gcfw/scripts/.../entity/WizardStash.as` | Damage entry points to hook |
| `do not commit/gcfw/scripts/.../entity/WizLock.as` | Existing restriction pattern |
| `do not commit/gcfw/scripts/.../constants/WizLockType.as` | Lock type enum pattern |
| `do not commit/gcfw/scripts/.../constants/GemComponentType.as` | Gem types (6 types) |
| `do not commit/gcfw/scripts/.../constants/BattleTraitId.as` | Battle trait IDs (15 traits) |
| `do not commit/gcfw/scripts/.../constants/SkillId.as` | Skill IDs (24 skills) |
| `do not commit/gcfw/scripts/.../ingame/IngameInitializer.as` | Stash placement/parsing (~line 369, ~947) |
| `do not commit/gcfw/scripts/.../ingame/IngameDestroyer.as` | Stash opening logic (~line 1844) |

---

## Open Questions
- Should restricted stashes be visually distinct? (color-coded border, icon overlay, tooltip?)
- Should we show a toast message when hitting a restricted stash without meeting requirements?
- How should gem bombs interact? (Block entirely since no origin gem? Exempt from restrictions?)
- Should restrictions come from the Archipelago server per-location, or be fixed per stash?
- Can we combine multiple restriction types on one stash?

---

## Verification Plan
1. Add a test restriction to an L5 stash (e.g., "requires Poison gem")
2. Build mod, load L5, hit stash with wrong gem type — confirm no damage
3. Hit with correct gem type — confirm damage applies and stash opens normally
4. Test battle trait restriction — confirm trait must be active
5. Test gem bomb interaction
6. Test visual feedback (toast/overlay)

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

---

## Wizard Stash Reference — All Fields

Every field has exactly one wizard stash. None appear in Trial mode (Journey or Endurance only).

**How to open:** Shoot with gems or drop gem bombs until HP reaches 0. The stash gives ALL listed rewards simultaneously.

**Note on multi-element SHC rewards:** The wizard stash gives all shadow core amounts at once. These fields also have separate Alloy Stash buildings that give individual tier amounts.

| Field | Mode | Reward |
|-------|------|--------|
| Z1 | Journey | Battle Trait: Insulation |
| Z2 | Endurance | 120+60+80+100+120 Shadow Cores |
| Z3 | Endurance | Talisman Fragment |
| Z4 | Endurance | Field Token: Z5 |
| Z5 | Endurance | Skill Tome: Mana Leeching |
| Y1 | Endurance | Battle Trait: Swarmling Domination |
| Y2 | Journey | Talisman Fragment |
| Y3 | Journey | Skill Tome: Freeze |
| Y4 | Endurance | Field Token: Z1 + Map Tile #0 |
| X1 | Journey | 30+40+50+60+70+80 Shadow Cores |
| X2 | Endurance | Talisman Fragment |
| X3 | Endurance | Talisman Fragment |
| X4 | Journey | Skill Tome: Beam |
| W1 | Endurance | Skill Tome: Orb of Presence |
| W2 | Endurance | 30+20+40+30 Shadow Cores |
| W3 | Endurance | Talisman Fragment |
| W4 | Endurance | Talisman Fragment |
| V1 | Journey | Battle Trait: Overcrowd |
| V2 | Endurance | Talisman Fragment |
| V3 | Journey | Talisman Fragment |
| V4 | Endurance | Skill Tome: Amplifiers |
| U1 | Journey | Talisman Fragment |
| U2 | Endurance | Talisman Fragment |
| U3 | Journey | Skill Tome: Pylons |
| U4 | Journey | 80+50+90+70 Shadow Cores |
| T1 | Journey | Skill Tome: Lanterns |
| T2 | Endurance | Talisman Fragment |
| T3 | Endurance | Field Token: T5 |
| T4 | Endurance | Battle Trait: Swarmling Parasites |
| T5 | Journey | Talisman Fragment |
| S1 | Endurance | Talisman Fragment |
| S2 | Endurance | Battle Trait: Haste |
| S3 | Endurance | 40+50+60+30 Shadow Cores |
| S4 | Journey | Skill Tome: Traps |
| R1 | Endurance | 50+100+50 Shadow Cores |
| R2 | Endurance | Talisman Fragment |
| R3 | Endurance | Battle Trait: Adaptive Carapace |
| R4 | Journey | Skill Tome: Resonance |
| R5 | Endurance | Talisman Fragment |
| R6 | Journey | Talisman Fragment |
| Q1 | Journey | Skill Tome: Bolt |
| Q2 | Journey | 100+100+100 Shadow Cores |
| Q3 | Endurance | Talisman Fragment |
| Q4 | Journey | Talisman Fragment |
| Q5 | Endurance | Talisman Fragment |
| P1 | Endurance | Skill Tome: Poison |
| P2 | Journey | Talisman Fragment |
| P3 | Journey | 70+70+80+90+100+70 Shadow Cores |
| P4 | Endurance | Battle Trait: Giant Domination |
| P5 | Endurance | Field Token: P6 |
| P6 | Endurance | Talisman Fragment |
| O1 | Journey | Talisman Fragment |
| O2 | Endurance | Battle Trait: Corrupted Banishment |
| O3 | Journey | Talisman Fragment |
| O4 | Endurance | Talisman Fragment |
| N1 | Endurance | Field Token: R6 |
| N2 | Endurance | Talisman Fragment |
| N3 | Journey | Skill Tome: Armor Tearing |
| N4 | Journey | Talisman Fragment |
| N5 | Endurance | Skill Tome: Slowing |
| M1 | Endurance | 220+110+330 Shadow Cores |
| M2 | Endurance | Talisman Fragment |
| M3 | Journey | Skill Tome: Barrage |
| M4 | Endurance | Talisman Fragment |
| L1 | Endurance | Talisman Fragment |
| L2 | Endurance | 200+150+100+50+100 Shadow Cores |
| L3 | Journey | Skill Tome: Demolition |
| L4 | Endurance | Talisman Fragment |
| L5 | Endurance | Talisman Fragment |
| K1 | Endurance | Battle Trait: Dark Masonry |
| K2 | Endurance | Talisman Fragment |
| K3 | Journey | Talisman Fragment |
| K4 | Endurance | Talisman Fragment |
| K5 | Journey | 60+90+120+150+180+120 Shadow Cores |
| J1 | Endurance | Skill Tome: True Colors |
| J2 | Journey | Talisman Fragment |
| J3 | Journey | Talisman Fragment |
| J4 | Journey | Battle Trait: Vital Link |
| I1 | Journey | Talisman Fragment |
| I2 | Journey | Battle Trait: Awakening |
| I3 | Endurance | 200+240+160+240 Shadow Cores |
| I4 | Endurance | Skill Tome: Bleeding |
| H1 | Endurance | 100+200+300+200 Shadow Cores |
| H2 | Journey | Field Token: H5 |
| H3 | Journey | Battle Trait: Thick Air |
| H4 | Endurance | Skill Tome: Iceshards |
| H5 | Journey | Talisman Fragment |
| G1 | Journey | Talisman Fragment |
| G2 | Endurance | Field Token: K5 |
| G3 | Endurance | Skill Tome: Whiteout |
| G4 | Endurance | Talisman Fragment |
| F1 | Endurance | Talisman Fragment |
| F2 | Journey | Battle Trait: Strength in Numbers |
| F3 | Journey | 140+360+500 Shadow Cores |
| F4 | Endurance | Field Token: F5 |
| F5 | Endurance | Talisman Fragment |
| E1 | Journey | Talisman Fragment |
| E2 | Endurance | Skill Tome: Fury |
| E3 | Endurance | Field Token: E5 |
| E4 | Endurance | Field Token: I1 + Map Tile #17 |
| E5 | Journey | Talisman Fragment |
| D1 | Endurance | Battle Trait: Ritual |
| D2 | Journey | Talisman Fragment |
| D3 | Endurance | Talisman Fragment |
| D4 | Endurance | Field Token: D5 |
| D5 | Endurance | Skill Tome: Seeker Sense |
| C1 | Endurance | 333+334+333 Shadow Cores |
| C2 | Journey | Talisman Fragment |
| C3 | Endurance | Battle Trait: Hatred |
| C4 | Endurance | Field Token: F3 + Map Tile #20 |
| C5 | Endurance | Talisman Fragment |
| B1 | Endurance | Talisman Fragment |
| B2 | Endurance | Field Token: B5 |
| B3 | Endurance | Talisman Fragment |
| B4 | Endurance | 270+70+110+170+280 Shadow Cores |
| B5 | Journey | Skill Tome: Critical Hit |
| A1 | Endurance | Talisman Fragment |
| A2 | Endurance | 200+300+400+300 Shadow Cores |
| A3 | Endurance | Field Token: A5 |
| A4 | Endurance | Field Token: A6 |
| A5 | Endurance | 400+300+600+700 Shadow Cores + Talisman Fragment |
| A6 | Journey | 350+450+650+750 Shadow Cores + Talisman Fragment |

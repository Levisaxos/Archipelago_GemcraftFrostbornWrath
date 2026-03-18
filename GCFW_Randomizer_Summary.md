# GCFW Scripts — System Summary & Randomizer Entry Points

**Date:** 2026-03-18
**Purpose:** Reference document mapping game systems to source files, for use when building the randomizer and adding a UI button to the tile map window.

All paths are relative to `scripts/com/giab/games/gcfw/`.

---

## 1. Level Unlocking & Progression

| File | Role |
|------|------|
| `struct/PlayerProgressData.as` | **Master save data** — holds all progression state: stage XP per mode, skill levels, battle trait levels, talisman inventory, achievement flags |
| `stages/StageCollection.as` | Master collection of all stages (loads J/E/T difficulty variants) |
| `stages/StageCollection1.as` | Journey/Endurance stage data provider |
| `stages/StageCollectionIron.as` | Iron difficulty variant |
| `struct/StageData.as` | Per-level config: wave data, rewards, difficulty |
| `struct/StageMetaData.as` | Stage metadata (coordinates, unlock dependencies) |
| `constants/StageType.as` | Enum: stage difficulty/type flags |
| `constants/GameMode.as` | Enum: Journey, Endurance, Trial, Iron |
| `utils/LoaderSaver.as` | Save/load system (reads/writes `PlayerProgressData`) |

**Key fields in `PlayerProgressData`:**
- `stageHighestXpsJourney[]`, `stageHighestXpsEndurance[]`, `stageHighestXpsTrial[]` — per-level XP (0 = locked)
- `gainedSkillTomes[]`, `selectedSkillLevels[]` — skill unlocks
- `gainedBattleTraits[]`, `selectedBattleTraitLevels[]` — trait unlocks
- `talismanInventory`, `talismanSlots` — equipment

**Randomizer hook:** Modify initial values or intercept the load/save cycle in `PlayerProgressData` to inject randomized unlock states.

---

## 2. Tile / World Map System

| File | Role |
|------|------|
| `entity/MapTile.as` | Individual tile entity (terrain, obstacle, stage node) |
| `utils/WorldMapBuilder.as` | Constructs the world map from tile data |
| `selector/SelectorCore.as` | **Main map window controller** — viewport management, `mapTiles[]` array, stage selection state |
| `selector/SelectorRenderer.as` | Renders the map (draws tiles, highlights) |
| `selector/SelectorPopulator.as` | Populates the map with tiles/stages |
| `selector/SelectorController.as` | Handles clicks, `selectStage()` — entry point for launching a level |
| `selector/SelectorInputHandler.as` | Mouse/keyboard input on the map |
| `struct/MapStamp.as` | Map tile stamp data structure |
| `constants/SelectorScreenStatus.as` | Enum: map screen states |

**Randomizer hook:** Shuffle tile/stage positions in `WorldMapBuilder` or `SelectorPopulator`. Override `StageMetaData` unlock dependencies.

**Button hook:** The map UI lives in `SelectorCore` / `SelectorRenderer`. A new button should be added as a child of `SelectorCore` with click handling wired in `SelectorController`.

---

## 3. Skills System

| File | Role |
|------|------|
| `constants/SkillId.as` | Enum: 24 skills (IDs 0–23) |
| `constants/SkillType.as` | Skill categorization |
| `selector/PnlSkills.as` | Skills panel UI in the selector |
| `mcStat/McPnlSkills.as` | Skills panel MovieClip |
| `struct/PlayerProgressData.as` | `gainedSkillTomes[]`, `selectedSkillLevels[]` |

**Skill IDs:**

| ID | Name | ID | Name |
|----|------|----|------|
| 0 | Mana Stream | 12 | Freeze |
| 1 | True Colors | 13 | Whiteout |
| 2 | Fusion | 14 | Ice Shards |
| 3 | Orb of Presence | 15 | Bolt |
| 4 | Resonance | 16 | Beam |
| 5 | Demolition | 17 | Barrage |
| 6 | Critical Hit | 18 | Fury |
| 7 | Mana Leeching | 19 | Amplifiers |
| 8 | Bleeding | 20 | Pylons |
| 9 | Armor Tearing | 21 | Lanterns |
| 10 | Poison | 22 | Traps |
| 11 | Slowing | 23 | Seeker Sense |

**Randomizer hook:** Shuffle `gainedSkillTomes[]` or reassign `selectedSkillLevels[]` on game start / button press.

---

## 4. Battle Traits System

| File | Role |
|------|------|
| `constants/BattleTraitId.as` | Enum: 15 traits (IDs 0–14) |
| `struct/PlayerProgressData.as` | `gainedBattleTraits[]`, `selectedBattleTraitLevels[]` |

**Trait IDs:**

| ID | Name | ID | Name |
|----|------|----|------|
| 0 | Adaptive Carapace | 8 | Swarmling Parasites |
| 1 | Dark Masonry | 9 | Haste |
| 2 | Swarmling Domination | 10 | Thick Air |
| 3 | Overcrowd | 11 | Vital Link |
| 4 | Corrupted Banishment | 12 | Giant Domination |
| 5 | Awakening | 13 | Strength in Numbers |
| 6 | Insulation | 14 | Ritual |
| 7 | Hatred | | |

**Randomizer hook:** Same pattern as skills — shuffle `gainedBattleTraits[]` on initialization.

---

## 5. Rewards & Drops

| File | Role |
|------|------|
| `constants/DropType.as` | Enum: 14 drop types |
| `entity/Drop.as` | Drop object |
| `entity/DropHolder.as` | Drop container |
| `mcDyn/McDrop.as` | Drop visual component |
| `ingame/IngameEnding.as` | **Level completion logic** — reward assignment (`endGameWithVictory()`, `updatePpdWithDrops()`) |
| `entity/WizardStash.as` | Wizard stash (reward chest on map) |
| `constants/WizStashStatus.as` | Stash state: LOCKED / UNLOCKED / OPENED |

**Drop types:** Shadow Core, Talisman Fragment, Field Token, Map Tile, Skill Tome, Battle Trait Scroll, Skill Point, XP, Mana, Gem, Journey Page, Endurance Wave Stone, Achievement

**Randomizer hook:** Intercept in `IngameEnding.updatePpdWithDrops()` to shuffle drop types/quantities, or randomize WizardStash contents on map load.

---

## 6. Adding a Button to the Map Window

**Target files:**
- `selector/SelectorCore.as` — owns the map window, manages child display components
- `selector/SelectorRenderer.as` — draws the map each frame
- `selector/SelectorController.as` — handles click interactions

**Approach:**
1. Add a button MovieClip or Sprite as a child of `SelectorCore`
2. Register a click listener in `SelectorController` or `SelectorInputHandler`
3. On click: invoke randomizer logic (shuffle `PlayerProgressData` fields, reload map display)

**Pattern to follow:** `mcStat/BtnOptions.as` — existing button class used in the same UI layer.

---

## 7. Save / Load Cycle (critical for randomizer)

| File | Role |
|------|------|
| `utils/LoaderSaver.as` | Reads/writes save state |
| `struct/PlayerProgressData.as` | Uses `Base64BitArray` compression for serialization |

**Randomizer must either:**
- Modify `PlayerProgressData` fields **after load, before render**, or
- Provide an alternative initialization path triggered by the randomizer button

---

## 8. Priority Files to Read Before Implementing

1. `struct/PlayerProgressData.as` — all tracked state fields
2. `selector/SelectorCore.as` — map window structure
3. `selector/SelectorController.as` — click handling hooks
4. `utils/LoaderSaver.as` — save/load lifecycle
5. `ingame/IngameEnding.as` — reward assignment
6. `stages/StageCollection.as` — stage unlock graph

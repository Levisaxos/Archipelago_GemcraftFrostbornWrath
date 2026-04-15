# AV (Archipelago Variables) Architecture Plan

## Context
Currently, Archipelago mod data is scattered across multiple classes (ConnectionManager, CollectedState, LogicEvaluator, SaveManager, and individual Unlockers). The user wants to consolidate this into a unified, maintainable structure using a top-level `AV` class with nested data containers organized by concern.

This will improve:
- **Maintainability** — single source of truth for each data domain
- **Discoverability** — clear organization of what data exists and where
- **Testability** — easier to mock and test components that depend on AV
- **Extensibility** — new data categories can be added without scattering code

---

## Architecture Design

### Four Data Domains

#### 1. **AV (top-level: generic mod data)**
Connection and config data shared across all systems:
```actionscript
AV.version:String                  // mod version
AV.changelog:String                // changelog text (if needed)
AV.isConnected:Boolean             // AP connection status
AV.currentSlot:String              // current AP slot name
AV.currentWorld:String             // current world/game context
AV.playerNames:Object              // slot → alias (from AP)
AV.playerGames:Object              // slot → game name (from AP)
```

#### 2. **AV.serverData (Archipelago-specific from slot_data)**
All data received from the AP server during the `Connected` packet. Immutable after connection:

**Item Mapping (from slot_data):**
```actionscript
AV.serverData.tokenMap:Object              // apId (str) → stage str_id
AV.serverData.talismanMap:Object           // apId (str) → "seed/rarity/type/upgradeLevel"
AV.serverData.talismanNameMap:Object       // apId (str) → display name
AV.serverData.shadowCoreMap:Object         // apId (str) → amount (int)
AV.serverData.shadowCoreNameMap:Object     // apId (str) → display name
AV.serverData.wizStashTalData:Object       // stage str_id → "seed/rarity/type/upgradeLevel"
```

**Logic Rules (from slot_data):**
```actionscript
AV.serverData.stageTier:Object             // stage str_id → tier (int)
AV.serverData.stageSkills:Object           // stage str_id → Array<skill name>
AV.serverData.cumulativeSkillReqs:Object   // tier (as string) → { category: required count }
AV.serverData.tierStageCounts:Object       // tier (as string) → stage count
AV.serverData.tokenRequirementPercent:int  // percentage of tokens needed per tier
AV.serverData.freeStages:Array             // Array of stage str_ids (W1, W2, W3, W4)
```

**Game Options (from slot_data):**
```actionscript
AV.serverData.goal:int                     // 0=beat_game, 2=swarm_queen, 3=fields_count, 4=fields_percentage
AV.serverData.tomeXpLevels:Object          // { tattered:1, worn:2, ancient:3 }
AV.serverData.fieldTokenPlacement:int      // 0=own_world, 1=any_world, 2=different_world
AV.serverData.enforce_logic:Boolean
AV.serverData.disable_endurance:Boolean
AV.serverData.disable_trial:Boolean
AV.serverData.enemyMultipliers:Object      // { hp, armor, shield, waves, extraWaves }
AV.serverData.startingWizardLevel:int
AV.serverData.startingOvercrowd:Boolean
```

#### 3. **AV.gameData (in-game equivalents: hardcoded game knowledge)**
Static, game-specific mappings that never change:

**Skill/Trait Definitions:**
```actionscript
AV.gameData.skills:Array                   // [{ name, gameId, apId }, ...]
                                           // 24 skills, AP IDs 300-323

AV.gameData.battleTraits:Array             // [{ name, gameId, apId }, ...]
                                           // 15 traits, AP IDs 400-414

AV.gameData.skillCategories:Object         // skill name → category (from slot_data)
```

**ID Mappings:**
```actionscript
AV.gameData.stageLocIds:Object             // stage str_id → base Journey location AP ID
AV.gameData.apIdRanges:Object              // { skills: [300,323], traits: [400,414], tomes: [500,502], talismans: [700,799], shadowCores: [800,868] }
```

#### 4. **AV.saveData (runtime state: player progress)**
Mutable, per-session state that tracks what the player has unlocked/collected:

**Collected Items:**
```actionscript
AV.saveData.unlockedSkills:Object          // gameId → Boolean
AV.saveData.unlockedTraits:Object          // gameId → Boolean
AV.saveData.unlockedTokenStages:Object     // stage str_id → Boolean
AV.saveData.receivedTalismans:Array        // Array<TalismanFragment>
AV.saveData.totalShadowCores:int
AV.saveData.grantedApIds:Object            // apId → Boolean (deduplication for reconnects)
```

**Location & Item Tracking:**
```actionscript
AV.saveData.receivedItems:Array            // Array of received item objects { apId, itemName, fromSlot, fromWorld }
AV.saveData.receivedLocations:Object       // locId → Boolean (locations the player has found items at)
AV.saveData.missingLocations:Object        // locId → Boolean (from AP server - what still needs checking)
AV.saveData.checkedLocations:Object        // locId → Boolean (inverse tracking - locations already checked)
```

**Player State:**
```actionscript
AV.saveData.bonusWizardLevel:int
AV.saveData.deathLinkEnabled:Boolean
AV.saveData.isStandalone:Boolean
AV.saveData.completed:Boolean
```

---

## Utility Classes

Add to `AV` namespace:

### AV.LogicChecker
Handles stage reachability evaluation (mirrors apworld logic):
```actionscript
public static function isStageAccessible(stageStrId:String):Boolean
public static function getInLogicStages():Array
public static function getRequiredSkillsForStage(stageStrId:String):Array
public static function getMinSkillsNeeded(category:String, tier:int):int
```

### AV.ItemResolver
Maps AP IDs to display names (used by item notifications):
```actionscript
public static function getItemName(apId:int):String
public static function getItemType(apId:int):String  // "skill", "trait", "token", etc.
public static function getApIdRange(type:String):Array
```

---

## Migration Plan (Full Refactor)

### Phase 1: Create AV Class Structure
- Create `AV.as` with nested static classes for each domain
- Initialize all properties to empty/null

### Phase 2: Refactor All Consumers Simultaneously
Update all systems to read/write AV exclusively (one coordinated refactor):

| Current Class | Current Data | Refactor To |
|---------------|-------------|-------------|
| ConnectionManager | _tokenMap, _talismanMap, _shadowCoreMap, etc. | AV.serverData |
| CollectedState | _skillsCollected, _skillCountByCategory | AV.saveData.unlockedSkills |
| LogicEvaluator | _stageTier, _stageSkills, _cumulativeSkillReqs | AV.serverData |
| TalismanUnlocker | _talMap, _talNameMap, _grantedApIds | AV.serverData + AV.saveData |
| ShadowCoreUnlocker | _shadowCoreMap, _shadowCoreNameMap | AV.serverData + AV.saveData |
| SkillUnlocker/TraitUnlocker | Individual skill/trait tracking | AV.saveData |
| SaveManager | Custom JSON serialization | Serialize/deserialize AV.saveData |
| ModButtons | Read missingLocations from ConnectionManager | Read AV.saveData.missingLocations |

### Phase 3: Extract Utility Classes
Create AV.LogicChecker and AV.ItemResolver to consolidate logic:
- Move stage reachability logic from LogicEvaluator → AV.LogicChecker
- Move item name resolution from ConnectionManager → AV.ItemResolver

---

## Critical Files to Modify

1. **mods/ArchipelagoMod/src/AV.as** (NEW)
   - Define all nested classes and static properties
   - Initialize empty structures

2. **mods/ArchipelagoMod/src/net/ConnectionManager.as**
   - Populate AV.serverData in handleConnected()
   - Keep internal state for now (dual-write during transition)

3. **mods/ArchipelagoMod/src/ArchipelagoMod.as**
   - Initialize AV.gameData (skills, traits, stageLocIds, apIdRanges)
   - Initialize AV.saveData structure
   - Update onApConnected() to configure AV instead of passing data to individual classes

4. **mods/ArchipelagoMod/src/SaveManager.as**
   - Load/save AV.saveData object instead of custom JSON
   - Serialize/deserialize the nested structure
   - Persist: unlockedSkills, unlockedTraits, unlockedTokenStages, receivedTalismans, totalShadowCores, grantedApIds, receivedItems, receivedLocations, bonusWizardLevel, deathLinkEnabled, isStandalone, completed

5. **mods/ArchipelagoMod/src/unlockers/\*.as** (all)
   - Read from AV.serverData instead of ConnectionManager
   - Write to AV.saveData instead of custom tracking

6. **mods/ArchipelagoMod/src/tracker/LogicEvaluator.as**
   - Read rules from AV.serverData instead of storing copies

---

---

## Item Receipt & Location Tracking Rationale

By tracking **receivedItems**, **receivedLocations**, **missingLocations**, and **checkedLocations**, the mod maintains:

1. **Complete history** — every item received from AP is recorded with source (apId, slot, world)
2. **Location state** — know which locations have been checked vs still pending
3. **Persistence** — all receipt data saved to file, survives reconnects
4. **Deduplication** — combined with grantedApIds, prevents duplicate item grants on reconnect
5. **Debugging/transparency** — can see full item history for player reference

This comprehensive tracking enables:
- Showing players what they've received (tracker UI)
- Filtering by source world/player
- Verifying no items were missed on reconnect
- Sync validation before applying items

---

## Verification

After implementation:
1. **Connection flow:** AP connects → AV is fully populated → all systems use AV
2. **Item grant flow:** AP sends item → grant routes to correct unlocker → AV.saveData updated
3. **Save/load:** Slot data persists correctly via SaveManager using AV.saveData
4. **No breaking changes:** Existing code can continue to work (dual-read pattern if needed)
5. **Logic evaluation:** LogicChecker returns correct stage accessibility based on collected items
6. **Item names:** ItemResolver returns correct display names for notifications

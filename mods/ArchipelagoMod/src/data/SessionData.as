package data {

    /**
     * Per-session Archipelago state.  Populated from received items and cleared
     * on disconnect.  Stores both raw collection data and cached logic results so
     * evaluators write here once and all UI reads from a single place.
     *
     * collectedSkills / collectedTraits / collectedAchievements are convenience
     * subsets of collectedItems; callers can use whichever is most natural.
     *
     * fieldsInLogic and achievementsInLogic are written by FieldLogicEvaluator and
     * AchievementLogicEvaluator respectively.  They are updated only on AP connect
     * and on item received.
     */
    public class SessionData {

        // Skill names indexed by (apId - 700).  Shared constant used by
        // FieldLogicEvaluator and LogicEvaluator for requirement parsing.
        public static const SKILL_NAMES:Array = [
            "Mana Stream", "True Colors", "Fusion", "Orb of Presence",
            "Resonance", "Demolition", "Critical Hit", "Mana Leech",
            "Bleeding", "Armor Tearing", "Poison", "Slowing",
            "Freeze", "Whiteout", "Ice Shards", "Bolt",
            "Beam", "Barrage", "Fury", "Amplifiers",
            "Pylons", "Lanterns", "Traps", "Seeker Sense"
        ];

        // apId (String) -> true — all received AP items, single source of truth
        public var collectedItems:Object = {};
        // apId (String) -> int — count of times this AP id has been received.
        // Same id can arrive multiple times for items the apworld places as
        // duplicates (Progressive Gempouch, future Progressive items, etc.).
        public var itemCounts:Object = {};
        // sub-sets by type (convenience)
        public var collectedSkills:Object = {};        // skill AP ID (700-723) -> true
        public var collectedTraits:Object = {};        // trait AP ID (800-814) -> true
        public var collectedAchievements:Object = {};  // achievement AP ID (2000-2636) -> true
        // strId -> true — field tokens received (one entry per stage with a token)
        public var tokensByStrId:Object = {};
        // strId -> true — Wizard Stash unlock items received (per-stage gating).
        public var unlockedStashesByStrId:Object = {};
        // category name -> int — skill count per category (for tier skill gates)
        public var skillCountByCategory:Object = {};

        // Cached logic results — written by evaluators, read by UI
        public var fieldsInLogic:Object = {};              // strId -> true
        public var achievementsInLogic:Object = {};        // apId (int) -> true
        public var achievementNamesInLogic:Array = [];     // sorted achievement names

        // -----------------------------------------------------------------------
        // Setup

        private var _tokenMap:Object;            // apId (String) -> stage strId
        private var _skillNameToCategory:Object; // skill name -> category

        /**
         * Wire slot_data mappings.  Call after reset() and before any onItem() calls.
         * @param tokenMap        ConnectionManager.tokenMap (apId string -> stage strId)
         * @param skillCategories slot_data.skill_categories (category -> list of skill names)
         */
        public function configure(tokenMap:Object, skillCategories:Object):void {
            _tokenMap = tokenMap;
            _skillNameToCategory = {};
            for (var category:String in skillCategories) {
                var names:Array = skillCategories[category] as Array;
                if (names == null) continue;
                for each (var skillName:String in names) {
                    _skillNameToCategory[skillName] = category;
                }
                if (skillCountByCategory[category] == undefined) {
                    skillCountByCategory[category] = 0;
                }
            }
        }

        /** Clear all tracked state.  Call on disconnect or before full sync. */
        public function reset():void {
            collectedItems        = {};
            itemCounts            = {};
            collectedSkills       = {};
            collectedTraits       = {};
            collectedAchievements = {};
            tokensByStrId         = {};
            unlockedStashesByStrId = {};
            skillCountByCategory  = {};
            fieldsInLogic            = {};
            achievementsInLogic      = {};
            achievementNamesInLogic  = [];
        }

        /** Mark a stage's Wizard Stash unlock item as received. */
        public function markStashUnlocked(strId:String):void {
            if (strId != null) unlockedStashesByStrId[strId] = true;
        }

        /** Mark a stage as having its field token held. Used by coarse
         *  (per-tile / per-tier) and progressive field-token grant paths
         *  that don't go through _tokenMap in onItem. */
        public function markFieldTokenHeld(strId:String):void {
            if (strId != null) tokensByStrId[strId] = true;
        }

        /** True if the player has received the Wizard Stash unlock item for this stage. */
        public function isStashUnlocked(strId:String):Boolean {
            return unlockedStashesByStrId[strId] == true;
        }

        /**
         * True if the player owns the Gempouch covering this stage.
         * Granularity-aware (matches gemPouchGranularity in slot_data):
         *   0 (off)                   → always true
         *   1 (per_tile)              → Gempouch (<prefix>) item present
         *   2 (per_tile_progressive)  → N copies of Progressive Gempouch where
         *                               N is 1-based index in progressiveTileOrder
         *   3 (per_tier)              → Tier <N> Gempouch item present
         *   4 (per_tier_progressive)  → N copies of Progressive Gempouch (per-tier)
         *                               where N is 1-based index in progressiveTierOrder
         *   5 (global)                → Master Gempouch item present
         * Returns true on any unknown configuration so a misconfigured seed
         * never deadlocks the player.
         */
        public function hasPouchForStage(stageStrId:String):Boolean {
            if (AV.serverData == null || AV.serverData.serverOptions == null)
                return true;
            var opts:* = AV.serverData.serverOptions;
            var mode:int = int(opts.gemPouchGranularity);
            var prefix:String = stageStrId.charAt(0);

            if (mode == 1) {
                var orderD:Array = opts.gemPouchPlayOrder as Array;
                if (orderD == null || orderD.length == 0)
                    return true;
                var idxD:int = orderD.indexOf(prefix);
                if (idxD < 0)
                    return true;
                return hasItem(626 + idxD);
            }
            if (mode == 2) {
                var orderP:Array = opts.progressiveTileOrder as Array;
                if (orderP == null || orderP.length == 0)
                    orderP = opts.gemPouchPlayOrder as Array;
                if (orderP == null || orderP.length == 0)
                    return true;
                var idxP:int = orderP.indexOf(prefix);
                if (idxP < 0)
                    return true;
                var progId:int = int(opts.gemPouchProgressiveId);
                if (progId <= 0)
                    progId = 652;
                return getItemCount(progId) >= idxP + 1;
            }
            if (mode == 3) {
                var tier:int = _tierForStage(stageStrId);
                if (tier < 0)
                    return true;
                return hasItem(1601 + tier);
            }
            if (mode == 4) {
                var tier4:int = _tierForStage(stageStrId);
                if (tier4 < 0)
                    return true;
                var tierProgId:int = int(opts.gemPouchPerTierProgressiveId);
                if (tierProgId <= 0)
                    return true;
                var tierOrd:Array = opts.progressiveTierOrder as Array;
                if (tierOrd != null && tierOrd.length > 0) {
                    var posT:int = tierOrd.indexOf(tier4);
                    if (posT < 0)
                        return true;
                    return getItemCount(tierProgId) >= posT + 1;
                }
                return getItemCount(tierProgId) >= tier4 + 1;
            }
            if (mode == 5) {
                return hasItem(1614);
            }
            return true;
        }

        private function _tierForStage(stageStrId:String):int {
            if (AV.serverData == null || AV.serverData.serverOptions == null)
                return -1;
            var map:Object = AV.serverData.serverOptions.stageTierByStrId;
            if (map == null || map[stageStrId] == null)
                return -1;
            return int(map[stageStrId]);
        }

        /**
         * True if the player owns ANY Gempouch covering the given tile prefix
         * letter ("W", "S", ...). Used by tracker/logic evaluators that work
         * on tile sets rather than specific stages.
         *
         * Differs from hasPouchForStage for per-tier modes (3, 4): iterates
         * every stage with this prefix and OR's the per-tier checks — owning
         * the tier-pouch for any one of the prefix's stages counts as
         * covering the prefix.
         */
        public function hasPouchForPrefix(prefix:String):Boolean {
            if (prefix == null || prefix.length == 0)
                return true;
            if (AV.serverData == null || AV.serverData.serverOptions == null)
                return true;
            var opts:* = AV.serverData.serverOptions;
            var mode:int = int(opts.gemPouchGranularity);
            if (mode == 0)
                return true;
            if (mode == 5)
                return hasItem(1614);
            if (mode == 3 || mode == 4) {
                var tierMap:Object = opts.stageTierByStrId;
                if (tierMap == null)
                    return true;
                var tierProgId:int = int(opts.gemPouchPerTierProgressiveId);
                var tierOrd:Array = opts.progressiveTierOrder as Array;
                for (var sid:String in tierMap) {
                    if (sid.charAt(0) != prefix)
                        continue;
                    var st:int = int(tierMap[sid]);
                    if (mode == 3) {
                        if (hasItem(1601 + st))
                            return true;
                    } else if (tierProgId > 0) {
                        var posT:int = (tierOrd != null && tierOrd.length > 0)
                                          ? tierOrd.indexOf(st) : st;
                        if (posT >= 0 && getItemCount(tierProgId) >= posT + 1)
                            return true;
                    }
                }
                return false;
            }
            if (mode == 1) {
                var orderD:Array = opts.gemPouchPlayOrder as Array;
                if (orderD == null || orderD.length == 0)
                    return true;
                var idxD:int = orderD.indexOf(prefix);
                if (idxD < 0)
                    return true;
                return hasItem(626 + idxD);
            }
            var orderP:Array = opts.progressiveTileOrder as Array;
            if (orderP == null || orderP.length == 0)
                orderP = opts.gemPouchPlayOrder as Array;
            if (orderP == null || orderP.length == 0)
                return true;
            var idxP:int = orderP.indexOf(prefix);
            if (idxP < 0)
                return true;
            var progId:int = int(opts.gemPouchProgressiveId);
            if (progId <= 0)
                progId = 652;
            return getItemCount(progId) >= idxP + 1;
        }

        // -----------------------------------------------------------------------
        // Item tracking

        /** True if the AP item with this ID has been received. */
        public function hasItem(apId:int):Boolean {
            return collectedItems[String(apId)] == true;
        }

        /** Count of times this AP id has been received. 0 if never. */
        public function getItemCount(apId:int):int {
            var v:* = itemCounts[String(apId)];
            return (v == null) ? 0 : int(v);
        }

        /** Classify an incoming AP item and update all relevant collections.
         *  Increments itemCounts every call (Progressive items receive the
         *  same id N times); collectedItems / per-type subsets are idempotent. */
        public function onItem(apId:int):void {
            var key:String = String(apId);
            collectedItems[key] = true;
            itemCounts[key] = getItemCount(apId) + 1;

            // Field token -> stage strId
            if (_tokenMap != null) {
                var strId:String = _tokenMap[String(apId)];
                if (strId != null) {
                    tokensByStrId[strId] = true;
                    return;
                }
            }
            // Skill (700-723)
            if (apId >= 700 && apId <= 723) {
                collectedSkills[apId] = true;
                var gameId:int = apId - 700;
                if (gameId >= 0 && gameId < SKILL_NAMES.length && _skillNameToCategory != null) {
                    var cat:String = _skillNameToCategory[SKILL_NAMES[gameId]];
                    if (cat != null) {
                        skillCountByCategory[cat] = int(skillCountByCategory[cat]) + 1;
                    }
                }
                return;
            }
            // Trait (800-814)
            if (apId >= 800 && apId <= 814) {
                collectedTraits[apId] = true;
                return;
            }
            // Achievement (2000-2636)
            if (apId >= 2000 && apId <= 2636) {
                collectedAchievements[apId] = true;
                return;
            }
        }

        /** Mark an achievement as collected (sent check or received from another player). */
        public function onAchievementCollected(apId:int):void {
            if (apId >= 2000 && apId <= 2636) {
                collectedAchievements[apId] = true;
                collectedItems[String(apId)] = true;
            }
        }

        public function isAchievementCollected(apId:int):Boolean {
            return collectedAchievements[apId] == true;
        }

        /** Number of distinct skills received (0–24). */
        public function get totalSkillsCollected():int {
            var n:int = 0;
            for (var i:int = 0; i < 24; i++) {
                if (hasItem(700 + i)) n++;
            }
            return n;
        }

        /** Count how many AP IDs in [start, end] inclusive have been received. */
        public function countItemsInRange(start:int, end:int):int {
            var n:int = 0;
            for (var i:int = start; i <= end; i++) {
                if (hasItem(i)) n++;
            }
            return n;
        }
    }
}

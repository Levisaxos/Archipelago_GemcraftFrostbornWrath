package tracker {
    import Bezel.Logger;

    /**
     * Tracks which items the player has collected from Archipelago, classified
     * by the categories the LogicEvaluator needs (field tokens per stage,
     * skills by name, skill counts per category).
     *
     * Populated from ConnectionManager.onFullSync / onItemReceived.
     */
    public class CollectedState {

        // Skill names indexed by game_id (apId - 700).  Must match
        // unlockers.SkillUnlocker.SKILL_NAMES exactly.
        public static const SKILL_NAMES:Array = [
            "Mana Stream", "True Colors", "Fusion", "Orb of Presence",
            "Resonance", "Demolition", "Critical Hit", "Mana Leech",
            "Bleeding", "Armor Tearing", "Poison", "Slowing",
            "Freeze", "Whiteout", "Ice Shards", "Bolt",
            "Beam", "Barrage", "Fury", "Amplifiers",
            "Pylons", "Lanterns", "Traps", "Seeker Sense"
        ];

        private var _logger:Logger;
        private var _modName:String;

        private var _tokenMap:Object;            // apId (string) -> stage strId
        private var _skillNameToCategory:Object; // skill name -> category (populated from slot_data)

        private var _receivedApIds:Object = {};          // apId (string) -> true — ALL received items
        private var _tokensByStrId:Object = {};          // strId -> true
        private var _skillsCollected:Object = {};        // skill name -> true
        private var _skillCountByCategory:Object = {};   // category -> int
        private var _achievementsCollected:Object = {};  // apId (int) -> true

        public function CollectedState(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        public function get tokensByStrId():Object { return _tokensByStrId; }
        public function get skillsCollected():Object { return _skillsCollected; }
        public function get skillCountByCategory():Object { return _skillCountByCategory; }
        public function get achievementsCollected():Object { return _achievementsCollected; }

        /**
         * Configure with slot_data.  Must be called before onItem().
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
                if (_skillCountByCategory[category] == undefined) {
                    _skillCountByCategory[category] = 0;
                }
            }
        }

        /** Clear all tracked collection state.  Call on reconnect. */
        public function reset():void {
            _receivedApIds = {};
            _tokensByStrId = {};
            _skillsCollected = {};
            _skillCountByCategory = {};
            _achievementsCollected = {};
        }

        /**
         * Returns true if the given AP item ID has been received from the server.
         * Works for all item types: tokens, skills, traits, XP, talismans, shadow cores, achievements.
         */
        public function hasItem(apId:int):Boolean {
            return _receivedApIds[String(apId)] == true;
        }

        /** Classify an incoming AP item id and update counters.  Idempotent. */
        public function onItem(apId:int):void {
            // Master registry — capture every received AP item regardless of type.
            _receivedApIds[String(apId)] = true;

            // Field token -> stage
            if (_tokenMap != null) {
                var strId:String = _tokenMap[String(apId)];
                if (strId != null) {
                    if (_tokensByStrId[strId] != true) {
                        _tokensByStrId[strId] = true;
                    }
                    return;
                }
            }
            // Skill (AP ids 700-723)
            if (apId >= 700 && apId <= 723) {
                var gameId:int = apId - 700;
                if (gameId < 0 || gameId >= SKILL_NAMES.length) return;
                var name:String = SKILL_NAMES[gameId];
                if (_skillsCollected[name] == true) return;
                _skillsCollected[name] = true;
                if (_skillNameToCategory != null) {
                    var cat:String = _skillNameToCategory[name];
                    if (cat != null) {
                        _skillCountByCategory[cat] = int(_skillCountByCategory[cat]) + 1;
                    }
                }
                return;
            }
            // Achievement (AP ids 2000-2636)
            if (apId >= 2000 && apId <= 2636) {
                if (_achievementsCollected[apId] != true) {
                    _achievementsCollected[apId] = true;
                }
                return;
            }
            // Other item kinds are not tracker-relevant.
        }

        /**
         * Mark an achievement as collected (called when receiving achievement from another player).
         */
        public function onAchievementCollected(apId:int):void {
            if (apId >= 2000 && apId <= 2636) {
                _achievementsCollected[apId] = true;
            }
        }

        /**
         * Check if an achievement has been collected.
         * @param apId The Archipelago item ID (2000-2636)
         * @return true if collected, false otherwise
         */
        public function isAchievementCollected(apId:int):Boolean {
            return _achievementsCollected[apId] == true;
        }

        /** Number of distinct skills collected (0..24), based on AP items received. */
        public function get totalSkillsCollected():int {
            var n:int = 0;
            for (var i:int = 0; i < 24; i++) {
                if (hasItem(300 + i)) n++;
            }
            return n;
        }
    }
}

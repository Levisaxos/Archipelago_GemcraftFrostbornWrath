package tracker {
    import Bezel.Logger;
    import data.AV;
    import data.EmbeddedData;

    /**
     * Determines which achievements are currently in-logic (reachable with the
     * player's collected items).  Extracted from AchievementUnlocker so the
     * in-logic computation is separate from achievement detection/sending.
     *
     * Delegates individual requirement evaluation to LogicEvaluator.
     * After recompute, writes the result set to AV.sessionData.achievementsInLogic
     * so AchievementPanelPatcher can read it without holding a reference here.
     *
     * Dirty-flag approach: markDirty() on item received, lazy recompute on
     * getInLogicAchApIds().
     */
    public class AchievementLogicEvaluator {

        private var _logger:Logger;
        private var _modName:String;

        private var _achievementData:Object = {}; // name -> { apId, requirements, ... }
        private var _elementStages:Object   = {}; // element name -> Array<String>
        private var _fieldEvaluator:FieldLogicEvaluator;
        private var _logicEvaluator:LogicEvaluator;

        private var _dirty:Boolean = true;

        public function AchievementLogicEvaluator(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        // -----------------------------------------------------------------------
        // Setup

        /**
         * Load achievement_logic.json from embedded resources.
         * Call once from ArchipelagoMod.bind().
         */
        public function loadData():void {
            try {
                var json:String = EmbeddedData.getAchievementLogicJSON();
                if (!json || json.length == 0) {
                    _logger.log(_modName, "AchievementLogicEvaluator.loadData: JSON empty");
                    return;
                }
                var parsed:Object = JSON.parse(json);
                if (parsed) {
                    _achievementData = parsed.achievements || parsed;
                    _elementStages   = parsed.element_stages || {};
                    var count:int = 0;
                    for (var k:String in _achievementData) count++;
                    _logger.log(_modName, "AchievementLogicEvaluator.loadData: loaded " + count + " achievements");
                }
            } catch (e:Error) {
                _logger.log(_modName, "AchievementLogicEvaluator.loadData error: " + e.message);
            }
        }

        /**
         * Wire evaluator dependencies.  Call on AP connect (after FieldLogicEvaluator
         * is configured so elementStages can be forwarded to LogicEvaluator).
         */
        public function configure(fieldEvaluator:FieldLogicEvaluator,
                                  logicEvaluator:LogicEvaluator):void {
            _fieldEvaluator = fieldEvaluator;
            _logicEvaluator = logicEvaluator;
            _logicEvaluator.configure(fieldEvaluator, _elementStages);
            _dirty = true;
        }

        public function markDirty():void { _dirty = true; }

        // -----------------------------------------------------------------------
        // Queries

        /**
         * Return apId->true for every achievement that is still missing and
         * whose requirements are currently met.  Triggers recompute if dirty.
         * Result is also written to AV.sessionData.achievementsInLogic.
         */
        public function getInLogicAchApIds():Object {
            if (_dirty) _recompute();
            return AV.sessionData.achievementsInLogic;
        }

        /**
         * Return apId->true for every achievement that has no requirements
         * (i.e. always receives a filler item and is excluded from logic).
         * The set is static — call once after loadData().
         */
        public function getExcludedAchApIds():Object {
            var result:Object = {};
            for (var achName:String in _achievementData) {
                var achData:Object = _achievementData[achName];
                if (!achData || !achData.apId) continue;
                if (achData.always_as_filler === true) {
                    result[int(achData.apId)] = true;
                }
            }
            return result;
        }

        /** Check requirements for a single achievement without using the cache. */
        public function isAchievementInLogic(achName:String, achData:Object):Boolean {
            if (!achData) return false;
            if (!achData.requirements) return true;
            var reqs:Array = achData.requirements as Array;
            if (!reqs || reqs.length == 0) return true;
            return _logicEvaluator != null && _logicEvaluator.evaluateRequirements(reqs);
        }

        /**
         * Return apId->true for every AP achievement whose requirements are
         * currently met, regardless of whether it has been collected yet.
         * Applies the same mode and effort filters as getInLogicAchApIds().
         * Used for the visual green/red dot indicators on achievement icons.
         */
        public function getRequirementsMetApIds():Object {
            var result:Object = {};
            if (_logicEvaluator == null || _achievementData == null) return result;

            var requiredEffort:int = (AV.serverData != null && AV.serverData.serverOptions != null)
                ? AV.serverData.serverOptions.achievementRequiredEffort : 0;
            var effortHierarchy:Array = ["Trivial", "Minor", "Major", "Extreme"];
            var maxEffortStr:String = (requiredEffort > 0 && requiredEffort <= 4)
                ? effortHierarchy[requiredEffort - 1]
                : "Trivial";

            try {
                for (var achName:String in _achievementData) {
                    var achData:Object = _achievementData[achName];
                    if (!achData || !achData.apId) continue;

                    var modes:Array = achData.modes as Array;
                    if (modes != null && modes.indexOf("journey") < 0) continue;

                    var achEffort:String = achData.required_effort || "Trivial";
                    if (effortHierarchy.indexOf(achEffort) > effortHierarchy.indexOf(maxEffortStr)) continue;

                    if (isAchievementInLogic(achName, achData)) {
                        result[int(achData.apId)] = true;
                    }
                }
            } catch (e:Error) {
                _logger.log(_modName, "getRequirementsMetApIds error: " + e.message);
            }
            return result;
        }

        /**
         * Returns [text, color] pairs describing failing requirements for the
         * achievement identified by apId.  Empty if in logic, excluded, or not found.
         */
        public function getFailingReqLines(apId:int):Array {
            if (_logicEvaluator == null) return [];
            for (var k:String in _achievementData) {
                var d:Object = _achievementData[k];
                if (d == null || int(d.apId) != apId) continue;
                var reqs:Array = d.requirements as Array;
                if (reqs == null || reqs.length == 0) return [];
                var descs:Array = _logicEvaluator.getFailingReqDescriptions(reqs);
                var result:Array = [];
                for each (var desc:String in descs) {
                    if (desc != null) result.push([desc, 0xCCCCCC]);
                }
                return result;
            }
            return [];
        }

        // -----------------------------------------------------------------------
        // Private

        private function _recompute():void {
            var result:Object = {};
            var names:Array   = [];

            if (_logicEvaluator == null || _achievementData == null) {
                AV.sessionData.achievementsInLogic     = result;
                AV.sessionData.achievementNamesInLogic = names;
                _dirty = false;
                return;
            }

            var missing:Object     = AV.saveData.missingLocations;
            var requiredEffort:int = AV.serverData.serverOptions.achievementRequiredEffort;
            var effortHierarchy:Array = ["Trivial", "Minor", "Major", "Extreme"];
            var maxEffortStr:String = (requiredEffort > 0 && requiredEffort <= 4)
                ? effortHierarchy[requiredEffort - 1]
                : "Trivial";

            for (var achName:String in _achievementData) {
                var achData:Object = _achievementData[achName];
                if (!achData || !achData.apId) continue;

                var apId:int = int(achData.apId);

                // Journey-only check
                var modes:Array = achData.modes as Array;
                if (modes != null && modes.indexOf("journey") < 0) continue;

                // Effort filter
                var achEffort:String = achData.required_effort || "Trivial";
                if (effortHierarchy.indexOf(achEffort) > effortHierarchy.indexOf(maxEffortStr)) continue;

                if (missing[apId] == true && isAchievementInLogic(achName, achData)) {
                    result[apId] = true;
                    names.push(achName);
                }
            }

            names.sort(Array.CASEINSENSITIVE);
            AV.sessionData.achievementsInLogic     = result;
            AV.sessionData.achievementNamesInLogic = names;
            _dirty = false;
        }
    }
}

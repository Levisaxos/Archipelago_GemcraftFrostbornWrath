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

        private
        var _logger: Logger;
        private
        var _modName: String;

        private
        var _achievementData: Object = {}; // name -> { apId, requirements, ... }
        private
        var _elementStages: Object = {}; // element name -> Array<String>
        private
        var _levelStats: Object = {}; // strId -> monster stat data
        private
        var _fieldEvaluator: FieldLogicEvaluator;
        private
        var _logicEvaluator: LogicEvaluator;

        private
        var _dirty: Boolean = true;
        private
        var _lastWL: int = -1; // wizard level at last recompute (for staleness)

        public
        function AchievementLogicEvaluator(logger: Logger, modName: String) {
            _logger = logger;
            _modName = modName;
        }

        // -----------------------------------------------------------------------
        // Setup

        /**
         * Load achievement_logic.json from embedded resources.
         * Call once from ArchipelagoMod.bind().
         */
        public
        function loadData(): void {
            try {
                var json: String = EmbeddedData.getAchievementLogicJSON();
                if (!json || json.length == 0) {
                    _logger.log(_modName, "AchievementLogicEvaluator.loadData: JSON empty");
                    return;
                }
                var parsed: Object = JSON.parse(json);
                if (parsed) {
                    _achievementData = parsed.achievements || parsed;
                    _elementStages = parsed.element_stages || {};
                    _levelStats = parsed.levelStats || {};
                    if (_fieldEvaluator != null) {
                        _fieldEvaluator.setLevelStats(_levelStats);
                    }
                    var count: int = 0;
                    for (var k: String in _achievementData) count++;
                    _logger.log(_modName, "AchievementLogicEvaluator.loadData: loaded " + count + " achievements");
                }
            } catch (e: Error) {
                _logger.log(_modName, "AchievementLogicEvaluator.loadData error: " + e.message);
            }
        }

        /**
         * Wire evaluator dependencies.  Call on AP connect (after FieldLogicEvaluator
         * is configured so elementStages can be forwarded to LogicEvaluator).
         */
        public
        function configure(fieldEvaluator: FieldLogicEvaluator,
            logicEvaluator: LogicEvaluator): void {
            _fieldEvaluator = fieldEvaluator;
            _logicEvaluator = logicEvaluator;
            _fieldEvaluator.setLevelStats(_levelStats);
            _logicEvaluator.configure(fieldEvaluator, _elementStages);
            _dirty = true;
        }

        public
        function markDirty(): void {
            _dirty = true;
        }

        // -----------------------------------------------------------------------
        // Queries

        /**
         * Return apId->true for every achievement that is still missing and
         * whose requirements are currently met.  Triggers recompute if dirty.
         * Result is also written to AV.sessionData.achievementsInLogic.
         */
        public
        function getInLogicAchApIds(): Object {
            var wl: int = (_fieldEvaluator != null) ? _fieldEvaluator.derivedWizardLevel() : 0;
            if (_dirty || wl != _lastWL) _recompute();
            return AV.sessionData.achievementsInLogic;
        }

        /**
         * Return apId->true for every achievement marked `untrackable` in the
         * data file (RNG-dependent, hidden-mod-only, or otherwise not gateable
         * at gen time). These always receive a filler item and are excluded
         * from logic. The set is static — call once after loadData().
         */
        public
        function getExcludedAchApIds(): Object {
            var result: Object = {};
            for (var achName: String in _achievementData) {
                var achData: Object = _achievementData[achName];
                if (!achData || !achData.apId) continue;
                if (achData.untrackable === true) {
                    result[int(achData.apId)] = true;
                }
            }
            return result;
        }

        /**
         * Return apId->true for every achievement filtered out by the yaml
         * achievement_required_effort setting (effort exceeds the threshold).
         * Excludes untrackable achievements (they are in getExcludedAchApIds).
         */
        public
        function getEffortExcludedAchApIds(): Object {
            var result: Object = {};
            if (AV.serverData == null || AV.serverData.serverOptions == null) return result;
            var effortHierarchy: Array = ["Trivial", "Minor", "Major", "Extreme"];
            var maxEffortStr: String = getMaxEffortLabel();
            for (var achName: String in _achievementData) {
                var achData: Object = _achievementData[achName];
                if (!achData || !achData.apId) continue;
                if (achData.untrackable === true) continue;
                var modes: Array = achData.modes as Array;
                if (modes != null && modes.indexOf("journey") < 0) continue;
                var achEffort: String = achData.required_effort || "Trivial";
                if (effortHierarchy.indexOf(achEffort) > effortHierarchy.indexOf(maxEffortStr)) {
                    result[int(achData.apId)] = true;
                }
            }
            return result;
        }

        /** Returns the human-readable label for the current achievement_required_effort setting. */
        public
        function getMaxEffortLabel(): String {
            if (AV.serverData == null || AV.serverData.serverOptions == null) return "Trivial";
            var requiredEffort: int = AV.serverData.serverOptions.achievementRequiredEffort;
            var effortHierarchy: Array = ["Trivial", "Minor", "Major", "Extreme"];
            return (requiredEffort > 0 && requiredEffort <= 4) ?
                effortHierarchy[requiredEffort - 1] :
                "Trivial";
        }

        /** Field evaluator. Public for tooltip overlays. */
        public
        function get fieldEvaluator(): FieldLogicEvaluator {
            return _fieldEvaluator;
        }

        /** Minimum wizard level for an achievement. A per-achievement
         *  `min_wl:N` token in the requirements OVERRIDES the effort-tier
         *  default (achievementMinWl[effort], shipped in slot_data); otherwise
         *  the effort-tier value applies. Mirrors apworld rules._extract_min_wl
         *  + set_rules override. */
        private
        function achMinWl(achData: Object): int {
            var wlOverride: int = _extractMinWl(achData ? achData.requirements as Array : null);
            if (wlOverride >= 0) return wlOverride;
            var effort: String = (achData && achData.required_effort)
                ? String(achData.required_effort) : "Trivial";
            var map: Object = (AV.serverData != null && AV.serverData.serverOptions != null)
                ? AV.serverData.serverOptions.achievementMinWl : null;
            if (map != null && map[effort] !== undefined) return int(map[effort]);
            return 0;
        }

        /** Scan `requirements` (flat or DNF) for a `min_wl:N` token and return
         *  the largest N found, or -1 if absent. Treated as a top-level pacing
         *  override regardless of which OR-group it sits in. */
        private
        function _extractMinWl(requirements: Array): int {
            if (requirements == null || requirements.length == 0) return -1;
            var groups: Array = (requirements[0] is Array) ? requirements : [requirements];
            var best: int = -1;
            for each (var group: * in groups)
            {
                var andGroup: Array = group as Array;
                if (andGroup == null) continue;
                for each (var tok: * in andGroup)
                {
                    if (!(tok is String)) continue;
                    var t: String = String(tok).replace(/^\s+|\s+$/g, "");
                    var ci: int = t.indexOf(":");
                    if (ci <= 0 || t.substring(0, ci) != "min_wl") continue;
                    var n: int = int(t.substring(ci + 1).replace(/^\s+|\s+$/g, ""));
                    if (n > best) best = n;
                }
            }
            return best;
        }

        /** In-logic gate — mirrors the apworld achievement access rule:
         *    derived WL >= ACH_MIN_WL[effort]  AND  every requirement satisfiable.
         *  Runs the FULL requirement check (elements, counters, Field_ prereqs,
         *  skills, traits) via LogicEvaluator.evaluateRequirements, so "in logic"
         *  means the achievement is actually reachable with the player's current
         *  items — matching the apworld rule, which compiles ALL requirement
         *  tokens. (This replaces the old skill/trait-only gate, which turned the
         *  green dot on as soon as skills/traits + WL were met, even when an
         *  element/counter/field requirement was still unmet.)
         *  min_wl stays a top-level WL floor here; inside evaluateRequirements it
         *  falls through as an unknown token, so it must be checked separately. */
        public
        function isAchievementInLogic(achName: String, achData: Object): Boolean {
            if (!achData) return false;
            if (_fieldEvaluator == null) return true;
            if (_fieldEvaluator.derivedWizardLevel() < achMinWl(achData))
                return false;
            if (_logicEvaluator != null
                    && !_logicEvaluator.evaluateRequirements(achData.requirements as Array))
                return false;
            return true;
        }

        /**
         * Return apId->true for every AP achievement whose requirements are
         * currently met, regardless of whether it has been collected yet.
         * Applies the same mode and effort filters as getInLogicAchApIds().
         * Used for the visual green/red dot indicators on achievement icons.
         */
        public
        function getRequirementsMetApIds(): Object {
            var result: Object = {};
            if (_logicEvaluator == null || _achievementData == null) return result;

            var requiredEffort: int = (AV.serverData != null && AV.serverData.serverOptions != null) ?
                AV.serverData.serverOptions.achievementRequiredEffort : 0;
            var effortHierarchy: Array = ["Trivial", "Minor", "Major", "Extreme"];
            var maxEffortStr: String = (requiredEffort > 0 && requiredEffort <= 4) ?
                effortHierarchy[requiredEffort - 1] :
                "Trivial";

            try {
                for (var achName: String in _achievementData) {
                    var achData: Object = _achievementData[achName];
                    if (!achData || !achData.apId) continue;

                    if (achData.untrackable === true) continue;

                    var modes: Array = achData.modes as Array;
                    if (modes != null && modes.indexOf("journey") < 0) continue;

                    var achEffort: String = achData.required_effort || "Trivial";
                    if (effortHierarchy.indexOf(achEffort) > effortHierarchy.indexOf(maxEffortStr)) continue;

                    if (isAchievementInLogic(achName, achData)) {
                        result[int(achData.apId)] = true;
                    }
                }
            } catch (e: Error) {
                _logger.log(_modName, "getRequirementsMetApIds error: " + e.message);
            }
            return result;
        }

        /**
         * Returns [text, color] pairs describing failing requirements for the
         * achievement identified by apId.  Empty if in logic, excluded, or not found.
         */
        public
        function getFailingReqLines(apId: int): Array {
            if (_logicEvaluator == null) return [];
            for (var k: String in _achievementData) {
                var d: Object = _achievementData[k];
                if (d == null || int(d.apId) != apId) continue;
                var reqs: Array = d.requirements as Array;
                if (reqs == null || reqs.length == 0) return [];
                var descs: Array = _logicEvaluator.getFailingReqDescriptions(reqs);
                var result: Array = [];
                for each(var desc: String in descs) {
                    if (desc != null) result.push([desc, 0xCCCCCC]);
                }
                return result;
            }
            return [];
        }

        // -----------------------------------------------------------------------
        // Private

        private
        function _recompute(): void {
            var result: Object = {};
            var names: Array = [];

            if (_logicEvaluator == null || _achievementData == null) {
                AV.sessionData.achievementsInLogic = result;
                AV.sessionData.achievementNamesInLogic = names;
                _dirty = false;
                return;
            }

            // Force field recompute first so AV.sessionData.fieldsInLogic is
            // current before we evaluate any same-stage-bound requirement.
            // LogicEvaluator._evaluateAndGroupBound (and a couple of other
            // gates) read fieldsInLogic directly without going through the
            // field evaluator's lazy gate, so if the field evaluator is
            // dirty when we start iterating, the first per-stage-bound ach
            // we hit will get a stale answer and cache it for the session.
            if (_fieldEvaluator != null) _fieldEvaluator.recompute();

            var missing: Object = AV.saveData.missingLocations;
            var requiredEffort: int = AV.serverData.serverOptions.achievementRequiredEffort;
            var effortHierarchy: Array = ["Trivial", "Minor", "Major", "Extreme"];
            var maxEffortStr: String = (requiredEffort > 0 && requiredEffort <= 4) ?
                effortHierarchy[requiredEffort - 1] :
                "Trivial";

            for (var achName: String in _achievementData) {
                var achData: Object = _achievementData[achName];
                if (!achData || !achData.apId) continue;

                var apId: int = int(achData.apId);

                // Untrackable achievements are design-excluded, never in logic
                if (achData.untrackable === true) continue;

                // Journey-only check
                var modes: Array = achData.modes as Array;
                if (modes != null && modes.indexOf("journey") < 0) continue;

                // Effort filter
                var achEffort: String = achData.required_effort || "Trivial";
                if (effortHierarchy.indexOf(achEffort) > effortHierarchy.indexOf(maxEffortStr)) continue;

                if (missing[apId] == true && isAchievementInLogic(achName, achData)) {
                    result[apId] = true;
                    names.push(achName);
                }
            }

            names.sort(Array.CASEINSENSITIVE);
            AV.sessionData.achievementsInLogic = result;
            AV.sessionData.achievementNamesInLogic = names;
            _lastWL = (_fieldEvaluator != null) ? _fieldEvaluator.derivedWizardLevel() : 0;
            _dirty = false;
        }
    }
}

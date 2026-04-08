package tracker {
    import Bezel.Logger;

    /**
     * Mirrors apworld/gcfw/rules.py to determine which stages are currently
     * in logic based on collected items.  Ships with slot_data-provided
     * rule tables so apworld stays the single source of truth.
     *
     * Algorithm (matches rules._has_tier_tokens + set_rules):
     *   reachableTier = highest tier T such that for every 0 < t <= T:
     *     - previous tier has >= floor(len(TIERS[t-1]) * pct / 100) collected tokens
     *     - per category, cumulativeSkillReqs[t][cat] <= skillCountByCategory[cat]
     *   Stage is in logic if:
     *     - stage is a free stage, OR
     *     - stageTier[strId] <= reachableTier
     *   Per-location WIZLOCK (stage_skills) is handled at location level, not here.
     */
    public class LogicEvaluator {

        // Stages whose Journey/Bonus locations require ALL 24 skills.
        // Matches rules.py "A4 locations + Victory" block.
        public static const ALL_SKILLS_STAGES:Object = { "A4": true };

        private var _logger:Logger;
        private var _modName:String;
        private var _state:CollectedState;

        // slot_data rule tables
        private var _stageTier:Object;        // strId -> tier (int)
        private var _stageSkills:Object;      // strId -> Array<String>
        private var _cumulativeSkillReqs:Object; // "t" -> { category: count }
        private var _tierStageCounts:Object;  // "t" -> int
        private var _tokenPct:int = 100;
        private var _freeStages:Object = {};  // strId -> true

        private var _dirty:Boolean = true;
        private var _reachableTier:int = -1;
        private var _inLogicByStrId:Object = {};

        public function LogicEvaluator(logger:Logger, modName:String, state:CollectedState) {
            _logger  = logger;
            _modName = modName;
            _state   = state;
        }

        /**
         * Feed slot_data rule tables.  Call once after Connected packet.
         * All arguments may be null if the apworld didn't ship them (older
         * versions) — in that case every stage will be reported in-logic.
         */
        public function configure(stageTier:Object,
                                  stageSkills:Object,
                                  cumulativeSkillReqs:Object,
                                  tierStageCounts:Object,
                                  tokenPct:int,
                                  freeStages:Array):void {
            _stageTier = stageTier;
            _stageSkills = stageSkills;
            _cumulativeSkillReqs = cumulativeSkillReqs;
            _tierStageCounts = tierStageCounts;
            _tokenPct = tokenPct > 0 ? tokenPct : 100;
            _freeStages = {};
            if (freeStages != null) {
                for each (var sid:String in freeStages) {
                    _freeStages[sid] = true;
                }
            }
            _dirty = true;
        }

        public function markDirty():void { _dirty = true; }

        public function get hasRules():Boolean { return _stageTier != null; }

        /** True iff at least one missing location on this stage is currently in logic. */
        public function isStageInLogic(strId:String):Boolean {
            if (_dirty) recompute();
            return _inLogicByStrId[strId] == true;
        }

        /**
         * Per-location reachability: does this stage have at least one missing
         * location that is in logic?  The caller provides the three booleans
         * indicating which of the stage's 3 locations are still missing.
         */
        public function stageHasInLogicMissing(strId:String,
                                               journeyMissing:Boolean,
                                               bonusMissing:Boolean,
                                               stashMissing:Boolean):Boolean {
            if (_dirty) recompute();
            if (!(journeyMissing || bonusMissing || stashMissing)) return false;

            // Stash has no skill gate at location level — only the tier gate
            // (which is the same as "stage in logic" for reachability purposes).
            var stageReachable:Boolean = _inLogicByStrId[strId] == true;
            if (!stageReachable) return false;

            if (stashMissing) return true;

            // Journey / Bonus are gated by stage_skills (WIZLOCK) and, for A4,
            // by the full 24-skill requirement.
            if (journeyMissing || bonusMissing) {
                var skillsOk:Boolean = skillGateMet(strId);
                if (!skillsOk) return false;
                if (ALL_SKILLS_STAGES[strId] == true && _state.totalSkillsCollected < 24) {
                    return false;
                }
                return true;
            }
            return false;
        }

        private function skillGateMet(strId:String):Boolean {
            if (_stageSkills == null) return true;
            var required:Array = _stageSkills[strId] as Array;
            if (required == null || required.length == 0) return true;
            var have:Object = _state.skillsCollected;
            for each (var skillName:String in required) {
                if (have[skillName] != true) return false;
            }
            return true;
        }

        private function recompute():void {
            _inLogicByStrId = {};
            _reachableTier = -1;

            if (_stageTier == null) {
                // No rules -> can't evaluate; fall back to "everything in logic"
                _reachableTier = 999;
                _dirty = false;
                return;
            }

            // Determine highest contiguously-reachable tier.
            var t:int = 0;
            while (true) {
                var ok:Boolean = true;
                if (t > 0) {
                    ok = tierTokensMet(t) && tierSkillsMet(t);
                }
                if (!ok) break;
                _reachableTier = t;
                t++;
                if (t > 50) break; // safety
                if (_tierStageCounts[String(t)] == undefined
                    && _cumulativeSkillReqs[String(t)] == undefined) {
                    // Beyond the defined tiers — stop.
                    break;
                }
            }

            // Mark each stage.
            for (var strId:String in _stageTier) {
                var tier:int = int(_stageTier[strId]);
                var inLogic:Boolean = _freeStages[strId] == true || tier <= _reachableTier;
                _inLogicByStrId[strId] = inLogic;
            }
            // Free stages (W1-W4) are not in _stageTier because they have no
            // token items, but they are always reachable from W1.
            for (var freeSid:String in _freeStages) {
                _inLogicByStrId[freeSid] = true;
            }
            _dirty = false;
        }

        /** Floor-division match of rules.py _has_tier_tokens. */
        private function tierTokensMet(tier:int):Boolean {
            var prev:int = tier - 1;
            var prevCount:int = int(_tierStageCounts[String(prev)]);
            if (prevCount <= 0) return true;
            var needed:int = int((prevCount * _tokenPct) / 100); // floor
            if (needed <= 0) return true;

            // Count collected tokens whose stage tier == prev.
            var have:int = 0;
            var tokens:Object = _state.tokensByStrId;
            for (var sid:String in tokens) {
                if (int(_stageTier[sid]) == prev) {
                    have++;
                    if (have >= needed) return true;
                }
            }
            return have >= needed;
        }

        private function tierSkillsMet(tier:int):Boolean {
            if (_cumulativeSkillReqs == null) return true;
            var reqs:Object = _cumulativeSkillReqs[String(tier)];
            if (reqs == null) return true;
            var counts:Object = _state.skillCountByCategory;
            for (var cat:String in reqs) {
                if (int(counts[cat]) < int(reqs[cat])) return false;
            }
            return true;
        }

        public function get reachableTier():int { return _reachableTier; }
    }
}

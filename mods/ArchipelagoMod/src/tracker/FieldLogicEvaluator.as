package tracker {
    import Bezel.Logger;
    import data.AV;
    import data.SessionData;

    /**
     * Mirrors apworld/gcfw/rules.py to determine which stages are currently
     * in logic based on collected items.  Ships with slot_data-provided rule
     * tables so the apworld stays the single source of truth.
     *
     * Reads item state from AV.sessionData (populated by onItem calls).
     * After every recompute, writes the result to AV.sessionData.fieldsInLogic
     * so UI components can read it without holding a reference to this class.
     *
     * Algorithm (matches rules._has_tier_tokens + set_rules):
     *   reachableTier = highest tier T such that for every 0 < t <= T:
     *     - previous tier has >= floor(len(TIERS[t-1]) * pct / 100) collected tokens
     *     - per category, cumulativeSkillReqs[t][cat] <= skillCountByCategory[cat]
     *   Stage is in logic if:
     *     - stage is a free stage (W1-W4), OR
     *     - stageTier[strId] <= reachableTier
     */
    public class FieldLogicEvaluator {

        // Stages whose Journey/Bonus locations require ALL 24 skills.
        public static const ALL_SKILLS_STAGES:Object = { "A4": true };

        private var _logger:Logger;
        private var _modName:String;

        // slot_data rule tables
        private var _stageTier:Object;           // strId -> tier (int)
        private var _stageSkills:Object;         // strId -> Array<String>
        private var _cumulativeSkillReqs:Object; // "t" -> { category: count }
        private var _tierStageCounts:Object;     // "t" -> int
        private var _tokenPct:int = 100;
        private var _freeStages:Object = {};     // strId -> true

        private var _dirty:Boolean = true;
        private var _reachableTier:int = -1;
        private var _inLogicByStrId:Object = {};

        public function FieldLogicEvaluator(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        /**
         * Feed slot_data rule tables.  Call once after the Connected packet.
         * Null arguments fall back to "all stages in logic" (older apworld).
         */
        public function configure(stageTier:Object,
                                  stageSkills:Object,
                                  cumulativeSkillReqs:Object,
                                  tierStageCounts:Object,
                                  tokenPct:int,
                                  freeStages:Array):void {
            _stageTier           = stageTier;
            _stageSkills         = stageSkills;
            _cumulativeSkillReqs = cumulativeSkillReqs;
            _tierStageCounts     = tierStageCounts;
            _tokenPct            = tokenPct > 0 ? tokenPct : 100;
            _freeStages          = {};
            if (freeStages != null) {
                for each (var sid:String in freeStages) {
                    _freeStages[sid] = true;
                }
            }
            _dirty = true;
        }

        public function markDirty():void { _dirty = true; }

        public function get hasRules():Boolean { return _stageTier != null; }
        public function get reachableTier():int { return _reachableTier; }

        // -----------------------------------------------------------------------
        // Public queries

        /** True if this stage is currently reachable (in logic). */
        public function isStageInLogic(strId:String):Boolean {
            if (_stageTier == null) return true;
            if (_dirty) recompute();
            return _inLogicByStrId[strId] == true;
        }

        /**
         * True if the stage is reachable AND at least one of the provided missing
         * locations is reachable.  Used by StageTinter (per-frame) and ModButtons.
         */
        public function stageHasInLogicMissing(strId:String,
                                               journeyMissing:Boolean,
                                               bonusMissing:Boolean,
                                               stashMissing:Boolean):Boolean {
            if (!(journeyMissing || bonusMissing || stashMissing)) return false;
            if (_stageTier == null) return true;
            if (_dirty) recompute();

            var stageReachable:Boolean = _inLogicByStrId[strId] == true;
            if (!stageReachable) return false;

            // Stash only needs the tier gate — no skill requirement.
            if (stashMissing) return true;

            // Journey / Bonus are additionally gated by stage_skills (WIZLOCK)
            // and, for A4, by the full 24-skill requirement.
            if (journeyMissing || bonusMissing) {
                if (!_skillGateMet(strId)) return false;
                if (ALL_SKILLS_STAGES[strId] == true
                        && AV.sessionData.totalSkillsCollected < 24) {
                    return false;
                }
                return true;
            }
            return false;
        }

        /**
         * True if any in-logic stage has at least minWaveCount waves.
         * Wave tier thresholds match rulesdata_settings.py WAVE_TIERS.
         */
        public function hasInLogicFieldWithMinWaves(minWaveCount:int):Boolean {
            var waveTiers:Array = [14, 22, 28, 33, 40, 48, 54, 60, 70, 72, 78, 84, 96];

            if (minWaveCount > 96) return false; // endurance/trial only

            var requiredTier:int = -1;
            for (var i:int = 0; i < waveTiers.length; i++) {
                if (int(waveTiers[i]) >= minWaveCount) {
                    requiredTier = i;
                    break;
                }
            }

            if (_stageTier == null) return true;
            if (_dirty) recompute(); // was incorrectly "return false" before fix

            for (var strId:String in _stageTier) {
                if (int(_stageTier[strId]) >= requiredTier
                        && _inLogicByStrId[strId] == true) {
                    return true;
                }
            }
            return false;
        }

        // -----------------------------------------------------------------------
        // Recompute

        /** Recalculate reachable tiers and in-logic stages; write to AV.sessionData. */
        public function recompute():void {
            _inLogicByStrId = {};
            _reachableTier  = -1;

            if (_stageTier == null) {
                _reachableTier = 999;
                _dirty = false;
                AV.sessionData.fieldsInLogic = _inLogicByStrId;
                return;
            }

            // Find highest contiguously-reachable tier.
            var t:int = 0;
            while (true) {
                var ok:Boolean = t == 0 || (_tierTokensMet(t) && _tierSkillsMet(t));
                if (!ok) break;
                _reachableTier = t;
                t++;
                if (t > 50) break;
                if (_tierStageCounts[String(t)] == undefined
                        && _cumulativeSkillReqs[String(t)] == undefined) {
                    break;
                }
            }

            // Mark each stage by tier.
            for (var strId:String in _stageTier) {
                var tier:int = int(_stageTier[strId]);
                _inLogicByStrId[strId] = _freeStages[strId] == true || tier <= _reachableTier;
            }
            // Free stages (W1-W4) are not in _stageTier but are always reachable.
            for (var freeSid:String in _freeStages) {
                _inLogicByStrId[freeSid] = true;
            }

            _dirty = false;
            AV.sessionData.fieldsInLogic = _inLogicByStrId;
        }

        // -----------------------------------------------------------------------
        // Private helpers

        private function _skillGateMet(strId:String):Boolean {
            if (_stageSkills == null) return true;
            var required:Array = _stageSkills[strId] as Array;
            if (required == null || required.length == 0) return true;
            for each (var skillName:String in required) {
                var idx:int = SessionData.SKILL_NAMES.indexOf(skillName);
                if (idx < 0) continue; // unknown name — don't block
                if (!AV.sessionData.hasItem(700 + idx)) return false;
            }
            return true;
        }

        private function _tierTokensMet(tier:int):Boolean {
            var prev:int     = tier - 1;
            var prevCount:int = int(_tierStageCounts[String(prev)]);
            if (prevCount <= 0) return true;
            var needed:int = int((prevCount * _tokenPct) / 100);
            if (needed <= 0) return true;

            var have:int = 0;
            var tokens:Object = AV.sessionData.tokensByStrId;
            for (var sid:String in tokens) {
                if (int(_stageTier[sid]) == prev) {
                    have++;
                    if (have >= needed) return true;
                }
            }
            return have >= needed;
        }

        private function _tierSkillsMet(tier:int):Boolean {
            if (_cumulativeSkillReqs == null) return true;
            var reqs:Object = _cumulativeSkillReqs[String(tier)];
            if (reqs == null) return true;
            var counts:Object = AV.sessionData.skillCountByCategory;
            for (var cat:String in reqs) {
                if (int(counts[cat]) < int(reqs[cat])) return false;
            }
            return true;
        }
    }
}

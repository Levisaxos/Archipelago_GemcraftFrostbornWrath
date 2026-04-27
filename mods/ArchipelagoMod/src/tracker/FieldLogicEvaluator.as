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
        private var _levelStats:Object = {};  // strId -> {GiantMaxHP, ReaverMaxHP, ...}

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

        /** True if this stage is a free/tutorial stage (W1-W4, always reachable). */
        public function isFreeStage(strId:String):Boolean {
            return _freeStages[strId] == true;
        }

        /** Returns the tier of the given stage, or -1 if unknown. */
        public function getStageTier(strId:String):int {
            if (_stageTier == null) return -1;
            var t:* = _stageTier[strId];
            return (t !== undefined) ? int(t) : -1;
        }

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

        /** Load per-level monster stat data from achievement_logic.json. */
        public function setLevelStats(stats:Object):void {
            _levelStats = stats || {};
        }

        /** True if any in-logic field has max(GiantMaxHP, ReaverMaxHP) >= threshold. */
        public function hasInLogicFieldWithMinMonsterHP(threshold:int):Boolean {
            if (_dirty) recompute();
            for (var sid:String in _levelStats) {
                if (_inLogicByStrId[sid] == true) {
                    var s:Object = _levelStats[sid];
                    if (Math.max(int(s.GiantMaxHP), int(s.ReaverMaxHP)) >= threshold) return true;
                }
            }
            return false;
        }

        /** True if any in-logic field has max(GiantMaxArmor, ReaverMaxArmor) >= threshold. */
        public function hasInLogicFieldWithMinMonsterArmor(threshold:int):Boolean {
            if (_dirty) recompute();
            for (var sid:String in _levelStats) {
                if (_inLogicByStrId[sid] == true) {
                    var s:Object = _levelStats[sid];
                    if (Math.max(int(s.GiantMaxArmor), int(s.ReaverMaxArmor)) >= threshold) return true;
                }
            }
            return false;
        }

        /** True if any in-logic field has MonsterCount >= threshold. */
        public function hasInLogicFieldWithMinMonsters(threshold:int):Boolean {
            if (_dirty) recompute();
            for (var sid:String in _levelStats) {
                if (_inLogicByStrId[sid] == true && int(_levelStats[sid].MonsterCount) >= threshold) return true;
            }
            return false;
        }

        /** True if any in-logic field has SwarmlingMaxArmor >= threshold. */
        public function hasInLogicFieldWithMinSwarmlingArmor(threshold:int):Boolean {
            if (_dirty) recompute();
            for (var sid:String in _levelStats) {
                if (_inLogicByStrId[sid] == true && int(_levelStats[sid].SwarmlingMaxArmor) >= threshold) return true;
            }
            return false;
        }

        /** True if any in-logic field has SwarmlingCount >= threshold. */
        public function hasInLogicFieldWithMinSwarmlings(threshold:int):Boolean {
            if (_dirty) recompute();
            for (var sid:String in _levelStats) {
                if (_inLogicByStrId[sid] == true && int(_levelStats[sid].SwarmlingCount) >= threshold) return true;
            }
            return false;
        }

        /**
         * Returns [text, color] line pairs for any unmet tier skill requirements
         * blocking this stage.  Empty array when skill reqs are disabled or all met.
         */
        public function getBlockingTierSkillLines(strId:String):Array {
            if (_cumulativeSkillReqs == null || _stageTier == null) return [];
            var lines:Array = [];
            var counts:Object = AV.sessionData.skillCountByCategory;

            var catLabel:Object = { gems: "gem", spells: "spell", focus: "focus",
                                    buildings: "building", wrath: "wrath" };

            // tier0 flat gem requirement (not cascaded into higher tiers).
            var tier0Reqs:Object = _cumulativeSkillReqs["0"];
            if (tier0Reqs != null) {
                for (var cat0:String in tier0Reqs) {
                    var need0:int = int(tier0Reqs[cat0]);
                    if (need0 <= 0) continue;
                    var have0:int = int(counts[cat0]);
                    if (have0 < need0) {
                        var lbl0:String = catLabel[cat0] != null ? String(catLabel[cat0]) : cat0;
                        lines.push(["Requires " + need0 + " " + lbl0 + " skill" + (need0 != 1 ? "s" : "") +
                                    " (" + have0 + "/" + need0 + ")", 0x888888]);
                    }
                }
            }

            // Cumulative tier skill requirements for this stage's tier (tier1+).
            var tier:int = int(_stageTier[strId]);
            if (tier > 0) {
                var tierReqs:Object = _cumulativeSkillReqs[String(tier)];
                if (tierReqs != null) {
                    for (var cat:String in tierReqs) {
                        var need:int = int(tierReqs[cat]);
                        if (need <= 0) continue;
                        var have:int = int(counts[cat]);
                        if (have < need) {
                            var lbl:String = catLabel[cat] != null ? String(catLabel[cat]) : cat;
                            lines.push(["Requires " + need + " " + lbl + " skill" + (need != 1 ? "s" : "") +
                                        " (" + have + "/" + need + ")", 0x888888]);
                        }
                    }
                }
            }
            return lines;
        }

        /**
         * For a stage not yet tier-reachable, returns the token count needed from
         * the current reachable tier and all stage strIds in that tier.
         * Returns null if the stage is already in logic, a free stage, or no rules loaded.
         * Result: { needed:int, strIds:Array<String> }
         */
        public function getBlockingTokenReq(strId:String):Object {
            if (_stageTier == null || _freeStages[strId] == true) return null;
            if (_dirty) recompute();
            if (_inLogicByStrId[strId] == true) return null;

            var prevTier:int  = int(_stageTier[strId]) - 1;
            var prevCount:int = int(_tierStageCounts[String(prevTier)]);
            if (prevCount <= 0) return null;

            var needed:int = Math.max(1, int((prevCount * _tokenPct) / 100));

            var allStrIds:Array = [];
            for (var sid:String in _stageTier) {
                if (int(_stageTier[sid]) == prevTier) allStrIds.push(sid);
            }
            allStrIds.sort(Array.CASEINSENSITIVE);
            return { needed: needed, strIds: allStrIds, tier: prevTier };
        }

        /**
         * Returns skill names required for this stage's Journey/Bonus that
         * the player has not yet collected.
         */
        public function getMissingStageSkills(strId:String):Array {
            if (_stageSkills == null) return [];
            var required:Array = _stageSkills[strId] as Array;
            if (required == null || required.length == 0) return [];

            var missing:Array = [];
            for each (var skillName:String in required) {
                var lower:String = skillName.toLowerCase().split(" ").join("");
                if (lower.indexOf("gemskills:") == 0) {
                    var need:int = int(skillName.split(":")[1]);
                    var have:int = int(AV.sessionData.skillCountByCategory["gems"]);
                    if (have < need) missing.push(need + " gem skills (" + have + "/" + need + ")");
                    continue;
                }
                var idx:int = SessionData.SKILL_NAMES.indexOf(skillName);
                if (idx >= 0 && !AV.sessionData.hasItem(700 + idx)) missing.push(skillName);
            }
            return missing;
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
            // for (var strId:String in _stageTier) {
            //     var tier:int = int(_stageTier[strId]);
            //     _inLogicByStrId[strId] = _freeStages[strId] == true || tier <= _reachableTier;
            // }
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
                var lower:String = skillName.toLowerCase().split(" ").join("");
                if (lower.indexOf("gemskills:") == 0) {
                    var need:int = int(skillName.split(":")[1]);
                    if (int(AV.sessionData.skillCountByCategory["gems"]) < need) return false;
                    continue;
                }
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

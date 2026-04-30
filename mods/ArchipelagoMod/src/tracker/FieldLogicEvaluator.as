package tracker {
    import Bezel.Logger;
    import data.AV;
    import data.SessionData;

    /**
     * Mirrors apworld/gcfw/rules.py to determine which stages are currently
     * in logic based on collected items.  Stage rule data ships in
     * mods/ArchipelagoMod/src/data/json/logic.json — generated from apworld
     * by do not commit/py-scripts/generate_logic_json.py — so the apworld
     * stays the single source of truth.
     *
     * Reads item state from AV.sessionData (populated by onItem calls).
     * After every recompute, writes the result to AV.sessionData.fieldsInLogic
     * so UI components can read it without holding a reference to this class.
     *
     * In-logic algorithm (matches apworld rules.set_rules + _eval_req):
     *   Stage is in logic iff every condition holds:
     *     1. Stage is in FREE_STAGES (W1-W4), OR has its own Field Token.
     *     2. WIZLOCK skill gate (stageSkills[sid]) is satisfied.
     *     3. Field-token prereq gate: at least one Field_<sid> entry in
     *        stageRequirements[sid] has its token collected — UNLESS the
     *        prereq list contains a free stage (then auto-satisfied) or
     *        contains no Field_ entries at all.
     *     4. Non-Field requirements (talismanRow:N, talismanColumn:N,
     *        skillPoints:N, ...) are all satisfied.
     */
    public class FieldLogicEvaluator {

        // Stages whose Journey location requires ALL 24 skills.
        public static const ALL_SKILLS_STAGES:Object = { "A4": true };

        private var _logger:Logger;
        private var _modName:String;

        // Logic data from logic.json (loaded by ServerData.loadLogicFromJSON).
        private var _stageSkills:Object;         // strId -> Array<WIZLOCK skill string>
        private var _stageRequirements:Object;   // strId -> Array<requirement string>
        private var _matchingTalismans:Object;   // { grid, rows, columns } or null
        private var _freeStages:Object = {};     // strId -> true

        // slot_data — power weights for achievement-side power gates only.
        // Stage in-logic no longer uses power; this is kept for the
        // achievement evaluator's required_power checks.
        private var _powerScalePct:int = 100;
        private var _powerWeights:Object;

        private var _dirty:Boolean = true;
        private var _inLogicByStrId:Object = {};
        private var _levelStats:Object = {};  // strId -> {GiantMaxHP, ReaverMaxHP, ...}
        private var _stageElements:Object = {};  // strId -> Array<String>
        private var _stageMonsters:Object = {};  // strId -> Array<String>
        private var _elementToStages:Object = {}; // element name -> Array<String>
        private var _monsterToStages:Object = {}; // monster name -> Array<String>

        // Ritual Battle Trait AP id (matches apworld). All current
        // non_monster_elements (Shadow / Specter / Spire / Wraith / Wizard
        // Hunter / Apparition) require this trait per rulesdata_settings.py.
        public static const RITUAL_TRAIT_AP_ID:int = 814;

        public function FieldLogicEvaluator(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        /**
         * Feed logic data from logic.json + slot_data power-scale info.
         * Call once after the Connected packet (ServerData has loaded JSON).
         */
        public function configure(stageSkills:Object,
                                  stageRequirements:Object,
                                  matchingTalismans:Object,
                                  freeStages:Array,
                                  powerScalePct:int,
                                  powerWeights:Object):void {
            _stageSkills         = stageSkills != null ? stageSkills : {};
            _stageRequirements   = stageRequirements != null ? stageRequirements : {};
            _matchingTalismans   = matchingTalismans;
            _powerScalePct       = powerScalePct > 0 ? powerScalePct : 100;
            _powerWeights        = powerWeights != null ? powerWeights : {};
            _freeStages          = {};
            if (freeStages != null) {
                for each (var sid:String in freeStages) {
                    _freeStages[sid] = true;
                }
            }
            _dirty = true;
        }

        public function markDirty():void { _dirty = true; }

        public function get hasRules():Boolean { return _stageRequirements != null; }
        public function get powerScalePct():int { return _powerScalePct; }

        /** True if this stage is a free/tutorial stage (W1-W4, always reachable). */
        public function isFreeStage(strId:String):Boolean {
            return _freeStages[strId] == true;
        }

        /**
         * Tier-style label for tooltips. The new prereq-graph logic doesn't
         * use tiers; return -1 so callers (e.g. FieldTooltipOverlay) hide
         * the tier line. Kept as a method to avoid breaking call sites.
         */
        public function getStageTier(strId:String):int {
            return -1;
        }

        // -----------------------------------------------------------------------
        // Public queries

        /** True if this stage is currently reachable (in logic). */
        public function isStageInLogic(strId:String):Boolean {
            if (_stageRequirements == null) return true;
            if (_dirty) recompute();
            return _inLogicByStrId[strId] == true;
        }

        /**
         * True if the stage is reachable AND at least one of the provided missing
         * locations is reachable.  Used by StageTinter (per-frame) and ModButtons.
         *
         * Per-check reachability:
         *   - Journey: stage tier + WIZLOCK skill gate (+ all 24 skills on A4)
         *   - Stash:   stage tier + WIZLOCK skill gate + Wizard Stash key item
         */
        public function stageHasInLogicMissing(strId:String,
                                               journeyMissing:Boolean,
                                               stashMissing:Boolean):Boolean {
            if (!(journeyMissing || stashMissing))
                return false;
            if (_stageRequirements == null)
                return true;
            if (!canCompleteStage(strId))
                return false;

            if (journeyMissing) {
                // A4-only: Journey additionally needs all 24 skills.
                var journeyOk:Boolean = !(ALL_SKILLS_STAGES[strId] == true
                        && AV.sessionData.totalSkillsCollected < 24);
                if (journeyOk)
                    return true;
            }
            // Stash needs both the key item AND power threshold met.
            if (stashMissing && isStashGateMet(strId))
                return true;
            return false;
        }

        /** True iff stage is tier-reachable AND its WIZLOCK skill gate is met.
         *  Mirrors apworld's location access_rule, which applies the same skill
         *  conditions to Journey and Wizard stash on a given stage. */
        public function canCompleteStage(strId:String):Boolean {
            if (_dirty) recompute();
            if (_inLogicByStrId[strId] != true) return false;
            return _skillGateMet(strId);
        }

        /**
         * True if any in-logic stage has at least minWaveCount waves.
         *
         * Reads WaveCount directly from _levelStats so the check sees free
         * stages (W1-W4) too — they aren't in _stageRequirements but are in _levelStats
         * and _inLogicByStrId, so a tier-table-driven version would miss them
         * (e.g. "Short Tempered" needs only minWave: 5, which W1 satisfies).
         */
        public function hasInLogicFieldWithMinWaves(minWaveCount:int):Boolean {
            if (_dirty) recompute();
            if (_levelStats == null) return false;
            for (var sid:String in _levelStats) {
                if (_inLogicByStrId[sid] == true
                        && int(_levelStats[sid].WaveCount) >= minWaveCount) {
                    return true;
                }
            }
            return false;
        }

        /** Load per-level monster stat data from achievement_logic.json. */
        public function setLevelStats(stats:Object):void {
            _levelStats = stats || {};
        }

        /** Per-stage element/monster lists from slot_data (for UI tooltips). */
        public function setStageElements(elements:Object, monsters:Object):void {
            _stageElements = elements != null ? elements : {};
            _stageMonsters = monsters != null ? monsters : {};
            _elementToStages = _buildInverse(_stageElements);
            _monsterToStages = _buildInverse(_stageMonsters);
        }

        public function getStageElements(strId:String):Array {
            var a:Array = _stageElements[strId] as Array;
            return a != null ? a : [];
        }

        public function getStageMonsters(strId:String):Array {
            var a:Array = _stageMonsters[strId] as Array;
            return a != null ? a : [];
        }

        /** True if at least one stage that has this element can be completed
         *  (tier + skill gate met).  Mirrors apworld _eval_req for
         *  game_level_elements via _can_reach_any_stage, which now requires
         *  the stage's WIZLOCK skills on Journey/Wizard stash alike. */
        public function isElementInLogic(elemName:String):Boolean {
            var stages:Array = _elementToStages[elemName] as Array;
            if (stages == null || stages.length == 0) return true;
            for each (var sid:String in stages) {
                if (canCompleteStage(sid)) return true;
            }
            return false;
        }

        /** True if Ritual is held AND at least one stage that has this monster
         *  can be completed. Mirrors apworld _eval_req for non_monster_elements. */
        public function isMonsterInLogic(monName:String):Boolean {
            if (!AV.sessionData.hasItem(RITUAL_TRAIT_AP_ID)) return false;
            var stages:Array = _monsterToStages[monName] as Array;
            if (stages == null || stages.length == 0) return true;
            for each (var sid:String in stages) {
                if (canCompleteStage(sid)) return true;
            }
            return false;
        }

        /**
         * Returns one entry per skill requirement on this stage as
         * [text:String, met:Boolean].  Empty array if the stage has no skill
         * requirements (or rules haven't loaded yet).
         */
        public function getStageSkillsStatus(strId:String):Array {
            if (_stageSkills == null) return [];
            var required:Array = _stageSkills[strId] as Array;
            if (required == null || required.length == 0) return [];

            var pouchMode:int = _pouchMode();
            var out:Array = [];
            for each (var skillName:String in required) {
                var lower:String = skillName.toLowerCase().split(" ").join("");
                if (lower.indexOf("gemskills:") == 0) {
                    if (pouchMode != 0)
                        continue; // pouches replace the gem-skill gate — hide
                    var need:int = int(skillName.split(":")[1]);
                    var have:int = int(AV.sessionData.skillCountByCategory["gems"]);
                    out.push([need + " gem skills (" + have + "/" + need + ")", have >= need]);
                    continue;
                }
                if (lower.indexOf("gempouch:") == 0) {
                    if (pouchMode == 0)
                        continue; // gating off — pouch line is meaningless
                    var pouchPrefix:String = skillName.split(":")[1];
                    if (pouchPrefix == null)
                        continue;
                    pouchPrefix = _trimAS(pouchPrefix);
                    out.push(["Gempouch (" + pouchPrefix + ")", _pouchHeld(pouchPrefix)]);
                    continue;
                }
                var idx:int = SessionData.SKILL_NAMES.indexOf(skillName);
                if (idx >= 0) {
                    out.push([skillName, AV.sessionData.hasItem(700 + idx)]);
                }
            }
            return out;
        }

        private function _buildInverse(perStage:Object):Object {
            var out:Object = {};
            for (var sid:String in perStage) {
                var arr:Array = perStage[sid] as Array;
                if (arr == null) continue;
                for each (var name:String in arr) {
                    if (out[name] == null) out[name] = [];
                    (out[name] as Array).push(sid);
                }
            }
            return out;
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
         * Returns [text, color] line pairs describing why this stage isn't
         * in logic. Used by FieldTooltipOverlay. Lines cover:
         *   - Missing prereq stages (Field_<sid>) — "Requires field X / Y / Z"
         *   - Unmet counter requirements (talismanRow:N etc.) — "Requires N matching rows"
         * Returns empty array when stage is in logic or has no rules.
         */
        public function getBlockingTierSkillLines(strId:String):Array {
            if (_stageRequirements == null) return [];
            var reqs:Array = _stageRequirements[strId] as Array;
            if (reqs == null || reqs.length == 0) return [];

            // Flatten DNF (outer-OR over inner-AND groups) into the union of
            // entries across all groups for tooltip display. Loses precision
            // for complex multi-group cases but matches the simpler "what
            // are you missing" intent. Backward compat: a flat list is its
            // own union.
            var groups:Array;
            if (reqs[0] is Array) {
                groups = reqs;
            } else {
                groups = [reqs];
            }
            var flat:Array = [];
            var seen:Object = {};
            for each (var group:Array in groups) {
                if (group == null) continue;
                for each (var entry:String in group) {
                    if (entry == null || seen[entry]) continue;
                    seen[entry] = true;
                    flat.push(entry);
                }
            }

            var lines:Array = [];

            // Field_ prereqs — show as a single OR line if any are missing.
            var missingFields:Array = [];
            var anyFieldHeld:Boolean = false;
            var anyFreePrereq:Boolean = false;
            var tokens:Object = AV.sessionData.tokensByStrId;
            for each (var req:String in flat) {
                if (req == null || req.indexOf("Field_") != 0) continue;
                var sid:String = req.substr(6);
                if (_freeStages[sid] == true) {
                    anyFreePrereq = true;
                } else if (tokens != null && tokens[sid] == true) {
                    anyFieldHeld = true;
                } else {
                    missingFields.push(sid);
                }
            }
            if (!anyFieldHeld && !anyFreePrereq && missingFields.length > 0) {
                lines.push(["Requires field " + missingFields.join(" / "), 0x888888]);
            }

            // Counter requirements that aren't met — one line each.
            for each (var creq:String in flat) {
                if (creq == null || creq.indexOf("Field_") == 0) continue;
                if (_evalCounterReq(creq)) continue;
                var colon:int = creq.indexOf(":");
                if (colon < 0) continue;
                var name:String = creq.substring(0, colon);
                var n:int = int(_trimStr(creq.substring(colon + 1)));
                if (name == "talismanRow") {
                    lines.push(["Requires " + n + " matching talisman row" + (n != 1 ? "s" : "")
                                + " (" + _countCompleteTalismanRows() + "/" + n + ")", 0x888888]);
                } else if (name == "talismanColumn") {
                    lines.push(["Requires " + n + " matching talisman column" + (n != 1 ? "s" : "")
                                + " (" + _countCompleteTalismanColumns() + "/" + n + ")", 0x888888]);
                } else if (name == "skillPoints") {
                    lines.push(["Requires " + n + " skill points (" + _countSkillPoints() + "/" + n + ")", 0x888888]);
                }
            }
            return lines;
        }

        /**
         * Hint object describing why a stage isn't in logic. Returns null
         * when the stage is already in logic, free, or has no rules. Used
         * by tooltips to render quick "missing token" / "missing prereq"
         * banners.
         */
        public function getBlockingTokenReq(strId:String):Object {
            if (_stageRequirements == null || _freeStages[strId] == true)
                return null;
            if (_dirty)
                recompute();
            if (_inLogicByStrId[strId] == true)
                return null;

            var tokens:Object = AV.sessionData.tokensByStrId;
            return {
                missingToken: !(tokens != null && tokens[strId] == true)
            };
        }

        /**
         * Returns skill names required for this stage's Journey that
         * the player has not yet collected.
         */
        public function getMissingStageSkills(strId:String):Array {
            if (_stageSkills == null) return [];
            var required:Array = _stageSkills[strId] as Array;
            if (required == null || required.length == 0) return [];

            var pouchMode:int = _pouchMode();
            var missing:Array = [];
            for each (var skillName:String in required) {
                var lower:String = skillName.toLowerCase().split(" ").join("");
                if (lower.indexOf("gemskills:") == 0) {
                    if (pouchMode != 0)
                        continue; // pouches replace the gem-skill gate
                    var need:int = int(skillName.split(":")[1]);
                    var have:int = int(AV.sessionData.skillCountByCategory["gems"]);
                    if (have < need) missing.push(need + " gem skills (" + have + "/" + need + ")");
                    continue;
                }
                if (lower.indexOf("gempouch:") == 0) {
                    if (pouchMode == 0)
                        continue; // gating off
                    var pouchPrefix:String = skillName.split(":")[1];
                    if (pouchPrefix == null)
                        continue;
                    pouchPrefix = _trimAS(pouchPrefix);
                    if (!_pouchHeld(pouchPrefix))
                        missing.push("Gempouch (" + pouchPrefix + ")");
                    continue;
                }
                var idx:int = SessionData.SKILL_NAMES.indexOf(skillName);
                if (idx >= 0 && !AV.sessionData.hasItem(700 + idx)) missing.push(skillName);
            }
            return missing;
        }

        // -----------------------------------------------------------------------
        // Recompute

        /**
         * Recalculate in-logic stages from current item state; write the
         * result to AV.sessionData.fieldsInLogic. Call after configure() and
         * after every relevant onItem.
         *
         * Mirrors apworld rules.set_rules per-stage gate:
         *   in-logic iff
         *     (free stage OR has own field token)
         *     AND WIZLOCK skill gate met
         *     AND (no Field_ prereqs in requirements
         *          OR a free stage appears in prereq list (auto-satisfied)
         *          OR at least one Field_<sid> prereq token is held)
         *     AND every non-Field requirement (talismanRow:N etc.) is met.
         */
        public function recompute():void {
            _inLogicByStrId = {};

            if (_stageRequirements == null) {
                _dirty = false;
                AV.sessionData.fieldsInLogic = _inLogicByStrId;
                return;
            }

            // Iterate every stage we know about (free + non-free).
            for (var freeSid:String in _freeStages) {
                _inLogicByStrId[freeSid] = _stageReachable(freeSid);
            }
            for (var strId:String in _stageRequirements) {
                if (_inLogicByStrId[strId] === undefined)
                    _inLogicByStrId[strId] = _stageReachable(strId);
            }

            _dirty = false;
            AV.sessionData.fieldsInLogic = _inLogicByStrId;
            AV.sessionData.playerPower   = computePlayerPower();
        }

        /** Run the four-clause stage gate for one stage. */
        private function _stageReachable(strId:String):Boolean {
            // Free stage = the chosen starting stage. Mirrors apworld
            // set_rules, which skips the requirements + token gate for the
            // start (Menu connects directly to it).
            if (_freeStages[strId] == true)
                return true;
            // Clause 1: own Field Token required.
            var tokens:Object = AV.sessionData.tokensByStrId;
            if (tokens == null || tokens[strId] != true)
                return false;
            // Clause 2: WIZLOCK skill gate.
            if (!_skillGateMet(strId))
                return false;
            // Clause 3 + 4: per-requirements list.
            return _requirementsGateMet(strId);
        }

        /**
         * Evaluate stageRequirements[strId] in DNF: outer-OR of inner
         * AND-groups. The stage passes if any one AND-group passes; an
         * AND-group passes when every entry inside it does. Within a group:
         *   - Field_<sid>: token <sid> held (or <sid> is a free stage).
         *   - everything else: routed through _evalCounterReq.
         * Empty / missing requirements pass automatically (used by the
         * starting stage upstream, plus W1-style stages from older data).
         *
         * Backward compat: a flat list of strings (no inner Arrays) is
         * treated as a single AND-group, matching apworld's
         * _normalize_requirements.
         */
        private function _requirementsGateMet(strId:String):Boolean {
            var reqs:Array = _stageRequirements != null
                ? (_stageRequirements[strId] as Array)
                : null;
            if (reqs == null || reqs.length == 0)
                return true;

            var groups:Array;
            if (reqs[0] is Array) {
                groups = reqs;
            } else {
                groups = [reqs];
            }

            var tokens:Object = AV.sessionData.tokensByStrId;
            for each (var group:Array in groups) {
                if (group == null) continue;
                var groupOk:Boolean = true;
                for each (var req:String in group) {
                    if (req == null) continue;
                    if (req.indexOf("Field_") == 0) {
                        var sid:String = req.substr(6);
                        if (_freeStages[sid] != true
                            && !(tokens != null && tokens[sid] == true)) {
                            groupOk = false;
                            break;
                        }
                    } else if (!_evalCounterReq(req)) {
                        groupOk = false;
                        break;
                    }
                }
                if (groupOk) return true;
            }
            return false;
        }

        /**
         * Evaluate a single non-Field requirement string.
         * Currently handles talismanRow:N, talismanColumn:N, skillPoints:N.
         * Unknown/metadata strings return true (mirrors apworld _eval_req).
         */
        private function _evalCounterReq(req:String):Boolean {
            var colon:int = req.indexOf(":");
            if (colon < 0) return true;
            var name:String = req.substring(0, colon);
            var n:int = int(_trimStr(req.substring(colon + 1)));
            if (name == "talismanRow")
                return _countCompleteTalismanRows() >= n;
            if (name == "talismanColumn")
                return _countCompleteTalismanColumns() >= n;
            if (name == "skillPoints")
                return _countSkillPoints() >= n;
            return true; // unknown counter — don't block
        }

        private function _countCompleteTalismanRows():int {
            return _countCompleteSets(_matchingTalismans != null
                ? _matchingTalismans.rows as Array : null);
        }

        private function _countCompleteTalismanColumns():int {
            return _countCompleteSets(_matchingTalismans != null
                ? _matchingTalismans.columns as Array : null);
        }

        private function _countCompleteSets(sets:Array):int {
            if (sets == null) return 0;
            var n:int = 0;
            for each (var set:Array in sets) {
                if (set == null) continue;
                var ok:Boolean = true;
                for each (var apId:* in set) {
                    if (!AV.sessionData.hasItem(int(apId))) { ok = false; break; }
                }
                if (ok) n++;
            }
            return n;
        }

        /** Sum SP across collected Skillpoint Bundle items (1700-1709,
         *  bundle apId-1699 = SP value). Counts each held bundle once. */
        private function _countSkillPoints():int {
            var total:int = 0;
            for (var size:int = 1; size <= 10; size++) {
                if (AV.sessionData.hasItem(1699 + size))
                    total += size;
            }
            return total;
        }

        private static function _trimStr(s:String):String {
            if (s == null) return "";
            return s.replace(/^\s+|\s+$/g, "");
        }

        /** Current player power score from collected items. Mirrors apworld/gcfw/power.py. */
        public function computePlayerPower():Number {
            var power:Number = 0;
            var sd:* = AV.sessionData;
            if (sd == null || _powerWeights == null)
                return 0;

            // Skillpoint Bundles 1700-1709 — bundle (apId-1699) SP per item.
            // We don't track per-item received counts in the mod (only "have"),
            // so approximate as 1 per AP id received. Good enough for in-logic UI;
            // exact count lives apworld-side at fill time.
            var spWeight:Number     = Number(_powerWeights["sp"]);
            for (var apId:int = 1700; apId <= 1709; apId++) {
                if (sd.hasItem(apId))
                    power += spWeight * (apId - 1699);
            }

            // Skills 700-723.
            var gemWeight:Number    = Number(_powerWeights["gem_skill"]);
            var skillWeight:Number  = Number(_powerWeights["other_skill"]);
            for (var sk:int = 0; sk < 24; sk++) {
                if (!sd.hasItem(700 + sk))
                    continue;
                if (sk >= 6 && sk <= 11)
                    power += gemWeight;     // gem-type skills (Crit/Leech/Bleed/AT/Poison/Slow)
                else
                    power += skillWeight;
            }

            // Battle traits 800-814.
            var traitWeight:Number  = Number(_powerWeights["battle_trait"]);
            if (traitWeight != 0) {
                for (var tr:int = 0; tr < 15; tr++) {
                    if (sd.hasItem(800 + tr))
                        power += traitWeight;
                }
            }

            // XP tomes 1100-1199 — exact wizard-level grant per tome lives in
            // LevelUnlocker.levelsForApId; for power we approximate flat 1 level.
            var xpWeight:Number     = Number(_powerWeights["xp_tome_level"]);
            if (xpWeight != 0) {
                for (var xp:int = 1100; xp <= 1199; xp++) {
                    if (sd.hasItem(xp))
                        power += xpWeight;
                }
            }

            // Shadow cores: specific 1000-1016 + extras 1300-1351.
            var coreWeight:Number   = Number(_powerWeights["shadow_core"]);
            if (coreWeight != 0) {
                for (var sc:int = 1000; sc <= 1016; sc++) {
                    if (sd.hasItem(sc))
                        power += coreWeight;
                }
                for (var sce:int = 1300; sce <= 1351; sce++) {
                    if (sd.hasItem(sce))
                        power += coreWeight;
                }
            }

            // Talisman fragments 900-952 + extras 1200-1246. Power = rarity / divisor.
            // Per-fragment rarity isn't sent in slot_data right now; we use a flat
            // average of rarity 50 (mid-pool) until rarity table is wired in.
            // TODO: forward per-fragment rarities from apworld for accurate count.
            var talDiv:Number       = Number(_powerWeights["talisman_divisor"]);
            if (talDiv > 0) {
                var talPower:Number = 50.0 / talDiv;
                for (var tf:int = 900; tf <= 952; tf++) {
                    if (sd.hasItem(tf))
                        power += talPower;
                }
                for (var tfe:int = 1200; tfe <= 1246; tfe++) {
                    if (sd.hasItem(tfe))
                        power += talPower;
                }
            }

            return power;
        }

        /**
         * True if this stage's wizard stash is reachable: stage in logic
         * (same gate as Journey) AND the wizard stash key is held.
         * Mirrors apworld rules: stash shares the stage's per-stage gate
         * plus the per-stage Wizard Stash Key item.
         */
        public function isStashGateMet(strId:String):Boolean {
            if (AV.sessionData == null || !AV.sessionData.isStashUnlocked(strId))
                return false;
            return canCompleteStage(strId);
        }

        // -----------------------------------------------------------------------
        // Private helpers

        private function _skillGateMet(strId:String):Boolean {
            if (_stageSkills == null) return true;
            var required:Array = _stageSkills[strId] as Array;
            if (required == null || required.length == 0) return true;
            var pouchMode:int = _pouchMode();
            for each (var skillName:String in required) {
                var lower:String = skillName.toLowerCase().split(" ").join("");
                if (lower.indexOf("gemskills:") == 0) {
                    if (pouchMode != 0)
                        continue; // pouches replace the gem-skill gate
                    var need:int = int(skillName.split(":")[1]);
                    if (int(AV.sessionData.skillCountByCategory["gems"]) < need) return false;
                    continue;
                }
                if (lower.indexOf("gempouch:") == 0) {
                    if (pouchMode == 0)
                        continue; // gating off — pouch is no-op
                    var pouchPrefix:String = skillName.split(":")[1];
                    if (pouchPrefix == null)
                        continue;
                    pouchPrefix = _trimAS(pouchPrefix);
                    if (!_pouchHeld(pouchPrefix)) return false;
                    continue;
                }
                var idx:int = SessionData.SKILL_NAMES.indexOf(skillName);
                if (idx < 0) continue; // unknown name — don't block
                if (!AV.sessionData.hasItem(700 + idx)) return false;
            }
            return true;
        }

        // Active gem-pouch gating mode (0=off, 1=distinct, 2=progressive).
        // Read from slot_data via ServerOptions; returns 0 if not set.
        private function _pouchMode():int {
            if (AV.serverData == null || AV.serverData.serverOptions == null)
                return 0;
            return int(AV.serverData.serverOptions.gemPouchGating);
        }

        // True when the player owns the pouch for the given stage-prefix
        // letter under the current mode (distinct: hasItem; progressive:
        // count >= prefix index + 1). Fails open on unknown prefixes.
        private function _pouchHeld(prefix:String):Boolean {
            if (prefix == null || prefix.length == 0) return true;
            var opts:* = AV.serverData != null ? AV.serverData.serverOptions : null;
            if (opts == null) return true;
            var order:Array = opts.gemPouchPlayOrder as Array;
            if (order == null || order.length == 0) return true;
            var idx:int = order.indexOf(prefix);
            if (idx < 0) return true;
            if (int(opts.gemPouchGating) == 1) {
                return AV.sessionData.hasItem(626 + idx);
            }
            // progressive
            var progId:int = int(opts.gemPouchProgressiveId);
            if (progId <= 0) progId = 652;
            return AV.sessionData.getItemCount(progId) >= idx + 1;
        }

        // Local trim to avoid pulling in a tracker dependency.
        private function _trimAS(s:String):String {
            if (s == null) return "";
            return s.replace(/^\s+|\s+$/g, "");
        }

    }
}

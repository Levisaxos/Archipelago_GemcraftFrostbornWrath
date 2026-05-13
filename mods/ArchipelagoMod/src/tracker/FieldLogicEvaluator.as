package tracker {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
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

        // Set once by ArchipelagoMod after both evaluators exist. Used by
        // _requirementsGateMet to delegate skill / trait / element / counter
        // token resolution back to the shared resolver in LogicEvaluator,
        // keeping prefix maps in one place. Field_<sid> entries are still
        // handled locally via _stageReachable so the recursion uses the
        // live computation rather than the cached fieldsInLogic snapshot.
        private var _logicEvaluator:LogicEvaluator;

        // Logic data from logic.json (loaded by ServerData.loadLogicFromJSON).
        private var _stageSkills:Object;         // strId -> Array<WIZLOCK skill string>
        private var _stageRequirements:Object;   // strId -> Array<requirement string>
        private var _matchingTalismans:Object;   // { grid, rows, columns } or null
        private var _freeStages:Object = {};     // strId -> true

        private var _dirty:Boolean = true;
        private var _inLogicByStrId:Object = {};
        private var _levelStats:Object = {};  // strId -> {GiantMaxHP, ReaverMaxHP, ...}
        private var _stageElements:Object = {};  // strId -> Array<String>
        private var _stageMonsters:Object = {};  // strId -> Array<String>
        private var _elementToStages:Object = {}; // element name -> Array<String>
        private var _monsterToStages:Object = {}; // monster name -> Array<String>

        // Ritual Battle Trait AP id (matches apworld). Used by
        // isMonsterInLogic to gate non-monster creature checks (Shadow /
        // Specter / Spire / Wraith / Wizard Hunter / Apparition).
        // NOTE: per current game behaviour these creatures spawn naturally
        // on their listed stages without Ritual; Ritual only amplifies.
        // The gate below is a legacy stricter check — review when
        // refactoring achievement-side logic.
        public static const RITUAL_TRAIT_AP_ID:int = 814;

        public function FieldLogicEvaluator(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        public function setLogicEvaluator(le:LogicEvaluator):void {
            _logicEvaluator = le;
        }

        /**
         * Feed logic data from logic.json.
         * Call once after the Connected packet (ServerData has loaded JSON).
         */
        public function configure(stageSkills:Object,
                                  stageRequirements:Object,
                                  matchingTalismans:Object,
                                  freeStages:Array):void {
            _stageSkills         = stageSkills != null ? stageSkills : {};
            _stageRequirements   = stageRequirements != null ? stageRequirements : {};
            _matchingTalismans   = matchingTalismans;
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
            // Stash needs the key item AND stage gate met.
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
         *  (tier + skill gate met).  Mirrors apworld _eval_element_reachable,
         *  which derives stages from <Pascal>Count fields in
         *  rulesdata_levels.py and requires WIZLOCK skills for completion. */
        public function isElementInLogic(elemName:String):Boolean {
            if (elemName == "Drop Holder" && !hasBoltSkill())
                return false;
            var stages:Array = _elementToStages[elemName] as Array;
            if (stages == null || stages.length == 0) return true;
            for each (var sid:String in stages) {
                if (canCompleteStage(sid)) return true;
            }
            return false;
        }

        // Drop Holders are opened only by Bolt shots (DropHolder.takeDamage
        // consumes the bolt-shot counter), so any element gate touching them
        // must additionally require the Bolt Skill AP item.
        private static const BOLT_SKILL_AP_ID:int = 700 + 15; // SKILL_NAMES index of "Bolt"

        public function hasBoltSkill():Boolean {
            return AV.sessionData.hasItem(BOLT_SKILL_AP_ID);
        }

        /** True if Ritual is held AND at least one stage that hosts this
         *  non-monster creature can be completed. Legacy stricter check —
         *  apworld no longer ties these creatures to Ritual (they spawn
         *  naturally on their listed stages); this gate may need to relax
         *  when achievement-side logic is refactored. */
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
                    pouchPrefix = _trimStr(pouchPrefix);
                    out.push(["Gempouch (" + pouchPrefix + ")", AV.sessionData.hasPouchForPrefix(pouchPrefix)]);
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

        /** True if any in-logic field has GiantCount >= threshold. */
        public function hasInLogicFieldWithMinGiants(threshold:int):Boolean {
            if (_dirty) recompute();
            for (var sid:String in _levelStats)
            {
                if (_inLogicByStrId[sid] == true && int(_levelStats[sid].GiantCount) >= threshold)
                {
                    return true;
                }
            }
            return false;
        }

        /** True if any in-logic field has ReaverCount >= threshold. */
        public function hasInLogicFieldWithMinReavers(threshold:int):Boolean {
            if (_dirty) recompute();
            for (var sid:String in _levelStats)
            {
                if (_inLogicByStrId[sid] == true && int(_levelStats[sid].ReaverCount) >= threshold)
                {
                    return true;
                }
            }
            return false;
        }

        /** True if any in-logic field has the named element count >= threshold.
         *  `fieldNamePascal` is the element name in PascalCase without spaces;
         *  the level-stat key is `<fieldNamePascal>Count`. */
        public function hasInLogicFieldWithElementCount(fieldNamePascal:String, threshold:int):Boolean {
            if (fieldNamePascal == "DropHolder" && !hasBoltSkill())
                return false;
            if (_dirty) recompute();
            var key:String = fieldNamePascal + "Count";
            for (var sid:String in _levelStats)
            {
                if (_inLogicByStrId[sid] == true && int(_levelStats[sid][key]) >= threshold)
                {
                    return true;
                }
            }
            return false;
        }

        /** True if a SPECIFIC stage has `<fieldNamePascal>Count >= threshold`.
         *  Used by gates that need to check element availability on a known
         *  stage (e.g. eWizardTower, which is gated by the stage's stash key
         *  on top of the count). */
        public function stageHasElementCount(strId:String, fieldNamePascal:String, threshold:int):Boolean {
            var stats:Object = _levelStats != null ? _levelStats[strId] : null;
            if (stats == null) return false;
            return int(stats[fieldNamePascal + "Count"]) >= threshold;
        }

        /** Per-stage count for an element or monster (display name with
         *  spaces, e.g. "Monster Nest"). Mirrors apworld _element_count_field:
         *  split on spaces, capitalise the first char of each word, join,
         *  read `<Pascal>Count` from the stage's level stats. Returns 0 when
         *  level stats for the stage haven't loaded. */
        public function getStageElementCount(strId:String, elemName:String):int {
            var stats:Object = _levelStats != null ? _levelStats[strId] : null;
            if (stats == null) return 0;
            return int(stats[_elementPascal(elemName) + "Count"]);
        }

        private static function _elementPascal(name:String):String {
            if (name == null) return "";
            var parts:Array = name.split(" ");
            var out:String = "";
            for each (var p:String in parts) {
                if (p == null || p.length == 0) continue;
                out += p.charAt(0).toUpperCase() + p.substring(1);
            }
            return out;
        }

        /** True if any in-logic field has MonstersBeforeWave12 >= threshold.
         *  The dedicated field is populated by a simulator from the
         *  decompiled stage data; mirrors the apworld gate exactly. */
        public function hasInLogicFieldWithMinMonstersBeforeWave12(threshold:int):Boolean {
            if (_dirty) recompute();
            for (var sid:String in _levelStats)
            {
                if (_inLogicByStrId[sid] == true && int(_levelStats[sid].MonstersBeforeWave12) >= threshold)
                {
                    return true;
                }
            }
            return false;
        }

        /** True if any in-logic field has MarkedMonsterCount >= threshold.
         *  Like MonstersBeforeWave12, this is a simulator-derived expected
         *  value (marked = monsters with 1 attribute, per buffPower). */
        public function hasInLogicFieldWithMarkedMonsterCount(threshold:int):Boolean {
            if (_dirty) recompute();
            for (var sid:String in _levelStats)
            {
                if (_inLogicByStrId[sid] == true && int(_levelStats[sid].MarkedMonsterCount) >= threshold)
                {
                    return true;
                }
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

            // Field_ prereqs — show as a single OR line if no path is satisfied.
            // A prereq path is satisfied when the prereq stage has actually
            // been beaten in vanilla Journey mode. Holding the AP token alone
            // doesn't help the player progress in-game — they still have to
            // play the prereq stage. The hint tells them which level to clear.
            // Skipped in progressive field-token modes: Field_<sid> chains are
            // artificial there (Nth copy unlocks Nth stage), so naming a stage
            // would point at an item they can't directly hunt for.
            if (!_isFieldTokenProgressive()) {
                var missingFields:Array = [];
                var anyFieldBeaten:Boolean = false;
                var anyFreePrereq:Boolean = false;
                for each (var req:String in flat) {
                    if (req == null || req.indexOf("Field_") != 0) continue;
                    var sid:String = req.substr(6);
                    if (_freeStages[sid] == true) {
                        anyFreePrereq = true;
                    } else if (_isFieldBeatenJourney(sid)) {
                        anyFieldBeaten = true;
                    } else {
                        missingFields.push(sid);
                    }
                }
                if (!anyFieldBeaten && !anyFreePrereq && missingFields.length > 0) {
                    lines.push(["Requires field " + missingFields.join(" / ") + " beaten", 0x888888]);
                }
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
         * "Got pouch …" / "Needs pouch …" suffix for the Journey line.
         * Returns null when pouch gating is off or the stage has no
         * gempouch requirement, so the caller appends nothing in that case.
         *
         * Suffix shape mirrors the YAML gem_pouch_granularity option so
         * the player sees the actual item to hunt for:
         *   off (0)                   → null (caller skips line)
         *   per_tile / progressive (1, 2)         → "pouch (X)"
         *   per_tier / progressive (3, 4)         → "pouch (Tier N)"
         *   global (5)                            → "pouch"   (no suffix)
         *
         * Verb (`Got` / `Needs`) is decided by `hasPouchForPrefix`, which
         * is itself granularity-aware (SessionData.as) — so the verb
         * always agrees with the live unlock check.
         */
        public function getPouchLabel(strId:String):String {
            if (_stageSkills == null) return null;
            var required:Array = _stageSkills[strId] as Array;
            if (required == null || required.length == 0) return null;
            var mode:int = _pouchMode();
            if (mode == 0) return null;
            for each (var skillName:String in required) {
                var lower:String = skillName.toLowerCase().split(" ").join("");
                if (lower.indexOf("gempouch:") != 0) continue;
                var prefix:String = skillName.split(":")[1];
                if (prefix == null) continue;
                prefix = _trimStr(prefix);
                var hasPouch:Boolean = AV.sessionData.hasPouchForPrefix(prefix);
                // Free starter stage without pouch yet: Hollow Gems get the
                // player past the WIZLOCK gate (mirrors the carve-out in
                // `_skillGateMet`). Hide the pouch suffix so the green
                // Journey line doesn't look like a contradiction with a
                // "Needs pouch" hint — the pouch isn't actually required
                // to clear this level yet.
                if (!hasPouch && _freeStages[strId] == true)
                    return null;
                var verb:String = hasPouch ? "Got" : "Needs";
                var opts:* = AV.serverData != null ? AV.serverData.serverOptions : null;
                if (opts == null)
                    return verb + " pouch (" + prefix + ")";
                if (mode == 5)
                    return verb + " pouch";
                if (mode == 3 || mode == 4) {
                    var tierMap:Object = opts.stageTierByStrId;
                    if (tierMap == null || tierMap[strId] == null)
                        return verb + " pouch";
                    return verb + " pouch (Tier " + int(tierMap[strId]) + ")";
                }
                // mode 1 / 2: per_tile (progressive) — tile letter is the right hint.
                return verb + " pouch (" + prefix + ")";
            }
            return null;
        }

        /**
         * "Got key (X)" / "Needs key (X)" suffix for the Stash line.
         * Stashes always require a key so this always returns a label —
         * granularity-aware so the player knows which item it points at:
         *   per_stage(_progressive)  → "key" (this stage's key, no suffix)
         *   per_tile(_progressive)   → "key (W)"
         *   per_tier(_progressive)   → "key (Tier 1)"
         *   global                   → "key" (master, no suffix)
         */
        public function getStashKeyLabel(strId:String):String {
            var verb:String = (AV.sessionData != null
                    && AV.sessionData.isStashUnlocked(strId)) ? "Got" : "Needs";
            var opts:* = AV.serverData != null ? AV.serverData.serverOptions : null;
            if (opts == null) return verb + " key";
            var g:int = int(opts.stashKeyGranularity);
            if (g == 3 || g == 4) {
                if (strId == null || strId.length == 0) return verb + " key";
                return verb + " key (" + strId.charAt(0) + ")";
            }
            if (g == 5 || g == 6) {
                var tierMap:Object = opts.stageTierByStrId;
                if (tierMap == null || tierMap[strId] == null) return verb + " key";
                return verb + " key (Tier " + int(tierMap[strId]) + ")";
            }
            // 0 (off), 1/2 (per_stage variants), 7 (global) — no extra suffix needed.
            return verb + " key";
        }

        /**
         * "Missing field token" tooltip line, shaped to the YAML
         * field_token_granularity so the player knows which token to hunt:
         *   per_stage / progressive (0, 1)        → "Missing field token"
         *   per_tile / progressive (2, 3)         → "Missing tile token (X)"
         *   per_tier / progressive (4, 5)         → "Missing tier token (Tier N)"
         * Falls back to the plain string whenever opts/tier data isn't
         * available, so a misconfigured seed never crashes the tooltip.
         */
        public function getMissingTokenLabel(strId:String):String {
            var opts:* = AV.serverData != null ? AV.serverData.serverOptions : null;
            if (opts == null) return "Missing field token";
            var g:int = int(opts.fieldTokenGranularity);
            if (g == 2 || g == 3) {
                if (strId == null || strId.length == 0)
                    return "Missing field token";
                return "Missing tile token (" + strId.charAt(0) + ")";
            }
            if (g == 4 || g == 5) {
                var tierMap:Object = opts.stageTierByStrId;
                if (tierMap == null || tierMap[strId] == null)
                    return "Missing field token";
                return "Missing tier token (Tier " + int(tierMap[strId]) + ")";
            }
            return "Missing field token";
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
                    pouchPrefix = _trimStr(pouchPrefix);
                    if (!AV.sessionData.hasPouchForPrefix(pouchPrefix))
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
            // _stageReachable memoises into _inLogicByStrId, so recursive
            // visits via prerequisite chains are reused for free.
            for (var freeSid:String in _freeStages) {
                _stageReachable(freeSid);
            }
            for (var strId:String in _stageRequirements) {
                _stageReachable(strId);
            }

            _dirty = false;
            AV.sessionData.fieldsInLogic = _inLogicByStrId;
        }

        /** Run the four-clause stage gate for one stage.
         *  Memoised on `_inLogicByStrId`: undefined = not yet evaluated;
         *  false (set BEFORE recursing into requirements) doubles as cycle
         *  guard; true = confirmed reachable. Mirrors apworld
         *  _can_clear_stage_cached (rules.py:653) so a Field_<sid> prereq
         *  is only satisfied when <sid>'s full chain back to the starter
         *  holds, not just when the player happens to hold its token. */
        private function _stageReachable(strId:String):Boolean {
            if (_inLogicByStrId[strId] !== undefined)
                return _inLogicByStrId[strId];

            // Free stage = the chosen starting stage. Mirrors apworld
            // set_rules, which skips the requirements + token gate for the
            // start (Menu connects directly to it).
            if (_freeStages[strId] == true) {
                _inLogicByStrId[strId] = true;
                return true;
            }
            // Clause 1: own Field Token required.
            var tokens:Object = AV.sessionData.tokensByStrId;
            if (tokens == null || tokens[strId] != true) {
                _inLogicByStrId[strId] = false;
                return false;
            }
            // Clause 2: WIZLOCK skill gate.
            if (!_skillGateMet(strId)) {
                _inLogicByStrId[strId] = false;
                return false;
            }
            // Pre-mark false before recursing into requirements — this is the
            // cycle guard. The DAG should be acyclic by construction, but a
            // broken edit would otherwise loop forever.
            _inLogicByStrId[strId] = false;
            var ok:Boolean = _requirementsGateMet(strId);
            _inLogicByStrId[strId] = ok;
            return ok;
        }

        /**
         * Evaluate stageRequirements[strId] in DNF: outer-OR of inner
         * AND-groups. The stage passes if any one AND-group passes; an
         * AND-group passes when every entry inside it does. Within a group:
         *   - Field_<sid>: <sid> itself in logic (recursive _stageReachable
         *     — chain back to the starter must hold, not just token held).
         *     Skipped under progressive field-token granularity (chain is
         *     artificial; see _strip_field_prereqs in apworld rules.py).
         *   - skill / trait / element / counter tokens (sBeam, tHaste,
         *     talismanRow:N, ...): delegated to LogicEvaluator.evaluateRequirement
         *     so the prefix maps live in one place. L5 and P5 are currently
         *     the only stages with non-Field clauses (sBeam/Bolt/Barrage/Freeze
         *     and sTraps respectively).
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

            // Under progressive field-token granularity the Field_<sid>
            // chain is artificial — the Nth singleton token unlocks the
            // Nth stage in the seed's randomized order. Skip Field_ entries
            // (treat as auto-satisfied) but still enforce skill / trait /
            // counter clauses inside the same AND-group (L5 → all four
            // damage skills; P5 → Traps). Apworld does the same via
            // _strip_field_prereqs in rules.py.
            var ftProgressive:Boolean = _isFieldTokenProgressive();

            var groups:Array;
            if (reqs[0] is Array) {
                groups = reqs;
            } else {
                groups = [reqs];
            }

            for each (var group:Array in groups) {
                if (group == null) continue;
                var groupOk:Boolean = true;
                for each (var req:String in group) {
                    if (req == null) continue;
                    if (req.indexOf("Field_") == 0) {
                        if (ftProgressive) continue; // chain artificial under progressive
                        var sid:String = req.substr(6);
                        // Recursive: the prereq stage must itself be in logic
                        // (full chain back to starter), not just have its
                        // token. Free-stage / token / skill-gate checks live
                        // inside _stageReachable, with memoisation.
                        if (!_stageReachable(sid)) {
                            groupOk = false;
                            break;
                        }
                    } else {
                        // Delegate skill / trait / element / counter tokens
                        // to the shared resolver in LogicEvaluator (single
                        // source of truth for prefix maps). Fall back to the
                        // local counter handler if the evaluator isn't wired
                        // yet, so we never accidentally pass an unknown.
                        var ok:Boolean = (_logicEvaluator != null)
                            ? _logicEvaluator.evaluateRequirement(req)
                            : _evalCounterReq(req);
                        if (!ok) {
                            groupOk = false;
                            break;
                        }
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

        /** Sum SP across collected Skillpoint Bundle items (1700-1703, four
         *  named tiers; per-tier SP value comes from slot_data via
         *  ServerOptions.spBundleValues). Bundles stack — same apId can
         *  arrive multiple times, so multiply tier value by per-apId count. */
        private function _countSkillPoints():int {
            var total:int = 0;
            if (AV.serverData == null || AV.serverData.serverOptions == null)
                return 0;
            var opts:* = AV.serverData.serverOptions;
            for (var apId:int = 1700; apId <= 1703; apId++) {
                var count:int = AV.sessionData.getItemCount(apId);
                if (count > 0)
                    total += count * opts.getSpBundleValue(apId);
            }
            return total;
        }

        private static function _trimStr(s:String):String {
            if (s == null) return "";
            return s.replace(/^\s+|\s+$/g, "");
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
            // Free stage (the seed's starter) without its Gempouch yet: the
            // player has Hollow Gems available — any WIZLOCK skill listed for
            // the stage can be brute-forced through. Treat as met so Journey,
            // elements, and monsters on the starter all show in logic until
            // the pouch arrives and normal rules take over.
            if (_freeStages[strId] == true && pouchMode != 0
                    && strId != null && strId.length > 0
                    && !AV.sessionData.hasPouchForPrefix(strId.charAt(0))) {
                return true;
            }
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
                    pouchPrefix = _trimStr(pouchPrefix);
                    if (!AV.sessionData.hasPouchForPrefix(pouchPrefix)) return false;
                    continue;
                }
                var idx:int = SessionData.SKILL_NAMES.indexOf(skillName);
                if (idx < 0) continue; // unknown name — don't block
                if (!AV.sessionData.hasItem(700 + idx)) return false;
            }
            return true;
        }

        // Active gem-pouch granularity:
        //   0=off, 1=per_tile, 2=per_tile_progressive,
        //   3=per_tier, 4=per_tier_progressive, 5=global
        // Read from slot_data via ServerOptions; returns 0 if not set.
        private function _pouchMode():int {
            if (AV.serverData == null || AV.serverData.serverOptions == null)
                return 0;
            return int(AV.serverData.serverOptions.gemPouchGranularity);
        }

        // True when field_token_granularity is one of the progressive variants (per_stage_progressive=1, per_tile_progressive=3, per_tier_progressive=5). In those modes the Nth copy of the singleton progressive item unlocks the Nth tile/stage in the seed's randomized order, so the token count IS the prereq chain — vanilla GCFW Field_<sid> chains from rulesdata_levels become artificial and must be ignored.
        private function _isFieldTokenProgressive():Boolean {
            if (AV.serverData == null || AV.serverData.serverOptions == null)
                return false;
            var g:int = int(AV.serverData.serverOptions.fieldTokenGranularity);
            return g == 1 || g == 3 || g == 5;
        }

        // True iff the player has beaten this stage in vanilla Journey mode at
        // least once. Mirrors BeatGameGoal / FieldPercentageGoal — XP > 0 means
        // the stage was cleared (0 = available/unlocked-not-cleared, -1 = locked).
        private function _isFieldBeatenJourney(strId:String):Boolean {
            if (GV.ppd == null || GV.stageCollection == null) return false;
            var stageId:int = GV.getFieldId(strId);
            if (stageId < 0) return false;
            var arr:Array = GV.ppd.stageHighestXpsJourney;
            if (arr == null || stageId >= arr.length) return false;
            var entry:* = arr[stageId];
            if (entry == null) return false;
            return entry.g() > 0;
        }

    }
}

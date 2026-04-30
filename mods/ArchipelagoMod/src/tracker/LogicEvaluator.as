package tracker {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import data.AV;
    import data.SessionData;
    import unlockers.TraitUnlocker;

    /**
     * Generic AP requirement evaluator used by AchievementLogicEvaluator.
     *
     * Reads item state directly from AV.sessionData and delegates field-in-logic
     * queries to the FieldLogicEvaluator (via AV.sessionData.fieldsInLogic for
     * simple lookups, or directly for wave-count checks).
     *
     * Handles all 14 requirement string patterns found in achievement_logic.json:
     *   "X skill"               — hasItem(700 + SKILL_NAMES.indexOf(X))
     *   "X skill | Y skill"     — pipe-separated OR
     *   "X element"             — any stage in elementStages[X] is in fieldsInLogic
     *   "X Battle trait"        — hasItem(800 + TRAIT_NAMES.indexOf(X))
     *   "Any Battle trait"      — any item 800-814
     *   "Field A4"              — fieldsInLogic["A4"]
     *   "Field N1, U1 or R5"   — comma/or-separated OR
     *   "trial"                 — always false (journey-only mod)
     *   "endurance"             — always false
     *   "endurance and trial"   — always false
     *   "strikeSpells: N"       — count(712-714) >= N
     *   "enhancementSpells: N"  — count(715-717) >= N
     *   "gemSkills: N"          — count(706-711) >= N
     *   "BattleTraits: N"       — count(800-814) >= N
     *   "minWave: N"            — FieldLogicEvaluator.hasInLogicFieldWithMinWaves(N)
     *   "fieldToken: N"         — count(1-122) >= N
     *   "minMonsterHP: N"       — FieldLogicEvaluator.hasInLogicFieldWithMinMonsterHP(N)
     *   "minMonsterArmor: N"    — FieldLogicEvaluator.hasInLogicFieldWithMinMonsterArmor(N)
     *   "minMonsters: N"        — FieldLogicEvaluator.hasInLogicFieldWithMinMonsters(N)
     *   "minSwarmlingArmor: N"  — FieldLogicEvaluator.hasInLogicFieldWithMinSwarmlingArmor(N)
     *   "minSwarmlings: N"      — FieldLogicEvaluator.hasInLogicFieldWithMinSwarmlings(N)
     *   "beforeWave: N"         — same gate as minWave (a stage with N+ waves exists)
     *   "shadowCore: N"         — count(1000-1016) + count(1300-1351) >= N
     *   "wizardLevel: N"        — count(1100-1199) >= ceil(N/2) — half from XP items, half from natural play
     */
    public class LogicEvaluator {

        private var _logger:Logger;
        private var _modName:String;
        private var _fieldEvaluator:FieldLogicEvaluator;
        private var _elementStages:Object; // element name -> Array<String> of stage strIds

        public function LogicEvaluator(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        /**
         * Wire dependencies.  Call on AP connect (once elementStages are loaded
         * from achievement_logic.json).
         */
        public function configure(fieldEvaluator:FieldLogicEvaluator,
                                  elementStages:Object):void {
            _fieldEvaluator = fieldEvaluator;
            _elementStages  = elementStages;
        }

        /** Read access to the element → stage strIds map (for in-level evaluator,
         *  panel rendering, etc.). May be null if configure() hasn't run yet. */
        public function get elementStages():Object {
            return _elementStages;
        }

        // -----------------------------------------------------------------------

        /** Returns true iff every requirement in the array passes.
         *  Supports DNF: if the first element is an Array, treats outer as OR of inner AND-groups. */
        public function evaluateRequirements(requirements:Array):Boolean {
            if (requirements == null || requirements.length == 0) return true;
            if (requirements[0] is Array) {
                // DNF format: outer = OR, inner = AND-groups
                for each (var group:* in requirements) {
                    var andGroup:Array = group as Array;
                    if (andGroup == null) continue;
                    var groupPasses:Boolean = true;
                    for each (var groupReq:* in andGroup) {
                        if (!evaluateRequirement(_trim(String(groupReq)))) {
                            groupPasses = false;
                            break;
                        }
                    }
                    if (groupPasses) return true;
                }
                return false;
            }
            // Flat list = single AND-group (backward compatibility)
            for each (var req:* in requirements) {
                if (!evaluateRequirement(_trim(String(req)))) return false;
            }
            return true;
        }

        /**
         * Returns human-readable descriptions of all FAILING requirements.
         * Used by tooltip overlays to show why an achievement is not yet in logic.
         * For DNF, shows failing reqs from the group closest to passing.
         */
        public function getFailingReqDescriptions(requirements:Array):Array {
            if (requirements == null || requirements.length == 0) return [];
            if (requirements[0] is Array) {
                // DNF: find the group with the most passing reqs, show its failures
                var bestFailing:Array = null;
                var bestPassCount:int = -1;
                for each (var group:* in requirements) {
                    var andGroup:Array = group as Array;
                    if (andGroup == null) continue;
                    var failing:Array = [];
                    var passCount:int = 0;
                    for each (var groupReq:* in andGroup) {
                        var gs:String = _trim(String(groupReq));
                        if (!evaluateRequirement(gs)) {
                            var gd:String = describeRequirement(gs);
                            if (gd != null) failing.push(gd);
                        } else {
                            passCount++;
                        }
                    }
                    if (failing.length == 0) return []; // group fully passes
                    if (passCount > bestPassCount) {
                        bestPassCount = passCount;
                        bestFailing = failing;
                    }
                }
                return bestFailing != null ? bestFailing : [];
            }
            var result:Array = [];
            for each (var req:* in requirements) {
                var s:String = _trim(String(req));
                if (!evaluateRequirement(s)) {
                    var desc:String = describeRequirement(s);
                    if (desc != null) result.push(desc);
                }
            }
            return result;
        }

        /** Returns a human-readable label for a single requirement string. */
        public function describeRequirement(req:String):String {
            var lower:String = req.toLowerCase();

            if (lower.indexOf(" skill") >= 0) {
                if (req.indexOf("|") >= 0) {
                    var parts:Array = req.split("|");
                    var labels:Array = [];
                    for each (var p:String in parts) {
                        p = _trim(p);
                        var pi:int = p.toLowerCase().indexOf(" skill");
                        if (pi >= 0) labels.push(_trim(p.substring(0, pi)) + " skill");
                    }
                    return "Requires " + labels.join(" or ");
                }
                return "Requires " + req;
            }

            if (lower.indexOf(" element") >= 0) {
                var elemName:String = _trim(req.substring(0, lower.indexOf(" element")));
                if (_elementStages != null) {
                    var stages:Array = _elementStages[elemName] as Array;
                    if (stages != null && stages.length > 0) {
                        var sorted:Array = stages.concat();
                        sorted.sort(Array.CASEINSENSITIVE);
                        if (sorted.length == 1) {
                            return "Requires " + elemName + " on " + sorted[0];
                        }
                        return "Requires " + elemName + " (any of " + sorted.join(", ") + ")";
                    }
                }
                return "Requires " + elemName + " element stage";
            }

            if (lower.indexOf(" trait") >= 0)
                return "Requires " + req;
            if (lower.indexOf("field ") == 0)
                return "Requires " + req + " in logic";
            if (lower == "trial" || lower == "endurance" || lower == "endurance and trial")
                return null;

            var colon:int = lower.indexOf(":");
            var n:int = colon >= 0 ? int(_trim(lower.substring(colon + 1))) : 0;

            if (lower.indexOf("skills")            == 0) return "Requires " + n + " skills total";
            if (lower.indexOf("strikespells")      == 0) return "Requires " + n + " strike spells";
            if (lower.indexOf("enhancementspells") == 0) return "Requires " + n + " enhancement spells";
            if (lower.indexOf("gemskills")         == 0) return "Requires " + n + " gem skills";
            if (lower.indexOf("gempouch:")         == 0) {
                var pouchPrefix:String = _trim(req.substring(req.indexOf(":") + 1));
                return "Requires Gempouch (" + pouchPrefix + ")";
            }
            if (lower.indexOf("battletraits")      == 0) return "Requires " + n + " battle traits";
            if (lower.indexOf("minwave")            == 0) return "Requires stage with " + n + "+ waves";
            if (lower.indexOf("beforewave")        == 0) return "Requires stage with " + n + "+ waves";
            if (lower.indexOf("fieldtoken")        == 0) return "Requires " + n + "+ field tokens";
            if (lower.indexOf("shadowcore")        == 0) return "Requires " + n + "+ Shadow Core stash items";
            if (lower.indexOf("wizardlevel")       == 0) return "Requires " + ((n + 1) >> 1) + "+ XP items (toward wizard level " + n + ")";
            if (lower.indexOf("minmonsterhp")      == 0) return "Requires stage with monster HP " + n + "+";
            if (lower.indexOf("minmonsterarmor")   == 0) return "Requires stage with monster armor " + n + "+";
            if (lower.indexOf("minmonsters")       == 0) return "Requires stage with " + n + "+ monsters";
            if (lower.indexOf("minswarmlingarmor") == 0) return "Requires stage with swarmling armor " + n + "+";
            if (lower.indexOf("minswarmlings")     == 0) return "Requires stage that spawns " + n + "+ swarmlings";

            return "Requires " + req;
        }

        /** Evaluate a single requirement string.  Unknown patterns return true. */
        public function evaluateRequirement(req:String):Boolean {
            var lower:String = req.toLowerCase();

            // "X skill" or "X skill | Y skill" (pipe = OR)
            if (lower.indexOf(" skill") >= 0) {
                if (req.indexOf("|") >= 0) {
                    var opts:Array = req.split("|");
                    for each (var opt:String in opts) {
                        opt = _trim(opt);
                        var ol:String = opt.toLowerCase();
                        if (ol.indexOf(" skill") >= 0) {
                            var sn:String = _trim(opt.substring(0, ol.indexOf(" skill")));
                            var si:int    = SessionData.SKILL_NAMES.indexOf(sn);
                            if (si >= 0 && AV.sessionData.hasItem(700 + si)) return true;
                        }
                    }
                    return false;
                }
                var sEnd:int      = lower.indexOf(" skill");
                var skillName:String = _trim(req.substring(0, sEnd));
                var skillIdx:int  = SessionData.SKILL_NAMES.indexOf(skillName);
                if (skillIdx < 0) return false; // unknown skill name = not obtainable
                return AV.sessionData.hasItem(700 + skillIdx);
            }

            // "X element"            
            if (lower.indexOf(" element") >= 0) {
                var eEnd:int     = lower.indexOf(" element");
                var elemName:String = _trim(req.substring(0, eEnd));                
                if (_elementStages != null) {
                    var stages:Array = _elementStages[elemName] as Array;
                    // Empty list = always available (e.g. Tower, Wall — never shuffled).
                    if (stages != null && stages.length > 0) {
                        for each (var stId:String in stages) {
                            if (AV.sessionData.fieldsInLogic[stId] == true){
                                 return true;
                            }
                        }
                        return false;
                    }
                }
                return true; // no mapping or empty mapping = don't block
            }

            // "X trait" — includes "Any Battle trait"
            if (lower.indexOf(" trait") >= 0) {
                var tEnd:int      = lower.indexOf(" trait");
                var traitName:String = _trim(req.substring(0, tEnd));
                if (traitName.toLowerCase() == "any battle") {
                    for (var t:int = 0; t < 15; t++) {
                        if (AV.sessionData.hasItem(800 + t)) return true;
                    }
                    return false;
                }
                var traitIdx:int = TraitUnlocker.BATTLE_TRAIT_NAMES.indexOf(traitName);
                if (traitIdx < 0) return true; // unknown trait = don't block
                return AV.sessionData.hasItem(800 + traitIdx);
            }

            // "Field A4" or "Field N1, U1 or R5" (comma/or = OR)
            if (lower.indexOf("field ") == 0) {
                var fieldPart:String = _trim(req.substring(6));
                var fieldTokens:Array = fieldPart.split(/,\s*|\s+or\s+/i);
                for each (var fid:String in fieldTokens) {
                    fid = _trim(fid);
                    if (fid.length > 0 && AV.sessionData.fieldsInLogic[fid] == true) return true;
                }
                return false;
            }

            // Mode gates — mod is journey-only
            if (lower == "trial" || lower == "endurance" || lower == "endurance and trial") {
                return false;
            }

            // Spell / skill group counters
            if (lower.indexOf("skills") == 0) {
                var skillsNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return AV.sessionData.totalSkillsCollected >= skillsNeed;
            }
            if (lower.indexOf("strikespells") == 0) {
                var sNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return AV.sessionData.countItemsInRange(712, 714) >= sNeed;
            }
            if (lower.indexOf("enhancementspells") == 0) {
                var eNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return AV.sessionData.countItemsInRange(715, 717) >= eNeed;
            }
            if (lower.indexOf("gemskills") == 0) {
                // When pouch gating is active, gemSkills:N is replaced by
                // gemPouch:<prefix> on every stage. The N-skills count is
                // still meaningful for achievements (gem skills 706-711 are
                // still in the pool), so leave this gate alone.
                var gNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return AV.sessionData.countItemsInRange(706, 711) >= gNeed;
            }

            // "gemPouch:<prefix>" — per-prefix gem-orb gate. Inactive in
            // off mode (returns true); in distinct mode requires the named
            // pouch item; in progressive mode requires enough Progressive
            // Gempouch copies for that prefix's position in the play order.
            if (lower.indexOf("gempouch:") == 0) {
                var mode:int = AV.serverData.serverOptions.gemPouchGating;
                if (mode == 0) return true;
                var pouchPrefix:String = _trim(req.substring(req.indexOf(":") + 1));
                var order:Array = AV.serverData.serverOptions.gemPouchPlayOrder;
                if (order == null) return true;
                var idx:int = order.indexOf(pouchPrefix);
                if (idx < 0) return true; // unknown prefix — don't block
                if (mode == 1) {
                    return AV.sessionData.hasItem(626 + idx);
                }
                // mode == 2: progressive
                var progId:int = AV.serverData.serverOptions.gemPouchProgressiveId;
                if (progId <= 0) progId = 652;
                return AV.sessionData.getItemCount(progId) >= idx + 1;
            }

            if (lower.indexOf("battletraits") == 0) {
                var btNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return AV.sessionData.countItemsInRange(800, 814) >= btNeed;
            }

            // "minWave: N" / "beforeWave: N" — same gate (a stage with N+ waves
            // exists). beforeWave is kept distinct in data because its semantic
            // is "must happen before wave N", but the gen-time reachability gate
            // is identical.
            if (lower.indexOf("minwave") == 0 || lower.indexOf("beforewave") == 0) {
                var wNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _fieldEvaluator != null
                    && _fieldEvaluator.hasInLogicFieldWithMinWaves(wNeed);
            }

            // "fieldToken: N"
            if (lower.indexOf("fieldtoken") == 0) {
                var ftNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return AV.sessionData.countItemsInRange(1, 122) >= ftNeed;
            }

            // "shadowCore: N" — counts AP-distributed Shadow Core stash items.
            // Specific stashes 1000-1016, extras 1300-1351 (ranges per items.py).
            if (lower.indexOf("shadowcore") == 0) {
                var scNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                var scHave:int = AV.sessionData.countItemsInRange(1000, 1016)
                               + AV.sessionData.countItemsInRange(1300, 1351);
                return scHave >= scNeed;
            }

            // "wizardLevel: N" — half from AP-distributed XP items (1100-1199),
            // half assumed from natural play. Gate at ceil(N/2) items collected.
            if (lower.indexOf("wizardlevel") == 0) {
                var wlNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                var itemsNeeded:int = (wlNeed + 1) >> 1; // ceil(N/2)
                return AV.sessionData.countItemsInRange(1100, 1199) >= itemsNeeded;
            }

            // "talismanRow: N" — at least N complete matching-icon rows from
            // the 3x3 grid of progression talisman fragments. Row membership
            // is hardcoded apworld-side; the AP IDs ship in slot_data /
            // logic.json's matchingTalismans block.
            if (lower.indexOf("talismanrow") == 0) {
                var trNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _countMatchingTalismanSets(true) >= trNeed;
            }
            // "talismanColumn: N" — at least N complete columns of the same
            // grid (cross-icon position groups).
            if (lower.indexOf("talismancolumn") == 0) {
                var tcNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _countMatchingTalismanSets(false) >= tcNeed;
            }
            // "skillPoints: N" — sum of SP across collected Skillpoint Bundle
            // items (1700..1709, bundle apId-1699 = SP value).
            if (lower.indexOf("skillpoints") == 0) {
                var spNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _countSkillPoints() >= spNeed;
            }

            // Level monster stat requirements
            if (lower.indexOf("minmonsterhp") == 0) {
                var mhpNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _fieldEvaluator != null && _fieldEvaluator.hasInLogicFieldWithMinMonsterHP(mhpNeed);
            }
            if (lower.indexOf("minmonsterarmor") == 0) {
                var marmNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _fieldEvaluator != null && _fieldEvaluator.hasInLogicFieldWithMinMonsterArmor(marmNeed);
            }
            if (lower.indexOf("minmonsters") == 0) {
                var monsNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _fieldEvaluator != null && _fieldEvaluator.hasInLogicFieldWithMinMonsters(monsNeed);
            }
            if (lower.indexOf("minswarmlingarmor") == 0) {
                var sarmNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _fieldEvaluator != null && _fieldEvaluator.hasInLogicFieldWithMinSwarmlingArmor(sarmNeed);
            }
            // "minSwarmlings: N" — checked AFTER minSwarmlingArmor because the
            // shorter name is a prefix of the longer one.
            if (lower.indexOf("minswarmlings") == 0) {
                var swNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _fieldEvaluator != null && _fieldEvaluator.hasInLogicFieldWithMinSwarmlings(swNeed);
            }

            // Unknown requirement — don't block
            return true;
        }

        // -----------------------------------------------------------------------
        // In-level evaluation: filter achievements by the player's CURRENT loadout
        // and the CURRENT field's static design data, rather than AP-logic state.
        // Powers the "Available achievements this run" HUD panel.
        // -----------------------------------------------------------------------

        /** Returns true iff every requirement passes against the current in-level
         *  state described by `currentStrId` (e.g. "A4"). DNF-aware. */
        public function evaluateInLevelRequirements(requirements:Array,
                                                    currentStrId:String):Boolean {
            if (requirements == null || requirements.length == 0) return true;
            if (requirements[0] is Array) {
                for each (var group:* in requirements) {
                    var andGroup:Array = group as Array;
                    if (andGroup == null) continue;
                    var groupPasses:Boolean = true;
                    for each (var groupReq:* in andGroup) {
                        if (!evaluateInLevelRequirement(_trim(String(groupReq)), currentStrId)) {
                            groupPasses = false;
                            break;
                        }
                    }
                    if (groupPasses) return true;
                }
                return false;
            }
            for each (var req:* in requirements) {
                if (!evaluateInLevelRequirement(_trim(String(req)), currentStrId)) return false;
            }
            return true;
        }

        /** Single-requirement in-level evaluator. Falls back to the AP-logic
         *  check (`evaluateRequirement`) for loadout-independent counters. */
        public function evaluateInLevelRequirement(req:String, currentStrId:String):Boolean {
            var lower:String = req.toLowerCase();

            // "X skill" / "X skill | Y skill" — must be unlocked AND have level > 0
            if (lower.indexOf(" skill") >= 0) {
                if (req.indexOf("|") >= 0) {
                    var opts:Array = req.split("|");
                    for each (var opt:String in opts) {
                        opt = _trim(opt);
                        var ol:String = opt.toLowerCase();
                        if (ol.indexOf(" skill") >= 0) {
                            var sn:String = _trim(opt.substring(0, ol.indexOf(" skill")));
                            if (_isSkillActive(sn)) return true;
                        }
                    }
                    return false;
                }
                var sEnd:int = lower.indexOf(" skill");
                return _isSkillActive(_trim(req.substring(0, sEnd)));
            }

            // "X element" — current field's strId must appear in elementStages[X]
            if (lower.indexOf(" element") >= 0) {
                var eEnd:int = lower.indexOf(" element");
                var elemName:String = _trim(req.substring(0, eEnd));
                if (_elementStages != null) {
                    var stages:Array = _elementStages[elemName] as Array;
                    if (stages != null && stages.length > 0) {
                        for each (var stId:String in stages) {
                            if (stId == currentStrId) return true;
                        }
                        return false;
                    }
                }
                return true; // no/empty mapping = element always present
            }

            // "X trait" / "Any Battle trait" — must be unlocked AND level > 0
            if (lower.indexOf(" trait") >= 0) {
                var tEnd:int = lower.indexOf(" trait");
                var traitName:String = _trim(req.substring(0, tEnd));
                if (traitName.toLowerCase() == "any battle") {
                    for (var t:int = 0; t < 15; t++) {
                        if (AV.sessionData.hasItem(800 + t) && _traitLevel(t) > 0) return true;
                    }
                    return false;
                }
                var traitIdx:int = TraitUnlocker.BATTLE_TRAIT_NAMES.indexOf(traitName);
                if (traitIdx < 0) return true;
                return AV.sessionData.hasItem(800 + traitIdx) && _traitLevel(traitIdx) > 0;
            }

            // "Field A4" / "Field N1, U1 or R5" — current strId must match
            if (lower.indexOf("field ") == 0) {
                var fieldPart:String = _trim(req.substring(6));
                var fieldTokens:Array = fieldPart.split(/,\s*|\s+or\s+/i);
                for each (var fid:String in fieldTokens) {
                    fid = _trim(fid);
                    if (fid.length > 0 && fid == currentStrId) return true;
                }
                return false;
            }

            // Mode gates — mod is journey-only
            if (lower == "trial" || lower == "endurance" || lower == "endurance and trial") {
                return false;
            }

            // Threshold-style requirements — evaluated against the current field's
            // static design data from level_stats.json.
            if (lower.indexOf("minwave") == 0 || lower.indexOf("beforewave") == 0) {
                var wNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _stat(currentStrId, "WaveCount") >= wNeed;
            }
            if (lower.indexOf("minmonsterhp") == 0) {
                var mhpNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _maxStat(currentStrId, "ReaverMaxHP", "SwarmlingMaxHP", "GiantMaxHP") >= mhpNeed;
            }
            if (lower.indexOf("minmonsterarmor") == 0) {
                var marmNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _maxStat(currentStrId, "ReaverMaxArmor", "SwarmlingMaxArmor", "GiantMaxArmor") >= marmNeed;
            }
            if (lower.indexOf("minmonsters") == 0) {
                var monsNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _stat(currentStrId, "MonsterCount") >= monsNeed;
            }
            if (lower.indexOf("minswarmlingarmor") == 0) {
                var sarmNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _stat(currentStrId, "SwarmlingMaxArmor") >= sarmNeed;
            }
            if (lower.indexOf("minswarmlings") == 0) {
                var swNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _stat(currentStrId, "SwarmlingCount") >= swNeed;
            }

            // Loadout-independent counters (skillsPoints, strikeSpells, fieldToken,
            // shadowCore, wizardLevel, BattleTraits, gemSkills, ...) — same gate as
            // AP-logic mode.
            return evaluateRequirement(req);
        }

        // -----------------------------------------------------------------------
        // In-level helpers

        private function _traitLevel(traitGameId:int):int {
            try {
                if (GV.ppd != null && GV.ppd.selectedBattleTraitLevels != null) {
                    var slot:* = GV.ppd.selectedBattleTraitLevels[traitGameId];
                    if (slot != null) return int(slot.g());
                }
            } catch (e:Error) {}
            return 0;
        }

        private function _skillLevel(skillGameId:int):int {
            try {
                if (GV.ppd != null) return int(GV.ppd.getSkillLevel(skillGameId));
            } catch (e:Error) {}
            return -1;
        }

        private function _isSkillActive(skillName:String):Boolean {
            var skillIdx:int = SessionData.SKILL_NAMES.indexOf(skillName);
            if (skillIdx < 0) return false;
            if (!AV.sessionData.hasItem(700 + skillIdx)) return false;
            return _skillLevel(skillIdx) > 0;
        }

        private function _stat(strId:String, key:String):int {
            if (strId == null) return 0;
            var stats:Object = AV.gameData.levelStats != null ? AV.gameData.levelStats[strId] : null;
            if (stats == null || stats[key] == null) return 0;
            return int(stats[key]);
        }

        private function _maxStat(strId:String, k1:String, k2:String, k3:String):int {
            var a:int = _stat(strId, k1);
            var b:int = _stat(strId, k2);
            var c:int = _stat(strId, k3);
            var m:int = a;
            if (b > m) m = b;
            if (c > m) m = c;
            return m;
        }

        private function _trim(s:String):String {
            return s.replace(/^\s+|\s+$/g, "");
        }

        /**
         * Count complete matching-talisman sets (rows or columns) the player
         * holds. Both row and column groupings come from
         * AV.serverData.matchingTalismans (loaded from logic.json), each as
         * a 3-element array of arrays of AP IDs.
         */
        private function _countMatchingTalismanSets(rows:Boolean):int {
            var mt:Object = AV.serverData != null ? AV.serverData.matchingTalismans : null;
            if (mt == null) return 0;
            var sets:Array = (rows ? mt.rows : mt.columns) as Array;
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

        /**
         * Sum SP across collected Skillpoint Bundle items. Bundle apId-1699
         * is the bundle's SP value (1..10). state.has equivalent is
         * AV.sessionData.hasItem; we don't track per-AP-id duplicates, so
         * each held bundle counts once. Mirrors apworld's _count_skill_points
         * with the same approximation.
         */
        private function _countSkillPoints():int {
            var total:int = 0;
            for (var size:int = 1; size <= 10; size++) {
                if (AV.sessionData.hasItem(1699 + size))
                    total += size;
            }
            return total;
        }
    }
}

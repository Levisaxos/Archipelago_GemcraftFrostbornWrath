package tracker {
    import Bezel.Logger;
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
            if (lower.indexOf("battletraits")      == 0) return "Requires " + n + " battle traits";
            if (lower.indexOf("minwave")            == 0) return "Requires stage with " + n + "+ waves";
            if (lower.indexOf("fieldtoken")        == 0) return "Requires " + n + "+ field tokens";
            if (lower.indexOf("minmonsterhp")      == 0) return "Requires stage with monster HP " + n + "+";
            if (lower.indexOf("minmonsterarmor")   == 0) return "Requires stage with monster armor " + n + "+";
            if (lower.indexOf("minmonsters")       == 0) return "Requires stage with " + n + "+ monsters";
            if (lower.indexOf("minswarmlingarmor") == 0) return "Requires stage with swarmling armor " + n + "+";

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
                    if (stages != null) {
                        for each (var stId:String in stages) {                               
                            if (AV.sessionData.fieldsInLogic[stId] == true){
                                _logger.log(_modName, "Found field " + stId + " in fieldsInLogic");
                                 return true;
                            }
                        }
                        return false;
                    }
                }
                return true; // no mapping = don't block
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
                var gNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return AV.sessionData.countItemsInRange(706, 711) >= gNeed;
            }
            if (lower.indexOf("battletraits") == 0) {
                var btNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return AV.sessionData.countItemsInRange(800, 814) >= btNeed;
            }

            // "minWave: N"
            if (lower.indexOf("minwave") == 0) {
                var wNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _fieldEvaluator != null
                    && _fieldEvaluator.hasInLogicFieldWithMinWaves(wNeed);
            }

            // "fieldToken: N"
            if (lower.indexOf("fieldtoken") == 0) {
                var ftNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return AV.sessionData.countItemsInRange(1, 122) >= ftNeed;
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

            // Unknown requirement — don't block
            return true;
        }

        private function _trim(s:String):String {
            return s.replace(/^\s+|\s+$/g, "");
        }
    }
}

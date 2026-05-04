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
     * Vocabulary (mirrors apworld/gcfw/rules.py):
     *   sX            — skill check; X is the PascalCase skill name (sBolt, sIceShards…)
     *   tX            — battle-trait check (tHaste, tRitual, tAdaptiveCarapace…)
     *   eX            — element-presence check (eBeacon, eMonsterNest…)
     *   eX:N          — element-with-count check (eBeacon:5 = stage with BeaconCount >= 5)
     *   wX            — weather (wRain, wSnow) — modelled as elements
     *   mTrial / mEndurance — mode gates; always-false in journey-only
     *   Field A4      — legacy stage-in-logic check (apworld emits Field_X4 server-side)
     *
     *   Counters (key:N):
     *     skills:N, strikeSpells:N, enhancementSpells:N, gemSkills:N,
     *     battleTraits:N (case-insensitive),
     *     minWave:N / beforeWave:N, fieldToken:N, shadowCore:N, wizardLevel:N,
     *     skillPoints:N, talismanRow:N, talismanColumn:N,
     *     talismanCornerFragment:N, talismanEdgeFragment:N,
     *     talismanCenterFragment:N, talismanFragments:N,
     *     minMonsters:N, minMonsterHP:N, minMonsterArmor:N,
     *     minSwarmlings:N, minSwarmlingArmor:N,
     *     minGiants:N, minReavers:N, markedMonster:N, minMonstersBeforeWave12:N,
     *     gemPouch:<prefix>
     */
    public class LogicEvaluator {

        // `eNonMonsters` is a group token resolving to "any of these
        // non-monster creatures is reachable on a stage in logic". Mirrors
        // the `non_monsters_group` list in apworld/gcfw/rulesdata_settings.py.
        private static const NON_MONSTERS:Array = [
            "Apparition", "Shadow", "Specter", "Spire", "Wizard Hunter", "Wraith",
        ];

        private var _logger:Logger;
        private var _modName:String;
        private var _fieldEvaluator:FieldLogicEvaluator;
        private var _elementStages:Object; // element name -> Array<String> of stage strIds

        // Prefix-encoded → game-name lookup tables (built in configure()).
        private var _skillPrefixMap:Object   = {}; // "sBolt"   -> "Bolt"
        private var _traitPrefixMap:Object   = {}; // "tHaste"  -> "Haste"
        private var _elementPrefixMap:Object = {}; // "eBeacon" -> "Beacon"

        // Talisman-fragment AP id buckets by type (built in configure()).
        // Filled from AV.serverData.talismanMap (apId -> "seed/rarity/type/upgradeLevel").
        private var _edgeFragIds:Array   = [];
        private var _cornerFragIds:Array = [];
        private var _innerFragIds:Array  = [];
        private var _allFragIds:Array    = [];

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
            _buildPrefixMaps();
            _buildTalismanIdBuckets();
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

            // ---- New prefix vocabulary descriptions ---------------------
            if (req == "mTrial" || req == "mEndurance")
            {
                return null;
            }
            if (req.indexOf("Field_") == 0)
            {
                return "Requires field " + req.substring(6) + " in logic";
            }
            if (req == "eNonMonsters" || req.indexOf("eNonMonsters:") == 0)
            {
                return "Requires any non-monster creature stage (Shadow / Specter / Spire / Wizard Hunter / Wraith / Apparition)";
            }
            if (req.length >= 2 && _isUpper(req.charAt(1)) && req.indexOf(":") < 0)
            {
                var firstCharD:String = req.charAt(0);
                if (firstCharD == "s" && _skillPrefixMap[req] != null)
                {
                    return "Requires " + _skillPrefixMap[req] + " skill";
                }
                if (firstCharD == "t" && _traitPrefixMap[req] != null)
                {
                    return "Requires " + _traitPrefixMap[req] + " Battle trait";
                }
                if ((firstCharD == "e" || firstCharD == "w"))
                {
                    var elemD:String = _elementPrefixMap[req];
                    if (elemD == null)
                    {
                        elemD = req.substring(1);
                    }
                    if (_elementStages != null)
                    {
                        var stagesD:Array = _elementStages[elemD] as Array;
                        if (stagesD != null && stagesD.length > 0)
                        {
                            var sortedD:Array = stagesD.concat();
                            sortedD.sort(Array.CASEINSENSITIVE);
                            if (sortedD.length == 1)
                            {
                                return "Requires " + elemD + " on " + sortedD[0];
                            }
                            return "Requires " + elemD + " (any of " + sortedD.join(", ") + ")";
                        }
                    }
                    return "Requires " + elemD;
                }
            }
            if (req.length >= 2 && req.charAt(0) == "e" && _isUpper(req.charAt(1)) && req.indexOf(":") > 0)
            {
                var ecD:int = req.indexOf(":");
                var eheadD:String = req.substring(0, ecD);
                var ecountD:int = int(_trim(req.substring(ecD + 1)));
                var elemNameD:String = _elementPrefixMap[eheadD];
                if (elemNameD == null)
                {
                    elemNameD = eheadD.substring(1);
                }
                return "Requires stage with " + ecountD + "+ " + elemNameD;
            }
            // -------------------------------------------------------------

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
            if (lower.indexOf("minmonstersbeforewave12") == 0) return "Requires stage with " + n + "+ monsters and 12+ waves";
            if (lower.indexOf("minmonsters")       == 0) return "Requires stage with " + n + "+ monsters";
            if (lower.indexOf("minswarmlingarmor") == 0) return "Requires stage with swarmling armor " + n + "+";
            if (lower.indexOf("minswarmlings")     == 0) return "Requires stage that spawns " + n + "+ swarmlings";
            if (lower.indexOf("mingiants")         == 0) return "Requires stage that spawns " + n + "+ giants";
            if (lower.indexOf("minreavers")        == 0) return "Requires stage that spawns " + n + "+ reavers";
            if (lower.indexOf("markedmonster")     == 0) return "Requires stage that spawns marked monsters";
            if (lower.indexOf("talismancornerfragment") == 0) return "Requires " + n + "+ corner talisman fragments";
            if (lower.indexOf("talismanedgefragment")   == 0) return "Requires " + n + "+ edge talisman fragments";
            if (lower.indexOf("talismancenterfragment") == 0) return "Requires " + n + "+ center talisman fragments";
            if (lower.indexOf("talismanfragments")      == 0) return "Requires " + n + "+ talisman fragments";

            return "Requires " + req;
        }

        /** Evaluate a single requirement string.  Unknown patterns return true. */
        public function evaluateRequirement(req:String):Boolean {
            var lower:String = req.toLowerCase();

            // ---- New prefix vocabulary -----------------------------------
            // Mode tokens: journey-only mod, so trial/endurance never satisfy.
            if (req == "mTrial" || req == "mEndurance")
            {
                return false;
            }
            // eNonMonsters[:N] — any of the Ritual-spawned creatures is
            // reachable on a stage in logic.  The count is unused.
            if (req == "eNonMonsters" || req.indexOf("eNonMonsters:") == 0)
            {
                for each (var nmName:String in NON_MONSTERS)
                {
                    if (_elementInLogic(nmName))
                    {
                        return true;
                    }
                }
                return false;
            }
            // eWizardStash — every stage has a wizard stash structurally,
            // but each is locked behind a per-stage key item (AP IDs
            // 1400..1521).  Pass the gate iff the player holds at least one
            // key whose stage is also clearable (per-stage tier + WIZLOCK
            // skills).  Mirrors apworld's _eval_element_reachable: holding a
            // key for an unbeatable stage doesn't make the stash reachable.
            if (req == "eWizardStash" || req.indexOf("eWizardStash:") == 0)
            {
                if (_fieldEvaluator == null) return false;
                var unlocked:Object = AV.sessionData.unlockedStashesByStrId;
                for (var stashSid:String in unlocked)
                {
                    if (unlocked[stashSid] == true
                            && _fieldEvaluator.isStashGateMet(stashSid))
                    {
                        return true;
                    }
                }
                return false;
            }
            // Prefix tokens (sBolt / tHaste / eBeacon / wRain).  Must take
            // precedence over the legacy " skill"/" element"/" trait" forms
            // and over the colon-counter dispatch below.
            if (req.length >= 2 && _isUpper(req.charAt(1)) && req.indexOf(":") < 0)
            {
                var firstChar:String = req.charAt(0);
                if (firstChar == "s")
                {
                    var sName:String = _skillPrefixMap[req];
                    if (sName != null)
                    {
                        // Gem-skill tokens broaden: also pass when a stage
                        // with the matching starter pouch is reachable.
                        if (_GEM_SKILL_TO_GEM_NAME[sName] != null)
                            return _hasGemSkillBroadenedAP(sName);
                        var sIdx:int = SessionData.SKILL_NAMES.indexOf(sName);
                        return sIdx >= 0 && AV.sessionData.hasItem(700 + sIdx);
                    }
                }
                else if (firstChar == "t")
                {
                    var tName:String = _traitPrefixMap[req];
                    if (tName != null)
                    {
                        var tIdx:int = TraitUnlocker.BATTLE_TRAIT_NAMES.indexOf(tName);
                        return tIdx >= 0 && AV.sessionData.hasItem(800 + tIdx);
                    }
                }
                else if (firstChar == "e" || firstChar == "w")
                {
                    var elemMapped:String = _elementPrefixMap[req];
                    if (elemMapped != null)
                    {
                        return _elementInLogic(elemMapped);
                    }
                    // Mod-only / unmapped element: treat token body as the name.
                    return _elementInLogic(req.substring(1));
                }
            }
            // eX:N — element with a per-stage count.
            if (req.length >= 2 && req.charAt(0) == "e" && _isUpper(req.charAt(1)) && req.indexOf(":") > 0)
            {
                var ec:int = req.indexOf(":");
                var ehead:String = req.substring(0, ec);
                var ecount:int = int(_trim(req.substring(ec + 1)));
                var enameMapped:String = _elementPrefixMap[ehead];
                var nameForField:String = (enameMapped != null) ? _pascalNoSpaces(enameMapped) : ehead.substring(1);
                // Wizard towers are the visual structure of wizard stashes —
                // unlocking a wizard tower requires opening its stash. Treat
                // eWizardTower:N like eWizardStash: needs an unlocked stash on
                // a clearable stage with the matching tower count.
                if (ehead == "eWizardTower" || nameForField == "WizardTower") {
                    if (_fieldEvaluator == null) return false;
                    var unlockedTowers:Object = AV.sessionData.unlockedStashesByStrId;
                    for (var towerSid:String in unlockedTowers) {
                        if (unlockedTowers[towerSid] != true) continue;
                        if (!_fieldEvaluator.isStashGateMet(towerSid)) continue;
                        if (_fieldEvaluator.stageHasElementCount(towerSid, "WizardTower", ecount)) {
                            return true;
                        }
                    }
                    return false;
                }
                return _fieldEvaluator != null
                    && _fieldEvaluator.hasInLogicFieldWithElementCount(nameForField, ecount);
            }
            // -------------------------------------------------------------

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

            // Field_<sid> — single stage must be in logic. Apworld emits this
            // form for per-stage prerequisites (e.g. Zapped requires Field_L5).
            if (req.indexOf("Field_") == 0) {
                var fSid:String = req.substring(6);
                return fSid.length > 0 && AV.sessionData.fieldsInLogic[fSid] == true;
            }

            // "Field A4" or "Field N1, U1 or R5" (comma/or = OR) — legacy form.
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
                // gemSkills:N broadens like the bare gem-skill tokens — a
                // skill counts as available if held OR a stage with the
                // matching starter pouch is reachable.  When pouch gating
                // is active, this gate still works against the gem-skill
                // items (706-711) that remain in the pool.
                var gNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _countGemSkillsBroadenedAP() >= gNeed;
            }

            // "gemPouch:<prefix>" — per-prefix gem-orb gate. Granularity-aware:
            //   off (0)        → no gating, always true
            //   per_tile (1)   → state.has("Gempouch (<prefix>)")
            //   progressive(2) → state.count("Progressive Gempouch") >= idx+1
            //   per_tier (3)   → state.has("Tier <N> Gempouch") for stage's tier
            //                    (requires a stage str_id reference; the
            //                    requirement string only carries prefix, so
            //                    per_tier is checked at stage-level — here we
            //                    fall back to "any tier pouch held" which is
            //                    permissive but safe for tracker preview)
            //   global (4)     → state.has("Master Gempouch")
            if (lower.indexOf("gempouch:") == 0) {
                var mode:int = AV.serverData.serverOptions.gemPouchGranularity;
                if (mode == 0) return true;
                if (mode == 5) {
                    return AV.sessionData.hasItem(1614); // POUCH_MASTER_ID
                }
                var pouchPrefix:String = _trim(req.substring(req.indexOf(":") + 1));
                if (mode == 1) {
                    // per_tile (distinct): canonical order for ID lookup.
                    var orderD:Array = AV.serverData.serverOptions.gemPouchPlayOrder;
                    if (orderD == null) return true;
                    var idxD:int = orderD.indexOf(pouchPrefix);
                    if (idxD < 0) return true;
                    return AV.sessionData.hasItem(626 + idxD);
                }
                if (mode == 2) {
                    // per_tile_progressive: starter-first count threshold.
                    var orderP:Array = AV.serverData.serverOptions.progressiveTileOrder;
                    if (orderP == null || orderP.length == 0)
                        orderP = AV.serverData.serverOptions.gemPouchPlayOrder;
                    if (orderP == null) return true;
                    var idxP:int = orderP.indexOf(pouchPrefix);
                    if (idxP < 0) return true;
                    var progId:int = AV.serverData.serverOptions.gemPouchProgressiveId;
                    if (progId <= 0) progId = 652;
                    return AV.sessionData.getItemCount(progId) >= idxP + 1;
                }
                if (mode == 3 || mode == 4) {
                    // per_tier (3) and per_tier_progressive (4): without a
                    // specific stage in scope, accept if ANY tier pouch is
                    // held that covers a stage with this prefix.
                    var tierMap:Object = AV.serverData.serverOptions.stageTierByStrId;
                    if (tierMap == null) return true;
                    var tierProgId:int = int(AV.serverData.serverOptions.gemPouchPerTierProgressiveId);
                    var tierOrd:Array = AV.serverData.serverOptions.progressiveTierOrder as Array;
                    for (var sid:String in tierMap) {
                        if (sid.charAt(0) == pouchPrefix) {
                            var st:int = int(tierMap[sid]);
                            if (mode == 3) {
                                if (AV.sessionData.hasItem(1601 + st))
                                    return true;
                            } else if (tierProgId > 0) {
                                // mode == 4: starter-first count threshold.
                                var posT:int = (tierOrd != null && tierOrd.length > 0)
                                                  ? tierOrd.indexOf(st) : st;
                                if (posT < 0) continue;
                                if (AV.sessionData.getItemCount(tierProgId) >= posT + 1)
                                    return true;
                            }
                        }
                    }
                    return false;
                }
                return true;
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

            // "shadowCore: N" — sum core amounts of held shadow-core stash
            // items.  Mirrors the apworld gate: each stash grants a specific
            // amount (per slot_data.shadow_core_map: apId -> amount), and we
            // need the sum of held amounts to reach N.  Only items the player
            // actually has count.
            if (lower.indexOf("shadowcore") == 0) {
                var scNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _sumShadowCores() >= scNeed;
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
            // "minGiants:N" / "minReavers:N" — stage-with-N-of-monster-type checks.
            if (lower.indexOf("mingiants") == 0)
            {
                var nGiants:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _fieldEvaluator != null && _fieldEvaluator.hasInLogicFieldWithMinGiants(nGiants);
            }
            if (lower.indexOf("minreavers") == 0)
            {
                var nReavers:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _fieldEvaluator != null && _fieldEvaluator.hasInLogicFieldWithMinReavers(nReavers);
            }
            // "minMonstersBeforeWave12:N" — composite gate (only used by one
            // achievement). At gen time and runtime we approximate as
            // "stage with >=N monsters AND >=12 waves is in logic".
            if (lower.indexOf("minmonstersbeforewave12") == 0)
            {
                var mbwNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _fieldEvaluator != null
                    && _fieldEvaluator.hasInLogicFieldWithMinMonstersBeforeWave12(mbwNeed);
            }
            // "markedMonster:N" — uses the dedicated MarkedMonsterCount
            // level-stat field (populated from a simulator that estimates
            // expected marked monsters per stage).  Passes when any in-logic
            // stage's expected MarkedMonsterCount >= N.
            if (lower.indexOf("markedmonster") == 0)
            {
                var mmNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _fieldEvaluator != null
                    && _fieldEvaluator.hasInLogicFieldWithMarkedMonsterCount(mmNeed);
            }
            // Talisman-fragment-by-type counters.  Bucket lists are built
            // from talismanMap on configure(); each fragment AP id is in
            // exactly one of edge/corner/inner.
            if (lower.indexOf("talismancornerfragment") == 0)
            {
                var tcfNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _countItemsInList(_cornerFragIds) >= tcfNeed;
            }
            if (lower.indexOf("talismanedgefragment") == 0)
            {
                var tefNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _countItemsInList(_edgeFragIds) >= tefNeed;
            }
            if (lower.indexOf("talismancenterfragment") == 0)
            {
                var tcenNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _countItemsInList(_innerFragIds) >= tcenNeed;
            }
            // Total fragments (any type).  Checked AFTER the typed ones
            // because "talismanFragments" is not a prefix of those names.
            if (lower.indexOf("talismanfragments") == 0)
            {
                var tfgNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _countItemsInList(_allFragIds) >= tfgNeed;
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

            // ---- New prefix vocabulary -----------------------------------
            if (req == "mTrial" || req == "mEndurance")
            {
                return false;
            }
            // eNonMonsters[:N] in-level: pass if the current stage hosts
            // any of the Ritual-spawned creatures.
            if (req == "eNonMonsters" || req.indexOf("eNonMonsters:") == 0)
            {
                for each (var nmNameIL:String in NON_MONSTERS)
                {
                    if (_elementStages != null)
                    {
                        var nmStages:Array = _elementStages[nmNameIL] as Array;
                        if (nmStages != null)
                        {
                            for each (var nmStId:String in nmStages)
                            {
                                if (nmStId == currentStrId)
                                {
                                    return true;
                                }
                            }
                        }
                    }
                }
                return false;
            }
            if (req.length >= 2 && _isUpper(req.charAt(1)) && req.indexOf(":") < 0)
            {
                var firstCharIL:String = req.charAt(0);
                if (firstCharIL == "s")
                {
                    var sNameIL:String = _skillPrefixMap[req];
                    if (sNameIL != null)
                    {
                        // Gem-skill tokens broaden: also pass when the
                        // current stage's starter pouch contains the gem.
                        if (_GEM_SKILL_TO_GEM_NAME[sNameIL] != null)
                            return _hasGemSkillOnStage(sNameIL, currentStrId);
                        return _isSkillActive(sNameIL);
                    }
                }
                else if (firstCharIL == "t")
                {
                    var tNameIL:String = _traitPrefixMap[req];
                    if (tNameIL != null)
                    {
                        var tIdxIL:int = TraitUnlocker.BATTLE_TRAIT_NAMES.indexOf(tNameIL);
                        return tIdxIL >= 0
                            && AV.sessionData.hasItem(800 + tIdxIL)
                            && _traitLevel(tIdxIL) > 0;
                    }
                }
                else if (firstCharIL == "e" || firstCharIL == "w")
                {
                    var elemMappedIL:String = _elementPrefixMap[req];
                    var lookupNameIL:String = (elemMappedIL != null) ? elemMappedIL : req.substring(1);
                    if (_elementStages != null)
                    {
                        var stagesIL:Array = _elementStages[lookupNameIL] as Array;
                        if (stagesIL != null && stagesIL.length > 0)
                        {
                            for each (var stIdIL:String in stagesIL)
                            {
                                if (stIdIL == currentStrId)
                                {
                                    return true;
                                }
                            }
                            return false;
                        }
                    }
                    return true;
                }
            }
            // eX:N — stage-element count check against the CURRENT stage's stats.
            if (req.length >= 2 && req.charAt(0) == "e" && _isUpper(req.charAt(1)) && req.indexOf(":") > 0)
            {
                var ecIL:int = req.indexOf(":");
                var eheadIL:String = req.substring(0, ecIL);
                var ecountIL:int = int(_trim(req.substring(ecIL + 1)));
                var enameMappedIL:String = _elementPrefixMap[eheadIL];
                var fieldName:String = ((enameMappedIL != null) ? _pascalNoSpaces(enameMappedIL) : eheadIL.substring(1)) + "Count";
                return _stat(currentStrId, fieldName) >= ecountIL;
            }
            // -------------------------------------------------------------

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

            // Field_<sid> — current strId must match the single named stage.
            // Apworld emits this form for per-stage prerequisites.
            if (req.indexOf("Field_") == 0) {
                var fSidIL:String = req.substring(6);
                return fSidIL == currentStrId;
            }

            // "Field A4" / "Field N1, U1 or R5" — current strId must match (legacy form).
            if (lower.indexOf("field ") == 0) {
                var fieldPart:String = _trim(req.substring(6));
                var fieldTokens:Array = fieldPart.split(/,\s*|\s+or\s+/i);
                for each (var fid:String in fieldTokens) {
                    fid = _trim(fid);
                    if (fid.length > 0 && fid == currentStrId) return true;
                }
                return false;
            }

            // Mode gates — mod is journey-only.  New tokens (mTrial / mEndurance)
            // are caught up top; legacy lowercase strings are kept for old data.
            if (lower == "trial" || lower == "endurance" || lower == "endurance and trial") {
                return false;
            }

            // Threshold-style requirements — evaluated against the current field's
            // static design data from level_stats.json.
            if (lower.indexOf("minwave") == 0 || lower.indexOf("beforewave") == 0) {
                var wNeed:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _stat(currentStrId, "WaveCount") >= wNeed;
            }
            if (lower.indexOf("mingiants") == 0)
            {
                var nGiantsIL:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _stat(currentStrId, "GiantCount") >= nGiantsIL;
            }
            if (lower.indexOf("minreavers") == 0)
            {
                var nReaversIL:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _stat(currentStrId, "ReaverCount") >= nReaversIL;
            }
            if (lower.indexOf("minmonstersbeforewave12") == 0)
            {
                var mbwNeedIL:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _stat(currentStrId, "MonsterCount") >= mbwNeedIL
                    && _stat(currentStrId, "WaveCount") >= 12;
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

            // gemSkills:N is in-level-aware: count of held gem-skill items
            // PLUS gems available on THIS stage's starter pouch.  Falling
            // through to evaluateRequirement would use the AP-logic
            // (cross-stage) count which is too lenient for "doable here".
            if (lower.indexOf("gemskills") == 0) {
                var gNeedIL:int = int(_trim(lower.substring(lower.indexOf(":") + 1)));
                return _countGemSkillsOnStage(currentStrId) >= gNeedIL;
            }

            // Loadout-independent counters (skillsPoints, strikeSpells, fieldToken,
            // shadowCore, wizardLevel, BattleTraits, ...) — same gate as
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

        /**
         * Sum core amounts of held shadow-core stash items.  shadowCoreMap
         * maps apId(str) -> amount(int), shipped via slot_data.  Iterates
         * the map and sums amounts for every item the player currently has.
         */
        private function _sumShadowCores():int {
            if (AV.serverData == null || AV.serverData.shadowCoreMap == null)
            {
                return 0;
            }
            var total:int = 0;
            var map:Object = AV.serverData.shadowCoreMap;
            for (var apIdStr:String in map)
            {
                if (AV.sessionData.hasItem(int(apIdStr)))
                {
                    total += int(map[apIdStr]);
                }
            }
            return total;
        }

        // -----------------------------------------------------------------
        // Prefix vocabulary helpers
        // -----------------------------------------------------------------

        private function _isUpper(ch:String):Boolean {
            return ch >= "A" && ch <= "Z";
        }

        /** Convert a space-separated game name to PascalCase with no spaces.
         *  e.g. "Strength in Numbers" -> "StrengthInNumbers". */
        private function _pascalNoSpaces(name:String):String {
            if (name == null || name.length == 0)
            {
                return "";
            }
            var parts:Array = name.split(/\s+/);
            var result:String = "";
            for each (var p:String in parts)
            {
                if (p == null || p.length == 0)
                {
                    continue;
                }
                result += p.charAt(0).toUpperCase() + p.substring(1);
            }
            return result;
        }

        private function _buildPrefixMaps():void {
            _skillPrefixMap   = {};
            _traitPrefixMap   = {};
            _elementPrefixMap = {};
            if (_elementStages != null)
            {
                for (var elemName:String in _elementStages)
                {
                    _elementPrefixMap["e" + _pascalNoSpaces(elemName)] = elemName;
                }
            }
            // Weather entries may not be in elementStages; map them explicitly.
            if (_elementPrefixMap["wRain"] == null)
            {
                _elementPrefixMap["wRain"] = "Rain";
            }
            if (_elementPrefixMap["wSnow"] == null)
            {
                _elementPrefixMap["wSnow"] = "Snow";
            }
            for each (var skillName:String in SessionData.SKILL_NAMES)
            {
                _skillPrefixMap["s" + _pascalNoSpaces(skillName)] = skillName;
            }
            for each (var traitName:String in TraitUnlocker.BATTLE_TRAIT_NAMES)
            {
                _traitPrefixMap["t" + _pascalNoSpaces(traitName)] = traitName;
            }
        }

        /** Group every talisman fragment AP id into edge/corner/inner buckets
         *  by parsing the talismanMap value (slash-separated; index 2 is type:
         *  0=EDGE, 1=CORNER, 2=INNER). */
        private function _buildTalismanIdBuckets():void {
            _edgeFragIds   = [];
            _cornerFragIds = [];
            _innerFragIds  = [];
            _allFragIds    = [];
            var talMap:Object = (AV.serverData != null) ? AV.serverData.talismanMap : null;
            if (talMap == null)
            {
                return;
            }
            for (var apIdStr:String in talMap)
            {
                var apId:int = int(apIdStr);
                var parts:Array = String(talMap[apIdStr]).split("/");
                if (parts.length < 3)
                {
                    continue;
                }
                var typeId:int = int(parts[2]);
                _allFragIds.push(apId);
                if (typeId == 0)
                {
                    _edgeFragIds.push(apId);
                }
                else if (typeId == 1)
                {
                    _cornerFragIds.push(apId);
                }
                else if (typeId == 2)
                {
                    _innerFragIds.push(apId);
                }
            }
        }

        private function _countItemsInList(ids:Array):int {
            var c:int = 0;
            for each (var apId:int in ids)
            {
                if (AV.sessionData.hasItem(apId))
                {
                    c++;
                }
            }
            return c;
        }

        /** Skill name -> in-game gem name (matches `availableGems` entries
         *  in logic.json).  Used to broaden gem-skill `sX` tokens and the
         *  gemSkills:N counter so a reachable starter pouch satisfies the
         *  gate without an item drop.  Mirrors apworld
         *  rules._GEM_TOKEN_TO_GEM_NAME. */
        private static const _GEM_SKILL_TO_GEM_NAME:Object = {
            "Critical Hit":   "Crit",
            "Mana Leech":     "Leech",
            "Bleeding":       "Bleed",
            "Armor Tearing":  "Armor Tear",
            "Poison":         "Poison",
            "Slowing":        "Slow"
        };

        private static const _GEM_SKILL_NAMES:Array = [
            "Critical Hit", "Mana Leech", "Bleeding",
            "Armor Tearing", "Poison", "Slowing"
        ];

        /** True if any in-logic stage's `availableGems` lists `gemName` AND
         *  the player has the matching prefix's gempouch (when gating is on). */
        private function _gemReachableInLogic(gemName:String):Boolean {
            if (AV.serverData == null || AV.serverData.stageAvailableGems == null)
                return false;
            if (AV.sessionData == null || AV.sessionData.fieldsInLogic == null)
                return false;
            var pools:Object = AV.serverData.stageAvailableGems;
            var fields:Object = AV.sessionData.fieldsInLogic;
            for (var sid:String in pools) {
                if (fields[sid] != true) continue;
                if (sid.length == 0 || !AV.sessionData.hasPouchForPrefix(sid.charAt(0))) continue;
                var arr:Array = pools[sid] as Array;
                if (arr == null) continue;
                for each (var g:String in arr) {
                    if (g == gemName) return true;
                }
            }
            return false;
        }

        /** True if `stageStrId`'s `availableGems` lists `gemName` AND the
         *  player has the matching prefix's gempouch. */
        private function _gemOnStage(stageStrId:String, gemName:String):Boolean {
            if (AV.serverData == null || AV.serverData.stageAvailableGems == null)
                return false;
            if (stageStrId == null || stageStrId.length == 0)
                return false;
            if (!AV.sessionData.hasPouchForPrefix(stageStrId.charAt(0)))
                return false;
            var arr:Array = AV.serverData.stageAvailableGems[stageStrId] as Array;
            if (arr == null) return false;
            for each (var g:String in arr) {
                if (g == gemName) return true;
            }
            return false;
        }

        /** AP-logic broadened check: skill item held OR any reachable stage's
         *  pouch contains the matching gem. */
        private function _hasGemSkillBroadenedAP(skillName:String):Boolean {
            var idx:int = SessionData.SKILL_NAMES.indexOf(skillName);
            if (idx >= 0 && AV.sessionData.hasItem(700 + idx)) return true;
            var gemName:String = _GEM_SKILL_TO_GEM_NAME[skillName];
            if (gemName == null) return false;
            return _gemReachableInLogic(gemName);
        }

        /** In-level broadened check: skill item held OR THIS stage's pouch
         *  contains the matching gem. */
        private function _hasGemSkillOnStage(skillName:String, currentStrId:String):Boolean {
            if (_isSkillActive(skillName)) return true;
            var gemName:String = _GEM_SKILL_TO_GEM_NAME[skillName];
            if (gemName == null) return false;
            return _gemOnStage(currentStrId, gemName);
        }

        /** Count of gem skills 'available' under the AP-logic broadened
         *  rule (each one held OR reachable via some pouch). */
        private function _countGemSkillsBroadenedAP():int {
            var n:int = 0;
            for each (var skillName:String in _GEM_SKILL_NAMES) {
                if (_hasGemSkillBroadenedAP(skillName)) n++;
            }
            return n;
        }

        /** Count of gem skills 'available' on a specific stage (held OR
         *  on that stage's pouch). */
        private function _countGemSkillsOnStage(currentStrId:String):int {
            var n:int = 0;
            for each (var skillName:String in _GEM_SKILL_NAMES) {
                if (_hasGemSkillOnStage(skillName, currentStrId)) n++;
            }
            return n;
        }

        /** Returns true if any reachable in-logic stage hosts the named element. */
        private function _elementInLogic(elemName:String):Boolean {
            if (elemName == "Drop Holder"
                    && !AV.sessionData.hasItem(700 + SessionData.SKILL_NAMES.indexOf("Bolt")))
            {
                // Drop Holders only open to Bolt shots — gate matches apworld
                // _eval_element_reachable for "Drop Holder".
                return false;
            }
            if (_elementStages == null)
            {
                return true;
            }
            var stages:Array = _elementStages[elemName] as Array;
            if (stages == null || stages.length == 0)
            {
                // No mapping or empty mapping = always available (Tower / Wall etc.).
                return true;
            }
            for each (var stId:String in stages)
            {
                if (AV.sessionData.fieldsInLogic[stId] == true)
                {
                    return true;
                }
            }
            return false;
        }

    }
}

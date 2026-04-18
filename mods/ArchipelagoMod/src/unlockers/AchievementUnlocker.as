package unlockers {
    import Bezel.Logger;
    import net.ConnectionManager;
    import tracker.CollectedState;
    import tracker.LogicEvaluator;
    import tracker.LogicHelper;
    import com.giab.games.gcfw.GV;
    import data.AV;
    import data.EmbeddedData;
    import patch.ProgressionBlocker;

    /**
     * Handles achievement detection, reporting, and skill-point rewards.
     *
     * Owns all achievement-related state:
     *   _achievementData      — name → { apId, reward, required_effort, requirements, modes }
     *   _elementStages        — element name → Array of stage strIds (for element requirements)
     *   _reportedAchievements — which achievements have been sent to AP this session
     *
     * Call order from ArchipelagoMod:
     *   1. loadData()                     — after bind(), loads achievement_logic.json
     *   2. configure(evaluator, helper)   — after logicEvaluator / logicHelper exist
     *   3. detectAndReport()              — every 30 frames while connected
     *   4. resetReportedAchievements()    — when entering MAINMENU or LOADGAME
     */
    public class AchievementUnlocker {

        private var _logger:Logger;
        private var _modName:String;
        private var _connectionManager:ConnectionManager;
        private var _collectedState:CollectedState;
        private var _logicEvaluator:LogicEvaluator;
        private var _logicHelper:LogicHelper;

        // Achievement data loaded from achievement_logic.json
        private var _achievementData:Object = {};
        private var _elementStages:Object = {};

        // Achievements already sent to AP this session (reset on screen change)
        private var _reportedAchievements:Object = {};

        // Queued icons for the level-end screen (cleared by LevelEndScreenBuilder)
        private var _pendingLevelAchievements:Array = [];

        // Counter for throttled guard logging (incremented on each detectAndReport call)
        private var _detectCallCount:int = 0;

        // -----------------------------------------------------------------------

        public function get pendingLevelAchievements():Array { return _pendingLevelAchievements; }
        public function clearPendingLevelAchievements():void { _pendingLevelAchievements = []; }

        public function AchievementUnlocker(
            logger:Logger,
            modName:String,
            connectionManager:ConnectionManager,
            collectedState:CollectedState
        ):void {
            _logger = logger;
            _modName = modName;
            _connectionManager = connectionManager;
            _collectedState = collectedState;
        }

        /**
         * Wire in logic subsystems that become available after construction.
         * Call from ArchipelagoMod once logicEvaluator and logicHelper are initialised.
         */
        public function configure(logicEvaluator:LogicEvaluator, logicHelper:LogicHelper):void {
            _logicEvaluator = logicEvaluator;
            _logicHelper    = logicHelper;
        }

        // -----------------------------------------------------------------------
        // Data loading

        /**
         * Load achievement map from embedded achievement_logic.json.
         * Populates _achievementData and _elementStages.
         * Call once after bind().
         */
        public function loadData():void {
            try {
                if (!_achievementData) {
                    _achievementData = {};
                }

                var jsonString:String = EmbeddedData.getAchievementLogicJSON();
                if (!jsonString || jsonString.length == 0) {
                    _logger.log(_modName, "AchievementUnlocker.loadData: achievement_logic.json is empty");
                    return;
                }

                var jsonData:Object = JSON.parse(jsonString);
                if (jsonData) {
                    if (jsonData.achievements) {
                        _achievementData = jsonData.achievements;
                        _elementStages   = jsonData.element_stages || {};
                        var elemCount:int = 0;
                        for (var e:String in _elementStages) elemCount++;
                        _logger.log(_modName, "AchievementUnlocker.loadData: loaded element_stages for " + elemCount + " elements");
                    } else {
                        // Flat format (legacy)
                        _achievementData = jsonData;
                        _elementStages   = {};
                    }
                    var count:int = 0;
                    for (var k:String in _achievementData) count++;
                    _logger.log(_modName, "AchievementUnlocker.loadData: loaded " + count + " achievements");
                } else {
                    _logger.log(_modName, "AchievementUnlocker.loadData: JSON parsed but returned null");
                }
            } catch (e:Error) {
                _logger.log(_modName, "AchievementUnlocker.loadData error: " + e.message + " (continuing with empty map)");
                _achievementData = {};
            }
        }

        // -----------------------------------------------------------------------
        // Session state

        /** Clear reported-achievements set. Call when entering MAINMENU or LOADGAME. */
        public function resetReportedAchievements():void {
            _reportedAchievements = {};
        }

        // -----------------------------------------------------------------------
        // Detection

        /**
         * Scan GV.achiCollection for newly earned achievements and send AP location
         * checks for any that have not yet been reported this session.
         * Call every ~30 frames while connected and not in standalone mode.
         */
        public function detectAndReport():void {
            _detectCallCount++;

            if (!GV.achiCollection || !_connectionManager.isConnected || !_achievementData) {
                if (_detectCallCount % 20 == 0) {
                    _logger.log(_modName, "detectAndReport: guard blocked"
                        + "  achiCollection=" + (GV.achiCollection != null)
                        + "  connected=" + _connectionManager.isConnected
                        + "  data=" + (_achievementData != null));
                }
                return;
            }

            try {
                var achisByOrder:Array = GV.achiCollection.achisByOrder;
                if (!achisByOrder) {
                    _logger.log(_modName, "detectAndReport: GV.achiCollection.achisByOrder not found");
                    return;
                }

                for (var i:int = 0; i < achisByOrder.length; i++) {
                    var ach:* = achisByOrder[i];
                    if (!ach) continue;

                    // Send as soon as the game marks the achievement earned (status 2+).
                    // Status 2 = condition met in a live battle; status 3 = permanently saved.
                    // We intentionally send at status 2 so the check goes out immediately
                    // without requiring a win.
                    var status:int = int(ach.status);
                    if (status < 2) continue;

                    var achTitle:String = String(ach.title);
                    if (!achTitle) continue;
                    if (_reportedAchievements[achTitle]) continue;

                    var achData:Object = _achievementData[achTitle];
                    if (!achData) {
                        _logger.log(_modName, "  Achievement '" + achTitle + "' not found in achievement map");
                        continue;
                    }

                    var apId:int = int(achData.apId);
                    if (apId < 2000 || apId > 2636) {
                        _logger.log(_modName, "  Achievement '" + achTitle + "' has invalid apId=" + apId + " (expected 2000-2636), skipping");
                        continue;
                    }

                    _reportedAchievements[achTitle] = true;
                    _logger.log(_modName, "Sending achievement: " + achTitle + "  apId=" + apId);
                    unlockAchievement(achTitle, apId);
                }
            } catch (err:Error) {
                _logger.log(_modName, "detectAndReport error: " + err.message);
            }
        }

        // -----------------------------------------------------------------------
        // Unlock / reward

        /**
         * Queue an achievement unlock (when player collects it in-game).
         * Marks it collected in CollectedState, sends the AP location check,
         * awards skill points, and queues a level-end icon.
         */
        public function unlockAchievement(achievementName:String, apId:int):void {
            if (!achievementName || apId < 2000 || apId > 2636) return;

            _collectedState.onAchievementCollected(apId);
            if (_connectionManager.isConnected) {
                _connectionManager.sendLocationChecks([apId]);
            }
            _awardSkillPointsForAchievement(achievementName);
            _pendingLevelAchievements.push({ apId: apId, achievementName: achievementName });
            _logger.log(_modName, "Sent achievement check: " + achievementName + "  apId=" + apId);
        }

        /**
         * Receive an achievement reward from another player.
         * Awards skill points only — does not mark collected or send a check.
         */
        public function receiveAchievementReward(achievementName:String, apId:int):void {
            if (!achievementName || apId < 2000 || apId > 2636) return;
            _awardSkillPointsForAchievement(achievementName);
            _logger.log(_modName, "Received achievement reward: " + achievementName + " (AP ID " + apId + ")");
        }

        // -----------------------------------------------------------------------
        // Lookups (used by ArchipelagoMod / AchievementPanelPatcher)

        /**
         * Reverse-lookup: find achievement name by AP ID.
         * Returns null if not found.
         */
        public function findAchievementNameByApId(apId:int):String {
            for (var name:String in _achievementData) {
                var entry:Object = _achievementData[name];
                if (entry && entry.apId == apId) return name;
            }
            return null;
        }

        /**
         * Build a set of AP location IDs for achievements that are currently in-logic.
         * Used by AchievementPanelPatcher.updateLogicFlags().
         */
        public function getInLogicAchApIds():Object {
            var result:Object = {};
            var names:Array = _computeInLogicAchievements();
            for (var i:int = 0; i < names.length; i++) {
                var achData:Object = _achievementData[names[i]];
                if (achData && achData.apId) {
                    result[int(achData.apId)] = true;
                }
            }
            return result;
        }

        // -----------------------------------------------------------------------
        // In-logic computation

        /**
         * Return a sorted array of achievement names that are still uncollected
         * and whose requirements are currently met.
         */
        private function _computeInLogicAchievements():Array {
            var result:Array = [];
            if (!_connectionManager.isConnected || !_collectedState || !_achievementData) {
                return result;
            }
            var missing:Object = AV.saveData.missingLocations;
            var requiredEffort:int = AV.serverData.serverOptions.achievementRequiredEffort;

            var effortHierarchy:Array = ["Trivial", "Minor", "Major", "Extreme"];
            var maxEffortStr:String = requiredEffort > 0 && requiredEffort <= 4
                ? effortHierarchy[requiredEffort - 1]
                : "Trivial";

            var achNames:Array = [];
            for (var name:String in _achievementData) {
                achNames.push(name);
            }
            achNames.sort(Array.CASEINSENSITIVE);

            for (var i:int = 0; i < achNames.length; i++) {
                var achName:String = achNames[i];
                var achData:Object = _achievementData[achName];
                if (!achData || !achData.apId) continue;

                var apId:int = int(achData.apId);

                var modes:Array = achData.modes as Array;
                if (modes != null && modes.indexOf("journey") < 0) continue;

                var achEffort:String = achData.required_effort || "Trivial";
                if (effortHierarchy.indexOf(achEffort) > effortHierarchy.indexOf(maxEffortStr)) continue;

                if (missing[apId] == true) {
                    if (_checkAchievementAccessible(achName, achData)) {
                        result.push(achName);
                    }
                }
            }

            return result;
        }

        /**
         * Check whether all AP-gated requirements for an achievement are currently met.
         * Returns true if every requirement is satisfied (or there are none).
         */
        private function _checkAchievementAccessible(achName:String, achData:Object):Boolean {
            if (!achData || !achData.requirements) return false;

            var requirements:Array = achData.requirements as Array;
            if (!requirements || requirements.length == 0) return true;

            var isDebug:Boolean = (achName == "Shattered Waves");
            if (isDebug) {
                _logger.log(_modName, "=== CHECKING ACHIEVEMENT: " + achName + " ===");
                _logger.log(_modName, "  Total requirements: " + requirements.length);
            }

            var TRAIT_NAMES:Array = TraitUnlocker.BATTLE_TRAIT_NAMES;

            for (var i:int = 0; i < requirements.length; i++) {
                var req:String    = _trimString(String(requirements[i]));
                var reqLower:String = req.toLowerCase();

                // --- Skill requirement: "X skill" (supports pipe-separated OR) ---
                if (reqLower.indexOf(" skill") >= 0) {
                    if (isDebug) _logger.log(_modName, "  Checking requirement: " + req);
                    if (req.indexOf("|") >= 0) {
                        var skillOptions:Array = req.split("|");
                        var anySkillFound:Boolean = false;
                        for each (var skillOpt:String in skillOptions) {
                            skillOpt = _trimString(skillOpt);
                            var optLower:String = skillOpt.toLowerCase();
                            if (optLower.indexOf(" skill") >= 0) {
                                var optSkillName:String = _trimString(skillOpt.substring(0, optLower.indexOf(" skill")));
                                var optSkillIdx:int = CollectedState.SKILL_NAMES.indexOf(optSkillName);
                                if (isDebug) _logger.log(_modName, "    Option: '" + optSkillName + "' (idx=" + optSkillIdx + ", hasItem=" + (_collectedState && _collectedState.hasItem(700 + optSkillIdx)) + ")");
                                if (optSkillIdx >= 0 && _collectedState && _collectedState.hasItem(700 + optSkillIdx)) {
                                    anySkillFound = true;
                                    break;
                                }
                            }
                        }
                        if (!anySkillFound) {
                            if (isDebug) _logger.log(_modName, "    -> FAILED: no skills matched");
                            return false;
                        }
                        if (isDebug) _logger.log(_modName, "    -> PASSED: at least one skill found");
                    } else {
                        var skillEndIdx:int = reqLower.indexOf(" skill");
                        var skillName:String = _trimString(req.substring(0, skillEndIdx));
                        var skillIdx:int = CollectedState.SKILL_NAMES.indexOf(skillName);
                        if (isDebug) _logger.log(_modName, "    Skill: '" + skillName + "' (idx=" + skillIdx + ", hasItem=" + (_collectedState && _collectedState.hasItem(700 + skillIdx)) + ")");
                        if (skillIdx < 0) {
                            _logger.log(_modName, "Warning: unknown skill in achievement '" + achName + "': " + skillName);
                            if (isDebug) _logger.log(_modName, "    -> FAILED: unknown skill");
                            return false;
                        }
                        if (!_collectedState || !_collectedState.hasItem(700 + skillIdx)) {
                            if (isDebug) _logger.log(_modName, "    -> FAILED: skill not collected");
                            return false;
                        }
                        if (isDebug) _logger.log(_modName, "    -> PASSED: skill collected");
                    }
                }

                // --- Element requirement: "X element" ---
                else if (reqLower.indexOf(" element") >= 0) {
                    if (isDebug) _logger.log(_modName, "  Checking requirement: " + req);
                    var elemEndIdx:int = reqLower.indexOf(" element");
                    var elemName:String = _trimString(req.substring(0, elemEndIdx));
                    if (_elementStages != null) {
                        var stages:Array = _elementStages[elemName] as Array;
                        if (isDebug) _logger.log(_modName, "    Element: '" + elemName + "' (stages=" + (stages ? stages.length : 0) + ")");
                        if (stages != null && stages.length > 0) {
                            var elemAccessible:Boolean = false;
                            for (var s:int = 0; s < stages.length; s++) {
                                var stageInLogic:Boolean = _logicEvaluator != null && _logicEvaluator.isStageInLogic(stages[s]);
                                if (isDebug) _logger.log(_modName, "      Stage " + stages[s] + ": " + (stageInLogic ? "IN" : "OUT"));
                                if (stageInLogic) { elemAccessible = true; break; }
                            }
                            if (!elemAccessible) {
                                if (isDebug) _logger.log(_modName, "    -> FAILED: no stages in logic");
                                return false;
                            }
                            if (isDebug) _logger.log(_modName, "    -> PASSED: at least one stage in logic");
                        } else {
                            if (isDebug) _logger.log(_modName, "    -> No stage mapping found, assuming accessible");
                        }
                    } else {
                        if (isDebug) _logger.log(_modName, "    -> _elementStages is null");
                    }
                }

                // --- Trait requirement: "X trait" ---
                else if (reqLower.indexOf(" trait") >= 0) {
                    var traitEndIdx:int = reqLower.indexOf(" trait");
                    var traitName:String = _trimString(req.substring(0, traitEndIdx));
                    if (traitName.toLowerCase() == "any battle") {
                        var hasTrait:Boolean = false;
                        for (var t:int = 0; t < 15; t++) {
                            if (_collectedState && _collectedState.hasItem(800 + t)) { hasTrait = true; break; }
                        }
                        if (!hasTrait) return false;
                    } else {
                        var traitId:int = TRAIT_NAMES.indexOf(traitName);
                        if (traitId >= 0 && _collectedState && !_collectedState.hasItem(800 + traitId)) {
                            return false;
                        }
                    }
                }

                // --- Field requirement: "Field A4" or "Field N1, U1 or R5" (OR) ---
                else if (reqLower.indexOf("field ") == 0) {
                    var fieldPart:String = _trimString(req.substring(6));
                    var stageTokens:Array = fieldPart.split(/,\s*|\s+or\s+/i);
                    var fieldAccessible:Boolean = false;
                    for (var f:int = 0; f < stageTokens.length; f++) {
                        var stageId:String = _trimString(String(stageTokens[f]));
                        if (stageId.length > 0 && _logicEvaluator != null
                                && _logicEvaluator.isStageInLogic(stageId)) {
                            fieldAccessible = true;
                            break;
                        }
                    }
                    if (!fieldAccessible) return false;
                }

                // --- Game mode requirements (mod is journey-only) ---
                else if (reqLower == "trial" || reqLower == "endurance" || reqLower == "endurance and trial") {
                    return false;
                }

                // --- Skill group counters ---
                else if (reqLower.indexOf("strikespells") == 0) {
                    var strikeNeeded:int = int(_trimString(reqLower.substring(reqLower.indexOf(":") + 1)));
                    if (!_logicHelper.hasStrikeSpells(strikeNeeded)) return false;
                }
                else if (reqLower.indexOf("enhancementspells") == 0) {
                    var enhanceNeeded:int = int(_trimString(reqLower.substring(reqLower.indexOf(":") + 1)));
                    if (!_logicHelper.hasEnhancementSpells(enhanceNeeded)) return false;
                }
                else if (reqLower.indexOf("gemskills") == 0) {
                    var gemNeeded:int = int(_trimString(reqLower.substring(reqLower.indexOf(":") + 1)));
                    if (!_logicHelper.hasGemSkills(gemNeeded)) return false;
                }

                // --- Wave requirement: "minWave: N" ---
                else if (reqLower.indexOf("minwave") == 0) {
                    var waveNeeded:int = int(_trimString(reqLower.substring(reqLower.indexOf(":") + 1)));
                    if (!_logicHelper.HasFieldWithMinWaveCount(waveNeeded)) return false;
                }

                // --- Field token requirement: "fieldToken: N" ---
                else if (reqLower.indexOf("fieldtoken") == 0) {
                    var ftNeeded:int = int(_trimString(reqLower.substring(reqLower.indexOf(":") + 1)));
                    var ftCount:int = 0;
                    for (var ftId:int = 1; ftId <= 199; ftId++) {
                        if (_collectedState && _collectedState.hasItem(ftId)) ftCount++;
                    }
                    if (ftCount < ftNeeded) return false;
                }

                // Stat and other in-game requirements are not AP-gated; skip them.
            }

            if (isDebug) _logger.log(_modName, "=== RESULT: " + achName + " IS IN LOGIC ===");
            return true;
        }

        // -----------------------------------------------------------------------
        // Private helpers

        private function _awardSkillPointsForAchievement(achievementName:String):void {
            if (!_achievementData) return;
            var achInfo:Object = _achievementData[achievementName];
            if (achInfo && achInfo.reward) {
                var reward:String = String(achInfo.reward);
                if (reward.indexOf("skillPoints:") == 0) {
                    var points:int = int(reward.substring(12));
                    _awardSkillPoints(points);
                }
            }
        }

        private function _awardSkillPoints(points:int):void {
            if (points <= 0 || GV.ppd == null) return;
            try {
                var current:int = int(GV.ppd.skillPtsFromLoot.g());
                GV.ppd.skillPtsFromLoot.s(current + points);
                _logger.log(_modName, "Awarded " + points + " skill points (total: " + (current + points) + ")");
            } catch (err:Error) {
                _logger.log(_modName, "Error awarding skill points: " + err.message);
            }
        }

        /** Trim leading and trailing whitespace (AS3 has no String.trim()). */
        private function _trimString(str:String):String {
            return str.replace(/^\s+|\s+$/g, "");
        }
    }
}

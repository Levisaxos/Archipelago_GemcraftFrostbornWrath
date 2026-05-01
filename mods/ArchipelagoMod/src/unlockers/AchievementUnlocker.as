package unlockers {
    import Bezel.Logger;
    import net.ConnectionManager;
    import com.giab.games.gcfw.GV;
    import data.AV;
    import data.EmbeddedData;
    import patch.ProgressionBlocker;
    import ui.ReceivedToast;

    /**
     * Handles achievement detection, reporting, and skill-point rewards.
     *
     * Owns:
     *   _achievementData      — name → { apId, reward, required_effort, requirements, modes }
     *   _reportedAchievements — which achievements have been sent to AP this session
     *
     * In-logic computation is handled by AchievementLogicEvaluator (separate class).
     *
     * Call order from ArchipelagoMod:
     *   1. loadData()                 — after bind(), loads achievement_logic.json
     *   2. detectAndReport()          — every 30 frames while connected
     *   3. resetReportedAchievements() — when entering MAINMENU or LOADGAME
     */
    public class AchievementUnlocker {

        private var _logger:Logger;
        private var _modName:String;
        private var _connectionManager:ConnectionManager;

        private var _receivedToast:ReceivedToast;

        private var _achievementData:Object = {}; // name  -> entry (for skill-point lookups)
        private var _gameIdToData:Object   = {}; // game_id (int) -> entry (for detection)

        // Achievements already sent to AP this session, keyed by game_id (reset on screen change)
        private var _reportedAchievements:Object = {};

        // Optional reference to AchievementLogicEvaluator. Set after configure
        // by ArchipelagoMod. Used to toast on unlocks that weren't in logic
        // — useful for diagnosing "this should not have been reachable yet".
        private var _achievementLogicEvaluator:Object = null;
        public function setAchievementLogicEvaluator(evaluator:Object):void {
            _achievementLogicEvaluator = evaluator;
        }

        private var _detectCallCount:int = 0;

        /**
         * Called after any achievement location check is sent to AP.
         * ArchipelagoMod wires this to mark the logic evaluator dirty and
         * refresh the achievement panel so collected achievements immediately
         * leave the "In Logic" group without waiting for the next item grant.
         * Signature: ():void
         */
        public var onChecked:Function = null;

        // -----------------------------------------------------------------------

        public function AchievementUnlocker(logger:Logger,
                                            modName:String,
                                            connectionManager:ConnectionManager,
                                            receivedToast:ReceivedToast = null):void {
            _logger            = logger;
            _modName           = modName;
            _connectionManager = connectionManager;
            _receivedToast     = receivedToast;
        }

        // -----------------------------------------------------------------------
        // Data loading

        /**
         * Load achievement map from embedded achievement_logic.json.
         * Call once after bind().
         */
        public function loadData():void {
            try {
                var jsonString:String = EmbeddedData.getAchievementLogicJSON();
                if (!jsonString || jsonString.length == 0) {
                    _logger.log(_modName, "AchievementUnlocker.loadData: JSON empty");
                    return;
                }
                var jsonData:Object = JSON.parse(jsonString);
                if (jsonData) {
                    _achievementData = jsonData.achievements || jsonData;
                    _gameIdToData    = {};
                    var count:int = 0;
                    for (var k:String in _achievementData) {
                        var entry:Object = _achievementData[k];
                        if (entry && entry.game_id != null) {
                            _gameIdToData[int(entry.game_id)] = entry;
                        }
                        count++;
                    }
                    _logger.log(_modName, "AchievementUnlocker.loadData: loaded " + count + " achievements");
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
        // Exclusion predicate (mirrors apworld _should_skip_achievement)

        /**
         * Returns the human-readable reason this achievement was omitted from
         * AP gen, or null if it IS in AP. Reasons:
         *   - "untrackable"            — flagged untrackable in rulesdata
         *   - "excluded by effort"     — required_effort above slot threshold
         *   - "Trial-mode only"        — "Trial" in requirements (no AP hook)
         *   - "Endurance disabled"     — "Endurance" requirement, mode off
         */
        public function getSkipReason(achData:Object):String {
            if (!achData)
                return "no data";

            var serverOptions:Object = (AV.serverData != null) ? AV.serverData.serverOptions : null;
            if (!serverOptions)
                return null;  // No slot data yet — be permissive.

            var threshold:int = int(serverOptions.achievementRequiredEffort);
            if (threshold > 0) {
                var rank:int = effortRank(String(achData.required_effort));
                if (rank > threshold)
                    return "excluded by effort";
            }

            if (achData.untrackable === true)
                return "untrackable";

            var reqs:Array = (achData.requirements is Array) ? (achData.requirements as Array) : null;
            if (reqs != null) {
                if (requirementsContain(reqs, "Trial"))
                    return "Trial-mode only";
                if (Boolean(serverOptions.disable_endurance) && requirementsContain(reqs, "Endurance"))
                    return "Endurance disabled";
            }
            return null;
        }

        /** Back-compat boolean wrapper around getSkipReason. */
        private function shouldSkipAchievement(achData:Object):Boolean {
            return getSkipReason(achData) != null;
        }

        private function effortRank(effort:String):int {
            if (effort == "Trivial") return 1;
            if (effort == "Minor")   return 2;
            if (effort == "Major")   return 3;
            if (effort == "Extreme") return 4;
            return 1;  // unknown -> treat as Trivial (always included)
        }

        private function requirementsContain(reqs:Array, target:String):Boolean {
            for (var i:int = 0; i < reqs.length; i++) {
                var r:* = reqs[i];
                if (r is Array) {
                    if (requirementsContain(r as Array, target))
                        return true;
                } else if (String(r) == target) {
                    return true;
                }
            }
            return false;
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
                    var status:int = int(ach.status);
                    if (status < 2) continue;

                    var gameId:int = int(ach.id);
                    if (_reportedAchievements[gameId]) continue;

                    var achData:Object = _gameIdToData[gameId];
                    if (!achData) {
                        _logger.log(_modName, "  Achievement gameId=" + gameId + " ('" + ach.title + "') not found in map");
                        continue;
                    }

                    var apId:int = int(achData.apId);
                    if (apId < 2000 || apId > 2636) {
                        _logger.log(_modName, "  Achievement gameId=" + gameId + " has invalid apId=" + apId + ", skipping");
                        continue;
                    }

                    // Achievement filtered out at AP gen time (untrackable / Trial /
                    // disabled-Endurance / above effort threshold). The AP server
                    // has no location for it — let the game's vanilla skill-point
                    // reward flow as if the mod weren't loaded for this one.
                    var skipReason:String = getSkipReason(achData);
                    if (skipReason != null) {
                        _reportedAchievements[gameId] = true;  // don't re-check every frame
                        // Toast it so the player can spot calibration mistakes
                        // ("I just got this — should it really be excluded?").
                        if (_receivedToast != null) {
                            _receivedToast.addItem(
                                ach.title + " — " + skipReason, 0xFF8844);
                        }
                        _logger.log(_modName, "Achievement excluded from AP ('" + ach.title
                            + "'): " + skipReason);
                        continue;
                    }

                    _reportedAchievements[gameId] = true;
                    _logger.log(_modName, "Sending achievement: " + ach.title + "  apId=" + apId + "  gameId=" + gameId);
                    unlockAchievement(String(ach.title), apId, gameId);

                    // Out-of-logic detection — useful for spotting requirements
                    // that are too lax / power values that are too low. If AP
                    // didn't think this was reachable yet, toast it.
                    if (_achievementLogicEvaluator != null) {
                        try {
                            var inLogic:Boolean = Boolean(
                                _achievementLogicEvaluator.isAchievementInLogic(
                                    String(ach.title), achData));
                            if (!inLogic && _receivedToast != null) {
                                _receivedToast.addItem(
                                    ach.title + " — out of logic", 0xFF8844);
                                _logger.log(_modName, "Out-of-logic unlock: " + ach.title);
                            }
                        } catch (eLogic:Error) {
                            _logger.log(_modName, "isAchievementInLogic threw for '"
                                + ach.title + "': " + eLogic.message);
                        }
                    }

                    // Vanilla SP suppression: PnlSkills.calculateAvailableSkillPoints
                    // adds pnlAchievements.calculateSkillPtBonus() — a live walk over
                    // gainedAchis[i] summing Achievement.skillPtValue — into the total.
                    // We deduct each newly-completed achievement's SP from
                    // skillPtsFromLoot here so the bonus exactly cancels in-formula.
                    // SP-bundle items still write positively to the same field, so
                    // the visible balance equals (bundles - achievement-bonus) and the
                    // panel sees (achi + bundles - achi) = bundles. Net: AP controls
                    // the SP economy via bundles, vanilla achievement SP is hidden.
                    suppressVanillaAchievementSp(ach);
                }
            } catch (err:Error) {
                _logger.log(_modName, "detectAndReport error: " + err.message);
            }
        }

        // -----------------------------------------------------------------------
        // Unlock / reward

        /**
         * Queue an achievement unlock (when player collects it in-game).
         * Marks it collected in sessionData, sends the AP location check,
         * awards skill points, and queues a level-end icon.
         *
         * @param gameId  The game's internal achievement ID (ach.id from achisByOrder).
         *                Pass -1 if unknown; the level-end screen will fall back to the generic AP icon.
         */
        public function unlockAchievement(achievementName:String, apId:int, gameId:int = -1):void {
            if (!achievementName || apId < 2000 || apId > 2636) return;

            AV.sessionData.onAchievementCollected(apId);
            if (_connectionManager.isConnected) {
                _connectionManager.sendLocationChecks([apId]);
            }
            _logger.log(_modName, "Sent achievement check: " + achievementName + "  apId=" + apId + "  gameId=" + gameId);
            if (onChecked != null) onChecked();
        }

        // -----------------------------------------------------------------------
        // Lookups

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
         * Reverse-lookup: find game-internal achievement id by AP ID.
         * Used to construct ACHIEVEMENT drop icons (vanilla McDropIconOutcome
         * looks up the achievement bitmap via GV.achiCollection.achisById[gameId]).
         * Returns -1 if not found.
         */
        public function findGameIdByApId(apId:int):int {
            for (var name:String in _achievementData) {
                var entry:Object = _achievementData[name];
                if (entry && entry.apId == apId && entry.game_id != null) {
                    return int(entry.game_id);
                }
            }
            return -1;
        }

        // -----------------------------------------------------------------------
        // Skill-point grants

        /**
         * Deduct an achievement's vanilla skill-point reward from
         * GV.ppd.skillPtsFromLoot so it exactly offsets the in-formula
         * contribution from PnlAchievements.calculateSkillPtBonus().
         * Called once per achievement per session right after AP detection.
         */
        public function suppressVanillaAchievementSp(ach:*):void {
            if (ach == null || GV.ppd == null)
                return;
            try {
                var spValue:int = int(ach.skillPtValue);
                if (spValue <= 0)
                    return;
                var current:int = int(GV.ppd.skillPtsFromLoot.g());
                GV.ppd.skillPtsFromLoot.s(current - spValue);
                _logger.log(_modName, "Suppressed vanilla achievement SP: -" + spValue
                    + " (skillPtsFromLoot now " + (current - spValue) + ")");
            } catch (err:Error) {
                _logger.log(_modName, "suppressVanillaAchievementSp error: " + err.message);
            }
        }

        /**
         * Add `points` to the player's wizard skill-point pool.
         * Used by Skillpoint Bundle items (apId 1700–1709).
         */
        public function awardSkillPoints(points:int):void {
            if (points <= 0 || GV.ppd == null) return;
            try {
                var current:int = int(GV.ppd.skillPtsFromLoot.g());
                GV.ppd.skillPtsFromLoot.s(current + points);
                _logger.log(_modName, "Awarded " + points + " skill points (total: " + (current + points) + ")");
            } catch (err:Error) {
                _logger.log(_modName, "Error awarding skill points: " + err.message);
            }
        }
    }
}

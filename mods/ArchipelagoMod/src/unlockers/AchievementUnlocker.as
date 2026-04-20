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

        // Queued icons for the level-end screen (cleared by LevelEndScreenBuilder)
        private var _pendingLevelAchievements:Array = [];

        private var _detectCallCount:int = 0;

        // -----------------------------------------------------------------------

        public function get pendingLevelAchievements():Array { return _pendingLevelAchievements; }
        public function clearPendingLevelAchievements():void { _pendingLevelAchievements = []; }

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

                    _reportedAchievements[gameId] = true;
                    _logger.log(_modName, "Sending achievement: " + ach.title + "  apId=" + apId + "  gameId=" + gameId);
                    unlockAchievement(String(ach.title), apId, gameId);
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
            _awardSkillPointsForAchievement(achievementName);
            _pendingLevelAchievements.push({ apId: apId, achievementName: achievementName, gameId: gameId });
            _logger.log(_modName, "Sent achievement check: " + achievementName + "  apId=" + apId + "  gameId=" + gameId);
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

        // -----------------------------------------------------------------------
        // Private helpers

        private function _awardSkillPointsForAchievement(achievementName:String):void {
            if (!_achievementData) return;
            var achInfo:Object = _achievementData[achievementName];
            if (achInfo && achInfo.reward) {
                var reward:String = String(achInfo.reward);
                if (reward.indexOf("skillPoints:") == 0) {
                    _awardSkillPoints(int(reward.substring(12)));
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
    }
}

package unlockers {
    import Bezel.Logger;
    import net.ConnectionManager;
    import com.giab.games.gcfw.GV;
    import data.AV;
    import data.EmbeddedData;
    import patch.ProgressionBlocker;
    import ui.ReceivedToast;
    import ui.ItemColors;

    /**
     * Handles achievement detection, reporting, and skill-point rewards.
     *
     * Owns:
     *   _achievementData      — name → { apId, required_effort, requirements, modes }
     *   _reportedAchievements — which achievements have been sent to AP this session
     *
     * In-logic computation is handled by AchievementLogicEvaluator (separate class).
     *
     * Call order from ArchipelagoMod:
     *   1. loadData()                 — after bind(), loads achievement_logic.json
     *   2. detectAndReport()          — every 30 frames while connected
     *   3. resetReportedAchievements() — when entering MAINMENU or LOADGAME
     *
     * Skill-point economy: skillPtsFromLoot is treated as a derived value,
     * reconciled from canonical sources (sessionData bundles + gainedAchis)
     * via reconcileSkillPoints(). It is never incremented/decremented
     * directly — non-idempotent writes were the cause of a bug where each
     * MAINMENU/LOADGAME round-trip re-deducted achievement SP because
     * _reportedAchievements resets but gainedAchis does not.
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

        /**
         * Called when an achievement is earned that's been excluded from AP
         * generation (effort threshold, untrackable, Trial-only, Endurance
         * disabled). ArchipelagoMod wires this to record the gameId so the
         * level-end drop screen can still render an achievement icon for it,
         * matching vanilla behaviour for excluded achievements.
         * Signature: (gameId:int, skipReason:String):void
         */
        public var onAchievementSkipped:Function = null;

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

                var newlyDetected:Boolean = false;

                // Per-slot authoritative source. GV.achiCollection.achisByOrder[i].status
                // is GLOBAL state and carries across slot loads (vanilla bug) — so a
                // standalone session that earned achievements leaves status >= 2 on those
                // entries when the next AP slot connects, causing detectAndReport to
                // spuriously fire location checks for them. GV.ppd.gainedAchis is the
                // current slot's saved set and is reset to all-false by setInitialValues
                // when the slot is created. Cross-checking against it eliminates the leak.
                var gainedAchis:Array = (GV.ppd != null) ? GV.ppd.gainedAchis : null;
                if (gainedAchis == null) return;

                for (var i:int = 0; i < achisByOrder.length; i++) {
                    var ach:* = achisByOrder[i];
                    if (!ach) continue;

                    // Send as soon as the game marks the achievement earned (status 2+).
                    var status:int = int(ach.status);
                    if (status < 2) continue;

                    var gameId:int = int(ach.id);
                    if (_reportedAchievements[gameId]) continue;

                    // Only report achievements actually committed to the current
                    // slot. gainedAchis[gameId] is set on the win-screen drop
                    // processing (IngameEnding.updatePpdWithDrops), so this delays
                    // mid-battle reporting until the battle is won — but the slot
                    // file is the only source of truth for "earned in this slot".
                    if (gameId >= gainedAchis.length || gainedAchis[gameId] !== true) continue;

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
                        // Toast the bare title so the unlock surfaces in the
                        // popup just like any other received item; the skip
                        // reason is dropped from user-facing UI but still
                        // logged for diagnostics.
                        if (_receivedToast != null) {
                            _receivedToast.addItem(ach.title, ItemColors.USEFUL);
                        }
                        _logger.log(_modName, "Achievement excluded from AP ('" + ach.title
                            + "'): " + skipReason);
                        // Notify ArchipelagoMod so it can still render a
                        // drop icon for the unlock at level end. Vanilla
                        // SP flows naturally because we don't suppress it
                        // for excluded achievements.
                        if (onAchievementSkipped != null) {
                            try { onAchievementSkipped(gameId, skipReason); }
                            catch (eSkip:Error) {
                                _logger.log(_modName, "onAchievementSkipped threw: " + eSkip.message);
                            }
                        }
                        continue;
                    }

                    _reportedAchievements[gameId] = true;
                    newlyDetected = true;
                    _logger.log(_modName, "Sending achievement: " + ach.title + "  apId=" + apId + "  gameId=" + gameId);
                    unlockAchievement(String(ach.title), apId, gameId);

                    // Out-of-logic detection — useful for spotting requirements
                    // that are too lax. If AP didn't think this was reachable
                    // yet, toast it.
                    if (_achievementLogicEvaluator != null) {
                        try {
                            var inLogic:Boolean = Boolean(
                                _achievementLogicEvaluator.isAchievementInLogic(
                                    String(ach.title), achData));
                            if (!inLogic && _receivedToast != null) {
                                _receivedToast.addItem(
                                    ach.title , 0xFF8844);
                                _logger.log(_modName, "Out-of-logic unlock: " + ach.title);
                            }
                        } catch (eLogic:Error) {
                            _logger.log(_modName, "isAchievementInLogic threw for '"
                                + ach.title + "': " + eLogic.message);
                        }
                    }

                }

                // Vanilla SP suppression: PnlSkills.calculateAvailableSkillPoints
                // adds pnlAchievements.calculateSkillPtBonus() — a live walk over
                // gainedAchis[i] summing Achievement.skillPtValue — into the total.
                // skillPtsFromLoot is set so the bonus exactly cancels in-formula
                // and only bundles affect the visible balance. Reconciled rather
                // than incrementally adjusted so MAINMENU/LOADGAME round-trips
                // (which reset _reportedAchievements) cannot re-deduct.
                if (newlyDetected) {
                    reconcileSkillPoints();
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
        // Debug menu support

        /**
         * Whole trackable achievement pool for the debug "Achievements" tab:
         * every achievement that has a real AP location (getSkipReason == null —
         * i.e. not untrackable, not above the effort threshold, not Trial-only,
         * not Endurance-disabled) and is still missing on the server. Returns an
         * Array of { apId:int, name:String } sorted by name.
         *
         * Reachability is NOT considered — this is the full pool, not the
         * in-logic subset (AchievementLogicEvaluator.getInLogicAchApIds()).
         */
        public function getTrackableMissingAchievements():Array {
            var result:Array = [];
            if (AV.saveData == null) return result;
            var missing:Object = AV.saveData.missingLocations;
            if (missing == null) return result;

            for (var name:String in _achievementData) {
                var achData:Object = _achievementData[name];
                if (!achData || achData.apId == null) continue;
                var apId:int = int(achData.apId);
                if (apId < 2000 || apId > 2636) continue;
                if (missing[apId] != true) continue;
                if (getSkipReason(achData) != null) continue;
                result.push({ apId: apId, name: name });
            }
            result.sortOn("name", Array.CASEINSENSITIVE);
            return result;
        }

        /**
         * Every non-excluded achievement the player has NOT yet earned in-game,
         * regardless of whether the AP location check has been sent. Used by the
         * debug menu's "not yet earned" achievements view. Filters:
         *   - has a real AP location (getSkipReason == null)
         *   - GV.ppd.gainedAchis[game_id] !== true (not earned in this slot)
         * Returns an Array of { apId:int, name:String } sorted by name.
         *
         * Differs from getTrackableMissingAchievements, which filters on the
         * AP server's missing-locations set (i.e. hides already-checked ones);
         * this filters on the game's own earned state instead.
         */
        public function getUnearnedTrackableAchievements():Array {
            var result:Array = [];
            var gainedAchis:Array = (GV.ppd != null) ? GV.ppd.gainedAchis : null;

            for (var name:String in _achievementData) {
                var achData:Object = _achievementData[name];
                if (!achData || achData.apId == null) continue;
                var apId:int = int(achData.apId);
                if (apId < 2000 || apId > 2636) continue;
                if (getSkipReason(achData) != null) continue;
                if (achData.game_id != null && gainedAchis != null) {
                    var gameId:int = int(achData.game_id);
                    if (gameId >= 0 && gameId < gainedAchis.length && gainedAchis[gameId] === true)
                        continue;
                }
                result.push({ apId: apId, name: name });
            }
            result.sortOn("name", Array.CASEINSENSITIVE);
            return result;
        }

        /**
         * Debug-menu entry point: send the AP location check for an achievement
         * WITHOUT marking it earned in-game. Routes through unlockAchievement,
         * which records the check AP-side (sessionData) and releases the item
         * behind the location to its owner (sendLocationChecks) — but never
         * writes gainedAchis or fires the in-game / Steam achievement, so the
         * player does not actually unlock it.
         *
         * Idempotent per session: skips if the achievement is already collected
         * (live receipt or a prior debug send). Returns true if a check was
         * sent, false if skipped (invalid apId or already collected).
         */
        public function debugSendAchievementCheck(apId:int):Boolean {
            if (apId < 2000 || apId > 2636) return false;
            if (AV.sessionData != null && AV.sessionData.isAchievementCollected(apId)) {
                _logger.log(_modName, "debugSendAchievementCheck: apId=" + apId + " already collected — skipping");
                return false;
            }
            if (!_connectionManager.isConnected) {
                _logger.log(_modName, "debugSendAchievementCheck: not connected — check will not reach the server");
            }
            var name:String = findAchievementNameByApId(apId);
            if (name == null) name = "Achievement " + apId;
            unlockAchievement(name, apId, -1);
            return true;
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
        // Restore from AP server checked_locations

        /**
         * Mark every achievement that AP says is already checked as locally
         * gained, so a fresh slot on a server with prior progress shows
         * those achievements as completed in-game rather than out-of-logic.
         *
         * Source of truth: AV.saveData.checkedLocations (populated by
         * ApReceiver.handleConnected from the Connected packet).
         *
         * For each AP-tracked achievement gameId already on the checked
         * list, sets:
         *   - GV.ppd.gainedAchis[gameId] = true   (slot save commitment)
         *   - achisByOrder[i].status = 3          (WAS_ALREADY_UNLOCKED —
         *                                          matches vanilla
         *                                          IngameInitializer2.resetAchis
         *                                          for previously-completed
         *                                          achievements; status=2
         *                                          would mean "just earned
         *                                          this run, win to keep")
         *   - _reportedAchievements[gameId] = true (no re-send to server)
         *
         * The status write is global (vanilla bug noted in detectAndReport)
         * but harmless: detectAndReport's gainedAchis cross-check stops it
         * from being interpreted as a brand-new check next session.
         *
         * Second pass — EVERY achievement already in gainedAchis (AP-tracked
         * and excluded alike): seed _reportedAchievements so detectAndReport
         * doesn't re-fire the location check + out-of-logic toast + drop-icon
         * for them on every reconnect. The first pass only seeds the
         * achievements it RESTORES (server-checked but not yet locally
         * gained); it bails out on entries already in gainedAchis before the
         * seed, which is what left previously-earned AP-tracked achievements
         * re-firing each session. Server-missing checks are not lost — the
         * reconcileLocationChecks pass that runs right after re-sends any
         * locally-earned achievement the server hasn't recorded. We also
         * stamp ach.status = 3 to match the AP-tracked path: vanilla's
         * IngameInitializer2.resetAchis only runs when entering a stage,
         * so on the selector screen ach.status would otherwise stay at
         * its initial 0 (or whatever previous slot left it), causing
         * _applySortedOrder to bucket the achievement into "rest" (g3)
         * and _applyLogicDots to paint a red "out of logic" dot even
         * though the achievement is collected. SP is left alone —
         * vanilla SP for excluded achis flows naturally from gainedAchis
         * via PnlAchievements.calculateSkillPtBonus.
         *
         * Returns the total number of achievements processed (AP-tracked
         * + excluded-seeded). Caller uses this to decide whether to
         * refresh the achievement panel.
         */
        public function restoreCheckedAchievements():int {
            if (GV.ppd == null || GV.achiCollection == null) return 0;
            var achisByOrder:Array = GV.achiCollection.achisByOrder;
            var gainedAchis:Array = GV.ppd.gainedAchis;
            if (achisByOrder == null || gainedAchis == null) return 0;

            var checked:Object = (AV.saveData != null) ? AV.saveData.checkedLocations : null;
            if (checked == null) return 0;

            var restored:int = 0;
            for (var i:int = 0; i < achisByOrder.length; i++) {
                var ach:* = achisByOrder[i];
                if (!ach) continue;
                var gameId:int = int(ach.id);
                if (gameId < 0 || gameId >= gainedAchis.length) continue;
                if (gainedAchis[gameId] === true) continue;

                var achData:Object = _gameIdToData[gameId];
                if (!achData) continue;
                var apId:int = int(achData.apId);
                if (apId < 2000 || apId > 2636) continue;
                if (checked[apId] !== true) continue;

                gainedAchis[gameId] = true;
                try { ach.status = 3; } catch (eStatus:Error) {}
                _reportedAchievements[gameId] = true;
                restored++;
            }

            // Second pass — silence EVERY previously-gained achievement
            // (AP-tracked and excluded alike) and stamp it
            // WAS_ALREADY_UNLOCKED so the panel sort + dot logic treat it as
            // earned. gainedAchis persists across sessions, but
            // _reportedAchievements is wiped on every MAINMENU / LOADGAME
            // entry. The first pass only seeds _reportedAchievements for
            // achievements it RESTORES (server-checked but not yet locally
            // gained) — it bails out early on entries already in gainedAchis,
            // before the seed. Without this pass, detectAndReport would
            // re-fire (re-send the location check + re-run the out-of-logic
            // toast) for every achievement already committed to the save on
            // every reconnect. Server-missing checks are NOT lost: the
            // reconcileLocationChecks pass that runs immediately after this
            // re-sends any locally-earned achievement the server doesn't yet
            // have (it diffs against the missing set). detectAndReport's job
            // is purely to catch achievements earned DURING this session, so
            // newly-earned achievements (not yet in gainedAchis) are left
            // unseeded and still surface their toast + drop icon.
            var seeded:int = 0;
            for (i = 0; i < achisByOrder.length; i++) {
                var achEx:* = achisByOrder[i];
                if (!achEx) continue;
                var gidEx:int = int(achEx.id);
                if (gidEx < 0 || gidEx >= gainedAchis.length) continue;
                if (gainedAchis[gidEx] !== true) continue;
                if (_reportedAchievements[gidEx]) continue;  // already covered by the restore pass
                if (_gameIdToData[gidEx] == null) continue;
                try { achEx.status = 3; } catch (eExStatus:Error) {}
                _reportedAchievements[gidEx] = true;
                seeded++;
            }
            if (seeded > 0) {
                _logger.log(_modName, "restoreCheckedAchievements: silenced " + seeded
                    + " previously-gained achievements (no re-send on reconnect)");
            }

            if (restored > 0) {
                _logger.log(_modName, "restoreCheckedAchievements: marked " + restored
                    + " AP-checked achievements as locally gained");

                // Refresh the selector panel's visual flags. The "locked"
                // overlay (mc.mcLocked2 / iconLocked) is driven by
                // filterFlags[1], populated by setAchiLockStatusesOnLoad
                // from gainedAchis at load time — well before our restore
                // runs. Without re-calling it the icons stay greyed out
                // even though gainedAchis is now true.
                // Only the AP-tracked pass mutates gainedAchis; the excluded
                // pass leaves it untouched (it was already true from save),
                // so the lock-status refresh is gated on `restored`.
                try {
                    if (GV.selectorCore != null && GV.selectorCore.pnlAchievements != null) {
                        GV.selectorCore.pnlAchievements.setAchiLockStatusesOnLoad();
                    }
                } catch (eFlags:Error) {
                    _logger.log(_modName, "restoreCheckedAchievements: setAchiLockStatusesOnLoad threw: " + eFlags.message);
                }
            }
            return restored + seeded;
        }

        /**
         * Return apIds of every AP-tracked achievement that gainedAchis says
         * is locally earned. Excluded achievements (effort / Trial /
         * Endurance-disabled / untrackable) are filtered out — they have no
         * AP location to check. Used by ConnectionManager.reconcileLocationChecks
         * to re-send checks the server may have missed (network drop,
         * detection skipped a tick, earned-while-disconnected).
         */
        public function scanLocallyEarnedAchievementApIds():Array {
            var result:Array = [];
            if (GV.ppd == null)
                return result;
            var gainedAchis:Array = GV.ppd.gainedAchis;
            if (gainedAchis == null)
                return result;

            for (var gameId:int = 0; gameId < gainedAchis.length; gameId++) {
                if (gainedAchis[gameId] !== true)
                    continue;
                var achData:Object = _gameIdToData[gameId];
                if (!achData)
                    continue;
                var apId:int = int(achData.apId);
                if (apId < 2000 || apId > 2636)
                    continue;
                if (getSkipReason(achData) != null)
                    continue;
                result.push(apId);
            }
            return result;
        }

        // -----------------------------------------------------------------------
        // Skill-point reconciliation

        /**
         * Recompute GV.ppd.skillPtsFromLoot from canonical state. Idempotent.
         *
         *   skillPtsFromLoot = sum(SP for received bundles 1700-1703)
         *                    - sum(skillPtValue for AP-tracked gainedAchis)
         *
         * The achievement term cancels PnlAchievements.calculateSkillPtBonus()
         * in the panel formula so the visible economy is bundles only.
         * Excluded achievements (effort/Trial/etc.) keep their vanilla SP —
         * they're skipped here, matching the detection branch above.
         *
         * Call after sync, after a bundle is granted, and after newly-detected
         * achievements. Safe to call repeatedly.
         */
        public function reconcileSkillPoints():void {
            if (GV.ppd == null) return;
            var breakdown:Object = getSkillPointBreakdown();
            if (breakdown == null) return;

            try {
                var target:int = int(breakdown.bundles) - int(breakdown.achievementsAp);
                GV.ppd.skillPtsFromLoot.s(target);
                _logger.log(_modName, "reconcileSkillPoints: bundles=" + breakdown.bundles
                    + " achiAp=" + breakdown.achievementsAp
                    + " achiExcluded=" + breakdown.achievementsExcluded
                    + " skillPtsFromLoot=" + target);
            } catch (err:Error) {
                _logger.log(_modName, "reconcileSkillPoints error: " + err.message);
            }
        }

        /**
         * Returns { bundles, achievementsAp, achievementsExcluded } — the
         * canonical SP contributions used both for reconcile and for the
         * Skills-panel tooltip breakdown. Returns null if state isn't ready.
         *
         *   bundles              — sum(SP for received bundles 1700-1703)
         *   achievementsAp       — sum(skillPtValue for gainedAchis that are AP-tracked)
         *   achievementsExcluded — sum(skillPtValue for gainedAchis NOT in AP
         *                          (effort/Trial/Endurance/untrackable);
         *                          these still flow through vanilla SP)
         */
        public function getSkillPointBreakdown():Object {
            if (GV.ppd == null) return null;
            if (AV.serverData == null || AV.serverData.serverOptions == null) return null;
            if (AV.sessionData == null) return null;

            // Bundles are stackable — the same apId can arrive multiple
            // times per slot. sessionData.collectedItems is just a boolean
            // ("seen at least once"), so multiply by getItemCount(apId) to
            // get the true total. Without this, a slot that received four
            // Small bundles would only credit one Small's worth of SP and
            // the drop icon's total would diverge from the panel.
            var bundles:int = 0;
            for (var apId:int = 1700; apId <= 1703; apId++) {
                var count:int = AV.sessionData.getItemCount(apId);
                if (count > 0) {
                    bundles += count * int(AV.serverData.serverOptions.getSpBundleValue(apId));
                }
            }

            var achiAp:int = 0;
            var achiExcluded:int = 0;
            var gainedAchis:Array = GV.ppd.gainedAchis;
            if (GV.achiCollection != null && GV.achiCollection.achisByOrder != null && gainedAchis != null) {
                var achisByOrder:Array = GV.achiCollection.achisByOrder;
                for (var i:int = 0; i < achisByOrder.length; i++) {
                    var ach:* = achisByOrder[i];
                    if (!ach) continue;
                    var gameId:int = int(ach.id);
                    if (gameId < 0 || gameId >= gainedAchis.length) continue;
                    if (gainedAchis[gameId] !== true) continue;

                    var spValue:int = int(ach.skillPtValue);
                    if (spValue <= 0) continue;

                    var achData:Object = _gameIdToData[gameId];
                    if (achData != null && getSkipReason(achData) == null) {
                        achiAp += spValue;
                    } else {
                        achiExcluded += spValue;
                    }
                }
            }

            return {bundles: bundles, achievementsAp: achiAp, achievementsExcluded: achiExcluded};
        }

        /**
         * Bundle item grant hook. Bundle's apId is already in
         * sessionData.collectedItems (set in ArchipelagoMod.grantItem before
         * this call), so reconcile picks it up. The `points` argument is
         * kept for log compatibility but the math is derived, not additive.
         */
        public function awardSkillPoints(points:int):void {
            reconcileSkillPoints();
        }
    }
}

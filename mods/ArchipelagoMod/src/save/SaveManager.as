package save {
    import Bezel.Logger;

    import data.AV;
    import net.ConnectionManager;
    import unlockers.LevelUnlocker;
    import unlockers.ShadowCoreUnlocker;
    import unlockers.TalismanUnlocker;

    /**
     * Owns all slot-data persistence for the Archipelago mod.
     *
     * Coordinates between FileHandler (raw I/O), ConnectionManager (credentials),
     * LevelUnlocker (bonusWizardLevel), ShadowCoreUnlocker (totalShadowCoresGranted),
     * and TalismanUnlocker (genericTalismansGranted) so ArchipelagoMod stays a thin shell.
     *
     * Slot file fields: host, port, slot, password, bonusWizardLevel,
     *                   totalShadowCoresGranted, genericTalismansGranted,
     *                   completed, deathLinkEnabled, deathLinksSent,
     *                   deathLinksReceived, standalone, seenOfflineApIds,
     *                   sessionState.
     *
     * sessionState is a snapshot of AV.sessionData (collected items, tokens,
     * stash unlocks). Persisted so map tooltips and tile coloring remain
     * correct across game restarts even before AP reconnect — every other
     * AP-granted item type is baked into GV.ppd and survives via the vanilla
     * save, but field tokens / stash unlocks live only in AV.sessionData and
     * would otherwise reset to empty on every launch.
     */
    public class SaveManager {

        private var _logger:Logger;
        private var _modName:String;
        private var _fileHandler:FileHandler;
        private var _connectionManager:ConnectionManager;
        private var _levelUnlocker:LevelUnlocker;
        private var _shadowCoreUnlocker:ShadowCoreUnlocker;

        private var _talismanUnlocker:TalismanUnlocker;
        private var _currentSlot:int       = 0;
        private var _slotCompleted:Boolean = false;
        private var _deathLinkEnabled:Boolean    = false;
        private var _deathLinkEnabledSet:Boolean = false; // false = no saved value yet (new slot)
        private var _deathLinksSent:int          = 0;     // DeathLinks we sent out (actual deaths bounced)
        private var _deathLinksReceived:int      = 0;     // DeathLinks received from other players
        // Per-stage AP play stats for the Stats tab grid.
        // strId -> { attempts:int, wins:int, losses:int, achievements:int } (Journey battles).
        private var _stageStats:Object           = {};
        private var _standalone:Boolean    = false;
        private var _standaloneSet:Boolean = false;       // false = no saved value yet (new slot)
        private var _seenOfflineApIds:Array = [];         // apIds the player has seen via the offline-items grid

        public function SaveManager(logger:Logger, modName:String,
                                    fileHandler:FileHandler,
                                    connectionManager:ConnectionManager,
                                    levelUnlocker:LevelUnlocker) {
            _logger            = logger;
            _modName           = modName;
            _fileHandler       = fileHandler;
            _connectionManager = connectionManager;
            _levelUnlocker     = levelUnlocker;
        }

        /** Wire in after construction so SaveManager can persist shadow core state. */
        public function set shadowCoreUnlocker(v:ShadowCoreUnlocker):void { _shadowCoreUnlocker = v; }

        /** Wire in after construction so SaveManager can persist talisman grant state. */
        public function set talismanUnlocker(v:TalismanUnlocker):void { _talismanUnlocker = v; }

        public function get currentSlot():int        { return _currentSlot; }
        public function set currentSlot(v:int):void  { _currentSlot = v; }
        public function get slotCompleted():Boolean   { return _slotCompleted; }
        public function get deathLinkEnabled():Boolean        { return _deathLinkEnabled; }
        public function set deathLinkEnabled(v:Boolean):void  { _deathLinkEnabled = v; _deathLinkEnabledSet = true; }
        /** False if the slot file had no saved deathlink preference (new slot). */
        public function get deathLinkEnabledSet():Boolean { return _deathLinkEnabledSet; }
        /** Count of DeathLinks we've sent out. */
        public function get deathLinksSent():int { return _deathLinksSent; }
        /** Count of DeathLinks received from other players. */
        public function get deathLinksReceived():int { return _deathLinksReceived; }
        /** Tally one DeathLink we sent and persist immediately. */
        public function incrementDeathLinksSent():void {
            _deathLinksSent++;
            saveSlotData();
        }
        /** Tally one DeathLink we received and persist immediately. */
        public function incrementDeathLinksReceived():void {
            _deathLinksReceived++;
            saveSlotData();
        }

        /** Per-stage AP play stats (strId -> {attempts,wins,losses,achievements}). Read-only view. */
        public function get stageStats():Object { return _stageStats; }

        /** Get (creating if absent) the mutable stat record for a stage. */
        private function _stageEntry(strId:String):Object {
            var e:Object = _stageStats[strId];
            if (e == null) {
                e = { attempts: 0, wins: 0, losses: 0, achievements: 0 };
                _stageStats[strId] = e;
            }
            return e;
        }

        public function recordStageAttempt(strId:String):void     { _stageEntry(strId).attempts++;     saveSlotData(); }
        public function recordStageWin(strId:String):void         { _stageEntry(strId).wins++;         saveSlotData(); }
        public function recordStageLoss(strId:String):void        { _stageEntry(strId).losses++;       saveSlotData(); }
        public function recordStageAchievement(strId:String):void { _stageEntry(strId).achievements++; saveSlotData(); }
        public function get standalone():Boolean        { return _standalone; }
        public function set standalone(v:Boolean):void  { _standalone = v; _standaloneSet = true; }
        /** False if the slot file had no saved standalone flag (new slot). */
        public function get standaloneSet():Boolean { return _standaloneSet; }

        /** apIds that have already been displayed in the offline-items grid for this slot. */
        public function get seenOfflineApIds():Array       { return _seenOfflineApIds; }
        public function set seenOfflineApIds(v:Array):void { _seenOfflineApIds = (v != null) ? v : []; }

        /**
         * Load saved slot data into ConnectionManager and LevelUnlocker.
         * Also updates currentSlot to slotId.
         */
        public function loadSlotData(slotId:int):void {
            _currentSlot = slotId;
            _connectionManager.resetSettings();
            _levelUnlocker.bonusWizardLevel = 0;
            if (_shadowCoreUnlocker != null) _shadowCoreUnlocker.totalGranted = 0;
            if (_talismanUnlocker != null) _talismanUnlocker.grantedApIds = {};
            AV.sessionData.reset();
            _slotCompleted       = false;
            _deathLinkEnabled    = false;
            _deathLinkEnabledSet = false;
            _deathLinksSent      = 0;
            _deathLinksReceived  = 0;
            _stageStats          = {};
            _standalone          = false;
            _standaloneSet       = false;
            _seenOfflineApIds    = [];

            var slotData:Object = _fileHandler.loadSlotData(slotId);
            if (slotData != null) {
                if (slotData.host             !== undefined) _connectionManager.apHost       = String(slotData.host);
                if (slotData.port             !== undefined) _connectionManager.apPort       = int(slotData.port);
                if (slotData.slot             !== undefined) _connectionManager.apSlot       = String(slotData.slot);
                if (slotData.password         !== undefined) _connectionManager.apPassword   = String(slotData.password);
                if (slotData.bonusWizardLevel !== undefined) _levelUnlocker.bonusWizardLevel = int(slotData.bonusWizardLevel);
                if (slotData.totalShadowCoresGranted !== undefined && _shadowCoreUnlocker != null)
                    _shadowCoreUnlocker.totalGranted = int(slotData.totalShadowCoresGranted);
                if (slotData.grantedTalismanApIds !== undefined && _talismanUnlocker != null) {
                    var grantedObj:Object = {};
                    for each (var talId:* in slotData.grantedTalismanApIds) grantedObj[String(int(talId))] = true;
                    _talismanUnlocker.grantedApIds = grantedObj;
                }
                if (slotData.completed        !== undefined) _slotCompleted                  = slotData.completed === true;
                if (slotData.deathLinkEnabled !== undefined) {
                    _deathLinkEnabled    = slotData.deathLinkEnabled === true;
                    _deathLinkEnabledSet = true;
                }
                if (slotData.deathLinksSent     !== undefined) _deathLinksSent     = int(slotData.deathLinksSent);
                if (slotData.deathLinksReceived !== undefined) _deathLinksReceived = int(slotData.deathLinksReceived);
                if (slotData.stageStats !== undefined && slotData.stageStats != null) {
                    _stageStats = {};
                    for (var sStrId:String in slotData.stageStats) {
                        var raw:Object = slotData.stageStats[sStrId];
                        if (raw == null) continue;
                        _stageStats[sStrId] = {
                            attempts:     int(raw.attempts),
                            wins:         int(raw.wins),
                            losses:       int(raw.losses),
                            achievements: int(raw.achievements)
                        };
                    }
                }
                if (slotData.standalone !== undefined) {
                    _standalone    = slotData.standalone === true;
                    _standaloneSet = true;
                }
                if (slotData.seenOfflineApIds !== undefined && slotData.seenOfflineApIds is Array) {
                    var ids:Array = slotData.seenOfflineApIds as Array;
                    var copy:Array = [];
                    for each (var rawId:* in ids) copy.push(int(rawId));
                    _seenOfflineApIds = copy;
                }
                if (slotData.sessionState !== undefined && slotData.sessionState != null) {
                    AV.sessionData.restoreFromSnapshot(slotData.sessionState);
                }
            }
        }

        /**
         * Persist current state to slot_N.json.
         * No-ops if currentSlot is not set.
         */
        public function saveSlotData():void {
            if (_currentSlot < 0) return;
            var grantedTalIds:Array = [];
            if (_talismanUnlocker != null) {
                var talIds:Object = _talismanUnlocker.grantedApIds;
                for (var k:String in talIds) grantedTalIds.push(int(k));
            }
            // Snapshot AV.sessionData. If empty (we're between reset() and
            // a full-sync repopulate, or AP hasn't connected yet), preserve
            // whatever sessionState is already on disk so the reset/save
            // dance during reconnect doesn't wipe the cached token state.
            var sessionState:Object = AV.sessionData.toSnapshot();
            if (AV.sessionData.isEmpty()) {
                var existing:Object = _fileHandler.loadSlotData(_currentSlot);
                if (existing != null && existing.sessionState != null) {
                    sessionState = existing.sessionState;
                }
            }

            var slotData:Object = {
                host:             _connectionManager.apHost,
                port:             _connectionManager.apPort,
                slot:             _connectionManager.apSlot,
                password:         _connectionManager.apPassword,
                bonusWizardLevel: _levelUnlocker.bonusWizardLevel,
                totalShadowCoresGranted: _shadowCoreUnlocker != null ? _shadowCoreUnlocker.totalGranted : 0,
                grantedTalismanApIds: grantedTalIds,
                completed:        _slotCompleted,
                deathLinkEnabled:   _deathLinkEnabled,
                deathLinksSent:     _deathLinksSent,
                deathLinksReceived: _deathLinksReceived,
                stageStats:         _stageStats,
                standalone:       _standalone,
                seenOfflineApIds: _seenOfflineApIds,
                sessionState:     sessionState
            };
            _fileHandler.saveSlotData(_currentSlot, slotData);
        }

        /** Mark the current slot as completed and persist immediately. */
        public function markSlotCompleted():void {
            _slotCompleted = true;
            saveSlotData();
            _logger.log(_modName, "Slot " + _currentSlot + " marked as completed");
        }

        /** Returns true if the slot file exists and standalone=true. */
        public function isSlotStandalone(slotId:int):Boolean {
            return _fileHandler.isSlotStandalone(slotId);
        }

        /** Returns true if the slot file exists and completed=true. */
        public function isSlotCompleted(slotId:int):Boolean {
            return _fileHandler.isSlotCompleted(slotId);
        }

        /** Delete the slot file for the given slot and wipe all in-memory state. */
        public function deleteSlot(slotId:int):void {
            _fileHandler.deleteSlot(slotId);
            // Clear in-memory credentials so that any subsequent saveSlotData() call
            // cannot resurrect the old slot name and trigger an auto-connect.
            _connectionManager.resetSettings();
            _levelUnlocker.bonusWizardLevel = 0;
            if (_shadowCoreUnlocker != null) _shadowCoreUnlocker.totalGranted = 0;
            if (_talismanUnlocker != null) _talismanUnlocker.grantedApIds = {};
            AV.sessionData.reset();
            _slotCompleted       = false;
            _deathLinkEnabled    = false;
            _deathLinkEnabledSet = false;
            _deathLinksSent      = 0;
            _deathLinksReceived  = 0;
            _stageStats          = {};
            _standalone          = false;
            _standaloneSet       = false;
            _seenOfflineApIds    = [];
            _logger.log(_modName, "Slot " + slotId + " deleted — in-memory state cleared");
        }
    }
}

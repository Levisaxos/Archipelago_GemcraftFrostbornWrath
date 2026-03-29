package save {
    import Bezel.Logger;

    import net.ConnectionManager;
    import unlockers.LevelUnlocker;

    /**
     * Owns all slot-data persistence for the Archipelago mod.
     *
     * Coordinates between FileHandler (raw I/O), ConnectionManager (credentials),
     * and LevelUnlocker (bonusWizardLevel) so ArchipelagoMod stays a thin shell.
     *
     * Slot file fields: host, port, slot, password, bonusWizardLevel, completed, deathLinkEnabled.
     */
    public class SaveManager {

        private var _logger:Logger;
        private var _modName:String;
        private var _fileHandler:FileHandler;
        private var _connectionManager:ConnectionManager;
        private var _levelUnlocker:LevelUnlocker;

        private var _currentSlot:int       = 0;
        private var _slotCompleted:Boolean = false;
        private var _deathLinkEnabled:Boolean    = false;
        private var _deathLinkEnabledSet:Boolean = false; // false = no saved value yet (new slot)
        private var _standalone:Boolean    = false;
        private var _standaloneSet:Boolean = false;       // false = no saved value yet (new slot)

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

        public function get currentSlot():int        { return _currentSlot; }
        public function set currentSlot(v:int):void  { _currentSlot = v; }
        public function get slotCompleted():Boolean   { return _slotCompleted; }
        public function get deathLinkEnabled():Boolean        { return _deathLinkEnabled; }
        public function set deathLinkEnabled(v:Boolean):void  { _deathLinkEnabled = v; _deathLinkEnabledSet = true; }
        /** False if the slot file had no saved deathlink preference (new slot). */
        public function get deathLinkEnabledSet():Boolean { return _deathLinkEnabledSet; }
        public function get standalone():Boolean        { return _standalone; }
        public function set standalone(v:Boolean):void  { _standalone = v; _standaloneSet = true; }
        /** False if the slot file had no saved standalone flag (new slot). */
        public function get standaloneSet():Boolean { return _standaloneSet; }

        /**
         * Load saved slot data into ConnectionManager and LevelUnlocker.
         * Also updates currentSlot to slotId.
         */
        public function loadSlotData(slotId:int):void {
            _currentSlot = slotId;
            _connectionManager.resetSettings();
            _levelUnlocker.bonusWizardLevel = 0;
            _slotCompleted       = false;
            _deathLinkEnabled    = false;
            _deathLinkEnabledSet = false;
            _standalone          = false;
            _standaloneSet       = false;

            var data:Object = _fileHandler.loadSlotData(slotId);
            if (data != null) {
                if (data.host             !== undefined) _connectionManager.apHost       = String(data.host);
                if (data.port             !== undefined) _connectionManager.apPort       = int(data.port);
                if (data.slot             !== undefined) _connectionManager.apSlot       = String(data.slot);
                if (data.password         !== undefined) _connectionManager.apPassword   = String(data.password);
                if (data.bonusWizardLevel !== undefined) _levelUnlocker.bonusWizardLevel = int(data.bonusWizardLevel);
                if (data.completed        !== undefined) _slotCompleted                  = data.completed === true;
                if (data.deathLinkEnabled !== undefined) {
                    _deathLinkEnabled    = data.deathLinkEnabled === true;
                    _deathLinkEnabledSet = true;
                }
                if (data.standalone !== undefined) {
                    _standalone    = data.standalone === true;
                    _standaloneSet = true;
                }
            }
        }

        /**
         * Persist current state to slot_N.json.
         * No-ops if currentSlot is not set.
         */
        public function saveSlotData():void {
            if (_currentSlot < 0) return;
            var data:Object = {
                host:             _connectionManager.apHost,
                port:             _connectionManager.apPort,
                slot:             _connectionManager.apSlot,
                password:         _connectionManager.apPassword,
                bonusWizardLevel: _levelUnlocker.bonusWizardLevel,
                completed:        _slotCompleted,
                deathLinkEnabled: _deathLinkEnabled,
                standalone:       _standalone
            };
            _fileHandler.saveSlotData(_currentSlot, data);
        }

        /** Mark the current slot as completed and persist immediately. */
        public function markSlotCompleted():void {
            _slotCompleted = true;
            saveSlotData();
            _logger.log(_modName, "Slot " + _currentSlot + " marked as completed");
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
            _slotCompleted       = false;
            _deathLinkEnabled    = false;
            _deathLinkEnabledSet = false;
            _standalone          = false;
            _standaloneSet       = false;
            _logger.log(_modName, "Slot " + slotId + " deleted — in-memory state cleared");
        }
    }
}

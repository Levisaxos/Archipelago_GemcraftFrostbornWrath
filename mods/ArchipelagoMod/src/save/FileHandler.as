package save {
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;

    import Bezel.Logger;

    /**
     * Handles all file-based config storage for the Archipelago mod.
     *
     * Directory structure:
     *   {applicationStorageDirectory}/archipelago/
     *     slot_N.json   — per-save-slot AP state
     *
     * Slot file fields:
     *   host             — AP server host
     *   port             — AP server port
     *   slot             — AP slot name
     *   password         — AP password
     *   bonusWizardLevel — accumulated wizard levels from XP tome items
     *   completed        — true once the player has reached the AP goal
     */
    public class FileHandler {

        private var _logger:Logger;
        private var _modName:String;
        private var _configDir:File;

        public function FileHandler(logger:Logger, modName:String) {
            _logger    = logger;
            _modName   = modName;
            _configDir = File.applicationStorageDirectory.resolvePath("archipelago");
            _logger.log(_modName, "Config dir: " + _configDir.nativePath);
        }

        /**
         * Load saved slot data from slot_N.json.
         * Returns an Object with fields: host, port, slot, password,
         *   bonusWizardLevel, completed.
         * Returns null if the file does not exist or cannot be read.
         */
        public function loadSlotData(slotId:int):Object {
            if (slotId <= 0) return null;
            var f:File = _configDir.resolvePath("slot_" + slotId + ".json");
            if (!f.exists) {
                _logger.log(_modName, "No slot_" + slotId + ".json — fresh slot");
                return null;
            }
            try {
                var stream:FileStream = new FileStream();
                stream.open(f, FileMode.READ);
                var raw:String = stream.readUTFBytes(stream.bytesAvailable);
                stream.close();
                var data:Object = JSON.parse(raw);
                _logger.log(_modName, "Loaded slot_" + slotId + ".json"
                    + "  host=" + data.host + " port=" + data.port
                    + " slot='" + data.slot + "'"
                    + " bonusWizardLevel=" + data.bonusWizardLevel
                    + " completed=" + data.completed);
                return data;
            } catch (err:Error) {
                _logger.log(_modName, "loadSlotData ERROR: " + err.message);
            }
            return null;
        }

        /**
         * Save slot data to slot_N.json.
         * @param slotId  The 1-indexed save slot number.
         * @param data    Object with fields: host, port, slot, password,
         *                bonusWizardLevel, completed.
         */
        public function saveSlotData(slotId:int, data:Object):void {
            if (slotId <= 0 || _configDir == null) return;
            try {
                if (!_configDir.exists) _configDir.createDirectory();
                var f:File = _configDir.resolvePath("slot_" + slotId + ".json");
                var stream:FileStream = new FileStream();
                stream.open(f, FileMode.WRITE);
                stream.writeUTFBytes(JSON.stringify(data, null, 2));
                stream.close();
                _logger.log(_modName, "Saved slot_" + slotId + ".json");
            } catch (err:Error) {
                _logger.log(_modName, "saveSlotData ERROR: " + err.message);
            }
        }

        /**
         * Returns true if the slot file exists and standalone=true.
         * Returns false if the file is missing, unreadable, or standalone is not set.
         */
        public function isSlotStandalone(slotId:int):Boolean {
            if (slotId <= 0) return false;
            var f:File = _configDir.resolvePath("slot_" + slotId + ".json");
            if (!f.exists) return false;
            try {
                var stream:FileStream = new FileStream();
                stream.open(f, FileMode.READ);
                var raw:String = stream.readUTFBytes(stream.bytesAvailable);
                stream.close();
                var data:Object = JSON.parse(raw);
                return data.standalone === true;
            } catch (err:Error) {
                _logger.log(_modName, "isSlotStandalone ERROR: " + err.message);
            }
            return false;
        }

        /**
         * Returns true if the slot file exists and completed=true.
         * Returns false if the file is missing, unreadable, or completed is not set.
         */
        public function isSlotCompleted(slotId:int):Boolean {
            if (slotId <= 0) return false;
            var f:File = _configDir.resolvePath("slot_" + slotId + ".json");
            if (!f.exists) return false;
            try {
                var stream:FileStream = new FileStream();
                stream.open(f, FileMode.READ);
                var raw:String = stream.readUTFBytes(stream.bytesAvailable);
                stream.close();
                var data:Object = JSON.parse(raw);
                return data.completed === true;
            } catch (err:Error) {
                _logger.log(_modName, "isSlotCompleted ERROR: " + err.message);
            }
            return false;
        }

        /**
         * Delete the slot file for the given slot.
         */
        public function deleteSlot(slotId:int):void {
            if (slotId <= 0 || _configDir == null) return;
            var f:File = _configDir.resolvePath("slot_" + slotId + ".json");
            if (!f.exists) return;
            try {
                f.deleteFile();
                _logger.log(_modName, "Deleted slot_" + slotId + ".json");
            } catch (err:Error) {
                _logger.log(_modName, "deleteSlot ERROR: " + err.message);
            }
        }
    }
}

package {
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;

    import Bezel.Logger;

    /**
     * Handles all file-based config storage for the Archipelago mod.
     *
     * Directory structure:
     *   {applicationStorageDirectory}/archipelago/
     *     slot_N.json          — per-save-slot AP state
     *     deleted/
     *       slot_N_{ts}.json   — archived AP data
     *       saveslot_N_{ts}.dat — archived game saves
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
         * Returns an Object with fields: host, port, slot, password, apWizardLevels.
         * Returns null if the file does not exist or cannot be read.
         */
        public function loadSlotData(slotId:int):Object {
            if (slotId <= 0) return null;
            var f:File = _configDir.resolvePath("slot_" + slotId + ".json");
            if (!f.exists) {
                _logger.log(_modName, "No slot_" + slotId + ".json — fresh slot, using defaults");
                return null;
            }
            try {
                var stream:FileStream = new FileStream();
                stream.open(f, FileMode.READ);
                var raw:String = stream.readUTFBytes(stream.bytesAvailable);
                stream.close();
                var data:Object = JSON.parse(raw);
                _logger.log(_modName, "Loaded slot_" + slotId + ".json — host=" + data.host
                    + " port=" + data.port + " slot='" + data.slot
                    + "' apWizardLevels=" + data.apWizardLevels);
                return data;
            } catch (err:Error) {
                _logger.log(_modName, "loadSlotData ERROR: " + err.message);
            }
            return null;
        }

        /**
         * Save slot data to slot_N.json.
         * @param slotId  The 1-indexed save slot number.
         * @param data    Object with fields: host, port, slot, password, apWizardLevels.
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
         * Archive a deleted slot's AP data and game save into the deleted/ subdirectory.
         */
        public function archiveSlot(slotId:int):void {
            if (_configDir == null) return;
            var timestamp:String = String(new Date().getTime());
            var deletedDir:File = _configDir.resolvePath("deleted");
            try {
                if (!deletedDir.exists) deletedDir.createDirectory();
            } catch (err:Error) {
                _logger.log(_modName, "archiveSlot: failed to create deleted/ — " + err.message);
                return;
            }
            // Move our AP slot file into deleted/.
            var apFile:File = _configDir.resolvePath("slot_" + slotId + ".json");
            _logger.log(_modName, "archiveSlot: checking AP file=" + apFile.nativePath + " exists=" + apFile.exists);
            if (apFile.exists) {
                try {
                    apFile.moveTo(deletedDir.resolvePath("slot_" + slotId + "_" + timestamp + ".json"), true);
                    _logger.log(_modName, "Archived AP data for slot " + slotId);
                } catch (err:Error) {
                    _logger.log(_modName, "archiveSlot AP data error: " + err.message);
                }
            }
            // Copy the game's own save file into deleted/.
            var saveFile:File = File.applicationStorageDirectory.resolvePath("saveslot" + slotId + ".dat");
            if (saveFile.exists) {
                try {
                    saveFile.copyTo(deletedDir.resolvePath("saveslot" + slotId + "_" + timestamp + ".dat"), true);
                    _logger.log(_modName, "Archived game save for slot " + slotId
                        + " (" + saveFile.size + " bytes)");
                } catch (err:Error) {
                    _logger.log(_modName, "archiveSlot game save error: " + err.message);
                }
            } else {
                _logger.log(_modName, "archiveSlot: no game save found at " + saveFile.nativePath);
            }
        }
    }
}

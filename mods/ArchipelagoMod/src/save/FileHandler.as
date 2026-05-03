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
         * Returns true if the slot file exists and has non-empty AP credentials
         * (host + slot). Used by the router to decide whether to activate AP mode
         * automatically vs prompt the player.
         */
        public function slotHasApCredentials(slotId:int):Boolean {
            if (slotId <= 0) return false;
            var f:File = _configDir.resolvePath("slot_" + slotId + ".json");
            if (!f.exists) return false;
            try {
                var stream:FileStream = new FileStream();
                stream.open(f, FileMode.READ);
                var raw:String = stream.readUTFBytes(stream.bytesAvailable);
                stream.close();
                var data:Object = JSON.parse(raw);
                return data.host != null && String(data.host).length > 0
                    && data.slot != null && String(data.slot).length > 0;
            } catch (err:Error) {
                _logger.log(_modName, "slotHasApCredentials ERROR: " + err.message);
            }
            return false;
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
         * Load all log entries from slot_N_log.jsonl.
         * Each line is a JSON object: { text, color, source, time (epoch ms) }.
         * Returns an empty Array if the file does not exist or cannot be read.
         */
        public function loadLog(slotId:int):Array {
            if (slotId <= 0) return [];
            var f:File = _configDir.resolvePath("slot_" + slotId + "_log.jsonl");
            if (!f.exists) return [];
            var entries:Array = [];
            try {
                var stream:FileStream = new FileStream();
                stream.open(f, FileMode.READ);
                var raw:String = stream.readUTFBytes(stream.bytesAvailable);
                stream.close();
                var lines:Array = raw.split("\n");
                for each (var line:String in lines) {
                    line = line.replace(/^\s+|\s+$/g, "");
                    if (line.length == 0) continue;
                    try {
                        var entry:Object = JSON.parse(line);
                        entry.time = new Date(Number(entry.time));
                        entries.push(entry);
                    } catch (parseErr:Error) {
                        _logger.log(_modName, "loadLog: skipping malformed line");
                    }
                }
                _logger.log(_modName, "Loaded " + entries.length + " log entries for slot " + slotId);
            } catch (err:Error) {
                _logger.log(_modName, "loadLog ERROR: " + err.message);
            }
            return entries;
        }

        /**
         * Append a single log entry to slot_N_log.jsonl.
         * Time is serialized as epoch milliseconds.
         */
        public function appendLogEntry(slotId:int, entry:Object):void {
            if (slotId <= 0 || _configDir == null) return;
            try {
                if (!_configDir.exists) _configDir.createDirectory();
                var f:File = _configDir.resolvePath("slot_" + slotId + "_log.jsonl");
                var stream:FileStream = new FileStream();
                stream.open(f, FileMode.APPEND);
                var serialized:Object = {
                    text:   entry.text,
                    color:  entry.color,
                    source: entry.source,
                    time:   (entry.time as Date).time
                };
                stream.writeUTFBytes(JSON.stringify(serialized) + "\n");
                stream.close();
            } catch (err:Error) {
                _logger.log(_modName, "appendLogEntry ERROR: " + err.message);
            }
        }

        /**
         * Load the mod-level config from modconfig.json.
         * Returns the parsed Object, or null if the file does not exist or cannot be read.
         */
        public function loadModConfig():Object {
            var f:File = _configDir.resolvePath("modconfig.json");
            if (!f.exists) return null;
            try {
                var stream:FileStream = new FileStream();
                stream.open(f, FileMode.READ);
                var raw:String = stream.readUTFBytes(stream.bytesAvailable);
                stream.close();
                return JSON.parse(raw);
            } catch (err:Error) {
                _logger.log(_modName, "loadModConfig ERROR: " + err.message);
            }
            return null;
        }

        /**
         * Save the mod-level config to modconfig.json.
         * @param data  Object to serialize as JSON.
         */
        public function saveModConfig(data:Object):void {
            if (_configDir == null) return;
            try {
                if (!_configDir.exists) _configDir.createDirectory();
                var f:File = _configDir.resolvePath("modconfig.json");
                var stream:FileStream = new FileStream();
                stream.open(f, FileMode.WRITE);
                stream.writeUTFBytes(JSON.stringify(data, null, 2));
                stream.close();
            } catch (err:Error) {
                _logger.log(_modName, "saveModConfig ERROR: " + err.message);
            }
        }

        /**
         * Delete the slot file for the given slot.
         */
        public function deleteSlot(slotId:int):void {
            if (slotId <= 0 || _configDir == null) return;
            var f:File = _configDir.resolvePath("slot_" + slotId + ".json");
            if (f.exists) {
                try {
                    f.deleteFile();
                    _logger.log(_modName, "Deleted slot_" + slotId + ".json");
                } catch (err:Error) {
                    _logger.log(_modName, "deleteSlot ERROR: " + err.message);
                }
            }
            var logFile:File = _configDir.resolvePath("slot_" + slotId + "_log.jsonl");
            if (logFile.exists) {
                try {
                    logFile.deleteFile();
                    _logger.log(_modName, "Deleted slot_" + slotId + "_log.jsonl");
                } catch (err:Error) {
                    _logger.log(_modName, "deleteSlot log ERROR: " + err.message);
                }
            }
        }
    }
}

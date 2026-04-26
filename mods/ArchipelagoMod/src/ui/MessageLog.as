package ui {

    import save.FileHandler;

    /**
     * Shared message store for all Archipelago toast messages.
     *
     * SystemToast and ReceivedToast push entries
     * here so the MessageLogPanel can display full history.
     *
     * Messages are persisted to slot_N_log.jsonl and reloaded on slot open,
     * so the full history survives across sessions for the same seed.
     */
    public class MessageLog {

        /** Source tags. */
        public static const SOURCE_SYSTEM:String     = "system";
        public static const SOURCE_COLLECTION:String  = "collection";

        private var _entries:Array; // { text:String, color:uint, source:String, time:Date }

        private var _fileHandler:FileHandler;
        private var _slotId:int;

        public function MessageLog() {
            _entries = [];
        }

        /**
         * Load persisted history for the given slot and wire up file persistence
         * for all subsequent add() calls. Call once per slot open.
         */
        public function init(fileHandler:FileHandler, slotId:int):void {
            _fileHandler = fileHandler;
            _slotId      = slotId;
            _entries     = _fileHandler.loadLog(slotId);
        }

        /** Add a message to the log (and persist it to disk if a slot is active). */
        public function add(text:String, color:uint, source:String):void {
            var entry:Object = {
                text:   text,
                color:  color,
                source: source,
                time:   new Date()
            };
            _entries.push(entry);
            if (_fileHandler != null && _slotId > 0) {
                _fileHandler.appendLogEntry(_slotId, entry);
            }
        }

        /** Number of entries in the log. */
        public function get length():int {
            return _entries.length;
        }

        /** Retrieve entry at index (0 = oldest). */
        public function getEntry(index:int):Object {
            return _entries[index];
        }

        /** All entries (oldest first). */
        public function get entries():Array {
            return _entries;
        }
    }
}

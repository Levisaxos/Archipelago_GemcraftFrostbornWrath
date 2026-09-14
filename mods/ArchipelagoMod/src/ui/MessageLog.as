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
        private var _pending:Array; // entries not yet written to disk

        private var _fileHandler:FileHandler;
        private var _slotId:int;

        public function MessageLog() {
            _entries = [];
            _pending = [];
        }

        /**
         * Load persisted history for the given slot and wire up file persistence
         * for all subsequent add() calls. Call once per slot open.
         */
        public function init(fileHandler:FileHandler, slotId:int):void {
            flushPending();
            _fileHandler = fileHandler;
            _slotId      = slotId;
            _entries     = _fileHandler.loadLog(slotId);
            _pending     = [];
        }

        /** Add a message to the log (and persist it to disk if a slot is active).
         *  If `html` is provided, the panel renders it via TextField.htmlText so
         *  individual segments (e.g. item names) can carry their own colours;
         *  otherwise the whole line is drawn in `color`. */
        public function add(text:String, color:uint, source:String, html:String = null):void {
            var entry:Object = {
                text:   text,
                color:  color,
                source: source,
                time:   new Date()
            };
            if (html != null) entry.html = html;
            _entries.push(entry);
            // Buffered, not written here: the log carries the whole multiworld
            // feed now, and a file open per line would hitch on a burst.
            // flushPending() runs once a frame.
            _pending.push(entry);
        }

        /**
         * Write everything buffered since the last call in a single file open.
         * Driven from ArchipelagoMod's per-frame tick, and again on teardown so
         * the last frame's messages are not lost.
         */
        public function flushPending():void {
            if (_pending.length == 0) return;
            if (_fileHandler != null && _slotId > 0) {
                _fileHandler.appendLogEntries(_slotId, _pending);
            }
            _pending.length = 0;
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

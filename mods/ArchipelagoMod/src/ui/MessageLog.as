package ui {

    /**
     * Shared message store for all Archipelago toast messages.
     *
     * Both ToastPanel (system) and ItemToastPanel (collection) push entries
     * here so the MessageLogPanel can display full history.
     */
    public class MessageLog {

        /** Maximum entries kept in memory. */
        private static const MAX_ENTRIES:int = 200;

        /** Source tags. */
        public static const SOURCE_SYSTEM:String     = "system";
        public static const SOURCE_COLLECTION:String  = "collection";

        private var _entries:Array; // { text:String, color:uint, source:String, time:Date }

        public function MessageLog() {
            _entries = [];
        }

        /** Add a message to the log. */
        public function add(text:String, color:uint, source:String):void {
            _entries.push({
                text:   text,
                color:  color,
                source: source,
                time:   new Date()
            });
            if (_entries.length > MAX_ENTRIES) {
                _entries.shift();
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

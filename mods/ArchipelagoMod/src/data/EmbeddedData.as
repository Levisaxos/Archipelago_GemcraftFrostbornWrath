package data {
    /**
     * EmbeddedData — Provides access to JSON data files embedded in the SWF.
     * Uses [Embed] metadata to include itemdata.json and logic.json at compile time.
     * This makes the mod completely self-contained (single SWF file, no external files needed).
     */
    public class EmbeddedData {

        [Embed(source="json/itemdata.json", mimeType="application/octet-stream")]
        private static var ItemDataBytes:Class;

        [Embed(source="json/logic.json", mimeType="application/octet-stream")]
        private static var LogicDataBytes:Class;

        /**
         * Get the itemdata.json content as a string.
         */
        public static function getItemDataJSON():String {
            var bytes:* = new ItemDataBytes();
            return bytes.toString();
        }

        /**
         * Get the logic.json content as a string.
         */
        public static function getLogicDataJSON():String {
            var bytes:* = new LogicDataBytes();
            return bytes.toString();
        }
    }
}

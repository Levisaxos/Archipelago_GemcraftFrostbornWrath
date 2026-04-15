package {
    /**
     * Provides access to the embedded logic.json resource.
     * The JSON file is embedded at compile time as a ByteArray resource.
     */
    public class AchievementMap {
        // Embed the logic.json file (path is relative to src directory)
        // File is in data/json/ folder with other game data
        [Embed(source="../data/json/logic.json", mimeType="application/octet-stream")]
        private static const ACHIEVEMENT_DATA:Class;

        /**
         * Load and return the logic rules JSON as a string.
         * @return JSON string containing achievement name -> {apId, grindiness, requirements, etc}
         */
        public static function getData():String {
            try {
                var bytes:* = new ACHIEVEMENT_DATA();
                if (bytes && bytes.readUTFBytes) {
                    return bytes.readUTFBytes(bytes.length);
                }
            } catch (e:Error) {
                // If embedding failed, return empty JSON object
            }
            return "{}";
        }
    }
}

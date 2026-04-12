package {
    /**
     * Provides access to the embedded achievement_id_map.json resource.
     * Maps base game achievement IDs (0-635) to Archipelago location IDs (1000-1635).
     * The JSON file is embedded at compile time as a ByteArray resource.
     */
    public class AchievementIdMap {
        // Embed the achievement_id_map.json file (path is relative to src directory)
        [Embed(source="../../../do not commit/achievement_id_map.json", mimeType="application/octet-stream")]
        private static const ACHIEVEMENT_ID_DATA:Class;

        /**
         * Load and return the achievement ID map JSON as a string.
         * @return JSON string containing base_game_id -> ap_id mapping
         */
        public static function getData():String {
            try {
                var bytes:* = new ACHIEVEMENT_ID_DATA();
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

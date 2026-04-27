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

        [Embed(source="json/achievement_logic.json", mimeType="application/octet-stream")]
        private static var AchievementLogicBytes:Class;

        [Embed(source="json/level_stats.json", mimeType="application/octet-stream")]
        private static var LevelStatsBytes:Class;

        /**
         * Get the itemdata.json content as a string.
         */
        public static function getItemDataJSON():String {
            var bytes:* = new ItemDataBytes();
            return bytes.toString();
        }

        /**
         * Get the stage-tree logic.json content as a string.
         * Used by ServerData to build tier/skill/unlock relationships.
         */
        public static function getLogicDataJSON():String {
            var bytes:* = new LogicDataBytes();
            return bytes.toString();
        }

        /**
         * Get the achievement_logic.json content as a string.
         * Maps achievement name → AP ID, reward, required effort, and requirements.
         */
        public static function getAchievementLogicJSON():String {
            var bytes:* = new AchievementLogicBytes();
            return bytes.readUTFBytes(bytes.length);
        }

        /**
         * Get the level_stats.json content as a string.
         * Per-stage monster stat caps (HP, armor, swarmling count, wave count) used to
         * determine whether threshold-style achievements are reachable in a given field.
         */
        public static function getLevelStatsJSON():String {
            var bytes:* = new LevelStatsBytes();
            return bytes.readUTFBytes(bytes.length);
        }
    }
}

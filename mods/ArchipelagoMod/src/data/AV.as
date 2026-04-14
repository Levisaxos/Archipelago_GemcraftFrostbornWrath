package data {
    /**
     * Archipelago Variables (AV) — Central data container for all mod state.
     * Organized into four domains: connection, server data, game data, and player save data.
     */
    public class AV {
        // -----------------------------------------------------------------------
        // Top-level generic mod data

        public static var version:String = "1.0.0";
        public static var isConnected:Boolean = false;
        public static var currentSlot:String = "";
        public static var currentWorld:String = "";
        public static var playerNames:Object = {};      // slot → alias (from AP)
        public static var playerGames:Object = {};      // slot → game name (from AP)

        // -----------------------------------------------------------------------
        // Archipelago server data (immutable after connection)

        public static var serverData:ServerData = new ServerData();

        // -----------------------------------------------------------------------
        // Game-specific static data (never changes)

        public static var gameData:GameData = new GameData();

        // -----------------------------------------------------------------------
        // Player save data (mutable, per-session state)

        public static var saveData:SaveData = new SaveData();

        // -----------------------------------------------------------------------
        // Utility functions

        /**
         * Initialize all data structures (call once on mod startup).
         */
        public static function initialize():void {
            serverData.initialize();
            gameData.initialize();
            saveData.initialize();
        }

        /**
         * Clear all Archipelago data (call on disconnect / exit to main menu).
         * Resets connection state, server data, and player progress.
         * Does NOT clear gameData (static game knowledge that never changes).
         *
         * After calling this, standalone games will run normally without any AP data.
         */
        public static function clear():void
        {
            // Clear connection state
            isConnected = false;
            currentSlot = "";
            currentWorld = "";
            playerNames = {};
            playerGames = {};

            // Clear server-specific data (from AP)
            serverData.clear();

            // Clear all player progress and collected items
            saveData.initialize();

            // Note: gameData is NOT cleared because it's static game knowledge
            // that never changes per connection
        }
    }
}

package data {
    /**
     * SaveData — Runtime player progress and state.
     * Mutable, per-session data that tracks what the player has collected.
     * This data is persisted to disk and restored on reconnect.
     */
    public class SaveData {
        // Collected Items
        public var unlockedSkills:Object;        // gameId → Boolean
        public var unlockedTraits:Object;        // gameId → Boolean
        public var unlockedTokenStages:Object;   // stage str_id → Boolean
        public var receivedTalismans:Array;      // Array<TalismanFragment>
        public var totalShadowCores:int;
        public var grantedApIds:Object;          // apId → Boolean (deduplication for reconnects)

        // Location & Item Tracking
        public var receivedItems:Array;          // Array of { apId, itemName, fromSlot, fromWorld }
        public var receivedLocations:Object;     // locId → Boolean (locations where items were found)
        public var missingLocations:Object;      // locId → Boolean (from AP server - what needs checking)
        public var checkedLocations:Object;      // locId → Boolean (inverse tracking)

        // Player State
        public var bonusWizardLevel:int;
        public var deathLinkEnabled:Boolean;
        public var isStandalone:Boolean;
        public var completed:Boolean;

        public function SaveData() {
            initialize();
        }

        public function initialize():void {
            unlockedSkills = {};
            unlockedTraits = {};
            unlockedTokenStages = {};
            receivedTalismans = [];
            totalShadowCores = 0;
            grantedApIds = {};

            receivedItems = [];
            receivedLocations = {};
            missingLocations = {};
            checkedLocations = {};

            bonusWizardLevel = 0;
            deathLinkEnabled = false;
            isStandalone = false;
            completed = false;
        }

        /**
         * Clear location tracking (for disconnect/reconnect).
         * Keep collected items but reset location state.
         */
        public function clearLocationTracking():void {
            missingLocations = {};
            checkedLocations = {};
        }

        /**
         * Record a received item.
         */
        public function addReceivedItem(apId:int, itemName:String, fromSlot:int, fromWorld:String):void {
            receivedItems.push({
                apId: apId,
                itemName: itemName,
                fromSlot: fromSlot,
                fromWorld: fromWorld
            });
            grantedApIds[String(apId)] = true;
        }

        /**
         * Check if an AP ID has already been granted.
         */
        public function isApIdGranted(apId:int):Boolean {
            return grantedApIds[String(apId)] == true;
        }
    }
}

package data {
    /**
     * ServerData — All data received from the Archipelago server during the
     * Connected packet. This data is immutable after initial connection.
     */
    public class ServerData {
        // Item Mapping (from slot_data)
        public var tokenMap:Object;              // apId (str) → stage str_id
        public var tokenStages:Object;           // stage str_id → true (reverse index)
        public var talismanMap:Object;           // apId (str) → "seed/rarity/type/upgradeLevel"
        public var talismanNameMap:Object;       // apId (str) → display name
        public var shadowCoreMap:Object;         // apId (str) → amount (int)
        public var shadowCoreNameMap:Object;     // apId (str) → display name
        public var wizStashTalData:Object;       // stage str_id → "seed/rarity/type/upgradeLevel"

        // Logic Rules (from slot_data)
        public var stageTier:Object;             // stage str_id → tier (int)
        public var stageSkills:Object;           // stage str_id → Array<skill name>
        public var cumulativeSkillReqs:Object;   // tier (as string) → { category: required count }
        public var tierStageCounts:Object;       // tier (as string) → stage count
        public var tokenRequirementPercent:int;  // percentage of tokens needed per tier
        public var freeStages:Array;             // Array of stage str_ids (W1, W2, W3, W4)

        // Game Options (from slot_data)
        public var serverOptions:ServerOptions;

        public function ServerData() {
            initialize();
        }

        public function initialize():void {
            tokenMap = {};
            tokenStages = {};
            talismanMap = {};
            talismanNameMap = {};
            shadowCoreMap = {};
            shadowCoreNameMap = {};
            wizStashTalData = {};
            stageTier = {};
            stageSkills = {};
            cumulativeSkillReqs = {};
            tierStageCounts = {};
            tokenRequirementPercent = 100;
            freeStages = [];
            serverOptions = new ServerOptions();
        }

        public function clear():void {
            initialize();
        }
    }
}

package data {
    import flash.filesystem.File;
    import flash.filesystem.FileStream;
    import flash.filesystem.FileMode;
    import Bezel.Logger;

    /**
     * ServerData — All data received from the Archipelago server during the
     * Connected packet. Can be loaded from logic.json and supplemented by slot_data.
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

        // Logic Rules (from logic.json or slot_data)
        public var stageTier:Object;             // stage str_id → tier (int)
        public var stageSkills:Object;           // stage str_id → Array<skill name>
        public var cumulativeSkillReqs:Object;   // tier (as string) → { category: required count }
        public var tierStageCounts:Object;       // tier (as string) → stage count
        public var tokenRequirementPercent:int;  // percentage of tokens needed per tier
        public var freeStages:Array;             // Array of stage str_ids (W1, W2, W3, W4)

        // Game Options (from slot_data)
        public var serverOptions:ServerOptions;

        private var _logger:Logger;

        public function ServerData(logger:Logger = null) {
            _logger = logger;
            initialize();
        }

        public function initialize():void
        {
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

        /**
         * Load item data from itemdata.json.
         * Populates AP ID to game name mappings (skills, traits, stages, talismans, etc.).
         */
        public function loadItemDataFromJSON():void
        {
            var jsonPath:File = File.applicationDirectory.resolvePath(
                "../../src/data/json/itemdata.json"
            );

            if (!jsonPath.exists)
            {
                if (_logger)
                {
                    _logger.log("ServerData", "itemdata.json not found at " + jsonPath.nativePath + " — using empty defaults");
                }
                return;
            }

            try
            {
                var stream:FileStream = new FileStream();
                stream.open(jsonPath, FileMode.READ);
                var rawData:String = stream.readUTFBytes(stream.bytesAvailable);
                stream.close();

                var itemData:Object = JSON.parse(rawData);

                // Load item definitions from the JSON for validation and reference
                // These provide Archipelago view of items with AP IDs and game ID references

                if (_logger)
                {
                    _logger.log("ServerData", "Loaded itemdata.json");
                }
            }
            catch (e:Error)
            {
                if (_logger)
                {
                    _logger.log("ServerData", "ERROR loading itemdata.json: " + e.message);
                }
            }
        }

        /**
         * Load logic rules from logic.json.
         * Populates stage requirements, tier information, and skill requirements.
         */
        public function loadLogicFromJSON():void
        {
            var jsonPath:File = File.applicationDirectory.resolvePath(
                "../../src/data/json/logic.json"
            );

            if (!jsonPath.exists)
            {
                if (_logger)
                {
                    _logger.log("ServerData", "logic.json not found at " + jsonPath.nativePath + " — using empty defaults");
                }
                return;
            }

            try
            {
                var stream:FileStream = new FileStream();
                stream.open(jsonPath, FileMode.READ);
                var rawData:String = stream.readUTFBytes(stream.bytesAvailable);
                stream.close();

                var logicData:Object = JSON.parse(rawData);

                // Load stage logic from the JSON
                if (logicData.stages)
                {
                    for each (var stageLogic:Object in logicData.stages)
                    {
                        var strId:String = stageLogic.strId;

                        if (stageLogic.unlocks)
                        {
                            // stageUnlocks can be set elsewhere if needed
                        }
                        if (stageLogic.requiredSkills)
                        {
                            stageSkills[strId] = stageLogic.requiredSkills;
                        }
                    }
                }

                if (_logger)
                {
                    _logger.log("ServerData", "Loaded logic.json");
                }
            }
            catch (e:Error)
            {
                if (_logger)
                {
                    _logger.log("ServerData", "ERROR loading logic.json: " + e.message);
                }
            }
        }

        public function clear():void
        {
            initialize();
        }
    }
}

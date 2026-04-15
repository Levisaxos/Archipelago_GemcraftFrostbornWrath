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

        // ID Mappings (from itemdata.json)
        public var apIdToGameId:Object;          // AP ID (int) → game ID (int) — skills, traits, gems, mapTiles
        public var apIdToName:Object;            // AP ID (int) → display name (str) — all named items
        public var stagesByStrId:Object;         // strId → { itemApId, locApId, wizStashLocApId, type }
        public var stagesByLocApId:Object;       // locApId (int) → stage strId — for location lookups
        public var talismansByApId:Object;       // item AP ID (int) → { str_id, tal_data }
        public var shadowCoresByApId:Object;     // item AP ID (int) → { str_id, amounts, total }

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
            apIdToGameId = {};
            apIdToName = {};
            stagesByStrId = {};
            stagesByLocApId = {};
            talismansByApId = {};
            shadowCoresByApId = {};
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

                // Skills: AP ID 300-323 → game ID 0-23
                if (itemData.skills)
                {
                    for each (var skill:Object in itemData.skills)
                    {
                        apIdToGameId[skill.ap_id] = skill.game_id;
                        apIdToName[skill.ap_id] = skill.name;
                    }
                }

                // Battle traits: AP ID 400-414 → game ID 0-14
                if (itemData.battleTraits)
                {
                    for each (var trait:Object in itemData.battleTraits)
                    {
                        apIdToGameId[trait.ap_id] = trait.game_id;
                        apIdToName[trait.ap_id] = trait.name;
                    }
                }

                // Gem unlocks: AP ID 600-605 → game ID 0-5
                if (itemData.gemUnlocks)
                {
                    for each (var gem:Object in itemData.gemUnlocks)
                    {
                        apIdToGameId[gem.ap_id] = gem.game_id;
                        apIdToName[gem.ap_id] = gem.name;
                    }
                }

                // Map tiles: AP ID 200-225 → game ID 0-25
                if (itemData.mapTiles)
                {
                    for each (var tile:Object in itemData.mapTiles)
                    {
                        apIdToGameId[tile.ap_id] = tile.game_id;
                    }
                }

                // Stages: strId → AP IDs, and locApId → strId for location lookups
                if (itemData.stages)
                {
                    for each (var stage:Object in itemData.stages)
                    {
                        var stageEntry:Object = {
                            strId:          stage.strId,
                            type:           stage.type,
                            itemApId:       stage.itemApId,
                            locApId:        stage.locApId,
                            wizStashLocApId: stage.wizStashLocApId
                        };
                        stagesByStrId[stage.strId] = stageEntry;
                        if (stage.locApId != null)
                        {
                            stagesByLocApId[stage.locApId] = stage.strId;
                        }
                        if (stage.itemApId != null)
                        {
                            apIdToName[stage.itemApId] = stage.strId + " Field Token";
                        }
                    }
                }

                // Talisman fragments: item AP ID 700-799 → {str_id, tal_data}
                if (itemData.talismanFragments)
                {
                    for each (var talisman:Object in itemData.talismanFragments)
                    {
                        talismansByApId[talisman.item_ap_id] = {
                            strId:   talisman.str_id,
                            talData: talisman.tal_data
                        };
                        apIdToName[talisman.item_ap_id] = "Talisman Fragment (" + talisman.str_id + ")";
                    }
                }

                // Extra talisman fragments
                if (itemData.extraTalismanFragments)
                {
                    for each (var extraTalisman:Object in itemData.extraTalismanFragments)
                    {
                        talismansByApId[extraTalisman.item_ap_id] = {
                            strId:   extraTalisman.str_id,
                            talData: extraTalisman.tal_data
                        };
                        apIdToName[extraTalisman.item_ap_id] = "Talisman Fragment (" + extraTalisman.str_id + ")";
                    }
                }

                // Shadow core stashes: item AP ID 800-868 → {str_id, amounts, total}
                if (itemData.shadowCoreStashes)
                {
                    for each (var shadowCore:Object in itemData.shadowCoreStashes)
                    {
                        shadowCoresByApId[shadowCore.item_ap_id] = {
                            strId:   shadowCore.str_id,
                            amounts: shadowCore.amounts,
                            total:   shadowCore.total
                        };
                        apIdToName[shadowCore.item_ap_id] = shadowCore.total + " Shadow Cores (" + shadowCore.str_id + ")";
                    }
                }

                // Extra shadow core stashes
                if (itemData.extraShadowCoreStashes)
                {
                    for each (var extraShadowCore:Object in itemData.extraShadowCoreStashes)
                    {
                        shadowCoresByApId[extraShadowCore.item_ap_id] = {
                            strId:   extraShadowCore.str_id,
                            amounts: extraShadowCore.amounts,
                            total:   extraShadowCore.total
                        };
                        apIdToName[extraShadowCore.item_ap_id] = extraShadowCore.total + " Shadow Cores (" + extraShadowCore.str_id + ")";
                    }
                }

                if (_logger)
                {
                    _logger.log("ServerData", "Loaded itemdata.json — "
                        + _countKeys(apIdToGameId) + " ID mappings, "
                        + _countKeys(stagesByStrId) + " stages, "
                        + _countKeys(talismansByApId) + " talismans, "
                        + _countKeys(shadowCoresByApId) + " shadow core stashes");
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

        private static function _countKeys(obj:Object):int {
            var n:int = 0;
            for (var k:String in obj) n++;
            return n;
        }
    }
}

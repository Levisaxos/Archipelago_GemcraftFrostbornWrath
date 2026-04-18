package data {
    import Bezel.Logger;

    /**
     * Archipelago Variables (AV) — Central data container for all mod state.
     * Organized into four domains: connection, server data, game data, and player save data.
     */
    public class AV {
        // -----------------------------------------------------------------------
        // Top-level generic mod data

        public static var version:String = "1.0.0";
        public static var currentSlot:String = "";

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
        public static var archipelagoData:ArchipelagoData = new ArchipelagoData();

        // -----------------------------------------------------------------------
        // Internal logger reference (set by ArchipelagoMod.bind)

        private static var _logger:Logger = null;

        // -----------------------------------------------------------------------
        // Utility functions

        /**
         * Set the logger for AV data structures (call from ArchipelagoMod.bind).
         */
        public static function setLogger(logger:Logger):void
        {
            _logger = logger;
            serverData = new ServerData(logger);
            gameData = new GameData(logger);
        }

        /**
         * Initialize all data structures (call once on mod startup).
         * GameData is populated from the actual game data (skills, traits, hardcoded definitions).
         * Logic rules will be loaded separately when AP connects via ServerData.loadLogicFromJSON().
         */
        public static function initialize():void
        {
            serverData.initialize();
            gameData.initialize();
            gameData.populateFromGame();
            saveData.initialize();
        }

        /**
         * Populate stage data from the game (call when GV.stageCollection is ready).
         */
        public static function populateStages():void
        {
            gameData.populateStagesFromGame();
        }

        /**
         * Load server data from JSON files (call when AP connects).
         * Loads both itemdata.json (AP ID mappings) and logic.json (unlock requirements).
         */
        public static function loadServerDataFromJSON():void
        {
            serverData.loadItemDataFromJSON();
            serverData.loadLogicFromJSON();
            validateGameData();
        }

        /**
         * Validate that GameData matches ServerData (one-time check after loading).
         * Compares skill/trait names and IDs between game definitions and itemdata.json.
         * Logs any mismatches.
         */
        public static function validateGameData():void
        {
            if (_logger == null) return;

            var hasErrors:Boolean = false;

            // Validate skills: compare GameData names against ServerData names from itemdata.json
            if (gameData.skills && gameData.skills.length > 0)
            {
                for (var i:int = 0; i < gameData.skills.length; i++)
                {
                    var gameSkill:Object = gameData.skills[i];
                    var apSkillName:String = serverData.apIdToName[gameSkill.apId];
                    var apSkillGameId:int  = serverData.apIdToGameId[gameSkill.apId];

                    if (apSkillName == null)
                    {
                        _logger.log("AV", "VALIDATION ERROR: Skill AP ID=" + gameSkill.apId + " (" + gameSkill.name + ") not found in itemdata.json");
                        hasErrors = true;
                    }
                    else if (apSkillName != gameSkill.name)
                    {
                        _logger.log("AV", "VALIDATION MISMATCH: Skill AP ID=" + gameSkill.apId + " game name='" + gameSkill.name + "' ap name='" + apSkillName + "'");
                        hasErrors = true;
                    }
                    else if (apSkillGameId != gameSkill.gameId)
                    {
                        _logger.log("AV", "VALIDATION MISMATCH: Skill AP ID=" + gameSkill.apId + " game_id=" + gameSkill.gameId + " ap game_id=" + apSkillGameId);
                        hasErrors = true;
                    }
                }
            }

            // Validate battle traits: compare GameData names against ServerData names from itemdata.json
            if (gameData.battleTraits && gameData.battleTraits.length > 0)
            {
                for (var j:int = 0; j < gameData.battleTraits.length; j++)
                {
                    var gameTrait:Object = gameData.battleTraits[j];
                    var apTraitName:String = serverData.apIdToName[gameTrait.apId];
                    var apTraitGameId:int  = serverData.apIdToGameId[gameTrait.apId];

                    if (apTraitName == null)
                    {
                        _logger.log("AV", "VALIDATION ERROR: Trait AP ID=" + gameTrait.apId + " (" + gameTrait.name + ") not found in itemdata.json");
                        hasErrors = true;
                    }
                    else if (apTraitName != gameTrait.name)
                    {
                        _logger.log("AV", "VALIDATION MISMATCH: Trait AP ID=" + gameTrait.apId + " game name='" + gameTrait.name + "' ap name='" + apTraitName + "'");
                        hasErrors = true;
                    }
                    else if (apTraitGameId != gameTrait.gameId)
                    {
                        _logger.log("AV", "VALIDATION MISMATCH: Trait AP ID=" + gameTrait.apId + " game_id=" + gameTrait.gameId + " ap game_id=" + apTraitGameId);
                        hasErrors = true;
                    }
                }
            }

            // Validate map tiles
            if (gameData.mapTiles && gameData.mapTiles.length > 0)
            {
                for (var m:int = 0; m < gameData.mapTiles.length; m++)
                {
                    var mapTile:Object = gameData.mapTiles[m];
                    if (mapTile.letter == null || mapTile.gameId == null || mapTile.tileIndex == null || mapTile.apId == null)
                    {
                        _logger.log("AV", "VALIDATION ERROR: MapTile " + m + " missing required fields");
                        hasErrors = true;
                        continue;
                    }
                    var apTileGameId:int = serverData.apIdToGameId[mapTile.apId];
                    if (apTileGameId != mapTile.gameId)
                    {
                        _logger.log("AV", "VALIDATION MISMATCH: MapTile AP ID=" + mapTile.apId + " letter=" + mapTile.letter + " game_id=" + mapTile.gameId + " ap game_id=" + apTileGameId);
                        hasErrors = true;
                    }
                }
            }

            // Validate stages (if populated from GV)
            if (gameData.stages && gameData.stages.length > 0)
            {
                for (var s:int = 0; s < gameData.stages.length; s++)
                {
                    var stage:Object = gameData.stages[s];
                    if (stage.gameId == null || stage.strId == null)
                    {
                        _logger.log("AV", "VALIDATION ERROR: Stage " + s + " missing required fields");
                        hasErrors = true;
                        continue;
                    }
                    var apStage:Object = serverData.stagesByStrId[stage.strId];
                    if (apStage == null)
                    {
                        _logger.log("AV", "VALIDATION ERROR: Stage strId=" + stage.strId + " (gameId=" + stage.gameId + ") not found in serverData.stagesByStrId");
                        hasErrors = true;
                    }
                }
            }

            if (hasErrors)
            {
                _logger.log("AV", "VALIDATION FAILED: GameData has mismatches with ServerData");
            }
            else
            {
                _logger.log("AV", "VALIDATION PASSED: GameData matches ServerData");
            }
        }

    }
}

package data {
    import com.giab.games.gcfw.GV;
    import Bezel.Logger;

    /**
     * GameData — All game-specific static data that never changes.
     * Includes skill/trait definitions and ID mappings between game and AP systems.
     * Populated from the actual game data (skill/trait names extracted from game knowledge).
     */
    public class GameData {
        // Skill/Trait Definitions
        public var skills:Array;                 // [{ name, gameId, apId }, ...] — 24 skills, AP IDs 300-323
        public var battleTraits:Array;           // [{ name, gameId, apId }, ...] — 15 traits, AP IDs 400-414
        public var gemUnlocks:Array;             // gem unlock definitions
        public var mapTiles:Array;               // map tile definitions
        public var stages:Array;                 // stage definitions (str_id, type, itemApId, locApId, etc.)
        public var talismanFragments:Array;      // talisman fragment definitions
        public var extraTalismanFragments:Array; // extra talisman fragments
        public var shadowCoreStashes:Array;      // shadow core stash definitions
        public var extraShadowCoreStashes:Array; // extra shadow core stashes
        public var skillCategories:Object;       // skill name → category (populated from slot_data)

        // ID Mappings
        public var stageLocIds:Object;           // stage str_id → base Journey location AP ID
        public var apIdRanges:Object;            // { skills: [300,323], traits: [400,414], tomes: [500,502], talismans: [700,799], shadowCores: [800,868] }

        private var _logger:Logger;

        public function GameData(logger:Logger = null) {
            _logger = logger;
            initialize();
        }

        public function initialize():void
        {
            skills = [];
            battleTraits = [];
            gemUnlocks = [];
            mapTiles = [];
            stages = [];
            talismanFragments = [];
            extraTalismanFragments = [];
            shadowCoreStashes = [];
            extraShadowCoreStashes = [];
            skillCategories = {};
            stageLocIds = {};
            apIdRanges = {
                skills: [300, 323],
                traits: [400, 414],
                tomes: [500, 502],
                talismans: [700, 799],
                shadowCores: [800, 868]
            };
        }

        /**
         * Populate game data from in-game structures (GV).
         * Called after the game has loaded to extract skill, trait, and stage definitions.
         *
         * This reads the actual game data rather than loading from JSON.
         * Skill and trait names come from hardcoded definitions.
         * Stage definitions come from GV.stageCollection.stageMetas.
         */
        public function populateFromGame():void
        {
            // Populate skill definitions (hardcoded from game knowledge)
            skills = [
                { name: "Mana Stream", gameId: 0, apId: 300 },
                { name: "True Colors", gameId: 1, apId: 301 },
                { name: "Fusion", gameId: 2, apId: 302 },
                { name: "Orb of Presence", gameId: 3, apId: 303 },
                { name: "Resonance", gameId: 4, apId: 304 },
                { name: "Demolition", gameId: 5, apId: 305 },
                { name: "Critical Hit", gameId: 6, apId: 306 },
                { name: "Mana Leech", gameId: 7, apId: 307 },
                { name: "Bleeding", gameId: 8, apId: 308 },
                { name: "Armor Tearing", gameId: 9, apId: 309 },
                { name: "Poison", gameId: 10, apId: 310 },
                { name: "Slowing", gameId: 11, apId: 311 },
                { name: "Freeze", gameId: 12, apId: 312 },
                { name: "Whiteout", gameId: 13, apId: 313 },
                { name: "Ice Shards", gameId: 14, apId: 314 },
                { name: "Bolt", gameId: 15, apId: 315 },
                { name: "Beam", gameId: 16, apId: 316 },
                { name: "Barrage", gameId: 17, apId: 317 },
                { name: "Fury", gameId: 18, apId: 318 },
                { name: "Amplifiers", gameId: 19, apId: 319 },
                { name: "Pylons", gameId: 20, apId: 320 },
                { name: "Lanterns", gameId: 21, apId: 321 },
                { name: "Traps", gameId: 22, apId: 322 },
                { name: "Seeker Sense", gameId: 23, apId: 323 }
            ];

            // Populate battle trait definitions (hardcoded from game knowledge)
            battleTraits = [
                { name: "Adaptive Carapace", gameId: 0, apId: 400 },
                { name: "Dark Masonry", gameId: 1, apId: 401 },
                { name: "Swarmling Domination", gameId: 2, apId: 402 },
                { name: "Overcrowd", gameId: 3, apId: 403 },
                { name: "Corrupted Banishment", gameId: 4, apId: 404 },
                { name: "Awakening", gameId: 5, apId: 405 },
                { name: "Insulation", gameId: 6, apId: 406 },
                { name: "Hatred", gameId: 7, apId: 407 },
                { name: "Swarmling Parasites", gameId: 8, apId: 408 },
                { name: "Haste", gameId: 9, apId: 409 },
                { name: "Thick Air", gameId: 10, apId: 410 },
                { name: "Vital Link", gameId: 11, apId: 411 },
                { name: "Giant Domination", gameId: 12, apId: 412 },
                { name: "Strength in Numbers", gameId: 13, apId: 413 },
                { name: "Ritual", gameId: 14, apId: 414 }
            ];

            // Populate map tile definitions (26 tiles for A-Z)
            // Index = 90 - charCode, so A=90 → index 0, B=89 → index 1, ..., Z=65 → index 25
            mapTiles = [
                { letter: "A", gameId: 0, tileIndex: 0 },
                { letter: "B", gameId: 1, tileIndex: 1 },
                { letter: "C", gameId: 2, tileIndex: 2 },
                { letter: "D", gameId: 3, tileIndex: 3 },
                { letter: "E", gameId: 4, tileIndex: 4 },
                { letter: "F", gameId: 5, tileIndex: 5 },
                { letter: "G", gameId: 6, tileIndex: 6 },
                { letter: "H", gameId: 7, tileIndex: 7 },
                { letter: "I", gameId: 8, tileIndex: 8 },
                { letter: "J", gameId: 9, tileIndex: 9 },
                { letter: "K", gameId: 10, tileIndex: 10 },
                { letter: "L", gameId: 11, tileIndex: 11 },
                { letter: "M", gameId: 12, tileIndex: 12 },
                { letter: "N", gameId: 13, tileIndex: 13 },
                { letter: "O", gameId: 14, tileIndex: 14 },
                { letter: "P", gameId: 15, tileIndex: 15 },
                { letter: "Q", gameId: 16, tileIndex: 16 },
                { letter: "R", gameId: 17, tileIndex: 17 },
                { letter: "S", gameId: 18, tileIndex: 18 },
                { letter: "T", gameId: 19, tileIndex: 19 },
                { letter: "U", gameId: 20, tileIndex: 20 },
                { letter: "V", gameId: 21, tileIndex: 21 },
                { letter: "W", gameId: 22, tileIndex: 22 },
                { letter: "X", gameId: 23, tileIndex: 23 },
                { letter: "Y", gameId: 24, tileIndex: 24 },
                { letter: "Z", gameId: 25, tileIndex: 25 }
            ];

            // Stage definitions will be loaded separately via populateStagesFromGame()
            // when the game has fully initialized and GV.stageCollection is available

            if (_logger)
            {
                _logger.log("GameData", "Populated from game — " + skills.length + " skills, " + battleTraits.length + " traits, " + mapTiles.length + " map tiles");
            }
        }

        /**
         * Populate stage definitions from GV.stageCollection.stageMetas.
         * Called after the game has fully initialized and stage data is available.
         *
         * Each stage has: id (gameId), strId (string ID like "A1", "A2", etc.)
         */
        public function populateStagesFromGame():void
        {
            if (GV.stageCollection == null || GV.stageCollection.stageMetas == null)
            {
                if (_logger)
                {
                    _logger.log("GameData", "populateStagesFromGame: GV.stageCollection not ready");
                }
                return;
            }

            stages = [];
            var metas:Array = GV.stageCollection.stageMetas;
            for (var i:int = 0; i < metas.length; i++)
            {
                var meta:* = metas[i];
                if (meta == null) continue;

                var stageDef:Object = {
                    gameId: meta.id,
                    strId: meta.strId
                };
                stages.push(stageDef);
            }

            if (_logger)
            {
                _logger.log("GameData", "Populated stages from game — " + stages.length + " stages");
            }
        }
    }
}

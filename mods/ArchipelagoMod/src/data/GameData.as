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
        public var skills:Array;                 // [{ name, gameId, apId }, ...] — 24 skills, AP IDs 700-723
        public var battleTraits:Array;           // [{ name, gameId, apId }, ...] — 15 traits, AP IDs 800-814
        public var gemUnlocks:Array;             // gem unlock definitions
        public var mapTiles:Array;               // map tile definitions
        public var stages:Array;                 // stage definitions (str_id, type, itemApId, locApId, etc.)
        public var talismanFragments:Array;      // talisman fragment definitions
        public var extraTalismanFragments:Array; // extra talisman fragments
        public var shadowCoreStashes:Array;      // shadow core stash definitions
        public var extraShadowCoreStashes:Array; // extra shadow core stashes
        public var skillCategories:Object;       // skill name → category (populated from slot_data)
        public var levelStats:Object;            // strId → { WaveCount, ReaverMaxHP, ReaverMaxArmor, SwarmlingCount, SwarmlingMaxHP, SwarmlingMaxArmor, GiantMaxHP, GiantMaxArmor }

        // ID Mappings
        public var stageLocIds:Object;           // stage str_id → base Journey location AP ID
        public var apIdRanges:Object;            // { skills: [700,723], traits: [800,814], tomes: [1100,1199], talismans: [900,952], shadowCores: [1000,1351] }

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
            levelStats = {};
            stageLocIds = {};
            apIdRanges = {
                skills: [700, 723],
                traits: [800, 814],
                tomes: [1100, 1199],
                talismans: [900, 952],
                shadowCores: [1000, 1351]
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
                { name: "Mana Stream", gameId: 0, apId: 700 },
                { name: "True Colors", gameId: 1, apId: 701 },
                { name: "Fusion", gameId: 2, apId: 702 },
                { name: "Orb of Presence", gameId: 3, apId: 703 },
                { name: "Resonance", gameId: 4, apId: 704 },
                { name: "Demolition", gameId: 5, apId: 705 },
                { name: "Critical Hit", gameId: 6, apId: 706 },
                { name: "Mana Leech", gameId: 7, apId: 707 },
                { name: "Bleeding", gameId: 8, apId: 708 },
                { name: "Armor Tearing", gameId: 9, apId: 709 },
                { name: "Poison", gameId: 10, apId: 710 },
                { name: "Slowing", gameId: 11, apId: 711 },
                { name: "Freeze", gameId: 12, apId: 712 },
                { name: "Whiteout", gameId: 13, apId: 713 },
                { name: "Ice Shards", gameId: 14, apId: 714 },
                { name: "Bolt", gameId: 15, apId: 715 },
                { name: "Beam", gameId: 16, apId: 716 },
                { name: "Barrage", gameId: 17, apId: 717 },
                { name: "Fury", gameId: 18, apId: 718 },
                { name: "Amplifiers", gameId: 19, apId: 719 },
                { name: "Pylons", gameId: 20, apId: 720 },
                { name: "Lanterns", gameId: 21, apId: 721 },
                { name: "Traps", gameId: 22, apId: 722 },
                { name: "Seeker Sense", gameId: 23, apId: 723 }
            ];

            // Populate battle trait definitions (hardcoded from game knowledge)
            battleTraits = [
                { name: "Adaptive Carapace", gameId: 0, apId: 800 },
                { name: "Dark Masonry", gameId: 1, apId: 801 },
                { name: "Swarmling Domination", gameId: 2, apId: 802 },
                { name: "Overcrowd", gameId: 3, apId: 803 },
                { name: "Corrupted Banishment", gameId: 4, apId: 804 },
                { name: "Awakening", gameId: 5, apId: 805 },
                { name: "Insulation", gameId: 6, apId: 806 },
                { name: "Hatred", gameId: 7, apId: 807 },
                { name: "Swarmling Parasites", gameId: 8, apId: 808 },
                { name: "Haste", gameId: 9, apId: 809 },
                { name: "Thick Air", gameId: 10, apId: 810 },
                { name: "Vital Link", gameId: 11, apId: 811 },
                { name: "Giant Domination", gameId: 12, apId: 812 },
                { name: "Strength in Numbers", gameId: 13, apId: 813 },
                { name: "Ritual", gameId: 14, apId: 814 }
            ];

            // Populate map tile definitions (26 tiles for A-Z)
            // Index = 90 - charCode, so A=90 → index 0, B=89 → index 1, ..., Z=65 → index 25
            // AP IDs 200-225, matching gameId 0-25 (apId = 200 + gameId)
            mapTiles = [
                { letter: "A", gameId: 0, tileIndex: 0, apId: 200 },
                { letter: "B", gameId: 1, tileIndex: 1, apId: 201 },
                { letter: "C", gameId: 2, tileIndex: 2, apId: 202 },
                { letter: "D", gameId: 3, tileIndex: 3, apId: 203 },
                { letter: "E", gameId: 4, tileIndex: 4, apId: 204 },
                { letter: "F", gameId: 5, tileIndex: 5, apId: 205 },
                { letter: "G", gameId: 6, tileIndex: 6, apId: 206 },
                { letter: "H", gameId: 7, tileIndex: 7, apId: 207 },
                { letter: "I", gameId: 8, tileIndex: 8, apId: 208 },
                { letter: "J", gameId: 9, tileIndex: 9, apId: 209 },
                { letter: "K", gameId: 10, tileIndex: 10, apId: 210 },
                { letter: "L", gameId: 11, tileIndex: 11, apId: 211 },
                { letter: "M", gameId: 12, tileIndex: 12, apId: 212 },
                { letter: "N", gameId: 13, tileIndex: 13, apId: 213 },
                { letter: "O", gameId: 14, tileIndex: 14, apId: 214 },
                { letter: "P", gameId: 15, tileIndex: 15, apId: 215 },
                { letter: "Q", gameId: 16, tileIndex: 16, apId: 216 },
                { letter: "R", gameId: 17, tileIndex: 17, apId: 217 },
                { letter: "S", gameId: 18, tileIndex: 18, apId: 218 },
                { letter: "T", gameId: 19, tileIndex: 19, apId: 219 },
                { letter: "U", gameId: 20, tileIndex: 20, apId: 220 },
                { letter: "V", gameId: 21, tileIndex: 21, apId: 221 },
                { letter: "W", gameId: 22, tileIndex: 22, apId: 222 },
                { letter: "X", gameId: 23, tileIndex: 23, apId: 223 },
                { letter: "Y", gameId: 24, tileIndex: 24, apId: 224 },
                { letter: "Z", gameId: 25, tileIndex: 25, apId: 225 }
            ];

            // Stage definitions will be loaded separately via populateStagesFromGame()
            // when the game has fully initialized and GV.stageCollection is available

            if (_logger)
            {
                _logger.log("GameData", "Populated from game — " + skills.length + " skills, " + battleTraits.length + " traits, " + mapTiles.length + " map tiles");
            }

            loadLevelStatsFromJSON();
        }

        /**
         * Load per-stage monster stat caps from the embedded level_stats.json.
         * Used by LogicEvaluator.evaluateInLevel to decide if threshold-style
         * achievements (minMonsterHP, minSwarmlings, ...) are reachable in a field.
         */
        public function loadLevelStatsFromJSON():void
        {
            try
            {
                var raw:String = EmbeddedData.getLevelStatsJSON();
                levelStats = JSON.parse(raw);
                if (_logger)
                {
                    var n:int = 0;
                    for (var k:String in levelStats) n++;
                    _logger.log("GameData", "Loaded level_stats.json — " + n + " stages");
                }
            }
            catch (e:Error)
            {
                levelStats = {};
                if (_logger) _logger.log("GameData", "Failed to load level_stats.json: " + e.message);
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

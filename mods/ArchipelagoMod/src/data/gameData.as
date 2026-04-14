package data {
    /**
     * GameData — All game-specific static data that never changes.
     * Includes skill/trait definitions and ID mappings between game and AP systems.
     */
    public class GameData {
        // Skill/Trait Definitions
        public var skills:Array;                 // [{ name, gameId, apId }, ...] — 24 skills, AP IDs 300-323
        public var battleTraits:Array;           // [{ name, gameId, apId }, ...] — 15 traits, AP IDs 400-414
        public var skillCategories:Object;       // skill name → category (populated from slot_data)

        // ID Mappings
        public var stageLocIds:Object;           // stage str_id → base Journey location AP ID
        public var apIdRanges:Object;            // { skills: [300,323], traits: [400,414], tomes: [500,502], talismans: [700,799], shadowCores: [800,868] }

        public function GameData() {
            initialize();
        }

        public function initialize():void {
            skills = [];
            battleTraits = [];
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
    }
}

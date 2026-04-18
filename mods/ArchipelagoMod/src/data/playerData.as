package data {    
    import Bezel.Logger;

    /**
     * GameData — All game-specific static data that never changes.
     * Includes skill/trait definitions and ID mappings between game and AP systems.
     * Populated from the actual game data (skill/trait names extracted from game knowledge).
     */
    public class PlayerData {

        public var id:Number
        public var name:String
        public var game:String
        public var items:Object
    }
}
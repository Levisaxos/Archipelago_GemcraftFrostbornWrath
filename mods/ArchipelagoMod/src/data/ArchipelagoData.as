package data {
    import flash.filesystem.File;
    import flash.filesystem.FileStream;
    import flash.filesystem.FileMode;
    import flash.utils.Dictionary;
    import Bezel.Logger;

        /**
     * ArchipelagoData — Stores games, locations and itemnames for all different archipelago games.
     */
    public class ArchipelagoData {
        
        public var games:Dictionary = new Dictionary();
        public var players:Dictionary = new Dictionary(); // Stores id, name of player, game and list of items. Needs to get filled by resolveItemNameForSlot.
        public var checks:Object = {};  // locationId(int) → {id:int, name:String, game:String}
        
        public function logPlayers(logger:Logger, modName:String)
        {
            logger.log(modName, "I'm posting all players now");
                for each (var player:PlayerData in players){
                    logger.log(modName, player.id + ": " + player.name + " playing " + player.game);
                }
        }
    }    
}
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
        public var checks:Object = {};  // locationId(int) → {id:int, name:String, game:String, playerName:String}
        
        public function logPlayers(logger:Logger, modName:String):void
        {
            for each (var player:PlayerData in players){
                logger.log(modName, player.id + ": " + player.name + " playing " + player.game);
            }
        }

        public function getCheckName(apId:Number, gameName:String):String
        {
            var check:Object = checks[int(apId)];
            if (check == null) return null;
            var name:String = (check.name != null) ? check.name : ("Item from " + (check.game || gameName || "?"));
            var player:String = check.playerName || "?";
            if (player == AV.currentSlot) return "Found " + name;
            return "Sent " + name + " to " + player;
        }
    }    
}
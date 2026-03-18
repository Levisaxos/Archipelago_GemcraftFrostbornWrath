package {
    import flash.display.MovieClip;

    import Bezel.Bezel;
    import Bezel.BezelMod;
    import Bezel.Logger;
    import Bezel.GCFW.Events.EventTypes;

    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.ingame.IngameEnding;
    import com.giab.games.gcfw.mcDyn.McDropIconOutcome;
    import com.giab.games.gcfw.constants.DropType;

    public class DropLogger extends MovieClip implements BezelMod {

        // --- BezelMod interface ---
        public function get VERSION():String      { return "0.0.1"; }
        public function get MOD_NAME():String     { return "DropLogger"; }
        public function get BEZEL_VERSION():String { return "2.1.1"; }

        private var _logger:Logger;
        private var _bezel:Bezel;

        public function DropLogger() {
            super();
            _logger = Logger.getLogger(MOD_NAME);
        }

        // Called by Bezel after all mods and the game are loaded.
        // gameObjects contains: main, GV, SB, prefs, mods, constants
        public function bind(bezel:Bezel, gameObjects:Object):void {
            _bezel = bezel;
            _logger.log(MOD_NAME, "DropLogger loaded!");

            // SAVE_SAVE fires after the game writes the save file, which happens
            // inside endGame() — called right after updatePpdWithDrops().
            // At this point dropIcons is still populated; it's only cleared in
            // returnToSelector(), which the player hasn't done yet.
            bezel.addEventListener(EventTypes.SAVE_SAVE, onSaveSave);
        }

        public function unload():void {
            _bezel.removeEventListener(EventTypes.SAVE_SAVE, onSaveSave);
            _logger.log(MOD_NAME, "DropLogger unloaded");
        }

        // -----------------------------------------------------------------------

        private function onSaveSave(e:*):void {
            // Guard: ingame state may not exist (e.g. save from menu)
            if (GV.ingameController == null || GV.ingameController.core == null) {
                _logger.log(MOD_NAME, "onSaveSave: no active ingame session, skipping");
                return;
            }

            var ending:IngameEnding = GV.ingameController.core.ending;
            if (ending == null) {
                _logger.log(MOD_NAME, "onSaveSave: ending is null");
                return;
            }

            _logger.log(MOD_NAME, "=== onSaveSave ===");

            // --- IngameEnding state ---
            _logger.log(MOD_NAME, "  isBattleWon:          " + ending.isBattleWon);
            _logger.log(MOD_NAME, "  stageTotalXp:         " + ending.stageTotalXp);
            _logger.log(MOD_NAME, "  stagePreviousXp:      " + ending.stagePreviousXp);
            _logger.log(MOD_NAME, "  fragmentsBoostedSoFar:" + ending.fragmentsBoostedSoFar);

            // --- dropIcons (these are exactly what updatePpdWithDrops iterates over) ---
            if (ending.dropIcons == null) {
                _logger.log(MOD_NAME, "  dropIcons: null");
                return;
            }

            _logger.log(MOD_NAME, "  dropIcons.length: " + ending.dropIcons.length);

            for (var i:int = 0; i < ending.dropIcons.length; i++) {
                var di:McDropIconOutcome = McDropIconOutcome(ending.dropIcons[i]);
                var typeName:String = dropTypeName(di.type);

                // data varies by type: numeric id, count, or a TalismanFragment object
                var dataStr:String = (di.data != null) ? di.data.toString() : "null";

                _logger.log(MOD_NAME, "  drop[" + i + "]  type=" + typeName + "(" + di.type + ")  data=" + dataStr);
            }

            // --- Also log what the stage was ---
            if (GV.ingameController.core.stageMeta != null) {
                _logger.log(MOD_NAME, "  stageId: " + GV.ingameController.core.stageMeta.id);
            }

            _logger.log(MOD_NAME, "=== end ===");
        }

        private function dropTypeName(type:int):String {
            switch (type) {
                case DropType.ACHIEVEMENT:          return "ACHIEVEMENT";
                case DropType.SHADOW_CORE:          return "SHADOW_CORE";
                case DropType.TALISMAN_FRAGMENT:    return "TALISMAN_FRAGMENT";
                case DropType.FIELD_TOKEN:          return "FIELD_TOKEN";
                case DropType.SKILL_POINT:          return "SKILL_POINT";
                case DropType.ENDURANCE_WAVE_STONE: return "ENDURANCE_WAVE_STONE";
                case DropType.MAP_TILE:             return "MAP_TILE";
                case DropType.SKILL_TOME:           return "SKILL_TOME";
                case DropType.BATTLETRAIT_SCROLL:   return "BATTLETRAIT_SCROLL";
                case DropType.JOURNEY_PAGE:         return "JOURNEY_PAGE";
                default:                            return "UNKNOWN";
            }
        }
    }
}

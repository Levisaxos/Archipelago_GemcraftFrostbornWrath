package goals {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Goal: kill the Swarm Queen on K4. Detected by polling
     * GV.ingameCore.stats.killedSwarmQueens (IngameStats lives directly on
     * IngameCore as .stats) while in-battle on K4.
     */
    public class SwarmQueenGoal implements IGoal {

        private var _logger:Logger;
        private var _modName:String;

        public function SwarmQueenGoal(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        public function check():Boolean {
            try {
                var core:* = GV.ingameCore;
                if (core == null) return false;
                if (core.stageMeta == null) return false;
                if (String(core.stageMeta.strId) != "K4") return false;
                var stats:* = core.stats;
                if (stats == null) return false;
                return stats.killedSwarmQueens > 0;
            } catch (err:Error) {
                _logger.log(_modName, "SwarmQueenGoal.check error: " + err.message);
                return false;
            }
        }

        public function get goalName():String {
            return "K4 - Swarm Queen Slain";
        }
    }
}

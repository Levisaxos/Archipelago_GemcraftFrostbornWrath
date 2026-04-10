package goals {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Goal: complete a fixed number of Journey stages.
     * Checks GV.ppd.stageHighestXpsJourney — any stage with XPS > 0 counts.
     */
    public class FieldCountGoal implements IGoal {

        private var _logger:Logger;
        private var _modName:String;
        private var _required:int;

        public function FieldCountGoal(logger:Logger, modName:String, required:int) {
            _logger   = logger;
            _modName  = modName;
            _required = required;
        }

        public function check():Boolean {
            if (GV.ppd == null) return false;

            var xps:* = GV.ppd.stageHighestXpsJourney;
            if (xps == null) return false;

            var completed:int = 0;
            for (var i:int = 0; i < xps.length; i++) {
                if (xps[i] != null && xps[i].g() > 0) completed++;
            }
            return completed >= _required;
        }

        public function get goalName():String {
            return "Fields Cleared (" + _required + " required)";
        }
    }
}

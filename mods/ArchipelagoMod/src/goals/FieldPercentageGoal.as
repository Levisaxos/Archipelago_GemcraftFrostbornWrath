package goals {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Goal: complete a percentage of Journey stages.
     * Required count = floor(percentage × total / 100).
     * Checks GV.ppd.stageHighestXpsJourney — any stage with XPS > 0 counts.
     */
    public class FieldPercentageGoal implements IGoal {

        private var _logger:Logger;
        private var _modName:String;
        private var _percentage:int;

        public function FieldPercentageGoal(logger:Logger, modName:String, percentage:int) {
            _logger     = logger;
            _modName    = modName;
            _percentage = percentage;
        }

        public function check():Boolean {
            if (GV.ppd == null) return false;

            var xps:* = GV.ppd.stageHighestXpsJourney;
            if (xps == null || xps.length == 0) return false;

            var completed:int = 0;
            for (var i:int = 0; i < xps.length; i++) {
                if (xps[i] != null && xps[i].g() > 0) completed++;
            }

            var required:int = int(Math.ceil(xps.length * _percentage / 100.0));
            return completed >= required;
        }

        public function get goalName():String {
            return "Fields Cleared (" + _percentage + "% required)";
        }
    }
}

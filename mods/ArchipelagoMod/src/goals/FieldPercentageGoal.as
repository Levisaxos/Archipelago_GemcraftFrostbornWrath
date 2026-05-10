package goals {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Goal: complete a percentage of Journey stages.
     * Threshold is computed by the apworld and shipped via slot_data
     * (fields_required_count) so this side never recomputes — keeps mod
     * and apworld evaluators in lockstep regardless of total stage count
     * or floor/ceil drift. Percentage is kept only for the goal-name UI.
     * Checks GV.ppd.stageHighestXpsJourney — any stage with XPS > 0 counts.
     */
    public class FieldPercentageGoal implements IGoal {

        private var _logger:Logger;
        private var _modName:String;
        private var _required:int;
        private var _percentage:int;

        public function FieldPercentageGoal(logger:Logger, modName:String, required:int, percentage:int) {
            _logger     = logger;
            _modName    = modName;
            _required   = required;
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

            return completed >= _required;
        }

        public function get goalName():String {
            return "Fields Cleared (" + _percentage + "% required, " + _required + " fields)";
        }
    }
}

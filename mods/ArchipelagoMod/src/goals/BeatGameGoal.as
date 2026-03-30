package goals {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /** Goal: defeat A4 in Journey mode. */
    public class BeatGameGoal implements IGoal {

        private var _logger:Logger;
        private var _modName:String;

        public function BeatGameGoal(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        public function check():Boolean {
            if (GV.stageCollection == null) return false;

            var a4Id:int = GV.getFieldId("A4");
            if (a4Id < 0) {
                _logger.log(_modName, "BeatGameGoal.check: A4 field id not found");
                return false;
            }

            return GV.ppd.stageHighestXpsJourney[a4Id].g() > 0;
        }

        public function get goalName():String {
            return "A4 - Frostborn Wrath Victory";
        }
    }
}

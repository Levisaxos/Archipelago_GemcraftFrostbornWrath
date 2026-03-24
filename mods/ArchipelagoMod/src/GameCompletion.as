package {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Detects when the Archipelago goal is reached (A4 beaten in Journey mode)
     * and fires onGoalReached exactly once per session.
     *
     * Call check() on every battle save event.
     * Call reset() when a new slot session starts (entering LOADGAME).
     * Call markAlreadyCompleted() when loading a slot whose completed flag is true,
     * so we don't re-send the goal to the server.
     */
    public class GameCompletion {

        private var _logger:Logger;
        private var _modName:String;
        private var _toast:ToastPanel;
        private var _goalSent:Boolean = false;

        /** Fired once when A4 is detected as beaten and goal not yet reported. */
        public var onGoalReached:Function; // ():void

        public function GameCompletion(logger:Logger, modName:String, toast:ToastPanel) {
            _logger  = logger;
            _modName = modName;
            _toast   = toast;
        }

        /**
         * Check whether A4 has been beaten and the goal hasn't been sent yet.
         * Safe to call every frame or on every battle save — no-ops once sent.
         */
        public function check():void {
            if (_goalSent) return;
            if (GV.ppd == null || GV.stageCollection == null) return;

            var a4Id:int = GV.getFieldId("A4");
            if (a4Id < 0) {
                _logger.log(_modName, "GameCompletion.check: A4 field id not found");
                return;
            }

            var xp:int = GV.ppd.stageHighestXpsJourney[a4Id].g();
            if (xp <= 0) return;

            _goalSent = true;
            _logger.log(_modName, "GOAL REACHED — A4 Journey completed (xp=" + xp + ")");
            _toast.addMessage("Goal Complete! A4 - Frostborn Wrath Victory!", 0xFFFFDD00);
            if (onGoalReached != null) onGoalReached();
        }

        /** Reset for a new slot session. Call when entering the LOADGAME screen. */
        public function reset():void {
            _goalSent = false;
        }

        /**
         * Suppress further goal sends for this session.
         * Call when the loaded slot already has completed=true, meaning the goal
         * was reported to the AP server in a previous session.
         */
        public function markAlreadyCompleted():void {
            _goalSent = true;
        }
    }
}

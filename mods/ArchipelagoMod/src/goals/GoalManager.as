package goals {
    import Bezel.Logger;

    import com.giab.games.gcfw.GV;

    /**
     * Manages goal detection lifecycle — creates the right IGoal strategy,
     * checks it on save events, and fires onGoalReached exactly once.
     *
     * Call configure() after connecting to set the goal type and parameters.
     * Call check() on every battle save event.
     * Call reset() when a new slot session starts (entering LOADGAME).
     * Call markAlreadyCompleted() when loading a slot whose completed flag
     * is true, so we don't re-send the goal to the server.
     */
    public class GoalManager {

        private var _logger:Logger;
        private var _modName:String;
        private var _itemToast:*;
        private var _goalSent:Boolean = false;
        private var _goal:IGoal;

        /** Fired once when the goal is detected as complete and not yet reported. */
        public var onGoalReached:Function; // ():void

        public function GoalManager(logger:Logger, modName:String, itemToast:*) {
            _logger    = logger;
            _modName   = modName;
            _itemToast = itemToast;
        }

        /**
         * Create the appropriate goal strategy from AP slot data.
         * @param goalType          0 = beat_game, 1 = full_talisman
         * @param talismanMinRarity Minimum fragment rarity for full_talisman goal.
         */
        public function configure(goalType:int, talismanMinRarity:int):void {
            if (goalType == 1) {
                _goal = new FullTalismanGoal(_logger, _modName, talismanMinRarity);
            } else {
                _goal = new BeatGameGoal(_logger, _modName);
            }
            _logger.log(_modName, "GoalManager configured: goalType=" + goalType
                + " talismanMinRarity=" + talismanMinRarity
                + " → " + _goal.goalName);
        }

        /**
         * Check whether the configured goal has been met.
         * Safe to call every frame or on every battle save — no-ops once sent.
         */
        public function check():void {
            if (_goalSent) return;
            if (GV.ppd == null) return;
            if (_goal == null) return;

            if (!_goal.check()) return;

            _goalSent = true;
            _logger.log(_modName, "GOAL REACHED — " + _goal.goalName);
            _itemToast.addItem("Goal Complete! " + _goal.goalName + "!", 0xFFDD00);
            if (onGoalReached != null) onGoalReached();
        }

        /** Reset for a new slot session. Call when entering the LOADGAME screen. */
        public function reset():void {
            _goalSent = false;
            _goal = null;
        }

        /**
         * Suppress further goal sends for this session.
         * Call when the loaded slot already has completed=true.
         */
        public function markAlreadyCompleted():void {
            _goalSent = true;
        }
    }
}

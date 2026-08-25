package patch {
    import com.giab.games.gcfw.utils.Calculator;

    /**
     * Drop-in replacement for GV.calculator that shifts the wizard-level XP
     * curve down by `bonusLevels`, so AP-granted levels stack ON TOP of the
     * level the player's own XP earned.
     *
     * Replaces the old approach, which stored the XP cost of the bonus levels
     * in A4's Trial slot. That baked the bonus into GV.ppd.getXp(), so every
     * XP the player earned afterwards was spent against the INFLATED level's
     * cost — the exact "level rewards overwrite your actual level" complaint.
     * It also pinned the XP bar to 0% of the current level (total XP always
     * landed exactly on a level threshold) and only recomputed when a tome
     * arrived, so the displayed level lagged behind the natural one in
     * between.
     *
     * Overriding this ONE method is enough to fix all of that, because every
     * wizard-level consumer in the game funnels through it:
     *
     *   - Calculator.calculateLevelFromXp() binary-searches
     *     `this.calculatePlayerLevelXpReq`, so virtual dispatch picks up the
     *     override and it returns naturalLevel + bonusLevels. That is what
     *     PlayerProgressData.getWizLevel() calls, which in turn backs skill
     *     points (PnlSkills), mana replenish rate, monster armor scaling,
     *     shadow-core and talisman-fragment drops, and the "reach wizard
     *     level N" achievements.
     *   - SelectorRenderer.renderXpBar() takes req(L) and req(L+1) as the
     *     bar's endpoints. Both shift by the same amount, so the bar shows
     *     progress through the player's NATURAL level: one full bar is one
     *     natural level of XP, not an inflated one.
     *   - SelectorInputHandler's "next level at" tooltip reads the same pair.
     *
     * The vanilla curve is strictly increasing for every real argument (its
     * derivative 300 + 15(p-1) + 3.75(p-1)^2 has no real roots), so shifting
     * it left of level 0 keeps it monotonic and the binary search still
     * converges.
     */
    public class ApCalculator extends Calculator {

        private var _bonusLevels:int = 0;
        private var _suspended:Boolean = false;

        /** AP-granted wizard levels stacked on top of the XP-derived level. */
        public function get bonusLevels():int {
            return _suspended ? 0 : _bonusLevels;
        }

        public function set bonusLevels(value:int):void {
            if (value < 0)
                value = 0;
            if (value == _bonusLevels)
                return;
            _bonusLevels = value;
            _invalidate();
        }

        /**
         * Suspend the bonus without forgetting it.
         *
         * GV.calculator is process-global but the bonus belongs to the AP
         * save, so the LOADGAME screen — which renders a wizard level for
         * EVERY slot via LoaderSaver.renderMcLoadGame — would otherwise show
         * standalone and vanilla slots inflated by the AP slot's bonus.
         */
        public function set suspended(value:Boolean):void {
            if (value == _suspended)
                return;
            _suspended = value;
            _invalidate();
        }

        public function get suspended():Boolean {
            return _suspended;
        }

        /**
         * calculateLevelFromXp memoizes on (lastCalculatedXp, lastCalculatedLevel).
         * The XP total does NOT change when a tome arrives, so without dropping
         * the memo the stale pre-bonus level would be returned forever.
         */
        private function _invalidate():void {
            lastCalculatedXp = -1;
            lastCalculatedLevel = -1;
        }

        /**
         * The vanilla curve shifted right by bonusLevels: reaching displayed
         * level L costs the XP vanilla charges for level L - bonusLevels.
         */
        override public function calculatePlayerLevelXpReq(pLevel:Number):Number {
            return super.calculatePlayerLevelXpReq(pLevel - bonusLevels);
        }
    }
}

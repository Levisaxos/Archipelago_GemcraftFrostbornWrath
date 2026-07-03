package patch {
    import flash.events.MouseEvent;

    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Refreshes the selector's cached skillPointsToSpend before vanilla's Retry
     * handler reinitialises the level.
     *
     * Vanilla starting mana ([IngameInitializer2.as:1310]) is computed as:
     *     initialMana + pnlSkills.skillPointsToSpend * manaForUnspentSkillPoints
     *                 + talisman bonuses
     *
     * pnlSkills.skillPointsToSpend is a cached selector-panel value that only
     * gets refreshed via PnlSkills.adjustSkillsInitial() — which is invoked
     * when the player enters/leaves the selector, on game load, and on
     * buy/sell/giveBack/undo inside the skill panel. The Retry button on the
     * outcome panel calls setScene1 directly without re-entering the selector,
     * so any SP-bearing items (skillpoint bundles, achievement SP) that arrived
     * during the failed battle or while the outcome panel was up are ignored
     * by the mana calc, and the auto-castRiseMaxMana chain doesn't run — the
     * mana pool stays at level 1.
     *
     * Fix: attach a target-phase MouseEvent.MOUSE_UP listener on btnRetry at
     * priority 100 (vanilla uses 0), calling adjustSkillsInitial() before the
     * vanilla handler. Same lifecycle pattern as VictoryRestartButton.
     */
    public class RetryButtonSkillPointsRefresh {

        private var _logger:Logger;
        private var _modName:String;
        private var _attached:Boolean = false;
        // Kept so detach() can remove the listener when leaving AP mode.
        private var _btnRetry:* = null;

        public function RetryButtonSkillPointsRefresh(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        /** Per-frame entry — attempts to attach the listener until the
         *  outcome panel and its btnRetry exist. Idempotent. */
        public function tryAttach():void {
            if (_attached)
                return;
            try {
                if (GV.ingameCore == null || GV.ingameCore.ending == null)
                    return;
                var cnt:* = GV.ingameCore.ending.cnt;
                if (cnt == null)
                    return;
                var panel:* = cnt.mcOutcomePanel;
                if (panel == null || panel.btnRetry == null)
                    return;

                panel.btnRetry.addEventListener(
                    MouseEvent.MOUSE_UP, _onRetryUp, false, 100, true);
                _btnRetry = panel.btnRetry;
                _attached = true;
                _logger.log(_modName,
                    "RetryButtonSkillPointsRefresh: attached to btnRetry");
            } catch (err:Error) {
                _logger.log(_modName,
                    "RetryButtonSkillPointsRefresh.tryAttach ERROR: " + err.message);
            }
        }

        /** Remove the btnRetry listener so a standalone save runs vanilla.
         *  Called from _deactivateApMode; tryAttach re-installs on next AP run. */
        public function detach():void {
            try {
                if (_btnRetry != null)
                    _btnRetry.removeEventListener(MouseEvent.MOUSE_UP, _onRetryUp, false);
            } catch (err:Error) {}
            _btnRetry = null;
            _attached = false;
        }

        private function _onRetryUp(e:MouseEvent):void {
            try {
                if (GV.selectorCore != null && GV.selectorCore.pnlSkills != null) {
                    GV.selectorCore.pnlSkills.adjustSkillsInitial();
                }
            } catch (err:Error) {
                _logger.log(_modName,
                    "RetryButtonSkillPointsRefresh._onRetryUp ERROR: " + err.message);
            }
        }
    }
}

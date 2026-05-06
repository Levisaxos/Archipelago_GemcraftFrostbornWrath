package patch {
    import flash.events.Event;

    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Adds the "Restart Battle" button (btnRetry) to the outcome panel on
     * VICTORY, mirroring the vanilla DEFEAT / ENDURANCE_ENDED behavior so the
     * player can immediately replay the level they just finished without
     * routing back through the map.
     *
     * Vanilla flow (IngameEnding.endGame, lines ~994-1009):
     *   btnRetry.visible = false;
     *   btnBackToMap.visible = true;
     *   if (battleOutcome == DEFEAT || battleOutcome == ENDURANCE_ENDED)
     *       btnRetry.visible = true;
     *   ...
     *   cnt.cntOutcomePanel.addChild(cnt.mcOutcomePanel);
     *
     * The addChild dispatches Event.ADDED_TO_STAGE on mcOutcomePanel after the
     * visibility lines have already executed. A capture-phase listener with
     * priority 100 (vanilla uses 0) flips btnRetry.visible back to true,
     * regardless of outcome. The vanilla click handler
     * IngameInputHandler2.ehOutcomePanelBtnRetryUp is outcome-agnostic — it
     * just calls core.initializer.setScene1(stageData, stageMeta) — so no
     * additional wiring is needed.
     *
     * Listener is attached once per session; mcOutcomePanel is created during
     * IngameInitializer and reused for every battle (removeChild'd on retry,
     * re-added on each endGame), so the listener fires for every outcome.
     */
    public class VictoryRestartButton {

        private var _logger:Logger;
        private var _modName:String;
        private var _attached:Boolean = false;

        public function VictoryRestartButton(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        /** Per-frame entry — attempts to attach the listener until the
         *  outcome panel exists. Idempotent. */
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
                if (panel == null)
                    return;

                // Capture-phase, priority 100 — runs after endGame() has set
                // visibility but at the moment addChild fires ADDED_TO_STAGE.
                panel.addEventListener(Event.ADDED_TO_STAGE, _onPanelAdded, true, 100, true);
                _attached = true;
                _logger.log(_modName,
                    "VictoryRestartButton: attached to mcOutcomePanel");
            } catch (err:Error) {
                _logger.log(_modName,
                    "VictoryRestartButton.tryAttach ERROR: " + err.message);
            }
        }

        private function _onPanelAdded(e:Event):void {
            try {
                var panel:* = e.currentTarget;
                if (panel == null || panel.btnRetry == null)
                    return;
                panel.btnRetry.visible = true;
            } catch (err:Error) {
                _logger.log(_modName,
                    "VictoryRestartButton._onPanelAdded ERROR: " + err.message);
            }
        }
    }
}

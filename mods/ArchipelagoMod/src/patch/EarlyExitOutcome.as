package patch {
    import flash.events.MouseEvent;

    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.IngameStatus;
    import com.giab.games.gcfw.constants.ScreenId;

    /**
     * Routes the in-game pause menu's "Return to map" and "Restart" buttons
     * through the defeat-outcome flow so the AP drop icons get a chance to
     * render before the level ends.
     *
     * Vanilla pause-menu buttons (in scrOptions.mc):
     *   - btnConfirmReturn → ehBtnConfirmReturnClick → IngameEnding.returnToSelector
     *     Skips the outcome panel entirely. AP drop icons (added during the level
     *     to ending.dropIcons by ProgressionBlocker.addXxxDropIcon) never display.
     *   - btnConfirmRetry  → ehBtnConfirmRetryClick → in-place restart
     *     Same problem: outcome panel never shows.
     *
     * This patcher adds capture-phase listeners with priority 100 (vanilla is at
     * priority 0) and stopImmediatePropagation()s the vanilla handler. Then it
     * runs the same pre-flight as the "End battle" button at ScrOptions.as:222 —
     * close the pause menu, force ingameStatus to PLAYING (the
     * endGameWithDefeat guard at IngameEnding.as:730 bails otherwise) — and
     * calls IngameEnding.endGameWithDefeat().
     *
     * The defeat outcome panel then runs through its normal lifecycle:
     *   prepareDropIcons(false) → ProgressionBlocker.tickDropIcons drains it
     *   → 120-frame countdown → _injectApDropIcons pushes AP icons →
     *   panel displays them. Player clicks the outcome panel's btnBackToMap
     *   (vanilla returnToSelector) or btnRetry (vanilla restart) to actually
     *   transition. Those outcome-panel buttons are separate from the pause-
     *   menu pair and not touched here.
     *
     * Listeners are attached once per session (scrOptions is a singleton
     * created in Main's constructor and never recreated); attachment is
     * idempotent via _attached.
     */
    public class EarlyExitOutcome {

        private var _logger:Logger;
        private var _modName:String;
        private var _attached:Boolean = false;

        public function EarlyExitOutcome(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        /** Per-frame entry — attempts to attach listeners until scrOptions
         *  exists and exposes the two confirm buttons. Idempotent. */
        public function tryAttach():void {
            if (_attached)
                return;
            try {
                if (GV.main == null || GV.main.scrOptions == null)
                    return;
                var mc:* = GV.main.scrOptions.mc;
                if (mc == null)
                    return;
                var btnReturn:* = mc.btnConfirmReturn;
                var btnRetry:* = mc.btnConfirmRetry;
                if (btnReturn == null || btnRetry == null)
                    return;

                // Capture-phase, higher priority than vanilla (which uses 0)
                // so we run first and can stopImmediatePropagation the chain.
                btnReturn.addEventListener(MouseEvent.MOUSE_UP, _onConfirmReturn, true, 100, true);
                btnRetry.addEventListener(MouseEvent.MOUSE_UP, _onConfirmRetry,   true, 100, true);
                _attached = true;
                _logger.log(_modName,
                    "EarlyExitOutcome: attached to btnConfirmReturn + btnConfirmRetry");
            } catch (err:Error) {
                _logger.log(_modName,
                    "EarlyExitOutcome.tryAttach ERROR: " + err.message);
            }
        }

        // -----------------------------------------------------------------------
        // Listeners

        private function _onConfirmReturn(e:MouseEvent):void {
            _showDefeatOutcome(e, "Return to map");
        }

        private function _onConfirmRetry(e:MouseEvent):void {
            _showDefeatOutcome(e, "Restart");
        }

        /** Shared body — runs the same prep "End battle" does, then calls
         *  endGameWithDefeat() so the AP drop icons get rendered. */
        private function _showDefeatOutcome(e:MouseEvent, source:String):void {
            try {
                if (GV.ingameCore == null)
                    return;
                if (GV.main == null || GV.main.currentScreen != ScreenId.INGAME)
                    return;

                // If the outcome panel is already up (the player would have
                // gotten here via the outcome-panel's own buttons, not the
                // pause-menu ones), don't re-trigger.
                var status:int = GV.ingameCore.ingameStatus;
                if (status == IngameStatus.GAMEOVER_PANEL_APPEARING
                        || status == IngameStatus.GAMEOVER_PANEL_STATS_ROLLING
                        || status == IngameStatus.GAMEOVER_PANEL_DROPS_LISTING
                        || status == IngameStatus.GAMEOVER_PANEL_SHOWING_IDLE
                        || status == IngameStatus.GAMEOVER_PANEL_DISAPPEARING) {
                    return;
                }

                // Block vanilla's same-event handler from firing.
                e.stopImmediatePropagation();

                // Match vanilla MOUSE_UP visual: press the confirm button's
                // plate. Wrapped because some event targets may not have the
                // expected nesting (e.g. when the listener fires during a
                // weird nested mouse situation).
                try {
                    var t:* = e.target;
                    if (t != null && t.parent != null && t.parent.plate != null) {
                        t.parent.plate.gotoAndStop(2);
                    }
                } catch (eVis:Error) {}

                // Close the pause menu — the End-battle handler does this
                // before calling endGameWithVictory, and the defeat outcome
                // panel needs the pause menu out of the way to render
                // properly.
                try { GV.main.scrOptions.switchOptions(e); } catch (eClose:Error) {}

                // endGameWithDefeat early-returns when ingameStatus isn't
                // exactly PLAYING (IngameEnding.as:730). The pause menu
                // doesn't change ingameStatus, so this is normally already
                // PLAYING — but force it for safety, including the
                // PLAYING_SHRINE_ACTIVE / SCRIPTED_SCENE_RUNNING edge cases
                // that the End-battle button also normalizes.
                GV.ingameCore.ingameStatus = IngameStatus.PLAYING;

                GV.ingameCore.ending.endGameWithDefeat();
                _logger.log(_modName,
                    "EarlyExitOutcome: " + source + " → defeat outcome panel triggered");
            } catch (err:Error) {
                _logger.log(_modName,
                    "EarlyExitOutcome._showDefeatOutcome (" + source
                    + ") ERROR: " + err.message);
            }
        }
    }
}

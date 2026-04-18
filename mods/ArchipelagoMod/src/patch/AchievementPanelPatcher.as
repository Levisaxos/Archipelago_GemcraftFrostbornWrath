package patch {
    import flash.events.MouseEvent;
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.mcDyn.BtnAchiFilter;
    import com.giab.games.gcfw.selector.PnlAchievements;
    import data.EmbeddedData;

    /**
     * Injects an "In Logic" filter button into the achievement panel so players
     * can quickly see which achievements are reachable with their current items.
     *
     * How it works:
     *   1. tryPatch() — called each selector frame until it succeeds.
     *      Adds a new BtnAchiFilter("In Logic", ...) to pnlAchievements.filterBtns
     *      and wires its mouse events to the panel's existing handlers.
     *
     *   2. patchResetButton() — replaces the "Reset Achievements" button with
     *      an "In Logic" toggle button at the bottom of the panel.
     *
     *   3. updateLogicFlags(inLogicApIds) — call whenever logic changes
     *      (items received, AP connected).  Sets Achievement.filterFlags[ourIndex]
     *      on every achievement based on whether its AP ID is in the provided set.
     *
     *   4. refreshIfActive() — if the achievements panel is currently visible,
     *      re-calls showAchiList() so the new counts appear immediately.
     */
    public class AchievementPanelPatcher {

        // SelectorScreenStatus constants (avoids importing the game class)
        private static const ACHIEVEMENTS_IDLE_STAGES:int   = 305;
        private static const ACHIEVEMENTS_IDLE_SETTINGS:int = 306;

        private var _logger:Logger;
        private var _modName:String;
        private var _patched:Boolean = false;
        private var _resetButtonPatched:Boolean = false;
        private var _ourFilterIndex:int = -1;
        private var _ourFilterButton:BtnAchiFilter;
        private var _resetButtonHandler:Function;

        // achievement title (String) -> AP location ID (int), built from logic_rules.json
        private var _titleToApId:Object = {};

        // -----------------------------------------------------------------------

        public function AchievementPanelPatcher(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
            _loadTitleMapping();
        }

        // -----------------------------------------------------------------------

        /** Build title -> apId map from logic_rules.json (via EmbeddedData). */
        private function _loadTitleMapping():void {
            try {
                var json:String = EmbeddedData.getAchievementLogicJSON();
                if (!json || json.length <= 2) return;
                var parsed:Object = JSON.parse(json);
                var achs:Object = parsed.achievements;
                if (achs == null) {
                    _logger.log(_modName, "AchievementPanelPatcher: JSON missing 'achievements' key");
                    return;
                }
                var count:int = 0;
                for (var name:String in achs) {
                    if (achs[name].apId != null) {
                        _titleToApId[name] = int(achs[name].apId);
                        count++;
                    }
                }
                _logger.log(_modName, "AchievementPanelPatcher: loaded " + count + " title->apId mappings");
            } catch (e:Error) {
                _logger.log(_modName, "AchievementPanelPatcher: error loading title map: " + e.message);
            }
        }

        // -----------------------------------------------------------------------

        /**
         * Try to inject the "In Logic" filter button into the achievement panel.
         * Safe to call every frame — does nothing once already patched.
         * Uses gold/orange color (0xE5AD0A) to match the prominence of
         * "Locked achievements" / "Unlocked achievements" buttons.
         * @return true once successfully patched.
         */
        public function get patched():Boolean { return _patched; }

        public function tryPatch():Boolean {
            if (_patched) return true;
            if (GV.selectorCore == null) return false;

            var panel:PnlAchievements = GV.selectorCore.pnlAchievements;
            if (panel == null || panel.filterBtns == null) return false;

            _ourFilterIndex = panel.filterBtns.length;

            // Create button with gold/orange color to match the core filter buttons
            // (same color as "Locked achievements" and "Unlocked achievements")
            var btn:BtnAchiFilter = new BtnAchiFilter("In Logic", _ourFilterIndex, 0xE5AD0A);
            btn.addEventListener(MouseEvent.MOUSE_OVER, panel.ehBtnFilterOver, true, 0, true);
            btn.addEventListener(MouseEvent.MOUSE_OUT,  panel.ehBtnFilterOut,  true, 0, true);
            btn.addEventListener(MouseEvent.MOUSE_DOWN, panel.ehBtnFilterDown, true, 0, true);
            btn.addEventListener(MouseEvent.MOUSE_UP,   panel.ehBtnFilterUp,   true, 0, true);
            panel.filterBtns.push(btn);
            _ourFilterButton = btn;

            _patched = true;
            _logger.log(_modName, "AchievementPanelPatcher: patched (filterIndex=" + _ourFilterIndex + ")");
            return true;
        }

        // -----------------------------------------------------------------------

        /**
         * Patch the "Reset Achievements" button to become an "In Logic" toggle.
         * Replaces its label with state-aware text that shows what will happen on click.
         * Safe to call every frame until patched.
         */
        public function patchResetButton(panel:PnlAchievements):Boolean {
            if (_resetButtonPatched) return true;
            if (panel == null || panel.mc == null || panel.mc.btnResetAchievements == null) return false;
            if (_ourFilterButton == null) return false; // Need filter button patched first

            var resetBtn:* = panel.mc.btnResetAchievements;

            // Update text to show current state
            _updateResetButtonText(resetBtn);

            // Add a capture-phase click handler that toggles our filter.
            // Stored in _resetButtonHandler to prevent the closure from being
            // garbage collected (useWeakReference=true only holds a weak ref).
            _resetButtonHandler = function(e:MouseEvent):void {
                if (e.target.parent == resetBtn) {
                    _toggleInLogicFilter(panel);
                    e.stopImmediatePropagation();
                }
            };
            resetBtn.addEventListener(MouseEvent.MOUSE_UP, _resetButtonHandler, true, 101, true);

            _resetButtonPatched = true;
            _logger.log(_modName, "AchievementPanelPatcher: reset button patched");
            return true;
        }

        private function _toggleInLogicFilter(panel:PnlAchievements):void {
            if (_ourFilterButton == null) return;

            // Toggle the filter button's selected state
            _ourFilterButton.isSelected = !_ourFilterButton.isSelected;
            _ourFilterButton.plate.gotoAndStop(_ourFilterButton.isSelected ? 3 : 1);

            // Update button text to reflect new state
            _updateResetButtonText(panel.mc.btnResetAchievements);

            // Refresh the achievement list
            try {
                panel.showAchiList();
            } catch (e:Error) {
                _logger.log(_modName, "Error refreshing achievement list: " + e.message);
            }
        }

        private function _updateResetButtonText(resetBtn:*):void {
            if (resetBtn == null || resetBtn.tf == null) return;

            if (_ourFilterButton.isSelected) {
                // ON state: show all achievements (click to unfilter)
                resetBtn.tf.text = "Show all achievements";
            } else {
                // OFF state: show in logic only (click to filter)
                resetBtn.tf.text = "Show in logic only";
            }
        }

        /**
         * Update filterFlags on every achievement to reflect the current logic state.
         *
         * Looks up each achievement by ach.title in _titleToApId (from logic_rules.json),
         * then checks if that AP ID is in the provided inLogicApIds set.
         *
         * IMPORTANT: The game's showAchiList() iterates filterFlags by index and
         * looks up filterBtns[j] with that same index.  Every achievement must
         * have filterFlags[_ourFilterIndex] set, otherwise the array is too short
         * and showAchiList() crashes with #1010 when shownAchis becomes empty.
         *
         * @param inLogicApIds  Object mapping AP location ID (int) -> true
         */
        public function updateLogicFlags(inLogicApIds:Object):void {
            if (!_patched || _ourFilterIndex < 0) return;
            if (GV.achiCollection == null || GV.achiCollection.achisByOrder == null) return;
            if (inLogicApIds == null) return;

            try {
                var achis:Array = GV.achiCollection.achisByOrder;
                for (var i:int = 0; i < achis.length; i++) {
                    var ach:* = achis[i];
                    if (ach == null) continue;

                    // Look up by title — the only reliable key between game and our data
                    var apId:* = _titleToApId[ach.title];

                    var isInLogic:Boolean = false;
                    if (apId != null && apId !== undefined) {
                        isInLogic = (inLogicApIds[int(apId)] === true);
                    }

                    // Ensure filterFlags is long enough for our index
                    // (game starts it as [] and only populates built-in indices)
                    while (ach.filterFlags.length <= _ourFilterIndex) {
                        ach.filterFlags.push(false);
                    }
                    ach.filterFlags[_ourFilterIndex] = isInLogic;
                }
            } catch (e:Error) {
                _logger.log(_modName, "ERROR in updateLogicFlags: " + e.message);
            }
        }

        /**
         * If the achievement panel is currently on screen, refresh its display.
         * Call this after updateLogicFlags() to make changes visible immediately.
         */
        public function refreshIfActive():void {
            if (!_patched) return;
            if (GV.selectorCore == null) return;
            var status:int = int(GV.selectorCore.screenStatus);
            if (status != ACHIEVEMENTS_IDLE_STAGES && status != ACHIEVEMENTS_IDLE_SETTINGS) return;
            try {
                GV.selectorCore.pnlAchievements.showAchiList();
            } catch (e:Error) {
                _logger.log(_modName, "AchievementPanelPatcher.refreshIfActive error: " + e.message);
            }
        }
    }
}

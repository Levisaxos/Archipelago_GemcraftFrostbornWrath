package patch {
    import flash.display.Shape;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.mcDyn.BtnAchiFilter;
    import com.giab.games.gcfw.selector.PnlAchievements;
    import tracker.AchievementLogicEvaluator;
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

        private static const DOT_NAME:String     = "apLogicDot";
        private static const DOT_RADIUS:Number   = 5;
        private static const DOT_INTERVAL:int    = 30; // frames between periodic re-checks

        private var _logger:Logger;
        private var _modName:String;
        private var _patched:Boolean = false;
        private var _resetButtonPatched:Boolean = false;
        private var _ourFilterIndex:int = -1;
        private var _ourFilterButton:BtnAchiFilter;
        private var _resetButtonHandler:Function;

        // game-internal achievement ID (int) -> AP location ID (int)
        private var _gameIdToApId:Object = {};

        // apId (int) -> true for achievements whose requirements are currently met
        private var _reqMetApIds:Object   = {};
        // apId (int) -> true for achievements with no requirements (always filler)
        private var _excludedApIds:Object = {};
        private var _dotsDirty:Boolean    = false;
        private var _dotFrame:int         = 0;

        private var _tooltipOverlay:AchievementTooltipOverlay;

        // -----------------------------------------------------------------------

        public function AchievementPanelPatcher(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
            _loadGameIdMapping();
            _tooltipOverlay = new AchievementTooltipOverlay(logger, modName);
            _tooltipOverlay.gameIdToApId = _gameIdToApId;
        }

        // -----------------------------------------------------------------------

        /** Build gameId -> apId map from achievement_logic.json (via EmbeddedData). */
        private function _loadGameIdMapping():void {
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
                    var entry:Object = achs[name];
                    if (entry.game_id != null && entry.apId != null) {
                        _gameIdToApId[int(entry.game_id)] = int(entry.apId);
                        count++;
                    }
                }
                _logger.log(_modName, "AchievementPanelPatcher: loaded " + count + " gameId->apId mappings");
            } catch (e:Error) {
                _logger.log(_modName, "AchievementPanelPatcher: error loading gameId map: " + e.message);
            }
        }

        // -----------------------------------------------------------------------

        /**
         * Register a provider that appends failing requirement lines for achievements
         * that are not yet in logic.  Call once after the evaluator is configured.
         */
        public function setAchievementLogicEvaluator(evaluator:AchievementLogicEvaluator):void {
            if (_tooltipOverlay == null || evaluator == null) return;
            var ev:AchievementLogicEvaluator = evaluator;
            _tooltipOverlay.registerProvider(
                function(ach:*, achName:String, apId:int,
                         isExcluded:Boolean, isInLogic:Boolean):Array {
                    if (isInLogic || isExcluded) return [];
                    return ev.getFailingReqLines(apId);
                });
        }

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

            // Refresh the achievement list, then re-apply dots
            try {
                panel.showAchiList();
                _applyLogicDots();
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
         * Looks up each achievement by ach.id in _gameIdToApId (from achievement_logic.json),
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

                    var apId:* = _gameIdToApId[int(ach.id)];

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
                _applyLogicDots();
            } catch (e:Error) {
                _logger.log(_modName, "AchievementPanelPatcher.refreshIfActive error: " + e.message);
            }
        }

        // -----------------------------------------------------------------------
        // Logic dot overlays

        /**
         * Store the latest "requirements met" map for dot rendering.
         * Call whenever logic changes (same timing as updateLogicFlags).
         * @param reqMetApIds  apId->true for every achievement with requirements met
         */
        public function updateDots(reqMetApIds:Object):void {
            _reqMetApIds = reqMetApIds || {};
            _dotsDirty   = true;
            if (_tooltipOverlay != null) _tooltipOverlay.reqMetApIds = _reqMetApIds;
        }

        /**
         * Store the set of achievements that are excluded from logic (no requirements).
         * Call alongside updateDots/updateLogicFlags — the set is static but kept in
         * sync for simplicity.
         * @param excludedApIds  apId->true for every excluded achievement
         */
        public function updateExcluded(excludedApIds:Object):void {
            _excludedApIds = excludedApIds || {};
            _dotsDirty     = true;
            if (_tooltipOverlay != null) _tooltipOverlay.excludedApIds = _excludedApIds;
        }

        /**
         * Call every selector frame.  Applies dots when the panel is visible,
         * throttled to DOT_INTERVAL frames unless _dotsDirty is set.
         */
        public function onSelectorFrame(panel:PnlAchievements):void {
            if (!_patched || panel == null) return;

            // Drive the tooltip overlay every frame (it does its own visibility checks).
            if (_tooltipOverlay != null) _tooltipOverlay.onSelectorFrame(panel);

            _dotFrame++;
            var needsUpdate:Boolean = _dotsDirty || (_dotFrame >= DOT_INTERVAL);
            if (!needsUpdate) return;

            if (GV.selectorCore == null) return;
            var status:int = int(GV.selectorCore.screenStatus);
            if (status != ACHIEVEMENTS_IDLE_STAGES && status != ACHIEVEMENTS_IDLE_SETTINGS) {
                _dotFrame = 0;
                return;
            }

            _dotFrame    = 0;
            _dotsDirty   = false;
            _applyLogicDots();
        }

        // -----------------------------------------------------------------------

        private function _applyLogicDots():void {
            if (!_patched || GV.achiCollection == null) return;
            var achis:Array = GV.achiCollection.achisByOrder;
            if (achis == null) return;

            var applied:int = 0;
            var noMc:int    = 0;

            for (var i:int = 0; i < achis.length; i++) {
                var ach:* = achis[i];
                if (ach == null) continue;

                var apId:* = _gameIdToApId[int(ach.id)];
                if (apId == null) continue; // not AP-tracked

                var mcAchi:* = _getAchMcAchi(ach);
                if (mcAchi == null) { noMc++; continue; }

                // Skip if not in the display list (filtered out or panel closed)
                try { if (mcAchi.parent == null) continue; } catch (e:Error) { continue; }

                var apIdInt:int       = int(apId);
                var excluded:Boolean  = (_excludedApIds[apIdInt] === true);
                var inLogic:Boolean   = (!excluded && _reqMetApIds[apIdInt] === true);
                var isEarned:Boolean  = (int(ach.status) >= 2);

                // Earned achievements need no dot (collected = done).
                if (isEarned) {
                    try {
                        var stale:* = mcAchi.getChildByName(DOT_NAME);
                        if (stale != null) mcAchi.removeChild(stale);
                    } catch (e2:Error) {}
                    applied++;
                    continue;
                }

                _updateDot(mcAchi, inLogic, excluded);
                applied++;
            }

            if (noMc > 0 && applied == 0) {
                _logger.log(_modName, "applyLogicDots: no McAchi found (tried 'mc', 'mcAchi', 'icon'). noMc=" + noMc);
            }
        }

        /** Try common property names that Flash games use for a single child MC. */
        private function _getAchMcAchi(ach:*):* {
            try {
                if (ach.hasOwnProperty("mc")     && ach["mc"]     != null) return ach["mc"];
                if (ach.hasOwnProperty("mcAchi")  && ach["mcAchi"] != null) return ach["mcAchi"];
                if (ach.hasOwnProperty("icon")    && ach["icon"]   != null) return ach["icon"];
            } catch (e:Error) {}
            return null;
        }

        private function _updateDot(mcAchi:*, inLogic:Boolean, excluded:Boolean = false):void {
            // Remove any existing dot
            try {
                var existing:* = mcAchi.getChildByName(DOT_NAME);
                if (existing != null) mcAchi.removeChild(existing);
            } catch (e:Error) {}

            var dot:Shape = new Shape();
            dot.name = DOT_NAME;
            // Grey = excluded/filler, green = in-logic, red = not yet in-logic
            var fillColor:uint = excluded ? 0x888888 : (inLogic ? 0x44FF44 : 0xFF4444);
            dot.graphics.lineStyle(1, 0x000000, 0.6);
            dot.graphics.beginFill(fillColor, 0.9);
            dot.graphics.drawCircle(0, 0, DOT_RADIUS);
            dot.graphics.endFill();

            // Place in top-right corner, using actual bounds when available
            try {
                var b:Rectangle = mcAchi.getBounds(mcAchi) as Rectangle;
                if (b != null && b.width > 20) {
                    dot.x = b.right  - DOT_RADIUS - 1;
                    dot.y = b.top    + DOT_RADIUS + 1;
                } else {
                    dot.x = 54; dot.y = 10;
                }
            } catch (e:Error) {
                dot.x = 54; dot.y = 10;
            }

            try { mcAchi.addChild(dot); } catch (e:Error) {
                _logger.log(_modName, "_updateDot addChild error: " + e.message);
            }
        }
    }
}

package patch {
    import flash.display.Shape;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.IngameStatus;
    import com.giab.games.gcfw.mcDyn.BtnAchiFilter;
    import com.giab.games.gcfw.selector.PnlAchievements;
    import tracker.AchievementLogicEvaluator;
    import data.EmbeddedData;

    /**
     * Patches the achievement panel with:
     *
     *   1. tryPatch() — injects an invisible filter slot (BtnAchiFilter) so the
     *      game's showAchiList() knows about our filterFlags index.
     *
     *   2. patchResetButton() — hides the "Reset Achievements" button and injects
     *      an AchievementGroupPanel (4 toggle buttons, one per group) in its place.
     *      The group panel drives OR-logic filtering over our single filter slot.
     *
     *   3. updateLogicFlags / updateDots / updateExcluded / updateEffortExcluded —
     *      called whenever AP logic changes; rebuild filterFlags and group counts.
     *
     *   4. refreshIfActive() — re-renders the panel if currently visible.
     *
     *   5. Logic dot overlays — coloured dots on each achievement icon.
     */
    public class AchievementPanelPatcher {

        // SelectorScreenStatus constants (avoids importing the game class)
        private static const ACHIEVEMENTS_IDLE_STAGES:int   = 305;
        private static const ACHIEVEMENTS_IDLE_SETTINGS:int = 306;

        private static const DOT_NAME:String   = "apLogicDot";
        private static const DOT_RADIUS:Number = 5;
        private static const DOT_INTERVAL:int  = 30; // frames between periodic dot re-checks

        private var _logger:Logger;
        private var _modName:String;
        private var _patched:Boolean      = false;
        private var _resetButtonPatched:Boolean = false;
        private var _ourFilterIndex:int   = -1;
        private var _ourFilterButton:BtnAchiFilter;

        // game-internal achievement ID (int) -> AP location ID (int)
        private var _gameIdToApId:Object = {};

        // Data sets — populated by update*() calls from ArchipelagoMod
        private var _reqMetApIds:Object         = {}; // apId -> true: req currently met (for dots)
        private var _inLogicApIds:Object        = {}; // apId -> true: req met AND still missing (for grouping/counts)
        private var _excludedApIds:Object       = {}; // apId -> true: untrackable
        private var _effortExcludedApIds:Object = {}; // apId -> true: effort > threshold
        private var _maxEffortLabel:String      = "Trivial";

        private var _dotsDirty:Boolean = false;
        private var _dotFrame:int      = 0;
        // Edge-detect for the in-game achievement panel: vanilla
        // openAchievementsPanel() runs resetFilters() and showAchiList(), but
        // never invokes our patcher because the selector frame loop is paused
        // while currentScreen == INGAME. We re-apply filters + dots once on
        // the rising edge, then throttle reapply while the panel stays up.
        private var _lastIngameAchPanelActive:Boolean = false;

        private var _tooltipOverlay:AchievementTooltipOverlay;
        private var _groupPanel:AchievementGroupPanel;
        private var _searchField:AchievementSearchField;

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
            _tooltipOverlay.achievementLogicEvaluator = ev;
            _tooltipOverlay.registerProvider(
                function(ach:*, achName:String, apId:int,
                         isExcluded:Boolean, isInLogic:Boolean):Array {
                    if (isInLogic || isExcluded) return [];
                    return ev.getFailingReqLines(apId);
                });
        }

        // -----------------------------------------------------------------------

        public function get patched():Boolean { return _patched; }

        /**
         * Inject an invisible filter slot into the achievement panel's filterBtns.
         * The slot is hidden (visible=false) — the AchievementGroupPanel drives it.
         * Safe to call every frame; no-ops once patched.
         */
        public function tryPatch():Boolean {
            if (_patched) return true;
            if (GV.selectorCore == null) return false;

            var panel:PnlAchievements = GV.selectorCore.pnlAchievements;
            if (panel == null || panel.filterBtns == null) return false;

            _ourFilterIndex = panel.filterBtns.length;

            // Hidden filter slot — no mouse listeners, invisible.
            // The game needs it in filterBtns so filterFlags[_ourFilterIndex] is checked.
            var btn:BtnAchiFilter = new BtnAchiFilter("", _ourFilterIndex, 0x000000);
            btn.visible      = false;
            btn.mouseEnabled = false;
            btn.mouseChildren = false;
            panel.filterBtns.push(btn);
            _ourFilterButton = btn;

            _patched = true;
            _logger.log(_modName, "AchievementPanelPatcher: patched (filterIndex=" + _ourFilterIndex + ")");
            return true;
        }

        // -----------------------------------------------------------------------

        /**
         * Replace the "Reset Achievements" button with the AchievementGroupPanel.
         * Safe to call every frame until patched.
         */
        public function patchResetButton(panel:PnlAchievements):Boolean {
            if (_resetButtonPatched) return true;
            if (panel == null || panel.mc == null || panel.mc.btnResetAchievements == null) return false;

            var resetBtn:* = panel.mc.btnResetAchievements;
            resetBtn.visible = false;

            _groupPanel = new AchievementGroupPanel();
            _groupPanel.x = resetBtn.x;
            _groupPanel.y = resetBtn.y - 3; // minor vertical nudge to align with hidden btn
            _groupPanel.onChange = _onGroupToggle;
            try {
                panel.mc.addChild(_groupPanel);
            } catch (e:Error) {
                _logger.log(_modName, "patchResetButton: addChild error: " + e.message);
                return false;
            }

            // Search field — top-right of the panel content area.
            _searchField = new AchievementSearchField();
            _searchField.onChange = _onSearchChange;
            try {
                var panelW:Number = 0;
                try { panelW = Number(panel.mc.width); } catch (eW:Error) { panelW = 0; }
                var sx:Number;
                if (panelW > AchievementSearchField.FIELD_W + 20) {
                    sx = panelW - AchievementSearchField.FIELD_W - 10;
                } else {
                    // Fallback: anchor to the right edge of the hidden reset button.
                    sx = resetBtn.x + 116 - AchievementSearchField.FIELD_W;
                }
                _searchField.x = sx;
                _searchField.y = 60;
                panel.mc.addChild(_searchField);
            } catch (eS:Error) {
                _logger.log(_modName, "patchResetButton: search field addChild error: " + eS.message);
            }

            // Apply default group selection to filterFlags + push counts now that
            // _groupPanel exists.  updateDots() may have run earlier (before the panel
            // was created) and short-circuited inside _updateGroupCounts because
            // _groupPanel was still null; refresh here so the buttons start with the
            // correct numbers (in particular Untrackable, whose set is static).
            _applyGroupFilter();
            _updateGroupCounts();

            _resetButtonPatched = true;
            _logger.log(_modName, "AchievementPanelPatcher: group panel injected");
            return true;
        }

        // -----------------------------------------------------------------------

        /**
         * Called when the group panel selection changes.
         * Recomputes filterFlags (OR union of selected groups) and refreshes the panel.
         */
        private function _onGroupToggle():void {
            _refreshFiltered();
        }

        /**
         * Called when the search query changes.  Same refresh path as the group toggle —
         * the search query is consumed inside _applyGroupFilter().
         */
        private function _onSearchChange():void {
            _refreshFiltered();
        }

        /**
         * Re-apply the combined filter (groups AND search) and refresh the panel.
         */
        private function _refreshFiltered():void {
            _applyGroupFilter();

            // Keep the hidden BtnAchiFilter in sync (isSelected drives the game filter).
            // Stay "selected" while either a group or a search query is active.
            if (_ourFilterButton != null) {
                var hasGroup:Boolean  = (_groupPanel != null && _groupPanel.selectedGroups != 0);
                var hasSearch:Boolean = (_searchField != null && _searchField.query.length > 0);
                var any:Boolean = hasGroup || hasSearch;
                _ourFilterButton.isSelected = any;
                try { _ourFilterButton.plate.gotoAndStop(any ? 3 : 1); } catch (e:Error) {}
            }

            try {
                var panel:PnlAchievements = GV.selectorCore != null
                    ? GV.selectorCore.pnlAchievements : null;
                if (panel != null) {
                    panel.showAchiList();
                    _applyLogicDots();
                }
            } catch (e2:Error) {
                _logger.log(_modName, "_refreshFiltered error: " + e2.message);
            }
        }

        /**
         * Write filterFlags[_ourFilterIndex] for every achievement based on the
         * group panel's current selection (OR logic across selected groups).
         * If no groups are selected, all achievements pass (show everything).
         */
        private function _applyGroupFilter():void {
            if (!_patched || _ourFilterIndex < 0) return;
            if (GV.achiCollection == null) return;

            var sel:uint = (_groupPanel != null) ? _groupPanel.selectedGroups : 0;
            var q:String = (_searchField != null) ? _searchField.query : "";
            var achis:Array = GV.achiCollection.achisByOrder;
            if (achis == null) return;

            try {
                for (var i:int = 0; i < achis.length; i++) {
                    var ach:* = achis[i];
                    if (ach == null) continue;

                    var rawApId:* = _gameIdToApId[int(ach.id)];
                    var passes:Boolean = (sel == 0); // nothing selected → show all

                    if (rawApId != null && sel != 0) {
                        var apId:int = int(rawApId);
                        var isEarned:Boolean = (int(ach.status) >= 2);
                        if (_excludedApIds[apId] === true) {
                            passes = (sel & AchievementGroupPanel.GROUP_DESIGN) != 0;
                        } else if (_effortExcludedApIds[apId] === true) {
                            passes = (sel & AchievementGroupPanel.GROUP_EFFORT) != 0;
                        } else if (!isEarned && _inLogicApIds[apId] === true) {
                            // Only unearned achievements belong in the In Logic group;
                            // earned-but-pending ones fall through to Out of Logic.
                            passes = (sel & AchievementGroupPanel.GROUP_IN_LOGIC) != 0;
                        } else {
                            passes = (sel & AchievementGroupPanel.GROUP_OUT_LOGIC) != 0;
                        }
                    }

                    if (passes && q.length > 0) {
                        var title:String = (ach.title != null) ? String(ach.title).toLowerCase() : "";
                        if (title.indexOf(q) < 0) passes = false;
                    }

                    while (ach.filterFlags.length <= _ourFilterIndex) ach.filterFlags.push(false);
                    ach.filterFlags[_ourFilterIndex] = passes;
                }
            } catch (e:Error) {
                _logger.log(_modName, "_applyGroupFilter error: " + e.message);
            }
        }

        /** Recompute per-group counts and push them to the group panel. */
        private function _updateGroupCounts():void {
            if (_groupPanel == null || GV.achiCollection == null) return;
            var achis:Array = GV.achiCollection.achisByOrder;
            if (achis == null) return;

            var g1:int = 0, g2:int = 0, g3:int = 0, g4:int = 0;
            for (var i:int = 0; i < achis.length; i++) {
                var ach:* = achis[i];
                if (ach == null) continue;
                // Earned achievements (status >= 2) are hidden by the game panel when any
                // filter is active — exclude them from all group counts so the button
                // label matches what is actually visible in the window.
                if (int(ach.status) >= 2) continue;
                var rawApId:* = _gameIdToApId[int(ach.id)];
                if (rawApId == null) continue;
                var apId:int = int(rawApId);
                if (_excludedApIds[apId] === true)       { g4++; }
                else if (_effortExcludedApIds[apId] === true) { g3++; }
                else if (_inLogicApIds[apId] === true)   { g1++; }
                else                                     { g2++; }
            }
            _groupPanel.setCounts(g1, g2, g3, g4);
        }

        // -----------------------------------------------------------------------
        // Data update API (called from ArchipelagoMod on connect / item received)

        /**
         * Ensure every achievement's filterFlags array is long enough for our index.
         * Must be called before the first showAchiList() — the game crashes (#1010)
         * if filterFlags[_ourFilterIndex] is out of bounds.
         */
        public function updateLogicFlags(inLogicApIds:Object):void {
            _inLogicApIds = inLogicApIds || {};
            // Push the same set to the per-achievement tooltip so its
            // "In logic" / "Out of logic" line agrees with the dots and the
            // panel's group counts.
            if (_tooltipOverlay != null) _tooltipOverlay.inLogicApIds = _inLogicApIds;
            if (!_patched || _ourFilterIndex < 0) return;
            if (GV.achiCollection == null || GV.achiCollection.achisByOrder == null) return;
            try {
                var achis:Array = GV.achiCollection.achisByOrder;
                for (var i:int = 0; i < achis.length; i++) {
                    var ach:* = achis[i];
                    if (ach == null) continue;
                    while (ach.filterFlags.length <= _ourFilterIndex) ach.filterFlags.push(false);
                }
            } catch (e:Error) {
                _logger.log(_modName, "ERROR in updateLogicFlags: " + e.message);
            }
        }

        public function updateExcluded(excludedApIds:Object):void {
            _excludedApIds = excludedApIds || {};
            _dotsDirty     = true;
            if (_tooltipOverlay != null) _tooltipOverlay.excludedApIds = _excludedApIds;
        }

        public function updateEffortExcluded(effortExcludedApIds:Object, maxEffortLabel:String):void {
            _effortExcludedApIds = effortExcludedApIds || {};
            _maxEffortLabel      = maxEffortLabel || "Trivial";
            _dotsDirty           = true;
            if (_tooltipOverlay != null) {
                _tooltipOverlay.effortExcludedApIds = _effortExcludedApIds;
                _tooltipOverlay.maxEffortLabel      = _maxEffortLabel;
            }
        }

        /**
         * Called last in the update sequence (after updateExcluded / updateEffortExcluded /
         * updateLogicFlags).  Stores the requirements-met set, re-sorts the panel, and
         * refreshes the group filter + counts.
         */
        public function updateDots(reqMetApIds:Object):void {
            _reqMetApIds = reqMetApIds || {};
            _dotsDirty   = true;
            _applySortedOrder();
            _applyGroupFilter();
            _updateGroupCounts();
        }

        /**
         * If the achievement panel is currently on screen, refresh its display.
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

        /**
         * Call every selector frame.  Keeps the hidden filter button invisible,
         * drives the tooltip overlay, and applies dots on a throttled schedule.
         */
        public function onSelectorFrame(panel:PnlAchievements):void {
            if (!_patched || panel == null) return;

            // Ensure the hidden slot button never becomes visible
            if (_ourFilterButton != null) _ourFilterButton.visible = false;

            // The game's showAchiList() re-shows btnResetAchievements; keep it hidden
            if (_resetButtonPatched) {
                try {
                    var resetBtn:* = panel.mc.btnResetAchievements;
                    if (resetBtn != null && resetBtn.visible) resetBtn.visible = false;
                } catch (eReset:Error) {}
            }

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

            _dotFrame  = 0;
            _dotsDirty = false;
            _applyLogicDots();
        }

        // -----------------------------------------------------------------------

        /**
         * Call every in-game frame while currentScreen == INGAME. Mirrors
         * onSelectorFrame() for the case where the player opens the achievement
         * panel mid-gameplay (vanilla IngameInputHandler2.openAchievementsPanel
         * re-parents pnlAchievements.mc under cntOutcomePanel and drives it via
         * IngameStatus.ACHIEVEMENTS_PANEL_*, not selectorCore.screenStatus).
         */
        public function onIngameFrame():void {
            if (!_patched) return;
            if (GV.ingameCore == null || GV.selectorCore == null) return;
            var panel:PnlAchievements = GV.selectorCore.pnlAchievements;
            if (panel == null) return;

            try {
                var status:int = int(GV.ingameCore.ingameStatus);
                var panelActive:Boolean =
                    status == IngameStatus.ACHIEVEMENTS_PANEL_APPEARING ||
                    status == IngameStatus.ACHIEVEMENTS_PANEL_SHOWING   ||
                    status == IngameStatus.ACHIEVEMENTS_PANEL_DISAPPEARING;

                if (panelActive) {
                    if (!_lastIngameAchPanelActive) {
                        // Rising edge: vanilla resetFilters() cleared our filter
                        // slot — reapply group/search filter, then force a list
                        // refresh + dots so the user sees them immediately.
                        _applyGroupFilter();
                        try {
                            panel.showAchiList();
                            _applyLogicDots();
                        } catch (eOpen:Error) {
                            _logger.log(_modName,
                                "AchievementPanelPatcher.onIngameFrame open error: " + eOpen.message);
                        }
                        _dotFrame  = 0;
                        _dotsDirty = false;
                    } else {
                        if (_tooltipOverlay != null) _tooltipOverlay.onSelectorFrame(panel);

                        _dotFrame++;
                        if (_dotsDirty || _dotFrame >= DOT_INTERVAL) {
                            _dotFrame  = 0;
                            _dotsDirty = false;
                            _applyLogicDots();
                        }
                    }
                }

                _lastIngameAchPanelActive = panelActive;
            } catch (e:Error) {
                _logger.log(_modName,
                    "AchievementPanelPatcher.onIngameFrame error: " + e.message);
                _lastIngameAchPanelActive = false;
            }
        }

        // -----------------------------------------------------------------------

        /**
         * Permanently reorder achisByOrder into 4 groups so the panel always shows:
         * in-logic (green) → out-of-logic (red) → effort-filler → always-filler.
         * Relative order within each group is preserved.
         */
        private function _applySortedOrder():void {
            if (GV.achiCollection == null || GV.achiCollection.achisByOrder == null) return;
            var achis:Array = GV.achiCollection.achisByOrder;

            var g1:Array = [], g2:Array = [], g3:Array = [], g4:Array = [], g5:Array = [], gRest:Array = [];

            for (var i:int = 0; i < achis.length; i++) {
                var ach:* = achis[i];
                if (ach == null) { gRest.push(ach); continue; }
                var rawApId:* = _gameIdToApId[int(ach.id)];
                if (rawApId == null) { gRest.push(ach); continue; }
                var apId:int = int(rawApId);
                if (_excludedApIds[apId] === true)
                    g5.push(ach);
                else if (_effortExcludedApIds[apId] === true)                 
                    g4.push(ach);
                else if (int(ach.status) < 2 && _inLogicApIds[apId] === true) 
                    g1.push(ach);
                else if (int(ach.status) >= 2)
                    g2.push(ach);
                else                                                          
                    g3.push(ach);
            }

            GV.achiCollection.achisByOrder = g1.sortOn("title").concat(g2.sortOn("title"), g3.sortOn("title"), g4.sortOn("title"), g5.sortOn("title"), gRest.sortOn("title"));
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
                if (apId == null) continue;

                var mcAchi:* = _getAchMcAchi(ach);
                if (mcAchi == null) { noMc++; continue; }

                try { if (mcAchi.parent == null) continue; } catch (e:Error) { continue; }

                var apIdInt:int      = int(apId);
                var excluded:Boolean = (_excludedApIds[apIdInt] === true || _effortExcludedApIds[apIdInt] === true);
                // Match the button label and the panel's "In Logic" group count:
                // an achievement is "in logic" iff it is uncollected on AP AND its
                // requirements are currently met. _reqMetApIds (requirements only,
                // ignores AP-collected status) caused green dots to appear on
                // achievements the AP server already considered checked.
                var inLogic:Boolean  = (!excluded && _inLogicApIds[apIdInt] === true);
                var isEarned:Boolean = (int(ach.status) >= 2);

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
                _logger.log(_modName, "applyLogicDots: no McAchi found. noMc=" + noMc);
            }
        }

        private function _getAchMcAchi(ach:*):* {
            try {
                if (ach.hasOwnProperty("mc")    && ach["mc"]    != null) return ach["mc"];
                if (ach.hasOwnProperty("mcAchi") && ach["mcAchi"] != null) return ach["mcAchi"];
                if (ach.hasOwnProperty("icon")   && ach["icon"]  != null) return ach["icon"];
            } catch (e:Error) {}
            return null;
        }

        private function _updateDot(mcAchi:*, inLogic:Boolean, excluded:Boolean = false):void {
            try {
                var existing:* = mcAchi.getChildByName(DOT_NAME);
                if (existing != null) mcAchi.removeChild(existing);
            } catch (e:Error) {}

            var dot:Shape = new Shape();
            dot.name = DOT_NAME;
            var fillColor:uint = excluded ? 0x888888 : (inLogic ? 0x44FF44 : 0xFF4444);
            dot.graphics.lineStyle(1, 0x000000, 0.6);
            dot.graphics.beginFill(fillColor, 0.9);
            dot.graphics.drawCircle(0, 0, DOT_RADIUS);
            dot.graphics.endFill();

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

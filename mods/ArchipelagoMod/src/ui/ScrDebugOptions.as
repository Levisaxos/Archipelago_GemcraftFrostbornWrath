package ui {
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.mcDyn.McOptPanel;
    import data.AV;
    import flash.events.MouseEvent;

    /**
     * Manages the tabbed Debug Options panel lifecycle and interaction.
     *
     * Wraps McDebugOptions (which uses the game's McOptions chrome).
     * Scroll / drag / viewport logic is handled by ScrollablePanel; tab
     * navigation by DebugTabStrip; per-tab click handlers live here.
     */
    public class ScrDebugOptions {

        // NOTE: every panel/tab listener below is registered with
        // useWeakReference = FALSE (strong). These handlers are anonymous
        // closures returned by _make*Handler() and are stored nowhere else, so
        // a weak registration let the GC reclaim them mid-session — the menu
        // stayed on screen but silently stopped responding to clicks. The
        // panels are dropped wholesale in dispose(), so strong refs don't leak
        // across AP sessions. See [[project_mod_structure]].

        private var _mod:ArchipelagoMod;
        private var _mc:McDebugOptions;
        private var _scroll:ScrollablePanel;
        private var _isOpen:Boolean = false;
        private var _wiredStageModes:Object = {}; // mode -> true once wired
        // Achievements tab view mode: false = still-missing checks only,
        // true = every non-excluded achievement not yet earned in-game.
        private var _showUnearnedAchievements:Boolean = false;

        public function get isOpen():Boolean { return _isOpen; }

        public function ScrDebugOptions(mod:ArchipelagoMod) {
            _mod    = mod;
            _scroll = new ScrollablePanel();
        }

        private function _initPanel():void {
            _mc = new McDebugOptions();
            _scroll.attach(_mc, close);

            // Level preset toggles (radio: clicking one sets the level exactly)
            for (var k:int = 0; k < _mc.levelPanels.length; k++) {
                var lentry:Object = _mc.levelPanels[k];
                var lpnl:McOptPanel = McOptPanel(lentry.panel);
                lpnl.addEventListener(      MouseEvent.CLICK,      _makeLevelClickHandler(int(lentry.level)), false, 0, false);
                lpnl.plate.addEventListener(MouseEvent.MOUSE_OVER, _scroll.ehBtnMouseOver, false, 0, false);
                lpnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  _scroll.ehBtnMouseOut,  false, 0, false);
            }

            // Skills tab
            for (var i:int = 0; i < _mc.skillPanels.length; i++) {
                var spnl:McOptPanel = McOptPanel(_mc.skillPanels[i]);
                spnl.addEventListener(      MouseEvent.CLICK,      _makeSkillClickHandler(i), false, 0, false);
                spnl.plate.addEventListener(MouseEvent.MOUSE_OVER, _scroll.ehBtnMouseOver,     false, 0, false);
                spnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  _scroll.ehBtnMouseOut,      false, 0, false);
            }

            // Traits tab
            for (var j:int = 0; j < _mc.traitPanels.length; j++) {
                var tpnl:McOptPanel = McOptPanel(_mc.traitPanels[j]);
                tpnl.addEventListener(      MouseEvent.CLICK,      _makeTraitClickHandler(j), false, 0, false);
                tpnl.plate.addEventListener(MouseEvent.MOUSE_OVER, _scroll.ehBtnMouseOver,     false, 0, false);
                tpnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  _scroll.ehBtnMouseOut,      false, 0, false);
            }

            // Talisman / core / xp grant panels
            _wireGrantPanels(_mc.talismanPanels, _onTalismanClick);
            _wireGrantPanels(_mc.corePanels,     _onCoreClick);
            _wireGrantPanels(_mc.xpPanels,       _onXpTomeClick);

            // Initial stage mode wiring (per-stage panels exist by default)
            _wireStageModeHandlers(_mc.stageMode);

            // Tab strip → swap content + refresh scroll
            _mc.tabStrip.onSelect = _onTabSelect;
        }

        private function _wireGrantPanels(arr:Array, onClick:Function):void {
            if (arr == null) return;
            for (var i:int = 0; i < arr.length; i++) {
                var entry:Object = arr[i];
                var pnl:McOptPanel = McOptPanel(entry.panel);
                var apId:int = int(entry.apId);
                pnl.addEventListener(MouseEvent.CLICK, _makeGrantHandler(onClick, apId), false, 0, false);
                pnl.plate.addEventListener(MouseEvent.MOUSE_OVER, _scroll.ehBtnMouseOver, false, 0, false);
                pnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  _scroll.ehBtnMouseOut,  false, 0, false);
            }
        }

        /**
         * Wire click + hover handlers for the Achievements tab. Unlike the grant
         * panels (built once in the constructor), achievement panels are rebuilt
         * on every open() from the current pool, so this must run after each
         * rebuildAchievementsContents() to bind the fresh panel instances.
         */
        private function _wireAchievementPanels():void {
            var arr:Array = _mc.achievementPanels;
            if (arr == null) return;
            for (var i:int = 0; i < arr.length; i++) {
                var entry:Object = arr[i];
                var pnl:McOptPanel = McOptPanel(entry.panel);
                var apId:int = int(entry.apId);
                pnl.addEventListener(MouseEvent.CLICK, _makeAchievementHandler(apId), false, 0, false);
                pnl.plate.addEventListener(MouseEvent.MOUSE_OVER, _scroll.ehBtnMouseOver, false, 0, false);
                pnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  _scroll.ehBtnMouseOut,  false, 0, false);
            }
        }

        /**
         * Rebuild the Achievements tab from the current view mode + (re)wire the
         * fresh panels and the view-mode toggle button. Called on open() and
         * whenever the toggle flips.
         */
        private function _rebuildAchievementsTab():void {
            var pool:Array = _showUnearnedAchievements
                ? _mod.getUnearnedAchievementPool()
                : _mod.getDebugAchievementPool();
            _mc.rebuildAchievementsContents(pool, _showUnearnedAchievements);
            _wireAchievementPanels();

            // Wire the freshly-built view-mode toggle button.
            if (_mc.achievementModeBtn != null) {
                _mc.achievementModeBtn.addEventListener(MouseEvent.CLICK, _onAchievementModeToggle, false, 0, false);
                _mc.achievementModeBtn.plate.addEventListener(MouseEvent.MOUSE_OVER, _scroll.ehBtnMouseOver, false, 0, false);
                _mc.achievementModeBtn.plate.addEventListener(MouseEvent.MOUSE_OUT,  _scroll.ehBtnMouseOut,  false, 0, false);
            }
        }

        private function _onAchievementModeToggle(e:MouseEvent):void {
            _showUnearnedAchievements = !_showUnearnedAchievements;
            _rebuildAchievementsTab();
            _scroll.refreshContents();
            _scroll.renderViewport();
            _renderDebugOptions();
        }

        /**
         * Wire click + hover handlers for the Stages tab in its current mode.
         * Idempotent per mode — each mode's panels get wired exactly once.
         */
        private function _wireStageModeHandlers(mode:String):void {
            if (_wiredStageModes[mode]) return;
            _wiredStageModes[mode] = true;

            if (mode == "stage") {
                for (var stageId:String in _mc.stageIdToPanel) {
                    var sPnl:McOptPanel = McOptPanel(_mc.stageIdToPanel[stageId]);
                    sPnl.addEventListener(MouseEvent.CLICK, _makeStageClickHandler(stageId), false, 0, false);
                    sPnl.plate.addEventListener(MouseEvent.MOUSE_OVER, _scroll.ehBtnMouseOver, false, 0, false);
                    sPnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  _scroll.ehBtnMouseOut,  false, 0, false);
                }
            } else if (mode == "tile") {
                for (var letter:String in _mc.tilePanels) {
                    var tilePnl:McOptPanel = McOptPanel(_mc.tilePanels[letter]);
                    tilePnl.addEventListener(MouseEvent.CLICK, _makeTileClickHandler(letter), false, 0, false);
                    tilePnl.plate.addEventListener(MouseEvent.MOUSE_OVER, _scroll.ehBtnMouseOver, false, 0, false);
                    tilePnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  _scroll.ehBtnMouseOut,  false, 0, false);
                }
            } else if (mode == "tier") {
                for (var tierKey:String in _mc.tierPanels) {
                    var tier:int = int(tierKey);
                    var tierPnl:McOptPanel = McOptPanel(_mc.tierPanels[tierKey]);
                    tierPnl.addEventListener(MouseEvent.CLICK, _makeTierClickHandler(tier), false, 0, false);
                    tierPnl.plate.addEventListener(MouseEvent.MOUSE_OVER, _scroll.ehBtnMouseOver, false, 0, false);
                    tierPnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  _scroll.ehBtnMouseOut,  false, 0, false);
                }
            }
        }

        // -----------------------------------------------------------------------
        // Open / close

        public function open():void {
            if (_isOpen) return;
            var firstOpen:Boolean = (_mc == null);
            if (firstOpen) _initPanel();
            _isOpen = true;

            _mc.btnConfirmRetry.visible     = false;
            _mc.btnConfirmReturn.visible    = false;
            _mc.btnConfirmEndBattle.visible = false;
            _mc.btnEndBattle.visible        = false;
            _mc.btnReturn.visible           = false;
            _mc.btnRetry.visible            = false;
            _mc.btnMainMenu.visible         = false;
            _mc.btnClose.visible            = true;

            // Refresh stages content from current AV state (it may have changed
            // since the menu was built, e.g. AP connected after first open).
            if (!firstOpen) {
                _mc.rebuildStagesContents();
                _wiredStageModes = {};
            }

            // Decide stage mode from current AP options (defaults to per-stage).
            var desiredMode:String = _resolveStageMode();
            _mc.setStageMode(desiredMode);
            _wireStageModeHandlers(desiredMode);

            // Achievements tab — the trackable pool depends on AP state (missing
            // locations, server options), so rebuild every open and (re)wire the
            // fresh panels.
            _rebuildAchievementsTab();

            // Always land on the Disclaimer tab so the usage / cheating notice
            // is seen every time the menu is opened. setActive(..., true) fires
            // _onTabSelect, which swaps content + refreshes the scroll range.
            _mc.tabStrip.setActive(McDebugOptions.TAB_DISCLAIMER, true);

            GV.main.addChildAt(_mc, GV.main.numChildren);
            _scroll.addWheelListener();
            _scroll.refreshContents();
            _renderDebugOptions();
            _scroll.renderViewport();
        }

        public function close():void {
            if (!_isOpen) return;
            _isOpen = false;
            if (_mc != null && _mc.parent != null) _mc.parent.removeChild(_mc);
            _scroll.removeWheelListener();
        }

        /**
         * Drop the built panel so the next open() rebuilds it from scratch.
         * Called from ArchipelagoMod._deactivateApMode so the menu never carries
         * state (or a stale display list) across an AP → standalone → AP cycle —
         * a fresh build on the next activation is identical to a first-ever open.
         * See [[feedback_standalone_clean_slate]].
         */
        public function dispose():void {
            close();
            _mc = null;
            _wiredStageModes = {};
            _scroll = new ScrollablePanel();
        }

        // -----------------------------------------------------------------------
        // Per-frame update

        public function doEnterFrame():void {
            // Keep the panel on top of GV.main. Granting a received item (e.g. a
            // field token / stage unlock, when checking an achievement releases
            // an item for us) makes the game add selector content to GV.main
            // ABOVE this panel — added once at open() — which leaves it visible
            // but unclickable. Re-raising each frame makes it immune, mirroring
            // how the stage-level toasts / message log are kept on top.
            if (_mc != null && _mc.parent != null) {
                _mc.parent.setChildIndex(_mc, _mc.parent.numChildren - 1);
            }
            _scroll.doEnterFrame();
            _renderDebugOptions();
        }

        // -----------------------------------------------------------------------
        // Tab selection

        private function _onTabSelect(idx:int):void {
            if (_mc == null) return;
            _mc.showTab(idx);
            _scroll.refreshContents();
            _scroll.renderViewport();
        }

        // -----------------------------------------------------------------------
        // Stage mode resolution

        private function _resolveStageMode():String {
            var so:* = (AV.serverData != null) ? AV.serverData.serverOptions : null;
            if (so == null) return "stage";
            // fieldTokenGranularity:
            //   0/1 = per_stage(_progressive)
            //   2/3 = per_tile(_progressive)
            //   4/5 = per_tier(_progressive)
            var g:int = int(so.fieldTokenGranularity);
            if (g >= 4) return "tier";
            if (g >= 2) return "tile";
            return "stage";
        }

        // -----------------------------------------------------------------------
        // Click handlers

        private function _onLevelPresetClick(level:int):void {
            _mod.setDebugWizardLevel(level);
            _renderDebugOptions();
        }

        private function _onSkillClick(gameId:int):void {
            if (GV.ppd == null) return;
            if (GV.ppd.gainedSkillTomes[gameId]) {
                GV.ppd.gainedSkillTomes[gameId] = false;
                GV.ppd.setSkillLevel(gameId, -1);
            } else {
                _mod.unlockSkill(700 + gameId);
            }
            _renderDebugOptions();
        }

        private function _onTraitClick(gameId:int):void {
            if (GV.ppd == null) return;
            if (GV.ppd.gainedBattleTraits[gameId]) {
                GV.ppd.gainedBattleTraits[gameId] = false;
            } else {
                _mod.unlockBattleTrait(800 + gameId);
            }
            _renderDebugOptions();
        }

        private function _onStageClick(stageId:String):void {
            if (_mod.isStageUnlocked(stageId)) {
                _mod.lockStage(stageId);
            } else {
                _mod.unlockStage(stageId);
            }
            _renderDebugOptions();
        }

        private function _onTileClick(letter:String):void {
            var stages:Array = _mc.tilesByLetter[letter] as Array;
            if (stages == null) return;
            // If every stage in the tile is already unlocked, clicking locks them all;
            // otherwise unlock all.
            var allUnlocked:Boolean = true;
            for (var i:int = 0; i < stages.length; i++) {
                if (!_mod.isStageUnlocked(String(stages[i]))) { allUnlocked = false; break; }
            }
            for (var j:int = 0; j < stages.length; j++) {
                var sid:String = String(stages[j]);
                if (allUnlocked) _mod.lockStage(sid);
                else if (!_mod.isStageUnlocked(sid)) _mod.unlockStage(sid);
            }
            _renderDebugOptions();
        }

        private function _onTierClick(tier:int):void {
            var stages:Array = _mc.tiersToStages[tier] as Array;
            if (stages == null) return;
            var allUnlocked:Boolean = true;
            for (var i:int = 0; i < stages.length; i++) {
                if (!_mod.isStageUnlocked(String(stages[i]))) { allUnlocked = false; break; }
            }
            for (var j:int = 0; j < stages.length; j++) {
                var sid:String = String(stages[j]);
                if (allUnlocked) _mod.lockStage(sid);
                else if (!_mod.isStageUnlocked(sid)) _mod.unlockStage(sid);
            }
            _renderDebugOptions();
        }

        private function _onTalismanClick(apId:int):void {
            _mod.debugLog("[Debug] talisman click apId=" + apId);
            _mod.debugGrantItem(apId);
            _renderDebugOptions();
        }

        private function _onCoreClick(apId:int):void {
            _mod.debugLog("[Debug] shadow-core click apId=" + apId);
            _mod.debugGrantItem(apId);
            _renderDebugOptions();
        }

        private function _onXpTomeClick(apId:int):void {
            _mod.debugLog("[Debug] xp-tome click apId=" + apId);
            _mod.debugGrantItem(apId);
            _renderDebugOptions();
        }

        private function _onAchievementClick(apId:int):void {
            _mod.debugLog("[Debug] achievement check click apId=" + apId);
            _mod.debugSendAchievementCheck(apId);
            _renderDebugOptions();
        }

        // Closures
        private function _makeLevelClickHandler(level:int):Function {
            return function(e:MouseEvent):void { _onLevelPresetClick(level); };
        }
        private function _makeSkillClickHandler(gameId:int):Function {
            return function(e:MouseEvent):void { _onSkillClick(gameId); };
        }
        private function _makeTraitClickHandler(gameId:int):Function {
            return function(e:MouseEvent):void { _onTraitClick(gameId); };
        }
        private function _makeStageClickHandler(stageId:String):Function {
            return function(e:MouseEvent):void { _onStageClick(stageId); };
        }
        private function _makeTileClickHandler(letter:String):Function {
            return function(e:MouseEvent):void { _onTileClick(letter); };
        }
        private function _makeTierClickHandler(tier:int):Function {
            return function(e:MouseEvent):void { _onTierClick(tier); };
        }
        private function _makeGrantHandler(handler:Function, apId:int):Function {
            return function(e:MouseEvent):void { handler(apId); };
        }
        private function _makeAchievementHandler(apId:int):Function {
            return function(e:MouseEvent):void { _onAchievementClick(apId); };
        }

        // -----------------------------------------------------------------------
        // Render state — only the active tab's panels need state updates.

        private function _renderDebugOptions():void {
            if (GV.ppd == null || _mc == null) return;

            var active:int = (_mc.tabStrip != null) ? _mc.tabStrip.activeIndex : McDebugOptions.TAB_LEVELS;

            switch (active) {
                case McDebugOptions.TAB_LEVELS:
                    var lvlNow:int = _mod.getDisplayedWizardLevel();
                    if (_mc.levelTitle != null) {
                        _mc.levelTitle.tf.text = "Wizard Level: " + lvlNow;
                    }
                    // Radio display: only the toggle whose level matches the
                    // current level shows checked (frame 2). Off-preset levels
                    // (e.g. nudged by XP tomes) leave all unchecked.
                    for (var lp:int = 0; lp < _mc.levelPanels.length; lp++) {
                        var le:Object = _mc.levelPanels[lp];
                        McOptPanel(le.panel).btn.gotoAndStop(int(le.level) == lvlNow ? 2 : 1);
                    }
                    _renderGrantPanelsCollected(_mc.xpPanels);
                    break;

                case McDebugOptions.TAB_SKILLS:
                    for (var i:int = 0; i < _mc.skillPanels.length; i++) {
                        McOptPanel(_mc.skillPanels[i]).btn.gotoAndStop(GV.ppd.getSkillLevel(i) >= 0 ? 2 : 1);
                    }
                    break;

                case McDebugOptions.TAB_TRAITS:
                    for (var j:int = 0; j < _mc.traitPanels.length; j++) {
                        McOptPanel(_mc.traitPanels[j]).btn.gotoAndStop(GV.ppd.gainedBattleTraits[j] ? 2 : 1);
                    }
                    break;

                case McDebugOptions.TAB_STAGES:
                    if (_mc.stageMode == "stage") {
                        for (var stageId:String in _mc.stageIdToPanel) {
                            McOptPanel(_mc.stageIdToPanel[stageId]).btn.gotoAndStop(
                                _mod.isStageUnlocked(stageId) ? 2 : 1);
                        }
                    } else if (_mc.stageMode == "tile") {
                        for (var letter:String in _mc.tilePanels) {
                            McOptPanel(_mc.tilePanels[letter]).btn.gotoAndStop(
                                _allStagesUnlocked(_mc.tilesByLetter[letter] as Array) ? 2 : 1);
                        }
                    } else if (_mc.stageMode == "tier") {
                        for (var tierKey:String in _mc.tierPanels) {
                            McOptPanel(_mc.tierPanels[tierKey]).btn.gotoAndStop(
                                _allStagesUnlocked(_mc.tiersToStages[int(tierKey)] as Array) ? 2 : 1);
                        }
                    }
                    break;

                case McDebugOptions.TAB_TALISMANS:
                    _renderGrantPanelsCollected(_mc.talismanPanels);
                    break;

                case McDebugOptions.TAB_CORES:
                    _renderGrantPanelsCollected(_mc.corePanels);
                    break;

                case McDebugOptions.TAB_ACHIEVEMENTS:
                    _renderGrantPanelsCollected(_mc.achievementPanels);
                    break;

                default:
                    break;
            }
        }

        /** Mark grant panels as 'collected' (frame 2) for any apId already
         *  present in sessionData.collectedItems. */
        private function _renderGrantPanelsCollected(arr:Array):void {
            if (arr == null) return;
            for (var i:int = 0; i < arr.length; i++) {
                var entry:Object = arr[i];
                var pnl:McOptPanel = McOptPanel(entry.panel);
                var apId:int = int(entry.apId);
                pnl.btn.gotoAndStop(_mod.debugIsItemCollected(apId) ? 2 : 1);
            }
        }

        private function _allStagesUnlocked(stages:Array):Boolean {
            if (stages == null || stages.length == 0) return false;
            for (var i:int = 0; i < stages.length; i++) {
                if (!_mod.isStageUnlocked(String(stages[i]))) return false;
            }
            return true;
        }
    }
}

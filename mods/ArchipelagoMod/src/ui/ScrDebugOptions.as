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

        private var _mod:ArchipelagoMod;
        private var _mc:McDebugOptions;
        private var _scroll:ScrollablePanel;
        private var _isOpen:Boolean = false;
        private var _wiredStageModes:Object = {}; // mode -> true once wired

        public function get isOpen():Boolean { return _isOpen; }

        public function ScrDebugOptions(mod:ArchipelagoMod) {
            _mod    = mod;
            _scroll = new ScrollablePanel();
        }

        private function _initPanel():void {
            _mc = new McDebugOptions();
            _scroll.attach(_mc, close);

            // Wizard slider
            _mc.wizardSlider.onChange = _onWizardLevelChanged;

            // Skills tab
            for (var i:int = 0; i < _mc.skillPanels.length; i++) {
                var spnl:McOptPanel = McOptPanel(_mc.skillPanels[i]);
                spnl.addEventListener(      MouseEvent.CLICK,      _makeSkillClickHandler(i), false, 0, true);
                spnl.plate.addEventListener(MouseEvent.MOUSE_OVER, _scroll.ehBtnMouseOver,     false, 0, true);
                spnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  _scroll.ehBtnMouseOut,      false, 0, true);
            }

            // Traits tab
            for (var j:int = 0; j < _mc.traitPanels.length; j++) {
                var tpnl:McOptPanel = McOptPanel(_mc.traitPanels[j]);
                tpnl.addEventListener(      MouseEvent.CLICK,      _makeTraitClickHandler(j), false, 0, true);
                tpnl.plate.addEventListener(MouseEvent.MOUSE_OVER, _scroll.ehBtnMouseOver,     false, 0, true);
                tpnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  _scroll.ehBtnMouseOut,      false, 0, true);
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
                pnl.addEventListener(MouseEvent.CLICK, _makeGrantHandler(onClick, apId), false, 0, true);
                pnl.plate.addEventListener(MouseEvent.MOUSE_OVER, _scroll.ehBtnMouseOver, false, 0, true);
                pnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  _scroll.ehBtnMouseOut,  false, 0, true);
            }
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
                    sPnl.addEventListener(MouseEvent.CLICK, _makeStageClickHandler(stageId), false, 0, true);
                    sPnl.plate.addEventListener(MouseEvent.MOUSE_OVER, _scroll.ehBtnMouseOver, false, 0, true);
                    sPnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  _scroll.ehBtnMouseOut,  false, 0, true);
                }
            } else if (mode == "tile") {
                for (var letter:String in _mc.tilePanels) {
                    var tilePnl:McOptPanel = McOptPanel(_mc.tilePanels[letter]);
                    tilePnl.addEventListener(MouseEvent.CLICK, _makeTileClickHandler(letter), false, 0, true);
                    tilePnl.plate.addEventListener(MouseEvent.MOUSE_OVER, _scroll.ehBtnMouseOver, false, 0, true);
                    tilePnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  _scroll.ehBtnMouseOut,  false, 0, true);
                }
            } else if (mode == "tier") {
                for (var tierKey:String in _mc.tierPanels) {
                    var tier:int = int(tierKey);
                    var tierPnl:McOptPanel = McOptPanel(_mc.tierPanels[tierKey]);
                    tierPnl.addEventListener(MouseEvent.CLICK, _makeTierClickHandler(tier), false, 0, true);
                    tierPnl.plate.addEventListener(MouseEvent.MOUSE_OVER, _scroll.ehBtnMouseOver, false, 0, true);
                    tierPnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  _scroll.ehBtnMouseOut,  false, 0, true);
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

        // -----------------------------------------------------------------------
        // Per-frame update

        public function doEnterFrame():void {
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

        private function _onWizardLevelChanged(level:int):void {
            _mod.setDebugWizardLevel(level);
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

        // Closures
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

        // -----------------------------------------------------------------------
        // Render state — only the active tab's panels need state updates.

        private function _renderDebugOptions():void {
            if (GV.ppd == null || _mc == null) return;

            var active:int = (_mc.tabStrip != null) ? _mc.tabStrip.activeIndex : McDebugOptions.TAB_LEVELS;

            switch (active) {
                case McDebugOptions.TAB_LEVELS:
                    if (!_mc.wizardSlider.isDragging) {
                        _mc.wizardSlider.setValue(_mod.getDisplayedWizardLevel());
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

package ui {
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.mcDyn.McOptPanel;
    import flash.events.MouseEvent;

    /**
     * Manages the Debug Options panel lifecycle and interaction.
     *
     * Wraps McDebugOptions (which uses the game's McOptions chrome).
     * Scroll / drag / viewport logic is handled by the ScrollablePanel helper.
     * Panel-specific handlers cover skill, battle-trait, and stage toggles.
     */
    public class ScrDebugOptions {

        private var _mod:ArchipelagoMod;
        private var _mc:McDebugOptions;
        private var _scroll:ScrollablePanel;
        private var _isOpen:Boolean = false;

        public function get isOpen():Boolean { return _isOpen; }

        public function ScrDebugOptions(mod:ArchipelagoMod) {
            _mod    = mod;
            _scroll = new ScrollablePanel();
            // _mc is created lazily on first open() — McOptions is not yet registered
            // in the application domain when the mod first loads on a cold start.
        }

        private function _initPanel():void {
            _mc = new McDebugOptions();
            _scroll.attach(_mc, close);

            // Wizard level slider
            _mc.wizardSlider.onChange = _onWizardLevelChanged;

            // Skill panel click + hover
            for (var i:int = 0; i < _mc.skillPanels.length; i++) {
                var spnl:McOptPanel = McOptPanel(_mc.skillPanels[i]);
                spnl.addEventListener(      MouseEvent.CLICK,      _makeSkillClickHandler(i), false, 0, true);
                spnl.plate.addEventListener(MouseEvent.MOUSE_OVER, _scroll.ehBtnMouseOver,     false, 0, true);
                spnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  _scroll.ehBtnMouseOut,      false, 0, true);
            }

            // Battle trait panel click + hover
            for (var j:int = 0; j < _mc.traitPanels.length; j++) {
                var tpnl:McOptPanel = McOptPanel(_mc.traitPanels[j]);
                tpnl.addEventListener(      MouseEvent.CLICK,      _makeTraitClickHandler(j), false, 0, true);
                tpnl.plate.addEventListener(MouseEvent.MOUSE_OVER, _scroll.ehBtnMouseOver,     false, 0, true);
                tpnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  _scroll.ehBtnMouseOut,      false, 0, true);
            }

            // Stage panel click + hover
            for (var stageId:String in _mc.stageIdToPanel) {
                var stagePnl:McOptPanel = McOptPanel(_mc.stageIdToPanel[stageId]);
                stagePnl.addEventListener(      MouseEvent.CLICK,      _makeStageClickHandler(stageId), false, 0, true);
                stagePnl.plate.addEventListener(MouseEvent.MOUSE_OVER, _scroll.ehBtnMouseOver,            false, 0, true);
                stagePnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  _scroll.ehBtnMouseOut,             false, 0, true);
            }
        }

        // -----------------------------------------------------------------------
        // Open / close

        public function open():void {
            if (_isOpen) return;
            if (_mc == null) _initPanel();
            _isOpen = true;

            _mc.btnConfirmRetry.visible     = false;
            _mc.btnConfirmReturn.visible    = false;
            _mc.btnConfirmEndBattle.visible = false;
            _mc.btnEndBattle.visible        = false;
            _mc.btnReturn.visible           = false;
            _mc.btnRetry.visible            = false;
            _mc.btnMainMenu.visible         = false;
            _mc.btnClose.visible            = true;

            GV.main.addChildAt(_mc, GV.main.numChildren);
            _scroll.addWheelListener();
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
        // Per-frame update — call from ArchipelagoMod.onEnterFrame while isOpen.

        public function doEnterFrame():void {
            _scroll.doEnterFrame();
            _renderDebugOptions();
        }

        // -----------------------------------------------------------------------
        // Panel-specific click handlers

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

        // Closures to capture the panel index / id.
        private function _makeSkillClickHandler(gameId:int):Function {
            return function(e:MouseEvent):void { _onSkillClick(gameId); };
        }

        private function _makeTraitClickHandler(gameId:int):Function {
            return function(e:MouseEvent):void { _onTraitClick(gameId); };
        }

        private function _makeStageClickHandler(stageId:String):Function {
            return function(e:MouseEvent):void { _onStageClick(stageId); };
        }

        // -----------------------------------------------------------------------
        // Render state

        private function _renderDebugOptions():void {
            if (GV.ppd == null) return;

            if (!_mc.wizardSlider.isDragging) {
                _mc.wizardSlider.setValue(_mod.getDisplayedWizardLevel());
            }
            for (var i:int = 0; i < _mc.skillPanels.length; i++) {
                McOptPanel(_mc.skillPanels[i]).btn.gotoAndStop(GV.ppd.getSkillLevel(i) >= 0 ? 2 : 1);
            }
            for (var j:int = 0; j < _mc.traitPanels.length; j++) {
                McOptPanel(_mc.traitPanels[j]).btn.gotoAndStop(GV.ppd.gainedBattleTraits[j] ? 2 : 1);
            }
            for (var stageId:String in _mc.stageIdToPanel) {
                McOptPanel(_mc.stageIdToPanel[stageId]).btn.gotoAndStop(
                    _mod.isStageUnlocked(stageId) ? 2 : 1
                );
            }
        }
    }
}

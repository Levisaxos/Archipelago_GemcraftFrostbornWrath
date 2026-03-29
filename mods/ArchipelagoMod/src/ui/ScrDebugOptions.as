package ui {
    import com.giab.common.utils.MathToolbox;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.mcDyn.McOptPanel;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import ui.McDebugOptions;

    /**
     * Manages the Debug Options panel lifecycle and interaction.
     * Mirrors ScrOptions in scroll / drag / viewport / wheel logic.
     * Replaces the boolean option toggles with skill, battle trait, and stage lock/unlock.
     */
    public class ScrDebugOptions {

        private var _mod:ArchipelagoMod;
        private var _mc:McDebugOptions;

        private var _isOpen:Boolean = false;

        // Scroll / drag state -- identical to ScrOptions.
        private var _isDragging:Boolean;
        private var _isVpDragging:Boolean;
        private var _draggedKnob:MovieClip;
        private var _vpY:Number;
        private var _vpYMin:Number;
        private var _vpYMax:Number;

        // Overall panel scale -- scales the entire dialog down so it fits on screen.
        // 1.0 = native size of symbol3117 added to stage (not GV.main).
        private static const PANEL_SCALE:Number = 1.0;

        // Viewport / scroll constants -- tweak these if the scroll range or clipping feels wrong.
        private static const VIEWPORT_HEIGHT:Number  = 735; // Visible height of the scroll area; used to compute max scroll
        private static const CLIP_TOP:Number         = 50;  // Items above this Y are hidden (top of the visible region)
        private static const CLIP_BOTTOM:Number      = 920; // Items below this Y are hidden (bottom of the visible region)
        private static const KNOB_Y_MIN:Number       = 127; // Scroll knob top travel limit
        private static const KNOB_Y_MAX:Number       = 851; // Scroll knob bottom travel limit
        private static const SCROLL_STEP:Number      = 30;  // Pixels scrolled per mouse-wheel tick
        private static const KNOB_DRAG_OFFSET:Number = 18;  // Centres the grab point on the knob

        public function get isOpen():Boolean { return _isOpen; }

        public function ScrDebugOptions(mod:ArchipelagoMod) {
            _mod = mod;
            // _mc is created lazily on first open() -- McOptions is not yet registered
            // in the application domain when the mod first loads on a cold start.
        }

        private function initPanel():void {
            var i:int = 0;
            _mc = new McDebugOptions();

            _mc.scaleX = PANEL_SCALE;
            _mc.scaleY = PANEL_SCALE;

            _vpYMin = 0;
            _vpYMax = 0;
            _vpY    = 0;

            for (i = 0; i < _mc.arrCntContents.length; i++) {
                _vpYMax = Math.max(_vpYMax, _mc.arrCntContents[i].yReal - VIEWPORT_HEIGHT);
            }

            buttonsInit();
        }

        // -----------------------------------------------------------------------
        // Open / close

        public function open():void {
            if (_isOpen) return;
            if (_mc == null) initPanel();
            _isOpen = true;

            // Hide all navigation buttons -- this is a debug-only panel on the selector screen.
            _mc.btnConfirmRetry.visible    = false;
            _mc.btnConfirmReturn.visible   = false;
            _mc.btnConfirmEndBattle.visible = false;
            _mc.btnEndBattle.visible       = false;
            _mc.btnReturn.visible          = false;
            _mc.btnRetry.visible           = false;
            _mc.btnMainMenu.visible        = false;
            _mc.btnClose.visible           = true;

            GV.main.addChildAt(_mc, GV.main.numChildren);
            addWheelListener();
            renderDebugOptions();
            renderViewport();
        }

        public function close():void {
            if (!_isOpen) return;
            _isOpen = false;
            if (_mc != null && _mc.parent != null) _mc.parent.removeChild(_mc);
            removeWheelListener();
        }

        // -----------------------------------------------------------------------
        // Button wiring -- mirrors ScrOptions.buttonsInit() for the common buttons.

        private function buttonsInit():void {
            var i:int = 0;

            // Close button
            _mc.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, ehBtnDown,       true, 0, true);
            _mc.btnClose.addEventListener(MouseEvent.MOUSE_UP,   ehBtnCloseClick, true, 0, true);
            _mc.btnClose.addEventListener(MouseEvent.MOUSE_OVER, ehBtnMouseOver,  true, 0, true);
            _mc.btnClose.addEventListener(MouseEvent.MOUSE_OUT,  ehBtnMouseOut,   true, 0, true);
            _mc.btnClose.tf.mouseEnabled = false;

            // Scroll
            _mc.mcScrollBar.addEventListener(MouseEvent.MOUSE_DOWN, ehScrollKnobDown, true, 0, true);
            _mc.btnScrollKnob.addEventListener(MouseEvent.MOUSE_DOWN, ehScrollKnobDown, true, 0, true);

            // Skill panel click + hover.
            // CLICK goes on spnl (the McOptPanel container) not spnl.plate because
            // plate.mouseEnabled is false in the FLA symbol, so MOUSE_DOWN never
            // lands on plate and CLICK is never synthesised there.
            // MOUSE_OVER/OUT still work on plate (Flash dispatches them regardless
            // of mouseEnabled for rollover-tracking purposes).
            for (i = 0; i < _mc.skillPanels.length; i++) {
                var spnl:McOptPanel = McOptPanel(_mc.skillPanels[i]);
                spnl.addEventListener(      MouseEvent.CLICK,      makeSkillClickHandler(i), false, 0, true);
                spnl.plate.addEventListener(MouseEvent.MOUSE_OVER, ehPanelMouseOver,          false, 0, true);
                spnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  ehPanelMouseOut,           false, 0, true);
            }

            // Battle trait panel click + hover
            for (i = 0; i < _mc.traitPanels.length; i++) {
                var tpnl:McOptPanel = McOptPanel(_mc.traitPanels[i]);
                tpnl.addEventListener(      MouseEvent.CLICK,      makeTraitClickHandler(i), false, 0, true);
                tpnl.plate.addEventListener(MouseEvent.MOUSE_OVER, ehPanelMouseOver,          false, 0, true);
                tpnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  ehPanelMouseOut,           false, 0, true);
            }

            // Stage panel click + hover -- same pattern, keyed by stageStrId.
            for (var stageId:String in _mc.stageIdToPanel) {
                var stagePnl:McOptPanel = McOptPanel(_mc.stageIdToPanel[stageId]);
                stagePnl.addEventListener(      MouseEvent.CLICK,      makeStageClickHandler(stageId), false, 0, true);
                stagePnl.plate.addEventListener(MouseEvent.MOUSE_OVER, ehPanelMouseOver,                false, 0, true);
                stagePnl.plate.addEventListener(MouseEvent.MOUSE_OUT,  ehPanelMouseOut,                 false, 0, true);
            }
        }

        // Closures to capture the panel index / id.
        private function makeSkillClickHandler(gameId:int):Function {
            return function(e:MouseEvent):void { onSkillClick(gameId); };
        }

        private function makeTraitClickHandler(gameId:int):Function {
            return function(e:MouseEvent):void { onTraitClick(gameId); };
        }

        private function makeStageClickHandler(stageId:String):Function {
            return function(e:MouseEvent):void { onStageClick(stageId); };
        }

        // -----------------------------------------------------------------------
        // Panel click logic

        private function onSkillClick(gameId:int):void {
            if (GV.ppd == null) return;
            if (GV.ppd.gainedSkillTomes[gameId]) {
                // Lock: clear the tome flag and reset level to -1 (the game's "locked" sentinel).
                GV.ppd.gainedSkillTomes[gameId] = false;
                GV.ppd.setSkillLevel(gameId, -1);
            } else {
                // Unlock via the existing mod function.
                _mod.unlockSkill(300 + gameId);
            }
            renderDebugOptions();
        }

        private function onTraitClick(gameId:int):void {
            if (GV.ppd == null) return;
            if (GV.ppd.gainedBattleTraits[gameId]) {
                // Lock: remove the trait flag.
                GV.ppd.gainedBattleTraits[gameId] = false;
            } else {
                // Unlock via the existing mod function.
                _mod.unlockBattleTrait(400 + gameId);
            }
            renderDebugOptions();
        }

        private function onStageClick(stageId:String):void {
            if (_mod.isStageUnlocked(stageId)) {
                _mod.lockStage(stageId);
            } else {
                _mod.unlockStage(stageId);
            }
            renderDebugOptions();
        }

        // -----------------------------------------------------------------------
        // Render state

        private function renderDebugOptions():void {
            var i:int = 0;
            if (GV.ppd == null) return;
            // A skill is considered active when its level is >= 0.
            // gainedSkillTomes only tracks tome collection; getSkillLevel >= 0
            // is what the game uses to consider a skill available.
            for (i = 0; i < _mc.skillPanels.length; i++) {
                McOptPanel(_mc.skillPanels[i]).btn.gotoAndStop(GV.ppd.getSkillLevel(i) >= 0 ? 2 : 1);
            }
            for (i = 0; i < _mc.traitPanels.length; i++) {
                McOptPanel(_mc.traitPanels[i]).btn.gotoAndStop(GV.ppd.gainedBattleTraits[i] ? 2 : 1);
            }
            for (var stageId:String in _mc.stageIdToPanel) {
                McOptPanel(_mc.stageIdToPanel[stageId]).btn.gotoAndStop(
                    _mod.isStageUnlocked(stageId) ? 2 : 1
                );
            }
        }

        // -----------------------------------------------------------------------
        // Button / hover handlers -- identical to ScrOptions equivalents.

        private function ehBtnCloseClick(e:MouseEvent):void {
            close();
        }

        private function ehBtnDown(e:MouseEvent):void {
            e.target.parent.plate.gotoAndStop(4);
            GV.pressedButton = e.target.parent;
        }

        private function ehBtnMouseOver(e:MouseEvent):void {
            if (GV.pressedButton == e.target.parent) {
                e.target.parent.plate.gotoAndStop(4);
            } else {
                e.target.parent.plate.gotoAndStop(2);
            }
        }

        private function ehBtnMouseOut(e:MouseEvent):void {
            e.target.parent.plate.gotoAndStop(1);
        }

        private function ehPanelMouseOver(e:MouseEvent):void {
            MovieClip(e.currentTarget.parent).plate.gotoAndStop(2);
        }

        private function ehPanelMouseOut(e:MouseEvent):void {
            MovieClip(e.currentTarget.parent).plate.gotoAndStop(1);
        }

        // -----------------------------------------------------------------------
        // Scroll / drag / viewport -- verbatim from ScrOptions.

        private function ehScrollKnobDown(e:Event):void {
            _draggedKnob = _mc.btnScrollKnob;
            _mc.btnScrollKnob.gotoAndStop(2);
            GV.main.stage.addEventListener(MouseEvent.MOUSE_UP, ehScrollKnobUp, true, 0, true);
            _isVpDragging = true;
        }

        private function ehScrollKnobUp(e:Event):void {
            GV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, ehScrollKnobUp, true);
            _isDragging = false;
            if (_draggedKnob != null) {
                _draggedKnob.gotoAndStop(1);
                _draggedKnob = null;
            }
            _isVpDragging = false;
        }

        private function ehWheel(e:Event):void {
            if (e is MouseEvent && MouseEvent(e).delta > 0 || e.type == GV.EVENT_SCROLL_UP) {
                _mc.btnScrollKnob.y = Math.min(KNOB_Y_MAX, Math.max(KNOB_Y_MIN, _mc.btnScrollKnob.y - SCROLL_STEP));
            } else {
                _mc.btnScrollKnob.y = Math.min(KNOB_Y_MAX, Math.max(KNOB_Y_MIN, _mc.btnScrollKnob.y + SCROLL_STEP));
            }
            _vpY = MathToolbox.convertCoord(KNOB_Y_MIN, KNOB_Y_MAX, _mc.btnScrollKnob.y, _vpYMin, _vpYMax);
            renderViewport();
        }

        private function addWheelListener():void {
            GV.main.stage.addEventListener(MouseEvent.MOUSE_WHEEL, ehWheel, true, 0, true);
            GV.main.stage.addEventListener(GV.EVENT_SCROLL_UP,     ehWheel, true, 0, true);
            GV.main.stage.addEventListener(GV.EVENT_SCROLL_DOWN,   ehWheel, true, 0, true);
        }

        private function removeWheelListener():void {
            GV.main.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, ehWheel, true);
            GV.main.stage.removeEventListener(GV.EVENT_SCROLL_UP,     ehWheel, true);
            GV.main.stage.removeEventListener(GV.EVENT_SCROLL_DOWN,   ehWheel, true);
        }

        public function doEnterFrame():void {
            if (_isVpDragging) {
                _mc.btnScrollKnob.y = Math.min(KNOB_Y_MAX, Math.max(KNOB_Y_MIN, GV.main.mouseY - KNOB_DRAG_OFFSET));
                _vpY = MathToolbox.convertCoord(KNOB_Y_MIN, KNOB_Y_MAX, _mc.btnScrollKnob.y, _vpYMin, _vpYMax);
                renderViewport();
            }
            renderDebugOptions();
        }

        private function renderViewport():void {
            var i:int = 0;
            for (i = 0; i < _mc.arrCntContents.length; i++) {
                _mc.arrCntContents[i].y       = _mc.arrCntContents[i].yReal - _vpY;
                _mc.arrCntContents[i].visible = _mc.arrCntContents[i].y > CLIP_TOP && _mc.arrCntContents[i].y < CLIP_BOTTOM;
            }
        }
    }
}

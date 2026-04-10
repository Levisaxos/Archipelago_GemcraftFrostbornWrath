package ui {
    import com.giab.common.utils.MathToolbox;
    import com.giab.games.gcfw.GV;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import net.ConnectionManager;
    import deathlink.DeathLinkHandler;

    /**
     * Manages the Slot Settings panel lifecycle.
     *
     * Mirrors the ScrDebugOptions pattern:
     *   - Wraps McSlotSettings (which uses the game's McOptions chrome).
     *   - Opens by adding to GV.main; closes by removing from parent.
     *   - Re-built on every configure() call so values are always fresh.
     *   - Full scroll/drag/wheel support identical to ScrDebugOptions.
     *
     * Usage:
     *   var scr:ScrSlotSettings = new ScrSlotSettings();
     *   // After AP connects:
     *   scr.configure(connectionManager, deathLinkHandler);
     *   // Button click:
     *   if (scr.isOpen) scr.close(); else scr.open();
     *   // In onEnterFrame:
     *   if (scr.isOpen) scr.doEnterFrame();
     */
    public class ScrSlotSettings {

        private var _mc:McSlotSettings;
        private var _isOpen:Boolean = false;

        // Scroll / drag state — identical to ScrDebugOptions / ScrOptions.
        private var _isDragging:Boolean;
        private var _isVpDragging:Boolean;
        private var _draggedKnob:MovieClip;
        private var _vpY:Number    = 0;
        private var _vpYMin:Number = 0;
        private var _vpYMax:Number = 0;

        // Viewport / scroll constants — match ScrDebugOptions.
        private static const VIEWPORT_HEIGHT:Number  = 735;
        private static const CLIP_TOP:Number         = 50;
        private static const CLIP_BOTTOM:Number      = 920;
        private static const KNOB_Y_MIN:Number       = 127;
        private static const KNOB_Y_MAX:Number       = 851;
        private static const SCROLL_STEP:Number      = 30;
        private static const KNOB_DRAG_OFFSET:Number = 18;

        public function get isOpen():Boolean { return _isOpen; }

        public function ScrSlotSettings() {
            // _mc created lazily in configure()
        }

        /**
         * Build (or rebuild) the panel from current slot data.
         * Call this after AP connects so the panel reflects the live values.
         */
        public function configure(cm:ConnectionManager, dl:DeathLinkHandler):void {
            if (_mc != null && _mc.parent != null) _mc.parent.removeChild(_mc);
            _isOpen = false;
            _mc = new McSlotSettings(cm, dl);

            // Compute scroll range from the tallest content item.
            _vpYMin = 0;
            _vpYMax = 0;
            _vpY    = 0;
            for (var i:int = 0; i < _mc.arrCntContents.length; i++) {
                _vpYMax = Math.max(_vpYMax, _mc.arrCntContents[i].yReal - VIEWPORT_HEIGHT);
            }

            buttonsInit();
        }

        // -----------------------------------------------------------------------
        // Open / close

        public function open():void {
            if (_isOpen || _mc == null) return;
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
            addWheelListener();
            renderViewport();
        }

        public function close():void {
            if (!_isOpen) return;
            _isOpen = false;
            if (_mc != null && _mc.parent != null) _mc.parent.removeChild(_mc);
            removeWheelListener();
        }

        // -----------------------------------------------------------------------
        // Per-frame update — call from ArchipelagoMod.onEnterFrame while isOpen.

        public function doEnterFrame():void {
            if (_isVpDragging) {
                _mc.btnScrollKnob.y = Math.min(KNOB_Y_MAX,
                    Math.max(KNOB_Y_MIN, GV.main.mouseY - KNOB_DRAG_OFFSET));
                _vpY = MathToolbox.convertCoord(
                    KNOB_Y_MIN, KNOB_Y_MAX, _mc.btnScrollKnob.y, _vpYMin, _vpYMax);
                renderViewport();
            }
        }

        // -----------------------------------------------------------------------
        // Viewport

        private function renderViewport():void {
            var items:Array = _mc.arrCntContents;
            for (var i:int = 0; i < items.length; i++) {
                var item:* = items[i];
                item.y       = item.yReal - _vpY;
                item.visible = item.y > CLIP_TOP && item.y < CLIP_BOTTOM;
            }
        }

        // -----------------------------------------------------------------------
        // Scroll / drag / wheel — verbatim from ScrDebugOptions.

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
                _mc.btnScrollKnob.y = Math.min(KNOB_Y_MAX,
                    Math.max(KNOB_Y_MIN, _mc.btnScrollKnob.y - SCROLL_STEP));
            } else {
                _mc.btnScrollKnob.y = Math.min(KNOB_Y_MAX,
                    Math.max(KNOB_Y_MIN, _mc.btnScrollKnob.y + SCROLL_STEP));
            }
            _vpY = MathToolbox.convertCoord(
                KNOB_Y_MIN, KNOB_Y_MAX, _mc.btnScrollKnob.y, _vpYMin, _vpYMax);
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

        // -----------------------------------------------------------------------
        // Button wiring

        private function buttonsInit():void {
            _mc.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, ehBtnDown,       true, 0, true);
            _mc.btnClose.addEventListener(MouseEvent.MOUSE_UP,   ehBtnCloseClick, true, 0, true);
            _mc.btnClose.addEventListener(MouseEvent.MOUSE_OVER, ehBtnMouseOver,  true, 0, true);
            _mc.btnClose.addEventListener(MouseEvent.MOUSE_OUT,  ehBtnMouseOut,   true, 0, true);
            _mc.btnClose.tf.mouseEnabled = false;

            _mc.mcScrollBar.addEventListener(MouseEvent.MOUSE_DOWN,   ehScrollKnobDown, true, 0, true);
            _mc.btnScrollKnob.addEventListener(MouseEvent.MOUSE_DOWN, ehScrollKnobDown, true, 0, true);
        }

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
    }
}

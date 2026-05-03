package ui {
    import com.giab.common.utils.MathToolbox;
    import com.giab.games.gcfw.GV;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;

    /**
     * Reusable scroll / drag / viewport helper used by ScrChangelog,
     * ScrDebugOptions, and ScrSlotSettings.
     *
     * Each panel holds one ScrollablePanel instance and delegates to it:
     *
     *   // After building / rebuilding _mc:
     *   _scroll.attach(_mc, close);   // computes scroll range, wires close btn + knob
     *
     *   // When showing the panel:
     *   _scroll.addWheelListener();
     *   _scroll.renderViewport();
     *
     *   // When hiding the panel:
     *   _scroll.removeWheelListener();
     *
     *   // Every frame while open:
     *   _scroll.doEnterFrame();
     *
     * Panels that add extra button listeners (e.g. skill/trait panels in
     * ScrDebugOptions) should use the public ehBtnDown / ehBtnMouseOver /
     * ehBtnMouseOut handlers directly on their own elements.
     */
    public class ScrollablePanel {

        // Shared viewport / scroll constants — identical across all three panels.
        public static const VIEWPORT_HEIGHT:Number  = 735;
        public static const CLIP_TOP:Number         = 50;
        public static const CLIP_BOTTOM:Number      = 920;
        public static const KNOB_Y_MIN:Number       = 127;
        public static const KNOB_Y_MAX:Number       = 851;
        public static const SCROLL_STEP:Number      = 30;
        public static const KNOB_DRAG_OFFSET:Number = 18;

        // Current panel MovieClip (typed * because it may be McOptions-derived)
        private var _mc:*;

        // Callback fired when the Close button is clicked
        private var _onClose:Function;

        // Scroll / drag state
        private var _isDragging:Boolean   = false;
        private var _isVpDragging:Boolean = false;
        private var _draggedKnob:MovieClip;
        private var _vpY:Number    = 0;
        private var _vpYMin:Number = 0;
        private var _vpYMax:Number = 0;

        // -----------------------------------------------------------------------

        /**
         * Attach a new (or rebuilt) panel MovieClip.
         * Computes the scroll range from mc.arrCntContents and wires the
         * close button and scroll knob event listeners.
         *
         * @param mc       The panel MovieClip (must expose arrCntContents,
         *                 btnScrollKnob, mcScrollBar, btnClose).
         * @param onClose  Function to call when the Close button is clicked.
         */
        public function attach(mc:*, onClose:Function):void {
            _mc      = mc;
            _onClose = onClose;

            _vpYMin = 0;
            _vpYMax = 0;
            _vpY    = 0;

            var contents:Array = mc.arrCntContents;
            if (contents != null) {
                for (var i:int = 0; i < contents.length; i++) {
                    _vpYMax = Math.max(_vpYMax, contents[i].yReal - VIEWPORT_HEIGHT);
                }
            }

            // Close button
            mc.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, ehBtnDown,       true, 0, true);
            mc.btnClose.addEventListener(MouseEvent.MOUSE_UP,   _onCloseClick,   true, 0, true);
            mc.btnClose.addEventListener(MouseEvent.MOUSE_OVER, ehBtnMouseOver,  true, 0, true);
            mc.btnClose.addEventListener(MouseEvent.MOUSE_OUT,  ehBtnMouseOut,   true, 0, true);
            mc.btnClose.tf.mouseEnabled = false;

            // Scroll knob + bar
            mc.mcScrollBar.addEventListener( MouseEvent.MOUSE_DOWN, _ehScrollKnobDown, true, 0, true);
            mc.btnScrollKnob.addEventListener(MouseEvent.MOUSE_DOWN, _ehScrollKnobDown, true, 0, true);
        }

        // -----------------------------------------------------------------------
        // Wheel listeners — add on show, remove on hide.

        public function addWheelListener():void {
            GV.main.stage.addEventListener(MouseEvent.MOUSE_WHEEL, _ehWheel, true, 0, true);
            GV.main.stage.addEventListener(GV.EVENT_SCROLL_UP,     _ehWheel, true, 0, true);
            GV.main.stage.addEventListener(GV.EVENT_SCROLL_DOWN,   _ehWheel, true, 0, true);
        }

        public function removeWheelListener():void {
            GV.main.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, _ehWheel, true);
            GV.main.stage.removeEventListener(GV.EVENT_SCROLL_UP,     _ehWheel, true);
            GV.main.stage.removeEventListener(GV.EVENT_SCROLL_DOWN,   _ehWheel, true);
        }

        // -----------------------------------------------------------------------
        // Per-frame update — call while the panel is open.

        public function doEnterFrame():void {
            if (_isVpDragging && _mc != null) {
                _mc.btnScrollKnob.y = Math.min(KNOB_Y_MAX,
                    Math.max(KNOB_Y_MIN, GV.main.mouseY - KNOB_DRAG_OFFSET));
                _vpY = MathToolbox.convertCoord(
                    KNOB_Y_MIN, KNOB_Y_MAX, _mc.btnScrollKnob.y, _vpYMin, _vpYMax);
                renderViewport();
            }
        }

        // -----------------------------------------------------------------------
        // Programmatic scroll — used by panels (e.g. OfflineItemsPanel) that
        // need to bring a freshly-revealed item into view.

        public function get viewportHeight():Number { return VIEWPORT_HEIGHT; }
        public function get vpY():Number            { return _vpY; }
        public function get vpYMax():Number         { return _vpYMax; }

        /**
         * Scroll the viewport so that _vpY equals the given target (clamped to
         * the valid range). Updates the scrollbar knob and re-renders the
         * viewport so item visibility / positions stay in sync.
         */
        public function scrollToY(targetY:Number):void {
            if (_mc == null) return;
            var clamped:Number = Math.max(_vpYMin, Math.min(_vpYMax, targetY));
            _vpY = clamped;
            _mc.btnScrollKnob.y = MathToolbox.convertCoord(
                _vpYMin, _vpYMax, _vpY, KNOB_Y_MIN, KNOB_Y_MAX);
            renderViewport();
        }

        // -----------------------------------------------------------------------
        // Viewport

        public function renderViewport():void {
            if (_mc == null) return;
            var items:Array = _mc.arrCntContents;
            for (var i:int = 0; i < items.length; i++) {
                var item:* = items[i];
                item.y       = item.yReal - _vpY;
                item.visible = item.y > CLIP_TOP && item.y < CLIP_BOTTOM;
            }
        }

        // -----------------------------------------------------------------------
        // Public button handlers — panels may attach these to their own elements.

        public function ehBtnDown(e:MouseEvent):void {
            e.target.parent.plate.gotoAndStop(4);
            GV.pressedButton = e.target.parent;
        }

        public function ehBtnMouseOver(e:MouseEvent):void {
            if (GV.pressedButton == e.target.parent) {
                e.target.parent.plate.gotoAndStop(4);
            } else {
                e.target.parent.plate.gotoAndStop(2);
            }
        }

        public function ehBtnMouseOut(e:MouseEvent):void {
            e.target.parent.plate.gotoAndStop(1);
        }

        // -----------------------------------------------------------------------
        // Private event handlers

        private function _onCloseClick(e:MouseEvent):void {
            if (_onClose != null) _onClose();
        }

        private function _ehScrollKnobDown(e:Event):void {
            _draggedKnob = _mc.btnScrollKnob;
            _mc.btnScrollKnob.gotoAndStop(2);
            GV.main.stage.addEventListener(MouseEvent.MOUSE_UP, _ehScrollKnobUp, true, 0, true);
            _isVpDragging = true;
        }

        private function _ehScrollKnobUp(e:Event):void {
            GV.main.stage.removeEventListener(MouseEvent.MOUSE_UP, _ehScrollKnobUp, true);
            _isDragging = false;
            if (_draggedKnob != null) {
                _draggedKnob.gotoAndStop(1);
                _draggedKnob = null;
            }
            _isVpDragging = false;
        }

        private function _ehWheel(e:Event):void {
            if (_mc == null) return;
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
    }
}

package ui {

    import com.giab.games.gcfw.GV;
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
     *
     * Usage:
     *   var scr:ScrSlotSettings = new ScrSlotSettings();
     *   // After AP connects:
     *   scr.configure(connectionManager, deathLinkHandler);
     *   // Button click:
     *   if (scr.isOpen) scr.close(); else scr.open();
     */
    public class ScrSlotSettings {

        private var _mc:McSlotSettings;
        private var _isOpen:Boolean = false;

        // Matches ScrDebugOptions — items outside these y-bounds are hidden.
        private static const CLIP_TOP:Number    = 50;
        private static const CLIP_BOTTOM:Number = 920;

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
            renderViewport();
        }

        public function close():void {
            if (!_isOpen) return;
            _isOpen = false;
            if (_mc != null && _mc.parent != null) _mc.parent.removeChild(_mc);
        }

        // -----------------------------------------------------------------------
        // Viewport

        /** Make all content items visible at their natural y positions (no scroll). */
        private function renderViewport():void {
            var items:Array = _mc.arrCntContents;
            for (var i:int = 0; i < items.length; i++) {
                var item:* = items[i];
                item.y       = item.yReal;
                item.visible = item.y > CLIP_TOP && item.y < CLIP_BOTTOM;
            }
        }

        // -----------------------------------------------------------------------
        // Button wiring — identical pattern to ScrDebugOptions

        private function buttonsInit():void {
            _mc.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, ehBtnDown,       true, 0, true);
            _mc.btnClose.addEventListener(MouseEvent.MOUSE_UP,   ehBtnCloseClick, true, 0, true);
            _mc.btnClose.addEventListener(MouseEvent.MOUSE_OVER, ehBtnMouseOver,  true, 0, true);
            _mc.btnClose.addEventListener(MouseEvent.MOUSE_OUT,  ehBtnMouseOut,   true, 0, true);
            _mc.btnClose.tf.mouseEnabled = false;
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

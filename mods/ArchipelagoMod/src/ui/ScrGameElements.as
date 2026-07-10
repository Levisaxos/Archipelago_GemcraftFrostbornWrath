package ui {
    import com.giab.games.gcfw.GV;
    import tracker.FieldLogicEvaluator;

    /**
     * Manages the Game Elements window lifecycle (open / close / dispose) and
     * hosts it inside a ScrollablePanel — same shape as ScrDebugOptions but with
     * no tabs.
     *
     * The window filters a 26x6 grid of fields by the requirement icons the
     * player toggles (AND); clicking a field closes the window and pans the
     * selector to it.
     */
    public class ScrGameElements {

        private var _evaluator:FieldLogicEvaluator;
        private var _mc:McGameElements;
        private var _scroll:ScrollablePanel;
        private var _isOpen:Boolean = false;

        public function get isOpen():Boolean {
            return _isOpen;
        }

        public function ScrGameElements(evaluator:FieldLogicEvaluator) {
            _evaluator = evaluator;
            _scroll    = new ScrollablePanel();
        }

        private function _initPanel():void {
            _mc = new McGameElements(_evaluator);
            _mc.onRequestClose = close;   // field click → close + pan
            _scroll.attach(_mc, close);
        }

        // -----------------------------------------------------------------------
        // Open / close

        public function open():void {
            if (_isOpen)
                return;
            if (_mc == null)
                _initPanel();
            _isOpen = true;

            _mc.btnConfirmRetry.visible     = false;
            _mc.btnConfirmReturn.visible    = false;
            _mc.btnConfirmEndBattle.visible = false;
            _mc.btnEndBattle.visible        = false;
            _mc.btnReturn.visible           = false;
            _mc.btnRetry.visible            = false;
            _mc.btnMainMenu.visible         = false;
            _mc.btnClose.visible            = true;

            // Field ownership + type availability can change between opens.
            _mc.refresh();

            GV.main.addChildAt(_mc, GV.main.numChildren);
            _scroll.addWheelListener();
            _scroll.refreshContents();
            _scroll.renderViewport();
        }

        public function close():void {
            if (!_isOpen)
                return;
            _isOpen = false;
            if (_mc != null && _mc.parent != null)
                _mc.parent.removeChild(_mc);
            _scroll.removeWheelListener();
        }

        /**
         * Drop the built panel so the next open() rebuilds it from scratch.
         * Called from ArchipelagoMod._deactivateApMode so nothing survives an
         * AP → standalone → AP cycle. See [[feedback_standalone_clean_slate]].
         */
        public function dispose():void {
            close();
            _mc     = null;
            _scroll = new ScrollablePanel();
        }

        // -----------------------------------------------------------------------
        // Per-frame update

        public function doEnterFrame():void {
            // Keep the panel on top of GV.main (game may add selector content
            // above it after open()).
            if (_mc != null && _mc.parent != null)
                _mc.parent.setChildIndex(_mc, _mc.parent.numChildren - 1);
            _scroll.doEnterFrame();
        }
    }
}

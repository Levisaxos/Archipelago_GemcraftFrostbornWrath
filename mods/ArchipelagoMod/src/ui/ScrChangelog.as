package ui {
    import com.giab.games.gcfw.GV;

    /**
     * Manages the Changelog panel lifecycle.
     *
     * Wraps McChangelog (which uses the game's McOptions chrome).
     * Scroll / drag / viewport logic is handled by the ScrollablePanel helper.
     *
     * Usage:
     *   var scr:ScrChangelog = new ScrChangelog();
     *   scr.populate(releases);       // Array of {tag, name, body, date}
     *   if (scr.isShowing) scr.dismiss(); else scr.show();
     *   // In onEnterFrame while isShowing:
     *   scr.doEnterFrame();
     */
    public class ScrChangelog {

        private var _mc:McChangelog;
        private var _scroll:ScrollablePanel;
        private var _isShowing:Boolean = false;

        public function get isShowing():Boolean { return _isShowing; }

        public function ScrChangelog() {
            _scroll = new ScrollablePanel();
        }

        // -----------------------------------------------------------------------
        // Content

        /**
         * Build (or rebuild) the panel from a releases array.
         * Safe to call while showing — closes and reopens with fresh content.
         */
        public function populate(releases:Array):void {
            var wasShowing:Boolean = _isShowing;
            if (wasShowing) dismiss();

            _mc = new McChangelog(releases);
            _scroll.attach(_mc, dismiss);

            if (wasShowing) show();
        }

        // -----------------------------------------------------------------------
        // Show / dismiss

        public function show():void {
            if (_isShowing || _mc == null) return;
            _isShowing = true;

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
            _scroll.renderViewport();
        }

        public function dismiss():void {
            if (!_isShowing) return;
            _isShowing = false;
            if (_mc != null && _mc.parent != null) _mc.parent.removeChild(_mc);
            _scroll.removeWheelListener();
        }

        // -----------------------------------------------------------------------
        // Per-frame update — call from MainMenuUI.onFrame while isShowing.

        public function doEnterFrame():void {
            _scroll.doEnterFrame();
        }
    }
}

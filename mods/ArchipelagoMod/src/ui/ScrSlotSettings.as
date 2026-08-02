package ui {
    import com.giab.games.gcfw.GV;
    import net.ConnectionManager;
    import deathlink.DeathLinkHandler;

    /**
     * Manages the Slot Settings panel lifecycle.
     *
     * Wraps McSlotSettings (which uses the game's McOptions chrome).
     * Scroll / drag / viewport logic is handled by the ScrollablePanel helper.
     *
     * Usage:
     *   var scr:ScrSlotSettings = new ScrSlotSettings();
     *   scr.configure(connectionManager, deathLinkHandler);
     *   if (scr.isOpen) scr.close(); else scr.open();
     *   // In onEnterFrame while isOpen:
     *   scr.doEnterFrame();
     */
    public class ScrSlotSettings {

        private var _mc:McSlotSettings;
        private var _scroll:ScrollablePanel;
        private var _isOpen:Boolean = false;

        public function get isOpen():Boolean { return _isOpen; }

        public function ScrSlotSettings() {
            _scroll = new ScrollablePanel();
        }

        /**
         * Build (or rebuild) the panel from current slot data.
         * Call after AP connects so the panel reflects live values.
         */
        public function configure(cm:ConnectionManager, dl:DeathLinkHandler):void {
            if (_mc != null && _mc.parent != null) _mc.parent.removeChild(_mc);
            // Rebuilding while open would strand the field tooltip hidden — restore it.
            if (_isOpen) _showFieldTooltip();
            _isOpen = false;
            _mc = new McSlotSettings(dl);
            _scroll.attach(_mc, close);
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
            _scroll.addWheelListener();
            _scroll.renderViewport();
            _hideFieldTooltip();
        }

        public function close():void {
            if (!_isOpen) return;
            _isOpen = false;
            if (_mc != null && _mc.parent != null) _mc.parent.removeChild(_mc);
            _scroll.removeWheelListener();
            _showFieldTooltip();
        }

        // -----------------------------------------------------------------------
        // Per-frame update — call from ArchipelagoMod.onEnterFrame while isOpen.

        public function doEnterFrame():void {
            _scroll.doEnterFrame();
            // The selector's field tokens sit underneath this panel and keep
            // firing hover events, so the game re-shows its field tooltip
            // (McInfoPanel) behind us. Keep it hidden every frame while open;
            // close() restores it. On the selector nothing else toggles this
            // flag, so a single set would suffice, but re-asserting per frame
            // is self-healing against a stray in-battle transition.
            _hideFieldTooltip();
        }

        // -----------------------------------------------------------------------
        // Field-tooltip suppression

        private function _hideFieldTooltip():void {
            if (GV.mcInfoPanel != null) GV.mcInfoPanel.visible = false;
        }

        private function _showFieldTooltip():void {
            if (GV.mcInfoPanel != null) GV.mcInfoPanel.visible = true;
        }
    }
}

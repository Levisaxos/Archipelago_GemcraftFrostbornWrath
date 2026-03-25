package {
    import flash.display.Stage;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;

    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Intercepts Chilling/Frostborn/Iron mode-selector clicks and delete-slot
     * buttons on the LOADGAME screen.  Hooks and unhooks its own mouse/key
     * listeners via load() / unload().
     *
     * Fires callbacks so ArchipelagoMod can show the connection overlay and
     * archive deleted slots without owning the event wiring.
     */
    public class ModeSelectorInterceptor {

        private var _logger:Logger;
        private var _modName:String;
        private var _toast:ToastPanel;
        private var _stage:Stage;

        private var _hooked:Boolean          = false;
        private var _pendingModeButton:*     = null;
        private var _pendingModeTarget:*     = null;
        private var _allowModeClick:Boolean  = false;
        private var _pendingDeleteSlot:int   = 0;

        // -----------------------------------------------------------------------
        // Callbacks — set by ArchipelagoMod

        /**
         * Called when a Chilling/Frostborn button is intercepted.
         * Signature: (slotId:int, pendingBtn:*, pendingTarget:*):void
         */
        public var onModeIntercepted:Function;

        /**
         * Called when a delete button is clicked, before D confirmation.
         * Use this to warn the player if the slot's game is not yet completed.
         * Signature: (slotId:int):void
         */
        public var onSlotDeleteWarning:Function;

        /**
         * Called when the D key confirms a slot deletion.
         * Signature: (slotId:int):void
         */
        public var onSlotDeleteConfirmed:Function;

        // -----------------------------------------------------------------------

        public function ModeSelectorInterceptor(logger:Logger, modName:String, toast:ToastPanel) {
            _logger  = logger;
            _modName = modName;
            _toast   = toast;
        }

        public function get isHooked():Boolean { return _hooked; }
        public function get pendingModeButton():* { return _pendingModeButton; }
        public function get pendingModeTarget():* { return _pendingModeTarget; }

        // -----------------------------------------------------------------------
        // Lifecycle

        /**
         * Attach mouse listeners to the mode-selector and delete buttons.
         * Call when on LOADGAME screen and not yet hooked.
         */
        public function hook(stage:Stage):void {
            if (_hooked) return;
            _stage = stage;
            try {
                var lg:*  = GV.main.cntScreens.mcLoadGame;
                var sel:* = lg.mcModeSelector;
                if (sel == null) return;
                // Mark hooked immediately so a later exception cannot cause a retry loop.
                _hooked = true;

                sel.btnModeChilling.addEventListener( MouseEvent.MOUSE_UP, onModeBtnUp, true, 100, true);
                sel.btnModeFrostborn.addEventListener(MouseEvent.MOUSE_UP, onModeBtnUp, true, 100, true);
                sel.btnModeIron.addEventListener(     MouseEvent.MOUSE_UP, onIronBtnUp, true, 100, true);
                // McModeSelector has no Continue button — existing saves fall through
                // to the _needsConnection fallback in ArchipelagoMod.onEnterFrame.

                for (var n:int = 1; n <= 8; n++) {
                    var btn:* = lg["btnResetSlotL" + n];
                    if (btn != null) btn.addEventListener(MouseEvent.MOUSE_UP, onDeleteBtnUp, false, 0, true);
                }
                _stage.addEventListener(KeyboardEvent.KEY_DOWN, onConfirmDeleteKey, true, 100, true);
                _logger.log(_modName, "LOADGAME buttons hooked (Chilling + Frostborn + Iron + Delete x8)");
            } catch (err:Error) {
                _logger.log(_modName, "ModeSelectorInterceptor.hook error: " + err.message);
            }
        }

        /**
         * Remove all listeners attached by hook().
         */
        public function unhook():void {
            if (!_hooked) return;
            try {
                var lg:*  = GV.main.cntScreens.mcLoadGame;
                var sel:* = lg != null ? lg.mcModeSelector : null;
                if (sel != null) {
                    sel.btnModeChilling.removeEventListener( MouseEvent.MOUSE_UP, onModeBtnUp, true);
                    sel.btnModeFrostborn.removeEventListener(MouseEvent.MOUSE_UP, onModeBtnUp, true);
                    sel.btnModeIron.removeEventListener(     MouseEvent.MOUSE_UP, onIronBtnUp, true);
                }
                if (lg != null) {
                    for (var n:int = 1; n <= 8; n++) {
                        var btn:* = lg["btnResetSlotL" + n];
                        if (btn != null) btn.removeEventListener(MouseEvent.MOUSE_UP, onDeleteBtnUp, false);
                    }
                }
                if (_stage != null) {
                    _stage.removeEventListener(KeyboardEvent.KEY_DOWN, onConfirmDeleteKey, true);
                }
            } catch (err:Error) {
                _logger.log(_modName, "ModeSelectorInterceptor.unhook error: " + err.message);
            }
            _pendingDeleteSlot = 0;
            _hooked = false;
            _logger.log(_modName, "LOADGAME buttons unhooked");
        }

        /** Clear the pending mode-click state (e.g. when overlay is dismissed). */
        public function clearPending():void {
            _pendingModeButton = null;
            _pendingModeTarget = null;
        }

        /**
         * Re-dispatch the intercepted mode button click so the game proceeds.
         * Called by ArchipelagoMod after AP connection succeeds.
         */
        public function redispatchPendingClick():void {
            if (_pendingModeButton == null) return;
            var pendingBtn:* = _pendingModeButton;
            var pendingTarget:* = _pendingModeTarget;
            _pendingModeButton = null;
            _pendingModeTarget = null;

            _logger.log(_modName, "Re-dispatching mode button MOUSE_UP — btn=" + pendingBtn
                + "  target=" + pendingTarget);
            GV.pressedButton = pendingBtn;
            _allowModeClick = true;
            pendingTarget.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false));
            _allowModeClick = false;
        }

        // -----------------------------------------------------------------------
        // Event handlers

        private function onModeBtnUp(e:MouseEvent):void {
            if (_allowModeClick) return; // our own re-dispatch — let it through
            e.stopImmediatePropagation();
            var slotId:int = int(GV.loaderSaver.activeSlotId);
            _pendingModeButton = e.currentTarget;
            _pendingModeTarget = e.target;
            var btnName:String = Object(e.currentTarget).name;
            var modeName:String = (btnName == "btnModeChilling") ? "Chilling"
                                : (btnName == "btnModeFrostborn") ? "Frostborn"
                                : btnName;
            _logger.log(_modName, "PLAYER_SELECTED_MODE mode=" + modeName + "  slot=" + slotId);
            if (onModeIntercepted != null) onModeIntercepted(slotId, _pendingModeButton, _pendingModeTarget);
        }

        private function onIronBtnUp(e:MouseEvent):void {
            e.stopImmediatePropagation();
            _toast.addMessage("Iron is not allowed (yet) for Archipelago", 0xFFFF8844);
            _logger.log(_modName, "Iron mode blocked — not supported in AP");
        }

        private function onDeleteBtnUp(e:MouseEvent):void {
            var lg:* = GV.main.cntScreens.mcLoadGame;
            var slotId:int = 0;
            for (var n:int = 1; n <= 8; n++) {
                if (lg["btnResetSlotL" + n] == e.currentTarget) { slotId = n; break; }
            }
            if (slotId <= 0) {
                _logger.log(_modName, "onDeleteBtnUp: could not identify slot — btn.name=" + e.currentTarget.name);
                return;
            }
            _pendingDeleteSlot = slotId;
            _logger.log(_modName, "Delete button clicked for slot " + slotId + " — waiting for D confirmation");
            if (onSlotDeleteWarning != null) onSlotDeleteWarning(slotId);
        }

        private function onConfirmDeleteKey(e:KeyboardEvent):void {
            if (e.keyCode != Keyboard.D || _pendingDeleteSlot <= 0) return;
            var slotId:int = _pendingDeleteSlot;
            _pendingDeleteSlot = 0;
            _logger.log(_modName, "D key confirmed — archiving slot " + slotId);
            if (onSlotDeleteConfirmed != null) onSlotDeleteConfirmed(slotId);
        }
    }
}

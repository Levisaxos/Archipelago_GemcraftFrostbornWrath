package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.ScreenId;
    import com.giab.games.gcfw.constants.SelectorScreenStatus;
    import flash.display.Bitmap;
    import unlockers.TalismanUnlocker;

    /**
     * Appends an "Archipelago item" line to the game's own talisman-fragment
     * hover tooltip (McInfoPanel) when the hovered fragment came from
     * Archipelago, so AP-sourced fragments stay identifiable in the inventory
     * and active slots.
     *
     * Mirrors AchievementTooltipOverlay: it runs after the game has rendered
     * the fragment panel this frame (parent set + isImageRendered), re-detects
     * the same hovered fragment via PnlTalisman.renderInfoPanel's own
     * coordinate zones, and — if that fragment's seed is an AP fragment —
     * disposes the freshly drawn bitmap, appends our line, and re-renders one
     * line taller.
     *
     * Gated hard to the talisman screen. GV.mcInfoPanel is a process-wide
     * singleton shared by every tooltip (battle gems, map fields, skills, ...),
     * and the selector frame loop also ticks during a battle, so touching it
     * off-screen would graft the marker onto unrelated tooltips.
     */
    public class TalismanFragmentTooltipOverlay {

        private static const MARKER_COLOR:uint = 0xE5AD0A;

        private var _logger:Logger;
        private var _modName:String;
        private var _unlocker:TalismanUnlocker;

        // The fragment we last appended the marker for. Unlike the achievements
        // panel, PnlTalisman.renderInfoPanel only re-renders the tooltip when the
        // hovered zone CHANGES — it stays static while you keep hovering the same
        // fragment. Without this latch we'd append a fresh "Archipelago item"
        // line every frame and stack them. Cleared whenever the hover leaves an
        // AP fragment, so re-hovering re-appends onto the game's fresh panel.
        private var _lastFrag:* = null;

        public function TalismanFragmentTooltipOverlay(logger:Logger, modName:String,
                                                       unlocker:TalismanUnlocker) {
            _logger   = logger;
            _modName  = modName;
            _unlocker = unlocker;
        }

        /** Call every selector frame; self-gates to the active talisman screen. */
        public function onSelectorFrame():void {
            if (_unlocker == null || GV.selectorCore == null || GV.mcInfoPanel == null)
                return;
            // Only while the talisman screen is the active on-screen window —
            // not during a battle (currentScreen != SELECTOR) or on any other
            // selector sub-screen (screenStatus check).
            if (int(GV.main.currentScreen) != ScreenId.SELECTOR)
                return;
            var status:int = int(GV.selectorCore.screenStatus);
            if (status != SelectorScreenStatus.TALISMAN_IDLE_STAGES
                    && status != SelectorScreenStatus.TALISMAN_IDLE_SETTINGS)
                return;

            var pnl:* = GV.selectorCore.pnlTalisman;
            if (pnl == null || pnl.mc == null) {
                _lastFrag = null;
                return;
            }

            var frag:* = _findHoveredFragment(pnl);
            // Not hovering an AP fragment — drop the latch so the next AP hover
            // re-appends onto the game's freshly rendered panel.
            if (frag == null || !_unlocker.isApFragmentSeed(int(frag.seed))) {
                _lastFrag = null;
                return;
            }
            // Same fragment as last frame: the game hasn't re-rendered (it only
            // re-renders on a zone change), so our line is already there.
            if (frag === _lastFrag)
                return;

            var vIp:* = GV.mcInfoPanel;
            // parent non-null + isImageRendered == the game drew the tooltip this
            // frame. If it's not ready yet, retry next frame WITHOUT latching.
            if (vIp.parent == null || !vIp.isImageRendered)
                return;

            // Dispose the game's freshly drawn bitmap and reset so drawBitmap()
            // will run again with our extra line included.
            try {
                var oldBmp:Bitmap = vIp.bmp as Bitmap;
                if (oldBmp != null && oldBmp.bitmapData != null)
                    oldBmp.bitmapData.dispose();
                vIp.bmp = null;
                vIp.isImageRendered = false;
            } catch (e:Error) {
                _logger.log(_modName, "TalismanFragmentTooltip: bitmap dispose error: " + e.message);
                return;
            }

            // drawBitmap() multiplied vIp.w by projectorZoom in place; undo it so
            // the appended text isn't double-zoomed (mirrors AchievementTooltipOverlay).
            try {
                var zoom:Number = Number(GV.projectorZoom);
                if (zoom > 0) vIp.w = vIp.w / zoom;
            } catch (e2:Error) {}

            try {
                vIp.addExtraHeight(7);
                vIp.addSeparator(-2);
                vIp.addTextfield(MARKER_COLOR, "Archipelago item", false, 10);
            } catch (e3:Error) {
                _logger.log(_modName, "TalismanFragmentTooltip: addTextfield error: " + e3.message);
                return;
            }

            try {
                vIp.doEnterFrame();
            } catch (e4:Error) {
                _logger.log(_modName, "TalismanFragmentTooltip: doEnterFrame error: " + e4.message);
            }

            // Latch: don't append again until the hover moves to another fragment.
            _lastFrag = frag;
        }

        /**
         * Replicate PnlTalisman.renderInfoPanel's two fragment hover zones (root-
         * space mouse coords) to find the fragment currently under the pointer,
         * or null. Skips the drag / compare case (draggedFragment != null) so we
         * never append onto a comparison panel.
         */
        private function _findHoveredFragment(pnl:*):* {
            try {
                if (pnl.draggedFragment != null) return null;
                if (GV.ppd == null) return null;
                var root:* = pnl.mc.root;
                if (root == null) return null;
                var mx:Number = root.mouseX;
                var my:Number = root.mouseY;

                // Inventory grid: 6x6, origin (1180,170), cell 106.
                if (mx >= 1180 && mx < 1180 + 6 * 106 && my >= 170 && my < 170 + 6 * 106) {
                    var invSlot:int = 6 * int((my - 170) / 106) + int((mx - 1180) / 106);
                    var inv:Array = GV.ppd.talismanInventory;
                    if (inv != null && invSlot >= 0 && invSlot < inv.length)
                        return inv[invSlot];
                    return null;
                }

                // Active-slot grid: 5x5, origin (106,98), cell 183x160.
                if (mx >= 106 && mx < 106 + 5 * 183 && my >= 98 && my < 98 + 5 * 160) {
                    var talSlot:int = 5 * int((my - 98) / 160) + int((mx - 106) / 183);
                    var slots:Array = GV.ppd.talismanSlots;
                    if (slots != null && talSlot >= 0 && talSlot < slots.length)
                        return slots[talSlot];
                    return null;
                }
            } catch (e:Error) {}
            return null;
        }
    }
}

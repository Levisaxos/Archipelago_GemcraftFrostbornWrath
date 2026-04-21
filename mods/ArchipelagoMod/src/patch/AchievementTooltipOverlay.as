package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import flash.display.Bitmap;

    /**
     * Appends Archipelago info into the game's own achievement hover tooltip
     * (McInfoPanel) so it appears as a natural extension of the game's panel.
     *
     * How it works:
     *   The game's PnlAchievements.doEnterFrame() detects hover by polling mouse
     *   bounds every frame, then calls renderAchiInfoPanel() which:
     *     1. Resets McInfoPanel and adds game text fields
     *     2. Adds McInfoPanel to panel.mc
     *     3. Calls McInfoPanel.doEnterFrame() → drawBitmap() → isImageRendered = true
     *
     *   Our onSelectorFrame() runs after the game (display list ordering means
     *   game objects' ENTER_FRAME fires before the mod's). We detect the same hover,
     *   then:
     *     1. Dispose the game's freshly-drawn bitmap (prevent BitmapData leak)
     *     2. Reset isImageRendered = false
     *     3. Add a separator + our lines via McInfoPanel.addTextfield()
     *     4. Call McInfoPanel.doEnterFrame() again → one unified, taller panel
     *
     * Extensible: call registerProvider() to add extra lines for future features.
     * Each provider receives (ach, achName, apId, isExcluded, isInLogic) and
     * returns an Array of [text:String, color:uint] pairs to append.
     */
    public class AchievementTooltipOverlay {

        private var _logger:Logger;
        private var _modName:String;

        // Data kept in sync by AchievementPanelPatcher
        private var _gameIdToApId:Object       = {}; // game ach.id (int) -> apId (int)
        private var _excludedApIds:Object      = {}; // apId -> true (always_as_filler)
        private var _effortExcludedApIds:Object = {}; // apId -> true (effort > threshold)
        private var _maxEffortLabel:String      = "Trivial";
        private var _reqMetApIds:Object        = {}; // apId -> true

        // Array of Function(ach:*, achName:String, apId:int, isExcluded:Boolean, isInLogic:Boolean):Array
        private var _providers:Array = [];

        // -----------------------------------------------------------------------

        public function AchievementTooltipOverlay(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
            _registerDefaultProvider();
        }

        // -----------------------------------------------------------------------
        // Data setters (called by AchievementPanelPatcher on every logic update)

        public function set gameIdToApId(v:Object):void        { _gameIdToApId        = v || {}; }
        public function set excludedApIds(v:Object):void       { _excludedApIds        = v || {}; }
        public function set effortExcludedApIds(v:Object):void { _effortExcludedApIds  = v || {}; }
        public function set maxEffortLabel(v:String):void      { _maxEffortLabel       = v || "Trivial"; }
        public function set reqMetApIds(v:Object):void         { _reqMetApIds          = v || {}; }

        /**
         * Register an additional tooltip content provider.
         *
         * @param provider  Function(ach:*, achName:String, apId:int,
         *                           isExcluded:Boolean, isInLogic:Boolean):Array
         *                  Must return an Array of two-element Arrays [text, color].
         *                  Return an empty Array to contribute nothing.
         */
        public function registerProvider(provider:Function):void {
            _providers.push(provider);
        }

        // -----------------------------------------------------------------------
        // Frame driver

        /**
         * Called every selector frame from AchievementPanelPatcher.onSelectorFrame().
         * Appends AP info into McInfoPanel if the game is currently showing a tooltip.
         */
        public function onSelectorFrame(panel:*):void {
            if (panel == null || GV.mcInfoPanel == null) return;

            // McInfoPanel.parent is non-null only while the game is showing a tooltip.
            // isImageRendered == true confirms the game already ran drawBitmap() this frame.
            var vIp:* = GV.mcInfoPanel;
            if (vIp.parent == null || !vIp.isImageRendered) return;

            // Replicate game's hover detection (PnlAchievements.doEnterFrame lines 395-402).
            var hoveredAch:* = _findHoveredAch(panel);
            if (hoveredAch == null) return;

            // Resolve AP data.
            var rawApId:* = _gameIdToApId[int(hoveredAch.id)];
            if (rawApId == null) return; // Not AP-tracked — don't modify panel.

            var apId:int           = int(rawApId);
            var isExcluded:Boolean = (_excludedApIds[apId] === true || _effortExcludedApIds[apId] === true);
            var isInLogic:Boolean  = (!isExcluded && _reqMetApIds[apId] === true);
            var achName:String     = String(hoveredAch.title);

            // Collect lines from all registered providers.
            var lines:Array = _collectLines(hoveredAch, achName, apId, isExcluded, isInLogic);
            if (lines.length == 0) return;

            // Dispose game's bitmap and reset so drawBitmap() will run again.
            try {
                var oldBmp:Bitmap = vIp.bmp as Bitmap;
                if (oldBmp != null && oldBmp.bitmapData != null) {
                    oldBmp.bitmapData.dispose();
                }
                vIp.bmp = null;
                vIp.isImageRendered = false;
            } catch (e:Error) {
                _logger.log(_modName, "TooltipOverlay: bitmap dispose error: " + e.message);
                return;
            }

            // drawBitmap() multiplied vIp.w by projectorZoom in-place during the first
            // render.  Undo that now so addTextfield() and the second drawBitmap() both
            // use the original unscaled width — otherwise text x-positions are double-zoomed.
            try {
                var zoom:Number = Number(GV.projectorZoom);
                if (zoom > 0) vIp.w = vIp.w / zoom;
            } catch (e2:Error) {}

            // Add separator + our lines into the existing textfields array.
            // Match game's own separator pattern: addExtraHeight(7) + addSeparator(-2).
            try {
                vIp.addExtraHeight(7);
                vIp.addSeparator(-2);
                for each (var pair:Array in lines) {
                    vIp.addTextfield(uint(pair[1]), String(pair[0]), false, 10);
                }
            } catch (e3:Error) {
                _logger.log(_modName, "TooltipOverlay: addTextfield error: " + e3.message);
                return;
            }

            // Re-render: drawBitmap() now includes game content + our lines.
            try {
                vIp.doEnterFrame();
            } catch (e4:Error) {
                _logger.log(_modName, "TooltipOverlay: doEnterFrame error: " + e4.message);
            }
        }

        // -----------------------------------------------------------------------
        // Private

        private function _findHoveredAch(panel:*):* {
            try {
                var shownAchis:Array = panel.shownAchis as Array;
                if (shownAchis == null) return null;
                var mx:Number = panel.mc.mouseX;
                var my:Number = panel.mc.mouseY;

                // Mirror the game's doEnterFrame Y-constraint so we don't trigger
                // when the mouse is outside the achievement grid region.
                if (my < 126 || my > 950) return null;

                // If the mouse is over the skill-points plate the game shows its own
                // info panel via a MOUSE_OVER listener — don't hijack that tooltip.
                try {
                    var sp:* = panel.mc.mcSkillPtsPlate;
                    if (sp != null && sp.visible &&
                            sp.hitTestPoint(panel.mc.stage.mouseX, panel.mc.stage.mouseY, true)) {
                        return null;
                    }
                } catch (esp:Error) {}

                for (var i:int = 0; i < shownAchis.length; i++) {
                    var ach:* = shownAchis[i];
                    if (ach == null || ach.mc == null) continue;
                    if (mx > ach.mc.x && mx < ach.mc.x + 64
                            && my > ach.mc.y && my < ach.mc.y + 64) {
                        return ach;
                    }
                }
            } catch (e:Error) {}
            return null;
        }

        private function _collectLines(ach:*, achName:String, apId:int,
                                        isExcluded:Boolean, isInLogic:Boolean):Array {
            var lines:Array = [];
            for each (var provider:Function in _providers) {
                try {
                    var result:Array = provider(ach, achName, apId, isExcluded, isInLogic);
                    if (result != null) {
                        for each (var pair:Array in result) {
                            lines.push(pair);
                        }
                    }
                } catch (pe:Error) {
                    _logger.log(_modName, "TooltipOverlay provider error: " + pe.message);
                }
            }
            return lines;
        }

        private function _registerDefaultProvider():void {
            var self:AchievementTooltipOverlay = this;
            _providers.push(function(ach:*, achName:String, apId:int,
                                     isExcluded:Boolean, isInLogic:Boolean):Array {
                var statusText:String;
                var statusColor:uint;
                if (isExcluded) {
                    if (self._effortExcludedApIds[apId] === true) {
                        statusText  = "Filler \u2014 excluded by yaml settings (effort > " + self._maxEffortLabel + ")";
                    } else {
                        statusText  = "Filler \u2014 no logic requirements";
                    }
                    statusColor = 0xAAAAAA;
                } else if (isInLogic) {
                    statusText  = "In logic \u2713";
                    statusColor = 0x44FF44;
                } else {
                    statusText  = "Not yet in logic";
                    statusColor = 0xFF4444;
                }
                return [
                    ["Archipelago", 0xE5AD0A],
                    [statusText,    statusColor]
                ];
            });
        }
    }
}

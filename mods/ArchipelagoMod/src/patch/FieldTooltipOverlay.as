package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import flash.display.Bitmap;
    import flash.geom.Rectangle;

    import data.AV;
    import net.ConnectionManager;
    import tracker.FieldLogicEvaluator;

    /**
     * Appends Archipelago check-status lines into the game's field hover tooltip
     * (McInfoPanel) using the same intercept pattern as AchievementTooltipOverlay.
     *
     * Shows per-check status for Journey, Bonus, and Stash locations:
     *   ✓  grey  — already checked
     *   in logic     green — missing and reachable
     *   not in logic red   — missing and blocked
     */
    public class FieldTooltipOverlay {

        private static const ACHIEVEMENTS_IDLE_STAGES:int   = 305;
        private static const ACHIEVEMENTS_IDLE_SETTINGS:int = 306;

        private var _logger:Logger;
        private var _modName:String;
        private var _evaluator:FieldLogicEvaluator;

        // True after we've appended our lines to the current tooltip.
        // Cleared when isImageRendered goes false (game reset or panel closed),
        // which signals a new tooltip is starting.
        private var _appended:Boolean = false;

        // -----------------------------------------------------------------------

        public function FieldTooltipOverlay(logger:Logger, modName:String,
                                            evaluator:FieldLogicEvaluator) {
            _logger    = logger;
            _modName   = modName;
            _evaluator = evaluator;
        }

        // -----------------------------------------------------------------------

        /**
         * Called every selector frame from ArchipelagoMod.onSelectorFrame().
         * mc is GV.selectorCore.mc.
         */
        public function onSelectorFrame(mc:*):void {
            if (mc == null || GV.mcInfoPanel == null) return;

            // Skip while the achievements panel is open — its own overlay handles that.
            if (GV.selectorCore != null) {
                var status:int = int(GV.selectorCore.screenStatus);
                if (status == ACHIEVEMENTS_IDLE_STAGES ||
                        status == ACHIEVEMENTS_IDLE_SETTINGS) return;
            }

            var vIp:* = GV.mcInfoPanel;

            // When the panel is hidden or the game resets it (isImageRendered=false),
            // clear our flag so we'll re-append for the next tooltip.
            if (vIp.parent == null || !vIp.isImageRendered) {
                _appended = false;
                return;
            }
            if (_appended) return;

            var hoveredTok:* = _findHoveredToken(mc);
            if (hoveredTok == null) return;

            // Resolve strId from the token index.
            var sid:int = int(hoveredTok.id);
            var metas:Array = (GV.stageCollection != null)
                    ? GV.stageCollection.stageMetas : null;
            if (metas == null || sid < 0 || sid >= metas.length) return;
            var meta:* = metas[sid];
            if (meta == null) return;
            var strId:String = String(meta.strId);

            var base:int = int(ConnectionManager.stageLocIds[strId]);
            if (base <= 0) return; // not an AP-tracked stage

            // Per-check status.
            var missing:Object = AV.saveData.missingLocations;
            var checked:Object = AV.saveData.checkedLocations;

            var journeyMissing:Boolean = missing[base]       == true;
            var journeyDone:Boolean    = checked[base]       == true;

            var bonusId:int            = base + 199;
            var bonusMissing:Boolean   = missing[bonusId]    == true;
            var bonusDone:Boolean      = checked[bonusId]    == true;

            var stashId:int            = base + 399;
            var stashMissing:Boolean   = missing[stashId]    == true;
            var stashDone:Boolean      = checked[stashId]    == true;

            var lines:Array = _buildLines(strId,
                    journeyMissing, journeyDone,
                    bonusMissing,   bonusDone,
                    stashMissing,   stashDone);

            // Dispose game's bitmap and reset so drawBitmap() runs again.
            try {
                var oldBmp:Bitmap = vIp.bmp as Bitmap;
                if (oldBmp != null && oldBmp.bitmapData != null) {
                    oldBmp.bitmapData.dispose();
                }
                vIp.bmp = null;
                vIp.isImageRendered = false;
            } catch (e:Error) {
                _logger.log(_modName, "FieldTooltipOverlay: bitmap dispose error: " + e.message);
                return;
            }

            // drawBitmap() multiplied vIp.w by projectorZoom in-place during the first
            // render.  Undo that before addTextfield() so text positions aren't double-zoomed.
            try {
                var zoom:Number = Number(GV.projectorZoom);
                if (zoom > 0) vIp.w = vIp.w / zoom;
            } catch (e2:Error) {}

            try {
                vIp.addExtraHeight(7);
                vIp.addSeparator(-2);
                for each (var pair:Array in lines) {
                    vIp.addTextfield(uint(pair[1]), String(pair[0]), false, 10);
                }
            } catch (e3:Error) {
                _logger.log(_modName, "FieldTooltipOverlay: addTextfield error: " + e3.message);
                return;
            }

            _appended = true;
            try {
                vIp.doEnterFrame();
            } catch (e4:Error) {
                _logger.log(_modName, "FieldTooltipOverlay: doEnterFrame error: " + e4.message);
            }
        }

        // -----------------------------------------------------------------------

        private function _findHoveredToken(mc:*):* {
            var cnt:* = mc.cntFieldTokens;
            if (cnt == null) return null;
            try {
                var mx:Number = cnt.mouseX;
                var my:Number = cnt.mouseY;
                for (var i:int = 0; i < cnt.numChildren; i++) {
                    var tok:* = cnt.getChildAt(i);
                    if (tok == null) continue;
                    var b:Rectangle = tok.getBounds(cnt);
                    if (b != null && mx >= b.left && mx <= b.right
                            && my >= b.top && my <= b.bottom) {
                        return tok;
                    }
                }
            } catch (e:Error) {}
            return null;
        }

        private function _buildLines(strId:String,
                                     journeyMissing:Boolean, journeyDone:Boolean,
                                     bonusMissing:Boolean,   bonusDone:Boolean,
                                     stashMissing:Boolean,   stashDone:Boolean):Array {
            var lines:Array = [["Archipelago", 0xE5AD0A]];

            var journeyExists:Boolean = journeyMissing || journeyDone;
            var bonusExists:Boolean   = bonusMissing   || bonusDone;
            var stashExists:Boolean   = stashMissing   || stashDone;

            if (journeyExists) {
                var journeyInLogic:Boolean = journeyMissing &&
                        _evaluator.stageHasInLogicMissing(strId, true, false, false);
                lines.push(_checkLine("Journey", journeyDone, journeyInLogic));
            }
            if (bonusExists) {
                var bonusInLogic:Boolean = bonusMissing &&
                        _evaluator.stageHasInLogicMissing(strId, false, true, false);
                lines.push(_checkLine("Bonus", bonusDone, bonusInLogic));
            }
            if (stashExists) {
                var stashInLogic:Boolean = stashMissing &&
                        _evaluator.stageHasInLogicMissing(strId, false, false, true);
                lines.push(_checkLine("Stash", stashDone, stashInLogic));
            }

            return lines;
        }

        private function _checkLine(label:String, done:Boolean, inLogic:Boolean):Array {
            if (done)         return [label + ": \u2713",         0x888888];
            if (inLogic)      return [label + ": in logic",       0x44FF44];
            return                   [label + ": not in logic",   0xFF4444];
        }
    }
}

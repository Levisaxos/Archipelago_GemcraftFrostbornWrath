package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import flash.display.Bitmap;
    import flash.text.TextField;

    /**
     * Rewrites the vanilla "Component skill" hover tooltip on the Skills panel.
     *
     * Vanilla (PnlSkills.renderInfoPanelSkill) describes every gem-component
     * skill as:
     *   "Unlocks the corresponding gem type if the field has been beaten at
     *    least once"
     * The AP randomizer removes the field-beaten gate on skill-unlocked gem
     * types (FirstPlayBypass adds them on top of vanilla GIVEGT regardless of
     * whether the field was ever cleared), so the conditional clause is
     * misleading. We trim it to "Unlocks the corresponding gem type".
     *
     * The panel is already drawn by the time we see it, so we edit the
     * matching textfield in place, dispose the cached bitmap and re-run
     * doEnterFrame to redraw — the same intercept pattern as
     * FieldTooltipOverlay. Layout below the line is left untouched: the
     * shortened text simply occupies one line instead of two.
     */
    public class SkillTypeTooltipOverlay {

        private static const VANILLA_TEXT:String =
            "Unlocks the corresponding gem type if the field has been beaten at least once";
        private static const PATCHED_TEXT:String =
            "Unlocks the corresponding gem type";

        private var _logger:Logger;
        private var _modName:String;

        // True after we've handled the current tooltip. Cleared when the panel
        // is hidden / re-rendered so the next tooltip is re-checked.
        private var _handled:Boolean = false;

        // -----------------------------------------------------------------------

        public function SkillTypeTooltipOverlay(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        // -----------------------------------------------------------------------

        /** Called every selector frame from ArchipelagoMod.onSelectorFrame(). */
        public function onSelectorFrame():void {
            if (GV.mcInfoPanel == null) return;
            var vIp:* = GV.mcInfoPanel;

            if (vIp.parent == null || !vIp.isImageRendered) {
                _handled = false;
                return;
            }
            if (_handled) return;

            var textfields:Array = vIp.textfields as Array;
            if (textfields == null) return;

            var target:TextField = null;
            for each (var tf:TextField in textfields) {
                if (tf != null && tf.text == VANILLA_TEXT) {
                    target = tf;
                    break;
                }
            }
            if (target == null) {
                _handled = true; // not the component-skill tooltip — leave alone
                return;
            }

            try {
                target.text = PATCHED_TEXT;

                // Dispose the cached bitmap so doEnterFrame redraws from the
                // edited textfields.
                var oldBmp:Bitmap = vIp.bmp as Bitmap;
                if (oldBmp != null && oldBmp.bitmapData != null) {
                    oldBmp.bitmapData.dispose();
                }
                vIp.bmp = null;
                vIp.isImageRendered = false;

                // drawBitmap multiplies w and h by the zoom factor in place on
                // every render, so undo that before re-rendering or the second
                // pass double-zooms the plate. After any panel build the height
                // invariant h == nextTfPos + 8 holds, which recovers the
                // un-zoomed height exactly.
                var zoom:Number = Number(GV.projectorZoom);
                if (zoom > 0) vIp.w = vIp.w / zoom;
                vIp.h = vIp.nextTfPos + 8;

                vIp.doEnterFrame();
            } catch (err:Error) {
                _logger.log(_modName, "SkillTypeTooltipOverlay error: " + err.message);
            }

            _handled = true;
        }
    }
}

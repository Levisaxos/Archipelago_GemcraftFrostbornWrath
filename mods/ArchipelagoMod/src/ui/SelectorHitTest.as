package ui {
    import flash.display.DisplayObject;

    /**
     * Geometry helper for the field-hover tooltip (IconTooltipPreview). It
     * locates the hovered field token by a raw bounds test that ignores
     * z-order, so a button drawn over a field token would still pop the field
     * tooltip behind it. This lets it defer to
     * buttons, matching the game's own mouse routing (a field's eventPlate
     * MOUSE_OVER never fires while a button covers it).
     */
    public class SelectorHitTest {

        /**
         * True when the cursor sits over one of the selector's buttons: the
         * vanilla left-panel nav buttons (instance names begin "btn") or any
         * mod button (CustomButton and its FieldsInLogicButton subclass). Only
         * direct children of the selector mc are tested, and each with a
         * pixel-accurate hitTestPoint so transparent button padding doesn't
         * count.
         */
        public static function isOverSelectorButton(mc:*):Boolean {
            if (mc == null) return false;
            var stg:* = null;
            try { stg = mc.stage; } catch (eStg:Error) {}
            if (stg == null) return false;

            var gx:Number = Number(stg.mouseX);
            var gy:Number = Number(stg.mouseY);
            try {
                var n:int = int(mc.numChildren);
                for (var i:int = 0; i < n; i++) {
                    var ch:DisplayObject = mc.getChildAt(i) as DisplayObject;
                    if (ch == null || !ch.visible) continue;
                    if (!_isButton(ch)) continue;
                    if (ch.hitTestPoint(gx, gy, true)) return true;
                }
            } catch (e:Error) {}
            return false;
        }

        private static function _isButton(ch:DisplayObject):Boolean {
            if (ch is CustomButton) return true; // covers FieldsInLogicButton
            var nm:String = ch.name;
            return nm != null && nm.indexOf("btn") == 0;
        }
    }
}

package ui {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.Matrix;

    /**
     * Base class for all mod buttons on the selector screen and the main menu.
     *
     * Clones the visual appearance of a game button via bitmap snapshot:
     * temporarily swaps its .tf.text label, draws the parent into a BitmapData,
     * then restores the original label. The result looks identical to the
     * game's own buttons.
     *
     * Usage:
     *   var btn:CustomButton = new CustomButton(mc.btnTutorial, "My Label");
     *   btn.onClick = function():void { doSomething(); };
     *   mc.addChild(btn);
     *
     * Subclasses may override _onOver / _onOut for custom hover behaviour, or
     * call _rebuild(newLabel) to re-snapshot with a different label at runtime.
     */
    public class CustomButton extends Sprite {

        /** Assign to wire click handling. Signature: ():void */
        public var onClick:Function;

        protected var _template:*;

        public function CustomButton(btnTemplate:*, label:String) {
            super();
            _template = btnTemplate;
            _rebuild(label);
            buttonMode    = true;
            useHandCursor = true;
            addEventListener(MouseEvent.MOUSE_OVER, _onOver,         false, 0, true);
            addEventListener(MouseEvent.MOUSE_OUT,  _onOut,          false, 0, true);
            addEventListener(MouseEvent.CLICK,      _onClickInternal, false, 0, true);
        }

        /**
         * Re-snapshot the button with a new label.
         * Clears all existing children, then draws a fresh bitmap clone.
         */
        protected function _rebuild(label:String):void {
            while (numChildren > 0) removeChildAt(0);

            var bw:Number = _template.width;
            var bh:Number = _template.height;

            var originalText:String = _template.tf.text;
            _template.tf.text = label;

            var bd:BitmapData = new BitmapData(bw, bh, true, 0x00000000);
            var m:Matrix = new Matrix();
            m.tx = -_template.x;
            m.ty = -_template.y;
            bd.draw(_template.parent, m);
            addChild(new Bitmap(bd));

            _template.tf.text = originalText;
        }

        protected function _onOver(e:MouseEvent):void {
            filters = [_brightnessFilter(1.35)];
        }

        protected function _onOut(e:MouseEvent):void {
            filters = [];
        }

        private function _onClickInternal(e:MouseEvent):void {
            if (onClick != null) onClick();
        }

        private function _brightnessFilter(scale:Number):ColorMatrixFilter {
            return new ColorMatrixFilter([
                scale, 0,     0,     0, 0,
                0,     scale, 0,     0, 0,
                0,     0,     scale, 0, 0,
                0,     0,     0,     1, 0
            ]);
        }
    }
}

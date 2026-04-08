package ui {

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.Matrix;
    import flash.text.TextField;

    /**
     * Main-menu button that opens/closes the ScrSlotSettings panel.
     * Cloned visually from btnTutorial, same pattern as ReportIssuesButton.
     * Only visible when the AP slot is connected (caller controls .visible).
     */
    public class SlotSettingsButton extends Sprite {

        /** Called when the button is clicked. Signature: ():void */
        public var onClick:Function;

        public function SlotSettingsButton(btnTemplate:*) {
            super();
            build(btnTemplate);
            buttonMode    = true;
            useHandCursor = true;
            addEventListener(MouseEvent.MOUSE_OVER, onOver,  false, 0, true);
            addEventListener(MouseEvent.MOUSE_OUT,  onOut,   false, 0, true);
            addEventListener(MouseEvent.CLICK,      onClicked, false, 0, true);
        }

        private function build(btnTemplate:*):void {
            var bw:Number = btnTemplate.width;
            var bh:Number = btnTemplate.height;

            var nativeLabel:TextField = findTextField(btnTemplate);
            var originalText:String   = null;
            if (nativeLabel != null) {
                originalText     = nativeLabel.text;
                nativeLabel.text = "AP Settings";
            }

            var bd:BitmapData = new BitmapData(bw, bh, true, 0x00000000);
            var m:Matrix = new Matrix();
            m.tx = -btnTemplate.x;
            m.ty = -btnTemplate.y;
            bd.draw(btnTemplate.parent, m);
            addChild(new Bitmap(bd));

            if (nativeLabel != null) nativeLabel.text = originalText;
        }

        private function onClicked(e:MouseEvent):void {
            if (onClick != null) onClick();
        }

        private function onOver(e:MouseEvent):void {
            filters = [makeBrightnessFilter(1.35)];
        }

        private function onOut(e:MouseEvent):void {
            filters = [];
        }

        private function findTextField(obj:DisplayObject):TextField {
            if (obj is TextField) return obj as TextField;
            if (obj is DisplayObjectContainer) {
                var doc:DisplayObjectContainer = obj as DisplayObjectContainer;
                for (var i:int = 0; i < doc.numChildren; i++) {
                    var result:TextField = findTextField(doc.getChildAt(i));
                    if (result != null) return result;
                }
            }
            return null;
        }

        private function makeBrightnessFilter(scale:Number):ColorMatrixFilter {
            return new ColorMatrixFilter([
                scale, 0,     0,     0, 0,
                0,     scale, 0,     0, 0,
                0,     0,     scale, 0, 0,
                0,     0,     0,     1, 0
            ]);
        }
    }
}

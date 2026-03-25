package {
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;

    /**
     * Temporary debug overlay — three buttons to test each DeathLink punishment
     * without needing a second Archipelago player to trigger one.
     *
     * Show while on the INGAME screen; hide on any other screen.
     * Remove this class once DeathLink is confirmed working.
     */
    public class DeathLinkTestOverlay {

        private static const BTN_W:int   = 110;
        private static const BTN_H:int   = 22;
        private static const BTN_GAP:int = 4;
        private static const OFFSET_X:Number = 10;
        private static const OFFSET_Y:Number = 120;

        private var _handler:DeathLinkHandler;
        private var _stage:Stage;
        private var _container:Sprite;

        public function DeathLinkTestOverlay(handler:DeathLinkHandler) {
            _handler = handler;
        }

        public function show(stage:Stage):void {
            if (_container != null) return;
            _stage = stage;
            _container = new Sprite();
            _container.x = OFFSET_X;
            _container.y = OFFSET_Y;

            addButton(0, "DL: Gem Loss",    0xAA3333, onGemLoss);
            addButton(1, "DL: Wave Surge",  0xAA6600, onWaveSurge);
            addButton(2, "DL: Instant Fail",0x660000, onInstantFail);

            _stage.addChild(_container);
        }

        public function hide():void {
            if (_container == null) return;
            if (_container.parent != null) _container.parent.removeChild(_container);
            _container = null;
        }

        // -----------------------------------------------------------------------

        private function addButton(index:int, label:String,
                                   color:uint, handler:Function):void {
            var btn:Sprite = new Sprite();
            btn.y = index * (BTN_H + BTN_GAP);

            // Background
            btn.graphics.beginFill(color, 0.85);
            btn.graphics.drawRoundRect(0, 0, BTN_W, BTN_H, 6, 6);
            btn.graphics.endFill();

            // Label
            var tf:TextField = new TextField();
            tf.mouseEnabled  = false;
            tf.selectable    = false;
            tf.width         = BTN_W;
            tf.height        = BTN_H;
            var fmt:TextFormat = new TextFormat("_sans", 11, 0xFFFFFF, true);
            fmt.align = "center";
            tf.defaultTextFormat = fmt;
            tf.text = label;
            tf.y    = 3;
            btn.addChild(tf);

            btn.buttonMode   = true;
            btn.useHandCursor = true;
            btn.addEventListener(MouseEvent.CLICK, handler, false, 0, true);

            _container.addChild(btn);
        }

        private function onGemLoss(e:MouseEvent):void    { _handler.testGemLoss(); }
        private function onWaveSurge(e:MouseEvent):void  { _handler.testWaveSurge(); }
        private function onInstantFail(e:MouseEvent):void { _handler.testInstantFail(); }
    }
}

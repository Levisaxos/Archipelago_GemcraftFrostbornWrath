package ui {
    import flash.display.Sprite;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;

    /**
     * A single left-aligned text row inside a ScrollablePanel.
     *
     * Defines `yReal` (ScrollablePanel positions content by that property) and
     * wraps a non-interactive TextField. Used for the Game Elements result list
     * and any simple scrollable label rows.
     */
    public class ScrollRow extends Sprite {

        private static const FONT:String = "Celtic Garamond for GemCraft";

        public var yReal:Number = 0;

        private var _tf:TextField;

        public function ScrollRow(x0:Number, size:int, bold:Boolean) {
            super();
            var fmt:TextFormat = new TextFormat(FONT, size, 0xFFFFFF, bold);

            _tf = new TextField();
            _tf.defaultTextFormat = fmt;
            _tf.selectable    = false;
            _tf.mouseEnabled  = false;
            _tf.antiAliasType = AntiAliasType.ADVANCED;
            _tf.multiline     = false;
            _tf.wordWrap      = false;
            _tf.autoSize      = TextFieldAutoSize.LEFT;
            _tf.x             = x0;
            addChild(_tf);
        }

        public function setText(text:String, color:uint):void {
            _tf.text = text;
            var f:TextFormat = _tf.getTextFormat();
            f.color = color;
            _tf.setTextFormat(f);
        }
    }
}

package ui {
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;

    /**
     * Floating tooltip listing everything present on a field. Shown when the
     * player hovers a field cell in the Game Elements grid.
     *
     * Added on top of the window (so it isn't hidden behind the panel like
     * GV.mcInfoPanel would be). Non-interactive; positioned near the cursor.
     */
    public class FieldTooltip extends Sprite {

        private static const FONT:String       = "Celtic Garamond for GemCraft";
        private static const PAD:Number         = 10;
        private static const BORDER_COLOR:uint  = 0x88CCFF;
        private static const BG_ALPHA:Number    = 0.92;
        private static const HIGHLIGHT_COLOR:uint = 0xFF5A5A;

        private var _bg:Shape;
        private var _title:TextField;
        private var _body:TextField;

        public function FieldTooltip() {
            super();
            mouseEnabled  = false;
            mouseChildren = false;
            visible       = false;

            _bg = new Shape();
            addChild(_bg);

            _title = _makeTf(17, true, 0xFFFFFF);
            _title.x = PAD;
            _title.y = PAD;
            addChild(_title);

            _body = _makeTf(14, false, 0xCFE0EC);
            _body.x = PAD;
            addChild(_body);
        }

        /**
         * Populate + position the tooltip. `atX`/`atY` are in this sprite's
         * parent coordinate space; `maxX` clamps the right edge on-screen.
         * `highlight` is an optional label -> true set; each whole occurrence of a label in the body is coloured red.
         */
        public function showFor(title:String, lines:Array, atX:Number, atY:Number,
                                maxX:Number, highlight:Object = null):void {
            _title.text = title;
            var body:String = (lines != null && lines.length > 0)
                ? lines.join("\n")
                : "(nothing listed)";
            _body.text = body;
            _body.setTextFormat(_body.defaultTextFormat);
            if (highlight != null)
                _highlightTerms(body, highlight);

            _body.y = PAD + _title.height + 4;

            var w:Number = Math.max(_title.width, _body.width) + PAD * 2;
            var h:Number = _body.y + _body.height + PAD;

            _bg.graphics.clear();
            _bg.graphics.beginFill(BORDER_COLOR, 1);
            _bg.graphics.drawRect(0, 0, w, h);
            _bg.graphics.endFill();
            _bg.graphics.beginFill(0x0C141C, BG_ALPHA);
            _bg.graphics.drawRect(1, 1, w - 2, h - 2);
            _bg.graphics.endFill();

            var tx:Number = atX + 16;
            var ty:Number = atY + 12;
            if (tx + w > maxX)
                tx = maxX - w;
            if (tx < 0)
                tx = 0;
            this.x = tx;
            this.y = ty;
            visible = true;
        }

        public function hide():void {
            visible = false;
        }

        /**
         * Colour every whole occurrence of each label red. A match must start a line or follow ": " / ", " and end the line or precede "," / " x" — so "Tower" doesn't hit inside "Wizard Tower" and gem labels match inside the "Gems: a, b" line.
         */
        private function _highlightTerms(body:String, highlight:Object):void {
            var fmt:TextFormat = new TextFormat(null, null, HIGHLIGHT_COLOR);
            for (var term:String in highlight) {
                if (highlight[term] != true || term.length == 0)
                    continue;
                var from:int = 0;
                var at:int;
                while ((at = body.indexOf(term, from)) >= 0) {
                    var end:int = at + term.length;
                    from = end;
                    var before:String = body.substring(Math.max(0, at - 2), at);
                    var startOk:Boolean = at == 0 || body.charAt(at - 1) == "\n"
                        || before == ": " || before == ", ";
                    var endOk:Boolean = end == body.length || body.charAt(end) == "\n"
                        || body.charAt(end) == "," || body.substr(end, 2) == " x";
                    if (startOk && endOk)
                        _body.setTextFormat(fmt, at, end);
                }
            }
        }

        private function _makeTf(size:int, bold:Boolean, color:uint):TextField {
            var fmt:TextFormat = new TextFormat(FONT, size, color, bold);

            var tf:TextField = new TextField();
            tf.defaultTextFormat = fmt;
            tf.selectable    = false;
            tf.mouseEnabled  = false;
            tf.antiAliasType = AntiAliasType.ADVANCED;
            tf.multiline     = true;
            tf.wordWrap      = false;
            tf.autoSize      = TextFieldAutoSize.LEFT;
            return tf;
        }
    }
}

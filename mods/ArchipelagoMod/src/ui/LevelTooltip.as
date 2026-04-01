package ui {
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    /**
     * Small tooltip shown when hovering over the wizard-level XP bar on the selector.
     * Displays the total wizard level, the base (pre-Archipelago) level, and the AP bonus.
     *
     * Usage:
     *   tooltip.show(totalLevel, bonusLevel, xpBarBounds);
     *   tooltip.hide();
     *
     * The sprite is added to `stage` so it renders above all game content.
     * Only visible when bonusLevel > 0.
     */
    public class LevelTooltip extends Sprite {

        private static const FONT:String      = "Celtic Garamond for GemCraft";
        private static const SIZE_LARGE:int   = 17;
        private static const SIZE_SMALL:int   = 14;
        private static const PAD_X:int        = 12;
        private static const PAD_TOP:int      = 9;
        private static const PAD_BOTTOM:int   = 9;
        private static const LINE_GAP:int     = 4;   // px between label and detail line
        private static const BORDER_COLOR:uint = 0x88CCFF;  // AP blue
        private static const BG_ALPHA:Number  = 0.88;
        private static const AP_COLOR:uint    = 0x88CCFF;
        private static const BASE_COLOR:uint  = 0xCCCCCC;
        private static const TITLE_COLOR:uint = 0xFFFFFF;

        private var _bg:Shape;
        private var _titleTf:TextField;
        private var _detailTf:TextField;

        public function LevelTooltip() {
            super();
            mouseEnabled  = false;
            mouseChildren = false;
            visible = false;

            _bg = new Shape();
            addChild(_bg);

            _titleTf = makeTf(SIZE_LARGE, true);
            _titleTf.x = PAD_X;
            _titleTf.y = PAD_TOP;
            addChild(_titleTf);

            _detailTf = makeTf(SIZE_SMALL, false);
            _detailTf.x = PAD_X;
            // y set in show() after title height is known
            addChild(_detailTf);
        }

        // -----------------------------------------------------------------------
        // Public API

        /**
         * Show the tooltip above the XP bar.
         *
         * @param totalLevel   Wizard level the game is currently displaying (1-indexed).
         * @param bonusLevel   How many of those levels came from Archipelago items.
         * @param barBounds    Stage-space bounding rect of the mcXpBar MovieClip.
         * @param stageWidth   Stage width, used to keep the tooltip on-screen.
         */
        public function show(totalLevel:int, bonusLevel:int,
                             barBounds:Rectangle, stageWidth:Number):void {
            if (bonusLevel <= 0) {
                visible = false;
                return;
            }

            var baseLevel:int = totalLevel - bonusLevel;

            // Title: "Wizard Level 42"
            _titleTf.textColor = TITLE_COLOR;
            _titleTf.text = "Wizard Level " + totalLevel;

            // Detail: "Base 37  (+5 from Archipelago)"
            _detailTf.text = "Base " + baseLevel + "  (+" + bonusLevel + " from Archipelago)";

            // Colour "Base X" grey, "(+Y from Archipelago)" in AP blue
            var fmt:TextFormat = new TextFormat();
            fmt.color = BASE_COLOR;
            _detailTf.setTextFormat(fmt, 0, _detailTf.text.length);

            var plusIdx:int = _detailTf.text.indexOf("(");
            if (plusIdx >= 0) {
                var fmtAp:TextFormat = new TextFormat();
                fmtAp.color = AP_COLOR;
                _detailTf.setTextFormat(fmtAp, plusIdx, _detailTf.text.length);
            }

            // Layout
            _detailTf.y = PAD_TOP + _titleTf.height + LINE_GAP;

            redrawBg();

            // Position centred above the XP bar; clamp to stage width.
            var tx:Number = barBounds.x + (barBounds.width - this.width) * 0.5;
            var ty:Number = barBounds.y - this.height - 6;
            if (tx + this.width > stageWidth) tx = stageWidth - this.width - 4;
            if (tx < 0) tx = 4;
            if (ty < 0) ty = barBounds.y + barBounds.height + 6; // flip below if no room above

            this.x = tx;
            this.y = ty;
            visible = true;
        }

        public function hide():void {
            visible = false;
        }

        // -----------------------------------------------------------------------
        // Helpers

        private function makeTf(size:int, bold:Boolean):TextField {
            var fmt:TextFormat = new TextFormat(FONT, size);
            fmt.align = TextFormatAlign.LEFT;
            fmt.bold  = bold;

            var tf:TextField = new TextField();
            tf.mouseEnabled      = false;
            tf.selectable        = false;
            tf.embedFonts        = false;
            tf.antiAliasType     = AntiAliasType.ADVANCED;
            tf.defaultTextFormat = fmt;
            tf.multiline         = false;
            tf.wordWrap          = false;
            tf.autoSize          = TextFieldAutoSize.LEFT;
            return tf;
        }

        private function redrawBg():void {
            _bg.graphics.clear();
            var w:Number = Math.max(_titleTf.width, _detailTf.width) + PAD_X * 2;
            var h:Number = _detailTf.y + _detailTf.height + PAD_BOTTOM;
            _bg.graphics.beginFill(BORDER_COLOR, 1);
            _bg.graphics.drawRect(0, 0, w, h);
            _bg.graphics.endFill();
            _bg.graphics.beginFill(0x000000, BG_ALPHA);
            _bg.graphics.drawRect(1, 1, w - 2, h - 2);
            _bg.graphics.endFill();
        }
    }
}

package ui {
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    /**
     * Notification-style badge that floats at the top-right of the in-level
     * `btnPnlAchis` button. Shows the number of achievements currently in
     * logic (missing AND with all requirements met).
     *
     * Visual style is a small near-black rounded box with a thin light-grey
     * rim — matches the collapsed-button look of the previous in-level
     * achievement panel and the in-game gem tooltip backing.
     */
    public class AchievementsInLogicBadge extends Sprite {

        // Geometry — sized to comfortably fit two-digit counts.
        private static const SIZE:int        = 32;
        private static const CORNER_R:Number = 8;

        // Style mirrors AvailableAchievementsPanel's collapsed-button visual.
        private static const BG_COLOR:uint      = 0x050505;
        private static const BG_ALPHA:Number    = 0.94;
        private static const BORDER_COLOR:uint  = 0xCFCFCF;
        private static const BORDER_ALPHA:Number = 0.95;
        private static const LABEL_COLOR:uint   = 0xFFFFFF;
        private static const FONT:String        = "Celtic Garamond for GemCraft";

        private var _bg:Shape;
        private var _label:TextField;
        private var _currentCount:int = -1;

        public function AchievementsInLogicBadge() {
            super();
            mouseEnabled  = false;
            mouseChildren = false;

            _bg = new Shape();
            _bg.graphics.lineStyle(1, BORDER_COLOR, BORDER_ALPHA);
            _bg.graphics.beginFill(BG_COLOR, BG_ALPHA);
            _bg.graphics.drawRoundRect(0, 0, SIZE, SIZE, CORNER_R * 2, CORNER_R * 2);
            _bg.graphics.endFill();
            addChild(_bg);

            var fmt:TextFormat = new TextFormat(FONT, 15);
            fmt.bold  = true;
            fmt.align = TextFormatAlign.CENTER;
            _label = new TextField();
            _label.mouseEnabled       = false;
            _label.selectable         = false;
            _label.embedFonts         = false;
            _label.antiAliasType      = AntiAliasType.ADVANCED;
            _label.defaultTextFormat  = fmt;
            _label.autoSize           = TextFieldAutoSize.CENTER;
            _label.textColor          = LABEL_COLOR;
            addChild(_label);

            update(0);
        }

        /**
         * Set the displayed count. Cheap to call every frame — only re-lays
         * the textfield when the number actually changes.
         */
        public function update(count:int):void {
            if (count == _currentCount) return;
            _currentCount = count;
            _label.text = String(count);
            // Re-center the label inside the box after autosize re-measures.
            _label.x = (SIZE - _label.width)  * 0.5;
            _label.y = (SIZE - _label.height) * 0.5;
        }

        /** Width of the rendered box (for caller positioning). */
        public function get badgeWidth():Number  { return SIZE; }
        /** Height of the rendered box (for caller positioning). */
        public function get badgeHeight():Number { return SIZE; }
    }
}

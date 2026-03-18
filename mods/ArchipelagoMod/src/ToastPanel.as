package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.PixelSnapping;
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    /**
     * Persistent HUD panel for Archipelago messages.
     * Visual style mirrors McFloaterPanel: semi-transparent dark fill,
     * coloured 1px border, rounded corners cut.
     *
     * Call setLines(texts, colors) to populate or update content.
     */
    public class ToastPanel extends Sprite {

        // Match McFloaterPanel's fill: 0xBB000000 (semi-transparent black)
        private static const BG_COLOR:uint    = 0xBB000000;
        // Archipelago brand purple for the border
        private static const FRAME_COLOR:uint = 0xFF7B52AB;
        private static const FONT:String      = "Celtic Garamond for GemCraft";
        private static const TEXT_SIZE:int    = 11;
        private static const PAD_X:int        = 8;
        private static const PAD_TOP:int      = 10;
        private static const PAD_BOTTOM:int   = 8;
        // Same as McFloaterPanel: nextTfPos += height - 2
        private static const LINE_GAP:Number  = -2;

        public function ToastPanel() {
            super();
            mouseEnabled  = false;
            mouseChildren = false;
        }

        /**
         * Draws (or redraws) the panel with new content.
         * texts  - up to 5 strings
         * colors - matching ARGB colours, one per line
         */
        public function setLines(texts:Array, colors:Array):void {
            removeChildren();

            var fields:Array = [];
            var nextY:Number = PAD_TOP;
            var maxW:Number  = 0;

            for (var i:int = 0; i < texts.length; i++) {
                var fmt:TextFormat   = new TextFormat(FONT, TEXT_SIZE);
                fmt.align            = TextFormatAlign.LEFT;
                fmt.bold             = true;

                var tf:TextField     = new TextField();
                tf.mouseEnabled      = false;
                tf.selectable        = false;
                // embedFonts=false so the panel works even before the game
                // font is in scope; swap to true once confirmed working.
                tf.embedFonts        = false;
                tf.antiAliasType     = AntiAliasType.ADVANCED;
                tf.defaultTextFormat = fmt;
                tf.multiline         = false;
                tf.wordWrap          = false;
                tf.autoSize          = TextFieldAutoSize.LEFT;
                tf.text              = texts[i];
                tf.textColor         = colors[i];
                tf.x                 = PAD_X;
                tf.y                 = nextY;

                maxW   = Math.max(maxW, tf.width + PAD_X * 2);
                nextY += tf.height + LINE_GAP;
                fields.push(tf);
            }

            var pw:int = Math.ceil(maxW);
            var ph:int = Math.ceil(nextY + PAD_BOTTOM);

            // Build background bitmap identical to McFloaterPanel
            var bmpd:BitmapData = new BitmapData(pw, ph, true, FRAME_COLOR);
            bmpd.fillRect(new Rectangle(1, 1, pw - 2, ph - 2), BG_COLOR);
            // Cut corners (McFloaterPanel does the same)
            bmpd.setPixel32(0,      0,      0x00000000);
            bmpd.setPixel32(0,      ph - 1, 0x00000000);
            bmpd.setPixel32(pw - 1, 0,      0x00000000);
            bmpd.setPixel32(pw - 1, ph - 1, 0x00000000);

            // Render text fields onto the background
            for each (var field:TextField in fields) {
                addChild(field);
            }
            bmpd.draw(this);
            removeChildren();

            addChild(new Bitmap(bmpd, PixelSnapping.ALWAYS, false));
        }
    }
}

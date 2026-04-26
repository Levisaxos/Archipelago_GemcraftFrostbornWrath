package ui {
    import flash.display.Bitmap;
    import flash.display.GradientType;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Matrix;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.utils.getTimer;

    /**
     * Top-center HUD panel for items received by the player.
     *
     * Shows one item at a time with an icon on the left and item text
     * on the right. Extras wait in a queue and appear in sequence.
     *
     * Use addItem(text, color) to enqueue a notification.
     * After calling addItem the caller should reposition this sprite so
     * it remains horizontally centered (panelWidth is updated each time
     * a new item is dequeued).
     */
    public class ReceivedToast extends Sprite {

        [Embed(source='../images/IconColorSmall.png')]
        private static const ICON_CLASS:Class;

        // -----------------------------------------------------------------------
        // Layout constants (all in stage pixels, no game-coordinate scaling)

        private static const FONT:String      = "Celtic Garamond for GemCraft";
        private static const TEXT_SIZE:int    = 17;
        private static const ICON_SIZE:int    = 42;
        private static const PAD_X:int        = 18;   // horizontal inner padding
        private static const PAD_Y:int        = 14;   // vertical inner padding
        private static const GAP:int          = 13;   // gap between icon and text
        private static const MIN_TEXT_W:int   = 200;  // minimum text field width
        private static const CORNER_R:Number  = 8;    // rounded corner radius

        // -----------------------------------------------------------------------
        // Timing

        private static const FADE_IN_MS:int   = 300;
        private static const VISIBLE_MS:int   = 2500;
        private static const FADE_OUT_MS:int  = 500;
        private static const TOTAL_MS:int     = FADE_IN_MS + VISIBLE_MS + FADE_OUT_MS;

        // -----------------------------------------------------------------------
        // Visual style

        // Bright AP purple border for a glowing rim effect
        private static const BORDER_COLOR:uint  = 0xCC99FF;
        private static const BORDER_ALPHA:Number = 0.95;
        // Dark purple-black gradient background
        private static const BG_TOP:uint        = 0x291840;
        private static const BG_BOT:uint        = 0x0C0818;
        private static const BG_ALPHA:Number    = 0.92;
        // Subtle lighter top edge to give depth
        private static const SHINE_COLOR:uint   = 0x9966CC;
        private static const SHINE_ALPHA:Number = 0.35;

        // -----------------------------------------------------------------------
        // State

        private var _bg:Shape;
        private var _queue:Array;   // { text:String, color:uint }
        private var _current:Object; // { text:String, color:uint, startTime:int, container:Sprite }

        /** Width of the currently displayed panel in stage pixels.
         *  Updated each time showNext() builds a new container.
         *  Read this after addItem() and reposition accordingly. */
        public var panelWidth:Number = 260;

        // -----------------------------------------------------------------------

        public function ReceivedToast() {
            super();
            mouseEnabled  = false;
            mouseChildren = false;
            alpha         = 0;

            _queue   = [];
            _current = null;
            _bg      = new Shape();
            addChild(_bg);

            addEventListener(Event.ENTER_FRAME, onFrame, false, 0, true);
        }

        // -----------------------------------------------------------------------
        // Public API

        /** Remove the current item and all queued items immediately. */
        public function clear():void {
            if (_current != null && _current.container != null) {
                removeChild(_current.container);
            }
            _current = null;
            _queue.length = 0;
            alpha = 0;
        }

        /**
         * Enqueue an item notification.
         * @param text   The full message string (e.g. "Received Stone of Order")
         * @param color  Text colour as 0xRRGGBB (no alpha component needed)
         */
        public function addItem(text:String, color:uint):void {
            _queue.push({ text: text, color: color });
            if (_current == null) showNext();
        }

        // -----------------------------------------------------------------------
        // Internal

        private function showNext():void {
            if (_queue.length == 0) return;
            var item:Object   = _queue.shift();
            item.startTime    = getTimer();
            item.container    = buildContainer(item.text, item.color);
            addChild(item.container);
            _current = item;
        }

        private function buildContainer(text:String, color:uint):Sprite {
            var c:Sprite    = new Sprite();
            c.mouseEnabled  = false;

            // --- Icon ---
            var bm:Bitmap   = new ICON_CLASS() as Bitmap;
            var longest:Number = Math.max(bm.width || 1, bm.height || 1);
            var sc:Number   = ICON_SIZE / longest;
            bm.scaleX       = sc;
            bm.scaleY       = sc;
            bm.x            = PAD_X;
            bm.y            = PAD_Y;
            c.addChild(bm);

            // --- Text ---
            var fmt:TextFormat  = new TextFormat(FONT, TEXT_SIZE);
            fmt.bold            = true;
            fmt.align           = TextFormatAlign.LEFT;

            var tf:TextField    = new TextField();
            tf.mouseEnabled     = false;
            tf.selectable       = false;
            tf.embedFonts       = false;
            tf.antiAliasType    = AntiAliasType.ADVANCED;
            tf.defaultTextFormat = fmt;
            tf.multiline        = false;
            tf.wordWrap         = false;
            tf.autoSize         = TextFieldAutoSize.LEFT;
            tf.textColor        = color;
            tf.text             = text;

            var iconRight:Number = PAD_X + ICON_SIZE + GAP;
            tf.x = iconRight;
            // vertically center the text on the icon
            tf.y = PAD_Y + (ICON_SIZE - tf.textHeight) * 0.5;
            c.addChild(tf);

            // Panel dimensions
            var textW:Number = Math.max(tf.textWidth + 6, MIN_TEXT_W);
            var totalW:Number = iconRight + textW + PAD_X;
            var totalH:Number = PAD_Y * 2 + ICON_SIZE;

            panelWidth = totalW;
            redrawBg(totalW, totalH);

            return c;
        }

        private function redrawBg(w:Number, h:Number):void {
            _bg.graphics.clear();

            // Gradient fill (top -> bottom: dark purple -> near-black)
            var mat:Matrix = new Matrix();
            mat.createGradientBox(w, h, Math.PI / 2, 0, 0);

            _bg.graphics.lineStyle(1.5, BORDER_COLOR, BORDER_ALPHA);
            _bg.graphics.beginGradientFill(
                GradientType.LINEAR,
                [BG_TOP, BG_BOT],
                [BG_ALPHA, BG_ALPHA],
                [0, 255],
                mat
            );
            _bg.graphics.drawRoundRect(0, 0, w, h, CORNER_R * 2, CORNER_R * 2);
            _bg.graphics.endFill();

            // Subtle top-edge shine -- clear the stroke first so no second border appears
            _bg.graphics.lineStyle(NaN);
            var shineH:Number = Math.ceil(h * 0.22);
            var shineMat:Matrix = new Matrix();
            shineMat.createGradientBox(w - 4, shineH, Math.PI / 2, 2, 2);
            _bg.graphics.beginGradientFill(
                GradientType.LINEAR,
                [SHINE_COLOR, SHINE_COLOR],
                [SHINE_ALPHA, 0],
                [0, 255],
                shineMat
            );
            _bg.graphics.drawRoundRect(2, 2, w - 4, shineH, CORNER_R * 2, CORNER_R * 2);
            _bg.graphics.endFill();
        }

        private function onFrame(e:Event):void {
            if (_current == null) {
                alpha = 0;
                return;
            }

            var elapsed:int = getTimer() - int(_current.startTime);

            if (elapsed >= TOTAL_MS) {
                removeChild(_current.container);
                _current = null;
                alpha = 0;
                if (_queue.length > 0) showNext();
                return;
            }

            if (elapsed < FADE_IN_MS) {
                alpha = elapsed / Number(FADE_IN_MS);
            } else if (elapsed < FADE_IN_MS + VISIBLE_MS) {
                alpha = 1;
            } else {
                alpha = 1 - (elapsed - FADE_IN_MS - VISIBLE_MS) / Number(FADE_OUT_MS);
            }
        }
    }
}

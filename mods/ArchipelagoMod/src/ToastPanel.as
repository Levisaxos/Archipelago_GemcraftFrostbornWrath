package {
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.utils.getTimer;

    /**
     * Persistent HUD panel for Archipelago messages.
     *
     * Holds up to MAX_SLOTS visible rows; extras wait in a queue.
     * Each row fades in, stays visible, then fades out independently.
     * The panel background resizes to fit the current rows and hides
     * automatically when no rows remain.
     */
    public class ToastPanel extends Sprite {

        private static const FONT:String      = "Celtic Garamond for GemCraft";
        private static const TEXT_SIZE:int    = 11;
        private static const PAD_X:int        = 8;
        private static const PAD_TOP:int      = 8;
        private static const PAD_BOTTOM:int   = 8;
        private static const SLOT_HEIGHT:int  = 18;
        private static const MIN_WIDTH:int    = 160;
        private static const MAX_SLOTS:int    = 5;

        private static const FADE_IN_MS:int   = 500;
        private static const VISIBLE_MS:int   = 5000;
        private static const FADE_OUT_MS:int  = 1000;
        private static const TOTAL_MS:int     = FADE_IN_MS + VISIBLE_MS + FADE_OUT_MS;

        // Dark fill + Archipelago purple border
        private static const BG_ALPHA:Number  = 0.73; // 0xBB / 0xFF
        private static const BORDER_COLOR:uint = 0x7B52AB;

        private var _bg:Shape;
        private var _slots:Array;  // { row:Sprite, startTime:int }
        private var _queue:Array;  // { text:String, color:uint }

        public function ToastPanel() {
            super();
            mouseEnabled  = false;
            mouseChildren = false;
            alpha = 0;

            _bg    = new Shape();
            _slots = [];
            _queue = [];
            addChild(_bg);

            addEventListener(Event.ENTER_FRAME, onFrame, false, 0, true);
        }

        // -----------------------------------------------------------------------
        // Public API

        /**
         * Enqueue a message. Shows immediately if a slot is free,
         * otherwise waits until a slot becomes available.
         */
        public function addMessage(text:String, color:uint):void {
            if (_slots.length < MAX_SLOTS) {
                addSlot(text, color);
            } else {
                _queue.push({ text: text, color: color });
            }
        }

        // -----------------------------------------------------------------------
        // Internal

        private function addSlot(text:String, color:uint):void {
            var fmt:TextFormat   = new TextFormat(FONT, TEXT_SIZE);
            fmt.align            = TextFormatAlign.LEFT;
            fmt.bold             = true;

            var tf:TextField     = new TextField();
            tf.mouseEnabled      = false;
            tf.selectable        = false;
            tf.embedFonts        = false;
            tf.antiAliasType     = AntiAliasType.ADVANCED;
            tf.defaultTextFormat = fmt;
            tf.multiline         = false;
            tf.wordWrap          = false;
            tf.autoSize          = TextFieldAutoSize.LEFT;
            tf.textColor         = color;
            tf.text              = text;
            tf.x                 = PAD_X;
            tf.y                 = 0;

            var row:Sprite = new Sprite();
            row.mouseEnabled = false;
            row.addChild(tf);
            row.alpha = 0;

            _slots.push({ row: row, startTime: getTimer() });
            addChild(row);

            layoutSlots();
            redrawBg();
        }

        private function layoutSlots():void {
            for (var i:int = 0; i < _slots.length; i++) {
                _slots[i].row.y = PAD_TOP + i * SLOT_HEIGHT;
            }
        }

        private function redrawBg():void {
            _bg.graphics.clear();
            var n:int = _slots.length;
            if (n == 0) return;

            // Compute width from widest current row
            var pw:Number = MIN_WIDTH;
            for (var i:int = 0; i < n; i++) {
                var tf:TextField = TextField(_slots[i].row.getChildAt(0));
                pw = Math.max(pw, tf.width + PAD_X * 2);
            }
            pw = Math.ceil(pw);
            var ph:int = PAD_TOP + n * SLOT_HEIGHT + PAD_BOTTOM;

            _bg.graphics.beginFill(BORDER_COLOR, 1);
            _bg.graphics.drawRect(0, 0, pw, ph);
            _bg.graphics.endFill();
            _bg.graphics.beginFill(0x000000, BG_ALPHA);
            _bg.graphics.drawRect(1, 1, pw - 2, ph - 2);
            _bg.graphics.endFill();
        }

        private function onFrame(e:Event):void {
            if (_slots.length == 0) {
                alpha = 0;
                return;
            }

            alpha = 1;

            var changed:Boolean = false;

            // Iterate backwards so splicing doesn't affect unvisited indices
            for (var i:int = _slots.length - 1; i >= 0; i--) {
                var slot:Object = _slots[i];
                var elapsed:int = getTimer() - slot.startTime;

                if (elapsed >= TOTAL_MS) {
                    removeChild(slot.row);
                    _slots.splice(i, 1);
                    changed = true;
                } else if (elapsed >= FADE_IN_MS + VISIBLE_MS) {
                    slot.row.alpha = 1 - (elapsed - FADE_IN_MS - VISIBLE_MS) / FADE_OUT_MS;
                } else if (elapsed >= FADE_IN_MS) {
                    slot.row.alpha = 1;
                } else {
                    slot.row.alpha = elapsed / FADE_IN_MS;
                }
            }

            if (changed) {
                // Fill freed slots from the queue
                while (_slots.length < MAX_SLOTS && _queue.length > 0) {
                    var pending:Object = _queue.shift();
                    addSlot(pending.text, pending.color);
                }
                layoutSlots();
                redrawBg();
            }
        }
    }
}

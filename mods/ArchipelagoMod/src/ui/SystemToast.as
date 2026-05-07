package ui {
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.utils.getTimer;

    import ui.MessageLog;

    /**
     * Persistent HUD panel for Archipelago system messages.
     *
     * Shows sent-item confirmations, connection status, DeathLink events,
     * chat from the AP server, and other non-item notifications.
     *
     * Holds up to MAX_SLOTS visible rows; extras wait in a queue.
     * Each row fades in, stays visible, then fades out independently.
     * The panel background resizes to fit the current rows and hides
     * automatically when no rows remain.
     */
    public class SystemToast extends Sprite {

        private static const FONT:String      = "Celtic Garamond for GemCraft";
        private static const TEXT_SIZE:int    = 17;
        private static const PAD_X:int        = 14;
        private static const PAD_TOP:int      = 11;
        private static const PAD_BOTTOM:int   = 11;
        private static const SLOT_HEIGHT:int  = 26;
        private static const MIN_WIDTH:int    = 220;
        private static const MAX_SLOTS:int    = 5;

        private static const FADE_IN_MS:int   = 500;
        private static const VISIBLE_MS:int   = 5000;
        private static const FADE_OUT_MS:int  = 1000;
        private static const TOTAL_MS:int     = FADE_IN_MS + VISIBLE_MS + FADE_OUT_MS;

        // Dark fill + neutral system-console border. Body text defaults to
        // white; coloured segments are emitted via htmlText (see addRichMessage)
        // so item names can carry their Archipelago importance colour while
        // the surrounding message stays readable.
        private static const BG_ALPHA:Number    = 0.85;
        private static const BORDER_COLOR:uint  = 0x444444;
        private static const DEFAULT_TEXT:uint  = 0xFFFFFF;

        private var _bg:Shape;
        private var _slots:Array;  // { row:Sprite, startTime:int }
        private var _queue:Array;  // { text:String, color:uint }
        private var _messageLog:MessageLog;

        public function SystemToast() {
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

        /** Attach a MessageLog so every message is recorded for the log panel. */
        public function set messageLog(log:MessageLog):void {
            _messageLog = log;
        }

        /** Remove all visible and queued messages immediately. */
        public function clear():void {
            for (var i:int = _slots.length - 1; i >= 0; i--) {
                removeChild(_slots[i].row);
            }
            _slots.length = 0;
            _queue.length = 0;
            _bg.graphics.clear();
            alpha = 0;
        }

        /**
         * Enqueue a plain-text message in a single colour. Shows immediately
         * if a slot is free, otherwise waits.
         */
        public function addMessage(text:String, color:uint):void {
            if (_messageLog != null) {
                _messageLog.add(text, color, MessageLog.SOURCE_SYSTEM);
            }
            if (_slots.length < MAX_SLOTS) {
                addSlot(text, null, color);
            } else {
                _queue.push({ text: text, html: null, color: color });
            }
        }

        /**
         * Enqueue a rich message rendered via TextField.htmlText. The body
         * defaults to white; embed `<font color="#XXXXXX">…</font>` to
         * colour individual segments (e.g. item names by importance).
         * Only the on-screen overlay slot is populated — callers that also
         * want a MessageLog entry must call MessageLog.add() themselves
         * (typically with their own resolved HTML), which avoids duplicates
         * when the log already records a richer version of the same event.
         */
        public function addRichMessage(html:String, plain:String, plainColor:uint = DEFAULT_TEXT):void {
            if (_slots.length < MAX_SLOTS) {
                addSlot(plain, html, plainColor);
            } else {
                _queue.push({ text: plain, html: html, color: plainColor });
            }
        }

        // -----------------------------------------------------------------------
        // Internal

        private function addSlot(text:String, html:String, color:uint):void {
            var fmt:TextFormat   = new TextFormat(FONT, TEXT_SIZE);
            fmt.align            = TextFormatAlign.LEFT;
            fmt.bold             = true;
            fmt.color            = color;

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
            if (html != null) {
                tf.htmlText      = html;
            } else {
                tf.text          = text;
            }
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
                    addSlot(pending.text, pending.html, pending.color);
                }
                layoutSlots();
                redrawBg();
            }
        }
    }
}

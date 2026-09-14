package ui {

    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.TextEvent;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.ui.Keyboard;

    import ui.MessageLog;

    /**
     * Full-screen overlay that shows the message log history and lets the
     * player talk to the Archipelago server.
     *
     * Toggled by the backtick key. Chat order: oldest at the top, newest on the
     * last row above the input, and the wheel scrolls back through history. The
     * input row at the bottom sends Say packets, so server commands such as
     * !hint <item> work without alt-tabbing to a separate text client.
     *
     * While the panel is open it installs a capture-phase key listener on the
     * stage that swallows every keystroke, so typing a hint mid-battle cannot
     * leak into the game's gem and wave hotkeys.
     */
    public class MessageLogPanel extends Sprite {

        private static const FONT:String      = "Celtic Garamond for GemCraft";
        private static const TEXT_SIZE:int    = 15;
        private static const LINE_HEIGHT:int  = 22;
        private static const PAD_X:int        = 24;
        private static const PAD_Y:int        = 18;
        private static const HEADER_H:int     = 40;
        private static const SCROLL_STEP:int  = 3; // lines per wheel tick

        // Input row
        private static const INPUT_H:int      = 26;
        private static const INPUT_GAP:int    = 10; // gap between log area and input
        private static const PROMPT_W:int     = 18;
        private static const MAX_HISTORY:int  = 50;

        // Visual style — neutral system-console palette so item-importance
        // colours embedded inside individual entries stand out rather than
        // fighting the panel chrome.
        private static const BG_COLOR:uint     = 0x000000;
        private static const BG_ALPHA:Number   = 0.92;
        private static const BORDER_COLOR:uint = 0x444444;
        private static const HEADER_COLOR:uint = 0xFFFFFF;
        private static const TIME_COLOR:uint   = 0x888888;
        private static const PROMPT_COLOR:uint = 0x88CC88;
        private static const INPUT_BG:uint     = 0x151515;
        private static const INPUT_BORDER:uint = 0x555555;
        private static const INPUT_TEXT:uint   = 0xEEEEEE;

        /** Called with the typed line when the player presses Enter. Signature: (text:String):void */
        public var onSubmit:Function;

        private var _log:MessageLog;
        private var _bg:Shape;
        private var _header:TextField;
        private var _content:Sprite;   // container for message rows
        private var _mask:Shape;       // clip mask for content area
        private var _prompt:TextField; // ">" marker in front of the input
        private var _input:TextField;  // chat / command entry
        private var _scrollOffset:int; // topmost visible line index (0 = oldest)
        private var _visibleLines:int;
        private var _isOpen:Boolean;

        private var _renderedLen:int;  // _log.length at the last redraw
        private var _history:Array;    // previously submitted lines, oldest first
        private var _historyIdx:int;   // browse cursor; == _history.length means "new line"

        // Stage the key blocker is attached to. Cached so close() can detach it
        // even if the panel has already been pulled off the display list.
        private var _keyStage:Stage;

        private var _panelW:Number;
        private var _panelH:Number;

        public function MessageLogPanel(log:MessageLog) {
            super();
            _log = log;
            _isOpen = false;
            _scrollOffset = 0;
            _history = [];
            _historyIdx = 0;
            mouseEnabled = true;
            mouseChildren = true;

            _bg = new Shape();
            addChild(_bg);

            // Header
            var fmt:TextFormat = new TextFormat(FONT, TEXT_SIZE + 2);
            fmt.bold = true;
            fmt.align = TextFormatAlign.LEFT;

            _header = new TextField();
            _header.mouseEnabled = false;
            _header.selectable = false;
            _header.embedFonts = false;
            _header.antiAliasType = AntiAliasType.ADVANCED;
            _header.defaultTextFormat = fmt;
            _header.autoSize = TextFieldAutoSize.LEFT;
            _header.textColor = HEADER_COLOR;
            _header.text = "Archipelago Message Log";
            _header.x = PAD_X;
            _header.y = 8;
            addChild(_header);

            // Content container
            _content = new Sprite();
            _content.mouseEnabled = false;
            _content.mouseChildren = false;
            addChild(_content);

            // Mask for content area
            _mask = new Shape();
            addChild(_mask);
            _content.mask = _mask;

            // Input row — added after the mask so it is never clipped.
            var promptFmt:TextFormat = new TextFormat("_sans", 14, PROMPT_COLOR, true);
            _prompt = new TextField();
            _prompt.mouseEnabled = false;
            _prompt.selectable = false;
            _prompt.defaultTextFormat = promptFmt;
            _prompt.autoSize = TextFieldAutoSize.LEFT;
            _prompt.text = ">";
            addChild(_prompt);

            var inputFmt:TextFormat = new TextFormat("_sans", 14, INPUT_TEXT);
            _input = new TextField();
            _input.type              = TextFieldType.INPUT;
            _input.multiline         = false;
            _input.wordWrap          = false;
            _input.maxChars          = 400;
            _input.defaultTextFormat = inputFmt;
            _input.background        = true;
            _input.backgroundColor   = INPUT_BG;
            _input.border            = true;
            _input.borderColor       = INPUT_BORDER;
            _input.height            = INPUT_H;
            addChild(_input);

            // The backtick that toggles the panel must never land in the field.
            _input.addEventListener(TextEvent.TEXT_INPUT, onTextInput);

            visible = false;
        }

        public function get isOpen():Boolean { return _isOpen; }

        /** Show the log overlay, sized to stage. */
        public function open(stageW:Number, stageH:Number):void {
            _panelW = stageW;
            _panelH = stageH;
            _isOpen = true;
            visible = true;

            // Offset 0 == pinned to the newest message at the bottom.
            _visibleLines = computeVisibleLines();
            _scrollOffset = 0;

            redraw();
            addEventListener(MouseEvent.MOUSE_WHEEL, onWheel, false, 0, true);
            addEventListener(MouseEvent.MOUSE_DOWN, onPanelMouseDown, false, 0, true);
            addEventListener(Event.ENTER_FRAME, onTick, false, 0, true);

            // Capture phase at top priority: we see every key before the game's
            // own stage listeners do, and stop it there.
            if (this.stage != null) {
                _keyStage = this.stage;
                _keyStage.addEventListener(KeyboardEvent.KEY_DOWN, onStageKeyCapture, true, int.MAX_VALUE, true);
                _keyStage.focus = _input;
            }
            _historyIdx = _history.length;
        }

        /** Hide the log overlay. */
        public function close():void {
            _isOpen = false;
            visible = false;
            removeEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
            removeEventListener(MouseEvent.MOUSE_DOWN, onPanelMouseDown);
            removeEventListener(Event.ENTER_FRAME, onTick);
            if (_keyStage != null) {
                _keyStage.removeEventListener(KeyboardEvent.KEY_DOWN, onStageKeyCapture, true);
                if (_keyStage.focus == _input)
                    _keyStage.focus = null;
                _keyStage = null;
            }
            _input.text = "";
        }

        /** Toggle open/close. Returns new open state. */
        public function toggle(stageW:Number, stageH:Number):Boolean {
            if (_isOpen) {
                close();
            } else {
                open(stageW, stageH);
            }
            return _isOpen;
        }

        /** Call when stage resizes while open. */
        public function resize(stageW:Number, stageH:Number):void {
            if (!_isOpen)
                return;
            _panelW = stageW;
            _panelH = stageH;
            _visibleLines = computeVisibleLines();
            _scrollOffset = Math.min(_scrollOffset, Math.max(0, _log.length - _visibleLines));
            redraw();
        }

        /**
         * Redraw when the log grew, so a server reply to something just typed
         * shows up without closing and reopening the panel. When the player has
         * scrolled back the offset advances with the new entries, keeping the
         * same messages on screen instead of sliding them out of view.
         */
        private function onTick(e:Event):void {
            if (!_isOpen || _log.length == _renderedLen)
                return;
            if (_scrollOffset > 0)
                _scrollOffset += (_log.length - _renderedLen);
            redraw();
        }

        // -----------------------------------------------------------------------
        // Input

        private function onStageKeyCapture(e:KeyboardEvent):void {
            if (!_isOpen)
                return;

            // Nothing typed here reaches the game — no gem hotkeys, no wave calls.
            e.stopImmediatePropagation();

            if (e.keyCode == 192 || e.keyCode == Keyboard.ESCAPE) {
                // Stopping propagation also robs Main.preventEsc of its chance
                // to cancel the default, which would drop out of fullscreen.
                if (e.keyCode == Keyboard.ESCAPE)
                    e.preventDefault();
                close();
                return;
            }
            if (e.keyCode == Keyboard.ENTER) {
                submit();
                return;
            }
            if (e.keyCode == Keyboard.UP) {
                browseHistory(-1);
                return;
            }
            if (e.keyCode == Keyboard.DOWN) {
                browseHistory(1);
                return;
            }
            if (e.keyCode == Keyboard.PAGE_UP) {
                scrollBy(SCROLL_STEP);
                return;
            }
            if (e.keyCode == Keyboard.PAGE_DOWN) {
                scrollBy(-SCROLL_STEP);
                return;
            }
        }

        /** Swallow the panel's own toggle key so it never lands in the field. */
        private function onTextInput(e:TextEvent):void {
            if (e.text == "`" || e.text == "~")
                e.preventDefault();
        }

        /** Clicking anywhere on the overlay puts the caret back in the input. */
        private function onPanelMouseDown(e:MouseEvent):void {
            if (e.target != _input && _keyStage != null)
                _keyStage.focus = _input;
        }

        private function submit():void {
            var text:String = trim(_input.text);
            _input.text = "";
            if (text.length == 0)
                return;

            _history.push(text);
            if (_history.length > MAX_HISTORY)
                _history.shift();
            _historyIdx = _history.length;

            if (onSubmit != null)
                onSubmit(text);
        }

        /** Step through submitted lines. dir -1 = older, +1 = newer. */
        private function browseHistory(dir:int):void {
            if (_history.length == 0)
                return;
            _historyIdx += dir;
            if (_historyIdx < 0)
                _historyIdx = 0;
            if (_historyIdx > _history.length)
                _historyIdx = _history.length;

            _input.text = (_historyIdx == _history.length) ? "" : String(_history[_historyIdx]);
            _input.setSelection(_input.length, _input.length);
        }

        private static function trim(s:String):String {
            if (s == null)
                return "";
            var start:int = 0;
            var end:int = s.length;
            while (start < end && s.charCodeAt(start) <= 32) start++;
            while (end > start && s.charCodeAt(end - 1) <= 32) end--;
            return s.substring(start, end);
        }

        // -----------------------------------------------------------------------

        private function onWheel(e:MouseEvent):void {
            // Newest entries render at the bottom, so wheel-up walks back
            // through history and wheel-down returns toward the newest.
            scrollBy(e.delta > 0 ? SCROLL_STEP : -SCROLL_STEP);
        }

        private function scrollBy(lines:int):void {
            _scrollOffset += lines;
            _scrollOffset = Math.max(0, Math.min(_scrollOffset, Math.max(0, _log.length - _visibleLines)));
            redraw();
        }

        private function computeVisibleLines():int {
            return Math.floor((_panelH - HEADER_H - PAD_Y * 2 - INPUT_H - INPUT_GAP) / LINE_HEIGHT);
        }

        private function redraw():void {
            _renderedLen = _log.length;
            _scrollOffset = Math.max(0, Math.min(_scrollOffset, Math.max(0, _log.length - _visibleLines)));

            // Background
            _bg.graphics.clear();
            _bg.graphics.beginFill(BG_COLOR, BG_ALPHA);
            _bg.graphics.lineStyle(1.5, BORDER_COLOR, 0.8);
            _bg.graphics.drawRect(0, 0, _panelW, _panelH);
            _bg.graphics.endFill();

            var logAreaH:Number = _panelH - HEADER_H - PAD_Y - INPUT_H - INPUT_GAP;

            // Mask
            _mask.graphics.clear();
            _mask.graphics.beginFill(0xFF0000);
            _mask.graphics.drawRect(0, HEADER_H, _panelW, logAreaH);
            _mask.graphics.endFill();

            // Input row, pinned to the bottom
            var inputY:Number = _panelH - PAD_Y - INPUT_H;
            _prompt.x = PAD_X;
            _prompt.y = inputY + 3;
            _input.x = PAD_X + PROMPT_W;
            _input.y = inputY;
            _input.width = Math.max(80, _panelW - PAD_X * 2 - PROMPT_W);

            // Clear old rows
            while (_content.numChildren > 0) {
                _content.removeChildAt(0);
            }

            var fmt:TextFormat = new TextFormat(FONT, TEXT_SIZE);
            fmt.bold = true;
            fmt.align = TextFormatAlign.LEFT;

            var timeFmt:TextFormat = new TextFormat(FONT, TEXT_SIZE - 2);
            timeFmt.bold = false;
            timeFmt.align = TextFormatAlign.LEFT;

            // Chat order: oldest at the top, newest on the last row above the
            // input. _scrollOffset counts entries hidden past the bottom edge,
            // so 0 means "pinned to the newest message".
            var endIdx:int   = _log.length - _scrollOffset;          // exclusive
            var startIdx:int = Math.max(0, endIdx - _visibleLines);
            var shown:int    = endIdx - startIdx;

            // Anchor the block to the bottom so a short log sits just above the
            // input rather than floating under the header.
            var yPos:Number = HEADER_H + logAreaH - shown * LINE_HEIGHT;

            for (var i:int = startIdx; i < endIdx; i++) {
                var entry:Object = _log.getEntry(i);
                var d:Date = entry.time as Date;

                // Timestamp
                var timeStr:String = pad2(d.getHours()) + ":" + pad2(d.getMinutes()) + ":" + pad2(d.getSeconds());
                var tag:String = entry.source == MessageLog.SOURCE_SYSTEM ? "[SYS]" : "[COL]";

                var timeTf:TextField = makeField(timeFmt, TIME_COLOR);
                timeTf.text = timeStr + " " + tag;
                timeTf.x = PAD_X;
                timeTf.y = yPos;
                _content.addChild(timeTf);

                // Message text — rich entries render via htmlText so embedded
                // <font color> tags from ItemSend messages can colour item
                // names by importance; plain entries draw in entry.color.
                var msgTf:TextField = makeField(fmt, entry.color);
                if (entry.html != null) {
                    msgTf.htmlText = String(entry.html);
                } else {
                    msgTf.text = entry.text;
                }
                msgTf.x = PAD_X + 120;
                msgTf.y = yPos;
                _content.addChild(msgTf);

                yPos += LINE_HEIGHT;
            }

            // Scroll indicator
            var help:String = "  (` to close, scroll to browse, Enter to send - try !help)";
            if (_log.length > _visibleLines) {
                _header.text = "Archipelago Message Log" + help + "  ["
                    + shown + " of " + _log.length + "]";
            } else {
                _header.text = "Archipelago Message Log" + help + "  [" + _log.length + " messages]";
            }
        }

        private function makeField(fmt:TextFormat, color:uint):TextField {
            var tf:TextField = new TextField();
            tf.mouseEnabled = false;
            tf.selectable = false;
            tf.embedFonts = false;
            tf.antiAliasType = AntiAliasType.ADVANCED;
            tf.defaultTextFormat = fmt;
            tf.autoSize = TextFieldAutoSize.LEFT;
            tf.textColor = color;
            return tf;
        }

        private static function pad2(n:int):String {
            return n < 10 ? "0" + n : String(n);
        }
    }
}

package {

    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    /**
     * Full-screen overlay that shows the message log history.
     *
     * Toggled by the backtick key. Scrollable via mouse wheel.
     * Newest messages appear at the bottom; panel auto-scrolls
     * to bottom on open.
     */
    public class MessageLogPanel extends Sprite {

        private static const FONT:String      = "Celtic Garamond for GemCraft";
        private static const TEXT_SIZE:int    = 15;
        private static const LINE_HEIGHT:int  = 22;
        private static const PAD_X:int        = 24;
        private static const PAD_Y:int        = 18;
        private static const HEADER_H:int     = 40;
        private static const SCROLL_STEP:int  = 3; // lines per wheel tick

        // Visual style
        private static const BG_COLOR:uint     = 0x0C0818;
        private static const BG_ALPHA:Number   = 0.92;
        private static const BORDER_COLOR:uint = 0x9966CC;
        private static const HEADER_COLOR:uint = 0xCC99FF;
        private static const TIME_COLOR:uint   = 0x887799;

        private var _log:MessageLog;
        private var _bg:Shape;
        private var _header:TextField;
        private var _content:Sprite;   // container for message rows
        private var _mask:Shape;       // clip mask for content area
        private var _scrollOffset:int; // topmost visible line index (0 = oldest)
        private var _visibleLines:int;
        private var _isOpen:Boolean;

        private var _panelW:Number;
        private var _panelH:Number;

        public function MessageLogPanel(log:MessageLog) {
            super();
            _log = log;
            _isOpen = false;
            _scrollOffset = 0;
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
            _header.text = "Archipelago Message Log  (` to close, scroll to browse)";
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

            visible = false;
        }

        public function get isOpen():Boolean { return _isOpen; }

        /** Show the log overlay, sized to stage. */
        public function open(stageW:Number, stageH:Number):void {
            _panelW = stageW;
            _panelH = stageH;
            _isOpen = true;
            visible = true;

            // Scroll to bottom (newest)
            _visibleLines = Math.floor((_panelH - HEADER_H - PAD_Y * 2) / LINE_HEIGHT);
            _scrollOffset = Math.max(0, _log.length - _visibleLines);

            redraw();
            addEventListener(MouseEvent.MOUSE_WHEEL, onWheel, false, 0, true);
        }

        /** Hide the log overlay. */
        public function close():void {
            _isOpen = false;
            visible = false;
            removeEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
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
            if (!_isOpen) return;
            _panelW = stageW;
            _panelH = stageH;
            _visibleLines = Math.floor((_panelH - HEADER_H - PAD_Y * 2) / LINE_HEIGHT);
            _scrollOffset = Math.min(_scrollOffset, Math.max(0, _log.length - _visibleLines));
            redraw();
        }

        // -----------------------------------------------------------------------

        private function onWheel(e:MouseEvent):void {
            // delta > 0 = scroll up, delta < 0 = scroll down
            _scrollOffset -= e.delta > 0 ? SCROLL_STEP : -SCROLL_STEP;
            _scrollOffset = Math.max(0, Math.min(_scrollOffset, Math.max(0, _log.length - _visibleLines)));
            redraw();
        }

        private function redraw():void {
            // Background
            _bg.graphics.clear();
            _bg.graphics.beginFill(BG_COLOR, BG_ALPHA);
            _bg.graphics.lineStyle(1.5, BORDER_COLOR, 0.8);
            _bg.graphics.drawRect(0, 0, _panelW, _panelH);
            _bg.graphics.endFill();

            // Mask
            _mask.graphics.clear();
            _mask.graphics.beginFill(0xFF0000);
            _mask.graphics.drawRect(0, HEADER_H, _panelW, _panelH - HEADER_H - PAD_Y);
            _mask.graphics.endFill();

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

            var yPos:Number = HEADER_H + PAD_Y;
            var end:int = Math.min(_scrollOffset + _visibleLines, _log.length);

            for (var i:int = _scrollOffset; i < end; i++) {
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

                // Message text
                var msgTf:TextField = makeField(fmt, entry.color);
                msgTf.text = entry.text;
                msgTf.x = PAD_X + 120;
                msgTf.y = yPos;
                _content.addChild(msgTf);

                yPos += LINE_HEIGHT;
            }

            // Scroll indicator
            if (_log.length > _visibleLines) {
                var pct:int = _log.length <= _visibleLines ? 100
                    : Math.round((_scrollOffset + _visibleLines) / _log.length * 100);
                _header.text = "Archipelago Message Log  (` to close, scroll to browse)  ["
                    + (_scrollOffset + 1) + "-" + end + " of " + _log.length + "]";
            } else {
                _header.text = "Archipelago Message Log  (` to close)  [" + _log.length + " messages]";
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

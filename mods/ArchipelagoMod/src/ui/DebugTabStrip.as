package ui {

    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    /**
     * Horizontal tab strip used at the top of the Archipelago Debug menu.
     *
     * Built once with a list of label strings; clicking a tab fires onSelect(index).
     * The owner is responsible for swapping the visible content list when notified.
     *
     * Tabs sit inside the McOptions chrome at a fixed Y. Each tab is a rounded-rect
     * with a label centred inside; the active tab uses a brighter fill and stays
     * highlighted until another tab is clicked.
     */
    public class DebugTabStrip extends Sprite {

        // Visual constants
        public static const TAB_HEIGHT:Number   = 32;
        private static const TAB_GAP:Number     = 4;

        private static const COL_BG:uint        = 0x1c1428;
        private static const COL_BG_HOVER:uint  = 0x332244;
        private static const COL_BG_ACTIVE:uint = 0x664488;
        private static const COL_BORDER:uint    = 0x9966cc;
        private static const COL_TEXT:uint      = 0xeeddff;
        private static const COL_TEXT_DIM:uint  = 0x998899;

        public var onSelect:Function; // function(index:int):void

        private var _tabs:Array;       // Sprite[]
        private var _active:int = 0;
        private var _tabW:Number;

        public function DebugTabStrip(labels:Array, x:Number, y:Number, stripWidth:Number = 980) {
            super();
            this.x = x;
            this.y = y;

            _tabs = [];
            var n:int = labels.length;
            _tabW = (stripWidth - TAB_GAP * (n - 1)) / n;

            for (var i:int = 0; i < n; i++) {
                var tab:Sprite = _buildTab(String(labels[i]), i);
                tab.x = i * (_tabW + TAB_GAP);
                tab.y = 0;
                _tabs.push(tab);
                addChild(tab);
            }
            _paint(0, true);
        }

        public function get activeIndex():int { return _active; }

        public function setActive(index:int, fireCallback:Boolean = false):void {
            if (index < 0 || index >= _tabs.length || index == _active) {
                if (fireCallback && index == _active && onSelect != null) onSelect(_active);
                return;
            }
            _paint(_active, false);
            _active = index;
            _paint(_active, true);
            if (fireCallback && onSelect != null) onSelect(_active);
        }

        private function _buildTab(label:String, idx:int):Sprite {
            var tab:Sprite = new Sprite();
            tab.buttonMode = true;
            tab.useHandCursor = true;
            tab.mouseChildren = false;

            var fmt:TextFormat = new TextFormat("Celtic Garamond for GemCraft", 16, COL_TEXT, true);
            fmt.align = TextFormatAlign.CENTER;
            var tf:TextField = new TextField();
            tf.defaultTextFormat = fmt;
            tf.embedFonts   = false;
            tf.selectable   = false;
            tf.mouseEnabled = false;
            tf.autoSize     = TextFieldAutoSize.NONE;
            tf.width  = _tabW;
            tf.height = TAB_HEIGHT;
            tf.textColor = COL_TEXT;
            tf.text = label;
            tf.y = (TAB_HEIGHT - tf.textHeight) * 0.5 - 2;
            tab.addChild(tf);

            // Capture index in closure
            var captured:int = idx;
            tab.addEventListener(MouseEvent.CLICK,
                function(e:MouseEvent):void { setActive(captured, true); },
                false, 0, true);
            tab.addEventListener(MouseEvent.MOUSE_OVER,
                function(e:MouseEvent):void { if (captured != _active) _paintTab(captured, false, true); },
                false, 0, true);
            tab.addEventListener(MouseEvent.MOUSE_OUT,
                function(e:MouseEvent):void { if (captured != _active) _paintTab(captured, false, false); },
                false, 0, true);
            return tab;
        }

        private function _paint(index:int, active:Boolean):void {
            _paintTab(index, active, false);
        }

        private function _paintTab(index:int, active:Boolean, hover:Boolean):void {
            var tab:Sprite = _tabs[index] as Sprite;
            if (tab == null) return;

            // Repaint background under the existing TextField child.
            // The TextField is at index 0 (added first), graphics draws beneath it
            // because Sprite.graphics renders before any child.
            tab.graphics.clear();
            var fill:uint = active ? COL_BG_ACTIVE : (hover ? COL_BG_HOVER : COL_BG);
            tab.graphics.beginFill(fill);
            tab.graphics.lineStyle(1, COL_BORDER, active ? 1.0 : 0.6);
            tab.graphics.drawRoundRect(0, 0, _tabW, TAB_HEIGHT, 6, 6);
            tab.graphics.endFill();

            // Tint label
            if (tab.numChildren > 0) {
                var tf:TextField = tab.getChildAt(0) as TextField;
                if (tf != null) tf.textColor = active ? COL_TEXT : COL_TEXT_DIM;
            }
        }
    }
}

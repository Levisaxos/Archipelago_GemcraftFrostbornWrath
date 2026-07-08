package ui {

    import com.giab.games.gcfw.mcDyn.BtnAchiFilter;

    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    /**
     * Horizontal tab strip used at the top of the AP Debug Menu.
     *
     * Built once with a list of label strings; clicking a tab fires onSelect(index).
     * The owner is responsible for swapping the visible content list when notified.
     *
     * Each tab IS a native game button — BtnAchiFilter, the same selectable button
     * the game uses for its achievement filters. Its plate MovieClip carries the
     * real button art with the game's own state frames:
     *   1 = normal, 2 = hover, 3 = selected/active, 4 = pressed.
     * We drive those frames directly so the tabs highlight on hover and stay lit
     * while active, exactly like the game's buttons.
     *
     * The plate is scaled horizontally to the tab width and its native label is
     * hidden in favour of our own centred TextField (so the label text stays crisp
     * rather than being squished with the plate).
     */
    public class DebugTabStrip extends Sprite {

        public static const TAB_HEIGHT:Number   = 32; // informational; native plate sets real height
        private static const TAB_GAP:Number     = 6;

        // Label colours per state (the plate art supplies the fill/border).
        private static const TX_NORMAL:uint = 0xB0A09A;
        private static const TX_HOVER:uint  = 0xE8DCD0;
        private static const TX_ACTIVE:uint = 0xF6E8DC;

        // Native plate frames.
        private static const FR_NORMAL:int = 1;
        private static const FR_HOVER:int  = 2;
        private static const FR_ACTIVE:int = 3;

        public var onSelect:Function; // function(index:int):void

        private var _tabs:Array;   // BtnAchiFilter[]
        private var _labels:Array; // TextField[] (parallel to _tabs)
        private var _active:int = 0;
        private var _tabW:Number;

        public function DebugTabStrip(labels:Array, x:Number, y:Number, stripWidth:Number = 980) {
            super();
            this.x = x;
            this.y = y;

            _tabs   = [];
            _labels = [];
            var n:int = labels.length;
            _tabW = (stripWidth - TAB_GAP * (n - 1)) / n;

            for (var i:int = 0; i < n; i++) {
                var tab:BtnAchiFilter = _buildTab(String(labels[i]), i);
                tab.x = i * (_tabW + TAB_GAP);
                tab.y = 0;
                _tabs.push(tab);
                addChild(tab);
            }
            _paint(0, FR_ACTIVE, TX_ACTIVE);
        }

        public function get activeIndex():int { return _active; }

        public function setActive(index:int, fireCallback:Boolean = false):void {
            if (index < 0 || index >= _tabs.length) return;
            if (index != _active) {
                _paint(_active, FR_NORMAL, TX_NORMAL);
                _active = index;
                _paint(_active, FR_ACTIVE, TX_ACTIVE);
            }
            if (fireCallback && onSelect != null) onSelect(_active);
        }

        private function _buildTab(label:String, idx:int):BtnAchiFilter {
            var btn:BtnAchiFilter = new BtnAchiFilter(label, idx, 0xFFFFFF);

            // Hide the native label/amount — we draw our own centred label so text
            // isn't distorted when the plate is scaled to the tab width.
            if (btn.tfLabel  != null) btn.tfLabel.visible  = false;
            if (btn.tfAmount != null) btn.tfAmount.visible = false;

            // Scale the plate art horizontally to the tab width, then pin its
            // top-left to the button's (0,0) regardless of the symbol's origin.
            var pb:Rectangle = btn.plate.getBounds(btn);
            if (pb.width > 0) btn.plate.scaleX = _tabW / pb.width;
            pb = btn.plate.getBounds(btn);
            btn.plate.x -= pb.x;
            btn.plate.y -= pb.y;
            var plateH:Number = btn.plate.getBounds(btn).height;

            // Our own centred label.
            var fmt:TextFormat = new TextFormat("Celtic Garamond for GemCraft", 16, TX_NORMAL, true);
            fmt.align = TextFormatAlign.CENTER;
            var tf:TextField = new TextField();
            tf.defaultTextFormat = fmt;
            tf.embedFonts   = false;
            tf.selectable   = false;
            tf.mouseEnabled = false;
            tf.autoSize     = TextFieldAutoSize.NONE;
            tf.width  = _tabW;
            tf.height = plateH;
            tf.textColor = TX_NORMAL;
            tf.text = label;
            tf.y = (plateH - tf.textHeight) * 0.5 - 2;
            btn.addChild(tf);
            _labels.push(tf);

            btn.plate.gotoAndStop(FR_NORMAL);
            btn.buttonMode    = true;
            btn.useHandCursor = true;
            btn.mouseChildren = false;

            var captured:int = idx;
            btn.addEventListener(MouseEvent.CLICK,
                function(e:MouseEvent):void { setActive(captured, true); },
                false, 0, true);
            btn.addEventListener(MouseEvent.MOUSE_OVER,
                function(e:MouseEvent):void { if (captured != _active) _paint(captured, FR_HOVER, TX_HOVER); },
                false, 0, true);
            btn.addEventListener(MouseEvent.MOUSE_OUT,
                function(e:MouseEvent):void { if (captured != _active) _paint(captured, FR_NORMAL, TX_NORMAL); },
                false, 0, true);
            return btn;
        }

        private function _paint(index:int, frame:int, textColor:uint):void {
            var btn:BtnAchiFilter = _tabs[index] as BtnAchiFilter;
            if (btn != null) btn.plate.gotoAndStop(frame);
            var tf:TextField = _labels[index] as TextField;
            if (tf != null) tf.textColor = textColor;
        }
    }
}

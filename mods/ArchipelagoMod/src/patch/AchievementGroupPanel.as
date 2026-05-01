package patch {
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;

    public class AchievementGroupPanel extends Sprite {

        public static const GROUP_IN_LOGIC:uint  = 1;
        public static const GROUP_OUT_LOGIC:uint = 2;
        public static const GROUP_EFFORT:uint    = 4;
        public static const GROUP_DESIGN:uint    = 8;

        private static const DEFAULT_SELECTED:uint = GROUP_IN_LOGIC | GROUP_OUT_LOGIC | GROUP_EFFORT;

        public var onChange:Function;

        private var _selectedGroups:uint = DEFAULT_SELECTED;
        private var _buttons:Vector.<Sprite>        = new Vector.<Sprite>();
        private var _countFields:Vector.<TextField> = new Vector.<TextField>();
        private var _hoveredIndex:int = -1;

        // Layout
        private static const BTN_W:Number    = 116;
        private static const BTN_H:Number    = 28;
        private static const COL_GAP:Number  = 5;
        private static const ROW_GAP:Number  = 4;
        private static const PAD_X:Number    = 5;
        private static const PAD_TOP:Number  = 18; // room for header label
        private static const PAD_BOT:Number  = 5;

        // Colors
        private static const C_PANEL_BG:uint     = 0x0A0A0A;
        private static const C_PANEL_BORDER:uint = 0x3A3A3A;
        private static const C_BTN_NORMAL:uint   = 0x181818;
        private static const C_BTN_SEL:uint      = 0x4A2C00;
        private static const C_BTN_HOVER:uint    = 0x262626;
        private static const C_BTN_SEL_HOV:uint  = 0x5A3800;
        private static const C_EDGE_NORMAL:uint  = 0x3A3A3A;
        private static const C_EDGE_SEL:uint     = 0xE5AD0A;
        private static const C_EDGE_HOVER:uint   = 0x666644;
        private static const C_LABEL:uint        = 0x888888;
        private static const C_LABEL_SEL:uint    = 0xFFDD88;
        private static const C_COUNT:uint        = 0xFFCC44;
        private static const C_HEADER:uint       = 0x777777;

        // [label, dot colour, group bit]
        private static const CONFIGS:Array = [
            {label: "In Logic",     dotColor: 0x44EE44, bit: 1},
            {label: "Out of Logic", dotColor: 0xFF4444, bit: 2},
            {label: "Excl. Effort", dotColor: 0x888888, bit: 4},
            {label: "Untrackable",  dotColor: 0xBB7700, bit: 8}
        ];

        public function AchievementGroupPanel() {
            super();
            _build();
        }

        public function get selectedGroups():uint { return _selectedGroups; }

        public function setCounts(g1:int, g2:int, g3:int, g4:int):void {
            var counts:Array = [g1, g2, g3, g4];
            var fmt:TextFormat = new TextFormat("_sans", 10, C_COUNT, true);
            fmt.align = "right";
            for (var i:int = 0; i < 4; i++) {
                _countFields[i].text = String(counts[i]);
                _countFields[i].setTextFormat(fmt);
            }
        }

        private function _panelW():Number { return PAD_X * 2 + BTN_W * 2 + COL_GAP; }
        private function _panelH():Number { return PAD_TOP + BTN_H * 2 + ROW_GAP + PAD_BOT; }

        private function _build():void {
            // Panel background
            var bg:Shape = new Shape();
            bg.graphics.lineStyle(1, C_PANEL_BORDER, 0.8);
            bg.graphics.beginFill(C_PANEL_BG, 0.85);
            bg.graphics.drawRoundRect(0, 0, _panelW(), _panelH(), 6, 6);
            bg.graphics.endFill();
            addChild(bg);

            // Header label
            var hdr:TextField = _makeTf(9, C_HEADER, false);
            hdr.text = "SHOW GROUPS";
            hdr.x    = PAD_X + 2;
            hdr.y    = 4;
            addChild(hdr);

            // Separator line under header
            var sep:Shape = new Shape();
            sep.graphics.lineStyle(1, C_PANEL_BORDER, 0.6);
            sep.graphics.moveTo(PAD_X, PAD_TOP - 3);
            sep.graphics.lineTo(_panelW() - PAD_X, PAD_TOP - 3);
            addChild(sep);

            for (var i:int = 0; i < 4; i++) {
                var col:int = i % 2;
                var row:int = i >> 1;
                var bx:Number = PAD_X + col * (BTN_W + COL_GAP);
                var by:Number = PAD_TOP + row * (BTN_H + ROW_GAP);
                var btn:Sprite = _makeBtn(i, bx, by);
                _buttons.push(btn);
                addChild(btn);
            }
            _refreshHighlights();
        }

        private function _makeBtn(idx:int, bx:Number, by:Number):Sprite {
            var cfg:Object = CONFIGS[idx];
            var btn:Sprite = new Sprite();
            btn.x = bx;
            btn.y = by;
            btn.buttonMode    = true;
            btn.useHandCursor = true;

            var bg:Shape = new Shape();
            bg.name = "bg";
            btn.addChild(bg);

            // Coloured dot
            var dot:Shape = new Shape();
            dot.graphics.lineStyle(1, 0x000000, 0.4);
            dot.graphics.beginFill(uint(cfg.dotColor), 1.0);
            dot.graphics.drawCircle(0, 0, 4);
            dot.graphics.endFill();
            dot.x = 10;
            dot.y = BTN_H * 0.5;
            btn.addChild(dot);

            // Label
            var lbl:TextField = _makeTf(10, C_LABEL, false);
            lbl.name = "lbl";
            lbl.text = String(cfg.label);
            lbl.x    = 19;
            lbl.y    = (BTN_H - lbl.textHeight) * 0.5 - 1;
            btn.addChild(lbl);

            // Count — fixed width, right-aligned format so text stays inside button
            var cntFmt:TextFormat = new TextFormat("_sans", 10, C_COUNT, true);
            cntFmt.align = "right";
            var cnt:TextField = new TextField();
            cnt.defaultTextFormat = cntFmt;
            cnt.selectable   = false;
            cnt.mouseEnabled = false;
            cnt.width  = 36;
            cnt.height = 16;
            cnt.x = BTN_W - 38; // right edge lands 2px from button edge
            cnt.y = lbl.y;
            cnt.text = "0";
            btn.addChild(cnt);
            _countFields.push(cnt);

            var self:AchievementGroupPanel = this;
            var bit:uint = uint(cfg.bit);

            btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
                self._selectedGroups ^= bit;
                self._refreshHighlights();
                if (self.onChange != null) self.onChange();
            }, false, 0, false);

            btn.addEventListener(MouseEvent.ROLL_OVER, function(e:MouseEvent):void {
                self._hoveredIndex = idx;
                self._refreshHighlights();
            }, false, 0, false);

            btn.addEventListener(MouseEvent.ROLL_OUT, function(e:MouseEvent):void {
                if (self._hoveredIndex == idx) self._hoveredIndex = -1;
                self._refreshHighlights();
            }, false, 0, false);

            return btn;
        }

        private function _makeTf(size:int, color:uint, bold:Boolean):TextField {
            var tf:TextField = new TextField();
            tf.defaultTextFormat = new TextFormat("_sans", size, color, bold);
            tf.autoSize     = TextFieldAutoSize.LEFT;
            tf.selectable   = false;
            tf.mouseEnabled = false;
            return tf;
        }

        private function _refreshHighlights():void {
            for (var i:int = 0; i < _buttons.length; i++) {
                var btn:Sprite = _buttons[i];
                var bg:Shape   = Shape(btn.getChildByName("bg"));
                var lbl:TextField = TextField(btn.getChildByName("lbl"));
                if (bg == null) continue;

                var sel:Boolean   = (_selectedGroups & uint(CONFIGS[i].bit)) != 0;
                var hov:Boolean   = (_hoveredIndex == i);

                var fillColor:uint;
                var edgeColor:uint;
                if (sel && hov)      { fillColor = C_BTN_SEL_HOV; edgeColor = C_EDGE_SEL; }
                else if (sel)        { fillColor = C_BTN_SEL;     edgeColor = C_EDGE_SEL; }
                else if (hov)        { fillColor = C_BTN_HOVER;   edgeColor = C_EDGE_HOVER; }
                else                 { fillColor = C_BTN_NORMAL;  edgeColor = C_EDGE_NORMAL; }

                bg.graphics.clear();
                bg.graphics.lineStyle(1, edgeColor, 0.9);
                bg.graphics.beginFill(fillColor, 1.0);
                bg.graphics.drawRoundRect(0, 0, BTN_W, BTN_H, 5, 5);
                bg.graphics.endFill();

                if (lbl != null) {
                    lbl.defaultTextFormat = new TextFormat(
                        "_sans", 10, sel ? C_LABEL_SEL : C_LABEL, false);
                    lbl.setTextFormat(new TextFormat(
                        "_sans", 10, sel ? C_LABEL_SEL : C_LABEL, false));
                }
            }
        }
    }
}

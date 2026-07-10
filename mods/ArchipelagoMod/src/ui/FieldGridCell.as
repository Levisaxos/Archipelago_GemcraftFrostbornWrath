package ui {
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    /**
     * One field in the results grid (a single stage, e.g. "N3").
     *
     * Three states:
     *   NEUTRAL — no filters selected; shown plain and clickable.
     *   MATCHED — matches the current AND filter; green.
     *   DIMMED  — filters active but this field doesn't match; faded.
     *
     * Hover fires onHover(strId) / onHover(null); click fires onClick(strId).
     * Exposes `yReal` for ScrollablePanel.
     */
    public class FieldGridCell extends Sprite {

        public static const NEUTRAL:int = 0;
        public static const MATCHED:int = 1;
        public static const DIMMED:int  = 2;
        public static const LOCKED:int  = 3;  // field the player doesn't have — inert

        private static const FONT:String = "Celtic Garamond for GemCraft";

        public var yReal:Number = 0;
        public var strId:String;

        /** onHover(strId:String or null). */
        public var onHover:Function;
        /** onClick(strId:String). */
        public var onClick:Function;

        private var _bg:Shape;
        private var _tf:TextField;
        private var _w:Number;
        private var _h:Number;
        private var _state:int = NEUTRAL;

        public function FieldGridCell(strId:String, w:Number, h:Number) {
            super();
            this.strId = strId;
            _w = w;
            _h = h;

            _bg = new Shape();
            addChild(_bg);

            _tf = new TextField();
            var fmt:TextFormat = new TextFormat(FONT, 17, 0xCFE0EC, true);
            fmt.align = TextFormatAlign.CENTER;
            _tf.defaultTextFormat = fmt;
            _tf.selectable    = false;
            _tf.mouseEnabled  = false;
            _tf.antiAliasType = AntiAliasType.ADVANCED;
            _tf.width  = _w;
            _tf.height = 24;
            _tf.y      = (_h - 22) * 0.5;
            _tf.text   = strId;
            addChild(_tf);

            buttonMode    = true;
            useHandCursor = true;
            mouseChildren = false;

            addEventListener(MouseEvent.MOUSE_OVER, _onOver,  false, 0, true);
            addEventListener(MouseEvent.MOUSE_OUT,  _onOut,   false, 0, true);
            addEventListener(MouseEvent.CLICK,      _onClick, false, 0, true);

            _redraw();
        }

        public function setState(state:int):void {
            _state = state;
            // A locked field is inert: no hand cursor, no hover/click.
            var live:Boolean = (_state != LOCKED);
            buttonMode    = live;
            useHandCursor = live;
            _redraw();
        }

        // -----------------------------------------------------------------------

        private function _onOver(e:MouseEvent):void {
            if (_state == LOCKED)
                return;
            filters = [_brightness(1.3)];
            if (onHover != null)
                onHover(strId);
        }

        private function _onOut(e:MouseEvent):void {
            filters = [];
            if (onHover != null)
                onHover(null);
        }

        private function _onClick(e:MouseEvent):void {
            if (_state == LOCKED)
                return;
            if (onClick != null)
                onClick(strId);
        }

        private function _redraw():void {
            var plate:uint;
            var border:uint;
            var text:uint;
            var alpha:Number = 1.0;

            switch (_state) {
                case MATCHED:
                    plate = 0x1E3A24; border = 0x66DD66; text = 0xC8F5C9;
                    break;
                case DIMMED:
                    plate = 0x10161C; border = 0x232D36; text = 0x55636E; alpha = 0.55;
                    break;
                case LOCKED:
                    plate = 0x0C1116; border = 0x1A2028; text = 0x3A444E; alpha = 0.5;
                    break;
                default:
                    plate = 0x1B2733; border = 0x3A4A58; text = 0xCFE0EC;
                    break;
            }

            var g:* = _bg.graphics;
            g.clear();
            g.lineStyle(2, border, 1);
            g.beginFill(plate, 0.95);
            g.drawRoundRect(0, 0, _w, _h, 7, 7);
            g.endFill();

            this.alpha = alpha;

            var f:TextFormat = _tf.getTextFormat();
            f.color = text;
            _tf.setTextFormat(f);
        }

        private function _brightness(scale:Number):ColorMatrixFilter {
            return new ColorMatrixFilter([
                scale, 0,     0,     0, 0,
                0,     scale, 0,     0, 0,
                0,     0,     scale, 0, 0,
                0,     0,     0,     1, 0
            ]);
        }
    }
}

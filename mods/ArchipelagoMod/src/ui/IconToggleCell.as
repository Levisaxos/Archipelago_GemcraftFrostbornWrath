package ui {
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    /**
     * One toggleable requirement-type icon.
     *
     * Size-parameterised: pass the plate size and whether to show a caption.
     * Selected = lit plate + gold border; unselected = dark plate + dimmed icon.
     * Hover brightens the cell and fires onHover(name). A flagged cell (icon
     * known to be wrong) shows a small red marker.
     *
     * Exposes `yReal` so ScrollablePanel can position it in the scroll viewport.
     */
    public class IconToggleCell extends Sprite {

        private static const PAD:Number       = 8;    // plate padding around icon
        private static const CAPTION_H:Number = 16;
        private static const FONT:String      = "Celtic Garamond for GemCraft";

        private static const COL_PLATE_OFF:uint   = 0x141E28;
        private static const COL_PLATE_ON:uint    = 0x24384C;
        private static const COL_BORDER_OFF:uint  = 0x30414F;
        private static const COL_BORDER_ON:uint   = 0xE5AD0A;  // AP gold
        private static const COL_CAPTION_OFF:uint = 0x9FB0BE;
        private static const COL_CAPTION_ON:uint  = 0xFFE9A8;
        private static const COL_FLAG:uint        = 0xFF3B30;  // red "needs fixing" dot

        public var yReal:Number = 0;
        public var reqName:String;

        /** Fired on click: onToggle(name:String, selected:Boolean). */
        public var onToggle:Function;
        /** Fired on roll-over/out: onHover(name:String or null). */
        public var onHover:Function;

        private var _plate:Shape;
        private var _icon:DisplayObject;
        private var _caption:TextField;
        private var _plateSize:Number;
        private var _flagged:Boolean;
        private var _selected:Boolean = false;
        private var _enabled:Boolean = true;

        public function IconToggleCell(name:String, icon:DisplayObject,
                                       plateSize:Number, showCaption:Boolean = false,
                                       flagged:Boolean = false) {
            super();
            this.reqName = name;
            _plateSize   = plateSize;
            _flagged     = flagged;

            _plate = new Shape();
            addChild(_plate);

            _icon = icon;
            if (_icon != null) {
                var fit:Number = _plateSize - PAD;
                var s:Number = Math.min(fit / _icon.width, fit / _icon.height);
                if (s > 4)
                    s = 4;
                if (s > 0 && s < Number.POSITIVE_INFINITY)
                    _icon.scaleX = _icon.scaleY = s;
                _icon.x = (_plateSize - _icon.width) * 0.5;
                _icon.y = (_plateSize - _icon.height) * 0.5;
                addChild(_icon);
            }

            if (showCaption) {
                _caption = _makeCaption(name);
                _caption.y = _plateSize + 1;
                addChild(_caption);
            }

            buttonMode    = true;
            useHandCursor = true;
            mouseChildren = false;

            addEventListener(MouseEvent.MOUSE_OVER, _onOver,  false, 0, true);
            addEventListener(MouseEvent.MOUSE_OUT,  _onOut,   false, 0, true);
            addEventListener(MouseEvent.CLICK,      _onClick, false, 0, true);

            _redraw();
        }

        public function get selected():Boolean {
            return _selected;
        }

        public function setSelected(v:Boolean):void {
            _selected = v;
            _redraw();
        }

        public function get enabled():Boolean {
            return _enabled;
        }

        /** Disabled = no available field has this type: dimmed + non-togglable. */
        public function setEnabled(v:Boolean):void {
            if (_enabled == v)
                return;
            _enabled      = v;
            buttonMode    = v;
            useHandCursor = v;
            _redraw();
        }

        // -----------------------------------------------------------------------

        private function _onClick(e:MouseEvent):void {
            if (!_enabled)
                return;
            _selected = !_selected;
            _redraw();
            if (onToggle != null)
                onToggle(reqName, _selected);
        }

        private function _onOver(e:MouseEvent):void {
            if (_enabled)
                filters = [_brightness(1.3)];
            if (onHover != null)
                onHover(reqName);
        }

        private function _onOut(e:MouseEvent):void {
            filters = [];
            if (onHover != null)
                onHover(null);
        }

        private function _redraw():void {
            // Disabled = no available field has this type: fully recede.
            this.alpha = _enabled ? 1.0 : 0.28;

            var g:* = _plate.graphics;
            g.clear();
            g.lineStyle(2, _selected ? COL_BORDER_ON : COL_BORDER_OFF, 1);
            g.beginFill(_selected ? COL_PLATE_ON : COL_PLATE_OFF, 0.92);
            g.drawRoundRect(0, 0, _plateSize, _plateSize, 8, 8);
            g.endFill();

            if (_flagged) {
                g.lineStyle();
                g.beginFill(COL_FLAG, 1);
                g.drawCircle(_plateSize - 5, 5, 4);
                g.endFill();
            }

            if (_icon != null)
                _icon.alpha = _selected ? 1.0 : 0.5;

            if (_caption != null) {
                var f:TextFormat = _caption.getTextFormat();
                f.color = _selected ? COL_CAPTION_ON : COL_CAPTION_OFF;
                _caption.setTextFormat(f);
            }
        }

        private function _makeCaption(text:String):TextField {
            var fmt:TextFormat = new TextFormat(FONT, 12, COL_CAPTION_OFF, false);
            fmt.align = TextFormatAlign.CENTER;

            var tf:TextField = new TextField();
            tf.defaultTextFormat = fmt;
            tf.selectable    = false;
            tf.mouseEnabled  = false;
            tf.antiAliasType = AntiAliasType.ADVANCED;
            tf.multiline     = false;
            tf.wordWrap      = false;
            tf.width         = _plateSize;
            tf.height        = CAPTION_H;
            tf.text          = text;
            return tf;
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

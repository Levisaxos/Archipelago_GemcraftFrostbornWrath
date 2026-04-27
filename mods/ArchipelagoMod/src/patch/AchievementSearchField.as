package patch {
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;

    /**
     * Small search input placed at the top-right of the achievements panel.
     * Drives a substring filter over achievement titles via the patcher's
     * existing filter slot; calls onChange whenever the query mutates.
     */
    public class AchievementSearchField extends Sprite {

        public static const FIELD_W:Number = 180;
        public static const FIELD_H:Number = 22;

        public var onChange:Function;

        private static const C_BG:uint     = 0x0A0A0A;
        private static const C_BORDER:uint = 0x3A3A3A;
        private static const C_TX:uint     = 0xEEDDFF;
        private static const C_LABEL:uint  = 0x888888;
        private static const C_CLEAR:uint  = 0xAA8866;
        private static const C_CLEAR_HOV:uint = 0xFFCC88;

        private static const LABEL_W:Number = 46;
        private static const CLEAR_W:Number = 16;

        private var _input:TextField;
        private var _clearBtn:Sprite;
        private var _clearTf:TextField;
        private var _query:String = "";

        public function AchievementSearchField() {
            super();
            _build();
        }

        public function get query():String { return _query; }

        private function _build():void {
            var bg:Shape = new Shape();
            bg.graphics.lineStyle(1, C_BORDER, 0.9);
            bg.graphics.beginFill(C_BG, 0.85);
            bg.graphics.drawRoundRect(0, 0, FIELD_W, FIELD_H, 5, 5);
            bg.graphics.endFill();
            addChild(bg);

            var lbl:TextField = new TextField();
            lbl.defaultTextFormat = new TextFormat("_sans", 11, C_LABEL, true);
            lbl.autoSize     = TextFieldAutoSize.LEFT;
            lbl.selectable   = false;
            lbl.mouseEnabled = false;
            lbl.text = "Search:";
            lbl.x = 5;
            lbl.y = (FIELD_H - lbl.textHeight) * 0.5 - 1;
            addChild(lbl);

            _input = new TextField();
            _input.defaultTextFormat = new TextFormat("_sans", 12, C_TX);
            _input.type            = TextFieldType.INPUT;
            _input.border          = false;
            _input.background      = false;
            _input.multiline       = false;
            _input.wordWrap        = false;
            _input.maxChars        = 64;
            _input.x      = LABEL_W;
            _input.y      = 3;
            _input.width  = FIELD_W - LABEL_W - CLEAR_W - 4;
            _input.height = FIELD_H - 6;
            _input.addEventListener(Event.CHANGE, _onTextChange, false, 0, false);
            // Swallow keyboard events so the game's stage-level handler doesn't
            // act on them (e.g. Backspace = "back to selector", Esc, hotkeys).
            _input.addEventListener(KeyboardEvent.KEY_DOWN, _swallowKey, false, int.MAX_VALUE, false);
            _input.addEventListener(KeyboardEvent.KEY_UP,   _swallowKey, false, int.MAX_VALUE, false);
            addChild(_input);

            _clearBtn = new Sprite();
            _clearBtn.x = FIELD_W - CLEAR_W - 2;
            _clearBtn.y = 3;
            _clearBtn.buttonMode    = true;
            _clearBtn.useHandCursor = true;
            _clearBtn.mouseEnabled  = true;

            var hit:Shape = new Shape();
            hit.graphics.beginFill(0x000000, 0.0);
            hit.graphics.drawRect(0, 0, CLEAR_W, FIELD_H - 6);
            hit.graphics.endFill();
            _clearBtn.addChild(hit);

            _clearTf = new TextField();
            _clearTf.defaultTextFormat = new TextFormat("_sans", 14, C_CLEAR, true);
            _clearTf.autoSize     = TextFieldAutoSize.CENTER;
            _clearTf.selectable   = false;
            _clearTf.mouseEnabled = false;
            _clearTf.text = "x";
            _clearTf.x = (CLEAR_W - _clearTf.textWidth) * 0.5 - 1;
            _clearTf.y = -2;
            _clearBtn.addChild(_clearTf);

            _clearBtn.addEventListener(MouseEvent.CLICK, _onClearClick, false, 0, false);
            _clearBtn.addEventListener(MouseEvent.ROLL_OVER, _onClearOver, false, 0, false);
            _clearBtn.addEventListener(MouseEvent.ROLL_OUT,  _onClearOut,  false, 0, false);
            _clearBtn.visible = false;
            addChild(_clearBtn);
        }

        private function _swallowKey(e:KeyboardEvent):void {
            e.stopImmediatePropagation();
        }

        private function _onTextChange(e:Event):void {
            var raw:String = (_input.text != null) ? _input.text : "";
            var trimmed:String = _trim(raw);
            _query = trimmed.toLowerCase();
            _clearBtn.visible = (_query.length > 0);
            if (onChange != null) onChange();
        }

        private function _onClearClick(e:MouseEvent):void {
            if (_input.text == "") return;
            _input.text = "";
            _query = "";
            _clearBtn.visible = false;
            if (onChange != null) onChange();
        }

        private function _onClearOver(e:MouseEvent):void {
            _clearTf.setTextFormat(new TextFormat("_sans", 14, C_CLEAR_HOV, true));
        }

        private function _onClearOut(e:MouseEvent):void {
            _clearTf.setTextFormat(new TextFormat("_sans", 14, C_CLEAR, true));
        }

        private static function _trim(s:String):String {
            if (s == null || s.length == 0) return "";
            var a:int = 0, b:int = s.length;
            while (a < b && s.charCodeAt(a) <= 32) a++;
            while (b > a && s.charCodeAt(b - 1) <= 32) b--;
            return s.substring(a, b);
        }
    }
}

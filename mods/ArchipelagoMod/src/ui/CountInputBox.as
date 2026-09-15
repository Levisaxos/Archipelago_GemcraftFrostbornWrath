package ui {
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;

    /**
     * Small numeric "at least N" input shown next to a Game Elements count filter icon (Reaver / Swarmling / Giant / Waves).
     * Digits only; a blank box reads as 0. Calls onChange() after every edit.
     */
    public class CountInputBox extends Sprite {

        public static const BOX_W:Number = 72;
        public static const BOX_H:Number = 24;

        /** Fired after every edit: onChange(). */
        public var onChange:Function;

        private static const COL_PLATE:uint  = 0x141E28;
        private static const COL_BORDER:uint = 0xE5AD0A;  // AP gold, matches a selected IconToggleCell
        private static const COL_LABEL:uint  = 0x9FB0BE;
        private static const COL_TEXT:uint   = 0xFFE9A8;
        private static const LABEL_W:Number  = 22;

        private var _input:TextField;

        public function CountInputBox() {
            super();

            var bg:Shape = new Shape();
            bg.graphics.lineStyle(1, COL_BORDER, 1);
            bg.graphics.beginFill(COL_PLATE, 0.92);
            bg.graphics.drawRoundRect(0, 0, BOX_W, BOX_H, 6, 6);
            bg.graphics.endFill();
            addChild(bg);

            var lbl:TextField = new TextField();
            lbl.defaultTextFormat = new TextFormat("_sans", 13, COL_LABEL, true);
            lbl.autoSize     = TextFieldAutoSize.LEFT;
            lbl.selectable   = false;
            lbl.mouseEnabled = false;
            lbl.text = "≥";
            lbl.x = 5;
            lbl.y = (BOX_H - lbl.height) * 0.5;
            addChild(lbl);

            _input = new TextField();
            _input.defaultTextFormat = new TextFormat("_sans", 13, COL_TEXT, true);
            _input.type      = TextFieldType.INPUT;
            _input.restrict  = "0-9";
            _input.maxChars  = 7;
            _input.multiline = false;
            _input.wordWrap  = false;
            _input.x      = LABEL_W;
            _input.y      = 3;
            _input.width  = BOX_W - LABEL_W - 4;
            _input.height = BOX_H - 6;
            _input.addEventListener(Event.CHANGE, _onTextChange, false, 0, false);
            // Swallow keyboard events so the game's stage-level handler doesn't act on them (e.g. Backspace = "back to selector", Esc, hotkeys).
            _input.addEventListener(KeyboardEvent.KEY_DOWN, _swallowKey, false, int.MAX_VALUE, false);
            _input.addEventListener(KeyboardEvent.KEY_UP,   _swallowKey, false, int.MAX_VALUE, false);
            addChild(_input);
        }

        /** The typed minimum; 0 when blank. */
        public function get value():int {
            return (_input.text != null && _input.text.length > 0) ? int(_input.text) : 0;
        }

        /** Put the caret in the box and select its contents so typing replaces the old number. */
        public function focusInput():void {
            if (stage == null)
                return;
            stage.focus = _input;
            _input.setSelection(0, _input.length);
        }

        private function _swallowKey(e:KeyboardEvent):void {
            e.stopImmediatePropagation();
        }

        private function _onTextChange(e:Event):void {
            if (onChange != null)
                onChange();
        }
    }
}

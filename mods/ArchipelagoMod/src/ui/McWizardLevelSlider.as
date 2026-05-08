package ui {

    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    /**
     * Compact horizontal drag slider for wizard level (1–1000).
     *
     * Designed to sit inside the McDebugOptions arrCntContents list.
     * Exposes a public `yReal` property so the viewport system can
     * reposition and show/hide it exactly like McOptTitle / McOptPanel.
     *
     * Layout: slider + label + value + ±1/±10 fine buttons on a single row,
     * with four preset jump buttons (1 / 100 / 500 / 1000) on the row below.
     *
     * `onChange(newValue:int)` is called on every value change.
     * `setValue(v, false)` silently updates the knob (no callback).
     */
    public class McWizardLevelSlider extends Sprite {

        public static const MIN_VALUE:int = 1;
        public static const MAX_VALUE:int = 1000;

        // Total height the viewport system should reserve for this widget.
        public static const TOTAL_HEIGHT:Number = 76;

        // Track geometry (compact)
        private static const TRACK_X:Number = 200;
        private static const TRACK_W:Number = 480;
        private static const TRACK_H:Number = 6;
        private static const KNOB_W:Number  = 12;
        private static const KNOB_H:Number  = 22;
        private static const ROW1_Y:Number  = 16;  // slider row centre
        private static const ROW2_Y:Number  = 52;  // preset row centre

        // Colors
        private static const COL_TRACK:uint  = 0x443366;
        private static const COL_FILL:uint   = 0x9966CC;
        private static const COL_KNOB:uint   = 0xCC99FF;
        private static const COL_LABEL:uint  = 0x998899;
        private static const COL_VALUE:uint  = 0xEEDDFF;
        private static const COL_BTN:uint    = 0x332244;
        private static const COL_BTN_HL:uint = 0x664488;
        private static const COL_BTN_BD:uint = 0x9966CC;

        // State
        private var _value:int       = 1;
        private var _isDragging:Boolean = false;
        private var _dragOriginX:Number = 0;
        private var _dragOriginKnobX:Number = 0;

        // Display objects
        private var _fill:Shape;
        private var _knob:Sprite;
        private var _valueTf:TextField;

        /** Required by the McDebugOptions viewport system — set in constructor. */
        public var yReal:Number;

        /** Called on every value change. Signature: (value:int):void */
        public var onChange:Function;

        /** True while the knob is being dragged — caller can poll to skip re-syncing. */
        public function get isDragging():Boolean { return _isDragging; }

        public function get value():int { return _value; }

        public function setValue(v:int, notify:Boolean = false):void {
            _value = Math.max(MIN_VALUE, Math.min(MAX_VALUE, v));
            syncKnob();
            syncLabel();
            if (notify && onChange != null) onChange(_value);
        }

        // -----------------------------------------------------------------------

        public function McWizardLevelSlider(x:Number, y:Number) {
            super();
            this.x = x;
            this.y = y;
            yReal  = y;
            build();
        }

        private function build():void {
            // ── Label ───────────────────────────────────────────────────────────
            var lFmt:TextFormat = new TextFormat("Celtic Garamond for GemCraft", 16, COL_LABEL, true);
            var lTf:TextField = new TextField();
            lTf.defaultTextFormat = lFmt;
            lTf.embedFonts   = false;
            lTf.selectable   = false;
            lTf.mouseEnabled = false;
            lTf.autoSize     = TextFieldAutoSize.LEFT;
            lTf.textColor    = COL_LABEL;
            lTf.text         = "Wizard Level";
            lTf.x = 0;
            lTf.y = ROW1_Y - 11;
            addChild(lTf);

            // ── Track background ────────────────────────────────────────────────
            var trackBg:Shape = new Shape();
            trackBg.graphics.beginFill(COL_TRACK);
            trackBg.graphics.drawRoundRect(0, 0, TRACK_W, TRACK_H, TRACK_H, TRACK_H);
            trackBg.graphics.endFill();
            trackBg.x = TRACK_X;
            trackBg.y = ROW1_Y - TRACK_H * 0.5;
            addChild(trackBg);

            // ── Track fill (colored portion left of knob) ───────────────────────
            _fill = new Shape();
            _fill.x = TRACK_X;
            _fill.y = trackBg.y;
            addChild(_fill);

            // ── Knob ────────────────────────────────────────────────────────────
            _knob = new Sprite();
            _knob.graphics.beginFill(COL_KNOB);
            _knob.graphics.drawRoundRect(-KNOB_W * 0.5, -KNOB_H * 0.5, KNOB_W, KNOB_H, 3, 3);
            _knob.graphics.endFill();
            _knob.y          = ROW1_Y;
            _knob.buttonMode = true;
            _knob.useHandCursor = true;
            _knob.addEventListener(MouseEvent.MOUSE_DOWN, onKnobDown, false, 0, true);
            addChild(_knob);

            // ── Track click-target (wider hit area) ─────────────────────────────
            var trackHit:Sprite = new Sprite();
            trackHit.graphics.beginFill(0, 0);
            trackHit.graphics.drawRect(0, -10, TRACK_W, TRACK_H + 20);
            trackHit.graphics.endFill();
            trackHit.x = TRACK_X;
            trackHit.y = trackBg.y;
            trackHit.buttonMode    = true;
            trackHit.useHandCursor = true;
            trackHit.addEventListener(MouseEvent.CLICK, onTrackClick, false, 0, true);
            addChild(trackHit);

            // ── Value label ─────────────────────────────────────────────────────
            var vFmt:TextFormat = new TextFormat("Celtic Garamond for GemCraft", 16, COL_VALUE, true);
            _valueTf = new TextField();
            _valueTf.defaultTextFormat = vFmt;
            _valueTf.embedFonts   = false;
            _valueTf.selectable   = false;
            _valueTf.mouseEnabled = false;
            _valueTf.width  = 50;
            _valueTf.height = 24;
            _valueTf.textColor = COL_VALUE;
            _valueTf.x = TRACK_X + TRACK_W + 12;
            _valueTf.y = ROW1_Y - 12;
            addChild(_valueTf);

            // ── Fine-adjustment buttons (same row) ──────────────────────────────
            var fineX:Number = TRACK_X + TRACK_W + 70;
            addBtn("-10", fineX,        ROW1_Y, 36, 22, function():void { setValue(_value - 10, true); });
            addBtn("-1",  fineX + 42,   ROW1_Y, 36, 22, function():void { setValue(_value - 1,  true); });
            addBtn("+1",  fineX + 84,   ROW1_Y, 36, 22, function():void { setValue(_value + 1,  true); });
            addBtn("+10", fineX + 126,  ROW1_Y, 36, 22, function():void { setValue(_value + 10, true); });

            // ── Preset jump buttons (second row) ────────────────────────────────
            var presetLabels:Array  = ["1", "100", "500", "1000"];
            var presetValues:Array  = [1, 100, 500, 1000];
            var presetX:Number = TRACK_X;
            for (var i:int = 0; i < presetLabels.length; i++) {
                var captured:int = int(presetValues[i]);
                addBtn(String(presetLabels[i]),
                    presetX + i * 60, ROW2_Y, 50, 22,
                    function(v:int):Function {
                        return function():void { setValue(v, true); };
                    }(captured));
            }

            setValue(MIN_VALUE);
        }

        // -----------------------------------------------------------------------
        // Generic button helper

        private function addBtn(label:String, cx:Number, cy:Number, w:Number, h:Number, action:Function):void {
            var btn:Sprite = new Sprite();
            drawButtonFace(btn, w, h, false);

            var fmt:TextFormat = new TextFormat("_sans", 11, 0xEECCFF, true);
            fmt.align = TextFormatAlign.CENTER;
            var tf:TextField = new TextField();
            tf.defaultTextFormat = fmt;
            tf.selectable   = false;
            tf.mouseEnabled = false;
            tf.width  = w;
            tf.height = h;
            tf.textColor = 0xEECCFF;
            tf.text = label;
            tf.y = (h - 14) * 0.5;
            btn.addChild(tf);

            btn.x = cx;
            btn.y = cy - h * 0.5;
            btn.buttonMode    = true;
            btn.useHandCursor = true;

            var capW:Number = w, capH:Number = h;
            btn.addEventListener(MouseEvent.CLICK,
                function(e:MouseEvent):void { action(); },
                false, 0, true);
            btn.addEventListener(MouseEvent.MOUSE_OVER,
                function(e:MouseEvent):void { drawButtonFace(btn, capW, capH, true); },
                false, 0, true);
            btn.addEventListener(MouseEvent.MOUSE_OUT,
                function(e:MouseEvent):void { drawButtonFace(btn, capW, capH, false); },
                false, 0, true);
            addChild(btn);
        }

        private function drawButtonFace(btn:Sprite, w:Number, h:Number, hover:Boolean):void {
            btn.graphics.clear();
            btn.graphics.beginFill(hover ? COL_BTN_HL : COL_BTN);
            btn.graphics.lineStyle(1, COL_BTN_BD, 0.7);
            btn.graphics.drawRoundRect(0, 0, w, h, 4, 4);
            btn.graphics.endFill();
        }

        // -----------------------------------------------------------------------
        // Track click — jump knob to clicked position

        private function onTrackClick(e:MouseEvent):void {
            var localX:Number = globalToLocal(new Point(e.stageX, 0)).x - TRACK_X;
            applyRatio(localX / TRACK_W);
        }

        // -----------------------------------------------------------------------
        // Knob drag

        private function onKnobDown(e:MouseEvent):void {
            _isDragging    = true;
            _dragOriginX   = e.stageX;
            _dragOriginKnobX = _knob.x;
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onKnobMove, false, 0, true);
            stage.addEventListener(MouseEvent.MOUSE_UP,   onKnobUp,   false, 0, true);
            e.stopPropagation();
        }

        private function onKnobMove(e:MouseEvent):void {
            if (!_isDragging) return;
            var delta:Number = e.stageX - _dragOriginX;
            var knobLocalX:Number = (_dragOriginKnobX - TRACK_X) + delta;
            applyRatio(knobLocalX / TRACK_W);
        }

        private function onKnobUp(e:MouseEvent):void {
            _isDragging = false;
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onKnobMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP,   onKnobUp);
        }

        // -----------------------------------------------------------------------
        // Sync helpers

        private function applyRatio(ratio:Number):void {
            setValue(MIN_VALUE + Math.round(
                Math.max(0, Math.min(1, ratio)) * (MAX_VALUE - MIN_VALUE)
            ), true);
        }

        private function syncKnob():void {
            var ratio:Number = (_value - MIN_VALUE) / Number(MAX_VALUE - MIN_VALUE);
            _knob.x = TRACK_X + ratio * TRACK_W;

            _fill.graphics.clear();
            _fill.graphics.beginFill(COL_FILL);
            _fill.graphics.drawRoundRect(0, 0, ratio * TRACK_W, TRACK_H, TRACK_H, TRACK_H);
            _fill.graphics.endFill();
        }

        private function syncLabel():void {
            _valueTf.text = String(_value);
        }
    }
}

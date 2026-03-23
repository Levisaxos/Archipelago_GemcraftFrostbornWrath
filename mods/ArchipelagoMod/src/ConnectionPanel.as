package {
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    /**
     * A self-contained overlay panel for entering Archipelago connection settings.
     * Call prefill() after adding to stage to populate the fields from saved settings.
     *
     * Usage:
     *   var panel:ConnectionPanel = new ConnectionPanel();
     *   panel.onConnect = function(host:String, port:int, slot:String, password:String):void { ... };
     *   panel.onCancel  = function():void { ... };
     *   stage.addChild(panel);
     *   panel.centerOnStage(stage.stageWidth, stage.stageHeight);
     *   panel.prefill(host, port, slot, password);
     */
    public class ConnectionPanel extends Sprite {

        // Panel dimensions — used externally for centering.
        public static const PANEL_W:Number = 430;
        public static const PANEL_H:Number = 295;

        private static const LABEL_W:Number = 110;
        private static const FIELD_W:Number = 240;
        private static const FIELD_H:Number = 26;
        private static const ROW_H:Number   = 38;
        private static const PADDING:Number = 20;

        // Colors
        private static const COL_BG:uint       = 0x0D0820;
        private static const COL_BORDER:uint   = 0x7744BB;
        private static const COL_TITLE:uint    = 0xCCAAFF;
        private static const COL_LABEL:uint    = 0xBBAADD;
        private static const COL_FIELD_BG:uint = 0x1E1035;
        private static const COL_FIELD_BD:uint = 0x6633AA;
        private static const COL_FIELD_TX:uint = 0xEEDDFF;
        private static const COL_BTN_OK:uint   = 0x3A1A6E;
        private static const COL_BTN_CN:uint   = 0x3A1010;
        private static const COL_BTN_BD:uint   = 0xAA77EE;
        private static const COL_BTN_TX:uint   = 0xFFFFFF;

        private var _tfHost:TextField;
        private var _tfPort:TextField;
        private var _tfSlot:TextField;
        private var _tfPassword:TextField;

        private var _btnConnect:Sprite;
        private var _btnCancel:Sprite;
        private var _tfConnectLabel:TextField;
        private var _tfStatus:TextField;

        /** Called with (host, port, slot, password) when the user clicks Connect. */
        public var onConnect:Function;
        /** Called when the user clicks Cancel. */
        public var onCancel:Function;

        public function ConnectionPanel() {
            super();
            build();
        }

        // -----------------------------------------------------------------------
        // Build

        private function build():void {
            // Background
            graphics.beginFill(COL_BG, 0.97);
            graphics.lineStyle(2, COL_BORDER);
            graphics.drawRoundRect(0, 0, PANEL_W, PANEL_H, 12, 12);
            graphics.endFill();

            // Title
            var title:TextField = makeLabelTf("Archipelago", PANEL_W, 28, COL_TITLE, 17, true, true);
            title.x = 0;
            title.y = PADDING - 2;
            addChild(title);

            // Separator line
            graphics.lineStyle(1, COL_BORDER, 0.5);
            graphics.moveTo(PADDING, PADDING + 30);
            graphics.lineTo(PANEL_W - PADDING, PADDING + 30);

            var startY:Number = PADDING + 40;

            // Rows: Host, Port, Slot, Password
            addRow("Host:",      startY + ROW_H * 0, false, function(tf:TextField):void { _tfHost     = tf; });
            addRow("Port:",      startY + ROW_H * 1, false, function(tf:TextField):void { _tfPort     = tf; _tfPort.restrict = "0-9"; });
            addRow("Slot name:", startY + ROW_H * 2, false, function(tf:TextField):void { _tfSlot     = tf; });
            addRow("Password:",  startY + ROW_H * 3, true,  function(tf:TextField):void { _tfPassword = tf; });

            // Status line — hidden until there is something to show.
            _tfStatus = makeLabelTf("", PANEL_W - PADDING * 2, 20, 0xFF6666AA, 12, false, true);
            _tfStatus.x       = PADDING;
            _tfStatus.y       = PANEL_H - 70;
            _tfStatus.visible = false;
            addChild(_tfStatus);

            // Buttons
            var btnY:Number = PANEL_H - 55;
            var centerX:Number = PANEL_W / 2;

            _btnConnect = makeButton("Connect", COL_BTN_OK, 105, 32);
            _tfConnectLabel = TextField(_btnConnect.getChildAt(0));
            _btnConnect.x = centerX - 115;
            _btnConnect.y = btnY;
            _btnConnect.addEventListener(MouseEvent.CLICK,      onConnectClicked, false, 0, true);
            _btnConnect.addEventListener(MouseEvent.MOUSE_OVER, onBtnOver,        false, 0, true);
            _btnConnect.addEventListener(MouseEvent.MOUSE_OUT,  onBtnOut,         false, 0, true);
            addChild(_btnConnect);

            _btnCancel = makeButton("Cancel", COL_BTN_CN, 105, 32);
            _btnCancel.x = centerX + 10;
            _btnCancel.y = btnY;
            _btnCancel.addEventListener(MouseEvent.CLICK,      onCancelClicked, false, 0, true);
            _btnCancel.addEventListener(MouseEvent.MOUSE_OVER, onBtnOver,       false, 0, true);
            _btnCancel.addEventListener(MouseEvent.MOUSE_OUT,  onBtnOut,        false, 0, true);
            addChild(_btnCancel);
        }

        private function addRow(labelText:String, y:Number, isPassword:Boolean, setter:Function):void {
            var lbl:TextField = makeLabelTf(labelText, LABEL_W, FIELD_H, COL_LABEL, 13, false, false);
            lbl.x = PADDING;
            lbl.y = y + 2;
            addChild(lbl);

            var tf:TextField = makeInputTf(FIELD_W, FIELD_H);
            tf.x = PADDING + LABEL_W + 6;
            tf.y = y;
            if (isPassword) tf.displayAsPassword = true;
            addChild(tf);
            setter(tf);
        }

        // -----------------------------------------------------------------------
        // TextField / button factories

        private function makeLabelTf(text:String, w:Number, h:Number,
                                     color:uint, size:int,
                                     bold:Boolean, center:Boolean):TextField {
            var fmt:TextFormat = new TextFormat("_sans", size, color, bold);
            if (center) fmt.align = TextFormatAlign.CENTER;
            var tf:TextField = new TextField();
            tf.defaultTextFormat = fmt;
            tf.selectable   = false;
            tf.mouseEnabled = false;
            tf.width        = w;
            tf.height       = h;
            tf.text         = text;
            return tf;
        }

        private function makeInputTf(w:Number, h:Number):TextField {
            var fmt:TextFormat = new TextFormat("_sans", 13, COL_FIELD_TX);
            var tf:TextField   = new TextField();
            tf.defaultTextFormat = fmt;
            tf.type            = TextFieldType.INPUT;
            tf.border          = true;
            tf.background      = true;
            tf.backgroundColor = COL_FIELD_BG;
            tf.borderColor     = COL_FIELD_BD;
            tf.width           = w;
            tf.height          = h;
            return tf;
        }

        private function makeButton(label:String, bgColor:uint,
                                    w:Number, h:Number):Sprite {
            var btn:Sprite = new Sprite();
            drawButtonFace(btn, bgColor, w, h, false);

            var fmt:TextFormat = new TextFormat("_sans", 13, COL_BTN_TX, true);
            fmt.align = TextFormatAlign.CENTER;
            var tf:TextField = new TextField();
            tf.defaultTextFormat = fmt;
            tf.selectable   = false;
            tf.mouseEnabled = false;
            tf.width        = w;
            tf.height       = h;
            tf.text         = label;
            btn.addChild(tf);

            btn.buttonMode    = true;
            btn.useHandCursor = true;
            return btn;
        }

        private function drawButtonFace(btn:Sprite, bgColor:uint,
                                        w:Number, h:Number, hover:Boolean):void {
            var fill:uint = hover ? brighten(bgColor, 0.4) : bgColor;
            btn.graphics.clear();
            btn.graphics.beginFill(fill);
            btn.graphics.lineStyle(1, COL_BTN_BD);
            btn.graphics.drawRoundRect(0, 0, w, h, 7, 7);
            btn.graphics.endFill();
        }

        private function brighten(color:uint, amount:Number):uint {
            var r:int = Math.min(255, int((color >> 16 & 0xFF) + 255 * amount));
            var g:int = Math.min(255, int((color >> 8  & 0xFF) + 255 * amount));
            var b:int = Math.min(255, int((color       & 0xFF) + 255 * amount));
            return (r << 16) | (g << 8) | b;
        }

        // -----------------------------------------------------------------------
        // Button hover

        private function onBtnOver(e:MouseEvent):void {
            var btn:Sprite = e.currentTarget as Sprite;
            if (btn == null) return;
            var bgColor:uint = (btn == _btnConnect) ? COL_BTN_OK : COL_BTN_CN;
            drawButtonFace(btn, bgColor, 105, 32, true);
        }

        private function onBtnOut(e:MouseEvent):void {
            var btn:Sprite = e.currentTarget as Sprite;
            if (btn == null) return;
            var bgColor:uint = (btn == _btnConnect) ? COL_BTN_OK : COL_BTN_CN;
            drawButtonFace(btn, bgColor, 105, 32, false);
        }

        // -----------------------------------------------------------------------
        // Actions

        private function onConnectClicked(e:MouseEvent):void {
            setConnecting(true);
            if (onConnect != null) {
                onConnect(_tfHost.text, int(_tfPort.text), _tfSlot.text, _tfPassword.text);
            }
        }

        private function onCancelClicked(e:MouseEvent):void {
            if (onCancel != null) onCancel();
        }

        /** Switch the Connect button between normal and connecting state. */
        private function setConnecting(connecting:Boolean):void {
            _tfConnectLabel.text      = connecting ? "Connecting..." : "Connect";
            _btnConnect.mouseEnabled  = !connecting;
            _btnConnect.buttonMode    = !connecting;
            _btnConnect.useHandCursor = !connecting;
            _btnConnect.alpha         = connecting ? 0.45 : 1.0;
            if (connecting) {
                _tfStatus.visible = false; // clear any previous error when retrying
            }
        }

        /** Reset the panel to its idle state (call after a failed connection attempt). */
        public function resetState():void {
            setConnecting(false);
        }

        /** Show an error message inside the panel. */
        public function showError(msg:String):void {
            _tfStatus.text    = msg;
            _tfStatus.visible = true;
        }

        // -----------------------------------------------------------------------
        // Pre-fill from saved settings (called by ArchipelagoMod after creating the panel)

        public function prefill(host:String, port:int, slot:String, password:String):void {
            _tfHost.text     = host;
            _tfPort.text     = String(port > 0 ? port : 38281);
            _tfSlot.text     = slot;
            _tfPassword.text = password;
        }

        // -----------------------------------------------------------------------
        // Positioning

        public function centerOnStage(stageW:Number, stageH:Number):void {
            x = Math.round((stageW - PANEL_W) / 2);
            y = Math.round((stageH - PANEL_H) / 2);
        }
    }
}

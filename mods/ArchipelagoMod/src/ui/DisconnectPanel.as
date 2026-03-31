package ui {
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    /**
     * A persistent bottom-of-screen banner shown when the Archipelago connection
     * drops unexpectedly.  Stays visible until the player reconnects or returns
     * to the main menu.
     *
     * Usage:
     *   var panel:DisconnectPanel = new DisconnectPanel();
     *   panel.onReconnect = function():void { ... };
     *   stage.addChild(panel);
     *   panel.positionAtBottom(stage.stageWidth, stage.stageHeight);
     */
    public class DisconnectPanel extends Sprite {

        // Layout
        private static const PANEL_H:Number  = 38;
        private static const PADDING:Number  = 14;
        private static const BTN_W:Number    = 106;
        private static const BTN_H:Number    = 26;
        private static const GAP:Number      = 10;

        // Colors — warning orange/amber palette, matching mod style
        private static const COL_BG:uint      = 0x140800;
        private static const COL_BORDER:uint  = 0xCC6622;
        private static const COL_TEXT:uint    = 0xFFBB55;
        private static const COL_BTN:uint     = 0x3A1A00;
        private static const COL_BTN_BD:uint  = 0xCC8833;
        private static const COL_BTN_TX:uint  = 0xFFFFFF;

        private static const ICON_W:Number   = 28;

        private var _panelW:Number = 400;
        private var _tfIcon:TextField;
        private var _tfMessage:TextField;
        private var _btnReconnect:Sprite;
        private var _btnLabel:TextField;
        private var _isReconnecting:Boolean = false;

        /** Called when the player clicks Reconnect. Signature: ():void */
        public var onReconnect:Function;

        public function DisconnectPanel() {
            super();
            build();
        }

        // -----------------------------------------------------------------------
        // Build

        private function build():void {
            // Warning icon — separate field so its vertical offset can be tuned independently
            var iconFmt:TextFormat = new TextFormat("_sans", 13, COL_TEXT, true);
            _tfIcon = new TextField();
            _tfIcon.defaultTextFormat = iconFmt;
            _tfIcon.selectable   = false;
            _tfIcon.mouseEnabled = false;
            _tfIcon.width  = ICON_W;
            _tfIcon.height = PANEL_H;
            _tfIcon.text   = "\u26A0";
            addChild(_tfIcon);

            // Message text — width set later in drawPanel()
            var fmt:TextFormat = new TextFormat("_sans", 13, COL_TEXT, true);
            fmt.align = TextFormatAlign.LEFT;
            _tfMessage = new TextField();
            _tfMessage.defaultTextFormat = fmt;
            _tfMessage.selectable   = false;
            _tfMessage.mouseEnabled = false;
            _tfMessage.text         = "Archipelago disconnected";
            addChild(_tfMessage);

            // Reconnect button
            _btnReconnect = new Sprite();
            _btnLabel = makeButtonLabel("Reconnect", BTN_W, BTN_H);
            _btnReconnect.addChild(_btnLabel);
            _btnReconnect.buttonMode    = true;
            _btnReconnect.useHandCursor = true;
            _btnReconnect.addEventListener(MouseEvent.CLICK,      onReconnectClicked, false, 0, true);
            _btnReconnect.addEventListener(MouseEvent.MOUSE_OVER, onBtnOver,          false, 0, true);
            _btnReconnect.addEventListener(MouseEvent.MOUSE_OUT,  onBtnOut,           false, 0, true);
            addChild(_btnReconnect);

            drawPanel(_panelW);
        }

        private function drawPanel(panelW:Number):void {
            _panelW = panelW;

            // Background + border
            graphics.clear();
            graphics.beginFill(COL_BG, 0.96);
            graphics.lineStyle(2, COL_BORDER);
            graphics.drawRoundRect(0, 0, panelW, PANEL_H, 8, 8);
            graphics.endFill();

            // Icon — left edge, nudged up slightly to align with text baseline
            _tfIcon.x = PADDING;
            _tfIcon.y = (PANEL_H - 16) * 0.5 - 15;

            // Message text — right of icon, vertically centred
            var msgW:Number = panelW - BTN_W - PADDING * 2 - GAP - ICON_W;
            _tfMessage.width  = msgW;
            _tfMessage.height = PANEL_H;
            _tfMessage.x      = PADDING + ICON_W;
            _tfMessage.y      = (PANEL_H - 16) * 0.5 - 3;

            // Button — right side, vertically centred
            drawButtonFace(_btnReconnect, COL_BTN, BTN_W, BTN_H, false);
            _btnReconnect.x = panelW - PADDING - BTN_W;
            _btnReconnect.y = (PANEL_H - BTN_H) * 0.5;
        }

        // -----------------------------------------------------------------------
        // Button helpers

        private function makeButtonLabel(text:String, w:Number, h:Number):TextField {
            var fmt:TextFormat = new TextFormat("_sans", 12, COL_BTN_TX, true);
            fmt.align = TextFormatAlign.CENTER;
            var tf:TextField = new TextField();
            tf.defaultTextFormat = fmt;
            tf.selectable   = false;
            tf.mouseEnabled = false;
            tf.width  = w;
            tf.height = h;
            tf.text   = text;
            return tf;
        }

        private function drawButtonFace(btn:Sprite, bgColor:uint,
                                        w:Number, h:Number, hover:Boolean):void {
            var fill:uint = hover ? brighten(bgColor, 0.3) : bgColor;
            btn.graphics.clear();
            btn.graphics.beginFill(fill);
            btn.graphics.lineStyle(1, COL_BTN_BD);
            btn.graphics.drawRoundRect(0, 0, w, h, 6, 6);
            btn.graphics.endFill();
        }

        private function brighten(color:uint, amount:Number):uint {
            var r:int = Math.min(255, int((color >> 16 & 0xFF) + 255 * amount));
            var g:int = Math.min(255, int((color >> 8  & 0xFF) + 255 * amount));
            var b:int = Math.min(255, int((color       & 0xFF) + 255 * amount));
            return (r << 16) | (g << 8) | b;
        }

        // -----------------------------------------------------------------------
        // Button events

        private function onReconnectClicked(e:MouseEvent):void {
            if (_isReconnecting) return;
            if (onReconnect != null) onReconnect();
        }

        private function onBtnOver(e:MouseEvent):void {
            if (!_isReconnecting) drawButtonFace(_btnReconnect, COL_BTN, BTN_W, BTN_H, true);
        }

        private function onBtnOut(e:MouseEvent):void {
            if (!_isReconnecting) drawButtonFace(_btnReconnect, COL_BTN, BTN_W, BTN_H, false);
        }

        // -----------------------------------------------------------------------
        // State

        /** Switch button between normal and "Reconnecting…" state. */
        public function setReconnecting(reconnecting:Boolean):void {
            _isReconnecting = reconnecting;
            _btnLabel.text        = reconnecting ? "Reconnecting..." : "Reconnect";
            _btnReconnect.mouseEnabled  = !reconnecting;
            _btnReconnect.buttonMode    = !reconnecting;
            _btnReconnect.useHandCursor = !reconnecting;
            _btnReconnect.alpha         = reconnecting ? 0.5 : 1.0;
        }

        /** Reset button to idle state (call after a failed connection attempt). */
        public function resetState():void {
            setReconnecting(false);
        }

        /** Returns true when this panel is visible. */
        public function get isShowing():Boolean {
            return this.visible && this.parent != null;
        }

        // -----------------------------------------------------------------------
        // Positioning

        /**
         * Resize the panel to match the current stage width and place it
         * near the bottom of the screen.
         */
        public function positionAtBottom(stageW:Number, stageH:Number):void {
            var panelW:Number = Math.min(stageW - 20, 500);
            drawPanel(panelW);
            x = Math.round((stageW - panelW) * 0.5);
            y = stageH - PANEL_H - 12;
        }
    }
}

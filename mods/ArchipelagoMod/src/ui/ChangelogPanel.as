package ui {
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.ui.Keyboard;

    /**
     * A scrollable modal changelog popup styled to match the mod's dark-purple theme.
     *
     * Usage:
     *   var panel:ChangelogPanel = new ChangelogPanel();
     *   panel.populate(releases);          // Array of {tag, name, body, date}
     *   panel.showWithOverlay(stage);
     */
    public class ChangelogPanel extends Sprite {

        // Panel dimensions
        public static const PANEL_W:Number = 600;
        public static const PANEL_H:Number = 480;

        private static const PADDING:Number    = 20;
        private static const HEADER_H:Number   = 50;  // space reserved for title + separator
        private static const FOOTER_H:Number   = 40;  // space reserved for Close button
        private static const SCROLL_W:Number   = 8;   // scrollbar track width
        private static const BODY_W:Number     = PANEL_W - PADDING * 2 - SCROLL_W - 4;
        private static const BODY_TOP:Number   = HEADER_H;
        private static const BODY_BOTTOM:Number = PANEL_H - FOOTER_H;
        private static const VISIBLE_H:Number  = BODY_BOTTOM - BODY_TOP;

        // Colors — same palette as ConnectionPanel
        private static const COL_BG:uint        = 0x0D0820;
        private static const COL_BORDER:uint    = 0x7744BB;
        private static const COL_TITLE:uint     = 0xCCAAFF;
        private static const COL_LABEL:uint     = 0xBBAADD;
        private static const COL_TAG:uint       = 0xFFDD88; // gold for version headings
        private static const COL_DATE:uint      = 0x887799; // muted for dates
        private static const COL_BODY:uint      = 0xCCBBEE; // body text
        private static const COL_BTN_BG:uint    = 0x3A1A6E;
        private static const COL_BTN_BD:uint    = 0xAA77EE;
        private static const COL_BTN_TX:uint    = 0xFFFFFF;
        private static const COL_SCROLL_TR:uint = 0x2A1850; // scrollbar track
        private static const COL_SCROLL_TH:uint = 0x7744BB; // scrollbar thumb

        private var _blockingOverlay:Sprite;
        private var _contentSprite:Sprite;   // container shifted to implement scroll
        private var _maskShape:Shape;
        private var _scrollTrack:Sprite;
        private var _scrollThumb:Sprite;
        private var _scrollOffset:Number   = 0; // pixels scrolled from top
        private var _totalContentH:Number  = 0;
        private var _closeBtn:Sprite;

        public function ChangelogPanel() {
            super();
            build();
        }

        // -----------------------------------------------------------------------
        // Build chrome (title, separator, scrollbar track, close button)

        private function build():void {
            // Background
            graphics.beginFill(COL_BG, 0.97);
            graphics.lineStyle(2, COL_BORDER);
            graphics.drawRoundRect(0, 0, PANEL_W, PANEL_H, 12, 12);
            graphics.endFill();

            // Title
            var title:TextField = makeLabelTf("Archipelago Changelog", PANEL_W, 28, COL_TITLE, 17, true, true);
            title.x = 0;
            title.y = PADDING - 2;
            addChild(title);

            // Separator line
            graphics.lineStyle(1, COL_BORDER, 0.5);
            graphics.moveTo(PADDING, HEADER_H - 4);
            graphics.lineTo(PANEL_W - PADDING, HEADER_H - 4);

            // Content sprite (will be shifted to scroll)
            _contentSprite = new Sprite();
            _contentSprite.mouseEnabled = false;
            _contentSprite.mouseChildren = false;
            _contentSprite.y = BODY_TOP;
            addChild(_contentSprite);

            // Clip mask — must be added to display list AFTER _contentSprite
            _maskShape = new Shape();
            _maskShape.graphics.beginFill(0xFF0000);
            _maskShape.graphics.drawRect(0, BODY_TOP, PANEL_W - SCROLL_W - 2, VISIBLE_H);
            _maskShape.graphics.endFill();
            addChild(_maskShape);
            _contentSprite.mask = _maskShape;

            // Scrollbar track (right edge)
            _scrollTrack = new Sprite();
            _scrollTrack.graphics.beginFill(COL_SCROLL_TR);
            _scrollTrack.graphics.drawRoundRect(0, 0, SCROLL_W, VISIBLE_H, 4, 4);
            _scrollTrack.graphics.endFill();
            _scrollTrack.x = PANEL_W - PADDING * 0.5 - SCROLL_W;
            _scrollTrack.y = BODY_TOP;
            addChild(_scrollTrack);

            // Scrollbar thumb (drawn by _updateScrollbar)
            _scrollThumb = new Sprite();
            _scrollThumb.x = _scrollTrack.x;
            _scrollThumb.y = BODY_TOP;
            addChild(_scrollThumb);

            // Close button
            _closeBtn = makeButton("Close", COL_BTN_BG, 80, 24);
            _closeBtn.x = (PANEL_W - 80) / 2;
            _closeBtn.y = PANEL_H - FOOTER_H + (FOOTER_H - 24) / 2;
            _closeBtn.addEventListener(MouseEvent.CLICK, onCloseClicked, false, 0, true);
            addChild(_closeBtn);

            // Mouse-wheel scrolling — listen on the panel itself
            addEventListener(MouseEvent.MOUSE_WHEEL, onWheel, false, 0, true);
        }

        // -----------------------------------------------------------------------
        // Content population

        /**
         * Clear and rebuild the scrollable content from an Array of release objects.
         * Each entry must have: tag (String), name (String), body (String), date (String).
         * If releases is null or empty, shows a "no changelog available" message.
         */
        public function populate(releases:Array):void {
            // Clear existing children from content sprite
            while (_contentSprite.numChildren > 0) {
                _contentSprite.removeChildAt(0);
            }
            _scrollOffset = 0;

            var yPos:Number = 0;
            var entryList:Array = (releases != null && releases.length > 0)
                ? releases
                : [{ tag: "", name: "No changelog available", body: "Could not load release data.", date: "" }];

            for each (var entry:Object in entryList) {
                var tag:String  = String(entry.tag  || "");
                var name:String = String(entry.name || tag);
                var body:String = String(entry.body || "");
                var date:String = String(entry.date || "");

                // Version tag heading (bold gold)
                var headLabel:String = (tag.length > 0 && name != tag) ? tag + "  —  " + name : (tag.length > 0 ? tag : name);
                var tagTf:TextField = makeLabelTf(headLabel, BODY_W - 100, 20, COL_TAG, 14, true, false);
                tagTf.x = PADDING;
                tagTf.y = yPos;
                _contentSprite.addChild(tagTf);

                // Date (right-aligned, muted)
                if (date.length > 0) {
                    var dateTf:TextField = makeLabelTf(date, 90, 18, COL_DATE, 11, false, true);
                    dateTf.x = BODY_W - 80;
                    dateTf.y = yPos + 2;
                    _contentSprite.addChild(dateTf);
                }
                yPos += 22;

                // Body text (multiline, word-wrapped)
                if (body.length > 0) {
                    var bodyTf:TextField = makeBodyTf(body, BODY_W);
                    bodyTf.x = PADDING;
                    bodyTf.y = yPos;
                    _contentSprite.addChild(bodyTf);
                    yPos += bodyTf.textHeight + 6; // use textHeight for actual rendered height
                }

                // Gap between releases
                yPos += 14;
            }

            _totalContentH = yPos;
            _updateScrollbar();
            _contentSprite.y = BODY_TOP;
        }

        // -----------------------------------------------------------------------
        // Overlay management

        /** Returns true if the panel is currently shown on stage. */
        public function get isShowing():Boolean {
            return _blockingOverlay != null && _blockingOverlay.parent != null;
        }

        /** Show with a full-stage blocking overlay. */
        public function showWithOverlay(stg:Stage):void {
            if (isShowing) return;

            if (_blockingOverlay == null) {
                _blockingOverlay = new Sprite();
                _blockingOverlay.graphics.beginFill(0x000000, 0.88);
                _blockingOverlay.graphics.drawRect(-500, -500, 3000, 3000);
                _blockingOverlay.graphics.endFill();
            }

            if (this.parent != null) this.parent.removeChild(this);
            _blockingOverlay.addChild(this);

            this.x = Math.round((stg.stageWidth  - PANEL_W) / 2);
            this.y = Math.round((stg.stageHeight - PANEL_H) / 2);

            stg.addChild(_blockingOverlay);
            stg.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
        }

        /** Remove the overlay from stage. */
        public function dismiss():void {
            if (_blockingOverlay != null && _blockingOverlay.parent != null) {
                var stg:Stage = _blockingOverlay.parent as Stage;
                if (stg != null) stg.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
                _blockingOverlay.parent.removeChild(_blockingOverlay);
            }
            // Reset scroll for next open
            _scrollOffset = 0;
            if (_contentSprite != null) _contentSprite.y = BODY_TOP;
            _updateScrollbar();
        }

        // -----------------------------------------------------------------------
        // Fallback data

        /**
         * Hardcoded release entries used when the GitHub API cannot be reached
         * and no cached data is available.
         */
        public static function getFallbackReleases():Array {
            return [
                {
                    tag:  "unknown",
                    date: "2025-04-07",
                    body: "  \u2022Unable to connect to Github to collect release log"                        
                }                
            ];
        }

        // -----------------------------------------------------------------------
        // Scrolling

        private function onWheel(e:MouseEvent):void {
            // delta > 0 = wheel up = scroll toward top = decrease offset
            // delta < 0 = wheel down = scroll toward bottom = increase offset
            _scrollOffset -= e.delta * 25;
            _clampAndApplyScroll();
        }

        private function _clampAndApplyScroll():void {
            var maxOffset:Number = Math.max(0, _totalContentH - VISIBLE_H);
            if (_scrollOffset < 0)          _scrollOffset = 0;
            if (_scrollOffset > maxOffset)  _scrollOffset = maxOffset;
            _contentSprite.y = BODY_TOP - _scrollOffset;
            _updateScrollbar();
        }

        private function _updateScrollbar():void {
            _scrollThumb.graphics.clear();
            if (_totalContentH <= VISIBLE_H) return; // no scrollbar needed

            var thumbH:Number = Math.max(20, VISIBLE_H * (VISIBLE_H / _totalContentH));
            var maxScroll:Number = _totalContentH - VISIBLE_H;
            var thumbY:Number = (maxScroll > 0)
                ? (BODY_TOP + (_scrollOffset / maxScroll) * (VISIBLE_H - thumbH))
                : BODY_TOP;

            _scrollThumb.graphics.beginFill(COL_SCROLL_TH, 0.85);
            _scrollThumb.graphics.drawRoundRect(0, 0, SCROLL_W, thumbH, 4, 4);
            _scrollThumb.graphics.endFill();
            _scrollThumb.y = thumbY;
        }

        // -----------------------------------------------------------------------
        // Event handlers

        private function onCloseClicked(e:MouseEvent):void {
            dismiss();
        }

        private function onKeyDown(e:KeyboardEvent):void {
            if (e.keyCode == Keyboard.ESCAPE) dismiss();
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

        private function makeBodyTf(text:String, w:Number):TextField {
            var fmt:TextFormat = new TextFormat("_sans", 13, COL_BODY);
            var tf:TextField = new TextField();
            tf.defaultTextFormat = fmt;
            tf.selectable   = false;
            tf.mouseEnabled = false;
            tf.multiline    = true;
            tf.wordWrap     = true;
            tf.autoSize     = TextFieldAutoSize.LEFT;
            tf.width        = w;
            tf.text         = text;
            // After autoSize, height adjusts to content — read textHeight for layout.
            return tf;
        }

        private function makeButton(label:String, bgColor:uint,
                                    w:Number, h:Number):Sprite {
            var btn:Sprite = new Sprite();
            _drawBtnFace(btn, bgColor, w, h, false);

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
            btn.addEventListener(MouseEvent.MOUSE_OVER, onBtnOver, false, 0, true);
            btn.addEventListener(MouseEvent.MOUSE_OUT,  onBtnOut,  false, 0, true);
            return btn;
        }

        private function _drawBtnFace(btn:Sprite, bgColor:uint,
                                      w:Number, h:Number, hover:Boolean):void {
            var fill:uint = hover ? _brighten(bgColor, 0.35) : bgColor;
            btn.graphics.clear();
            btn.graphics.beginFill(fill);
            btn.graphics.lineStyle(1, COL_BTN_BD);
            btn.graphics.drawRoundRect(0, 0, w, h, 7, 7);
            btn.graphics.endFill();
        }

        private function onBtnOver(e:MouseEvent):void {
            _drawBtnFace(e.currentTarget as Sprite, COL_BTN_BG, 80, 24, true);
        }

        private function onBtnOut(e:MouseEvent):void {
            _drawBtnFace(e.currentTarget as Sprite, COL_BTN_BG, 80, 24, false);
        }

        private function _brighten(color:uint, amount:Number):uint {
            var r:int = Math.min(255, int((color >> 16 & 0xFF) + 255 * amount));
            var g:int = Math.min(255, int((color >> 8  & 0xFF) + 255 * amount));
            var b:int = Math.min(255, int((color       & 0xFF) + 255 * amount));
            return (r << 16) | (g << 8) | b;
        }
    }
}

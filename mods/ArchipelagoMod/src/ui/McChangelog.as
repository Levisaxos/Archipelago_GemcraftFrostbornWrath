package ui {
    import com.giab.games.gcfw.mcDyn.McOptTitle;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.geom.Rectangle;
    import flash.text.StaticText;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.getDefinitionByName;

    /**
     * Changelog view rendered inside the game's McOptions chrome.
     * Mirrors McSlotSettings: uses McOptTitle for section headers and
     * MovieClip-wrapped TextFields for body lines.
     *
     * Used by ScrChangelog to manage lifecycle and scrolling.
     */
    public class McChangelog extends MovieClip {

        private var _inner:*;

        // Expose McOptions chrome members to ScrChangelog (same as McSlotSettings)
        public function get arrCntContents():Array       { return _inner.arrCntContents; }
        public function get btnClose():*                 { return _inner.btnClose; }
        public function get btnScrollKnob():MovieClip    { return _inner.btnScrollKnob; }
        public function get mcScrollBar():*              { return _inner.mcScrollBar; }
        public function get btnConfirmRetry():*          { return _inner.btnConfirmRetry; }
        public function get btnConfirmReturn():*         { return _inner.btnConfirmReturn; }
        public function get btnConfirmEndBattle():*      { return _inner.btnConfirmEndBattle; }
        public function get btnEndBattle():*             { return _inner.btnEndBattle; }
        public function get btnReturn():*                { return _inner.btnReturn; }
        public function get btnRetry():*                 { return _inner.btnRetry; }
        public function get btnMainMenu():*              { return _inner.btnMainMenu; }

        // Layout — full stage width, roughly x: 200–1720; HEADER_X is McOptTitle centre point
        private static const CONTENT_START_Y:Number = 140;
        private static const HEADER_HEIGHT:Number   = 55;  // matches McSlotSettings ROW_HEIGHT
        private static const LINE_HEIGHT:Number     = 28;  // per body-text line
        private static const RELEASE_GAP:Number     = 24;  // extra space between releases
        private static const HEADER_X:Number        = 536; // centred, same as McDebugOptions
        private static const BODY_X:Number          = 200; // left edge of body text
        private static const BODY_W:Number          = 1520; // spans full stage width

        public function McChangelog(releases:Array) {
            super();

            var McOptionsClass:Class =
                getDefinitionByName("com.giab.games.gcfw.mcStat.McOptions") as Class;
            _inner = new McOptionsClass();
            addChild(_inner);

            overlayTitle("Archipelago Changelog");

            // Clear any default content from the chrome
            while (_inner.cnt.numChildren > 0) _inner.cnt.removeChildAt(0);
            _inner.arrCntContents = new Array();

            var vY:Number = CONTENT_START_Y;

            var list:Array = (releases != null && releases.length > 0)
                ? releases
                : [{ tag: "", name: "Could not reach GitHub", date: "",
                     body: "Release notes are unavailable.\nPlease check your internet connection." }];

            for each (var entry:Object in list) {
                var tag:String  = String(entry.tag  || "");
                var name:String = String(entry.name || tag);
                var body:String = String(entry.body || "");
                var date:String = String(entry.date || "");

                // Version / date header — centred, game-styled
                var headerText:String = tag;
                if (name.length > 0 && name != tag) headerText += "  —  " + name;
                if (date.length > 0) headerText += "  ·  " + date;
                addSectionHeader(headerText, vY);
                vY += HEADER_HEIGHT;

                // Body lines — advance vY by actual rendered height so wrapped
                // lines don't overlap the next entry.
                if (body.length > 0) {
                    var lines:Array = body.split("\n");
                    for each (var line:String in lines) {
                        line = line.replace(/^\s+|\s+$/g, "");
                        if (line.length == 0) { vY += LINE_HEIGHT * 0.5; continue; }
                        vY += addBodyLine(line, vY);
                    }
                }

                vY += RELEASE_GAP;
            }

            // Add all content items to the scrollable container
            for (var i:int = 0; i < _inner.arrCntContents.length; i++) {
                _inner.cnt.addChild(_inner.arrCntContents[i]);
            }
        }


        // -----------------------------------------------------------------------
        // Content helpers

        private function addSectionHeader(text:String, y:Number):void {
            _inner.arrCntContents.push(new McOptTitle(text, HEADER_X, y));
        }

        /**
         * Body lines use a MovieClip wrapper so we can attach the yReal property
         * that the ScrChangelog viewport system relies on (MovieClip is dynamic).
         * Returns the actual rendered height (including word-wrap) plus a small gap,
         * so the caller can advance vY correctly.
         */
        private function addBodyLine(text:String, y:Number):Number {
            var lm:MovieClip = new MovieClip();
            lm["yReal"] = y;

            var fmt:TextFormat = new TextFormat("Palatino Linotype", 18, 0xDDCCBB);
            var tf:TextField = new TextField();
            tf.defaultTextFormat = fmt;
            tf.selectable   = false;
            tf.mouseEnabled = false;
            tf.multiline    = false;
            tf.wordWrap     = false;
            tf.x            = BODY_X;
            tf.width        = BODY_W;
            tf.text         = text;
            lm.addChild(tf);

            _inner.arrCntContents.push(lm);

            // textHeight gives the actual rendered height; add a small gap below.
            return tf.textHeight + 6;
        }

        // -----------------------------------------------------------------------
        // Title overlay (identical to McSlotSettings / McDebugOptions)

        private function overlayTitle(label:String):void {
            var original:StaticText = findStaticText(_inner, "Options");
            if (original != null) {
                original.visible = false;
                var bounds:Rectangle = original.getBounds(original.parent);
                var tf:TextField = new TextField();
                var fmt:TextFormat = new TextFormat("Palatino Linotype", 28, 0xffffff, true);
                fmt.align = "center";
                tf.defaultTextFormat = fmt;
                tf.selectable   = false;
                tf.mouseEnabled = false;
                var tfWidth:Number = 400;
                tf.x      = bounds.x + bounds.width / 2 - tfWidth / 2;
                tf.y      = bounds.y;
                tf.width  = tfWidth;
                tf.height = bounds.height + 8;
                tf.text   = label;
                original.parent.addChild(tf);
            }
        }

        private function findStaticText(obj:DisplayObjectContainer, search:String):StaticText {
            for (var i:int = 0; i < obj.numChildren; i++) {
                var child:* = obj.getChildAt(i);
                if (child is StaticText && StaticText(child).text == search) return StaticText(child);
                if (child is DisplayObjectContainer) {
                    var found:StaticText = findStaticText(DisplayObjectContainer(child), search);
                    if (found != null) return found;
                }
            }
            return null;
        }
    }
}

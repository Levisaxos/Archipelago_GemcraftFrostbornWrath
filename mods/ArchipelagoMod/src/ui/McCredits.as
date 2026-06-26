package ui {
    import com.giab.games.gcfw.mcDyn.McOptTitle;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.text.StaticText;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.geom.Rectangle;
    import flash.utils.getDefinitionByName;

    /**
     * Credits / Thanks view rendered inside the game's McOptions chrome.
     * Mirrors McChangelog: McOptTitle for section headers and MovieClip-wrapped
     * TextFields for body lines. Content comes from CreditsData.getSections().
     *
     * Used by ScrCredits to manage lifecycle and scrolling.
     */
    public class McCredits extends MovieClip {

        private var _inner:*;

        // Expose McOptions chrome members to ScrCredits (same as McChangelog)
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

        // Layout — mirrors McChangelog
        private static const CONTENT_START_Y:Number = 140;
        private static const HEADER_HEIGHT:Number   = 55;  // matches McChangelog
        private static const LINE_HEIGHT:Number     = 28;  // per body-text line
        private static const SECTION_GAP:Number     = 24;  // extra space between sections
        private static const HEADER_X:Number        = 536; // centred, same as McChangelog
        private static const BODY_X:Number          = 200; // left edge of body text
        private static const BODY_W:Number          = 1520; // spans full stage width

        public function McCredits(sections:Array) {
            super();

            var McOptionsClass:Class =
                getDefinitionByName("com.giab.games.gcfw.mcStat.McOptions") as Class;
            _inner = new McOptionsClass();
            addChild(_inner);

            overlayTitle("Credits & Thanks");

            // Clear any default content from the chrome
            while (_inner.cnt.numChildren > 0)
            {
                _inner.cnt.removeChildAt(0);
            }
            _inner.arrCntContents = new Array();

            var list:Array = (sections != null && sections.length > 0)
                ? sections
                : [{ sectionTitle: "Credits", lines: ["No credits available."] }];

            var vY:Number = CONTENT_START_Y;
            for each (var section:Object in list)
            {
                var sectionTitle:String = String(section.sectionTitle || "");
                var lines:Array         = (section.lines as Array) || [];

                // Section header — centred, game-styled
                addSectionHeader(sectionTitle, vY);
                vY += HEADER_HEIGHT;

                // Body lines — advance vY by actual rendered height.
                for each (var rawLine:String in lines)
                {
                    var line:String = String(rawLine);
                    if (line.length == 0)
                    {
                        vY += LINE_HEIGHT * 0.5;
                        continue;
                    }
                    vY += addBodyLine(line, vY);
                }

                vY += SECTION_GAP;
            }

            // Add all content items to the scrollable container
            for (var i:int = 0; i < _inner.arrCntContents.length; i++)
            {
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
         * that the scrolling viewport relies on (MovieClip is dynamic).
         * Returns the actual rendered height plus a small gap.
         */
        private function addBodyLine(text:String, y:Number):Number {
            var lineMovie:MovieClip = new MovieClip();
            lineMovie["yReal"] = y;

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
            lineMovie.addChild(tf);

            _inner.arrCntContents.push(lineMovie);

            // textHeight gives the actual rendered height; add a small gap below.
            return tf.textHeight + 6;
        }

        // -----------------------------------------------------------------------
        // Title overlay (identical to McChangelog / McSlotSettings)

        private function overlayTitle(label:String):void {
            var original:StaticText = findStaticText(_inner, "Options");
            if (original != null)
            {
                original.visible = false;
                var bounds:Rectangle = original.getBounds(original.parent);
                var tf:TextField = new TextField();
                var fmt:TextFormat = new TextFormat("Palatino Linotype", 28, 0xffffff, true);
                fmt.align = "center";
                tf.defaultTextFormat = fmt;
                tf.selectable   = false;
                tf.mouseEnabled = false;
                var titleWidth:Number = 400;
                tf.x      = bounds.x + bounds.width / 2 - titleWidth / 2;
                tf.y      = bounds.y;
                tf.width  = titleWidth;
                tf.height = bounds.height + 8;
                tf.text   = label;
                original.parent.addChild(tf);
            }
        }

        private function findStaticText(obj:DisplayObjectContainer, search:String):StaticText {
            for (var i:int = 0; i < obj.numChildren; i++)
            {
                var child:* = obj.getChildAt(i);
                if (child is StaticText && StaticText(child).text == search)
                {
                    return StaticText(child);
                }
                if (child is DisplayObjectContainer)
                {
                    var found:StaticText = findStaticText(DisplayObjectContainer(child), search);
                    if (found != null)
                    {
                        return found;
                    }
                }
            }
            return null;
        }
    }
}

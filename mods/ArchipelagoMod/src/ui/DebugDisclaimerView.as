package ui {

    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;

    /**
     * One rich-text block of the AP Debug Menu's "Disclaimer" tab.
     *
     * The disclaimer is split into several stacked blocks (see build()) instead
     * of one tall TextField. ScrollablePanel (mirroring the vanilla McOptions
     * viewport) shows/hides and scrolls each content item by its own `yReal`,
     * with no mask: an item is visible only while 50 < y < 920, and the scroll
     * range is derived from each item's `yReal` (its top). A single oversized
     * item therefore can neither establish a scroll range nor stay visible once
     * its top scrolls past the clip line. Small stacked blocks behave exactly
     * like the row-based tabs.
     *
     * Each block exposes `yReal` (required by the viewport system) and
     * `contentHeight` (its measured text height, used to stack the next block).
     */
    public class DebugDisclaimerView extends Sprite {

        /** Required by the McDebugOptions viewport system — set in constructor. */
        public var yReal:Number;

        private var _tf:TextField;

        private static const COL_HEADING:uint = 0xEEDDFF;
        private static const COL_BODY:uint    = 0xCCC0DD;
        private static const COL_WARN:uint    = 0xFF7744;

        // Vertical gap inserted between stacked blocks.
        private static const BLOCK_GAP:Number = 18;

        // Extra scroll room past the final block (~2 blank lines at 18px + leading)
        // so the last line isn't flush against the viewport's bottom clip edge.
        private static const TRAILING_SCROLL_PAD:Number = 48;

        public function DebugDisclaimerView(x:Number, y:Number, width:Number, html:String) {
            super();
            this.x        = x;
            this.y        = y;
            this.yReal    = y;
            mouseEnabled  = false;
            mouseChildren = false;

            _tf = new TextField();
            _tf.width        = width;
            _tf.multiline    = true;
            _tf.wordWrap     = true;
            _tf.selectable   = false;
            _tf.mouseEnabled = false;
            _tf.embedFonts   = false;
            _tf.autoSize     = TextFieldAutoSize.LEFT;

            var fmt:TextFormat = new TextFormat("Palatino Linotype", 18, COL_BODY, false);
            fmt.leading = 6;
            _tf.defaultTextFormat = fmt;

            _tf.htmlText = html;
            addChild(_tf);
        }

        /** Measured height of the rendered text block (autoSize gives this
         *  immediately, even before the block is on the display list). */
        public function get contentHeight():Number { return _tf.height; }

        /**
         * Build the disclaimer as an Array of stacked DebugDisclaimerView blocks,
         * each positioned below the previous by its measured height + BLOCK_GAP.
         * The result drops straight into McDebugOptions.arrCntContents so the
         * shared scroll/viewport logic handles it like any other tab.
         */
        public static function build(x:Number, startY:Number, width:Number):Array {
            var sections:Array = _sections();
            var arr:Array = [];
            var vY:Number = startY;
            var last:DebugDisclaimerView = null;
            for (var i:int = 0; i < sections.length; i++) {
                var block:DebugDisclaimerView = new DebugDisclaimerView(x, vY, width, String(sections[i]));
                arr.push(block);
                last = block;
                vY += block.contentHeight + BLOCK_GAP;
            }
            // Trailing blank spacer: extends the scroll range ~2 lines past the
            // final block. Its yReal (a touch below the last block's top) is all
            // the scroll-range math reads; the content stays empty on purpose.
            if (last != null) {
                arr.push(new DebugDisclaimerView(x, last.yReal + TRAILING_SCROLL_PAD, width, ""));
            }
            return arr;
        }

        /**
         * The disclaimer copy, split into individually-scrollable blocks. Each
         * heading is kept in the same block as the body it introduces so they
         * scroll together; blocks are otherwise split at section boundaries to
         * keep every item short.
         */
        private static function _sections():Array {
            var heading:String = _hex(COL_HEADING);
            var body:String    = _hex(COL_BODY);
            var warn:String    = _hex(COL_WARN);

            return [
                "<font color=\"" + heading + "\" size=\"22\"><b>Why this menu exists</b></font><br><br>"
                    + "<font color=\"" + body + "\">This menu is here to help you recover from Archipelago logic problems — a softlock, a hardlock, or a check that logic says should be reachable but that you cannot actually get to. It lets you grant yourself the specific item, unlock, or achievement check you need to get moving again.</font>",

                "<font color=\"" + heading + "\" size=\"22\"><b>How to use it</b></font><br><br>"
                    + "<font color=\"" + body + "\">Pick the tab for what you are missing and click the entry you need. There are two very different kinds of action here:</font>",

                "<font color=\"" + warn + "\"><b>Achievements tab — affects your whole multiworld.</b> Clicking an achievement releases that location's check, sending the item behind it to whichever player it belongs to. This is the only tab that unlocks anything in Archipelago or changes another player's game.</font>",

                "<font color=\"" + body + "\"><b>Every other tab (Levels, Skills, Traits, Stages, Talismans, Cores, XP) — local to your game only.</b> These grant the item or unlock directly in your current save. Nothing is sent out to the server and no check is released.</font>",

                "<font color=\"" + body + "\">Note that Skills, Traits, Stages and Levels change the game but are not seen by the mod's logic tracker (which only counts things actually received from AP), while Talismans, Cores and XP are applied as if received and do update your local tracker — but still send nothing outward. Playing on afterwards will, of course, earn real checks that report to AP as normal.</font>",

                "<font color=\"" + warn + "\" size=\"22\"><b>Please read</b></font><br><br>"
                    + "<font color=\"" + warn + "\">Using this menu for anything other than resolving a genuine logic bug, softlock, or hardlock is cheating. The Achievements tab in particular releases checks that affect everyone in your multiworld. Use it at your own discretion.</font>"
            ];
        }

        /** Format a 0xRRGGBB uint as an HTML "#RRGGBB" color string. */
        private static function _hex(color:uint):String {
            var s:String = color.toString(16);
            while (s.length < 6)
                s = "0" + s;
            return "#" + s;
        }
    }
}

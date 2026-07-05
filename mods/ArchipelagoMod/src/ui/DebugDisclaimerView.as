package ui {

    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;

    /**
     * Static informational panel shown as the first ("Disclaimer") tab of the
     * AP Debug Menu. Explains why the menu exists, how to use it, and that using
     * it for anything other than resolving a genuine logic bug / softlock /
     * hardlock is cheating.
     *
     * Sits inside McDebugOptions.arrCntContents, so it exposes a public yReal
     * property just like McOptTitle / McOptPanel / McWizardLevelSlider.
     */
    public class DebugDisclaimerView extends Sprite {

        /** Required by the McDebugOptions viewport system — set in constructor. */
        public var yReal:Number;

        private static const COL_HEADING:uint = 0xEEDDFF;
        private static const COL_BODY:uint    = 0xCCC0DD;
        private static const COL_WARN:uint    = 0xFF7744;

        public function DebugDisclaimerView(x:Number, y:Number, width:Number) {
            super();
            this.x        = x;
            this.y        = y;
            this.yReal    = y;
            mouseEnabled  = false;
            mouseChildren = false;

            var tf:TextField = new TextField();
            tf.width        = width;
            tf.multiline    = true;
            tf.wordWrap     = true;
            tf.selectable   = false;
            tf.mouseEnabled = false;
            tf.embedFonts   = false;
            tf.autoSize     = TextFieldAutoSize.LEFT;

            var fmt:TextFormat = new TextFormat("Palatino Linotype", 18, COL_BODY, false);
            fmt.leading = 6;
            tf.defaultTextFormat = fmt;

            tf.htmlText = _buildHtml();
            addChild(tf);
        }

        private function _buildHtml():String {
            var heading:String = _hex(COL_HEADING);
            var body:String    = _hex(COL_BODY);
            var warn:String    = _hex(COL_WARN);

            var s:String = "";
            s += "<font color=\"" + heading + "\" size=\"22\"><b>Why this menu exists</b></font><br><br>";
            s += "<font color=\"" + body + "\">This menu is here to help you recover from Archipelago logic problems — a softlock, a hardlock, or a check that logic says should be reachable but that you cannot actually get to. It lets you grant yourself the specific item, unlock, or achievement check you need to get moving again.</font><br><br>";
            s += "<font color=\"" + heading + "\" size=\"22\"><b>How to use it</b></font><br><br>";
            s += "<font color=\"" + body + "\">Pick the tab for what you are missing — Levels, Skills, Traits, Stages, Talismans, Cores, or Achievements — and click the entry you need. Grants apply immediately and achievement checks are released to the multiworld.</font><br><br>";
            s += "<font color=\"" + warn + "\" size=\"22\"><b>Please read</b></font><br><br>";
            s += "<font color=\"" + warn + "\">Using this menu for anything other than resolving a genuine logic bug, softlock, or hardlock is cheating. It directly grants items and releases checks that affect everyone in your multiworld. Use it at your own discretion.</font>";
            return s;
        }

        /** Format a 0xRRGGBB uint as an HTML "#RRGGBB" color string. */
        private function _hex(color:uint):String {
            var s:String = color.toString(16);
            while (s.length < 6)
                s = "0" + s;
            return "#" + s;
        }
    }
}

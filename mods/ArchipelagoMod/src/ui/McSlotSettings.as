package ui {

    import com.giab.games.gcfw.mcDyn.McOptTitle;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.geom.Rectangle;
    import flash.text.StaticText;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.getDefinitionByName;

    import net.ConnectionManager;
    import deathlink.DeathLinkHandler;

    /**
     * Read-only view of the current AP slot settings, rendered inside the
     * game's McOptions chrome.  Built once per connection via ScrSlotSettings.
     *
     * Layout mirrors McDebugOptions: two McOptTitle columns (label | value)
     * per row.  No interactive elements — close button is handled by ScrSlotSettings.
     */
    public class McSlotSettings extends MovieClip {

        private var _inner:*;

        // Getters to expose McOptions chrome to ScrSlotSettings
        public function get arrCntContents():Array        { return _inner.arrCntContents; }
        public function get btnClose():*                  { return _inner.btnClose; }
        public function get btnScrollKnob():MovieClip     { return _inner.btnScrollKnob; }
        public function get mcScrollBar():*               { return _inner.mcScrollBar; }
        public function get btnConfirmRetry():*           { return _inner.btnConfirmRetry; }
        public function get btnConfirmReturn():*          { return _inner.btnConfirmReturn; }
        public function get btnConfirmEndBattle():*       { return _inner.btnConfirmEndBattle; }
        public function get btnEndBattle():*              { return _inner.btnEndBattle; }
        public function get btnReturn():*                 { return _inner.btnReturn; }
        public function get btnRetry():*                  { return _inner.btnRetry; }
        public function get btnMainMenu():*               { return _inner.btnMainMenu; }

        // Layout
        private static const CONTENT_START_Y:Number = 140;
        private static const ROW_HEIGHT:Number       = 55;
        private static const SECTION_GAP:Number      = 30;
        private static const LABEL_X:Number          = 250;
        private static const VALUE_X:Number          = 800;
        private static const HEADER_X:Number         = 536; // centred, same as McDebugOptions TITLE_X

        public function McSlotSettings(cm:ConnectionManager, dl:DeathLinkHandler) {
            super();

            var McOptionsClass:Class =
                getDefinitionByName("com.giab.games.gcfw.mcStat.McOptions") as Class;
            _inner = new McOptionsClass();
            addChild(_inner);

            overlayTitle("AP Slot Settings");

            while (_inner.cnt.numChildren > 0) _inner.cnt.removeChildAt(0);
            _inner.arrCntContents = new Array();

            var vY:Number = CONTENT_START_Y;

            // ── General settings ─────────────────────────────────────────────
            addSectionHeader("General", vY); vY += ROW_HEIGHT;
            addRow("Goal",                    goalName(cm.goal), vY);                               vY += ROW_HEIGHT;
            addRow("Field Token Placement",   ftpName(cm.fieldTokenPlacement), vY);                 vY += ROW_HEIGHT;
            addRow("Tier Requirement",        cm.tierRequirements + "%", vY);                       vY += ROW_HEIGHT;
            addRow("Enforce Logic",           cm.enforceLogic ? "Yes" : "No", vY);                  vY += ROW_HEIGHT;
            addRow("Endurance Mode",          cm.disableEndurance ? "Disabled" : "Enabled", vY);    vY += ROW_HEIGHT;
            addRow("Trial Mode",              cm.disableTrial     ? "Disabled" : "Enabled", vY);    vY += ROW_HEIGHT;
            addRow("Starting Wizard Level",   cm.startingWizardLevel == 1 ? "Off" : "Level " + cm.startingWizardLevel, vY); vY += ROW_HEIGHT;
            addRow("Starting Overcrowd",      cm.startingOvercrowd ? "Yes" : "No", vY);             vY += ROW_HEIGHT;
            addRow("Tattered Scroll",         cm.tatteredScrollLevels + " levels", vY);              vY += ROW_HEIGHT;
            addRow("Worn Tome",               cm.wornTomeLevels       + " levels", vY);              vY += ROW_HEIGHT;
            addRow("Ancient Grimoire",        cm.ancientGrimoireLevels + " levels", vY);             vY += ROW_HEIGHT;

            // ── Difficulty Modifiers ─────────────────────────────────────────
            vY += SECTION_GAP;
            addSectionHeader("Difficulty Modifiers", vY); vY += ROW_HEIGHT;
            addRow("Enemy HP",               cm.enemyHpMultiplier          + "%", vY);               vY += ROW_HEIGHT;
            addRow("Enemy Armor",            cm.enemyArmorMultiplier        + "%", vY);              vY += ROW_HEIGHT;
            addRow("Enemy Shield",           cm.enemyShieldMultiplier       + "%", vY);              vY += ROW_HEIGHT;
            addRow("Enemies Per Wave",       cm.enemiesPerWaveMultiplier    + "%", vY);              vY += ROW_HEIGHT;
            addRow("Extra Waves",            cm.extraWaveCount == 0 ? "Off" : "+" + cm.extraWaveCount, vY); vY += ROW_HEIGHT;

            // ── DeathLink ────────────────────────────────────────────────────
            vY += SECTION_GAP;
            addSectionHeader("DeathLink", vY); vY += ROW_HEIGHT;
            addRow("Enabled", dl.enabled ? "Yes" : "No", vY); vY += ROW_HEIGHT;

            if (dl.enabled) {
                addRow("Punishment", punishmentName(dl.punishment), vY); vY += ROW_HEIGHT;

                if (dl.punishment == DeathLinkHandler.PUNISHMENT_GEM_LOSS) {
                    addRow("Gem Loss", dl.gemLossPercent + "%", vY); vY += ROW_HEIGHT;
                } else if (dl.punishment == DeathLinkHandler.PUNISHMENT_WAVE_SURGE) {
                    addRow("Surge Count",     String(dl.waveSurgeCount),    vY); vY += ROW_HEIGHT;
                    addRow("Surge Gem Level", String(dl.waveSurgeGemLevel), vY); vY += ROW_HEIGHT;
                }

                addRow("Grace Period", dl.gracePeriodSec + "s", vY); vY += ROW_HEIGHT;
                addRow("Cooldown",     dl.cooldownSec + "s",    vY); vY += ROW_HEIGHT;
            }

            for (var i:int = 0; i < _inner.arrCntContents.length; i++) {
                _inner.cnt.addChild(_inner.arrCntContents[i]);
            }
        }

        // -----------------------------------------------------------------------
        // Row helpers

        private function addSectionHeader(text:String, y:Number):void {
            _inner.arrCntContents.push(new McOptTitle(text, HEADER_X, y));
        }

        private function addRow(label:String, value:String, y:Number):void {
            _inner.arrCntContents.push(new McOptTitle(label, LABEL_X, y));
            _inner.arrCntContents.push(new McOptTitle(value, VALUE_X, y));
        }

        // -----------------------------------------------------------------------
        // Value formatters

        private function goalName(goal:int):String {
            switch (goal) {
                case 0:  return "Beat Gatekeeper (A4)";
                case 2:  return "Beat Swarm Queen (K4)";
                default: return "Unknown (" + goal + ")";
            }
        }

        private function ftpName(ftp:int):String {
            switch (ftp) {
                case 0:  return "Own World";
                case 1:  return "Any World";
                case 2:  return "Different World";
                default: return "Unknown (" + ftp + ")";
            }
        }

        private function punishmentName(p:int):String {
            switch (p) {
                case DeathLinkHandler.PUNISHMENT_GEM_LOSS:     return "Gem Loss";
                case DeathLinkHandler.PUNISHMENT_WAVE_SURGE:   return "Wave Surge";
                case DeathLinkHandler.PUNISHMENT_INSTANT_FAIL: return "Instant Fail";
                default: return "Unknown (" + p + ")";
            }
        }

        // -----------------------------------------------------------------------
        // Title overlay (same as McDebugOptions)

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

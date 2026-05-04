package ui {

    import com.giab.games.gcfw.mcDyn.McOptTitle;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.geom.Rectangle;
    import flash.text.StaticText;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.getDefinitionByName;

    import data.AV;
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

        public function McSlotSettings(dl:DeathLinkHandler) {
            super();

            var McOptionsClass:Class =
                getDefinitionByName("com.giab.games.gcfw.mcStat.McOptions") as Class;
            _inner = new McOptionsClass();
            addChild(_inner);

            overlayTitle("AP Slot Settings");

            while (_inner.cnt.numChildren > 0) _inner.cnt.removeChildAt(0);
            _inner.arrCntContents = new Array();

            var opts:* = AV.serverData.serverOptions;
            var vY:Number = CONTENT_START_Y;

            // ── General settings ─────────────────────────────────────────────
            addSectionHeader("General", vY); vY += ROW_HEIGHT;
            addRow("Goal",                    goalName(opts.goal), vY);                                        vY += ROW_HEIGHT;
            if (opts.goal == 3)
                { addRow("Fields Required",   opts.fieldsRequired + " fields", vY);                           vY += ROW_HEIGHT; }
            if (opts.goal == 4) {
                var pct:int = opts.fieldsRequiredPercentage;
                var count:int = int(Math.ceil(pct * 122.0 / 100.0));
                addRow("Fields Required", count + " (" + pct + "%)", vY);                                     vY += ROW_HEIGHT;
            }
            addRow("Starting Stage",          startingStageName(opts.startingStage), vY);                     vY += ROW_HEIGHT;
            addRow("Field Token Placement",   ftpName(opts.fieldTokenPlacement), vY);                         vY += ROW_HEIGHT;
            addRow("Achievement Required Effort", effortName(opts.achievementRequiredEffort), vY);             vY += ROW_HEIGHT;
            addRow("Enforce Logic",           opts.enforce_logic    ? "Yes" : "No", vY);                      vY += ROW_HEIGHT;
            addRow("Endurance Mode",          opts.disable_endurance ? "Disabled" : "Enabled", vY);           vY += ROW_HEIGHT;
            addRow("Trial Mode",              opts.disable_trial     ? "Disabled" : "Enabled", vY);           vY += ROW_HEIGHT;
            addRow("Starting Wizard Level",   opts.startingWizardLevel == 1 ? "Off" : "Level " + opts.startingWizardLevel, vY); vY += ROW_HEIGHT;
            addRow("Starting Overcrowd",      opts.startingOvercrowd ? "Yes" : "No", vY);                    vY += ROW_HEIGHT;

            // ── Item gating granularity ──────────────────────────────────────
            vY += SECTION_GAP;
            addSectionHeader("Gating", vY); vY += ROW_HEIGHT;
            addRow("Field Token Granularity", fieldTokenGranularityName(opts.fieldTokenGranularity), vY);     vY += ROW_HEIGHT;
            addRow("Stash Key Granularity",   stashKeyGranularityName(opts.stashKeyGranularity), vY);         vY += ROW_HEIGHT;
            addRow("Gem Pouch Granularity",   gemPouchGranularityName(opts.gemPouchGranularity), vY);         vY += ROW_HEIGHT;

            // ── Item economy ─────────────────────────────────────────────────
            vY += SECTION_GAP;
            addSectionHeader("Item Economy", vY); vY += ROW_HEIGHT;
            addRow("XP Tome Bonus",           opts.xpTomeBonus + "%", vY);                                    vY += ROW_HEIGHT;
            addRow("Tattered Scroll",         opts.tomeXpLevels.tattered + " levels", vY);                    vY += ROW_HEIGHT;
            addRow("Worn Tome",               opts.tomeXpLevels.worn     + " levels", vY);                    vY += ROW_HEIGHT;
            addRow("Ancient Grimoire",        opts.tomeXpLevels.ancient  + " levels", vY);                    vY += ROW_HEIGHT;
            addRow("Skillpoint Multiplier",   opts.skillpointMultiplier + "%", vY);                           vY += ROW_HEIGHT;

            // ── Difficulty Modifiers ─────────────────────────────────────────
            vY += SECTION_GAP;
            addSectionHeader("Difficulty Modifiers", vY); vY += ROW_HEIGHT;
            addRow("Enemy HP",               opts.enemyMultipliers.hp     + "%", vY);                         vY += ROW_HEIGHT;
            addRow("Enemy Armor",            opts.enemyMultipliers.armor  + "%", vY);                         vY += ROW_HEIGHT;
            addRow("Enemy Shield",           opts.enemyMultipliers.shield + "%", vY);                         vY += ROW_HEIGHT;
            addRow("Enemies Per Wave",       opts.enemyMultipliers.waves  + "%", vY);                         vY += ROW_HEIGHT;
            addRow("Extra Waves",            opts.enemyMultipliers.extraWaves == 0 ? "Off" : "+" + opts.enemyMultipliers.extraWaves, vY); vY += ROW_HEIGHT;

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
                case 0:  return "Kill Gatekeeper (A4)";
                case 2:  return "Beat Swarm Queen (K4)";
                case 3:  return "Fields Cleared (Count)";
                case 4:  return "Fields Cleared (Percentage)";
                default: return "Unknown (" + goal + ")";
            }
        }

        private function effortName(effort:int):String {
            switch (effort) {
                case 0:  return "Off";
                case 1:  return "Trivial";
                case 2:  return "Minor";
                case 3:  return "Major";
                case 4:  return "Extreme";
                default: return "Unknown (" + effort + ")";
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

        private function startingStageName(s:int):String {
            switch (s) {
                case 0:  return "W1";
                case 1:  return "W2";
                case 2:  return "W3";
                case 3:  return "W4";
                case 4:  return "S1";
                case 5:  return "S2";
                case 6:  return "S3";
                case 7:  return "S4";
                default: return "Unknown (" + s + ")";
            }
        }

        // Field tokens & stash keys share the same granularity values 0-5,
        // and stash keys add 6=global. Render with the same name table.
        private function fieldTokenGranularityName(g:int):String {
            switch (g) {
                case 0:  return "Per Stage";
                case 1:  return "Per Stage (Progressive)";
                case 2:  return "Per Tile";
                case 3:  return "Per Tile (Progressive)";
                case 4:  return "Per Tier";
                case 5:  return "Per Tier (Progressive)";
                default: return "Unknown (" + g + ")";
            }
        }

        private function stashKeyGranularityName(g:int):String {
            if (g == 6) return "Global";
            return fieldTokenGranularityName(g);
        }

        private function gemPouchGranularityName(g:int):String {
            switch (g) {
                case 0:  return "Off";
                case 1:  return "Per Tile";
                case 2:  return "Per Tile (Progressive)";
                case 3:  return "Per Tier";
                case 4:  return "Per Tier (Progressive)";
                case 5:  return "Global";
                default: return "Unknown (" + g + ")";
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

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

            // Section headers + membership mirror the apworld's YAML option_groups
            // (GCFWWebWorld.option_groups in apworld/gcfw/__init__.py). Every
            // yaml-settable option appears here under its yaml group so the panel
            // is a faithful read-only view of what the player could set.

            // ── Game Options ─────────────────────────────────────────────────
            addSectionHeader("Game Options", vY); vY += ROW_HEIGHT;
            addRow("Goal",                    goalName(opts.goal), vY);                                        vY += ROW_HEIGHT;
            if (opts.goal == 2)
                { addRow("Fields Required",   opts.fieldsRequiredCount + " fields", vY);                      vY += ROW_HEIGHT; }
            addRow("Starting Stages",         startingStagesName(opts.startingStages), vY);                   vY += ROW_HEIGHT;
            addRow("Difficulty",              difficultyName(opts.difficulty), vY);                           vY += ROW_HEIGHT;
            addRow("Achievement Required Effort", effortName(opts.achievementRequiredEffort), vY);             vY += ROW_HEIGHT;
            addRow("Endurance Mode",          opts.disable_endurance ? "Disabled" : "Enabled", vY);           vY += ROW_HEIGHT;
            addRow("Trial Mode",              opts.disable_trial     ? "Disabled" : "Enabled", vY);           vY += ROW_HEIGHT;
            addRow("Extra Shadow Cores/Wave", opts.extraShadowCoresPerWave == 0 ? "Off" : "+" + opts.extraShadowCoresPerWave, vY); vY += ROW_HEIGHT;

            // ── Field Options ────────────────────────────────────────────────
            vY += SECTION_GAP;
            addSectionHeader("Field Options", vY); vY += ROW_HEIGHT;
            addRow("Field Token Granularity", fieldTokenGranularityName(opts.fieldTokenGranularity), vY);     vY += ROW_HEIGHT;
            addRow("Stash Key Granularity",   stashKeyGranularityName(opts.stashKeyGranularity), vY);         vY += ROW_HEIGHT;
            addRow("Gem Pouch Granularity",   gemPouchGranularityName(opts.gemPouchGranularity), vY);         vY += ROW_HEIGHT;
            addRow("Field Token Placement",   ftpName(opts.fieldTokenPlacement), vY);                         vY += ROW_HEIGHT;

            // ── Difficulty Multipliers ───────────────────────────────────────
            vY += SECTION_GAP;
            addSectionHeader("Difficulty Multipliers", vY); vY += ROW_HEIGHT;
            addRow("Starting Wizard Level",   opts.startingWizardLevel == 1 ? "Off" : "Level " + opts.startingWizardLevel, vY); vY += ROW_HEIGHT;
            addRow("Starting Overcrowd",      opts.startingOvercrowd ? "Yes" : "No", vY);                    vY += ROW_HEIGHT;
            addRow("XP Tome Bonus",           opts.xpTomeBonus + "%", vY);                                    vY += ROW_HEIGHT;
            // Derived per-tome level rewards (not yaml options — shown as context
            // for the XP Tome Bonus above).
            addRow("Tattered Scroll",         opts.tomeXpLevels.tattered + " levels", vY);                    vY += ROW_HEIGHT;
            addRow("Worn Tome",               opts.tomeXpLevels.worn     + " levels", vY);                    vY += ROW_HEIGHT;
            addRow("Ancient Grimoire",        opts.tomeXpLevels.ancient  + " levels", vY);                    vY += ROW_HEIGHT;

            // ── Enemy Manipulation Options ───────────────────────────────────
            vY += SECTION_GAP;
            addSectionHeader("Enemy Manipulation Options", vY); vY += ROW_HEIGHT;
            addRow("Enemy HP",               opts.enemyMultipliers.hp     + "%", vY);                         vY += ROW_HEIGHT;
            addRow("Enemy Armor",            opts.enemyMultipliers.armor  + "%", vY);                         vY += ROW_HEIGHT;
            addRow("Enemy Shield",           opts.enemyMultipliers.shield + "%", vY);                         vY += ROW_HEIGHT;
            addRow("Enemies Per Wave",       opts.enemyMultipliers.waves  + "%", vY);                         vY += ROW_HEIGHT;
            addRow("Extra Waves",            opts.enemyMultipliers.extraWaves == 0 ? "Off" : "+" + opts.enemyMultipliers.extraWaves, vY); vY += ROW_HEIGHT;

            // ── DeathLink Options ────────────────────────────────────────────
            vY += SECTION_GAP;
            addSectionHeader("DeathLink Options", vY); vY += ROW_HEIGHT;
            addRow("Enabled", dl.enabled ? "Yes" : "No", vY); vY += ROW_HEIGHT;

            if (dl.enabled) {
                addRow("Punishment", punishmentName(dl.punishment), vY); vY += ROW_HEIGHT;

                if (dl.punishment == DeathLinkHandler.PUNISHMENT_GEM_LOSS) {
                    addRow("Gem Loss", dl.gemLossPercent + "%", vY); vY += ROW_HEIGHT;
                } else if (dl.punishment == DeathLinkHandler.PUNISHMENT_WAVE_SURGE) {
                    addRow("Surge Count",     String(dl.waveSurgeCount),    vY); vY += ROW_HEIGHT;
                    addRow("Surge Gem Level", String(dl.waveSurgeGemLevel), vY); vY += ROW_HEIGHT;
                } else if (dl.punishment == DeathLinkHandler.PUNISHMENT_SPAWN_HORDE) {
                    addRow("Horde Count", String(dl.spawnHordeCount), vY); vY += ROW_HEIGHT;
                } else if (dl.punishment == DeathLinkHandler.PUNISHMENT_SPAWN_SPECIAL) {
                    var elements:Array = dl.spawnSpecialElements;
                    var elementsStr:String = (elements != null && elements.length > 0)
                        ? elements.join(", ") : "(none)";
                    addRow("Special Count",    String(dl.spawnSpecialCount), vY); vY += ROW_HEIGHT;
                    addRow("Special Elements", elementsStr,                  vY); vY += ROW_HEIGHT;
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
                case 1:  return "Beat Swarm Queen (K4)";
                case 2:  return "Fields Cleared (Count)";
                default: return "Unknown (" + goal + ")";
            }
        }

        private function difficultyName(d:int):String {
            switch (d) {
                case 0:  return "Easy";
                case 1:  return "Medium";
                case 2:  return "Hard";
                case 3:  return "Extreme";
                default: return "Unknown (" + d + ")";
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

        private function startingStagesName(arr:Array):String {
            if (arr == null || arr.length == 0) return "Unknown";
            return arr.join(", ");
        }

        // Field-token granularity values 0-3 (per_stage, per_stage_progressive,
        // per_tile, per_tile_progressive). Stash keys / gem pouches use 0-2 plus
        // 5=global. (per_tier / per_tier_progressive retired.)
        private function fieldTokenGranularityName(g:int):String {
            switch (g) {
                case 0:  return "Per Stage";
                case 1:  return "Per Stage (Progressive)";
                case 2:  return "Per Tile";
                case 3:  return "Per Tile (Progressive)";
                default: return "Unknown (" + g + ")";
            }
        }

        private function stashKeyGranularityName(g:int):String {
            switch (g) {
                case 0:  return "Off";
                case 1:  return "Per Tile";
                case 2:  return "Per Tile (Progressive)";
                case 5:  return "Global";
                default: return "Unknown (" + g + ")";
            }
        }

        private function gemPouchGranularityName(g:int):String {
            switch (g) {
                case 0:  return "Off";
                case 1:  return "Per Tile";
                case 2:  return "Per Tile (Progressive)";
                case 5:  return "Global";
                default: return "Unknown (" + g + ")";
            }
        }

        private function punishmentName(p:int):String {
            switch (p) {
                case DeathLinkHandler.PUNISHMENT_GEM_LOSS:      return "Gem Loss";
                case DeathLinkHandler.PUNISHMENT_WAVE_SURGE:    return "Wave Surge";
                case DeathLinkHandler.PUNISHMENT_INSTANT_FAIL:  return "Instant Fail";
                case DeathLinkHandler.PUNISHMENT_SPAWN_HORDE:   return "Spawn Horde";
                case DeathLinkHandler.PUNISHMENT_SPAWN_SPECIAL: return "Spawn Special";
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

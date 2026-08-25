package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import com.giab.common.utils.NumberFormatter;
    import flash.display.Bitmap;
    import flash.text.TextField;

    import tracker.WizardLevelCalc;
    import unlockers.LevelUnlocker;

    /**
     * Annotates the selector XP-bar hover tooltip with the AP level split, so a
     * player can see how much of their wizard level they actually earned:
     *
     *   Vanilla                        We show
     *   ---------------------------    ---------------------------------------
     *   Wizard Level 35            →   Wizard Level 35 (+20 bonus levels)
     *   initial mana replenish...      (unchanged)
     *   15,340 / 24,900 XP             (unchanged — already natural-level XP)
     *   ...
     *
     * Since ApCalculator shifts the curve rather than the XP total, every other
     * line in the vanilla panel is already right: the "X / Y XP" and "more XP to
     * go" figures come from req(L)..req(L+1), which shift together and therefore
     * describe progress through the player's NATURAL level. Only the headline
     * number needed context.
     *
     * Tooltip is identified by its first textfield starting with "Wizard Level ",
     * which is unique to this hover on the selector screen (PnlSkills' tooltip
     * leads with "Total skill points:"). When no levels have been granted we
     * leave the vanilla panel completely alone.
     *
     * Implementation mirrors SkillsTooltipOverlay: McInfoPanel.separatorYs is
     * private, so the existing layout can't be spliced — reset() and rebuild the
     * whole panel through the public addTextfield/addSeparator API, mirroring
     * SelectorInputHandler.ehXpBarOver line for line.
     */
    public class XpBarTooltipOverlay {

        private var _logger:Logger;
        private var _modName:String;
        private var _levelUnlocker:LevelUnlocker;

        // True after we've rebuilt the current tooltip. Cleared when the panel
        // closes (MOUSE_OUT unparents it) or a new hover re-renders it.
        private var _rebuilt:Boolean = false;

        // -----------------------------------------------------------------------

        public function XpBarTooltipOverlay(logger:Logger, modName:String,
                                            levelUnlocker:LevelUnlocker) {
            _logger        = logger;
            _modName       = modName;
            _levelUnlocker = levelUnlocker;
        }

        // -----------------------------------------------------------------------

        /** Called every selector frame from ArchipelagoMod.onSelectorFrame(). */
        public function onSelectorFrame():void {
            if (GV.mcInfoPanel == null) return;
            var vIp:* = GV.mcInfoPanel;

            if (vIp.parent == null || !vIp.isImageRendered) {
                _rebuilt = false;
                return;
            }
            if (_rebuilt) return;

            var textfields:Array = vIp.textfields as Array;
            if (textfields == null || textfields.length == 0) return;

            var firstTf:TextField = textfields[0] as TextField;
            if (firstTf == null || firstTf.text == null) return;
            if (firstTf.text.indexOf("Wizard Level ") != 0) return;

            // Nothing granted → the vanilla panel is already accurate.
            if (_levelUnlocker == null || _levelUnlocker.grantedWizardLevels <= 0) {
                _rebuilt = true;
                return;
            }

            try {
                _rebuild(vIp);
            } catch (err:Error) {
                _logger.log(_modName, "XpBarTooltipOverlay rebuild error: " + err.message);
            }
            _rebuilt = true;
        }

        // -----------------------------------------------------------------------

        /**
         * Rebuild of SelectorInputHandler.ehXpBarOver. Colors, sizes, leading
         * flags and separator offsets are copied verbatim so the panel is
         * visually identical apart from the annotated title.
         */
        private function _rebuild(vIp:*):void {
            var granted:int   = _levelUnlocker.grantedWizardLevels;
            var displayed:int = _levelUnlocker.getDisplayedWizardLevel();  // 1-indexed, incl. bonus
            var effective:int = displayed - 1;                             // vanilla's 0-indexed getWizLevel()
            var xp:Number     = GV.ppd.getXp();

            // Dispose the vanilla bitmap before reset; reset() also nulls bmp
            // but explicit dispose makes ownership clear.
            try {
                var oldBmp:Bitmap = vIp.bmp as Bitmap;
                if (oldBmp != null && oldBmp.bitmapData != null)
                    oldBmp.bitmapData.dispose();
            } catch (eb:Error) {}

            // Undo the projectorZoom multiplication that drawBitmap baked into
            // vIp.w on the first render so reset()'s width math is correct.
            try {
                var zoom:Number = Number(GV.projectorZoom);
                if (zoom > 0)
                    vIp.w = vIp.w / zoom;
            } catch (ez:Error) {}

            // ehXpBarOver passes 360 — match it.
            vIp.reset(360);

            vIp.addTextfield(16777215,
                    "Wizard Level " + NumberFormatter.format(displayed)
                        + " (+" + NumberFormatter.format(granted)
                        + (granted == 1 ? " bonus level)" : " bonus levels)"),
                    true, 13);
            vIp.addTextfield(12694419,
                    "initial mana replenish rate: "
                        + NumberFormatter.format(GV.manaReplenishPerSecBase.g() * 60 * (1 + 0.13 * effective))
                        + " per minute",
                    false, 11, null, 9040127);
            vIp.addExtraHeight(5);
            vIp.addSeparator(-2);

            if (effective >= GV.wizLevelMax) {
                vIp.addTextfield(14598217, "Highest wizard level reached", false, 12, null, 16777215);
            } else {
                // The shifted curve's req(effective) / req(effective + 1) are by
                // construction the vanilla curve's req at the NATURAL level, so
                // compute them off WizardLevelCalc (the validated port of
                // Calculator.calculatePlayerLevelXpReq) rather than going through
                // GV.calculator. Same numbers, no dependency on which calculator
                // is installed or suspended.
                var natural:int          = _levelUnlocker.naturalWizardLevel - 1;   // 0-indexed
                var lastLevelAt:Number   = WizardLevelCalc.playerLevelXpReq(natural);
                var nextLevelAt:Number   = WizardLevelCalc.playerLevelXpReq(natural + 1);
                var xpBetween:Number     = nextLevelAt - lastLevelAt;
                var xpInLevel:Number     = xp - lastLevelAt;
                vIp.addTextfield(16383833,
                        NumberFormatter.format(xpInLevel) + " / " + NumberFormatter.format(xpBetween) + " XP",
                        true, 13);
                vIp.addTextfield(16755560,
                        NumberFormatter.format(xpBetween - xpInLevel) + " more XP to go until next level",
                        false, 12, null, 16777215);
            }

            vIp.addExtraHeight(5);
            vIp.addSeparator(-2);
            // Vanilla's last line. The AP split goes here so the tooltip reads
            // "what you earned" -> "what AP gave you" at the bottom.
            vIp.addTextfield(12694419, "Total XP: " + NumberFormatter.format(xp), false, 10);
            vIp.addTextfield(12694419,
                    "Wizard Level " + NumberFormatter.format(_levelUnlocker.naturalWizardLevel)
                        + " from XP, +" + NumberFormatter.format(granted) + " from Archipelago",
                    false, 10);

            // doEnterFrame builds the bitmap and adds children. The panel is
            // still parented to cntInfoPanel from the vanilla call.
            try {
                vIp.doEnterFrame();
            } catch (e:Error) {
                _logger.log(_modName, "XpBarTooltipOverlay doEnterFrame error: " + e.message);
            }
        }
    }
}

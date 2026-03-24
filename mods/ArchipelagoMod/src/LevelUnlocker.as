package {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Handles AP wizard level / XP bonus grants.
     * XP Bonus AP IDs: 500 (Tattered Scroll=+1), 501 (Worn Tome=+3), 502 (Ancient Grimoire=+9).
     */
    public class LevelUnlocker {

        private var _logger:Logger;
        private var _modName:String;
        private var _toast:ToastPanel;
        private var _apWizardLevel:int = 0;

        /** Called after granting XP so the caller can persist the updated state. */
        public var onDataChanged:Function; // ():void

        public function LevelUnlocker(logger:Logger, modName:String, toast:ToastPanel) {
            _logger  = logger;
            _modName = modName;
            _toast   = toast;
        }

        public function get apWizardLevel():int { return _apWizardLevel; }
        public function set apWizardLevel(value:int):void { _apWizardLevel = value; }

        /**
         * Grant AP wizard levels from a received XP Bonus item.
         * Tattered Scroll=1, Worn Tome=3, Ancient Grimoire=9 wizard levels.
         */
        public function grantXpBonus(apId:int):void {
            var levels:int = 0;
            var label:String = "";
            if      (apId == 500) { levels = 1; label = "Tattered Scroll";  }
            else if (apId == 501) { levels = 3; label = "Worn Tome";        }
            else if (apId == 502) { levels = 9; label = "Ancient Grimoire"; }
            else return;

            _apWizardLevel += levels;
            if (onDataChanged != null) onDataChanged();

            _logger.log(_modName, label + " XP Bonus → +" + levels
                + " wizard levels (AP total: " + _apWizardLevel + ")");
            _toast.addMessage("+" + levels + " Wizard Levels (total: "
                + _apWizardLevel + ")", 0xFF88CCFF);

            applyApWizardLevels(_apWizardLevel);
        }

        /**
         * Ensure the game's wizard level is at least 'targetLevel', regardless
         * of what the player has earned from playing stages.
         *
         * How it works:
         *   getXp() (on PlayerProgressData) sums stageHighestXpsJourney +
         *   Endurance + Trial for every stage (values clamped to >=0).
         *   W1 has no endurance mode so stageHighestXpsEndurance[W1] is always
         *   -1 (unused) and contributes 0 to the sum normally.
         *   We store our AP bonus XP there; the game's own sum picks it up and
         *   the wizard level display updates automatically.
         *
         * NOTE: we do NOT call GV.calculator or GV.ppd.getXp()/getWizLevel()
         * because Calculator -> Monster -> IngameRenderer pulls in mcStat UI
         * classes that are absent from the SWC stub (VerifyError #1014).
         * Instead we replicate the formula and XP sum locally.
         */
        public function applyApWizardLevels(targetLevel:int):void {
            if (GV.ppd == null || GV.stageCollection == null) return;
            if (targetLevel <= 0) return;

            var W1_END_IDX:int = GV.getFieldId("W1");

            // Read any bonus XP we previously stored in the W1 endurance slot.
            var prevBonus:Number = Math.max(0, GV.ppd.stageHighestXpsEndurance[W1_END_IDX].g());

            // Replicate PlayerProgressData.getXp() without calling the method.
            // Excludes our own bonus slot so we don't double-count.
            var normalXp:Number = 0;
            var metas:Array = GV.stageCollection.stageMetas;
            for (var i:int = 0; i < metas.length; i++) {
                var meta:* = metas[i];
                if (meta == null) continue;
                normalXp += Math.max(0, GV.ppd.stageHighestXpsJourney[meta.id].g());
                normalXp += Math.max(0, GV.ppd.stageHighestXpsTrial[meta.id].g());
                if (meta.id != W1_END_IDX) {
                    normalXp += Math.max(0, GV.ppd.stageHighestXpsEndurance[meta.id].g());
                }
            }

            // XP threshold for targetLevel — replicated from Calculator.calculatePlayerLevelXpReq.
            var bonusXp:Number = Math.max(0, apXpForWizLevel(targetLevel) - normalXp);

            GV.ppd.stageHighestXpsEndurance[W1_END_IDX].s(bonusXp > 0 ? bonusXp : -1);
            _logger.log(_modName, "applyApWizardLevels: target=" + targetLevel
                + " normalXp=" + normalXp + " bonusXp=" + bonusXp);
        }

        /**
         * XP required to reach wizard level pLevel.
         * Copied verbatim from Calculator.calculatePlayerLevelXpReq() to avoid
         * linking Calculator (and its mcStat dependency chain) into our SWF.
         */
        private function apXpForWizLevel(pLevel:int):Number {
            var vDelta2:Number = 30 + (pLevel - 1) * 5;
            var vDelta:Number  = 600 + vDelta2 / 2 * (pLevel - 1);
            return -10 + 10 * Math.round(0.8 * (300 + vDelta / 2 * (pLevel - 1)) / 10);
        }
    }
}

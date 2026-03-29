package unlockers {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import ui.ItemToastPanel;

    /**
     * Handles AP wizard level / XP bonus grants.
     * XP Bonus AP IDs: 500 (Tattered Scroll=+3), 501 (Worn Tome=+6), 502 (Ancient Grimoire=+18).
     *
     * Bonus wizard levels are persisted in the slot JSON file and injected into
     * A4's trial XP slot so the game's own XP sum picks them up automatically.
     * A4 trial is used because it is the final stage and unlikely to be played
     * in a randomizer context.
     */
    public class LevelUnlocker {

        private var _logger:Logger;
        private var _modName:String;
        private var _itemToast:ItemToastPanel;
        private var _bonusWizardLevel:int = 0;
        private var _xpBarDirty:Boolean = false;

        /** Called after granting XP so the caller can persist the updated state. */
        public var onDataChanged:Function; // ():void

        public function LevelUnlocker(logger:Logger, modName:String, itemToast:ItemToastPanel) {
            _logger    = logger;
            _modName   = modName;
            _itemToast = itemToast;
        }

        public function get bonusWizardLevel():int { return _bonusWizardLevel; }
        public function set bonusWizardLevel(value:int):void { _bonusWizardLevel = value; }

        /** Canonical wizard-level values per AP item ID. */
        public static function levelsForApId(apId:int):int {
            if (apId == 500) return 3;   // Tattered Scroll
            if (apId == 501) return 6;   // Worn Tome
            if (apId == 502) return 18;  // Ancient Grimoire
            return 0;
        }

        /**
         * Render the XP bar if it was marked dirty by applyBonusLevels().
         * Safe to call every frame — returns immediately if nothing changed
         * or the selector renderer is unavailable.
         */
        public function renderXpBarIfDirty():Boolean {
            if (!_xpBarDirty) return false;
            if (GV.selectorCore == null || GV.selectorCore.renderer == null) return false;
            GV.selectorCore.renderer.renderXpBar(GV.ppd.getXp());
            _xpBarDirty = false;
            return true;
        }

        /**
         * Grant AP wizard levels from a received XP Bonus item.
         * Tattered Scroll=3, Worn Tome=6, Ancient Grimoire=18 wizard levels.
         */
        public function grantXpBonus(apId:int):void {
            var levels:int = levelsForApId(apId);
            if (levels <= 0) return;

            var label:String = "";
            if      (apId == 500) label = "Tattered Scroll";
            else if (apId == 501) label = "Worn Tome";
            else if (apId == 502) label = "Ancient Grimoire";

            _bonusWizardLevel += levels;
            if (onDataChanged != null) onDataChanged();
            applyBonusLevels();

            _logger.log(_modName, label + " → +" + levels
                + " wizard levels (bonus total: " + _bonusWizardLevel + ")");
            _itemToast.addItem("+" + levels + " Wizard Levels (bonus total: "
                + _bonusWizardLevel + ")", 0x88CCFF);
        }

        /**
         * Inject bonus wizard levels into the game by storing the required XP
         * in A4's trial slot. The game's own XP sum picks it up and updates the
         * wizard level display automatically.
         *
         * Call this after setting bonusWizardLevel (on item grant, sync, or load).
         *
         * NOTE: We cannot call Calculator.calculatePlayerLevelXpReq() directly
         * because Calculator → Monster → IngameRenderer pulls in mcStat UI classes
         * absent from the SWC stub (VerifyError #1014). The formula is replicated
         * locally via apXpForWizLevel().
         */
        public function applyBonusLevels():void {
            if (GV.ppd == null || GV.stageCollection == null) return;
            if (_bonusWizardLevel <= 0) {
                // Clear any previously stored bonus.
                var clearIdx:int = GV.getFieldId("A4");
                if (clearIdx >= 0) GV.ppd.stageHighestXpsTrial[clearIdx].s(-1);
                _xpBarDirty = true;
                return;
            }

            var a4Idx:int = GV.getFieldId("A4");
            if (a4Idx < 0) {
                _logger.log(_modName, "applyBonusLevels: A4 field id not found");
                return;
            }

            // Sum all normal XP, excluding the A4 trial slot we use for our bonus.
            var normalXp:Number = 0;
            var metas:Array = GV.stageCollection.stageMetas;
            for (var i:int = 0; i < metas.length; i++) {
                var meta:* = metas[i];
                if (meta == null) continue;
                normalXp += Math.max(0, GV.ppd.stageHighestXpsJourney[meta.id].g());
                normalXp += Math.max(0, GV.ppd.stageHighestXpsEndurance[meta.id].g());
                if (meta.id != a4Idx) {
                    normalXp += Math.max(0, GV.ppd.stageHighestXpsTrial[meta.id].g());
                }
            }

            // XP required to reach _bonusWizardLevel above the player's current level.
            var currentLevel:int = currentWizardLevel(normalXp);
            var targetLevel:int  = currentLevel + _bonusWizardLevel;
            var bonusXp:Number   = Math.max(0, apXpForWizLevel(targetLevel) - normalXp);

            GV.ppd.stageHighestXpsTrial[a4Idx].s(bonusXp > 0 ? bonusXp : -1);
            _xpBarDirty = true;
            _logger.log(_modName, "applyBonusLevels: currentLevel=" + currentLevel
                + " bonusLevels=" + _bonusWizardLevel
                + " targetLevel=" + targetLevel
                + " normalXp=" + normalXp
                + " bonusXp=" + bonusXp);
        }

        /**
         * Approximate current wizard level from raw XP total.
         * Inverts apXpForWizLevel() by linear search (levels are small in practice).
         */
        private function currentWizardLevel(xp:Number):int {
            var level:int = 1;
            while (apXpForWizLevel(level + 1) <= xp) level++;
            return level;
        }

        /**
         * XP required to reach wizard level pLevel.
         * Replicated from Calculator.calculatePlayerLevelXpReq() to avoid
         * linking Calculator (and its mcStat dependency chain) into our SWF.
         */
        private function apXpForWizLevel(pLevel:int):Number {
            var vDelta2:Number = 30 + (pLevel - 1) * 5;
            var vDelta:Number  = 600 + vDelta2 / 2 * (pLevel - 1);
            return -10 + 10 * Math.round(0.8 * (300 + vDelta / 2 * (pLevel - 1)) / 10);
        }
    }
}

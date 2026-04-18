package unlockers {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import flash.utils.getDefinitionByName;
    import ui.ReceivedToast;

    /**
     * Handles AP wizard level / XP bonus grants.
     * XP Bonus AP IDs: 500 (Tattered Scroll), 501 (Worn Tome), 502 (Ancient Grimoire).
     * Per-tome level values are configured from slot_data via configure().
     *
     * Bonus wizard levels are persisted in the slot JSON file and injected into
     * A4's trial XP slot so the game's own XP sum picks them up automatically.
     * A4 trial is used because it is the final stage and unlikely to be played
     * in a randomizer context.
     */
    public class LevelUnlocker extends BaseUnlocker {
        private var _bonusWizardLevel:int = 0;
        private var _naturalWizardLevel:int = 1;
        private var _xpBarDirty:Boolean = false;

        // Per-tome level values — set from slot_data on connect; fallback to 1/2/3 defaults.
        private var _tatteredLevels:int = 1;
        private var _wornLevels:int     = 2;
        private var _ancientLevels:int  = 3;
        // Flat level bonus granted at game start from the starting_wizard_level option.
        // Treated identically to _bonusWizardLevel in applyBonusLevels() but is not
        // persisted — it is re-applied from slot_data each time the player connects.
        private var _startingLevelBonus:int = 0;

        /** Called after granting XP so the caller can persist the updated state. */
        public var onDataChanged:Function; // ():void

        public function LevelUnlocker(logger:Logger, modName:String, itemToast:ReceivedToast) {
            super(logger, modName, itemToast);
        }

        public function get bonusWizardLevel():int { return _bonusWizardLevel; }
        public function set bonusWizardLevel(value:int):void { _bonusWizardLevel = value; }

        /** The natural (non-AP) wizard level; updated each time applyBonusLevels() runs. */
        public function get naturalWizardLevel():int { return _naturalWizardLevel; }

        /**
         * The wizard level currently displayed by the game (1-indexed, includes AP bonus).
         * Returns 1 if GV.ppd is unavailable.
         */
        public function getDisplayedWizardLevel():int {
            if (GV.ppd == null) return 1;
            return currentWizardLevel(GV.ppd.getXp());
        }

        /**
         * Set per-tome level values from slot_data.
         * Call once in onApConnected before syncing items.
         */
        public function configure(tattered:int, worn:int, ancient:int, startingWizardLevel:int = 1):void {
            _tatteredLevels     = Math.max(1, tattered);
            _wornLevels         = Math.max(1, worn);
            _ancientLevels      = Math.max(1, ancient);
            _startingLevelBonus = Math.max(0, startingWizardLevel - 1);
            logAction("LevelUnlocker configured: tattered=" + _tatteredLevels
                + " worn=" + _wornLevels + " ancient=" + _ancientLevels
                + " startingLevelBonus=" + _startingLevelBonus);
        }

        /** Wizard-level value for an AP item ID, using the configured per-tome values. */
        public function levelsForApId(apId:int):int {
            if (apId == 500) return _tatteredLevels;
            if (apId == 501) return _wornLevels;
            if (apId == 502) return _ancientLevels;
            // XP tomes: 1100-1131 Tattered, 1132-1137 Worn, 1138-1139 Ancient, 1140-1199 filler (tattered-equivalent)
            if (apId >= 1100 && apId <= 1131) return _tatteredLevels;
            if (apId >= 1132 && apId <= 1137) return _wornLevels;
            if (apId >= 1138 && apId <= 1139) return _ancientLevels;
            if (apId >= 1140 && apId <= 1199) return _tatteredLevels;
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

            var oldXp:Number = (GV.ppd != null) ? GV.ppd.getXp() : 0;

            _bonusWizardLevel += levels;
            if (onDataChanged != null) onDataChanged();
            applyBonusLevels(); // sets _xpBarDirty = true; also updates the A4 trial slot

            // Animate XP bar on the selector instead of snapping.
            // applyBonusLevels() already set _xpBarDirty; clear it so the frame-loop
            // doesn't also snap to the final value while the animation is running.
            if (GV.ppd != null) {
                var newXp:Number = GV.ppd.getXp();
                if (pushSelectorEvent(4, [oldXp, newXp])) { // 4 = XP_INCREASING
                    _xpBarDirty = false;
                }
            }

            logAction(label + " → +" + levels + " wizard levels (bonus total: " + _bonusWizardLevel + ")");
            showToast("Received " + label, 0x88CCFF);
        }

        /**
         * Grant AP wizard levels from a received XP Tome item (AP IDs 1100-1199).
         * Uses levelsForApId() to determine the level value.
         */
        public function grantXpFromApId(apId:int, label:String = ""):void {
            var levels:int = levelsForApId(apId);
            if (levels <= 0) return;

            if (label == "") label = "XP Tome";

            var oldXp:Number = (GV.ppd != null) ? GV.ppd.getXp() : 0;

            _bonusWizardLevel += levels;
            if (onDataChanged != null) onDataChanged();
            applyBonusLevels();

            if (GV.ppd != null) {
                var newXp:Number = GV.ppd.getXp();
                if (pushSelectorEvent(4, [oldXp, newXp])) {
                    _xpBarDirty = false;
                }
            }

            logAction(label + " → +" + levels + " wizard levels (bonus total: " + _bonusWizardLevel + ")");
            showToast("Received " + label, 0x88CCFF);
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
            var totalBonus:int = _bonusWizardLevel + _startingLevelBonus;
            if (totalBonus <= 0) {
                // Clear any previously stored bonus.
                var clearIdx:int = GV.getFieldId("A4");
                if (clearIdx >= 0) GV.ppd.stageHighestXpsTrial[clearIdx].s(-1);
                _xpBarDirty = true;
                return;
            }

            var a4Idx:int = GV.getFieldId("A4");
            if (a4Idx < 0) {
                logAction("applyBonusLevels: A4 field id not found");
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

            _naturalWizardLevel = currentWizardLevel(normalXp);

            var bonusXp:Number = Math.max(0, apXpForWizLevel(_naturalWizardLevel + totalBonus) - normalXp);

            GV.ppd.stageHighestXpsTrial[a4Idx].s(bonusXp > 0 ? bonusXp : -1);
            _xpBarDirty = true;
            logAction("applyBonusLevels: apBonus=" + _bonusWizardLevel
                + " startingBonus=" + _startingLevelBonus
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

        /**
         * Push a SelectorEvent to GV.selectorCore.eventQueue, triggering UPDATING_STAGES
         * if the selector is currently idle so the animation plays immediately.
         * Returns true if the event was pushed (selector available); false otherwise.
         */
        private function pushSelectorEvent(type:int, args:Array):Boolean {
            try {
                var core:* = GV.selectorCore;
                if (core == null) return false;
                var SelectorEventClass:Class = getDefinitionByName("com.giab.games.gcfw.struct.SelectorEvent") as Class;
                core.eventQueue.push(new SelectorEventClass(type, args));
                if (core.screenStatus == 4) core.screenStatus = 3; // STAGES_IDLE → UPDATING_STAGES
                return true;
            } catch (err:Error) {
                logAction("pushSelectorEvent error: " + err.message);
                return false;
            }
        }
    }
}

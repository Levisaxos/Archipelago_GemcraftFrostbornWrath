package unlockers {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import com.giab.common.utils.NumberFormatter;
    import patch.ApCalculator;
    import tracker.WizardLevelCalc;
    import ui.ReceivedToast;
    import ui.ItemColors;

    /**
     * Handles AP wizard level / XP bonus grants.
     * XP tomes use AP IDs 1100-1199 (see levelsForApId).
     * Per-tome level values are configured from slot_data via configure().
     *
     * Bonus levels are applied by swapping GV.calculator for an ApCalculator,
     * which shifts the level curve so the bonus stacks ON TOP of the level the
     * player's own XP earned (see ApCalculator for why that one override covers
     * every wizard-level consumer in the game). GV.ppd.getXp() therefore stays
     * pure natural XP and the XP bar shows real progress toward the next level.
     *
     * Before this, the XP cost of the bonus levels was written into A4's Trial
     * slot so the game's own XP sum would pick it up. That made every XP earned
     * afterwards pay the inflated level's price, and only recomputed when a tome
     * arrived. clearLegacyTrialInjection() migrates saves carrying that leftover.
     */
    public class LevelUnlocker extends BaseUnlocker {
        private var _bonusWizardLevel:int = 0;
        private var _xpBarDirty:Boolean = false;

        // Per-tome level values — set from slot_data on connect; fallback to 1/2/3 defaults.
        private var _tatteredLevels:int = 1;
        private var _wornLevels:int     = 2;
        private var _ancientLevels:int  = 3;
        // Flat level bonus granted at game start from the starting_wizard_level option.
        // Treated identically to _bonusWizardLevel in applyBonusLevels() but is not
        // persisted — it is re-applied from slot_data each time the player connects.
        private var _startingLevelBonus:int = 0;

        // The installed ApCalculator and the vanilla instance it displaced, so
        // _deactivateApMode can hand a standalone slot back an unmodified curve.
        private var _apCalc:ApCalculator = null;
        private var _vanillaCalc:* = null;

        // One-time migration flag, persisted in the slot JSON. See clearLegacyTrialInjection().
        private var _legacyTrialXpCleared:Boolean = false;
        // Set once the migration has run this session. A late-arriving DataStorage
        // Retrieved can max-merge the stale A4 value back in after the flag was
        // already persisted, so the migration has to stay armed until the slot is
        // switched — hence "cleared this session" rather than a pure one-shot.
        private var _legacyTrialXpClearedThisSession:Boolean = false;

        /** Called after granting XP so the caller can persist the updated state. */
        public var onDataChanged:Function; // ():void

        public function LevelUnlocker(logger:Logger, modName:String, itemToast:ReceivedToast) {
            super(logger, modName, itemToast);
        }

        public function get bonusWizardLevel():int { return _bonusWizardLevel; }
        public function set bonusWizardLevel(value:int):void { _bonusWizardLevel = value; }

        public function get legacyTrialXpCleared():Boolean { return _legacyTrialXpCleared; }
        public function set legacyTrialXpCleared(value:Boolean):void {
            _legacyTrialXpCleared = value;
            _legacyTrialXpClearedThisSession = false;
        }

        /**
         * The level the player's OWN XP has earned, 1-indexed, with no AP bonus.
         * Computed live off the unshifted curve (WizardLevelCalc is the validated
         * port of Calculator.calculatePlayerLevelXpReq), so it stays correct
         * regardless of which calculator is installed or whether it is suspended.
         */
        public function get naturalWizardLevel():int {
            if (GV.ppd == null)
                return 1;
            return WizardLevelCalc.levelFromXp(GV.ppd.getXp()) + 1;
        }

        /** AP-granted levels stacked on top: XP tomes + the starting_wizard_level option. */
        public function get grantedWizardLevels():int {
            return _bonusWizardLevel + _startingLevelBonus;
        }

        /** The starting_wizard_level share of grantedWizardLevels; XP tomes are the rest. */
        public function get startingLevelBonus():int {
            return _startingLevelBonus;
        }

        /**
         * The wizard level currently displayed by the game (1-indexed, includes AP bonus).
         * Returns 1 if GV.ppd is unavailable.
         */
        public function getDisplayedWizardLevel():int {
            if (GV.ppd == null)
                return 1;
            return int(GV.ppd.getWizLevel()) + 1;
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
            if (!_xpBarDirty)
                return false;
            if (GV.ppd == null || GV.selectorCore == null || GV.selectorCore.renderer == null)
                return false;
            var xp:Number = GV.ppd.getXp();
            GV.selectorCore.renderer.renderXpBar(xp);
            _fixZeroXpLevelPlate(xp);
            _xpBarDirty = false;
            return true;
        }

        /**
         * SelectorRenderer.renderXpBar short-circuits at pXp == 0 and hard-codes
         * the plate to "1", never consulting the curve. A fresh run with a
         * starting_wizard_level bonus and no XP yet hits exactly that case, so
         * repaint the plate ourselves. Everything else on the bar is correct at
         * zero XP (empty strip), so only the label and its backing plate move.
         */
        private function _fixZeroXpLevelPlate(xp:Number):void {
            if (xp != 0)
                return;
            var displayed:int = getDisplayedWizardLevel();
            if (displayed <= 1)
                return;
            try {
                var bar:* = GV.selectorCore.renderer.mc.mcXpBar;
                bar.wizLevelTf.text = NumberFormatter.format(displayed);
                // Mirrors the vanilla plate-width steps, which key off the
                // 0-indexed level (displayed - 1).
                var lvl:int = displayed - 1;
                bar.wizLevelPlate.scaleX = lvl > 1000 ? 1.3 : (lvl > 100 ? 1.18 : (lvl > 10 ? 1.05 : 1));
            } catch (err:Error) {
                logAction("_fixZeroXpLevelPlate error: " + err.message);
            }
        }

        /**
         * Grant AP wizard levels from a received XP Tome item (AP IDs 1100-1199).
         * Uses levelsForApId() to determine the level value.
         */
        public function grantXpFromApId(apId:int, label:String = ""):void {
            var levels:int = levelsForApId(apId);
            if (levels <= 0)
                return;

            if (label == null || label == "")
                label = "XP Tome";

            _bonusWizardLevel += levels;
            if (onDataChanged != null)
                onDataChanged();
            applyBonusLevels();

            logAction(label + " → +" + levels + " wizard levels (bonus total: " + _bonusWizardLevel + ")");
            showToast("Received " + label, ItemColors.forApId(apId));
        }

        /**
         * Push the current bonus into the shifted level curve.
         * Call after setting bonusWizardLevel (on item grant, sync, or load).
         *
         * Unlike the old A4-trial injection this does NOT need re-running when
         * the player earns XP — the curve is shifted, not the XP total, so the
         * displayed level tracks the natural one automatically.
         */
        public function applyBonusLevels():void {
            if (GV.ppd == null)
                return;
            installCalculator();
            if (_apCalc == null)
                return;

            var totalBonus:int = _bonusWizardLevel + _startingLevelBonus;
            _apCalc.bonusLevels = totalBonus;
            _xpBarDirty = true;

            logAction("applyBonusLevels: apBonus=" + _bonusWizardLevel
                + " startingBonus=" + _startingLevelBonus
                + " naturalLevel=" + naturalWizardLevel
                + " displayedLevel=" + getDisplayedWizardLevel());
        }

        /** Swap GV.calculator for the shifted-curve one. Idempotent. */
        public function installCalculator():void {
            if (_apCalc != null && GV.calculator == _apCalc)
                return;
            if (GV.calculator is ApCalculator) {
                _apCalc = GV.calculator as ApCalculator;
                return;
            }
            _vanillaCalc = GV.calculator;
            _apCalc = new ApCalculator();
            GV.calculator = _apCalc;
            logAction("ApCalculator installed (GV.calculator swapped)");
        }

        /**
         * Put the vanilla calculator back. GV.calculator is process-global, so
         * without this a standalone slot loaded after an AP run would keep the
         * AP slot's level shift.
         */
        public function restoreVanillaCalculator():void {
            if (_apCalc == null)
                return;
            if (GV.calculator == _apCalc && _vanillaCalc != null)
                GV.calculator = _vanillaCalc;
            else if (GV.calculator == _apCalc)
                _apCalc.bonusLevels = 0;
            _apCalc = null;
            _vanillaCalc = null;
            _xpBarDirty = true;
            logAction("ApCalculator removed (vanilla GV.calculator restored)");
        }

        /**
         * Hide the bonus while the LOADGAME screen is up.
         * LoaderSaver.renderMcLoadGame draws a wizard level for EVERY slot off
         * the same global calculator, so standalone and vanilla slots would
         * otherwise be listed with the AP slot's bonus added on.
         */
        public function set bonusSuspended(value:Boolean):void {
            if (_apCalc == null)
                return;
            if (_apCalc.suspended == value)
                return;
            _apCalc.suspended = value;
            _xpBarDirty = true;
        }

        /**
         * Migration for saves written before the ApCalculator swap: those stored
         * the XP cost of the bonus levels in A4's Trial slot, which now double-
         * counts against the shifted curve. Wipe it once, then never again so a
         * genuine A4 Trial run (possible when the run allows Trial mode) is kept.
         *
         * Must run AFTER ApStateSync.applyPendingState — that max-merges the
         * server's copy of the XP arrays back in, leftover A4 value included.
         * The cleared array is pushed back to AP by the next pushIfChanged, so
         * the server-side copy is fixed in the same session.
         *
         * Returns true if a value was actually cleared.
         */
        public function clearLegacyTrialInjection():Boolean {
            if (_legacyTrialXpCleared && !_legacyTrialXpClearedThisSession)
                return false;
            if (GV.ppd == null || GV.stageCollection == null)
                return false;

            var a4Idx:int = GV.getFieldId("A4");
            if (a4Idx < 0) {
                logAction("clearLegacyTrialInjection: A4 field id not found");
                return false;
            }

            var stale:Number = GV.ppd.stageHighestXpsTrial[a4Idx].g();
            var alreadyPersisted:Boolean = _legacyTrialXpCleared;
            _legacyTrialXpCleared = true;
            _legacyTrialXpClearedThisSession = true;
            if (!alreadyPersisted && onDataChanged != null)
                onDataChanged();
            if (stale <= 0)
                return false;

            GV.ppd.stageHighestXpsTrial[a4Idx].s(-1);
            _xpBarDirty = true;
            logAction("clearLegacyTrialInjection: dropped " + stale + " legacy XP from A4 Trial");
            return true;
        }
    }
}

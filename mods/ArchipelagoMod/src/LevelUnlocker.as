package {
    import Bezel.Logger;

    /**
     * Handles AP wizard level / XP bonus grants.
     * XP Bonus AP IDs: 500 (Tattered Scroll=+1), 501 (Worn Tome=+3), 502 (Ancient Grimoire=+9).
     *
     * The accumulated bonus level is persisted in the slot JSON file.
     * Applying it to in-game wizard level needs a safe injection point (TODO).
     */
    public class LevelUnlocker {

        private var _logger:Logger;
        private var _modName:String;
        private var _toast:ToastPanel;
        private var _bonusWizardLevel:int = 0;

        /** Called after granting XP so the caller can persist the updated state. */
        public var onDataChanged:Function; // ():void

        public function LevelUnlocker(logger:Logger, modName:String, toast:ToastPanel) {
            _logger  = logger;
            _modName = modName;
            _toast   = toast;
        }

        public function get bonusWizardLevel():int { return _bonusWizardLevel; }
        public function set bonusWizardLevel(value:int):void { _bonusWizardLevel = value; }

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

            _bonusWizardLevel += levels;
            if (onDataChanged != null) onDataChanged();

            _logger.log(_modName, label + " → +" + levels
                + " wizard levels (bonus total: " + _bonusWizardLevel + ")");
            _toast.addMessage("+" + levels + " Wizard Levels (bonus total: "
                + _bonusWizardLevel + ")", 0xFF88CCFF);
        }
    }
}

package {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Handles unlocking battle traits by Archipelago item ID.
     * Battle trait AP IDs range from 400 to 414.
     */
    public class TraitUnlocker {

        private var _logger:Logger;
        private var _modName:String;
        private var _itemToast:ItemToastPanel;

        // Battle trait names indexed by game_id (matches BattleTraitId constants).
        private static const BATTLE_TRAIT_NAMES:Array = [
            "Adaptive Carapace", "Dark Masonry", "Swarmling Domination", "Overcrowd",
            "Corrupted Banishment", "Awakening", "Insulation", "Hatred",
            "Swarmling Parasites", "Haste", "Thick Air", "Vital Link",
            "Giant Domination", "Strength in Numbers", "Ritual"
        ];

        public function TraitUnlocker(logger:Logger, modName:String, itemToast:ItemToastPanel) {
            _logger    = logger;
            _modName   = modName;
            _itemToast = itemToast;
        }

        /**
         * Unlock a battle trait by its Archipelago item ID (400-414).
         * Sets the gained flag and initialises the selected level to 0.
         */
        public function unlockBattleTrait(apId:int):void {
            var gameId:int = apId - 400;
            if (gameId < 0 || gameId > 14) {
                _logger.log(_modName, "unlockBattleTrait: invalid AP ID " + apId);
                return;
            }
            if (GV.ppd == null) {
                _logger.log(_modName, "unlockBattleTrait: GV.ppd is null, cannot unlock trait " + apId);
                return;
            }
            GV.ppd.gainedBattleTraits[gameId] = true;
            GV.ppd.selectedBattleTraitLevels[gameId].s(Math.max(GV.ppd.selectedBattleTraitLevels[gameId].g(), 0));
            var traitName:String = BATTLE_TRAIT_NAMES[gameId];
            _logger.log(_modName, "Unlocked battle trait game_id=" + gameId + " (AP ID=" + apId + ")");
            _itemToast.addItem("Trait Unlocked: " + traitName, 0xFFAA44);
        }

        /** Returns the human-readable trait name for an AP ID (400-414), or null if out of range. */
        public function getTraitName(apId:int):String {
            var gameId:int = apId - 400;
            if (gameId < 0 || gameId >= BATTLE_TRAIT_NAMES.length) return null;
            return BATTLE_TRAIT_NAMES[gameId];
        }
    }
}

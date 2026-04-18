package unlockers {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import ui.ItemToastPanel;

    /**
     * Handles unlocking battle traits by Archipelago item ID.
     * Battle trait AP IDs range from 800 to 814 (after refactoring).
     */
    public class TraitUnlocker extends BaseUnlocker {

        // Battle trait names indexed by game_id (matches BattleTraitId constants).
        public static const BATTLE_TRAIT_NAMES:Array = [
            "Adaptive Carapace", "Dark Masonry", "Swarmling Domination", "Overcrowd",
            "Corrupted Banishment", "Awakening", "Insulation", "Hatred",
            "Swarmling Parasites", "Haste", "Thick Air", "Vital Link",
            "Giant Domination", "Strength in Numbers", "Ritual"
        ];

        public function TraitUnlocker(logger:Logger, modName:String, itemToast:ItemToastPanel) {
            super(logger, modName, itemToast);
        }

        /**
         * Unlock a battle trait by its Archipelago item ID (800-814).
         * Sets the gained flag and initialises the selected level to 0.
         */
        public function unlockBattleTrait(apId:int):void {
            var gameId:int = apId - 800;
            if (gameId < 0 || gameId > 14) {
                logAction("unlockBattleTrait: invalid AP ID " + apId);
                return;
            }
            if (!ensurePpdExists("unlockBattleTrait")) {
                return;
            }
            GV.ppd.gainedBattleTraits[gameId] = true;
            GV.ppd.selectedBattleTraitLevels[gameId].s(Math.max(GV.ppd.selectedBattleTraitLevels[gameId].g(), 0));
            var traitName:String = BATTLE_TRAIT_NAMES[gameId];
            logAction("Unlocked battle trait game_id=" + gameId + " (AP ID=" + apId + ")");
            showToast("Trait Unlocked: " + traitName, 0xFFAA44);
        }

        /** Returns the human-readable trait name for an AP ID (800-814), or null if out of range. */
        public function getTraitName(apId:int):String {
            var gameId:int = apId - 800;
            if (gameId < 0 || gameId >= BATTLE_TRAIT_NAMES.length) return null;
            return BATTLE_TRAIT_NAMES[gameId];
        }
    }
}

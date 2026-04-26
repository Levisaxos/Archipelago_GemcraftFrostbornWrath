package unlockers {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import ui.ReceivedToast;

    /**
     * Handles unlocking skills by Archipelago item ID.
     * Skill AP IDs range from 700 to 723 (after refactoring).
     */
    public class SkillUnlocker extends BaseUnlocker {

        // Skill names indexed by game_id (matches SkillId constants).
        private static const SKILL_NAMES:Array = [
            "Mana Stream", "True Colors", "Fusion", "Orb of Presence",
            "Resonance", "Demolition", "Critical Hit", "Mana Leech",
            "Bleeding", "Armor Tearing", "Poison", "Slowing",
            "Freeze", "Whiteout", "Ice Shards", "Bolt",
            "Beam", "Barrage", "Fury", "Amplifiers",
            "Pylons", "Lanterns", "Traps", "Seeker Sense"
        ];

        public function SkillUnlocker(logger:Logger, modName:String, itemToast:ReceivedToast) {
            super(logger, modName, itemToast);
        }

        /**
         * Unlock a skill by its Archipelago item ID (700-723).
         * Sets the skill tome flag and initialises the level to 0 if not yet available.
         */
        public function unlockSkill(apId:int):void {
            var gameId:int = apId - 700;
            if (gameId < 0 || gameId > 23) {
                logAction("unlockSkill: invalid AP ID " + apId);
                return;
            }
            if (!ensurePpdExists("unlockSkill")) {
                return;
            }
            GV.ppd.gainedSkillTomes[gameId] = true;
            GV.ppd.setSkillLevel(gameId, Math.max(GV.ppd.getSkillLevel(gameId), 0));
            var skillName:String = SKILL_NAMES[gameId];
            logAction("Unlocked skill game_id=" + gameId + " (AP ID=" + apId + ")");
            showToast("Received " + skillName, 0xDDA0FF);
            showPlusNodeOnSelector("mcPlusNodeSkills");
        }

        /** Returns the human-readable skill name for an AP ID (700-723), or null if out of range. */
        public function getSkillName(apId:int):String {
            var gameId:int = apId - 700;
            if (gameId < 0 || gameId >= SKILL_NAMES.length) return null;
            return SKILL_NAMES[gameId];
        }

    }
}

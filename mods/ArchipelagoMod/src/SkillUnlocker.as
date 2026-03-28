package {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Handles unlocking skills by Archipelago item ID.
     * Skill AP IDs range from 300 to 323.
     */
    public class SkillUnlocker {

        private var _logger:Logger;
        private var _modName:String;
        private var _itemToast:ItemToastPanel;

        // Skill names indexed by game_id (matches SkillId constants).
        private static const SKILL_NAMES:Array = [
            "Mana Stream", "True Colors", "Fusion", "Orb of Presence",
            "Resonance", "Demolition", "Critical Hit", "Mana Leech",
            "Bleeding", "Armor Tearing", "Poison", "Slowing",
            "Freeze", "Whiteout", "Ice Shards", "Bolt",
            "Beam", "Barrage", "Fury", "Amplifiers",
            "Pylons", "Lanterns", "Traps", "Seeker Sense"
        ];

        public function SkillUnlocker(logger:Logger, modName:String, itemToast:ItemToastPanel) {
            _logger    = logger;
            _modName   = modName;
            _itemToast = itemToast;
        }

        /**
         * Unlock a skill by its Archipelago item ID (300-323).
         * Sets the skill tome flag and initialises the level to 0 if not yet available.
         */
        public function unlockSkill(apId:int):void {
            var gameId:int = apId - 300;
            if (gameId < 0 || gameId > 23) {
                _logger.log(_modName, "unlockSkill: invalid AP ID " + apId);
                return;
            }
            if (GV.ppd == null) {
                _logger.log(_modName, "unlockSkill: GV.ppd is null, cannot unlock skill " + apId);
                return;
            }
            GV.ppd.gainedSkillTomes[gameId] = true;
            GV.ppd.setSkillLevel(gameId, Math.max(GV.ppd.getSkillLevel(gameId), 0));
            var skillName:String = SKILL_NAMES[gameId];
            _logger.log(_modName, "Unlocked skill game_id=" + gameId + " (AP ID=" + apId + ")");
            _itemToast.addItem("Skill Unlocked: " + skillName, 0xDDA0FF);
        }

        /** Returns the human-readable skill name for an AP ID (300-323), or null if out of range. */
        public function getSkillName(apId:int):String {
            var gameId:int = apId - 300;
            if (gameId < 0 || gameId >= SKILL_NAMES.length) return null;
            return SKILL_NAMES[gameId];
        }
    }
}

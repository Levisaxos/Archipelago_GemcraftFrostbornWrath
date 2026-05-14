package unlockers {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import ui.ReceivedToast;
    import ui.ItemColors;

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

        // Vanilla achievement 367 "Regaining Knowledge" auto-fires at 7 unlocked skills
        // because vanilla pre-unlocks Mana Stream + Fusion. The AP mod locks all starters,
        // so the vanilla check never trips. Fire it ourselves at 5 received skills to
        // match the apworld rule (skills:5).
        private static const ACHI_REGAINING_KNOWLEDGE:int = 367;
        private static const SKILLS_FOR_REGAINING_KNOWLEDGE:int = 5;

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
            showToast("Received " + skillName, ItemColors.forApId(apId));
            showPlusNodeOnSelector("mcPlusNodeSkills");
            maybeFireRegainingKnowledge();
        }

        /**
         * Force-complete game_id 367 ("Regaining Knowledge") when the player has received
         * SKILLS_FOR_REGAINING_KNOWLEDGE skill tomes. AchievementUnlocker observes the
         * resulting status>=2 and sends the AP location check on its next frame tick.
         * Safe to call any time — guarded against null collection and re-trigger.
         */
        public function maybeFireRegainingKnowledge():void {
            if (GV.achiCollection == null)
                return;
            var ach:* = GV.achiCollection.achisById[ACHI_REGAINING_KNOWLEDGE];
            if (ach == null || ach.status >= 2)
                return;
            if (GV.ppd == null || GV.ppd.gainedSkillTomes == null)
                return;
            var count:int = 0;
            for (var i:int = 0; i < 24; i++) {
                if (GV.ppd.gainedSkillTomes[i])
                    count++;
            }
            if (count >= SKILLS_FOR_REGAINING_KNOWLEDGE) {
                try {
                    ach.status = 2;
                    logAction("Forced achievement 367 (Regaining Knowledge) to status=2 — " + count + " skills unlocked");
                } catch (e:Error) {
                    logAction("maybeFireRegainingKnowledge: failed to set status: " + e);
                }
            }
        }

        /** Returns the human-readable skill name for an AP ID (700-723), or null if out of range. */
        public function getSkillName(apId:int):String {
            var gameId:int = apId - 700;
            if (gameId < 0 || gameId >= SKILL_NAMES.length) return null;
            return SKILL_NAMES[gameId];
        }

    }
}

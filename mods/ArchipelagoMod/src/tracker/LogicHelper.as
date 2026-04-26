package tracker {
    import Bezel.Logger;
    import data.AV;

    /**
     * Convenience wrapper for logic checks used by external callers.
     * Reads from AV.sessionData (items) and delegates wave checks to
     * FieldLogicEvaluator.
     */
    public class LogicHelper {
        private var _logger:Logger;
        private var _modName:String;
        private var _fieldEvaluator:FieldLogicEvaluator;

        public function LogicHelper(logger:Logger, modName:String,
                                    fieldEvaluator:FieldLogicEvaluator) {
            _logger         = logger;
            _modName        = modName;
            _fieldEvaluator = fieldEvaluator;
        }

        /**
         * Check if player has received a specific battle trait.
         * @param traitId Game index 0–14, maps to AP IDs 800–814.
         */
        public function HasBattleTrait(traitId:int):Boolean {
            if (traitId < 0 || traitId >= 15) return false;
            return AV.sessionData.hasItem(800 + traitId);
        }

        /**
         * Check if player has received a specific skill.
         * @param skillId Game index 0–23, maps to AP IDs 700–723.
         */
        public function HasSkill(skillId:int):Boolean {
            if (skillId < 0 || skillId >= 24) return false;
            return AV.sessionData.hasItem(700 + skillId);
        }

        /**
         * Check if a stage is currently in logic.
         * Reads from AV.sessionData.fieldsInLogic (updated by FieldLogicEvaluator).
         */
        public function HasFieldInLogic(fieldStrId:String):Boolean {
            return AV.sessionData.fieldsInLogic[fieldStrId] == true;
        }

        /**
         * Check if any in-logic field has enough waves for a given minWave requirement.
         */
        public function HasFieldWithMinWaveCount(waveCount:int):Boolean {
            return _fieldEvaluator != null
                && _fieldEvaluator.hasInLogicFieldWithMinWaves(waveCount);
        }

        /** Check if player has at least count strike spells (AP IDs 712–714). */
        public function hasStrikeSpells(count:int):Boolean {
            return AV.sessionData.countItemsInRange(712, 714) >= count;
        }

        /** Check if player has at least count enhancement spells (AP IDs 715–717). */
        public function hasEnhancementSpells(count:int):Boolean {
            return AV.sessionData.countItemsInRange(715, 717) >= count;
        }

        /** Check if player has at least count gem skills (AP IDs 706–711). */
        public function hasGemSkills(count:int):Boolean {
            return AV.sessionData.countItemsInRange(706, 711) >= count;
        }
    }
}

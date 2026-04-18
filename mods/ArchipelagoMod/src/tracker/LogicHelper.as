package tracker {
    import Bezel.Logger;

    /**
     * Helper class for logic checks (achievements and field access).
     * Encapsulates queries about player progression, item collection, and stage accessibility.
     *
     * All checks read from CollectedState (AP-received items) and LogicEvaluator (stage tier progression),
     * ensuring a single source of truth for what the player has and can access.
     *
     * Used by:
     *   - Achievement in-logic filtering (skill/trait/spell group requirements)
     *   - Field token access checks (green glow indicators on stages)
     */
    public class LogicHelper {
        private var _logger:Logger;
        private var _modName:String;
        private var _collectedState:CollectedState;
        private var _logicEvaluator:LogicEvaluator;
        private var _connectionManager:Object; // ConnectionManager

        public function LogicHelper(logger:Logger, modName:String,
                                    collectedState:CollectedState,
                                    logicEvaluator:LogicEvaluator,
                                    connectionManager:Object) {
            _logger = logger;
            _modName = modName;
            _collectedState = collectedState;
            _logicEvaluator = logicEvaluator;
            _connectionManager = connectionManager;
        }

        /**
         * Check if player has received a specific battle trait.
         * @param traitId Game index 0–14, maps to AP IDs 400–414.
         *                Must match TraitUnlocker.BATTLE_TRAIT_NAMES order.
         * @return true if the trait AP item has been received.
         */
        public function HasBattleTrait(traitId:int):Boolean {
            if (traitId < 0 || traitId >= 15) return false;
            return _collectedState != null && _collectedState.hasItem(800 + traitId);
        }

        /**
         * Check if player has received a specific skill.
         * @param skillId Game index 0–23, maps to AP IDs 700–723.
         *                Corresponds to CollectedState.SKILL_NAMES order.
         * @return true if the skill AP item has been received.
         */
        public function HasSkill(skillId:int):Boolean {
            if (skillId < 0 || skillId >= 24) return false;
            return _collectedState != null && _collectedState.hasItem(700 + skillId);
        }

        /**
         * Check if a stage is currently accessible to the player (in logic).
         * Uses tier progression rules: depends on field tokens collected and skills available.
         * Also checks WIZLOCK gates (stage_skills) if applicable.
         *
         * @param fieldStrId Stage identifier (e.g., "A4", "N1", "W1").
         * @return true if at least one missing location on this stage is reachable.
         */
        public function HasFieldInLogic(fieldStrId:String):Boolean {
            return _logicEvaluator != null && _logicEvaluator.isStageInLogic(fieldStrId);
        }

        /**
         * Check if any in-logic field has enough waves for a given minWave requirement.
         * Only returns true if at least one accessible stage meets the wave requirement.
         *
         * Wave tier mapping:
         *   tier 0: 14 waves     tier 6: 54 waves     tier 12: 96 waves
         *   tier 1: 22 waves     tier 7: 60 waves
         *   tier 2: 28 waves     tier 8: 70 waves    (endurance starts >96)
         *   etc.
         *
         * @param waveCount Minimum waves needed (e.g., 22 for tier 1, 100 for endurance).
         * @return true if at least one in-logic stage has waveCount waves.
         */
        public function HasFieldWithMinWaveCount(waveCount:int):Boolean {
            if (_logicEvaluator == null) return false;

            // Only journey mode is supported — check if any in-logic field
            // has enough waves. Waves > 96 are endurance/trial only and
            // automatically fail since we don't consider those modes.
            return _logicEvaluator.hasInLogicFieldWithMinWaves(waveCount);
        }

        /**
         * Check if player has at least the specified number of strike spells.
         * Strike spells: Freeze, Whiteout, Ice Shards (AP IDs 312–314).
         *
         * @param count Minimum number of strike spells required.
         * @return true if player has at least count strike spells.
         */
        public function hasStrikeSpells(count:int):Boolean {
            var have:int = 0;
            for (var i:int = 712; i <= 714; i++) {
                if (_collectedState && _collectedState.hasItem(i)) have++;
            }
            return have >= count;
        }

        /**
         * Check if player has at least the specified number of enhancement spells.
         * Enhancement spells: Bolt, Beam, Barrage (AP IDs 715–717).
         *
         * @param count Minimum number of enhancement spells required.
         * @return true if player has at least count enhancement spells.
         */
        public function hasEnhancementSpells(count:int):Boolean {
            var have:int = 0;
            for (var i:int = 715; i <= 717; i++) {
                if (_collectedState && _collectedState.hasItem(i)) have++;
            }
            return have >= count;
        }

        /**
         * Check if player has at least the specified number of gem skills.
         * Gem skills: Critical Hit, Mana Leech, Bleeding, Armor Tearing, Poison, Slowing (AP IDs 706–711).
         *
         * @param count Minimum number of gem skills required.
         * @return true if player has at least count gem skills.
         */
        public function hasGemSkills(count:int):Boolean {
            var have:int = 0;
            for (var i:int = 706; i <= 711; i++) {
                if (_collectedState && _collectedState.hasItem(i)) have++;
            }
            return have >= count;
        }
    }
}

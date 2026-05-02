package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import tracker.FieldLogicEvaluator;

    /**
     * Gates Ritual-trait creature spawns by AP logic.
     *
     * IngameInitializer populates demonicMeter spawn-schedule arrays for special
     * creatures (Shadow / Spire / Wraith / Specter / Wizard Hunter / Apparition)
     * once Ritual is gained.  This patcher runs in the same first-frame window as
     * WavePrePatcher (currentWave < 0) and rewrites those arrays so a creature
     * type only spawns if at least one of its original-vanilla levels is in logic
     * for the current seed.  Locked-type entries are redistributed onto random
     * unlocked types to preserve the configured ritual count.
     *
     * Source of truth for the creature -> original-levels map:
     *   apworld/gcfw/rulesdata_levels.py  (per-stage <Creature>Count fields:
     *   ShadowCount / SpecterCount / SpireCount / WraithCount /
     *   WizardHunterCount / ApparitionCount)
     */
    public class RitualSpawnPatcher {

        private static const RITUAL_TRAIT_GAME_ID:int = 14;

        // Standard four redistribute among each other.
        private static const SHADOW_LEVELS:Array  = ["A4", "C5", "E4", "G3"];
        private static const SPECTER_LEVELS:Array = ["E4", "Y4"];
        private static const SPIRE_LEVELS:Array   = ["E2"];
        private static const WRAITH_LEVELS:Array  = ["A4", "X4"];

        // Special-case creatures.
        private static const WIZARD_HUNTER_LEVELS:Array = ["L4"];
        private static const APPARITION_LEVELS:Array    = ["Q1", "R6"];

        private var _logger:Logger;
        private var _modName:String;
        private var _logicEval:FieldLogicEvaluator;
        private var _hasApplied:Boolean = false;

        // -----------------------------------------------------------------------

        public function RitualSpawnPatcher(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        /** Call once after AP connects (same place LogicEnforcer is configured). */
        public function configure(logicEval:FieldLogicEvaluator):void {
            _logicEval = logicEval;
        }

        /** Reset the applied flag so the patcher fires again on the next stage. */
        public function resetForNewStage():void {
            _hasApplied = false;
        }

        // -----------------------------------------------------------------------
        // Ingame frame hook

        public function applyIfReady():void {
            if (_hasApplied) return;
            if (_logicEval == null) return;

            try {
                var core:* = GV.ingameCore;
                if (core == null) return;
                if (core.currentWave.g() >= 0) {
                    _hasApplied = true;
                    return;
                }
                if (core.waves == null || core.waves.length == 0) return;
                if (core.demonicMeter == null) return;
                if (GV.ppd == null) return;

                // Ritual not granted -> nothing to do (arrays are empty anyway).
                if (!GV.ppd.gainedBattleTraits[RITUAL_TRAIT_GAME_ID]) {
                    _hasApplied = true;
                    return;
                }

                _apply(core);
                _hasApplied = true;
            } catch (err:Error) {
                _logger.log(_modName, "RitualSpawnPatcher.applyIfReady ERROR: " + err.message);
            }
        }

        // -----------------------------------------------------------------------

        private function _apply(core:*):void {
            var dm:* = core.demonicMeter;

            var shadowUnlocked:Boolean  = _anyInLogic(SHADOW_LEVELS);
            var specterUnlocked:Boolean = _anyInLogic(SPECTER_LEVELS);
            var spireUnlocked:Boolean   = _anyInLogic(SPIRE_LEVELS);
            var wraithUnlocked:Boolean  = _anyInLogic(WRAITH_LEVELS);
            var wizardUnlocked:Boolean  = _anyInLogic(WIZARD_HUNTER_LEVELS);
            var apparitionUnlocked:Boolean = _anyInLogic(APPARITION_LEVELS);

            // Build pool of arrays the standard redistribution can target.
            var stdPool:Array = [];
            if (shadowUnlocked)  stdPool.push(dm.shadowsComingAtWaveNums_rnd);
            if (spireUnlocked)   stdPool.push(dm.spiresComingAtWaveNums_rnd);
            if (wraithUnlocked)  stdPool.push(dm.wraithsComingAtWaveNums_rnd);
            if (specterUnlocked) stdPool.push(dm.spectersComingAtWaveNums_rnd);

            // ---- Standard four: drain all, then redistribute onto unlocked. ----
            var inShadow:int   = (dm.shadowsComingAtWaveNums_rnd  as Array).length;
            var inSpire:int    = (dm.spiresComingAtWaveNums_rnd   as Array).length;
            var inWraith:int   = (dm.wraithsComingAtWaveNums_rnd  as Array).length;
            var inSpecter:int  = (dm.spectersComingAtWaveNums_rnd as Array).length;

            var allEntries:Array = [];
            allEntries = allEntries.concat(dm.shadowsComingAtWaveNums_rnd);
            allEntries = allEntries.concat(dm.spiresComingAtWaveNums_rnd);
            allEntries = allEntries.concat(dm.wraithsComingAtWaveNums_rnd);
            allEntries = allEntries.concat(dm.spectersComingAtWaveNums_rnd);

            (dm.shadowsComingAtWaveNums_rnd  as Array).length = 0;
            (dm.spiresComingAtWaveNums_rnd   as Array).length = 0;
            (dm.wraithsComingAtWaveNums_rnd  as Array).length = 0;
            (dm.spectersComingAtWaveNums_rnd as Array).length = 0;

            if (stdPool.length > 0) {
                for each (var waveNum:* in allEntries) {
                    var target:Array = stdPool[int(Math.random() * stdPool.length)] as Array;
                    target.push(waveNum);
                }
            }

            // ---- Wizard Hunter: drop Hps/Armors; if locked, move waveNums into stdPool. ----
            var inWizard:int = (dm.wizardHuntersComingAtWaveNums_scripted as Array).length;
            if (!wizardUnlocked) {
                if (stdPool.length > 0) {
                    for each (var whWaveNum:* in dm.wizardHuntersComingAtWaveNums_scripted) {
                        var whTarget:Array = stdPool[int(Math.random() * stdPool.length)] as Array;
                        whTarget.push(whWaveNum);
                    }
                }
                (dm.wizardHuntersComingAtWaveNums_scripted       as Array).length = 0;
                (dm.wizardHuntersComingAtWaveNums_scriptedHps    as Array).length = 0;
                (dm.wizardHuntersComingAtWaveNums_scriptedArmors as Array).length = 0;
            }

            // ---- Apparitions: independent count; just clear if locked. ----
            var inApparition:int = (dm.apparitionsComingAtWaveNums_rnd as Array).length;
            if (!apparitionUnlocked) {
                (dm.apparitionsComingAtWaveNums_rnd as Array).length = 0;
            }

            _logger.log(_modName,
                "RitualSpawnPatcher: unlocked="
                + "[" + (shadowUnlocked  ? "shadow "  : "")
                      + (spireUnlocked   ? "spire "   : "")
                      + (wraithUnlocked  ? "wraith "  : "")
                      + (specterUnlocked ? "specter " : "")
                      + (wizardUnlocked  ? "wizardHunter " : "")
                      + (apparitionUnlocked ? "apparition" : "")
                + "]"
                + "  in: shadow=" + inShadow + " spire=" + inSpire
                + " wraith=" + inWraith + " specter=" + inSpecter
                + " wizardHunter=" + inWizard + " apparition=" + inApparition
                + "  out: shadow=" + (dm.shadowsComingAtWaveNums_rnd  as Array).length
                + " spire="    + (dm.spiresComingAtWaveNums_rnd   as Array).length
                + " wraith="   + (dm.wraithsComingAtWaveNums_rnd  as Array).length
                + " specter="  + (dm.spectersComingAtWaveNums_rnd as Array).length
                + " wizardHunter=" + (dm.wizardHuntersComingAtWaveNums_scripted as Array).length
                + " apparition="   + (dm.apparitionsComingAtWaveNums_rnd as Array).length);
        }

        // -----------------------------------------------------------------------

        private function _anyInLogic(levels:Array):Boolean {
            for each (var strId:String in levels) {
                if (_logicEval.isStageInLogic(strId)) return true;
            }
            return false;
        }
    }
}

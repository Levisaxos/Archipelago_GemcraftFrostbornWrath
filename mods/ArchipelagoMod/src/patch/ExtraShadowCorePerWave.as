package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import data.AV;

    /**
     * Mod-only quality-of-life reward: grants `extraShadowCoresPerWave` extra
     * shadow cores for every wave the player gets through in a battle.
     *
     * The cores are added straight into the vanilla per-battle loot accumulator
     * (IngameCore.ocLootShadowCoreNum), exactly where real shadow-core drops
     * land.  The game banks that accumulator into the persistent pool
     * (GV.ppd.shadowCoreAmount) at level end for BOTH victory and defeat
     * (IngameEnding), so:
     *   - clearing a 30-wave field at 5/wave grants 150 cores, and
     *   - losing a 50-wave field after 30 waves still grants 150 cores.
     * No second pool, no separate post-level grant — the reward flows through
     * the game's own drop-tally and outcome panel.
     *
     * Detection reuses the delta pattern from LinkedWaveEarlyCredit: watch
     * IngameCore.currentWave (starts at -1, +1 per wave spawned; linked pairs
     * advance it by 2 in one frame) and credit `per * waveDelta` whenever it
     * increases.  Because ocLootShadowCoreNum is reset to 0 at battle start by
     * the vanilla initializer, there is nothing persistent to unwind — this
     * patcher is only polled while AP mode is active.
     */
    public class ExtraShadowCorePerWave {

        private var _logger:Logger;
        private var _modName:String;

        // Last observed wave index. Starts at -1 to match currentWave's
        // pre-first-wave state so the first wave is credited exactly once.
        private var _prevWave:int = -1;

        // -----------------------------------------------------------------------

        public function ExtraShadowCorePerWave(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        /**
         * Re-baseline at the start of (or restart of) a battle, where the game
         * resets currentWave to -1 and ocLootShadowCoreNum to 0.
         */
        public function resetForNewStage():void {
            _prevWave = -1;
        }

        // -----------------------------------------------------------------------

        /**
         * Call every INGAME frame.  Credits `per` shadow cores for each wave the
         * player has reached since the last frame.
         */
        public function onIngameFrame():void {
            try {
                var per:int = AV.serverData.serverOptions.extraShadowCoresPerWave;
                if (per <= 0) return;

                var core:* = GV.ingameCore;
                if (core == null || core.currentWave == null || core.ocLootShadowCoreNum == null) return;

                var curWave:int = int(core.currentWave.g());

                // Fresh battle / retry not yet caught by resetForNewStage:
                // currentWave is back below our baseline. Re-baseline, don't act.
                if (curWave < _prevWave) {
                    _prevWave = curWave;
                    return;
                }

                var waveDelta:int = curWave - _prevWave;
                if (waveDelta > 0) {
                    core.ocLootShadowCoreNum.s(core.ocLootShadowCoreNum.g() + per * waveDelta);
                }

                _prevWave = curWave;
            } catch (err:Error) {
                _logger.log(_modName, "ExtraShadowCorePerWave.onIngameFrame ERROR: " + err.message);
            }
        }
    }
}

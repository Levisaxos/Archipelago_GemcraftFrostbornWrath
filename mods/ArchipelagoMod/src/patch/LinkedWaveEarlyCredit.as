package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Fixes a vanilla counting quirk: calling a LINKED wave early only credits
     * one wavesCalledEarly++, even though the linked follower auto-spawns with
     * its leader (two waves consumed by a single button press).
     *
     * Consequences in vanilla:
     *   - "Skylark" (game_id 460) checks wavesCalledEarly >= waves.length - 1.
     *     Every linked pair on a field steals one point, so the threshold is
     *     unreachable on any stage that contains a link (e.g. S2: 16 waves,
     *     1 link -> max 14, needs 15). The achievement is impossible there.
     *   - The "Call N waves early" family (322-326) reaches its threshold one
     *     call later than the player expects on linked fields.
     *
     * This tracker watches the per-battle counter and currentWave each ingame
     * frame.  When an early call advances currentWave by more than one (the
     * linked follower), it credits the extra wave(s) so a linked pair counts as
     * two.  After the fix the maximum is always waves.length - 1 regardless of
     * links. NOTE: that is HIGHER than the apworld's vanilla CallableWaveCount
     * (which subtracts one per link); because this patch restores the linked
     * credit, minWave:N logic gates on total WaveCount, not CallableWaveCount
     * (see requirement_tokens.py / LogicEvaluator.as).
     *
     * Detection is delta-based and only acts on frames where wavesCalledEarly
     * actually increased, so naturally-arriving waves (which never touch the
     * counter) are ignored.  The vanilla checks consume the corrected counter
     * on their own cadence — Skylark stays victory-gated (checkAchisAtTrueVictory)
     * and the 322-326 family stay on their regular round-robin check — so we
     * deliberately do NOT fire checkAchi ourselves.
     */
    public class LinkedWaveEarlyCredit {

        private var _logger:Logger;
        private var _modName:String;

        // Last observed per-battle values. _prevWave starts at -1 to match
        // currentWave's pre-first-wave state (the first wave auto-starts and
        // never counts as an early call).
        private var _prevCalled:int = 0;
        private var _prevWave:int   = -1;

        // -----------------------------------------------------------------------

        public function LinkedWaveEarlyCredit(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        /**
         * Re-baseline at the start of (or restart of) a battle, where the game
         * resets currentWave to -1 and wavesCalledEarly to 0.
         */
        public function resetForNewStage():void {
            _prevCalled = 0;
            _prevWave   = -1;
        }

        // -----------------------------------------------------------------------

        /**
         * Call every INGAME frame.  Credits linked followers as additional
         * early-wave calls.
         */
        public function onIngameFrame():void {
            try {
                var core:* = GV.ingameCore;
                if (core == null || core.stats == null || core.currentWave == null) return;

                var curCalled:int = int(core.stats.wavesCalledEarly);
                var curWave:int   = int(core.currentWave.g());

                // Fresh battle / retry not yet caught by resetForNewStage:
                // either counter is back at zero range. Re-baseline, don't act.
                if (curWave < _prevWave || curCalled < _prevCalled) {
                    _prevCalled = curCalled;
                    _prevWave   = curWave;
                    return;
                }

                var callDelta:int = curCalled - _prevCalled;
                if (callDelta > 0) {
                    // Waves consumed beyond one-per-call are linked followers
                    // that the player did not get separate credit for.
                    var waveDelta:int   = curWave - _prevWave;
                    var linkedExtra:int = waveDelta - callDelta;

                    // Consecutive links are blocked by the populator, so each
                    // call can pull in at most one follower — clamp defensively
                    // in case a natural arrival lands in the same frame.
                    if (linkedExtra > callDelta) linkedExtra = callDelta;

                    if (linkedExtra > 0) {
                        curCalled += linkedExtra;
                        core.stats.wavesCalledEarly = curCalled;
                    }
                }

                _prevCalled = curCalled;
                _prevWave   = curWave;
            } catch (err:Error) {
                _logger.log(_modName, "LinkedWaveEarlyCredit.onIngameFrame ERROR: " + err.message);
            }
        }
    }
}

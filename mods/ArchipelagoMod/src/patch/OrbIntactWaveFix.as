package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Fixes a vanilla off-by-one on the four "don't let a monster touch your orb
     * for N beaten waves" achievements (260 Well Defended / 20, 261 Tightly
     * Secured / 60, 262 It's a Trap / 120, 248 You Shall Not Pass / 240).
     *
     * Orb.numIntactWaves initializes to -1 — an intentional base for the orb-XP
     * bonus, which only starts paying out from the 2nd consecutive intact wave.
     * So after N intact beaten waves the counter reads N-1, while the checks
     * want numIntactWaves > (N - 0.5), i.e. value >= N. That means they really
     * require N+1 intact waves, one more than the "N beaten waves" the text
     * promises — and on a field with exactly N waves they can never be earned.
     *
     * We can't retune numIntactWaves itself without also shifting the orb-XP
     * bonus (same field). So once the real intact-wave count reaches the stated
     * number (value == stated - 1), we nudge the counter up by one for a single
     * re-check through the game's own checkAchi() — unlocking the achievement
     * exactly as vanilla would at the stated count — then restore the counter.
     * The XP bonus reads numIntactWaves only inside the wave-beaten handler, so
     * the transient +1 never affects XP.
     *
     * checkAchi() self-guards (arrIsAchiStatusAvailable[id] flips false on
     * unlock), and we also skip already-gained achievements, so this fires at
     * most once per achievement per battle. The unlock is
     * UNLOCKED_BUT_HAVE_TO_WIN, so the win requirement is preserved.
     */
    public class OrbIntactWaveFix {

        // { id, waves } — the stated intact-wave count each achievement advertises.
        private static const ORB_ACHIS:Array = [
            { id: 260, waves: 20 },
            { id: 261, waves: 60 },
            { id: 262, waves: 120 },
            { id: 248, waves: 240 }
        ];

        // Lowest stated count, minus one — below this there is nothing to do.
        private static const MIN_VALUE:int = 19;

        private var _logger:Logger;
        private var _modName:String;

        public function OrbIntactWaveFix(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        /** Call every in-game frame (currentScreen == INGAME) while AP is active. */
        public function onIngameFrame():void {
            var core:* = GV.ingameCore;
            if (core == null) return;
            var orb:* = core.orb;
            var ctrl:* = GV.ingameAchiCtrl;
            if (orb == null || ctrl == null) return;

            var n:int = int(orb.numIntactWaves.g());
            if (n < MIN_VALUE) return; // not at any stated threshold yet

            for each (var a:Object in ORB_ACHIS) {
                if (n == int(a.waves) - 1) {
                    _forceUnlock(int(a.id), orb, ctrl, n);
                }
            }
        }

        private function _forceUnlock(id:int, orb:*, ctrl:*, n:int):void {
            try {
                // Already earned on this save? leave it alone.
                if (GV.ppd != null && GV.ppd.gainedAchis != null && GV.ppd.gainedAchis[id])
                    return;
                var avail:Array = ctrl.arrIsAchiStatusAvailable;
                // Not checkable in this battle, or already unlocked-pending.
                if (avail == null || id >= avail.length || !avail[id])
                    return;

                // One-shot: bump past the vanilla > (waves - 0.5) gate, let the
                // game unlock it, then restore so the orb-XP bonus is untouched.
                orb.numIntactWaves.s(n + 1);
                ctrl.checkAchi(id, true, true);
                orb.numIntactWaves.s(n);

                _logger.log(_modName,
                    "OrbIntactWaveFix: unlocked achi " + id + " at " + (n + 1) + " intact waves");
            } catch (e:Error) {
                _logger.log(_modName, "OrbIntactWaveFix error on achi " + id + ": " + e.message);
            }
        }
    }
}

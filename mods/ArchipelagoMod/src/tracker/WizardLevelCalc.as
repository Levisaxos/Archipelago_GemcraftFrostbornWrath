package tracker {

    /**
     * Derived Wizard Level — the AS3 port of apworld difficulty_gates.py.
     * MUST stay bit-for-bit identical to the Python side (invariant 1 of the
     * WL-derived design). Validated against data/wl_test_vectors.json (280
     * cases). Do NOT reorder operations or use Math.pow for the multiplier —
     * the multiplier ships as exact literals in slot_data (xp_trait_multiplier).
     *
     *   derivedWl = levelFromXp( clearedXpSum * multiplier[n] )
     *   clearedXpSum = sum of wlEffXp[strId] over cleared fields
     *   n            = how many of the 4 XP-scaling traits are held (cap 4)
     */
    public class WizardLevelCalc {

        /** Total XP needed to reach wizard `level`
         *  (mirror of Calculator.calculatePlayerLevelXpReq / the Python fn). */
        public static function playerLevelXpReq(level:int):Number {
            var d2:Number = 30 + (level - 1) * 5;
            var d:Number = 600 + d2 / 2 * (level - 1);
            return -10 + 10 * Math.floor(0.8 * (300 + d / 2 * (level - 1)) / 10 + 0.5);
        }

        /** Highest wizard level whose XP requirement is <= xp. */
        public static function levelFromXp(xp:Number, cap:int = 3000):int {
            var lvl:int = 0;
            while (lvl < cap && playerLevelXpReq(lvl + 1) <= xp)
                lvl++;
            return lvl;
        }

        /** Canonical derived WL. `multiplier` is the shipped xp_trait_multiplier
         *  array ([1.0,1.2,1.44,1.728,2.0736]); traitsHeld is clamped to 0..4. */
        public static function derivedWl(clearedXpSum:Number, traitsHeld:int, multiplier:Array):int {
            var n:int = traitsHeld;
            if (n < 0)
                n = 0;
            else if (n > 4)
                n = 4;
            var m:Number = (multiplier != null && n < multiplier.length)
                    ? Number(multiplier[n]) : 1.0;
            return levelFromXp(clearedXpSum * m);
        }

        /** Parity self-check of the ported curve against reference values
         *  computed from apworld difficulty_gates.py. Returns "" if all pass,
         *  else a "; "-joined list of mismatches. Logged once on connect so a
         *  bad AS3 transcription is caught immediately (invariant 1). */
        public static function selfTest():String {
            var errs:Array = [];
            _chk(errs, "req(1)",       playerLevelXpReq(1),   230);
            _chk(errs, "req(2)",       playerLevelXpReq(2),   480);
            _chk(errs, "req(5)",       playerLevelXpReq(5),   1350);
            _chk(errs, "req(10)",      playerLevelXpReq(10),  3610);
            _chk(errs, "req(50)",      playerLevelXpReq(50),  144050);
            _chk(errs, "req(100)",     playerLevelXpReq(100), 1053100);
            _chk(errs, "lvl(0)",       levelFromXp(0),        0);
            _chk(errs, "lvl(100)",     levelFromXp(100),      0);
            _chk(errs, "lvl(5000)",    levelFromXp(5000),     12);
            _chk(errs, "lvl(50000)",   levelFromXp(50000),    33);
            _chk(errs, "lvl(500000)",  levelFromXp(500000),   77);
            _chk(errs, "lvl(5000000)", levelFromXp(5000000),  169);
            return errs.length == 0 ? "" : errs.join("; ");
        }

        private static function _chk(errs:Array, label:String, got:Number, want:Number):void {
            if (got != want)
                errs.push(label + " got " + got + " want " + want);
        }
    }
}

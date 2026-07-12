package tracker {

    /**
     * Derived Wizard Level — the AS3 port of apworld difficulty_gates.py.
     * MUST stay bit-for-bit identical to the Python side (invariant 1 of the
     * WL-derived design). Validated against data/wl_test_vectors.json (280
     * cases). Do NOT reorder operations or use Math.pow for the multiplier —
     * the multiplier ships as exact literals in slot_data (xp_trait_multiplier).
     *
     *   derivedWl = levelFromXp( clearedXpSum * multiplier[eff] )
     *   clearedXpSum = sum of wlEffXp[strId] over cleared fields
     *   eff          = effective XP-trait count after the harness gate: apply
     *                  traits one at a time (up to the held count, cap 4); the
     *                  k-th trait counts only if the WL already reached with
     *                  k-1 traits is >= minWl[k]. See difficulty_gates.py.
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
         *  array ([1.0,1.2,1.44,1.728,2.0736]); `minWl` is xp_trait_min_wl
         *  ([0,10,20,30,40]). traitsHeld is clamped to 0..4. Greedy harness gate:
         *  the k-th held trait counts only if the WL already reached with the
         *  first k-1 traits is >= minWl[k]. Mirrors effective_trait_wl. */
        public static function derivedWl(clearedXpSum:Number, traitsHeld:int, multiplier:Array, minWl:Array = null):int {
            var held:int = traitsHeld;
            if (held < 0)
                held = 0;
            else if (held > 4)
                held = 4;
            var n:int = 0;
            var wl:int = levelFromXp(clearedXpSum * _mult(multiplier, 0));
            while (n < held && wl >= _gate(minWl, n + 1)) {
                n++;
                wl = levelFromXp(clearedXpSum * _mult(multiplier, n));
            }
            return wl;
        }

        /** multiplier[i] with a 1.0 fallback (pre-slot_data / short array). */
        private static function _mult(multiplier:Array, i:int):Number {
            return (multiplier != null && i < multiplier.length)
                    ? Number(multiplier[i]) : 1.0;
        }

        /** minWl[i] with a 0 fallback (no gate shipped => traits always count). */
        private static function _gate(minWl:Array, i:int):int {
            return (minWl != null && i < minWl.length) ? int(minWl[i]) : 0;
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
            // Harness gate (greedy step-up) — mirrors effective_trait_wl. Holding
            // 4 traits at low base XP applies fewer than 4 until base WL rises.
            var _mu:Array = [1.0, 1.2, 1.44, 1.728, 2.0736];
            var _mw:Array = [0, 10, 20, 30, 40];
            _chk(errs, "wl(1000,4)",  derivedWl(1000,  4, _mu, _mw), 3);   // eff 0
            _chk(errs, "wl(6000,1)",  derivedWl(6000,  1, _mu, _mw), 14);  // eff 1
            _chk(errs, "wl(6000,4)",  derivedWl(6000,  4, _mu, _mw), 14);  // eff 1
            _chk(errs, "wl(20000,4)", derivedWl(20000, 4, _mu, _mw), 27);  // eff 2
            _chk(errs, "wl(40000,4)", derivedWl(40000, 4, _mu, _mw), 38);  // eff 3
            _chk(errs, "wl(80000,4)", derivedWl(80000, 4, _mu, _mw), 52);  // eff 4
            return errs.length == 0 ? "" : errs.join("; ");
        }

        private static function _chk(errs:Array, label:String, got:Number, want:Number):void {
            if (got != want)
                errs.push(label + " got " + got + " want " + want);
        }
    }
}

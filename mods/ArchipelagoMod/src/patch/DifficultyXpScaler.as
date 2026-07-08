package patch {
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.BattleMode;

    import data.AV;

    /**
     * Difficulty-scaled battle XP.
     *
     * Vanilla computes the battle-XP multiplier as
     *     traitsXpMult = 1.0 + Σ(0.1 × selectedBattleTraitLevel)
     * (SelectorRenderer.renderTraitButtons) and multiplies ALL earned XP by it
     * (battle end, live counter, the XP/outcome screen).
     *
     * We replace the fixed 1.0 base with a per-difficulty base so easier
     * difficulties earn proportionally more XP (and harder ones less), matching
     * the WL model the tracker/apworld use to gate fields:
     *     Easy 2.0 · Medium 1.5 · Hard 1.0 (vanilla) · Extreme 0.5
     * Battle-trait bonuses still add on top, so e.g. Easy + one lvl-12 trait =
     * 2.0 + 1.2 = 3.2.
     *
     * Recomputed every frame from the same inputs the game uses, so it stays
     * correct after the game rebuilds traitsXpMult (trait change / battle init).
     * Idempotent — a full recompute, never an incremental offset. Trial mode is
     * left alone (it uses earlyWaveTrialXpMultPercent, not traitsXpMult).
     */
    public class DifficultyXpScaler {

        // difficulty option value (0=Easy, 1=Medium, 2=Hard, 3=Extreme) → XP base.
        private static const BASE:Array = [2.0, 1.5, 1.0, 0.5];

        /** Recompute traitsXpMult = difficultyBase + Σ(0.1 × traitLevel). Safe to
         *  call every frame in the selector and in battle. */
        public static function apply():void {
            try {
                var sc:* = GV.selectorCore;
                if (sc == null || sc.traitsXpMult == null || GV.ppd == null) return;
                // Trial scales XP a different way — don't touch it there.
                if (GV.ingameCore != null && int(GV.ingameCore.battleMode) == BattleMode.TRIAL)
                    return;

                var sum:Number = 0;
                var n:int = int(GV.BATTLE_TRAITS_NUM);
                for (var i:int = 0; i < n; i++) {
                    if (GV.ppd.gainedBattleTraits[i]) {
                        var lvl:int = int(GV.ppd.selectedBattleTraitLevels[i].g());
                        if (lvl > 0) sum += 0.1 * lvl;
                    }
                }
                sc.traitsXpMult.s(difficultyBase() + sum);
            } catch (e:Error) {}
        }

        /** Per-difficulty XP base; Hard (or unknown difficulty) = 1.0 = vanilla.
         *  Public so the WL model / tooltips can reuse the same value. */
        public static function difficultyBase():Number {
            try {
                var opts:* = (AV.serverData != null) ? AV.serverData.serverOptions : null;
                var d:int = (opts != null) ? int(opts.difficulty) : 2;
                if (d >= 0 && d < BASE.length) return Number(BASE[d]);
            } catch (e:Error) {}
            return 1.0;
        }
    }
}

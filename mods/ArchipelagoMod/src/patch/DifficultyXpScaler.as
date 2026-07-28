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
     *
     * This value is PLAYER-VISIBLE (outcome panel "Battle Traits Multiplier",
     * and difficultyBase() backs the map-tile tooltip), so nothing hidden may be
     * folded into it. The per-tile XP curve lives on the monsters' own xpBase
     * instead — see tileXpMultiplier() below and its consumer WavePrePatcher.
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
                // Pure per-difficulty base — NOTHING else is folded in here.
                //
                // The old starter/free-stage boost (max(2.0, difficultyBase))
                // was REMOVED: the per-tile XP curve now eases the cold start
                // (W x1.90, S x1.85, ...) invisibly and with finer control, so
                // the extra boost was redundant AND it compounded to an
                // effective 3.8x on starter fields.
                //
                // It also has to stay pure because traitsXpMult is
                // player-visible ("Battle Traits Multiplier" on the outcome
                // panel, IngameEnding.tfTraitsMultiplier) and difficultyBase()
                // is what the map-tile tooltip shows — the starter boost made
                // the two disagree (tooltip x1.50 vs in-battle x2.00 on Medium).
                // The XP curve is applied to the monsters' own xpBase instead;
                // see WavePrePatcher, which consumes tileXpMultiplier() below.
                sc.traitsXpMult.s(difficultyBase() + sum);
            } catch (e:Error) {}
        }

        /** Restore the vanilla battle-XP multiplier (base 1.0 + trait bonuses),
         *  dropping the per-difficulty AP scaling. Called on AP-mode teardown so
         *  a standalone/vanilla save loaded next never inherits AP XP scaling.
         *  Mirrors apply() with the vanilla 1.0 base instead of difficultyBase(). */
        public static function restoreVanilla():void {
            try {
                var sc:* = GV.selectorCore;
                if (sc == null || sc.traitsXpMult == null || GV.ppd == null)
                    return;

                var sum:Number = 0;
                var n:int = int(GV.BATTLE_TRAITS_NUM);
                for (var i:int = 0; i < n; i++) {
                    if (GV.ppd.gainedBattleTraits[i]) {
                        var lvl:int = int(GV.ppd.selectedBattleTraitLevels[i].g());
                        if (lvl > 0)
                            sum += 0.1 * lvl;
                    }
                }
                sc.traitsXpMult.s(1.0 + sum);
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

        /**
         * Hidden per-TILE XP-curve multiplier for the field currently being
         * played. This is what shapes real in-game progression to match the WL
         * curve the apworld gates on — early tiles worth far more, late tiles
         * cut hard so the endgame flattens instead of exploding.
         *
         * Source: the hand-authored mods/.../json/xp_curve.json, embedded at
         * compile time. py-scripts/apply_xp_curve.py reads the SAME file to bake
         * eff_xp / WL gates into the apworld, so the two curves cannot drift.
         *
         * CONSUMED BY WavePrePatcher, which scales each wave's monsterProto.xpBase
         * by this before the first wave spawns. It is deliberately NOT folded into
         * traitsXpMult — that value is shown to the player as the "Battle Traits
         * Multiplier", so putting the curve there exposed it (x3.80 on a starter
         * field) and misattributed it to battle traits.
         *
         * Returns 1.0 (vanilla) outside a battle, when the table is missing, or
         * for any tile with no entry — never blocks or zeroes XP.
         */
        public static function tileXpMultiplier():Number {
            try {
                if (GV.ingameCore == null || GV.ingameCore.stageMeta == null)
                    return 1.0;
                if (AV.serverData == null)
                    return 1.0;
                var tbl:Object = AV.serverData.tileXpMultiplier;
                if (tbl == null)
                    return 1.0;
                var sid:String = String(GV.ingameCore.stageMeta.strId);
                if (sid == null || sid.length == 0)
                    return 1.0;
                // Tile = the leading non-digit run of the stage id ("A4" -> "A").
                var tile:String = "";
                for (var i:int = 0; i < sid.length; i++) {
                    var c:String = sid.charAt(i);
                    if (c >= "0" && c <= "9")
                        break;
                    tile += c;
                }
                if (tile.length == 0)
                    return 1.0;
                var v:* = tbl[tile];
                if (v == null)
                    return 1.0;
                var n:Number = Number(v);
                return (n > 0) ? n : 1.0;
            } catch (e:Error) {}
            return 1.0;
        }

        // NOTE: _onStarterStage() was removed along with the starter/free-stage
        // XP boost — the per-tile XP curve (xp_curve.json, applied to monster
        // xpBase by WavePrePatcher) now handles easing the opening.
    }
}

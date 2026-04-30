package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import data.AV;

    /**
     * Strips ALL gem types from a Journey level when the player does not own
     * the Gempouch for that level's stage-prefix.
     *
     * Two vanilla paths populate `IngameCore.availableGemTypes`:
     *   1. IngameInitializer2 GIVEGT/SPELLS — the per-stage available_gems
     *      list from initScript.
     *   2. IngameInitializer2 lines 1208-1246 — the skill-unlock branch:
     *      any gem skill the player has selected is added on revisit.
     *
     * FirstPlayBypass also adds skill-unlock gems on first play. When the
     * pouch is missing we want NO gems at all from any source — so this
     * patcher must run after FirstPlayBypass each frame and wipe the array.
     *
     * Per-frame guard mirrors FirstPlayBypass: cache the array reference and
     * only re-process when the game replaces it (level restart / new stage).
     *
     * Inactive when gem_pouch_gating == 0 (off mode) or when the pouch for
     * the current stage's prefix is owned.
     */
    public class GemPouchSuppressor {

        private var _logger:Logger;
        private var _modName:String;

        // Tracks the availableGemTypes array reference we last processed —
        // when the game rebuilds it the reference changes and we re-scan.
        private var _lastSeenArray:Array = null;

        // arrIsSpellBtnVisible indices for the 6 gem-create button slots.
        // Mirrors IngameInitializer2 lines 1201/1214/1220/1226/1232/1238/1244
        // (gem type 0..5 → spellBtn slot 6..11).
        private static const GEM_SPELL_BTN_BASE:int = 6;
        private static const GEM_TYPE_COUNT:int     = 6;

        public function GemPouchSuppressor(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        /**
         * Called every ENTER_FRAME while screen == INGAME. Wipes
         * availableGemTypes and removes gem-create buttons when the player is
         * missing the pouch for the current stage's prefix. No-op on every
         * subsequent frame (until the game replaces the array on level exit).
         */
        public function onIngameFrame():void {
            try {
                if (AV.serverData == null || AV.serverData.serverOptions == null)
                    return;
                var mode:int = int(AV.serverData.serverOptions.gemPouchGating);
                if (mode == 0)
                    return; // off — no suppression

                if (GV.ingameCore == null || GV.ingameCore.stageMeta == null)
                    return;
                var stageStrId:String = String(GV.ingameCore.stageMeta.strId);
                if (stageStrId == null || stageStrId.length == 0)
                    return;

                var prefix:String = stageStrId.charAt(0);
                if (_hasPouchFor(prefix))
                    return; // pouch owned — let vanilla / FirstPlayBypass run

                var availableGemTypes:Array = GV.ingameCore.availableGemTypes;
                var cnt:* = GV.ingameCore.cnt;
                if (availableGemTypes == null || cnt == null)
                    return;

                if (_lastSeenArray === availableGemTypes && availableGemTypes.length == 0)
                    return; // already wiped this array instance

                var removed:int = _suppressGems(availableGemTypes, cnt);
                _lastSeenArray = availableGemTypes;

                if (removed > 0) {
                    _logger.log(_modName,
                        "GemPouchSuppressor: stage=" + stageStrId
                        + " prefix=" + prefix
                        + " removed=" + removed + " gem types (no pouch)");
                }
            } catch (err:Error) {
                _logger.log(_modName,
                    "GemPouchSuppressor.onIngameFrame ERROR: " + err.message);
            }
        }

        /** Reset cached array reference on level exit so the next ingame
         *  entry re-runs suppression against the freshly-built array. */
        public function resetIngame():void {
            _lastSeenArray = null;
        }

        // -----------------------------------------------------------------------
        // Helpers

        /** True when the player owns the pouch (or precollected copy) that
         *  unlocks gems for the given stage-prefix letter. */
        private function _hasPouchFor(prefix:String):Boolean {
            var opts:* = AV.serverData.serverOptions;
            var order:Array = opts.gemPouchPlayOrder as Array;
            if (order == null || order.length == 0)
                return true; // no order — fail open, don't strip gems
            var idx:int = order.indexOf(prefix);
            if (idx < 0)
                return true; // unknown prefix — fail open

            var mode:int = int(opts.gemPouchGating);
            if (mode == 1) {
                // Distinct: AP id 626 + index in play order.
                return AV.sessionData.hasItem(626 + idx);
            }
            // Progressive (mode == 2): need at least (idx + 1) copies of the
            // single Progressive Gempouch item.
            var progId:int = int(opts.gemPouchProgressiveId);
            if (progId <= 0)
                progId = 652;
            return AV.sessionData.getItemCount(progId) >= idx + 1;
        }

        /** Wipe availableGemTypes and remove all 6 gem-create buttons.
         *  Returns the number of gem types that were present before wiping. */
        private function _suppressGems(availableGemTypes:Array, cnt:*):int {
            var removed:int = availableGemTypes.length;

            // Empty the array in place — keeps the reference valid for any
            // other code holding a pointer to it.
            availableGemTypes.length = 0;

            // Remove every gem-create button from the ingame frame and
            // mark its spell-button slot invisible.
            var frame:* = cnt.mcIngameFrame;
            if (frame != null && frame.gemCreateButtons != null) {
                for (var gemType:int = 0; gemType < GEM_TYPE_COUNT; gemType++) {
                    var btn:* = frame.gemCreateButtons[gemType];
                    if (btn != null) {
                        try {
                            if (frame.contains(btn))
                                frame.removeChild(btn);
                        } catch (e:Error) {}
                    }
                    if (GV.ingameCore.arrIsSpellBtnVisible != null) {
                        GV.ingameCore.arrIsSpellBtnVisible[GEM_SPELL_BTN_BASE + gemType] = false;
                    }
                }
            }

            return removed;
        }
    }
}

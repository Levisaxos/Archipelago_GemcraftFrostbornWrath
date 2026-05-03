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
     * Inactive when gemPouchGranularity == 0 (off mode) or when the pouch for
     * the current stage's prefix is owned.
     */
    public class GemPouchSuppressor {

        private var _logger:Logger;
        private var _modName:String;

        // Tracks the availableGemTypes array reference we last processed —
        // when the game rebuilds it the reference changes and we re-scan.
        private var _lastSeenArray:Array = null;

        // Per-stage decision lock: -1 = not yet decided, 0 = let vanilla run
        // (pouch owned at level start), 1 = suppress (pouch missing at level
        // start). Set on the first frame with valid state, carried for the
        // rest of the stage, reset on stage exit. Without this, an AP-granted
        // Gempouch arriving mid-level would flip the decision: vanilla
        // mana-leech button would reappear alongside the Hollow Gem button,
        // and HollowGemInjector's combine-tracked colorless gems would lose
        // their pairing with the suppressed-state assumptions.
        private var _lockedSuppress:int = -1;

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
                if (!_shouldSuppressThisStage())
                    return;

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
                        "GemPouchSuppressor: removed=" + removed
                        + " gem types (no pouch at level start)");
                }
            } catch (err:Error) {
                _logger.log(_modName,
                    "GemPouchSuppressor.onIngameFrame ERROR: " + err.message);
            }
        }

        /** Reset cached array reference + decision lock on level exit so the
         *  next ingame entry re-runs suppression against the freshly-built
         *  array and re-evaluates pouch ownership for the new stage. */
        public function resetIngame():void {
            _lastSeenArray = null;
            _lockedSuppress = -1;
        }

        /** Snapshot the "should we suppress on this stage?" decision on the
         *  first frame with valid state, then keep returning the same answer
         *  for the rest of the level. Mid-level Gempouch acquisitions don't
         *  flip the decision — the next stage entry re-evaluates. */
        private function _shouldSuppressThisStage():Boolean {
            if (_lockedSuppress == 1) return true;
            if (_lockedSuppress == 0) return false;

            if (AV.serverData == null || AV.serverData.serverOptions == null)
                return false; // pre-init — wait, don't lock.
            var mode:int = int(AV.serverData.serverOptions.gemPouchGranularity);
            if (mode == 0) {
                _lockedSuppress = 0; // gating off for the seed — stable, lock.
                return false;
            }
            if (GV.ingameCore == null || GV.ingameCore.stageMeta == null)
                return false; // wait for stage data.
            var stageStrId:String = String(GV.ingameCore.stageMeta.strId);
            if (stageStrId == null || stageStrId.length == 0)
                return false;

            var suppress:Boolean = !_hasPouchFor(stageStrId);
            _lockedSuppress = suppress ? 1 : 0;
            return suppress;
        }

        // -----------------------------------------------------------------------
        // Helpers

        /** True when the player owns the pouch (or precollected copy) that
         *  unlocks gems for the given stage. Granularity-aware:
         *    mode 1 (per_tile):             Gempouch (<prefix>) item present
         *    mode 2 (per_tile_progressive): N copies of Progressive Gempouch
         *    mode 3 (per_tier):             Tier <N> Gempouch item present
         *    mode 4 (per_tier_progressive): N+1 copies of Progressive
         *                                    Gempouch (per-tier) where N is
         *                                    the stage's tier in ACTIVE_TIERS
         *    mode 5 (global):               Master Gempouch item present
         */
        private function _hasPouchFor(stageStrId:String):Boolean {
            var opts:* = AV.serverData.serverOptions;
            var mode:int = int(opts.gemPouchGranularity);
            var prefix:String = stageStrId.charAt(0);

            if (mode == 1) {
                // per_tile (distinct): canonical ID assignment via gemPouchPlayOrder.
                var orderD:Array = opts.gemPouchPlayOrder as Array;
                if (orderD == null || orderD.length == 0) return true;
                var idxD:int = orderD.indexOf(prefix);
                if (idxD < 0) return true;
                return AV.sessionData.hasItem(626 + idxD);
            }
            if (mode == 2) {
                // per_tile_progressive: starter-first count threshold.
                var orderP:Array = opts.progressiveTileOrder as Array;
                if (orderP == null || orderP.length == 0)
                    orderP = opts.gemPouchPlayOrder as Array;
                if (orderP == null || orderP.length == 0) return true;
                var idxP:int = orderP.indexOf(prefix);
                if (idxP < 0) return true;
                var progId:int = int(opts.gemPouchProgressiveId);
                if (progId <= 0) progId = 652;
                return AV.sessionData.getItemCount(progId) >= idxP + 1;
            }
            if (mode == 3) {
                // per_tier: AP id 1601 + tier (see gating.py POUCH_TIER_BASE).
                var tier:int = _tierForStage(stageStrId);
                if (tier < 0) return true;
                return AV.sessionData.hasItem(1601 + tier);
            }
            if (mode == 4) {
                // per_tier_progressive: Nth copy unlocks Nth tier in
                // progressiveTierOrder (starter's tier first).
                var tier4:int = _tierForStage(stageStrId);
                if (tier4 < 0) return true;
                var tierProgId:int = int(opts.gemPouchPerTierProgressiveId);
                if (tierProgId <= 0) return true;
                var tierOrd:Array = opts.progressiveTierOrder as Array;
                if (tierOrd != null && tierOrd.length > 0) {
                    var posT:int = tierOrd.indexOf(tier4);
                    if (posT < 0) return true;
                    return AV.sessionData.getItemCount(tierProgId) >= posT + 1;
                }
                // Fallback to natural ascending.
                return AV.sessionData.getItemCount(tierProgId) >= tier4 + 1;
            }
            if (mode == 5) {
                // global: AP id 1614 (see gating.py POUCH_MASTER_ID).
                return AV.sessionData.hasItem(1614);
            }
            return true;
        }

        /** Look up a stage's tier from slot_data; -1 if unknown. */
        private function _tierForStage(stageStrId:String):int {
            var map:Object = AV.serverData.serverOptions.stageTierByStrId;
            if (map == null || map[stageStrId] == null)
                return -1;
            return int(map[stageStrId]);
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

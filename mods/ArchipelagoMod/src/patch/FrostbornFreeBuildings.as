package patch {
    import Bezel.Logger;

    import com.giab.common.data.ENumber;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.GameMode;

    import data.AV;

    /**
     * Frostborn-mode bootstrap helper for the seed's starter stage.
     *
     * In Chilling mode, IngameInitializer.as:1570 grants 3 free buildings at
     * level start so the player can scaffold a defence before they have mana.
     * In Frostborn mode the counter stays at 0 (default from
     * IngameInitializer2.as:409) — fine for stages with multiple pre-placed
     * towers, but a stage with 0–2 towers and no pouch (so no normal gems) is
     * effectively unplayable.
     *
     * On the seed's starter stage, while the matching Gempouch is missing
     * (Hollow Gem mode active), we set:
     *
     *   freeBuildingsLeft = max(0, 3 - towers_pre-placed_on_stage)
     *
     * Counts towers only (core.towers.length on the first valid frame; pre-
     * placed towers exist by then and the player hasn't acted yet). Walls,
     * traps, amplifiers, lanterns, pylons are not counted — by design, so a
     * tower-light stage with many walls still gets the bootstrap.
     *
     * Activation gates (all must hold):
     *   - GameMode == FROSTBORN  (Chilling already gets its own 3 free)
     *   - Stage is in AV.serverData.freeStages (any stage in the starter set —
     *     a single stage at per_stage granularity, an entire tile or tier
     *     under per_tile / per_tier)
     *   - Gempouch covering that stage not owned (granularity-aware)
     *
     * Decision is snapshotted on the first frame with valid state (mirrors
     * HollowGemInjector / GemPouchSuppressor). Mid-level pouch arrival does
     * NOT revoke the free buildings — the player keeps them for the rest of
     * the level. Reset on stage exit.
     */
    public class FrostbornFreeBuildings {

        // Free-building cap when active (matches Chilling's ENumber(3) at
        // IngameInitializer.as:1570).
        private static const TARGET_TOTAL:int = 3;

        private var _logger:Logger;
        private var _modName:String;

        // True once we've set freeBuildingsLeft on the current stage. Reset
        // by resetIngame() on stage exit.
        private var _appliedThisStage:Boolean = false;

        public function FrostbornFreeBuildings(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        public function onIngameFrame():void {
            try {
                if (_appliedThisStage)
                    return;
                if (!_shouldApply())
                    return;

                var core:* = GV.ingameCore;
                var towers:Array = core.towers as Array;
                var towerCount:int = (towers != null) ? towers.length : 0;
                var free:int = TARGET_TOTAL - towerCount;
                if (free < 0) free = 0;

                core.freeBuildingsLeft = new ENumber(free);
                _appliedThisStage = true;

                _logger.log(_modName,
                    "FrostbornFreeBuildings: stage=" + String(core.stageMeta.strId)
                    + " towers=" + towerCount + " freeBuildingsLeft=" + free);
            } catch (err:Error) {
                _logger.log(_modName,
                    "FrostbornFreeBuildings.onIngameFrame ERROR: " + err.message);
            }
        }

        /** Reset on stage exit so the next stage entry re-evaluates. */
        public function resetIngame():void {
            _appliedThisStage = false;
        }

        // -----------------------------------------------------------------------
        // Activation gates

        private function _shouldApply():Boolean {
            if (GV.ingameCore == null || GV.ingameCore.stageMeta == null)
                return false;
            if (GV.ppd == null)
                return false;
            if (int(GV.ppd.gameMode) != GameMode.FROSTBORN)
                return false;
            if (AV.serverData == null || AV.serverData.serverOptions == null)
                return false;

            var stageStrId:String = String(GV.ingameCore.stageMeta.strId);
            if (stageStrId == null || stageStrId.length == 0)
                return false;

            var freeStages:Array = AV.serverData.freeStages as Array;
            if (freeStages == null || freeStages.length == 0)
                return false;
            // Starter set may span multiple stages under per_tile / per_tier.
            var inStarterSet:Boolean = false;
            for (var fi:int = 0; fi < freeStages.length; fi++) {
                if (String(freeStages[fi]) == stageStrId) {
                    inStarterSet = true;
                    break;
                }
            }
            if (!inStarterSet)
                return false;

            var opts:* = AV.serverData.serverOptions;
            var mode:int = int(opts.gemPouchGranularity);
            if (mode == 0)
                return false; // no gating → no Hollow Gem mode → no bootstrap.

            return !_hasPouchFor(stageStrId, opts);
        }

        private function _hasPouchFor(stageStrId:String, opts:*):Boolean {
            var mode:int = int(opts.gemPouchGranularity);
            var prefix:String = stageStrId.charAt(0);

            if (mode == 1 || mode == 2) {
                var order:Array = opts.gemPouchPlayOrder as Array;
                if (order == null || order.length == 0)
                    return true; // unknown — fail open.
                var idx:int = order.indexOf(prefix);
                if (idx < 0)
                    return true;
                if (mode == 1)
                    return AV.sessionData.hasItem(626 + idx);
                var progId:int = int(opts.gemPouchProgressiveId);
                if (progId <= 0)
                    progId = 652;
                return AV.sessionData.getItemCount(progId) >= idx + 1;
            }
            if (mode == 3) {
                var tierMap:Object = opts.stageTierByStrId;
                if (tierMap == null || tierMap[stageStrId] == null)
                    return true;
                return AV.sessionData.hasItem(1601 + int(tierMap[stageStrId]));
            }
            if (mode == 4) {
                return AV.sessionData.hasItem(1614);
            }
            return true;
        }
    }
}

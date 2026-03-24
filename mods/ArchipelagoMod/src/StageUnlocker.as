package {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;

    /**
     * Handles stage/tile unlock, lock, and visibility management.
     */
    public class StageUnlocker {

        private var _logger:Logger;
        private var _modName:String;

        public function StageUnlocker(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        /**
         * Make a stage available (Journey XP = 0) and reveal its map tile.
         * Refreshes the selector display if it is currently open.
         */
        public function unlockStage(stageStrId:String):void {
            if (GV.ppd == null) return;
            var stageId:int = GV.getFieldId(stageStrId);
            if (stageId < 0) {
                _logger.log(_modName, "unlockStage: unknown stage " + stageStrId);
                return;
            }
            GV.ppd.stageHighestXpsJourney[stageId].s(0);
            var tileIdx:int = 90 - stageStrId.charCodeAt(0);
            if (tileIdx >= 0 && tileIdx < GV.ppd.gainedMapTiles.length) {
                GV.ppd.gainedMapTiles[tileIdx] = true;
            }
            refreshSelectorIfOpen();
            _logger.log(_modName, "Stage unlocked: " + stageStrId);
        }

        /**
         * Lock a stage (Journey XP = -1).  Hides the map tile if no other
         * stage on the same tile is still unlocked.
         */
        public function lockStage(stageStrId:String):void {
            if (GV.ppd == null) return;
            var stageId:int = GV.getFieldId(stageStrId);
            if (stageId < 0) return;
            GV.ppd.stageHighestXpsJourney[stageId].s(-1);
            // Re-evaluate tile visibility.
            var letter:String = stageStrId.charAt(0);
            var tileIdx:int = 90 - letter.charCodeAt(0);
            if (tileIdx >= 0 && tileIdx < GV.ppd.gainedMapTiles.length) {
                var anyUnlocked:Boolean = false;
                var metas:Array = GV.stageCollection.stageMetas;
                for (var i:int = 0; i < metas.length; i++) {
                    var meta:* = metas[i];
                    if (meta != null && meta.strId.charAt(0) == letter
                            && GV.ppd.stageHighestXpsJourney[meta.id].g() >= 0) {
                        anyUnlocked = true;
                        break;
                    }
                }
                GV.ppd.gainedMapTiles[tileIdx] = anyUnlocked;
            }
            refreshSelectorIfOpen();
            _logger.log(_modName, "Stage locked: " + stageStrId);
        }

        /** Returns true if the stage's Journey XP >= 0 (available or completed). */
        public function isStageUnlocked(stageStrId:String):Boolean {
            if (GV.ppd == null) return false;
            var stageId:int = GV.getFieldId(stageStrId);
            if (stageId < 0) return false;
            return GV.ppd.stageHighestXpsJourney[stageId].g() >= 0;
        }

        /** Refreshes field-token and tile visibility on the selector if it is open. */
        public function refreshSelectorIfOpen():void {
            if (GV.selectorCore == null || GV.selectorCore.renderer == null) return;
            GV.selectorCore.renderer.setMapTilesVisibility();
            GV.selectorCore.renderer.adjustFieldTokens();
        }

        /**
         * Reveal the map tile for every stage whose Journey XP is already >= 0.
         * Called once per selector session.
         */
        public function syncMapTilesWithStages():void {
            if (GV.ppd == null || GV.stageCollection == null) return;
            var metas:Array = GV.stageCollection.stageMetas;
            for (var i:int = 0; i < metas.length; i++) {
                var meta:* = metas[i];
                if (meta == null) continue;
                if (GV.ppd.stageHighestXpsJourney[meta.id].g() >= 0) {
                    var tileIdx:int = 90 - meta.strId.charCodeAt(0);
                    if (tileIdx >= 0 && tileIdx < GV.ppd.gainedMapTiles.length) {
                        GV.ppd.gainedMapTiles[tileIdx] = true;
                    }
                }
            }
        }

        /**
         * Override the scroll limits to the full world extent every frame.
         *
         * setVpLimits() in SelectorCore has a hard-coded override that collapses
         * the scroll area to just the W tile whenever W4 Journey hasn't been
         * completed.  It is called both on selector open and whenever the event
         * queue processes a level-return, so a one-shot fix is not enough.
         *
         * The constants are the global-clamp values from setVpLimits() lines 1030-1033,
         * which represent the widest bounds the game ever allows:
         *   vpXMin = 264, vpXMax = 1864, vpYMin = 330, vpYMax = 3712
         */
        public function enforceFullWorldScrollLimits():void {
            GV.selectorCore.vpXMin = 200 + 104 - 40 - 544 + 960 - 416;  // 264
            GV.selectorCore.vpXMax = 1400 - 408 + 40 - 544 + 960 + 416; // 1864
            GV.selectorCore.vpYMin = 0 + 61 - 40 + 115 - 40 - 306 + 540; // 330
            GV.selectorCore.vpYMax = 3300 - 306 + 540 + 178;              // 3712
        }
    }
}

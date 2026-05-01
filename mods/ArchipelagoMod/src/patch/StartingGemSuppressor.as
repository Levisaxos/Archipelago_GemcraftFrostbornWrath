package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.BattleMode;

    /**
     * Strips PUTGEM and CREGEM entries from the current Journey stage's
     * initScript before IngameInitializer2.runInitScript reads it. This kills
     * pre-placed starting gems at the source — IngameCreator.createGem is
     * never called for them, they never enter core.gems[], and the inline
     * spentManaOn*Gem markers in runInitScript do not fire either.
     *
     * Timing: runInitScript is called from IngameInitializer.start() inside
     * setScene2, which is reached during TRANS_SELECTOR_TO_INGAME2. Hooking
     * applyIfReady on TRANS_SELECTOR_TO_INGAME1 entry guarantees we mutate
     * the array before it is read.
     *
     * Reference-equality cache: the H-flip / V-flip path in
     * Main.switchScreenVisibility clones stageData (StageData.clone uses
     * initScript.concat()), giving a fresh array reference. Calling
     * applyIfReady again on TRANS_SELECTOR_TO_INGAME2 catches that case —
     * the cache check sees a new reference and re-filters.
     */
    public class StartingGemSuppressor {

        private var _logger:Logger;
        private var _modName:String;

        private var _lastSeenScript:Array = null;

        public function StartingGemSuppressor(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        public function applyIfReady():void {
            try {
                if (GV.ingameCore == null)
                    return;
                if (GV.ingameCore.battleMode != BattleMode.JOURNEY)
                    return;
                if (GV.ingameCore.stageData == null)
                    return;
                var script:Array = GV.ingameCore.stageData.initScript as Array;
                if (script == null)
                    return;
                if (_lastSeenScript === script)
                    return;

                var removed:int = _stripStartingGems(script);
                _lastSeenScript = script;

                if (removed > 0) {
                    var stageStrId:String = GV.ingameCore.stageMeta != null
                        ? String(GV.ingameCore.stageMeta.strId)
                        : "?";
                    _logger.log(_modName,
                        "StartingGemSuppressor: stripped " + removed
                        + " PUTGEM/CREGEM entries from " + stageStrId);
                }
            } catch (err:Error) {
                _logger.log(_modName,
                    "StartingGemSuppressor.applyIfReady ERROR: " + err.message);
            }
        }

        public function resetForNewStage():void {
            _lastSeenScript = null;
        }

        private function _stripStartingGems(script:Array):int {
            var removed:int = 0;
            for (var i:int = script.length - 1; i >= 0; i--) {
                var cmd:String = String(script[i]);
                if (cmd.indexOf("PUTGEM,") == 0 || cmd.indexOf("CREGEM,") == 0) {
                    script.splice(i, 1);
                    removed++;
                }
            }
            return removed;
        }
    }
}

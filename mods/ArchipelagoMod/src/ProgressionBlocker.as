package {
    import Bezel.Bezel;
    import Bezel.Logger;
    import Bezel.GCFW.Events.EventTypes;

    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.DropType;

    /**
     * Intercepts the SAVE_SAVE event after every level victory and reverts any
     * automatic field-token, map-tile, skill-tome, and battle-trait unlocks that
     * the game wrote to PlayerProgressData.  The save file is immediately
     * overwritten so the reverted state is persisted.
     *
     * Archipelago will later send the correct items; this class just ensures the
     * game cannot hand them out on its own.
     */
    public class ProgressionBlocker {

        private var _logger:Logger;
        private var _modName:String;
        private var _bezel:Bezel;
        private var _isSaving:Boolean = false;

        public function ProgressionBlocker(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
        }

        // -----------------------------------------------------------------------
        // Lifecycle

        /** Attach to the Bezel event bus. Call from ArchipelagoMod.bind(). */
        public function enable(bezel:Bezel):void {
            _bezel = bezel;
            _bezel.addEventListener(EventTypes.SAVE_SAVE, onSaveSave);
        }

        /** Detach from the Bezel event bus. Call from ArchipelagoMod.unload(). */
        public function disable():void {
            if (_bezel != null) {
                _bezel.removeEventListener(EventTypes.SAVE_SAVE, onSaveSave);
                _bezel = null;
            }
        }

        // -----------------------------------------------------------------------
        // Save hook

        private function onSaveSave(e:*):void {
            if (_isSaving) return;
            try {
                if (GV.ingameController == null || GV.ingameController.core == null) return;
                var ending:* = GV.ingameController.core.ending;
                if (ending == null || !ending.isBattleWon) return;
                var drops:Array = ending.dropIcons;
                if (drops == null || drops.length == 0) return;

                var reverted:int = 0;
                for (var i:int = 0; i < drops.length; i++) {
                    var di:* = drops[i];
                    if (di == null) continue;
                    switch (di.type) {
                        case DropType.FIELD_TOKEN:
                            GV.ppd.stageHighestXpsJourney[Number(di.data)].s(-1);
                            reverted++;
                            _logger.log(_modName, "Blocked stage unlock id=" + di.data);
                            break;
                        case DropType.MAP_TILE:
                            GV.ppd.gainedMapTiles[Number(di.data)] = false;
                            reverted++;
                            _logger.log(_modName, "Blocked map tile id=" + di.data);
                            break;
                        case DropType.SKILL_TOME:
                            GV.ppd.gainedSkillTomes[Number(di.data)] = false;
                            reverted++;
                            _logger.log(_modName, "Blocked skill tome id=" + di.data);
                            break;
                        case DropType.BATTLETRAIT_SCROLL:
                            GV.ppd.gainedBattleTraits[Number(di.data)] = false;
                            reverted++;
                            _logger.log(_modName, "Blocked battle trait id=" + di.data);
                            break;
                    }
                }

                if (reverted > 0) {
                    // Strip pending TOKEN_APPEARING (0) and MAP_TILE_APPEARING (1)
                    // events from the selector queue so no unlock animation plays on return.
                    var queue:Array = GV.selectorCore.eventQueue;
                    for (var j:int = queue.length - 1; j >= 0; j--) {
                        var evt:* = queue[j];
                        if (evt != null && (evt.type == 0 || evt.type == 1)) {
                            queue.splice(j, 1);
                        }
                    }
                    _isSaving = true;
                    GV.loaderSaver.saveGameData();
                    _isSaving = false;
                    _logger.log(_modName, "Blocked " + reverted + " progression drop(s), save overwritten");
                }
            } catch (err:Error) {
                _isSaving = false;
                _logger.log(_modName, "ProgressionBlocker.onSaveSave ERROR: " + err.message + "\n" + err.getStackTrace());
            }
        }
    }
}

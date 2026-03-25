package {
    import Bezel.Bezel;
    import Bezel.Logger;
    import Bezel.GCFW.Events.EventTypes;

    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.DropType;

    /**
     * Intercepts the SAVE_SAVE event and reverts any automatic field-token,
     * map-tile, skill-tome, and battle-trait unlocks that the game wrote to
     * PlayerProgressData.  The save file is immediately overwritten so the
     * reverted state is persisted.
     *
     * Archipelago will later send the correct items; this class just ensures the
     * game cannot hand them out on its own.
     *
     * The class tracks which skills and traits AP has actually granted via
     * markSkillGranted / markTraitGranted.  On every save (including wizard-stash
     * clears that happen outside of battle) it enforces AP authority: any
     * skill tome or battle trait that is set in the save data but was NOT granted
     * by AP is immediately reverted.
     */
    public class NormalProgressionBlocker {

        private var _logger:Logger;
        private var _modName:String;
        private var _bezel:Bezel;
        private var _isSaving:Boolean = false;

        // Tracks which skills / traits AP has granted (by game index).
        private var _apGrantedSkills:Array; // Boolean[24]
        private var _apGrantedTraits:Array; // Boolean[15]

        public function NormalProgressionBlocker(logger:Logger, modName:String) {
            _logger  = logger;
            _modName = modName;
            _apGrantedSkills = new Array(24);
            _apGrantedTraits = new Array(15);
            for (var i:int = 0; i < 24; i++) _apGrantedSkills[i] = false;
            for (var j:int = 0; j < 15; j++) _apGrantedTraits[j] = false;
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
        // AP grant tracking

        /** Call at the start of a full AP sync to clear the previous grant state. */
        public function resetGrants():void {
            for (var i:int = 0; i < 24; i++) _apGrantedSkills[i] = false;
            for (var j:int = 0; j < 15; j++) _apGrantedTraits[j] = false;
        }

        /** Mark a skill as AP-granted so it will not be reverted on saves. */
        public function markSkillGranted(gameId:int):void {
            if (gameId >= 0 && gameId < 24) _apGrantedSkills[gameId] = true;
        }

        /** Mark a battle trait as AP-granted so it will not be reverted on saves. */
        public function markTraitGranted(gameId:int):void {
            if (gameId >= 0 && gameId < 15) _apGrantedTraits[gameId] = true;
        }

        // -----------------------------------------------------------------------
        // Save hook

        private function onSaveSave(e:*):void {
            if (_isSaving) return;
            try {
                var reverted:int = 0;

                // --- Battle-victory drops (field tokens, map tiles, in-battle tomes) ---
                if (GV.ingameController != null && GV.ingameController.core != null) {
                    var ending:* = GV.ingameController.core.ending;
                    if (ending != null && ending.isBattleWon) {
                        var drops:Array = ending.dropIcons;
                        if (drops != null) {
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
                                }
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
                        }
                    }
                }

                // --- Enforce AP authority over skills and traits on every save ---
                // This catches wizard-stash clears (and any other source) that grant
                // skill tomes or battle traits outside of a normal battle victory.
                if (GV.ppd != null) {
                    for (var s:int = 0; s < 24; s++) {
                        if (GV.ppd.gainedSkillTomes[s] && !_apGrantedSkills[s]) {
                            GV.ppd.gainedSkillTomes[s] = false;
                            GV.ppd.setSkillLevel(s, -1);
                            reverted++;
                            _logger.log(_modName, "Blocked non-AP skill tome gameId=" + s);
                        }
                    }
                    for (var t:int = 0; t < 15; t++) {
                        if (GV.ppd.gainedBattleTraits[t] && !_apGrantedTraits[t]) {
                            GV.ppd.gainedBattleTraits[t] = false;
                            reverted++;
                            _logger.log(_modName, "Blocked non-AP battle trait gameId=" + t);
                        }
                    }
                }

                if (reverted > 0) {
                    _isSaving = true;
                    GV.loaderSaver.saveGameData();
                    _isSaving = false;
                    _logger.log(_modName, "Blocked " + reverted + " progression item(s), save overwritten");
                }
            } catch (err:Error) {
                _isSaving = false;
                _logger.log(_modName, "NormalProgressionBlocker.onSaveSave ERROR: " + err.message + "\n" + err.getStackTrace());
            }
        }
    }
}

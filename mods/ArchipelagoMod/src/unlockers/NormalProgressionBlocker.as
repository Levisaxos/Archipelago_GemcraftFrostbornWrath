package unlockers {
    import Bezel.Bezel;
    import Bezel.Logger;
    import Bezel.GCFW.Events.EventTypes;

    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.DropType;
    import com.giab.games.gcfw.entity.TalismanFragment;

    /**
     * Intercepts the SAVE_SAVE event and reverts any automatic field-token,
     * map-tile, skill-tome, battle-trait, shadow-core, and talisman-fragment
     * unlocks that the game wrote to PlayerProgressData.  The save file is
     * immediately overwritten so the reverted state is persisted.
     *
     * Archipelago will later send the correct items; this class just ensures the
     * game cannot hand them out on its own.
     *
     * The class tracks which skills and traits AP has actually granted via
     * markSkillGranted / markTraitGranted.  On every save (including wizard-stash
     * clears that happen outside of battle) it enforces AP authority: any
     * skill tome or battle trait that is set in the save data but was NOT granted
     * by AP is immediately reverted.
     *
     * For wizard stashes specifically, shadow cores and talisman fragments in
     * stashDrops are also blocked: when a stash is detected as newly cleared
     * (OPEN or DESTROYED), its SC{n} shadow-core grant is subtracted and the
     * talisman fragment with the matching seed is removed from the inventory.
     */
    public class NormalProgressionBlocker {

        private var _logger:Logger;
        private var _modName:String;
        private var _bezel:Bezel;
        private var _isSaving:Boolean = false;

        // Tracks which skills / traits AP has granted (by game index).
        private var _apGrantedSkills:Array; // Boolean[24]
        private var _apGrantedTraits:Array; // Boolean[15]

        // Wiz stash blocking: str_id → "seed/rarity/type/upgradeLevel"
        // Set once on AP connect via setWizStashTalData().
        private var _wizStashTalData:Object = null;

        // Tracks which stage IDs have had their stash rewards blocked already
        // so we don't double-subtract on subsequent saves.
        private var _stashBlockedIds:Object = {}; // stageId (int key) → true

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

        /**
         * Provide the wiz stash talisman data map (str_id → "seed/rarity/type/upgradeLevel")
         * from slot_data so the blocker knows which fragment seed to remove per stage.
         * Also resets _stashBlockedIds so prior blocks are re-evaluated for the new slot.
         */
        public function setWizStashTalData(map:Object):void {
            _wizStashTalData = map;
            _stashBlockedIds = {};
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

                // --- Block shadow cores and talisman fragments from wizard stashes ---
                if (GV.ppd != null && GV.stageCollection != null && _wizStashTalData != null) {
                    var metas:Array = GV.stageCollection.stageMetas;
                    for (var m:int = 0; m < metas.length; m++) {
                        var meta:* = metas[m];
                        if (meta == null) continue;
                        var stageId:int    = int(meta.id);
                        var stashStatus:int = int(GV.ppd.stageWizStashStauses[stageId]);
                        // Only process newly-cleared stashes (OPEN=1 or DESTROYED=2).
                        if (stashStatus == 0) continue;
                        if (_stashBlockedIds[stageId]) continue;

                        var strId:String   = String(meta.strId);
                        var stashDrops:String = String(meta.stashDrops);
                        var parts:Array    = stashDrops.split("+");
                        var stashReverted:int = 0;

                        for (var p:int = 0; p < parts.length; p++) {
                            var drop:String = String(parts[p]);

                            // Shadow cores: "SC{amount}"
                            if (drop.indexOf("SC") == 0) {
                                var scAmount:int = int(drop.substring(2));
                                if (scAmount > 0) {
                                    var currentSC:Number = GV.ppd.shadowCoreAmount.g();
                                    GV.ppd.shadowCoreAmount.s(Math.max(0, currentSC - scAmount));
                                    reverted++;
                                    stashReverted++;
                                    _logger.log(_modName, "Blocked stash SC grant stage=" + strId
                                        + " amount=" + scAmount);
                                }
                            }

                            // Talisman fragment: "TAL" (actual seed from wizStashTalData)
                            if (drop == "TAL") {
                                var talData:* = _wizStashTalData[strId];
                                if (talData != null) {
                                    var talParts:Array = String(talData).split("/");
                                    if (talParts.length >= 1) {
                                        var seed:int = int(talParts[0]);
                                        if (removeTalismanBySeed(seed)) {
                                            reverted++;
                                            stashReverted++;
                                            _logger.log(_modName, "Blocked stash TAL grant stage=" + strId
                                                + " seed=" + seed);
                                        }
                                    }
                                }
                            }
                        }

                        if (stashReverted > 0) {
                            _stashBlockedIds[stageId] = true;
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

        // -----------------------------------------------------------------------
        // Helpers

        /**
         * Remove the first talisman fragment with the given seed from the inventory.
         * Returns true if a fragment was found and removed.
         */
        private function removeTalismanBySeed(seed:int):Boolean {
            if (GV.ppd == null) return false;
            var inv:Array = GV.ppd.talismanInventory;
            if (inv == null) return false;
            for (var i:int = 0; i < inv.length; i++) {
                var frag:* = inv[i];
                if (frag != null && TalismanFragment(frag).seed == seed) {
                    inv[i] = null;
                    return true;
                }
            }
            return false;
        }
    }
}

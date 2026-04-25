package patch {
    import Bezel.Bezel;
    import Bezel.Logger;
    import Bezel.GCFW.Events.EventTypes;

    import com.giab.games.gcfw.GV;
    import com.giab.games.gcfw.constants.DropType;
    import com.giab.games.gcfw.entity.TalismanFragment;

    /**
     * Intercepts SAVE_SAVE and reverts any automatic field-token, map-tile,
     * skill-tome, battle-trait, shadow-core, and talisman-fragment unlocks
     * that the game wrote to PlayerProgressData. The save file is immediately
     * overwritten so the reverted state is persisted.
     */
    public class ProgressionBlocker {

        // Drop-type constants used to identify AP rewards queued during a battle.
        // Referenced externally by AchievementUnlocker.
        public static const AP_ACHIEVEMENT_COLLECTED:String  = "AP_ACHIEVEMENT_COLLECTED";
        public static const AP_ACHIEVEMENT_SKILL:String      = "AP_ACHIEVEMENT_SKILL";
        public static const AP_ACHIEVEMENT_TRAIT:String      = "AP_ACHIEVEMENT_TRAIT";
        public static const AP_ACHIEVEMENT_TALISMAN:String   = "AP_ACHIEVEMENT_TALISMAN";
        public static const AP_ACHIEVEMENT_SHADOWCORE:String = "AP_ACHIEVEMENT_SHADOWCORE";
        public static const AP_STASH_TALISMAN:String         = "AP_STASH_TALISMAN";
        public static const AP_STASH_SHADOWCORE:String       = "AP_STASH_SHADOWCORE";
        public static const AP_ITEM_FOR_US:String            = "AP_ITEM_FOR_US";
        public static const AP_ITEM_FOR_OTHER:String         = "AP_ITEM_FOR_OTHER";

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
        private var _stashBlockedIds:Object = {};

        public function ProgressionBlocker(logger:Logger, modName:String) {
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
        // Per-frame drop suppression

        /**
         * Call every frame. Clears ending.dropIcons as items are collected so the
         * victory screen finds an empty array and displays nothing. Data effects
         * for known drop types are reverted immediately; unknown types are logged.
         */
        public function tickDropIcons():void {
            if (GV.ingameController == null || GV.ingameController.core == null) return;
            var ending:* = GV.ingameController.core.ending;
            if (ending == null) return;
            var drops:Array = ending.dropIcons;
            if (drops == null || drops.length == 0) return;

            for (var i:int = 0; i < drops.length; i++) {
                var di:* = drops[i];
                if (di == null) continue;
                switch (di.type) {
                    case DropType.FIELD_TOKEN:
                        if (GV.ppd != null)
                            GV.ppd.stageHighestXpsJourney[Number(di.data)].s(-1);
                        _logger.log(_modName, "tickDropIcons: blocked FIELD_TOKEN id=" + di.data);
                        break;
                    case DropType.MAP_TILE:
                        if (GV.ppd != null)
                            GV.ppd.gainedMapTiles[Number(di.data)] = false;
                        _logger.log(_modName, "tickDropIcons: blocked MAP_TILE id=" + di.data);
                        break;
                    default:
                        _logger.log(_modName, "tickDropIcons: suppressed drop type=" + di.type + " data=" + di.data);
                        break;
                }
            }
            drops.splice(0, drops.length);
        }

        // -----------------------------------------------------------------------
        // Save hook

        private function onSaveSave(e:*):void {
            if (_isSaving) return;
            try {
                var reverted:int = 0;

                // --- Battle-victory drops (field tokens, map tiles) ---
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
                var skillReverted:Boolean = false;
                if (GV.ppd != null) {
                    for (var s:int = 0; s < 24; s++) {
                        if (GV.ppd.gainedSkillTomes[s] && !_apGrantedSkills[s]) {
                            GV.ppd.gainedSkillTomes[s] = false;
                            GV.ppd.setSkillLevel(s, -1);
                            reverted++;
                            skillReverted = true;
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
                if (skillReverted) removePlusNodeFromSelector("mcPlusNodeSkills");

                // --- Block shadow cores and talisman fragments from wizard stashes ---
                if (GV.ppd != null && GV.stageCollection != null && _wizStashTalData != null) {
                    var metas:Array = GV.stageCollection.stageMetas;
                    for (var m:int = 0; m < metas.length; m++) {
                        var meta:* = metas[m];
                        if (meta == null) continue;
                        var stageId:int     = int(meta.id);
                        var stashStatus:int = int(GV.ppd.stageWizStashStauses[stageId]);
                        if (stashStatus == 0) continue;
                        if (_stashBlockedIds[stageId]) continue;

                        var strId:String      = String(meta.strId);
                        var stashDrops:String = String(meta.stashDrops);
                        var parts:Array       = stashDrops.split("+");
                        var stashReverted:int = 0;

                        for (var p:int = 0; p < parts.length; p++) {
                            var drop:String = String(parts[p]);

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
                            removePlusNodeFromSelector("mcPlusNodeTalisman");
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
                _logger.log(_modName, "ProgressionBlocker.onSaveSave ERROR: " + err.message + "\n" + err.getStackTrace());
            }
        }

        // -----------------------------------------------------------------------
        // Private helpers

        private function removePlusNodeFromSelector(nodeName:String):void {
            try {
                var mc:* = GV.selectorCore != null ? GV.selectorCore.mc : null;
                if (mc == null) return;
                var node:* = mc[nodeName];
                if (node != null && mc.contains(node)) {
                    mc.removeChild(node);
                    _logger.log(_modName, "Removed " + nodeName + " (suppressed non-AP gain)");
                }
            } catch (err:Error) {
                _logger.log(_modName, "removePlusNodeFromSelector " + nodeName + " error: " + err.message);
            }
        }

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

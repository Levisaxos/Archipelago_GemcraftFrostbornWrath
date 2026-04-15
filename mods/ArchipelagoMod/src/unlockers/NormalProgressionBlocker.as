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
     * Instead of immediately calling unlockers, queues AP rewards to dropIcons
     * via custom drop types (AP_ACHIEVEMENT_*, AP_STASH_*). These are processed
     * together at level end via processApDropIcons().
     */
    public class NormalProgressionBlocker {

        // Custom drop types for AP rewards (to be processed at level end)
        public static const AP_ACHIEVEMENT_COLLECTED:String = "AP_ACHIEVEMENT_COLLECTED";
        public static const AP_ACHIEVEMENT_SKILL:String = "AP_ACHIEVEMENT_SKILL";
        public static const AP_ACHIEVEMENT_TRAIT:String = "AP_ACHIEVEMENT_TRAIT";
        public static const AP_ACHIEVEMENT_TALISMAN:String = "AP_ACHIEVEMENT_TALISMAN";
        public static const AP_ACHIEVEMENT_SHADOWCORE:String = "AP_ACHIEVEMENT_SHADOWCORE";
        public static const AP_STASH_TALISMAN:String = "AP_STASH_TALISMAN";
        public static const AP_STASH_SHADOWCORE:String = "AP_STASH_SHADOWCORE";

        // Items received from AP (to display on ending screen)
        public static const AP_ITEM_FOR_US:String = "AP_ITEM_FOR_US";           // Item sent to us
        public static const AP_ITEM_FOR_OTHER:String = "AP_ITEM_FOR_OTHER";     // Item sent to another player

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

        // References to unlockers for dropIcons processor
        private var _achievementUnlocker:*;
        private var _skillUnlocker:*;
        private var _traitUnlocker:*;
        private var _talismanUnlocker:*;
        private var _shadowCoreUnlocker:*;

        // Track items received during this level (to display on ending screen)
        private var _itemsReceivedThisLevel:Array = [];  // Array of {apId, itemName, sentTo, isForUs}

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

        /** Clear the items received in this level (call at level start). */
        public function clearReceivedItems():void {
            _itemsReceivedThisLevel = [];
        }

        /**
         * Add an AP item directly to the ending screen's dropIcons if it is still active.
         * Call from grantItem() for items that arrive after onSaveSave() has already run —
         * the Flash ending object stays live until dismissed, so adding here still renders.
         */
        public function addItemToActiveEndingScreen(apId:int, itemName:String, isForUs:Boolean = true):void {
            try {
                if (GV.ingameController == null || GV.ingameController.core == null) return;
                var ending:* = GV.ingameController.core.ending;
                if (ending == null || ending.dropIcons == null || !ending.isBattleWon) return;
                var dropType:String = isForUs ? AP_ITEM_FOR_US : AP_ITEM_FOR_OTHER;
                addApDropToIcons(ending, dropType, apId, {itemName: itemName, sentTo: "You"});
                _logger.log(_modName, "addItemToActiveEndingScreen: " + itemName + " (AP ID " + apId + ")");
            } catch (err:Error) {
                _logger.log(_modName, "addItemToActiveEndingScreen ERROR: " + err.message);
            }
        }

        /** Track an item received from AP (to display on ending screen). */
        public function trackReceivedItem(apId:int, itemName:String = "", sentToPlayer:String = "You", isForUs:Boolean = true):void {
            if (itemName == "") {
                itemName = "Item " + apId;  // Fallback name
            }
            _itemsReceivedThisLevel.push({
                apId: apId,
                itemName: itemName,
                sentTo: sentToPlayer,
                isForUs: isForUs
            });
            _logger.log(_modName, "TRACKED ITEM: " + itemName + " (AP ID " + apId + ")");
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

        /**
         * Set references to the unlockers for dropIcons processor.
         * Called from ArchipelagoMod after all unlockers are initialized.
         */
        public function setUnlockers(
            achievementUnlocker:*,
            skillUnlocker:*,
            traitUnlocker:*,
            talismanUnlocker:*,
            shadowCoreUnlocker:*
        ):void {
            _achievementUnlocker = achievementUnlocker;
            _skillUnlocker = skillUnlocker;
            _traitUnlocker = traitUnlocker;
            _talismanUnlocker = talismanUnlocker;
            _shadowCoreUnlocker = shadowCoreUnlocker;
        }

        // -----------------------------------------------------------------------
        // dropIcons helpers

        /**
         * Add an AP reward drop to the dropIcons array for later processing.
         * Creates a custom drop object with type, data (apId), and metadata.
         */
        public static function addApDropToIcons(ending:Object, dropType:String, apId:int, meta:Object = null):void {
            if (ending == null || ending.dropIcons == null) return;
            var drop:Object = {
                type: dropType,
                data: apId,
                meta: meta || {}
            };
            ending.dropIcons.push(drop);
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
                // If any skill tomes were reverted, suppress the '+' indicator on btnSkills.
                if (skillReverted) removePlusNodeFromSelector("mcPlusNodeSkills");

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
                            removePlusNodeFromSelector("mcPlusNodeTalisman");
                        }
                    }
                }

                // --- Populate dropIcons with items received from AP ---
                if (GV.ingameController != null && GV.ingameController.core != null) {
                    var endingForProcessor:* = GV.ingameController.core.ending;
                    if (endingForProcessor != null && endingForProcessor.dropIcons != null) {
                        _logger.log(_modName, "Items tracked this level: " + _itemsReceivedThisLevel.length);

                        // Add tracked AP items to dropIcons so the ending screen displays them
                        for (var r:int = 0; r < _itemsReceivedThisLevel.length; r++) {
                            var item:Object = _itemsReceivedThisLevel[r];
                            if (item != null) {
                                var dropType:String = item.isForUs ? AP_ITEM_FOR_US : AP_ITEM_FOR_OTHER;
                                addApDropToIcons(endingForProcessor, dropType, item.apId, {
                                    itemName: item.itemName,
                                    sentTo: item.sentTo
                                });
                                _logger.log(_modName, "Added drop to icons: " + item.itemName);
                            }
                        }

                        _logger.log(_modName, "Total drops in dropIcons before processor: " + endingForProcessor.dropIcons.length);

                        // Process all AP drops (including newly added items)
                        if (endingForProcessor.dropIcons.length > 0) {
                            processApDropIcons(endingForProcessor, {
                                achievementUnlocker: _achievementUnlocker,
                                skillUnlocker: _skillUnlocker,
                                traitUnlocker: _traitUnlocker,
                                talismanUnlocker: _talismanUnlocker,
                                shadowCoreUnlocker: _shadowCoreUnlocker
                            });
                        }

                        _logger.log(_modName, "Total drops in dropIcons after processor: " + endingForProcessor.dropIcons.length);

                        // NOTE: Don't clear tracked items here - they may arrive after onSaveSave().
                        // Items will be cleared when the next level starts or after they're displayed.
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
        // dropIcons processor

        /**
         * Process all AP reward drops from ending.dropIcons and call the appropriate unlocker.
         * Removes all non-AP drops from dropIcons to prevent them from being saved.
         * Called at the end of onSaveSave() after reverting non-AP drops.
         *
         * Expects unlockerRefs object with:
         *   - achievementUnlocker: AchievementUnlocker
         *   - skillUnlocker: SkillUnlocker
         *   - traitUnlocker: TraitUnlocker
         *   - talismanUnlocker: TalismanUnlocker
         *   - shadowCoreUnlocker: ShadowCoreUnlocker
         */
        public static function processApDropIcons(ending:Object, unlockerRefs:Object):void {
            if (ending == null || ending.dropIcons == null) return;

            var drops:Array = ending.dropIcons;
            var apDropsToKeep:Array = []; // Only keep AP drops

            for (var i:int = 0; i < drops.length; i++) {
                var drop:Object = drops[i];
                if (drop == null) continue;

                var isApDrop:Boolean = false;

                try {
                    switch (drop.type) {
                        case AP_ACHIEVEMENT_COLLECTED:
                            // Mark achievement collected and send location check
                            if (unlockerRefs.achievementUnlocker != null) {
                                unlockerRefs.achievementUnlocker.markCollectedAndSendCheck(drop.data);
                            }
                            isApDrop = true;
                            break;

                        case AP_ACHIEVEMENT_SKILL:
                            // Award skill points and unlock skill
                            if (unlockerRefs.achievementUnlocker != null && unlockerRefs.skillUnlocker != null) {
                                var achName:String = drop.meta.achievementName || "";
                                unlockerRefs.achievementUnlocker.awardSkillPointsPublic(achName, drop.meta.achievementData);
                                unlockerRefs.skillUnlocker.unlockSkill(drop.data);
                            }
                            isApDrop = true;
                            break;

                        case AP_ACHIEVEMENT_TRAIT:
                            // Award skill points and unlock trait
                            if (unlockerRefs.achievementUnlocker != null && unlockerRefs.traitUnlocker != null) {
                                unlockerRefs.achievementUnlocker.awardSkillPointsPublic(drop.meta.achievementName || "", drop.meta.achievementData);
                                unlockerRefs.traitUnlocker.unlockBattleTrait(drop.data);
                            }
                            isApDrop = true;
                            break;

                        case AP_ACHIEVEMENT_TALISMAN:
                            // Award skill points and grant talisman
                            if (unlockerRefs.achievementUnlocker != null && unlockerRefs.talismanUnlocker != null) {
                                unlockerRefs.achievementUnlocker.awardSkillPointsPublic(drop.meta.achievementName || "", drop.meta.achievementData);
                                unlockerRefs.talismanUnlocker.grantFragment(drop.data);
                            }
                            isApDrop = true;
                            break;

                        case AP_ACHIEVEMENT_SHADOWCORE:
                            // Award skill points and grant shadow cores
                            if (unlockerRefs.achievementUnlocker != null && unlockerRefs.shadowCoreUnlocker != null) {
                                unlockerRefs.achievementUnlocker.awardSkillPointsPublic(drop.meta.achievementName || "", drop.meta.achievementData);
                                unlockerRefs.shadowCoreUnlocker.grantShadowCores(drop.data);
                            }
                            isApDrop = true;
                            break;

                        case AP_STASH_TALISMAN:
                            // Grant talisman from stash
                            if (unlockerRefs.talismanUnlocker != null) {
                                unlockerRefs.talismanUnlocker.grantFragment(drop.data);
                            }
                            isApDrop = true;
                            break;

                        case AP_STASH_SHADOWCORE:
                            // Grant shadow cores from stash
                            if (unlockerRefs.shadowCoreUnlocker != null) {
                                unlockerRefs.shadowCoreUnlocker.grantShadowCores(drop.data);
                            }
                            isApDrop = true;
                            break;

                        case AP_ITEM_FOR_US:
                            // Item received for us - keep it for display on ending screen
                            isApDrop = true;
                            break;

                        case AP_ITEM_FOR_OTHER:
                            // Item received but sent to another player - keep it for display on ending screen
                            isApDrop = true;
                            break;

                        default:
                            // Game drop (skill tome, trait, field token, map tile, etc.) - don't keep it
                            isApDrop = false;
                            break;
                    }
                } catch (err:Error) {
                    // Error processing drop - treat as non-AP drop
                    isApDrop = false;
                }

                // Only keep AP drops in the array (game drops will be discarded)
                if (isApDrop) {
                    apDropsToKeep.push(drop);
                }
            }

            // Replace dropIcons array with only AP drops (effectively removing game drops)
            ending.dropIcons = apDropsToKeep;
        }

        // -----------------------------------------------------------------------
        // Helpers

        /**
         * Remove a plus-node indicator from the selector mc, if it is currently displayed.
         * nodeName is "mcPlusNodeSkills" or "mcPlusNodeTalisman".
         */
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
